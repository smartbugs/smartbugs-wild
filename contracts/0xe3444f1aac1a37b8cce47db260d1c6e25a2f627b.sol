pragma solidity 0.4.18;

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




/// @title Basic ERC20 token contract implementation.
/// @dev Based on OpenZeppelin's StandardToken.
contract BasicToken is ERC20 {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /// @dev Function to check the amount of tokens that an owner allowed to a spender.
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    /// @dev Gets the balance of the specified address.
    /// @param _owner address The address to query the the balance of.
    /// @return uint256 representing the amount owned by the passed address.
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Transfer token to a specified address.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Transfer tokens from one address to another.
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        var _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}




/// @title ERC Token Standard #677 Interface (https://github.com/ethereum/EIPs/issues/677)
contract ERC677 is ERC20 {
    function transferAndCall(address to, uint value, bytes data) public returns (bool ok);

    event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}

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





/// @title Standard677Token implentation, base on https://github.com/ethereum/EIPs/issues/677

contract Standard677Token is ERC677, BasicToken {

  /// @dev ERC223 safe token transfer from one address to another
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(super.transfer(_to, _value)); // do a normal token transfer
    TransferAndCall(msg.sender, _to, _value, _data);
    //filtering if the target is a contract with bytecode inside it
    if (isContract(_to)) return contractFallback(_to, _value, _data);
    return true;
  }

  /// @dev called when transaction target is a contract
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
    ERC223Receiver receiver = ERC223Receiver(_to);
    require(receiver.tokenFallback(msg.sender, _value, _data));
    return true;
  }

  /// @dev check if the address is contract
  /// assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  /// @param _addr address the address to check
  function isContract(address _addr) private constant returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
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




/// @title Token holder contract.
contract TokenHolder is Ownable {
    /// @dev Allow the owner to transfer out any accidentally sent ERC20 tokens.
    /// @param _tokenAddress address The address of the ERC20 contract.
    /// @param _amount uint256 The amount of tokens to be transferred.
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}






/// @title Colu Local Currency contract.
/// @author Rotem Lev.
contract ColuLocalCurrency is Ownable, Standard677Token, TokenHolder {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
   
    /// @dev cotract to use when issuing a CC (Local Currency)
    /// @param _name string name for CC token that is created.
    /// @param _symbol string symbol for CC token that is created.
    /// @param _decimals uint8 percison for CC token that is created.
    /// @param _totalSupply uint256 total supply of the CC token that is created. 
    function ColuLocalCurrency(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        require(_totalSupply != 0);     
        require(bytes(_name).length != 0);
        require(bytes(_symbol).length != 0);

        totalSupply = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = totalSupply;
    }
}

