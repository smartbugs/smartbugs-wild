pragma solidity >=0.4.10;

/*  ----------------------------------------------------------------------------------------

    Dev:    "Owned" to ensure control of contracts

            Identical to https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol

    ---------------------------------------------------------------------------------------- */
contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

/*  ----------------------------------------------------------------------------------------

    Dev:    SafeMath library

            Identical to https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

    ---------------------------------------------------------------------------------------- */
library SafeMath {
  function safeMul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a); // Ensuring no negatives
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a && c>=b);
    return c;
  }
}

/*  ----------------------------------------------------------------------------------------

    Dev:    ESG Asset Holder is called when the token "burn" function is called

    Sum:    Locked to false so users cannot burn their tokens until the Asset Contract is
            put in place with value.

    ---------------------------------------------------------------------------------------- */
contract ESGAssetHolder {
    
    function burn(address _holder, uint _amount) returns (bool result) {

        _holder = 0x0;                              // To avoid variable not used issue on deployment
        _amount = 0;                                // To avoid variable not used issue on deployment
        return false;
    }
}


/*  ----------------------------------------------------------------------------------------

    Dev:    The Esports Gold Token:  ERC20 standard token with MINT and BURN functions

    Func:   Mint, Approve, Transfer, TransferFrom  

    Note:   Mint function takes UNITS of tokens to mint as ICO event is set to have a minimum
            contribution of 1 token. All other functions (transfer etc), the value to transfer
            is the FULL DECIMAL value
            The user is only ever presented with the latter option, therefore should avoid
            any confusion.
    ---------------------------------------------------------------------------------------- */
