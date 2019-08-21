pragma solidity ^0.4.24;


/* ----------------------------------------------------------------------------
| Sheltercoin ICO 'Sheltercoin Token' Crowdfunding contract
| Date - 16-November-2017
| Blockchain Date - Dec 4 2018
| copyright 2017 zMint Limited. All Rights Reserved.
| authors A Campbell, S Outtrim
| Vers - 000 v001
| ------------------------
| Updates 
| Date 25-Aug-17 ADC Finalising format
| Date 27-Aug-17 ADC Code review amendments
| Date 01-Sep-17 ADC Changes 
| Date 16-Nov-17 ADC Sheltercoin Pre-ICO phase
| Date 27-Nov-17 ADC Pragma 17 Changes
| Date 12-Dec-17 SO, ADC Code Review, testing; production migration.
| Date 01-May-18 ADC Code changes
| Date 12-May-18 ADC KYC Client Verication 
| Date 29-May-18 SO, ADC Code Revew, testing
| Date 11-Jun-18 SO  hard coding, testing, production migration. 
|                    Removed TransferAnyERC20Token, KYC contract shell
|                    Added whitelist and blacklist code
|                    Added bonus calc to ICO function
| Date 08-Aug-18 SO  Updated function to constructor()
|                    Added SHLT specific function to SHLT code, replaced names
| Date 07-Feb-19 SO  Production deployment of new SHLT token
|                    
| 
| Sheltercoin.io :-)
| :-) hAVe aN aWeSoMe iCo :-) 
|
// ---------------------------------------------------------------------------- */


/* =============================================================================
| Sheltercoin ICO 'Sheltercoin Token & Crowdfunding 
|
| 001. contract - ERC20 Token Interface
|
|
|
| Apache Licence
| ============================================================================= */


/* ============================================================================
|
| Token Standard #20 Interface
| https://github.com/ethereum/EIPs/issues/20
| 
| ============================================================================ */


contract ERC20Interface {
    uint public totalSupply;
    uint public tokensSold;
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) 
        public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant 
        returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, 
        uint _value);
}



/* ======================================================================
|
| 002. contract Owned 
| 
| ====================================================================== */

contract Owned {

    /* ------------------------------------------------------------------------
    | 002.01 - Current owner, and proposed new owner
    | -----------------------------------------------------------------------*/
    address public owner;
    address public newOwner;

    // ------------------------------------------------------------------------
    // 002.02 - Constructor - assign creator as the owner
    // -----------------------------------------------------------------------*/
    constructor () public {
        owner = msg.sender;
    }

    /* ------------------------------------------------------------------------
    | 002.03 - Modifier to mark that a function can only be executed by the owner
    | -----------------------------------------------------------------------*/
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    /* ------------------------------------------------------------------------
    | 002.04 - Owner can initiate transfer of contract to a new owner
    | -----------------------------------------------------------------------*/
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

 
    /* ------------------------------------------------------------------------
    | 002.05 - New owner has to accept transfer of contract
    | -----------------------------------------------------------------------*/
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}

/* ===================================================================================
|
| 003. contract Pausable
|      Abstract contract that allows children to implement an emergency stop mechanism
| 
| ==================================================================================== */

contract Pausable is Owned {
  event Pause();
  event Unpause();

  bool public paused = false;
    /* ------------------------------------------------------------------------
    | 003.01 - modifier to allow actions only when the contract IS paused
    | -----------------------------------------------------------------------*/
   modifier whenNotPaused() {
    require(!paused);
    _;
  }
   
   /* ------------------------------------------------------------------------
    | 003.02 - modifier to allow actions only when the contract IS NOT paused
    | -----------------------------------------------------------------------*/
  modifier whenPaused {
    require(paused);
    _;
  }
   
   /* ------------------------------------------------------------------------
    | 003.01 - called by the owner to pause, triggers stopped state
    | -----------------------------------------------------------------------*/
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }
   
   /* ------------------------------------------------------------------------
    | 003.01 - called by the owner to unpause, returns to normal state
    | -----------------------------------------------------------------------*/
   function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

