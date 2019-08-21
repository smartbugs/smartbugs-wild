pragma solidity ^0.4.19;

contract EXPERIMENTAL_ETH_AUCTION
{
    uint public PrizeFund;
    
    uint public MaxOffer = 0;
    
    uint public EndTime= now + 14 days;
    
    uint public SelfDestructTime = now + 16 days;
    
    mapping(address=>uint) public Bids;
    
    address creator = msg.sender;
    
    function ContributionToPrizeFund()
    public
    payable
    {
        PrizeFund+=msg.value;
    }
    
    function() 
    public
    payable
    {
        if(msg.value>0)
        {
            ContributionToPrizeFund();
        }
    }
    
    function SendBid()
    public
    payable
    {
        require(now<EndTime);
        
        Bids[msg.sender]+=msg.value;
        
        if(Bids[msg.sender]>MaxOffer)
        {
            MaxOffer=Bids[msg.sender];
        }
    }
    
    function GetPrizeFund()
    public
    payable
    {
        require(now>EndTime);
        require(Bids[msg.sender]>=MaxOffer);
        
        uint prizeAmount = Bids[msg.sender]+PrizeFund;
        PrizeFund = 0;
        Bids[msg.sender]=0;
        
        msg.sender.call.value(prizeAmount);
    }
    
    function RevokeBid()
    public
    payable
    {
        require(now>EndTime);
        
        uint toTransfer = Bids[msg.sender];
        Bids[msg.sender]=0;
        msg.sender.call.value(toTransfer);
    }
   
    function kill()
    public
    {
        require(msg.sender==creator);
        require(now>SelfDestructTime);
        
        selfdestruct(msg.sender);
    }
   
}