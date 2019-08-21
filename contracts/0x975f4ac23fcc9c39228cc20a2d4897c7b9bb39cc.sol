pragma solidity ^0.5.0;
contract Vote {
    event LogVote(address indexed addr);

    function() external {
        emit LogVote(msg.sender);
    }
}