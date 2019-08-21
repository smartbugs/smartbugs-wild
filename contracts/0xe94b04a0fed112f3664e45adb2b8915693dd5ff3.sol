contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract ReplaySafeSplit {
    // Fork oracle to use
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    event e(address a);
	
    // Splits the funds into 2 addresses
    function split(address targetFork, address targetNoFork) returns(bool) {
        if (amIOnTheFork.forked() && targetFork.send(msg.value)) {
			e(targetFork);
            return true;
        } else if (!amIOnTheFork.forked() && targetNoFork.send(msg.value)) {
			e(targetNoFork);		
            return true;
        }
        throw; // don't accept value transfer, otherwise it would be trapped.
    }

    // Reject value transfers.
    function() {
        throw;
    }
}