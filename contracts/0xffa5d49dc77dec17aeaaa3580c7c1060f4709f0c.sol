pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: contracts/interface/IBasicMultiToken.sol

contract IBasicMultiToken is ERC20 {
    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);

    function tokensCount() public view returns(uint256);
    function tokens(uint i) public view returns(ERC20);
    function bundlingEnabled() public view returns(bool);
    
    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;
    function bundle(address _beneficiary, uint256 _amount) public;

    function unbundle(address _beneficiary, uint256 _value) public;
    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;

    // Owner methods
    function disableBundling() public;
    function enableBundling() public;

    bytes4 public constant InterfaceId_IBasicMultiToken = 0xd5c368b6;
	  /**
	   * 0xd5c368b6 ===
	   *   bytes4(keccak256('tokensCount()')) ^
	   *   bytes4(keccak256('tokens(uint256)')) ^
       *   bytes4(keccak256('bundlingEnabled()')) ^
       *   bytes4(keccak256('bundleFirstTokens(address,uint256,uint256[])')) ^
       *   bytes4(keccak256('bundle(address,uint256)')) ^
       *   bytes4(keccak256('unbundle(address,uint256)')) ^
       *   bytes4(keccak256('unbundleSome(address,uint256,address[])')) ^
       *   bytes4(keccak256('disableBundling()')) ^
       *   bytes4(keccak256('enableBundling()'))
	   */
}

// File: contracts/interface/IMultiToken.sol

contract IMultiToken is IBasicMultiToken {
    event Update();
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);

    function weights(address _token) public view returns(uint256);
    function changesEnabled() public view returns(bool);
    
    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);
    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);

    // Owner methods
    function disableChanges() public;

    bytes4 public constant InterfaceId_IMultiToken = 0x81624e24;
	  /**
	   * 0x81624e24 ===
       *   InterfaceId_IBasicMultiToken(0xd5c368b6) ^
	   *   bytes4(keccak256('weights(address)')) ^
       *   bytes4(keccak256('changesEnabled()')) ^
       *   bytes4(keccak256('getReturn(address,address,uint256)')) ^
	   *   bytes4(keccak256('change(address,address,uint256,uint256)')) ^
       *   bytes4(keccak256('disableChanges()'))
	   */
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/ext/CheckedERC20.sol

library CheckedERC20 {
    using SafeMath for uint;

    function isContract(address addr) internal view returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch eq(returndatasize(), 32) // not a std erc20
            case 1 {
                returndatacopy(0, 0, 32)
                result := mload(0)
            }

            switch gt(returndatasize(), 32) // std erc20
            case 1 {
                returndatacopy(0, 64, 32)
                result := mload(0)
            }

            switch lt(returndatasize(), 32) // anything else, should revert for safety
            case 1 {
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address token, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("transfer(address,uint256)")), to, value));
        return handleReturnBool();
    }

    function asmTransferFrom(address token, address from, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, value));
        return handleReturnBool();
    }

    function asmApprove(address token, address spender, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("approve(address,uint256)")), spender, value));
        return handleReturnBool();
    }

    //

    function checkedTransfer(ERC20 token, address to, uint256 value) internal {
        if (value > 0) {
            uint256 balance = token.balanceOf(this);
            asmTransfer(token, to, value);
            require(token.balanceOf(this) == balance.sub(value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        if (value > 0) {
            uint256 toBalance = token.balanceOf(to);
            asmTransferFrom(token, from, to, value);
            require(token.balanceOf(to) == toBalance.add(value), "checkedTransfer: Final balance didn't match");
        }
    }

    //

    function asmName(address token) internal view returns(bytes32) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("name()"))));
        return handleReturnBytes32();
    }

    function asmSymbol(address token) internal view returns(bytes32) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("symbol()"))));
        return handleReturnBytes32();
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
    require(msg.sender == owner);
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
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

// File: contracts/network/MultiChanger.sol

contract IEtherToken is ERC20 {
    function deposit() public payable;
    function withdraw(uint256 amount) public;
}


