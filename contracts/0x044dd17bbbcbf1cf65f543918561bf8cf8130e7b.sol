pragma solidity 0.4.18;


contract Owned {
    // The address of the account of the current owner
    address public owner;

    // The publiser is the inital owner
    function Owned() public {
        owner = msg.sender;
    }

    /**
     * Access is restricted to the current owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}


// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    // Total supply
    uint256 public totalSupply; // Implicit getter

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);

    // Send _amount amount of tokens to address _to
    function transfer(address _to, uint256 _amount) public returns (bool success);

    // Send _amount amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _amount amount.
    // If this function is called again it overwrites the current allowance with _amount.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _amount) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event TransferEvent(address indexed _from, address indexed _to, uint256 _amount);

    // Triggered whenever approve(address _spender, uint256 _amount) is called.
    event ApprovalEvent(address indexed _owner, address indexed _spender, uint256 _amount);
}


/**
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
 *
 * Modified version of https://github.com/ConsenSys/Tokens that implements the
 * original Token contract, an abstract contract for the full ERC 20 Token standard
 */
contract EngravedToken is ERC20Interface, Owned {
    string public constant symbol = "EGR";
    string public constant name = "Engraved Token";
    uint8 public constant decimals = 3;

    // Core team incentive distribution
    bool public incentiveDistributionStarted = false;
    uint256 public incentiveDistributionDate = 0;
    uint256 public incentiveDistributionRound = 1;
    uint256 public incentiveDistributionMaxRounds = 4;
    uint256 public incentiveDistributionInterval = 1 years;
    uint256 public incentiveDistributionRoundDenominator = 2;

    // Core team incentives
    struct Incentive {
        address recipient;
        uint8 percentage;
    }

    Incentive[] public incentives;

    // Token starts if the locked state restricting transfers
    bool public locked;

    // Balances for each account
    mapping(address => uint256) internal balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) internal allowed;

    // Constructor
    function EngravedToken() public {
        owner = msg.sender;
        balances[owner] = 0;
        totalSupply = 0;
        locked = true;

        incentives.push(Incentive(0xCA73c8705cbc5942f42Ad39bC7EAeCA8228894BB, 5)); // 5% founder
        incentives.push(Incentive(0xd721f5c14a4AF2625AF1E1E107Cc148C8660BA72, 5)); // 5% founder
    }

    /**
     * Prevents accidental sending of ether
     */
    function() public {
        assert(false);
    }

    /**
     * Get balance of `_owner`
     *
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * Send `_amount` token to `_to` from `msg.sender`
     *
     * @param _to The address of the recipient
     * @param _amount The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(!locked);
        require(balances[msg.sender] >= _amount);
        require(_amount > 0);
        assert(balances[_to] + _amount > balances[_to]);

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        TransferEvent(msg.sender, _to, _amount);
        return true;
    }

    /**
     * Send `_amount` token to `_to` from `_from` on the condition it is approved by `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom (
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(!locked);
        require(balances[_from] >= _amount);
        require(allowed[_from][msg.sender] >= _amount);
        require(_amount > 0);
        assert(balances[_to] + _amount > balances[_to]);

        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        TransferEvent(_from, _to, _amount);
        return true;
    }

    /**
     * `msg.sender` approves `_spender` to spend `_amount` tokens
     *
     * @param _spender The address of the account able to transfer the tokens
     * @param _amount The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(!locked);

        // Update allowance
        allowed[msg.sender][_spender] = _amount;

        // Notify listners
        ApprovalEvent(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     *
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public constant returns (
        uint256 remaining
    ) {
        return allowed[_owner][_spender];
    }

    /**
     * Starts incentive distribution
     *
     * Called by the crowdsale contract when tokenholders voted
     * for the transfer of ownership of the token contract to DCorp
     *
     * @return Whether the incentive distribution was started
     */
    function startIncentiveDistribution() public onlyOwner returns (bool success) {
        if (!incentiveDistributionStarted) {
            incentiveDistributionDate = now;
            incentiveDistributionStarted = true;
        }

        return incentiveDistributionStarted;
    }

    /**
     * Distributes incentives over the core team members as
     * described in the whitepaper
     */
    function withdrawIncentives() public {
        // Crowdsale triggers incentive distribution
        require(incentiveDistributionStarted);

        // Enforce max distribution rounds
        require(incentiveDistributionRound < incentiveDistributionMaxRounds);

        // Enforce time interval
        require(now > incentiveDistributionDate);

        uint256 totalSupplyToDate = totalSupply;
        uint256 denominator = 1;

        // Incentive decreased each round
        if (incentiveDistributionRound > 1) {
            denominator = incentiveDistributionRoundDenominator**(incentiveDistributionRound - 1);
        }

        for (uint256 i = 0; i < incentives.length; i++) {

            uint256 amount = totalSupplyToDate * incentives[i].percentage / 10**2 / denominator;
            address recipient = incentives[i].recipient;

            // Create tokens
            balances[recipient] += amount;
            totalSupply += amount;

            // Notify listeners
            TransferEvent(0, this, amount);
            TransferEvent(this, recipient, amount);
        }

        // Next round
        incentiveDistributionDate = now + incentiveDistributionInterval;
        incentiveDistributionRound++;
    }

    /**
     * Unlocks the token irreversibly so that the transfering of value is enabled
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() public onlyOwner returns (bool success) {
        locked = false;
        return true;
    }

    /**
     * Issues `_amount` new tokens to `_recipient` (_amount < 0 guarantees that tokens are never removed)
     *
     * @param _recipient The address to which the tokens will be issued
     * @param _amount The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _recipient, uint256 _amount) public onlyOwner returns (bool success) {
        // Guarantee positive
        require(_amount >= 0);

        // Create tokens
        balances[_recipient] += _amount;
        totalSupply += _amount;

        // Notify listners
        TransferEvent(0, owner, _amount);
        TransferEvent(owner, _recipient, _amount);

        return true;
    }

}