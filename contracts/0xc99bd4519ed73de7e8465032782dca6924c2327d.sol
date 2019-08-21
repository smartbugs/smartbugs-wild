/* file: openzeppelin-solidity/contracts/ownership/Ownable.sol */
pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/* eof (openzeppelin-solidity/contracts/ownership/Ownable.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol */
pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol */
pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol */
pragma solidity ^0.4.24;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol) */
/* file: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

/* eof (openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol) */
/* file: openzeppelin-solidity/contracts/math/SafeMath.sol */
pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/* eof (openzeppelin-solidity/contracts/math/SafeMath.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

/* eof (openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/* eof (openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

/* eof (openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  /**
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
   * @param _cap Max amount of wei to be contributed
   */
  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(weiRaised.add(_weiAmount) <= cap);
  }

}

/* eof (openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol) */
/* file: openzeppelin-solidity/contracts/access/rbac/Roles.sol */
pragma solidity ^0.4.24;


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

/* eof (openzeppelin-solidity/contracts/access/rbac/Roles.sol) */
/* file: openzeppelin-solidity/contracts/access/rbac/RBAC.sol */
pragma solidity ^0.4.24;



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

/* eof (openzeppelin-solidity/contracts/access/rbac/RBAC.sol) */
/* file: openzeppelin-solidity/contracts/access/Whitelist.sol */
pragma solidity ^0.4.24;




/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if operator is not whitelisted.
   * @param _operator address
   */
  modifier onlyIfWhitelisted(address _operator) {
    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param _operator address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address _operator)
    public
    onlyOwner
  {
    addRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address _operator)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param _operators addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param _operator address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address _operator)
    public
    onlyOwner
  {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param _operators addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}

/* eof (openzeppelin-solidity/contracts/access/Whitelist.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Whitelist, Crowdsale {
  /**
   * @dev Extend parent behavior requiring beneficiary to be in whitelist.
   * @param _beneficiary Token beneficiary
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyIfWhitelisted(_beneficiary)
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/* eof (openzeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol */
pragma solidity ^0.4.24;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/* eof (openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/* eof (openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol) */
/* file: openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol */
pragma solidity ^0.4.24;



/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting.
 */
contract MintedCrowdsale is Crowdsale {

  /**
   * @dev Overrides delivery by minting tokens upon purchase.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Number of tokens to be minted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    // Potentially dangerous assumption about the type of the token.
    require(MintableToken(address(token)).mint(_beneficiary, _tokenAmount));
  }
}

/* eof (openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol */
pragma solidity ^0.4.24;



/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  constructor(
    ERC20Basic _token,
    address _beneficiary,
    uint256 _releaseTime
  )
    public
  {
    // solium-disable-next-line security/no-block-members
    require(_releaseTime > block.timestamp);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= releaseTime);

    uint256 amount = token.balanceOf(address(this));
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol) */
/* file: openzeppelin-solidity/contracts/lifecycle/Pausable.sol */
pragma solidity ^0.4.24;




