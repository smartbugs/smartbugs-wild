pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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


contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
    
}


contract BasicToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }else {
            return false;
        }
    }
    

    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        uint256 _allowance = allowed[_from][msg.sender];
        allowed[_from][msg.sender] = _allowance.sub(_value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
}


    /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */

    function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

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
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }


}

contract ANOToken is BasicToken {

using SafeMath for uint256;

string public name = "Anonium";                                 // Name of the token
string public symbol = "ANO";                                   // Symbol of the token
uint8 public decimals = 18;                                     // Decimals
uint256 public totalSupply = 21000000000 * 10**18;              // Total supply of SPC Tokens  

//Variables
uint256 public tokensAllocatedToCrowdFund;                      // variable to track the allocations of the token to crowdfund
uint256 public totalAllocatedTokens;                            // variable to track the supply in to the market

//Address
address public crowdFundAddress;                                // Address of the crowdfund
address public founderMultiSigAddress;                          // Address of the founder

//events
event ChangeFoundersWalletAddress(uint256  _blockTimeStamp, address indexed _foundersWalletAddress);

//modifiers

  modifier onlyCrowdFundAddress() {
    require(msg.sender == crowdFundAddress);
    _;
  }

  modifier nonZeroAddress(address _to) {
    require(_to != 0x0);
    _;
  }

  modifier onlyFounders() {
    require(msg.sender == founderMultiSigAddress);
    _;
  }


  
   // creation of the token contract 
   function ANOToken (address _crowdFundAddress) public {
    crowdFundAddress = _crowdFundAddress;
    founderMultiSigAddress = msg.sender;

    tokensAllocatedToCrowdFund = totalSupply;                   // 100 % allocation of totalSupply

    // Assigned balances to respective stakeholders
    balances[crowdFundAddress] = tokensAllocatedToCrowdFund;
  
  }

// function to keep track of the total token allocation
  function changeSupply(uint256 _amount) public onlyCrowdFundAddress {
    totalAllocatedTokens += _amount;
  }

// function to change founder multisig wallet address            
  function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) public onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
    founderMultiSigAddress = _newFounderMultiSigAddress;
    ChangeFoundersWalletAddress(now, founderMultiSigAddress);
  }

  /**
    @dev `burnToken` used to burn the remianing token after the end of crowdsale
    it only be called by the crowdfund address only 
   */

  function burnToken() public onlyCrowdFundAddress returns (bool) {
    totalSupply = totalSupply.sub(balances[msg.sender]);
    balances[msg.sender] = 0;
    return true;
  }

}

