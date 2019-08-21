library SafeMath {
  function mul(uint256 a, uint256 b) pure internal  returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal  returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal  returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    address public sale;
    bool public transfersAllowed;
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value)
        public
        validTransfer
       	returns (bool success) 
    {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
    	require(balances[msg.sender] >= _value);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to],_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        validTransfer
      	returns (bool success)
      {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
	    require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        balances[_from] = SafeMath.sub(balances[_from], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    modifier validTransfer()
    {
        require(msg.sender == sale || transfersAllowed);
        _;
    }   
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address _sale)
        public
    {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        sale = _sale;
        transfersAllowed = false;
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    function reversePurchase(address _tokenHolder)
        public
        onlySale
    {
        require(!transfersAllowed);
        uint value = balances[_tokenHolder];
        balances[_tokenHolder] = SafeMath.sub(balances[_tokenHolder], value);
        balances[sale] = SafeMath.add(balances[sale], value);
        Transfer(_tokenHolder, sale, value);
    }

    function removeTransferLock()
        public
        onlySale
    {
        transfersAllowed = true;
    }

    modifier onlySale()
    {
        require(msg.sender == sale);
        _;
    }
}

contract Disbursement {

    /*
     *  Storage
     */
    address public owner;
    address public receiver;
    uint public disbursementPeriod;
    uint public startDate;
    uint public withdrawnTokens;
    Token public token;

    /*
     *  Modifiers
     */
    modifier isOwner() {
        if (msg.sender != owner)
            // Only owner is allowed to proceed
            revert();
        _;
    }

    modifier isReceiver() {
        if (msg.sender != receiver)
            // Only receiver is allowed to proceed
            revert();
        _;
    }

    modifier isSetUp() {
        if (address(token) == 0)
            // Contract is not set up
            revert();
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Constructor function sets contract owner
    /// @param _receiver Receiver of vested tokens
    /// @param _disbursementPeriod Vesting period in seconds
    /// @param _startDate Start date of disbursement period (cliff)
    function Disbursement(address _receiver, uint _disbursementPeriod, uint _startDate)
        public
    {
        if (_receiver == 0 || _disbursementPeriod == 0)
            // Arguments are null
            revert();
        owner = msg.sender;
        receiver = _receiver;
        disbursementPeriod = _disbursementPeriod;
        startDate = _startDate;
        if (startDate == 0)
            startDate = now;
    }

    /// @dev Setup function sets external contracts' addresses
    /// @param _token Token address
    function setup(Token _token)
        public
        isOwner
    {
        if (address(token) != 0 || address(_token) == 0)
            // Setup was executed already or address is null
            revert();
        token = _token;
    }

    /// @dev Transfers tokens to a given address
    /// @param _to Address of token receiver
    /// @param _value Number of tokens to transfer
    function withdraw(address _to, uint256 _value)
        public
        isReceiver
        isSetUp
    {
        uint maxTokens = calcMaxWithdraw();
        if (_value > maxTokens)
            revert();
        withdrawnTokens = SafeMath.add(withdrawnTokens, _value);
        token.transfer(_to, _value);
    }

    /// @dev Calculates the maximum amount of vested tokens
    /// @return Number of vested tokens to withdraw
    function calcMaxWithdraw()
        public
        constant
        returns (uint)
    {
        uint maxTokens = SafeMath.mul(SafeMath.add(token.balanceOf(this), withdrawnTokens), SafeMath.sub(now,startDate)) / disbursementPeriod;
        //uint maxTokens = (token.balanceOf(this) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
        if (withdrawnTokens >= maxTokens || startDate > now)
            return 0;
        if (SafeMath.sub(maxTokens, withdrawnTokens) > token.totalSupply())
            return token.totalSupply();
        return SafeMath.sub(maxTokens, withdrawnTokens);
    }
}

contract Sale {

    // EVENTS
    event TransferredTimelockedTokens(address beneficiary, address disbursement,uint beneficiaryTokens);
    event PurchasedTokens(address indexed purchaser, uint amount);
    event LockedUnsoldTokens(uint numTokensLocked, address disburser);

    // STORAGE
    uint public constant TOTAL_SUPPLY = 1000000000000000000;
    uint public constant MAX_PRIVATE = 750200000000000000;

    uint8 public constant DECIMALS = 9;
    string public constant NAME = "Leverj";
    string public constant SYMBOL = "LEV";
    address public owner;
    address public whitelistAdmin;
    address public wallet;
    HumanStandardToken public token;
    uint public freezeBlock;
    uint public startBlock;
    uint public endBlock;
    uint public price_in_wei = 333333; //wei per 10**-9 of a LEV!
    uint public privateAllocated = 0;
    bool public setupCompleteFlag = false;
    bool public emergencyFlag = false;
    address[] public disbursements;
    mapping(address => uint) public whitelistRegistrants;
    mapping(address => bool) public whitelistRegistrantsFlag;
    bool public publicSale = false;

    // PUBLIC FUNCTIONS
    function Sale(
        address _owner,
        uint _freezeBlock,
        uint _startBlock,
        uint _endBlock,
        address _whitelistAdmin)
        public 
        checkBlockNumberInputs(_freezeBlock, _startBlock, _endBlock)
    {
        owner = _owner;
        whitelistAdmin = _whitelistAdmin;
        token = new HumanStandardToken(TOTAL_SUPPLY, NAME, DECIMALS, SYMBOL, address(this));
        freezeBlock = _freezeBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        assert(token.transfer(this, token.totalSupply()));
        assert(token.balanceOf(this) == token.totalSupply());
        assert(token.balanceOf(this) == TOTAL_SUPPLY);
    }

    function purchaseTokens()
        public
        payable
        setupComplete
        notInEmergency
        saleInProgress
    {
        require(whitelistRegistrantsFlag[msg.sender] == true);
        /* Calculate whether any of the msg.value needs to be returned to
           the sender. The purchaseAmount is the actual number of tokens which
           will be purchased. */
        uint purchaseAmount = msg.value / price_in_wei; 
        uint excessAmount = msg.value % price_in_wei;

        if (!publicSale){
            require(whitelistRegistrants[msg.sender] > 0 );
            uint tempWhitelistAmount = whitelistRegistrants[msg.sender];
            if (purchaseAmount > whitelistRegistrants[msg.sender]){
                uint extra = SafeMath.sub(purchaseAmount,whitelistRegistrants[msg.sender]);
                purchaseAmount = whitelistRegistrants[msg.sender];
                excessAmount = SafeMath.add(excessAmount,extra*price_in_wei);
            }
            whitelistRegistrants[msg.sender] = SafeMath.sub(whitelistRegistrants[msg.sender], purchaseAmount);
            assert(whitelistRegistrants[msg.sender] < tempWhitelistAmount);
        }  

        // Cannot purchase more tokens than this contract has available to sell
        require(purchaseAmount <= token.balanceOf(this));
        // Return any excess msg.value
        if (excessAmount > 0){
            msg.sender.transfer(excessAmount);
        }
        // Forward received ether minus any excessAmount to the wallet
        wallet.transfer(this.balance);
        // Transfer the sum of tokens tokenPurchase to the msg.sender
        assert(token.transfer(msg.sender, purchaseAmount));
        PurchasedTokens(msg.sender, purchaseAmount);
    }

    function lockUnsoldTokens(address _unsoldTokensWallet)
        public
        saleEnded
        setupComplete
        onlyOwner
    {
        Disbursement disbursement = new Disbursement(
            _unsoldTokensWallet,
            1*365*24*60*60,
            block.timestamp
        );
        disbursement.setup(token);
        uint amountToLock = token.balanceOf(this);
        disbursements.push(disbursement);
        token.transfer(disbursement, amountToLock);
        LockedUnsoldTokens(amountToLock, disbursement);
    }

    // OWNER-ONLY FUNCTIONS
    function distributeTimelockedTokens(
        address[] _beneficiaries,
        uint[] _beneficiariesTokens,
        uint[] _timelockStarts,
        uint[] _periods
    ) 
        public
        onlyOwner
        saleNotEnded
    { 
        assert(!setupCompleteFlag);
        assert(_beneficiariesTokens.length < 11);
        assert(_beneficiaries.length == _beneficiariesTokens.length);
        assert(_beneficiariesTokens.length == _timelockStarts.length);
        assert(_timelockStarts.length == _periods.length);
        for(uint i = 0; i < _beneficiaries.length; i++) {
            require(privateAllocated + _beneficiariesTokens[i] <= MAX_PRIVATE);
            privateAllocated = SafeMath.add(privateAllocated, _beneficiariesTokens[i]);
            address beneficiary = _beneficiaries[i];
            uint beneficiaryTokens = _beneficiariesTokens[i];
            Disbursement disbursement = new Disbursement(
                beneficiary,
                _periods[i],
                _timelockStarts[i]
            );
            disbursement.setup(token);
            token.transfer(disbursement, beneficiaryTokens);
            disbursements.push(disbursement);
            TransferredTimelockedTokens(beneficiary, disbursement, beneficiaryTokens);
        }
        assert(token.balanceOf(this) >= (SafeMath.sub(TOTAL_SUPPLY, MAX_PRIVATE)));
    }

    function distributePresaleTokens(address[] _buyers, uint[] _amounts)
        public
        onlyOwner
        saleNotEnded
    {
        assert(!setupCompleteFlag);
        require(_buyers.length < 11);
        require(_buyers.length == _amounts.length);
        for(uint i=0; i < _buyers.length; i++){
            require(SafeMath.add(privateAllocated, _amounts[i]) <= MAX_PRIVATE);
            assert(token.transfer(_buyers[i], _amounts[i]));
            privateAllocated = SafeMath.add(privateAllocated, _amounts[i]);
            PurchasedTokens(_buyers[i], _amounts[i]);
        }
        assert(token.balanceOf(this) >= (SafeMath.sub(TOTAL_SUPPLY, MAX_PRIVATE)));
    }

    function removeTransferLock()
        public
        onlyOwner
    {
        token.removeTransferLock();
    }

    function reversePurchase(address _tokenHolder)
        payable
        public
        onlyOwner
    {
        uint refund = SafeMath.mul(token.balanceOf(_tokenHolder),price_in_wei);
        require(msg.value >= refund);
        uint excessAmount = SafeMath.sub(msg.value, refund);
        if (excessAmount > 0) {
            msg.sender.transfer(excessAmount);
        }

        _tokenHolder.transfer(refund);
        token.reversePurchase(_tokenHolder);
    }

    function setSetupComplete()
        public
        onlyOwner
    {
        require(wallet!=0);
        require(privateAllocated!=0);  
        setupCompleteFlag = true;
    }

    function configureWallet(address _wallet)
        public
        onlyOwner
    {
        wallet = _wallet;
    }

    function changeOwner(address _newOwner)
        public
        onlyOwner
    {
        require(_newOwner != 0);
        owner = _newOwner;
    }

    function changeWhitelistAdmin(address _newAdmin)
        public
        onlyOwner
    {
        require(_newAdmin != 0);
        whitelistAdmin = _newAdmin;
    }

    function changePrice(uint _newPrice)
        public
        onlyOwner
        notFrozen
        validPrice(_newPrice)
    {
        price_in_wei = _newPrice;
    }

    function changeStartBlock(uint _newBlock)
        public
        onlyOwner
        notFrozen
    {
        require(block.number <= _newBlock && _newBlock < startBlock);
        freezeBlock = SafeMath.sub(_newBlock , SafeMath.sub(startBlock, freezeBlock));
        startBlock = _newBlock;
    }

    function emergencyToggle()
        public
        onlyOwner
    {
        emergencyFlag = !emergencyFlag;
    }
    
    function addWhitelist(address[] _purchaser, uint[] _amount)
        public
        onlyWhitelistAdmin
        saleNotEnded
    {
        assert(_purchaser.length < 11 );
        assert(_purchaser.length == _amount.length);
        for(uint i = 0; i < _purchaser.length; i++) {
            whitelistRegistrants[_purchaser[i]] = _amount[i];
            whitelistRegistrantsFlag[_purchaser[i]] = true;
            
        }
    }

    function startPublicSale()
        public
        onlyOwner
    {
        if (!publicSale){
            publicSale = true;
        }
    }

    // MODIFIERS
    modifier saleEnded {
        require(block.number >= endBlock);
        _;
    }
    modifier saleNotEnded {
        require(block.number < endBlock);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyWhitelistAdmin {
        require(msg.sender == owner || msg.sender == whitelistAdmin);
        _;
    }
    modifier notFrozen {
        require(block.number < freezeBlock);
        _;
    }
    modifier saleInProgress {
        require(block.number >= startBlock && block.number < endBlock);
        _;
    }
    modifier setupComplete {
        assert(setupCompleteFlag);
        _;
    }
    modifier notInEmergency {
        assert(emergencyFlag == false);
        _;
    }
    modifier checkBlockNumberInputs(uint _freeze, uint _start, uint _end) {
        require(_freeze >= block.number
        && _start >= _freeze
        && _end >= _start);
        _;
    }
    modifier validPrice(uint _price){
        require(_price > 0);
        _;
    }
}