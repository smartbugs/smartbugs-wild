pragma solidity ^0.4.13;
 
contract s_Form001 {
    
    mapping (bytes32 => string) data;
    
    address owner;
    
    function s_Form001() {
        owner = msg.sender;

    }
    
    function setData(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }
    
    function getData(string key) constant returns(string) {
        return data[sha3(key)];
    }

/*
0x1aB8991D086831556b5846760F527B0b0b4F4aF5
*/
}