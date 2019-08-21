pragma solidity 0.4.11;

contract contractSKbasic{
    
    string name1 = "Persona 1";
    string name2 = "Persona 2";
    uint date = now;
    
    function setContract(string intervener1, string intervener2){
        date = now;
        name1 = intervener1;
        name2 = intervener2;
    } 
    
    
    function getContractData() constant returns(string, string, uint){
        return (name1, name2, date) ;
    }
    
}