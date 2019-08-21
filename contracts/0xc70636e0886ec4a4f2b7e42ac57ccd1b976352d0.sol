pragma solidity 0.4.18;

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function toPower2(uint256 a) internal pure returns (uint256) {
        return mul(a, a);
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
}

/// @title ERC223Receiver Interface
/// @dev Based on the specs form: https://github.com/ethereum/EIPs/issues/223
contract ERC223Receiver {
    function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
}



/// @title Market Maker Interface.
/// @author Tal Beja.
contract MarketMaker is ERC223Receiver {

  function getCurrentPrice() public constant returns (uint _price);
  function change(address _fromToken, uint _amount, address _toToken) public returns (uint _returnAmount);
  function change(address _fromToken, uint _amount, address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function change(address _toToken) public returns (uint _returnAmount);
  function change(address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function quote(address _fromToken, uint _amount, address _toToken) public constant returns (uint _returnAmount);
  function openForPublicTrade() public returns (bool success);
  function isOpenForPublic() public returns (bool success);

  event Change(address indexed fromToken, uint inAmount, address indexed toToken, uint returnAmount, address indexed account);
}





/// @title Ellipse Market Maker Interfase
/// @author Tal Beja
contract IEllipseMarketMaker is MarketMaker {

    // precision for price representation (as in ether or tokens).
    uint256 public constant PRECISION = 10 ** 18;

    // The tokens pair.
    ERC20 public token1;
    ERC20 public token2;

    // The tokens reserves.
    uint256 public R1;
    uint256 public R2;

    // The tokens full suplly.
    uint256 public S1;
    uint256 public S2;

    // State flags.
    bool public operational;
    bool public openForPublic;

    // Library contract address.
    address public mmLib;

    function supportsToken(address token) public constant returns (bool);

    function calcReserve(uint256 _R1, uint256 _S1, uint256 _S2) public pure returns (uint256);

    function validateReserves() public view returns (bool);

    function withdrawExcessReserves() public returns (uint256);

    function initializeAfterTransfer() public returns (bool);

    function initializeOnTransfer() public returns (bool);

    function getPrice(uint256 _R1, uint256 _R2, uint256 _S1, uint256 _S2) public constant returns (uint256);
}


/// @title ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/issues/20)
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _owner) constant public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions,
/// this simplifies the implementation of "user permissions".
/// @dev Based on OpenZeppelin's Ownable.

contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev Constructor sets the original `owner` of the contract to the sender account.
    function Ownable() public {
        owner = msg.sender;
    }

    /// @dev Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));

        newOwnerCandidate = _newOwnerCandidate;

        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }
}



 /// @title Standard ERC223 Token Receiver implementing tokenFallback function and tokenPayable modifier

contract Standard223Receiver is ERC223Receiver {
  Tkn tkn;

  struct Tkn {
    address addr;
    address sender; // the transaction caller
    uint256 value;
  }

  bool __isTokenFallback;

  modifier tokenPayable {
    require(__isTokenFallback);
    _;
  }

  /// @dev Called when the receiver of transfer is contract
  /// @param _sender address the address of tokens sender
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok) {
    if (!supportsToken(msg.sender)) {
      return false;
    }

    // Problem: This will do a sstore which is expensive gas wise. Find a way to keep it in memory.
    // Solution: Remove the the data
    tkn = Tkn(msg.sender, _sender, _value);
    __isTokenFallback = true;
    if (!address(this).delegatecall(_data)) {
      __isTokenFallback = false;
      return false;
    }
    // avoid doing an overwrite to .token, which would be more expensive
    // makes accessing .tkn values outside tokenPayable functions unsafe
    __isTokenFallback = false;

    return true;
  }

  function supportsToken(address token) public constant returns (bool);
}





/// @title TokenOwnable
/// @dev The TokenOwnable contract adds a onlyTokenOwner modifier as a tokenReceiver with ownable addaptation

