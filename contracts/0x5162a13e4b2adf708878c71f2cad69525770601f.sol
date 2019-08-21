pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------------------------
// Acute Angle Coin by Triangle Technology Co., Ltd. Limited.
// An ERC20 standard
//
// author: AAC Team

contract ERC20Interface {
    function totalSupply() public constant returns (uint256 _totalSupply);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
contract AcuteAngleCoin is ERC20Interface {
    uint256 public constant decimals = 5;

    string public constant symbol = "AAC";
    string public constant name = "AcuteAngleCoin";

    bool public _selling = true;//initial selling
    uint256 public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 AAC
    uint256 public _originalBuyPrice = 39 * 10**7; // original buy 1ETH = 3900 AAC = 39 * 10**7 unit

    // Owner of this contract
    address public owner;
 
    // Balances AAC for each AACount
    mapping(address => uint256) private balances;
    
    // Owner of AACount approves the transfer of an amount to another AACount
    mapping(address => mapping (address => uint256)) private allowed;

    // List of approved investors
    mapping(address => bool) private approvedInvestorList;
    
    // deposit
    mapping(address => uint256) private deposit;
       

    // totalTokenSold
    uint256 public totalTokenSold = 0;
    
    // tradable
    bool public tradable = false;
    
    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling);
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
     * 
     */
    modifier isTradable(){
        require(tradable == true || msg.sender == owner);
        _;
    }

    /// @dev Fallback function allows to buy ether.
    function()
        public
        payable {
        buyAAC();
    }
    
    /// @dev buy function allows to buy ether. for using optional data
    function buyAAC()
        public
        payable
        onSale
        validInvestor {
        uint256 requestedUnits = (msg.value * _originalBuyPrice) / 10**18;
        require(balances[owner] >= requestedUnits);
        // prepare transfer data
        balances[owner] -= requestedUnits;
        balances[msg.sender] += requestedUnits;
        
        // increase total deposit amount
        deposit[msg.sender] += msg.value;
        
        // check total and auto turnOffSale
        totalTokenSold += requestedUnits;
        
        // submit transfer
        Transfer(owner, msg.sender, requestedUnits);
        owner.transfer(msg.value);
    }

    /// @dev Constructor
    function AAC() 
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
    
    function turnOnTradable() 
        public
        onlyOwner{
        tradable = true;
    }
        
    /// @dev Gets AACount's balance
    /// @param _addr Address of the AACount
    /// @return AACount balance
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
    
    /// @dev get ETH deposit
    /// @param _addr address get deposit
    /// @return amount deposit of an buyer
    function getDeposit(address _addr)
        public
        constant
        returns(uint256){
        return deposit[_addr];
}
    
    /// @dev Adds list of new investors to the investors list and approve all
    /// @param newInvestorList Array of new investors addresses to be added
    function addInvestorList(address[] newInvestorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    /// @dev Removes list of investors from list
    /// @param investorList Array of addresses of investors to be removed
    function removeInvestorList(address[] investorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }
 
    /// @dev Transfers the balance from msg.sender to an AACount
    /// @param _to Recipient address
    /// @param _amount Transfered amount in unit
    /// @return Transfer status
    function transfer(address _to, uint256 _amount)
        public 
        isTradable
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
            return false;
        }
    }
     
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from AACount has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
    public
    isTradable
    returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    // Allow _spender to withdraw from your AACount, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) 
        public
        isTradable
        returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    // get allowance
    function allowance(address _owner, address _spender) 
        public
        constant 
        returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    /// @dev Withdraws Ether in contract (Owner only)
    /// @return Status of withdrawal
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
}