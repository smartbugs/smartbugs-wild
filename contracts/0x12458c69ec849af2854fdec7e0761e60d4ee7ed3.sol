pragma solidity ^0.4.11;

contract ConsensysAcademy{
    mapping(address=>bytes32) public names;
    address[] public addresses;
    
    modifier onlyUnique(){
        if(names[msg.sender] == 0){ _; }else{ throw; }
    }
    function register(bytes32 name) onlyUnique{
        names[msg.sender] = name; //32 character limit (first 32 used)
        addresses.push(msg.sender);
    }
    function getAddresses() returns(address[]){ return addresses; }
}