/* ===================================================================================
|
| 004. contract Transferable
|      Abstract contract that allows wallets the transfer mechanism
| 
| ==================================================================================== */

contract Transferable is Owned {
  event Transfer();
  event Untransfer();

  bool public flg_transfer = true;
    /* ------------------------------------------------------------------------
    | 004.01 - modifier to allow actions only when the contract IS transfer
    | -----------------------------------------------------------------------*/
   modifier whenNotTransfer() {
    require(!flg_transfer);
    _;
  }
   
   /* ------------------------------------------------------------------------
    | 004.02 - modifier to allow actions only when the contract IS NOT transfer
    | -----------------------------------------------------------------------*/
  modifier whenTransfer {
    require(flg_transfer);
    _;
  }
   
   /* ------------------------------------------------------------------------
    | 004.01 - called by the owner to transfer, triggers stopped state
    | -----------------------------------------------------------------------*/
  function transfer() public onlyOwner whenNotTransfer returns (bool) {
    flg_transfer = true;
    emit Transfer();
    return true;
  }
   
   /* ------------------------------------------------------------------------
    | 004.01 - called by the owner to untransfer, returns to normal state
    | -----------------------------------------------------------------------*/
   function untransfer() public onlyOwner whenTransfer returns (bool) {
    flg_transfer = false;
    emit Untransfer();
    return true;
  }
}



/* ----------------------------------------------------------------------------
| 005. libraty Safe maths - OpenZeppelin
| --------------------------------------------------------------------------- */
library SafeMath {

    /* ------------------------------------------------------------------------
    // 005.01 - safeAdd a number to another number, checking for overflows
    // -----------------------------------------------------------------------*/
    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    /* ------------------------------------------------------------------------
    // 005.02 - safeSubtract a number from another number, checking for underflows
    // -----------------------------------------------------------------------*/
    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
    /* ------------------------------------------------------------------------
    // 005.03 - safeMuiltplier a number to another number, checking for underflows
    // -----------------------------------------------------------------------*/
    function safeMul(uint a, uint b) internal pure returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    /* ------------------------------------------------------------------------
    // 005.04 - safeDivision 
    // -----------------------------------------------------------------------*/
    function safeDiv(uint a, uint b) internal pure returns (uint256) {
        uint c = a / b;
        return c;
    }
    /* ------------------------------------------------------------------------
    // 005.05 - Max64
    // -----------------------------------------------------------------------*/
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }
    /* ------------------------------------------------------------------------
    // 005.06 - Min64
    // -----------------------------------------------------------------------*/
    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }
    /* ------------------------------------------------------------------------
    // 005.07 - max256
    // -----------------------------------------------------------------------*/
    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    /* ------------------------------------------------------------------------
    // 005.08 - min256
    // -----------------------------------------------------------------------*/
    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
/* ----------------------------------------------------------------------------
| 006. contract Sheltercoin Token Configuration - pass through parameters
| ---------------------------------------------------------------------------- */

