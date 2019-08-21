pragma solidity ^0.4.13;

contract BusinessCardAM {
    
    mapping (bytes32 => string) variables;
    
    function setVar(string key, string value) {
        variables[sha3(key)] = value;
    }
    
    function getVar(string key) constant returns(string) {
        return variables[sha3(key)];
    }
}