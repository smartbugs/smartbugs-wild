pragma solidity ^0.4.18;


contract Token {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    string public description;
    uint8 public decimals;
    string public logoURL;
    string public name;
    string public symbol;
    uint public totalSupply;

    address public creator;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Created(address creator, uint supply);

    function Token(
        string _description,
        string _logoURL,
        string _name,
        string _symbol,
        uint256 _totalSupply
    ) public
    {
        description = _description;
        logoURL = _logoURL;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _totalSupply;

        creator = tx.origin;
        Created(creator, _totalSupply);
        balances[creator] = _totalSupply;
    }

    // Don't let people randomly send ETH to contract
    function() public payable {
        revert();
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function setLogoURL(string url) public {
        require(msg.sender == creator);
        logoURL = url;
    }
}

// Sample constructor args
// "0x54686520746f6b656e20666f7220617765736f6d652070656f706c652e", "0x68747470733a2f2f692e696d6775722e636f6d2f5a336871756c492e6a7067", "0x417765736f6d6520546f6b656e", "0x415745", "0x52b7d2dcc80cd2e4000000"

contract Coinsling {

    address public owner;

    function Coinsling() public {
        owner = msg.sender;
    }

    event TokenCreated(address token);
    function sling(
        string _description,
        string _logoURL,
        string _name,
        string _symbol,
        uint   _totalSupply
    ) public payable returns (Token token)
    {
        token = new Token(
            _description,
            _logoURL,
            _name,
            _symbol,
            _totalSupply
        );

        TokenCreated(token);
        return token;
    }

    // This allows me to collect the revenue paid into the contract
    function transfer(uint amount, address to) public {
        require(msg.sender == owner);
        to.transfer(amount);
    }
}