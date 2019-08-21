pragma solidity ^0.4.24;

contract Owned
{
  address internal owner;
  address private manager;
  address internal sink;

  constructor() public
  {
    owner = msg.sender;
    manager = msg.sender;
    sink = msg.sender;
  }

  modifier onlyOwner
  {
    require(msg.sender == owner, "Contract owner is required");
    _;
  }

  modifier onlyManager
  {
    require(msg.sender == manager, "Contract manager is required");
    _;
  }

  modifier onlyManagerNUser(address user)
  {
    require(msg.sender == manager || msg.sender == user, "Contract manager or wallet owner is required");
    _;
  }

  function transferOwnership(address newOwner, address newManager, address newSink) onlyOwner public
  {
    owner = newOwner;
    manager = newManager;
    sink = newSink;
  }
}

/*
interface tokenRecipient
{
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}
*/

contract SupplyInfo
{
  string public name;
  string public symbol;
  uint8 constant public decimals = 18;
  uint256 constant internal denominator = 10 ** uint256(decimals);
  uint256 public totalSupply;

  constructor(
      uint256 initialSupply,
      string tokenName,
      string tokenSymbol
  )
    public
  {
    totalSupply = initialSupply * denominator;
    name = tokenName;
    symbol = tokenSymbol;
  }
}

contract Transferable
{
  mapping (address => uint256) public balanceOf;
  event Transfer(address indexed from, address indexed to, uint256 value);

  function _transferTokens(address _from, address _to, uint _value) internal
  {
    require(balanceOf[_from] >= _value, "Not enough funds");
    require(balanceOf[_to] + _value >= balanceOf[_to], "BufferOverflow on receiver side");

    // uint previousBalances = balanceOf[_from] + balanceOf[_to];

    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);

    // assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
  }

  function transfer(address _to, uint256 _value) public returns (bool success)
  {
    _transferTokens(msg.sender, _to, _value);
    return true;
  }


}


contract ERC20 is SupplyInfo, Transferable
{
  constructor(
      uint256 initialSupply,
      string tokenName,
      string tokenSymbol
  ) SupplyInfo(initialSupply, tokenName, tokenSymbol)
    public
  {
    balanceOf[this] = totalSupply;
  }
}

contract Manageable is Transferable, Owned {
  event Deposit(
      address indexed _from,
      // bytes32 indexed _id,
      uint _value,
      string comment
  );

  event Withdraw(
      address indexed _to,
      uint _value,
      string comment
  );

  // function deposit(bytes32 _id) public payable {
  function deposit(string comment) public payable {
    emit Deposit(msg.sender, msg.value, comment);
  }

  function withdraw(uint256 amount, string comment) onlyOwner public {
    _transferEther(sink, amount);
    emit Withdraw(sink, amount, comment);
  }

  function _transferEther(address _to, uint _value) internal {
    address contractAddress = this;
    require(contractAddress.balance >= _value);
    _to.transfer(_value);
  }
}

contract Tradeable is ERC20, Manageable {


  event Buy(address indexed who, uint256 amount, uint256 buyPrice, string comment);
  event Sell(address indexed who, uint256 amount, uint256 sellPrice, string comment);

  function _convertEtherToToken(uint256 etherAmount, uint256 buyPrice) pure internal returns (uint256) {
    require(buyPrice > 0, "Buy price cant be zero");

    // BufferOverflow just in case
    require(etherAmount * denominator > etherAmount, "BufferOverflow");
    uint256 tokenAmount = etherAmount * denominator / buyPrice;

    return tokenAmount;
  }

  function _convertTokenToEther(uint256 tokenAmount, uint256 sellPrice) pure internal returns (uint256) {
    require(sellPrice > 0, "Sell price cant be zero");

    // BufferOverflow just in case
    require(tokenAmount * sellPrice > tokenAmount, "BufferOverflow");
    uint256 etherAmount = tokenAmount * sellPrice / denominator;
    return etherAmount;
  }

  function _buy(uint256 etherAmount, uint256 buyPrice, string comment) internal {
    require(etherAmount > 0, "Ether amount cant be zero");
    uint256 tokenAmount = _convertEtherToToken(etherAmount, buyPrice);

    // At this point transaction is accepted, just send tokens in return
    _transferTokens(this, msg.sender, tokenAmount);
    _transferEther(sink, etherAmount);
    emit Buy(msg.sender, tokenAmount, buyPrice, comment);
  }

  function _sell(uint256 tokenAmount, uint256 sellPrice, string comment) internal {
    uint256 etherAmount = _convertTokenToEther(tokenAmount, sellPrice);
    require(etherAmount > 0, "Ether amount after convert become zero - reverting"); // makes no sense otherwise

    _transferTokens(msg.sender, this, tokenAmount);
    _transferEther(msg.sender, tokenAmount);
    emit Sell(msg.sender, tokenAmount,sellPrice, comment);
  }
}

