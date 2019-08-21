contract chal2sweep {
    address chal = 0x08d698358b31ca6926e329879db9525504802abf;
    address noel = 0x1488e30b386903964b2797c97c9a3a678cf28eca;

    // restrict msg.sender
    modifier only_noel { if (msg.sender == noel) _ }
    // don't run recursively
    modifier msg_value_not(uint _amount) {
        if (msg.value != _amount) _
    }

    // could use kill() straight-up, but want to test gas on live chain
    function withdraw(uint _amount) only_noel {
        if (!noel.send(_amount)) throw;
    }

    // should allow withdrawal without gas calc
    function kill() only_noel {
        suicide(noel);
    }

    // web3.toWei(10, "ether") == "10000000000000000000"
    function () msg_value_not(10000000000000000000) {
        if (!chal.call("withdrawEtherOrThrow", 10000000000000000000))
            throw;
    }
}