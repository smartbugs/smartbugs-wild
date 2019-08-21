pragma solidity ^0.4.2;

contract RemiCoin {
    //Common information about coin
    string public name;
    string public symbol;
    uint8  public decimal;
    uint256 public totalSupply;
    
    //Balance property which should be always associate with an address
    mapping (address => uint256) public balanceOf;
    
    //These generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //Construtor for initial supply (The address who deployed the contract will get it) and important information
    function RemiCoin(uint256 initial_supply, string _name, string _symbol, uint8 _decimal) {
        balanceOf[msg.sender] = initial_supply;
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = initial_supply;
    }
    
    //Function for transer the coin from one address to another
    function transfer(address to, uint value) {
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
}