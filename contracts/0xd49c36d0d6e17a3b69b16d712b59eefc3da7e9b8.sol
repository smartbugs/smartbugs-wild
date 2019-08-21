/*
file:   Hut34ICO.sol
ver:    0.2.4_deploy
author: Darryl Morris
date:   27-Oct-2017
email:  o0ragman0o AT gmail.com
(c) Darryl Morris 2017

A collated contract set for the receipt of funds and production and transfer
of ERC20 tokens as specified by Hut34.

License
-------
This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
* Added `event Aborted()`
* correct `wholesaleLeft` magnitude bug
* All tests passed

Dedications
-------------
* with love to Isabella and pea from your dad
* xx to edie, robin, william and charlotte x
*/


pragma solidity ^0.4.17;

// Audited 27 October 2017 by Darryl Morris, Peter Godbolt
contract Hut34Config
{
    // ERC20 token name
    string  public constant name            = "Hut34 Entropy";
    
    // ERC20 trading symbol
    string  public constant symbol          = "ENT";

    // ERC20 decimal places
    uint8   public constant decimals        = 18;

    // Total supply (* in unit ENT *)
    uint    public constant TOTAL_TOKENS    = 100000000;

    // Contract owner at time of deployment.
    address public constant OWNER           = 0xdA3780Cff2aE3a59ae16eC1734DEec77a7fd8db2;

    // + new Date("00:00 2 November 2017 utc")/1000
    uint    public constant START_DATE      = 1509580800;

    // A Hut34 address to own tokens
    address public constant HUT34_RETAIN    = 0x3135F4acA3C1Ad4758981500f8dB20EbDc5A1caB;
    
    // A Hut34 address to accept raised funds
    address public constant HUT34_WALLET    = 0xA70d04dC4a64960c40CD2ED2CDE36D76CA4EDFaB;
    
    // Percentage of tokens to be vested over 2 years. 20%
    uint    public constant VESTED_PERCENT  = 20;

    // Vesting period
    uint    public constant VESTING_PERIOD  = 26 weeks;

    // Minimum cap over which the funding is considered successful
    uint    public constant MIN_CAP         = 3000 * 1 ether;

    // An ether threshold over which a funder must KYC before tokens can be
    // transferred (unit of ether);
    uint    public constant KYC_THRESHOLD   = 150 * 1 ether;

    // A minimum amount of ether funding before the concierge rate is applied
    // to tokens
    uint    public constant WHOLESALE_THRESHOLD  = 150 * 1 ether;
    
    // Number of tokens up for wholesale purchasers (* in unit ENT *)
    uint    public constant WHOLESALE_TOKENS = 12500000;

    // Tokens sold to prefunders (* in unit ENT *)
    uint    public constant PRESOLD_TOKENS  = 1817500;
    
    // Presale ether is estimateed from fiat raised prior to ICO at the ETH/AUD
    // rate at the time of contract deployment
    uint    public constant PRESALE_ETH_RAISE = 2190 * 1 ether;
    
    // Address holding presold tokens to be distributed after ICO
    address public constant PRESOLD_ADDRESS = 0x6BF708eF2C1FDce3603c04CE9547AA6E134093b6;
    
    // wholesale rate for purchases over WHOLESALE_THRESHOLD ether
    uint    public constant RATE_WHOLESALE  = 1000;

    // Time dependant retail rates
    // First Day
    uint    public constant RATE_DAY_0      = 750;

    // First Week (The six days after first day)
    uint    public constant RATE_DAY_1      = 652;

    // Second Week
    uint    public constant RATE_DAY_7      = 588;

    // Third Week
    uint    public constant RATE_DAY_14     = 545;

    // Fourth Week
    uint    public constant RATE_DAY_21     = 517;

    // Fifth Week
    uint    public constant RATE_DAY_28     = 500;
}


library SafeMath
{
    // a add to b
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    
    // a subtract b
    function sub(uint a, uint b) internal pure returns (uint c) {
        c = a - b;
        assert(c <= a);
    }
    
    // a multiplied by b
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    
    // a divided by b
    function div(uint a, uint b) internal pure returns (uint c) {
        assert(b != 0);
        c = a / b;
    }
}


contract ReentryProtected
{
    // The reentry protection state mutex.
    bool __reMutex;

    // Sets and clears mutex in order to block function reentry
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
    }

    // Blocks function entry if mutex is set
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
}


