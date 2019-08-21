pragma solidity ^0.4.16;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
* @author Fares A. Akel C.
*/

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

    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value);

    }

contract ICO {
    using SafeMath for uint256;
    //This ico have 2 stages
    enum State {
        Ongoin,
        Successful
    }
    //public variables
    State public state = State.Ongoin; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    //List of prices, as both, eth and token have 18 decimal, its a direct factor
    uint256 public price = 1500; //1500 tokens per eth fixed
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens with decimals
    uint256 public ICOdeadline; //deadline
    uint256 public closedAt; //time when it finished
    token public tokenReward; //token address used as reward
    address public creator; //creator of the contract
    address public beneficiary; //beneficiary of the contract
    string public campaignUrl; //URL of the campaing
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
    * @param _addressOfTokenUsedAsReward is the token distributed
    * @param _timeInDaysForICO is the days the campaing will last
    */
    function ICO (string _campaignUrl, token _addressOfTokenUsedAsReward, uint256 _timeInDaysForICO) public {
        creator = msg.sender; //creator wallet address
        beneficiary = msg.sender; //beneficiary wallet address
        campaignUrl = _campaignUrl; //URL of the campaing
        tokenReward = token(_addressOfTokenUsedAsReward); //token used as reward
        ICOdeadline = startTime + _timeInDaysForICO * 1 days; //deadline is _timeInDaysForICO days from now

        //logs
        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    * @dev user must provide enough gas
    */
    function contribute() public notFinished payable {

        uint256 tokenBought;
        totalRaised = totalRaised.add(msg.value); //increase raised counter
        tokenBought = msg.value.mul(price); //calculate how much tokens will be sent
        totalDistributed = totalDistributed.add(tokenBought); //increase distributed token counter
        require(beneficiary.send(msg.value)); //transfer funds
        tokenReward.transfer(msg.sender,tokenBought); //transfer tokens
        
        //logs
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
            closedAt = now; //we complete now
            
            LogFundingSuccessful(totalRaised); //we log the finish
            finished(); //and execute closure
        }
    }

   /**
    * @notice closure handler
    */
    function finished() public { //When finished eth and tokens remaining are transfered to beneficiary
        require(state == State.Successful); //only when Successful
        require(beneficiary.send(this.balance)); //we require the transfer has been sent

        uint256 remaining = tokenReward.balanceOf(this); //get the total tokens remaining
        tokenReward.transfer(beneficiary,remaining); //transfer remaining tokens to the beneficiary

        LogBeneficiaryPaid(beneficiary);
    }

    /**
    * @dev user must provide enough gas
    */
    function () public payable {
        contribute(); //this function require more gas than a normal callback function, sender must provide it
    }
}