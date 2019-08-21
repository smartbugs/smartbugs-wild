pragma solidity ^0.4.17;

library SafeMath {

    /**
    * Multiplication with safety check
    */
    function Mul(uint256 a, uint256 b) pure internal returns (uint256) {
      uint256 c = a * b;
      //check result should not be other wise until a=0
      assert(a == 0 || c / a == b);
      return c;
    }

    /**
    * Division with safety check
    */
    function Div(uint256 a, uint256 b) pure internal returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    /**
    * Subtraction with safety check
    */
    function Sub(uint256 a, uint256 b) pure internal returns (uint256) {
      //b must be greater that a as we need to store value in unsigned integer
      assert(b <= a);
      return a - b;
    }

    /**
    * Addition with safety check
    */
    function Add(uint256 a, uint256 b) pure internal returns (uint256) {
      uint256 c = a + b;
      //We need to check result greater than only one number for valid Addition
      //refer https://ethereum.stackexchange.com/a/15270/16048
      assert(c >= a);
      return c;
    }
}

/**
 * Contract "ERC20Basic"
 * Purpose: Defining ERC20 standard with basic functionality like - CheckBalance and Transfer including Transfer event
 */
contract ERC20Basic {

  //Give realtime totalSupply of IAC token
  uint256 public totalSupply;

  //Get IAC token balance for provided address
  function balanceOf(address who) view public returns (uint256);

  //Transfer IAC token to provided address
  function transfer(address _to, uint256 _value) public returns(bool ok);

  //Emit Transfer event outside of blockchain for every IAC token transfer
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

/**
 * Contract "ERC20"
 * Purpose: Defining ERC20 standard with more advanced functionality like - Authorize spender to transfer IAC token
 */
contract ERC20 is ERC20Basic {

  //Get IAC token amount that spender can spend from provided owner's account
  function allowance(address owner, address spender) public view returns (uint256);

  //Transfer initiated by spender
  function transferFrom(address _from, address _to, uint256 _value) public returns(bool ok);

  //Add spender to authrize for spending specified amount of IAC Token
  function approve(address _spender, uint256 _value) public returns(bool ok);

  //Emit event for any approval provided to spender
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * Contract "Ownable"
 * Purpose: Defines Owner for contract and provide functionality to transfer ownership to another account
 */
contract Ownable {

  //owner variable to store contract owner account
  address public owner;

  //Constructor for the contract to store owner's account on deployment
  function Ownable() public {
    owner = msg.sender;
  }

  //modifier to check transaction initiator is only owner
  modifier onlyOwner() {
    require (msg.sender == owner);
      _;
  }

  //ownership can be transferred to provided newOwner. Function can only be initiated by contract owner's account
  function transferOwnership(address newOwner) public onlyOwner {
    require (newOwner != address(0));
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
 * Contract "IAC"
 * Purpose: Create IAC token
 */
contract Injii is ERC20, Ownable {

  using SafeMath for uint256;

  /* Public variables of the token */
  //To store name for token
  string public constant name = "Injii Access Coins";

  //To store symbol for token
  string public constant symbol = "IAC";

  //To store decimal places for token
  uint8 public constant decimals = 0;

  //To store decimal version for token
  string public version = 'v1.0';

  //flag to indicate whether transfer of IAC Token is allowed or not
  bool public locked;

  //map to store IAC Token balance corresponding to address
  mapping(address => uint256) balances;

  //To store spender with allowed amount of IAC Token to spend corresponding to IAC Token holder's account
  mapping (address => mapping (address => uint256)) allowed;

  //To handle ERC20 short address attack
  modifier onlyPayloadSize(uint256 size) {
     require(msg.data.length >= size + 4);
     _;
  }

  // Lock transfer during Sale
  modifier onlyUnlocked() {
    require(!locked);
    _;
  }

  //Contructor to define IAC Token properties
  function Injii() public {
    // lock the transfer function during Sale
    locked = true;

    //initial token supply is 0
    totalSupply = 0;
  }

  //Implementation for transferring IAC Token to provided address
  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public onlyUnlocked returns (bool){

    //Check provided IAC Token should not be 0
    if (_to != address(0) && _value >= 1) {
      //deduct IAC Token amount from transaction initiator
      balances[msg.sender] = balances[msg.sender].Sub(_value);
      //Add IAC Token to balace of target account
      balances[_to] = balances[_to].Add(_value);
      //Emit event for transferring IAC Token
      Transfer(msg.sender, _to, _value);
      return true;
    }
    else{
      return false;
    }
  }

  //Transfer initiated by spender
  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public onlyUnlocked returns (bool) {

    //Check provided IAC Token should not be 0
    if (_to != address(0) && _from != address(0)) {
      //Get amount of IAC Token for which spender is authorized
      var _allowance = allowed[_from][msg.sender];
      //Add amount of IAC Token in trarget account's balance
      balances[_to] = balances[_to].Add(_value);
      //Deduct IAC Token amount from _from account
      balances[_from] = balances[_from].Sub(_value);
      //Deduct Authorized amount for spender
      allowed[_from][msg.sender] = _allowance.Sub(_value);
      //Emit event for Transfer
      Transfer(_from, _to, _value);
      return true;
    }else{
      return false;
    }
  }

  //Get IAC Token balance for provided address
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  //Add spender to authorize for spending specified amount of IAC Token
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(_spender != address(0));
    //do not allow decimals
    uint256 iacToApprove = _value;
    allowed[msg.sender][_spender] = iacToApprove;
    //Emit event for approval provided to spender
    Approval(msg.sender, _spender, iacToApprove);
    return true;
  }

  //Get IAC Token amount that spender can spend from provided owner's account
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Metadata {
    
    address public owner;
    
    mapping (uint => address) registerMap;

    function Metadata() public {
        owner = msg.sender;
        registerMap[0] = msg.sender;
    }

    //get contract address by its ID
    function getAddress (uint addressId) public view returns (address){
        return registerMap[addressId];
    }

    //add or replace contract address by id. This is also the order of deployment
    //0 = owner
    //1 = Ecosystem
    //2 = Crowdsale. This will deploy the token contract also.
    //3 = Company Inventory
    function addAddress (uint addressId, address addressContract) public {
        assert(addressContract != 0x0 );
        require (owner == msg.sender || owner == tx.origin);
        registerMap[addressId] = addressContract;
    }
}

contract Ecosystem is Ownable{


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    //variable of type metadata to store metadata contract object
    Metadata private objMetadata;
    Crowdsale private objCrowdsale;
    uint256 constant private ecosystemContractID = 1;
    uint256 constant private crowdsaleContractID = 2;
    bool public crowdsaleAddressSet;
    event TokensReceived(address receivedFrom, uint256 numberOfTokensReceive);

    //Constructor
    function Ecosystem(address _metadataContractAddr) public {
        assert(_metadataContractAddr != address(0));
        //passing address of meta data contract to metadata type address variable
        objMetadata = Metadata(_metadataContractAddr);
        //register this contract in metadata
        objMetadata.addAddress(ecosystemContractID, this);
    }

    function SetCrowdsaleAddress () public onlyOwner {
        require(!crowdsaleAddressSet);
        address crowdsaleContractAddress = objMetadata.getAddress(crowdsaleContractID);
        assert(crowdsaleContractAddress != address(0));
        objCrowdsale = Crowdsale(crowdsaleContractAddress);
        crowdsaleAddressSet = true;
    }

    function rewardUser(address user, uint256 iacToSend) public onlyOwner{
        assert(crowdsaleAddressSet);
        objCrowdsale.transfer(user, iacToSend);
    }

    function tokenFallback(address _from, uint _value){
        TokensReceived(_from, _value);
    }

}

contract CompanyInventory is Ownable{
    using SafeMath for uint256;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    //record timestamp when the lock was initiated
    uint256 public startBlock;
    //to record how many tokens are unlocked
    uint256 public unlockedTokens;
    uint256 public initialReleaseDone = 0;
    uint256 public secondReleaseDone = 0;
    uint256 public totalSuppliedAfterLock = 0;
    uint256 public balance = 0;
    uint256 public totalSupplyFromInventory;
    //total number of tokens available in inventory
    uint256 public totalRemainInInventory;
    //variable of type metadata to store metadata contract object
    Metadata private objMetadata;
    Crowdsale private objCrowdsale;
    uint256 constant private crowdsaleContractID = 2;
    uint256 constant private inventoryContractID = 3;
    //Emit event when tokens are transferred from company inventory
    event TransferredUnlockedTokens(address addr, uint value, bytes32 comment);
    //Emit event when any change happens in crowdsale state
    event StateChanged(bool changed);
    
    //constructor
    function CompanyInventory(address _metadataContractAddr) public {
        assert(_metadataContractAddr != address(0));
        //passing address of meta data contract to metadat type address variable
        objMetadata = Metadata(_metadataContractAddr);
        objMetadata.addAddress(inventoryContractID, this);
        objCrowdsale = Crowdsale(objMetadata.getAddress(crowdsaleContractID));
    }
    
    function initiateLocking (uint256 _alreadyTransferredTokens) public {
        require(msg.sender == objMetadata.getAddress(crowdsaleContractID) && startBlock == 0);
        startBlock = now;
        unlockedTokens = 0;
        balance = objCrowdsale.balanceOf(this);
        totalSupplyFromInventory = _alreadyTransferredTokens;
        totalRemainInInventory = balance.Add(_alreadyTransferredTokens).Sub(_alreadyTransferredTokens);
        StateChanged(true);
    }
    
    function releaseTokens () public onlyOwner {
        require(startBlock > 0);
        if(initialReleaseDone == 0){
            require(now >= startBlock.Add(1 years));
            unlockedTokens =  balance/2;
            initialReleaseDone = 1;
        }
        else if(secondReleaseDone == 0){
            require(now >= startBlock.Add(2 years));
            unlockedTokens = balance;
            secondReleaseDone = 1;
        }
        StateChanged(true);
    }
    
    /*
    * To enable transferring tokens from company inventory
    */
    function TransferFromCompanyInventory(address beneficiary,uint256 iacToCredit,bytes32 comment) onlyOwner external {
        require(beneficiary != address(0));
        require(totalSuppliedAfterLock.Add(iacToCredit) <= unlockedTokens);
        objCrowdsale.transfer(beneficiary,iacToCredit);
        //Update total supply for IAC Token
        totalSuppliedAfterLock = totalSuppliedAfterLock.Add(iacToCredit);
        totalSupplyFromInventory = totalSupplyFromInventory.Add(iacToCredit);
        //total number of tokens remaining in inventory
        totalRemainInInventory = totalRemainInInventory.Sub(iacToCredit);
        // send event for transferring IAC Token on offline payment
        TransferredUnlockedTokens(beneficiary, iacToCredit, comment);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }
}

contract Crowdsale is Injii, Pausable {
    using SafeMath for uint256;
    //Record the timestamp when sale starts
    uint256 public startBlock;
    //No of days for which the complete crowdsale will run
    uint256 public constant durationCrowdSale = 25 days;
    //the gap period between ending of primary crowdsale and starting of secondary crowdsale
    uint256 public constant gapInPrimaryCrowdsaleAndSecondaryCrowdsale = 2 years;
    //Record the timestamp when sale ends
    uint256 public endBlock;

    //maximum number of tokens available in company inventory
    uint256 public constant maxCapCompanyInventory = 250e6;
    //Maximum number of tokens in crowdsale = 500M tokens
    uint256 public constant maxCap = 500e6;
    uint256 public constant maxCapEcosystem = 250e6;
    uint256 public constant numberOfTokensToAvail50PercentDiscount = 2e6;
    uint256 public constant numberOfTokensToAvail25percentDiscount = 5e5;
    uint256 public constant minimumNumberOfTokens = 2500;
    uint256 public targetToAchieve;

    bool public inventoryLocked = false;
    uint256 public totalSupply;
    //Total tokens for crowdsale including mint and transfer 
    uint256 public totalSupplyForCrowdsaleAndMint = 0;
    //coinbase account where all ethers should go
    address public coinbase;
    //To store total number of ETH received
    uint256 public ETHReceived;
    //total number of tokens supplied from company inventory
    uint256 public totalSupplyFromInventory;
    //total number of tokens available in inventory
    uint256 public totalRemainInInventory;
    //number of tokens per ether
    uint256 public getPrice;
    // To indicate Sale status
    //crowdsaleStatus=0 => crowdsale not started
    //crowdsaleStatus=1 => crowdsale started;
    //crowdsaleStatus=2 => crowdsale finished
    uint256 public crowdsaleStatus;
    //type of CrowdSale:
    //1 = crowdsale
    //2 = seconadry crowdsale for remaining tokens
    uint8 public crowdSaleType;
    //Emit event on receiving ETH
    event ReceivedETH(address addr, uint value);
    //Emit event on transferring IAC Token to user when payment is received in traditional ways
    event MintAndTransferIAC(address addr, uint value, bytes32 comment);
    //Emit event when tokens are transferred from company inventory
    event SuccessfullyTransferedFromCompanyInventory(address addr, uint value, bytes32 comment);
    //event to log token supplied
    event TokenSupplied(address indexed beneficiary, uint256 indexed tokens, uint256 value);
    //Emit event when any change happens in crowdsale state
    event StateChanged(bool changed);

    //variable to store object of Metadata contract
    Metadata private objMetada;
    Ecosystem private objEcosystem;
    CompanyInventory private objCompanyInventory;
    address private ecosystemContractAddress;
    //ID of Ecosystem contract
    uint256 constant ecosystemContractID = 1;
    //ID of this contract
    uint256 constant private crowdsaleContractID = 2;
    //ID of company inventory
    uint256 constant private inventoryContractID = 3;

    /**
     * @dev Constuctor of the contract
     *
     */
    function Crowdsale() public {
        address _metadataContractAddr = 0x8A8473E51D7f562ea773A019d7351A96c419B633;
        startBlock = 0;
        endBlock = 0;
        crowdSaleType = 1;
        totalSupply = maxCapEcosystem;
        crowdsaleStatus=0;
        coinbase = 0xA84196972d6b5796cE523f861CC9E367F739421F;
        owner = msg.sender;
        totalSupplyFromInventory=0;
        totalRemainInInventory = maxCapCompanyInventory;
        getPrice = 2778;
        objMetada = Metadata(_metadataContractAddr);
        ecosystemContractAddress = objMetada.getAddress(ecosystemContractID);
        assert(ecosystemContractAddress != address(0));
        objEcosystem = Ecosystem(ecosystemContractAddress);
        objMetada.addAddress(crowdsaleContractID, this);
        balances[ecosystemContractAddress] = maxCapEcosystem;
        targetToAchieve = (50000*100e18)/(12*getPrice);
    }

    //Verify if the sender is owner
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }

    //Modifier to make sure transaction is happening during sale when it is not stopped
    modifier respectTimeFrame() {
      // When contract is deployed, startblock is 0. When sale is started, startBlock should not be zero
      assert(startBlock != 0 && !stopped && crowdsaleStatus == 1);
      //check if requirest is made after time is up
      if(now > endBlock){
          //tokens cannot be bought after time is up
          revert();
      }
      _;
    }

    /**
     * @dev To upgrade ecosystem contract
     *
     */
    function SetEcosystemContract () public onlyOwner {
        uint256 balanceOfOldEcosystem = balances[ecosystemContractAddress];
        balances[ecosystemContractAddress] = 0;
        //find new address of contract from metadata
        ecosystemContractAddress = objMetada.getAddress(ecosystemContractID);
        //update the balance of new contract
        balances[ecosystemContractAddress] = balanceOfOldEcosystem;
        assert(ecosystemContractAddress != address(0));
        objEcosystem = Ecosystem(ecosystemContractAddress);
    }

    function GetIACFundAccount() internal view returns (address) {
        uint remainder = block.number%10;
        if(remainder==0){
            return 0x8786DB52D292551f4139a963F79Ce1018d909655;
        } else if(remainder==1){
            return 0x11818E22CDc0592F69a22b30CF0182888f315FBC;
        } else if(remainder==2){
            return 0x17616b652C3c2eAf2aa82a72Bd2b3cFf40A854fE;
        } else if(remainder==3){
            return 0xD433632CA5cAFDa27655b8E536E5c6335343d408;
        } else if(remainder==4){
            return 0xb0Dc59A8312D901C250f8975E4d99eAB74D79484;
        } else if(remainder==5){
            return 0x0e6B1F7955EF525C2707799963318c49f9Ad7374;
        } else if(remainder==6){
            return 0x2fE6C4D2DC0EB71d2ac885F64f029CE78b9F98d9;
        } else if(remainder==7){
            return 0x0a7cD1cCc55191F8046D1023340bdfdfa475F267;
        } else if(remainder==8){
            return 0x76C40fDFd3284da796851611e7e9e8De0CcA546C;
        }else {
            return 0xe4FE5295772997272914447549D570882423A227;
        }
  }
    /*
    * To start Crowdsale
    */
    function startSale() public onlyOwner {
        assert(startBlock == 0);
        //record timestamp when sale is started
        startBlock = now;
        //change the type of sale to crowdsale
        crowdSaleType = 1;
        //Change status of crowdsale to running
        crowdsaleStatus = 1;
        //Crowdsale should end after its proper duration when started
        endBlock = now.Add(durationCrowdSale);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    /*
    * To start crowdsale after 2 years(gapInPrimaryCrowdsaleAndSecondaryCrowdsale)
    */
    function startSecondaryCrowdsale (uint256 durationSecondaryCrowdSale) public onlyOwner {
      //crowdsale should have been stopped
      //startBlock should have a value. It show that sale was started at some point of time
      //endBlock > the duration of crowdsale: this ensures endblock was updated by finalize
      assert(crowdsaleStatus == 2 && crowdSaleType == 1);
      if(now > endBlock.Add(gapInPrimaryCrowdsaleAndSecondaryCrowdsale)){
          //crowdsale status set to "running"
          crowdsaleStatus = 1;
          //change the type of CrowdSale
          crowdSaleType = 2;
          //Duration is received in days
          endBlock = now.Add(durationSecondaryCrowdSale * 86400);
          //Emit event when crowdsale state changes
          StateChanged(true);
      }
      else
        revert();
    }
    

    /*
    * To set price for IAC Token per ether
    */
    function setPrice(uint _tokensPerEther) public onlyOwner
    {
        require( _tokensPerEther != 0);
        getPrice = _tokensPerEther;
        targetToAchieve = (50000*100e18)/(12*_tokensPerEther);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    /*
    * To create and assign IAC Tokens to transaction initiator
    */
    function createTokens(address beneficiary) internal stopInEmergency  respectTimeFrame {
        //Make sure sent Eth is not 0
        require(msg.value != 0);
        //Initially count without giving discount
        uint256 iacToSend = (msg.value.Mul(getPrice))/1e18;
        //calculate price to avail 50% discount
        uint256 priceToAvail50PercentDiscount = numberOfTokensToAvail50PercentDiscount.Div(2*getPrice).Mul(1e18);
        //calculate price of tokens at 25% discount
        uint256 priceToAvail25PercentDiscount = 3*numberOfTokensToAvail25percentDiscount.Div(4*getPrice).Mul(1e18);
        //Check if less than minimum number of tokens are bought
        if(iacToSend < minimumNumberOfTokens){
            revert();
        }
        else if(msg.value >= priceToAvail25PercentDiscount && msg.value < priceToAvail50PercentDiscount){
            //grant tokens according to 25% discount
            iacToSend = (((msg.value.Mul(getPrice)).Mul(4)).Div(3))/1e18;
        }
        //check if user is eligible for 50% discount
        else if(msg.value >= priceToAvail50PercentDiscount){
            //here tokens are given at 50% discount
            iacToSend = (msg.value.Mul(2*getPrice))/1e18;
        }
        //default case: no discount
        else {
            iacToSend = (msg.value.Mul(getPrice))/1e18;
        }
        //we should not be supplying more tokens than maxCap
        assert(iacToSend.Add(totalSupplyForCrowdsaleAndMint) <= maxCap);
        //increase totalSupply
        totalSupply = totalSupply.Add(iacToSend);

        totalSupplyForCrowdsaleAndMint = totalSupplyForCrowdsaleAndMint.Add(iacToSend);

        if(ETHReceived < targetToAchieve){
            //transfer ether to coinbase account
            coinbase.transfer(msg.value);
        }
        else{
            GetIACFundAccount().transfer(msg.value);
        }

        //store ETHReceived
        ETHReceived = ETHReceived.Add(msg.value);
        //Emit event for contribution
        ReceivedETH(beneficiary,ETHReceived);
        balances[beneficiary] = balances[beneficiary].Add(iacToSend);

        TokenSupplied(beneficiary, iacToSend, msg.value);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    /*
    * To enable owner to mint tokens
    */
    function MintAndTransferToken(address beneficiary,uint256 iacToCredit,bytes32 comment) external onlyOwner {
        //Available after the crowdsale is started
        assert(crowdsaleStatus == 1 && beneficiary != address(0));
        //number of tokens to mint should be whole number
        require(iacToCredit >= 1);
        //Check whether tokens are available or not
        assert(totalSupplyForCrowdsaleAndMint <= maxCap);
        //Check whether the amount of token are available to transfer
        require(totalSupplyForCrowdsaleAndMint.Add(iacToCredit) <= maxCap);
        //Update IAC Token balance for beneficiary
        balances[beneficiary] = balances[beneficiary].Add(iacToCredit);
        //Update total supply for IAC Token
        totalSupply = totalSupply.Add(iacToCredit);
        totalSupplyForCrowdsaleAndMint = totalSupplyForCrowdsaleAndMint.Add(iacToCredit);
        // send event for transferring IAC Token on offline payment
        MintAndTransferIAC(beneficiary, iacToCredit, comment);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    /*
    * To enable transferring tokens from company inventory
    */
    function TransferFromCompanyInventory(address beneficiary,uint256 iacToCredit,bytes32 comment) external onlyOwner {
        //Available after the crowdsale is started
        assert(startBlock != 0 && beneficiary != address(0));
        //Check whether tokens are available or not
        assert(totalSupplyFromInventory <= maxCapCompanyInventory && !inventoryLocked);
        //number of tokens to transfer should be whole number
        require(iacToCredit >= 1);
        //Check whether the amount of token are available to transfer
        require(totalSupplyFromInventory.Add(iacToCredit) <= maxCapCompanyInventory);
        //Update IAC Token balance for beneficiary
        balances[beneficiary] = balances[beneficiary].Add(iacToCredit);
        //Update total supply for IAC Token
        totalSupplyFromInventory = totalSupplyFromInventory.Add(iacToCredit);
        //Update total supply for IAC Token
        totalSupply = totalSupply.Add(iacToCredit);
        //total number of tokens remaining in inventory
        totalRemainInInventory = totalRemainInInventory.Sub(iacToCredit);
        //send event for transferring IAC Token on offline payment
        SuccessfullyTransferedFromCompanyInventory(beneficiary, iacToCredit, comment);
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    function LockInventory () public onlyOwner {
        require(startBlock > 0 && now >= startBlock.Add(durationCrowdSale.Add(90 days)) && !inventoryLocked);
        address inventoryContractAddress = objMetada.getAddress(inventoryContractID);
        require(inventoryContractAddress != address(0));
        balances[inventoryContractAddress] = totalRemainInInventory;
        totalSupply = totalSupply.Add(totalRemainInInventory);
        objCompanyInventory = CompanyInventory(inventoryContractAddress);
        objCompanyInventory.initiateLocking(totalSupplyFromInventory);
        inventoryLocked = true;
    }

    /*
    * Finalize the crowdsale
    */
    function finalize() public onlyOwner {
          //Make sure Sale is running
          //finalize should be called only if crowdsale is running
          assert(crowdsaleStatus == 1 && (crowdSaleType == 1 || crowdSaleType == 2));
          //finalize only if less than minimum number of tokens are left or if time is up
          assert(maxCap.Sub(totalSupplyForCrowdsaleAndMint) < minimumNumberOfTokens || now >= endBlock);
          //crowdsale is ended
          crowdsaleStatus = 2;
          //update endBlock to the actual ending of crowdsale
          endBlock = now;
          //Emit event when crowdsale state changes
          StateChanged(true);
    }

    /*
    * To enable transfers of IAC Token anytime owner wishes
    */
    function unlock() public onlyOwner
    {
        //unlock will happen after 90 days of ending of crowdsale
        //crowdsale itself being of 25 days
        assert(crowdsaleStatus==2 && now >= startBlock.Add(durationCrowdSale.Add(90 days)));
        locked = false;
        //Emit event when crowdsale state changes
        StateChanged(true);
    }

    /**
     * @dev payable function to accept ether.
     *
     */
    function () public payable {
        createTokens(msg.sender);
    }

   /*
    * Failsafe drain
    */
   function drain() public  onlyOwner {
        GetIACFundAccount().transfer(this.balance);
  }
}