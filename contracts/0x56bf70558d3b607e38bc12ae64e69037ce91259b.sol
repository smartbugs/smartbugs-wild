/**
 * Copyright 2017–2018, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */
 
pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;


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

contract EIP20 is ERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
}

interface NonCompliantEIP20 {
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
    function approve(address _spender, uint256 _value) external;
}

contract EIP20Wrapper {

    function eip20Transfer(
        address token,
        address to,
        uint256 value)
        internal
        returns (bool result) {

        NonCompliantEIP20(token).transfer(to, value);

        assembly {
            switch returndatasize()   
            case 0 {                        // non compliant ERC20
                result := not(0)            // result is true
            }
            case 32 {                       // compliant ERC20
                returndatacopy(0, 0, 32) 
                result := mload(0)          // result == returndata of external call
            }
            default {                       // not an not an ERC20 token
                revert(0, 0) 
            }
        }

        require(result, "eip20Transfer failed");
    }

    function eip20TransferFrom(
        address token,
        address from,
        address to,
        uint256 value)
        internal
        returns (bool result) {

        NonCompliantEIP20(token).transferFrom(from, to, value);

        assembly {
            switch returndatasize()   
            case 0 {                        // non compliant ERC20
                result := not(0)            // result is true
            }
            case 32 {                       // compliant ERC20
                returndatacopy(0, 0, 32) 
                result := mload(0)          // result == returndata of external call
            }
            default {                       // not an not an ERC20 token
                revert(0, 0) 
            }
        }

        require(result, "eip20TransferFrom failed");
    }

    function eip20Approve(
        address token,
        address spender,
        uint256 value)
        internal
        returns (bool result) {

        NonCompliantEIP20(token).approve(spender, value);

        assembly {
            switch returndatasize()   
            case 0 {                        // non compliant ERC20
                result := not(0)            // result is true
            }
            case 32 {                       // compliant ERC20
                returndatacopy(0, 0, 32) 
                result := mload(0)          // result == returndata of external call
            }
            default {                       // not an not an ERC20 token
                revert(0, 0) 
            }
        }

        require(result, "eip20Approve failed");
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
  * @dev Integer division of two numbers, rounding up and truncating the quotient
  */
  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    return ((_a - 1) / _b) + 1;
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
    require(msg.sender == owner);
    _;
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
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract BZxOwnable is Ownable {

    address public bZxContractAddress;

    event BZxOwnershipTransferred(address indexed previousBZxContract, address indexed newBZxContract);

    // modifier reverts if bZxContractAddress isn't set
    modifier onlyBZx() {
        require(msg.sender == bZxContractAddress, "only bZx contracts can call this function");
        _;
    }

    /**
    * @dev Allows the current owner to transfer the bZx contract owner to a new contract address
    * @param newBZxContractAddress The bZx contract address to transfer ownership to.
    */
    function transferBZxOwnership(address newBZxContractAddress) public onlyOwner {
        require(newBZxContractAddress != address(0) && newBZxContractAddress != owner, "transferBZxOwnership::unauthorized");
        emit BZxOwnershipTransferred(bZxContractAddress, newBZxContractAddress);
        bZxContractAddress = newBZxContractAddress;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    * This overrides transferOwnership in Ownable to prevent setting the new owner the same as the bZxContract
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0) && newOwner != bZxContractAddress, "transferOwnership::unauthorized");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ExchangeV2Interface {

    struct OrderV2 {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    /// @dev Fills the input order.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        OrderV2 memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature)
        public
        returns (FillResults memory fillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrdersNoThrow(
        OrderV2[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures)
        public
        returns (FillResults memory totalFillResults);


    /// @dev Verifies that a signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signerAddress Address that should have signed the given hash.
    /// @param signature Proof of signing.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature)
        external
        view
        returns (bool isValid);
}

contract BZxTo0xShared {
    using SafeMath for uint256;

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function _safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !_isRoundingErrorFloor(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );
        
        partialAmount = SafeMath.div(
            SafeMath.mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function _isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );
        
        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero. 
        if (target == 0 || numerator == 0) {
            return false;
        }
        
        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = SafeMath.mul(1000, remainder) >= SafeMath.mul(numerator, target);
        return isError;
    }
}

contract BZxTo0xV2 is BZxTo0xShared, EIP20Wrapper, BZxOwnable {
    using SafeMath for uint256;

    event LogFillResults(
        uint256 makerAssetFilledAmount,
        uint256 takerAssetFilledAmount,
        uint256 makerFeePaid,
        uint256 takerFeePaid
    );

    bool public DEBUG = false;

    address public exchangeV2Contract;
    address public zrxTokenContract;
    address public erc20ProxyContract;

    constructor(
        address _exchangeV2,
        address _zrxToken,
        address _proxy)
        public
    {
        exchangeV2Contract = _exchangeV2;
        zrxTokenContract = _zrxToken;
        erc20ProxyContract = _proxy;
    }

    function()
        external {
        revert();
    }

    // 0xc78429c4 == "take0xV2Trade(address,address,uint256,(address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],bytes[])"
    function take0xV2Trade(
        address trader,
        address vaultAddress,
        uint256 sourceTokenAmountToUse,
        ExchangeV2Interface.OrderV2[] memory orders0x, // Array of 0x V2 order structs
        bytes[] memory signatures0x) // Array of signatures for each of the V2 orders
        public
        onlyBZx
        returns (
            address destTokenAddress,
            uint256 destTokenAmount,
            uint256 sourceTokenUsedAmount)
    {
        address sourceTokenAddress;

        //destTokenAddress==makerToken, sourceTokenAddress==takerToken
        (destTokenAddress, sourceTokenAddress) = getV2Tokens(orders0x[0]);

        (sourceTokenUsedAmount, destTokenAmount) = _take0xV2Trade(
            trader,
            sourceTokenAddress,
            sourceTokenAmountToUse,
            orders0x,
            signatures0x);

        if (sourceTokenUsedAmount < sourceTokenAmountToUse) {
            // all sourceToken has to be traded
            revert("BZxTo0xV2::take0xTrade: sourceTokenUsedAmount < sourceTokenAmountToUse");
        }

        // transfer the destToken to the vault
        eip20Transfer(
            destTokenAddress,
            vaultAddress,
            destTokenAmount);
    }

    /// @dev Calculates partial value given a numerator and denominator.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target.
    function getPartialAmount(uint256 numerator, uint256 denominator, uint256 target)
        public
        pure
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(numerator, target), denominator);
    }

    /// @dev Extracts the maker and taker token addresses from the 0x V2 order object.
    /// @param order 0x V2 order object.
    /// @return makerTokenAddress and takerTokenAddress.
    function getV2Tokens(
        ExchangeV2Interface.OrderV2 memory order)
        public
        pure
        returns (
            address makerTokenAddress,
            address takerTokenAddress)
    {
        bytes memory makerAssetData = order.makerAssetData;
        bytes memory takerAssetData = order.takerAssetData;
        bytes4 makerProxyID;
        bytes4 takerProxyID;

        // example data: 0xf47261b00000000000000000000000001dc4c1cefef38a777b15aa20260a54e584b16c48
        assembly {
            makerProxyID := mload(add(makerAssetData, 32))
            takerProxyID := mload(add(takerAssetData, 32))

            makerTokenAddress := mload(add(makerAssetData, 36))
            takerTokenAddress := mload(add(takerAssetData, 36))
        }

        // ERC20 Proxy ID -> bytes4(keccak256("ERC20Token(address)")) = 0xf47261b0
        require(makerProxyID == 0xf47261b0 && takerProxyID == 0xf47261b0, "BZxTo0xV2::getV2Tokens: 0x V2 orders must use ERC20 tokens");
    }

    function set0xV2Exchange (
        address _exchange)
        public
        onlyOwner
    {
        exchangeV2Contract = _exchange;
    }

    function setZRXToken (
        address _zrxToken)
        public
        onlyOwner
    {
        zrxTokenContract = _zrxToken;
    }

    function set0xTokenProxy (
        address _proxy)
        public
        onlyOwner
    {
        erc20ProxyContract = _proxy;
    }

    function approveFor (
        address token,
        address spender,
        uint256 value)
        public
        onlyOwner
        returns (bool)
    {
        eip20Approve(
            token,
            spender,
            value);

        return true;
    }

    function toggleDebug (
        bool isDebug)
        public
        onlyOwner
    {
        DEBUG = isDebug;
    }

    function _take0xV2Trade(
        address trader,
        address sourceTokenAddress,
        uint256 sourceTokenAmountToUse,
        ExchangeV2Interface.OrderV2[] memory orders0x, // Array of 0x V2 order structs
        bytes[] memory signatures0x)
        internal
        returns (uint256 sourceTokenUsedAmount, uint256 destTokenAmount)
    {
        uint256 zrxTokenAmount = 0;
        uint256 takerAssetRemaining = sourceTokenAmountToUse;
        for (uint256 i = 0; i < orders0x.length; i++) {
            // Note: takerAssetData (sourceToken) is confirmed to be the same in 0x for batch orders
            // To confirm makerAssetData is the same for each order, rather than doing a more expensive per order bytes
            // comparison, we will simply set makerAssetData the same in each order to the first value observed. The 0x
            // trade will fail for invalid orders.
            if (i > 0)
                orders0x[i].makerAssetData = orders0x[0].makerAssetData;

            // calculate required takerFee
            if (takerAssetRemaining > 0 && orders0x[i].takerFee > 0) { // takerFee
                if (takerAssetRemaining >= orders0x[i].takerAssetAmount) {
                    zrxTokenAmount = zrxTokenAmount.add(orders0x[i].takerFee);
                    takerAssetRemaining = takerAssetRemaining.sub(orders0x[i].takerAssetAmount);
                } else {
                    zrxTokenAmount = zrxTokenAmount.add(_safeGetPartialAmountFloor(
                        takerAssetRemaining,
                        orders0x[i].takerAssetAmount,
                        orders0x[i].takerFee
                    ));
                    takerAssetRemaining = 0;
                }
            }
        }

        if (zrxTokenAmount > 0) {
            // The 0x erc20ProxyContract already has unlimited transfer allowance for ZRX from this contract (set during deployment of this contract)
            eip20TransferFrom(
                zrxTokenContract,
                trader,
                address(this),
                zrxTokenAmount);
        }

        // Make sure there is enough allowance for 0x Exchange Proxy to transfer the sourceToken needed for the 0x trade
        uint256 tempAllowance = EIP20(sourceTokenAddress).allowance(address(this), erc20ProxyContract);
        if (tempAllowance < sourceTokenAmountToUse) {
            if (tempAllowance > 0) {
                // reset approval to 0
                eip20Approve(
                    sourceTokenAddress,
                    erc20ProxyContract,
                    0);
            }

            eip20Approve(
                sourceTokenAddress,
                erc20ProxyContract,
                sourceTokenAmountToUse);
        }

        ExchangeV2Interface.FillResults memory fillResults;
        if (orders0x.length > 1) {
            fillResults = ExchangeV2Interface(exchangeV2Contract).marketSellOrdersNoThrow(
                orders0x,
                sourceTokenAmountToUse,
                signatures0x);
        } else {
            fillResults = ExchangeV2Interface(exchangeV2Contract).fillOrderNoThrow(
                orders0x[0],
                sourceTokenAmountToUse,
                signatures0x[0]);
        }

        if (zrxTokenAmount > 0 && fillResults.takerFeePaid < zrxTokenAmount) {
            // refund unused ZRX token (if any)
            eip20Transfer(
                zrxTokenContract,
                trader,
                zrxTokenAmount.sub(fillResults.takerFeePaid));
        }

        if (DEBUG) {
            emit LogFillResults(
                fillResults.makerAssetFilledAmount,
                fillResults.takerAssetFilledAmount,
                fillResults.makerFeePaid,
                fillResults.takerFeePaid
            );
        }

        sourceTokenUsedAmount = fillResults.takerAssetFilledAmount;
        destTokenAmount = fillResults.makerAssetFilledAmount;
    }
}