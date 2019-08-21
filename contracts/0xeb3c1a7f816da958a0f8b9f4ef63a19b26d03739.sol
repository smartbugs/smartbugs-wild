pragma solidity ^0.4.2;

contract storadge {
    
    event log(string description);
    
	function save(
        string mdhash
    )
    {
        log(mdhash);
    }
}