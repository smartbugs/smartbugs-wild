pragma solidity ^0.4.13;

// Record the thumbs up for EtherShare
contract EtherShareLike {

    address public link = 0xc86bdf9661c62646194ef29b1b8f5fe226e8c97e;  

    mapping(uint => mapping(uint => uint)) public allLike;

    function like(uint ShareID, uint ReplyID) public {
        allLike[ShareID][ReplyID]++;
    }
}