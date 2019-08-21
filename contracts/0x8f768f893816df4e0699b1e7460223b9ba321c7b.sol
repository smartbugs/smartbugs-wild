pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}






contract BaseLBSCSale {
    using SafeMath for uint256;

    address public owner;
    bool public paused = false;
    // The beneficiary is the future recipient of the funds
    address public beneficiary;

    // The crowdsale has a funding goal, cap, deadline, and minimum contribution
    uint public fundingGoal;
    uint public fundingCap;
    uint public minContribution;
    uint public decimals;
    bool public fundingGoalReached = false;
    bool public fundingCapReached = false;
    bool public saleClosed = false;

    // Time period of sale (UNIX timestamps)
    uint public startTime;
    uint public endTime;

    // Keeps track of the amount of wei raised
    uint public amountRaised;

    // Refund amount, should it be required
    uint public refundAmount;

    // The ratio of CHP to Ether
    uint public rate = 220;

    // prevent certain functions from being recursively called
    bool private rentrancy_lock = false;

    // A map that tracks the amount of wei contributed by address
    mapping(address => uint256) public balanceOf;

    address public manager;

    // Events
    event GoalReached(address _beneficiary, uint _amountRaised);
    event CapReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event Pause();
    event Unpause();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner,"Only the owner is allowed to call this."); 
        _; 
    }

    modifier onlyOwnerOrManager{
        require(msg.sender == owner || msg.sender == manager, "Only owner or manager is allowed to call this");
        _;
    }

    modifier beforeDeadline(){
        require (currentTime() < endTime, "Validation: Before endtime");
        _;
    }
    modifier afterDeadline(){
        require (currentTime() >= endTime, "Validation: After endtime"); 
        _;
    }
    modifier afterStartTime(){
        require (currentTime() >= startTime, "Validation: After starttime"); 
        _;
    }

    modifier saleNotClosed(){
        require (!saleClosed, "Sale is not yet ended"); 
        _;
    }

    modifier nonReentrant() {
        require(!rentrancy_lock, "Validation: Reentrancy");
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused, "You are not allowed to access this time.");
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "You are not allowed to access this time.");
        _;
    }

    constructor() public{
        owner = msg.sender;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Owner cannot be 0 address.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwnerOrManager whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwnerOrManager whenPaused {
        paused = false;
        emit Unpause();
    }

    /**
     * Returns the current time.
     * Useful to abstract calls to "now" for tests.
    */
    function currentTime() public view returns (uint _currentTime) {
        return block.timestamp;
    }

    /**
     * The owner can terminate the crowdsale at any time.
     */
    function terminate() external onlyOwnerOrManager {
        saleClosed = true;
    }

    /**
     * The owner can update the rate (CHP to ETH).
     *
     * @param _rate  the new rate for converting CHP to ETH
     */
    function setRate(uint _rate) public onlyOwnerOrManager {
        //require(_rate >= LOW_RANGE_RATE && _rate <= HIGH_RANGE_RATE);
        rate = _rate;
    }

    /**
     * The owner can unlock the fund with this function. The use-
     * case for this is when the owner decides after the deadline
     * to allow contributors to be refunded their contributions.
     * Note that the fund would be automatically unlocked if the
     * minimum funding goal were not reached.
     */
    function ownerUnlockFund() external afterDeadline onlyOwner {
        fundingGoalReached = false;
    }

    /**
     * Checks if the funding goal has been reached. If it has, then
     * the GoalReached event is triggered.
     */
    function checkFundingGoal() internal {
        if (!fundingGoalReached) {
            if (amountRaised >= fundingGoal) {
                fundingGoalReached = true;
                emit GoalReached(beneficiary, amountRaised);
            }
        }
    }

    /**
     * Checks if the funding cap has been reached. If it has, then
     * the CapReached event is triggered.
     */
    function checkFundingCap() internal {
        if (!fundingCapReached) {
            if (amountRaised >= fundingCap) {
                fundingCapReached = true;
                saleClosed = true;
                emit CapReached(beneficiary, amountRaised);
            }
        }
    }

    /**
     * These helper functions are exposed for changing the start and end time dynamically   
     */
    function changeStartTime(uint256 _startTime) external onlyOwnerOrManager {startTime = _startTime;}
    function changeEndTime(uint256 _endTime) external onlyOwnerOrManager {endTime = _endTime;}
    function changeMinContribution(uint256 _newValue) external onlyOwnerOrManager {minContribution = _newValue * (10 ** decimals);}
}






