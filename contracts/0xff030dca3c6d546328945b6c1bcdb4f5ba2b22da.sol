pragma solidity ^0.4.13;

/**
 * Contract "Math"
 * Purpose: Math operations with safety checks
 */
library Math {

    /**
    * Multiplication with safety check
    */
    function Mul(uint a, uint b) constant internal returns (uint) {
      uint c = a * b;
      //check result should not be other wise until a=0
      assert(a == 0 || c / a == b);
      return c;
    }

    /**
    * Division with safety check
    */
    function Div(uint a, uint b) constant internal returns (uint) {
      //overflow check; b must not be 0
      assert(b > 0);
      uint c = a / b;
      assert(a == b * c + a % b);
      return c;
    }

    /**
    * Subtraction with safety check
    */
    function Sub(uint a, uint b) constant internal returns (uint) {
      //b must be greater that a as we need to store value in unsigned integer
      assert(b <= a);
      return a - b;
    }

    /**
    * Addition with safety check
    */
    function Add(uint a, uint b) constant internal returns (uint) {
      uint c = a + b;
      //result must be greater as a or b can not be negative
      assert(c>=a && c>=b);
      return c;
    }
}

/**
 * Contract "ERC20Basic"
 * Purpose: Defining ERC20 standard with basic functionality like - CheckBalance and Transfer including Transfer event
 */
contract ERC20Basic {
  
  //Give realtime totalSupply of EXH token
  uint public totalSupply;

  //Get EXH token balance for provided address in lowest denomination
  function balanceOf(address who) constant public returns (uint);

  //Transfer EXH token to provided address
  function transfer(address _to, uint _value) public returns(bool ok);

  //Emit Transfer event outside of blockchain for every EXH token transfers
  event Transfer(address indexed _from, address indexed _to, uint _value);
}

/**
 * Contract "ERC20"
 * Purpose: Defining ERC20 standard with more advanced functionality like - Authorize spender to transfer EXH token
 */
contract ERC20 is ERC20Basic {

  //Get EXH token amount that spender can spend from provided owner's account 
  function allowance(address owner, address spender) public constant returns (uint);

  //Transfer initiated by spender 
  function transferFrom(address _from, address _to, uint _value) public returns(bool ok);

  //Add spender to authrize for spending specified amount of EXH Token
  function approve(address _spender, uint _value) public returns(bool ok);

  //Emit event for any approval provided to spender
  event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * Contract "Ownable"
 * Purpose: Defines Owner for contract and provide functionality to transfer ownership to another account
 */
contract Ownable {

  //owner variable to store contract owner account
  address public owner;

  //Constructor for the contract to store owner's account on deployement
  function Ownable() public {
    owner = msg.sender;
  }
  
  //modifier to check transaction initiator is only owner
  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  //ownership can be transferred to provided newOwner. Function can only be initiated by contract owner's account
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) 
        owner = newOwner;
  }

}

/**
 * Contract "Pausable"
 * Purpose: Contract to provide functionality to pause and resume Sale in case of emergency
 */
contract Pausable is Ownable {

  //flag to indicate whether Sale is paused or not
  bool public stopped;

  //Emit event when any change happens in crowdsale state
  event StateChanged(bool changed);

  //modifier to continue with transaction only when Sale is not paused
  modifier stopInEmergency {
    require(!stopped);
    _;
  }

  //modifier to continue with transaction only when Sale is paused
  modifier onlyInEmergency {
    require(stopped);
    _;
  }

  // called by the owner on emergency, pause Sale
  function emergencyStop() external onlyOwner  {
    stopped = true;
    //Emit event when crowdsale state changes
    StateChanged(true);
  }

  // called by the owner on end of emergency, resumes Sale
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
    //Emit event when crowdsale state changes
    StateChanged(true);
  }

}

/**
 * Contract "EXH"
 * Purpose: Create EXH token
 */
