pragma solidity ^0.4.11;

contract TwoUp {
    // Punter who made the most recent bet
    address public punterAddress;
    // Amount of that most recent bet
    uint256 public puntAmount;
    // Is there someone waiting with a bet down?
    bool public punterWaiting;

    // Note the lack of owner privileges. The house gets nothing, like true blue
    // Aussie two-up. Also this feels more legal idunno

    // Don't let mad dogs bet more than 10 ether and don't let time wasters send
    // empty transactions.
    modifier withinRange {
        assert(msg.value > 0 ether && msg.value < 10 ether);
        _;
    }
    
    // Initialise/Create Contract
    function TwoUp() public {
        punterWaiting = false;
    }
    
    // Main Function. All action happens by users submitting a bet to the smart
    // contract. No message is required, just a bet. If you bet more than your 
    // opponent then you will get the change sent back to you. If you bet less
    // then they will get their change sent back to them. i.e. the actual wager
    // amount is min(bet_1,bet_2).
    function () payable public withinRange {
        if (punterWaiting){
            uint256 _payout = min(msg.value,puntAmount);
            if (rand(punterAddress) >= rand(msg.sender)) {
                punterAddress.transfer(_payout+puntAmount);
                if ((msg.value-_payout)>0)
                    msg.sender.transfer(msg.value-_payout);
            } else {
                msg.sender.transfer(_payout+msg.value);
                if ((puntAmount-_payout)>0)
                    punterAddress.transfer(puntAmount-_payout);
            }
            punterWaiting = false;
        } else {
            punterWaiting = true;
            punterAddress = msg.sender;
            puntAmount = msg.value;
        }
    }
    
    // min(a,b) function required for tidiness
    function min(uint256 _a, uint256 _b) private pure returns(uint256){
        if (_b < _a) {
            return _b;
        } else {
            return _a;
        }
    }
    function rand(address _who) private view returns(bytes32){
        return keccak256(_who,now);
    }
    
}