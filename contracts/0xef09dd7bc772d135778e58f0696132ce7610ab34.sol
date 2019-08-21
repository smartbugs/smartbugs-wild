pragma solidity ^0.4.25;

contract Voting{
    address owner;
    event Voting(uint256 videoNum, uint256 totalVoting);
    event ChangeOwner(address owner);
    
    mapping (uint256=>uint256) totalVoting;
    
    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function changeOwner(address _owner) onlyOwner returns(bool){
        owner = _owner;
        emit ChangeOwner(_owner);
        return true;
    }
    
    function likeVoting(uint256 videoNum) onlyOwner returns(bool){
        totalVoting[videoNum] = totalVoting[videoNum] + 1;
        emit Voting(videoNum, totalVoting[videoNum]);
        return true;
    }

    function starVoting(uint256 videoNum, uint8 star) onlyOwner returns(bool) {
        if(star > 0 && star < 6){
            totalVoting[videoNum] = totalVoting[videoNum] + star;
            emit Voting(videoNum, totalVoting[videoNum]);
            return true;
        }else{
            return false;
        }
    }

    function voteVoting(uint256[] videoNum, uint256[] count) onlyOwner returns(bool){
        for(uint i=0; i< videoNum.length; i++){
            totalVoting[videoNum[i]] = totalVoting[videoNum[i]] + (3 * count[i]);
            emit Voting(videoNum[i], totalVoting[videoNum[i]]);
        }
        return true;
    }
    
    function getVotingData(uint256 videoNum) returns(uint256){
        return totalVoting[videoNum];
    }
}