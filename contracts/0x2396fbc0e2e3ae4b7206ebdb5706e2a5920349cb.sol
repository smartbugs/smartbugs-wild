pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ERC20 {

    // Get the total token supply
    function totalSupply() public view returns (uint256);

    // Get the account balance of another account with address _owner
    function balanceOf(address who) public view returns (uint256);

    // Send _value amount of tokens to address _to
    function transfer(address to, uint256 value) public returns (bool);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address from, address to, uint256 value) public returns (bool);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address spender, uint256 value) public returns (bool);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address owner, address spender) public view returns (uint256);

    // Triggered when tokens are transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed owner,address indexed spender,uint256 value);
}


/// @title Implementation of basic ERC20 function.
/// @notice The only difference from most other ERC20 contracts is that we introduce 2 superusers - the founder and the admin.
contract _Base20 is ERC20 {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) internal allowed;

  mapping(address => uint256) internal accounts;

  address internal admin;

  address payable internal founder;

  uint256 internal __totalSupply;

  constructor(uint256 _totalSupply,
    address payable _founder,
    address _admin) public {
      __totalSupply = _totalSupply;
      admin = _admin;
      founder = _founder;
      accounts[founder] = __totalSupply;
      emit Transfer(address(0), founder, accounts[founder]);
    }

    // define onlyAdmin
    modifier onlyAdmin {
      require(admin == msg.sender);
      _;
    }

    // define onlyFounder
    modifier onlyFounder {
      require(founder == msg.sender);
      _;
    }

    // Change founder
    function changeFounder(address payable who) onlyFounder public {
      founder = who;
    }

    // show founder address
    function getFounder() onlyFounder public view returns (address) {
      return founder;
    }

    // Change admin
    function changeAdmin(address who) public {
      require(who == founder || who == admin);
      admin = who;
    }

    // show admin address
    function getAdmin() public view returns (address) {
      require(msg.sender == founder || msg.sender == admin);
      return admin;
    }

    //
    // ERC20 spec.
    //
    function totalSupply() public view returns (uint256) {
      return __totalSupply;
    }

    // ERC20 spec.
    function balanceOf(address _owner) public view returns (uint256) {
      return accounts[_owner];
    }

    function _transfer(address _from, address _to, uint256 _value)
    internal returns (bool) {
      require(_to != address(0));

      require(_value <= accounts[_from]);

      // This should go first. If SafeMath.add fails, the sender's balance is not changed
      accounts[_to] = accounts[_to].add(_value);
      accounts[_from] = accounts[_from].sub(_value);

      emit Transfer(_from, _to, _value);

      return true;
    }
    // ERC20 spec.
    function transfer(address _to, uint256 _value) public returns (bool) {
      return _transfer(msg.sender, _to, _value);
    }

    // ERC20 spec.
    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool) {
      require(_value <= allowed[_from][msg.sender]);

      // _transfer is either successful, or throws.
      _transfer(_from, _to, _value);

      allowed[_from][msg.sender] -= _value;
      emit Approval(_from, msg.sender, allowed[_from][msg.sender]);

      return true;
    }

    // ERC20 spec.
    function approve(address _spender, uint256 _value) public returns (bool) {
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
    }

    // ERC20 spec.
    function allowance(address _owner, address _spender) public view returns (uint256) {
      return allowed[_owner][_spender];
    }
}


