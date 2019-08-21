pragma solidity ^0.4.15;


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

contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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

    function transfer(address _to, uint256 _value) returns (bool) {
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

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
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

    function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

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


contract DOWToken is BasicToken {

using SafeMath for uint256;

string public name = "DOW";                        //name of the token
string public symbol = "dow";                      // symbol of the token
uint8 public decimals = 18;                        // decimals
uint256 public initialSupply = 2000000000 * 10**18;  // total supply of dow Tokens  

// variables
uint256 public foundersAllocation;                  // fund allocated to founders
uint256 public devAllocation;                       // fund allocated to developers 
uint256 public totalAllocatedTokens;                // variable to keep track of funds allocated
uint256 public tokensAllocatedToCrowdFund;          // funds allocated to crowdfund
// addresses

address public founderMultiSigAddress;              // Multi sign address of founders which hold 
address public devTeamAddress;                      // Developemnt team address which hold devAllocation funds
address public crowdFundAddress;                    // Address of crowdfund contract



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
   function DOWToken (address _crowdFundAddress, address _founderMultiSigAddress, address _devTeamAddress) {
    crowdFundAddress = _crowdFundAddress;
    founderMultiSigAddress = _founderMultiSigAddress;
    devTeamAddress = _devTeamAddress;

    // Token Distribution 
    foundersAllocation = 50 * 10 ** 25;               // 25 % allocation of initialSupply 
    devAllocation = 30 * 10 ** 25;                    // 15 % allocation of initialSupply 
    tokensAllocatedToCrowdFund = 120 * 10 ** 25;      // 60 % allocation of initialSupply
   
    // Assigned balances to respective stakeholders
    balances[founderMultiSigAddress] = foundersAllocation;
    balances[devTeamAddress] = devAllocation;
    balances[crowdFundAddress] = tokensAllocatedToCrowdFund;

    totalAllocatedTokens = balances[founderMultiSigAddress] + balances[devTeamAddress];
  }


// function to keep track of the total token allocation
  function addToAllocation(uint256 _amount) onlyCrowdFundAddress {
    totalAllocatedTokens = totalAllocatedTokens.add(_amount);
  }

// function to change founder multisig wallet address            
  function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
    founderMultiSigAddress = _newFounderMultiSigAddress;
    ChangeFoundersWalletAddress(now, founderMultiSigAddress);
  }

// fallback function to restrict direct sending of ether
  function () {
    revert();
  }

}


