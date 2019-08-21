contract Escrow {
    address seller;
    address buyer;
    address arbitrator;
    
    function Escrow(address _seller, address _arbitrator) {
        seller = _seller;
        arbitrator = _arbitrator;
        buyer = msg.sender;
    }
    
    function finalize() {
        if (msg.sender == buyer || msg.sender == arbitrator)
            seller.send(this.balance);
    }
    
    function refund() {
        if (msg.sender == seller || msg.sender == arbitrator)
            buyer.send(this.balance);
    }
}