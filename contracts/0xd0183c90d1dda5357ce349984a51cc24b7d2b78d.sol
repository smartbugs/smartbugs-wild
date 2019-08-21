// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/Utils/Ownable.sol

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
    require(msg.sender == owner, "msg.sender not owner");
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
    require(_newOwner != address(0), "_newOwner == 0");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Utils/Destructible.sol

pragma solidity ^0.4.24;


/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

// File: contracts/Interfaces/IWallet.sol

pragma solidity ^0.4.24;

/**
 * @title Wallet interface.
 * @dev The interface of the SC that own the assets.
 */
interface IWallet {

  function transferAssetTo(
    address _assetAddress,
    address _to,
    uint _amount
  ) external payable returns (bool);

  function withdrawAsset(
    address _assetAddress,
    uint _amount
  ) external returns (bool);

  function setTokenSwapAllowance (
    address _tokenSwapAddress,
    bool _allowance
  ) external returns(bool);
}

// File: contracts/Utils/Pausable.sol

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
    require(!paused, "The contract is paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "The contract is not paused");
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

// File: contracts/Interfaces/IBadERC20.sol

pragma solidity ^0.4.24;

/**
 * @title Bad formed ERC20 token interface.
 * @dev The interface of the a bad formed ERC20 token.
 */
interface IBadERC20 {
    function transfer(address to, uint256 value) external;
    function approve(address spender, uint256 value) external;
    function transferFrom(
      address from,
      address to,
      uint256 value
    ) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(
      address who
    ) external view returns (uint256);

    function allowance(
      address owner,
      address spender
    ) external view returns (uint256);

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

// File: contracts/Utils/SafeTransfer.sol

pragma solidity ^0.4.24;


/**
 * @title SafeTransfer
 * @dev Transfer Bad ERC20 tokens
 */
library SafeTransfer {
/**
   * @dev Wrapping the ERC20 transferFrom function to avoid missing returns.
   * @param _tokenAddress The address of bad formed ERC20 token.
   * @param _from Transfer sender.
   * @param _to Transfer receiver.
   * @param _value Amount to be transfered.
   * @return Success of the safeTransferFrom.
   */

  function _safeTransferFrom(
    address _tokenAddress,
    address _from,
    address _to,
    uint256 _value
  )
    internal
    returns (bool result)
  {
    IBadERC20(_tokenAddress).transferFrom(_from, _to, _value);

    assembly {
      switch returndatasize()
      case 0 {                      // This is our BadToken
        result := not(0)            // result is true
      }
      case 32 {                     // This is our GoodToken
        returndatacopy(0, 0, 32)
        result := mload(0)          // result == returndata of external call
      }
      default {                     // This is not an ERC20 token
        revert(0, 0)
      }
    }
  }

  /**
   * @dev Wrapping the ERC20 transfer function to avoid missing returns.
   * @param _tokenAddress The address of bad formed ERC20 token.
   * @param _to Transfer receiver.
   * @param _amount Amount to be transfered.
   * @return Success of the safeTransfer.
   */
  function _safeTransfer(
    address _tokenAddress,
    address _to,
    uint _amount
  )
    internal
    returns (bool result)
  {
    IBadERC20(_tokenAddress).transfer(_to, _amount);

    assembly {
      switch returndatasize()
      case 0 {                      // This is our BadToken
        result := not(0)            // result is true
      }
      case 32 {                     // This is our GoodToken
        returndatacopy(0, 0, 32)
        result := mload(0)          // result == returndata of external call
      }
      default {                     // This is not an ERC20 token
        revert(0, 0)
      }
    }
  }
}

// File: contracts/TokenSwap.sol

pragma solidity ^0.4.24;







/**
 * @title TokenSwap.
 * @author Eidoo SAGL.
 * @dev A swap asset contract. The offerAmount and wantAmount are collected and sent into the contract itself.
 */
contract TokenSwap is
  Pausable,
  Destructible
{
  using SafeMath for uint;

  address public baseTokenAddress;
  address public quoteTokenAddress;

  address public wallet;

  uint public buyRate;
  uint public buyRateDecimals;
  uint public sellRate;
  uint public sellRateDecimals;

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );
  event LogSetWallet(address indexed _wallet);
  event LogSetBaseTokenAddress(address indexed _token);
  event LogSetQuoteTokenAddress(address indexed _token);
  event LogSetRateAndRateDecimals(
    uint _buyRate,
    uint _buyRateDecimals,
    uint _sellRate,
    uint _sellRateDecimals
  );
  event LogSetNumberOfZeroesFromLastDigit(
    uint _numberOfZeroesFromLastDigit
  );
  event LogTokenSwap(
    address indexed _userAddress,
    address indexed _userSentTokenAddress,
    uint _userSentTokenAmount,
    address indexed _userReceivedTokenAddress,
    uint _userReceivedTokenAmount
  );

  /**
   * @dev Contract constructor.
   * @param _baseTokenAddress  The base of the swap pair.
   * @param _quoteTokenAddress The quote of the swap pair.
   * @param _buyRate Purchase rate, how many baseToken for the given quoteToken.
   * @param _buyRateDecimals Define the decimals precision for the given asset.
   * @param _sellRate Purchase rate, how many quoteToken for the given baseToken.
   * @param _sellRateDecimals Define the decimals precision for the given asset.
   */
  constructor(
    address _baseTokenAddress,
    address _quoteTokenAddress,
    address _wallet,
    uint _buyRate,
    uint _buyRateDecimals,
    uint _sellRate,
    uint _sellRateDecimals
  )
    public
  {
    require(_wallet != address(0), "_wallet == address(0)");
    baseTokenAddress = _baseTokenAddress;
    quoteTokenAddress = _quoteTokenAddress;
    wallet = _wallet;
    buyRate = _buyRate;
    buyRateDecimals = _buyRateDecimals;
    sellRate = _sellRate;
    sellRateDecimals = _sellRateDecimals;
  }

  function() external {
    revert("fallback function not allowed");
  }

  /**
   * @dev Set base token address.
   * @param _baseTokenAddress The pair base token address.
   * @return bool.
   */
  function setBaseTokenAddress(address _baseTokenAddress)
    public
    onlyOwner
    returns (bool)
  {
    baseTokenAddress = _baseTokenAddress;
    emit LogSetBaseTokenAddress(_baseTokenAddress);
    return true;
  }

  /**
   * @dev Set quote token address.
   * @param _quoteTokenAddress The quote token address.
   * @return bool.
   */
  function setQuoteTokenAddress(address _quoteTokenAddress)
    public
    onlyOwner
    returns (bool)
  {
    quoteTokenAddress = _quoteTokenAddress;
    emit LogSetQuoteTokenAddress(_quoteTokenAddress);
    return true;
  }

  /**
   * @dev Set wallet sc address.
   * @param _wallet The wallet sc address.
   * @return bool.
   */
  function setWallet(address _wallet)
    public
    onlyOwner
    returns (bool)
  {
    require(_wallet != address(0), "_wallet == address(0)");
    wallet = _wallet;
    emit LogSetWallet(_wallet);
    return true;
  }

  /**
   * @dev Set rate.
   * @param _buyRate Multiplier, how many base token for the quote token.
   * @param _buyRateDecimals Number of significan digits of the rate.
   * @param _sellRate Multiplier, how many quote token for the base token.
   * @param _sellRateDecimals Number of significan digits of the rate.
   * @return bool.
   */
  function setRateAndRateDecimals(
    uint _buyRate,
    uint _buyRateDecimals,
    uint _sellRate,
    uint _sellRateDecimals
  )
    public
    onlyOwner
    returns (bool)
  {
    require(_buyRate != buyRate, "_buyRate == buyRate");
    require(_buyRate != 0, "_buyRate == 0");
    require(_sellRate != sellRate, "_sellRate == sellRate");
    require(_sellRate != 0, "_sellRate == 0");
    buyRate = _buyRate;
    sellRate = _sellRate;
    buyRateDecimals = _buyRateDecimals;
    sellRateDecimals = _sellRateDecimals;
    emit LogSetRateAndRateDecimals(
      _buyRate,
      _buyRateDecimals,
      _sellRate,
      _sellRateDecimals
    );
    return true;
  }

  /**
   * @dev Withdraw asset.
   * @param _tokenAddress Asset to be withdrawed.
   * @return bool.
   */
  function withdrawToken(address _tokenAddress)
    public
    onlyOwner
    returns(bool)
  {
    uint tokenBalance;
    if (isETH(_tokenAddress)) {
      tokenBalance = address(this).balance;
      msg.sender.transfer(tokenBalance);
    } else {
      tokenBalance = ERC20(_tokenAddress).balanceOf(address(this));
      require(
        SafeTransfer._safeTransfer(_tokenAddress, msg.sender, tokenBalance),
        "withdraw transfer failed"
      );
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, tokenBalance);
    return true;
  }

  /**
   * @dev Understand if the user swap request is a BUY or a SELL.
   * @param _offerTokenAddress The token address the purchaser is offering (It may be the quote or the base).
   * @return bool.
   */

  function isBuy(address _offerTokenAddress)
    public
    view
    returns (bool)
  {
    return _offerTokenAddress == quoteTokenAddress;
  }

  /**
   * @dev Understand if the token is ETH or not.
   * @param _tokenAddress The token address the purchaser is offering (It may be the quote or the base).
   * @return bool.
   */

  function isETH(address _tokenAddress)
    public
    pure
    returns (bool)
  {
    return _tokenAddress == address(0);
  }

  /**
   * @dev Understand if the user swap request is for the available pair.
   * @param _offerTokenAddress The token address the purchaser is offering (It may be the quote or the base).
   * @return bool.
   */

  function isOfferInPair(address _offerTokenAddress)
    public
    view
    returns (bool)
  {
    return _offerTokenAddress == quoteTokenAddress ||
      _offerTokenAddress == baseTokenAddress;
  }

  /**
   * @dev Function to calculate the number of tokens the user is going to receive.
   * @param _offerTokenAmount The amount of tokne number of WEI to convert in ERC20.
   * @return uint.
   */
  function getAmount(
    uint _offerTokenAmount,
    bool _isBuy
  )
    public
    view
    returns(uint)
  {
    uint amount;
    if (_isBuy) {
      amount = _offerTokenAmount.mul(buyRate).div(10 ** buyRateDecimals);
    } else {
      amount = _offerTokenAmount.mul(sellRate).div(10 ** sellRateDecimals);
    }
    return amount;
  }

  /**
   * @dev Release purchased asset to the buyer based on pair rate.
   * @param _userOfferTokenAddress The token address the purchaser is offering (It may be the quote or the base).
   * @param _userOfferTokenAmount The amount of token the user want to swap.
   * @return bool.
   */
  function swapToken (
    address _userOfferTokenAddress,
    uint _userOfferTokenAmount
  )
    public
    whenNotPaused
    payable
    returns (bool)
  {
    require(_userOfferTokenAmount != 0, "_userOfferTokenAmount == 0");
    // check if offered token address is the base or the quote token address
    require(
      isOfferInPair(_userOfferTokenAddress),
      "_userOfferTokenAddress not in pair"
    );
    // check if the msg.value is consistent when offered token address is eth
    if (isETH(_userOfferTokenAddress)) {
      require(_userOfferTokenAmount == msg.value, "msg.value != _userOfferTokenAmount");
    } else {
      require(msg.value == 0, "msg.value != 0");
    }
    bool isUserBuy = isBuy(_userOfferTokenAddress);
    uint toWalletAmount = _userOfferTokenAmount;
    uint toUserAmount = getAmount(
      _userOfferTokenAmount,
      isUserBuy
    );
    require(toUserAmount > 0, "toUserAmount must be greater than 0");
    if (isUserBuy) {
      // send the quote to wallet
      require(
        _transferAmounts(
          msg.sender,
          wallet,
          quoteTokenAddress,
          toWalletAmount
        ),
        "the transfer from of the quote the user to the TokenSwap SC failed"
      );
      // send the base to user
      require(
        _transferAmounts(
          wallet,
          msg.sender,
          baseTokenAddress,
          toUserAmount
        ),
        "the transfer of the base from the TokenSwap SC to the user failed"
      );
      emit LogTokenSwap(
        msg.sender,
        quoteTokenAddress,
        toWalletAmount,
        baseTokenAddress,
        toUserAmount
      );
    } else {
      // send the base to wallet
      require(
        _transferAmounts(
          msg.sender,
          wallet,
          baseTokenAddress,
          toWalletAmount
        ),
        "the transfer of the base from the user to the TokenSwap SC failed"
      );
      // send the quote to user
      require(
        _transferAmounts(
          wallet,
          msg.sender,
          quoteTokenAddress,
          toUserAmount
        ),
        "the transfer of the quote from the TokenSwap SC to the user failed"
      );
      emit LogTokenSwap(
        msg.sender,
        baseTokenAddress,
        toWalletAmount,
        quoteTokenAddress,
        toUserAmount
      );
    }
    return true;
  }

  /**
   * @dev Transfer amounts from user to this contract and vice versa.
   * @param _from The 'from' address.
   * @param _to The 'to' address.
   * @param _tokenAddress The asset to be transfer.
   * @param _amount The amount to be transfer.
   * @return bool.
   */
  function _transferAmounts(
    address _from,
    address _to,
    address _tokenAddress,
    uint _amount
  )
    private
    returns (bool)
  {
    if (isETH(_tokenAddress)) {
      if (_from == wallet) {
        require(
          IWallet(_from).transferAssetTo(
            _tokenAddress,
            _to,
            _amount
          ),
          "trasnsferAssetTo failed"
        );
      } else {
        _to.transfer(_amount);
      }
    } else {
      if (_from == wallet) {
        require(
          IWallet(_from).transferAssetTo(
            _tokenAddress,
            _to,
            _amount
          ),
          "trasnsferAssetTo failed"
        );
      } else {
        require(
          SafeTransfer._safeTransferFrom(
            _tokenAddress,
            _from,
            _to,
            _amount
        ),
          "transferFrom reserve to _receiver failed"
        );
      }
    }
    return true;
  }
}