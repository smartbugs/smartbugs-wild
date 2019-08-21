pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title INT Coin (trade-mining coin)
 */


/**
 * @title ERC20 Standard Interface
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title INTCoin implementation
 */
contract INTCoin is IERC20 {
    string public name = "INT";
    string public symbol = "INT";
    uint8 public decimals = 18;
    
    uint256 preSaleAmount;
    uint256 mktAmount;
    uint256 rndAmount;
    uint256 teamAmount;
    uint256 miningAmount;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    // Admin Address
    address public owner;
    address public master;
    address public rnd;
    address public team;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        master = 0xdae5de7e76f6f2d7d91c984d76fa2deb7b025baa;
        rnd    = 0x15bB050a89081e95ebAb17b6921Fcfdc675395C2;
        team   = 0x216B46BB70D9E08B3078e8B564c62E263e240E91;
        require(owner != rnd);
        require(owner != team);

        preSaleAmount   = toWei(1250000000);  //1,250,000,000
        mktAmount       = toWei(875000000);   //875,000,000
        rndAmount       = toWei(312500000);   //312,500,000
        teamAmount      = toWei(937500000);   //937,500,000
        miningAmount    = toWei(3125000000);  //3,125,000,000
        _totalSupply    = toWei(6500000000);  //6,500,000,000

        require(_totalSupply == preSaleAmount + mktAmount + rndAmount + teamAmount + miningAmount);
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(rnd, rndAmount);
        transfer(team, teamAmount);
        require(balances[owner] == miningAmount + preSaleAmount + mktAmount);
        
        transfer(master, balances[owner]);
        require(balances[owner] == 0);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);
        //require(msg.sender != owner);   // owner is not free to transfer
        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow

        if(msg.sender == rnd) {
            require(now >= 1566662400);     // 100% lock to 2019-08-25
        }

        if(msg.sender == team) {
            require(now >= 1566662400);     // 100% lock to 2019-08-25
        }

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function burnCoins(uint256 value) public {
        require(msg.sender != owner);   // owner can't burn any coin
        require(balances[msg.sender] >= value);
        require(_totalSupply >= value);
        
        balances[msg.sender] -= value;
        _totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }

    function rndValance() public view returns (uint256) {
        return balances[rnd];
    }
    
    /** @dev private function
     */

    function toWei(uint256 value) private constant returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}