pragma solidity ^0.4.0;
contract TestContract {
    string name;
    function getName() public constant returns (string){
        return name;
    }
    function setName(string newName) public {
        name = newName;
    }
}