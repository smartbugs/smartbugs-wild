pragma solidity ^0.4.18;

// File: contracts/ERC20Basic.sol

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

// File: contracts/SafeMath.sol

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

// File: contracts/BasicToken.sol

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

// File: contracts/ERC20.sol

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

// File: contracts/StandardToken.sol

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

// File: contracts/Ownable.sol

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

// File: contracts/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
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

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: contracts/CanReclaimToken.sol

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
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

// File: contracts/HasNoTokens.sol

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external pure {
    from_;
    value_;
    data_;
    revert();
  }

}

// File: contracts/Vesting.sol

/**
 * @title Standalone Vesting  logic to be added in token
 * @dev Beneficiary can have at most one VestingGrant only, we do not support adding two vesting grants of vesting grant to same address.
 *      Token transfer related logic is not handled in this class for simplicity and modularity purpose
 */
contract Vesting {
  using SafeMath for uint256;

  struct VestingGrant {
    uint256 grantedAmount;       // 32 bytes
    uint64 start;
    uint64 cliff;
    uint64 vesting;             // 3 * 8 = 24 bytes
  } // total 56 bytes = 2 sstore per operation (32 per sstore)

  mapping (address => VestingGrant) public grants;

  event VestingGrantSet(address indexed to, uint256 grantedAmount, uint64 vesting);

  function getVestingGrantAmount(address _to) public view returns (uint256) {
    return grants[_to].grantedAmount;
  }

  /**
   * @dev Set vesting grant to a specified address
   * @param _to address The address which the vesting amount will be granted to.
   * @param _grantedAmount uint256 The amount to be granted.
   * @param _start uint64 Time of the beginning of the grant.
   * @param _cliff uint64 Time of the cliff period.
   * @param _vesting uint64 The vesting period.
   * @param _override bool Must be true if you are overriding vesting grant that has been set before
   *          this is to prevent accidental overwriting vesting grant
   */
  function setVestingGrant(address _to, uint256 _grantedAmount, uint64 _start, uint64 _cliff, uint64 _vesting, bool _override) public {

    // Check for date inconsistencies that may cause unexpected behavior
    require(_cliff >= _start && _vesting >= _cliff);
    // only one vesting logic per address, and once set to update _override flag is required
    require(grants[_to].grantedAmount == 0 || _override);
    grants[_to] = VestingGrant(_grantedAmount, _start, _cliff, _vesting);

    VestingGrantSet(_to, _grantedAmount, _vesting);
  }

  /**
   * @dev Calculate amount of vested amounts at a specific time (monthly graded)
   * @param grantedAmount uint256 The amount of amounts granted
   * @param time uint64 The time to be checked
   * @param start uint64 The time representing the beginning of the grant
   * @param cliff uint64  The cliff period, the period before nothing can be paid out
   * @param vesting uint64 The vesting period
   * @return An uint256 representing the vested amounts
   *   |                         _/--------   vestedTokens rect
   *   |                       _/
   *   |                     _/
   *   |                   _/
   *   |                 _/
   *   |                /
   *   |              .|
   *   |            .  |
   *   |          .    |
   *   |        .      |
   *   |      .        |
   *   |    .          |
   *   +===+===========+---------+----------> time
   *      Start       Cliff    Vesting
   */
  function calculateVested (
    uint256 grantedAmount,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal pure returns (uint256)
    {
      // Shortcuts for before cliff and after vesting cases.
      if (time < cliff) return 0;
      if (time >= vesting) return grantedAmount;

      // Interpolate all vested amounts.
      // As before cliff the shortcut returns 0, we can use just calculate a value
      // in the vesting rect (as shown in above's figure)

      // vestedAmounts = (grantedAmount * (time - start)) / (vesting - start)   <-- this is the original formula
      // vestedAmounts = (grantedAmount * ( (time - start) / (30 days) ) / ( (vesting - start) / (30 days) )   <-- this is made

      uint256 vestedAmounts = grantedAmount.mul(time.sub(start).div(30 days)).div(vesting.sub(start).div(30 days));

      //if (vestedAmounts > grantedAmount) return amounts; // there is no possible case where this is true

      return vestedAmounts;
  }

  function calculateLocked (
    uint256 grantedAmount,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal pure returns (uint256)
    {
      return grantedAmount.sub(calculateVested(grantedAmount, time, start, cliff, vesting));
    }

  /**
   * @dev Gets the locked amount of a given beneficiary, ie. non vested amount, at a specific time.
   * @param _to The beneficiary to be checked.
   * @param _time uint64 The time to be checked
   * @return An uint256 representing the non vested amounts of a specific grant on the
   * passed time frame.
   */
  function getLockedAmountOf(address _to, uint256 _time) public view returns (uint256) {
    VestingGrant storage grant = grants[_to];
    if (grant.grantedAmount == 0) return 0;
    return calculateLocked(grant.grantedAmount, uint256(_time), uint256(grant.start),
      uint256(grant.cliff), uint256(grant.vesting));
  }


}

// File: contracts/DirectToken.sol

contract DirectToken is MintableToken, HasNoTokens, Vesting {

  string public constant name = "DIREC";
  string public constant symbol = "DIR";
  uint8 public constant decimals = 18;

  bool public tradingStarted = false;   // target is TRADING_START date = 1533081600; // 2018-08-01 00:00:00 UTC

  /**
   * @dev Allows the owner to enable the trading.
   */
  function setTradingStarted(bool _tradingStarted) public onlyOwner {
    tradingStarted = _tradingStarted;
  }

  /**
   * @dev Allows anyone to transfer the PAY tokens once trading has started
   * @param _to the recipient address of the tokens.
   * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    checkTransferAllowed(msg.sender, _to, _value);
    return super.transfer(_to, _value);
  }

   /**
   * @dev Allows anyone to transfer the PAY tokens once trading has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    checkTransferAllowed(msg.sender, _to, _value);
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * Throws if the transfer not allowed due to minting not finished, trading not started, or vesting
   *   this should be called at the top of transfer functions and so as to refund unused gas
   */
  function checkTransferAllowed(address _sender, address _to, uint256 _value) private view {
      if (mintingFinished && tradingStarted && isAllowableTransferAmount(_sender, _value)) {
          // Everybody can transfer once the token is finalized and trading has started and is within allowable vested amount if applicable
          return;
      }

      // Owner is allowed to transfer tokens before the sale is finalized.
      // This allows the tokens to move from the TokenSale contract to a beneficiary.
      // We also allow someone to send tokens back to the owner. This is useful among other
      // cases, reclaimTokens etc.
      require(_sender == owner || _to == owner);
  }

  function setVestingGrant(address _to, uint256 _grantedAmount, uint64 _start, uint64 _cliff, uint64 _vesting, bool _override) public onlyOwner {
    return super.setVestingGrant(_to, _grantedAmount, _start, _cliff, _vesting, _override);
  }

  function isAllowableTransferAmount(address _sender, uint256 _value) private view returns (bool allowed) {
     if (getVestingGrantAmount(_sender) == 0) {
        return true;
     }
     // the address has vesting grant set, he can transfer up to the amount that vested
     uint256 transferableAmount = balanceOf(_sender).sub(getLockedAmountOf(_sender, now));
     return (_value <= transferableAmount);
  }

}