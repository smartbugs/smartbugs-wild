pragma solidity ^0.4.19;

contract MyMap {
    address public owner;
    mapping(bytes32=>bytes15) map;

    function MyMap() public {
        owner = msg.sender;
    }
    
    function setValue(bytes32 a, bytes15 b) public {
        if(owner == msg.sender) {
            map[a] = b;
        }
    }
}