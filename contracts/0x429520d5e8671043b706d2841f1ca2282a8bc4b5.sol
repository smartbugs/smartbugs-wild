pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title ONBT token - Issued by OnBIT.
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
 * @title Token implementation
 */
contract ONBT is IERC20 {
    string public name = "OnBIT Token";
    string public symbol = "ONBT";
    uint8 public decimals = 18;
    
    uint256 exAmount;
    uint256 reserveAmount;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    address public owner;
    address public reserve;

    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        reserve   = 0x5BDd983b96AC7337e976f60229898Ae816fe2c47;

        exAmount        = toWei(4650000000);   // 4,650,000,000
        reserveAmount   = toWei(350000000);    //   350,000,000
        _totalSupply    = toWei(5000000000);   // 5,000,000,000

        require(_totalSupply == exAmount + reserveAmount );
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(reserve, reserveAmount);
        require(balances[owner] == exAmount);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);

        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow

        if(msg.sender == reserve) {
            require(now >= 1587600000);     // 350M lock to 2020-04-23
        }

        if (to == address(0) || to == address(0x1) || to == address(0xdead)) {
             _totalSupply -= value;
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

    function balanceOfOwner() public view returns (uint256) {
        return balances[owner];
    }
    
    /** @dev private function
     */

    function toWei(uint256 value) private constant returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}