contract TokenOwnable is Standard223Receiver, Ownable {
    /// @dev Reverts if called by any account other than the owner for token sending.
    modifier onlyTokenOwner() {
        require(tkn.sender == owner);
        _;
    }
}






/// @title Ellipse Market Maker Library.
/// @dev market maker, using ellipse equation.
/// @dev for more information read the appendix of the CLN white paper: https://cln.network/pdf/cln_whitepaper.pdf
/// @author Tal Beja.
contract EllipseMarketMakerLib is TokenOwnable, IEllipseMarketMaker {
  using SafeMath for uint256;

  // temp reserves
  uint256 private l_R1;
  uint256 private l_R2;

  modifier notConstructed() {
    require(mmLib == address(0));
    _;
  }

  /// @dev Reverts if not operational
  modifier isOperational() {
    require(operational);
    _;
  }

  /// @dev Reverts if operational
  modifier notOperational() {
    require(!operational);
    _;
  }

  /// @dev Reverts if msg.sender can't trade
  modifier canTrade() {
    require(openForPublic || msg.sender == owner);
    _;
  }

  /// @dev Reverts if tkn.sender can't trade
  modifier canTrade223() {
    require (openForPublic || tkn.sender == owner);
    _;
  }

  /// @dev The Market Maker constructor
  /// @param _mmLib address address of the market making lib contract
  /// @param _token1 address contract of the first token for marker making (CLN)
  /// @param _token2 address contract of the second token for marker making (CC)
  function constructor(address _mmLib, address _token1, address _token2) public onlyOwner notConstructed returns (bool) {
    require(_mmLib != address(0));
    require(_token1 != address(0));
    require(_token2 != address(0));
    require(_token1 != _token2);

    mmLib = _mmLib;
    token1 = ERC20(_token1);
    token2 = ERC20(_token2);
    R1 = 0;
    R2 = 0;
    S1 = token1.totalSupply();
    S2 = token2.totalSupply();

    operational = false;
    openForPublic = false;

    return true;
  }

  /// @dev open the Market Maker for public trade.
  function openForPublicTrade() public onlyOwner isOperational returns (bool) {
    openForPublic = true;
    return true;
  }

  /// @dev returns true iff the contract is open for public trade.
  function isOpenForPublic() public onlyOwner returns (bool) {
    return (openForPublic && operational);
  }

  /// @dev returns true iff token is supperted by this contract (for erc223/677 tokens calls)
  /// @param _token address adress of the contract to check
  function supportsToken(address _token) public constant returns (bool) {
      return (token1 == _token || token2 == _token);
  }

  /// @dev initialize the contract after transfering all of the tokens form the pair
  function initializeAfterTransfer() public notOperational onlyOwner returns (bool) {
    require(initialize());
    return true;
  }

  /// @dev initialize the contract during erc223/erc677 transfer of all of the tokens form the pair
  function initializeOnTransfer() public notOperational onlyTokenOwner tokenPayable returns (bool) {
    require(initialize());
    return true;
  }

  /// @dev initialize the contract.
  function initialize() private returns (bool success) {
    R1 = token1.balanceOf(this);
    R2 = token2.balanceOf(this);
    // one reserve should be full and the second should be empty
    success = ((R1 == 0 && R2 == S2) || (R2 == 0 && R1 == S1));
    if (success) {
      operational = true;
    }
  }

  /// @dev the price of token1 in terms of token2, represented in 18 decimals.
  function getCurrentPrice() public constant isOperational returns (uint256) {
    return getPrice(R1, R2, S1, S2);
  }

  /// @dev the price of token1 in terms of token2, represented in 18 decimals.
  /// price = (S1 - R1) / (S2 - R2) * (S2 / S1)^2
  /// @param _R1 uint256 reserve of the first token
  /// @param _R2 uint256 reserve of the second token
  /// @param _S1 uint256 total supply of the first token
  /// @param _S2 uint256 total supply of the second token
  function getPrice(uint256 _R1, uint256 _R2, uint256 _S1, uint256 _S2) public constant returns (uint256 price) {
    price = PRECISION;
    price = price.mul(_S1.sub(_R1));
    price = price.div(_S2.sub(_R2));
    price = price.mul(_S2);
    price = price.div(_S1);
    price = price.mul(_S2);
    price = price.div(_S1);
  }

  /// @dev get a quote for exchanging and update temporary reserves.
  /// @param _fromToken the token to sell from
  /// @param _inAmount the amount to sell
  /// @param _toToken the token to buy
  /// @return the return amount of the buying token
  function quoteAndReserves(address _fromToken, uint256 _inAmount, address _toToken) private isOperational returns (uint256 returnAmount) {
    // if buying token2 from token1
    if (token1 == _fromToken && token2 == _toToken) {
      // add buying amount to the temp reserve
      l_R1 = R1.add(_inAmount);
      // calculate the other reserve
      l_R2 = calcReserve(l_R1, S1, S2);
      if (l_R2 > R2) {
        return 0;
      }
      // the returnAmount is the other reserve difference
      returnAmount = R2.sub(l_R2);
    }
    // if buying token1 from token2
    else if (token2 == _fromToken && token1 == _toToken) {
      // add buying amount to the temp reserve
      l_R2 = R2.add(_inAmount);
      // calculate the other reserve
      l_R1 = calcReserve(l_R2, S2, S1);
      if (l_R1 > R1) {
        return 0;
      }
      // the returnAmount is the other reserve difference
      returnAmount = R1.sub(l_R1);
    } else {
      return 0;
    }
  }

  /// @dev get a quote for exchanging.
  /// @param _fromToken the token to sell from
  /// @param _inAmount the amount to sell
  /// @param _toToken the token to buy
  /// @return the return amount of the buying token
  function quote(address _fromToken, uint256 _inAmount, address _toToken) public constant isOperational returns (uint256 returnAmount) {
    uint256 _R1;
    uint256 _R2;
    // if buying token2 from token1
    if (token1 == _fromToken && token2 == _toToken) {
      // add buying amount to the temp reserve
      _R1 = R1.add(_inAmount);
      // calculate the other reserve
      _R2 = calcReserve(_R1, S1, S2);
      if (_R2 > R2) {
        return 0;
      }
      // the returnAmount is the other reserve difference
      returnAmount = R2.sub(_R2);
    }
    // if buying token1 from token2
    else if (token2 == _fromToken && token1 == _toToken) {
      // add buying amount to the temp reserve
      _R2 = R2.add(_inAmount);
      // calculate the other reserve
      _R1 = calcReserve(_R2, S2, S1);
      if (_R1 > R1) {
        return 0;
      }
      // the returnAmount is the other reserve difference
      returnAmount = R1.sub(_R1);
    } else {
      return 0;
    }
  }

  /// @dev calculate second reserve from the first reserve and the supllies.
  /// @dev formula: R2 = S2 * (S1 - sqrt(R1 * S1 * 2  - R1 ^ 2)) / S1
  /// @dev the equation is simetric, so by replacing _S1 and _S2 and _R1 with _R2 we can calculate the first reserve from the second reserve
  /// @param _R1 the first reserve
  /// @param _S1 the first total supply
  /// @param _S2 the second total supply
  /// @return _R2 the second reserve
  function calcReserve(uint256 _R1, uint256 _S1, uint256 _S2) public pure returns (uint256 _R2) {
    _R2 = _S2
      .mul(
        _S1
        .sub(
          _R1
          .mul(_S1)
          .mul(2)
          .sub(
            _R1
            .toPower2()
          )
          .sqrt()
        )
      )
      .div(_S1);
  }

  /// @dev change tokens.
  /// @param _fromToken the token to sell from
  /// @param _inAmount the amount to sell
  /// @param _toToken the token to buy
  /// @return the return amount of the buying token
  function change(address _fromToken, uint256 _inAmount, address _toToken) public canTrade returns (uint256 returnAmount) {
    return change(_fromToken, _inAmount, _toToken, 0);
  }

  /// @dev change tokens.
  /// @param _fromToken the token to sell from
  /// @param _inAmount the amount to sell
  /// @param _toToken the token to buy
  /// @param _minReturn the munimum token to buy
  /// @return the return amount of the buying token
  function change(address _fromToken, uint256 _inAmount, address _toToken, uint256 _minReturn) public canTrade returns (uint256 returnAmount) {
    // pull transfer the selling token
    require(ERC20(_fromToken).transferFrom(msg.sender, this, _inAmount));
    // exchange the token
    returnAmount = exchange(_fromToken, _inAmount, _toToken, _minReturn);
    if (returnAmount == 0) {
      // if no return value revert
      revert();
    }
    // transfer the buying token
    ERC20(_toToken).transfer(msg.sender, returnAmount);
    // validate the reserves
    require(validateReserves());
    Change(_fromToken, _inAmount, _toToken, returnAmount, msg.sender);
  }

  /// @dev change tokens using erc223\erc677 transfer.
  /// @param _toToken the token to buy
  /// @return the return amount of the buying token
  function change(address _toToken) public canTrade223 tokenPayable returns (uint256 returnAmount) {
    return change(_toToken, 0);
  }

  /// @dev change tokens using erc223\erc677 transfer.
  /// @param _toToken the token to buy
  /// @param _minReturn the munimum token to buy
  /// @return the return amount of the buying token
  function change(address _toToken, uint256 _minReturn) public canTrade223 tokenPayable returns (uint256 returnAmount) {
    // get from token and in amount from the tkn object
    address fromToken = tkn.addr;
    uint256 inAmount = tkn.value;
    // exchange the token
    returnAmount = exchange(fromToken, inAmount, _toToken, _minReturn);
    if (returnAmount == 0) {
      // if no return value revert
      revert();
    }
    // transfer the buying token
    ERC20(_toToken).transfer(tkn.sender, returnAmount);
    // validate the reserves
    require(validateReserves());
    Change(fromToken, inAmount, _toToken, returnAmount, tkn.sender);
  }

  /// @dev exchange tokens.
  /// @param _fromToken the token to sell from
  /// @param _inAmount the amount to sell
  /// @param _toToken the token to buy
  /// @param _minReturn the munimum token to buy
  /// @return the return amount of the buying token
  function exchange(address _fromToken, uint256 _inAmount, address _toToken, uint256 _minReturn) private returns (uint256 returnAmount) {
    // get quote and update temp reserves
    returnAmount = quoteAndReserves(_fromToken, _inAmount, _toToken);
    // if the return amount is lower than minimum return, don't buy
    if (returnAmount == 0 || returnAmount < _minReturn) {
      return 0;
    }

    // update reserves from temp values
    updateReserve();
  }

  /// @dev update token reserves from temp values
  function updateReserve() private {
    R1 = l_R1;
    R2 = l_R2;
  }

  /// @dev validate that the tokens balances don't goes below reserves
  function validateReserves() public view returns (bool) {
    return (token1.balanceOf(this) >= R1 && token2.balanceOf(this) >= R2);
  }

  /// @dev allow admin to withraw excess tokens accumulated due to precision
  function withdrawExcessReserves() public onlyOwner returns (uint256 returnAmount) {
    // if there is excess of token 1, transfer it to the owner
    if (token1.balanceOf(this) > R1) {
      returnAmount = returnAmount.add(token1.balanceOf(this).sub(R1));
      token1.transfer(msg.sender, token1.balanceOf(this).sub(R1));
    }
    // if there is excess of token 2, transfer it to the owner
    if (token2.balanceOf(this) > R2) {
      returnAmount = returnAmount.add(token2.balanceOf(this).sub(R2));
      token2.transfer(msg.sender, token2.balanceOf(this).sub(R2));
    }
  }
}