/// @title Admin can suspend specific wallets in cases of misbehaving or theft.
/// @notice This contract implements methods to lock tranfers, either globally or for specific accounts.
contract _Suspendable is _Base20 {
  /// @dev flag whether transfers are allowed on global scale.
  ///    When `isTransferable` is `false`, all transfers between wallets are blocked.
  bool internal isTransferable = false;
  /// @dev set of suspended wallets.
  ///   When `suspendedAddresses[wallet]` is `true`, the `wallet` can't both send and receive COLs.
  mapping(address => bool) internal suspendedAddresses;

  /// @notice Sets total supply and the addresses of super users - founder and admin.
  /// @param _totalSupply Total amount of Color Coin tokens available.
  /// @param _founder Address of the founder wallet
  /// @param _admin Address of the admin wallet
  constructor(uint256 _totalSupply,
    address payable _founder,
    address _admin) public _Base20(_totalSupply, _founder, _admin)
  {
  }

  /// @dev specifies that the marked method could be used only when transfers are enabled.
  ///   Founder can always transfer
  modifier transferable {
    require(isTransferable || msg.sender == founder);
    _;
  }

  /// @notice Getter for the global flag `isTransferable`.
  /// @dev Everyone is allowed to view it.
  function isTransferEnabled() public view returns (bool) {
    return isTransferable;
  }

  /// @notice Enable tranfers globally.
  ///   Note that suspended acccounts remain to be suspended.
  /// @dev Sets the global flag `isTransferable` to `true`.
  function enableTransfer() onlyAdmin public {
    isTransferable = true;
  }

  /// @notice Disable tranfers globally.
  ///   All transfers between wallets are blocked.
  /// @dev Sets the global flag `isTransferable` to `false`.
  function disableTransfer() onlyAdmin public {
    isTransferable = false;
  }

  /// @notice Check whether an address is suspended.
  /// @dev Everyone can check any address they want.
  /// @param _address wallet to check
  /// @return returns `true` if the wallet `who` is suspended.
  function isSuspended(address _address) public view returns(bool) {
    return suspendedAddresses[_address];
  }

  /// @notice Suspend an individual wallet.
  /// @dev Neither the founder nor the admin could be suspended.
  /// @param who  address of the wallet to suspend.
  function suspend(address who) onlyAdmin public {
    if (who == founder || who == admin) {
      return;
    }
    suspendedAddresses[who] = true;
  }

  /// @notice Unsuspend an individual wallet
  /// @param who  address of the wallet to unsuspend.
  function unsuspend(address who) onlyAdmin public {
    suspendedAddresses[who] = false;
  }

  //
  // Update of ERC20 functions
  //

  /// @dev Internal function for transfers updated.
  ///   Neither source nor destination of the transfer can be suspended.
  function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
    require(!isSuspended(_to));
    require(!isSuspended(_from));

    return super._transfer(_from, _to, _value);
  }

  /// @notice `transfer` can't happen when transfers are disabled globally
  /// @dev added modifier `transferable`.
  function transfer(address _to, uint256 _value) public transferable returns (bool) {
    return _transfer(msg.sender, _to, _value);
  }

  /// @notice `transferFrom` can't happen when transfers are disabled globally
  /// @dev added modifier `transferable`.
  function transferFrom(address _from, address _to, uint256 _value) public transferable returns (bool) {
    require(!isSuspended(msg.sender));
    return super.transferFrom(_from, _to, _value);
  }

  // ERC20 spec.
  /// @notice `approve` can't happen when transfers disabled globally
  ///   Suspended users are not allowed to do approvals as well.
  /// @dev  Added modifier `transferable`.
  function approve(address _spender, uint256 _value) public transferable returns (bool) {
    require(!isSuspended(msg.sender));
    return super.approve(_spender, _value);
  }

  /// @notice Change founder. New founder must not be suspended.
  function changeFounder(address payable who) onlyFounder public {
    require(!isSuspended(who));
    super.changeFounder(who);
  }

  /// @notice Change admin. New admin must not be suspended.
  function changeAdmin(address who) public {
    require(!isSuspended(who));
    super.changeAdmin(who);
  }
}


