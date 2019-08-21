pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
  constructor() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/**
 * @title ERC223Interface
 * @dev Simpler version of ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */

contract ERC223Interface {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    function transfer(address to, uint value, bytes data) public;
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

/**
 * @title Contract that will work with ERC223 tokens.
 */
 
contract ERC223ReceivingContract { 
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

/**
 * @title Reference implementation of the ERC223 standard token.
 */
 
contract ERC223Token is ERC223Interface, Pausable  {
    using SafeMath for uint;

    mapping(address => uint) balances; // List of user balances.
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
     
    function transfer(address _to, uint _value, bytes _data) public whenNotPaused {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public whenNotPaused {
        uint codeLength;
        bytes memory empty;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
    }

    
    /**
     * @dev Returns balance of the `_owner`.
     *
     * @param _owner   The address whose balance will be returned.
     * @return balance Balance of the `_owner`.
     */
    function balanceOf(address _owner) public whenNotPaused constant returns (uint balance)  {
        return balances[_owner];
    }
}


contract LinTokenMint is ERC223Token {
    
    string public constant name = "LinToken";   // Set the name for display purposes
    string public constant symbol = "LIN";  // Set the symbol for display purposes
    uint256 public constant decimals = 18;  // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));    // Set the initial supply
    uint256 public totalSupply = INITIAL_SUPPLY;    // Set the total supply
    uint256 internal Percent = INITIAL_SUPPLY.div(100); // Set the 1 percent of the total supply
    
    uint256 public ICOSupply = Percent.mul(50); // Set the 50 percent of the ico supply
    uint256 internal LinNetOperationSupply = Percent.mul(30);   // Set the 30 percent of the LinNetOperation supply
    uint256 internal LinTeamSupply = Percent.mul(10);   // Set the 10 percent of the LinTeam supply
    uint256 internal SympoSiumSupply = Percent.mul(5);  // Set the 5 percent of the SympoSium supply
    uint256 internal BountySupply = Percent.mul(5).div(2);  // Set the 2.5 percent of the SympoSium supply
    uint256 internal preICOSupply = Percent.mul(5).div(2);  // Set the 2.5 percent of the preICO supply
    
    address internal LinNetOperation = 0x48a240d2aB56FE372e9867F19C7Ba33F60cB32fc;  // Set a LinNetOperation's address
    address internal LinTeam = 0xF55f80d09e551c35735ed4af107f6d361a7eD623;  // Set a LinTeam's address
    address internal SympoSium = 0x5761DB2F09A0DF0b03A885C61E618CFB4Da7492D;    // Set a SympoSium's address
    address internal Bounty = 0x76e1173022e0fD87D15AA90270828b1a6a54Eac1;   // Set a Bounty's address
    address internal preICO = 0x2bfdf8B830DAaf54d0b538aF1E62A192Bf291B5d;   // Set a preICO's address

    event InitSupply(uint256 owner, uint256 LinNetOperation, uint256 LinTeam, uint256 SympoSium, uint256 Bounty, uint256 preICO);
    
     /**
     * @dev The log is output when the contract is distributed.
     */
    
    constructor() public {
       
        emit InitSupply(ICOSupply, LinNetOperationSupply, LinTeamSupply, SympoSiumSupply, BountySupply, preICOSupply);
        
    }
    
}
contract WhitelistedCrowdsale is Ownable {

    mapping(address => bool) public whitelist;

    event AddWhiteList(address who);
    event DelWhiteList(address who);

    /**
     * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
     */
    modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
    }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
    emit AddWhiteList(_beneficiary);
  }
  
  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing. 
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist. 
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
    emit DelWhiteList(_beneficiary);
  }

}


/**
 * @title LinCrowdSale
 */
 