contract ANOCrowdsale {

using SafeMath for uint256;

ANOToken token;                                                  // Token variable

uint256 public startDate;                                        // Start date of the crowdsale
uint256 public endDate;                                          // End date of crowdsale
uint256 private weekNo = 0;                                       // Flag variable to track the week no.
uint256 public allocatedToken = 21000000000 * 10 ** 18;          // Total tokens allocated to crowdsale 
uint256 private tokenAllocatedForWeek;                           // Variable to track the allocation per week
uint256 private tokenSoldForWeek;                                // Token sold per week
uint256 public ethRaised;                                        // Public variable to track the amount of ETH raised
uint32 public tokenRate = 6078;                                  // Initialization of token rate 
uint32 public appreciationRate = 1216;                           // The rate of token will increased by that much amount
bool private isTokenSet = false;                                 // Flag variable to track the token address

address public founderAddress;                                   // Founder address which will control the operations of the crowdsale
address public beneficiaryAddress;                               // Address where ETH get trasferred  

/**
    @note structure for keeping the weekly data to track
    the week rate of the crowdsale
 */
struct weeklyData {
    uint256 startTime;
    uint256 endTime;
    uint32 weekRate;
}

// mapping is used to store the weeklyData corresponds to integer
mapping(uint256 => weeklyData) public weeklyRate;

//Event 
event LogWeekRate(uint32 _weekRate, uint256 _timestamp);

// Modifier for validating the time lapse should between in start and end date
modifier isBetween() {
    require(now >= startDate && now <= endDate);
    _;
}

// Modifier for validating the msg.sender should be founder address
modifier onlyFounder() {
    require(msg.sender == founderAddress);
    _;
}

//Event 
event TokenBought(address indexed _investor, uint256 _tokenQuantity);

/**
    @dev Fallback function
    minimum 2,00,000 gas should be used at the time calling this function 
 */

function () public payable {
    buyTokens(msg.sender);
}

/**
    @dev Private function to set the weekly rate it called only once
    in the constructor.
    @return bool
 */

function setWeeklyRate() private returns (bool) {
    for (uint32 i = 0; i < 40; ++i) {
        uint32 weekRate = tokenRate + appreciationRate * i;
        uint256 weekStartTime = now + i * 1 weeks;
        uint256 weekEndTime = now + (i+1) * 1 weeks;
        weeklyRate[i] = weeklyData(weekStartTime, weekEndTime, weekRate);
    }
    return true;
}

/**
    @dev Private function to get the weekly rate 
    as per the week no.
    @return uint32
 */

function getWeeklyRate() private returns (uint32) {
   if (now <= weeklyRate[weekNo].endTime && now >= weeklyRate[weekNo].startTime) {
       return weeklyRate[weekNo].weekRate;
   } if (now <= weeklyRate[weekNo + 1].endTime && now >= weeklyRate[weekNo + 1].startTime ) {
        weekNo = weekNo + 1;
        setWeeklyAllocation();
        return weeklyRate[weekNo + 1].weekRate;
   } else {
       uint256 increasedBy = now - startDate;
       uint256 weekIncreasedBy = increasedBy.div(604800);    // 7 days seconds 7 * 24 * 60 * 60
       setWeeklyAllocation();
       weekNo = weekNo.add(weekIncreasedBy);
       LogWeekRate(weeklyRate[weekNo].weekRate, now);
       return weeklyRate[weekNo].weekRate;
   }
}

// function to transfer the funds to founders account
function fundTransfer(uint256 weiAmount) internal {
        beneficiaryAddress.transfer(weiAmount);
    }

/**
    @dev Simple function to track the token allocation for a week
 */
function setWeeklyAllocation() private {
    tokenAllocatedForWeek = (tokenAllocatedForWeek + (tokenAllocatedForWeek - tokenSoldForWeek)).div(2);
    tokenSoldForWeek = 0;
}

/**
    @dev ANOCrowdsale constructor to set the founder and beneficiary
    as well as to set start & end date.
    @param _founderAddress address which operates all the admin functionality of the contract
    @param _beneficiaryAddress address where all invested amount get transferred 
 */

function ANOCrowdsale (address _founderAddress, address _beneficiaryAddress) public {
    startDate = now;
    endDate = now + 40 weeks;
    founderAddress = _founderAddress;
    beneficiaryAddress = _beneficiaryAddress;
    require(setWeeklyRate());
    tokenAllocatedForWeek = allocatedToken.div(2);
}

/**
    @dev `setTokenAddress` used to assign the token address into the variable
    only be called by founder and called only once.
    @param _tokenAddress address of the token which will be distributed using this crowdsale
    @return bool
 */

function setTokenAddress (address _tokenAddress) public onlyFounder returns (bool) {
    require(isTokenSet == false);
    token = ANOToken(_tokenAddress);
    isTokenSet = !isTokenSet;
    return true;
}

/**
    @dev `buyTokens` function used to buy the token
    @param _investor address of the investor where ROI will transferred
    @return bool
 */

function buyTokens(address _investor) 
public 
isBetween
payable
returns (bool) 
{
   require(isTokenSet == true);
   require(_investor != address(0));
   uint256 rate = uint256(getWeeklyRate());
   uint256 tokenAmount = (msg.value.div(rate)).mul(10 ** 8);
   require(tokenAllocatedForWeek >= tokenSoldForWeek + tokenAmount);
   fundTransfer(msg.value);
   require(token.transfer(_investor, tokenAmount));
   tokenSoldForWeek = tokenSoldForWeek.add(tokenAmount);
   token.changeSupply(tokenAmount);
   ethRaised = ethRaised.add(msg.value);
   TokenBought(_investor, tokenAmount);
   return true;
}

/**
    @dev `getWeekNo` public function to get the current week no
 */

function getWeekNo() public view returns (uint256) {
    return weekNo;
}

/**
    @dev `endCrowdfund` function used to end the crowdfund
    called only by the founder and remiaining tokens get burned 
 */

function endCrowdfund() public onlyFounder returns (bool) {
    require(isTokenSet == true);
    require(now > endDate);
    require(token.burnToken());
    return true;
}

}