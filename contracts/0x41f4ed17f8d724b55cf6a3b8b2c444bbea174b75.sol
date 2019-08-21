pragma solidity >=0.4.22 <0.6.0;
contract LauWarmContract {
    // Deployed As 0x41f4ed17f8d724b55cf6a3b8b2c444bbea174b75
    address public owner;
    mapping (address => bool) public allowed;
    mapping (address => address) public account;
    
    constructor () public {
      owner=msg.sender;
    }
	
	modifier isOwner() {
    if (msg.sender != owner) {
        emit NotOwner(msg.sender);
        return;
    }
    _; 
    }
    event NotOwner(address sender);
    event Error(address sender, address from, address to, uint amount, string mac);
    event Process(address sender, address from, address to, uint amount, string mac);
    
    function allow(address operator,address walletAddr) public isOwner{
        allowed[operator]=true;
	    account[operator]=walletAddr;
    }

    function disallow(address operator) public isOwner{
        allowed[operator]=false;
    }

    function process(address to,uint amount, string memory mac) public {
     if( allowed[msg.sender] != true )  {
      emit Error(msg.sender,account[msg.sender],to,amount,mac);
      return ;
     }
     emit Process(msg.sender,account[msg.sender],to,amount,mac);
     return ;
    }
    
   
}