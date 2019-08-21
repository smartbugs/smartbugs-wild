pragma solidity ^0.4.18;
// US value-weighted stock index w/o dividends
// 0.056710, given prior day value of 0.056300, implies a 0.73% net return
// pulled using closing prices around 4:15 PM EST 

contract useqIndexOracle{
    
    address private owner;

    function useqIndexOracle() 
        payable 
    {
        owner = msg.sender;
    }
    
    function updateUSeqIndex() 
        payable 
        onlyOwner 
    {
        owner.transfer(this.balance-msg.value);
    }
    
    modifier 
        onlyOwner 
    {
        require(msg.sender == owner);
        _;
    }

}