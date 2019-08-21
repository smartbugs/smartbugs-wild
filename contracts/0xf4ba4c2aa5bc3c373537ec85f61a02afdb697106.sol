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

// File: contracts/Wallet.sol

pragma solidity ^0.4.24;






/**
 * @title Wallet.
 * The wallet that will manage the TokenSwap contract liquidity.
 */
contract Wallet is IWallet, Destructible {
  using SafeMath for uint;

  mapping (address => bool) public isTokenSwapAllowed;

  event LogTransferAssetTo(
    address indexed _assetAddress,
    address indexed _to,
    uint _amount
  );
  event LogWithdrawAsset(
    address indexed _assetAddress,
    address indexed _from,
    uint _amount
  );
  event LogSetTokenSwapAllowance(
    address indexed _tokenSwapAddress,
    bool _allowance
  );

  constructor(address[] memory _tokenSwapContractsAddress) public {
    for (uint i = 0; i < _tokenSwapContractsAddress.length; i++) {
      isTokenSwapAllowed[_tokenSwapContractsAddress[i]] = true;
    }
  }

  /**
   * @dev Throws if called by any TokenSwap not allowed.
   */
  modifier onlyTokenSwapAllowed() {
    require(
      isTokenSwapAllowed[msg.sender],
      "msg.sender is not one of the allowed TokenSwap smart contract"
    );
    _;
  }

  /**
   * @dev Fallback function.
   * So the contract is able to receive ETH.
   */
  function() external payable {}

  /**
   * @dev Transfer an asset from this wallet to a receiver.
   * This function can be call only from allowed TokenSwap smart contracts.
   * @param _assetAddress The asset address.
   * @param _to The asset receiver.
   * @param _amount The amount to be received.
   */
  function transferAssetTo(
    address _assetAddress,
    address _to,
    uint _amount
  )
    external
    payable
    onlyTokenSwapAllowed
    returns (bool)
  {
    require(_to != address(0), "_to == 0");
    if (isETH(_assetAddress)) {
      require(address(this).balance >= _amount, "ETH balance not sufficient");
      _to.transfer(_amount);
    } else {
      require(
        IBadERC20(_assetAddress).balanceOf(address(this)) >= _amount,
        "Token balance not sufficient"
      );
      require(
        SafeTransfer._safeTransfer(
          _assetAddress,
          _to,
          _amount
        ),
        "Token transfer failed"
      );
    }
    emit LogTransferAssetTo(_assetAddress, _to, _amount);
    return true;
  }

  /**
   * @dev Asset withdraw.
   * This function can be call only from the owner of the Wallet smart contract.
   * @param _assetAddress The asset address.
   * @param _amount The amount to be received.
   */
  function withdrawAsset(
    address _assetAddress,
    uint _amount
  )
    external
    onlyOwner
    returns(bool)
  {
    if (isETH(_assetAddress)) {
      require(
        address(this).balance >= _amount,
        "ETH balance not sufficient"
      );
      msg.sender.transfer(_amount);
    } else {
      require(
        IBadERC20(_assetAddress).balanceOf(address(this)) >= _amount,
        "Token balance not sufficient"
      );
      require(
        SafeTransfer._safeTransfer(
          _assetAddress,
          msg.sender,
          _amount
        ),
        "Token transfer failed"
      );
    }
    emit LogWithdrawAsset(_assetAddress, msg.sender, _amount);
    return true;
  }

  /**
   * @dev Add or remove Token Swap allowance.
   * @param _tokenSwapAddress The token swap sc address.
   * @param _allowance The allowance TRUE or FALSE.
   */
  function setTokenSwapAllowance (
    address _tokenSwapAddress,
    bool _allowance
  ) external onlyOwner returns(bool) {
    emit LogSetTokenSwapAllowance(
      _tokenSwapAddress,
      _allowance
    );
    isTokenSwapAllowed[_tokenSwapAddress] = _allowance;
    return true;
  }

  /**
   * @dev Understand if the token is ETH or not.
   * @param _tokenAddress The token address to be checked.
   */
  function isETH(address _tokenAddress)
    public
    pure
    returns (bool)
  {
    return _tokenAddress == 0;
  }
}