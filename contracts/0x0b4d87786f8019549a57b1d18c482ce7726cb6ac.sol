pragma solidity ^0.4.23;

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

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

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

contract BablosTokenInterface is ERC20 {
  bool public frozen;
  function burn(uint256 _value) public;
  function setSale(address _sale) public;
  function thaw() external;
}

contract PriceUpdaterInterface {
  enum Currency { ETH, BTC, WME, WMZ, WMR, WMX }

  uint public decimalPrecision = 3;

  mapping(uint => uint) public price;
}

contract BablosCrowdsaleWalletInterface {
  enum State {
    // gathering funds
    GATHERING,
    // returning funds to investors
    REFUNDING,
    // funds can be pulled by owners
    SUCCEEDED
  }

  event StateChanged(State state);
  event Invested(address indexed investor, PriceUpdaterInterface.Currency currency, uint amount, uint tokensReceived);
  event EtherWithdrawan(address indexed to, uint value);
  event RefundSent(address indexed to, uint value);
  event ControllerRetired(address was);

  /// @dev price updater interface
  PriceUpdaterInterface public priceUpdater;

  /// @notice total amount of investments in currencies
  mapping(uint => uint) public totalInvested;

  /// @notice state of the registry
  State public state = State.GATHERING;

  /// @dev balances of investors in wei
  mapping(address => uint) public weiBalances;

  /// @dev balances of tokens sold to investors
  mapping(address => uint) public tokenBalances;

  /// @dev list of unique investors
  address[] public investors;

  /// @dev token accepted for refunds
  BablosTokenInterface public token;

  /// @dev operations will be controlled by this address
  address public controller;

  /// @dev the team's tokens percent
  uint public teamPercent;

  /// @dev tokens sent to initial PR - they will be substracted, when tokens will be burn
  uint public prTokens;
  
  /// @dev performs only allowed state transitions
  function changeState(State _newState) external;

  /// @dev records an investment
  /// @param _investor who invested
  /// @param _tokenAmount the amount of token bought, calculation is handled by ICO
  /// @param _currency the currency in which investor invested
  /// @param _amount the invested amount
  function invested(address _investor, uint _tokenAmount, PriceUpdaterInterface.Currency _currency, uint _amount) external payable;

  /// @dev get total invested in ETH
  function getTotalInvestedEther() external view returns (uint);

  /// @dev get total invested in EUR
  function getTotalInvestedEur() external view returns (uint);

  /// @notice withdraw `_value` of ether to his address, can be called if crowdsale succeeded
  /// @param _value amount of wei to withdraw
  function withdrawEther(uint _value) external;

  /// @notice owner: send `_value` of tokens to his address, can be called if
  /// crowdsale failed and some of the investors refunded the ether
  /// @param _value amount of token-wei to send
  function withdrawTokens(uint _value) external;

  /// @notice withdraw accumulated balance, called by payee in case crowdsale failed
  /// @dev caller should approve tokens bought during ICO to this contract
  function withdrawPayments() external;

  /// @dev returns investors count
  function getInvestorsCount() external view returns (uint);

  /// @dev ability for controller to step down
  function detachController() external;

  /// @dev unhold holded team's tokens
  function unholdTeamTokens() external;
}

