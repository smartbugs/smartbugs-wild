/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer (address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20 {
    
    using SafeMath for uint256;

    mapping (address => uint256) internal balances;

    mapping (address => mapping (address => uint256)) private allowed;

    uint256 internal totalSupply_;

    /**
    * @dev Total tokens amount
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
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
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner,address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
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
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from,address _to,uint256 _value)public returns (bool){
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
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
    function increaseApproval(address _spender,uint256 _addedValue) public returns (bool){
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
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
    function decreaseApproval(address _spender,uint256 _subtractedValue) public returns (bool){
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

/**
 * @title Rate means
 * @dev The contract purposed for managing crowdsale financial data,
 *      such as rates, prices, limits and etc.
 */
contract Rate  {
    
    using SafeMath for uint;
    
    //  Ether / US cent exchange rate
    uint public ETHUSDC;
    
    //  Token price in US cents
    uint public usCentsPrice;
    
    //  Token price in wei
    uint public tokenWeiPrice;
    
    //  Minimum wei amount derived from requiredDollarAmount parameter
    uint public requiredWeiAmount;
    
    //  Minimum dollar amount that investor can provide for purchasing
    uint public requiredDollarAmount;

    //  Total tokens amount which can be sold at the current crowdsale stage
    uint internal percentLimit;

    //  All percent limits according to Crowdsale stages
    uint[] internal percentLimits = [10, 27, 53, 0];
    
    //  Event for interacting with OraclizeAPI
    event LogConstructorInitiated(string  nextStep);
    
    //  Event for price updating
    event LogPriceUpdated(string price);
    
    //  Event for logging oraclize queries
    event LogNewOraclizeQuery(string  description);


    function ethersToTokens(uint _ethAmount)
    public
    view
    returns(uint microTokens)
    {
        uint centsAmount = _ethAmount.mul(ETHUSDC);
        return centsToTokens(centsAmount);
    }
    
    function centsToTokens(uint _cents)
    public
    view
    returns(uint microTokens)
    {
        require(_cents > 0);
        microTokens = _cents.mul(1000000).div(usCentsPrice);
        return microTokens;
    }
    
    function tokensToWei(uint _microTokensAmount)
    public
    view
    returns(uint weiAmount) {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div(10 ** 6);
        weiAmount = _microTokensAmount.mul(microTokenWeiPrice);
        return weiAmount;
    }
    
    function tokensToCents(uint _microTokenAmount)
    public
    view
    returns(uint centsAmount) {
        centsAmount = _microTokenAmount.mul(usCentsPrice).div(1000000);
        return centsAmount;
    }
    

    function stringUpdate(string _rate) internal {
        ETHUSDC = getInt(_rate, 0);
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        tokenWeiPrice = usCentsPrice.mul(centsWei);
        requiredWeiAmount = requiredDollarAmount.mul(100).mul(1 ether).div(ETHUSDC);
    }
    
    function getInt(string _a, uint _b) private pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        return mint;
    }
    
}

/**
 * @title IMPCoin implementation based on ERC20 standard token
 */
contract IMPERIVMCoin is StandardToken {
    
    using SafeMath for uint;
    
    string public name = "IMPERIVMCoin";
    string public symbol = "IMPC";
    uint8 public decimals = 6;
    
    address owner;
    
    /**
     *  @dev Contract initiallization
     *  @param _initialSupply total tokens amount
     */
    constructor(uint _initialSupply) public {
        totalSupply_ = _initialSupply * 10 ** uint(decimals);
        owner = msg.sender;
        balances[owner] = balances[owner].add(totalSupply_);
    }
    
}  

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 *      functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    //  The account who initially deployed both an IMPCoin and IMPCrowdsale contracts
    address public initialOwner;
    
    mapping(address => bool) owners;
    
    /**
     * Event for adding owner
     * @param admin is an account gonna be added to the admin list
     */
    event AddOwner(address indexed admin);
    
    /**
     * Event for deleting owner
     * @param admin is an account gonna be deleted from the admin list
     */
    event DeleteOwner(address indexed admin);
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwners() {
        require(
            msg.sender == initialOwner
            || inOwners(msg.sender)
        );
        _;
    }
    
    /**
     * @dev Throws if called by any account other than the initial owner.
     */
    modifier onlyInitialOwner() {
        require(msg.sender == initialOwner);
        _;
    }
    
    /**
     * @dev adding admin account to the admins list
     * @param _wallet is an account gonna be approved as an admin account
     */
    function addOwner(address _wallet) public onlyInitialOwner {
        owners[_wallet] = true;
        emit AddOwner(_wallet);
    }
    
    /**
     * @dev deleting admin account from the admins list
     * @param _wallet is an account gonna be deleted from the admins list
     */
    function deleteOwner(address _wallet) public onlyInitialOwner {
        owners[_wallet] = false;
        emit DeleteOwner(_wallet);
    }
    
    /**
     * @dev checking if account is admin or not
     * @param _wallet is an account for checking
     */
    function inOwners(address _wallet)
    public
    view
    returns(bool)
    {
        if(owners[_wallet]){ 
            return true;
        }
        return false;
    }
    
}

