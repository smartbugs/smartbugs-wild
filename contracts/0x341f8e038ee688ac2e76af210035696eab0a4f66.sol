contract tradeReport {
    struct trade {
        string symbol;
        string price;
        string quantity;
        string buyer;
        string seller;
        string execID;
    }
    address public publisher;
    trade public lastTrade;

    function tradeReport() {
        publisher = msg.sender;
    }
    
    event Execution(string symbol, string price, string quantity, string buyer, string seller, string execID);
    
    function publishExecution(string symbol, string price, string quantity, string buyer, string seller, string execID) {
        if (msg.sender != publisher)
            throw;
            
        Execution(symbol, price, quantity, buyer, seller, execID);
        lastTrade = trade(symbol, price, quantity, buyer, seller, execID);
    }
}