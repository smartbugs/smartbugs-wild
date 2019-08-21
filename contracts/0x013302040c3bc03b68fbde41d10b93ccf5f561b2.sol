/**
 * This smart contract code is Copyright 2018 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */


/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

/**
 * Deserialize bytes payloads.
 *
 * Values are in big-endian byte order.
 *
 */
library BytesDeserializer {

  /**
   * Extract 256-bit worth of data from the bytes stream.
   */
  function slice32(bytes b, uint offset) constant returns (bytes32) {
    bytes32 out;

    for (uint i = 0; i < 32; i++) {
      out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
    }
    return out;
  }

  /**
   * Extract Ethereum address worth of data from the bytes stream.
   */
  function sliceAddress(bytes b, uint offset) constant returns (address) {
    bytes32 out;

    for (uint i = 0; i < 20; i++) {
      out |= bytes32(b[offset + i] & 0xFF) >> ((i+12) * 8);
    }
    return address(uint(out));
  }

  /**
   * Extract 128-bit worth of data from the bytes stream.
   */
  function slice16(bytes b, uint offset) constant returns (bytes16) {
    bytes16 out;

    for (uint i = 0; i < 16; i++) {
      out |= bytes16(b[offset + i] & 0xFF) >> (i * 8);
    }
    return out;
  }

  /**
   * Extract 32-bit worth of data from the bytes stream.
   */
  function slice4(bytes b, uint offset) constant returns (bytes4) {
    bytes4 out;

    for (uint i = 0; i < 4; i++) {
      out |= bytes4(b[offset + i] & 0xFF) >> (i * 8);
    }
    return out;
  }

  /**
   * Extract 16-bit worth of data from the bytes stream.
   */
  function slice2(bytes b, uint offset) constant returns (bytes2) {
    bytes2 out;

    for (uint i = 0; i < 2; i++) {
      out |= bytes2(b[offset + i] & 0xFF) >> (i * 8);
    }
    return out;
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
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 *      Supports unlimited numbers of roles and addresses.
 *      See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * A constant role name for indicating admins.
   */
  string public constant ROLE_ADMIN = "admin";

  /**
   * @dev constructor. Sets msg.sender as admin by default
   */
  function RBAC()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
  }

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to admins
   * // reverts
   */
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}




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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface InvestorToken {
  function transferInvestorTokens(address, uint256);
}

