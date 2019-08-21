pragma solidity ^0.4.13;
 
contract s_Form003 {
    
    mapping (bytes32 => string) data;
    
    address owner;
    
    function s_Form003() {
        owner = msg.sender;

    }
    
    function setDataColla_001_001(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }
    
    function getDataColla_001_001(string key) constant returns(string) {
        return data[sha3(key)];
    }



    function setDataColla_001_002(string key, string value) {
        require(msg.sender == owner);
        data[sha3(key)] = value;
    }
    
    function getDataColla_001_002(string key) constant returns(string) {
        return data[sha3(key)];
    }


/*
0x1FeCdc11d045Cfe5a564610C23120EBE35852Cb3
*/
}