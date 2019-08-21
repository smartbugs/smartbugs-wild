contract Prism {
    address constant theWithdraw = 0xbf4ed7b27f1d666546e30d74d50d173d20bca754;
    function Prism() {
        forked = theWithdraw.balance > 1 ether;
    }
    
    function transferETC(address to) {
        if (forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }

    function transferETH(address to) {
        if (!forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }
    
    bool public forked;
}