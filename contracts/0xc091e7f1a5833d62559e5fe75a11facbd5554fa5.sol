pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  address public owner;
  address public ownerCandidate;

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
   * @dev Delegate contract to another person.
   * @param candidate New owner address
   */
  function setOwnerCandidate(address candidate) external onlyOwner {
    ownerCandidate = candidate;
  }

  /**
   * @dev Person should decide does he want to became a new owner. It is necessary
   * to protect that some contract or stranger became new owner.
   */
  function approveNewOwner() external {
    address candidate = ownerCandidate;
    require(msg.sender == candidate, "Only owner candidate can use this function");
    emit OwnershipTransferred(owner, candidate);
    owner = candidate;
    ownerCandidate = 0x0;
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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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

contract IERC20Token {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

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
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract CFGToken is IERC20Token, Ownable {

  using SafeMath for uint256;

  mapping(address => uint256) private balances;
  mapping(address => mapping(address => uint256)) private allowed;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint256 private totalSupply_;

  bool public initialized = false;
  uint256 public lockedUntil;
  address public hotWallet;
  address public reserveWallet;
  address public teamWallet;
  address public advisersWallet;

  constructor() public {
    symbol = "CFGT";
    name = "Cardonio Financial Group Token";
    decimals = 18;
  }

  function init(address _hotWallet, address _reserveWallet, address _teamWallet, address _advisersWallet) external onlyOwner {
    require(!initialized, "Already initialized");

    lockedUntil = now + 730 days; // 2 years
    hotWallet = _hotWallet;
    reserveWallet = _reserveWallet;
    teamWallet = _teamWallet;
    advisersWallet = _advisersWallet;

    uint256 hotSupply      = 380000000e18;
    uint256 reserveSupply  = 100000000e18;
    uint256 teamSupply     =  45000000e18;
    uint256 advisersSupply =  25000000e18;

    balances[hotWallet] = hotSupply;
    balances[reserveWallet] = reserveSupply;
    balances[teamWallet] = teamSupply;
    balances[advisersWallet] = advisersSupply;

    totalSupply_ = hotSupply.add(reserveSupply).add(teamSupply).add(advisersSupply);
    initialized = true;
  }

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
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
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Receiver address should be specified");
    require(initialized, "Not initialized yet");
    require(_value <= balances[msg.sender], "Not enough funds");

    if (teamWallet == msg.sender && lockedUntil > now) {
      revert("Tokens locked");
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
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
    require(msg.sender != _spender, "Owner can not approve to himself");
    require(initialized, "Not initialized yet");

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Receiver address should be specified");
    require(initialized, "Not initialized yet");
    require(_value <= balances[_from], "Not enough funds");
    require(_value <= allowed[_from][msg.sender], "Not enough allowance");

    if (teamWallet == _from && lockedUntil > now) {
      revert("Tokens locked");
    }

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Restricted access function that mints an amount of the token and assigns it to
   * a specified account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _to The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function mint(address _to, uint256 _amount) external {
    address source = hotWallet;
    require(msg.sender == source, "You are not allowed withdraw tokens");
    withdraw(source, _to, _amount);
  }

  /**
   * @dev Internal function to withdraw tokens from special wallets.
   * @param _from The address of special wallet.
   * @param _to The address of receiver.
   * @param _amount The amount of tokens which will be sent to receiver's address.
   */
  function withdraw(address _from, address _to, uint256 _amount) private {
    require(_to != address(0), "Receiver address should be specified");
    require(initialized, "Not initialized yet");
    require(_amount > 0, "Amount should be more than zero");
    require(_amount <= balances[_from], "Not enough funds");

    balances[_from] = balances[_from].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    emit Transfer(_from, _to, _amount);
  }

  /**
   * @dev Restricted access function to withdraw tokens from reserve wallet.
   * @param _to The address of receiver.
   * @param _amount The amount of tokens which will be sent to receiver's address.
   */
  function withdrawFromReserveWallet(address _to, uint256 _amount) external {
    address source = reserveWallet;
    require(msg.sender == source, "You are not allowed withdraw tokens");
    withdraw(source, _to, _amount);
  }

  /**
   * @dev Restricted access function to withdraw tokens from team wallet.
   * But tokens can be withdraw only after lock period end.
   * @param _to The address of receiver.
   * @param _amount The amount of tokens which will be sent to receiver's address.
   */
  function withdrawFromTeamWallet(address _to, uint256 _amount) external {
    address source = teamWallet;
    require(msg.sender == source, "You are not allowed withdraw tokens");
    require(lockedUntil <= now, "Tokens locked");
    withdraw(source, _to, _amount);
  }

  /**
   * @dev Restricted access function to withdraw tokens from advisers wallet.
   * @param _to The address of receiver.
   * @param _amount The amount of tokens which will be sent to receiver's address.
   */
  function withdrawFromAdvisersWallet(address _to, uint256 _amount) external {
    address source = advisersWallet;
    require(msg.sender == source, "You are not allowed withdraw tokens");
    withdraw(source, _to, _amount);
  }
}