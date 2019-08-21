pragma solidity ^0.4.19;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  uint256 totalRecycledTokens_; 

  bool public paused = false; 

  bool public tgeMode = false;

  address public ceoAddress;

  address public marketplaceAddress;


  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  modifier whenNotPaused() { 
        require(!paused);
        _;
  }
  
  modifier whenPaused() { 
        require(paused);
        _;
  }

  modifier onlyCEO() {
      require(msg.sender == ceoAddress);
      _;  
  }

  function pause() public onlyCEO() whenNotPaused() {
      paused = true;
  }

  function unpause() public onlyCEO() whenPaused() {
      paused = false;
  }

  modifier inTGE() {
      require(tgeMode);
      _;  
  }

  modifier afterTGE() {
      require(!tgeMode);
      _;  
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public whenNotPaused() returns (bool) {
    require( !tgeMode || (msg.sender == ceoAddress) ); 
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


contract ExoToken is ERC20, BasicToken {

  string public name = "ExoToken";

  string public symbol = "EXT"; 

  uint8 public decimals = 18;

  uint256 public MaxNumTokens = 175000000000000000000000000;
  
  uint256 private priceOfToken;


  mapping (address => mapping (address => uint256)) internal allowed;

  mapping(address => bool) private tgeUserMap;
  address[] private tgeUserList;

  event Mint(address _to, uint256 _amount);
  event RecycleTokens(uint256 value);


  uint32 public bonusFactor_1 = 5; 
  uint32 public bonusFactor_2 = 10;
  uint32 public bonusFactor_3 = 20;


  function setBonusFactors(uint32 factor_1, uint32 factor_2, uint32 factor_3) public onlyCEO() inTGE() {
    bonusFactor_1 = factor_1;
    bonusFactor_2 = factor_2;
    bonusFactor_3 = factor_3;
  }

  /*** CONSTRUCTOR ***/
  function ExoToken(uint256 initialSupply, uint256 initialPriceOfToken) public {  
    // set initialSupply to e.g. 82,250,000
    require(initialPriceOfToken > 0);
    ceoAddress = msg.sender;
    marketplaceAddress = msg.sender;
    priceOfToken = initialPriceOfToken; 
    balances[msg.sender] = initialSupply;
    totalSupply_ = initialSupply;
  }


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused() afterTGE() returns (bool) {
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
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public whenNotPaused() afterTGE() returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) whenNotPaused() public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function setPriceOfToken(uint256 newPriceOfToken) public onlyCEO() {
    require(newPriceOfToken > 0);
    priceOfToken = newPriceOfToken;
  }

  function getPriceOfToken() public view returns(uint256) {
    return priceOfToken;
  }

  function getNumRecycledTokens() public view returns(uint256) {
    return totalRecycledTokens_;
  }
  

  function recycleTokensForPayment(uint256 numTokens, uint256 payment) public onlyCEO() { 
    require(payment <= this.balance); 
    recycleTokens(numTokens); 
    ceoAddress.transfer(payment);
  }
  

  function recycleTokens(uint256 numTokens) public onlyCEO() { 
    // allow more tokens to be minted
    require(numTokens <= balances[ceoAddress]);

    totalSupply_ = totalSupply_.sub(numTokens);
    balances[ceoAddress] = balances[ceoAddress].sub(numTokens);
    totalRecycledTokens_ = totalRecycledTokens_.add(numTokens);
    RecycleTokens(numTokens);
  }


  uint256 public firstBonusStep = 1 ether;
  uint256 public secondBonusStep = 5 ether;
  uint256 public thirdBonusStep = 10 ether;

  function setBonusSteps(uint256 step_1, uint256 step_2, uint256 step_3) public onlyCEO() inTGE() {
    firstBonusStep = step_1;
    secondBonusStep = step_2;
    thirdBonusStep = step_3;
  }



  function purchase() public payable whenNotPaused() inTGE() {
    /// when in TGE - buy tokens (from CEO account) for ETH

    uint256 amount = msg.value.div(priceOfToken);
    require(amount > 0);
        
    if (tgeUserMap[ msg.sender] == false) { // In Solidity, mapping will return the default value for each key type
      tgeUserMap[ msg.sender] = true;
      tgeUserList.push( msg.sender);
    }

    uint bonusFactor;
    if (msg.value < firstBonusStep) {
      bonusFactor = 100; // no bonus  
    } else if (msg.value < secondBonusStep) {
      bonusFactor = 100 + bonusFactor_1;
    } else if (msg.value < thirdBonusStep) {
      bonusFactor = 100 + bonusFactor_2;
    } else {
      bonusFactor = 100 + bonusFactor_3;
    }
    
    amount = amount.mul(bonusFactor).div(100);
    amount = amount.mul(1000000000000000000);
    
     /// mint requested amount of tokens
    
    doMint(msg.sender, amount);

    /// Transfer tokens from ceo to msg.sender
    // require(amount <= balances[ceoAddress]); 
    // balances[ceoAddress] = balances[ceoAddress].sub(amount);
    // balances[msg.sender] = balances[msg.sender].add(amount);
    // Transfer(ceoAddress, msg.sender, amount);
  }


 /// mint function - either by CEO or from site
 function mintTokens(address buyerAddress, uint256 amount) public whenNotPaused() returns (bool) {  
    require(msg.sender == marketplaceAddress || msg.sender == ceoAddress); 
    return doMint(buyerAddress, amount);
  }

 function doMint(address buyerAddress, uint256 amount) private whenNotPaused() returns (bool) {
    require( totalSupply_.add(amount) <= MaxNumTokens);
    totalSupply_ = totalSupply_.add(amount);
    balances[buyerAddress] = balances[buyerAddress].add(amount);
    Mint(buyerAddress, amount);
    return true;
  }

  

  function getNumTGEUsers() public view returns (uint256) {
      return tgeUserList.length;
  }

  function getTGEUser( uint32 ind) public view returns (address) {
      return tgeUserList[ind];
  }


  function payout() public onlyCEO {
      ceoAddress.transfer(this.balance);
  }

  function payoutPartial(uint256 amount) public onlyCEO {
      require(amount <= this.balance);
      ceoAddress.transfer(amount);  
  }

  function setTGEMode(bool newMode) public onlyCEO {
      tgeMode = newMode;
  }

  function setCEO(address newCEO) public onlyCEO {
      require(newCEO != address(0));
      uint256 ceoTokens = balances[ceoAddress];
      balances[ceoAddress] = 0;
      balances[newCEO] = balances[newCEO].add(ceoTokens);
      ceoAddress = newCEO; 
  }

  function setMarketplaceAddress(address newMarketplace) public onlyCEO {
    marketplaceAddress = newMarketplace;
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
  function increaseApproval(address _spender, uint _addedValue) whenNotPaused() public returns (bool) {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
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
  function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused() public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
        return 0;
      }
      uint256 c = a * b;
      assert(c / a == b);
      return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}