pragma solidity ^0.4.25;

contract Timestamper {
    address private owner; 
    event Timestamp(bytes32 sha256);

    constructor() public {
        owner = msg.sender;
    }
    function dotimestamp(bytes32 _sha256) public {
        require(owner==msg.sender);
        emit Timestamp(_sha256);
    }
}