contract EXH is ERC20, Ownable {

  using Math for uint;

  /* Public variables of the token */
  //To store name for token
  string public name;

  //To store symbol for token       
  string public symbol;

  //To store decimal places for token
  uint8 public decimals;    

  //To store decimal version for token
  string public version = 'v1.0'; 

  //To store current supply of EXH Token
  uint public totalSupply;

  //flag to indicate whether transfer of EXH Token is allowed or not
  bool public locked;

  //map to store EXH Token balance corresponding to address
  mapping(address => uint) balances;

  //To store spender with allowed amount of EXH Token to spend corresponding to EXH Token holder's account
  mapping (address => mapping (address => uint)) allowed;

  //To handle ERC20 short address attack  
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4);
     _;
  }
  
  // Lock transfer during Sale
  modifier onlyUnlocked() {
    require(!locked || msg.sender == owner);
    _;
  }

  //Contructor to define EXH Token token properties
  function EXH() public {

    // lock the transfer function during Sale
    locked = true;

    //initial token supply is 0
    totalSupply = 0;

    //Name for token set to EXH Token
    name = 'EXH Token';

    // Symbol for token set to 'EXH'
    symbol = 'EXH';
 
    decimals = 18;
  }
 
  //Implementation for transferring EXH Token to provided address 
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public onlyUnlocked returns (bool){

    //Check provided EXH Token should not be 0
    if (_value > 0 && !(_to == address(0))) {
      //deduct EXH Token amount from transaction initiator
      balances[msg.sender] = balances[msg.sender].Sub(_value);
      //Add EXH Token to balace of target account
      balances[_to] = balances[_to].Add(_value);
      //Emit event for transferring EXH Token
      Transfer(msg.sender, _to, _value);
      return true;
    }
    else{
      return false;
    }
  }

  //Transfer initiated by spender 
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) public onlyUnlocked returns (bool) {

    //Check provided EXH Token should not be 0
    if (_value > 0 && (_to != address(0) && _from != address(0))) {
      //Get amount of EXH Token for which spender is authorized
      var _allowance = allowed[_from][msg.sender];
      //Add amount of EXH Token in trarget account's balance
      balances[_to] = balances[_to].Add( _value);
      //Deduct EXH Token amount from _from account
      balances[_from] = balances[_from].Sub( _value);
      //Deduct Authorized amount for spender
      allowed[_from][msg.sender] = _allowance.Sub( _value);
      //Emit event for Transfer
      Transfer(_from, _to, _value);
      return true;
    }else{
      return false;
    }
  }

  //Get EXH Token balance for provided address
  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }
  
  //Add spender to authorize for spending specified amount of EXH Token 
  function approve(address _spender, uint _value) public returns (bool) {
    require(_spender != address(0));
    allowed[msg.sender][_spender] = _value;
    //Emit event for approval provided to spender
    Approval(msg.sender, _spender, _value);
    return true;
  }

  //Get EXH Token amount that spender can spend from provided owner's account 
  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
}

/**
 * Contract "Crowdsale"
 * Purpose: Contract for crowdsale of EXH Token
 */
