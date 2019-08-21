pragma solidity ^0.4.25;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

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
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

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
    require(value <= _allowed[from][msg.sender]);

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
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: eth-token-recover/contracts/TokenRecover.sol

/**
 * @title TokenRecover
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Allow to recover any ERC20 sent into the contract for error
 */
contract TokenRecover is Ownable {

  /**
   * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
   * @param tokenAddress The token contract address
   * @param tokenAmount Number of tokens to be sent
   */
  function recoverERC20(
    address tokenAddress,
    uint256 tokenAmount
  )
    public
    onlyOwner
  {
    IERC20(tokenAddress).transfer(owner(), tokenAmount);
  }
}

// File: contracts/faucet/TokenFaucet.sol

/**
 * @title TokenFaucet
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Implementation of a TokenFaucet
 */
contract TokenFaucet is TokenRecover {
  using SafeMath for uint256;

  // struct representing the faucet status for an account
  struct RecipientDetail {
    bool exists;
    uint256 tokens;
    uint256 lastUpdate;
    address referral;
  }

  // struct representing the referral status
  struct ReferralDetail {
    uint256 tokens;
    address[] recipients;
  }

  // the time between two tokens claim
  uint256 private _pauseTime = 1 days;

  // the token to distribute
  ERC20 private _token;

  // the daily rate of tokens distributed
  uint256 private _dailyRate;

  // the value earned by referral per mille
  uint256 private _referralPerMille;

  // the sum of distributed tokens
  uint256 private _totalDistributedTokens;

  // map of address and received token amount
  mapping (address => RecipientDetail) private _recipientList;

  // list of addresses who received tokens
  address[] private _recipients;

  // map of address and referred addresses
  mapping (address => ReferralDetail) private _referralList;

  /**
   * @param token Address of the token being distributed
   * @param dailyRate Daily rate of tokens distributed
   * @param referralPerMille The value earned by referral per mille
   */
  constructor(
    address token,
    uint256 dailyRate,
    uint256 referralPerMille
  )
    public
  {
    require(token != address(0));
    require(dailyRate > 0);
    require(referralPerMille > 0);

    _token = ERC20(token);
    _dailyRate = dailyRate;
    _referralPerMille = referralPerMille;
  }

  /**
   * @dev fallback
   */
  function () external payable {
    require(msg.value == 0);

    getTokens();
  }

  /**
   * @dev function to be called to receive tokens
   */
  function getTokens() public {
    // distribute tokens
    _distributeTokens(msg.sender, address(0));
  }

  /**
   * @dev function to be called to receive tokens
   * @param referral Address to an account that is referring
   */
  function getTokensWithReferral(address referral) public {
    require(referral != msg.sender);

    // distribute tokens
    _distributeTokens(msg.sender, referral);
  }

  /**
   * @return the token to distribute
   */
  function token() public view returns (ERC20) {
    return _token;
  }

  /**
   * @return the daily rate of tokens distributed
   */
  function dailyRate() public view returns (uint256) {
    return _dailyRate;
  }

  /**
   * @return the value earned by referral for each recipient
   */
  function referralTokens() public view returns (uint256) {
    return _dailyRate.mul(_referralPerMille).div(1000);
  }

  /**
   * @return the sum of distributed tokens
   */
  function totalDistributedTokens() public view returns (uint256) {
    return _totalDistributedTokens;
  }

  /**
   * @param account The address to check
   * @return received token amount for the given address
   */
  function receivedTokens(address account) public view returns (uint256) {
    return _recipientList[account].tokens;
  }

  /**
   * @param account The address to check
   * @return last tokens received timestamp
   */
  function lastUpdate(address account) public view returns (uint256) {
    return _recipientList[account].lastUpdate;
  }

  /**
   * @param account The address to check
   * @return time of next available claim or zero
   */
  function nextClaimTime(address account) public view returns (uint256) {
    return !_recipientList[account].exists ? 0 : _recipientList[account].lastUpdate + _pauseTime;
  }

  /**
   * @param account The address to check
   * @return referral for given address
   */
  function getReferral(address account) public view returns (address) {
    return _recipientList[account].referral;
  }

  /**
   * @param account The address to check
   * @return earned tokens by referrals
   */
  function earnedByReferral(address account) public view returns (uint256) {
    return _referralList[account].tokens;
  }

  /**
   * @param account The address to check
   * @return referred addresses for given address
   */
  function getReferredAddresses(address account) public view returns (address[]) {
    return _referralList[account].recipients;
  }

  /**
   * @param account The address to check
   * @return referred addresses for given address
   */
  function getReferredAddressesLength(address account) public view returns (uint) {
    return _referralList[account].recipients.length;
  }

  /**
   * @dev return the number of remaining tokens to distribute
   * @return uint256
   */
  function remainingTokens() public view returns (uint256) {
    return _token.balanceOf(this);
  }

  /**
   * @return address of a recipient by list index
   */
  function getRecipientAddress(uint256 index) public view returns (address) {
    return _recipients[index];
  }

  /**
   * @dev return the recipients length
   * @return uint
   */
  function getRecipientsLength() public view returns (uint) {
    return _recipients.length;
  }

  /**
   * @dev change daily rate and referral per mille
   * @param newDailyRate Daily rate of tokens distributed
   * @param newReferralPerMille The value earned by referral per mille
   */
  function setRates(uint256 newDailyRate, uint256 newReferralPerMille) public onlyOwner {
    require(newDailyRate > 0);
    require(newReferralPerMille > 0);

    _dailyRate = newDailyRate;
    _referralPerMille = newReferralPerMille;
  }

  /**
   * @dev distribute tokens
   * @param account Address being distributing
   * @param referral Address to an account that is referring
   */
  function _distributeTokens(address account, address referral) internal {
    require(nextClaimTime(account) <= block.timestamp); // solium-disable-line security/no-block-members

    // check if recipient exists
    if (!_recipientList[account].exists) {
      _recipients.push(account);
      _recipientList[account].exists = true;

      // check if valid referral
      if (referral != address(0)) {
        _recipientList[account].referral = referral;
        _referralList[referral].recipients.push(account);
      }
    }

    // update recipient status
    _recipientList[account].lastUpdate = block.timestamp; // solium-disable-line security/no-block-members
    _recipientList[account].tokens = _recipientList[account].tokens.add(_dailyRate);

    // update faucet status
    _totalDistributedTokens = _totalDistributedTokens.add(_dailyRate);

    // transfer tokens to recipient
    _token.transfer(account, _dailyRate);

    // check referral
    if (_recipientList[account].referral != address(0)) {
      // referral is only the first one referring
      address firstReferral = _recipientList[account].referral;

      uint256 referralEarnedTokens = referralTokens();

      // update referral status
      _referralList[firstReferral].tokens = _referralList[firstReferral].tokens.add(referralEarnedTokens);

      // update faucet status
      _totalDistributedTokens = _totalDistributedTokens.add(referralEarnedTokens);

      // transfer tokens to referral
      _token.transfer(firstReferral, referralEarnedTokens);
    }
  }
}