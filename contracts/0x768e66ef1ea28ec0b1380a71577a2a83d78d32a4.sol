pragma solidity ^0.4.18;
// US gross value-weighted daily stock return w/o dividends
// 0.10251 ETH balance implies a 1.0251 gross return, 2.51% net return
// pulled using closing prices around 4:15 PM EST 
contract useqgretOracle{
    
    address private owner;

    function useqgretOracle() 
        payable 
    {
        owner = msg.sender;
    }
    
    function updateUSeqgret() 
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