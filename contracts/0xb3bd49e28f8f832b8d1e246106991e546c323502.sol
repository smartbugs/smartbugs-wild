pragma solidity 0.4.17;

contract Token {

    /* Total amount of tokens */
    uint256 public totalSupply;

    /*
     * Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     * Public functions
     */

    /// @notice send `value` token to `to` from `msg.sender`
    /// @param to The address of the recipient
    /// @param value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint value) public returns (bool);

    /// @notice send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint value) public returns (bool);

    /// @notice `msg.sender` approves `spender` to spend `value` tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @param value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address spender, uint value) public returns (bool);

    /// @param owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address owner) public constant returns (uint);

    /// @param owner The address of the account owning tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) public constant returns (uint);
}

contract StandardToken is Token {
    /*
     *  Storage
    */
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;

    /*
     *  Public functions
    */

    function transfer(address to, uint value) public returns (bool) {
        // Do not allow transfer to 0x0 or the token contract itself
        require((to != 0x0) && (to != address(this)));
        if (balances[msg.sender] < value)
            revert();  // Balance too low
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        // Do not allow transfer to 0x0 or the token contract itself
        require((to != 0x0) && (to != address(this)));
        if (balances[from] < value || allowances[from][msg.sender] < value)
            revert(); // Balance or allowance too low
        balances[to] += value;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public constant returns (uint) {
        return allowances[owner][spender];
    }

    function balanceOf(address owner) public constant returns (uint) {
        return balances[owner];
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract GMToken is StandardToken {

    using SafeMath for uint256;

    /*
    *  Metadata
    */
    string public constant name = "Global Messaging Token";
    string public constant symbol = "GMT";
    uint8 public constant decimals = 18;
    uint256 public constant tokenUnit = 10 ** uint256(decimals);

    /*
    *  Contract owner (Radical App International)
    */
    address public owner;

    /*
    *  Hardware wallets
    */
    address public ethFundAddress;  // Address for ETH owned by Radical App International
    address public gmtFundAddress;  // Address for GMT allocated to Radical App International

    /*
    *  List of registered participants
    */
    mapping (address => bool) public registered;

    /*
    *  List of token purchases per address
    *  Same as balances[], except used for individual cap calculations, 
    *  because users can transfer tokens out during sale and reset token count in balances.
    */
    mapping (address => uint) public purchases;

    /*
    *  Crowdsale parameters
    */
    bool public isFinalized;
    bool public isStopped;
    uint256 public startBlock;  // Block number when sale period begins
    uint256 public endBlock;  // Block number when sale period ends
    uint256 public firstCapEndingBlock;  // Block number when first individual user cap period ends
    uint256 public secondCapEndingBlock;  // Block number when second individual user cap period ends
    uint256 public assignedSupply;  // Total GMT tokens currently assigned
    uint256 public tokenExchangeRate;  // Units of GMT per ETH
    uint256 public baseTokenCapPerAddress;  // Base user cap in GMT tokens
    uint256 public constant baseEthCapPerAddress = 7 ether;  // Base user cap in ETH
    uint256 public constant blocksInFirstCapPeriod = 2105;  // Block length for first cap period
    uint256 public constant blocksInSecondCapPeriod = 1052;  // Block length for second cap period
    uint256 public constant gasLimitInWei = 51000000000 wei; //  Gas price limit during individual cap period 
    uint256 public constant gmtFund = 500 * (10**6) * tokenUnit;  // 500M GMT reserved for development and user growth fund 
    uint256 public constant minCap = 100 * (10**6) * tokenUnit;  // 100M min cap to be sold during sale

    /*
    *  Events
    */
    event RefundSent(address indexed _to, uint256 _value);
    event ClaimGMT(address indexed _to, uint256 _value);

    modifier onlyBy(address _account){
        require(msg.sender == _account);  
        _;
    }

    function changeOwner(address _newOwner) onlyBy(owner) external {
        owner = _newOwner;
    }

    modifier registeredUser() {
        require(registered[msg.sender] == true);  
        _;
    }

    modifier minCapReached() {
        require(assignedSupply >= minCap);
        _;
    }

    modifier minCapNotReached() {
        require(assignedSupply < minCap);
        _;
    }

    modifier respectTimeFrame() {
        require(block.number >= startBlock && block.number < endBlock);
        _;
    }

    modifier salePeriodCompleted() {
        require(block.number >= endBlock || assignedSupply.add(gmtFund) == totalSupply);
        _;
    }

    modifier isValidState() {
        require(!isFinalized && !isStopped);
        _;
    }

    /*
    *  Constructor
    */
    function GMToken(
        address _ethFundAddress,
        address _gmtFundAddress,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _tokenExchangeRate) 
        public 
    {
        require(_gmtFundAddress != 0x0);
        require(_ethFundAddress != 0x0);
        require(_startBlock < _endBlock && _startBlock > block.number);

        owner = msg.sender; // Creator of contract is owner
        isFinalized = false; // Controls pre-sale state through crowdsale state
        isStopped = false;  // Circuit breaker (only to be used by contract owner in case of emergency)
        ethFundAddress = _ethFundAddress;
        gmtFundAddress = _gmtFundAddress;
        startBlock = _startBlock;
        endBlock = _endBlock;
        tokenExchangeRate = _tokenExchangeRate;
        baseTokenCapPerAddress = baseEthCapPerAddress.mul(tokenExchangeRate);
        firstCapEndingBlock = startBlock.add(blocksInFirstCapPeriod);
        secondCapEndingBlock = firstCapEndingBlock.add(blocksInSecondCapPeriod);
        totalSupply = 1000 * (10**6) * tokenUnit;  // 1B total GMT tokens
        assignedSupply = 0;  // Set starting assigned supply to 0
    }

    /// @notice Stop sale in case of emergency (i.e. circuit breaker)
    /// @dev Only allowed to be called by the owner
    function stopSale() onlyBy(owner) external {
        isStopped = true;
    }

    /// @notice Restart sale in case of an emergency stop
    /// @dev Only allowed to be called by the owner
    function restartSale() onlyBy(owner) external {
        isStopped = false;
    }

    /// @dev Fallback function can be used to buy tokens
    function () payable public {
        claimTokens();
    }

    /// @notice Create `msg.value` ETH worth of GMT
    /// @dev Only allowed to be called within the timeframe of the sale period
    function claimTokens() respectTimeFrame registeredUser isValidState payable public {
        require(msg.value > 0);

        uint256 tokens = msg.value.mul(tokenExchangeRate);

        require(isWithinCap(tokens));

        // Check that we're not over totals
        uint256 checkedSupply = assignedSupply.add(tokens);

        // Return money if we're over total token supply
        require(checkedSupply.add(gmtFund) <= totalSupply); 

        balances[msg.sender] = balances[msg.sender].add(tokens);
        purchases[msg.sender] = purchases[msg.sender].add(tokens);

        assignedSupply = checkedSupply;
        ClaimGMT(msg.sender, tokens);  // Logs token creation for UI purposes
        // As per ERC20 spec, a token contract which creates new tokens SHOULD trigger a Transfer event with the _from address
        // set to 0x0 when tokens are created (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
        Transfer(0x0, msg.sender, tokens);
    }

    /// @dev Checks if transaction meets individual cap requirements
    function isWithinCap(uint256 tokens) internal view returns (bool) {
        // Return true if we've passed the cap period
        if (block.number >= secondCapEndingBlock) {
            return true;
        }

        // Ensure user is under gas limit
        require(tx.gasprice <= gasLimitInWei);
        
        // Ensure user is not purchasing more tokens than allowed
        if (block.number < firstCapEndingBlock) {
            return purchases[msg.sender].add(tokens) <= baseTokenCapPerAddress;
        } else {
            return purchases[msg.sender].add(tokens) <= baseTokenCapPerAddress.mul(4);
        }
    }


    /// @notice Updates registration status of an address for sale participation
    /// @param target Address that will be registered or deregistered
    /// @param isRegistered New registration status of address
    function changeRegistrationStatus(address target, bool isRegistered) public onlyBy(owner) {
        registered[target] = isRegistered;
    }

    /// @notice Updates registration status for multiple addresses for participation
    /// @param targets Addresses that will be registered or deregistered
    /// @param isRegistered New registration status of addresses
    function changeRegistrationStatuses(address[] targets, bool isRegistered) public onlyBy(owner) {
        for (uint i = 0; i < targets.length; i++) {
            changeRegistrationStatus(targets[i], isRegistered);
        }
    }

    /// @notice Sends the ETH to ETH fund wallet and finalizes the token sale
    function finalize() minCapReached salePeriodCompleted isValidState onlyBy(owner) external {
        // Upon successful completion of sale, send tokens to GMT fund
        balances[gmtFundAddress] = balances[gmtFundAddress].add(gmtFund);
        assignedSupply = assignedSupply.add(gmtFund);
        ClaimGMT(gmtFundAddress, gmtFund);   // Log tokens claimed by Radical App International GMT fund
        Transfer(0x0, gmtFundAddress, gmtFund);
        
        // In the case where not all 500M GMT allocated to crowdfund participants
        // is sold, send the remaining unassigned supply to GMT fund address,
        // which will then be used to fund the user growth pool.
        if (assignedSupply < totalSupply) {
            uint256 unassignedSupply = totalSupply.sub(assignedSupply);
            balances[gmtFundAddress] = balances[gmtFundAddress].add(unassignedSupply);
            assignedSupply = assignedSupply.add(unassignedSupply);

            ClaimGMT(gmtFundAddress, unassignedSupply);  // Log tokens claimed by Radical App International GMT fund
            Transfer(0x0, gmtFundAddress, unassignedSupply);
        }

        ethFundAddress.transfer(this.balance);

        isFinalized = true; // Finalize sale
    }

    /// @notice Allows contributors to recover their ETH in the case of a failed token sale
    /// @dev Only allowed to be called once sale period is over IF the min cap is not reached
    /// @return bool True if refund successfully sent, false otherwise
    function refund() minCapNotReached salePeriodCompleted registeredUser isValidState external {
        require(msg.sender != gmtFundAddress);  // Radical App International not entitled to a refund

        uint256 gmtVal = balances[msg.sender];
        require(gmtVal > 0); // Prevent refund if sender GMT balance is 0

        balances[msg.sender] = balances[msg.sender].sub(gmtVal);
        assignedSupply = assignedSupply.sub(gmtVal); // Adjust assigned supply to account for refunded amount
        
        uint256 ethVal = gmtVal.div(tokenExchangeRate); // Covert GMT to ETH

        msg.sender.transfer(ethVal);
        
        RefundSent(msg.sender, ethVal);  // Log successful refund 
    }

    /*
        NOTE: We explicitly do not define a fallback function, in order to prevent 
        receiving Ether for no reason. As noted in Solidity documentation, contracts 
        that receive Ether directly (without a function call, i.e. using send or transfer)
        but do not define a fallback function throw an exception, sending back the Ether (this was different before Solidity v0.4.0).
    */
}