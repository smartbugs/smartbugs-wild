pragma solidity ^0.4.13;
 

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
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
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
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
   * @return A uint256 specifing the amount of tokens still available for the spender.
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

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
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
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}

contract RomanovEmpireTokenCoin is MintableToken {
    
    string public constant name = " Romanov Empire Imperium Token";
    
    string public constant symbol = "REI";
    
    uint32 public constant decimals = 0;
    
}


contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    address multisig;
    
    address manager;

    uint restrictedPercent;

    address restricted;

    RomanovEmpireTokenCoin public token = new RomanovEmpireTokenCoin();

    uint start;

    uint preIcoEnd;
    
    //uint period;

    //uint hardcap;
    
    uint preICOhardcap;

    uint public ETHUSD;
    
    uint public hardcapUSD;
    
    uint public collectedFunds;
    
    bool pause;

    function Crowdsale() {
        //кошелек на который зачисляются средства
        multisig = 0x1e129862b37Fe605Ef2099022F497caab7Db194c;//msg.sender;
        //кошелек куда будет перечислен процент наших токенов
        restricted = 0x1e129862b37Fe605Ef2099022F497caab7Db194c;//msg.sender;
        //адрес кошелька управляющего контрактом
        manager = msg.sender;
        //процент, от проданных токенов, который мы оставляем себе 
        restrictedPercent = 1200;
        //курс эфира к токенам 
        ETHUSD = 70000;
        //время старта  
        start = now;
	//время завершения prICO
        preIcoEnd = 1546300800;//Tue, 01 Jan 2019 00:00:00 GMT
        //период ICO в минутах
        //period = 25;
        //максимальное число сбора в токенах на PreICO
        preICOhardcap = 42000;		
        //максимальное число сбора в токенах
        //hardcap = 42000;
        //максимальное число сбора в центах
        hardcapUSD = 500000000;
        //собрано средство в центах
        collectedFunds = 0;
        //пауза 
        pause = false;
    }

    modifier saleIsOn() {
    	require(now > start && now < preIcoEnd);
    	require(pause!=true);
    	_;
    }
	
    modifier isUnderHardCap() {
        require(token.totalSupply() < preICOhardcap);
        //если набран hardcapUSD
        require(collectedFunds < hardcapUSD);
        _;
    }

    function finishMinting() public {
        require(msg.sender == manager);
        
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(10000);
        token.mint(restricted, restrictedTokens);
        token.transferOwnership(restricted);
    }

    function createTokens() isUnderHardCap saleIsOn payable {

        require(msg.value > 0);
        
        uint256 totalSupply = token.totalSupply();
        
        uint256 numTokens = 0;
        uint256 summ1 = 1800000;
        uint256 summ2 = 3300000;
          
        uint256 price1 = 18000;
        uint256 price2 = 15000;
        uint256 price3 = 12000;
          
        uint256 usdValue = msg.value.mul(ETHUSD).div(1000000000000000000);
          
        uint256 spendMoney = 0; 
        
        uint256 tokenRest = 0;
        uint256 rest = 0;
        
          tokenRest = preICOhardcap.sub(totalSupply);
          require(tokenRest > 0);
            
          
          if(usdValue>summ2 && tokenRest > 200 ){
              numTokens = (usdValue.sub(summ2)).div(price3).add(200);
              if(numTokens > tokenRest)
                numTokens = tokenRest;              
              spendMoney = summ2.add((numTokens.sub(200)).mul(price3));
          }else if(usdValue>summ1 && tokenRest > 100 ) {
              numTokens = (usdValue.sub(summ1)).div(price2).add(100);
              if(numTokens > tokenRest)
                numTokens = tokenRest;
              spendMoney = summ1.add((numTokens.sub(100)).mul(price2));
          }else {
              numTokens = usdValue.div(price1);
              if(numTokens > tokenRest)
                numTokens = tokenRest;
              spendMoney = numTokens.mul(price1);
          }
    
          rest = (usdValue.sub(spendMoney)).mul(1000000000000000000).div(ETHUSD);
    
         msg.sender.transfer(rest);
         if(rest<msg.value){
            multisig.transfer(msg.value.sub(rest));
            collectedFunds = collectedFunds + msg.value.sub(rest).mul(ETHUSD).div(1000000000000000000); 
         }
         
          token.mint(msg.sender, numTokens);
          
        
        
    }

    function() external payable {
        createTokens();
    }

    function mint(address _to, uint _value) {
        require(msg.sender == manager);
        token.mint(_to, _value);   
    }    
    
    function setETHUSD( uint256 _newPrice ) {
        require(msg.sender == manager);
        ETHUSD = _newPrice;
    }    
    
    function setPause( bool _newPause ) {
        require(msg.sender == manager);
        pause = _newPause;
    } 
    
}