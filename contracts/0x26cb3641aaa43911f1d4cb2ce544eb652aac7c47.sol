pragma solidity ^0.4.19;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic
{
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic
{
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Contract Ownable (defines a contract with an owner)
//------------------------------------------------------------------------------------------------------------
contract Ownable
{
    /**
    * @dev Address of the current owner
    */
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor. Set the original `owner` of the contract to the sender account.
    function Ownable() public
    {
        owner = msg.sender;
    }

    // Throws if called by any account other than the owner.
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    /** Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public
    {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
// ------------------------------------------------------------------------------------------------------------


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract SafeBasicToken is ERC20Basic
{
    // Use safemath for math operations
    using SafeMath for uint256;

    // Maps each address to its current balance
    mapping(address => uint256) balances;

    // List of admins that can transfer tokens also during the ICO
    mapping(address => bool) public admin;

    // List of addresses that can receive tokens also during the ICO
    mapping(address => bool) public receivable;

    // Specifies whether the tokens are locked(ICO is running) - Tokens cannot be transferred during the ICO
    bool public locked;


    // Checks the size of the message to avoid attacks
    modifier onlyPayloadSize(uint size)
    {
        assert(msg.data.length >= size + 4);
        _;
    }

    /** Transfer tokens to the specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool)
    {
        require(_to != address(0));
        require(!locked || admin[msg.sender] == true || receivable[_to] == true);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }


    /** Get the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256)
    {
        return balances[_owner];
    }
}


/** @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract SafeStandardToken is ERC20, SafeBasicToken
{
    /** Map address => (address => value)
    *   allowed[_owner][_spender] represents the amount of tokens the _spender can use on behalf of the _owner
    */
    mapping(address => mapping(address => uint256)) allowed;


    /** Return the allowance of the _spender on behalf of the _owner
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will be allowed to spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }


    /** Allow the _spender to spend _value tokens on behalf of msg.sender.
     * To avoid race condition, the current allowed amount must be first set to 0 through a different transaction.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool)
    {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /** Increase the allowance for _spender by _addedValue (to be use when allowed[_spender] > 0)
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    /** Decrease the allowance for _spender by _subtractedValue. Set it to 0 if _subtractedValue is less then the current allowance
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success)
    {
        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue)
            allowed[msg.sender][_spender] = 0;
        else
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    /** Transfer tokens on behalf of _from to _to (if allowed)
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        require(_to != address(0));
        uint256 _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
}



// Main contract
contract CrystalToken is SafeStandardToken, Ownable
{
    using SafeMath for uint256;

    string public constant name = "CrystalToken";
    string public constant symbol = "CYL";
    uint256 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 28000000 * (10 ** uint256(decimals));

    // Struct representing information of a single round
    struct Round
    {
        uint256 startTime;                      // Timestamp of the start of the round
        uint256 endTime;                        // Timestamp of the end of the round
        uint256 availableTokens;                // Number of tokens available in this round
        uint256 maxPerUser;                     // Number of maximum tokens per user
        uint256 rate;                           // Number of token per wei in this round
        mapping(address => uint256) balances;   // Balances of the users in this round
    }

    // Array containing information of all the rounds
    Round[5] rounds;

    // Address where funds are collected
    address public wallet;

    // Amount of collected money in wei
    uint256 public weiRaised;

    // Current round index
    uint256 public runningRound;

    // Constructor
    function CrystalToken(address _walletAddress) public
    {
        wallet = _walletAddress;
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;

        rounds[0] = Round(1519052400, 1519138800,  250000 * (10 ** 18), 200 * (10 ** 18), 2000);    // 19 Feb 2018 - 15.00 GMT
        rounds[1] = Round(1519398000, 1519484400, 1250000 * (10 ** 18), 400 * (10 ** 18), 1333);    // 23 Feb 2018 - 15.00 GMT
        rounds[2] = Round(1519657200, 1519743600, 1500000 * (10 ** 18), 1000 * (10 ** 18), 1000);   // 26 Feb 2018 - 15.00 GMT
        rounds[3] = Round(1519830000, 1519916400, 2000000 * (10 ** 18), 1000 * (10 ** 18), 800);    // 28 Feb 2018 - 15.00 GMT
        rounds[4] = Round(1520262000, 1520348400, 2000000 * (10 ** 18), 2000 * (10 ** 18), 667);    //  5 Mar 2018 - 15.00 GMT

        // Set the owner as an admin
        admin[msg.sender] = true;

        // Lock the tokens for the ICO
        locked = true;

        // Set the current round to 100 (no round)
        runningRound = uint256(0);
    }


    /** Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    // Rate change event
    event RateChanged(address indexed owner, uint round, uint256 old_rate, uint256 new_rate);


    // Fallback function, used to buy token
    // If ETH are sent to the contract address, without any additional data, this function is called
    function() public payable
    {
        // Take the address of the buyer
        address beneficiary = msg.sender;

        // Check that the sender is not the 0 address
        require(beneficiary != 0x0);

        // Check that sent ETH in wei is > 0
        uint256 weiAmount = msg.value;
        require(weiAmount != 0);

        // Get the current round (100 if there is no open round)
        uint256 roundIndex = runningRound;

        // Check if there is a running round
        require(roundIndex != uint256(100));

        // Get the information of the current round
        Round storage round = rounds[roundIndex];

        // Calculate the token amount to sell. Exceeding amount will not generate tokens
        uint256 tokens = weiAmount.mul(round.rate);
        uint256 maxPerUser = round.maxPerUser;
        uint256 remaining = maxPerUser - round.balances[beneficiary];
        if(remaining < tokens)
            tokens = remaining;

        // Check if the tokens can be sold
        require(areTokensBuyable(roundIndex, tokens));

        // Reduce the number of available tokens in the round (fails if there are no more available tokens)
        round.availableTokens = round.availableTokens.sub(tokens);

        // Add the number of tokens to the current user's balance of this round
        round.balances[msg.sender] = round.balances[msg.sender].add(tokens);

        // Transfer the amount of token to the buyer
        balances[owner] = balances[owner].sub(tokens);
        balances[beneficiary] = balances[beneficiary].add(tokens);
        Transfer(owner, beneficiary, tokens);

        // Raise the event of token purchase
        TokenPurchase(beneficiary, beneficiary, weiAmount, tokens);

        // Update the number of collected money
        weiRaised = weiRaised.add(weiAmount);

        // Transfer funds to the wallet
        wallet.transfer(msg.value);
    }


    /** Check if there is an open round and if there are enough tokens available for current phase and for the sender
    * @param _roundIndex index of the current round
    * @param _tokens number of requested tokens
    */
    function areTokensBuyable(uint _roundIndex, uint256 _tokens) internal constant returns (bool)
    {
        uint256 current_time = block.timestamp;
        Round storage round = rounds[_roundIndex];

        return (
        _tokens > 0 &&                                              // Check that the user can still buy tokens
        round.availableTokens >= _tokens &&                         // Check that there are still available tokens
        current_time >= round.startTime &&                          // Check that the current timestamp is after the start of the round
        current_time <= round.endTime                               // Check that the current timestamp is before the end of the round
        );
    }



    // Return the current number of unsold tokens
    function tokenBalance() constant public returns (uint256)
    {
        return balanceOf(owner);
    }


    event Burn(address burner, uint256 value);


    /** Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public onlyOwner
    {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }



    /** Mint a specific amount of tokens.
   * @param _value The amount of token to be minted.
   */
    function mint(uint256 _value) public onlyOwner
    {
        totalSupply = totalSupply.add(_value);
        balances[msg.sender] = balances[msg.sender].add(_value);
    }



    // Functions to set the features of each round (only for the owner) and of the whole ICO
    // ----------------------------------------------------------------------------------------
    function setTokensLocked(bool _value) onlyOwner public
    {
        locked = _value;
    }

    /** Set the current round index
    * @param _roundIndex the new round index to set
    */
    function setRound(uint256 _roundIndex) public onlyOwner
    {
        runningRound = _roundIndex;
    }

    function setAdmin(address _addr, bool _value) onlyOwner public
    {
        admin[_addr] = _value;
    }

    function setReceivable(address _addr, bool _value) onlyOwner public
    {
        receivable[_addr] = _value;
    }

    function setRoundStart(uint _round, uint256 _value) onlyOwner public
    {
        require(_round >= 0 && _round < rounds.length);
        rounds[_round].startTime = _value;
    }

    function setRoundEnd(uint _round, uint256 _value) onlyOwner public
    {
        require(_round >= 0 && _round < rounds.length);
        rounds[_round].endTime = _value;
    }

    function setRoundAvailableToken(uint _round, uint256 _value) onlyOwner public
    {
        require(_round >= 0 && _round < rounds.length);
        rounds[_round].availableTokens = _value;
    }

    function setRoundMaxPerUser(uint _round, uint256 _value) onlyOwner public
    {
        require(_round >= 0 && _round < rounds.length);
        rounds[_round].maxPerUser = _value;
    }

    function setRoundRate(uint _round, uint256 _round_usd_cents, uint256 _ethvalue_usd) onlyOwner public
    {
        require(_round >= 0 && _round < rounds.length);
        uint256 rate = _ethvalue_usd * 100 / _round_usd_cents;
        uint256 oldRate = rounds[_round].rate;
        rounds[_round].rate = rate;
        RateChanged(msg.sender, _round, oldRate, rounds[_round].rate);
    }
    // ----------------------------------------------------------------------------------------


    // Functions to get the features of each round
    // ----------------------------------------------------------------------------------------
    function getRoundUserBalance(uint _round, address _user) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].balances[_user];
    }

    function getRoundStart(uint _round) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].startTime;
    }

    function getRoundEnd(uint _round) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].endTime;
    }

    function getRoundAvailableToken(uint _round) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].availableTokens;
    }

    function getRoundMaxPerUser(uint _round) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].maxPerUser;
    }

    function getRoundRate(uint _round) public constant returns (uint256)
    {
        require(_round >= 0 && _round < rounds.length);
        return rounds[_round].rate;
    }
    // ----------------------------------------------------------------------------------------
}