contract FrezeeableAccounts is Transferable, Owned {
  mapping (address => bool) internal frozenAccount;
  /* This generates a public event  on the blockchain that will notify clients */
  event FrozenFunds(address indexed target, bool indexed frozen);

  modifier notFrozen(address target)
  {
    require(!frozenAccount[target], "Account is frozen");
    _;
  }

  function freezeAccount(address target, bool freeze) onlyManager public {
    frozenAccount[target] = freeze;
    emit FrozenFunds(target, freeze);
  }

  function iamFrozen() view public returns(bool isFrozen)
  {
    return frozenAccount[msg.sender];
  }

  function transfer(address _to, uint256 _value) public notFrozen(msg.sender) notFrozen(_to) returns (bool success)
  {
    return super.transfer(_to, _value);
  }
}

contract Destructable is Owned {
  event Destruct(string indexed comment);

  function destruct(string comment) onlyOwner public {
    selfdestruct(owner);
    emit Destruct(comment);
  }
}

contract CoeficientTransform is SupplyInfo
{
  function applyChange(uint256 currentCoeficient, uint256 value) pure internal returns(uint256)
  {
    return currentCoeficient * value / denominator;
  }

  function deduceChange(uint256 currentCoeficient, uint256 value) pure internal returns(uint256)
  {
    require(value > 0, "Cant deduce zero change");
    uint256 opposite = denominator * denominator / value;
    return applyChange(currentCoeficient, opposite);
  }
}

contract DayCounter
{
  uint private DayZero;
  uint internal constant SecondsInDay = 60 * 60 * 24;

  constructor(uint ZeroDayTimestamp) public
  {
    DayZero = ZeroDayTimestamp;
  }

  function daysSince(uint a, uint b) pure internal returns(uint)
  {
    return (b - a) / SecondsInDay;
  }

  function DaysPast() view public returns(uint)
  {
    return daysSince(DayZero, now);
  }
}

contract InvestmentTransform is CoeficientTransform, DayCounter
{
  uint constant private percentsPerDay = 3;

  function currentRoiInPersents() view public returns(uint)
  {
    uint currentPercents = percentsPerDay * DaysPast();
    return 100 + currentPercents;
  }

  function investmentRate(uint256 currentCoeficient) view internal returns(uint256)
  {
    uint256 dailyMultiply = denominator * currentRoiInPersents() / 100;
    return applyChange(currentCoeficient, dailyMultiply);
  }
}

contract LinkedToFiatTransform is CoeficientTransform, Owned
{
  uint256 public fiatDriftAncor;
  uint256 public etherToFiatRate;

  event FiatLink(uint256 ancorDrift, uint exchangeRate);

  function setFiatLinkedCoef(uint256 newAncor, uint256 newRate) public onlyManager {
    require(newAncor > 0 && newRate > 0, "Coeficients cant be zero");
    fiatDriftAncor = newAncor;
    etherToFiatRate = newRate;
    emit FiatLink(newAncor, newRate);
  }

  function fiatDrift(uint256 currentCoeficient) view internal returns(uint256)
  {
    return applyChange(currentCoeficient, fiatDriftAncor);
  }

  function FiatToEther(uint256 amount) view internal returns(uint256)
  {
    return deduceChange(amount, etherToFiatRate);
  }

  function EtherToFiat(uint256 amount) view internal returns(uint256)
  {
    return applyChange(amount, etherToFiatRate);
  }
}

contract StartStopSell is CoeficientTransform, Owned
{
  bool internal buyAvailable = false;
  bool internal sellAvailable = false;

  function updateBuySellFlags(bool allowBuy, bool allowSell) public onlyManager
  {
    buyAvailable = allowBuy;
    sellAvailable = allowSell;
  }

  modifier canBuy()
  {
    require(buyAvailable, "Buy currently disabled");
    _;
  }

  modifier canSell()
  {
    require(sellAvailable, "Sell currently disabled");
    _;
  }
}

