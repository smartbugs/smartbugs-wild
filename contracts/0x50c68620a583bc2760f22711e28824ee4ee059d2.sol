pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract ERC20Interface {
      // Get the total token supply
      function totalSupply() constant returns (uint256 _totalSupply);
   
     // Get the account balance of another account with address _owner
     function balanceOf(address _owner) constant returns (uint256 balance);
  
     // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
  
    // Send _value amount of tokens from address _from to address _to
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     // this function is required for some DEX functionality
     function approve(address _spender, uint256 _value) returns (bool success);
  
     // Returns the amount which _spender is still allowed to withdraw from _owner
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  
     // Triggered when tokens are transferred.
     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     // Triggered whenever approve(address _spender, uint256 _value) is called.
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TokenERC20 is Owned,ERC20Interface {
    using SafeMath for uint256;

    // Public variables of the token
    string public name = "BITFINCOIN";
    string public symbol = "BIC";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = 0;
    uint256 public totalSold;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    event ContractFrozen(bool status);

    // defaults, 1 ether = 500 tokens
    uint256 public rate = 125;
    
    // true if contract is block for transaction
    bool public isContractFrozen = false;

    // minimal ether value that this contact accept
    // default 0.0001Ether = 0.0001 * 10^18 wei
    uint256 public minAcceptEther = 100000000000000; // 0.0001 ether = 10^14 wei
    
    function TokenERC20() public {
        //name = "Bitfincoin";
        //symbol = "BIC";
        //decimals = 18;
        //totalSupply = 39000000000000000000000000; // 39M * 10^18
        //totalSold = 0;
        //rate = 125;
        //minAcceptEther = 100000000000000; // 0.0001 ether = 10^14 wei

        // grant all totalSupply tokens to owner
        //balanceOf[msg.sender] = totalSupply;
    }

    function createTokens() internal {
        require(msg.value >= minAcceptEther);
        require(totalSupply > 0);

        // send back tokens to sender balance base on rate
        uint256 tokens = msg.value.mul(rate);
        require(tokens <= totalSupply);

        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokens);
        balanceOf[owner] = balanceOf[owner].sub(tokens);

        totalSupply = totalSupply.sub(tokens);
        totalSold = totalSold.add(tokens);
        // send ether to owner address
        owner.transfer(msg.value);
        Transfer(owner, msg.sender, tokens);
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check if contract is frozen
        require(!isContractFrozen);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowance[msg.sender][_spender] == 0));

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Get allowance
     */
    function allowance(address _from, address _to) public constant returns (uint256) {
        return allowance[_from][_to];
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }

    /** Set contract frozen status */
    function setContractFrozen(bool status) onlyOwner public {
        isContractFrozen = status;
        ContractFrozen(status);
    }

    /** Get account balance (number of tokens the account hold)*/
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOf[_owner];
    }

    /**  Get the total token supply */
    function totalSupply() public constant returns (uint256 _totalSupply) {
        return totalSupply;
    }

    /** Set token name */
    function setName(string _name) onlyOwner public {
        name = _name;
    }

    /** Set token symbol */
    function setSymbol(string _symbol) onlyOwner public {
        symbol = _symbol;
    }

    /** Set token rate */
    function setRate(uint256 _rate) onlyOwner public {
        rate = _rate;
    }
    
    /** Set minimum accept ether */
    function setMinAcceptEther(uint256 _acceptEther) onlyOwner public {
        minAcceptEther = _acceptEther;
    }

    /** Set total supply */
    function setTotalSupply(uint256 _totalSupply) onlyOwner public {
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
        Transfer(0, this, totalSupply);
        Transfer(this, owner, totalSupply);
    }

    /** Transfer ownership and transfer account balance */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        require(owner != newOwner);
        balanceOf[newOwner] = balanceOf[newOwner].add(balanceOf[owner]);
        Transfer(owner, newOwner, balanceOf[owner]);
        balanceOf[owner] = 0;
        owner = newOwner;
    }
}

contract BICToken is TokenERC20 {

	bool public isOpenForSale = false;

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /**
     * Fallback funtion will be call when someone send ether to this contract
     */
    function () public payable {
		require(isOpenForSale);
        require(!isContractFrozen);
        createTokens();
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function BICToken() TokenERC20() public {
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);               // Check if the sender has enough
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        require(!isContractFrozen);                         // Check if contract is frozen
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        uint256 amount = mintedAmount * 10 ** uint256(decimals);
        balanceOf[target] = balanceOf[target].add(amount);
        totalSupply = totalSupply.add(amount);
        Transfer(0, this, amount);
        Transfer(this, target, amount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

	/// @notice Sets openned for sale status
	function setOpenForSale(bool status) onlyOwner public {
		isOpenForSale = status;
	}
}