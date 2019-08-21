pragma solidity ^0.4.4;

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

//File: /Users/jbaylina/git/MVP/StandardToken.sol
pragma solidity ^0.4.4;
/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time
        //goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
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
}

//File: /Users/jbaylina/git/MVP/HumanStandardToken.sol
pragma solidity ^0.4.4;

/*
This Token Contract implements the standard token functionality
(https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL
extras intended for use by humans.

In other words. This is intended for deployment in something like a Token
Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these
extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval()
has occurred.

*/



contract HumanStandardToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include
    them.
    They allow one to customise the token contract & in no way influences the
    core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //An arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount; // Give the creator all initial tokens
        totalSupply = _initialAmount;          // Update total supply
        name = _tokenName;                     // Set the name for display purposes
        decimals = _decimalUnits;              // Amount of decimals for display purposes
        symbol = _tokenSymbol;                 // Set the symbol for display purposes
    }
/*
    / * Approves and then calls the receiving contract * /
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be
        //notified. This crafts the function signature manually so one doesn't
        //have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed,
        //otherwise one would use vanilla approve instead.
        if(!_spender.call(
        bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))),
        msg.sender,
        _value,
        this,
        _extraData)) { throw; }
        return true;
    }
*/
}

//File: /Users/jbaylina/git/MVP/CampaignToken.sol
pragma solidity ^0.4.4;



/// @title CampaignToken Contract
/// @author Jordi Baylina
/// @dev This token contract is a clone of ConsenSys's HumanStandardToken with
/// the approveAndCall function omitted; it is ERC 20 compliant.

contract CampaignToken is HumanStandardToken {

/// @dev The tokenController is the address that deployed the CampaignToken, for this
/// token it will be it will be the Campaign Contract

    address public tokenController;

/// @dev The onlyController modifier only allows the tokenController to call the function

    modifier onlyController { if (msg.sender != tokenController) throw; _; }

/// @notice `CampaignToken()` is the function that deploys a new
/// HumanStandardToken with the parameters of 0 initial tokens, the name
/// "CharityDAO Token" the decimal place of the smallest unit being 18, and the
/// call sign being "GIVE". It will set the tokenController to be the contract that
/// calls the function.

    function CampaignToken() HumanStandardToken(0,"CharityDAO Token",18,"GIVE") {
        tokenController = msg.sender;
    }

/// @notice `createTokens()` will create tokens if the campaign has not been
/// sealed.
/// @dev `createTokens()` is called by the campaign contract when
/// someone sends ether to that contract or calls `doPayment()`
/// @param beneficiary The address receiving the tokens
/// @param amount The amount of tokens the address is receiving
/// @return True if tokens are created

    function createTokens(address beneficiary, uint amount
    ) onlyController returns (bool success) {
        if (sealed()) throw;
        balances[beneficiary] += amount;  // Create tokens for the beneficiary
        totalSupply += amount;            // Update total supply
        Transfer(0, beneficiary, amount); // Create an Event for the creation
        return true;
    }

/// @notice `seal()` ends the Campaign by making it impossible to create more
/// tokens.
/// @dev `seal()` changes the tokenController to 0 and therefore can only be called by
/// the tokenCreator contract once
/// @return True if the Campaign is sealed

    function seal() onlyController returns (bool success)  {
        tokenController = 0;
        return true;
    }

/// @notice `sealed()` checks to see if the the Campaign has been sealed
/// @return True if the Campaign has been sealed and can't receive funds

    function sealed() constant returns (bool) {
        return tokenController == 0;
    }
}

//File: /Users/jbaylina/git/MVP/Campaign.sol
pragma solidity ^0.4.4;



/// @title CampaignToken Contract
/// @author Jordi Baylina
/// @dev This is designed to control the ChairtyToken contract.

contract Campaign {

    uint public startFundingTime;       // In UNIX Time Format
    uint public endFundingTime;         // In UNIX Time Format
    uint public maximumFunding;         // In wei
    uint public totalCollected;         // In wei
    CampaignToken public tokenContract;  // The new token for this Campaign
    address public vaultContract;       // The address to hold the funds donated

/// @notice 'Campaign()' initiates the Campaign by setting its funding
/// parameters and creating the deploying the token contract
/// @dev There are several checks to make sure the parameters are acceptable
/// @param _startFundingTime The UNIX time that the Campaign will be able to
/// start receiving funds
/// @param _endFundingTime The UNIX time that the Campaign will stop being able
/// to receive funds
/// @param _maximumFunding In wei, the Maximum amount that the Campaign can
/// receive (currently the max is set at 10,000 ETH for the beta)
/// @param _vaultContract The address that will store the donated funds

    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultContract
    ) {
        if ((_endFundingTime < now) ||                // Cannot start in the past
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||        // The Beta is limited
            (_vaultContract == 0))                    // To prevent burning ETH
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = new CampaignToken (); // Deploys the Token Contract
        vaultContract = _vaultContract;
    }

/// @dev The fallback function is called when ether is sent to the contract, it
/// simply calls `doPayment()` with the address that sent the ether as the
/// `_owner`. Payable is a required solidity modifier for functions to receive
/// ether, without this modifier they will throw

    function ()  payable {
        doPayment(msg.sender);
    }

/// @notice `proxyPayment()` allows the caller to send ether to the Campaign and
/// have the CampaignTokens created in an address of their choosing
/// @param _owner The address that will hold the newly created CampaignTokens

    function proxyPayment(address _owner) payable {
        doPayment(_owner);
    }

/// @dev `doPayment()` is an internal function that sends the ether that this
/// contract receives to the `vaultContract` and creates campaignTokens in the
/// address of the `_owner` assuming the Campaign is still accepting funds
/// @param _owner The address that will hold the newly created CampaignTokens

    function doPayment(address _owner) internal {

// First we check that the Campaign is allowed to receive this donation
        if ((now<startFundingTime) ||
            (now>endFundingTime) ||
            (tokenContract.tokenController() == 0) ||           // Extra check
            (msg.value == 0) ||
            (totalCollected + msg.value > maximumFunding))
        {
            throw;
        }

//Track how much the Campaign has collected
        totalCollected += msg.value;

//Send the ether to the vaultContract
        if (!vaultContract.send(msg.value)) {
            throw;
        }

// Creates an equal amount of CampaignTokens as ether sent. The new CampaignTokens
// are created in the `_owner` address
        if (!tokenContract.createTokens(_owner, msg.value)) {
            throw;
        }

        return;
    }

/// @notice `seal()` ends the Campaign by calling `seal()` in the CampaignToken
/// contract
/// @dev `seal()` can only be called after the end of the funding period.

    function seal() {
        if (now < endFundingTime) throw;
        tokenContract.seal();
    }

}