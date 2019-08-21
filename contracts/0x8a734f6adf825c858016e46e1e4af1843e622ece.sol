pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
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
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
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

// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

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
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

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
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

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
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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
    hasMintPermission
    canMint
    public
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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
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
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/CarryToken.sol

// The Carry token and the tokensale contracts
// Copyright (C) 2018 Carry Protocol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity ^0.4.24;




contract CarryToken is PausableToken, CappedToken, BurnableToken {
    string public name = "CarryToken";
    string public symbol = "CRE";
    uint8 public decimals = 18;

    // See also <https://carryprotocol.io/#section-token-distribution>.
    //                10 billion <---------|   |-----------------> 10^18
    uint256 constant TOTAL_CAP = 10000000000 * (10 ** uint256(decimals));

    constructor() public CappedToken(TOTAL_CAP) {
    }
}

// File: contracts/CarryPublicTokenCrowdsale.sol

// The Carry token and the tokensale contracts
// Copyright (C) 2018 Carry Protocol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity ^0.4.24;





/**
 * @title CarryPublicTokenCrowdsale
 * @dev The Carry token public sale contract.
 */
contract CarryPublicTokenCrowdsale is CappedCrowdsale, Pausable {
    using SafeMath for uint256;

    uint256 constant maxGasPrice = 40000000000;  // 40 gwei

    // Individual min purchases.
    uint256 public individualMinPurchaseWei;

    struct IndividualMaxCap {
        uint256 timestamp;
        uint256 maxWei;
    }

    // Individual max purchases differ by time.  The mapping keys are timestamps
    // and values are weis an individual can purchase at most
    // If the transaction is made later than a timestamp it can accept
    // the corresponding cap at most.
    //
    // Where individualMaxCaps = [
    //   IndividualMaxCap(1533081600, 5 ether),
    //   IndividualMaxCap(1533686400, 10 ether)
    // ]
    // If a transaction is made before 1533081600 (2018-08-01 sharp UTC)
    // it disallows any purchase.
    // If a transaction is made between 1533081600 (2018-08-01 sharp UTC)
    // 1533686400 (2018-08-08 sharp UTC) it takes 5 ethers at most.
    // If a transaction is made after 1533686400 (2018-08-08 sharp UTC)
    // it takes 10 ethers at most.
    IndividualMaxCap[] public individualMaxCaps;

    mapping(address => uint256) public contributions;

    // Each index represents the grade (the order is arbitrary) and its value
    // represents a timestamp when people (i.e., addresses) belonging to that
    // grade becomes available to purchase tokens.  Note that the first value
    // (i.e., whitelistGrades[0]) must be zero since the index 0 must represent
    // the state of "not whitelisted."
    //
    // The index numbers are used by the whitelist mapping (see below).
    // As the key type of the whitelist mapping is uint8, there cannot be more
    // than 2^8 grades.
    uint256[] public whitelistGrades;

    // This mapping represents what grade each address belongs to.  Values are
    // an index number and refer to a grade (see the whitelistGrades array).
    // A special value 0 represents the predefined state that "it is not
    // whitelisted and does not belong to any grade."
    //
    // Where whitelistGrades = [0, 1533686400, 1533081600]
    //   and whitelist = [X => 2, Y => 1, Z => 0]
    //
    // X cannot purchase any tokens until 1533081600 (2018-08-01 sharp UTC),
    // but became to able to purchase tokens after that.
    // Y cannot purchase any tokens until 1533686400 (2018-08-08 sharp
    // UTC), but became to able to purchase tokens after that.
    // Z cannot purchase any tokens since it is not whitelisted and does not
    // belong to any grade.
    //
    // As values of a mapping in solidity are virtually all zeros by default,
    // addresses never associated by the whitelist mapping are not whitelisted
    // by default.
    mapping(address => uint8) public whitelist;

    // Token amounts people purchased.  Keys are an address and values are
    // CRE tokens (in minor units).  If X purchased 5 CRE it is represented as
    // [X => 5 * 10**18].
    mapping(address => uint256) public balances;

    // Whether to allow purchasers to withdraw their tokens.  Intended to be
    // false at first, and then become true at some point.
    bool public withdrawable;

    // The fixed due date (timestamp) of token delivery.  Even if withdrawable
    // if not set to true, since the due date purchasers become able to withdraw
    // tokens.  See also whenWithdrawable modifier below.
    uint256 public tokenDeliveryDue;

    mapping(address => uint256) public refundedDeposits;

    constructor(
        address _wallet,
        CarryToken _token,
        uint256 _rate,
        uint256 _cap,
        uint256 _tokenDeliveryDue,
        uint256[] _whitelistGrades,
        uint256 _individualMinPurchaseWei,

        // Since Solidity currently doesn't allows parameters to take array of
        // structs, we work around this by taking two arrays for each field
        // (timestmap and maxWei) separately.  It fails unless two arrays are
        // of equal length.
        uint256[] _individualMaxCapTimestamps,
        uint256[] _individualMaxCapWeis
    ) public CappedCrowdsale(_cap) Crowdsale(_rate, _wallet, _token) {
        require(
            _individualMaxCapTimestamps.length == _individualMaxCapWeis.length,
            "_individualMaxCap{Timestamps,Weis} do not have equal length."
        );
        tokenDeliveryDue = _tokenDeliveryDue;
        if (_whitelistGrades.length < 1) {
            whitelistGrades = [0];
        } else {
            require(
                _whitelistGrades.length < 0x100,
                "The grade number must be less than 2^8."
            );
            require(
                _whitelistGrades[0] == 0,
                "The _whitelistGrades[0] must be zero."
            );
            whitelistGrades = _whitelistGrades;
        }
        individualMinPurchaseWei = _individualMinPurchaseWei;
        for (uint i = 0; i < _individualMaxCapTimestamps.length; i++) {
            uint256 timestamp = _individualMaxCapTimestamps[i];
            require(
                i < 1 || timestamp > _individualMaxCapTimestamps[i - 1],
                "_individualMaxCapTimestamps have to be in ascending order and no duplications."
            );
            individualMaxCaps.push(
                IndividualMaxCap(
                    timestamp,
                    _individualMaxCapWeis[i]
                )
            );
        }
    }

    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    ) internal whenNotPaused {
        // Prevent gas war among purchasers.
        require(
            tx.gasprice <= maxGasPrice,
            "Gas price is too expensive. Don't be competitive."
        );

        super._preValidatePurchase(_beneficiary, _weiAmount);

        uint8 grade = whitelist[_beneficiary];
        require(grade > 0, "Not whitelisted.");
        uint openingTime = whitelistGrades[grade];
        require(
            // solium-disable-next-line security/no-block-members
            block.timestamp >= openingTime,
            "Currently unavailable to purchase tokens."
        );

        uint256 contribution = contributions[_beneficiary];
        uint256 contributionAfterPurchase = contribution.add(_weiAmount);

        // If a contributor already has purchased a minimum amount, say 0.1 ETH,
        // then they can purchase once again with less than a minimum amount,
        // say 0.01 ETH, because they have already satisfied the minimum
        // purchase.
        require(
            contributionAfterPurchase >= individualMinPurchaseWei,
            "Sent ethers is not enough."
        );

        // See also the comment on the individualMaxCaps above.
        uint256 individualMaxWei = 0;
        for (uint i = 0; i < individualMaxCaps.length; i++) {
            uint256 capTimestamp = individualMaxCaps[i].timestamp;
            // solium-disable-next-line security/no-block-members
            if (capTimestamp <= block.timestamp) {
                individualMaxWei = individualMaxCaps[i].maxWei;
            } else {
                // Optimize gas consumption by trimming timestamps no more used.
                if (i > 1) {
                    uint offset = i - 1;
                    uint trimmedLength = individualMaxCaps.length - offset;
                    for (uint256 j = 0; j < trimmedLength; j++) {
                        individualMaxCaps[j] = individualMaxCaps[offset + j];
                    }
                    individualMaxCaps.length = trimmedLength;
                }
                break;
            }
        }
        require(
            contributionAfterPurchase <= individualMaxWei,
            individualMaxWei > 0
                ? "Total ethers you've purchased is too much."
                : "Purchase is currently disallowed."
        );
    }

    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    ) internal {
        super._updatePurchasingState(_beneficiary, _weiAmount);
        contributions[_beneficiary] = contributions[_beneficiary].add(
            _weiAmount
        );
    }

    function addAddressesToWhitelist(
        address[] _beneficiaries,
        uint8 _grade
    ) external onlyOwner {
        require(_grade < whitelistGrades.length, "No such grade number.");
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = _grade;
        }
    }

    // Override to prevent immediate delivery of tokens.
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    ) internal {
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    }

    function setWithdrawable(bool _withdrawable) external onlyOwner {
        withdrawable = _withdrawable;
    }

    modifier whenWithdrawable() {
        require(
            // solium-disable-next-line security/no-block-members
            withdrawable || block.timestamp >= tokenDeliveryDue,
            "Currently tokens cannot be withdrawn."
        );
        _;
    }

    event TokenDelivered(address indexed beneficiary, uint256 tokenAmount);

    function _deliverTokens(address _beneficiary) internal {
        uint256 amount = balances[_beneficiary];
        if (amount > 0) {
            balances[_beneficiary] = 0;
            _deliverTokens(_beneficiary, amount);
            emit TokenDelivered(_beneficiary, amount);
        }
    }

    function withdrawTokens() public whenWithdrawable {
        _deliverTokens(msg.sender);
    }

    function deliverTokens(
        address[] _beneficiaries
    ) public onlyOwner whenWithdrawable {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _deliverTokens(_beneficiaries[i]);
        }
    }

    event RefundDeposited(
        address indexed beneficiary,
        uint256 tokenAmount,
        uint256 weiAmount
    );
    event Refunded(
        address indexed beneficiary,
        address indexed receiver,
        uint256 weiAmount
    );

    /**
     * @dev Refund the given ether to a beneficiary.  It only can be called by
     * either the contract owner or the wallet (i.e., Crowdsale.wallet) address.
     * The only amount of the ether sent together in a transaction is refunded.
     */
    function depositRefund(address _beneficiary) public payable {
        require(
            msg.sender == owner || msg.sender == wallet,
            "No permission to access."
        );
        uint256 weiToRefund = msg.value;
        require(
            weiToRefund <= weiRaised,
            "Sent ethers is higher than even the total raised ethers."
        );
        uint256 tokensToRefund = _getTokenAmount(weiToRefund);
        uint256 tokenBalance = balances[_beneficiary];
        require(
            tokenBalance >= tokensToRefund,
            "Sent ethers is higher than the ethers _beneficiary has purchased."
        );
        weiRaised = weiRaised.sub(weiToRefund);
        balances[_beneficiary] = tokenBalance.sub(tokensToRefund);
        refundedDeposits[_beneficiary] = refundedDeposits[_beneficiary].add(
            weiToRefund
        );
        emit RefundDeposited(_beneficiary, tokensToRefund, weiToRefund);
    }

    /**
     * @dev Receive one's refunded ethers in the deposit.  It can be called by
     * only a beneficiary of refunds.
     * It takes a parameter, a wallet address to receive the deposited
     * (refunded) ethers.  (Usually it would be the same to the beneficiary
     * address unless the beneficiary address is a smart contract unable to
     * receive ethers.)
     */
    function receiveRefund(address _wallet) public {
        _transferRefund(msg.sender, _wallet);
    }

    function _transferRefund(address _beneficiary, address _wallet) internal {
        uint256 depositedWeiAmount = refundedDeposits[_beneficiary];
        require(depositedWeiAmount > 0, "_beneficiary has never purchased.");
        refundedDeposits[_beneficiary] = 0;
        contributions[_beneficiary] = contributions[_beneficiary].sub(
            depositedWeiAmount
        );
        _wallet.transfer(depositedWeiAmount);
        emit Refunded(_beneficiary, _wallet, depositedWeiAmount);
    }
}