contract ERC20Token
{
    using SafeMath for uint;

/* Constants */

    // none
    
/* State variable */

    /// @return The Total supply of tokens
    uint public totalSupply;
    
    /// @return Tokens owned by an address
    mapping (address => uint) balances;
    
    /// @return Tokens spendable by a thridparty
    mapping (address => mapping (address => uint)) allowed;

/* Events */

    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount);

    // Triggered whenever approve(address _spender, uint256 _amount) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount);

/* Modifiers */

    // none
    
/* Functions */

    // Using an explicit getter allows for function overloading    
    function balanceOf(address _addr)
        public
        view
        returns (uint)
    {
        return balances[_addr];
    }
    
    // Using an explicit getter allows for function overloading    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _amount)
        public
        returns (bool)
    {
        return xfer(msg.sender, _to, _amount);
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        returns (bool)
    {
        require(_amount <= allowed[_from][msg.sender]);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        return xfer(_from, _to, _amount);
    }

    // Process a transfer internally.
    function xfer(address _from, address _to, uint _amount)
        internal
        returns (bool)
    {
        require(_amount <= balances[_from]);

        Transfer(_from, _to, _amount);
        
        // avoid wasting gas on 0 token transfers
        if(_amount == 0) return true;
        
        balances[_from] = balances[_from].sub(_amount);
        balances[_to]   = balances[_to].add(_amount);
        
        return true;
    }

    // Approves a third-party spender
    function approve(address _spender, uint256 _amount)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
}


/*-----------------------------------------------------------------------------\

## Conditional Entry Table

Functions must throw on F conditions

Renetry prevention is on all public mutating functions
Reentry mutex set in finalizeICO(), externalXfer(), refund()

|function                |<startDate |<endDate  |fundFailed  |fundRaised|icoSucceeded
|------------------------|:---------:|:--------:|:----------:|:--------:|:---------:|
|()                      |F          |T         |F           |T         |F          |
|abort()                 |T          |T         |T           |T         |F          |
|proxyPurchase()         |F          |T         |F           |T         |F          |
|finalizeICO()           |F          |F         |F           |T         |T          |
|refund()                |F          |F         |T           |F         |F          |
|refundFor()             |F          |F         |T           |F         |F          |
|transfer()              |F          |F         |F           |F         |T          |
|transferFrom()          |F          |F         |F           |F         |T          |
|transferToMany()        |F          |F         |F           |F         |T          |
|approve()               |F          |F         |F           |F         |T          |
|clearKyc()              |T          |T         |T           |T         |T          |
|releaseVested()         |F          |F         |F           |F         |now>release|
|changeOwner()           |T          |T         |T           |T         |T          |
|acceptOwnership()       |T          |T         |T           |T         |T          |
|transferExternalTokens()|T          |T         |T           |T         |T          |
|destroy()               |F          |F         |!__abortFuse|F         |F          |

\*----------------------------------------------------------------------------*/

