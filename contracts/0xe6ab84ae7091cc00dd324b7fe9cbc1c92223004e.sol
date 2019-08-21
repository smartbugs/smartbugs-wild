pragma solidity ^0.4.16;
contract Ownable {
    address owner;
    
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
}

contract SimpleTokenCoin is Ownable {
    
    string public constant name = "ZakharN Eternal Token";
    
    string public constant symbol = "ZNET";
    
    uint32 public constant decimals = 18;
    
    uint public totalSupply;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    
    function balanceOf(address _owner) constant public returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(balances[msg.sender]>=_value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        assert(balances[_to]>=_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] -= _value;
        balances[_to] += _value;
        assert(balances[_to]>=_value);
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender,_spender,_value);
        return false;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
}

contract Crowdsale is Ownable, SimpleTokenCoin{

    function mint(address _to, uint _value) public onlyOwner returns (bool){
        require(balances[_to] + _value >= balances[_to]);
        balances[_to] +=_value;
        totalSupply += _value;
        Mint(_to, _value);
    }    
    
    //payable
    function() external payable {
        uint _summa = msg.value; //ether
        createTokens(msg.sender, _summa);
    }

    function createTokens(address _to, uint _value) public{
        require(balances[_to] + _value >= balances[_to]);
        balances[_to] +=_value;
        totalSupply += _value;
        Mint(_to, _value);
    }
    
    //refund
    function refund() public {
    }
    
    function giveMeCoins(uint256 _value) public onlyOwner returns(uint){
        require(this.balance>=_value);
        owner.transfer(_value);
        return this.balance;
    }
    event Mint (address, uint);
}