pragma solidity ^0.4.16;

contract owned {
    address public owner;
    function owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
}

contract GOG is owned {
    // Public variables of the GOG token
    string public name;
    string public symbol;
    uint8 public decimals = 6;
    // 6 decimals for GOG
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balances;
    // this creates an 2 x 2 array with allowances
    mapping (address => mapping (address => uint256)) public allowance;
    // This creates an array with all frozenFunds
    mapping (address => uint256) public frozenFunds;
    // This generates a public event on the blockchain that will notify clients freezing of funds
    event FrozenFunds(address target, uint256 funds);
        // This generates a public event on the blockchain that will notify clients unfreezing of funds
    event UnFrozenFunds(address target, uint256 funds);
    // This generates a public event on the blockchain that will notify clients transfering of funds
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    // This notifies clients about approval of allowances
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * Constrctor function
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function GOG() public {
        totalSupply = 10000000000000000;               // GOG's total supply is 10 billion with 6 decimals
        balances[msg.sender] = totalSupply;          // Give the creator all initial tokens
        name = "GoGlobe Token";                       // Token name is GoGlobe Token
        symbol = "GOG";                               // token symbol is GOG
    }

    /**
     * Freeze funds on account
     * @param _target The account will be freezed
     * @param _funds The amount of funds will be freezed
     */
    function freezeAccount(address _target, uint256 _funds) public onlyOwner {
        if (_funds == 0x0)
            frozenFunds[_target] = balances[_target];
        else
            frozenFunds[_target] = _funds;
        FrozenFunds(_target, _funds);
    }

    /**
     * unfreeze funds on account
     * @param _target The account will be unfreezed
     * @param _funds The amount of funds will be unfreezed
     */
    function unFreezeAccount(address _target, uint256 _funds) public onlyOwner {
        require(_funds > 0x0);
        uint256 temp = frozenFunds[_target];
        temp = temp < _funds ? 0x0 : temp - _funds;
        frozenFunds[_target] = temp;
        UnFrozenFunds(_target, _funds);
    }

    /**
     * get the balance of account
     * @param _owner The account address
     */
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    /**
     * get the frozen balance of account
     * @param _owner The account address
     */
    function frozenFundsOf(address _owner) constant public returns (uint256) {
        return frozenFunds[_owner];
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowance to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still avaible for the spender.
     */
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowance[_owner][_spender];
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);

        // Check if the sender has enough
        require(balances[_from] > frozenFunds[_from]);
        require((balances[_from] - frozenFunds[_from]) >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     * Send `_value` tokens to `_to` from your account
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     * Send `_value` tokens to `_to` on behalf of `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Destroy tokens
     * Remove `_value` tokens from the system irreversibly
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}