contract Hut34ICOAbstract
{
    /// @dev Logged upon receiving a deposit
    /// @param _from The address from which value has been recieved
    /// @param _value The value of ether received
    event Deposit(address indexed _from, uint _value);
    
    /// @dev Logged upon a withdrawal
    /// @param _from the address of the withdrawer
    /// @param _to Address to which value was sent
    /// @param _value The value in ether which was withdrawn
    event Withdrawal(address indexed _from, address indexed _to, uint _value);

    /// @dev Logged when new owner accepts ownership
    /// @param _from the old owner address
    /// @param _to the new owner address
    event ChangedOwner(address indexed _from, address indexed _to);
    
    /// @dev Logged when owner initiates a change of ownership
    /// @param _to the new owner address
    event ChangeOwnerTo(address indexed _to);
    
    /// @dev Logged when a funder exceeds the KYC limit
    /// @param _addr Address to set or clear KYC flag
    /// @param _kyc A boolean flag
    event Kyc(address indexed _addr, bool _kyc);

    /// @dev Logged when vested tokens are released back to HUT32_WALLET
    /// @param _releaseDate The official release date (even if released at
    /// later date)
    event VestingReleased(uint _releaseDate);
    
    /// @dev Logged if the contract is aborted
    event Aborted();

//
// Constants
//

    /// @dev The Hut34 vesting 'psudo-address' for transferring and releasing
    /// vested tokens to the Hut34 Wallet. The address is UTF8 encoding of the
    /// string and can only be accessed by the 'releaseVested()' function.
    /// @return `0x48757433342056657374696e6700000000000000`
    address public constant HUT34_VEST_ADDR = address(bytes20("Hut34 Vesting"));

//
// State Variables
//

    /// @dev This fuse blows upon calling abort() which forces a fail state
    /// @return the abort state. true == not aborted
    bool public __abortFuse = true;
    
    /// @dev Sets to true after the fund is swept to the fund wallet, allows
    /// token transfers and prevents abort()
    /// @return final success state of ICO
    bool public icoSucceeded;

    /// @dev An address permissioned to enact owner restricted functions
    /// @return owner
    address public owner;
    
    /// @dev An address permissioned to take ownership of the contract
    /// @return new owner address
    address public newOwner;

    /// @dev A tally of total ether raised during the funding period
    /// @return Total ether raised during funding
    uint public etherRaised;
    
    /// @return Wholesale tokens available for sale
    uint public wholesaleLeft;
    
    /// @return Total ether refunded. Used to permision call to `destroy()`
    uint public refunded;
    
    /// @returns Date of next vesting release
    uint public nextReleaseDate;

    /// @return Ether paid by an address
    mapping (address => uint) public etherContributed;
    
    /// @returns KYC flag for an address
    mapping (address => bool) public mustKyc;

//
// Modifiers
//

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

//
// Function Abstracts
//

    /// @return `true` if MIN_FUNDS were raised
    function fundRaised() public view returns (bool);
    
    /// @return `true` if MIN_FUNDS were not raised before END_DATE or contract 
    /// has been aborted
    function fundFailed() public view returns (bool);

    /// @return The current retail rate for token purchase
    function currentRate() public view returns (uint);
    
    /// @param _wei A value of ether in units of wei
    /// @return allTokens_ returnable tokens for the funding amount
    /// @return wholesaleToken_ Number of tokens purchased at wholesale rate
    function ethToTokens(uint _wei)
        public view returns (uint allTokens_, uint wholesaleTokens_);

    /// @notice Processes a token purchase for `_addr`
    /// @param _addr An address to purchase tokens
    /// @return Boolean success value
    /// @dev Requires <150,000 gas
    function proxyPurchase(address _addr) public payable returns (bool);

    /// @notice Finalize the ICO and transfer funds
    /// @return Boolean success value
    function finalizeICO() public returns (bool);

    /// @notice Clear the KYC flags for an array of addresses to allow tokens
    /// transfers
    function clearKyc(address[] _addrs) public returns (bool);
    
    /// @notice Make bulk transfer of tokens to many addresses
    /// @param _addrs An array of recipient addresses
    /// @param _amounts An array of amounts to transfer to respective addresses
    /// @return Boolean success value
    function transferToMany(address[] _addrs, uint[] _amounts)
        public returns (bool);

    /// @notice Release vested tokens after a maturity date
    /// @return Boolean success value
    function releaseVested() public returns (bool);

    /// @notice Claim refund on failed ICO
    /// @return Boolean success value
    function refund() public returns (bool);
    
    /// @notice Push refund for `_addr` from failed ICO
    /// @param _addrs An array of address to refund
    /// @return Boolean success value
    function refundFor(address[] _addrs) public returns (bool);

    /// @notice Abort the token sale prior to finalizeICO() 
    function abort() public returns (bool);

    /// @notice Salvage `_amount` tokens at `_kaddr` and send them to `_to`
    /// @param _kAddr An ERC20 contract address
    /// @param _to and address to send tokens
    /// @param _amount The number of tokens to transfer
    /// @return Boolean success value
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public returns (bool);
}


/*-----------------------------------------------------------------------------\

 Hut34ICO implimentation

\*----------------------------------------------------------------------------*/

