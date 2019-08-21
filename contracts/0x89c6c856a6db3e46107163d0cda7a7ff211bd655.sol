pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}










/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}



/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
  }
}









/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}





/**
* @title Allowable
* @dev The Allowable contract provides basic functionality to authorize
* only allowed addresses to action.
*/
contract Allowable is Ownable {

    // Contains details regarding allowed addresses
    mapping (address => bool) public permissions;

    /**
    * @dev Reverts if an address is not allowed. Can be used when extending this contract.
    */
    modifier isAllowed(address _operator) {
        require(permissions[_operator] || _operator == owner);
        _;
    }

    /**
    * @dev Adds single address to the permissions list. Allowed only for contract owner.
    * @param _operator Address to be added to the permissions list
    */
    function allow(address _operator) external onlyOwner {
        permissions[_operator] = true;
    }

    /**
    * @dev Removes single address from an permissions list. Allowed only for contract owner.  
    * @param _operator Address to be removed from the permissions list
    */
    function deny(address _operator) external onlyOwner {
        permissions[_operator] = false;
    }
}




/**
 * @title Operable
 * @dev The Operable contract has an operator address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Operable is Ownable {
    address public operator;

    event OperatorRoleTransferred(address indexed previousOperator, address indexed newOperator);


    /**
    * @dev The Operable constructor sets the original `operator` of the contract to the sender
    * account.
    */
    function Operable() public {
        operator = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer operator role to a newOperator.
    * @param newOperator The address to transfer Operator role to.
    */
    function transferOperatorRole(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        OperatorRoleTransferred(operator, newOperator);
        operator = newOperator;
    }
}


/**
* @title DaricoEcosystemToken
* @dev The DaricoEcosystemToken (DEC) is a ERC20 token.
* DEC volume is pre-minted and distributed to a set of pre-configurred wallets according the following rules:
*   120000000 - total tokens
*   72000000 - tokens for sale
*   18000000 - reserved tokens
*   18000000 - tokens for the team
*   12000000 - tokens for marketing needs
* DEC supports burn functionality to destroy tokens left after sale. 
* Burn functionality is limited to Operator role that belongs to sale contract
* DEC is disactivated by default, which means initially token transfers are allowed to a limited set of addresses. 
* Activation functionality is limited to Owner role. After activation token transfers are not limited
*/
contract DaricoEcosystemToken is BurnableToken, StandardToken, Allowable, Operable {
    using SafeMath for uint256;

    // token name
    string public constant name= "Darico Ecosystem Coin";
    // token symbol
    string public constant symbol= "DEC";
    // supported decimals
    uint256 public constant decimals = 18;

    //initially tokens locked for any transfers
    bool public isActive = false;

    /**
    * @param _saleWallet Wallet to hold tokens for sale 
    * @param _reserveWallet Wallet to hold tokens for reserve 
    * @param _teamWallet Wallet to hold tokens for team 
    * @param _otherWallet Wallet to hold tokens for other needs  
    */
    function DaricoEcosystemToken(address _saleWallet, 
                                  address _reserveWallet, 
                                  address _teamWallet, 
                                  address _otherWallet) public {
        totalSupply_ = uint256(120000000).mul(10 ** decimals);

        configureWallet(_saleWallet, uint256(72000000).mul(10 ** decimals));
        configureWallet(_reserveWallet, uint256(18000000).mul(10 ** decimals));
        configureWallet(_teamWallet, uint256(18000000).mul(10 ** decimals));
        configureWallet(_otherWallet, uint256(12000000).mul(10 ** decimals));
    }

    /**
    * @dev checks if address is able to perform token operations
    * @param _from The address that owns tokens, to check over permissions list
    */ 
    modifier whenActive(address _from){
        if (!permissions[_from]) {            
            require(isActive);            
        }
        _;
    }

    /**
    * @dev Activate tokens. Can be executed by contract Owner only.
    */
    function activate() onlyOwner public {
        isActive = true;
    }

    /**
    * @dev transfer token for a specified address, validates if there are enough unlocked tokens
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public whenActive(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Transfer tokens from one address to another, validates if there are enough unlocked tokens
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public whenActive(_from) returns (bool) {        
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Burns a specific amount of tokens. Can be executed by contract Operator only.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public onlyOperator {
        super.burn(_value);
    }

    /**
    * @dev Sends tokens to a specified wallet
    */
    function configureWallet(address _wallet, uint256 _amount) private {
        require(_wallet != address(0));
        permissions[_wallet] = true;
        balances[_wallet] = _amount;
        Transfer(address(0), _wallet, _amount);
    }
}