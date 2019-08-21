pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20 _token,
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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

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

contract AddressesFilterFeature is Ownable {}
contract ERC20Basic {}
contract BasicToken is ERC20Basic {}
contract StandardToken is ERC20, BasicToken {}
contract MintableToken is AddressesFilterFeature, StandardToken {}

contract Token is MintableToken {
      function mint(address, uint256) public returns (bool);
}


/**
 * @title CrowdsaleWPTByAuction
 * @dev This is a fully fledged crowdsale.
*/

contract CrowdsaleWPTByAuction is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // Address of tokens minter
  Token public minterContract;

  // Amount of invested ETH
  uint256 public ethRaised;

  // Array of investors and the amount of their investments
  mapping (address => uint256) private _balances;

  // Array of investors
  address[] public beneficiaryAddresses;

  // Cap for current round
  uint256 public cap;

  // BonusCap for current round
  uint256 public bonusCap;

  // Time ranges for current round
  uint256 public openingTime;
  uint256 public closingTime;

  //Minimal value of investment
  uint public minInvestmentValue;

  //Flags to on/off checks for buy Token
  bool public checksOn;

  //Amount of gas for internal transactions
  uint256 public gasAmount;

  /**
   * @dev Allows the owner to set the minter contract.
   * @param _minterAddr the minter address
   */
  function setMinter(address _minterAddr) public onlyOwner {
    minterContract = Token(_minterAddr);
  }

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
    );

  /**
   * Event for token transfer
   * @param _from who paid for the tokens
   * @param _to who got the tokens
   * @param amount amount of tokens purchased
   * @param isDone flag of success of transfer
   */
  event TokensTransfer(
    address indexed _from,
    address indexed _to,
    uint256 amount,
    bool isDone
    );

constructor () public {
    wallet = 0xeA9cbceD36a092C596e9c18313536D0EEFacff46;
    openingTime = 1537135200;
    closingTime = 1538344800;
    cap = 0;
    bonusCap = 1000000000000000000000000; //1M WPT 
    minInvestmentValue = 0.02 ether;
    ethRaised = 0;
        
    checksOn = true;
    gasAmount = 25000;
  }

   /**
   * @dev Close current round.
   */
  function closeRound() public onlyOwner {
    closingTime = block.timestamp + 1;
  }

   /**
   * @dev Set token address.
   */
  function setToken(ERC20 _token) public onlyOwner {
    token = _token;
  }

   /**
   * @dev Set address od deposit wallet.
   */
  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

   /**
   * @dev Change minimal amount of investment.
   */
  function changeMinInvest(uint256 newMinValue) public onlyOwner {
    minInvestmentValue = newMinValue;
  }

  /**
   * @dev Flag to sell WPT without checks.
   */
  function setChecksOn(bool _checksOn) public onlyOwner {
    checksOn = _checksOn;
  }

   /**
   * @dev Set amount of gas for internal transactions.
   */
  function setGasAmount(uint256 _gasAmount) public onlyOwner {
    gasAmount = _gasAmount;
  }
  
   /**
   * @dev Set cap for current round.
   */
  function setCap(uint256 _newCap) public onlyOwner {
    cap = _newCap;
  }

   /**
   * @dev Set bonusCap for current round.
   */
  function setBonusCap(uint256 _newBonusCap) public onlyOwner {
    bonusCap = _newBonusCap;
  }

   /**
   * @dev Add new investor.
   */
  function addInvestor(address _beneficiary, uint8 amountOfinvestedEth) public onlyOwner {
      _balances[_beneficiary] = amountOfinvestedEth;
      beneficiaryAddresses.push(_beneficiary);
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open.
   * @return Whether crowdsale period has opened
   */
  function hasOpened() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return (openingTime < block.timestamp && block.timestamp < closingTime);
  }

   /**
   * @dev Start new crowdsale round with auction if already not started.
   */
  function startNewRound(address _wallet, ERC20 _token, uint256 _cap, uint256 _bonusCap, uint256 _openingTime, uint256 _closingTime) payable public onlyOwner {
    require(!hasOpened());
    wallet = _wallet;
    token = _token;
    cap = _cap;
    bonusCap = _bonusCap;
    openingTime = _openingTime;
    closingTime = _closingTime;
    ethRaised = 0;
  }

   /**
   * @dev Pay all bonuses to all investors from last round
   */
  function payAllBonuses() payable public onlyOwner {
    require(hasClosed());

    uint256 allFunds = cap.add(bonusCap);
    uint256 priceWPTperETH = allFunds.div(ethRaised);

    uint beneficiaryCount = beneficiaryAddresses.length;
    for (uint i = 0; i < beneficiaryCount; i++) {
      minterContract.mint(beneficiaryAddresses[i], _balances[beneficiaryAddresses[i]].mul(priceWPTperETH));
      delete _balances[beneficiaryAddresses[i]];
    }

    delete beneficiaryAddresses;
    cap = 0;
    bonusCap = 0;

  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () payable external {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) payable public{

    uint256 weiAmount = msg.value;
    if (checksOn) {
        _preValidatePurchase(_beneficiary, weiAmount);
    }

    _balances[_beneficiary] = _balances[_beneficiary].add(weiAmount);
    beneficiaryAddresses.push(_beneficiary);

    // update state
    ethRaised = ethRaised.add(weiAmount);

    _forwardFunds();
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
  internal
  view
  onlyWhileOpen
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0 && _weiAmount > minInvestmentValue);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    bool isTransferDone = wallet.call.value(msg.value).gas(gasAmount)();
    emit TokensTransfer (
        msg.sender,
        wallet,
        msg.value,
        isTransferDone
        );
  }
}

