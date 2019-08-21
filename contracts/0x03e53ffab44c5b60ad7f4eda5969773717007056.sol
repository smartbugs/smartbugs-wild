pragma solidity ^0.4.18;
// expected daily volatility on US equities
// 0.0121 ETH balance implies 1.21% (average annual vol is around 18%, which
// is about 1.1% daily)
// pulled using closing option and equity prices around 4:15 PM EST 
contract useqvolOracle{
    
    address private owner;

    function useqvolOracle() 
        payable 
    {
        owner = msg.sender;
    }
    
    function updateUSeqvol()
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