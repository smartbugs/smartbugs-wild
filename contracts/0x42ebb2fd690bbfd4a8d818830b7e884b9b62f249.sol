pragma solidity ^0.4.18;

contract AbstractTRMBalances {
    mapping(address => bool) public oldBalances;
}


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
    //Mint(_to, _amount);
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

contract TRM2TokenCoin is MintableToken {
    
    string public constant name = "TerraMiner";
    
    string public constant symbol = "TRM2";
    
    uint32 public constant decimals = 8;
    
}



contract Crowdsale is Ownable, AbstractTRMBalances {
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    
    using SafeMath for uint;
    
    uint public ETHUSD;
    
    address multisig;
    
    address manager;

    TRM2TokenCoin public token = new TRM2TokenCoin();

    uint public startPreSale;
    uint public endPreSale;
    
    uint public startPreICO;
    uint public endPreICO;
    
    uint public startICO;
    uint public endICO;
    
    uint public startPostICO;
    uint public endPostICO;    
    
    uint hardcap;
    
    bool pause;
    
    AbstractTRMBalances oldBalancesP1;
    AbstractTRMBalances oldBalancesP2;   
    

    function Crowdsale() {
        //кошелек на который зачисляются средства
        multisig = 0xc2CDcE18deEcC1d5274D882aEd0FB082B813FFE8;
        //адрес кошелька управляющего контрактом
        manager = 0xf5c723B7Cc90eaA3bEec7B05D6bbeBCd9AFAA69a;
        //курс эфира к токенам 
        ETHUSD = 70000;
        
        //время   
        startPreSale = now;
        endPreSale = 1515974400; //Mon, 15 Jan 2018 00:00:00 GMT
        
        startPreICO = 1514332800; // Wed, 27 Dec 2017 00:00:00 GMT
        endPreICO = 1517443200; // Thu, 01 Feb 2018 00:00:00 GMT

        startICO = 1517443200; // Thu, 01 Feb 2018 00:00:00 GMT
        endICO = 1519862400; // Thu, 01 Mar 2018 00:00:00 GMT
        
        startPostICO = 1519862400; // Thu, 01 Mar 2018 00:00:00 GMT
        endPostICO = 1522540800; // Sun, 01 Apr 2018 00:00:00 GMT
		
        //максимальное число сбора в токенах
        hardcap = 250000000 * 100000000;
        //пауза  
        pause = false;
        
        oldBalancesP1 = AbstractTRMBalances(0xfcc6C3C19dcD67c282fFE27Ea79F1181693dA194);
        oldBalancesP2 = AbstractTRMBalances(0x4B7a1c77323c1e2ED6BcE44152b30092CAA9B1D3);
    }

    modifier saleIsOn() {
        require((now >= startPreSale && now < endPreSale) || (now >= startPreICO && now < endPreICO) || (now >= startICO && now < endICO) || (now >= startPostICO && now < endPostICO));
    	require(pause!=true);
    	_;
    }
	
    modifier isUnderHardCap() {
        require(token.totalSupply() < hardcap);
        _;
    }

    function finishMinting() public {
        require(msg.sender == manager);
        token.finishMinting();
        token.transferOwnership(manager);
    }

    function createTokens() isUnderHardCap saleIsOn payable {

        uint256 sum = msg.value;
        uint256 sumUSD = msg.value.mul(ETHUSD).div(100);

       //require(msg.value > 0);
        require(sumUSD.div(1000000000000000000) > 100);
        
        uint256 totalSupply = token.totalSupply();
        
        uint256 numTokens = 0;
        
        uint256 tokenRest = 0;
        uint256 tokenPrice = 8 * 1000000000000000000;
        
        
        //PreSale
        //------------------------------------
        if( (now >= startPreSale && now < endPreSale ) && ((oldBalancesP1.oldBalances(msg.sender) == true)||(oldBalancesP2.oldBalances(msg.sender) == true)) ){
            
            tokenPrice = 35 * 100000000000000000; 

            numTokens = sumUSD.mul(100000000).div(tokenPrice);
            
        } else {
            //------------------------------------
            
            //PreICO
            //------------------------------------
            if(now >= startPreICO && now < endPreICO){
                
                tokenPrice = 7 ether; 
                if(sum >= 151 ether){
                   tokenPrice = 35 * 100000000000000000;
                } else if(sum >= 66 ether){
                   tokenPrice = 40 * 100000000000000000;
                } else if(sum >= 10 ether){
                   tokenPrice = 45 * 100000000000000000;
                } else if(sum >= 5 ether){
                   tokenPrice = 50 * 100000000000000000;
                }
                
                numTokens = sumUSD.mul(100000000).div(tokenPrice);
                
            }
            //------------------------------------        
            
            //ICO
            //------------------------------------
            if(now >= startICO && now < endICO){
                
                tokenPrice = 7 ether; 
                if(sum >= 151 ether){
                   tokenPrice = 40 * 100000000000000000;
                } else if(sum >= 66 ether){
                   tokenPrice = 50 * 100000000000000000;
                } else if(sum >= 10 ether){
                   tokenPrice = 55 * 100000000000000000;
                } else if(sum >= 5 ether){
                   tokenPrice = 60 * 100000000000000000;
                } 
                
                numTokens = sumUSD.mul(100000000).div(tokenPrice);
                
            }
            //------------------------------------
            
            //PostICO
            //------------------------------------
            if(now >= startPostICO && now < endPostICO){
                
                tokenPrice = 8 ether; 
                if(sum >= 151 ether){
                   tokenPrice = 45 * 100000000000000000;
                } else if(sum >= 66 ether){
                   tokenPrice = 55 * 100000000000000000;
                } else if(sum >= 10 ether){
                   tokenPrice = 60 * 100000000000000000;
                } else if(sum >= 5 ether){
                   tokenPrice = 65 * 100000000000000000;
                } 
                
                numTokens = sumUSD.mul(100000000).div(tokenPrice);
                
            }
            //------------------------------------  
        }

        require(msg.value > 0);
        require(numTokens > 0);
        
        tokenRest = hardcap.sub(totalSupply);
        require(tokenRest >= numTokens);
        
        token.mint(msg.sender, numTokens);
        multisig.transfer(msg.value);
        
        NewContribution(msg.sender, numTokens, msg.value);
        
        
    }

    function() external payable {
        createTokens();
    }

    function mint(address _to, uint _value) {
        require(msg.sender == manager);
        uint256 tokenRest = hardcap.sub(token.totalSupply());
        require(tokenRest > 0);
        if(_value > tokenRest)
            _value = tokenRest;
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