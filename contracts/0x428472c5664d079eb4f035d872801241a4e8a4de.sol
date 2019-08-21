contract SimplePonzi {
    address public currentInvestor;
    uint public currentInvestment = 0;
    
    function () payable public {
        require(msg.value > currentInvestment);
        
        // payout previous investor
        currentInvestor.send(currentInvestment);

        // document new investment
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

    }
}