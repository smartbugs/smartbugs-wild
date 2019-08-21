contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract ReplaySafeSend {
    // Fork oracle to use
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    function safeSend(address etcAddress) returns(bool) {
        if (!amIOnTheFork.forked() && etcAddress.send(msg.value)) {
            return true;
        }
        throw; // don't accept value transfer, otherwise it would be trapped.
    }

    // Reject value transfers.
    function() {
        throw;
    }
}