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
    
    modifier nonZeroEth(uint _value) {
      require(_value > 0);
      _;
    }

    modifier onlyPayloadSize() {
      require(msg.data.length >= 68);
      _;
    }
    /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */

    function transfer(address _to, uint256 _value) nonZeroEth(_value) onlyPayloadSize returns (bool) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]){
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }else{
            return false;
        }
    }
    

    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */

    function transferFrom(address _from, address _to, uint256 _value) nonZeroEth(_value) onlyPayloadSize returns (bool) {
      if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]){
        uint256 _allowance = allowed[_from][msg.sender];
        allowed[_from][msg.sender] = _allowance.sub(_value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        Transfer(_from, _to, _value);
        return true;
      }else{
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


contract RPTToken is BasicToken {

using SafeMath for uint256;

string public name = "RPT Token";                  //name of the token
string public symbol = "RPT";                      // symbol of the token
uint8 public decimals = 18;                        // decimals
uint256 public totalSupply = 1000000000 * 10**18;  // total supply of RPT Tokens  

// variables
uint256 public keyEmployeeAllocation;               // fund allocated to key employee
uint256 public totalAllocatedTokens;                // variable to regulate the funds allocation
uint256 public tokensAllocatedToCrowdFund;          // funds allocated to crowdfund

// addresses
address public founderMultiSigAddress = 0xf96E905091d38ca25e06C014fE67b5CA939eE83D;    // multi sign address of founders which hold 
address public crowdFundAddress;                    // address of crowdfund contract

//events
event ChangeFoundersWalletAddress(uint256  _blockTimeStamp, address indexed _foundersWalletAddress);
event TransferPreAllocatedFunds(uint256  _blockTimeStamp , address _to , uint256 _value);

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
   function RPTToken (address _crowdFundAddress) {
    crowdFundAddress = _crowdFundAddress;

    // Token Distribution  
    tokensAllocatedToCrowdFund = 70 * 10 ** 25;        // 70 % allocation of totalSupply
    keyEmployeeAllocation = 30 * 10 ** 25;             // 30 % allocation of totalSupply

    // Assigned balances to respective stakeholders
    balances[founderMultiSigAddress] = keyEmployeeAllocation;
    balances[crowdFundAddress] = tokensAllocatedToCrowdFund;

    totalAllocatedTokens = balances[founderMultiSigAddress];
  }

// function to keep track of the total token allocation
  function changeTotalSupply(uint256 _amount) onlyCrowdFundAddress {
    totalAllocatedTokens = totalAllocatedTokens.add(_amount);
  }

// function to change founder multisig wallet address            
  function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
    founderMultiSigAddress = _newFounderMultiSigAddress;
    ChangeFoundersWalletAddress(now, founderMultiSigAddress);
  }
 

}


contract RPTCrowdsale {

    using SafeMath for uint256;
    
    RPTToken public token;                                          // Token variable
    //variables
   
    uint256 public totalWeiRaised;                                  // Flag to track the amount raised
    uint32 public exchangeRate = 3000;                              // calculated using priceOfEtherInUSD/priceOfRPTToken 
    uint256 public preDistriToAcquiantancesStartTime = 1510876801;  // Friday, 17-Nov-17 00:00:01 UTC
    uint256 public preDistriToAcquiantancesEndTime = 1511827199;    // Monday, 27-Nov-17 23:59:59 UTC
    uint256 public presaleStartTime = 1511827200;                   // Tuesday, 28-Nov-17 00:00:00 UTC
    uint256 public presaleEndTime = 1513036799;                     // Monday, 11-Dec-17 23:59:59 UTC
    uint256 public crowdfundStartTime = 1513036800;                 // Tuesday, 12-Dec-17 00:00:00 UTC
    uint256 public crowdfundEndTime = 1515628799;                   // Wednesday, 10-Jan-18 23:59:59 UTC
    bool internal isTokenDeployed = false;                          // Flag to track the token deployment
    
    // addresses
    address public founderMultiSigAddress;                          // Founders multi sign address
    address public remainingTokenHolder;                            // Address to hold the remaining tokens after crowdfund end
    address public beneficiaryAddress;                              // All funds are transferred to this address
    

    enum State { Acquiantances, PreSale, CrowdFund, Closed }

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

    modifier inState(State state) {
        require(getState() == state); 
        _;
    }

    modifier inBetween() {
        require(now >= preDistriToAcquiantancesStartTime && now <= crowdfundEndTime);
        _;
    }

    // Constructor to initialize the local variables 
    function RPTCrowdsale (address _founderWalletAddress, address _remainingTokenHolder, address _beneficiaryAddress) {
        founderMultiSigAddress = _founderWalletAddress;
        remainingTokenHolder = _remainingTokenHolder;
        beneficiaryAddress = _beneficiaryAddress;
    }

    // Function to change the founders multi sign address 
     function setFounderMultiSigAddress(address _newFounderAddress) onlyFounders  nonZeroAddress(_newFounderAddress) {
        founderMultiSigAddress = _newFounderAddress;
        ChangeFoundersWalletAddress(now, founderMultiSigAddress);
    }
    
    // Attach the token contract     
    function setTokenAddress(address _tokenAddress) external onlyFounders nonZeroAddress(_tokenAddress) {
        require(isTokenDeployed == false);
        token = RPTToken(_tokenAddress);
        isTokenDeployed = true;
    }


    // function call after crowdFundEndTime it transfers the remaining tokens to remainingTokenHolder address
    function endCrowdfund() onlyFounders returns (bool) {
        require(now > crowdfundEndTime);
        uint256 remainingToken = token.balanceOf(this);  // remaining tokens

        if (remainingToken != 0) {
          token.transfer(remainingTokenHolder, remainingToken); 
          CrowdFundClosed(now);
          return true; 
        } else {
            CrowdFundClosed(now);
            return false;
        }
       
    }

    // Buy token function call only in duration of crowdfund active 
    function buyTokens(address beneficiary)
    nonZeroEth 
    tokenIsDeployed 
    onlyPublic 
    nonZeroAddress(beneficiary) 
    inBetween
    payable 
    public 
    returns(bool) 
    {
            fundTransfer(msg.value);

            uint256 amount = getNoOfTokens(exchangeRate, msg.value);
            
            if (token.transfer(beneficiary, amount)) {
                token.changeTotalSupply(amount); 
                totalWeiRaised = totalWeiRaised.add(msg.value);
                TokenPurchase(beneficiary, msg.value, amount);
                return true;
            } 
            return false;
        
    }


    // function to transfer the funds to founders account
    function fundTransfer(uint256 weiAmount) internal {
        beneficiaryAddress.transfer(weiAmount);
    }

// Get functions 

    // function to get the current state of the crowdsale
    function getState() internal constant returns(State) {
        if (now >= preDistriToAcquiantancesStartTime && now <= preDistriToAcquiantancesEndTime) {
            return State.Acquiantances;
        } if (now >= presaleStartTime && now <= presaleEndTime) {
            return State.PreSale;
        } if (now >= crowdfundStartTime && now <= crowdfundEndTime) {
            return State.CrowdFund;
        } else {
            return State.Closed;
        }
        
    }


   // function to calculate the total no of tokens with bonus multiplication
    function getNoOfTokens(uint32 _exchangeRate, uint256 _amount) internal returns (uint256) {
         uint256 noOfToken = _amount.mul(uint256(_exchangeRate));
         uint256 noOfTokenWithBonus = ((uint256(100 + getCurrentBonusRate())).mul(noOfToken)).div(100);
         return noOfTokenWithBonus;
    }

    

    // function provide the current bonus rate
    function getCurrentBonusRate() internal returns (uint8) {
        
        if (getState() == State.Acquiantances) {
            return 40;
        }
        if (getState() == State.PreSale) {
            return 20;
        }
        if (getState() == State.CrowdFund) {
            return 0;
        } else {
            return 0;
        }
    }

    // provides the bonus % 
    function getBonus() constant returns (uint8) {
        return getCurrentBonusRate();
    }

    // send ether to the contract address
    // With at least 200 000 gas
    function() public payable {
        buyTokens(msg.sender);
    }
}