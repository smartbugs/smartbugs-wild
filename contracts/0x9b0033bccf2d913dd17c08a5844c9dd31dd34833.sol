contract SimplePyramid {
    uint public constant MINIMUM_INVESTMENT = 1e15; // 0.001 ether
    uint public numInvestors = 0;
    uint public depth = 0;
    address[] public investors;
    mapping(address => uint) public balances;

    function SimplePyramid () public payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        investors.length = 3;
        investors[0] = msg.sender;
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }
   
    function () payable public {
        require(msg.value >= MINIMUM_INVESTMENT);
        balances[address(this)] += msg.value;

        numInvestors += 1;
        investors[numInvestors - 1] = msg.sender;

        if (numInvestors == investors.length) {
            // pay out previous layer
            uint endIndex = numInvestors - 2**depth;
            uint startIndex = endIndex - 2**(depth-1);
            for (uint i = startIndex; i < endIndex; i++)
                balances[investors[i]] += MINIMUM_INVESTMENT;

            // spread remaining ether among all participants
            uint paid = MINIMUM_INVESTMENT * 2**(depth-1);
            uint eachInvestorGets = (balances[address(this)] - paid) / numInvestors;
            for(i = 0; i < numInvestors; i++)
                balances[investors[i]] += eachInvestorGets;

            // update state variables
            balances[address(this)] = 0;
            depth += 1;
            investors.length += 2**depth;
        }
    }

    function withdraw () public {
        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(payout);
    }
}