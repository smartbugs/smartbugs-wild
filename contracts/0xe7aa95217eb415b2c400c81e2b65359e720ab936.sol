contract Switch {
    address constant theWithdraw = 0xbf4ed7b27f1d666546e30d74d50d173d20bca754;
    function Switch() {
        forked = theWithdraw.balance > 10000 ether;
    }
    
    function transferringETC(address to) {
        if (forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }

    function transferringETH(address to) {
        if (!forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }
    
    bool public forked;
}