contract Hut34ICO is 
    ReentryProtected,
    ERC20Token,
    Hut34ICOAbstract,
    Hut34Config
{
    using SafeMath for uint;

//
// Constants
//

    // Token fixed point for decimal places
    uint constant TOKEN = uint(10)**decimals; 

    // Calculate vested tokens
    uint public constant VESTED_TOKENS =
            TOTAL_TOKENS * TOKEN * VESTED_PERCENT / 100;
            
    // Hut34 retains 50% of tokens (70% - 20% vested tokens) 
    uint public constant RETAINED_TOKENS = TOKEN * TOTAL_TOKENS / 2;

    // Calculate end date
    uint public constant END_DATE = START_DATE + 35 days;

    // Divides `etherRaised` to calculate commision
    // etherRaised/6.66... == etherRaised * 1.5% / 100
    uint public constant COMMISSION_DIV = 67;

    // Developer commission wallet
    address public constant COMMISSION_WALLET = 
        0x0065D506E475B5DBD76480bAFa57fe7C41c783af;

//
// Functions
//

    function Hut34ICO()
        public
    {
        // Run sanity checks
        require(TOTAL_TOKENS != 0);
        require(OWNER != 0x0);
        require(HUT34_RETAIN != 0x0);
        require(HUT34_WALLET != 0x0);
        require(PRESOLD_TOKENS <= WHOLESALE_TOKENS);
        require(PRESOLD_TOKENS == 0 || PRESOLD_ADDRESS != 0x0);
        require(MIN_CAP != 0);
        require(START_DATE >= now);
        require(bytes(name).length != 0);
        require(bytes(symbol).length != 0);
        require(KYC_THRESHOLD != 0);
        require(RATE_DAY_0 >= RATE_DAY_1);
        require(RATE_DAY_1 >= RATE_DAY_7);
        require(RATE_DAY_7 >= RATE_DAY_14);
        require(RATE_DAY_14 >= RATE_DAY_21);
        require(RATE_DAY_21 >= RATE_DAY_28);
        
        owner = OWNER;
        totalSupply = TOTAL_TOKENS.mul(TOKEN);
        wholesaleLeft = WHOLESALE_TOKENS.mul(TOKEN);
        uint presold = PRESOLD_TOKENS.mul(TOKEN);
        wholesaleLeft = wholesaleLeft.sub(presold);

        // Presale raise is appoximate given it was conducted in Fiat.
        etherRaised = PRESALE_ETH_RAISE;

        // Mint the total supply into Hut34 token holding address
        balances[HUT34_RETAIN] = totalSupply;
        Transfer(0x0, HUT34_RETAIN, totalSupply);

        // Transfer vested tokens from holding wallet to vesting pseudo-address
        balances[HUT34_RETAIN] = balances[HUT34_RETAIN].sub(VESTED_TOKENS);
        balances[HUT34_VEST_ADDR] = balances[HUT34_VEST_ADDR].add(VESTED_TOKENS);
        Transfer(HUT34_RETAIN, HUT34_VEST_ADDR, VESTED_TOKENS);

        // Transfer presold tokens to holding address;
        balances[HUT34_RETAIN] = balances[HUT34_RETAIN].sub(presold);
        balances[PRESOLD_ADDRESS] = balances[PRESOLD_ADDRESS].add(presold);
        Transfer(HUT34_RETAIN, PRESOLD_ADDRESS, presold);
    }

    // Default function. Accepts payments during funding period
    function ()
        public
        payable
    {
        // Pass through to purchasing function. Will throw on failed or
        // successful ICO
        proxyPurchase(msg.sender);
    }

//
// Getters
//

    // ICO fails if aborted or minimum funds are not raised by the end date
    function fundFailed() public view returns (bool)
    {
        return !__abortFuse
            || (now > END_DATE && etherRaised < MIN_CAP);
    }
    
    // Funding succeeds if not aborted, minimum funds are raised before end date
    function fundRaised() public view returns (bool)
    {
        return !fundFailed()
            && etherRaised >= MIN_CAP
            && now > START_DATE;
    }

    // Returns wholesale value in wei
    function wholeSaleValueLeft() public view returns (uint)
    {
        return wholesaleLeft / RATE_WHOLESALE;
    }

    function currentRate()
        public
        view
        returns (uint)
    {
        return
            fundFailed() ? 0 :
            icoSucceeded ? 0 :
            now < START_DATE ? 0 :
            now < START_DATE + 1 days ? RATE_DAY_0 :
            now < START_DATE + 7 days ? RATE_DAY_1 :
            now < START_DATE + 14 days ? RATE_DAY_7 :
            now < START_DATE + 21 days ? RATE_DAY_14 :
            now < START_DATE + 28 days ? RATE_DAY_21 :
            now < END_DATE ? RATE_DAY_28 :
            0;
    }
    
    // Calculates the sale and wholesale portion of tokens for a given value
    // of wei at the time of calling.
    function ethToTokens(uint _wei)
        public
        view
        returns (uint allTokens_, uint wholesaleTokens_)
    {
        // Get wholesale portion of ether and tokens
        uint wsValueLeft = wholeSaleValueLeft();
        uint wholesaleSpend = 
                fundFailed() ? 0 :
                icoSucceeded ? 0 :
                now < START_DATE ? 0 :
                now > END_DATE ? 0 :
                // No wholesale purchse
                _wei < WHOLESALE_THRESHOLD ? 0 :
                // Total wholesale purchase
                _wei < wsValueLeft ?  _wei :
                // over funded for remaining wholesale tokens
                wsValueLeft;
        
        wholesaleTokens_ = wholesaleSpend
                .mul(RATE_WHOLESALE)
                .mul(TOKEN)
                .div(1 ether);

        // Remaining wei used to purchase retail tokens
        _wei = _wei.sub(wholesaleSpend);

        // Get retail rate        
        uint saleRate = currentRate();

        allTokens_ = _wei
                .mul(saleRate)
                .mul(TOKEN)
                .div(1 ether)
                .add(wholesaleTokens_);
    }

//
// ICO functions
//

    // The fundraising can be aborted any time before `finaliseICO()` is called.
    // This will force a fail state and allow refunds to be collected.
    // The owner can abort or anyone else if a successful fund has not been
    // finalised before 7 days after the end date.
    function abort()
        public
        noReentry
        returns (bool)
    {
        require(!icoSucceeded);
        require(msg.sender == owner || now > END_DATE  + 14 days);
        delete __abortFuse;
        Aborted();
        return true;
    }
    
    // General addresses can purchase tokens during funding
    function proxyPurchase(address _addr)
        public
        payable
        noReentry
        returns (bool)
    {
        require(!fundFailed());
        require(!icoSucceeded);
        require(now > START_DATE);
        require(now <= END_DATE);
        require(msg.value > 0);
        
        // Log ether deposit
        Deposit (_addr, msg.value);
        
        // Get ether to token conversion
        uint tokens;
        // Portion of tokens sold at wholesale rate
        uint wholesaleTokens;

        (tokens, wholesaleTokens) = ethToTokens(msg.value);

        // Block any failed token creation
        require(tokens > 0);

        // Prevent over subscribing 
        require(balances[HUT34_RETAIN] - tokens >= RETAINED_TOKENS);

        // Adjust wholesale tokens left for sale
        if (wholesaleTokens != 0) {
            wholesaleLeft = wholesaleLeft.sub(wholesaleTokens);
        }
        
        // transfer tokens from fund wallet
        balances[HUT34_RETAIN] = balances[HUT34_RETAIN].sub(tokens);
        balances[_addr] = balances[_addr].add(tokens);
        Transfer(HUT34_RETAIN, _addr, tokens);

        // Update funds raised
        etherRaised = etherRaised.add(msg.value);

        // Update holder payments
        etherContributed[_addr] = etherContributed[_addr].add(msg.value);

        // Check KYC requirement
        if(etherContributed[_addr] >= KYC_THRESHOLD && !mustKyc[_addr]) {
            mustKyc[_addr] = true;
            Kyc(_addr, true);
        }

        return true;
    }
    
    // Owner can sweep a successful funding to the fundWallet.
    // Can be called repeatedly to recover errant ether which may have been
    // `selfdestructed` to the contract
    // Contract can be aborted up until this returns `true`
    function finalizeICO()
        public
        onlyOwner
        preventReentry()
        returns (bool)
    {
        // Must have reached minimum cap
        require(fundRaised());

        // Set first vesting date (only once as this function can be called again)
        if(!icoSucceeded) {
            nextReleaseDate = now + VESTING_PERIOD;
        }

        // Set success flag;
        icoSucceeded = true;
        
        // Transfer % Developer commission
        uint devCommission = calcCommission();
        Withdrawal(this, COMMISSION_WALLET, devCommission);
        COMMISSION_WALLET.transfer(devCommission);

        // Remaining % to the fund wallet
        Withdrawal(this, HUT34_WALLET, this.balance);
        HUT34_WALLET.transfer(this.balance);
        return true;
    }

    function clearKyc(address[] _addrs)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        uint len = _addrs.length;
        for(uint i; i < len; i++) {
            delete mustKyc[_addrs[i]];
            Kyc(_addrs[i], false);
        }
        return true;
    }

    // Releases vested tokens back to Hut34 wallet
    function releaseVested()
        public
        returns (bool)
    {
        require(now > nextReleaseDate);
        VestingReleased(nextReleaseDate);
        nextReleaseDate = nextReleaseDate.add(VESTING_PERIOD);
        return xfer(HUT34_VEST_ADDR, HUT34_RETAIN, VESTED_TOKENS / 4);
    }

    // Direct refund to caller
    function refund()
        public
        returns (bool)
    {
        address[] memory addrs = new address[](1);
        addrs[0] = msg.sender;
        return refundFor(addrs);
    }
    
    // Bulk refunds can be pushed from a failed ICO
    function refundFor(address[] _addrs)
        public
        preventReentry()
        returns (bool)
    {
        require(fundFailed());
        uint i;
        uint len = _addrs.length;
        uint value;
        uint tokens;
        address addr;
        
        for (i; i < len; i++) {
            addr = _addrs[i];
            value = etherContributed[addr];
            tokens = balances[addr];
            if (tokens > 0) {    
                // Return tokens
                // transfer tokens from fund wallet
                balances[HUT34_RETAIN] = balances[HUT34_RETAIN].add(tokens);
                delete balances[addr];
                Transfer(addr, HUT34_RETAIN, tokens);
            }
    
            if (value > 0) {
                // Refund ether contribution
                delete etherContributed[addr];
                delete mustKyc[addr];
                refunded = refunded.add(value);
                Withdrawal(this, addr, value);
                addr.transfer(value);
            }
        }
        return true;
    }

