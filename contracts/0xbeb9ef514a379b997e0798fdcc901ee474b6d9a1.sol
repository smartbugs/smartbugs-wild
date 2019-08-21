pragma solidity ^0.4.8;

/// @title Assertive contract
/// @author Melonport AG <team@melonport.com>
/// @notice Asserts function
contract Assertive {

  function assert(bool assertion) internal {
      if (!assertion) throw;
  }

}

/// @title Overflow aware uint math functions.
/// @author Melonport AG <team@melonport.com>
/// @notice Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
contract SafeMath is Assertive{

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

}

/// @title ERC20 Token Protocol
/// @author Melonport AG <team@melonport.com>
/// @notice See https://github.com/ethereum/EIPs/issues/20
contract ERC20Protocol {

    function totalSupply() constant returns (uint256 totalSupply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/// @title ERC20 Token
/// @author Melonport AG <team@melonport.com>
/// @notice Original taken from https://github.com/ethereum/EIPs/issues/20
/// @notice Checked against integer overflow
contract ERC20 is ERC20Protocol {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
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

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

}


/// @title Melon Token Contract
/// @author Melonport AG <team@melonport.com>
contract MelonToken is ERC20, SafeMath {

    // FIELDS

    // Constant token specific fields
    string public constant name = "Melon Token";
    string public constant symbol = "MLN";
    uint public constant decimals = 18;
    uint public constant THAWING_DURATION = 2 years; // Time needed for iced tokens to thaw into liquid tokens
    uint public constant MAX_TOTAL_TOKEN_AMOUNT_OFFERED_TO_PUBLIC = 1000000 * 10 ** decimals; // Max amount of tokens offered to the public
    uint public constant MAX_TOTAL_TOKEN_AMOUNT = 1250000 * 10 ** decimals; // Max amount of total tokens raised during all contributions (includes stakes of patrons)

    // Fields that are only changed in constructor
    address public minter; // Contribution contract(s)
    address public melonport; // Can change to other minting contribution contracts but only until total amount of token minted
    uint public startTime; // Contribution start time in seconds
    uint public endTime; // Contribution end time in seconds

    // Fields that can be changed by functions
    mapping (address => uint) lockedBalances;

    // MODIFIERS

    modifier only_minter {
        assert(msg.sender == minter);
        _;
    }

    modifier only_melonport {
        assert(msg.sender == melonport);
        _;
    }

    modifier is_later_than(uint x) {
        assert(now > x);
        _;
    }

    modifier max_total_token_amount_not_reached(uint amount) {
        assert(safeAdd(totalSupply, amount) <= MAX_TOTAL_TOKEN_AMOUNT);
        _;
    }

    // CONSTANT METHODS

    function lockedBalanceOf(address _owner) constant returns (uint balance) {
        return lockedBalances[_owner];
    }

    // METHODS

    /// Pre: All fields, except { minter, melonport, startTime, endTime } are valid
    /// Post: All fields, including { minter, melonport, startTime, endTime } are valid
    function MelonToken(address setMinter, address setMelonport, uint setStartTime, uint setEndTime) {
        minter = setMinter;
        melonport = setMelonport;
        startTime = setStartTime;
        endTime = setEndTime;
    }

    /// Pre: Address of contribution contract (minter) is set
    /// Post: Mints token into tradeable tranche
    function mintLiquidToken(address recipient, uint amount)
        external
        only_minter
        max_total_token_amount_not_reached(amount)
    {
        balances[recipient] = safeAdd(balances[recipient], amount);
        totalSupply = safeAdd(totalSupply, amount);
    }

    /// Pre: Address of contribution contract (minter) is set
    /// Post: Mints Token into iced tranche. Become liquid after completion of the melonproject or two years.
    function mintIcedToken(address recipient, uint amount)
        external
        only_minter
        max_total_token_amount_not_reached(amount)
    {
        lockedBalances[recipient] = safeAdd(lockedBalances[recipient], amount);
        totalSupply = safeAdd(totalSupply, amount);
    }

    /// Pre: Thawing period has passed - iced funds have turned into liquid ones
    /// Post: All funds available for trade
    function unlockBalance(address recipient)
        is_later_than(endTime + THAWING_DURATION)
    {
        balances[recipient] = safeAdd(balances[recipient], lockedBalances[recipient]);
        lockedBalances[recipient] = 0;
    }

    /// Pre: Prevent transfers until contribution period is over.
    /// Post: Transfer MLN from msg.sender
    /// Note: ERC20 interface
    function transfer(address recipient, uint amount)
        is_later_than(endTime)
        returns (bool success)
    {
        return super.transfer(recipient, amount);
    }

    /// Pre: Prevent transfers until contribution period is over.
    /// Post: Transfer MLN from arbitrary address
    /// Note: ERC20 interface
    function transferFrom(address sender, address recipient, uint amount)
        is_later_than(endTime)
        returns (bool success)
    {
        return super.transferFrom(sender, recipient, amount);
    }

    /// Pre: Melonport address is set. Restricted to melonport.
    /// Post: New minter can now create tokens up to MAX_TOTAL_TOKEN_AMOUNT.
    /// Note: This allows additional contribution periods at a later stage, while still using the same ERC20 compliant contract.
    function changeMintingAddress(address newAddress) only_melonport { minter = newAddress; }

    /// Pre: Melonport address is set. Restricted to melonport.
    /// Post: New address set. This address controls the setting of the minter address
    function changeMelonportAddress(address newAddress) only_melonport { melonport = newAddress; }
}


/// @title Contribution Contract
/// @author Melonport AG <team@melonport.com>
/// @notice This follows Condition-Orientated Programming as outlined here:
/// @notice   https://medium.com/@gavofyork/condition-orientated-programming-969f6ba0161a#.saav3bvva
contract Contribution is SafeMath {

    // FIELDS

    // Constant fields
    uint public constant ETHER_CAP = 227000 ether; // Max amount raised during first contribution; targeted amount CHF 2.5MN
    uint public constant MAX_CONTRIBUTION_DURATION = 4 weeks; // Max amount in seconds of contribution period
    uint public constant BTCS_ETHER_CAP = ETHER_CAP * 25 / 100; // Max melon token allocation for btcs before contribution period starts
    // Price Rates
    uint public constant PRICE_RATE_FIRST = 2200; // Four price tiers, each valid for two weeks
    uint public constant PRICE_RATE_SECOND = 2150;
    uint public constant PRICE_RATE_THIRD = 2100;
    uint public constant PRICE_RATE_FOURTH = 2050;
    uint public constant DIVISOR_PRICE = 1000; // Price rates are divided by this number
    // Addresses of Patrons
    address public constant FOUNDER_ONE = 0x009beAE06B0c0C536ad1eA43D6f61DCCf0748B1f;
    address public constant FOUNDER_TWO = 0xB1EFca62C555b49E67363B48aE5b8Af3C7E3e656;
    address public constant EXT_COMPANY_ONE = 0x00779e0e4c6083cfd26dE77B4dbc107A7EbB99d2;
    address public constant EXT_COMPANY_TWO = 0x1F06B976136e94704D328D4d23aae7259AaC12a2;
    address public constant EXT_COMPANY_THREE = 0xDD91615Ea8De94bC48231c4ae9488891F1648dc5;
    address public constant ADVISOR_ONE = 0x0001126FC94AE0be2B685b8dE434a99B2552AAc3;
    address public constant ADVISOR_TWO = 0x4f2AF8d2614190Cc80c6E9772B0C367db8D9753C;
    address public constant ADVISOR_THREE = 0x715a70a7c7d76acc8d5874862e381c1940c19cce;
    address public constant ADVISOR_FOUR = 0x8615F13C12c24DFdca0ba32511E2861BE02b93b2;
    address public constant AMBASSADOR_ONE = 0xd3841FB80CE408ca7d0b41D72aA91CA74652AF47;
    address public constant AMBASSADOR_TWO = 0xDb775577538018a689E4Ad2e8eb5a7Ae7c34722B;
    address public constant AMBASSADOR_THREE = 0xaa967e0ce6A1Ff5F9c124D15AD0412F137C99767;
    address public constant AMBASSADOR_FOUR = 0x910B41a6568a645437bC286A5C733f3c501d8c88;
    address public constant AMBASSADOR_FIVE = 0xb1d16BFE840E66E3c81785551832aAACB4cf69f3;
    address public constant AMBASSADOR_SIX = 0x5F6ff16364BfEf546270325695B6e90cc89C497a;
    address public constant AMBASSADOR_SEVEN = 0x58656e8872B0d266c2acCD276cD23F4C0B5fEfb9;
    address public constant SPECIALIST_ONE = 0x8a815e818E617d1f93BE7477D179258aC2d25310;
    address public constant SPECIALIST_TWO = 0x1eba6702ba21cfc1f6c87c726364b60a5e444901;
    address public constant SPECIALIST_THREE = 0x82eae6c30ed9606e2b389ae65395648748c6a17f;
    // Stakes of Patrons
    uint public constant MELONPORT_COMPANY_STAKE = 1000; // 10% of all created melon token allocated to melonport company
    uint public constant FOUNDER_STAKE = 445; // 4.45% of all created melon token allocated to founder
    uint public constant EXT_COMPANY_STAKE_ONE = 150; // 1.5% of all created melon token allocated to external company
    uint public constant EXT_COMPANY_STAKE_TWO = 100; // 1% of all created melon token allocated to external company
    uint public constant EXT_COMPANY_STAKE_THREE = 50; // 0.5% of all created melon token allocated to external company
    uint public constant ADVISOR_STAKE_ONE = 150; // 1.5% of all created melon token allocated to advisor
    uint public constant ADVISOR_STAKE_TWO = 50; // 0.5% of all created melon token allocated to advisor
    uint public constant ADVISOR_STAKE_THREE = 25; // 0.25% of all created melon token allocated to advisor
    uint public constant ADVISOR_STAKE_FOUR = 10; // 0.1% of all created melon token allocated to advisor
    uint public constant AMBASSADOR_STAKE = 5; // 0.05% of all created melon token allocated to ambassadors
    uint public constant SPECIALIST_STAKE_ONE = 25; // 0.25% of all created melon token allocated to specialist
    uint public constant SPECIALIST_STAKE_TWO = 10; // 0.1% of all created melon token allocated to specialist
    uint public constant SPECIALIST_STAKE_THREE = 5; // 0.05% of all created melon token allocated to specialist
    uint public constant DIVISOR_STAKE = 10000; // Stakes are divided by this number; Results to one basis point

    // Fields that are only changed in constructor
    address public melonport; // All deposited ETH will be instantly forwarded to this address.
    address public btcs; // Bitcoin Suisse address for their allocation option
    address public signer; // Signer address as on https://contribution.melonport.com
    uint public startTime; // Contribution start time in seconds
    uint public endTime; // Contribution end time in seconds
    MelonToken public melonToken; // Contract of the ERC20 compliant melon token

    // Fields that can be changed by functions
    uint public etherRaised; // This will keep track of the Ether raised during the contribution
    bool public halted; // The melonport address can set this to true to halt the contribution due to an emergency

    // EVENTS

    event TokensBought(address indexed sender, uint eth, uint amount);

    // MODIFIERS

    modifier is_signer_signature(uint8 v, bytes32 r, bytes32 s) {
        bytes32 hash = sha256(msg.sender);
        assert(ecrecover(hash, v, r, s) == signer);
        _;
    }

    modifier only_melonport {
        assert(msg.sender == melonport);
        _;
    }

    modifier only_btcs {
        assert(msg.sender == btcs);
        _;
    }

    modifier is_not_halted {
        assert(!halted);
        _;
    }

    modifier ether_cap_not_reached {
        assert(safeAdd(etherRaised, msg.value) <= ETHER_CAP);
        _;
    }

    modifier btcs_ether_cap_not_reached {
        assert(safeAdd(etherRaised, msg.value) <= BTCS_ETHER_CAP);
        _;
    }

    modifier is_not_earlier_than(uint x) {
        assert(now >= x);
        _;
    }

    modifier is_earlier_than(uint x) {
        assert(now < x);
        _;
    }

    // CONSTANT METHODS

    /// Pre: startTime, endTime specified in constructor,
    /// Post: Price rate at given blockTime; One ether equals priceRate() / DIVISOR_PRICE of melon tokens
    function priceRate() constant returns (uint) {
        // Four price tiers
        if (startTime <= now && now < startTime + 1 weeks)
            return PRICE_RATE_FIRST;
        if (startTime + 1 weeks <= now && now < startTime + 2 weeks)
            return PRICE_RATE_SECOND;
        if (startTime + 2 weeks <= now && now < startTime + 3 weeks)
            return PRICE_RATE_THIRD;
        if (startTime + 3 weeks <= now && now < endTime)
            return PRICE_RATE_FOURTH;
        // Should not be called before or after contribution period
        assert(false);
    }

    // NON-CONSTANT METHODS

    /// Pre: All fields, except { melonport, btcs, signer, startTime } are valid
    /// Post: All fields, including { melonport, btcs, signer, startTime } are valid
    function Contribution(address setMelonport, address setBTCS, address setSigner, uint setStartTime) {
        melonport = setMelonport;
        btcs = setBTCS;
        signer = setSigner;
        startTime = setStartTime;
        endTime = startTime + MAX_CONTRIBUTION_DURATION;
        melonToken = new MelonToken(this, melonport, startTime, endTime); // Create Melon Token Contract
        var maxTotalTokenAmountOfferedToPublic = melonToken.MAX_TOTAL_TOKEN_AMOUNT_OFFERED_TO_PUBLIC();
        uint stakeMultiplier = maxTotalTokenAmountOfferedToPublic / DIVISOR_STAKE;
        // Mint liquid tokens for melonport company, liquid means tradeale
        melonToken.mintLiquidToken(melonport,       MELONPORT_COMPANY_STAKE * stakeMultiplier);
        // Mint iced tokens that are unable to trade for two years and allocate according to relevant stakes
        melonToken.mintIcedToken(FOUNDER_ONE,       FOUNDER_STAKE *           stakeMultiplier);
        melonToken.mintIcedToken(FOUNDER_TWO,       FOUNDER_STAKE *           stakeMultiplier);
        melonToken.mintIcedToken(EXT_COMPANY_ONE,   EXT_COMPANY_STAKE_ONE *   stakeMultiplier);
        melonToken.mintIcedToken(EXT_COMPANY_TWO,   EXT_COMPANY_STAKE_TWO *   stakeMultiplier);
        melonToken.mintIcedToken(EXT_COMPANY_THREE, EXT_COMPANY_STAKE_THREE * stakeMultiplier);
        melonToken.mintIcedToken(ADVISOR_ONE,       ADVISOR_STAKE_ONE *       stakeMultiplier);
        melonToken.mintIcedToken(ADVISOR_TWO,       ADVISOR_STAKE_TWO *       stakeMultiplier);
        melonToken.mintIcedToken(ADVISOR_THREE,     ADVISOR_STAKE_THREE *     stakeMultiplier);
        melonToken.mintIcedToken(ADVISOR_FOUR,      ADVISOR_STAKE_FOUR *      stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_ONE,    AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_TWO,    AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_THREE,  AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_FOUR,   AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_FIVE,   AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_SIX,    AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(AMBASSADOR_SEVEN,  AMBASSADOR_STAKE *        stakeMultiplier);
        melonToken.mintIcedToken(SPECIALIST_ONE,    SPECIALIST_STAKE_ONE *    stakeMultiplier);
        melonToken.mintIcedToken(SPECIALIST_TWO,    SPECIALIST_STAKE_TWO *    stakeMultiplier);
        melonToken.mintIcedToken(SPECIALIST_THREE,  SPECIALIST_STAKE_THREE *  stakeMultiplier);
    }

    /// Pre: Valid signature received from https://contribution.melonport.com
    /// Post: Bought melon tokens according to priceRate() and msg.value
    function buy(uint8 v, bytes32 r, bytes32 s) payable { buyRecipient(msg.sender, v, r, s); }

    /// Pre: Valid signature received from https://contribution.melonport.com
    /// Post: Bought melon tokens according to priceRate() and msg.value on behalf of recipient
    function buyRecipient(address recipient, uint8 v, bytes32 r, bytes32 s)
        payable
        is_signer_signature(v, r, s)
        is_not_earlier_than(startTime)
        is_earlier_than(endTime)
        is_not_halted
        ether_cap_not_reached
    {
        uint amount = safeMul(msg.value, priceRate()) / DIVISOR_PRICE;
        melonToken.mintLiquidToken(recipient, amount);
        etherRaised = safeAdd(etherRaised, msg.value);
        assert(melonport.send(msg.value));
        TokensBought(recipient, msg.value, amount);
    }

    /// Pre: BTCS before contribution period, BTCS has exclusive right to buy up to 25% of all melon tokens
    /// Post: Bought melon tokens according to PRICE_RATE_FIRST and msg.value on behalf of recipient
    function btcsBuyRecipient(address recipient)
        payable
        only_btcs
        is_earlier_than(startTime)
        is_not_halted
        btcs_ether_cap_not_reached
    {
        uint amount = safeMul(msg.value, PRICE_RATE_FIRST) / DIVISOR_PRICE;
        melonToken.mintLiquidToken(recipient, amount);
        etherRaised = safeAdd(etherRaised, msg.value);
        assert(melonport.send(msg.value));
        TokensBought(recipient, msg.value, amount);
    }

    /// Pre: Emergency situation that requires contribution period to stop.
    /// Post: Contributing not possible anymore.
    function halt() only_melonport { halted = true; }

    /// Pre: Emergency situation resolved.
    /// Post: Contributing becomes possible again withing the outlined restrictions.
    function unhalt() only_melonport { halted = false; }

    /// Pre: Restricted to melonport.
    /// Post: New address set. To halt contribution and/or change minter in MelonToken contract.
    function changeMelonportAddress(address newAddress) only_melonport { melonport = newAddress; }
}