pragma solidity ^0.4.13;

/**
 * @title FornicoinCrowdsale
 * The Crowdsale contract for the Fornicoin Project.
 * Read more at fornicoin.network
 * <info (at) fornicoin.network>
 */


 /*
 * This is the smart contract for the Fornicoin token.
 * More information can be found on our website at: https://fornicoin.network
 * Created by the Fornicoin Team <info@fornicoin.network>
 */

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
  function transfer(address _to, uint _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
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
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
    /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

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
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
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

}



 /*
 * This is the smart contract for the Fornicoin token.
 * More information can be found on our website at: https://fornicoin.network
 * Created by the Fornicoin Team <info@fornicoin.network>
 */

contract FornicoinToken is StandardToken, Ownable {
  using SafeMath for uint256;

  string public constant name = "Fornicoin";
  string public constant symbol = "FXX";
  uint8 public constant decimals = 18;

  // 100 000 000 Fornicoin tokens created
  uint256 public constant MAX_SUPPLY = 100000000 * (10 ** uint256(decimals));
  
  // admin address for team functions
  address public admin;
  uint256 public teamTokens = 25000000 * (10 ** 18);
  
  // Top up gas balance
  uint256 public minBalanceForTxFee = 55000 * 3 * 10 ** 9 wei; // == 55000 gas @ 3 gwei
  // 800 FXX per ETH as the gas generation price
  uint256 public sellPrice = 800; 
  
  event Refill(uint256 amount);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function FornicoinToken(address _admin) {
    totalSupply = teamTokens;
    balances[msg.sender] = MAX_SUPPLY;
    admin =_admin;
  }
  
  function setSellPrice(uint256 _price) public onlyAdmin {
      require(_price >= 0);
      // FXX can only become stronger
      require(_price <= sellPrice);
      
      sellPrice = _price;
  }
  
  // Update state of contract showing tokens bought
  function updateTotalSupply(uint256 additions) onlyOwner {
      require(totalSupply.add(additions) <= MAX_SUPPLY);
      totalSupply += additions;
  }
  
  function setMinTxFee(uint256 _balance) public onlyAdmin {
      require(_balance >= 0);
      // can only add more eth
      require(_balance > minBalanceForTxFee);
      
      minBalanceForTxFee = _balance;
  }
  
  function refillTxFeeMinimum() public payable onlyAdmin {
      Refill(msg.value);
  }
  
  // Transfers FXX tokens to another address
  // Utilises transaction fee obfuscation
  function transfer(address _to, uint _value) public returns (bool) {
        // Prevent transfer to 0x0 address
        require (_to != 0x0);
        // Check for overflows 
        require (balanceOf(_to) + _value > balanceOf(_to));
        // Determine if account has necessary funding for another tx
        if(msg.sender.balance < minBalanceForTxFee && 
        balances[msg.sender].sub(_value) >= minBalanceForTxFee * sellPrice && 
        this.balance >= minBalanceForTxFee){
            sellFXX((minBalanceForTxFee.sub(msg.sender.balance)) *                                 
                             sellPrice);
    	        }
        // Subtract from the sender
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // Add the same to the recipient                   
        balances[_to] = balances[_to].add(_value); 
        // Send out Transfer event to notify all parties
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // Sells the amount of FXX to refill the senders ETH balance for another transaction
    function sellFXX(uint amount) internal returns (uint revenue){
        // checks if the sender has enough to sell
        require(balanceOf(msg.sender) >= amount);  
        // adds the amount to owner's balance       
        balances[admin] = balances[admin].add(amount);          
        // subtracts the amount from seller's balance              
        balances[msg.sender] = balances[msg.sender].sub(amount);   
        // Determines amount of ether to send to the seller 
        revenue = amount / sellPrice;
        msg.sender.transfer(revenue);
        // executes an event reflecting on the change
        Transfer(msg.sender, this, amount); 
        // ends function and returns              
        return revenue;                                   
    }
}


/**
 * @title FornicoinCrowdsale
 * The Crowdsale contract for the Fornicoin Project.
 * Read more at fornicoin.network
 * <info (at) fornicoin.network>
 */
 
contract FornicoinCrowdsale {
  using SafeMath for uint256;

  // The token being sold
  FornicoinToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startICOPhaseOne;
  uint256 public startICOPhaseTwo;
  uint256 public startICOPhaseThree;
  uint256 public endICO;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public phaseOneRate = 1100;
  uint256 public phaseTwoRate = 1000;
  uint256 public phaseThreeRate = 850;

  // amount of raised money in wei
  uint256 public weiRaised;
  
  // admin address to halt contract
  address public admin;
  bool public haltSale;
  uint256 public teamTokens = 25000000 * (10 ** 18);
  bool public presaleDist = false;
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  
  function FornicoinCrowdsale(uint256 _startTime, address _wallet, address _admin) 
    public 
    {
    require(_startTime >= now);
    require(_wallet != 0x0);
    
    token = new FornicoinToken(_admin);
    startICOPhaseOne = _startTime;
    startICOPhaseTwo = startICOPhaseOne + 3 days;
    startICOPhaseThree = startICOPhaseTwo + 4 weeks;
    endICO = startICOPhaseThree + 15 days;
    wallet = _wallet;
    admin = _admin;
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

//   low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());
    require(!haltSale);

    uint256 weiAmount = msg.value;
    
    uint256 tokens;

    // calculate token amount to be created
    if (now <= startICOPhaseTwo) {
      tokens = weiAmount.mul(phaseOneRate);
    } else if (now < startICOPhaseThree){
      tokens = weiAmount.mul(phaseTwoRate);
    } else {
      tokens = weiAmount.mul(phaseThreeRate);
    }
    
    token.updateTotalSupply(tokens);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    if (this.balance > 1 ether){
      forwardFunds();
    }
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(this.balance);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startICOPhaseOne && now <= endICO;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  
  // @return currentRate of FXX tokens per ETH
  function currentRate() public constant returns (uint256) {
    if (now <= startICOPhaseTwo) {
      return phaseOneRate;
    } else if (now <= startICOPhaseThree){
      return phaseTwoRate;
    } else {
      return phaseThreeRate;
    }
  }
  
  // Withdraw team tokens after 1 year
  function withdrawTeamTokens() public onlyAdmin returns (bool) {
    require(now >= startICOPhaseOne + 1 years);

    token.transfer(wallet, teamTokens);
    return true;
  }
  
  function distPresale(address _presale, uint256 _tokens) public onlyAdmin {
      require(_tokens <= 13000000*10**18);
      require(!presaleDist);
      presaleDist = true;
      
      token.transfer(_presale, _tokens);
  }
  
  //sends any left over funds to the wallet
  function finalizeSale() public onlyAdmin {
      require(now > endICO);
      
      if (this.balance>0){
          wallet.transfer(this.balance);
      }
      if(token.totalSupply() < token.MAX_SUPPLY()){
          uint256 difference = token.MAX_SUPPLY().sub(token.totalSupply());
          token.transfer(wallet, difference);
          token.updateTotalSupply(difference);
      }
  }

}