pragma solidity ^0.4.19;

contract Token {
   
    uint256 public totalSupply;

    
    function balanceOf(address _owner) public constant returns (uint256 balance);

   
    function transfer(address _to, uint256 _value) public returns (bool success);

  
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  
    function approve(address _spender, uint256 _value) public returns (bool success);

  
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library SafeMath 
{
  function mul(uint256 a, uint256 b) internal constant returns (uint256) 
  {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract StandardToken is Token {
using SafeMath for uint256;
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
       require(
         balances[msg.sender] >= _value
         && _value > 0
         );
          balances[msg.sender]=balances[msg.sender].sub(_value);
           balances[_to]=balances[_to].add(_value);
          Transfer(msg.sender,_to,_value);
          return true;
      
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       
       require(
         allowed[_from][msg.sender] >= _value
         &&  balances[_from]>=_value
         &&  _value > 0
         );
          balances[_from]= balances[_from].sub(_value);
           balances[_to]=balances[_to].add(_value);
         allowed[_from][msg.sender] = allowed[_from][msg.sender].sub( _value);
        Transfer(_from,_to,_value);
          return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract Owned {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _owner) public onlyOwner {
        require(_owner != 0x0);
        owner = _owner;
    }
}

contract Crypton is StandardToken, Owned {
    string public name = "Crypton";
    uint256 public decimals = 18;
    string public symbol = "CRP";
   
    
    function Crypton() public {
      
       totalSupply = 100000000e18;
        balances[msg.sender] = totalSupply;
    }

    function() public payable {
        revert();
    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if (!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { 
            revert(); 
        }
        return true;
    }
}