contract BaseLBSCToken {
    using SafeMath for uint256;

    // Globals
    address public owner;
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Mint(address indexed to, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner,"Only the owner is allowed to call this."); 
        _; 
    }

    constructor() public{
        owner = msg.sender;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender], "You do not have sufficient balance.");
        require(_to != address(0), "You cannot send tokens to 0 address");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(_value <= balances[_from], "You do not have sufficient balance.");
        require(_value <= allowed[_from][msg.sender], "You do not have allowance.");
        require(_to != address(0), "You cannot send tokens to 0 address");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
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
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool){
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool){
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who], "Insufficient balance of tokens");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance
    * @param _from address The address which you want to send tokens from
    * @param _value uint256 The amount of token to be burned
    */
    function burnFrom(address _from, uint256 _value) public {
        require(_value <= allowed[_from][msg.sender], "Insufficient allowance to burn tokens.");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Owner cannot be 0 address.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}

contract LBSCToken is BaseLBSCToken {
    
    // Constants
    string  public constant name = "LabelsCoin";
    string  public constant symbol = "LBSC";
    uint8   public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY      =  30000000 * (10 ** uint256(decimals));
    //uint256 public constant CROWDSALE_ALLOWANCE =  1000000000 * (10 ** uint256(decimals));
    uint256 public constant ADMIN_ALLOWANCE     =  30000000 * (10 ** uint256(decimals));
    
    // Properties
    //uint256 public totalSupply;
    //uint256 public crowdSaleAllowance;      // the number of tokens available for crowdsales
    uint256 public adminAllowance;          // the number of tokens available for the administrator
    //address public crowdSaleAddr;           // the address of a crowdsale currently selling this token
    address public adminAddr;               // the address of a crowdsale currently selling this token
    //bool    public transferEnabled = false; // indicates if transferring tokens is enabled or not
    bool    public transferEnabled = true;  // Enables everyone to transfer tokens

    /**
     * The listed addresses are not valid recipients of tokens.
     *
     * 0x0           - the zero address is not valid
     * this          - the contract itself should not receive tokens
     * owner         - the owner has all the initial tokens, but cannot receive any back
     * adminAddr     - the admin has an allowance of tokens to transfer, but does not receive any
     * crowdSaleAddr - the crowdsale has an allowance of tokens to transfer, but does not receive any
     */
    modifier validDestination(address _to) {
        require(_to != address(0x0), "Cannot send to 0 address");
        require(_to != address(this), "Cannot send to contract address");
        //require(_to != owner, "Cannot send to the owner");
        //require(_to != address(adminAddr), "Cannot send to admin address");
        //require(_to != address(crowdSaleAddr), "Cannot send to crowdsale address");
        _;
    }

    constructor(address _admin) public {
        require(msg.sender != _admin, "Owner and admin cannot be the same");

        totalSupply_ = INITIAL_SUPPLY;
        adminAllowance = ADMIN_ALLOWANCE;

        // mint all tokens
        //balances[msg.sender] = totalSupply_.sub(adminAllowance);
        //emit Transfer(address(0x0), msg.sender, totalSupply_.sub(adminAllowance));

        balances[_admin] = adminAllowance;
        emit Transfer(address(0x0), _admin, adminAllowance);

        adminAddr = _admin;
        approve(adminAddr, adminAllowance);
    }

    /**
     * Overrides ERC20 transfer function with modifier that prevents the
     * ability to transfer tokens until after transfers have been enabled.
     */
    function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * Overrides ERC20 transferFrom function with modifier that prevents the
     * ability to transfer tokens until after transfers have been enabled.
     */
    function transferFrom(address _from, address _to, uint256 _value) public validDestination(_to) returns (bool) {
        bool result = super.transferFrom(_from, _to, _value);
        if (result) {
            if (msg.sender == adminAddr)
                adminAllowance = adminAllowance.sub(_value);
        }
        return result;
    }
}

