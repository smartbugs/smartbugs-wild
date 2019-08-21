contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract SplitterEtcToEth {

    address intermediate;
    address owner;

    // there is a limit accepted by exchange
    uint256 public upLimit = 400 ether;
    // and exchange costs, ignore small transactions
    uint256 public lowLimit = 0.5 ether;

    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    function SplitterEtcToEth() {
        owner = msg.sender;
    }

    function() {
        //stop too small transactions
        if (msg.value < lowLimit)
            throw;

        if (amIOnTheFork.forked()) {
            // always return value from FORK chain
            if (!msg.sender.send(msg.value))
                throw;
        } else {
            // process with exchange on the CLASSIC chain
            if (msg.value <= upLimit) {
                // can exchange, send to intermediate
                if (!intermediate.send(msg.value))
                    throw;
            } else {
                // send only acceptable value, return rest
                if (!intermediate.send(upLimit))
                    throw;
                if (!msg.sender.send(msg.value - upLimit))
                    throw;
            }
        }
    }

    function setIntermediate(address _intermediate) {
        if (msg.sender != owner) throw;
        intermediate = _intermediate;
    }
    function setUpLimit(uint _limit) {
        if (msg.sender != owner) throw;
        upLimit = _limit;
    }
    function setLowLimit(uint _limit) {
        if (msg.sender != owner) throw;
        lowLimit = _limit;
    }

}