contract LISCTrade is FrezeeableAccounts, Tradeable, LinkedToFiatTransform, InvestmentTransform, StartStopSell
{
  uint256 internal baseFiatPrice;
  uint256 public minBuyAmount;

  constructor(uint256 basePrice) public
  {
    baseFiatPrice = basePrice;
  }

  function setMinTrade(uint256 _minBuyAmount) onlyManager public
  {
    minBuyAmount = _minBuyAmount;
  }

  function priceInUSD() view public returns(uint256)
  {
    uint256 price = baseFiatPrice;
    price = fiatDrift(price);
    price = investmentRate(price);
    require(price > 0, "USD price cant be zero");
    return price;
  }

  function priceInETH() view public returns(uint256)
  {
    return FiatToEther(priceInUSD());
  }

  function tokensPerETH() view public returns(uint256)
  {
    uint256 EthPerToken = priceInETH();
    return deduceChange(denominator, EthPerToken);
  }

  function buy(string comment) payable public canBuy notFrozen(msg.sender)
  {
    uint256 USDAmount = EtherToFiat(msg.value);
    require(USDAmount > minBuyAmount, "You cant buy lesser than min USD amount");
    _buy(msg.value, priceInETH(), comment);
  }

  function sell(uint256 tokenAmount, string comment) public canSell notFrozen(msg.sender)
  {
    _sell(tokenAmount, priceInETH(), comment);
  }
}


contract MintNBurn is ERC20
{
  event Mint(address indexed target, uint256 mintedAmount, string comment);
  event Burn(address indexed target, uint256 mintedAmount, string comment);


  function mintToken(address target, uint256 mintedAmount, string comment) internal
  {
    balanceOf[this] += mintedAmount;
    totalSupply += mintedAmount;

    _transferTokens(this, target, mintedAmount);
    emit Mint(target, mintedAmount, comment);
  }

  function burnToken(address target, uint256 amount, string comment) internal
  {
    _transferTokens(msg.sender, this, amount);
    balanceOf[this] -= amount;
    totalSupply -= amount;
    emit Burn(target, amount, comment);
  }
}

contract Upgradeable is MintNBurn, Owned
{
  address private prevVersion;
  address private newVersion = 0x0;
  mapping (address => bool) public upgraded;

  constructor(address upgradeFrom) internal {
    prevVersion = upgradeFrom;
  }

  function setUpgradeTo(address upgradeTo) public onlyOwner {
    newVersion = upgradeTo;
  }

  function upgradeAvalable() view public returns(bool) {
    return newVersion != 0x0;
  }

  function upgradeMe() public {
    upgradeUser(msg.sender);
  }

  function upgradeUser(address target) public onlyManagerNUser(target)
  {
    require(upgradeAvalable(), "New version not yet available");
    Upgradeable newContract = Upgradeable(newVersion);
    require(!newContract.upgraded(target), "Your account already been upgraded");
    newContract.importUser(target);
    burnToken(target, balanceOf[target], "Upgrading to new version");
  }

  function importMe() public {
    importUser(msg.sender);
  }

  function importUser(address target) onlyManager public
  {
    require(!upgraded[target], "Account already been upgraded");
    upgraded[target] = true;
    Transferable oldContract = Transferable(prevVersion);
    uint256 amount = oldContract.balanceOf(target);
    mintToken(target, amount, "Upgrade from previous version");
  }
}

contract TOKEN is ERC20, Owned, Destructable, LISCTrade, Upgradeable  {

  event Init(uint256 basePrice, uint dayZero);

  constructor(
      string tokenName,
      string tokenSymbol,
      uint basePrice,
      uint dayZero
  ) ERC20(0, tokenName, tokenSymbol) DayCounter(dayZero) LISCTrade(basePrice * denominator) Upgradeable(0x0) public
  {
    emit Init(basePrice, dayZero);
  }

  event Mint(address indexed target, uint256 mintedAmount, string comment);

  function mint(address target, uint256 mintedAmount, string comment) onlyOwner public {
    mintedAmount *= denominator;
    mintToken(target, mintedAmount, comment);
  }

  function burn(uint256 amount, string comment) private
  {
    burnToken(msg.sender, amount, comment);
  }

  function balance() view public returns(uint256)
  {
    return balanceOf[msg.sender];
  }

  event Broadcast(string message);

  function broadcast(string _message) public onlyManager
  {
    emit Broadcast(_message);
  }


}