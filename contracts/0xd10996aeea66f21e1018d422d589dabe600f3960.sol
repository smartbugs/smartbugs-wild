pragma solidity ^0.4.18;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
* @author Fares A. Akel C. f.antonio.akel@gmail.com
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract token {

    function balanceOf(address _owner) public constant returns (uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }

contract ICO {
    using SafeMath for uint256;
    //This ico have 5 states
    enum State {
        preico,
        week1,
        week2,
        week3,
        week4,
        week5,
        week6,
        week7,
        Successful
    }
    //public variables
    State public state = State.preico; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public rate;
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public totalContributors;
    uint256 public ICOdeadline;
    uint256 public completedAt;
    token public tokenReward;
    address public creator;
    string public campaignUrl;
    string public version = '1';

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
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
    function ICO (
        string _campaignUrl,
        token _addressOfTokenUsedAsReward) public {
        require(_addressOfTokenUsedAsReward!=address(0));

        creator = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = _addressOfTokenUsedAsReward;
        rate = 3214;
        ICOdeadline = startTime.add(64 days); //9 weeks

        LogFunderInitialized(
            creator,
            campaignUrl,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        uint256 tokenBought = 0;

        totalRaised = totalRaised.add(msg.value);
        totalContributors = totalContributors.add(1);

        tokenBought = msg.value.mul(rate);

        //Rate of exchange depends on stage
        if (state == State.preico){

            tokenBought = tokenBought.mul(14);
            tokenBought = tokenBought.mul(10); //14/10 = 1.4 = 140%
        
        } else if (state == State.week1){

            tokenBought = tokenBought.mul(13);
            tokenBought = tokenBought.mul(10); //13/10 = 1.3 = 130%

        } else if (state == State.week2){

            tokenBought = tokenBought.mul(125);
            tokenBought = tokenBought.mul(100); //125/100 = 1.25 = 125%

        } else if (state == State.week3){

            tokenBought = tokenBought.mul(12);
            tokenBought = tokenBought.mul(10); //12/10 = 1.2 = 120%

        } else if (state == State.week4){

            tokenBought = tokenBought.mul(115);
            tokenBought = tokenBought.mul(100); //115/100 = 1.15 = 115%

        } else if (state == State.week5){

            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.mul(10); //11/10 = 1.10 = 110%

        } else if (state == State.week6){

            tokenBought = tokenBought.mul(105);
            tokenBought = tokenBought.mul(100); //105/100 = 1.05 = 105%

        }

        totalDistributed = totalDistributed.add(tokenBought);
        
        require(creator.send(msg.value));
        tokenReward.transfer(msg.sender, tokenBought);

        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {

        if(state == State.preico && now > startTime.add(15 days)){

            state = State.week1;

        } else if(state == State.week1 && now > startTime.add(22 days)){

            state = State.week2;
            
        } else if(state == State.week2 && now > startTime.add(29 days)){

            state = State.week3;
            
        } else if(state == State.week3 && now > startTime.add(36 days)){

            state = State.week4;
            
        } else if(state == State.week4 && now > startTime.add(43 days)){

            state = State.week5;
            
        } else if(state == State.week5 && now > startTime.add(50 days)){

            state = State.week6;
            
        } else if(state == State.week6 && now > startTime.add(57 days)){

            state = State.week7;
            
        } else if(now > ICOdeadline && state!=State.Successful ) { //if we reach ico deadline and its not Successful yet

            state = State.Successful; //ico becomes Successful
            completedAt = now; //ICO is complete

            LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure
        }
    }

    /**
    * @notice closure handler
    */
    function finished() public { //When finished eth are transfered to creator

        require(state == State.Successful);
        uint256 remanent = tokenReward.balanceOf(this);

        tokenReward.transfer(creator,remanent);

        LogBeneficiaryPaid(creator);
        LogContributorsPayout(creator, remanent);

    }

    /*
    * @dev Direct payments handle
    */

    function () public payable {
        
        contribute();

    }
}