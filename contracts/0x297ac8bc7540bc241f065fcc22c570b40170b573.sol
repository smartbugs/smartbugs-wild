/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.18;

/*************************************************************************
 * import "./math/SafeMath.sol" : start
 *************************************************************************/


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
/*************************************************************************
 * import "./math/SafeMath.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./ownership/Ownable.sol" : start
 *************************************************************************/
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
  function Ownable() public { owner = msg.sender; }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() { require(msg.sender == owner); _; }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}/*************************************************************************
 * import "./ownership/Ownable.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./TraceToken.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./token/MintableToken.sol" : start
 *************************************************************************/


/*************************************************************************
 * import "./StandardToken.sol" : start
 *************************************************************************/


/*************************************************************************
 * import "./BasicToken.sol" : start
 *************************************************************************/


/*************************************************************************
 * import "./ERC20Basic.sol" : start
 *************************************************************************/


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
/*************************************************************************
 * import "./ERC20Basic.sol" : end
 *************************************************************************/



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
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
/*************************************************************************
 * import "./BasicToken.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./ERC20.sol" : start
 *************************************************************************/





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
/*************************************************************************
 * import "./ERC20.sol" : end
 *************************************************************************/


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
  function approve(address _spender, uint256 _value) public returns (bool) {
    // mitigating the race condition
    assert(allowed[msg.sender][_spender] == 0 || _value == 0);
    
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
/*************************************************************************
 * import "./StandardToken.sol" : end
 *************************************************************************/




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
    Transfer(0x0, _to, _amount);
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
/*************************************************************************
 * import "./token/MintableToken.sol" : end
 *************************************************************************/

contract TraceToken is MintableToken {

    string public constant name = 'Trace Token';
    string public constant symbol = 'TRACE';
    uint8 public constant decimals = 18;
    bool public transferAllowed = false;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferAllowed(bool transferIsAllowed);

    modifier canTransfer() {
        require(mintingFinished && transferAllowed);
        _;        
    }

    function transferFrom(address from, address to, uint256 value) canTransfer public returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) canTransfer public returns (bool) {
        return super.transfer(to, value);
    }

    function mint(address contributor, uint256 amount) public returns (bool) {
        return super.mint(contributor, amount);
    }

    function endMinting(bool _transferAllowed) public returns (bool) {
        transferAllowed = _transferAllowed;
        TransferAllowed(_transferAllowed);
        return super.finishMinting();
    }
}
/*************************************************************************
 * import "./TraceToken.sol" : end
 *************************************************************************/

