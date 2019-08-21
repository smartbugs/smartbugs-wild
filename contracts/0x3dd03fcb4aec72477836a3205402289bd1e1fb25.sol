pragma solidity ^0.5.2;
contract Hoouusch {
   address owner;
   mapping(address => uint256) balances;
   constructor() public {
        owner = msg.sender;
    }
    
    
function () payable external {
    balances[msg.sender] += msg.value;
}  
  function withdraw(address payable receiver, uint256 amount) public {
      require(owner == msg.sender);
        receiver.transfer(amount);
        }    
  
    function transferOwnership(address newOwner) public  {
    require(owner == msg.sender);
    owner = newOwner;
  }
  
}