contract SheltercoinTokCfg {

    /* ------------------------------------------------------------------------
    | 006.01 - Token symbol(), name() and decimals()
    |------------------------------------------------------------------------ */
    string public constant SYMBOL = "SHLT";
    string public constant NAME = "SHLT Sheltercoin.io";
    uint8 public constant DECIMALS = 8;
    bool public flg001 = false;
    



    /* -----------------------------------------------------------------------
    | 006.02 - Decimal factor for multiplications 
    | ------------------------------------------------------------------------*/
    uint public constant TOKENS_SOFT_CAP = 1 * DECIMALSFACTOR;
    uint public constant TOKENS_HARD_CAP = 1000000000 * DECIMALSFACTOR; /* billion */
    uint public constant TOKENS_TOTAL = 1000000000 * DECIMALSFACTOR;
    uint public tokensSold = 0;


    /* ------------------------------------------------------------------------
    | 006.03 - Lot 1 Crowdsale start date and end date
    | Do not use the `now` function here
    | Good caluclator for sanity check for epoch - http://www.unixtimestamp.com/
    | Start - Sunday 30-Jun-19 12:00:00 UTC 
    | End - Tuesday 30-Jun-20  12:00:00 UTC 
    | ----------------------------------------------------------------------- */
    uint public constant DECIMALSFACTOR = 10**uint(DECIMALS);

    /* ------------------------------------------------------------------------
    | 006.04 - Lot 1 Crowdsale timings Soft Cap and Hard Cap, and Total tokens
    | -------------------------------------------------------------------------- */
    uint public START_DATE = 1582545600;  // 24-Feb-20 12:00:00 GMT
    uint public END_DATE = 1614165071;    // 24-Feb-21 11:11:11 GMT

    /* ------------------------------------------------------------------------
    | 006.05 - Individual transaction contribution min and max amounts
    | Set to 0 to switch off, or `x ether`
    | ----------------------------------------------------------------------*/
    uint public CONTRIBUTIONS_MIN = 0;
    uint public CONTRIBUTIONS_MAX = 1000000 ether;
}



/* ----------------------------------------------------------------------------
| 007. - contract ERC20 Token, with the safeAddition of Symbol, name and Decimal
| --------------------------------------------------------------------------*/
contract ERC20Token is ERC20Interface, Owned, Pausable, Transferable {
    using SafeMath for uint;

    /* ------------------------------------------------------------------------
    | 007.01 - Symbol(), Name() and Decimals()
    | ----------------------------------------------------------------------*/
    string public symbol;
    string public name;
    uint8 public decimals;

    /* ------------------------------------------------------------------------
    | 007.02 - Balances for each account
    | ----------------------------------------------------------------------*/
    mapping(address => uint) balances;

    /*------------------------------------------------------------------------
    | 007.03 - Owner of account approves the transfer of an amount to another account
    | ----------------------------------------------------------------------*/
    mapping(address => mapping (address => uint)) allowed;


    /* ------------------------------------------------------------------------
    | 007.04 - Constructor
    | ----------------------------------------------------------------------*/
    constructor (
        string _symbol, 
        string _name, 
        uint8 _decimals, 
        uint _tokensSold
    ) Owned() public {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        tokensSold = _tokensSold;
        balances[owner] = _tokensSold;
    }


    /* ------------------------------------------------------------------------
    | 007.05 -Get the account balance of another account with address _owner
    | ----------------------------------------------------------------------*/
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }


    /* ------------------------------------------------------------------------
    | 007.06 - Transfer the balance from owner's account to another account
    | ----------------------------------------------------------------------*/
    function transfer(address _to, uint _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount             // User has balance
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[msg.sender] = balances[msg.sender].safeSub(_amount);
            balances[_to] = balances[_to].safeAdd(_amount);
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    /* ------------------------------------------------------------------------
    | 007.07 - Allow _spender to withdraw from your Account, multiple times, up to the
    |          _value amount. If this function is called again it overwrites the
    |          current allowance with _value.
    | ----------------------------------------------------------------------*/
    function approve(
        address _spender,
        uint _amount
    ) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


    /* ------------------------------------------------------------------------
    | 007.08 - Spender of tokens transfer an amount of tokens from the token owner's
    |          balance to another account. The owner of the tokens must already
    |          have approved this transfer
    | ----------------------------------------------------------------------*/
    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount                  // _from a/c has a balance
            && allowed[_from][msg.sender] >= _amount    // Transfer allowed
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[_from] = balances[_from].safeSub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].safeSub(_amount);
            balances[_to] = balances[_to].safeAdd(_amount);
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    /* ------------------------------------------------------------------------
    | 007.09 - Returns the amount of tokens approved by the owner that can be
    |          transferred to the spender's account
    | ----------------------------------------------------------------------*/
    function allowance(
        address _owner, 
        address _spender
    ) public constant returns (uint remaining) 
    {
        return allowed[_owner][_spender];
    }
}


