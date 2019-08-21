pragma solidity ^0.4.20;

contract gift_for_friend
{
    address sender;
    
    address reciver;
    
    bool closed = false;
    
    uint unlockTime;
 
    function SetGiftFor(address _reciver)
    public
    payable
    {
        if( (!closed&&(msg.value > 3 ether)) || sender==0x0 )
        {
            sender = msg.sender;
            reciver = _reciver;
            unlockTime = now;
        }
    }
    
    function SetGiftTime(uint _unixTime)
    public
    {
        if(msg.sender==sender&&now>unlockTime)
        {
            unlockTime = _unixTime;
        }
    }
    
    function GetGift()
    public
    payable
    {
        if(reciver==msg.sender&&now>unlockTime)
        {
            selfdestruct(msg.sender);
        }
    }
    
    function CloseGift()
    public
    {
        if(sender == msg.sender && reciver != 0x0 )
        {
           closed=true;
        }
    }
    
    function() public payable{}
}