/**
 * @title Lifecycle means
 * @dev The contract purposed for managing crowdsale lifecycle
 */
contract Lifecycle is Ownable, Rate {
    
    /**
     * Enumeration describing all crowdsale stages
     * @ Private for small group of privileged investors
     * @ PreSale for more wide and less privileged group of investors
     * @ Sale for all buyers
     * @ Cancel crowdsale completing stage
     * @ Stopped special stage for updates and force-major handling
     */
    enum Stages {
        Private,
        PreSale,
        Sale,
        Cancel,
        Stopped
    }
    
    //  Previous crowdsale stage
    Stages public previousStage;
    
    //  Current crowdsale stage
    Stages public crowdsaleStage;
    
    //  Event for crowdsale stopping
    event ICOStopped(uint timeStamp);
    
    //  Event for crowdsale continuing after stopping
    event ICOContinued(uint timeStamp);
    
    //  Event for crowdsale starting
    event CrowdsaleStarted(uint timeStamp);
    
    /**
    * Event for ICO stage switching
    * @param timeStamp time of switching
    * @param newPrice one token price (US cents)
    * @param newRequiredDollarAmount new minimum limit for investment
    */
    event ICOSwitched(uint timeStamp,uint newPrice,uint newRequiredDollarAmount);
    
    modifier appropriateStage() {
        require(
            crowdsaleStage != Stages.Cancel,
            "ICO is finished now"
        );
        
        require(
            crowdsaleStage != Stages.Stopped,
            "ICO is temporary stopped at the moment"
        );
        _;
    }
    
    function stopCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage != Stages.Stopped);
        previousStage = crowdsaleStage;
        crowdsaleStage = Stages.Stopped;
        
        emit ICOStopped(now);
    }
    
    function continueCrowdsale()
    public
    onlyOwners
    {
        require(crowdsaleStage == Stages.Stopped);
        crowdsaleStage = previousStage;
        previousStage = Stages.Stopped;
        
        emit ICOContinued(now);
    }
    
    function nextStage(
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    onlyOwners
    appropriateStage
    {
        crowdsaleStage = Stages(uint(crowdsaleStage)+1);
        setUpConditions( _cents, _requiredDollarAmount);
        emit ICOSwitched(now,_cents,_requiredDollarAmount);
    }
    
    /**
     * @dev Setting up specified parameters for particular ICO stage
     * @param _cents One token cost in U.S. cents
     * @param _requiredDollarAmount Minimal dollar amount whicn Investor can send for buying purpose
     */
    function setUpConditions(
        uint _cents,
        uint _requiredDollarAmount
    )
    internal
    {
        require(_cents > 0);
        require(_requiredDollarAmount > 0);
        
        percentLimit =  percentLimits[ uint(crowdsaleStage) ];
        usCentsPrice = _cents;
        requiredDollarAmount = _requiredDollarAmount;
    }
    
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

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



/**
 * @title Verification means
 * @dev The contract purposed for validating ethereum accounts
 *      able to buy IMP Coin
 */
contract Verification is Ownable {
    
    /**
     * Event for adding buyer
     * @param buyer is a new buyer
     */
    event AddBuyer(address indexed buyer);
    
    /**
     * Event for deleting buyer
     * @param buyer is a buyer gonna be deleted
     * @param success is a result of deleting operation
     */
    event DeleteBuyer(address indexed buyer, bool indexed success);
    
    mapping(address => bool) public approvedBuyers;
    
    /**
     * @dev adding buyer to the list of approved buyers
     * @param _buyer account gonna to be added
     */
    function addBuyer(address _buyer)
    public
    onlyOwners
    returns(bool success)
    {
        approvedBuyers[_buyer] = true;
        emit AddBuyer(_buyer);
        return true;
    }  
    
    /**
     * @dev deleting buyer from the list of approved buyers
     * @param _buyer account gonna to be deleted
     */
    function deleteBuyer(address _buyer)
    public
    onlyOwners
    returns(bool success)
    {
        if (approvedBuyers[_buyer]) {
            delete approvedBuyers[_buyer];
            emit DeleteBuyer(_buyer, true);
            return true;
        } else {
            emit DeleteBuyer(_buyer, false);
            return false;
        }
    }
    
    /**
     * @dev If specified account address is in approved buyers list
     *      then the function returns true, otherwise returns false
     */
    function getBuyer(address _buyer) public view  returns(bool success){
        if (approvedBuyers[_buyer]){
            return true;  
        }
        return false;        
    }
    
}
/**
 * @dev Brainspace crowdsale contract
 */
contract IMPCrowdsale is Lifecycle, Verification {

    using SafeMath for uint;
     
    //  Token contract for the Crowdsale
    IMPERIVMCoin public token;
    
    //  Total amount of received wei
    uint public weiRaised;
    
    //  Total amount of sold tokens
    uint public totalSold;
    
    //  The variable is purposed for ETHUSD updating
    uint lastTimeStamp;
    
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        uint value,
        uint amount
    );
    
    /**
     * Event for token purchase logging
     * @param rate new rate
     */
    event StringUpdate(string rate);
    
    
    /**
     * Event for manual token transfer
     * @param to receiver address
     * @param value tokens amount
     */
    event ManualTransfer(address indexed to, uint indexed value);

    constructor(
        IMPERIVMCoin _token,
        uint _cents,
        uint _requiredDollarAmount
    )
    public
    {
        require(_token != address(0));
        token = _token;
        initialOwner = msg.sender;
        setUpConditions( _cents, _requiredDollarAmount);
        crowdsaleStage = Stages.Sale;
    }
    
    /**
     * @dev callback
     */
    function () public payable {
        initialOwner.transfer(msg.value);
    }
    
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     */
    function buyTokens()
    public
    payable
    appropriateStage
    {
        require(approvedBuyers[msg.sender]);
        require(totalSold <= token.totalSupply().div(100).mul(percentLimit));

        uint weiAmount = msg.value;
        _preValidatePurchase(weiAmount);

        // calculate token amount to be created
        uint tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(tokens);
        
        emit TokenPurchase(
            msg.sender,
            weiAmount,
            tokens
        );

        _forwardFunds();
        _postValidatePurchase(tokens);
    }
    
    
    /**
     * @dev manual ETHUSD rate updating according to exchange data
     * @param _rate is the rate gonna be set up
     */
    function stringCourse(string _rate) public payable onlyOwners {
        stringUpdate(_rate);
        lastTimeStamp = now;
        emit StringUpdate(_rate);
    }
    
    function manualTokenTransfer(address _to, uint _value)
    public
    onlyOwners
    returns(bool success)
    {
        if(approvedBuyers[_to]) {
            totalSold = totalSold.add(_value);
            token.transferFrom(initialOwner, _to, _value);
            emit ManualTransfer(_to, _value);
            return true;    
        } else {
            return false;
        }
    }
    
    function _preValidatePurchase(uint _weiAmount)
    internal
    view
    {
        require(
            _weiAmount >= requiredWeiAmount,
            "Your investment funds are less than minimum allowable amount for tokens buying"
        );
    }
    
    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     */
    function _postValidatePurchase(uint _tokensAmount)
    internal
    {
        totalSold = totalSold.add(_tokensAmount);
    }
    
    /**
     * @dev Get tokens amount for purchasing
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint _weiAmount)
    internal
    view
    returns (uint)
    {
        uint centsWei = SafeMath.div(1 ether, ETHUSDC);
        uint microTokenWeiPrice = centsWei.mul(usCentsPrice).div(10 ** uint(token.decimals()));
        uint amountTokensForInvestor = _weiAmount.div(microTokenWeiPrice);
        
        return amountTokensForInvestor;
    }
    
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(uint _tokenAmount) internal {
        token.transferFrom(initialOwner, msg.sender, _tokenAmount);
    }
    
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(uint _tokenAmount) internal {
        _deliverTokens(_tokenAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        initialOwner.transfer(msg.value);
    }
    
    function destroy() public onlyInitialOwner {
        selfdestruct(this);
    }
}