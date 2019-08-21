pragma solidity ^0.4.16;
/** @title Ether to the Moon */
contract EtherToTheMoon {
 // Publically visible who is the owner of this contract. Also,
 // this adds get functions for this variable automatically.
 address public owner;
 uint public totalContribution;

 /// Runs only once when the contract is deployed.
 function EtherToTheMoon() public{
   owner = msg.sender;
 }
 modifier onlyOwner() {
   require(msg.sender == owner);
   _;
 }
 struct richData {
   uint amount;
   bytes32 message;
   address sender;
 }
 /* DATABASES */
 // We are creating a publically accessible database for all
 // the bids that we will recieve. We are mapping address of
 // each sender to the value inside it.
 mapping(address => uint) public users;
 richData[10] public richDatabase; // [0] = Richest & [9] = Poorest

 // Function to be called when anyone sends us money. We take the money
 // in wei and add it to his total bid.
 function takeMyMoney(bytes32 message) public payable returns (bool){
   // Add value to his total amount.
   users[msg.sender] += msg.value;
   totalContribution += msg.value;
   if(users[msg.sender] >= users[richDatabase[9].sender] ){
     richData[] memory arr = new richData[](10);
     bool updated = false;
     uint j = 0;
     for (uint i = 0; i < 10; i++) {
       if(j == 10) break;
       if(!updated && users[msg.sender] > richDatabase[i].amount) {
         richData memory newData;
         newData.amount = users[msg.sender];
         newData.message = message;
         newData.sender = msg.sender;
         arr[j] = newData;
         j++;
         if(richDatabase[i].sender != msg.sender) {
          arr[j] = richDatabase[i];
          j++;
         }
         updated = true;
       } else if(richDatabase[i].sender != msg.sender){
         arr[j] = richDatabase[i];
         j++;
       }
     }
     for(i = 0; i < 10; i++) {
         richDatabase[i] = arr[i];
       }
   }
   return updated;
 }
 function buyerHistory() public constant returns (address[], uint[], bytes32[]){

     uint length;
     length = 10;
     address[] memory senders = new address[](length);
     uint[] memory amounts = new uint[](length);
     bytes32[] memory statuses = new bytes32[](length);

     for (uint i = 0; i < length; i++)
     {
         senders[i] = (richDatabase[i].sender);
         amounts[i] = (richDatabase[i].amount);
         statuses[i] = (richDatabase[i].message);
     }
     return (senders, amounts, statuses);
 }
 function withdraw(address _to, uint _amount) onlyOwner external payable{
     require(_amount <= totalContribution);
     totalContribution -= _amount;
     _to.transfer(_amount);
 }
}