/// @title ERC223Receiver Interface
/// @dev Based on the specs form: https://github.com/ethereum/EIPs/issues/223
contract ERC223Receiver {
    function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
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





/// @title Ellipse Market Maker contract.
/// @dev market maker, using ellipse equation.
/// @author Tal Beja.
contract EllipseMarketMaker is TokenOwnable {

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

  /// @dev Constructor calling the library contract using delegate.
  function EllipseMarketMaker(address _mmLib, address _token1, address _token2) public {
    require(_mmLib != address(0));
    // Signature of the mmLib's constructor function
    // bytes4 sig = bytes4(keccak256("constructor(address,address,address)"));
    bytes4 sig = 0x6dd23b5b;

    // 3 arguments of size 32
    uint256 argsSize = 3 * 32;
    // sig + arguments size
    uint256 dataSize = 4 + argsSize;


    bytes memory m_data = new bytes(dataSize);

    assembly {
        // Add the signature first to memory
        mstore(add(m_data, 0x20), sig)
        // Add the parameters
        mstore(add(m_data, 0x24), _mmLib)
        mstore(add(m_data, 0x44), _token1)
        mstore(add(m_data, 0x64), _token2)
    }

    // delegatecall to the library contract
    require(_mmLib.delegatecall(m_data));
  }

  /// @dev returns true iff token is supperted by this contract (for erc223/677 tokens calls)
  /// @param token can be token1 or token2
  function supportsToken(address token) public constant returns (bool) {
    return (token1 == token || token2 == token);
  }

  /// @dev gets called when no other function matches, delegate to the lib contract.
  function() public {
    address _mmLib = mmLib;
    if (msg.data.length > 0) {
      assembly {
        calldatacopy(0xff, 0, calldatasize)
        let retVal := delegatecall(gas, _mmLib, 0xff, calldatasize, 0, 0x20)
        switch retVal case 0 { revert(0,0) } default { return(0, 0x20) }
      }
    }
  }
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









/// @title Colu Local Currency + Market Maker factory contract.
/// @author Rotem Lev.
contract CurrencyFactory is Standard223Receiver, TokenHolder {

  struct CurrencyStruct {
    string name;
    uint8 decimals;
    uint256 totalSupply;
    address owner;
    address mmAddress;
  }


  // map of Market Maker owners: token address => currency struct
  mapping (address => CurrencyStruct) public currencyMap;
  // address of the deployed CLN contract (ERC20 Token)
  address public clnAddress;
  // address of the deployed elipse market maker contract
  address public mmLibAddress;

  address[] public tokens;

  event MarketOpen(address indexed marketMaker);
  event TokenCreated(address indexed token, address indexed owner);

  // modifier to check if called by issuer of the token
  modifier tokenIssuerOnly(address token, address owner) {
    require(currencyMap[token].owner == owner);
    _;
  }
  // modifier to only accept transferAndCall from CLN token
  modifier CLNOnly() {
    require(msg.sender == clnAddress);
    _;
  }

  /// @dev constructor only reuires the address of the CLN token which must use the ERC20 interface
  /// @param _mmLib address for the deployed market maker elipse contract
  /// @param _clnAddress address for the deployed ERC20 CLN token
  function CurrencyFactory(address _mmLib, address _clnAddress) public {
  	require(_mmLib != address(0));
  	require(_clnAddress != address(0));
  	mmLibAddress = _mmLib;
  	clnAddress = _clnAddress;
  }

  /// @dev create the MarketMaker and the CC token put all the CC token in the Market Maker reserve
  /// @param _name string name for CC token that is created.
  /// @param _symbol string symbol for CC token that is created.
  /// @param _decimals uint8 percison for CC token that is created.
  /// @param _totalSupply uint256 total supply of the CC token that is created.
  function createCurrency(string _name,
                          string _symbol,
                          uint8 _decimals,
                          uint256 _totalSupply) public
                          returns (address) {

  	ColuLocalCurrency subToken = new ColuLocalCurrency(_name, _symbol, _decimals, _totalSupply);
  	EllipseMarketMaker newMarketMaker = new EllipseMarketMaker(mmLibAddress, clnAddress, subToken);
  	//set allowance
  	require(subToken.transfer(newMarketMaker, _totalSupply));
  	require(IEllipseMarketMaker(newMarketMaker).initializeAfterTransfer());
  	currencyMap[subToken] = CurrencyStruct({ name: _name, decimals: _decimals, totalSupply: _totalSupply, mmAddress: newMarketMaker, owner: msg.sender});
    tokens.push(subToken);
  	TokenCreated(subToken, msg.sender);
  	return subToken;
  }

  /// @dev normal send cln to the market maker contract, sender must approve() before calling method. can only be called by owner
  /// @dev sending CLN will return CC from the reserve to the sender.
  /// @param _token address address of the cc token managed by this factory.
  /// @param _clnAmount uint256 amount of CLN to transfer into the Market Maker reserve.
  function insertCLNtoMarketMaker(address _token,
                                  uint256 _clnAmount) public
                                  tokenIssuerOnly(_token, msg.sender)
                                  returns (uint256 _subTokenAmount) {
  	require(_clnAmount > 0);
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(clnAddress).transferFrom(msg.sender, this, _clnAmount));
  	require(ERC20(clnAddress).approve(marketMakerAddress, _clnAmount));
  	_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, _clnAmount, _token);
    require(ERC20(_token).transfer(msg.sender, _subTokenAmount));
  }

  /// @dev ERC223 transferAndCall, send cln to the market maker contract can only be called by owner (see MarketMaker)
  /// @dev sending CLN will return CC from the reserve to the sender.
  /// @param _token address address of the cc token managed by this factory.
  function insertCLNtoMarketMaker(address _token) public
                                  tokenPayable
                                  CLNOnly
                                  tokenIssuerOnly(_token, tkn.sender)
                                  returns (uint256 _subTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(clnAddress).approve(marketMakerAddress, tkn.value));
  	_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, tkn.value, _token);
    require(ERC20(_token).transfer(tkn.sender, _subTokenAmount));
  }

  /// @dev normal send cc to the market maker contract, sender must approve() before calling method. can only be called by owner
  /// @dev sending CC will return CLN from the reserve to the sender.
  /// @param _token address address of the cc token managed by this factory.
  /// @param _ccAmount uint256 amount of CC to transfer into the Market Maker reserve.
  function extractCLNfromMarketMaker(address _token,
                                     uint256 _ccAmount) public
                                     tokenIssuerOnly(_token, msg.sender)
                                     returns (uint256 _clnTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(_token).transferFrom(msg.sender, this, _ccAmount));
  	require(ERC20(_token).approve(marketMakerAddress, _ccAmount));
  	_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(_token, _ccAmount, clnAddress);
  	require(ERC20(clnAddress).transfer(msg.sender, _clnTokenAmount));
  }

  /// @dev ERC223 transferAndCall, send CC to the market maker contract can only be called by owner (see MarketMaker)
  /// @dev sending CC will return CLN from the reserve to the sender.
  function extractCLNfromMarketMaker() public
                                    tokenPayable
                                    tokenIssuerOnly(msg.sender, tkn.sender)
                                    returns (uint256 _clnTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(msg.sender);
  	require(ERC20(msg.sender).approve(marketMakerAddress, tkn.value));
  	_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(msg.sender, tkn.value, clnAddress);
  	require(ERC20(clnAddress).transfer(tkn.sender, _clnTokenAmount));
  }

  /// @dev opens the Market Maker to recvice transactions from all sources.
  /// @dev Request to transfer ownership of Market Maker contract to Owner instead of factory.
  /// @param _token address address of the cc token managed by this factory.
  function openMarket(address _token) public
                      tokenIssuerOnly(_token, msg.sender)
                      returns (bool) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(MarketMaker(marketMakerAddress).openForPublicTrade());
  	Ownable(marketMakerAddress).requestOwnershipTransfer(msg.sender);
  	MarketOpen(marketMakerAddress);
  	return true;
  }

  /// @dev implementation for standard 223 reciver.
  /// @param _token address of the token used with transferAndCall.
  function supportsToken(address _token) public constant returns (bool) {
  	return (clnAddress == _token || currencyMap[_token].totalSupply > 0);
  }

  /// @dev helper function to get the market maker address form token
  /// @param _token address of the token used with transferAndCall.
  function getMarketMakerAddressFromToken(address _token) public constant returns (address _marketMakerAddress) {
  	_marketMakerAddress = currencyMap[_token].mmAddress;
    require(_marketMakerAddress != address(0));
  }
}









