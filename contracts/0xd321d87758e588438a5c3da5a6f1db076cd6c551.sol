pragma solidity ^0.4.25;


contract VIC {
    event CardsAdded(
        address indexed user,
        uint160 indexed root,
        uint32 count
    );
    
    event CardCompromised(
        address indexed user,
        uint160 indexed root,
        uint32 index
    );
    
    function publish(uint160 root, uint32 count) public {
        _publish(msg.sender, root, count);
    }
    
    function publishBySignature(address user, uint160 root, uint32 count, bytes32 r, bytes32 s, uint8 v) public {
        bytes32 messageHash = keccak256(abi.encodePacked(root, count));
        require(user == ecrecover(messageHash, 27 + v, r, s), "Invalid signature");
        _publish(user, root, count);
    }
    
    function report(uint160 root, uint32 index) public {
        _report(msg.sender, root, index);
    }
    
    function reportBySignature(address user, uint160 root, uint32 index, bytes32 r, bytes32 s, uint8 v) public {
        bytes32 messageHash = keccak256(abi.encodePacked(root, index));
        require(user == ecrecover(messageHash, 27 + v, r, s), "Invalid signature");
        _report(user, root, index);
    }
    
    function _publish(address user, uint160 root, uint32 count) public {
        emit CardsAdded(user, root, count);
    }
    
    function _report(address user, uint160 root, uint32 index) public {
        emit CardCompromised(user, root, index);
    }
}