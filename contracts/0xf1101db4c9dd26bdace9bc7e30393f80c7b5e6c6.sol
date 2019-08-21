contract AmIOnTheFork {
    bool public forked = false;
    address constant darkDAO = 0x304a554a310c7e546dfe434669c62820b7d83490;
    // Check the fork condition during creation of the contract.
    // This function should be called between block 1920000 and 1921200.
    // Approximately between 2016-07-20 12:00:00 UTC and 2016-07-20 17:00:00 UTC.
    // After that the status will be locked in.
    function update() {
        if (block.number >= 1920000 && block.number <= 1921200) {
            forked = darkDAO.balance < 3600000 ether;
        }
    }
    function() {
        throw;
    }
}

contract MyReplaySafeProxy {
    
    address eth_target = 0x447F7556C8D2E5281438358087DdD368B6bCb824; 
    address ethc_target = 0xCd76f273d307551016452724241EA3C1775270a2;

	address public target;
	
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);
    
    function MyReplaySafeProxy () {
			if (amIOnTheFork.forked())
				target =  eth_target;
			else
				target =  ethc_target;
    }

    function() {
        if(!target.send(msg.value))
            throw;
    }
}