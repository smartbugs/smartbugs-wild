contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract LedgerSplitSingle {
    // Fork oracle to use
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    // Splits the funds on a single chain
    function split(bool forked, address target) returns(bool) {
        if (amIOnTheFork.forked() && forked && target.send(msg.value)) {
            return true;
        } 
        else
        if (!amIOnTheFork.forked() && !forked && target.send(msg.value)) {
            return true;
        } 
        throw; // don't accept value transfer, otherwise it would be trapped.
    }

    // Reject value transfers.
    function() {
        throw;
    }
}