contract ESGToken is Owned {
        
    string public name = "ESG Token";               // Name of token
    string public symbol = "ESG";                   // Token symbol
    uint256 public decimals = 3;                    // Decimals for the token
    uint256 public currentSupply;                   // Current supply of tokens
    uint256 public supplyCap;                       // Hard cap on supply of tokens
    address public ICOcontroller;                   // Controlling contract from ICO
    address public timelockTokens;                  // Address for locked management tokens
    bool public tokenParametersSet;                        // Ensure that parameters required are set
    bool public controllerSet;                             // Ensure that ICO controller is set

    mapping (address => uint256) public balanceOf;                      // Balances of addresses
    mapping (address => mapping (address => uint)) public allowance;    // Allowances from addresses
    mapping (address => bool) public frozenAccount;                     // Safety mechanism


    modifier onlyControllerOrOwner() {            // Ensures that only contracts can manage key functions
        require(msg.sender == ICOcontroller || msg.sender == owner);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address owner, uint amount);
    event FrozenFunds(address target, bool frozen);
    event Burn(address coinholder, uint amount);
    
    /*  ----------------------------------------------------------------------------------------

    Dev:    Constructor

    param:  Owner:  Address of owner
            Name:   Esports Gold Token
            Sym:    ESG_TKN
            Dec:    3
            Cap:    Hard coded cap to ensure excess tokens cannot be minted

    Other parameters have been set up as a separate function to help lower initial gas deployment cost.

    ---------------------------------------------------------------------------------------- */
    function ESGToken() {
        currentSupply = 0;                      // Starting supply is zero
        supplyCap = 0;                          // Hard cap supply in Tokens set by ICO
        tokenParametersSet = false;             // Ensure parameters are set
        controllerSet = false;                  // Ensure controller is set
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Key parameters to setup for ICO event

    Param:  _ico    Address of the ICO Event contract to ensure the ICO event can control
                    the minting function
    
    ---------------------------------------------------------------------------------------- */
    function setICOController(address _ico) onlyOwner {     // ICO event address is locked in
        require(_ico != 0x0);
        ICOcontroller = _ico;
        controllerSet = true;
    }


    /*  ----------------------------------------------------------------------------------------
    NEW
    Dev:    Address for the timelock tokens to be held

    Param:  _timelockAddr   Address of the timelock contract that will hold the locked tokens
    
    ---------------------------------------------------------------------------------------- */
    function setParameters(address _timelockAddr) onlyOwner {
        require(_timelockAddr != 0x0);

        timelockTokens = _timelockAddr;

        tokenParametersSet = true;
    }

    function parametersAreSet() constant returns (bool) {
        return tokenParametersSet && controllerSet;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Set the total number of Tokens that can be minted

    Param:  _supplyCap  The number of tokens (in whole units) that can be minted. This number then
                        gets increased by the decimal number
   
    ---------------------------------------------------------------------------------------- */
    function setTokenCapInUnits(uint256 _supplyCap) onlyControllerOrOwner {   // Supply cap in UNITS
        assert(_supplyCap > 0);
        
        supplyCap = SafeMath.safeMul(_supplyCap, (10**decimals));
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Mint the number of tokens for the timelock contract

    Param:  _mMentTkns  Number of tokens in whole units that need to be locked into the Timelock
    
    ---------------------------------------------------------------------------------------- */
    function mintLockedTokens(uint256 _mMentTkns) onlyControllerOrOwner {
        assert(_mMentTkns > 0);
        assert(tokenParametersSet);

        mint(timelockTokens, _mMentTkns);  
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Gets the balance of the address owner

    Param:  _owner  Address of the owner querying their balance
    
    ---------------------------------------------------------------------------------------- */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOf[_owner];
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Mint ESG Tokens by controller

    Control:            OnlyControllers. ICO event needs to be able to control the minting
                        function

    Param:  Address     Address for tokens to be minted to
            Amount      Number of tokens to be minted (in whole UNITS. Min minting is 1 token)
                        Minimum ETH contribution in ICO event is 0.01ETH at 100 tokens per ETH
    
    ---------------------------------------------------------------------------------------- */
    function mint(address _address, uint _amount) onlyControllerOrOwner {
        require(_address != 0x0);
        uint256 amount = SafeMath.safeMul(_amount, (10**decimals));             // Tokens minted using unit parameter supplied

        // Ensure that supplyCap is set and that new tokens don't breach cap
        assert(supplyCap > 0 && amount > 0 && SafeMath.safeAdd(currentSupply, amount) <= supplyCap);
        
        balanceOf[_address] = SafeMath.safeAdd(balanceOf[_address], amount);    // Add tokens to address
        currentSupply = SafeMath.safeAdd(currentSupply, amount);                // Add to supply
        
        Mint(_address, amount);
    }
    
    /*  ----------------------------------------------------------------------------------------

    Dev:    ERC20 standard transfer function

    Param:  _to         Address to send to
            _value      Number of tokens to be sent - in FULL decimal length
    
    Ref:    https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/BasicToken.sol
    ---------------------------------------------------------------------------------------- */
    function transfer(address _to, uint _value) returns (bool success) {
        require(!frozenAccount[msg.sender]);        // Ensure account is not frozen

        /* 
            Update balances from "from" and "to" addresses with the tokens transferred
            safeSub method ensures that address sender has enough tokens to send
        */
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);    
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                  
        Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    /*  ----------------------------------------------------------------------------------------

    Dev:    ERC20 standard transferFrom function

    Param:  _from       Address to send from
            _to         Address to send to
            Amount      Number of tokens to be sent - in FULL decimal length

    ---------------------------------------------------------------------------------------- */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {   
        require(!frozenAccount[_from]);                         // Check account is not frozen
        
        /* 
            Ensure sender has been authorised to send the required number of tokens
        */
        if (allowance[_from][msg.sender] < _value)
            return false;

        /* 
            Update allowance of sender to reflect tokens sent
        */
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value); 

        /* 
            Update balances from "from" and "to" addresses with the tokens transferred
            safeSub method ensures that address sender has enough tokens to send
        */
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);

        Transfer(_from, _to, _value);
        return true;
    }
    
    /*  ----------------------------------------------------------------------------------------

    Dev:    ERC20 standard approve function

    Param:  _spender        Address of sender who is approved
            _value          The number of tokens (full decimals) that are approved

    ---------------------------------------------------------------------------------------- */
    function approve(address _spender, uint256 _value)      // FULL DECIMALS OF TOKENS
        returns (bool success)
    {
        require(!frozenAccount[msg.sender]);                // Check account is not frozen

        /* Requiring the user to set to zero before resetting to nonzero */
        if ((_value != 0) && (allowance[msg.sender][_spender] != 0)) {
           return false;
        }

        allowance[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Function to check the amount of tokens that the owner has allowed the "spender" to
            transfer

    Param:  _owner          Address of the authoriser who owns the tokens
            _spender        Address of sender who will be authorised to spend the tokens

    ---------------------------------------------------------------------------------------- */

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowance[_owner][_spender];
    }
    
    /*  ----------------------------------------------------------------------------------------

    Dev:    As ESG is aiming to be a regulated betting operator. Regulatory hurdles may require
            this function if an account on the betting platform, using the token, breaches
            a regulatory requirement.

            ESG can then engage with the account holder to get it unlocked

            This does not stop the token accruing value from its share of the Asset Contract

    Param:  _target         Address of account
            _freeze         Boolean to lock/unlock account

    Ref:    This is a replica of the code as per https://ethereum.org/token
    ---------------------------------------------------------------------------------------- */
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Burn function: User is able to burn their token for a share of the ESG Asset Contract

    Note:   Deployed with the ESG Asset Contract set to false to ensure token holders cannot
            accidentally burn their tokens for zero value

    Param:  _amount         Number of tokens (full decimals) that should be burnt

    Ref:    Based on the open source TokenCard Burn function. A copy can be found at
            https://github.com/bokkypoobah/TokenCardICOAnalysis
    ---------------------------------------------------------------------------------------- */
    function burn(uint _amount) returns (bool result) {

        if (_amount > balanceOf[msg.sender])
            return false;       // If owner has enough to burn

        /* 
            Remove tokens from circulation
            Update sender's balance of tokens
        */
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _amount);
        currentSupply = SafeMath.safeSub(currentSupply, _amount);

        // Call burn function
        result = esgAssetHolder.burn(msg.sender, _amount);
        require(result);

        Burn(msg.sender, _amount);
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Section of the contract that links to the ESG Asset Contract

    Note:   Deployed with the ESG Asset Contract set to false to ensure token holders cannot
            accidentally burn their tokens for zero value

    Param:  _amount         Number of tokens (full decimals) that should be burnt

    Ref:    Based on the open source TokenCard Burn function. A copy can be found at
            https://github.com/bokkypoobah/TokenCardICOAnalysis
    ---------------------------------------------------------------------------------------- */

    ESGAssetHolder esgAssetHolder;              // Holds the accumulated asset contract
    bool lockedAssetHolder;                     // Will be locked to stop tokenholder to be upgraded

    function lockAssetHolder() onlyOwner {      // Locked once deployed
        lockedAssetHolder = true;
    }

    function setAssetHolder(address _assetAdress) onlyOwner {   // Used to lock in the Asset Contract
        assert(!lockedAssetHolder);             // Check that we haven't locked the asset holder yet
        esgAssetHolder = ESGAssetHolder(_assetAdress);
    }    
}

    /*  ----------------------------------------------------------------------------------------

    Dev:    Vested token option for management - locking in account holders for 2 years

    Ref:    Identical to OpenZeppelin open source contract except releaseTime is locked in
            https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/TokenTimelock.sol

    ---------------------------------------------------------------------------------------- */
contract TokenTimelock {

    // ERC20 basic token contract being held
    ESGToken token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint256 public releaseTime;

    function TokenTimelock(address _token, address _beneficiary) {
        require(_token != 0x0);
        require(_beneficiary != 0x0);

        token = ESGToken(_token);
        //token = _token;
        beneficiary = _beneficiary;
        releaseTime = now + 2 years;
    }

    /* 
        Show the balance in the timelock for transparency
        Therefore transparent view of the whitepaper allotted management tokens
    */
    function lockedBalance() public constant returns (uint256) {
        return token.balanceOf(this);
    }

    /* 
        Transfers tokens held by timelock to beneficiary
    */
    function release() {
        require(now >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.transfer(beneficiary, amount);
    }
}

    /*  ----------------------------------------------------------------------------------------

    Dev:    ICO Controller event

            ICO Controller manages the ICO event including payable functions that trigger mint,
            Refund collections, Base target and ICO discount rates for deposits before Base
            Target

    Ref:    Modified version of crowdsale contract with refund option (if base target not reached)
            https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol
            https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/RefundVault.sol           
    ---------------------------------------------------------------------------------------- */
contract ICOEvent is Owned {

    ESGToken public token;                              // ESG TOKEN used for Deposit, Claims, Set Address

    uint256 public startTime = 0;                       // StartTime default
    uint256 public endTime;                             // End time is start + duration
    uint256 duration;                                   // Duration in days for ICO
    bool parametersSet;                                 // Ensure paramaters are locked in before starting ICO
    bool supplySet;                                     // Ensure token supply set

    address holdingAccount = 0x0;                       // Address for successful closing of ICO
    uint256 public totalTokensMinted;                   // To record total number of tokens minted

    // For purchasing tokens
    uint256 public rate_toTarget;                       // Rate of tokens per 1 ETH contributed to the base target
    uint256 public rate_toCap;                          // Rate of tokens from base target to cap per 1 ETH
    uint256 public totalWeiContributed = 0;             // Tracks total Ether contributed in WEI
    uint256 public minWeiContribution = 0.01 ether;     // At 100:1ETH means 1 token = the minimum contribution
    uint256 constant weiEtherConversion = 10**18;       // To allow inputs for setup in ETH for simplicity

    // Cap parameters
    uint256 public baseTargetInWei;                     // Target for bonus rate of tokens
    uint256 public icoCapInWei;                         // Max cap of the ICO in Wei

    event logPurchase (address indexed purchaser, uint value, uint256 tokens);

    enum State { Active, Refunding, Closed }            // Allows control of the ICO state
    State public state;
    mapping (address => uint256) public deposited;      // Mapping for address deposit amounts
    mapping (address => uint256) public tokensIssued;   // Mapping for address token amounts

    /*  ----------------------------------------------------------------------------------------

    Dev:    Constructor

    param:  Parameters are set individually after construction to lower initial deployment gas
            State:  set default state to active

    ---------------------------------------------------------------------------------------- */
    function ICOEvent() {
        state = State.Active;
        totalTokensMinted = 0;
        parametersSet = false;
        supplySet = false;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    This section is to set parameters for the ICO control by the owner

    Param:  _tokenAddress   Address of the ESG Token contract that has been deployed
            _target_rate    Number of tokens (in units, excl token decimals) per 1 ETH contribution
                            up to the ETH base target
            _cap_rate       Number of tokens (in units, excl token decimals) per 1 ETH contribution
                            from the base target to the ICO cap
            _baseTarget     Number of ETH to reach the base target. ETH is refunded if base target
                            is not reached
            _cap            Total ICO cap in ETH. No further ETH can be deposited beyond this
            _holdingAccount Address of the beneficiary account on a successful ICO
            _duration       Duration of ICO in days
    ---------------------------------------------------------------------------------------- */ 
    function ICO_setParameters(address _tokenAddress, uint256 _target_rate, uint256 _cap_rate, uint256 _baseTarget, uint256 _cap, address _holdingAccount, uint256 _duration) onlyOwner {
        require(_target_rate > 0 && _cap_rate > 0);
        require(_baseTarget >= 0);
        require(_cap > 0);
        require(_duration > 0);
        require(_holdingAccount != 0x0);
        require(_tokenAddress != 0x0);

        rate_toTarget = _target_rate;
        rate_toCap = _cap_rate;
        token = ESGToken(_tokenAddress);
        baseTargetInWei = SafeMath.safeMul(_baseTarget, weiEtherConversion);
        icoCapInWei = SafeMath.safeMul(_cap, weiEtherConversion);
        holdingAccount = _holdingAccount;
        duration = SafeMath.safeMul(_duration, 1 days);
        parametersSet = true;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Ensure the ICO parameters are set before initialising start of ICO

    ---------------------------------------------------------------------------------------- */
    function eventConfigured() internal constant returns (bool) {
        return parametersSet && supplySet;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Starts the ICO. Initialises starttime at now - current block timestamp

    ---------------------------------------------------------------------------------------- */ 
    function ICO_start() onlyOwner {
        assert (eventConfigured());
        startTime = now;
        endTime = SafeMath.safeAdd(startTime, duration);
    }

    function ICO_start_future(uint _startTime) onlyOwner {
        assert(eventConfigured());
        require(_startTime > now);
        startTime = _startTime;
        endTime = SafeMath.safeAdd(startTime, duration);
    }

    function ICO_token_supplyCap() onlyOwner {
        require(token.parametersAreSet());                          // Ensure parameters are set in the token

        // Method to calculate number of tokens required to base target
        uint256 targetTokens = SafeMath.safeMul(baseTargetInWei, rate_toTarget);         
        targetTokens = SafeMath.safeDiv(targetTokens, weiEtherConversion);

        // Method to calculate number of tokens required between base target and cap
        uint256 capTokens = SafeMath.safeSub(icoCapInWei, baseTargetInWei);
        capTokens = SafeMath.safeMul(capTokens, rate_toCap);
        capTokens = SafeMath.safeDiv(capTokens, weiEtherConversion);

        /*
            Hard setting for 10% of base target tokens as per Whitepaper as M'ment incentive
            This is set to only a percentage of the base target, not overall cap
            Don't need to divide by weiEtherConversion as already in tokens
        */
        uint256 mmentTokens = SafeMath.safeMul(targetTokens, 10);
        mmentTokens = SafeMath.safeDiv(mmentTokens, 100);

        // Total supply for the ICO will be available tokens + m'ment reserve
        uint256 tokens_available = SafeMath.safeAdd(capTokens, targetTokens); 

        uint256 total_Token_Supply = SafeMath.safeAdd(tokens_available, mmentTokens); // Tokens in UNITS

        token.setTokenCapInUnits(total_Token_Supply);          // Set supply cap and mint to timelock
        token.mintLockedTokens(mmentTokens);                   // Lock in the timelock tokens
        supplySet = true;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Fallback payable function if ETH is transferred to the ICO contract

    param:  No parameters - calls deposit(Address) with msg.sender

    ---------------------------------------------------------------------------------------- */
    function () payable {
        deposit(msg.sender);
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Deposit function. User needs to ensure that the purchase is within ICO cap range

            Function checks that the ICO is still active, that the cap hasn't been reached and
            the address provided is != 0x0.

    Calls:  getPreTargetContribution(value)
                This function calculates how much (if any) of the value transferred falls within
                the base target goal and qualifies for the target rate of tokens

            Token.mint(address, number)
                Calls the token mint function in the ESGToken contract

    param: _for     Address of the sender for tokens
            
    ---------------------------------------------------------------------------------------- */
    function deposit(address _for) payable {

        /* 
            Checks to ensure purchase is valid. A purchase that breaches the cap is not allowed
        */
        require(validPurchase(msg.value));           // Checks time, value purchase is within Cap and address != 0x0
        require(state == State.Active);     // IE not in refund or closed
        require(!ICO_Ended());              // Checks time closed or cap reached

        /* 
            Calculates if any of the value falls before the base target so that the correct
            Token : ETH rate can be applied to the value transferred
        */
        uint256 targetContribution = getPreTargetContribution(msg.value);               // Contribution before base target
        uint256 capContribution = SafeMath.safeSub(msg.value, targetContribution);      // Contribution above base target
        totalWeiContributed = SafeMath.safeAdd(totalWeiContributed, msg.value);         // Update total contribution

        /* 
            Calculate total tokens earned by rate * contribution (in Wei)
            Multiplication first ensures that dividing back doesn't truncate/round
        */
        uint256 targetTokensToMint = SafeMath.safeMul(targetContribution, rate_toTarget);   // Discount rate tokens
        uint256 capTokensToMint = SafeMath.safeMul(capContribution, rate_toCap);            // Standard rate tokens
        uint256 tokensToMint = SafeMath.safeAdd(targetTokensToMint, capTokensToMint);       // Total tokens
        
        tokensToMint = SafeMath.safeDiv(tokensToMint, weiEtherConversion);                  // Get tokens in units
        totalTokensMinted = SafeMath.safeAdd(totalTokensMinted, tokensToMint);              // Update total tokens minted

        deposited[_for] = SafeMath.safeAdd(deposited[_for], msg.value);                     // Log deposit and inc of refunds
        tokensIssued[_for] = SafeMath.safeAdd(tokensIssued[_for], tokensToMint);            // Log tokens issued

        token.mint(_for, tokensToMint);                                                     // Mint tokens from Token Mint
        logPurchase(_for, msg.value, tokensToMint);
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Calculates how much of the ETH contributed falls before the base target cap to therefore
            calculate the correct rates of Token to be issued

    param:      _valueSent  The value of ETH transferred on the payable function

    returns:    uint256     The value that falls before the base target
            
    ---------------------------------------------------------------------------------------- */
    function getPreTargetContribution(uint256 _valueSent) internal returns (uint256) {
        
        uint256 targetContribution = 0;                                                     // Default return

        if (totalWeiContributed < baseTargetInWei) {                                             
            if (SafeMath.safeAdd(totalWeiContributed, _valueSent) > baseTargetInWei) {           // Contribution straddles baseTarget
                targetContribution = SafeMath.safeSub(baseTargetInWei, totalWeiContributed);     // IF #1 means always +ve
            } else {
                targetContribution = _valueSent;
            }
        }
        return targetContribution;    
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    Public viewable functions to show key parameters

    ---------------------------------------------------------------------------------------- */

    // Is the ICO Live: time live, state Active
    function ICO_Live() public constant returns (bool) {
        return (now >= startTime && now < endTime && state == State.Active);
    }

    // Time is valid, purchase isn't zero and cap won't be breached
    function validPurchase(uint256 _value) payable returns (bool) {          // Known true
        bool validTime = (now >= startTime && now < endTime);           // Must be true    
        bool validAmount = (_value >= minWeiContribution);
        bool withinCap = SafeMath.safeAdd(totalWeiContributed, _value) <= icoCapInWei;

        return validTime && validAmount && withinCap;
    }

    // ICO has ended
    function ICO_Ended() public constant returns (bool) {
        bool capReached = (totalWeiContributed >= icoCapInWei);
        bool stateValid = state == State.Closed;

        return (now >= endTime) || capReached || stateValid;
    }

    // Wei remaining until ICO is capped
    function Wei_Remaining_To_ICO_Cap() public constant returns (uint256) {
        return (icoCapInWei - totalWeiContributed);
    }

    // Shows if the base target cap has been reached
    function baseTargetReached() public constant returns (bool) {
    
        return totalWeiContributed >= baseTargetInWei;
    }

    // Shows if the cap has been reached
    function capReached() public constant returns (bool) {
    
        return totalWeiContributed == icoCapInWei;
    }

    /*  ----------------------------------------------------------------------------------------

    Dev:    This section controls closing of the ICO. The state is set to closed so that the ICO
            is shown as ended.

            Based on the function from open zeppelin contracts: RefundVault + RefundableCrowdsale

    Ref:    https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/RefundableCrowdsale.sol
            https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/RefundVault.sol
    ---------------------------------------------------------------------------------------- */

    event Closed();

    // Set closed ICO and transfer balance to holding account
    function close() onlyOwner {
        require((now >= endTime) || (totalWeiContributed >= icoCapInWei));
        require(state==State.Active);
        state = State.Closed;
        Closed();

        holdingAccount.transfer(this.balance);
    }
}