/// @title TokenMarket Exchange Smart Contract
/// @author TokenMarket Ltd. / Ville Sundell <ville at tokenmarket.net> and Rainer Koirikivi <rainer at tokenmarket.net>
contract Exchange is RBAC {
    using SafeMath for uint256;
    using BytesDeserializer for bytes;

    // Roles for Role Based Access Control, initially the deployer account will
    // have all of these roles:
    string public constant ROLE_FORCED = "forced";
    string public constant ROLE_TRANSFER_TOKENS = "transfer tokens";
    string public constant ROLE_TRANSFER_INVESTOR_TOKENS = "transfer investor tokens";
    string public constant ROLE_CLAIM = "claim";
    string public constant ROLE_WITHDRAW = "withdraw";
    string public constant ROLE_TRADE = "trade";
    string public constant ROLE_CHANGE_DELAY = "change delay";
    string public constant ROLE_SET_FEEACCOUNT = "set feeaccount";
    string public constant ROLE_TOKEN_WHITELIST = "token whitelist user";


    /// @dev Is the withdrawal transfer (identified by the hash) executed:
    mapping(bytes32 => bool) public withdrawn;
    /// @dev Is the out-bound transfer (identified by the hash) executed:
    mapping(bytes32 => bool) public transferred;
    /// @dev Is the token whitelisted for deposit:
    mapping(address => bool) public tokenWhitelist;
    /// @dev Keeping account of the total supply per token we posses:
    mapping(address => uint256) public tokensTotal;
    /// @dev Keeping account what tokens the user owns, and how many:
    mapping(address => mapping(address => uint256)) public balanceOf;
    /// @dev How much of the order (identified by hash) has been filled:
    mapping (bytes32 => uint256) public orderFilled;
    /// @dev Account where fees should be deposited to:
    address public feeAccount;
    /// @dev This defines the delay in seconds between user initiang withdrawal
    ///      by themselves with withdrawRequest(), and finalizing the withdrawal
    ///      with withdrawUser():
    uint256 public delay;

    /// @dev This is emitted when token is added or removed from the whitelist:
    event TokenWhitelistUpdated(address token, bool status);
    /// @dev This is emitted when fee account is changed
    event FeeAccountChanged(address newFeeAccocunt);
    /// @dev This is emitted when delay between the withdrawRequest() and withdrawUser() is changed:
    event DelayChanged(uint256 newDelay);
    /// @dev This is emitted when user deposits either ether (token 0x0) or tokens:
    event Deposited(address token, address who, uint256 amount, uint256 balance);
    /// @dev This is emitted when tokens are forcefully pushed back to user (for example because of contract update):
    event Forced(address token, address who, uint256 amount);
    /// @dev This is emitted when user is Withdrawing ethers (token 0x0) or tokens with withdrawUser():
    event Withdrawn(address token, address who, uint256 amount, uint256 balance);
    /// @dev This is emitted when user starts withdrawal process with withdrawRequest():
    event Requested(address token, address who, uint256 amount, uint256 index);
    /// @dev This is emitted when Investor Interaction Contract tokens are transferred:
    event TransferredInvestorTokens(address, address, address, uint256);
    /// @dev This is emitted when tokens are transferred inside this Exchange smart contract:
    event TransferredTokens(address, address, address, uint256, uint256, uint256);
    /// @dev This is emitted when order gets executed, one for each "side" (right and left):
    event OrderExecuted(
        bytes32 orderHash,
        address maker,
        address baseToken,
        address quoteToken,
        address feeToken,
        uint256 baseAmountFilled,
        uint256 quoteAmountFilled,
        uint256 feePaid,
        uint256 baseTokenBalance,
        uint256 quoteTokenBalance,
        uint256 feeTokenBalance
    );

    /// @dev This struct will have information on withdrawals initiated with withdrawRequest()
    struct Withdrawal {
      address user;
      address token;
      uint256 amount;
      uint256 createdAt;
      bool executed;
    }

    /// @dev This is a list of withdrawals initiated with withdrawRequest()
    ///      and which can be finalized by withdrawUser(index).
    Withdrawal[] withdrawals;

    enum OrderType {Buy, Sell}

    /// @dev This struct is containing all the relevant information from the
    ///      initiating user which can be used as one "side" of each trade
    ///      trade() needs two of these, once for each "side" (left and right).
    struct Order {
      OrderType orderType;
      address maker;
      address baseToken;
      address quoteToken;
      address feeToken;
      uint256 amount;
      uint256 priceNumerator;
      uint256 priceDenominator;
      uint256 feeNumerator;
      uint256 feeDenominator;
      uint256 expiresAt;
      uint256 nonce;
    }

    /// @dev Upon deployment, user withdrawal delay is set, and the initial roles
    /// @param _delay Minimum delay in seconds between withdrawRequest() and withdrawUser()
    function Exchange(uint256 _delay) {
      delay = _delay;

      feeAccount = msg.sender;
      addRole(msg.sender, ROLE_FORCED);
      addRole(msg.sender, ROLE_TRANSFER_TOKENS);
      addRole(msg.sender, ROLE_TRANSFER_INVESTOR_TOKENS);
      addRole(msg.sender, ROLE_CLAIM);
      addRole(msg.sender, ROLE_WITHDRAW);
      addRole(msg.sender, ROLE_TRADE);
      addRole(msg.sender, ROLE_CHANGE_DELAY);
      addRole(msg.sender, ROLE_SET_FEEACCOUNT);
      addRole(msg.sender, ROLE_TOKEN_WHITELIST);
    }

    /// @dev Update token whitelist: only whitelisted tokens can be deposited
    /// @param token The token whose whitelist status will be changed
    /// @param status Is the token whitelisted or not
    function updateTokenWhitelist(address token, bool status) external onlyRole(ROLE_TOKEN_WHITELIST) {
      tokenWhitelist[token] = status;

      TokenWhitelistUpdated(token, status);
    }


    /// @dev Changing the fee account
    /// @param _feeAccount Address of the new fee account
    function setFeeAccount(address _feeAccount) external onlyRole(ROLE_SET_FEEACCOUNT) {
      feeAccount = _feeAccount;

      FeeAccountChanged(feeAccount);
    }

    /// @dev Set user withdrawal delay (must be less than 2 weeks)
    /// @param _delay New delay
    function setDelay(uint256 _delay) external onlyRole(ROLE_CHANGE_DELAY) {
      require(_delay < 2 weeks);
      delay = _delay;

      DelayChanged(delay);
    }

    /// @dev This takes in user's tokens
    ///      User must first call properly approve() on token contract
    ///      The token must be whitelisted with updateTokenWhitelist() beforehand
    /// @param token Token to fetch
    /// @param amount Amount of tokens to fetch, in its smallest denominator
    /// @return true if transfer is successful
    function depositTokens(ERC20 token, uint256 amount) external returns(bool) {
      depositInternal(token, amount);
      require(token.transferFrom(msg.sender, this, amount));
      return true;
    }

    /// @dev This takes in user's ethers
    ///      Ether deposit must be allowed with updateTokenWhitelist(address(0), true)
    /// @return true if transfer is successful
    function depositEthers() external payable returns(bool) {
      depositInternal(address(0), msg.value);
      return true;
    }

    /// @dev By default, backend will provide the withdrawal functionality
    /// @param token Address of the token
    /// @param user Who is the sender (and signer) of this token transfer
    /// @param amount Amount of tokens in its smallest denominator
    /// @param fee Optional fee in the smallest denominator of the token
    /// @param nonce Nonce to make this signed transfer unique
    /// @param v V of the user's key which was used to sign this transfer
    /// @param r R of the user's key which was used to sign this transfer
    /// @param s S of the user's key which was used to sign this transfer
    function withdrawAdmin(ERC20 token, address user, uint256 amount, uint256 fee, uint256 nonce, uint8 v, bytes32 r, bytes32 s) external onlyRole(ROLE_WITHDRAW) {
      bytes32 hash = keccak256(this, token, user, amount, fee, nonce);
      require(withdrawn[hash] == false);
      require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user);
      withdrawn[hash] = true;

      withdrawInternal(token, user, amount, fee);
    }

    /// @dev Backend can force tokens out of the Exchange contract back to user's wallet
    /// @param token Token that backend wants to push back to the user
    /// @param user User whose funds we want to push back
    /// @param amount Amount of tokens in its smallest denominator
    function withdrawForced(ERC20 token, address user, uint256 amount) external onlyRole(ROLE_FORCED) {
      Forced(token, user, amount);
      withdrawInternal(token, user, amount, 0);
    }

    /// @dev First part of the last-resort user withdrawal
    /// @param token Token address that user wants to withdraw
    /// @param amount Amount of tokens in its smallest denominator
    /// @return ID number of the transfer to be passed to withdrawUser()
    function withdrawRequest(ERC20 token, uint256 amount) external returns(uint256) {
      uint256 index = withdrawals.length;
      withdrawals.push(Withdrawal(msg.sender, address(token), amount, now, false));

      Requested(token, msg.sender, amount, index);
      return index;
    }

    /// @dev User can withdraw their tokens here as the last resort. User must call withdrawRequest() first
    /// @param index Unique ID of the withdrawal passed by withdrawRequest()
    function withdrawUser(uint256 index) external {
      require((withdrawals[index].createdAt.add(delay)) < now);
      require(withdrawals[index].executed == false);
      require(withdrawals[index].user == msg.sender);

      withdrawals[index].executed = true;
      withdrawInternal(withdrawals[index].token, withdrawals[index].user, withdrawals[index].amount, 0);
    }

    /// @dev Token transfer inside the Exchange
    /// @param token Address of the token
    /// @param from Who is the sender (and signer) of this internal token transfer
    /// @param to Who is the receiver of this internal token transfer
    /// @param amount Amount of tokens in its smallest denominator
    /// @param fee Optional fee in the smallest denominator of the token
    /// @param nonce Nonce to make this signed transfer unique
    /// @param expires Expiration of this transfer
    /// @param v V of the user's key which was used to sign this transfer
    /// @param r R of the user's key which was used to sign this transfer
    /// @param s S of the user's key which was used to sign this transfer
    function transferTokens(ERC20 token, address from, address to, uint256 amount, uint256 fee, uint256 nonce, uint256 expires, uint8 v, bytes32 r, bytes32 s) external onlyRole(ROLE_TRANSFER_TOKENS) {
      bytes32 hash = keccak256(this, token, from, to, amount, fee, nonce, expires);
      require(expires >= now);
      require(transferred[hash] == false);
      require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == from);

      balanceOf[address(token)][from] = balanceOf[address(token)][from].sub(amount.add(fee));
      balanceOf[address(token)][feeAccount] = balanceOf[address(token)][feeAccount].add(fee);
      balanceOf[address(token)][to] = balanceOf[address(token)][to].add(amount);
      TransferredTokens(token, from, to, amount, fee, nonce);
    }

    /// @dev This is used to interact with TokenMarket's Security Token Infrastructure
    /// @param token Address of the Investor Interaction Contract
    /// @param to Destination where those tokens should be transferred to
    /// @param amount Amount of tokens in its smallest denominator
    function transferInvestorTokens(InvestorToken token, address to, uint256 amount) external onlyRole(ROLE_TRANSFER_INVESTOR_TOKENS) {
      token.transferInvestorTokens(to, amount);
      TransferredInvestorTokens(msg.sender, token, to, amount);
    }

    /// @dev This is used to rescue accidentally transfer()'d tokens
    /// @param token Address of the EIP-20 compatible token'
    function claimExtra(ERC20 token) external onlyRole(ROLE_CLAIM) {
      uint256 totalBalance = token.balanceOf(this);
      token.transfer(feeAccount, totalBalance.sub(tokensTotal[token]));
    }

    /// @dev This is the entry point for trading, and will prepare structs for tradeInternal()
    /// @param _left The binary blob where Order struct will be extracted from
    /// @param leftV V of the user's key which was used to sign _left
    /// @param leftR R of the user's key which was used to sign _left
    /// @param leftS S of the user's key which was used to sign _left
    /// @param _right The binary blob where Order struct will be extracted from
    /// @param rightV V of the user's key which was used to sign _right
    /// @param leftR R of the user's key which was used to sign _right
    /// @param rightS S of the user's key which was used to sign _right
    function trade(bytes _left, uint8 leftV, bytes32 leftR, bytes32 leftS, bytes _right, uint8 rightV, bytes32 rightR, bytes32 rightS) external {
      checkRole(msg.sender, ROLE_TRADE); //If we use the onlyRole() modifier, we will get "stack too deep" error

      Order memory left;
      Order memory right;

      left.maker = _left.sliceAddress(0);
      left.baseToken = _left.sliceAddress(20);
      left.quoteToken = _left.sliceAddress(40);
      left.feeToken = _left.sliceAddress(60);
      left.amount = uint256(_left.slice32(80));
      left.priceNumerator = uint256(_left.slice32(112));
      left.priceDenominator = uint256(_left.slice32(144));
      left.feeNumerator = uint256(_left.slice32(176));
      left.feeDenominator = uint256(_left.slice32(208));
      left.expiresAt = uint256(_left.slice32(240));
      left.nonce = uint256(_left.slice32(272));
      if (_left.slice2(304) == 0) {
          left.orderType = OrderType.Sell;
      } else {
          left.orderType = OrderType.Buy;
      }

      right.maker = _right.sliceAddress(0);
      right.baseToken = _right.sliceAddress(20);
      right.quoteToken = _right.sliceAddress(40);
      right.feeToken = _right.sliceAddress(60);
      right.amount = uint256(_right.slice32(80));
      right.priceNumerator = uint256(_right.slice32(112));
      right.priceDenominator = uint256(_right.slice32(144));
      right.feeNumerator = uint256(_right.slice32(176));
      right.feeDenominator = uint256(_right.slice32(208));
      right.expiresAt = uint256(_right.slice32(240));
      right.nonce = uint256(_right.slice32(272));
      if (_right.slice2(304) == 0) {
          right.orderType = OrderType.Sell;
      } else {
          right.orderType = OrderType.Buy;
      }

      bytes32 leftHash = getOrderHash(left);
      bytes32 rightHash = getOrderHash(right);
      address leftSigner = ecrecover(keccak256("\x19Ethereum Signed Message:\n32", leftHash), leftV, leftR, leftS);
      address rightSigner = ecrecover(keccak256("\x19Ethereum Signed Message:\n32", rightHash), rightV, rightR, rightS);

      require(leftSigner == left.maker);
      require(rightSigner == right.maker);

      tradeInternal(left, leftHash, right, rightHash);
    }

    /// @dev Trading itself happens here
    /// @param left Left side of the order pair
    /// @param leftHash getOrderHash() of the left
    /// @param right Right side of the order pair
    /// @param rightHash getOrderHash() of the right
    function tradeInternal(Order left, bytes32 leftHash, Order right, bytes32 rightHash) internal {
      uint256 priceNumerator;
      uint256 priceDenominator;
      uint256 leftAmountRemaining;
      uint256 rightAmountRemaining;
      uint256 amountBaseFilled;
      uint256 amountQuoteFilled;
      uint256 leftFeePaid;
      uint256 rightFeePaid;

      require(left.expiresAt > now);
      require(right.expiresAt > now);

      require(left.baseToken == right.baseToken);
      require(left.quoteToken == right.quoteToken);

      require(left.baseToken != left.quoteToken);

      require((left.orderType == OrderType.Sell && right.orderType == OrderType.Buy) || (left.orderType == OrderType.Buy && right.orderType == OrderType.Sell));

      require(left.amount > 0);
      require(left.priceNumerator > 0);
      require(left.priceDenominator > 0);
      require(right.amount > 0);
      require(right.priceNumerator > 0);
      require(right.priceDenominator > 0);

      require(left.feeDenominator > 0);
      require(right.feeDenominator > 0);

      require(left.amount % left.priceDenominator == 0);
      require(left.amount % right.priceDenominator == 0);
      require(right.amount % left.priceDenominator == 0);
      require(right.amount % right.priceDenominator == 0);

      if (left.orderType == OrderType.Buy) {
        require((left.priceNumerator.mul(right.priceDenominator)) >= (right.priceNumerator.mul(left.priceDenominator)));
      } else {
        require((left.priceNumerator.mul(right.priceDenominator)) <= (right.priceNumerator.mul(left.priceDenominator)));
      }

      priceNumerator = left.priceNumerator;
      priceDenominator = left.priceDenominator;

      leftAmountRemaining = left.amount.sub(orderFilled[leftHash]);
      rightAmountRemaining = right.amount.sub(orderFilled[rightHash]);

      require(leftAmountRemaining > 0);
      require(rightAmountRemaining > 0);

      if (leftAmountRemaining < rightAmountRemaining) {
        amountBaseFilled = leftAmountRemaining;
      } else {
        amountBaseFilled = rightAmountRemaining;
      }
      amountQuoteFilled = amountBaseFilled.mul(priceNumerator).div(priceDenominator);

      leftFeePaid = calculateFee(amountQuoteFilled, left.feeNumerator, left.feeDenominator);
      rightFeePaid = calculateFee(amountQuoteFilled, right.feeNumerator, right.feeDenominator);

      if (left.orderType == OrderType.Buy) {
        checkBalances(left.maker, left.baseToken, left.quoteToken, left.feeToken, amountBaseFilled, amountQuoteFilled, leftFeePaid);
        checkBalances(right.maker, right.quoteToken, right.baseToken, right.feeToken, amountQuoteFilled, amountBaseFilled, rightFeePaid);

        balanceOf[left.baseToken][left.maker] = balanceOf[left.baseToken][left.maker].add(amountBaseFilled);
        balanceOf[left.quoteToken][left.maker] = balanceOf[left.quoteToken][left.maker].sub(amountQuoteFilled);
        balanceOf[right.baseToken][right.maker] = balanceOf[right.baseToken][right.maker].sub(amountBaseFilled);
        balanceOf[right.quoteToken][right.maker] = balanceOf[right.quoteToken][right.maker].add(amountQuoteFilled);
      } else {
        checkBalances(left.maker, left.quoteToken, left.baseToken, left.feeToken, amountQuoteFilled, amountBaseFilled, leftFeePaid);
        checkBalances(right.maker, right.baseToken, right.quoteToken, right.feeToken, amountBaseFilled, amountQuoteFilled, rightFeePaid);

        balanceOf[left.baseToken][left.maker] = balanceOf[left.baseToken][left.maker].sub(amountBaseFilled);
        balanceOf[left.quoteToken][left.maker] = balanceOf[left.quoteToken][left.maker].add(amountQuoteFilled);
        balanceOf[right.baseToken][right.maker] = balanceOf[right.baseToken][right.maker].add(amountBaseFilled);
        balanceOf[right.quoteToken][right.maker] = balanceOf[right.quoteToken][right.maker].sub(amountQuoteFilled);
      }

      if (leftFeePaid > 0) {
        balanceOf[left.feeToken][left.maker] = balanceOf[left.feeToken][left.maker].sub(leftFeePaid);
        balanceOf[left.feeToken][feeAccount] = balanceOf[left.feeToken][feeAccount].add(leftFeePaid);
      }

      if (rightFeePaid > 0) {
        balanceOf[right.feeToken][right.maker] = balanceOf[right.feeToken][right.maker].sub(rightFeePaid);
        balanceOf[right.feeToken][feeAccount] = balanceOf[right.feeToken][feeAccount].add(rightFeePaid);
      }

      orderFilled[leftHash] = orderFilled[leftHash].add(amountBaseFilled);
      orderFilled[rightHash] = orderFilled[rightHash].add(amountBaseFilled);

      emitOrderExecutedEvent(left, leftHash, amountBaseFilled, amountQuoteFilled, leftFeePaid);
      emitOrderExecutedEvent(right, rightHash, amountBaseFilled, amountQuoteFilled, rightFeePaid);
    }

    /// @dev Calculate the fee for an order
    /// @param amountFilled How much of the order has been filled
    /// @param feeNumerator Will multiply amountFilled with this
    /// @param feeDenominator Will divide amountFilled * feeNumerator with this
    /// @return Will return the fee
    function calculateFee(uint256 amountFilled, uint256 feeNumerator, uint256 feeDenominator) public returns(uint256) {
      return (amountFilled.mul(feeNumerator).div(feeDenominator));
    }

    /// @dev This is the internal method shared by all withdrawal functions
    /// @param token Address of the token withdrawn
    /// @param user Address of the user making the withdrawal
    /// @param amount Amount of token in its smallest denominator
    /// @param fee Fee paid in this particular token
    function withdrawInternal(address token, address user, uint256 amount, uint256 fee) internal {
      require(amount > 0);
      require(balanceOf[token][user] >= amount.add(fee));

      balanceOf[token][user] = balanceOf[token][user].sub(amount.add(fee));
      balanceOf[token][feeAccount] = balanceOf[token][feeAccount].add(fee);
      tokensTotal[token] = tokensTotal[token].sub(amount);

      if (token == address(0)) {
          user.transfer(amount);
      } else {
          require(ERC20(token).transfer(user, amount));
      }

      Withdrawn(token, user, amount, balanceOf[token][user]);
    }

    /// @dev This is the internal method shared by all deposit functions
    ///      The token must have been whitelisted with updateTokenWhitelist()
    /// @param token Address of the token deposited
    /// @param amount Amount of token in its smallest denominator
    function depositInternal(address token, uint256 amount) internal {
      require(tokenWhitelist[address(token)]);

      balanceOf[token][msg.sender] = balanceOf[token][msg.sender].add(amount);
      tokensTotal[token] = tokensTotal[token].add(amount);

      Deposited(token, msg.sender, amount, balanceOf[token][msg.sender]);
    }

    /// @dev This is for emitting OrderExecuted(), one per order
    /// @param order The Order struct which is relevant for this event
    /// @param orderHash Hash received from getOrderHash()
    /// @param amountBaseFilled Amount of order.baseToken filled
    /// @param amountQuoteFilled Amount of order.quoteToken filled
    /// @param feePaid Amount in order.feeToken paid
    function emitOrderExecutedEvent(
      Order order,
      bytes32 orderHash,
      uint256 amountBaseFilled,
      uint256 amountQuoteFilled,
      uint256 feePaid
    ) private {
      uint256 baseTokenBalance = balanceOf[order.baseToken][order.maker];
      uint256 quoteTokenBalance = balanceOf[order.quoteToken][order.maker];
      uint256 feeTokenBalance = balanceOf[order.feeToken][order.maker];
      OrderExecuted(
          orderHash,
          order.maker,
          order.baseToken,
          order.quoteToken,
          order.feeToken,
          amountBaseFilled,
          amountQuoteFilled,
          feePaid,
          baseTokenBalance,
          quoteTokenBalance,
          feeTokenBalance
      );
    }

    /// @dev Order struct will be hashed here with keccak256
    /// @param order The Order struct which will be hashed
    /// @return The keccak256 hash in bytes32
    function getOrderHash(Order order) private returns(bytes32) {
        return keccak256(
            this,
            order.orderType,
            order.maker,
            order.baseToken,
            order.quoteToken,
            order.feeToken,
            order.amount,
            order.priceNumerator,
            order.priceDenominator,
            order.feeNumerator,
            order.feeDenominator,
            order.expiresAt,
            order.nonce
        );
    }

    /// @dev This is used to check balances for a user upon trade, all in once
    /// @param addr Address of the user
    /// @param boughtToken The address of the token which is being bought
    /// @param soldToken The address of the token which is being sold
    /// @param feeToken The token which is used for fees
    /// @param boughtAmount Amount in boughtToken
    /// @param soldAmount Amount in soldTokens
    /// @param feeAmount Amount in feeTokens
    function checkBalances(address addr, address boughtToken, address soldToken, address feeToken, uint256 boughtAmount, uint256 soldAmount, uint256 feeAmount) private {
      if (feeToken == soldToken) {
        require (balanceOf[soldToken][addr] >= (soldAmount.add(feeAmount)));
      } else {
        if (feeToken == boughtToken) {
          require (balanceOf[feeToken][addr].add(boughtAmount) >= feeAmount);
        } else {
          require (balanceOf[feeToken][addr] >= feeAmount);
        }
        require (balanceOf[soldToken][addr] >= soldAmount);
      }
    }
}