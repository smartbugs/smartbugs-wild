pragma solidity ^0.5.0;

contract Wallet {
    bytes32 keyHash;

    constructor(bytes32 _keyHash) public payable {
        keyHash = _keyHash;
    }
    
    function withdraw(bytes memory key) public payable {
        uint256 balanceBeforeMsg = address(this).balance - msg.value;
        require(msg.value >= balanceBeforeMsg * 2, "balance required");
        require(sha256(key) == keyHash, "invalid key");
        selfdestruct(msg.sender);
    }   
}