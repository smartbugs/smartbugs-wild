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

contract DateTime {

    function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp);

}

contract token {

    function balanceOf(address _owner) public constant returns (uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }

contract ICO {
    using SafeMath for uint256;
    //This ico have 5 states
    enum State {
        ico,
        Successful
    }
    //public variables
    State public state = State.ico; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public rate = 1250;
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public ICOdeadline;
    uint256 public completedAt;
    token public tokenReward;
    address public creator;
    string public version = '1';

    DateTime dateTimeContract = DateTime(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    function ICO (token _addressOfTokenUsedAsReward ) public {

        creator = msg.sender;
        tokenReward = _addressOfTokenUsedAsReward;
        ICOdeadline = dateTimeContract.toTimestamp(2018,5,15);

        LogFunderInitialized(
            creator,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        require(msg.value > (10**10));
        
        uint256 tokenBought = 0;

        totalRaised = totalRaised.add(msg.value);

        tokenBought = msg.value.div(10 ** 10);//token is 8 decimals, eth 18
        tokenBought = tokenBought.mul(rate);

        //Bonuses depends on stage
        if (now < dateTimeContract.toTimestamp(2018,2,15)){//presale

            tokenBought = tokenBought.mul(15);
            tokenBought = tokenBought.div(10); //15/10 = 1.5 = 150%
            require(totalDistributed.add(tokenBought) <= 100000000 * (10 ** 8));//presale limit
        
        } else if (now < dateTimeContract.toTimestamp(2018,2,28)){

            tokenBought = tokenBought.mul(14);
            tokenBought = tokenBought.div(10); //14/10 = 1.4 = 140%
        
        } else if (now < dateTimeContract.toTimestamp(2018,3,15)){

            tokenBought = tokenBought.mul(13);
            tokenBought = tokenBought.div(10); //13/10 = 1.3 = 130%
        
        } else if (now < dateTimeContract.toTimestamp(2018,3,31)){

            tokenBought = tokenBought.mul(12);
            tokenBought = tokenBought.div(10); //12/10 = 1.2 = 120%
        
        } else if (now < dateTimeContract.toTimestamp(2018,4,30)){

            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.div(10); //11/10 = 1.1 = 110%
        
        } else if (now < dateTimeContract.toTimestamp(2018,5,15)){

            tokenBought = tokenBought.mul(105);
            tokenBought = tokenBought.div(100); //105/10 = 1.05 = 105%
        
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

        if(now > ICOdeadline && state!=State.Successful ) { //if we reach ico deadline and its not Successful yet

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

        require(creator.send(this.balance));
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