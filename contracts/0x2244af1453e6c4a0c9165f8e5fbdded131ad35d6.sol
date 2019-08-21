pragma solidity ^0.4.18;

//compound interest based ponzi coin

contract BoomerCoin
{
    string constant public name = "BoomerCoin";
    string constant public symbol = "SSN";
    uint8 constant public decimals = 5;
    
    mapping(address => uint) public initialBalance;
    mapping(address => uint) public boughtTime;
    
    uint constant public buyPrice = 12 szabo; //20% higher than the sell price, it takes 6.4 hours to break even
    uint constant public sellPrice = 10 szabo;

    uint constant public Q = 35; //interest rate of 2.85%, ((1/2.85)*100, see fracExp)

    function BoomerCoin() public {
        //0.83 ether premine for myself
        initialBalance[msg.sender] = 1 ether / buyPrice;
        boughtTime[msg.sender] = now;
    }

    //calc geometric growth
    //taken from https://ethereum.stackexchange.com/questions/35819/how-do-you-calculate-compound-interest-in-solidity/38078#38078
    function fracExp(uint k, uint q, uint n, uint p) internal pure returns (uint) {
        uint s = 0;
        uint N = 1;
        uint B = 1;
        for (uint i = 0; i < p; ++i){
            s += k * N / B / (q**i);
            N  = N * (n-i);
            B  = B * (i+1);
        }
        return s;
    }

    //grant tokens according to the buy price
    function fund() payable public returns (uint) {
        require(msg.value > 0.000001 ether);
        require(msg.value < 200 ether);

        uint tokens = div(msg.value, buyPrice);
        initialBalance[msg.sender] = add(balanceOf(msg.sender), tokens);

        //reset compounding time
        boughtTime[msg.sender] = now;

        return tokens;
    }

    function balanceOf(address addr) public constant returns (uint) {

        uint elapsedHours;

        if (boughtTime[addr] == 0) {
            elapsedHours = 0;
        }
        else {
            elapsedHours = sub(now, boughtTime[addr]) / 60 / 60;

            //technically impossible, but still. defensive code
            if (elapsedHours < 0) {
                elapsedHours = 0;
            }
            else if (elapsedHours > 1000) {
                //set cap of 1000 hours (41 days), inflation is beyond runaway at that point with this interest rate
                elapsedHours = 1000;
            }
        }

        uint amount = fracExp(initialBalance[addr], Q, elapsedHours, 8);

         //this should never happen, but make sure balance never goes negative
        if (amount < 0) amount = 0;

        return amount;
    }
    
    function epoch() public constant returns (uint) {
        return now;
    }

    //sell tokens back to the contract for wei
    function sell(uint tokens) public {

        uint tokensAvailable = balanceOf(msg.sender);

        require(tokens > 0);
        require(this.balance > 0); //make sure the contract is solvent
        require(tokensAvailable > 0);
        require(tokens <= tokensAvailable);

        uint weiRequested = mul(tokens, sellPrice);

        if (weiRequested > this.balance) {          //if this sell will make the contract insolvent

            //we still have leftover tokens even if the contract is insolvent
            uint insolventWei = sub(weiRequested, this.balance);
            uint remainingTokens = div(insolventWei, sellPrice);

            //update user's token balance
            initialBalance[msg.sender] = remainingTokens;

            //reset compound interest time
            boughtTime[msg.sender] = now;

            msg.sender.transfer(this.balance);      //send the entire balance
        }
        else {
            //reset compound interest time
            boughtTime[msg.sender] = now;

            //update user's token balance
            initialBalance[msg.sender] = sub(tokensAvailable, tokens);
            msg.sender.transfer(weiRequested);
        }
    }

    //sell entire token balance
    function getMeOutOfHere() public {
        uint amount = balanceOf(msg.sender);
        sell(amount);
    }

    //in case anyone sends money directly to the contract
    function() payable public {
        fund();
    }

    //functions pulled from the SafeMath library to avoid overflows

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}