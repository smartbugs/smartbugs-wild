pragma solidity 0.4.24;

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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable  {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

contract NIX is StandardToken, Pausable {

    string public name; 
    string public symbol;
    uint8 public decimals;
    //token available for reserved
    uint256 public TOKEN_RESERVED = 35e5 * 10 **18;
    uint256 public TOKEN_FOUNDERS_TEAMS = 525e4 * 10 **18;
    uint256 public TOKEN_ADVISORS = 175e4 * 10 **18;
    uint256 public TOKEN_MARKETING = 175e3 * 10 **18;

   constructor () public {
        name = "Encrypt Index";
        symbol = "NIX";
        decimals = 18;
        totalSupply_ = 35e6 * 10  **  uint256(decimals); //35 millions
        balances[owner] = totalSupply_;
   }
}

contract Sale is NIX{

    using SafeMath for uint256;
    // To indicate Sale status; saleStatus=0 => sale not started; saleStatus=1=> sale started; saleStatus=2=> sale finished
    uint256 public saleStatus; 
    // To store sale type; saleType=0 => private sale ,saleType=1 => PreSale; saleType=2 => public sale
    uint256 public saleType; 
    //price of token in cents
    uint256 public tokenCostPrivate = 8; //5 cents i.e., .5$
    //price of token in cents
    uint256 public tokenCostPre = 9; //5 cents i.e., .5$
    //price of token in cents
    uint256 public tokenCostPublic = 10; //5 cents i.e., .5$
    //1 eth = usd in cents, eg: 1 eth = 107.91$ so, 1 eth = =107,91 cents
    uint256 public ETH_USD;
    //min contribution 
    uint256 public minContribution = 1000000; //10000,00 cents i.e., 10000.00$
    //coinbase account
    address public wallet;
    //soft cap
    uint256 public softCap = 500000000; //$5 million
    //hard cap
    uint256 public hardCap = 1500000000; //$15 million
    //store total wei raised
    uint256 public weiRaised;
    //initially whitelisting is false  
    bool public whitelistingEnabled = false;

    //Structure to store token sent and wei received by the buyer of tokens
    struct Investor {
        uint256 weiReceived;
        uint256 tokenSent;
    }

    //investors indexed by their ETH address
    mapping(address => Investor) public investors;
    //whitelisting address
    mapping (address => bool) public whitelisted;

    
    /*
    * constructor invoked with wallet and eth_usd parameter
    */
    constructor (address _wallet, uint256 _ETH_USD) public{
      require(_wallet != address(0x0), "wallet address must not be zero");
      wallet = _wallet;
      ETH_USD = _ETH_USD;
    }
    
    /*
    * fallback function to create tokens
    */
    function () external payable{
        createTokens(msg.sender);
    }

    /*
    * function to change wallet
    */
    function changeWallet(address _wallet) public onlyOwner{
      require(_wallet != address(0x0), "wallet address must not be zero");
      wallet = _wallet;
    }

    /*
    * drain ethers from contract
    */
    function drain() external onlyOwner{
      wallet.transfer(address(this).balance);
    }

    /*
    * function to change whitelisting status
    */
    function toggleWhitelist() public onlyOwner{
        whitelistingEnabled = !whitelistingEnabled;
    }

    /*
    * function to change eth usd rate
    */
    function changeETH_USD(uint256 _ETH_USD) public onlyOwner{
        ETH_USD = _ETH_USD;
    }

    /*
    * function to add user to whitelist
    */
    function whitelistAddress(address investor) public onlyOwner{
        require(!whitelisted[investor], "users is already whitelisted");
        whitelisted[investor] = true;
    }

    /*
    * To start private sale
    */
    function startPrivateSale(uint256 _ETH_USD) public onlyOwner{
      require (saleStatus == 0);
      ETH_USD = _ETH_USD;
      saleStatus = 1;
    }

    /*
    * To start pre sale
    */
    function startPreSale(uint256 _ETH_USD) public onlyOwner{
      require (saleStatus == 1 && saleType == 0);
      ETH_USD = _ETH_USD;
      saleType = 1;
    }

    /*
    * To start public sale
    */
    function startPublicSale(uint256 _ETH_USD) public onlyOwner{
      require (saleStatus == 1 && saleType == 1);
      ETH_USD = _ETH_USD;
      saleType = 2;
    }

    /**
    * Set new minimum contribution
    * _minContribution minimum contribution in cents
    *
    */
    function changeMinContribution(uint256 _minContribution) public onlyOwner {
        require(_minContribution > 0, "min contribution should be greater than 0");
        minContribution = _minContribution;
    }

    /*
    * To create NIX Token and assign to transaction initiator
    */
    function createTokens(address _beneficiary) internal {
       _preValidatePurchase(_beneficiary, msg.value);
      //Calculate NIX Token to send
      uint256 totalNumberOfTokenTransferred = _getTokenAmount(msg.value);

      //transfer tokens to investor
      transferTokens(_beneficiary, totalNumberOfTokenTransferred);

      //initializing structure for the address of the beneficiary
      Investor storage _investor = investors[_beneficiary];
      //Update investor's balance
      _investor.tokenSent = _investor.tokenSent.add(totalNumberOfTokenTransferred);
      _investor.weiReceived = _investor.weiReceived.add(msg.value);
      weiRaised = weiRaised.add(msg.value);
      wallet.transfer(msg.value);
    }
    
    function transferTokens(address toAddr, uint256 value) private{
        balances[owner] = balances[owner].sub(value);
        balances[toAddr] = balances[toAddr].add(value);
        emit Transfer(owner, toAddr, value);
    }

    /**
    * function to create number of tokens to be transferred
    *
    */

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
      if(saleType == 0){
        return (_weiAmount.mul(ETH_USD).mul(100)).div((tokenCostPrivate).mul(80)); // 20% discount
      }else if(saleType == 1){
        return (_weiAmount.mul(ETH_USD).mul(100)).div((tokenCostPrivate).mul(90)); // 10% discount
      }else if (saleType == 2){
        return (_weiAmount.mul(ETH_USD).mul(100)).div((tokenCostPrivate).mul(95)); //5% discount
      }
    }

    /**
    * validatess sale requirement before creating tokens
    *
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) whenNotPaused internal view{
      require(_beneficiary != address(0), "beneficiary address must not be zero");
      require(whitelistingEnabled == false || whitelisted[_beneficiary],
                "whitelisting should be disabled or users should be whitelisted");
      //Make sure Sale is running
      assert(saleStatus == 1);
      require(_weiAmount >= getMinContributionInWei(), "amount is less than min contribution" );
    }

    /**
    * gives minimum contribution in wei
    * the min contribution value in wei
    *
    */
    function getMinContributionInWei() public view returns(uint256){
      return (minContribution.mul(1e18)).div(ETH_USD);
    }

    /**
    * gives usd raised based on wei raised
    * the usd value in cents
    *
    */
    function usdRaised() public view returns (uint256) {
      return weiRaised.mul(ETH_USD).div(1e18);
    }

    /**
    * tell soft cap reached or not
    * bool true=> if reached
    *
    */
    function isSoftCapReached() public view returns (bool) {
      if(usdRaised() >= softCap){
        return true;
      }
    }

    /**
    * tell hard cap reached or not
    * bool true=> if reached
    *
    */
    function isHardCapReached() public view returns (bool) {
      if(usdRaised() >= hardCap){
        return true;
      }
    }

}