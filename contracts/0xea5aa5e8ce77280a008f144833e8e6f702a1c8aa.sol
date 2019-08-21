pragma solidity ^0.4.16;
/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract token {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }

contract ICO {
    using SafeMath for uint256;
    //This ico have 3 stages
    enum State {
        Ongoin,
        SoftCap,
        Successful
    }
    //public variables
    State public state = State.Ongoin; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public delay;
    //List of prices, as both, eth and token have 18 decimal, its a direct factor
    uint[2] public tablePrices = [
    2500, //for first 10million tokens
    2000
    ];
    uint256 public SoftCap = 40000000 * (10 ** 18); //40 million tokens
    uint256 public HardCap = 80000000 * (10 ** 18); //80 million tokens
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public ICOdeadline = startTime.add(21 days);//21 days deadline
    uint256 public completedAt;
    uint256 public closedAt;
    token public tokenReward;
    address public creator;
    address public beneficiary;
    string public campaignUrl;
    uint8 constant version = 1;

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        address _beneficiary,
        string _url,
        uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    function ICO (string _campaignUrl, token _addressOfTokenUsedAsReward, uint256 _delay) public {
        creator = msg.sender;
        beneficiary = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = token(_addressOfTokenUsedAsReward);
        delay = startTime.add(_delay * 1 hours);
        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {
        require(now > delay);
        uint tokenBought;
        totalRaised = totalRaised.add(msg.value);

        if(totalDistributed < 10000000 * (10 ** 18)){ //if on the first 10M
            tokenBought = msg.value.mul(tablePrices[0]);
        }
        else {
            tokenBought = msg.value.mul(tablePrices[1]);
        }

        totalDistributed = totalDistributed.add(tokenBought);
        tokenReward.transfer(msg.sender, tokenBought);
        
        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {
        
        if(now < ICOdeadline && state!=State.Successful){ //if we are on ICO period and its not Successful
            if(state == State.Ongoin && totalRaised >= SoftCap){ //if we are Ongoin and we pass the SoftCap
                state = State.SoftCap; //We are on SoftCap state
                completedAt = now; //ICO is complete and will finish in 24h
            }
            else if (state == State.SoftCap && now > completedAt.add(24 hours)){ //if we are on SoftCap state and 24hrs have passed
                state == State.Successful; //the ico becomes Successful
                closedAt = now; //we finish now
                LogFundingSuccessful(totalRaised); //we log the finish
                finished(); //and execute closure
            }
        }
        else if(now > ICOdeadline && state!=State.Successful ) { //if we reach ico deadline and its not Successful yet
            state = State.Successful; //ico becomes Successful

            if(completedAt == 0){  //if not completed previously
                completedAt = now; //we complete now
            }

            closedAt = now; //we finish now
            LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure
        }
    }

    function payOut() public {
        require(msg.sender == beneficiary);
        require(beneficiary.send(this.balance));
        LogBeneficiaryPaid(beneficiary);
    }

   /**
    * @notice closure handler
    */
    function finished() public { //When finished eth are transfered to beneficiary
        require(state == State.Successful);
        uint256 remanent = tokenReward.balanceOf(this);

        require(beneficiary.send(this.balance));
        tokenReward.transfer(beneficiary,remanent);

        LogBeneficiaryPaid(beneficiary);
        LogContributorsPayout(beneficiary, remanent);
    }

    function () public payable {
        contribute();
    }
}