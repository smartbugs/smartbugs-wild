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

contract BablosCrowdsaleWallet is BablosCrowdsaleWalletInterface, Ownable, ReentrancyGuard {
  using SafeMath for uint;

  modifier requiresState(State _state) {
    require(state == _state);
    _;
  }

  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }
  
  constructor(
    BablosTokenInterface _token, 
    address _controller, 
    PriceUpdaterInterface _priceUpdater, 
    uint _teamPercent, 
    uint _prTokens) 
      public 
  {
    token = _token;
    controller = _controller;
    priceUpdater = _priceUpdater;
    teamPercent = _teamPercent;
    prTokens = _prTokens;
  }

  function getTotalInvestedEther() external view returns (uint) {
    uint etherPrice = priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH));
    uint totalInvestedEth = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)];
    uint totalAmount = _totalInvestedNonEther();
    return totalAmount.mul(1 ether).div(etherPrice).add(totalInvestedEth);
  }

  function getTotalInvestedEur() external view returns (uint) {
    uint totalAmount = _totalInvestedNonEther();
    uint etherAmount = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)]
      .mul(priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH)))
      .div(1 ether);
    return totalAmount.add(etherAmount);
  }

  /// @dev total invested in EUR within ETH amount
  function _totalInvestedNonEther() internal view returns (uint) {
    uint totalAmount;
    uint precision = priceUpdater.decimalPrecision();
    // BTC
    uint btcAmount = totalInvested[uint(PriceUpdaterInterface.Currency.BTC)]
      .mul(10 ** precision)
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.BTC)));
    totalAmount = totalAmount.add(btcAmount);
    // WME
    uint wmeAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WME)]
      .mul(10 ** precision)
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WME)));
    totalAmount = totalAmount.add(wmeAmount);
    // WMZ
    uint wmzAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMZ)]
      .mul(10 ** precision)
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMZ)));
    totalAmount = totalAmount.add(wmzAmount);
    // WMR
    uint wmrAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMR)]
      .mul(10 ** precision)
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMR)));
    totalAmount = totalAmount.add(wmrAmount);
    // WMX
    uint wmxAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMX)]
      .mul(10 ** precision)
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMX)));
    totalAmount = totalAmount.add(wmxAmount);
    return totalAmount;
  }

  function changeState(State _newState) external onlyController {
    assert(state != _newState);

    if (State.GATHERING == state) {
      assert(_newState == State.REFUNDING || _newState == State.SUCCEEDED);
    } else {
      assert(false);
    }

    state = _newState;
    emit StateChanged(state);
  }

  function invested(
    address _investor,
    uint _tokenAmount,
    PriceUpdaterInterface.Currency _currency,
    uint _amount) 
      external 
      payable
      onlyController
  {
    require(state == State.GATHERING || state == State.SUCCEEDED);
    uint amount;
    if (_currency == PriceUpdaterInterface.Currency.ETH) {
      amount = msg.value;
      weiBalances[_investor] = weiBalances[_investor].add(amount);
    } else {
      amount = _amount;
    }
    require(amount != 0);
    require(_tokenAmount != 0);
    assert(_investor != controller);

    // register investor
    if (tokenBalances[_investor] == 0) {
      investors.push(_investor);
    }

    // register payment
    totalInvested[uint(_currency)] = totalInvested[uint(_currency)].add(amount);
    tokenBalances[_investor] = tokenBalances[_investor].add(_tokenAmount);

    emit Invested(_investor, _currency, amount, _tokenAmount);
  }

  function withdrawEther(uint _value)
    external
    onlyOwner
    requiresState(State.SUCCEEDED) 
  {
    require(_value > 0 && address(this).balance >= _value);
    owner.transfer(_value);
    emit EtherWithdrawan(owner, _value);
  }

  function withdrawTokens(uint _value)
    external
    onlyOwner
    requiresState(State.REFUNDING)
  {
    require(_value > 0 && token.balanceOf(address(this)) >= _value);
    token.transfer(owner, _value);
  }

  function withdrawPayments()
    external
    nonReentrant
    requiresState(State.REFUNDING)
  {
    address payee = msg.sender;
    uint payment = weiBalances[payee];
    uint tokens = tokenBalances[payee];

    // check that there is some ether to withdraw
    require(payment != 0);
    // check that the contract holds enough ether
    require(address(this).balance >= payment);
    // check that the investor (payee) gives back all tokens bought during ICO
    require(token.allowance(payee, address(this)) >= tokenBalances[payee]);

    totalInvested[uint(PriceUpdaterInterface.Currency.ETH)] = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)].sub(payment);
    weiBalances[payee] = 0;
    tokenBalances[payee] = 0;

    token.transferFrom(payee, address(this), tokens);

    payee.transfer(payment);
    emit RefundSent(payee, payment);
  }

  function getInvestorsCount() external view returns (uint) { return investors.length; }

  function detachController() external onlyController {
    address was = controller;
    controller = address(0);
    emit ControllerRetired(was);
  }

  function unholdTeamTokens() external onlyController {
    uint tokens = token.balanceOf(address(this));
    if (state == State.SUCCEEDED) {
      uint soldTokens = token.totalSupply().sub(token.balanceOf(address(this))).sub(prTokens);
      uint soldPecent = 100 - teamPercent;
      uint teamShares = soldTokens.mul(teamPercent).div(soldPecent).sub(prTokens);
      token.transfer(owner, teamShares);
      token.burn(token.balanceOf(address(this)));
    } else {
      token.approve(owner, tokens);
    }
  }
}