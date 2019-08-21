pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract DebtToken {
  using SafeMath for uint256;
  /**
  Recognition data
  */
  string public name;
  string public symbol;
  string public version = 'DT0.1';
  uint256 public decimals = 18;

  /**
  ERC20 properties
  */
  uint256 public totalSupply;
  mapping(address => uint256) public balances;
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
  Mintable Token properties
  */
  bool public mintingFinished = true;
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  /**
  Actual logic data
  */
  uint256 public dayLength;//Number of seconds in a day
  uint256 public loanTerm;//Loan term in days
  uint256 public exchangeRate; //Exchange rate for Ether to loan coins
  uint256 public initialSupply; //Keep record of Initial value of Loan
  uint256 public loanActivation; //Timestamp the loan was funded
  
  uint256 public interestRatePerCycle; //Interest rate per interest cycle
  uint256 public interestCycleLength; //Total number of days per interest cycle
  
  uint256 public totalInterestCycles; //Total number of interest cycles completed
  uint256 public lastInterestCycle; //Keep record of Initial value of Loan
  
  address public lender; //The address from which the loan will be funded, and to which the refund will be directed
  address public borrower;
  
  uint256 public constant PERCENT_DIVISOR = 100;
  
  function DebtToken(
      string _tokenName,
      string _tokenSymbol,
      uint256 _initialAmount,
      uint256 _exchangeRate,
      uint256 _dayLength,
      uint256 _loanTerm,
      uint256 _loanCycle,
      uint256 _interestRatePerCycle,
      address _lender,
      address _borrower
      ) {

      require(_exchangeRate > 0);
      require(_initialAmount > 0);
      require(_dayLength > 0);
      require(_loanCycle > 0);

      require(_lender != 0x0);
      require(_borrower != 0x0);
      
      exchangeRate = _exchangeRate;                           // Exchange rate for the coins
      initialSupply = _initialAmount.mul(exchangeRate);            // Update initial supply
      totalSupply = initialSupply;                           //Update total supply
      balances[_borrower] = initialSupply;                 // Give the creator all initial tokens

      name = _tokenName;                                    // Amount of decimals for display purposes
      symbol = _tokenSymbol;                              // Set the symbol for display purposes
      
      dayLength = _dayLength;                             //Set the length of each day in seconds...For dev purposes
      loanTerm = _loanTerm;                               //Set the number of days, for loan maturity
      interestCycleLength = _loanCycle;                   //set the Interest cycle period
      interestRatePerCycle = _interestRatePerCycle;                      //Set the Interest rate per cycle
      lender = _lender;                             //set lender address
      borrower = _borrower;

      Transfer(0,_borrower,totalSupply);//Allow funding be tracked
  }

  /**
  Debt token functionality
   */
  function actualTotalSupply() public constant returns(uint) {
    uint256 coins;
    uint256 cycle;
    (coins,cycle) = calculateInterestDue();
    return totalSupply.add(coins);
  }

  /**
  Fetch total value of loan in wei (Initial +interest)
  */
  function getLoanValue(bool initial) public constant returns(uint){
    //TODO get a more dynamic way to calculate
    if(initial == true)
      return initialSupply.div(exchangeRate);
    else{
      uint totalTokens = actualTotalSupply().sub(balances[borrower]);
      return totalTokens.div(exchangeRate);
    }
  }

  /**
  Fetch total coins gained from interest
  */
  function getInterest() public constant returns (uint){
    return actualTotalSupply().sub(initialSupply);
  }

  /**
  Checks that caller's address is the lender
  */
  function isLender() private constant returns(bool){
    return msg.sender == lender;
  }

  /**
  Check that caller's address is the borrower
  */
  function isBorrower() private constant returns (bool){
    return msg.sender == borrower;
  }

  function isLoanFunded() public constant returns(bool) {
    return balances[lender] > 0 && balances[borrower] == 0;
  }

  /**
  Check if the loan is mature for interest
  */
  function isTermOver() public constant returns (bool){
    if(loanActivation == 0)
      return false;
    else
      return now >= loanActivation.add( dayLength.mul(loanTerm) );
  }

  /**
  Check if updateInterest() needs to be called before refundLoan()
  */
  function isInterestStatusUpdated() public constant returns(bool){
    if(!isTermOver())
      return true;
    else
      return !( now >= lastInterestCycle.add( interestCycleLength.mul(dayLength) ) );
  }

  /**
  calculate the total number of passed interest cycles and coin value
  */
  function calculateInterestDue() public constant returns(uint256 _coins,uint256 _cycle){
    if(!isTermOver() || !isLoanFunded())
      return (0,0);
    else{
      uint timeDiff = now.sub(lastInterestCycle);
      _cycle = timeDiff.div(dayLength.mul(interestCycleLength) );
      _coins = _cycle.mul( interestRatePerCycle.mul(initialSupply) ).div(PERCENT_DIVISOR);//Delayed division to avoid too early floor
    }
  }

  /**
  Update the interest of the contract
  */
  function updateInterest() public {
    require( isTermOver() );
    uint interest_coins;
    uint256 interest_cycle;
    (interest_coins,interest_cycle) = calculateInterestDue();
    assert(interest_coins > 0 && interest_cycle > 0);
    totalInterestCycles =  totalInterestCycles.add(interest_cycle);
    lastInterestCycle = lastInterestCycle.add( interest_cycle.mul( interestCycleLength.mul(dayLength) ) );
    mint(lender , interest_coins);
  }

  /**
  Make payment to inititate loan
  */
  function fundLoan() public payable{
    require(isLender());
    require(msg.value == getLoanValue(true)); //Ensure input available
    require(!isLoanFunded()); //Avoid double payment

    loanActivation = now;  //store the time loan was activated
    lastInterestCycle = now.add(dayLength.mul(loanTerm) ) ; //store the date interest matures
    mintingFinished = false;                 //Enable minting
    transferFrom(borrower,lender,totalSupply);

    borrower.transfer(msg.value);
  }

  /**
  Make payment to refund loan
  */
  function refundLoan() onlyBorrower public payable{
    if(! isInterestStatusUpdated() )
        updateInterest(); //Ensure Interest is updated

    require(msg.value == getLoanValue(false));
    require(isLoanFunded());

    finishMinting() ;//Prevent further Minting
    transferFrom(lender,borrower,totalSupply);

    lender.transfer(msg.value);
  }

  /**
  Partial ERC20 functionality
   */

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) internal {
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
  }

  /**
  MintableToken functionality
   */

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyBorrower internal returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }


  /**
  Fallback function
  */
  function() public payable{
    require(initialSupply > 0);//Stop the whole process if initialSupply not set
    if(isBorrower())
      refundLoan();
    else if(isLender())
      fundLoan();
    else revert(); //Throw if neither of cases apply, ensure no free money
  }

  /**
  Modifiers
  */
  modifier onlyBorrower() {
    require(isBorrower());
    _;
  }
}

