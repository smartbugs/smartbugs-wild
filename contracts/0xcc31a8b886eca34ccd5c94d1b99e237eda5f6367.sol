pragma solidity ^0.4.24;

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
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}




contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}






/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}



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





/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
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


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
  }
}





/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}


contract BToken is ERC20Burnable, ERC20Detailed {
  uint constant private INITIAL_SUPPLY = 10 * 1e24;
  
  constructor() ERC20Detailed("BurnToken", "BUTK", 18) public {
    super._mint(msg.sender, INITIAL_SUPPLY);
  }
}

contract BMng is Pausable, Ownable {
  using SafeMath for uint256;

  enum TokenStatus {
    Unknown,
    Active,
    Suspended
  }

  struct Token {
    TokenStatus status;
    uint256 rewardRateNumerator;
    uint256 rewardRateDenominator;
    uint256 burned;
    uint256 burnedAccumulator;
    uint256 bTokensRewarded;
    uint256 totalSupplyInit; // provided during registration
  }

  event Auth(
    address indexed burner,
    address indexed partner
  );

  event Burn(
    address indexed token,
    address indexed burner,
    address partner,
    uint256 value,
    uint256 bValue,
    uint256 bValuePartner
  );

  event DiscountUpdate(
    uint256 discountNumerator,
    uint256 discountDenominator,
    uint256 balanceThreshold
  );

  string public name;
  address constant burnAddress = 0x000000000000000000000000000000000000dEaD;
  address registrator;
  address defaultPartner;
  
  uint256 partnerBonusRateNumerator;
  uint256 partnerBonusRateDenominator;

  uint256 constant discountNumeratorMul = 95;
  uint256 constant discountDenominatorMul = 100;

  uint256 discountNumerator;
  uint256 discountDenominator;
  uint256 balanceThreshold;

  mapping (address => Token) public tokens;

  // Emails registered
  mapping (address => address) referalPartners;

  // Counters
  mapping (address => mapping (address => uint256)) burntByTokenUser;
  // mapping (address => uint256) burntByTokenTotal;
  
  // Reference codes
  mapping (bytes8 => address) refLookup;

  // Bonuses
  mapping (address => bool) public shouldGetBonus;

  BToken bToken;
  uint256 public initialBlockNumber;

  constructor(
    address _bTokenAddress, 
    address _registrator, 
    address _defaultPartner,
    uint256 _initialBalance
  ) 
  public 
  {
    name = "Burn Token Management Contract v0.2";
    registrator = _registrator;
    defaultPartner = _defaultPartner;
    bToken = BToken(_bTokenAddress);
    initialBlockNumber = block.number;
    // Formal referals
    referalPartners[_registrator] = burnAddress;
    referalPartners[_defaultPartner] = burnAddress;
    // Bonus rate
    partnerBonusRateNumerator = 15; // 15% default
    partnerBonusRateDenominator = 100;
    discountNumerator = 1;
    discountDenominator = 1;
    balanceThreshold = _initialBalance.mul(discountNumeratorMul).div(discountDenominatorMul);
  }

  // --------------------------------------------------------------------------
  // Administration fuctionality
  
  function claimBurnTokensBack(address _to) public onlyOwner {
    // This is necessary to finalize the contract lifecicle 
    uint256 remainingBalance = bToken.balanceOf(this);
    bToken.transfer(_to, remainingBalance);
  }

  function register(
    address tokenAddress, 
    uint256 totalSupply,
    uint256 _rewardRateNumerator,
    uint256 _rewardRateDenominator,
    bool activate
  ) 
    public 
    onlyOwner 
  {
    require(tokens[tokenAddress].status == TokenStatus.Unknown, "Cannot register more than one time");
    Token memory _token;
    if (activate) {
      _token.status = TokenStatus.Active;
    } else {
      _token.status = TokenStatus.Suspended;
    }    
    _token.rewardRateNumerator = _rewardRateNumerator;
    _token.rewardRateDenominator = _rewardRateDenominator;
    _token.totalSupplyInit = totalSupply;
    tokens[tokenAddress] = _token;
  }

  function changeRegistrator(address _newRegistrator) public onlyOwner {
    registrator = _newRegistrator;
  }

  function changeDefaultPartnerAddress(address _newDefaultPartner) public onlyOwner {
    defaultPartner = _newDefaultPartner;
  }

  
  function setRewardRateForToken(
    address tokenAddress,
    uint256 _rewardRateNumerator,
    uint256 _rewardRateDenominator
  )
    public 
    onlyOwner 
  {
    require(tokens[tokenAddress].status != TokenStatus.Unknown, "Token should be registered first");
    tokens[tokenAddress].rewardRateNumerator = _rewardRateNumerator;
    tokens[tokenAddress].rewardRateDenominator = _rewardRateDenominator;
  }
  

  function setPartnerBonusRate(
    uint256 _partnerBonusRateNumerator,
    uint256 _partnerBonusRateDenominator
  )
    public 
    onlyOwner 
  {
    partnerBonusRateNumerator = _partnerBonusRateNumerator;
    partnerBonusRateDenominator = _partnerBonusRateDenominator;
  }

  function suspend(address tokenAddress) public onlyOwner {
    require(tokens[tokenAddress].status != TokenStatus.Unknown, "Token should be registered first");
    tokens[tokenAddress].status = TokenStatus.Suspended;
  }

  function unSuspend(address tokenAddress) public onlyOwner {
    require(tokens[tokenAddress].status != TokenStatus.Unknown, "Token should be registered first");
    tokens[tokenAddress].status = TokenStatus.Active;
    tokens[tokenAddress].burnedAccumulator = 0;
  }

  function activate(address tokenAddress) public onlyOwner {
    require(tokens[tokenAddress].status != TokenStatus.Unknown, "Token should be registered first");
    tokens[tokenAddress].status = TokenStatus.Active;
  }

  // END of Administration fuctionality
  // --------------------------------------------------------------------------

  function isAuthorized(address _who) public view whenNotPaused returns (bool) {
    address partner = referalPartners[_who];
    return partner != address(0);
  }

  function amountBurnedTotal(address token) public view returns (uint256) {
    return tokens[token].burned;
  }

  function amountBurnedByUser(address token, address _who) public view returns (uint256) {
    return burntByTokenUser[token][_who];
  }

  // Ref code
  function getRefByAddress(address _who) public pure returns (bytes6) {
    /* 
      We use Base58 encoding and want refcode length to be 8 symbols 
      bits = log2(58) * 8 = 46.86384796102058 = 40 + 6.86384796102058
      2^(40 + 6.86384796102058) = 0x100^5 * 116.4726943 ~ 0x100^5 * 116
      CEIL(47 / 8) = 6
      Output: bytes6 (48 bits)
      In such case for 10^6 records we have 0.39% hash collision probability 
      (see: https://preshing.com/20110504/hash-collision-probabilities/)
    */ 
    bytes32 dataHash = keccak256(abi.encodePacked(_who, "BUTK"));
    return bytes6(uint256(dataHash) % uint256(116 * 0x10000000000));
  }

  function getAddressByRef(bytes6 ref) public view returns (address) {
    return refLookup[ref];
  }

  function saveRef(address _who) private returns (bool) {
    require(_who != address(0), "Should not be zero address");
    bytes6 ref = getRefByAddress(_who);
    refLookup[ref] = _who;
    return true;
  }

  function checkSignature(bytes sig, address _who) public view returns (bool) {
    bytes32 dataHash = keccak256(abi.encodePacked(_who));
    return (ECDSA.recover(dataHash, sig) == registrator);
  }

  function authorizeAddress(bytes authSignature, bytes6 ref) public whenNotPaused returns (bool) {
    // require(false, "Test fail");
    require(checkSignature(authSignature, msg.sender) == true, "Authorization should be signed by registrator");
    require(isAuthorized(msg.sender) == false, "No need to authorize more then once");
    address refAddress = getAddressByRef(ref);
    address partner = (refAddress == address(0)) ? defaultPartner : refAddress;

    // Create ref code (register as a partner)
    saveRef(msg.sender);

    referalPartners[msg.sender] = partner;

    // Only if ref code is used authorized to get extra bonus
    if (partner != defaultPartner) {
      shouldGetBonus[msg.sender] = true;
    }

    emit Auth(msg.sender, partner);

    return true;
  }

  function suspendIfNecessary(
    address tokenAddress
  )
    private returns (bool) 
  {
    // When 10% of totalSupply is burnt suspend the token just in case 
    // there is a chance that its contract is broken
    if (tokens[tokenAddress].burnedAccumulator > tokens[tokenAddress].totalSupplyInit.div(10)) {
      tokens[tokenAddress].status = TokenStatus.Suspended;
      return true;
    }
    return false;
  }

  // Discount
  function discountCorrectionIfNecessary(
    uint256 balance
  ) 
    private returns (bool)
  {
    if (balance < balanceThreshold) {
      // Update discountNumerator, discountDenominator and balanceThreshold
      // we multiply discount coefficient by 0.9
      discountNumerator = discountNumerator * discountNumeratorMul;
      discountDenominator = discountDenominator * discountDenominatorMul;
      balanceThreshold = balanceThreshold.mul(discountNumeratorMul).div(discountDenominatorMul);
      emit DiscountUpdate(discountNumerator, discountDenominator, balanceThreshold);
      return true;
    }
    return false;
  }

  // Helpers
  function getAllTokenData(
    address tokenAddress,
    address _who
  )
    public view returns (uint256, uint256, uint256, uint256, bool) 
  {
    IERC20 tokenContract = IERC20(tokenAddress);
    uint256 balance = tokenContract.balanceOf(_who);
    uint256 allowance = tokenContract.allowance(_who, this);
    bool isActive = (tokens[tokenAddress].status == TokenStatus.Active);
    uint256 burnedByUser = amountBurnedByUser(tokenAddress, _who);
    uint256 burnedTotal = amountBurnedTotal(tokenAddress);
    return (balance, allowance, burnedByUser, burnedTotal, isActive);
  }

  function getBTokenValue(
    address tokenAddress, 
    uint256 value
  )
    public view returns (uint256) 
  {
    Token memory tokenRec = tokens[tokenAddress];
    require(tokenRec.status == TokenStatus.Active, "Token should be in active state");
    uint256 denominator = tokenRec.rewardRateDenominator;
    require(denominator > 0, "Reward denominator should not be zero");
    uint256 numerator = tokenRec.rewardRateNumerator;
    uint256 bTokenValue = value.mul(numerator).div(denominator);
    // Discount
    uint256 discountedBTokenValue = bTokenValue.mul(discountNumerator).div(discountDenominator);
    return discountedBTokenValue;
  } 

  function getPartnerReward(uint256 bTokenValue) public view returns (uint256) {
    return bTokenValue.mul(partnerBonusRateNumerator).div(partnerBonusRateDenominator);
  }

  function burn(
    address tokenAddress, 
    uint256 value
  ) 
    public 
    whenNotPaused 
    returns (bool) 
  {
    address partner = referalPartners[msg.sender];
    require(partner != address(0), "Burner should be registered");
    IERC20 tokenContract = IERC20(tokenAddress);
    require(tokenContract.allowance(msg.sender, this) >= value, "Should be allowed");
 
    uint256 bTokenValueFin;
    uint256 bTokenValue = getBTokenValue(tokenAddress, value);
    uint256 currentBalance = bToken.balanceOf(this);
    require(bTokenValue < currentBalance.div(100), "Cannot reward more than 1% of the balance");

    uint256 bTokenPartnerBonus = getPartnerReward(bTokenValue);
    uint256 bTokenTotal = bTokenValue.add(bTokenPartnerBonus);
    
    // Update counters
    tokens[tokenAddress].burned = tokens[tokenAddress].burned.add(value);
    tokens[tokenAddress].burnedAccumulator = tokens[tokenAddress].burnedAccumulator.add(value);
    tokens[tokenAddress].bTokensRewarded = tokens[tokenAddress].bTokensRewarded.add(bTokenTotal);
    burntByTokenUser[tokenAddress][msg.sender] = burntByTokenUser[tokenAddress][msg.sender].add(value);

    tokenContract.transferFrom(msg.sender, burnAddress, value); // burn shit-token
    
    discountCorrectionIfNecessary(currentBalance.sub(bTokenValue).sub(bTokenPartnerBonus));
    
    suspendIfNecessary(tokenAddress);

    bToken.transfer(partner, bTokenPartnerBonus);

    if (shouldGetBonus[msg.sender]) {
      // give bonus once
      shouldGetBonus[msg.sender] = false;
      bTokenValueFin = bTokenValue.mul(6).div(5); // +20%
    } else {
      bTokenValueFin = bTokenValue;
    }

    bToken.transfer(msg.sender, bTokenValueFin);
    emit Burn(tokenAddress, msg.sender, partner, value, bTokenValueFin, bTokenPartnerBonus);
  }
}