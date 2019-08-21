/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */
pragma solidity ^0.4.2;

contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is Token {

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

}


/**
 * Arcade City crowdsale crowdsale contract.
 *
 * Security criteria evaluated against http://ethereum.stackexchange.com/questions/8551/methodological-security-review-of-a-smart-contract
 *
 *
 */
contract ARCToken is StandardToken, SafeMath {

    string public name = "Arcade Token";
    string public symbol = "ARC";
    uint public decimals = 18;
    uint public startBlock; //crowdsale start block (set in constructor)
    uint public endBlock; //crowdsale end block (set in constructor)

    // Initial multisig address (set in constructor)
    // All deposited ETH will be instantly forwarded to this address.
    // Address is a multisig wallet.
    address public multisig = 0x0;

    address public founder = 0x0;
    address public developer = 0x0;
    address public rewards = 0x0;
    bool public rewardAddressesSet = false;

    address public owner = 0x0;
    bool public marketactive = false;

    uint public etherCap = 672000 * 10**18; //max amount raised during crowdsale (8.5M USD worth of ether will be measured with a moving average market price at beginning of the crowdsale)
    uint public rewardsAllocation = 2; //2% tokens allocated post-crowdsale for swarm rewards
    uint public developerAllocation = 6 ; //6% of token supply allocated post-crowdsale for the developer fund
    uint public founderAllocation = 8; //8% of token supply allocated post-crowdsale for the founder allocation
    bool public allocated = false; //this will change to true when the rewards are allocated
    uint public presaleTokenSupply = 0; //this will keep track of the token supply created during the crowdsale
    uint public presaleEtherRaised = 0; //this will keep track of the Ether raised during the crowdsale
    bool public halted = false; //the founder address can set this to true to halt the crowdsale due to emergency
    event Buy(address indexed sender, uint eth, uint fbt);

    function ARCToken(address multisigInput, uint startBlockInput, uint endBlockInput) {
        owner = msg.sender;
        multisig = multisigInput;

        startBlock = startBlockInput;
        endBlock = endBlockInput;
    }

    function setRewardAddresses(address founderInput, address developerInput, address rewardsInput){
        if (msg.sender != owner) throw;
        if (rewardAddressesSet) throw;
        founder = founderInput;
        developer = developerInput;
        rewards = rewardsInput;
        rewardAddressesSet = true;
    }

    function price() constant returns(uint) {
        return testPrice(block.number);        
    }

    // price() exposed for unit tests
    function testPrice(uint blockNumber) constant returns(uint) {
        if (blockNumber>=startBlock && blockNumber<startBlock+250) return 125; //power hour
        if (blockNumber<startBlock || blockNumber>endBlock) return 75; //default price
        return 75 + 4*(endBlock - blockNumber)/(endBlock - startBlock + 1)*34/4; //crowdsale price
    }

    /**
     * Main token buy function.
     *
     * Security review
     *
     * - Integer math: ok - using SafeMath
     *
     * - halt flag added - ok
     *
     * Applicable tests:
     *
     * - Test halting, buying, and failing
     * - Test buying on behalf of a recipient
     * - Test buy
     * - Test unhalting, buying, and succeeding
     * - Test buying after the sale ends
     *
     */
    function buyRecipient(address recipient) {
        if (block.number<startBlock || block.number>endBlock || safeAdd(presaleEtherRaised,msg.value)>etherCap || halted) throw;
        uint tokens = safeMul(msg.value, price());
        balances[recipient] = safeAdd(balances[recipient], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        presaleEtherRaised = safeAdd(presaleEtherRaised, msg.value);

        if (!multisig.send(msg.value)) throw; //immediately send Ether to multisig address

        // if etherCap is reached - activate the market
        if (presaleEtherRaised == etherCap && !marketactive){
            marketactive = true;
        }

        Buy(recipient, msg.value, tokens);

    }

    /**
     * Set up founder address token balance.
     *
     * allocateBountyAndEcosystemTokens() must be calld first.
     *
     * Security review
     *
     * - Integer math: ok - only called once with fixed parameters
     *
     * Applicable tests:
     *
     * - Test bounty and ecosystem allocation
     * - Test bounty and ecosystem allocation twice
     *
     */
    function allocateTokens() {
        // make sure founder/developer/rewards addresses are configured
        if(founder == 0x0 || developer == 0x0 || rewards == 0x0) throw;
        // owner/founder/developer/rewards addresses can call this function
        if (msg.sender != owner && msg.sender != founder && msg.sender != developer && msg.sender != rewards ) throw;
        // it should only continue if endBlock has passed OR presaleEtherRaised has reached the cap
        if (block.number <= endBlock && presaleEtherRaised < etherCap) throw;
        if (allocated) throw;
        presaleTokenSupply = totalSupply;
        // total token allocations add up to 16% of total coins, so formula is reward=allocation_in_percent/84 .
        balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / 84 );
        totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / 84);
        
        balances[developer] = safeAdd(balances[developer], presaleTokenSupply * developerAllocation / 84);
        totalSupply = safeAdd(totalSupply, presaleTokenSupply * developerAllocation / 84);
        
        balances[rewards] = safeAdd(balances[rewards], presaleTokenSupply * rewardsAllocation / 84);
        totalSupply = safeAdd(totalSupply, presaleTokenSupply * rewardsAllocation / 84);

        allocated = true;

    }

    /**
     * Emergency Stop crowdsale.
     *
     *  Applicable tests:
     *
     * - Test unhalting, buying, and succeeding
     */
    function halt() {
        if (msg.sender!=founder && msg.sender != developer) throw;
        halted = true;
    }

    function unhalt() {
        if (msg.sender!=founder && msg.sender != developer) throw;
        halted = false;
    }

    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until token sale is over.
     *
     * Applicable tests:
     *
     * - Test transfer after restricted period
     * - Test transfer after market activated
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock && marketactive == false) throw;
        return super.transfer(_to, _value);
    }
    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until token sale is over.
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock && marketactive == false) throw;
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * Direct deposits buys tokens
     */
    function() payable {
        buyRecipient(msg.sender);
    }

}