/**
 * The IssuanceFactory creates an issuance contract that accepts on one side CLN
 * locks then up in an elipse market maker up to the supplied softcap
 * and returns a CC token based on price that is derived form the two supplies and reserves of each
 */

/// @title Colu Issuance factoy with CLN for CC tokens.
/// @author Rotem Lev.
contract IssuanceFactory is CurrencyFactory {
	using SafeMath for uint256;

	uint256 public PRECISION;

  struct IssuanceStruct {
  	uint256 hardcap;
  	uint256 reserve;
    uint256 startTime;
    uint256 endTime;
    uint256 targetPrice;
    uint256 clnRaised;
  }

  uint256 public totalCLNcustodian;

  //map of Market Maker owners
  mapping (address => IssuanceStruct) public issueMap;
  // total supply of CLN
  uint256 public CLNTotalSupply;

  event CLNRaised(address indexed token, address indexed participant, uint256 amount);
  event CLNRefunded(address indexed token, address indexed participant, uint256 amount);

  event SaleFinalized(address indexed token, uint256 clnRaised);

  // sale has begun based on time and status
  modifier saleOpen(address _token) {
  	require(now >= issueMap[_token].startTime && issueMap[_token].endTime >= now);
    require(issueMap[_token].clnRaised < issueMap[_token].hardcap);
  	_;
  }

  // sale is passed its endtime
  modifier hasEnded(address _token) {
    require(issueMap[_token].endTime < now);
  	_;
  }

  // sale considered successful when it raised equal to or more than the softcap
  modifier saleWasSuccessfull(address _token) {
  	require(issueMap[_token].clnRaised >= issueMap[_token].reserve);
  	_;
  }

   // sale considerd failed when it raised less than the softcap
  modifier saleHasFailed(address _token) {
  	require(issueMap[_token].clnRaised < issueMap[_token].reserve);
  	_;
  }

  // checks if the instance of market maker contract is closed for public
  modifier marketClosed(address _token) {
  	require(!MarketMaker(currencyMap[_token].mmAddress).isOpenForPublic());
  	_;
  }
  /// @dev constructor
  /// @param _mmLib address for the deployed elipse market maker contract
  /// @param _clnAddress address for the deployed CLN ERC20 token
  function IssuanceFactory(address _mmLib, address _clnAddress) public CurrencyFactory(_mmLib, _clnAddress) {
    CLNTotalSupply = ERC20(_clnAddress).totalSupply();
    PRECISION = IEllipseMarketMaker(_mmLib).PRECISION();
  }

	/// @dev createIssuance create local currency issuance sale
	/// @param _startTime uint256 blocktime for sale start
	/// @param _durationTime uint 256 duration of the sale
	/// @param _hardcap uint CLN hardcap for issuance
	/// @param _reserveAmount uint CLN reserve ammount
	/// @param _name string name of the token
	/// @param _symbol string symbol of the token
	/// @param _decimals uint8 ERC20 decimals of local currency
	/// @param _totalSupply uint total supply of the local currency
  function createIssuance( uint256 _startTime,
                            uint256 _durationTime,
                            uint256 _hardcap,
                            uint256 _reserveAmount,
                            string _name,
                            string _symbol,
                            uint8 _decimals,
                            uint256 _totalSupply) public
                            returns (address) {
    require(_startTime > now);
    require(_durationTime > 0);
	require(_hardcap > 0);

    uint256 R2 = IEllipseMarketMaker(mmLibAddress).calcReserve(_reserveAmount, CLNTotalSupply, _totalSupply);
    uint256 targetPrice = IEllipseMarketMaker(mmLibAddress).getPrice(_reserveAmount, R2, CLNTotalSupply, _totalSupply);
    require(isValidIssuance(_hardcap, targetPrice, _totalSupply, R2));
    address tokenAddress = super.createCurrency(_name,  _symbol,  _decimals,  _totalSupply);
    addToMap(tokenAddress, _startTime, _startTime + _durationTime, _hardcap, _reserveAmount, targetPrice);

    return tokenAddress;
  }

  /// @dev internal helper to add currency data to the issuance map
  /// @param _token address token address for this issuance (same as CC adress)
  /// @param _startTime uint256 blocktime for sale start
  /// @param _endTime uint256 blocktime for sale end
  /// @param _hardcap uint256 sale hardcap
  /// @param _reserveAmount uint256 sale softcap
  /// @param _targetPrice uint256 sale CC price per CLN if it were to pass the softcap
  function addToMap(address _token,
                    uint256 _startTime,
                    uint256 _endTime,
                    uint256 _hardcap,
                    uint256 _reserveAmount,
                    uint256 _targetPrice) private {
  	issueMap[_token] = IssuanceStruct({ hardcap: _hardcap,
										reserve: _reserveAmount,
										startTime: _startTime,
										endTime: _endTime,
										clnRaised: 0,
										targetPrice: _targetPrice});
  }

  /// @dev participate in the issuance of the local currency
  /// @param _token address token address for this issuance (same as CC adress)
  /// @param _clnAmount uint256 amount of CLN to try and participate
  /// @return releaseAmount uint ammount of CC tokens released and transfered to sender
  function participate(address _token,
						uint256 _clnAmount) public
						saleOpen(_token)
						returns (uint256 releaseAmount) {
	require(_clnAmount > 0);
    address marketMakerAddress = getMarketMakerAddressFromToken(_token);

    // how much do we need to actually send to market maker of the incomming amount
    // and how much of the amount can participate
    uint256 transferToReserveAmount;
    uint256 participationAmount;
    (transferToReserveAmount, participationAmount) = getParticipationAmounts(_clnAmount, _token);
    // send what we need to the market maker for reserve
    require(ERC20(clnAddress).transferFrom(msg.sender, this, participationAmount));
  	approveAndChange(clnAddress, _token, transferToReserveAmount, marketMakerAddress);
    // pay back to participant with the participated amount * price
    releaseAmount = participationAmount.mul(issueMap[_token].targetPrice).div(PRECISION);

    issueMap[_token].clnRaised = issueMap[_token].clnRaised.add(participationAmount);
    totalCLNcustodian = totalCLNcustodian.add(participationAmount);
    CLNRaised(_token, msg.sender, participationAmount);
    require(ERC20(_token).transfer(msg.sender, releaseAmount));
  }

  /// @dev Participate in the CLN based issuance (for contract)
  /// @param _token address token address for this issuance (same as CC adress)
  function participate(address _token)
						public
						tokenPayable
						saleOpen(_token)
						returns (uint256 releaseAmount) {
  	require(tkn.value > 0 && msg.sender == clnAddress);
    //check if we need to send cln to mm or save it
    uint256 transferToReserveAmount;
    uint256 participationAmount;
    (transferToReserveAmount, participationAmount) = getParticipationAmounts(tkn.value, _token);
    address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	approveAndChange(clnAddress, _token, transferToReserveAmount, marketMakerAddress);
    // transfer only what we need
    releaseAmount = participationAmount.mul(issueMap[_token].targetPrice).div(PRECISION);
    issueMap[_token].clnRaised = issueMap[_token].clnRaised.add(participationAmount);
    totalCLNcustodian = totalCLNcustodian.add(participationAmount);
    CLNRaised(_token, tkn.sender, participationAmount);
    require(ERC20(_token).transfer(tkn.sender, releaseAmount));
    // send CLN change to the participent since its transferAndCall
    if (tkn.value > participationAmount)
       require(ERC20(clnAddress).transfer(tkn.sender, tkn.value.sub(participationAmount)));
  }

  /// @dev called by the creator to finish the sale, open the market maker and get his tokens
  /// @dev can only be called after the sale end time and if the sale passed the softcap
  /// @param _token address token address for this issuance (same as CC adress)
  function finalize(address _token) public
  							tokenIssuerOnly(_token, msg.sender)
  							hasEnded(_token)
							saleWasSuccessfull(_token)
  							marketClosed(_token)
  							returns (bool) {
    // move all CC and CLN that were raised and not in the reserves to the issuer
    address marketMakerAddress = getMarketMakerAddressFromToken(_token);
    uint256 clnAmount = issueMap[_token].clnRaised.sub(issueMap[_token].reserve);
    totalCLNcustodian = totalCLNcustodian.sub(clnAmount);
    uint256 ccAmount = ERC20(_token).balanceOf(this);
    // open Market Maker for public trade.
    require(MarketMaker(marketMakerAddress).openForPublicTrade());

    require(ERC20(_token).transfer(msg.sender, ccAmount));
    require(ERC20(clnAddress).transfer(msg.sender, clnAmount));
    SaleFinalized(_token, issueMap[_token].clnRaised);
    return true;
}

  /// @dev Give back CC and get a refund back in CLN,
  /// dev can only be called after sale ended and the softcap not reached
  /// @param _token address token address for this issuance (same as CC adress)
  /// @param _ccAmount uint256 amount of CC to try and refund
  function refund(address _token,
                  uint256 _ccAmount) public
  							hasEnded(_token)
  							saleHasFailed(_token)
  							marketClosed(_token)
  							returns (bool) {
	require(_ccAmount > 0);
	// exchange CC for CLN throuh Market Maker
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(_token).transferFrom(msg.sender, this, _ccAmount));
  	uint256 factoryCCAmount = ERC20(_token).balanceOf(this);
  	require(ERC20(_token).approve(marketMakerAddress, factoryCCAmount));
  	require(MarketMaker(marketMakerAddress).change(_token, factoryCCAmount, clnAddress) > 0);

  	uint256 returnAmount = _ccAmount.mul(PRECISION).div(issueMap[_token].targetPrice);
    issueMap[_token].clnRaised = issueMap[_token].clnRaised.sub(returnAmount);
    totalCLNcustodian = totalCLNcustodian.sub(returnAmount);
    CLNRefunded(_token, msg.sender, returnAmount);
  	require(ERC20(clnAddress).transfer(msg.sender, returnAmount));
    return true;
  }


  /// @dev Give back CC and get a refund back in CLN,
  /// dev can only be called after sale ended and the softcap not
  function refund() public
	                tokenPayable
					hasEnded(msg.sender)
					saleHasFailed(msg.sender)
					marketClosed(msg.sender)
					returns (bool) {
	require(tkn.value > 0);
  	// if we have CC time to thorw it to the Market Maker
  	address marketMakerAddress = getMarketMakerAddressFromToken(msg.sender);
  	uint256 factoryCCAmount = ERC20(msg.sender).balanceOf(this);
  	require(ERC20(msg.sender).approve(marketMakerAddress, factoryCCAmount));
  	require(MarketMaker(marketMakerAddress).change(msg.sender, factoryCCAmount, clnAddress) > 0);

  	uint256 returnAmount = tkn.value.mul(PRECISION).div(issueMap[msg.sender].targetPrice);
    issueMap[msg.sender].clnRaised = issueMap[msg.sender].clnRaised.sub(returnAmount);
    totalCLNcustodian = totalCLNcustodian.sub(returnAmount);
    CLNRefunded(msg.sender, tkn.sender, returnAmount);
  	require(ERC20(clnAddress).transfer(tkn.sender, returnAmount));
    return true;

  }

  /// @dev normal send cln to the market maker contract, sender must approve() before calling method. can only be called by owner
  /// @dev sending CLN will return CC from the reserve to the sender.
  function insertCLNtoMarketMaker(address, uint256) public returns (uint256) {
    require(false);
    return 0;
  }

  /// @dev ERC223 transferAndCall, send cln to the market maker contract can only be called by owner (see MarketMaker)
  /// @dev sending CLN will return CC from the reserve to the sender.
  function insertCLNtoMarketMaker(address) public returns (uint256) {
    require(false);
    return 0;
  }

  /// @dev normal send CC to the market maker contract, sender must approve() before calling method. can only be called by owner
  /// @dev sending CC will return CLN from the reserve to the sender.
  function extractCLNfromMarketMaker(address, uint256) public returns (uint256) {
    require(false);
    return 0;
  }

  /// @dev ERC223 transferAndCall, send CC to the market maker contract can only be called by owner (see MarketMaker)
  /// @dev sending CC will return CLN from the reserve to the sender.
  function extractCLNfromMarketMaker() public returns (uint256) {
    require(false);
    return 0;
  }

  /// @dev opens the Market Maker to recvice transactions from all sources.
  /// @dev Request to transfer ownership of Market Maker contract to Owner instead of factory.
  function openMarket(address) public returns (bool) {
		require(false);
		return false;
  }

  /// @dev checks if the parameters that were sent to the create are valid for a promised price and buyback
  /// @param _hardcap uint256 CLN hardcap for issuance
  /// @param _price uint256 computed through the market maker using the supplies and reserves
  /// @param _S2 uint256 supply of the CC token
  /// @param _R2 uint256 reserve of the CC token
  function isValidIssuance(uint256 _hardcap,
                            uint256 _price,
                            uint256 _S2,
                            uint256 _R2) public view
                            returns (bool) {
 	  return (_S2 > _R2 && _S2.sub(_R2).mul(PRECISION) >= _hardcap.mul(_price));
  }


  /// @dev helper function to fetch market maker contract address deploed with the CC
  /// @param _token address token address for this issuance (same as CC adress)
  function getMarketMakerAddressFromToken(address _token) public constant returns (address) {
  	return currencyMap[_token].mmAddress;
  }

  /// @dev helper function to approve tokens for market maker and then change tokens
  /// @param _token address deployed ERC20 token address to spend
  /// @param _token2 address deployed ERC20 token address to buy
  /// @param _amount uint256 amount of _token to spend
  /// @param _marketMakerAddress address for the deploed market maker with this CC
  function approveAndChange(address _token,
                            address _token2,
                            uint256 _amount,
                            address _marketMakerAddress) private
                            returns (uint256) {
  	if (_amount > 0) {
	  	require(ERC20(_token).approve(_marketMakerAddress, _amount));
	  	return MarketMaker(_marketMakerAddress).change(_token, _amount, _token2);
	  }
	  return 0;
  }

  /// @dev helper function participation with CLN
  /// @dev returns the amount to send to reserve and amount to participate
  /// @param _clnAmount amount of cln the user wants to participate with
  /// @param _token address token address for this issuance (same as CC adress)
  /// @return {
  ///	"transferToReserveAmount": ammount of CLN to transfer to reserves
  ///	"participationAmount": ammount of CLN that the sender will participate with in the sale
  ///}
  function getParticipationAmounts(uint256 _clnAmount,
                                   address _token) private view
                                   returns (uint256 transferToReserveAmount, uint256 participationAmount) {
    uint256 clnRaised = issueMap[_token].clnRaised;
    uint256 reserve = issueMap[_token].reserve;
    uint256 hardcap = issueMap[_token].hardcap;
    participationAmount = SafeMath.min256(_clnAmount, hardcap.sub(clnRaised));
    if (reserve > clnRaised) {
      transferToReserveAmount = SafeMath.min256(participationAmount, reserve.sub(clnRaised));
    }
  }

  /// @dev Returns total number of issuances after filters are applied.
  /// @dev this function is gas wasteful so do not call this from a state changing transaction
  /// @param _pending include pending currency issuances.
  /// @param _started include started currency issuances.
  /// @param _successful include successful and ended currency issuances.
  /// @param _failed include failed and ended currency issuances.
  /// @return Total number of currency issuances after filters are applied.
  function getIssuanceCount(bool _pending, bool _started, bool _successful, bool _failed)
    public
    view
    returns (uint _count)
  {
    for (uint i = 0; i < tokens.length; i++) {
      IssuanceStruct memory issuance = issueMap[tokens[i]];
      if ((_pending && issuance.startTime > now)
        || (_started && now >= issuance.startTime && issuance.endTime >= now && issuance.clnRaised < issuance.hardcap)
        || (_successful && issuance.endTime < now && issuance.clnRaised >= issuance.reserve)
        || (_successful && issuance.endTime >= now && issuance.clnRaised == issuance.hardcap)
        || (_failed && issuance.endTime < now && issuance.clnRaised < issuance.reserve))
        _count += 1;
    }
  }

  /// @dev Returns list of issuance ids (allso the token address of the issuance) in defined range after filters are applied.
  /// @dev _offset and _limit parameters are intended for pagination
  /// @dev this function is gas wasteful so do not call this from a state changing transaction
  /// @param _pending include pending currency issuances.
  /// @param _started include started currency issuances.
  /// @param _successful include successful and ended currency issuances.
  /// @param _failed include failed and ended currency issuances.
  /// @param _offset index start position of issuance ids array.
  /// @param _limit maximum number of issuance ids to return.
  /// @return Returns array of token adresses for issuance.
  function getIssuanceIds(bool _pending, bool _started, bool _successful, bool _failed, uint _offset, uint _limit)
    public
    view
    returns (address[] _issuanceIds)
  {
	require(_limit >= 1);
	require(_limit <= 100);
    _issuanceIds = new address[](_limit);
    uint filteredIssuancesCount = 0;
	uint retrieveIssuancesCount = 0;
    for (uint i = 0; i < tokens.length; i++) {
      IssuanceStruct memory issuance = issueMap[tokens[i]];
      if ((_pending && issuance.startTime > now)
        || (_started && now >= issuance.startTime && issuance.endTime >= now && issuance.clnRaised < issuance.hardcap)
        || (_successful && issuance.endTime < now && issuance.clnRaised >= issuance.reserve)
        || (_successful && issuance.endTime >= now && issuance.clnRaised == issuance.hardcap)
        || (_failed && issuance.endTime < now && issuance.clnRaised < issuance.reserve))
      {
		if (filteredIssuancesCount >= _offset) {
			_issuanceIds[retrieveIssuancesCount] = tokens[i];
			retrieveIssuancesCount += 1;
		}
		if (retrieveIssuancesCount == _limit) {
			return _issuanceIds;
		}
        filteredIssuancesCount += 1;
      }
    }

	if (retrieveIssuancesCount < _limit) {
		address[] memory _issuanceIdsTemp = new address[](retrieveIssuancesCount);
		for (i = 0; i < retrieveIssuancesCount; i++) {
			_issuanceIdsTemp[i] = _issuanceIds[i];
		}
		return _issuanceIdsTemp;
	}
  }

  /// @dev Allow the owner to transfer out any accidentally sent ERC20 tokens.
  /// @param _tokenAddress address The address of the ERC20 contract.
  /// @param _amount uint256 The amount of tokens to be transferred.
  function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
    if (_tokenAddress == clnAddress) {
      uint256 excessCLN = ERC20(clnAddress).balanceOf(this).sub(totalCLNcustodian);
      require(excessCLN <= _amount);
    }

    if (issueMap[_tokenAddress].hardcap > 0) {
      require(MarketMaker(currencyMap[_tokenAddress].mmAddress).isOpenForPublic());
    }
    return ERC20(_tokenAddress).transfer(owner, _amount);
  }
}