contract IBancorNetwork {
    function convert(
        address[] path,
        uint256 amount,
        uint256 minReturn
    )
        public
        payable
        returns(uint256);

    function claimAndConvert(
        address[] path,
        uint256 amount,
        uint256 minReturn
    )
        public
        payable
        returns(uint256);
}


contract IKyberNetworkProxy {
    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);
}


contract MultiChanger is CanReclaimToken {
    using SafeMath for uint256;
    using CheckedERC20 for ERC20;

    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns (bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                add(d, dataOffset),
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
    }

    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length
        for (uint i = 0; i < starts.length - 1; i++) {
            require(externalCall(this, 0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    function sendEthValue(address target, bytes data, uint256 value) external {
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data));
    }

    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data));
    }

    function approveTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        // solium-disable-next-line security/no-low-level-calls
        require(target.call(data));
    }

    function approveTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        // solium-disable-next-line security/no-low-level-calls
        require(target.call(data));
    }

    function transferTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        fromToken.asmTransfer(target, amount);
        if (target != address(0)) {
            // solium-disable-next-line security/no-low-level-calls
            require(target.call(data));
        }
    }

    function transferTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        fromToken.asmTransfer(target, amount);
        if (target != address(0)) {
            // solium-disable-next-line security/no-low-level-calls
            require(target.call(data));
        }
    }

    // Multitoken

    function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {
        if (fromToken.allowance(this, mtkn) == 0) {
            fromToken.asmApprove(mtkn, uint256(-1));
        }
        mtkn.change(fromToken, toToken, amount, minReturn);
    }

    function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);
    }

    // Ether token

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    // Bancor Network

    function bancorSendEthValue(IBancorNetwork bancor, address[] path, uint256 value) external {
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorSendEthProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorApproveTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorApproveTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorTransferTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorTransferTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(bancor).mul(mul).div(div);
        bancor.convert(path, amount, 1);
    }

    // Kyber Network

    function kyberSendEthProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        kyber.trade.value(value)(
            fromToken,
            value,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenAmount(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 amount) external {
        if (fromToken.allowance(this, kyber) == 0) {
            fromToken.asmApprove(kyber, uint256(-1));
        }
        kyber.trade(
            fromToken,
            amount,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);
    }
}

// File: contracts/network/MultiBuyer.sol

contract MultiBuyer is MultiChanger {
    using CheckedERC20 for ERC20;

    function buy(
        IMultiToken mtkn,
        uint256 minimumReturn,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
        payable
    {
        change(callDatas, starts);

        uint mtknTotalSupply = mtkn.totalSupply(); // optimization totalSupply
        uint256 bestAmount = uint256(-1);
        for (uint i = mtkn.tokensCount(); i > 0; i--) {
            ERC20 token = mtkn.tokens(i - 1);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }

            uint256 amount = mtknTotalSupply.mul(token.balanceOf(this)).div(token.balanceOf(mtkn));
            if (amount < bestAmount) {
                bestAmount = amount;
            }
        }

        require(bestAmount >= minimumReturn, "buy: return value is too low");
        mtkn.bundle(msg.sender, bestAmount);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = mtkn.tokensCount(); i > 0; i--) {
            token = mtkn.tokens(i - 1);
            if (token.balanceOf(this) > 0) {
                token.asmTransfer(msg.sender, token.balanceOf(this));
            }
        }
    }

    function buyFirstTokens(
        IMultiToken mtkn,
        bytes callDatas,
        uint[] starts, // including 0 and LENGTH values
        uint ethPriceMul,
        uint ethPriceDiv
    )
        public
        payable
    {
        change(callDatas, starts);

        uint tokensCount = mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }
        }

        mtkn.bundleFirstTokens(msg.sender, msg.value.mul(ethPriceMul).div(ethPriceDiv), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = mtkn.tokensCount(); i > 0; i--) {
            token = mtkn.tokens(i - 1);
            if (token.balanceOf(this) > 0) {
                token.asmTransfer(msg.sender, token.balanceOf(this));
            }
        }
    }
}