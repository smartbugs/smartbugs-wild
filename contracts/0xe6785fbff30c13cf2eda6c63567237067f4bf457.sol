pragma solidity ^0.4.24;

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
    uint256 suspiciousVolume; // provided during registration
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

  address constant burnAddress = 0x000000000000000000000000000000000000dEaD;

  // Lifetime parameters (set on initialization)
  string public name;
  IERC20 bToken; // BurnToken address
  uint256 discountNumeratorMul;
  uint256 discountDenominatorMul;
  uint256 bonusNumerator;
  uint256 bonusDenominator;
  uint256 public initialBlockNumber;

  // Evolving parameters
  uint256 discountNumerator;
  uint256 discountDenominator;
  uint256 balanceThreshold;

  // Managable parameters 
  address registrator;
  address defaultPartner;
  uint256 partnerRewardRateNumerator;
  uint256 partnerRewardRateDenominator;
  bool permissionRequired;

  mapping (address => Token) public tokens;
  mapping (address => address) referalPartners; // Users associated with referrals
  mapping (address => mapping (address => uint256)) burnedByTokenUser; // Counters
  mapping (bytes6 => address) refLookup; // Reference codes
  mapping (address => bool) public shouldGetBonus; // Bonuses
  mapping (address => uint256) public nonces; // Nonces for permissions

  constructor(
    address bTokenAddress, 
    address _registrator, 
    address _defaultPartner,
    uint256 initialBalance
  ) 
  public 
  {
    name = "Burn Token Management Contract v0.3";
    registrator = _registrator;
    defaultPartner = _defaultPartner;
    bToken = IERC20(bTokenAddress);
    initialBlockNumber = block.number;

    // Initially no permission needed for each burn
    permissionRequired = false;

    // Formal referals for registrator and defaultPartner
    referalPartners[registrator] = burnAddress;
    referalPartners[defaultPartner] = burnAddress;

    // Reward rate 15% for each referral burning
    partnerRewardRateNumerator = 15;
    partnerRewardRateDenominator = 100;

    // 20% bonus for using referal link
    bonusNumerator = 20;
    bonusDenominator = 100;

    // discount 5% each time when when 95% of the balance spent
    discountNumeratorMul = 95;
    discountDenominatorMul = 100;

    discountNumerator = 1;
    discountDenominator = 1;
    balanceThreshold = initialBalance.mul(discountNumeratorMul).div(discountDenominatorMul);
  }

  // --------------------------------------------------------------------------
  // Administration fuctionality
  
  function claimBurnTokensBack(address to) public onlyOwner {
    // This is necessary to finalize the contract lifecicle 
    uint256 remainingBalance = bToken.balanceOf(address(this));
    bToken.transfer(to, remainingBalance);
  }

  function registerToken(
    address tokenAddress, 
    uint256 suspiciousVolume,
    uint256 rewardRateNumerator,
    uint256 rewardRateDenominator,
    bool activate
  ) 
    public 
    onlyOwner 
  {
    // require(tokens[tokenAddress].status == TokenStatus.Unknown, "Cannot register more than one time");
    Token memory token;
    if (activate) {
      token.status = TokenStatus.Active;
    } else {
      token.status = TokenStatus.Suspended;
    }    
    token.rewardRateNumerator = rewardRateNumerator;
    token.rewardRateDenominator = rewardRateDenominator;
    token.suspiciousVolume = suspiciousVolume;
    tokens[tokenAddress] = token;
  }

  function changeRegistrator(address newRegistrator) public onlyOwner {
    registrator = newRegistrator;
  }

  function changeDefaultPartnerAddress(address newDefaultPartner) public onlyOwner {
    defaultPartner = newDefaultPartner;
  }

  
  function setRewardRateForToken(
    address tokenAddress,
    uint256 rewardRateNumerator,
    uint256 rewardRateDenominator
  )
    public 
    onlyOwner 
  {
    require(tokens[tokenAddress].status != TokenStatus.Unknown, "Token should be registered first");
    tokens[tokenAddress].rewardRateNumerator = rewardRateNumerator;
    tokens[tokenAddress].rewardRateDenominator = rewardRateDenominator;
  }
  

  function setPartnerRewardRate(
    uint256 newPartnerRewardRateNumerator,
    uint256 newPartnerRewardRateDenominator
  )
    public 
    onlyOwner 
  {
    partnerRewardRateNumerator = newPartnerRewardRateNumerator;
    partnerRewardRateDenominator = newPartnerRewardRateDenominator;
  }

  function setPermissionRequired(bool state) public onlyOwner {
    permissionRequired = state;
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

  modifier whenNoPermissionRequired() {
    require(!isPermissionRequired(), "Need a permission");
    _;
  }

  function isPermissionRequired() public view returns (bool) {
    // if burn can only occure by signed permission
    return permissionRequired;
  }

  function isAuthorized(address user) public view whenNotPaused returns (bool) {
    address partner = referalPartners[user];
    return partner != address(0);
  }

  function amountBurnedTotal(address tokenAddress) public view returns (uint256) {
    return tokens[tokenAddress].burned;
  }

  function amountBurnedByUser(address tokenAddress, address user) public view returns (uint256) {
    return burnedByTokenUser[tokenAddress][user];
  }

  // Ref code
  function getRefByAddress(address user) public pure returns (bytes6) {
    /* 
      We use Base58 encoding and want refcode length to be 8 symbols 
      bits = log2(58) * 8 = 46.86384796102058 = 40 + 6.86384796102058
      2^(40 + 6.86384796102058) = 0x100^5 * 116.4726943 ~ 0x100^5 * 116
      CEIL(47 / 8) = 6
      Output: bytes6 (48 bits)
      In such case for 10^6 records we have 0.39% hash collision probability 
      (see: https://preshing.com/20110504/hash-collision-probabilities/)
    */ 
    bytes32 dataHash = keccak256(abi.encodePacked(user, "BUTK"));
    bytes32 tmp = bytes32(uint256(dataHash) % uint256(116 * 0x10000000000));
    return bytes6(tmp << 26 * 8);
  }

  function getAddressByRef(bytes6 ref) public view returns (address) {
    return refLookup[ref];
  }

  function saveRef(address user) private returns (bool) {
    require(user != address(0), "Should not be zero address");
    bytes6 ref = getRefByAddress(user);
    refLookup[ref] = user;
    return true;
  }

  function checkSignature(bytes memory sig, address user) public view returns (bool) {
    bytes32 dataHash = keccak256(abi.encodePacked(user));
    return (ECDSA.recover(dataHash, sig) == registrator);
  }

  function checkPermissionSignature(
    bytes memory sig, 
    address user, 
    address tokenAddress,
    uint256 value,
    uint256 nonce
  ) 
    public view returns (bool) 
  {
    bytes32 dataHash = keccak256(abi.encodePacked(user, tokenAddress, value, nonce));
    return (ECDSA.recover(dataHash, sig) == registrator);
  }

  function authorizeAddress(bytes memory authSignature, bytes6 ref) public whenNotPaused returns (bool) {
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

  function suspendIfNecessary(address tokenAddress) private returns (bool) {
    // When 10% of totalSupply is burned suspend the token just in case 
    // there is a chance that its contract is broken
    if (tokens[tokenAddress].burnedAccumulator > tokens[tokenAddress].suspiciousVolume) {
      tokens[tokenAddress].status = TokenStatus.Suspended;
      return true;
    }
    return false;
  }

  // Discount
  function discountCorrectionIfNecessary(uint256 balance) private returns (bool) {
    if (balance < balanceThreshold) {
      // Update discountNumerator, discountDenominator and balanceThreshold
      // we multiply discount coefficient by discountNumeratorMul / discountDenominatorMul
      discountNumerator = discountNumerator.mul(discountNumeratorMul);
      discountDenominator = discountDenominator.mul(discountDenominatorMul);
      balanceThreshold = balanceThreshold.mul(discountNumeratorMul).div(discountDenominatorMul);
      emit DiscountUpdate(discountNumerator, discountDenominator, balanceThreshold);
      return true;
    }
    return false;
  }

  // Helpers
  function getAllTokenData(
    address tokenAddress,
    address user
  )
    public view returns (uint256, uint256, uint256, uint256, bool) 
  {
    IERC20 tokenContract = IERC20(tokenAddress);
    uint256 balance = tokenContract.balanceOf(user);
    uint256 allowance = tokenContract.allowance(user, address(this));
    uint256 burnedByUser = amountBurnedByUser(tokenAddress, user);
    uint256 burnedTotal = amountBurnedTotal(tokenAddress);
    bool isActive = (tokens[tokenAddress].status == TokenStatus.Active);
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
    return bTokenValue.mul(partnerRewardRateNumerator).div(partnerRewardRateDenominator);
  }

  function burn(
    address tokenAddress, 
    uint256 value
  )
    public 
    whenNotPaused
    whenNoPermissionRequired
  {
    _burn(tokenAddress, value);
  }

  function burnPermissioned(
    address tokenAddress, 
    uint256 value,
    uint256 nonce,
    bytes memory permissionSignature
  )
    public 
    whenNotPaused
  {
    require(nonces[msg.sender] < nonce, "New nonce should be greater than previous");
    bool signatureOk = checkPermissionSignature(permissionSignature, msg.sender, tokenAddress, value, nonce);
    require(signatureOk, "Permission should have a correct signature");
    nonces[msg.sender] = nonce;
    _burn(tokenAddress, value);
  }

  function _burn(address tokenAddress, uint256 value) private {
    address partner = referalPartners[msg.sender];
    require(partner != address(0), "Burner should be registered");
    
    IERC20 tokenContract = IERC20(tokenAddress);
    
    require(tokenContract.allowance(msg.sender, address(this)) >= value, "Should be allowed");
 
    uint256 bTokenValueTotal; // total user reward including bonus if allowed
    uint256 bTokenValue = getBTokenValue(tokenAddress, value);
    uint256 currentBalance = bToken.balanceOf(address(this));
    require(bTokenValue < currentBalance.div(100), "Cannot reward more than 1% of the balance");

    uint256 bTokenPartnerReward = getPartnerReward(bTokenValue);
    
    // Update counters
    tokens[tokenAddress].burned = tokens[tokenAddress].burned.add(value);
    tokens[tokenAddress].burnedAccumulator = tokens[tokenAddress].burnedAccumulator.add(value);
    burnedByTokenUser[tokenAddress][msg.sender] = burnedByTokenUser[tokenAddress][msg.sender].add(value);
    
    tokenContract.transferFrom(msg.sender, burnAddress, value); // burn shit-token
    discountCorrectionIfNecessary(currentBalance.sub(bTokenValue).sub(bTokenPartnerReward));
    
    suspendIfNecessary(tokenAddress);

    bToken.transfer(partner, bTokenPartnerReward);

    if (shouldGetBonus[msg.sender]) {
      // give 20% bonus once
      shouldGetBonus[msg.sender] = false;
      bTokenValueTotal = bTokenValue.add(bTokenValue.mul(bonusNumerator).div(bonusDenominator));
    } else {
      bTokenValueTotal = bTokenValue;
    }

    bToken.transfer(msg.sender, bTokenValueTotal);
    emit Burn(tokenAddress, msg.sender, partner, value, bTokenValueTotal, bTokenPartnerReward);
  }
}