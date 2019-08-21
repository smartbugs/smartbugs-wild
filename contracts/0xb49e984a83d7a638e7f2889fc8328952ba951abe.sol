library SafeMath {
  function mul(uint256 a, uint256 b) constant public returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant public returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) constant public returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant public returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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
    if(msg.sender == owner){
      _;
    }
    else{
      revert();
    }
  }

}
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  using SafeMath for uint128;

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
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}


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
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    if(!mintingFinished){
      _;
    }
    else{
      revert();
    }
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0),_to,_amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract MON is MintableToken{
    
    event BuyStatus(uint256 status);
    struct Buy{
        uint128 amountOfEth;
        uint128 stage;
    }
    
    struct StageData{
        uint128 stageTime;
        uint64 stageSum;
        uint64 stagePrice;
    }
    
	string public constant name = "MillionCoin";
	string public constant symbol = "MON";
	uint256 public constant DECIMALS = 8;
	uint256 public constant decimals = 8;
	address public beneficiary ;
    uint256 private alreadyRunned 	= 0;
    uint256 internal _now =0;
    uint256 public stageIndex = 0;
    StageData[] public stageDataStore;
    uint256 public period = 3600*24; //1 day
    uint256 public start = 0;
    uint256 public sumMultiplayer = 100000;
    mapping(address => Buy) public stageBuys;
 
 modifier runOnce(uint256 bit){
     if((alreadyRunned & bit)==0){
        alreadyRunned = alreadyRunned | bit;   
         _;   
     }
     else{
         revert();
     }
 }
 
 
 function MON(address _benef,uint256 _start,uint256 _sumMul,uint256 _period) public{
     beneficiary = _benef;
     if(_start==0){
         start = GetNow();
     }
     else{
         start = _start;
     }
     if(_period!=0){
         period = _period;
     }
     if(_sumMul!=0){
         sumMultiplayer = _sumMul;
     }
     stageDataStore.push(StageData(uint128(start+period*151),uint64(50*sumMultiplayer),uint64(5000)));
     stageDataStore.push(StageData(uint128(start+period*243),uint64(60*sumMultiplayer),uint64(3000)));
     stageDataStore.push(StageData(uint128(start+period*334),uint64(50*sumMultiplayer),uint64(1666)));
     stageDataStore.push(StageData(uint128(start+period*455),uint64(60*sumMultiplayer),uint64(1500)));
     stageDataStore.push(StageData(uint128(start+period*548),uint64(65*sumMultiplayer),uint64(1444)));
     stageDataStore.push(StageData(uint128(start+period*641),uint64(55*sumMultiplayer),uint64(1000)));
     
 }
 
 
 function GetMaxStageEthAmount() public constant returns(uint256){
     StageData memory currS = stageDataStore[stageIndex];
     uint256 retVal = currS.stageSum;
     retVal = retVal*(10**18);
     retVal = retVal/currS.stagePrice;
     retVal = retVal.sub(this.balance);
     return retVal;
 }
 
 
 function () public payable {
     uint256  status = 0;
     status = 0;
     bool transferToBenef = false;
     uint256  amountOfEthBeforeBuy = 0;
     uint256  stageMaxEthAmount = 0;
     uint128 _n = uint128(GetNow());
     StageData memory currS = stageDataStore[stageIndex] ;
     if(_n<start){
         revert();
     }
     if(this.balance <msg.value){
        amountOfEthBeforeBuy =0 ;
     }
     else{
        amountOfEthBeforeBuy = this.balance - msg.value;
     }
     stageMaxEthAmount = uint256(currS.stageSum)*(10**18)/currS.stagePrice;
         uint256 amountToReturn =0;
         uint256 amountToMint =0;
         Buy memory b = stageBuys[msg.sender];
     if(currS.stageTime<_n && amountOfEthBeforeBuy<stageMaxEthAmount){
         status = 1;
         //current stage is unsuccessful money send in transaction should be returned plus 
         // all money spent in current round 
         amountToReturn = msg.value;
         if(b.stage==stageIndex){
             amountToReturn = amountToReturn.add(b.amountOfEth);
             if(b.amountOfEth>0){
                burn(msg.sender,b.amountOfEth.mul(currS.stagePrice));
             }
         }
         b.amountOfEth=0;
         mintingFinished = true;
         msg.sender.transfer(amountToReturn);
     }
     else{
         status = 2;
         
         if(b.stage!=stageIndex){
             b.stage = uint128(stageIndex);
             b.amountOfEth = 0;
             status = status*10+3;
         }
         
         if(currS.stageTime>_n &&  this.balance < stageMaxEthAmount){
            //nothing special normal buy 
             b.amountOfEth = uint128(b.amountOfEth.add(uint128(msg.value)));
            amountToMint = msg.value*currS.stagePrice;
            status = status*10+4;
            mintCoins(msg.sender,amountToMint);
         }else{
             if( this.balance >=stageMaxEthAmount){
                 //we exceed stage limit
                status = status*10+5;
                 transferToBenef = true;
                amountToMint = (stageMaxEthAmount - amountOfEthBeforeBuy)*(currS.stagePrice);
                mintCoins(msg.sender,amountToMint);
                stageIndex = stageIndex+1;
                beneficiary.transfer(stageMaxEthAmount);
                stageMaxEthAmount =  GetMaxStageEthAmount();
                if(stageIndex<5 && stageMaxEthAmount>this.balance){
                 //   status = status*10+7;
                    //buys for rest of eth tokens in new prices
                    currS = stageDataStore[stageIndex] ;
                    amountToMint = this.balance*(currS.stagePrice);
                    b.stage = uint128(stageIndex);
                    b.amountOfEth =uint128(this.balance);
                    mintCoins(msg.sender,amountToMint);
                }
                else{
                    status = status*10+8;
                    //returns rest of money if during buy hardcap is reached
                    amountToReturn = this.balance;
                    msg.sender.transfer(amountToReturn);
                }
             }else{
                status = status*10+6;
           //     revert() ;// not implemented, should not happend
             }
         }
         
     }
     stageBuys[msg.sender] = b;
     BuyStatus(status);
 }
 
 
 function GetBalance() public constant returns(uint256){
     return this.balance;
 }

  uint256 public constant maxTokenSupply = (10**(18-DECIMALS))*(10**6)*34 ;  
  
  function burn(address _from, uint256 _amount) private returns (bool){
      _amount = _amount.div(10**10);
      balances[_from] = balances[_from].sub(_amount);
      totalSupply = totalSupply.sub(_amount);
      Transfer(_from,address(0),_amount);
  }
  
  function GetStats()public constant returns (uint256,uint256,uint256,uint256){
      uint256 timeToEnd = 0;
      uint256 round =0;
      StageData memory _s = stageDataStore[stageIndex];
      if(GetNow()>=start){
        round = stageIndex+1;
        if(_s.stageTime>GetNow())
        {
            timeToEnd = _s.stageTime-GetNow();
        }
        else{
            return(0,0,0,0);
        }
      }
      else{
        timeToEnd = start-GetNow();
      }
      return(timeToEnd,
       round,
       _s.stageSum*1000/_s.stagePrice,
       GetMaxStageEthAmount().div(10**15));
  }
  
  function mintCoins(address _to, uint256 _amount)  canMint internal returns (bool) {
      
    _amount = _amount.div(10**10);
  	if(totalSupply.add(_amount)<maxTokenSupply){
  	  super.mint(_to,_amount.mul(75).div(100));
  	  super.mint(address(beneficiary),_amount.mul(25).div(100));
  	  
  	  return true;
  	}
  	else{
  		return false; 
  	}
  	
  	return true;
  }
  
  
 function GetNow() public constant returns(uint256){
    return now; 
 }
  
  
}