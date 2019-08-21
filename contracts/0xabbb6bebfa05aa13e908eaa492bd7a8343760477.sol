contract RequiringFunds {
    modifier NeedEth () {
        if (msg.value <= 0 ) throw;
        _
    }
}

contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract ReplaySafeSplit is RequiringFunds {
    //address private constant oracleAddress = 0x8128B12cABc6043d94BD3C4d9B9455077Eb18807;    // testnet
    address private constant oracleAddress = 0x2bd2326c993dfaef84f696526064ff22eba5b362;   // mainnet
    
    // Fork oracle to use
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(oracleAddress);

    // Splits the funds into 2 addresses
    function split(address targetFork, address targetNoFork) NeedEth returns(bool) {
        // The 2 checks are to ensure that users provide BOTH addresses
        // and prevent funds to be sent to 0x0 on one fork or the other.
        if (targetFork == 0) throw;
        if (targetNoFork == 0) throw;

        if (amIOnTheFork.forked()                   // if we are on the fork 
            && targetFork.send(msg.value)) {        // send the ETH to the targetFork address
            return true;
        } else if (!amIOnTheFork.forked()           // if we are NOT on the fork 
            && targetNoFork.send(msg.value)) {      // send the ETH to the targetNoFork address 
            return true;
        }

        throw;                                      // don't accept value transfer, otherwise it would be trapped.
    }

    // Reject value transfers.
    function() {
        throw;
    }
}