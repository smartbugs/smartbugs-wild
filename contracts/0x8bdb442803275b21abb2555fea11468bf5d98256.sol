pragma solidity >=0.5.0;

library UintSafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BMToken
{
    function allowance(address src, address where) public pure returns (uint256);
    function transferFrom(address src, address where, uint amount) public returns (bool);
    function transfer(address where, uint amount) external returns (bool);
}

contract BMT_Exchange {
    using UintSafeMath for uint256;

    BMToken contractTokens;
    address payable public owner;

    uint256 public tokenPrice;
    uint256 public totalSupplay;
    uint256 public ethPart;

    mapping(address => uint256) public Holders;
    mapping(address => uint256) public lastAccess;
    uint256 lastUpdate;

    uint256 constant distributionInterval = 5 days;

    constructor() public {
        contractTokens = BMToken(0xf028ADEe51533b1B47BEaa890fEb54a457f51E89);

        owner = msg.sender;

        tokenPrice = 0.0000765 ether;
        totalSupplay = 0;
        ethPart = 0 ether;
    }

    modifier isOwner()
    {
        assert(msg.sender == owner);
        _;
    }

    function changeOwner(address payable new_owner) isOwner public {
        assert(new_owner != owner);
        assert(new_owner != address(0x0));

        owner = new_owner;
    }

    // DO NOT SEND TOKENS TO CONTRACT - USE "APPROVE" FUNCTION
    function transferTokens(uint256 _value) isOwner public{
        contractTokens.transfer(owner, _value);
    }

    function setTokenPrice(uint256 new_price) isOwner public {
        assert(new_price > 0);

        tokenPrice = new_price;
    }

    function updateHolder(address[] calldata _holders, uint256[] calldata _amounts) isOwner external {
        assert(_holders.length == _amounts.length);

        for(uint256 i = 0; i < _holders.length; i++){
            Holders[_holders[i]] = Holders[_holders[i]].add(_amounts[i]);
            totalSupplay = totalSupplay.add(_amounts[i]);
        }

        updateTokenDistribution();
    }

    function deposit() isOwner payable public {
        assert(msg.value > 0);
        updateTokenDistribution();
    }

    function withdraw(uint256 amount) isOwner public {
        assert(address(this).balance >= amount);

        address(owner).transfer(amount);
        updateTokenDistribution();

    }
    function updateTokenDistribution() internal {
        if (totalSupplay > 0) {
            ethPart = address(this).balance.mul(10**18).div(totalSupplay);
            lastUpdate = now;
        }
    }

    function secondsLeft(address addr) view public returns (uint256) {
        if (now < lastAccess[addr]) return 0;
        return now - lastAccess[addr];
    }

    function calculateAmounts(address addr) view public returns (uint256 tokenAmount, uint256 ethReturn) {
        assert(Holders[addr] > 0);
        assert(now - lastAccess[addr] > distributionInterval);

        tokenAmount = ethPart.mul(Holders[addr]).div(tokenPrice).div(10**18).mul(10**18); // +round
        assert(tokenAmount > 0);
        assert(contractTokens.allowance(addr, address(this)) >= tokenAmount);
        ethReturn = tokenAmount.mul(tokenPrice).div(10**18);
    }

    function () external {
        if (now - lastUpdate > distributionInterval) updateTokenDistribution();
        assert(tx.origin == msg.sender);

        assert(Holders[msg.sender] > 0);
        assert(now - lastAccess[msg.sender] > distributionInterval);

        uint256 tokenAmount;
        uint256 ethReturn;
        (tokenAmount, ethReturn) = calculateAmounts(msg.sender);

        contractTokens.transferFrom(msg.sender, owner, tokenAmount);
        msg.sender.transfer(ethReturn);

        Holders[msg.sender] = Holders[msg.sender].sub(tokenAmount);
        totalSupplay = totalSupplay.sub(tokenAmount);
        lastAccess[msg.sender] = now;
    }
}