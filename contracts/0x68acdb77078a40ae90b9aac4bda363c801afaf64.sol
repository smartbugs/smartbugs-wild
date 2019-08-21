pragma solidity >=0.4.24;

/**
 * @title -Security PO8 Token
 * SPO8 contract records the core attributes of SPO8 Token
 * 
 * ███████╗██████╗  ██████╗  █████╗     ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗
 * ██╔════╝██╔══██╗██╔═══██╗██╔══██╗    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║
 * ███████╗██████╔╝██║   ██║╚█████╔╝       ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║
 * ╚════██║██╔═══╝ ██║   ██║██╔══██╗       ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║
 * ███████║██║     ╚██████╔╝╚█████╔╝       ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║
 * ╚══════╝╚═╝      ╚═════╝  ╚════╝        ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
 * ---
 * POWERED BY
 *  __    ___   _     ___  _____  ___     _     ___
 * / /`  | |_) \ \_/ | |_)  | |  / / \   | |\ |  ) )
 * \_\_, |_| \  |_|  |_|    |_|  \_\_/   |_| \| _)_)
 * Company Info at https://po8.io
 * code at https://github.com/crypn3
 */

contract SPO8 {
    using SafeMath for uint256;
    
    /* All props and event of Company */
    // Company informations
    string public companyName;
    string public companyLicenseID;
    string public companyTaxID;
    string public companySecurityID;
    string public companyURL;
    address public CEO;
    string public CEOName;
    address public CFO;
    string public CFOName;
    address public BOD; // Board of directer
    
    event CEOTransferred(address indexed previousCEO, address indexed newCEO);
    event CEOSuccession(string previousCEO, string newCEO);
    event CFOTransferred(address indexed previousCFO, address indexed newCFO);
    event CFOSuccession(string previousCFO, string newCFO);
    event BODTransferred(address indexed previousBOD, address indexed newBOD);
    
    // Threshold
    uint256 public threshold;
    /* End Company */
    
    /* All props and event of user */
    
    address[] internal whiteListUser; // List of User
    
    // Struct of User Information
    struct Infor{
        string userName;
        string phone;
        string certificate;
    }
    
    mapping(address => Infor) internal userInfor;
    
    mapping(address => uint256) internal userPurchasingTime; // The date when user purchases tokens from Sale contract.
    
    uint256 public transferLimitationTime = 31536000000; // 1 year
    
    event UserInforUpdated(address indexed user, string name, string phone, string certificate);
    event NewUserAdded(address indexed newUser);
    event UserRemoved(address indexed user);
    event UserUnlocked(address indexed user);
    event UserLocked(address indexed user);
    event LimitationTimeSet(uint256 time);
    event TokenUnlocked(uint256 time);
    /* End user */
    
    /* Sale token Contracts address */
    address[] internal saleContracts;
    
    event NewSaleContractAdded(address _saleContractAddress);
    event SaleContractRemoved(address _saleContractAddress);
    /* End Sale Contract */
    
    /* All props and event of SPO8 token */
    // Token informations
    string public name;
    string public symbol;
    uint256 internal _totalSupply;

    mapping (address => uint256) internal balances;

    mapping (address => mapping (address => uint256)) internal allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BODBudgetApproval(address indexed owner, address indexed spender, uint256 value, address indexed to);
    event AllowanceCanceled(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 totalMint);
    /* End Token */
    
    // Boss's power
    modifier onlyBoss() {
        require(msg.sender == CEO || msg.sender == CFO);
        _;
    }
    
    // BOD's power
    modifier onlyBOD {
        require(msg.sender == BOD);
        _;
    }
    
    // Change CEO and CFO and BOD address or name
    function changeCEO(address newCEO) public onlyBoss {
        require(newCEO != address(0));
        emit CEOTransferred(CEO, newCEO);
        CEO = newCEO;
    }
    
    function changeCEOName(string newName) public onlyBoss {
        emit CEOSuccession(CEOName, newName);
        CEOName = newName;
    }
    
    function changeCFO(address newCFO) public onlyBoss {
        require(newCFO != address(0));
        emit CEOTransferred(CFO, newCFO);
        CFO = newCFO;
    }
    
    function changeCFOName(string newName) public onlyBoss {
        emit CFOSuccession(CFOName, newName);
        CFOName = newName;
    }
    
    function changeBODAddress(address newBOD) public onlyBoss {
        require(newBOD != address(0));
        emit BODTransferred(BOD, newBOD);
        BOD = newBOD;
    }
    
    // Informations of special Transfer
    /**
     * @dev: TransferState is a state of special transation. (sender have balance more than 10% total supply) 
     * State: Fail - 0.
     * State: Success - 1.
     * State: Pending - 2 - default state.
    */
    enum TransactionState {
        Fail,
        Success,
        Pending
    }
        
    /**
     * @dev Struct of one special transaction.
     * from The sender of transaction.
     * to The receiver of transaction.
     * value Total tokens is sended.
     * state State of transaction.
     * date The date when transaction is made.
    */
    struct Transaction {
        address from;
        address to;
        uint256 value;
        TransactionState state;
        uint256 date;
        address bod;
    }
    
     
    Transaction[] internal specialTransactions; // An array where is used to save special transactions
    
    // Contract's constructor
    constructor (uint256 totalSupply_,
                address _CEO, 
                string _CEOName, 
                address _CFO, 
                string _CFOName,
                address _BOD) public {
        name = "Security PO8 Token";
        symbol = "SPO8";
        _totalSupply = totalSupply_;
        companyName = "PO8 Ltd";
        companyTaxID = "IBC";
        companyLicenseID = "No. 203231 B";
        companySecurityID = "qKkFiGP4235d";
        companyURL = "https://po8.io";
        CEO = _CEO;
        CEOName = _CEOName; // Mathew Arnett
        CFO = _CFO;
        CFOName = _CFOName; // Raul Vasquez
        BOD = _BOD;
        threshold = (totalSupply_.mul(10)).div(100); // threshold = 10% of totalSupply
        balances[CEO] = totalSupply_;
    }
    
    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
    
    /**
     * @dev Mint more tokens
     * @param _totalMint total token will be minted and transfer to CEO wallet.
    */
    function mint(uint256 _totalMint) external onlyBoss returns (bool) {
        balances[CEO] += _totalMint;
        _totalSupply += _totalMint;
        threshold = (_totalSupply.mul(10)).div(100);
        
        emit Mint(address(0), CEO, _totalMint);
        
        return true;
    }
    
    /**
    * @dev Transfer token for a specified address (utilities function)
    * @param _from address The address which you want to send tokens from
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        require(balances[_from] >= _value);
        require(balances[_to].add(_value) > balances[_to]);
        require(checkWhiteList(_from));
        require(checkWhiteList(_to));
        require(!checkLockedUser(_from));
        
        if(balances[_from] < threshold || msg.sender == CEO || msg.sender == CFO || msg.sender == BOD) {
            uint256 previousBalances = balances[_from].add(balances[_to]);
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
    
            assert(balances[_from].add(balances[_to]) == previousBalances);
        }
        
        else {
            specialTransfer(_from, _to, _value); // waiting for acceptance from board of directer
            emit Transfer(_from, _to, 0);
        }
    }
    
    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
		return true;
    }
    
    /**
    * @dev Special Transfer token for a specified address, but waiting for acceptance from BOD, and push transaction infor to specialTransactions array
    * @param _from The address transfer from.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function specialTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
        specialTransactions.push(Transaction({from: _from, to: _to, value: _value, state: TransactionState.Pending, date: now.mul(1000), bod: BOD}));
        approveToBOD(_value, _to);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0));
        require(_spender != BOD);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
    * @dev The approval to BOD address who will transfer the funds from msg.sender to address _to.  
    * @param _value The amount of tokens to be spent.
    * @param _to The address which will receive the funds from msg.sender.
    */
    function approveToBOD(uint256 _value, address _to) internal returns (bool) {
        if(allowed[msg.sender][BOD] > 0)
            allowed[msg.sender][BOD] = (allowed[msg.sender][BOD].add(_value));
        else
            allowed[msg.sender][BOD] = _value;
        emit BODBudgetApproval(msg.sender, BOD, _value, _to);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);     // Check allowance
        require(msg.sender != BOD);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    
    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        require(_spender != address(0));
        require(_spender != BOD);

        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        require(_spender != address(0));
        require(_spender != BOD);

        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].sub(_subtractedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    /**
     * @dev Cancel allowance of address from to BOD
     * @param _from The address of whom approve tokens to BOD for spend.
     * @param _value Total tokens are canceled.
     */
    function cancelAllowance(address _from, uint256 _value) internal onlyBOD {
        require(_from != address(0));
        
        allowed[_from][BOD] = allowed[_from][BOD].sub(_value);
        emit AllowanceCanceled(_from, BOD, _value);
    }
    
    /**
    * @dev Only CEO or CFO can add new users.
    * @param _newUser The address which will add to whiteListUser array.
    */
    function addUser(address _newUser) external onlyBoss returns (bool) {
        require (!checkWhiteList(_newUser));
        whiteListUser.push(_newUser);
        emit NewUserAdded(_newUser);
        return true;
    }
    
    /**
    * @dev Only CEO or CFO can add new users.
    * @param _newUsers The address array which will add to whiteListUser array.
    */
    function addUsers(address[] _newUsers) external onlyBoss returns (bool) {
        for(uint i = 0; i < _newUsers.length; i++)
        {
            whiteListUser.push(_newUsers[i]);
            emit NewUserAdded(_newUsers[i]);
        }
        return true;
    }
    
    /**
    * @dev Return total users in white list array.
    */
    function totalUsers() public view returns (uint256 users) {
        return whiteListUser.length;
    }
    
    /**
    * @dev Checking the user address whether in WhiteList or not.
    * @param _user The address which will be checked.
    */
    function checkWhiteList(address _user) public view returns (bool) {
        uint256 length = whiteListUser.length;
        for(uint i = 0; i < length; i++)
            if(_user == whiteListUser[i])
                return true;
        
        return false;
    }
    
     /**
    * @dev Delete the user address in WhiteList.
    * @param _user The address which will be delete.
    * After the function excuted, address in the end of list will be moved to postion of deleted user.
    */
    function deleteUser(address _user) external onlyBoss returns (bool) {
        require(checkWhiteList(_user));
        
        uint256 i;
        uint256 length = whiteListUser.length;
        
        for(i = 0; i < length; i++)
        {
            if (_user == whiteListUser[i])
                break;
        }
        
        whiteListUser[i] = whiteListUser[length - 1];
        delete whiteListUser[length - 1];
        whiteListUser.length--;
        
        emit UserRemoved(_user);
        return true;
    }
    
    /**
    * @dev User or CEO or CFO can update user address informations.
    * @param _user The address which will be checked.
    * @param _name The new name
    * @param _phone The new phone number
    */
    function updateUserInfor(address _user, string _name, string _phone, string _certificate) external onlyBoss returns (bool) {
        require(checkWhiteList(_user));
        
        userInfor[_user].userName = _name;
        userInfor[_user].phone = _phone;
        userInfor[_user].certificate = _certificate;
        emit UserInforUpdated(_user, _name, _phone, _certificate);
        
        return true;
    }
    
    /**
    * @dev User can get address informations.
    * @param _user The address which will be checked.
    */
    function getUserInfor(address _user) public view returns (string, string) {
        require(msg.sender == _user);
        require(checkWhiteList(_user));
        
        Infor memory infor = userInfor[_user];
        
        return (infor.userName, infor.phone);
    }
    
    /**
    * @dev CEO and CFO can lock user address, prevent them from transfer token action. If users buy token from any sale contracts, user address also will be locked in 1 year.
    * @param _user The address which will be locked.
    */
    function lockUser(address _user) external returns (bool) {
        require(checkSaleContracts(msg.sender) || msg.sender == CEO || msg.sender == CFO);
        
        userPurchasingTime[_user] = now.mul(1000);
        emit UserLocked(_user);
        
        return true;
    }
    
    /**
    * @dev CEO and CFO can unlock user address. That address can do transfer token action.
    * @param _user The address which will be unlocked.
    */
    function unlockUser(address _user) external onlyBoss returns (bool) {
        userPurchasingTime[_user] = 0;
        emit UserUnlocked(_user);
        
        return true;
    }
    
    /**
    * @dev The function check the user address whether locked or not.
    * @param _user The address which will be checked.
    * if now sub User Purchasing Time < 1 year => Address is locked. In contrast, the address is unlocked.
    * @return true The address is locked.
    * @return false The address is unlock.
    */
    function checkLockedUser(address _user) public view returns (bool) {
        if ((now.mul(1000)).sub(userPurchasingTime[_user]) < transferLimitationTime)
            return true;
        return false;
    }
    
    /**
    * @dev CEO or CFO can set transferLimitationTime.
    * @param _time The new time will be set.
    */
    function setLimitationTime(uint256 _time) external onlyBoss returns (bool) {
        transferLimitationTime = _time;
        emit LimitationTimeSet(_time);
        
        return true;
    }
    
    /**
    * @dev CEO or CFO can unlock tokens.
    * transferLimitationTime = 0;
    */
    function unlockToken() external onlyBoss returns (bool) {
        transferLimitationTime = 0;
        emit TokenUnlocked(now.mul(1000)); 
        return true;
    }
    
    /**
    * @dev Get special transaction informations
    * @param _index The index of special transaction which user want to know about.
    */
    function getSpecialTxInfor(uint256 _index) public view returns (address from, 
                                                                            address to,
                                                                            uint256 value, 
                                                                            TransactionState state, 
                                                                            uint256 date, 
                                                                            address bod) {
        Transaction storage txInfor = specialTransactions[_index];
        return (txInfor.from, txInfor.to, txInfor.value, txInfor.state, txInfor.date, txInfor.bod);
    }
    
    /**
    * @dev Get total special pending transaction
    */
    function getTotalPendingTxs() internal view returns (uint32) {
        uint32 count;
        TransactionState txState = TransactionState.Pending;
        for(uint256 i = 0; i < specialTransactions.length; i++) {
            if(specialTransactions[i].state == txState)
                count++;
        }
        return count;
    }
    
    /**
     * @dev Get pending transation IDs from Special Transactions array
     */
    function getPendingTxIDs() public view returns (uint[]) {
        uint32 totalPendingTxs = getTotalPendingTxs();
        uint[] memory pendingTxIDs = new uint[](totalPendingTxs);
        uint32 id = 0;
        TransactionState txState = TransactionState.Pending;
        for(uint256 i = 0; i < specialTransactions.length; i++) {
            if(specialTransactions[i].state == txState) {
                pendingTxIDs[id] = i;
                id++;
            }
        }
        return pendingTxIDs;
    }
    
    /**
     * @dev The function handle pending special transaction. Only BOD can use it.
     * @param _index The id of pending transaction is in specialTransactions array.
     * @param _decision The decision of BOD to handle pending Transaction (true or false).
     * If true: transfer tokens from address txInfo.from to address txInfo.to and set state of that tx to Success.
     * If false: cancel allowance from address txInfo.from to BOD and set state of that tx to Fail.
     */
    function handlePendingTx(uint256 _index, bool _decision) public onlyBOD returns (bool) {
        Transaction storage txInfo = specialTransactions[_index];
        require(txInfo.state == TransactionState.Pending);
        require(txInfo.bod == BOD);
        
        if(_decision) {
            require(txInfo.value <= allowed[txInfo.from][BOD]);
            
            allowed[txInfo.from][BOD] = allowed[txInfo.from][BOD].sub(txInfo.value);
            _transfer(txInfo.from, txInfo.to, txInfo.value);
            txInfo.state = TransactionState.Success;
        }
        else {
            txInfo.state = TransactionState.Fail;
            cancelAllowance(txInfo.from, txInfo.value);
        }
        return true;
    }
    
    /**
     * @dev The function check an address whether in saleContracts array or not.
     * @param _saleContract The address will be checked.
     */
    function checkSaleContracts(address _saleContract) public view returns (bool) {
        uint256 length = saleContracts.length;
        for(uint i = 0; i < length; i++) {
            if(saleContracts[i] == _saleContract)
                return true;
        }
        return false;
    }
    
    /**
     * @dev The function adds new sale contract address to saleContracts array.
     * @param _newSaleContract The address will be added.
     */
    function addNewSaleContract(address _newSaleContract) external onlyBoss returns (bool) {
        require(!checkSaleContracts(_newSaleContract));
        
        saleContracts.push(_newSaleContract);
        emit NewSaleContractAdded(_newSaleContract);
        
        return true;
    }
    
    /**
     * @dev The function remove sale contract address from saleContracts array.
     * @param _saleContract The address will be removed.
     */
    function removeSaleContract(address _saleContract) external onlyBoss returns (bool) {
        require(checkSaleContracts(_saleContract));
        
        uint256 length = saleContracts.length;
        uint256 i;
        for(i = 0; i < length; i++) {
            if(saleContracts[i] == _saleContract)
                break;
        }
        
        saleContracts[i] = saleContracts[length - 1];
        delete saleContracts[length - 1];
        saleContracts.length--;
        emit SaleContractRemoved(_saleContract);
        
        return true;
    }
    
    // Contract does not accept Ether
    function () public payable {
        revert();
    }
}

/**
 * @title SafeMath library
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
    
        uint256 c = a * b;
        require(c / a == b);
    
        return c;
    }
    
    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        require(a == b * c);
    
        return c;
    }
    
    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
    
        return c;
    }
    
    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
    
        return c;
    }
    
    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}