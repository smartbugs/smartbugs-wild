pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------------------------
// Gifto Token by Gifto Limited.
// An ERC20 standard
//
// author: Gifto Team
// Contact: datwhnguyen@gmail.com

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
  
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
contract Gifto is ERC20Interface {
    uint public constant decimals = 5;

    string public constant symbol = "Gifto";
    string public constant name = "Gifto";

    bool public _selling = false;//initial not selling
    uint public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 Gifto
    uint public _originalBuyPrice = 10 ** 10; // original buy in wei of one unit. Ajustable.

    // Owner of this contract
    address public owner;
 
    // Balances Gifto for each account
    mapping(address => uint256) balances;

    // List of approved investors
    mapping(address => bool) approvedInvestorList;
    
    // mapping Deposit
    mapping(address => uint256) deposit;
    
    // buyers buy token deposit
    address[] buyers;
    
    // icoPercent
    uint _icoPercent = 10;
    
    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    uint public _icoSupply = _totalSupply * _icoPercent / 100;
    
    // minimum buy 0.1 ETH
    uint public _minimumBuy = 10 ** 17;
    
    // maximum buy 30 ETH
    uint public _maximumBuy = 30 * 10 ** 18;
    
    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Functions with this modifier can only be executed by users except owners
     */
    modifier onlyNotOwner() {
        require(msg.sender != owner);
        _;
    }

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling && (_icoSupply > 0) );
        _;
    }

    /**
     * Functions with this modifier check the validity of original buy price
     */
    modifier validOriginalBuyPrice() {
        require(_originalBuyPrice > 0);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of address is investor
     */
    modifier validInvestor() {
        require(approvedInvestorList[msg.sender]);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of msg value
     * value must greater than equal minimumBuyPrice
     * total deposit must less than equal maximumBuyPrice
     */
    modifier validValue(){
        // if value < _minimumBuy OR total deposit of msg.sender > maximumBuyPrice
        require ( (msg.value >= _minimumBuy) &&
                ( (deposit[msg.sender] + msg.value) <= _maximumBuy) );
        _;
    }

    /// @dev Fallback function allows to buy ether.
    function()
        public
        payable
        validValue {
        // check the first buy => push to Array
        if (deposit[msg.sender] == 0 && msg.value != 0){
            // add new buyer to List
            buyers.push(msg.sender);
        }
        // increase amount deposit of buyer
        deposit[msg.sender] += msg.value;
    }

    /// @dev Constructor
    function Gifto() 
        public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }
    
    /// @dev Gets totalSupply
    /// @return Total supply
    function totalSupply()
        public 
        constant 
        returns (uint256) {
        return _totalSupply;
    }
    
    /// @dev set new icoPercent
    /// @param newIcoPercent new value of icoPercent
    function setIcoPercent(uint256 newIcoPercent)
        public 
        onlyOwner
        returns (bool){
        _icoPercent = newIcoPercent;
        _icoSupply = _totalSupply * _icoPercent / 100;
    }
    
    /// @dev set new _minimumBuy
    /// @param newMinimumBuy new value of _minimumBuy
    function setMinimumBuy(uint256 newMinimumBuy)
        public 
        onlyOwner
        returns (bool){
        _minimumBuy = newMinimumBuy;
    }
    
    /// @dev set new _maximumBuy
    /// @param newMaximumBuy new value of _maximumBuy
    function setMaximumBuy(uint256 newMaximumBuy)
        public 
        onlyOwner
        returns (bool){
        _maximumBuy = newMaximumBuy;
    }
 
    /// @dev Gets account's balance
    /// @param _addr Address of the account
    /// @return Account balance
    function balanceOf(address _addr) 
        public
        constant 
        returns (uint256) {
        return balances[_addr];
    }
    
    /// @dev check address is approved investor
    /// @param _addr address
    function isApprovedInvestor(address _addr)
        public
        constant
        returns (bool) {
        return approvedInvestorList[_addr];
    }
    
    /// @dev filter buyers in list buyers
    /// @param isInvestor type buyers, is investor or not
    function filterBuyers(bool isInvestor)
        private
        constant
        returns(address[] filterList){
        address[] memory filterTmp = new address[](buyers.length);
        uint count = 0;
        for (uint i = 0; i < buyers.length; i++){
            if(approvedInvestorList[buyers[i]] == isInvestor){
                filterTmp[count] = buyers[i];
                count++;
            }
        }
        
        filterList = new address[](count);
        for (i = 0; i < count; i++){
            if(filterTmp[i] != 0x0){
                filterList[i] = filterTmp[i];
            }
        }
    }
    
    /// @dev filter buyers are investor in list deposited
    function getInvestorBuyers()
        public
        constant
        returns(address[]){
        return filterBuyers(true);
    }
    
    /// @dev filter normal Buyers in list buyer deposited
    function getNormalBuyers()
        public
        constant
        returns(address[]){
        return filterBuyers(false);
    }
    
    /// @dev get ETH deposit
    /// @param _addr address get deposit
    /// @return amount deposit of an buyer
    function getDeposit(address _addr)
        public
        constant
        returns(uint256){
        return deposit[_addr];
    }
    
    /// @dev get total deposit of buyers
    /// @return amount ETH deposit
    function getTotalDeposit()
        public
        constant
        returns(uint256 totalDeposit){
        totalDeposit = 0;
        for (uint i = 0; i < buyers.length; i++){
            totalDeposit += deposit[buyers[i]];
        }
    }
    
    /// @dev delivery token for buyer
    /// @param isInvestor transfer token for investor or not
    ///         true: investors
    ///         false: not investors
    function deliveryToken(bool isInvestor)
        public
        onlyOwner
        validOriginalBuyPrice {
        //sumary deposit of investors
        uint256 sum = 0;
        
        for (uint i = 0; i < buyers.length; i++){
            if(approvedInvestorList[buyers[i]] == isInvestor) {
                
                // compute amount token of each buyer
                uint256 requestedUnits = deposit[buyers[i]] / _originalBuyPrice;
                
                //check requestedUnits > _icoSupply
                if(requestedUnits <= _icoSupply && requestedUnits > 0 ){
                    // prepare transfer data
                    // NOTE: make sure balances owner greater than _icoSupply
                    balances[owner] -= requestedUnits;
                    balances[buyers[i]] += requestedUnits;
                    _icoSupply -= requestedUnits;
                    
                    // submit transfer
                    Transfer(owner, buyers[i], requestedUnits);
                    
                    // reset deposit of buyer
                    sum += deposit[buyers[i]];
                    deposit[buyers[i]] = 0;
                }
            }
        }
        //transfer total ETH of investors to owner
        owner.transfer(sum);
    }
    
    /// @dev return ETH for normal buyers
    function returnETHforNormalBuyers()
        public
        onlyOwner{
        for(uint i = 0; i < buyers.length; i++){
            // buyer not approve investor
            if (!approvedInvestorList[buyers[i]]) {
                // get deposit of buyer
                uint256 buyerDeposit = deposit[buyers[i]];
                // reset deposit of buyer
                deposit[buyers[i]] = 0;
                // return deposit amount for buyer
                buyers[i].transfer(buyerDeposit);
            }
        }
    }
 
    /// @dev Transfers the balance from Multisig wallet to an account
    /// @param _to Recipient address
    /// @param _amount Transfered amount in unit
    /// @return Transfer status
    function transfer(address _to, uint256 _amount)
        public 
        returns (bool) {
        // if sender's balance has enough unit and amount >= 0, 
        //      and the sum is not overflow,
        // then do transfer 
        if ( (balances[msg.sender] >= _amount) &&
             (_amount >= 0) && 
             (balances[_to] + _amount > balances[_to]) ) {  

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            
            return true;

        } else {
            revert();
        }
    }

    /// @dev Enables sale 
    function turnOnSale() onlyOwner 
        public {
        _selling = true;
    }

    /// @dev Disables sale
    function turnOffSale() onlyOwner 
        public {
        _selling = false;
    }

    /// @dev Gets selling status
    function isSellingNow() 
        public 
        constant
        returns (bool) {
        return _selling;
    }

    /// @dev Updates buy price (owner ONLY)
    /// @param newBuyPrice New buy price (in unit)
    function setBuyPrice(uint newBuyPrice) 
        onlyOwner 
        public {
        _originalBuyPrice = newBuyPrice;
    }

    /// @dev Adds list of new investors to the investors list and approve all
    /// @param newInvestorList Array of new investors addresses to be added
    function addInvestorList(address[] newInvestorList)
        onlyOwner
        public {
        for (uint i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    /// @dev Removes list of investors from list
    /// @param investorList Array of addresses of investors to be removed
    function removeInvestorList(address[] investorList)
        onlyOwner
        public {
        for (uint i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }

    /// @dev Buys Gifto
    /// @return Amount of requested units 
    function buy() payable
        onlyNotOwner 
        validOriginalBuyPrice
        validInvestor
        onSale 
        public
        returns (uint256 amount) {
        // convert buy amount in wei to number of unit want to buy
        uint requestedUnits = msg.value / _originalBuyPrice ;
        
        //check requestedUnits <= _icoSupply
        require(requestedUnits <= _icoSupply);

        // prepare transfer data
        balances[owner] -= requestedUnits;
        balances[msg.sender] += requestedUnits;
        
        // decrease _icoSupply
        _icoSupply -= requestedUnits;

        // submit transfer
        Transfer(owner, msg.sender, requestedUnits);

        //transfer ETH to owner
        owner.transfer(msg.value);
        
        return requestedUnits;
    }
    
    /// @dev Withdraws Ether in contract (Owner only)
    /// @return Status of withdrawal
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
}

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
contract MultiSigWallet {

    event Confirmation(address sender, bytes32 transactionId);
    event Revocation(address sender, bytes32 transactionId);
    event Submission(bytes32 transactionId);
    event Execution(bytes32 transactionId);
    event Deposit(address sender, uint value);
    event OwnerAddition(address owner);
    event OwnerRemoval(address owner);
    event RequirementChange(uint required);
    event CoinCreation(address coin);

    mapping (bytes32 => Transaction) public transactions;
    mapping (bytes32 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] owners;
    bytes32[] transactionList;
    uint public required;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        uint nonce;
        bool executed;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier confirmed(bytes32 transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(bytes32 transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(bytes32 transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address destination) {
        require(destination != 0);
        _;
    }

    modifier validRequirement(uint _ownerCount, uint _required) {
        require(   _required <= _ownerCount
                && _required > 0 );
        _;
    }
    
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function MultiSigWallet(address[] _owners, uint _required)
        validRequirement(_owners.length, _required)
        public {
        for (uint i=0; i<_owners.length; i++) {
            // check duplicate owner and invalid address
            if (isOwner[_owners[i]] || _owners[i] == 0){
                revert();
            }
            // assign new owner
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    ///  Fallback function allows to deposit ether.
    function()
        public
        payable {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner) {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner) {
        // DO NOT remove last owner
        require(owners.length > 1);
        
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    /// @dev Update the minimum required owner for transaction validation
    /// @param _required number of owners
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required) {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @param nonce 
    /// @return transactionId.
    function addTransaction(address destination, uint value, bytes data, uint nonce)
        private
        notNull(destination)
        returns (bytes32 transactionId) {
        // transactionId = sha3(destination, value, data, nonce);
        transactionId = keccak256(destination, value, data, nonce);
        if (transactions[transactionId].destination == 0) {
            transactions[transactionId] = Transaction({
                destination: destination,
                value: value,
                data: data,
                nonce: nonce,
                executed: false
            });
            transactionList.push(transactionId);
            Submission(transactionId);
        }
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @param nonce 
    /// @return transactionId.
    function submitTransaction(address destination, uint value, bytes data, uint nonce)
        external
        ownerExists(msg.sender)
        returns (bytes32 transactionId) {
        transactionId = addTransaction(destination, value, data, nonce);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId transaction Id.
    function confirmTransaction(bytes32 transactionId)
        public
        ownerExists(msg.sender)
        notConfirmed(transactionId, msg.sender) {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    
    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId transaction Id.
    function executeTransaction(bytes32 transactionId)
        public
        notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId]; 
            txn.executed = true;
            if (!txn.destination.call.value(txn.value)(txn.data))
                revert();
            Execution(transactionId);
        }
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId transaction Id.
    function revokeConfirmation(bytes32 transactionId)
        external
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId) {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId transaction Id.
    /// @return Confirmation status.
    function isConfirmed(bytes32 transactionId)
        public
        constant
        returns (bool) {
        uint count = 0;
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId transaction Id.
    /// @return Number of confirmations.
    function confirmationCount(bytes32 transactionId)
        external
        constant
        returns (uint count) {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    ///  @dev Return list of transactions after filters are applied
    ///  @param isPending pending status
    ///  @return List of transactions
    function filterTransactions(bool isPending)
        private
        constant
        returns (bytes32[] _transactionList) {
        bytes32[] memory _transactionListTemp = new bytes32[](transactionList.length);
        uint count = 0;
        for (uint i=0; i<transactionList.length; i++)
            if (transactions[transactionList[i]].executed != isPending)
            {
                _transactionListTemp[count] = transactionList[i];
                count += 1;
            }
        _transactionList = new bytes32[](count);
        for (i=0; i<count; i++)
            if (_transactionListTemp[i] > 0)
                _transactionList[i] = _transactionListTemp[i];
    }

    /// @dev Returns list of pending transactions
    function getPendingTransactions()
        external
        constant
        returns (bytes32[]) {
        return filterTransactions(true);
    }

    /// @dev Returns list of executed transactions
    function getExecutedTransactions()
        external
        constant
        returns (bytes32[]) {
        return filterTransactions(false);
    }
    
    /// @dev Create new coin.
    function createCoin()
        external
        onlyWallet
    {
        CoinCreation(new Gifto());
    }
}