contract LinCrowdSale is LinTokenMint, WhitelistedCrowdsale {
    
    /**
     * @dev Calculate date in seconds.
     */
   
    uint constant Month = 60*60*24*30;
    uint constant SixMonth = 6 * Month;
    uint constant Year = 12 * Month;
    
    /**
     * @dev Set sales start time and end time.
     */
    
    uint public StartTime = now;
    uint public EndTime = StartTime + SixMonth;

    /**
     * @dev Set private Sale EndTime and PreSale EndTime.
     */

    uint public PrivateSaleEndTime = StartTime.add(Month*3);
    uint public PreSaleEndTime = PrivateSaleEndTime.add(Month);
    
     /**
     * @dev Flag value to check when SoftCapReached, HardCapReached, SaleClosed is achieved.
     */
    
    bool public SoftCapReached = false;
    bool public HardCapReached = false;
    bool public SaleClosed = false;
    
    bool private rentrancy_lock = false; // prevent certain functions from being recursively called
    
    uint public constant Private_rate = 2000; // The ratio of LIN to Ether; 40% bonus
    uint public constant Pre_rate = 1500; //  The ratio of LIN to Ether; 20%
    uint public constant Public = 1200; //  The ratio of LIN to Ether; 0% bonus
    

    uint public MinInvestMent = 2 * (10 ** decimals); // The minimum investment is 2 eth
    uint public HardCap = 500000000 * (10 ** decimals);  // Set hardcap number   =  500000000
    uint public SoftCap =  10000000 * (10 ** decimals); // Set softcap number   =   10000000
    
    /**
     * @dev Check total quantity of total amount eth, sale amount lin, refund amount.
     */
     
    uint public TotalAmountETH;
    uint public SaleAmountLIN;
    uint public RefundAmount;
    
    uint public InvestorNum;    // check total inverstor number
    
    
    /**
     * @dev Providing information by inserting events into all functions.
     */
     
    event SuccessCoreAccount(uint256 InvestorNum);
    event Burn(address burner, uint256 value);
    event SuccessInvestor(address RequestAddress, uint256 amount);
    event SuccessSoftCap(uint256 SaleAmountLin, uint256 time);
    event SuccessHardCap(uint256 SaleAmountLin, uint256 time);
    event SucessWithdraw(address who, uint256 AmountEth, uint256 time);
    event SuccessEthToOwner(address owner, uint256 AmountEth, uint256 time);
    
    event linTokenToInvestors(address InverstorAddress, uint256 Amount, uint256 now);
    event linTokenToCore(address CoreAddress, uint256 Amount, uint256 now);
    event FailsafeWithdrawal(address InverstorAddress, uint256 Amount, uint256 now);
    event FaillinTokenToInvestors(address InverstorAddress, uint256 Amount, uint256 now, uint256 ReleaseTime);
    event FaillinTokenToCore(address CoreAddress, uint256 Amount, uint256 now, uint256 ReleaseTime);
    event FailEthToOwner(address who, uint256 _amount, uint256 now);
    event safeWithdrawalTry(address who);


    /**
     * @dev Check whether the specified time is satisfied.
     */
    modifier beforeDeadline()   { require (now < EndTime); _; }
    modifier afterDeadline()    { require (now >= EndTime); _; }
    modifier afterStartTime()   { require (now >= StartTime); _; }
    modifier saleNotClosed()    { require (!SaleClosed); _; }
    
    
    /**
     * @dev Prevent reentrant attacks.
     */
     
    modifier nonReentrant() {

        require(!rentrancy_lock);

        rentrancy_lock = true;

        _;

        rentrancy_lock = false;

    }
    
    /**
     * @dev Set investor structure.
     */
     
    struct Investor {
    
    	uint256 EthAmount;
    	uint256 LinTokenAmount;
    	uint256 LockupTime;
    	bool    LinTokenWithdraw;
    	
    }
    
    
    mapping (address => Investor) public Inverstors;    // Investor structure connector
    mapping (uint256 => address) public InverstorList;  // Investor list connector
    
    
    constructor() public {
        
        /**
         * @dev Initial information setting of core members.
         */
     
        Inverstors[LinNetOperation].EthAmount = 0;
        Inverstors[LinNetOperation].LockupTime = Year;
        Inverstors[LinNetOperation].LinTokenAmount = LinNetOperationSupply;
        Inverstors[LinNetOperation].LinTokenWithdraw = false; 
        InverstorList[InvestorNum] = LinNetOperation;
        InvestorNum++;
        
        Inverstors[LinTeam].EthAmount = 0;
        Inverstors[LinTeam].LockupTime = Year;
        Inverstors[LinTeam].LinTokenAmount = LinTeamSupply;
        Inverstors[LinTeam].LinTokenWithdraw = false; 
        InverstorList[InvestorNum] = LinTeam;
        InvestorNum++;
        
        Inverstors[SympoSium].EthAmount = 0;
        Inverstors[SympoSium].LockupTime = Year;
        Inverstors[SympoSium].LinTokenAmount = SympoSiumSupply;
        Inverstors[SympoSium].LinTokenWithdraw = false; 
        InverstorList[InvestorNum] = SympoSium;
        InvestorNum++;
        
        Inverstors[Bounty].EthAmount = 0;
        Inverstors[Bounty].LockupTime = Month.mul(4);
        Inverstors[Bounty].LinTokenAmount = BountySupply;
        Inverstors[Bounty].LinTokenWithdraw = false; 
        InverstorList[InvestorNum] = Bounty;
        InvestorNum++;
        
        Inverstors[preICO].EthAmount = 0;
        Inverstors[preICO].LockupTime = Year;
        Inverstors[preICO].LinTokenAmount = preICOSupply;
        Inverstors[preICO].LinTokenWithdraw = false; 
        InverstorList[InvestorNum] = preICO;
        InvestorNum++;
        
        emit SuccessCoreAccount(InvestorNum);
        
    }
    
    
    /**
     * @dev It is automatically operated when depositing the eth.
     *  Set the minimum amount to a MinInvestMent
     */
    
    function() payable public isWhitelisted(msg.sender) whenNotPaused beforeDeadline afterStartTime saleNotClosed nonReentrant {
         
        require(msg.value >= MinInvestMent);    // Check if minimum amount satisfies

        uint amount = msg.value;    // Assign investment amount
        
        uint CurrentTime = now; // Assign Current time
        
        address RequestAddress = msg.sender;    // Investor address assignment
        
        uint rate;  // Token quantity variable
        
        uint CurrentInvestMent = Inverstors[RequestAddress].EthAmount;  // Allocated eth allocation so far


        Inverstors[RequestAddress].EthAmount = CurrentInvestMent.add(amount);   // Updated eth investment

        Inverstors[RequestAddress].LockupTime = StartTime.add(SixMonth); // Set lockup time to trade tokens
        
        Inverstors[RequestAddress].LinTokenWithdraw = false;    // Confirm whether the token is withdrawn after unlocking
        
        TotalAmountETH = TotalAmountETH.add(amount); // Total investment of all investors eth Quantity
        
       
        /**
         * @dev Bonus Quantity Variable Setting Logic
         */
       
        if(CurrentTime<PrivateSaleEndTime) {
            
            rate = Private_rate;
            
        } else if(CurrentTime<PreSaleEndTime) {
            
            rate = Pre_rate;
            
        } else {
            
            rate = Public;
            
        }


        uint NumLinToken = amount.mul(rate);    // Lin token Quantity assignment
        
        ICOSupply = ICOSupply.sub(NumLinToken); // Decrease in ICOSupply quantity
        
        
        if(ICOSupply > 0) {     
        
        //  Update investor's lean token
        Inverstors[RequestAddress].LinTokenAmount =  Inverstors[RequestAddress].LinTokenAmount.add(NumLinToken);
        
        SaleAmountLIN = SaleAmountLIN.add(NumLinToken); // Total amount of lin tokens sold
        
        CheckHardCap(); // Execute hard cap check function
        
        CheckSoftCap(); // Execute soft cap check function
        
        InverstorList[InvestorNum] = RequestAddress;    // Assign the investor address to the current index
        
        InvestorNum++;  // Increase number of investors
        
        emit SuccessInvestor(msg.sender, msg.value);    // Investor Information event print
        
        } else {

            revert();   // If ICOSupply is less than 0, revert
             
        }
    }
        
    /**
     * @dev If it is a hard cap, set the flag to true and print the event
     */
         
    function CheckHardCap() internal {

        if (!HardCapReached) {

            if (SaleAmountLIN >= HardCap) {

                HardCapReached = true;

                SaleClosed = true;
                
                emit SuccessSoftCap(SaleAmountLIN, now);

            }
        }
    }   
    
    /**
     * @dev If it is a soft cap, set the flag to true and print the event
     */
     
    function CheckSoftCap() internal {

        if (!SoftCapReached) {

            if (SaleAmountLIN >= SoftCap) {

                SoftCapReached = true;
                
                emit SuccessHardCap(SaleAmountLIN, now);

            } 
        }
    }  
 
    /**
     * @dev If the soft cap fails, return the investment and print the event
     */
     
    function safeWithdrawal() external afterDeadline nonReentrant {

        if (!SoftCapReached) {

            uint amount = Inverstors[msg.sender].EthAmount;
            
            Inverstors[msg.sender].EthAmount = 0;
            

            if (amount > 0) {

                msg.sender.transfer(amount);

                RefundAmount = RefundAmount.add(amount);

                emit SucessWithdraw(msg.sender, amount, now);

            } else { 
                
                emit FailsafeWithdrawal(msg.sender, amount, now);
                
                revert(); 
                
            }

        } else {
            
            emit safeWithdrawalTry(msg.sender);
            
        } 

    }
    
    /**
     * @dev send owner's funds to the ICO owner - after ICO
     */
     
    function transferEthToOwner(uint256 _amount) public onlyOwner afterDeadline nonReentrant { 
        
        if(SoftCapReached) {
            
            owner.transfer(_amount); 
        
            emit SuccessEthToOwner(msg.sender, _amount, now);
        
        } else {
            
            emit FailEthToOwner(msg.sender, _amount, now);
            
        }   

    }
    
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
     
    function burn(uint256 _value) public onlyOwner afterDeadline nonReentrant {
        
        require(_value <= ICOSupply);

        address burner = msg.sender;
        
        ICOSupply = ICOSupply.sub(_value);
        
        totalSupply = totalSupply.sub(_value);
        
        emit Burn(burner, _value);
        
     }
     
    /**
     * @dev After the lockout time, the tokens are paid to investors.
     */
     
    function LinTokenToInvestors() public onlyOwner afterDeadline nonReentrant {
        
        require(SoftCapReached);

        for(uint256 i=5; i<InvestorNum; i++) {
                
            uint256 ReleaseTime = Inverstors[InverstorList[i]].LockupTime;
            
            address InverstorAddress = InverstorList[i];
            
            uint256 Amount = Inverstors[InverstorAddress].LinTokenAmount;
               
                
            if(now>ReleaseTime && Amount>0) {
                    
                balances[InverstorAddress] = Amount;
                    
                Inverstors[InverstorAddress].LinTokenAmount = Inverstors[InverstorAddress].LinTokenAmount.sub(Amount);
                    
                Inverstors[InverstorAddress].LinTokenWithdraw = true;
                
                emit linTokenToInvestors(InverstorAddress, Amount, now);
                
            } else {
                
                emit FaillinTokenToInvestors(InverstorAddress, Amount, now, ReleaseTime);
                
                revert();
            }
                
        }
  
    }
  
    /**
     * @dev After the lockout time, the tokens are paid to Core.
     */
  
    function LinTokenToCore() public onlyOwner afterDeadline nonReentrant {
        
        require(SoftCapReached);

        for(uint256 i=0; i<5; i++) {
                
            uint256 ReleaseTime = Inverstors[InverstorList[i]].LockupTime;
            
            address CoreAddress = InverstorList[i];
            
            uint256 Amount = Inverstors[CoreAddress].LinTokenAmount;
            
                
            if(now>ReleaseTime && Amount>0) {
                    
                balances[CoreAddress] = Amount;
                    
                Inverstors[CoreAddress].LinTokenAmount = Inverstors[CoreAddress].LinTokenAmount.sub(Amount);
                
                Inverstors[CoreAddress].LinTokenWithdraw = true;
                    
                emit linTokenToCore(CoreAddress, Amount, now);
                
            } else {
                
                emit FaillinTokenToCore(CoreAddress, Amount, now, ReleaseTime);
                
                revert();
            }
                
        }
  
    }
  
}