//
// ERC20 additional and overloaded functions
//

    // Allows a sender to transfer tokens to an array of recipients
    function transferToMany(address[] _addrs, uint[] _amounts)
        public
        noReentry
        returns (bool)
    {
        require(_addrs.length == _amounts.length);
        uint len = _addrs.length;
        for(uint i = 0; i < len; i++) {
            xfer(msg.sender, _addrs[i], _amounts[i]);
        }
        return true;
    }
    
    // Overload to check ICO success and KYC flags.
    function xfer(address _from, address _to, uint _amount)
        internal
        noReentry
        returns (bool)
    {
        require(icoSucceeded);
        require(!mustKyc[_from]);
        super.xfer(_from, _to, _amount);
        return true;
    }

    // Overload to require ICO success
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        // ICO must be successful
        require(icoSucceeded);
        super.approve(_spender, _amount);
        return true;
    }

//
// Contract management functions
//

    // Initiate a change of owner to `_owner`
    function changeOwner(address _owner)
        public
        onlyOwner
        returns (bool)
    {
        ChangeOwnerTo(_owner);
        newOwner = _owner;
        return true;
    }
    
    // Finalise change of ownership to newOwner
    function acceptOwnership()
        public
        returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, msg.sender);
        owner = newOwner;
        delete newOwner;
        return true;
    }

    // This will selfdestruct the contract on the condittion all have been
    // processed.
    function destroy()
        public
        noReentry
        onlyOwner
    {
        require(!__abortFuse);
        require(refunded == (etherRaised - PRESALE_ETH_RAISE));
        // Log burned tokens for complete ledger accounting on archival nodes
        Transfer(HUT34_RETAIN, 0x0, balances[HUT34_RETAIN]);
        Transfer(HUT34_VEST_ADDR, 0x0, VESTED_TOKENS);
        Transfer(PRESOLD_ADDRESS, 0x0, PRESOLD_TOKENS);
        // Garbage collect mapped state
        delete balances[HUT34_RETAIN];
        delete balances[PRESOLD_ADDRESS];
        selfdestruct(owner);
    }
    
    // Owner can salvage ERC20 tokens that may have been sent to the account
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public
        onlyOwner
        preventReentry
        returns (bool) 
    {
        require(ERC20Token(_kAddr).transfer(_to, _amount));
        return true;
    }
    
    // Calculate commission on prefunded and raised ether.
    function calcCommission()
        internal
        view
        returns(uint)
    {
        uint commission = (this.balance + PRESALE_ETH_RAISE) / COMMISSION_DIV;
        // Edge case that prefund causes commission to be greater than balance
        return commission <= this.balance ? commission : this.balance;
    }
}