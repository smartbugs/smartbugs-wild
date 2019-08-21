pragma solidity ^0.4.18;

contract SendToMany
{
    address[] public recipients;
    
    function SendToMany(address[] _recipients) public
    {
        recipients = _recipients;
    }
    
    function() payable public
    {
        uint256 amountOfRecipients = recipients.length;
        for (uint256 i=0; i<amountOfRecipients; i++)
        {
            recipients[i].transfer(msg.value / amountOfRecipients);
        }
    }
}