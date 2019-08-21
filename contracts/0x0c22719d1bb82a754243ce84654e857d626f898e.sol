pragma solidity ^0.4.22;

contract Owned {
    
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract CONUNToken2 is Owned {

    struct Lock {
        bool state; // whether locked or not
        uint until; // lock until in timestamp
                    // 0 will be unlocked manually(if unlocked by owner)
                    // > 0 will be unlocked automatically(if expired)
    }

    mapping(address => Lock) public locks;

    // This notifies clients about the address locked until or unlocked.
    event Locked(address target, bool state, uint until);

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

     // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt.
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
		uint256 initialSupply,
        string tokenName,
        string tokenSymbol
	) Owned() public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }
    
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Unlock account if its lock is expired.
        if (locks[msg.sender].state && locks[msg.sender].until > 0 && now > locks[msg.sender].until) {
            locks[msg.sender] = Lock(false, 0);
        }
        if (msg.sender != owner) {
            // Check if the contract is unlocked
            require(!locks[owner].state);
        }
        // Check if the account is unlocked.
        require(!locks[msg.sender].state);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		// This should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value The amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other account
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Transfer tokens and lock recipient
     *
     * Send `_value` tokens to `_to` from your account and lock `_to` until `_until`
     *
     * @param _to The address of the recipient
     * @param _value The amount to send
     */
    function transferAndLock(address _to, uint256 _value, uint _until) public returns (bool success) {
        return transfer(_to, _value) && lock(_to, true, _until);
    }
    
    /**
     * Set allowance for other address
     *
     * Allow `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value The max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allow `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value The max amount they can spend
     * @param _extraData Some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Internal burn, only can be called by this contract
     */
    function _burn(address _from, uint256 _value) internal {
        balanceOf[_from] -= _value; // Subtract from
        totalSupply -= _value; // Update totalSupply
    }
    
    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value The amount of money to burn
     */
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[msg.sender] >= _value); // Check if the sender has enough
        _burn(msg.sender, _value);
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from The address of the sender
     * @param _value The amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value); // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        allowance[_from][msg.sender] -= _value; // Subtract from the sender's allowance
        _burn(_from, _value);
        emit Burn(_from, _value);
        return true;
    }
    
    /**
     * Lock or unlock account
     *
     * Set `_target`'s account to `_state` until `_until`.
     *
     * @param _target The address of the target
     * @param _state Whether the account is locked or not
     * @param _until Lock until in timestamp
     */
    function lock(address _target, bool _state, uint _until) onlyOwner public returns (bool success) {
        locks[_target] = Lock(_state, _until);
        emit Locked(_target, _state, _until);
        return true;
    }
}