/* ----------------------------------------------------------------------------
| 008. contract SheltercoinToken - Sheltercoin ICO Crowdsale
| --------------------------------------------------------------------------*/
contract SHLTSheltercoinToken is ERC20Token, SheltercoinTokCfg {

    /* ------------------------------------------------------------------------
    | 007.01 - Has the crowdsale been finalised?
    | ----------------------------------------------------------------------*/
    bool public finalised = false;
    
    /* ------------------------------------------------------------------------
    | 007.02 - Number of Tokens per 1 ETH
    |          This can be adjusted as the ETH/USD rate changes
    |          
    | 007.03 SO 
               Price per ETH $105.63 Feb 7 2019 coinmarketcap
               1 ETH = 2000 SHLT
               1 SHLT = 0.0005 ETH
               USD 5c 
               1 billion SHLT = total hard cap 
    |
    |          tokensPerEther  = 2000
    |          tokensPerKEther = 2000000
    |          

    /* ----------------------------------------------------------------------*/
    uint public tokensPerEther = 2000;    
    uint public tokensPerKEther = 2000000;  
    uint public etherSold = 0;
    uint public weiSold = 0;
    uint public tokens = 0;
    uint public dspTokens = 0;
    uint public dspTokensSold = 0;
    uint public dspEther = 0;
    uint public dspEtherSold = 0;
    uint public dspWeiSold = 0;
    uint public BONUS_VALUE = 0;
    uint public bonusTokens = 0;

// Emergency Disaster Relief 
    string public SCE_Shelter_ID;
    string public SCE_Shelter_Desc;
  //  string public SCE_Emergency_ID;
    string public SCE_Emergency_Type;
// string public SCE_UN_Body;
    string public SCE_UN_Programme_ID;
    string public SCE_Country;
    string public SCE_Region; 
 //   string public SCE_Area;
    uint public SCE_START_DATE;
    uint public SCE_END_DATE; 
    
    /* ------------------------------------------------------------------------
    | 007.04 - Wallet receiving the raised funds 
    |        - The ICO Contract address 
    | ----------------------------------------------------------------------*/
    address public wallet;
    address public tokenContractAdr;
    /* ------------------------------------------------------------------------
    | 007.05 - Crowdsale participant's accounts need to be client verified client before
    |          the participant can move their tokens
    | ----------------------------------------------------------------------*/
    mapping(address => bool) public Whitelisted;
    mapping(address => bool) public Blacklisted;

    modifier isWhitelisted() {
        require(Whitelisted[msg.sender] == true);
        _;
      }
    
    modifier isBlacklisted() {
        require(Blacklisted[msg.sender] == true);
        _;


      }
   
    /* ------------------------------------------------------------------------
    | 007.06 - Constructor
    | ----------------------------------------------------------------------*/
    constructor (address _wallet) 
       public ERC20Token(SYMBOL, NAME, DECIMALS, 0)
    {
        wallet = _wallet;
        flg001 = true ;   

    }

    /* ------------------------------------------------------------------------
    | 007.07 - Sheltercoin Owner can change the Crowdsale wallet address
    |          Can be set at any time before or during the Crowdsale
    |          Not relevant after the crowdsale is finalised as no more contributions
    |          are accepted
    | ----------------------------------------------------------------------*/
    function setWallet(address _wallet) public onlyOwner {
        wallet = _wallet;
        emit WalletUpdated(wallet);
    }
    event WalletUpdated(address newWallet);


    /* ------------------------------------------------------------------------
    | 007.08 - Sheltercoin Owner can set number of tokens per 1 x  ETH
    |          Can only be set before the start of the Crowdsale
    | ----------------------------------------------------------------------*/
    function settokensPerKEther(uint _tokensPerKEther) public onlyOwner {
        require(now < START_DATE);
        require(_tokensPerKEther > 0);
        tokensPerKEther = _tokensPerKEther;
        emit tokensPerKEtherUpdated(tokensPerKEther);
    }
    event tokensPerKEtherUpdated(uint _tokPerKEther);


    /* ------------------------------------------------------------------------
    | 007.09 - Accept Ethers to buy Tokens during the Crowdsale
    | ----------------------------------------------------------------------*/
    function () public payable {
        ICOContribution(msg.sender);
    }


    /* ------------------------------------------------------------------------
    | 007.10 - Accept Ethers from one account for tokens to be created for another
    |          account. Can be used by Exchanges to purchase Tokens on behalf of 
    |          it's Customers
    | ----------------------------------------------------------------------*/
    function ICOContribution(address participant) public payable {
        // No contributions after the crowdsale is finalised
        require(!finalised);
        // Not paused
        require(!paused);
        // No contributions before the start of the crowdsale
        require(now >= START_DATE);
        // No contributions after the end of the crowdsale
        require(now <= END_DATE);
        // No contributions below the minimum (can be 0 ETH)
        require(msg.value >= CONTRIBUTIONS_MIN);
        // No contributions above a maximum (if maximum is set to non-0)
        require(CONTRIBUTIONS_MAX == 0 || msg.value < CONTRIBUTIONS_MAX);

        // client verification required before participant can transfer the tokens
        require(Whitelisted[msg.sender]);
        require(!Blacklisted[msg.sender]);

        // Transfer the contributed ethers to the Crowdsale wallet
        require(wallet.send(msg.value)); 

        // Calculate number of Tokens for contributed ETH
        // `18` is the ETH decimals
        // `- decimals` is the token decimals
        // `+ 3` for the tokens per 1,000 ETH factor
        tokens = msg.value * tokensPerKEther / 10**uint(18 - decimals + 3);

        /* create variable bonusTokens. This is the purchase amount adjusted by
           any bonus. The SetBonus function is onlyOwner
           Bonus is expressed in %, eg 50 = 50%
           */
        bonusTokens = msg.value.safeMul(BONUS_VALUE + 100);

        bonusTokens = bonusTokens.safeDiv(100);
 
        tokens = bonusTokens;

        dspTokens = tokens * tokensPerKEther / 10**uint(18 - decimals + 6);
        dspEther = tokens / 10**uint(18);  
        // Check if the Hard Cap will be exceeded
       require(totalSupply + tokens <= TOKENS_HARD_CAP);
       require(tokensSold + tokens <= TOKENS_HARD_CAP);
        // Crowdsale Address
         tokenContractAdr = this;
        // safeAdd tokens purchased to Account's balance and TokensSold
        balances[participant] = balances[participant].safeAdd(tokens);
        tokensSold = tokensSold.safeAdd(tokens);
        etherSold = etherSold.safeAdd(dspEther);
        weiSold = weiSold + tokenContractAdr.balance;
        //weiSold = weiSold + this.balance;
        // Event Display Totals 
        dspTokensSold = dspTokensSold.safeAdd(dspTokens);
        dspEtherSold = dspEtherSold.safeAdd(dspEther);
        dspWeiSold = dspWeiSold + tokenContractAdr.balance;
       //dspWeiSold = dspWeiSold + this.balance;

  
         // Transfer Tokens &  Log the tokens purchased 
        emit Transfer(tokenContractAdr, participant, tokens);
        emit TokensBought(participant,bonusTokens, dspWeiSold, dspEther, dspEtherSold, dspTokens, dspTokensSold, tokensPerEther);

        
     
    }
    event TokensBought(address indexed buyer, uint newWei, 
        uint newWeiBalance, uint newEther, uint EtherTotal, uint _toks, uint newTokenTotal, 
        uint _toksPerEther);


    /* ------------------------------------------------------------------------
    |  007.11 - SheltercoinOwner to finalise the Crowdsale 
    |           
    | ----------------------------------------------------------------------*/
    function finalise() public onlyOwner {
        // Can only finalise if raised > soft cap or after the end date
        require(tokensSold >= TOKENS_SOFT_CAP || now > END_DATE);
       // Can only finalise once
        require(!finalised);
          // Crowdsale Address
         tokenContractAdr = this;    
        // Write out the total
        emit TokensBought(tokenContractAdr, 0, dspWeiSold, dspEther, dspEtherSold, dspTokens, dspTokensSold, tokensPerEther);
        // Can only finalise once
        finalised = true;
    }


    /* ------------------------------------------------------------------------
    | 007.12 - Sheltercoin Owner to safeAdd Pre-sales funding token balance before the Crowdsale
    |          commences
    | ----------------------------------------------------------------------*/
    function ICOAddPrecommitment(address participant, uint balance) public onlyOwner {
         // Not paused
        require(!paused);
        // No contributions after the start of the crowdsale
        // Allowing off chain contributions during the Crowdsale
        // Allowing contributions after the end of the crowdsale
        // Off Chain SHLT Balance to Transfer 
        require(balance > 0);
        //Address field is completed
        require(address(participant) != 0x0);
        // safeAdd tokens purchased to Account's balance and TokensSold
        tokenContractAdr = this;
        balances[participant] = balances[participant].safeAdd(balance);
        tokensSold = tokensSold.safeAdd(balance);
        emit Transfer(tokenContractAdr, participant, balance);
    }
    event ICOcommitmentAdded(address indexed participant, uint balance, uint tokensSold );

    /* ------------------------------------------------------------------------
    | 007.12a - Sheltercoin Owner to Change ICO Start Date or ICO End Date
    |          commences
    | ----------------------------------------------------------------------*/
    function ICOdt(uint START_DATE_NEW, uint END_DATE_NEW ) public onlyOwner {
        // No contributions after the crowdsale is finalised
        require(!finalised);
        // Not paused
        require(!paused);
        //  Allowed to change any time 
        // No 0 
        require(START_DATE_NEW > 0);
        require(END_DATE_NEW > 0);
        tokenContractAdr = this;
        START_DATE = START_DATE_NEW;
        END_DATE = END_DATE_NEW;
        emit ICOdate(START_DATE, END_DATE);
     }
    event ICOdate(uint ST_DT, uint END_DT);

    /* ----------------------------------------------------------------------
    | 007.13 - Transfer the Balance from Owner's account to another account, with client
    |          verification check for the crowdsale participant's first transfer
    | ----------------------------------------------------------------------*/
    function transfer(address _to, uint _amount) public returns (bool success) {
        // Cannot transfer before crowdsale ends
        // require(finalised);
        //  require(flg002transfer);
        // Cannot transfer if Client verification is required
        //require(!clientRequired[msg.sender]);
        // Standard transfer
        return super.transfer(_to, _amount);
    }


    /* ------------------------------------------------------------------------
    | 007.14 - Spender of tokens transfer an amount of tokens from the token Owner's
    |          balance to another account, with Client verification check for the
    |          Crowdsale participant's first transfer
    | ----------------------------------------------------------------------*/
    function transferFrom(address _from, address _to, uint _amount) 
        public returns (bool success)
    {
        // Cannot transfer before crowdsale ends
        // require(flg002transfer);
        // Cannot transfer if Client verification is required
        //require(!clientRequired[_from]);
        // Standard transferFrom
        return super.transferFrom(_from, _to, _amount);
    }


 /* ------------------------------------------------------------------------
    | 007.16 - Any account can burn _from's tokens as long as the _from account has 
    |          approved the _amount to be burnt using
    |          approve(0x0, _amount)
    | ----------------------------------------------------------------------*/
    function mintFrom(
        address _from,
        uint _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][0x0] >= _amount           // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[0x0] + _amount > balances[0x0]  // Overflow check
        ) {
            balances[_from] = balances[_from].safeSub(_amount);
            allowed[_from][0x0] = allowed[_from][0x0].safeSub(_amount);
            balances[0x0] = balances[0x0].safeAdd(_amount);
            tokensSold = tokensSold.safeSub(_amount);
            emit Transfer(_from, 0x0, _amount);
            return true;
        } else {
            return false;
        }
    
 
     }  
    

