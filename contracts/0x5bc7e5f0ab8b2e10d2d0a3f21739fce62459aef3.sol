/*
file:   Hut34ENTRP.sol
ver:    0.1.0
author: Darryl Morris
date:   19-12-2017
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

-------------
Release Notes
-------------
* Reissuence of Hut34 ENT tokens as ENTRP tokens due to post sale offchain
bulk transfer tool bug, and desire to update ticker / symbol.

Dedications
-------------
* With love to Isabella and Molly from your dad
* xx to Edie, Robin, William and Charlotte x
*/

pragma solidity ^0.4.17;

contract Hut34Config
{
    // ERC20 token name
    string  public constant name            = "Hut34 Entropy Token";
    
    // ERC20 trading symbol
    string  public constant symbol          = "ENTRP";

    // ERC20 decimal places
    uint8   public constant decimals        = 18;

    // Total supply (* in unit ENT *)
    uint    public constant TOTAL_TOKENS    = 100000000;

    // Contract owner at time of deployment.
    address public constant OWNER           = 0xdA3780Cff2aE3a59ae16eC1734DEec77a7fd8db2;

    // A Hut34 address to own tokens
    address public constant HUT34_RETAIN    = 0x3135F4acA3C1Ad4758981500f8dB20EbDc5A1caB;
    
    // A Hut34 address to accept raised funds
    address public constant HUT34_WALLET    = 0xA70d04dC4a64960c40CD2ED2CDE36D76CA4EDFaB;
    
    // Percentage of tokens to be vested over 2 years. 20%
    uint    public constant VESTED_PERCENT  = 20;

    // Vesting period
    uint    public constant VESTING_PERIOD  = 26 weeks;

    // Origional Token sale contract with misallocated post token sale whitelist, see https://medium.com/@hut34project/entropy-token-reissuance-f37a8574c05c
    address public constant REPLACES        = 0x9901ed1e649C4a77C7Fff3dFd446ffE3464da747;
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


contract Hut34ENTRPAbstract
{
    /// @dev Logged when new owner accepts ownership
    /// @param _from the old owner address
    /// @param _to the new owner address
    event ChangedOwner(address indexed _from, address indexed _to);
    
    /// @dev Logged when owner initiates a change of ownership
    /// @param _to the new owner address
    event ChangeOwnerTo(address indexed _to);
    
    /// @dev Logged when vested tokens are released back to HUT32_WALLET
    /// @param _releaseDate The official release date (even if released at
    /// later date)
    event VestingReleased(uint _releaseDate);

//
// Constants
//

    // The Hut34 vesting 'psudo-address' for transferring and releasing vested
    // tokens to the Hut34 Wallet. The address is UTF8 encoding of the
    // string and can only be accessed by the 'releaseVested()' function.
    // `0x48757433342056657374696e6700000000000000`
    address public constant HUT34_VEST_ADDR = address(bytes20("Hut34 Vesting"));

//
// State Variables
//

    /// @dev An address permissioned to enact owner restricted functions
    /// @return owner
    address public owner;
    
    /// @dev An address permissioned to take ownership of the contract
    /// @return new owner address
    address public newOwner;

    /// @returns Date of next vesting release
    uint public nextReleaseDate;

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


    /// @notice Make bulk transfer of tokens to many addresses
    /// @param _addrs An array of recipient addresses
    /// @param _amounts An array of amounts to transfer to respective addresses
    /// @return Boolean success value
    function transferToMany(address[] _addrs, uint[] _amounts)
        public returns (bool);

    /// @notice Release vested tokens after a maturity date
    /// @return Boolean success value
    function releaseVested() public returns (bool);

    /// @notice Salvage `_amount` tokens at `_kaddr` and send them to `_to`
    /// @param _kAddr An ERC20 contract address
    /// @param _to and address to send tokens
    /// @param _amount The number of tokens to transfer
    /// @return Boolean success value
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public returns (bool);
}


/*-----------------------------------------------------------------------------\

 Hut34ENTRP implimentation

\*----------------------------------------------------------------------------*/

contract Hut34ENTRP is 
    ERC20Token,
    Hut34ENTRPAbstract,
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
            
//
// Functions
//

    function Hut34ENTRP()
        public
    {
        // Run sanity checks
        require(TOTAL_TOKENS != 0);
        require(OWNER != 0x0);
        require(HUT34_RETAIN != 0x0);
        require(HUT34_WALLET != 0x0);
        require(bytes(name).length != 0);
        require(bytes(symbol).length != 0);

        owner = OWNER;
        totalSupply = TOTAL_TOKENS.mul(TOKEN);

        // Mint the total supply into Hut34 token holding address
        balances[HUT34_RETAIN] = totalSupply;
        Transfer(0x0, HUT34_RETAIN, totalSupply);

        // Transfer vested tokens to vesting account
        xfer(HUT34_RETAIN, HUT34_VEST_ADDR, VESTED_TOKENS);

        // Set first vesting release date
        nextReleaseDate = now.add(VESTING_PERIOD);
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

//
// ERC20 additional and overloaded functions
//

    // Allows a sender to transfer tokens to an array of recipients
    function transferToMany(address[] _addrs, uint[] _amounts)
        public
        returns (bool)
    {
        require(_addrs.length == _amounts.length);
        uint len = _addrs.length;
        for(uint i = 0; i < len; i++) {
            xfer(msg.sender, _addrs[i], _amounts[i]);
        }
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

    // Owner can salvage ERC20 tokens that may have been sent to the account
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public
        onlyOwner
        returns (bool) 
    {
        require(ERC20Token(_kAddr).transfer(_to, _amount));
        return true;
    }
}