contract DOWCrowdfund {

    using SafeMath for uint256;
    
    DOWToken public token;                                 // Token contract reference

    //variables
    uint256 public crowdfundStartTime;                     // Starting time of CrowdFund
    uint256 public crowdfundEndTime;                       // End time of Crowdfund
    uint256 public totalWeiRaised;                         // Counter to track the amount raised
    uint256 public weekOneRate = 3000;                     // Calculated using priceOfEtherInUSD/priceOfDOWToken 
    uint256 public weekTwoRate = 2000;                     // Calculated using priceOfEtherInUSD/priceOfDOWToken 
    uint256 public weekThreeRate = 1500;                   // Calculated using priceOfEtherInUSD/priceOfDOWToken 
    uint256 public weekFourthRate = 1200;                  // Calculated using priceOfEtherInUSD/priceOfDOWToken 
    uint256 minimumFundingGoal = 5000 * 1 ether;           // Minimum amount of ethers required for a success of the crowdsale
    uint256 MAX_FUNDING_GOAL = 400000 * 1 ether;           // Maximum amount of ethers can invested in the crowdsale
    uint256 public totalDowSold = 0;
    address public owner = 0x0;                            // Address of the owner or the deployer 

    bool  internal isTokenDeployed = false;                // Flag to track the token deployment -- only can be set once

    // addresses
    address public founderMultiSigAddress;                 // Founders multisig address
    address public remainingTokenHolder;                   // Remaining token holder address
    //events
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount); 
    event CrowdFundClosed(uint256 _blockTimeStamp);
    event ChangeFoundersWalletAddress(uint256 _blockTimeStamp, address indexed _foundersWalletAddress);
   
    //Modifiers
    modifier tokenIsDeployed() {
        require(isTokenDeployed == true);
        _;
    }
     modifier nonZeroEth() {
        require(msg.value > 0);
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

    modifier onlyPublic() {
        require(msg.sender != founderMultiSigAddress);
        _;
    }

    modifier isBetween() {
        require(now >= crowdfundStartTime && now <= crowdfundEndTime);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor to initialize the local variables 
    function DOWCrowdfund (address _founderWalletAddress, address _remainingTokenHolder) {
        founderMultiSigAddress = _founderWalletAddress;
        remainingTokenHolder = _remainingTokenHolder;
        owner = msg.sender;
        crowdfundStartTime = 1510272001;  //Friday, 10-Nov-17 00:00:01 UTC 
        crowdfundEndTime = 1512950399;    //Sunday, 10-Dec-17 23:59:59 UTC 
    }


    // Function to change the founders multisig address 
    function ChangeFounderMultiSigAddress(address _newFounderAddress) onlyFounders nonZeroAddress(_newFounderAddress) {
        founderMultiSigAddress = _newFounderAddress;
        ChangeFoundersWalletAddress(now, founderMultiSigAddress);
    }

    // Attach the token contract, can only be done once     
    function setTokenAddress(address _tokenAddress) external onlyOwner nonZeroAddress(_tokenAddress) {
        require(isTokenDeployed == false);
        token = DOWToken(_tokenAddress);
        isTokenDeployed = true;
    }


    // function call after crowdFundEndTime.
    // It transfers the remaining tokens to remainingTokenHolder address
    function endCrowdfund() onlyFounders returns (bool) {
        require(now > crowdfundEndTime);
        uint256 remainingToken = token.balanceOf(this);  // remaining tokens

        if (remainingToken != 0) {
          token.transfer(remainingTokenHolder, remainingToken); 
          CrowdFundClosed(now);
          return true; 
        } 
        CrowdFundClosed(now);
        return false;
       
    }

    // Buy token function call only in duration of crowdfund active 
    function buyTokens(address beneficiary) 
    nonZeroEth 
    tokenIsDeployed 
    onlyPublic
    isBetween 
    nonZeroAddress(beneficiary) 
    payable 
    returns(bool) 
    {
        if (totalWeiRaised.add(msg.value) > MAX_FUNDING_GOAL) 
            revert();

            fundTransfer(msg.value);
            uint256 amount = getNoOfTokens(msg.value);
            
            if (token.transfer(beneficiary, amount)) {
                token.addToAllocation(amount); 
                totalDowSold = totalDowSold.add(amount);
                totalWeiRaised = totalWeiRaised.add(msg.value);
                TokenPurchase(beneficiary, msg.value, amount);
                return true;
            } 
            return false;
        }

    // function to transfer the funds to founders account
    function fundTransfer(uint256 weiAmount) internal {
        founderMultiSigAddress.transfer(weiAmount);
    }

// Get functions

    // function provide the token
    function getNoOfTokens(uint256 investedAmount) internal returns (uint256) {
        
        if ( now > crowdfundStartTime + 3 weeks && now < crowdfundEndTime) {
            return  investedAmount.mul(weekFourthRate);
        }
        if (now > crowdfundStartTime + 2 weeks) {
            return investedAmount.mul(weekThreeRate);
        }
        if (now > crowdfundStartTime + 1 weeks) {
            return investedAmount.mul(weekTwoRate);
        }
        if (now > crowdfundStartTime) {
            return investedAmount.mul(weekOneRate);
        }
    }

    
    // Crowdfund entry
    // send ether to the contract address
    // With at least 200 000 gas
    function() public payable {
        buyTokens(msg.sender);
    }
}