pragma solidity 0.4.19;

contract DocumentStore {

    event Store(bytes32 indexed document, bytes32 indexed party1, bytes32 indexed party2);

    function store(bytes32 document, bytes32 party1, bytes32 party2) public {
        Store(document, party1, party2);
    }
}