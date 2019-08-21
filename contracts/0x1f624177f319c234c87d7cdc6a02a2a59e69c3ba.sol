pragma solidity ^0.4.19;


contract Owned
{
    address public owner;

    modifier onlyOwner
	{
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner()
	{
        owner = newOwner;
    }
}

contract EIP20Interface {
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
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20 is EIP20Interface {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

     function EIP20(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract Gabicoin is Owned, EIP20
{
    // Struct for ico minting.
    struct IcoBalance
    {
        bool hasTransformed;// Has transformed ico balances to real balance for this user?
        uint[3] balances;// Balances.
    }

    // Mint event.
    event Mint(address indexed to, uint value, uint phaseNumber);

    // Activate event.
    event Activate();

    // Constructor.
    function Gabicoin() EIP20(0, "Gabicoin", 2, "GCO") public
    {
        owner = msg.sender;
    }

    // Mint function for ICO.
    function mint(address to, uint value, uint phase) onlyOwner() external
    {
        require(!isActive);

        icoBalances[to].balances[phase] += value;// Increase ICO balance.

        Mint(to, value, phase);
    }

    // Activation function after successful ICO.
    function activate(bool i0, bool i1, bool i2) onlyOwner() external
    {
        require(!isActive);// Only for not yet activated token.

        activatedPhases[0] = i0;
        activatedPhases[1] = i1;
        activatedPhases[2] = i2;

        Activate();
        
        isActive = true;// Activate token.
    }

    // Transform ico balance to standard balance.
    function transform(address addr) public
    {
        require(isActive);// Only after activation.
        require(!icoBalances[addr].hasTransformed);// Only for not transfromed structs.

        for (uint i = 0; i < 3; i++)
        {
            if (activatedPhases[i])// Check phase activation.
            {
                balances[addr] += icoBalances[addr].balances[i];// Increase balance.
                Transfer(0x00, addr, icoBalances[addr].balances[i]);
                icoBalances[addr].balances[i] = 0;// Set ico balance to zero.
            }
        }

        icoBalances[addr].hasTransformed = true;// Set struct to transformed status.
    }

    // For simple call transform().
    function () payable external
    {
        transform(msg.sender);
        msg.sender.transfer(msg.value);
    }

    // Activated on ICO phases.
    bool[3] public activatedPhases;

    // Token activation status.
    bool public isActive;

    // Ico balances.
    mapping (address => IcoBalance) public icoBalances;
}