contract TraceTokenSale is Ownable{
	using SafeMath for uint256;

	// Presale token
	TraceToken public token;

  // amount of tokens in existance - 500mil TRACE = 5e26 Tracks
  uint256 public constant TOTAL_NUM_TOKENS = 5e26; // 1 TRACE = 1e18 Tracks, all units in contract in Tracks
  uint256 public constant tokensForSale = 25e25; // 50% of all tokens

  // totalEthers received
  uint256 public totalEthers = 0;

  // Minimal possible cap in ethers
  uint256 public constant softCap = 3984.064 ether; 
  // Maximum possible cap in ethers
  uint256 public constant hardCap = 17928.287 ether; 
  
  uint256 public constant presaleLimit = 7968.127 ether; 
  bool public presaleLimitReached = false;

  // Minimum and maximum investments in Ether
  uint256 public constant min_investment_eth = 0.5 ether; // fixed value, not changing
  uint256 public constant max_investment_eth = 398.4064 ether; 

  uint256 public constant min_investment_presale_eth = 5 ether; // fixed value, not changing

  // refund if softCap is not reached
  bool public refundAllowed = false;

  // pause flag
  bool public paused = false;

  uint256 public constant bountyReward = 1e25;
  uint256 public constant preicoAndAdvisors = 4e25;
  uint256 public constant liquidityPool = 25e24;
  uint256 public constant futureDevelopment = 1e26; 
  uint256 public constant teamAndFounders = 75e24;  

  uint256 public leftOverTokens = 0;

  uint256[8] public founderAmounts = [uint256(teamAndFounders.div(8)),teamAndFounders.div(8),teamAndFounders.div(8),teamAndFounders.div(8),teamAndFounders.div(8),teamAndFounders.div(8),teamAndFounders.div(8),teamAndFounders.div(8)];
  uint256[2]  public preicoAndAdvisorsAmounts = [ uint256(preicoAndAdvisors.mul(2).div(5)),preicoAndAdvisors.mul(2).div(5)];


  // Withdraw multisig wallet
  address public wallet;

  // Withdraw multisig wallet
  address public teamAndFoundersWallet;

  // Withdraw multisig wallet
  address public advisorsAndPreICO;

  // Token per ether
  uint256 public constant token_per_wei = 12550;

  // start and end timestamp where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  uint256 private constant weekInSeconds = 86400 * 7;

  // whitelist addresses and planned investment amounts
  mapping(address => uint256) public whitelist;

  // amount of ether received from token buyers
  mapping(address => uint256) public etherBalances;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Whitelist(address indexed beneficiary, uint256 value);
  event SoftCapReached();
  event Finalized();

  function TraceTokenSale(uint256 _startTime, address traceTokenAddress, address _wallet, address _teamAndFoundersWallet, address _advisorsAndPreICO) public {
    require(_startTime >=  now);
    require(_wallet != 0x0);
    require(_teamAndFoundersWallet != 0x0);
    require(_advisorsAndPreICO != 0x0);

    token = TraceToken(traceTokenAddress);
    wallet = _wallet;
    teamAndFoundersWallet = _teamAndFoundersWallet;
    advisorsAndPreICO = _advisorsAndPreICO;
    startTime = _startTime;
    endTime = _startTime + 4 * weekInSeconds; // the sale lasts a maximum of 5 weeks
    
  }
    /*
     * @dev fallback for processing ether
     */
     function() public payable {
       return buyTokens(msg.sender);
     }

     function calcAmount() internal view returns (uint256) {

      if (totalEthers >= presaleLimit || startTime + 2 * weekInSeconds  < now ){
        // presale has ended
        return msg.value.mul(token_per_wei);
        }else{
          // presale ongoing
          require(msg.value >= min_investment_presale_eth);

          /* discount 20 % in the first week - presale week 1 */
          if (now <= startTime + weekInSeconds) {
            return msg.value.mul(token_per_wei.mul(100)).div(80);

          }

          /* discount 15 % in the second week - presale week 2 */
          if ( startTime +  weekInSeconds  < now ) {
           return msg.value.mul(token_per_wei.mul(100)).div(85);
         }
       }

     }

    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
     function buyTokens(address contributor) public payable {
       require(!hasEnded());
       require(!isPaused());
       require(validPurchase());
       require(checkWhitelist(contributor,msg.value));
       uint256 amount = calcAmount();
       require((token.totalSupply() + amount) <= TOTAL_NUM_TOKENS);
       
       whitelist[contributor] = whitelist[contributor].sub(msg.value);
       etherBalances[contributor] = etherBalances[contributor].add(msg.value);

       totalEthers = totalEthers.add(msg.value);

       token.mint(contributor, amount);
       require(totalEthers <= hardCap); 
       TokenPurchase(0x0, contributor, msg.value, amount);
     }


     // @return user balance
     function balanceOf(address _owner) public view returns (uint256 balance) {
      return token.balanceOf(_owner);
    }

    function checkWhitelist(address contributor, uint256 eth_amount) public view returns (bool) {
     require(contributor!=0x0);
     require(eth_amount>0);
     return (whitelist[contributor] >= eth_amount);
   }

   function addWhitelist(address contributor, uint256 eth_amount) onlyOwner public returns (bool) {
     require(!hasEnded());
     require(contributor!=0x0);
     require(eth_amount>0);
     Whitelist(contributor, eth_amount);
     whitelist[contributor] = eth_amount;
     return true;
   }

   function addWhitelists(address[] contributors, uint256[] amounts) onlyOwner public returns (bool) {
     require(!hasEnded());
     address contributor;
     uint256 amount;
     require(contributors.length == amounts.length);

     for (uint i = 0; i < contributors.length; i++) {
      contributor = contributors[i];
      amount = amounts[i];
      require(addWhitelist(contributor, amount));
    }
    return true;
  }


  function validPurchase() internal view returns (bool) {

   bool withinPeriod = now >= startTime && now <= endTime;
   bool withinPurchaseLimits = msg.value >= min_investment_eth && msg.value <= max_investment_eth;
   return withinPeriod && withinPurchaseLimits;
 }

 function hasStarted() public view returns (bool) {
  return now >= startTime;
}

function hasEnded() public view returns (bool) {
  return now > endTime || token.totalSupply() == TOTAL_NUM_TOKENS;
}


function hardCapReached() public view returns (bool) {
  return hardCap.mul(999).div(1000) <= totalEthers; 
}

function softCapReached() public view returns(bool) {
  return totalEthers >= softCap;
}


function withdraw() onlyOwner public {
  require(softCapReached());
  require(this.balance > 0);

  wallet.transfer(this.balance);
}

function withdrawTokenToFounders() onlyOwner public {
  require(softCapReached());
  require(hasEnded());

  if (now > startTime + 720 days && founderAmounts[7]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[7]);
    founderAmounts[7] = 0;
  }

  if (now > startTime + 630 days && founderAmounts[6]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[6]);
    founderAmounts[6] = 0;
  }
  if (now > startTime + 540 days && founderAmounts[5]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[5]);
    founderAmounts[5] = 0;
  }
  if (now > startTime + 450 days && founderAmounts[4]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[4]);
    founderAmounts[4] = 0;
  }
  if (now > startTime + 360 days&& founderAmounts[3]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[3]);
    founderAmounts[3] = 0;
  }
  if (now > startTime + 270 days && founderAmounts[2]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[2]);
    founderAmounts[2] = 0;
  }
  if (now > startTime + 180 days && founderAmounts[1]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[1]);
    founderAmounts[1] = 0;
  }
  if (now > startTime + 90 days && founderAmounts[0]!=0){
    token.transfer(teamAndFoundersWallet, founderAmounts[0]);
    founderAmounts[0] = 0;
  }
}