contract LBSCSale is BaseLBSCSale {
    using SafeMath for uint256;

    // The token being sold
    LBSCToken public tokenReward;

    mapping(address => bool) public approvedUsers;

    /**
     * Constructor for a crowdsale of CHPToken tokens.
     *
     * @param ifSuccessfulSendTo            the beneficiary of the fund
     * @param fundingGoalInEthers           the minimum goal to be reached
     * @param fundingCapInEthers            the cap (maximum) size of the fund
     * @param minimumContribution           Minimum contribution to participate in the crowdsale
     * @param start                         the start time (UNIX timestamp)
     * @param end                           the end time (UNIX timestamp)
     * @param rateLBSCToEther                 the conversion rate from LBSC to Ether
     * @param addressOfTokenUsedAsReward    address of the token being sold
     * @param _manager                      Address that will manage the crowdsale 
     */
    constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint fundingCapInEthers,
        uint minimumContribution,
        uint start,
        uint end,
        uint rateLBSCToEther,
        address addressOfTokenUsedAsReward,
        address _manager
    ) public {
        require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this), "Beneficiary cannot be 0 address");
        require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this), "Token address cannot be 0 address");
        require(fundingGoalInEthers <= fundingCapInEthers, "Funding goal should be less that funding cap.");
        require(end > 0, "Endtime cannot be 0");
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers;
        fundingCap = fundingCapInEthers;
        minContribution = minimumContribution;
        startTime = start;
        endTime = end; // TODO double check
        rate = rateLBSCToEther;
        tokenReward = LBSCToken(addressOfTokenUsedAsReward);
        manager = _manager;
        decimals = tokenReward.decimals();
    }

    /**
     * This fallback function is called whenever Ether is sent to the
     * smart contract. It can only be executed when the crowdsale is
     * not paused, not closed, and before the deadline has been reached.
     *
     * This function will update state variables for whether or not the
     * funding goal or cap have been reached. It also ensures that the
     * tokens are transferred to the sender, and that the correct
     * number of tokens are sent according to the current rate.
     */
    function () public payable whenNotPaused beforeDeadline afterStartTime saleNotClosed nonReentrant {
        require(msg.value >= minContribution, "Value should be greater than minimum contribution");
        require(isApprovedUser(msg.sender), "Only the approved users are allowed to participate in ICO");
        
        // Update the sender's balance of wei contributed and the amount raised
        uint amount = msg.value;
        uint currentBalance = balanceOf[msg.sender];
        balanceOf[msg.sender] = currentBalance.add(amount);
        amountRaised = amountRaised.add(amount);

        // Compute the number of tokens to be rewarded to the sender
        // Note: it's important for this calculation that both wei
        // and CHP have the same number of decimal places (18)
        uint numTokens = amount.mul(rate);

        // Transfer the tokens from the crowdsale supply to the sender
        if (tokenReward.transferFrom(tokenReward.owner(), msg.sender, numTokens)) {
            emit FundTransfer(msg.sender, amount, true);
            //contributions[msg.sender] = contributions[msg.sender].add(amount);
            // Following code is to automatically transfer ETH to beneficiary
            //uint balanceToSend = this.balance;
            //beneficiary.transfer(balanceToSend);
            //FundTransfer(beneficiary, balanceToSend, false);
            // Check if the funding goal or cap have been reached
            // TODO check impact on gas cost
            checkFundingGoal();
            checkFundingCap();
        }
        else {
            revert("Transaction Failed. Please try again later.");
        }
    }

    /**
     * The owner can allocate the specified amount of tokens from the
     * crowdsale allowance to the recipient (_to).
     *
     * NOTE: be extremely careful to get the amounts correct, which
     * are in units of wei and mini-LBSC. Every digit counts.
     *
     * @param _to            the recipient of the tokens
     * @param amountInEth     the amount contributed in wei
     * @param amountLBSC the amount of tokens transferred in mini-LBSC (18 decimals)
     */
    function ownerAllocateTokens(address _to, uint amountInEth, uint amountLBSC) public
            onlyOwnerOrManager nonReentrant
    {
        if (!tokenReward.transferFrom(tokenReward.owner(), _to, convertToMini(amountLBSC))) {
            revert("Transfer failed. Please check allowance");
        }

        uint amountWei = convertToMini(amountInEth);
        balanceOf[_to] = balanceOf[_to].add(amountWei);
        amountRaised = amountRaised.add(amountWei);
        emit FundTransfer(_to, amountWei, true);
        checkFundingGoal();
        checkFundingCap();
    }

    /**
     * The owner can call this function to withdraw the funds that
     * have been sent to this contract for the crowdsale subject to
     * the funding goal having been reached. The funds will be sent
     * to the beneficiary specified when the crowdsale was created.
     */
    function ownerSafeWithdrawal() public onlyOwner nonReentrant {
        require(fundingGoalReached, "Check funding goal");
        uint balanceToSend = address(this).balance;
        beneficiary.transfer(balanceToSend);
        emit FundTransfer(beneficiary, balanceToSend, false);
    }

    /**
     * This function permits anybody to withdraw the funds they have
     * contributed if and only if the deadline has passed and the
     * funding goal was not reached.
     */
    function safeWithdrawal() public afterDeadline nonReentrant {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                emit FundTransfer(msg.sender, amount, false);
                refundAmount = refundAmount.add(amount);
            }
        }
    }
    
    function convertToMini(uint amount) internal view returns (uint) {
        return amount * (10 ** decimals);
    }

    function approveUser(address _address) external onlyOwnerOrManager {
        approvedUsers[_address] = true;
    }

    function disapproveUser(address _address) external onlyOwnerOrManager {
        approvedUsers[_address] = false;
    }

    function changeManager(address _manager) external onlyOwnerOrManager {
        manager = _manager;
    }

    function isApprovedUser(address _address) internal view returns (bool) {
        return approvedUsers[_address];
    }

    function changeTokenAddress(address _address) external onlyOwnerOrManager {
        tokenReward = LBSCToken(_address);
    }
}