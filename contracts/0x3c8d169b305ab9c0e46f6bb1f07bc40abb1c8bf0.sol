contract owned {
    address public owner;

    function owned() public {
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

contract Shaycoin is owned {
    // Public variables of the token
    string public name;
    string public symbol;
    uint256 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
    uint256 public donations = 0;

    uint256 public price = 200000000000000;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (uint256 => address) public depositIndex;
    mapping (address => bool) public depositBool;
    uint256 public indexTracker = 0;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the contract
     */
    function Shaycoin(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** decimals;  // Update total supply with the decimal amount
        balanceOf[this] = totalSupply;                // Give the contract all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        if (_to != address(this) && !depositBool[_to]) {
           depositIndex[indexTracker] = _to;
           depositBool[_to] = true;
           indexTracker += 1;
        }
        Transfer(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint256 amount = 10 ** decimals * msg.value / price;               // calculates the amount
        if (amount > balanceOf[this]) {
            totalSupply += amount - balanceOf[this];
            balanceOf[this] = amount;
        }
        _transfer(this, msg.sender, amount);                                        // makes the transfers       
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(this.balance >= amount * price / 10 ** decimals);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);                                    // makes the transfers
        msg.sender.transfer(amount * price / 10 ** decimals);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }

    function donate() payable public {
        donations += msg.value;
    }

    function collectDonations() onlyOwner public {
        owner.transfer(donations);
        donations = 0;
    }

    /* Function to recover the funds on the contract */
    function killAndRefund() onlyOwner public {
        for (uint256 i = 0; i < indexTracker; i++) {
            depositIndex[i].transfer(balanceOf[depositIndex[i]] * price / 10 ** decimals);
        }
        selfdestruct(owner);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

 }