contract BablosCrowdsale is ReentrancyGuard, Ownable {
  using SafeMath for uint;

  enum SaleState { INIT, ACTIVE, PAUSED, SOFT_CAP_REACHED, FAILED, SUCCEEDED }

  SaleState public state = SaleState.INIT;

  // The token being sold
  BablosTokenInterface public token;

  // Address where funds are collected
  BablosCrowdsaleWalletInterface public wallet;

  // How many tokens per 1 ether
  uint public rate;

  uint public openingTime;
  uint public closingTime;

  uint public tokensSold;
  uint public tokensSoldExternal;

  uint public softCap;
  uint public hardCap;
  uint public minimumAmount;

  address public controller;
  PriceUpdaterInterface public priceUpdater;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param currency of paid value
   * @param value paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint currency,
    uint value,
    uint amount
  );

  event StateChanged(SaleState _state);
  event FundTransfer(address _backer, uint _amount);

  // MODIFIERS

  modifier requiresState(SaleState _state) {
    require(state == _state);
    _;
  }

  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }

  /// @dev triggers some state changes based on current time
  /// @param _client optional refund parameter
  /// @param _payment optional refund parameter
  /// @param _currency currency
  /// note: function body could be skipped!
  modifier timedStateChange(address _client, uint _payment, PriceUpdaterInterface.Currency _currency) {
    if (SaleState.INIT == state && getTime() >= openingTime) {
      changeState(SaleState.ACTIVE);
    }

    if ((state == SaleState.ACTIVE || state == SaleState.SOFT_CAP_REACHED) && getTime() >= closingTime) {
      finishSale();

      if (_currency == PriceUpdaterInterface.Currency.ETH && _payment > 0) {
        _client.transfer(_payment);
      }
    } else {
      _;
    }
  }

  constructor(
    uint _rate, 
    BablosTokenInterface _token,
    uint _openingTime, 
    uint _closingTime, 
    uint _softCap,
    uint _hardCap,
    uint _minimumAmount) 
    public
  {
    require(_rate > 0);
    require(_token != address(0));
    require(_openingTime >= getTime());
    require(_closingTime > _openingTime);
    require(_softCap > 0);
    require(_hardCap > 0);

    rate = _rate;
    token = _token;
    openingTime = _openingTime;
    closingTime = _closingTime;
    softCap = _softCap;
    hardCap = _hardCap;
    minimumAmount = _minimumAmount;
  }

  function setWallet(BablosCrowdsaleWalletInterface _wallet) external onlyOwner {
    require(_wallet != address(0));
    wallet = _wallet;
  }

  function setController(address _controller) external onlyOwner {
    require(_controller != address(0));
    controller = _controller;
  }

  function setPriceUpdater(PriceUpdaterInterface _priceUpdater) external onlyOwner {
    require(_priceUpdater != address(0));
    priceUpdater = _priceUpdater;
  }

  function isActive() public view returns (bool active) {
    return state == SaleState.ACTIVE || state == SaleState.SOFT_CAP_REACHED;
  }

  /**
   * @dev fallback function
   */
  function () external payable {
    require(msg.data.length == 0);
    buyTokens(msg.sender);
  }

  /**
   * @dev token purchase
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {
    uint weiAmount = msg.value;

    require(_beneficiary != address(0));
    require(weiAmount != 0);

    // calculate token amount to be created
    uint tokens = _getTokenAmount(weiAmount);

    require(tokens >= minimumAmount && token.balanceOf(address(this)) >= tokens);

    _internalBuy(_beneficiary, PriceUpdaterInterface.Currency.ETH, weiAmount, tokens);
  }

  /**
   * @dev external token purchase (BTC and WebMoney). Only allowed for merchant controller
   * @param _beneficiary Address performing the token purchase
   * @param _tokens Quantity of purchased tokens
   */
  function externalBuyToken(
    address _beneficiary, 
    PriceUpdaterInterface.Currency _currency, 
    uint _amount, 
    uint _tokens)
      external
      onlyController
  {
    require(_beneficiary != address(0));
    require(_tokens >= minimumAmount && token.balanceOf(address(this)) >= _tokens);
    require(_amount != 0);

    _internalBuy(_beneficiary, _currency, _amount, _tokens);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate).div(1 ether);
  }

  function _internalBuy(
    address _beneficiary, 
    PriceUpdaterInterface.Currency _currency, 
    uint _amount, 
    uint _tokens)
      internal
      nonReentrant
      timedStateChange(_beneficiary, _amount, _currency)
  {
    require(isActive());
    if (_currency == PriceUpdaterInterface.Currency.ETH) {
      tokensSold = tokensSold.add(_tokens);
    } else {
      tokensSoldExternal = tokensSoldExternal.add(_tokens);
    }
    token.transfer(_beneficiary, _tokens);

    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      uint(_currency),
      _amount,
      _tokens
    );

    if (_currency == PriceUpdaterInterface.Currency.ETH) {
      wallet.invested.value(_amount)(_beneficiary, _tokens, _currency, _amount);
      emit FundTransfer(_beneficiary, _amount);
    } else {
      wallet.invested(_beneficiary, _tokens, _currency, _amount);
    }
    
    // check if soft cap reached
    if (state == SaleState.ACTIVE && wallet.getTotalInvestedEther() >= softCap) {
      changeState(SaleState.SOFT_CAP_REACHED);
    }

    // check if all tokens are sold
    if (token.balanceOf(address(this)) < minimumAmount) {
      finishSale();
    }

    // check if hard cap reached
    if (state == SaleState.SOFT_CAP_REACHED && wallet.getTotalInvestedEur() >= hardCap) {
      finishSale();
    }
  }

  function finishSale() private {
    if (wallet.getTotalInvestedEther() < softCap) {
      changeState(SaleState.FAILED);
    } else {
      changeState(SaleState.SUCCEEDED);
    }
  }

  /// @dev performs only allowed state transitions
  function changeState(SaleState _newState) private {
    require(state != _newState);

    if (SaleState.INIT == state) {
      assert(SaleState.ACTIVE == _newState);
    } else if (SaleState.ACTIVE == state) {
      assert(
        SaleState.PAUSED == _newState ||
        SaleState.SOFT_CAP_REACHED == _newState ||
        SaleState.FAILED == _newState ||
        SaleState.SUCCEEDED == _newState
      );
    } else if (SaleState.SOFT_CAP_REACHED == state) {
      assert(
        SaleState.PAUSED == _newState ||
        SaleState.SUCCEEDED == _newState
      );
    } else if (SaleState.PAUSED == state) {
      assert(SaleState.ACTIVE == _newState || SaleState.FAILED == _newState);
    } else {
      assert(false);
    }

    state = _newState;
    emit StateChanged(state);

    if (SaleState.SOFT_CAP_REACHED == state) {
      onSoftCapReached();
    } else if (SaleState.SUCCEEDED == state) {
      onSuccess();
    } else if (SaleState.FAILED == state) {
      onFailure();
    }
  }

  function onSoftCapReached() private {
    wallet.changeState(BablosCrowdsaleWalletInterface.State.SUCCEEDED);
  }

  function onSuccess() private {
    // burn all remaining tokens
    token.burn(token.balanceOf(address(this)));
    token.thaw();
    wallet.unholdTeamTokens();
    wallet.detachController();
  }

  function onFailure() private {
    // allow clients to get their ether back
    wallet.changeState(BablosCrowdsaleWalletInterface.State.REFUNDING);
    wallet.unholdTeamTokens();
    wallet.detachController();
  }

  /// @dev to be overridden in tests
  function getTime() internal view returns (uint) {
    // solium-disable-next-line security/no-block-members
    return now;
  }

}