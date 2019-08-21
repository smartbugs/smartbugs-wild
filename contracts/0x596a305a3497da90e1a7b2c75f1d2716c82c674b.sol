pragma solidity ^0.4.10;

// The NOTES ERC20 Token. There is a delay before addresses that are not added to the "activeGroup" can transfer tokens. 
// That delay ends when admin calls the "activate()"" function, or when "activateDate" is reached.
// Otherwise a generic ERC20 standard token.

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

// The standard ERC20 Token interface
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// NOTES Token Implementation - transfers are prohibited unless switched on by admin
contract Notes is Token {

    //// CONSTANTS

    // Number of NOTES
    uint256 public constant nFund = 80 * (10**6) * 10**decimals;

    // Token Metadata
    string public constant name = "NOTES";
    string public constant symbol = "NTS";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    //// PROPERTIES

    address admin;
    bool public activated = false;
    mapping (address => bool) public activeGroup;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) allowed;

    //// MODIFIERS

    modifier active()
    {
      require(activated || activeGroup[msg.sender]);
      _;
    }

    modifier onlyAdmin()
    {
      require(msg.sender == admin);
      _;
    }

    //// CONSTRUCTOR

    function Notes(address fund)
    {
      admin = msg.sender;
      totalSupply = nFund;
      balances[fund] = nFund;    // Deposit all to fund
      activeGroup[fund] = true;  // Allow the fund to transfer
    }

    //// ADMIN FUNCTIONS

    function addToActiveGroup(address a) onlyAdmin {
      activeGroup[a] = true;
    }

    function activate() onlyAdmin {
      activated = true;
    }

    //// TOKEN FUNCTIONS    

    function transfer(address _to, uint256 _value) active returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) active returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) active returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}