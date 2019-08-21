/**
    Copyright (c) 2018 Taylor OÜ

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

    based on the contracts of OpenZeppelin:
    https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts

**/

pragma solidity ^0.4.18;

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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
  @title TaylorToken
**/
contract TaylorToken is Ownable{

    using SafeMath for uint256;

    /**
        EVENTS
    **/
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _owner, uint256 _amount);
    /**
        CONTRACT VARIABLES
    **/
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    //this address can transfer even when transfer is disabled.
    mapping (address => bool) public whitelistedTransfer;
    mapping (address => bool) public whitelistedBurn;

    string public name = "Taylor";
    string public symbol = "TAY";
    uint8 public decimals = 18;
    uint256 constant internal DECIMAL_CASES = 10**18;
    uint256 public totalSupply = 10**7 * DECIMAL_CASES;
    bool public transferable = false;

    /**
        MODIFIERS
    **/
    modifier onlyWhenTransferable(){
      if(!whitelistedTransfer[msg.sender]){
        require(transferable);
      }
      _;
    }

    /**
        CONSTRUCTOR
    **/

    /**
      @dev Constructor function executed on contract creation
    **/
    function TaylorToken()
      Ownable()
      public
    {
      balances[owner] = balances[owner].add(totalSupply);
      whitelistedTransfer[msg.sender] = true;
      whitelistedBurn[msg.sender] = true;
      Transfer(address(0),owner, totalSupply);
    }

    /**
        OWNER ONLY FUNCTIONS
    **/

    /**
      @dev Activates the trasfer for all users
    **/
    function activateTransfers()
      public
      onlyOwner
    {
      transferable = true;
    }

    /**
      @dev Allows the owner to add addresse that can bypass the
      transfer lock. Eg: ICO contract, TGE contract.
      @param _address address Address to be added
    **/
    function addWhitelistedTransfer(address _address)
      public
      onlyOwner
    {
      whitelistedTransfer[_address] = true;
    }

    /**
      @dev Sends all avaible TAY to the TGE contract to be properly
      distribute
      @param _tgeAddress address Address of the token distribution
      contract
    **/
    function distribute(address _tgeAddress)
      public
      onlyOwner
    {
      whitelistedTransfer[_tgeAddress] = true;
      transfer(_tgeAddress, balances[owner]);
    }


    /**
      @dev Allows the owner to add addresse that can burn tokens
      Eg: ICO contract, TGE contract.
      @param _address address Address to be added
    **/
    function addWhitelistedBurn(address _address)
      public
      onlyOwner
    {
      whitelistedBurn[_address] = true;
    }

    /**
        PUBLIC FUNCTIONS
    **/

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value)
      public
      onlyWhenTransferable
      returns (bool success)
    {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);

      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }

    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom
      (address _from,
        address _to,
        uint256 _value)
        public
        onlyWhenTransferable
        returns (bool success) {
      require(_to != address(0));
      require(_value <= balances[_from]);
      require(_value <= allowed[_from][msg.sender]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }

    /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    For security reasons, if one need to change the value from a existing allowance, it must furst sets
    it to zero and then sets the new value

   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value)
      public
      onlyWhenTransferable
      returns (bool success)
    {
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
    }

      /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue)
      public
      returns (bool)
    {
      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue)
      public
      returns (bool)
    {
      uint oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
      } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
    }

    /**
      @dev Allows for msg.sender to burn his on tokens
      @param _amount uint256 The amount of tokens to be burned
    **/
    function burn(uint256 _amount)
      public
      returns (bool success)
    {
      require(whitelistedBurn[msg.sender]);
      require(_amount <= balances[msg.sender]);
      balances[msg.sender] = balances[msg.sender].sub(_amount);
      totalSupply =  totalSupply.sub(_amount);
      Burn(msg.sender, _amount);
      return true;
    }


    /**
        CONSTANT FUNCTIONS
    **/

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(address _owner, address _spender)
      view
      public
      returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
  @title Crowdsale

