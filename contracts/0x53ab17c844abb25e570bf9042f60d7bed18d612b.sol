pragma solidity ^0.4.24;

/*
    @title Provides support and utilities for contract ownership
*/
contract Ownable {
  address public owner;
  address public newOwnerCandidate;

  event OwnerUpdate(address prevOwner, address newOwner);

  /*
    @dev constructor
  */
  constructor() public {
    owner = msg.sender;
  }

  /*
    @dev allows execution by the owner only
  */
  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

  /*
    @dev allows transferring the contract ownership
    the new owner still needs to accept the transfer
    can only be called by the contract owner

    @param _newOwnerCandidate    new contract owner
  */
  function transferOwnership(address _newOwnerCandidate) public ownerOnly {
    require(_newOwnerCandidate != address(0));
    require(_newOwnerCandidate != owner);
    newOwnerCandidate = _newOwnerCandidate;
  }

  /*
    @dev used by a new owner to accept an ownership transfer
  */
  function acceptOwnership() public {
    require(msg.sender == newOwnerCandidate);
    emit OwnerUpdate(owner, newOwnerCandidate);
    owner = newOwnerCandidate;
    newOwnerCandidate = address(0);
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) internal _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 internal _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. In order to mitigate this
   * race condition is we first check the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    // if the allowance isn't 0, it can only be updated to 0 to prevent an allowance change immediately after withdrawal
    require(value == 0 || _allowed[msg.sender][spender] == 0);

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is ERC20, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Burn(address indexed from, uint256 amount);

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 amount) public ownerOnly canMint returns (bool) {
    require(to != address(0));
    
    _totalSupply = _totalSupply.add(amount);
    _balances[to] = _balances[to].add(amount);
    emit Mint(to, amount);
    emit Transfer(address(0), to, amount);
    return true;
  }

    /**
   * @dev Function to burn tokens
   * @param from The address whose tokens will be burnt.
   * @param amount The amount of tokens to burn.
   * @return A boolean that indicates if the operation was successful.
   */
  function burn(address from, uint256 amount) public ownerOnly canMint returns (bool) {
    require(from != address(0));

    _totalSupply = _totalSupply.sub(amount);
    _balances[from] = _balances[from].sub(amount);
    emit Burn(from, amount);
    emit Transfer(from, address(0), amount);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public ownerOnly canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

/**
 * @title FreezableToken
 * @dev LimitedTransferToken transfers start as disabled untill enabled by the contract owner
 */

contract FreezableToken is ERC20, Ownable {

  event TransfersEnabled();

  bool public allowTransfers = false;

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer() {
    require(allowTransfers || msg.sender == owner);
    _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.

   */
  function enableTransfers() public ownerOnly {
    allowTransfers = true;
    emit TransfersEnabled();
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param to The address that will receive the tokens.
   * @param value The amount of tokens to be transferred.
   */
  function transfer(address to, uint256 value) public canTransfer returns (bool) {
    return super.transfer(to, value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param from The address that will send the tokens.
  * @param to The address that will receive the tokens.
  * @param value The amount of tokens to be transferred.
  */
  function transferFrom(address from, address to, uint256 value) public canTransfer returns (bool) {
    return super.transferFrom(from, to, value);
  }
}

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public constant cap = 1000000000000000000000000000;

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 amount
  )
    public
    returns (bool)
  {
    require(_totalSupply.add(amount) <= cap);

    return super.mint(to, amount);
  }

}

/**
 * @title VeganCoin
 * @dev Based on openzeppelin ERC20 token
 */
contract VeganCoin is CappedToken, FreezableToken {

  string public name = "VeganCoin"; 
  string public symbol = "VCN";
  uint8 public decimals = 18;
}

/// @title Vesting contract
contract VestingTrustee is Ownable {
    using SafeMath for uint256;

    // The address of the VCN ERC20 token.
    VeganCoin public veganCoin;

    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 transferred;
        bool revokable;
    }

    // Grants holder.
    mapping (address => Grant) public grants;

    // Total tokens available for vesting.
    uint256 public totalVesting;

    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event UnlockGrant(address indexed _holder, uint256 _value);
    event RevokeGrant(address indexed _holder, uint256 _refund);

    /// @dev Constructor that initializes the address of the VeganCoin contract.
    /// @param _veganCoin The address of the previously deployed VeganCoin smart contract.
    constructor(VeganCoin _veganCoin) public {
        require(_veganCoin != address(0));

        veganCoin = _veganCoin;
    }

    /// @dev Grant tokens to a specified address.
    /// @param _to address The address to grant tokens to.
    /// @param _value uint256 The amount of tokens to be granted.
    /// @param _start uint256 The beginning of the vesting period.
    /// @param _cliff uint256 Duration of the cliff period.
    /// @param _end uint256 The end of the vesting period.
    /// @param _revokable bool Whether the grant is revokable or not.
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end, bool _revokable)
        public ownerOnly {
        require(_to != address(0));
        require(_value > 0);

        // Make sure that a single address can be granted tokens only once.
        require(grants[_to].value == 0);

        // Check for date inconsistencies that may cause unexpected behavior.
        require(_start <= _cliff && _cliff <= _end);

        // Check that this grant doesn't exceed the total amount of tokens currently available for vesting.
        require(totalVesting.add(_value) <= veganCoin.balanceOf(address(this)));

        // Assign a new grant.
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            transferred: 0,
            revokable: _revokable
        });

        // Tokens granted, reduce the total amount available for vesting.
        totalVesting = totalVesting.add(_value);

        emit NewGrant(msg.sender, _to, _value);
    }

    /// @dev Revoke the grant of tokens of a specifed address.
    /// @param _holder The address which will have its tokens revoked.
    function revoke(address _holder) public ownerOnly {
        Grant storage grant = grants[_holder];

        require(grant.revokable);

        // Revoke the remaining VCN.
        uint256 refund = grant.value.sub(grant.transferred);

        // Remove the grant.
        delete grants[_holder];

        totalVesting = totalVesting.sub(refund);

        emit RevokeGrant(_holder, refund);
    }

    /// @dev Calculate the total amount of vested tokens of a holder at a given time.
    /// @param _holder address The address of the holder.
    /// @param _time uint256 The specific time.
    /// @return a uint256 representing a holder's total amount of vested tokens.
    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {
        Grant storage grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }

        return calculateVestedTokens(grant, _time);
    }

    /// @dev Calculate amount of vested tokens at a specifc time.
    /// @param _grant Grant The vesting grant.
    /// @param _time uint256 The time to be checked
    /// @return An uint256 representing the amount of vested tokens of a specific grant.
    ///   |                         _/--------   vestedTokens rect
    ///   |                       _/
    ///   |                     _/
    ///   |                   _/
    ///   |                 _/
    ///   |                /
    ///   |              .|
    ///   |            .  |
    ///   |          .    |
    ///   |        .      |
    ///   |      .        |
    ///   |    .          |
    ///   +===+===========+---------+----------> time
    ///     Start       Cliff      End
    function calculateVestedTokens(Grant _grant, uint256 _time) private pure returns (uint256) {
        // If we're before the cliff, then nothing is vested.
        if (_time < _grant.cliff) {
            return 0;
        }

        // If we're after the end of the vesting period - everything is vested;
        if (_time >= _grant.end) {
            return _grant.value;
        }

        // Interpolate all vested tokens: vestedTokens = tokens/// (time - start) / (end - start)
         return _grant.value.mul(_time.sub(_grant.start)).div(_grant.end.sub(_grant.start));
    }

    /// @dev Unlock vested tokens and transfer them to their holder.
    /// @return a uint256 representing the amount of vested tokens transferred to their holder.
    function unlockVestedTokens() public {
        Grant storage grant = grants[msg.sender];
        require(grant.value != 0);

        // Get the total amount of vested tokens, acccording to grant.
        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            return;
        }

        // Make sure the holder doesn't transfer more than what he already has.
        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            return;
        }

        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        veganCoin.transfer(msg.sender, transferable);

        emit UnlockGrant(msg.sender, transferable);
    }
}