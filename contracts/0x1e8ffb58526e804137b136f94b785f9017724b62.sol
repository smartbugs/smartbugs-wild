pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
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
    function tokens(uint256 _index) public view returns(ERC20);
    function allTokens() public view returns(ERC20[]);
    function allDecimals() public view returns(uint8[]);
    function allBalances() public view returns(uint256[]);
    function allTokensDecimalsBalances() public view returns(ERC20[], uint8[], uint256[]);

    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;
    function bundle(address _beneficiary, uint256 _amount) public;

    function unbundle(address _beneficiary, uint256 _value) public;
    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;

    function denyBundling() public;
    function allowBundling() public;
}

// File: contracts/interface/IMultiToken.sol

contract IMultiToken is IBasicMultiToken {
    event Update();
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);
    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);

    function allWeights() public view returns(uint256[] _weights);
    function allTokensDecimalsBalancesWeights() public view returns(ERC20[] _tokens, uint8[] _decimals, uint256[] _balances, uint256[] _weights);

    function denyChanges() public;
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
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
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
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
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

// File: contracts/registry/MultiChanger.sol

contract IBancorNetwork {
    function convert(
        address[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) 
        public
        payable
        returns(uint256);

    function claimAndConvert(
        address[] _path,
        uint256 _amount,
        uint256 _minReturn
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

    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns (bool result) {
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

    function change(
        bytes _callDatas,
        uint[] _starts // including 0 and LENGTH values
    )
        internal
    {
        for (uint i = 0; i < _starts.length - 1; i++) {
            require(externalCall(this, 0, _callDatas, _starts[i], _starts[i + 1] - _starts[i]));
        }
    }

    function sendEthValue(address _target, bytes _data, uint256 _value) external {
        require(_target.call.value(_value)(_data));
    }

    function sendEthProportion(address _target, bytes _data, uint256 _mul, uint256 _div) external {
        uint256 value = address(this).balance.mul(_mul).div(_div);
        require(_target.call.value(value)(_data));
    }

    function approveTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {
        if (_fromToken.allowance(this, _target) != 0) {
            _fromToken.approve(_target, 0);
        }
        _fromToken.approve(_target, _amount);
        require(_target.call(_data));
    }

    function approveTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {
        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
        if (_fromToken.allowance(this, _target) != 0) {
            _fromToken.approve(_target, 0);
        }
        _fromToken.approve(_target, amount);
        require(_target.call(_data));
    }

    function transferTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {
        _fromToken.transfer(_target, _amount);
        require(_target.call(_data));
    }

    function transferTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {
        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
        _fromToken.transfer(_target, amount);
        require(_target.call(_data));
    }

    // Bancor Network

    function bancorSendEthValue(IBancorNetwork _bancor, address[] _path, uint256 _value) external {
        _bancor.convert.value(_value)(_path, _value, 1);
    }

    function bancorSendEthProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
        uint256 value = address(this).balance.mul(_mul).div(_div);
        _bancor.convert.value(value)(_path, value, 1);
    }

    function bancorApproveTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
        if (ERC20(_path[0]).allowance(this, _bancor) == 0) {
            ERC20(_path[0]).approve(_bancor, uint256(-1));
        }
        _bancor.claimAndConvert(_path, _amount, 1);
    }

    function bancorApproveTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
        uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);
        if (ERC20(_path[0]).allowance(this, _bancor) == 0) {
            ERC20(_path[0]).approve(_bancor, uint256(-1));
        }
        _bancor.claimAndConvert(_path, amount, 1);
    }

    function bancorTransferTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
        ERC20(_path[0]).transfer(_bancor, _amount);
        _bancor.convert(_path, _amount, 1);
    }

    function bancorTransferTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
        uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);
        ERC20(_path[0]).transfer(_bancor, amount);
        _bancor.convert(_path, amount, 1);
    }

    function bancorAlreadyTransferedTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
        _bancor.convert(_path, _amount, 1);
    }

    function bancorAlreadyTransferedTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
        uint256 amount = ERC20(_path[0]).balanceOf(_bancor).mul(_mul).div(_div);
        _bancor.convert(_path, amount, 1);
    }

    // Kyber Network

    function kyberSendEthProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {
        uint256 value = address(this).balance.mul(_mul).div(_div);
        _kyber.trade.value(value)(
            _fromToken,
            value,
            _toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenAmount(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _amount) external {
        if (_fromToken.allowance(this, _kyber) == 0) {
            _fromToken.approve(_kyber, uint256(-1));
        }
        _kyber.trade(
            _fromToken,
            _amount,
            _toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {
        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
        this.kyberApproveTokenAmount(_kyber, _fromToken, _toToken, amount);
    }
}

// File: contracts/registry/MultiBuyer.sol

contract MultiBuyer is MultiChanger {
    function buy(
        IMultiToken _mtkn,
        uint256 _minimumReturn,
        bytes _callDatas,
        uint[] _starts // including 0 and LENGTH values
    )
        public
        payable
    {
        change(_callDatas, _starts);

        uint mtknTotalSupply = _mtkn.totalSupply(); // optimization totalSupply
        uint256 bestAmount = uint256(-1);
        for (uint i = _mtkn.tokensCount(); i > 0; i--) {
            ERC20 token = _mtkn.tokens(i - 1);
            if (token.allowance(this, _mtkn) == 0) {
                token.approve(_mtkn, uint256(-1));
            }

            uint256 amount = mtknTotalSupply.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
            if (amount < bestAmount) {
                bestAmount = amount;
            }
        }

        require(bestAmount >= _minimumReturn, "buy: return value is too low");
        _mtkn.bundle(msg.sender, bestAmount);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = _mtkn.tokensCount(); i > 0; i--) {
            token = _mtkn.tokens(i - 1);
            token.transfer(msg.sender, token.balanceOf(this));
        }
    }

    function buyFirstTokens(
        IMultiToken _mtkn,
        bytes _callDatas,
        uint[] _starts // including 0 and LENGTH values
    )
        public
        payable
    {
        change(_callDatas, _starts);

        uint tokensCount = _mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = _mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, _mtkn) == 0) {
                token.approve(_mtkn, uint256(-1));
            }
        }

        _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = _mtkn.tokensCount(); i > 0; i--) {
            token = _mtkn.tokens(i - 1);
            token.transfer(msg.sender, token.balanceOf(this));
        }
    }
}