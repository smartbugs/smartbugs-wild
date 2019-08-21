pragma solidity ^0.4.2;

contract Owner {
    //For storing the owner address
    address public owner;
    //Constructor for assign a address for owner property(It will be address who deploy the contract) 
    function Owner() {
        owner = msg.sender;
    }
    //This is modifier (a special function) which will execute before the function execution on which it applied 
    modifier onlyOwner() {
        if(msg.sender != owner) throw;
        //This statement replace with the code of fucntion on which modifier is applied
        _;
    }
    //Here is the example of modifier this function code replace _; statement of modifier 
    function transferOwnership(address new_owner) onlyOwner {
        owner = new_owner;
    }
}

contract MyToken is Owner {
    //Common information about coin
    string public name;
    string public symbol;
    uint8  public decimal;
    uint256 public totalSupply;
    
    //Balance property which should be always associate with an address
    mapping (address => uint256) public balanceOf;
    //frozenAccount property which should be associate with an address
    mapping (address => bool) public frozenAccount;
    
    //These generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    //Construtor for initial supply (The address who deployed the contract will get it) and important information
    function MyToken(uint256 initial_supply, string _name, string _symbol, uint8 _decimal) {
        balanceOf[msg.sender] = initial_supply;
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = initial_supply;
    }
    
    //Function for transer the coin from one address to another
    function transfer(address to, uint value) {
        //checking account is freeze or not
        if (frozenAccount[msg.sender]) throw;
        //checking the sender should have enough coins
        if(balanceOf[msg.sender] < value) throw;
        //checking for overflows
        if(balanceOf[to] + value < balanceOf[to]) throw;
        
        //substracting the sender balance
        balanceOf[msg.sender] -= value;
        //adding the reciever balance
        balanceOf[to] += value;
        
        // Notify anyone listening that this transfer took place
        Transfer(msg.sender, to, value);
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner{
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        
        Transfer(0,owner,mintedAmount);
        Transfer(owner,target,mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
}