contract DebtTokenDeployer is Ownable{

    address public dayTokenAddress;
    uint public dayTokenFees; //DAY tokens to be paid for deploying custom DAY contract
    ERC20 dayToken;

    event FeeUpdated(uint _fee, uint _time);
    event DebtTokenCreated(address  _creator, address _debtTokenAddress, uint256 _time);

    function DebtTokenDeployer(address _dayTokenAddress, uint _dayTokenFees){
        dayTokenAddress = _dayTokenAddress;
        dayTokenFees = _dayTokenFees;
        dayToken = ERC20(dayTokenAddress);
    }

    function updateDayTokenFees(uint _dayTokenFees) onlyOwner public {
        dayTokenFees = _dayTokenFees;
        FeeUpdated(dayTokenFees, now);
    }

    function createDebtToken(string _tokenName,
        string _tokenSymbol,
        uint256 _initialAmount,
        uint256 _exchangeRate,
        uint256 _dayLength,
        uint256 _loanTerm,
        uint256 _loanCycle,
        uint256 _intrestRatePerCycle,
        address _lender)
    public
    {
        if(dayToken.transferFrom(msg.sender, this, dayTokenFees)){
            DebtToken newDebtToken = new DebtToken(_tokenName, _tokenSymbol, _initialAmount, _exchangeRate,
                 _dayLength, _loanTerm, _loanCycle,
                _intrestRatePerCycle, _lender, msg.sender);
            DebtTokenCreated(msg.sender, address(newDebtToken), now);
        }
    }

    // to collect all fees paid till now
    function fetchDayTokens() onlyOwner public {
        dayToken.transfer(owner, dayToken.balanceOf(this));
    }
}