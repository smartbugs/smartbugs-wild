pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'V-KITA' token contract
// Symbol      : KITA
// Name        : V-KITA
// Decimals    : 8
//
// 2019 | By V-KITA IDTeam
// ----------------------------------------------------------------------------

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract VKITAToken {
    using SafeMath for uint256;
    address owner = msg.sender;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    // Balances for each account
    mapping (address => uint256) public balanceOf;
    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) public allowance;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    constructor() public {
        symbol = "KITA";
        name = "V-KITA";
        decimals = 8;
        _totalSupply = 45000000 * 9**uint(decimals);
        balanceOf[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balanceOf[address(0)]);
    }
    function balanceOf(address _owner) constant public returns (uint256) {
        return balanceOf[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(this));
        require(_value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub (_value);
        balanceOf[_to] = balanceOf[_to].add (_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    // A contract attempts to get the coins   
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(this));
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] = balanceOf[_from].sub (_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub (_value);
        balanceOf[_to] = balanceOf[_to].add (_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
     // Allow another contract to spend some tokens in your behalf
    function approve(address _spender, uint256 _value) public returns (bool success) {
    require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowance[_owner][_spender];
    }
}