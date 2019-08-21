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

// File: contracts/ext/ExternalCall.sol

library ExternalCall {
    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns(bool result) {
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
}

// File: contracts/network/MultiChanger.sol

contract IEtherToken is ERC20 {
    function deposit() public payable;
    function withdraw(uint256 amount) public;
}


contract MultiChanger {
    using SafeMath for uint256;
    using CheckedERC20 for ERC20;
    using ExternalCall for address;

    function() public payable {
        require(tx.origin != msg.sender);
    }

    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length
        for (uint i = 0; i < starts.length - 1; i++) {
            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    // Ether

    function sendEthValue(address target, uint256 value) external {
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)());
    }

    function sendEthProportion(address target, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)());
    }

    // Ether token

    function depositEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.deposit.value(amount)();
    }

    function depositEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = address(this).balance.mul(mul).div(div);
        etherToken.deposit.value(amount)();
    }

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    // Token

    function transferTokenAmount(address target, ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransfer(target, amount));
    }

    function transferTokenProportion(address target, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransfer(target, amount));
    }

    function transferFromTokenAmount(ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransferFrom(tx.origin, this, amount));
    }

    function transferFromTokenProportion(ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransferFrom(tx.origin, this, amount));
    }

    // MultiToken

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
}