/// @title Advanced functions for Color Coin token smart contract.
/// @notice Implements functions for private ICO and super users.
/// @dev Not intended for reuse.
contract ColorCoinBase is _Suspendable {

  /// @dev Represents a lock-up period.
  struct LockUp {
    /// @dev end of the period, in seconds since the epoch.
    uint256 unlockDate;
    /// @dev amount of coins to be unlocked at the end of the period.
    uint256 amount;
  }

  /// @dev Represents a wallet with lock-up periods.
  struct Investor {
    /// @dev initial amount of locked COLs
    uint256 initialAmount;
    /// @dev current amount of locked COLs
    uint256 lockedAmount;
    /// @dev current lock-up period, index in the array `lockUpPeriods`
    uint256 currentLockUpPeriod;
    /// @dev the list of lock-up periods
    LockUp[] lockUpPeriods;
  }

  /// @dev Entry in the `adminTransferLog`, that stores the history of admin operations.
  struct AdminTransfer {
    /// @dev the wallet, where COLs were withdrawn from
    address from;
    /// @dev the wallet, where COLs were deposited to
    address to;
    /// @dev amount of coins transferred
    uint256 amount;
    /// @dev the reason, why super user made this transfer
    string  reason;
  }

  /// @notice The event that is fired when a lock-up period expires for a certain wallet.
  /// @param  who the wallet where the lock-up period expired
  /// @param  period  the number of the expired period
  /// @param  amount  amount of unlocked coins.
  event Unlock(address who, uint256 period, uint256 amount);

  /// @notice The event that is fired when a super user makes transfer.
  /// @param  from the wallet, where COLs were withdrawn from
  /// @param  to  the wallet, where COLs were deposited to
  /// @param  requestedAmount  amount of coins, that the super user requested to transfer
  /// @param  returnedAmount  amount of coins, that were actually transferred
  /// @param  reason  the reason, why super user made this transfer
  event SuperAction(address from, address to, uint256 requestedAmount, uint256 returnedAmount, string reason);

  /// @dev  set of wallets with lock-up periods
  mapping (address => Investor) internal investors;

  /// @dev amount of Color Coins locked in lock-up wallets.
  ///   It is used to calculate circulating supply.
  uint256 internal totalLocked;

  /// @dev the list of transfers performed by super users
  AdminTransfer[] internal adminTransferLog;

  /// @notice Sets total supply and the addresses of super users - founder and admin.
  /// @param _totalSupply Total amount of Color Coin tokens available.
  /// @param _founder Address of the founder wallet
  /// @param _admin Address of the admin wallet
  constructor(uint256 _totalSupply,
    address payable _founder,
    address _admin
  ) public _Suspendable (_totalSupply, _founder, _admin)
  {
  }

  //
  // ERC20 spec.
  //

  /// @notice Returns the balance of a wallet.
  ///   For wallets with lock-up the result of this function inludes both free floating and locked COLs.
  /// @param _owner The address of a wallet.
  function balanceOf(address _owner) public view returns (uint256) {
    return accounts[_owner] + investors[_owner].lockedAmount;
  }

  /// @dev Performs transfer from one wallet to another.
  ///   The maximum amount of COLs to transfer equals to `balanceOf(_from) - getLockedAmount(_from)`.
  ///   This function unlocks COLs if any of lock-up periods expired at the moment
  ///   of the transaction execution.
  ///   Calls `Suspendable._transfer` to do the actual transfer.
  ///   This function is used by ERC20 `transfer` function.
  /// @param  _from   wallet from which tokens are withdrawn.
  /// @param  _to   wallet to which tokens are deposited.
  /// @param  _value  amount of COLs to transfer.
  function _transfer(address _from, address _to, uint256 _value)
  internal returns (bool) {
    if (hasLockup(_from)) {
      tryUnlock(_from);
    }
    super._transfer(_from, _to, _value);
  }

  /// @notice The founder sends COLs to early investors and sets lock-up periods.
  ///   Initially all distributed COL's are locked.
  /// @dev  Only founder can call this function.
  /// @param _to  address of the wallet that receives the COls.
  /// @param _value amount of COLs that founder sends to the investor's wallet.
  /// @param unlockDates array of lock-up period dates.
  ///   Each date is in seconds since the epoch. After `unlockDates[i]` is expired,
  ///   the corresponding `amounts[i]` amount of COLs gets unlocked.
  ///   After expiring the last date in this array all COLs become unlocked.
  /// @param amounts array of COL amounts to unlock.
  function distribute(address _to, uint256 _value,
      uint256[] memory unlockDates, uint256[] memory amounts
    ) onlyFounder public returns (bool) {
    // We distribute invested coins to new wallets only
    require(balanceOf(_to) == 0);
    require(_value <= accounts[founder]);
    require(unlockDates.length == amounts.length);

    // We don't check that unlock dates strictly increase.
    // That doesn't matter. It will work out in tryUnlock function.

    // We don't check that amounts in total equal to _value.
    // tryUnlock unlocks no more that _value anyway.

    investors[_to].initialAmount = _value;
    investors[_to].lockedAmount = _value;
    investors[_to].currentLockUpPeriod = 0;

    for (uint256 i=0; i<unlockDates.length; i++) {
      investors[_to].lockUpPeriods.push(LockUp(unlockDates[i], amounts[i]));
    }

    // ensureLockUp(_to);
    accounts[founder] -= _value;
    emit Transfer(founder, _to, _value);
    totalLocked = totalLocked.add(_value);
    // Check the lock-up periods. If the leading periods are 0 or already expired
    // unlock corresponding coins.
    tryUnlock(_to);
    return true;
  }

  /// @notice Returns `true` if the wallet has locked COLs
  /// @param _address address of the wallet.
  /// @return `true` if the wallet has locked COLs and `false` otherwise.
  function hasLockup(address _address) public view returns(bool) {
    return (investors[_address].lockedAmount > 0);
  }

  //
  // Unlock operations
  //

  /// @dev tells whether the wallet still has lockup and number of seconds until unlock date.
  /// @return locked if `locked` is true, the wallet still has a lockup period, otherwise all lockups expired.
  /// @return seconds amount of time in seconds until unlock date. Zero means that it has expired,
  ///   and the user can invoke `doUnlock` to release corresponding coins.
  function _nextUnlockDate(address who) internal view returns (bool, uint256) {
    if (!hasLockup(who)) {
      return (false, 0);
    }

    uint256 i = investors[who].currentLockUpPeriod;
    // This must not happen! but still...
    // If all lockup periods have expired, but there are still locked coins,
    // tell the user to unlock.
    if (i == investors[who].lockUpPeriods.length) return (true, 0);

    if (now < investors[who].lockUpPeriods[i].unlockDate) {
      // If the next unlock date is in the future, return the number of seconds left
      return (true, investors[who].lockUpPeriods[i].unlockDate - now);
    } else {
      // The current unlock period has expired.
      return (true, 0);
    }
  }

  /// @notice tells the wallet owner whether the wallet still has lockup and number of seconds until unlock date.
  /// @return locked if `locked` is true, the wallet still has a lockup period, otherwise all lockups expired.
  /// @return seconds amount of time in seconds until unlock date. Zero means that it has expired,
  ///   and the user can invoke `doUnlock` to release corresponding coins.
  function nextUnlockDate() public view returns (bool, uint256) {
    return _nextUnlockDate(msg.sender);
  }

  /// @notice tells to the admin whether the wallet still has lockup and number of seconds until unlock date.
  /// @return locked if `locked` is true, the wallet still has a lockup period, otherwise all lockups expired.
  /// @return seconds amount of time in seconds until unlock date. Zero means that it has expired,
  ///   and the user can invoke `doUnlock` to release corresponding coins.
  function nextUnlockDate_Admin(address who) public view onlyAdmin returns (bool, uint256) {
    return _nextUnlockDate(who);
  }

  /// @notice the wallet owner signals that the next unlock period has passed, and some coins could be unlocked
  function doUnlock() public {
    tryUnlock(msg.sender);
  }

  /// @notice admin unlocks coins in the wallet, if any
  /// @param who the wallet to unlock coins
  function doUnlock_Admin(address who) public onlyAdmin {
    tryUnlock(who);
  }
  /// @notice Returns the amount of locked coins in the wallet.
  ///   This function tells the amount of coins to the wallet owner only.
  /// @return amount of locked COLs by `now`.
  function getLockedAmount() public view returns (uint256) {
    return investors[msg.sender].lockedAmount;
  }

  /// @notice Returns the amount of locked coins in the wallet.
  /// @return amount of locked COLs by `now`.
  function getLockedAmount_Admin(address who) public view onlyAdmin returns (uint256) {
    return investors[who].lockedAmount;
  }

  function tryUnlock(address _address) internal {
    if (!hasLockup(_address)) {
      return ;
    }

    uint256 amount = 0;
    uint256 i;
    uint256 start = investors[_address].currentLockUpPeriod;
    uint256 end = investors[_address].lockUpPeriods.length;

    for ( i = start;
          i < end;
          i++)
    {
      if (investors[_address].lockUpPeriods[i].unlockDate <= now) {
        amount += investors[_address].lockUpPeriods[i].amount;
      } else {
        break;
      }
    }

    if (i == investors[_address].lockUpPeriods.length) {
      // all unlock periods expired. Unlock all
      amount = investors[_address].lockedAmount;
    } else if (amount > investors[_address].lockedAmount) {
      amount = investors[_address].lockedAmount;
    }

    if (amount > 0 || i > start) {
      investors[_address].lockedAmount = investors[_address].lockedAmount.sub(amount);
      investors[_address].currentLockUpPeriod = i;
      accounts[_address] = accounts[_address].add(amount);
      emit Unlock(_address, i, amount);
      totalLocked = totalLocked.sub(amount);
    }
  }

  //
  // Circulating supply
  //

  /// @notice Returns the circulating supply of Color Coins.
  ///   It consists of all unlocked coins in user wallets.
  function circulatingSupply() public view returns(uint256) {
    return __totalSupply.sub(accounts[founder]).sub(totalLocked);
  }

  //
  // Release contract
  //

  /// @notice Calls `selfdestruct` operator and transfers all Ethers to the founder (if any)
  function destroy() public onlyAdmin {
    selfdestruct(founder);
  }
}


