pragma solidity 0.4.24;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


interface token {
    function transfer(address to, uint tokens) external;
    function balanceOf(address tokenOwner) external returns(uint balance);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    event tokensBought(address _addr, uint _amount);
    event tokensCalledBack(uint _amount);
    event privateSaleEnded(uint _time);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }

}


contract Crowdsale is Owned{
    using SafeMath for uint;
    
    uint public start;
    uint public end;
    uint public phaseOneLimit;
    uint public phaseTwoLimit;
    uint public phaseThreeLimit;
    uint public levelOneBonus;
    uint public levelTwoBonus;
    uint public levelThreeBonus;
    uint public softCap;
    uint public hardCap;
    bool public hardCapReached;
    
    mapping (address => address) public refers;
    
    mapping (address => uint) public etherHoldings;
    mapping (address => uint) public tokenHoldings;
    
    token public rewardToken;
    
    constructor() public{
        start = now;
        end = now.safeAdd(112 days);
        rewardToken = token(0x64d431354f27009965b163f7e6cdb60700ad5d12);
        phaseOneLimit = 10000 ether;
        phaseTwoLimit = 30000 ether;
        phaseThreeLimit = 50000 ether;
        levelOneBonus = 3;
        levelTwoBonus = 2;
        levelThreeBonus = 1;
        softCap = 10000 ether;
        hardCap = 50000 ether;
    }
    
    modifier stillActive{
        require(address(this).balance <= phaseThreeLimit && now <= end);
        _;
    }
    
    function returnETher(address _addr) view public returns(uint){
        return etherHoldings[_addr];
    }
    
    function () public payable stillActive{
        require(msg.value != 0);
        uint cb = address(this).balance;
        address buyer = msg.sender;
        uint buyamount = msg.value;
        uint tokens;
        if(cb <= phaseOneLimit){
            tokens = buyamount * 2000;
        }
        if(cb <= phaseTwoLimit && cb > phaseOneLimit){
            tokens = buyamount * 1500;
        }
        if(cb <= phaseThreeLimit && cb > phaseTwoLimit ){
            tokens = buyamount * 1000;
        }
        etherHoldings[buyer] += msg.value;
        tokenHoldings[buyer] += tokens;
        
    }
    
    
    function buyWithReferral(address _addr) public payable stillActive{
        require(msg.sender != _addr);
        require(msg.value != 0);
        uint cb = address(this).balance;
        address buyer = msg.sender;
        uint buyamount = msg.value;
        uint tokens;
        refers[buyer] = _addr;
        address ref1 = _addr;
        address ref2 = refers[ref1];
        address ref3 = refers[ref2];
        
        
        if(cb <= phaseOneLimit){
            tokens = buyamount * 2000;
        }
        if(cb <= phaseTwoLimit && cb > phaseOneLimit){
            tokens = buyamount * 1500;
        }
        if(cb <= phaseThreeLimit && cb > phaseTwoLimit ){
            tokens = buyamount * 1000;
        }
        
        etherHoldings[buyer] += buyamount;
        tokenHoldings[buyer] += tokens;

        uint reftok1 = tokens/uint(100);
        reftok1 = reftok1 * 5;
        reftok1 = reftok1;
        tokenHoldings[ref1] += reftok1;

        
        if(ref2 != 0){
        uint reftok2 = tokens/uint(100);
        reftok2 = reftok2 * 3;
        reftok2 = reftok2;
        tokenHoldings[ref2] += reftok2;
        }
        
        if(ref3 != 0){
        uint reftok3 = tokens/uint(100);
        reftok3 = reftok3 * 1;
        reftok3 = reftok3;
        tokenHoldings[ref3] += reftok3;
        }
        
    }
    
    modifier saleSuccessful{
        require(now > end);
        _;
    }
    
    modifier saleFailed{
        require (now > end && address(this).balance < softCap );
        _;
    }
    
    function releaseTokens() public {
        uint tokens = tokenHoldings[msg.sender];
        if(tokens <= 0){
            revert();
        }
        rewardToken.transfer(msg.sender, tokens);
        tokenHoldings[msg.sender] = 0;
    }
    
    
    function releaseEthers() public saleFailed{
        uint ethers = etherHoldings[msg.sender];
        if(ethers <= 0){
            revert();
        }
        msg.sender.transfer(ethers);
        etherHoldings[msg.sender] = 0;
        
    }
    
    modifier softCapReached{
        require(address(this).balance >= softCap);
        _;
    }
    
    function safeWithdrawal() public onlyOwner softCapReached {
        uint amount = address(this).balance;
        owner.transfer(amount);
        
    }
    

    function withdrawTokens() public onlyOwner saleSuccessful{
        uint Ownerbalance = rewardToken.balanceOf(this);
    	rewardToken.transfer(owner, Ownerbalance);
    }
    
    
}