/* ------------------------------------------------------------------------
    | 007.17 - Set bonus percentage multiplier. 50% = * 1.5
    | ----------------------------------------------------------------------*/
    function setBonus(uint _bonus) public onlyOwner

        returns (bool success) {
        require (!finalised);
        if (_bonus >= 0)               // From a/c is owner
          {
            BONUS_VALUE = _bonus;
            return true;
        } else {
            return false;
        }
          emit BonusSet(_bonus);
        }
    event BonusSet(uint _bonus);

    /* ------------------------------------------------------------------------
    |  007.15 - SheltercoinOwner to Client verify the participant's account
    |  ----------------------------------------------------------------------*/
   
   
    function AddToWhitelist(address participant) public onlyOwner {
        Whitelisted[participant] = true;
        emit AddedToWhitelist(participant);
    }
    event AddedToWhitelist(address indexed participant);

    function IsWhitelisted(address participant) 
        public view returns (bool) {
      return bool(Whitelisted[participant]);
    }
    
    function RemoveFromWhitelist(address participant) public onlyOwner {
        Whitelisted[participant] = false;
        emit RemovedFromWhitelist(participant);
    }
    event RemovedFromWhitelist(address indexed participant);

    function AddToBlacklist(address participant) public onlyOwner {
        Blacklisted[participant] = true;
        emit AddedToBlacklist(participant);
    }
    event AddedToBlacklist(address indexed participant);

    function IsBlacklisted(address participant) 
        public view returns (bool) {
      return bool(Blacklisted[participant]);
    }
    function RemoveFromBlackList(address participant) public onlyOwner {
        Blacklisted[participant] = false;
        emit RemovedFromBlacklist(participant);
    }
    event RemovedFromBlacklist(address indexed participant);

    function SCEmergency(string _Shelter_ID, string _Shelter_Description, string _Emergency_Type, string _UN_Programme_ID, string _Country, string _Region, uint START_DATE_SCE, uint END_DATE_SCE ) public onlyOwner {
 
        // Disaster Occur's
        finalised = true;
        require(finalised);
        // Not paused
        //require(!paused);
        // No 0 
         require(START_DATE_SCE > 0);
        // Write to the blockchain 
        tokenContractAdr = this;
        SCE_Shelter_ID = _Shelter_ID;
        SCE_Shelter_Desc = _Shelter_Description;
        SCE_Emergency_Type = _Emergency_Type;
        SCE_UN_Programme_ID = _UN_Programme_ID;
        SCE_Country = _Country;
        SCE_Region = _Region; 
        SCE_START_DATE = START_DATE_SCE;
        SCE_END_DATE = END_DATE_SCE; 
        emit SC_Emergency(SCE_Shelter_ID, SCE_Shelter_Desc, SCE_Emergency_Type, SCE_UN_Programme_ID, SCE_Country, SCE_Region, SCE_START_DATE, SCE_END_DATE );
       
    }
    event SC_Emergency(string _str_Shelter_ID, string _str_Shelter_Descrip, string _str_Emergency_Type, string _str_UN_Prog_ID, string _str_Country, string _str_Region, uint SC_ST_DT, uint SC_END_DT);
    

}