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