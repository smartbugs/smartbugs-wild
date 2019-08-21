pragma solidity 0.4.19;

contract Admin {

    address public owner;
    mapping(address => bool) public AdminList;
    
    function Test() public returns (uint256 _balance) {
            
        address sender = msg.sender;
        return sender.balance;
        
    }
    
      function TestX() public {
         
         owner = msg.sender;
        
    }
    
}