//========================================================================

contract CrowdsaleWPTByRounds is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // Address of tokens minter
  Token public minterContract;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  uint256 public rate;

  // Amount of tokens raised
  uint256 public tokensRaised;

  // Cap for current round
  uint256 public cap;

  // Time ranges for current round
  uint256 public openingTime;
  uint256 public closingTime;

  //Minimal value of investment
  uint public minInvestmentValue;

  //Flags to on/off checks for buy Token
  bool public checksOn;

  //Amount of gas for internal transactions
  uint256 public gasAmount;

  /**
   * @dev Allows the owner to set the minter contract.
   * @param _minterAddr the minter address
   */
  function setMinter(address _minterAddr) public onlyOwner {
    minterContract = Token(_minterAddr);
  }

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
    );

  /**
   * Event for token transfer
   * @param _from who paid for the tokens
   * @param _to who got the tokens
   * @param amount amount of tokens purchased
   * @param isDone flag of success of transfer
   */
  event TokensTransfer(
    address indexed _from,
    address indexed _to,
    uint256 amount,
    bool isDone
    );

constructor () public {
    rate = 400;
    wallet = 0xeA9cbceD36a092C596e9c18313536D0EEFacff46;
    cap = 400000000000000000000000;
    openingTime = 1534558186;
    closingTime = 1535320800;

    minInvestmentValue = 0.02 ether;
        
    checksOn = true;
    gasAmount = 25000;
  }

   /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return tokensRaised >= cap;
  }

   /**
   * @dev Correction of current rate.
   */
  function changeRate(uint256 newRate) public onlyOwner {
    rate = newRate;
  }

   /**
   * @dev Close current round.
   */
  function closeRound() public onlyOwner {
    closingTime = block.timestamp + 1;
  }

   /**
   * @dev Set token address.
   */
  function setToken(ERC20 _token) public onlyOwner {
    token = _token;
  }

   /**
   * @dev Set address od deposit wallet.
   */
  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

   /**
   * @dev Change minimal amount of investment.
   */
  function changeMinInvest(uint256 newMinValue) public onlyOwner {
    minInvestmentValue = newMinValue;
  }

  /**
   * @dev Flag to sell WPT without checks.
   */
  function setChecksOn(bool _checksOn) public onlyOwner {
    checksOn = _checksOn;
  }

   /**
   * @dev Set amount of gas for internal transactions.
   */
  function setGasAmount(uint256 _gasAmount) public onlyOwner {
    gasAmount = _gasAmount;
  }

   /**
   * @dev Set cap for current round.
   */
  function setCap(uint256 _newCap) public onlyOwner {
    cap = _newCap;
  }

   /**
   * @dev Start new crowdsale round if already not started.
   */
  function startNewRound(uint256 _rate, address _wallet, ERC20 _token, uint256 _cap, uint256 _openingTime, uint256 _closingTime) payable public onlyOwner {
    require(!hasOpened());
    rate = _rate;
    wallet = _wallet;
    token = _token;
    cap = _cap;
    openingTime = _openingTime;
    closingTime = _closingTime;
    tokensRaised = 0;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open.
   * @return Whether crowdsale period has opened
   */
  function hasOpened() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return (openingTime < block.timestamp && block.timestamp < closingTime);
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () payable external {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) payable public{

    uint256 weiAmount = msg.value;
    if (checksOn) {
        _preValidatePurchase(_beneficiary, weiAmount);
    }

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    tokensRaised = tokensRaised.add(tokens);

    minterContract.mint(_beneficiary, tokens);
    
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _forwardFunds();
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
  internal
  view
  onlyWhileOpen
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0 && _weiAmount > minInvestmentValue);
    require(tokensRaised.add(_getTokenAmount(_weiAmount)) <= cap);
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    bool isTransferDone = wallet.call.value(msg.value).gas(gasAmount)();
    emit TokensTransfer (
        msg.sender,
        wallet,
        msg.value,
        isTransferDone
        );
  }
}