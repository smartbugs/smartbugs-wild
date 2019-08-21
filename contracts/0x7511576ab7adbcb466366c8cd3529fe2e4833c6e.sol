pragma solidity ^0.5.1;

contract BasicVote {
    
    function vote(bool _option) public{
        if (_option == true) {
            emit VoteCast("missionStatementA");
        } else {
            emit VoteCast("missionStatementB");
        }

    }
    
    event VoteCast(string mission);
}