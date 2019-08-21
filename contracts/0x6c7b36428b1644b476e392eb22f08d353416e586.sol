pragma solidity ^0.4.18;

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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


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
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract GUT is Ownable, MintableToken {
  using SafeMath for uint256;    
  string public constant name = "Geekz Utility Token";
  string public constant symbol = "GUT";
  uint32 public constant decimals = 18;

  address public addressTeam;
  address public addressReserveFund;

  uint public summTeam = 4000000 * 1 ether;
  uint public summReserveFund = 1000000 * 1 ether;

  function GUT() public {
    addressTeam = 0x142c0dba7449ceae2Dc0A5ce048D65b690630274;  //set your value
    addressReserveFund = 0xc709565D92a6B9a913f4d53de730712e78fe5B8C; //set your value

    //Founders and supporters initial Allocations
    balances[addressTeam] = balances[addressTeam].add(summTeam);
    balances[addressReserveFund] = balances[addressReserveFund].add(summReserveFund);

    totalSupply = summTeam.add(summReserveFund);
  }
  function getTotalSupply() public constant returns(uint256){
      return totalSupply;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where Contributors can make
 * token Contributions and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive. The contract requires a MintableToken that will be
 * minted as contributions arrive, note that the crowdsale contract
 * must be owner of the token in order to be able to mint it.
 */
contract Crowdsale is Ownable {
  using SafeMath for uint256;
  // totalTokens
  uint256 public totalTokens;
  // soft cap
  uint softcap;
  // balances for softcap
  mapping(address => uint) public balances;
  // The token being offered
  GUT public token;
  // start and end timestamps where investments are allowed (both inclusive)
  
  //Early stage
    //start
  uint256 public startEarlyStage1;
  uint256 public startEarlyStage2;
  uint256 public startEarlyStage3;
  uint256 public startEarlyStage4;
    //end
  uint256 public endEarlyStage1;
  uint256 public endEarlyStage2;
  uint256 public endEarlyStage3;
  uint256 public endEarlyStage4;   
  
  //Final stage
    //start
  uint256 public startFinalStage1;
  uint256 public startFinalStage2;
    //end 
  uint256 public endFinalStage1;    
  uint256 public endFinalStage2;  
  
  //token distribution
  uint256 public maxEarlyStage;
  uint256 public maxFinalStage;

  uint256 public totalEarlyStage;
  uint256 public totalFinalStage;
  
  // how many token units a Contributor gets per wei
  uint256 public rateEarlyStage1;
  uint256 public rateEarlyStage2;
  uint256 public rateEarlyStage3;
  uint256 public rateEarlyStage4;
  uint256 public rateFinalStage1;
  uint256 public rateFinalStage2;   
  
  // Remaining Token Allocation 
  // (after completion of all stages of crowdfunding)
  uint public mintStart; //31 Mar 2018 08:00:00 GMT

  // address where funds are collected
  address public wallet;

  // minimum quantity values
  uint256 public minQuanValues; 

/**
* event for token Procurement logging
* @param contributor who Pledged for the tokens
* @param beneficiary who got the tokens
* @param value weis Contributed for Procurement
* @param amount amount of tokens Procured
*/
  event TokenProcurement(address indexed contributor, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale() public {
    token = createTokenContract();
    // total number of tokens
    totalTokens = 25000000 * 1 ether;
    //soft cap
    softcap = 400 * 1 ether;   
    // minimum quantity values
    minQuanValues = 100000000000000000; //0.1 eth
    // start and end timestamps where investments are allowed
    //Early stage
      //start
    startEarlyStage1 = 1519804800;//28 Feb 2018 08:00:00 GMT
    startEarlyStage2 = startEarlyStage1 + 2 * 1 days;
    startEarlyStage3 = startEarlyStage2 + 2 * 1 days;
    startEarlyStage4 = startEarlyStage3 + 2 * 1 days;
      //end
    endEarlyStage1 = startEarlyStage1 + 2 * 1 days;
    endEarlyStage2 = startEarlyStage2 + 2 * 1 days;
    endEarlyStage3 = startEarlyStage3 + 2 * 1 days;
    endEarlyStage4 = startEarlyStage4 + 2 * 1 days;   
    //Final stage
      //start
    startFinalStage1 = 1520582400;//09 Mar 2018 08:00:00 GMT
    startFinalStage2 = startFinalStage1 + 6 * 1 days;
      //end 
    endFinalStage1 = startFinalStage1 + 6 * 1 days;    
    endFinalStage2 = startFinalStage2 + 16 * 1 days;         
    // restrictions on amounts during the crowdfunding event stages
    maxEarlyStage = 4000000 * 1 ether;
    maxFinalStage = 16000000 * 1 ether;
    // rate;
    rateEarlyStage1 = 10000;
    rateEarlyStage2 = 7500;
    rateEarlyStage3 = 5000;
    rateEarlyStage4 = 4000;
    rateFinalStage1 = 3000;
    rateFinalStage2 = 2000; 
    // Remaining Token Allocation 
    // (after completion of all stages of crowdfunding event)
    mintStart = endFinalStage2; //31 Mar 2018 08:00:00 GMT
    // address where funds are collected
    wallet = 0x80B48F46CD1857da32dB10fa54E85a2F18B96412;
  }

  
  function setRateEarlyStage1(uint _rateEarlyStage1) public {
    rateEarlyStage1 = _rateEarlyStage1;
  }
  function setRateEarlyStage2(uint _rateEarlyStage2) public {
    rateEarlyStage2 = _rateEarlyStage2;
  }  
  function setRateEarlyStage3(uint _rateEarlyStage3) public {
    rateEarlyStage3 = _rateEarlyStage3;
  }  
  function setRateEarlyStage4(uint _rateEarlyStage4) public {
    rateEarlyStage4 = _rateEarlyStage4;
  }  
  
  function setRateFinalStage1(uint _rateFinalStage1) public {
    rateFinalStage1 = _rateFinalStage1;
  }  
  function setRateFinalStage2(uint _rateFinalStage2) public {
    rateFinalStage2 = _rateFinalStage2;
  }   
  
  function createTokenContract() internal returns (GUT) {
    return new GUT();
  }

  // fallback function can be used to Procure tokens
  function () external payable {
    procureTokens(msg.sender);
  }

  // low level token Pledge function
  function procureTokens(address beneficiary) public payable {
    uint256 tokens;
    uint256 weiAmount = msg.value;
    uint256 backAmount;
    require(beneficiary != address(0));
    //minimum amount in ETH
    require(weiAmount >= minQuanValues);
    //EarlyStage1
    if (now >= startEarlyStage1 && now < endEarlyStage1 && totalEarlyStage < maxEarlyStage){
      tokens = weiAmount.mul(rateEarlyStage1);
      if (maxEarlyStage.sub(totalEarlyStage) < tokens){
        tokens = maxEarlyStage.sub(totalEarlyStage); 
        weiAmount = tokens.div(rateEarlyStage1);
        backAmount = msg.value.sub(weiAmount);
      }
      totalEarlyStage = totalEarlyStage.add(tokens);
    }
    //EarlyStage2
    if (now >= startEarlyStage2 && now < endEarlyStage2 && totalEarlyStage < maxEarlyStage){
      tokens = weiAmount.mul(rateEarlyStage2);
      if (maxEarlyStage.sub(totalEarlyStage) < tokens){
        tokens = maxEarlyStage.sub(totalEarlyStage); 
        weiAmount = tokens.div(rateEarlyStage2);
        backAmount = msg.value.sub(weiAmount);
      }
      totalEarlyStage = totalEarlyStage.add(tokens);
    }    
    //EarlyStage3
    if (now >= startEarlyStage3 && now < endEarlyStage3 && totalEarlyStage < maxEarlyStage){
      tokens = weiAmount.mul(rateEarlyStage3);
      if (maxEarlyStage.sub(totalEarlyStage) < tokens){
        tokens = maxEarlyStage.sub(totalEarlyStage); 
        weiAmount = tokens.div(rateEarlyStage3);
        backAmount = msg.value.sub(weiAmount);
      }
      totalEarlyStage = totalEarlyStage.add(tokens);
    }    
    //EarlyStage4
    if (now >= startEarlyStage4 && now < endEarlyStage4 && totalEarlyStage < maxEarlyStage){
      tokens = weiAmount.mul(rateEarlyStage4);
      if (maxEarlyStage.sub(totalEarlyStage) < tokens){
        tokens = maxEarlyStage.sub(totalEarlyStage); 
        weiAmount = tokens.div(rateEarlyStage4);
        backAmount = msg.value.sub(weiAmount);
      }
      totalEarlyStage = totalEarlyStage.add(tokens);
    }   
    //FinalStage1
    if (now >= startFinalStage1 && now < endFinalStage1 && totalFinalStage < maxFinalStage){
      tokens = weiAmount.mul(rateFinalStage1);
      if (maxFinalStage.sub(totalFinalStage) < tokens){
        tokens = maxFinalStage.sub(totalFinalStage); 
        weiAmount = tokens.div(rateFinalStage1);
        backAmount = msg.value.sub(weiAmount);
      }
      totalFinalStage = totalFinalStage.add(tokens);
    }       
    //FinalStage2    
    if (now >= startFinalStage2 && now < endFinalStage2 && totalFinalStage < maxFinalStage){
      tokens = weiAmount.mul(rateFinalStage2);
      if (maxFinalStage.sub(totalFinalStage) < tokens){
        tokens = maxFinalStage.sub(totalFinalStage); 
        weiAmount = tokens.div(rateFinalStage2);
        backAmount = msg.value.sub(weiAmount);
      }
      totalFinalStage = totalFinalStage.add(tokens);
    }        
    
    require(tokens > 0);
    token.mint(beneficiary, tokens);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    //wallet.transfer(weiAmount);
    
    if (backAmount > 0){
      msg.sender.transfer(backAmount);    
    }
    TokenProcurement(msg.sender, beneficiary, weiAmount, tokens);
  }

  //Mint is allowed while TotalSupply <= totalTokens
  function mintTokens(address _to, uint256 _amount) onlyOwner public returns (bool) {
    require(_amount > 0);
    require(_to != address(0));
    require(now >= mintStart);
    require(_amount <= totalTokens.sub(token.getTotalSupply()));
    token.mint(_to, _amount);
    return true;
  }
  
  function refund() public{
    require(this.balance < softcap && now > endFinalStage2);
    require(balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
  }
  
  function transferToMultisig() public onlyOwner {
    require(this.balance >= softcap && now > endFinalStage2);  
      wallet.transfer(this.balance);
  }  
}