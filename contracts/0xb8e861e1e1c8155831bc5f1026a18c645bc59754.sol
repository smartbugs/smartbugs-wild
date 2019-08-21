pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

   function mul(uint256 a, uint256 b) internal constant returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
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

   function min256(uint256 a, uint256 b) internal constant returns (uint256) {
      return a < b ? a : b;
   }
}

/**
 * @title ERC20 interface
 *
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Token {

   uint256 public totalSupply;
   function balanceOf(address _owner) constant returns (uint256 balance);
   function transfer(address _to, uint256 _value) returns (bool success);
   function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
   function approve(address _spender, uint256 _value) returns (bool success);
   function allowance(address _owner, address _spender) constant returns (uint256 remaining);
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title ERC20 implementation
 *
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 * @dev Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */
contract StandardToken is ERC20Token {
   using SafeMath for uint256;

   mapping (address => uint256) balances;
   mapping (address => mapping (address => uint256)) allowed;

   /**
    * @dev gets the balance of the specified address
    * @param _owner The address to query the balance of
    * @return uint256 The balance of the passed address
    */
   function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
   }

   /**
    * @dev transfer tokens to the specified address
    * @param _to The address to transfer to
    * @param _value The amount to be transferred
    * @return bool A successful transfer returns true
    */
   function transfer(address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));

      // SafeMath.sub will throw if there is not enough balance.
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
   }

   /**
    * @dev transfer tokens from one address to another
    * @param _from address The address that you want to send tokens from
    * @param _to address The address that you want to transfer to
    * @param _value uint256 The amount to be transferred
    * @return bool A successful transfer returns true
    */
   function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));

      uint256 _allowance = allowed[_from][msg.sender];
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = _allowance.sub(_value);
      Transfer(_from, _to, _value);
      return true;
   }

   /**
    * @dev approve the passed address to spend the specified amount of tokens
    * @dev Note that the approved value must first be set to zero in order for it to be changed
    * @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address that will spend the funds
    * @param _value The amount of tokens to be spent
    * @return bool A successful approval returns true
    */
   function approve(address _spender, uint256 _value) returns (bool success) {

     //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     require((_value == 0) || (allowed[msg.sender][_spender] == 0));

     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

   /**
    * @dev gets the amount of tokens that an owner has allowed an address to spend
    * @param _owner The address that owns the funds
    * @param _spender The address that will spend the funds
    * @return uint256 The amount that is available to spend
    */
   function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
     return allowed[_owner][_spender];
   }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
   address public owner;

   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
   function Ownable() {
      owner = msg.sender;
   }

   /**
   * @dev Throws if called by any account other than the owner.
   */
   modifier onlyOwner() {
      require(msg.sender == owner);
      _;
   }

   /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
   function transferOwnership(address newOwner) onlyOwner {
      require(newOwner != address(0));
      OwnershipTransferred(owner, newOwner);
      owner = newOwner;
   }
}


/**
 * @title Token holder contract
 *
 * @dev Allow the owner to transfer any ERC20 tokens accidentally sent to the contract address
 */
contract TokenHolder is Ownable {

    /**
     * @dev transfer tokens to the specified address
     * @param _tokenAddress The address to transfer to
     * @param _amount The amount to be transferred
     * @return bool A successful transfer returns true
     */
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
        return ERC20Token(_tokenAddress).transfer(owner, _amount);
    }
}


/**
 * @title Kudos Token
 * @author Ben Johnson
 *
 * @dev ERC20 Kudos Token (KUDOS)
 *
 * Kudos tokens are displayed using 18 decimal places of precision.
 *
 * The base units of Kudos tokens are referred to as "kutoas".
 *
 * In Swahili, kutoa means "to give".
 * In Finnish, kutoa means "to weave" or "to knit".
 *
 * 1 KUDOS is equivalent to:
 *
 *    1,000,000,000,000,000,000 == 1 * 10**18 == 1e18 == One Quintillion kutoas
 *
 *
 * All initial KUDOS kutoas are assigned to the creator of this contract.
 *
 */
contract KudosToken is StandardToken, Ownable, TokenHolder {

   string public constant name = "Kudos";
   string public constant symbol = "KUDOS";
   uint8 public constant decimals = 18;
   string public constant version = "1.0";

   uint256 public constant tokenUnit = 10 ** 18;
   uint256 public constant oneBillion = 10 ** 9;
   uint256 public constant maxTokens = 10 * oneBillion * tokenUnit;

   function KudosToken() {
      totalSupply = maxTokens;
      balances[msg.sender] = maxTokens;
   }
}