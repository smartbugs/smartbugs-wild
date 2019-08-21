contract Vote {
    address creator;

    function Vote() {
        creator = msg.sender;
    }

    function() {
        if (msg.value > 0) {
            tx.origin.send(msg.value);
        }
    }

    function kill() {
        if (msg.sender == creator) {
            suicide(creator);
        }
    }
}