/// @title Dedicated methods for Pixel program
/// @notice Pixels are a type of “airdrop” distributed to all Color Coin wallet holders,
///   five Pixels a day. They are awarded on a periodic basis. Starting from Sunday GMT 0:00,
///   the Pixels have a lifespan of 24 hours. Pixels in their original form do not have any value.
///   The only way Pixels have value is by sending them to other wallet holders.
///   Pixels must be sent to another person’s account within 24 hours or they will become void.
///   Each user can send up to five Pixels to a single account per week. Once a wallet holder receives Pixels,
///   the Pixels will become Color Coins. The received Pixels may be converted to Color Coins
///   on weekly basis, after Saturday GMT 24:00.
/// @dev Pixel distribution might require thousands and tens of thousands transactions.
///   The methods in this contract consume less gas compared to batch transactions.
contract ColorCoinWithPixel is ColorCoinBase {

  address internal pixelAccount;

  /// @dev The rate to convert pixels to Color Coins
  uint256 internal pixelConvRate;

  /// @dev Methods could be called by either the founder of the dedicated account.
  modifier pixelOrFounder {
    require(msg.sender == founder || msg.sender == pixelAccount);
    _;
  }

  function circulatingSupply() public view returns(uint256) {
    uint256 result = super.circulatingSupply();
    return result - balanceOf(pixelAccount);
  }

  /// @notice Initialises a newly created instance.
  /// @dev Initialises Pixel-related data and transfers `_pixelCoinSupply` COLs
  ///   from the `_founder` to `_pixelAccount`.
  /// @param _totalSupply Total amount of Color Coin tokens available.
  /// @param _founder Address of the founder wallet
  /// @param _admin Address of the admin wallet
  /// @param _pixelCoinSupply Amount of tokens dedicated for Pixel program
  /// @param _pixelAccount Address of the account that keeps coins for the Pixel program
  constructor(uint256 _totalSupply,
    address payable _founder,
    address _admin,
    uint256 _pixelCoinSupply,
    address _pixelAccount
  ) public ColorCoinBase (_totalSupply, _founder, _admin)
  {
    require(_pixelAccount != _founder);
    require(_pixelAccount != _admin);

    pixelAccount = _pixelAccount;
    accounts[pixelAccount] = _pixelCoinSupply;
    accounts[_founder] = accounts[_founder].sub(_pixelCoinSupply);
    emit Transfer(founder, pixelAccount, accounts[pixelAccount]);
  }

  /// @notice Founder or the pixel account set the pixel conversion rate.
  ///   Pixel team first sets this conversion rate and then start sending COLs
  ///   in exchange of pixels that people have received.
  /// @dev This rate is used in `sendCoinsForPixels` functions to calculate the amount
  ///   COLs to transfer to pixel holders.
  function setPixelConversionRate(uint256 _pixelConvRate) public pixelOrFounder {
    pixelConvRate = _pixelConvRate;
  }

  /// @notice Get the conversion rate that was used in the most recent exchange of pixels to COLs.
  function getPixelConversionRate() public view returns (uint256) {
    return pixelConvRate;
  }

  /// @notice Distribute COL coins for pixels
  ///   COLs are spent from `pixelAccount` wallet. The amount of COLs is equal to `getPixelConversionRate() * pixels`
  /// @dev Only founder and pixel account can invoke this function.
  /// @param pixels       Amount of pixels to exchange into COLs
  /// @param destination  The wallet that holds the pixels.
  function sendCoinsForPixels(
    uint32 pixels, address destination
  ) public pixelOrFounder {
    uint256 coins = pixels*pixelConvRate;
    if (coins == 0) return;

    require(coins <= accounts[pixelAccount]);

    accounts[destination] = accounts[destination].add(coins);
    accounts[pixelAccount] -= coins;
    emit Transfer(pixelAccount, destination, coins);
  }

  /// @notice Distribute COL coins for pixels to multiple users.
  ///   This function consumes less gas compared to a batch transaction of `sendCoinsForPixels`.
  ///   `pixels[i]` specifies the amount of pixels belonging to `destinations[i]` wallet.
  ///   COLs are spent from `pixelAccount` wallet. The amount of COLs sent to i-th wallet is equal to `getPixelConversionRate() * pixels[i]`
  /// @dev Only founder and pixel account can invoke this function.
  /// @param pixels         Array of pixel amounts to exchange into COLs
  /// @param destinations   Array of addresses of wallets that hold pixels.
  function sendCoinsForPixels_Batch(
    uint32[] memory pixels,
    address[] memory destinations
  ) public pixelOrFounder {
    require(pixels.length == destinations.length);
    uint256 total = 0;
    for (uint256 i = 0; i < pixels.length; i++) {
      uint256 coins = pixels[i]*pixelConvRate;
      address dst = destinations[i];
      accounts[dst] = accounts[dst].add(coins);
      emit Transfer(pixelAccount, dst, coins);
      total += coins;
    }

    require(total <= accounts[pixelAccount]);
    accounts[pixelAccount] -= total;
  }

  /// @notice Distribute COL coins for pixels to multiple users.
  ///   COLs are spent from `pixelAccount` wallet. The amount of COLs sent to each wallet is equal to `getPixelConversionRate() * pixels`
  /// @dev The difference between `sendCoinsForPixels_Array` and `sendCoinsForPixels_Batch`
  ///   is that all destination wallets hold the same amount of pixels.
  ///   This optimization saves about 10% of gas compared to `sendCoinsForPixels_Batch`
  ///   with the same amount of recipients.
  /// @param pixels   Amount of pixels to exchange. All of `recipients` hold the same amount of pixels.
  /// @param recipients Addresses of wallets, holding `pixels` amount of pixels.
  function sendCoinsForPixels_Array(
    uint32 pixels, address[] memory recipients
  ) public pixelOrFounder {
    uint256 coins = pixels*pixelConvRate;
    uint256 total = coins * recipients.length;

    if (total == 0) return;
    require(total <= accounts[pixelAccount]);

    for (uint256 i; i < recipients.length; i++) {
      address dst = recipients[i];
      accounts[dst] = accounts[dst].add(coins);
      emit Transfer(pixelAccount, dst, coins);
    }

    accounts[pixelAccount] -= total;
  }
}


/// @title Smart contract for Color Coin token.
/// @notice Color is the next generation platform for high-performance sophisticated decentralized applications (dApps). https://www.colors.org/
/// @dev Not intended for reuse.
contract ColorCoin is ColorCoinWithPixel {
  /// @notice Token name
  string public constant name = "Color Coin";

  /// @notice Token symbol
  string public constant symbol = "CLR";

  /// @notice Precision in fixed point arithmetics
  uint8 public constant decimals = 18;

  /// @notice Initialises a newly created instance
  /// @param _totalSupply Total amount of Color Coin tokens available.
  /// @param _founder Address of the founder wallet
  /// @param _admin Address of the admin wallet
  /// @param _pixelCoinSupply Amount of tokens dedicated for Pixel program
  /// @param _pixelAccount Address of the account that keeps coins for the Pixel program
  constructor(uint256 _totalSupply,
    address payable _founder,
    address _admin,
    uint256 _pixelCoinSupply,
    address _pixelAccount
  ) public ColorCoinWithPixel (_totalSupply, _founder, _admin, _pixelCoinSupply, _pixelAccount)
  {
  }
}