/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/* eof (openzeppelin-solidity/contracts/lifecycle/Pausable.sol) */
/* file: ./contracts/ico/HbeCrowdsale.sol */
/**
 * @title HBE Crowdsale
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity 0.4.24;



// solhint-disable-next-line
contract HbeCrowdsale is CanReclaimToken, CappedCrowdsale, MintedCrowdsale, WhitelistedCrowdsale, FinalizableCrowdsale, Pausable {
    /*** PRE-DEPLOYMENT CONFIGURED CONSTANTS */
    address public constant ETH_WALLET = 0x9E35Ee118D9B305F27AE1234BF5c035c1860989C;
    address public constant TEAM_WALLET = 0x992CEad41b885Dc90Ef82673c3c211Efa1Ef1AE2;
    uint256 public constant START_EASTER_BONUS = 1555668000; // Friday, 19 April 2019 12:00:00 GMT+02:00
    uint256 public constant END_EASTER_BONUS = 1555970399;   // Monday, 22 April 2019 23:59:59 GMT+02:00
    /*** CONSTANTS ***/
    uint256 public constant ICO_HARD_CAP = 22e8;             // 2,200,000,000 tokens, 0 decimals spec v1.7
    uint256 public constant CHF_HBE_RATE = 0.0143 * 1e4;    // 0.0143 (.10/7) CHF per HBE Token
    uint256 public constant TEAM_HBE_AMOUNT = 200e6;        // spec v1.7 200,000,000 team tokens
    uint256 public constant FOUR = 4;            // 25%
    uint256 public constant TWO = 2;             // 50%
    uint256 public constant HUNDRED = 100;
    uint256 public constant ONE_YEAR = 365 days;
    uint256 public constant BONUS_DURATION = 14 days;   // two weeks
    uint256 public constant BONUS_1 = 15;   // set 1 - 15% bonus
    uint256 public constant BONUS_2 = 10;   // set 2 and Easter Bonus - 10% bonus
    uint256 public constant BONUS_3 = 5;    // set 3 - 5% bonus
    uint256 public constant PRECISION = 1e6; // precision to account for none decimals

    /*** VARIABLES ***/
    // marks team allocation as minted
    bool public isTeamTokensMinted;
    address[3] public teamTokensLocked;

    // allow managers to whitelist and confirm contributions by manager accounts
    // managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;

    uint256 public tokensMinted;    // total token supply that has been minted and sold. does not include team tokens
    uint256 public rateDecimals;    // # of decimals that the CHF/ETH rate came in as

    /*** EVENTS  ***/
    event ChangedManager(address indexed manager, bool active);
    event NonEthTokenPurchase(uint256 investmentType, address indexed beneficiary, uint256 tokenAmount);
    event RefundAmount(address indexed beneficiary, uint256 refundAmount);
    event UpdatedFiatRate(uint256 fiatRate, uint256 rateDecimals);

    /*** MODIFIERS ***/
    modifier onlyManager() {
        require(isManager[msg.sender], "not manager");
        _;
    }

    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    modifier onlyNoneZero(address _to, uint256 _amount) {
        require(_to != address(0), "invalid address");
        require(_amount > 0, "invalid amount");
        _;
    }

    /**
     * @dev constructor Deploy HBE Token Crowdsale
     * @param _startTime uint256 Start time of the crowdsale
     * @param _endTime uint256 End time of the crowdsale
     * @param _token ERC20 token address
     * @param _rate current CHF per ETH rate
     * @param _rateDecimals the # of decimals contained in the _rate variable
     */
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        address _token,
        uint256 _rate,
        uint256 _rateDecimals
        )
        public
        Crowdsale(_rate, ETH_WALLET, ERC20(_token))
        TimedCrowdsale(_startTime, _endTime)
        CappedCrowdsale(ICO_HARD_CAP) {
            setManager(msg.sender, true);
            _updateRate(_rate, _rateDecimals);
        }

    /**
     * @dev Allow manager to update the exchange rate when necessary.
     * @param _rate uint256 current CHF per ETH rate
     * @param _rateDecimals the # of decimals contained in the _rate variable
     */
    function updateRate(uint256 _rate, uint256 _rateDecimals) external onlyManager {
        _updateRate(_rate, _rateDecimals);
    }

    /**
    * @dev create 3 token lockup contracts for X years to be released to the TEAM_WALLET
    */
    function mintTeamTokens() external onlyManager {
        require(!isTeamTokensMinted, "team tokens already minted");

        isTeamTokensMinted = true;

        TokenTimelock team1 = new TokenTimelock(ERC20Basic(token), TEAM_WALLET, openingTime.add(ONE_YEAR));
        TokenTimelock team2 = new TokenTimelock(ERC20Basic(token), TEAM_WALLET, openingTime.add(2 * ONE_YEAR));
        TokenTimelock team3 = new TokenTimelock(ERC20Basic(token), TEAM_WALLET, openingTime.add(3 * ONE_YEAR));

        teamTokensLocked[0] = address(team1);
        teamTokensLocked[1] = address(team2);
        teamTokensLocked[2] = address(team3);

        _deliverTokens(address(team1), TEAM_HBE_AMOUNT.div(FOUR));
        _deliverTokens(address(team2), TEAM_HBE_AMOUNT.div(FOUR));
        _deliverTokens(address(team3), TEAM_HBE_AMOUNT.div(TWO));
    }

    /**
    * @dev onlyManager allowed to handle batches of non-ETH investments
    * @param _investmentTypes uint256[] array of ids to identify investment types IE: BTC, CHF, EUR, etc...
    * @param _beneficiaries address[]
    * @param _amounts uint256[]
    */
    function batchNonEthPurchase(uint256[] _investmentTypes, address[] _beneficiaries, uint256[] _amounts) external {
        require(_beneficiaries.length == _amounts.length && _investmentTypes.length == _amounts.length, "length !=");

        for (uint256 i; i < _beneficiaries.length; i = i.add(1)) {
            nonEthPurchase(_investmentTypes[i], _beneficiaries[i], _amounts[i]);
        }
    }

    /**
    * @dev return the array of 3 token lock contracts for the HBE Team
    */
    function getTeamLockedContracts() external view returns (address[3]) {
        return teamTokensLocked;
    }

    /** OVERRIDE
    * @dev low level token purchase
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // calculate a wei refund, if any, since decimal place is 0
        // update weiAmount if refund is > 0
        weiAmount = weiAmount.sub(refundLeftOverWei(weiAmount, tokens));

        // calculate bonus, if in bonus time period(s)
        tokens = tokens.add(_calcBonusAmount(tokens));

        // update state
        weiRaised = weiRaised.add(weiAmount);
        //push to investments array
        _processPurchase(_beneficiary, tokens);
        // throw event
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        // forward wei to the wallet
        _forwardFunds(weiAmount);
    }

    /** OVERRIDE - change to tokensMinted from weiRaised
    * @dev Checks whether the cap has been reached.
    * only active if a cap has been set
    * @return Whether the cap was reached
    */
    function capReached() public view returns (bool) {
        return tokensMinted >= cap;
    }

    /**
     * @dev Set / alter manager / whitelister "account". This can be done from owner only
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }

    /** OVERRIDE
    * @dev add an address to the whitelist
    * @param _address address
    * @return true if the address was added to the whitelist, false if the address was already in the whitelist
    */
    function addAddressToWhitelist(address _address)
        public
        onlyManager
    {
        addRole(_address, ROLE_WHITELISTED);
    }

    /** OVERRIDE
    * @dev remove an address from the whitelist
    * @param _address address
    * @return true if the address was removed from the whitelist,
    * false if the address wasn't in the whitelist in the first place
    */
    function removeAddressFromWhitelist(address _address)
        public
        onlyManager
    {
        removeRole(_address, ROLE_WHITELISTED);
    }

    /** OVERRIDE
    * @dev remove addresses from the whitelist
    * @param _addresses addresses
    * @return true if at least one address was removed from the whitelist,
    * false if all addresses weren't in the whitelist in the first place
    */
    function removeAddressesFromWhitelist(address[] _addresses)
        public
        onlyManager
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** OVERRIDE
    * @dev add addresses to the whitelist
    * @param _addresses addresses
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */
    function addAddressesToWhitelist(address[] _addresses)
        public
        onlyManager
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    /**
    * @dev onlyManager allowed to allocate non-ETH investments during the crowdsale
    * @param _investmentType uint256
    * @param _beneficiary address
    * @param _tokenAmount uint256
    */
    function nonEthPurchase(uint256 _investmentType, address _beneficiary, uint256 _tokenAmount) public
        onlyManager
        onlyWhileOpen
        onlyNoneZero(_beneficiary, _tokenAmount)
    {
        _processPurchase(_beneficiary, _tokenAmount);
        emit NonEthTokenPurchase(_investmentType, _beneficiary, _tokenAmount);
    }

    /** OVERRIDE
    * @dev called by the manager to pause, triggers stopped state
    */
    function pause() public onlyManager whenNotPaused onlyWhileOpen {
        paused = true;
        emit Pause();
    }

    /** OVERRIDE
    * @dev called by the manager to unpause, returns to normal state
    */
    function unpause() public onlyManager whenPaused {
        paused = false;
        emit Unpause();
    }

    /** OVERRIDE
    * @dev onlyManager allows tokens to be tradeable transfers HBE Token ownership back to owner
    */
    function finalize() public onlyManager {
        Pausable(address(token)).unpause();
        Ownable(address(token)).transferOwnership(owner);

        super.finalize();
    }

    /*** INTERNAL/PRIVATE FUNCTIONS ***/
    /** OVERRIDE - do not call super.METHOD
    * @dev Validation of an incoming purchase. Use require statements to revert
    * state when conditions are not met. Use super to concatenate validations.
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        onlyWhileOpen
        whenNotPaused
        onlyIfWhitelisted(_beneficiary) {
            require(_weiAmount != 0, "invalid amount");
            require(!capReached(), "cap has been reached");
        }

    /** OVERRIDE
    * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
    * @param _beneficiary Address receiving the tokens
    * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        tokensMinted = tokensMinted.add(_tokenAmount);
        // respect the token cap
        require(tokensMinted <= cap, "tokensMinted > cap");
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /** OVERRIDE
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate).div(rateDecimals).div(1e18).div(PRECISION);
    }

    /**
    * @dev calculate the bonus amount pending on time
    */
    function _calcBonusAmount(uint256 _tokenAmount) internal view returns (uint256) {
        uint256 currentBonus;

        /* solhint-disable */
        if (block.timestamp < openingTime.add(BONUS_DURATION)) {
            currentBonus = BONUS_1;
        } else if (block.timestamp < openingTime.add(BONUS_DURATION.mul(2))) {
            currentBonus = BONUS_2;
        } else if (block.timestamp < openingTime.add(BONUS_DURATION.mul(3))) {
            currentBonus = BONUS_3;
        } else if (block.timestamp >= START_EASTER_BONUS && block.timestamp < END_EASTER_BONUS) {
            currentBonus = BONUS_2;
        }
        /* solhint-enable */

        return _tokenAmount.mul(currentBonus).div(HUNDRED);
    }

    /**
     * @dev calculate wei refund to investor, if any. This handles rounding errors
     * which are important here due to the 0 decimals
     * @param _weiReceived uint256 wei received from the investor
     * @param _tokenAmount uint256 HBE tokens minted for investor
     */
    function refundLeftOverWei(uint256 _weiReceived, uint256 _tokenAmount) internal returns (uint256 refundAmount) {
        uint256 weiInvested = _tokenAmount.mul(1e18).mul(PRECISION).mul(rateDecimals).div(rate);

        if (weiInvested < _weiReceived) {
            refundAmount = _weiReceived.sub(weiInvested);
        }

        if (refundAmount > 0) {
            msg.sender.transfer(refundAmount);
            emit RefundAmount(msg.sender, refundAmount);
        }

        return refundAmount;
    }

    /** OVERRIDE
    * @dev Determines how ETH is stored/forwarded on purchases.
    * @param _weiAmount uint256
    */
    function _forwardFunds(uint256 _weiAmount) internal {
        wallet.transfer(_weiAmount);
    }

    /**
     * @dev Allow manager to update the exchange rate when necessary.
     * @param _rate uint256
     * @param _rateDecimals the # of decimals contained in the _rate variable
     */
    function _updateRate(uint256 _rate, uint256 _rateDecimals) internal {
        require(_rateDecimals <= 18);

        rateDecimals = 10**_rateDecimals;
        rate = (_rate.mul(1e4).mul(PRECISION).div(CHF_HBE_RATE));

        emit UpdatedFiatRate(_rate, _rateDecimals);
    }
}

/* eof (./contracts/ico/HbeCrowdsale.sol) */