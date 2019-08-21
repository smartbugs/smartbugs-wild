pragma solidity ^0.4.18;

contract Registra1000 {

   struct Arquivo {
       bytes shacode;
   }

   bytes[] arquivos;
   
   function Registra() public {
       arquivos.length = 1;
   }

   function setArquivo(bytes shacode) public {
       arquivos.push(shacode);
   }
   
 
}