pragma solidity ^0.4.17;


library SafeMath {
    function mul(uint a, uint b) internal pure  returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint a, uint b) internal pure  returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure  returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

contract ERC20 {
    uint public totalSupply;

    function balanceOf(address who) public view returns(uint);

    function allowance(address owner, address spender) public view returns(uint);

    function transfer(address to, uint value) public returns(bool ok);

    function transferFrom(address from, address to, uint value) public returns(bool ok);

    function approve(address spender, uint value) public returns(bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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
    function Ownable() public {
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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
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
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}


/// @title Migration Agent interface
contract MigrationAgent {

    function migrateFrom(address _from, uint256 _value) public;
}


// Crowdsale Smart Contract
// This smart contract collects ETH and in return sends tokens to the Backers
contract Crowdsale is Pausable {

    using SafeMath for uint;

    struct Backer {
        uint weiReceived; // amount of ETH contributed
        uint tokensSent; // amount of tokens  sent  
        bool refunded; // true if user has been refunded       
    }

    Token public token; // Token contract reference   
    address public multisig; // Multisig contract that will receive the ETH    
    address public team; // Address to which the team tokens will be sent   
    address public zen; // Address to which zen team tokens will be sent
    uint public ethReceived; // Number of ETH received
    uint public totalTokensSent; // Number of tokens sent to ETH contributors
    uint public startBlock; // Crowdsale start block
    uint public endBlock; // Crowdsale end block
    uint public maxCap; // Maximum number of tokens to sell
    uint public minCap; // Minimum number of tokens to sell    
    bool public crowdsaleClosed; // Is crowdsale still in progress
    uint public refundCount;  // number of refunds
    uint public totalRefunded; // total amount of refunds in wei
    uint public tokenPriceWei; // tokn price in wei
    uint public minInvestETH; // Minimum amount to invest
    uint public presaleTokens;
    uint public totalWhiteListed; 
    uint public claimCount;
    uint public totalClaimed;
    uint public numOfBlocksInMinute; // number of blocks in one minute * 100. eg. 
                                     // if one block takes 13.34 seconds, the number will be 60/13.34* 100= 449

    mapping(address => Backer) public backers; //backer list
    address[] public backersIndex; // to be able to itarate through backers for verification.  
    mapping(address => bool) public whiteList;

    // @notice to verify if action is not performed out of the campaing range
    modifier respectTimeFrame() {

        require(block.number >= startBlock && block.number <= endBlock);           
        _;
    }

    // Events
    event LogReceivedETH(address backer, uint amount, uint tokenAmount);
    event LogRefundETH(address backer, uint amount);
    event LogWhiteListed(address user, uint whiteListedNum);
    event LogWhiteListedMultiple(uint whiteListedNum);   

    // Crowdsale  {constructor}
    // @notice fired when contract is crated. Initilizes all constant and initial variables.
    function Crowdsale() public {

        multisig = 0xE804Ad72e60503eD47d267351Bdd3441aC1ccb03; 
        team = 0x86Ab6dB9932332e3350141c1D2E343C478157d04; 
        zen = 0x3334f1fBf78e4f0CFE0f5025410326Fe0262ede9; 
        presaleTokens = 4692000e8;      //TODO: ensure that this is correct amount
        totalTokensSent = presaleTokens;  
        minInvestETH = 1 ether/10; // 0.1 eth
        startBlock = 0; // ICO start block
        endBlock = 0; // ICO end block                    
        maxCap = 42000000e8; // takes into consideration zen team tokens and team tokens.   
        minCap = 8442000e8;        
        tokenPriceWei = 80000000000000;  // Price is 0.00008 eth    
        numOfBlocksInMinute = 400;  //  TODO: updte this value before deploying. E.g. 4.00 block/per minute wold be entered as 400           
    }

     // @notice to populate website with status of the sale 
    function returnWebsiteData() external view returns(uint, uint, uint, uint, uint, uint, uint, uint, bool, bool) {
    
        return (startBlock, endBlock, numberOfBackers(), ethReceived, maxCap, minCap, totalTokensSent, tokenPriceWei, paused, crowdsaleClosed);
    }

    // @notice in case refunds are needed, money can be returned to the contract
    function fundContract() external payable onlyOwner() returns (bool) {
        return true;
    }

    function addToWhiteList(address _user) external onlyOwner() returns (bool) {

        if (whiteList[_user] != true) {
            whiteList[_user] = true;
            totalWhiteListed++;
            LogWhiteListed(_user, totalWhiteListed);            
        }
        return true;
    }

    function addToWhiteListMultiple(address[] _users) external onlyOwner()  returns (bool) {

        for (uint i = 0; i < _users.length; ++i) {

            if (whiteList[_users[i]] != true) {
                whiteList[_users[i]] = true;
                totalWhiteListed++;                          
            }           
        }
        LogWhiteListedMultiple(totalWhiteListed); 
        return true;
    }

    // @notice Move funds from pre ICO sale if needed. 
    function transferPreICOFunds() external payable onlyOwner() returns (bool) {
        ethReceived = ethReceived.add(msg.value);
        return true;
    }

    // @notice Specify address of token contract
    // @param _tokenAddress {address} address of the token contract
    // @return res {bool}
    function updateTokenAddress(Token _tokenAddress) external onlyOwner() returns(bool res) {
        token = _tokenAddress;
        return true;
    }

    // {fallback function}
    // @notice It will call internal function which handels allocation of Ether and calculates amout of tokens.
    function () external payable {           
        contribute(msg.sender);
    }

    // @notice It will be called by owner to start the sale    
    function start(uint _block) external onlyOwner() {   

        require(_block < (numOfBlocksInMinute * 60 * 24 * 60)/100);  // allow max 60 days for campaign
                                                         
        startBlock = block.number;
        endBlock = startBlock.add(_block); 
    }

    // @notice Due to changing average of block time
    // this function will allow on adjusting duration of campaign closer to the end 
    function adjustDuration(uint _block) external onlyOwner() {

        require(_block < (numOfBlocksInMinute * 60 * 24 * 80)/100); // allow for max of 80 days for campaign
        require(_block > block.number.sub(startBlock)); // ensure that endBlock is not set in the past
        endBlock = startBlock.add(_block); 
    }
    
    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed or all tokens are sold.
    function finalize() external onlyOwner() {

        require(!crowdsaleClosed);        
        // purchasing precise number of tokens might be impractical, 
        //thus subtract 1000 tokens so finalizition is possible near the end 
        require(block.number > endBlock || totalTokensSent >= maxCap - 1000); 
        require(totalTokensSent >= minCap);  // ensure that campaign was successful         
        crowdsaleClosed = true; 

        if (!token.transfer(team, 45000000e8 + presaleTokens))
            revert();
        if (!token.transfer(zen, 3000000e8)) 
            revert();
        token.unlock();                       
    }

    // @notice
    // This function will allow to transfer unsold tokens to a new
    // contract/wallet address to start new ICO in the future
    function transferRemainingTokens(address _newAddress) external onlyOwner() returns (bool) {

        require(_newAddress != address(0));
        // 180 days after ICO ends   
        assert(block.number > endBlock + (numOfBlocksInMinute * 60 * 24 * 180)/100);         
        if (!token.transfer(_newAddress, token.balanceOf(this))) 
            revert(); // transfer tokens to admin account or multisig wallet
        return true;
    }

    // @notice Failsafe drain
    function drain() external onlyOwner() {
        multisig.transfer(this.balance);      
    }

    // @notice it will allow contributors to get refund in case campaign failed
    function refund()  external whenNotPaused returns (bool) {


        require(block.number > endBlock); // ensure that campaign is over
        require(totalTokensSent < minCap); // ensure that campaign failed
        require(this.balance > 0);  // contract will hold 0 ether at the end of the campaign.                                  
                                    // contract needs to be funded through fundContract() for this action

        Backer storage backer = backers[msg.sender];

        require(backer.weiReceived > 0);           
        require(!backer.refunded);      

        backer.refunded = true;      
        refundCount++;
        totalRefunded = totalRefunded + backer.weiReceived;

        if (!token.burn(msg.sender, backer.tokensSent))
            revert();
        msg.sender.transfer(backer.weiReceived);
        LogRefundETH(msg.sender, backer.weiReceived);
        return true;
    }
   

    // @notice return number of contributors
    // @return  {uint} number of contributors
    function numberOfBackers() public view returns(uint) {
        return backersIndex.length;
    }

    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _backer {address} address of beneficiary
    // @return res {bool} true if transaction was successful
    function contribute(address _backer) internal whenNotPaused respectTimeFrame returns(bool res) {

        require(msg.value >= minInvestETH);   // stop when required minimum is not sent
        require(whiteList[_backer]);
        uint tokensToSend = calculateNoOfTokensToSend();
        require(totalTokensSent.add(tokensToSend) <= maxCap);  // Ensure that max cap hasn't been reached
           
        Backer storage backer = backers[_backer];

        if (backer.weiReceived == 0)
            backersIndex.push(_backer);
        
        backer.tokensSent = backer.tokensSent.add(tokensToSend);
        backer.weiReceived = backer.weiReceived.add(msg.value);
        ethReceived = ethReceived.add(msg.value); // Update the total Ether recived
        totalTokensSent = totalTokensSent.add(tokensToSend);

        if (!token.transfer(_backer, tokensToSend)) 
            revert(); // Transfer SOCX tokens

        multisig.transfer(msg.value);  // send money to multisignature wallet
        LogReceivedETH(_backer, msg.value, tokensToSend); // Register event
        return true;
    }

    // @notice This function will return number of tokens based on time intervals in the campaign
    function calculateNoOfTokensToSend() internal constant  returns (uint) {

        uint tokenAmount = msg.value.mul(1e8) / tokenPriceWei;        

        if (block.number <= startBlock + (numOfBlocksInMinute * 60) / 100)  // less then one hour
            return  tokenAmount + (tokenAmount * 50) / 100;
        else if (block.number <= startBlock + (numOfBlocksInMinute * 60 * 24) / 100)  // less than one day
            return  tokenAmount + (tokenAmount * 25) / 100; 
        else if (block.number <= startBlock + (numOfBlocksInMinute * 60 * 24 * 2) / 100)  // less than two days
            return  tokenAmount + (tokenAmount * 10) / 100; 
        else if (block.number <= startBlock + (numOfBlocksInMinute * 60 * 24 * 3) / 100)  // less than three days
            return  tokenAmount + (tokenAmount * 5) / 100;
        else                                                                // after 3 days
            return  tokenAmount;     
    }
}



// The SOCX token
contract Token is ERC20, Ownable {
    
    using SafeMath for uint;
    
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals; // How many decimals to show.
    string public version = "v0.1";
    uint public initialSupply;
    uint public totalSupply;
    bool public locked;           
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address public migrationMaster;
    address public migrationAgent;
    address public crowdSaleAddress;
    uint256 public totalMigrated;

    // Lock transfer for contributors during the ICO 
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleAddress && locked) 
            revert();
        _;
    }

    modifier onlyAuthorized() {
        if (msg.sender != owner && msg.sender != crowdSaleAddress) 
            revert();
        _;
    }

    // The SOCX Token created with the time at which the crowdsale ends
    function Token(address _crowdSaleAddress, address _migrationMaster) public {
        // Lock the transfCrowdsaleer function during the crowdsale
        locked = true; // Lock the transfer of tokens during the crowdsale
        initialSupply = 90000000e8;
        totalSupply = initialSupply;
        name = "SocialX"; // Set the name for display purposes
        symbol = "SOCX"; // Set the symbol for display purposes
        decimals = 8; // Amount of decimals for display purposes
        crowdSaleAddress = _crowdSaleAddress;              
        balances[crowdSaleAddress] = totalSupply;
        migrationMaster = _migrationMaster;
    }

    function unlock() public onlyAuthorized {
        locked = false;
    }

    function lock() public onlyAuthorized {
        locked = true;
    }

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    // Token migration support:

    /// @notice Migrate tokens to the new token contract.
    /// @dev Required state: Operational Migration
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value) external onlyUnlocked() {
        // Abort if not in Operational Migration state.
        
        if (migrationAgent == 0) 
            revert();
        
        // Validate input value.
        if (_value == 0) 
            revert();
        if (_value > balances[msg.sender]) 
            revert();

        balances[msg.sender] -= _value;
        totalSupply -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
    /// process.
    /// @dev Required state: Operational Normal
    /// @dev State transition: -> Operational Migration
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent) external onlyUnlocked() {
        // Abort if not in Operational Normal state.
        
        require(migrationAgent == 0);
        require(msg.sender == migrationMaster);
        migrationAgent = _agent;
    }

    function resetCrowdSaleAddress(address _newCrowdSaleAddress) external onlyAuthorized() {
        crowdSaleAddress = _newCrowdSaleAddress;
    }
    
    function setMigrationMaster(address _master) external {       
        require(msg.sender == migrationMaster);
        require(_master != 0);
        migrationMaster = _master;
    }

   // @notice burn tokens in case campaign failed
    // @param _member {address} of member
    // @param _value {uint} amount of tokens to burn
    // @return  {bool} true if successful
    function burn( address _member, uint256 _value) public onlyAuthorized returns(bool) {
        balances[_member] = balances[_member].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Transfer(_member, 0x0, _value);
        return true;
    }

    // @notice transfer tokens to given address 
    // @param _to {address} address or recipient
    // @param _value {uint} amount to transfer
    // @return  {bool} true if successful  
    function transfer(address _to, uint _value) public onlyUnlocked returns(bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // @notice transfer tokens from given address to another address
    // @param _from {address} from whom tokens are transferred 
    // @param _to {address} to whom tokens are transferred
    // @parm _value {uint} amount of tokens to transfer
    // @return  {bool} true if successful   
    function transferFrom(address _from, address _to, uint256 _value) public onlyUnlocked returns(bool success) {
        require(balances[_from] >= _value); // Check if the sender has enough                            
        require(_value <= allowed[_from][msg.sender]); // Check if allowed is greater or equal        
        balances[_from] = balances[_from].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    // @notice to query balance of account
    // @return _owner {address} address of user to query balance 
    function balanceOf(address _owner) public view returns(uint balance) {
        return balances[_owner];
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // @notice to query of allowance of one user to the other
    // @param _owner {address} of the owner of the account
    // @param _spender {address} of the spender of the account
    // @return remaining {uint} amount of remaining allowance
    function allowance(address _owner, address _spender) public view returns(uint remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}