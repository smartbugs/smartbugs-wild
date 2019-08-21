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


contract SPCToken is BasicToken {

using SafeMath for uint256;

string public name = "SecurityPlusCloud Token";              //name of the token
string public symbol = "SPC";                                // symbol of the token
uint8 public decimals = 18;                                  // decimals
uint256 public totalSupply = 500000000 * 10**18;             // total supply of SPC Tokens  

// variables
uint256 public keyEmployeesAllocation;              // fund allocated to key employees 
uint256 public bountiesAllocation;                  // fund allocated to advisors 
uint256 public longTermBudgetAllocation;            // fund allocated to Market 
uint256 public bonusAllocation;                     // funds allocated to founders that in under vesting period
uint256 public totalAllocatedTokens;                // variable to keep track of funds allocated
uint256 public tokensAllocatedToCrowdFund;          // funds allocated to crowdfund

// addresses
// multi sign address of founders which hold 
address public founderMultiSigAddress = 0x70b0ea058aee845342B09f1769a2bE8deB46aA86;     
address public crowdFundAddress;                    // address of crowdfund contract
address public owner;                               // owner of the contract
// bonus funds get allocated to below address
address public bonusAllocAddress = 0x95817119B58D195C10a935De6fA4141c2647Aa56;
// Address to allocate the bounties
address public bountiesAllocAddress = 0x6272A7521c60dE62aBc048f7B40F61f775B32d78;
// Address to allocate the LTB
address public longTermbudgetAllocAddress = 0x00a6858fe26c326c664a6B6499e47D72e98402Bb;

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
   function SPCToken (address _crowdFundAddress) {
    owner = msg.sender;
    crowdFundAddress = _crowdFundAddress;

    // Token Distribution 
    keyEmployeesAllocation = 50 * 10 ** 24;           // 10 % allocation of totalSupply 
    bountiesAllocation = 35 * 10 ** 24;               // 7 % allocation of totalSupply 
    tokensAllocatedToCrowdFund = 25 * 10 ** 25;       // 50 % allocation of totalSupply
    longTermBudgetAllocation = 10 * 10 ** 25;         // 20 % allocation of totalSupply
    bonusAllocation = 65 * 10 ** 24;                  // 13 % allocation of totalSupply

    // Assigned balances to respective stakeholders
    balances[founderMultiSigAddress] = keyEmployeesAllocation;
    balances[crowdFundAddress] = tokensAllocatedToCrowdFund;
    balances[bonusAllocAddress] = bonusAllocation;
    balances[bountiesAllocAddress] = bountiesAllocation;
    balances[longTermbudgetAllocAddress] = longTermBudgetAllocation;

    totalAllocatedTokens = balances[founderMultiSigAddress] + balances[bonusAllocAddress] + balances[bountiesAllocAddress] + balances[longTermbudgetAllocAddress];
  }

// function to keep track of the total token allocation
  function changeTotalSupply(uint256 _amount) onlyCrowdFundAddress {
    totalAllocatedTokens += _amount;
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



contract SPCCrowdFund {

    using SafeMath for uint256;
    
    SPCToken public token;                                    // Token contract reference

    //variables
    uint256 public preSaleStartTime = 1509494401;             // Wednesday, 01-Nov-17 00:00:01 UTC     
    uint256 public preSaleEndTime = 1510531199;               // Sunday, 12-Nov-17 23:59:59 UTC           
    uint256 public crowdfundStartDate = 1511308801;           // Wednesday, 22-Nov-17 00:00:01 UTC
    uint256 public crowdfundEndDate = 1515283199;             // Saturday, 06-Jan-18 23:59:59 UTC
    uint256 public totalWeiRaised;                            // Counter to track the amount raised
    uint256 public exchangeRateForETH = 300;                  // No. of SOC Tokens in 1 ETH
    uint256 public exchangeRateForBTC = 4500;                 // No. of SPC Tokens in 1 BTC  
    uint256 internal tokenSoldInPresale = 0;
    uint256 internal tokenSoldInCrowdsale = 0;
    uint256 internal minAmount = 1 * 10 ** 17;                // Equivalent to 0.1 ETH

    bool internal isTokenDeployed = false;                    // Flag to track the token deployment -- only can be set once
 

     // addresses
    // Founders multisig address
    address public founderMultiSigAddress = 0xF50aCE12e0537111be782899Fd5c4f5f638340d5;                            
    // Owner of the contract
    address public owner;                                              
    
    enum State { PreSale, Crowdfund, Finish }

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

    modifier onlyOwner() {
        require(msg.sender == owner);
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

     // Constructor to initialize the local variables 
    function SPCCrowdFund () {
        owner = msg.sender;
    }

    // Function to change the founders multisig address 
     function setFounderMultiSigAddress(address _newFounderAddress) onlyFounders  nonZeroAddress(_newFounderAddress) {
        founderMultiSigAddress = _newFounderAddress;
        ChangeFoundersWalletAddress(now, founderMultiSigAddress);
    }

    // Attach the token contract, can only be done once     
    function setTokenAddress(address _tokenAddress) external onlyOwner nonZeroAddress(_tokenAddress) {
        require(isTokenDeployed == false);
        token = SPCToken(_tokenAddress);
        isTokenDeployed = true;
    }

    // function call after crowdFundEndTime.
    // It transfers the remaining tokens to remainingTokenHolder address
    function endCrowdfund() onlyFounders inState(State.Finish) returns (bool) {
        require(now > crowdfundEndDate);
        uint256 remainingToken = token.balanceOf(this);  // remaining tokens

        if (remainingToken != 0) 
          token.transfer(founderMultiSigAddress, remainingToken); 
        CrowdFundClosed(now);
        return true; 
    }

    // Buy token function call only in duration of crowdfund active 
    function buyTokens(address beneficiary) 
    nonZeroEth 
    tokenIsDeployed 
    onlyPublic 
    nonZeroAddress(beneficiary) 
    payable 
    returns(bool) 
    {
        require(msg.value >= minAmount);

        if (getState() == State.PreSale) {
            if (buyPreSaleTokens(beneficiary)) {
                return true;
            }
            return false;
        } else {
            require(now >= crowdfundStartDate && now <= crowdfundEndDate);
            fundTransfer(msg.value);

            uint256 amount = getNoOfTokens(exchangeRateForETH, msg.value);
            
            if (token.transfer(beneficiary, amount)) {
                tokenSoldInCrowdsale = tokenSoldInCrowdsale.add(amount);
                token.changeTotalSupply(amount); 
                totalWeiRaised = totalWeiRaised.add(msg.value);
                TokenPurchase(beneficiary, msg.value, amount);
                return true;
            } 
            return false;
        }
       
    }
        
    // function to buy the tokens at presale 
    function buyPreSaleTokens(address beneficiary) internal returns(bool) {
            
            uint256 amount = getTokensForPreSale(exchangeRateForETH, msg.value);
            fundTransfer(msg.value);

            if (token.transfer(beneficiary, amount)) {
                tokenSoldInPresale = tokenSoldInPresale.add(amount);
                token.changeTotalSupply(amount); 
                totalWeiRaised = totalWeiRaised.add(msg.value);
                TokenPurchase(beneficiary, msg.value, amount);
                return true;
            }
            return false;
    }    

// function to calculate the total no of tokens with bonus multiplication
    function getNoOfTokens(uint256 _exchangeRate, uint256 _amount) internal constant returns (uint256) {
         uint256 noOfToken = _amount.mul(_exchangeRate);
         uint256 noOfTokenWithBonus = ((100 + getCurrentBonusRate()) * noOfToken ).div(100);
         return noOfTokenWithBonus;
    }

    function getTokensForPreSale(uint256 _exchangeRate, uint256 _amount) internal constant returns (uint256) {
        uint256 noOfToken = _amount.mul(_exchangeRate);
        uint256 noOfTokenWithBonus = ((100 + getCurrentBonusRate()) * noOfToken ).div(100);
        if (noOfTokenWithBonus + tokenSoldInPresale > (50000000 * 10 ** 18) ) {
            revert();
        }
        return noOfTokenWithBonus;
    }

    // function to transfer the funds to founders account
    function fundTransfer(uint256 weiAmount) internal {
        founderMultiSigAddress.transfer(weiAmount);
    }


// Get functions 

    // function to get the current state of the crowdsale
    function getState() public constant returns(State) {
        if (now >= preSaleStartTime && now <= preSaleEndTime) {
            return State.PreSale;
        }
        if (now >= crowdfundStartDate && now <= crowdfundEndDate) {
            return State.Crowdfund;
        } 
        return State.Finish;
    }


    // function provide the current bonus rate
    function getCurrentBonusRate() internal returns (uint8) {
        
        if (getState() == State.PreSale) {
           return 50;
        } 
        if (getState() == State.Crowdfund) {
           if (tokenSoldInCrowdsale <= (100000000 * 10 ** 18) ) {
               return 30;
           }
           if (tokenSoldInCrowdsale > (100000000 * 10 ** 18) && tokenSoldInCrowdsale <= (175000000 * 10 ** 18)) {
               return 10;
           } else {
               return 0;
           }
        }
    }


    // provides the bonus % 
    function currentBonus() public constant returns (uint8) {
        return getCurrentBonusRate();
    }

    // GET functions

    function getContractTimestamp() public constant returns ( 
        uint256 _presaleStartDate, 
        uint256 _presaleEndDate, 
        uint256 _crowdsaleStartDate, 
        uint256 _crowdsaleEndDate) 
    {
        return (preSaleStartTime, preSaleEndTime, crowdfundStartDate, crowdfundEndDate);
    }

    function getExchangeRate() public constant returns (uint256 _exchangeRateForETH, uint256 _exchangeRateForBTC) {
        return (exchangeRateForETH, exchangeRateForBTC);
    }

    function getNoOfSoldToken() public constant returns (uint256 _tokenSoldInPresale , uint256 _tokenSoldInCrowdsale) {
        return (tokenSoldInPresale, tokenSoldInCrowdsale);
    }

    function getWeiRaised() public constant returns (uint256 _totalWeiRaised) {
        return totalWeiRaised;
    }

    // Crowdfund entry
    // send ether to the contract address
    // With at least 200 000 gas
    function() public payable {
        buyTokens(msg.sender);
    }
}