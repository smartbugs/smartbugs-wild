pragma solidity ^0.4.16;
/*
Moira ICO Contract

MOI is an ERC-20 Token Standar Compliant

Contract developer: Fares A. Akel C.
f.antonio.akel@gmail.com
MIT PGP KEY ID: 078E41CB
*/

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract token { //Token functions definition

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }
contract MOIRAICO {
    //This ico have 3 stages
    enum State {
        Preico,
        Ico,
        Successful
    }
    
    State public state = State.Preico; //Set initial stage
    uint startTime = now; //block-time when it was deployed

    //We use an aproximation of 1 eth = 290$ for this price calculation
    //List of prices for each stage, as both, eth and moi have 18 decimal, its a direct factor
    uint[9] tablePrices = [
    63800,70180,76560, //+10%,+20%,+30%
    58000,63800,70180, //+0%,+10%,+20%
    32200,35420,38640  //+0%,+10%,+20%
    ];

    mapping (address => uint) balances; //balances mapping
    //public variables
    uint public totalRaised;
    uint public currentBalance;
    uint public preICODeadline;
    uint public ICOdeadline;
    uint public completedAt;
    token public tokenReward;
    address public creator;
    address public beneficiary; 
    string public campaignUrl;
    uint constant version = 1;

    //events for log

    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        address _beneficiary,
        string _url,
        uint256 _preICODeadline,
        uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }

    function MOIRAICO (
        string _campaignUrl,
        token _addressOfTokenUsedAsReward )
        public
    {
        creator = msg.sender;
        beneficiary = msg.sender;
        campaignUrl = _campaignUrl;
        preICODeadline = SafeMath.add(startTime,34 days);
        ICOdeadline = SafeMath.add(preICODeadline,30 days);
        currentBalance = 0;
        tokenReward = token(_addressOfTokenUsedAsReward);
        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            preICODeadline,
            ICOdeadline);
    }

    function contribute() public notFinished payable {

        require(msg.value > 1 finney); //minimun contribution

        uint tokenBought;
        totalRaised =SafeMath.add(totalRaised, msg.value);
        currentBalance = totalRaised;
        /**
         * Here price logic is made
         */
        if(state == State.Preico && now < (startTime + 1 days)){ //if we are on preico first day
            if(msg.value < 10 ether){ //if the amount is less than 10 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[0]);
            }
            else if(msg.value < 20 ether){//if the amount is more than 10 ether and less than 20
                tokenBought = SafeMath.mul(msg.value,tablePrices[1]);
            }
            else{//if the amount is more than 20 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[2]);
            }
        }
        else if(state == State.Preico) {//if we are on preico normal days
            if(msg.value < 10 ether){ //if the amount is less than 10 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[3]);
            }
            else if(msg.value < 20 ether){//if the amount is more than 10 ether and less than 20
                tokenBought = SafeMath.mul(msg.value,tablePrices[4]);
            }
            else{//if the amount is more than 20 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[5]);
            }
        }
        else{//if we are on ico
            if(msg.value < 10 ether){ //if the amount is less than 10 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[6]);
            }
            else if(msg.value < 20 ether){//if the amount is more than 10 ether and less than 20
                tokenBought = SafeMath.mul(msg.value,tablePrices[7]);
            }
            else{//if the amount is more than 20 ether
                tokenBought = SafeMath.mul(msg.value,tablePrices[8]);
            }
        }

        tokenReward.transfer(msg.sender, tokenBought);
        
        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    function checkIfFundingCompleteOrExpired() public {
        
        if(now < ICOdeadline && state!=State.Successful){
            if(now > preICODeadline && state==State.Preico){
                state = State.Ico;    
            }
        }
        else if(now > ICOdeadline && state!=State.Successful) {
            state = State.Successful;
            completedAt = now;
            LogFundingSuccessful(totalRaised);
            finished();  
        }
    }

    function payOut() public {
        require(msg.sender == beneficiary);
        require(beneficiary.send(this.balance));
        LogBeneficiaryPaid(beneficiary);
    }


    function finished() public { //When finished eth and remaining tokens are transfered to beneficiary
        uint remanent;

        require(state == State.Successful);
        require(beneficiary.send(this.balance));
        remanent =  tokenReward.balanceOf(this);
        tokenReward.transfer(beneficiary,remanent);

        currentBalance = 0;

        LogBeneficiaryPaid(beneficiary);
        LogContributorsPayout(beneficiary, remanent);
    }

    function () public payable {
        require(msg.value > 1 finney);
        contribute();
    }
}