**/
contract Crowdsale is Ownable, Pausable {

  using SafeMath for uint256;

  /**
      EVENTS
  **/
  event Purchase(address indexed buyer, uint256 weiAmount, uint256 tokenAmount);
  event Finalized(uint256 tokensSold, uint256 weiAmount);

  /**
      CONTRACT VARIABLES
  **/
  TaylorToken public taylorToken;

  uint256 public startTime;
  uint256 public endTime;
  uint256 public weiRaised;
  uint256 public tokensSold;
  uint256 public tokenCap;
  uint256 public poolEthSold;
  bool public finalized;
  address public wallet;

  uint256 public maxGasPrice = 50000000000;

  uint256[4] public rates;

  mapping (address => bool) public whitelisted;
  mapping (address => bool) public whitelistedPools;
  mapping (address => uint256) public contributors;

  /**
      PUBLIC CONSTANTS
  **/
  uint256 public constant poolEthCap = 1250 ether;
  uint256 public constant minimumPoolPurchase = 100 ether;
  uint256 public constant minimumPurchase = 0.01 ether;
  uint256 public constant maximumPoolPurchase = 250 ether;
  uint256 public constant maximumPurchase = 50 ether;
  uint256 public constant specialPoolsRate = 600000000000000;



  /**
      CONSTRUCTOR
  **/

  /**
    @dev ICO CONSTRUCTOR
    @param _startTime uint256 timestamp that the sale will begin
    @param _duration uint256  how long(in days) the sale will last
    @param _tokenCap uint256 How many tokens will be sold sale
    @param _token address the address of the token contract
    @param _wallet address the address of the wallet that will recieve funds
  **/
  function Crowdsale(
    uint256 _startTime,
    uint256 _duration,
    uint256 _tokenCap,
    address _token,
    address _wallet)
    public
  {
    require(_startTime >= now);
    require(_token != address(0));
    require(_wallet != address(0));

    taylorToken = TaylorToken(_token);

    startTime = _startTime;
    endTime = startTime + _duration * 1 seconds ;
    wallet = _wallet;
    tokenCap = _tokenCap;
    rates = [700000000000000, 790000000000000, 860000000000000, 930000000000000];
  }


  /**
      PUBLIC FUNCTIONS

  **/

  /**
    @dev Fallback function that accepts eth and buy tokens
  **/
  function () payable whenNotPaused public {
    buyTokens();
  }

  /**
    @dev Allows participants to buy tokens
  **/
  function buyTokens() payable whenNotPaused public {
    require(isValidPurchase());

    uint256 tokens;
    uint256 amount = msg.value;


    if(whitelistedPools[msg.sender] && poolEthSold.add(amount) > poolEthCap){
      uint256 validAmount = poolEthCap.sub(poolEthSold);
      require(validAmount > 0);
      uint256 ch = amount.sub(validAmount);
      msg.sender.transfer(ch);
      amount = validAmount;
    }

    tokens  = calculateTokenAmount(amount);


    uint256 tokenPool = tokensSold.add(tokens);
    if(tokenPool > tokenCap){
      uint256 possibleTokens = tokenCap.sub(tokensSold);
      uint256 change = calculatePriceForTokens(tokens.sub(possibleTokens));
      msg.sender.transfer(change);
      tokens = possibleTokens;
      amount = amount.sub(change);
    }



    contributors[msg.sender] = contributors[msg.sender].add(amount);
    taylorToken.transfer(msg.sender, tokens);

    tokensSold = tokensSold.add(tokens);
    weiRaised = weiRaised.add(amount);
    if(whitelistedPools[msg.sender]){
      poolEthSold = poolEthSold.add(amount);
    }


    forwardFunds(amount);
    Purchase(msg.sender, amount, tokens);

    if(tokenCap.sub(tokensSold) < calculateTokenAmount(minimumPurchase)){
      finalizeSale();
    }
  }

  /**
    @dev Allows owner to add addresses to the whitelisted
    @param _address address The address to be added
    @param isPool bool Indicating if address represents a buying pool
  **/
  function addWhitelisted(address _address, bool isPool)
    public
    onlyOwner
    whenNotPaused
  {
    if(isPool) {
      whitelistedPools[_address] = true;
    } else {
      whitelisted[_address] = true;
    }
  }

  /**
    @dev allows the owner to change the max gas price
    @param _gasPrice uint256 the new maximum gas price
  **/
  function changeMaxGasprice(uint256 _gasPrice)
    public
    onlyOwner
    whenNotPaused
  {
    maxGasPrice = _gasPrice;
  }

  /**
    @dev Triggers the finalization process
  **/
  function endSale() whenNotPaused public {
    require(finalized ==  false);
    require(now > endTime);
    finalizeSale();
  }

  /**
      INTERNAL FUNCTIONS

  **/

  /**
    @dev Checks if purchase is valid
    @return Bool Indicating if purchase is valid
  **/
  function isValidPurchase() view internal returns(bool valid) {
    require(now >= startTime && now <= endTime);
    require(msg.value >= minimumPurchase);
    require(tx.gasprice <= maxGasPrice);
    uint256 week = getCurrentWeek();
    if(week == 0 && whitelistedPools[msg.sender]){
      require(msg.value >= minimumPoolPurchase);
      require(contributors[msg.sender].add(msg.value) <= maximumPoolPurchase);
    } else {
      require(whitelisted[msg.sender] || whitelistedPools[msg.sender]);
      require(contributors[msg.sender].add(msg.value) <= maximumPurchase);
    }
    return true;
  }



  /**
    @dev Internal function that redirects recieved funds to wallet
    @param _amount uint256 The amount to be fowarded
  **/
  function forwardFunds(uint256 _amount) internal {
    wallet.transfer(_amount);
  }

  /**
    @dev Calculates the amount of tokens that buyer will recieve
    @param weiAmount uint256 The amount, in Wei, that will be bought
    @return uint256 Representing the amount of tokens that weiAmount buys in
    the current stage of the sale
  **/
  function calculateTokenAmount(uint256 weiAmount) view internal returns(uint256 tokenAmount){
    uint256 week = getCurrentWeek();
    if(week == 0 && whitelistedPools[msg.sender]){
      return weiAmount.mul(10**18).div(specialPoolsRate);
    }
    return weiAmount.mul(10**18).div(rates[week]);
  }

  /**
    @dev Calculates wei cost of specific amount of tokens
    @param tokenAmount uint256 The amount of tokens to be calculated
    @return uint256 Representing the total cost, in wei, for tokenAmount
  **/
  function calculatePriceForTokens(uint256 tokenAmount) view internal returns(uint256 weiAmount){
    uint256 week = getCurrentWeek();
    return tokenAmount.div(10**18).mul(rates[week]);
  }

  /**
    @dev Checks the current week in the sale. It's zero indexed, so the first
    week returns 0, the sencond 1, and so forth.
    @return Uint representing the current week
  **/
  function getCurrentWeek() view internal returns(uint256 _week){
    uint256 week = (now.sub(startTime)).div(1 weeks);
    if(week > 3){
      week = 3;
    }
    return week;
  }

  /**
    @dev Triggers the sale finalizations process
  **/
  function finalizeSale() internal {
    taylorToken.burn(taylorToken.balanceOf(this));
    finalized = true;
    Finalized(tokensSold, weiRaised);
  }

  /**
      READ ONLY FUNCTIONS

  **/

  /**
    @dev Give the current rate(in Wei) that buys exactly one token
  **/
  function getCurrentRate() view public returns(uint256 _rate){
    return rates[getCurrentWeek()];
  }


}