function withdrawTokensToAdvisors() onlyOwner public {
  require(softCapReached());
  require(hasEnded());

  if (now > startTime + 180 days && preicoAndAdvisorsAmounts[1]!=0){
    token.transfer(advisorsAndPreICO, preicoAndAdvisorsAmounts[1]);
    preicoAndAdvisorsAmounts[1] = 0;
  }

  if (now > startTime + 90 days && preicoAndAdvisorsAmounts[0]!=0){
    token.transfer(advisorsAndPreICO, preicoAndAdvisorsAmounts[0]);
    preicoAndAdvisorsAmounts[0] = 0;
  }
}

function refund() public {
  require(refundAllowed);
  require(hasEnded());
  require(!softCapReached());
  require(etherBalances[msg.sender] > 0);
  require(token.balanceOf(msg.sender) > 0);

  uint256 current_balance = etherBalances[msg.sender];
  etherBalances[msg.sender] = 0;
  token.transfer(this,token.balanceOf(msg.sender)); // burning tokens by sending back to contract
  msg.sender.transfer(current_balance);
}


function finishCrowdsale() onlyOwner public returns (bool){
  require(!token.mintingFinished());
  require(hasEnded() || hardCapReached());

  if(softCapReached()) {
    token.mint(wallet, bountyReward);
    token.mint(advisorsAndPreICO,  preicoAndAdvisors.div(5)); //20% available immediately
    token.mint(wallet, liquidityPool);
    token.mint(wallet, futureDevelopment);
    token.mint(this, teamAndFounders);
    token.mint(this, preicoAndAdvisors.mul(4).div(5)); 
    leftOverTokens = TOTAL_NUM_TOKENS.sub(token.totalSupply());
    token.mint(wallet,leftOverTokens); // will be equaly distributed among all presale and sale contributors after the sale

    token.endMinting(true);
    return true;
    } else {
      refundAllowed = true;
      token.endMinting(false);
      return false;
    }

    Finalized();
  }


  // additional functionality, used to pause crowdsale for 24h
  function pauseSale() onlyOwner public returns (bool){
    paused = true;
    return true;
  }

  function unpauseSale() onlyOwner public returns (bool){
    paused = false;
    return true;
  }

  function isPaused() public view returns (bool){
    return paused;
  }
}