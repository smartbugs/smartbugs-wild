// +----------------------------------------------------------------------
// | Copyright (c) 2019 OFEX Token (OFT)
// +----------------------------------------------------------------------
// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
// +----------------------------------------------------------------------
// | TECHNICAL SUPPORT: HAO MA STUDIO
// +----------------------------------------------------------------------

pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public { owner = msg.sender; }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals = 18;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // Event which is triggered to log all transfers to this contract's event log
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Event which is triggered whenever an owner approves a new allowance for a spender.
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Initialization Construction
     */
    function TokenERC20(uint256 _initialSupply, string _tokenName, string _tokenSymbol) public {
        totalSupply = _initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                     // Give the creator all initial tokens
        name = _tokenName;                                       // Set the name for display purposes
        symbol = _tokenSymbol;                                   // Set the symbol for display purposes
    }

    /**
     * Internal Realization of Token Transaction Transfer
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                                            // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);                            // Check if the sender has enough    
        require(balanceOf[_to] + _value > balanceOf[_to]);              // Check for overflows

        uint previousBalances = balanceOf[_from] + balanceOf[_to];      // Save this for an assertion in the future
        balanceOf[_from] -= _value;                                     // Subtract from the sender
        balanceOf[_to] += _value;                                       // Add the same to the recipient
        Transfer(_from, _to, _value);                                   // Notify anyone listening that this transfer took place

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // Use assert to check code logic
    }

    /**
     * Transfer tokens
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to     The address of the recipient
     * @param _value  The amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from   The address of the sender
     * @param _to     The address of the recipient
     * @param _value  The amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender  The address authorized to spend
     * @param _value    The max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender    The address authorized to spend
     * @param _value      The max amount they can spend
     * @param _extraData  Some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value  The amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from   The address of the sender
     * @param _value  The amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}