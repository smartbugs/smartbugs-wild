pragma solidity ^0.4.0;

contract Presale {
   struct PresaleEntry {
        address ethID;
        string email;
        string bitcoinSRC;
        string bitcoinDEST;
        uint satoshis;
        uint centiWRG;
    }
  
   PresaleEntry [] public entries ;
   address public master; // master address
   uint public presaleAmount;
   bool public presaleGoing;
   
   event presaleMade(string sender, uint satoshis);

    /* Initializes contract with initial supply tokens to the creator of the contract */

    function Presale() {
     master = msg.sender;
     presaleAmount = 23970000 * 100; // 6 030 000 was sold to first investors
     presaleGoing = true;
    }

    /* Very simple trade function */

    function makePresale(string mail, address adr, uint satoshis, uint centiWRG,string bitcoinSRC, string bitcoinDEST) returns(bool sufficient) {
        PresaleEntry memory entry;
        int expectedWRG = int(presaleAmount) - int(centiWRG);
        
        if (!presaleGoing) return;
        
        if (msg.sender != master) return false; 
        if (expectedWRG < 0) return false;
        
        presaleAmount -= centiWRG;
        entry.ethID = adr;
        entry.email = mail;
        entry.satoshis = satoshis;
        entry.centiWRG = centiWRG;
        entry.bitcoinSRC = bitcoinSRC;
        entry.bitcoinDEST = bitcoinDEST;
        
        entries.push(entry);
        
        return true;
     }
     
     function stopPresale() returns (bool ok) {
          if (msg.sender != master) return false; 
          presaleGoing = false;
          return true;
     }
     
     function getAmountLeft() returns (uint amount){
         return presaleAmount;
     }
     
     function getPresaleNumber() returns (uint length){
         return entries.length;
     }
    
     function getPresale(uint i) returns (string,address,uint,uint,string,string){
         uint max = entries.length;
         if (i >= max) {
             return ("NotFound",0,0,0,"","");
         }
         return (entries[i].email,entries[i].ethID, entries[i].satoshis, entries[i].centiWRG,entries[i].bitcoinSRC,entries[i].bitcoinDEST);
     }

}