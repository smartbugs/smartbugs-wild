pragma solidity ^0.4.23;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract owned{

    address public owner;

    constructor ()public{
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
}

contract Erc20Token {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract NausiCoin is Erc20Token, owned {

    string public name;
    string public symbol;
    uint public decimals;

    uint _totalSupply;
    mapping(address => uint) _balanceOf;
    mapping(address => mapping(address => uint)) _allowance;

    event Burn(address indexed from, uint amount);
    event Mint(address indexed from, uint amount);
    
    constructor(string tokenName, string tokenSymbol, uint tokenDecimals, uint tokenTotalSupply) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;

        _totalSupply = tokenTotalSupply * 10**uint(decimals);
        _balanceOf[msg.sender] = _totalSupply;
    }

    function totalSupply() public view returns (uint){
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance){
        return _balanceOf[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return _allowance[tokenOwner][spender];
    }

    function transfer(address to, uint value) public returns (bool success){
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool success){
        require(_allowance[from][msg.sender] >= value);
        
        _allowance[from][msg.sender] -= value;
        _transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint value) public returns (bool succes) {
        _allowance[msg.sender][spender] = value;
        return true;
    }

    function approveAndCall(address spender, uint value, bytes extraData) public returns (bool success){
        tokenRecipient _spender = tokenRecipient(spender);
        if(approve(spender, value)){
            _spender.receiveApproval(msg.sender, value, this, extraData);
            return true;
        }
    }

    function burnFrom(address from, uint amount) public onlyOwner returns(bool success) {
        require(_balanceOf[from] >= amount);
        require(_balanceOf[from] - amount <= _balanceOf[from]);

        if(owner != from){
            require(_allowance[msg.sender][from] >= amount);
        }

        _balanceOf[from] -= amount;
        _allowance[msg.sender][from] -= amount;
        _totalSupply -= amount;

        emit Burn(from, amount);

        return true;
    }

    function mintTo(address to, uint amount) public onlyOwner returns(bool success){
        require(_balanceOf[to] + amount >= _balanceOf[to]);
        require(_totalSupply + amount >= _totalSupply);

        _balanceOf[to] += amount;
        _totalSupply += amount;

        emit Mint(to, amount);

        return true;
    }

    function() public payable {
        require(false);
    }

    function _transfer(address from, address to, uint value) internal{
        require(to != 0x0);
        require(_balanceOf[from] >= value);
        require(_balanceOf[to] + value >= _balanceOf[to]);

        uint previousBalance = _balanceOf[from] + _balanceOf[to];

        _balanceOf[from] -= value;
        _balanceOf[to] += value;

        emit Transfer(from, to, value);

        assert(_balanceOf[from] + _balanceOf[to] == previousBalance);
    }
}