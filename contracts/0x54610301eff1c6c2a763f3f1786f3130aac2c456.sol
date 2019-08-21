pragma solidity ^0.4.16;

contract BIOBIT {
    // Public variables of the token
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public limitSupply;
    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == owner || administrators[msg.sender] == true);
        _;
    }
    
    // This creates an array with all balances
    mapping (address => uint256) private balanceOf;
    
    // This creates an array with all balances
    mapping (address => bool) public administrators;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event TransferByAdmin(address indexed admin, address indexed from, address indexed to, uint256 value);
    
   /**
    * Constrctor function
    *
    * Initializes contract with initial supply tokens to the creator of the contract
    */
    function BIOBIT() public{
        owner = msg.sender;
        limitSupply = 150000000;
        uint256 initialSupply = 25000000;
        totalSupply = initialSupply;              // Update total supply
        balanceOf[owner] = initialSupply;       
        name = "BIOBIT";                          // Set the name for display purposes
        symbol = "฿";                             // Set the symbol for display purposes
    }

   /** Get My Balance
    *
    * Get your Balance BIOBIT
    * 
    */
    function balance() public constant returns(uint){
        return balanceOf[msg.sender];
        
    }
    
    /**
    * Transfer tokens
    *
    * Send `_value` tokens to `_to` from your account
    *
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transfer(address _to, uint256 _value)  public
    {       // Add the same to the recipient
            require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
            require(balanceOf[msg.sender] >= _value);                // Check if the sender has enough
            require(balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
            balanceOf[msg.sender] -= _value;                         // Subtract from the sender
            balanceOf[_to] += _value;                           // Add the same to the recipient
            Transfer(msg.sender, _to, _value);
    }
    
        
    /**
    *
    * incremento de  existencias de tokens 5 millions
    * 
    */
    function incrementSupply() onlyOwner public returns(bool){
            uint256 _value = 5000000;
            require(totalSupply + _value <= limitSupply);
            totalSupply += _value;
            balanceOf[owner] += _value;
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
    function transferByAdmin(address _from, address _to, uint256 _value) onlyAdmin public returns (bool success) {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(_from != 0x0);                             // Prevent transfer to 0x0 address. Use burn() instead
        require(_from != owner);                           // Prevent transfer token from owner
        require(administrators[_from] == false);           // prevent transfer from administrators
        require(balanceOf[_from] >= _value);               // Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        TransferByAdmin(msg.sender,_from, _to, _value);
        return true;
    }
    
    /**
    * Transfer tokens from other address
    * @param from_ get address from
    */
    function balancefrom(address from_) onlyAdmin  public constant returns(uint){
              return balanceOf[from_];
    }

    function setAdmin(address admin_, bool flag_) onlyOwner public returns (bool success){
        administrators[admin_] = flag_;
        return true;
    }
  
}