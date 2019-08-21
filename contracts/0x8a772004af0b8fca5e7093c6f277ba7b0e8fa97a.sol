contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function sendApproval(address _from, uint256 _value, address _token); }

contract MyToken is owned { 
    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
	uint8 public disableconstruction;
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyTokenLoad(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol, address centralMinter) {
		if(disableconstruction != 2){
            if(centralMinter != 0 ) owner = msg.sender;         // Sets the minter
            balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens                    
            name = tokenName;                                   // Set the name for display purposes     
            symbol = tokenSymbol;                               // Set the symbol for display purposes    
            decimals = decimalUnits;                            // Amount of decimals for display purposes        
		}
    }
    function MyToken(){
        MyTokenLoad(10000000000000,'Kraze',8,'KRZ',0);
		disableconstruction=2;
    }
    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough   
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient            
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}