contract Crowdsale is EXH, Pausable {

  using Math for uint;
  
  /* Public variables for Sale */

  // Sale start block
  uint public startBlock;   

  // Sale end block  
  uint public endBlock;  

  // To store maximum number of EXH Token to sell
  uint public maxCap;   

  // To store maximum number of EXH Token to sell in PreSale
  uint public maxCapPreSale;   

  // To store total number of ETH received
  uint public ETHReceived;    

  // Number of tokens that can be purchased with 1 Ether
  uint public PRICE;   

  // To indicate Sale status; crowdsaleStatus=0 => crowdsale not started; crowdsaleStatus=1=> crowdsale started; crowdsaleStatus=2=> crowdsale finished
  uint public crowdsaleStatus; 

  // To store crowdSale type; crowdSaleType=0 => PreSale; crowdSaleType=1 => CrowdSale
  uint public crowdSaleType; 

  //Total Supply in PreSale
  uint public totalSupplyPreSale; 

  //No of days for which presale will be open
  uint public durationPreSale;

  //Value of 1 ether, ie, 1 followed by 18 zero
  uint valueOneEther = 1e18;

  //No of days for which the complete crowdsale will run- presale  + crowdsale
  uint public durationCrowdSale;

  //Store total number of investors
  uint public countTotalInvestors;

  //Number of investors who have received refund
  uint public countInvestorsRefunded;
  
  //Set status of refund
  uint public refundStatus;

 //maxCAp for mint and transfer
  uint public maxCapMintTransfer ;

  //total supply for mint and transfer
  uint public totalSupplyMintTransfer;

  //total tokens sold in crowdsale
  uint public totalSupplyCrowdsale;

  //Stores total investros in crowdsale
  uint256 public countTotalInvestorsInCrowdsale;

  uint256 public countInvestorsRefundedInCrowdsale;

  //Structure for investors; holds received wei amount and EXH Token sent
  struct Investor {
    //wei received during PreSale
    uint weiReceivedCrowdsaleType0;
    //wei received during CrowdSale
    uint weiReceivedCrowdsaleType1;
    //Tokens sent during PreSale
    uint exhSentCrowdsaleType0;
    //Tokens sent during CrowdSale
    uint exhSentCrowdsaleType1;
    //Uniquely identify an investor(used for iterating)
    uint investorID;
  }

  //investors indexed by their ETH address
  mapping(address => Investor) public investors;
  //investors indexed by their IDs
  mapping (uint => address) public investorList;

  
  //Emit event on receiving ETH
  event ReceivedETH(address addr, uint value);

  //Emit event on transferring EXH Token to user when payment is received in traditional ways or B type EXH Token converted to A type EXH Token
  event MintAndTransferEXH(address addr, uint value, bytes32 comment);

  //constructor to initialize contract variables
  function Crowdsale() public {

    //Will be set in function start; Makes sure Sale will be started only when start() function is called
    startBlock = 0;   
    //Will be set in function start; Makes sure Sale will be started only when start() function is called        
    endBlock = 0;    
    //Max number of EXH Token to sell in CrowdSale[Includes the tokens sold in presale](33M)
    maxCap = 31750000e18;
    //Max number of EXH Token to sell in Presale(0.5M)
    maxCapPreSale = 500000e18;
    //1250000 Tokens avalable for Mint and Transfer
    maxCapMintTransfer = 1250000e18;
    // EXH Token per ether
    PRICE = 10; 
    //Indicates Sale status; Sale is not started yet
    crowdsaleStatus = 0;    
    //At time of deployment crowdSale type is set to Presale
    crowdSaleType = 0;
    // Number of days after which sale will start since the starting of presale, a single value to replace the hardcoded
    durationPreSale = 8 days + 1 hours;
    // Number of days for which complete crowdsale will run, ie, presale and crowdsale period
    durationCrowdSale = 28 days;
    // Investor count is 0 initially
    countTotalInvestors = 0;
    //Initially no investor has been refunded
    countInvestorsRefunded = 0;
    //Refund eligible or not
    refundStatus = 0;

    countTotalInvestorsInCrowdsale = 0;
    countInvestorsRefundedInCrowdsale = 0;
    
  }

  //Modifier to make sure transaction is happening during Sale
  modifier respectTimeFrame() {
    assert(!((now < startBlock) || (now > endBlock )));
    _;
  }

  /*
  * To start Sale from Presale
  */
  function start() public onlyOwner {
    //Set block number to current block number
    assert(startBlock == 0);
    startBlock = now;            
    //Set end block number
    endBlock = now.Add(durationCrowdSale.Add(durationPreSale));
    //Sale presale is started
    crowdsaleStatus = 1;
    //Emit event when crowdsale state changes
    StateChanged(true);  
  }

  /*
  * To start Crowdsale
  */
  function startSale() public onlyOwner
  {
    if(now > startBlock.Add(durationPreSale) && now <= endBlock){
        crowdsaleStatus = 1;
        crowdSaleType = 1;
        if(crowdSaleType != 1)
        {
          totalSupplyCrowdsale = totalSupplyPreSale;
        }
        //Emit event when crowdsale state changes
        StateChanged(true); 
    }
    else
      revert();
  }

  /*
  * To extend duration of Crowdsale
  */
  function updateDuration(uint time) public onlyOwner
  {
      require(time != 0);
      assert(startBlock != 0);
      assert(crowdSaleType == 1 && crowdsaleStatus != 2);
      durationCrowdSale = durationCrowdSale.Add(time);
      endBlock = endBlock.Add(time);
      //Emit event when crowdsale state changes
      StateChanged(true);
  }

  /*
  * To set price for EXH Token
  */
  function setPrice(uint price) public onlyOwner
  {
      require( price != 0);
      PRICE = price;
      //Emit event when crowdsale state changes
      StateChanged(true);
  }
  
  /*
  * To enable transfers of EXH Token after completion of Sale
  */
  function unlock() public onlyOwner
  {
    locked = false;
    //Emit event when crowdsale state changes
    StateChanged(true);
  }
  
  //fallback function i.e. payable; initiates when any address transfers Eth to Contract address
  function () public payable {
  //call createToken function with account who transferred Eth to contract address
    createTokens(msg.sender);
  }

  /*
  * To create EXH Token and assign to transaction initiator
  */
  function createTokens(address beneficiary) internal stopInEmergency  respectTimeFrame {
    //Make sure Sale is running
    assert(crowdsaleStatus == 1); 
    //Don't accept fund to purchase less than 1 EXH Token   
    require(msg.value >= 1 ether/getPrice());   
    //Make sure sent Eth is not 0           
    require(msg.value != 0);
    //Calculate EXH Token to send
    uint exhToSend = msg.value.Mul(getPrice());

    //Make entry in Investor indexed with address
    Investor storage investorStruct = investors[beneficiary];

    // For Presale
    if(crowdSaleType == 0){
      require(exhToSend.Add(totalSupplyPreSale) <= maxCapPreSale);
      totalSupplyPreSale = totalSupplyPreSale.Add(exhToSend);
      if((maxCapPreSale.Sub(totalSupplyPreSale) < valueOneEther)||(now > (startBlock.Add(7 days + 1 hours)))){
        crowdsaleStatus = 2;
      }        
      investorStruct.weiReceivedCrowdsaleType0 = investorStruct.weiReceivedCrowdsaleType0.Add(msg.value);
      investorStruct.exhSentCrowdsaleType0 = investorStruct.exhSentCrowdsaleType0.Add(exhToSend);
    }

    // For CrowdSale
    else if (crowdSaleType == 1){
      if (exhToSend.Add(totalSupply) > maxCap ) {
        revert();
      }
      totalSupplyCrowdsale = totalSupplyCrowdsale.Add(exhToSend);
      if(maxCap.Sub(totalSupplyCrowdsale) < valueOneEther)
      {
        crowdsaleStatus = 2;
      }
      if(investorStruct.investorID == 0 || investorStruct.weiReceivedCrowdsaleType1 == 0){
        countTotalInvestorsInCrowdsale++;
      }
      investorStruct.weiReceivedCrowdsaleType1 = investorStruct.weiReceivedCrowdsaleType1.Add(msg.value);
      investorStruct.exhSentCrowdsaleType1 = investorStruct.exhSentCrowdsaleType1.Add(exhToSend);
    }

    //If it is a new investor, then create a new id
    if(investorStruct.investorID == 0){
        countTotalInvestors++;
        investorStruct.investorID = countTotalInvestors;
        investorList[countTotalInvestors] = beneficiary;
    }

    //update total supply of EXH Token
    totalSupply = totalSupply.Add(exhToSend);
    // Update the total wei collected during Sale
    ETHReceived = ETHReceived.Add(msg.value);  
    //Update EXH Token balance for transaction initiator
    balances[beneficiary] = balances[beneficiary].Add(exhToSend);
    //Emit event for contribution
    ReceivedETH(beneficiary,ETHReceived); 
    //ETHReceived during Sale will remain with contract
    GetEXHFundAccount().transfer(msg.value);
    //Emit event when crowdsale state changes
    StateChanged(true);
  }

  /*
  * To enable vesting of B type EXH Token
  */
  function MintAndTransferToken(address beneficiary,uint exhToCredit,bytes32 comment) external onlyOwner {
    //Available after the crowdsale is started
    assert(startBlock != 0);
    //Check whether tokens are available or not
    assert(totalSupplyMintTransfer <= maxCapMintTransfer);
    //Check whether the amount of token are available to transfer
    require(totalSupplyMintTransfer.Add(exhToCredit) <= maxCapMintTransfer);
    //Update EXH Token balance for beneficiary
    balances[beneficiary] = balances[beneficiary].Add(exhToCredit);
    //Update total supply for EXH Token
    totalSupply = totalSupply.Add(exhToCredit);
    //update total supply for EXH token in mint and transfer
    totalSupplyMintTransfer = totalSupplyMintTransfer.Add(exhToCredit);
    // send event for transferring EXH Token on offline payment
    MintAndTransferEXH(beneficiary, exhToCredit,comment);
    //Emit event when crowdsale state changes
    StateChanged(true);  
  }

  /*
  * To get price for EXH Token
  */
  function getPrice() public constant returns (uint result) {
      if (crowdSaleType == 0) {
            return (PRICE.Mul(100)).Div(70);
      }
      if (crowdSaleType == 1) {
          uint crowdsalePriceBracket = 1 weeks;
          uint startCrowdsale = startBlock.Add(durationPreSale);
            if (now > startCrowdsale && now <= startCrowdsale.Add(crowdsalePriceBracket)) {
                return ((PRICE.Mul(100)).Div(80));
            }else if (now > startCrowdsale.Add(crowdsalePriceBracket) && now <= (startCrowdsale.Add(crowdsalePriceBracket.Mul(2)))) {
                return (PRICE.Mul(100)).Div(85);
            }else if (now > (startCrowdsale.Add(crowdsalePriceBracket.Mul(2))) && now <= (startCrowdsale.Add(crowdsalePriceBracket.Mul(3)))) {
                return (PRICE.Mul(100)).Div(90);
            }else if (now > (startCrowdsale.Add(crowdsalePriceBracket.Mul(3))) && now <= (startCrowdsale.Add(crowdsalePriceBracket.Mul(4)))) {
                return (PRICE.Mul(100)).Div(95);
            }
      }
      return PRICE;
  }

  function GetEXHFundAccount() internal returns (address) {
    uint remainder = block.number%10;
    if(remainder==0){
      return 0xda141e704601f8C8E343C5cA246355c812238D91;
    } else if(remainder==1){
      return 0x2381963906C434dD4639489Bec9A2bB55D83cC14;
    } else if(remainder==2){
      return 0x537C7119452A7814ABD1C4ED71F6eCD25225C0F6;
    } else if(remainder==3){
      return 0x1F04880fFdFff05d36307f69EAAc8645B98449E2;
    } else if(remainder==4){
      return 0xd72B82b69FEe29d81f5e2DA66aB91014aDaE0AA0;
    } else if(remainder==5){
      return 0xf63bef6B67064053191dc4bC6F1D06592C07925f;
    } else if(remainder==6){
      return 0x7381F9C5d35E895e80aDeC1e1A3541860F876600;
    } else if(remainder==7){
      return 0x370301AE4659D2975be9F976011c787EC59e0645;
    } else if(remainder==8){
      return 0x2C041b6A7fF277966cB0b4cb966aaB8Fc1178ac5;
    }else {
      return 0x8A401290A39Dc8D046e42BABaf5a818e29ae4fda;
    }
  }

  /*
  * Finalize the crowdsale
  */
  function finalize() public onlyOwner {
    //Make sure Sale is running
    assert(crowdsaleStatus==1 && crowdSaleType==1);
    // cannot finalise before end or until maxcap is reached
      assert(!((totalSupplyCrowdsale < maxCap && now < endBlock) && (maxCap.Sub(totalSupplyCrowdsale) >= valueOneEther)));  
      //Indicates Sale is ended
      
      //Checks if the fundraising goal is reached in crowdsale or not
      if (totalSupply < 5300000e18)
        refundStatus = 2;
      else
        refundStatus = 1;
      
    //crowdsale is ended
    crowdsaleStatus = 2;
    //Emit event when crowdsale state changes
    StateChanged(true);
  }

  /*
  * Refund the investors in case target of crowdsale not achieved
  */
  function refund() public onlyOwner {
      assert(refundStatus == 2);
      uint batchSize = countInvestorsRefunded.Add(50) < countTotalInvestors ? countInvestorsRefunded.Add(50): countTotalInvestors;
      for(uint i=countInvestorsRefunded.Add(1); i <= batchSize; i++){
          address investorAddress = investorList[i];
          Investor storage investorStruct = investors[investorAddress];
          //If purchase has been made during CrowdSale
          if(investorStruct.exhSentCrowdsaleType1 > 0 && investorStruct.exhSentCrowdsaleType1 <= balances[investorAddress]){
              //return everything
              investorAddress.transfer(investorStruct.weiReceivedCrowdsaleType1);
              //Reduce ETHReceived
              ETHReceived = ETHReceived.Sub(investorStruct.weiReceivedCrowdsaleType1);
              //Update totalSupply
              totalSupply = totalSupply.Sub(investorStruct.exhSentCrowdsaleType1);
              // reduce balances
              balances[investorAddress] = balances[investorAddress].Sub(investorStruct.exhSentCrowdsaleType1);
              //set everything to zero after transfer successful
              investorStruct.weiReceivedCrowdsaleType1 = 0;
              investorStruct.exhSentCrowdsaleType1 = 0;
              countInvestorsRefundedInCrowdsale = countInvestorsRefundedInCrowdsale.Add(1);
          }
      }
      //Update the number of investors that have recieved refund
      countInvestorsRefunded = batchSize;
      StateChanged(true);
  }

  /*
   * Failsafe drain
   */
  function drain() public onlyOwner {
    GetEXHFundAccount().transfer(this.balance);
  }

  /*
  * Function to add Ether in the contract 
  */
  function fundContractForRefund() payable{
    // StateChanged(true);
  }

}