pragma solidity 0.4.20;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

contract token {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }

/**
* @title DateTime contract
* @dev This contract will return the unix value of any date
*/
contract DateTimeAPI {
        
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);

}


contract ICO {
    using SafeMath for uint256;
    //This ico have 5 states
    enum State {
        stage1,
        stage2,
        stage3,
        stage4,
        Successful
    }

    DateTimeAPI dateTimeContract = DateTimeAPI(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);//Main
    //DateTimeAPI dateTimeContract = DateTimeAPI(0x1F0a2ba4B115bd3e4007533C52BBd30C17E8B222);//Ropsten

    //public variables
    State public state = State.stage1; //Set initial stage
    uint256 public startTime;
    uint256 public rate;
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public ICOdeadline;
    uint256 public completedAt;
    token public tokenReward;
    address public creator;
    address public beneficiary;
    string public version = '1';

    mapping(address => bool) public airdropClaimed;
    mapping(address => uint) public icoTokensReceived;

    uint public constant TOKEN_SUPPLY_ICO   = 130000000 * 10 ** 18; // 130 Million tokens

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(address _creator, uint256 _ICOdeadline);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    function ICO (token _addressOfTokenUsedAsReward) public {
        
        startTime = dateTimeContract.toTimestamp(2018,3,2,12); //From March 2 12:00 UTC
        ICOdeadline = dateTimeContract.toTimestamp(2018,3,30,12); //Till March 30 12:00 UTC;
        rate = 80000; //Tokens per ether unit

        creator = msg.sender;
        beneficiary = 0x3a1CE9289EC2826A69A115A6AAfC2fbaCc6F8063;
        tokenReward = _addressOfTokenUsedAsReward;

        LogFunderInitialized(
            creator,
            ICOdeadline);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {
        require(now >= startTime);
        require(msg.value > 50 finney);

        uint256 tokenBought = 0;

        totalRaised = totalRaised.add(msg.value);
        tokenBought = msg.value.mul(rate);

        //Rate of exchange depends on stage
        if (state == State.stage1){

            tokenBought = tokenBought.mul(15);
            tokenBought = tokenBought.div(10);//+50%
        
        } else if (state == State.stage2){
        
            tokenBought = tokenBought.mul(125);
            tokenBought = tokenBought.div(100);//+25%
        
        } else if (state == State.stage3){
        
            tokenBought = tokenBought.mul(115);
            tokenBought = tokenBought.div(100);//+15%
        
        }

        icoTokensReceived[msg.sender] = icoTokensReceived[msg.sender].add(tokenBought);
        totalDistributed = totalDistributed.add(tokenBought);
        
        tokenReward.transfer(msg.sender, tokenBought);

        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    function claimAirdrop() external {

        doAirdrop(msg.sender);

    }

    function doAirdrop(address _participant) internal {
        uint airdrop = computeAirdrop(_participant);

        require( airdrop > 0 );

        // update balances and token issue volume
        airdropClaimed[_participant] = true;
        tokenReward.transfer(_participant,airdrop);

        // log
        LogContributorsPayout(_participant, airdrop);
    }

    /* Function to estimate airdrop amount. For some accounts, the value of */
    /* tokens received by calling claimAirdrop() may be less than gas costs */

    /* If an account has tokens from the ico, the amount after the airdrop */
    /* will be newBalance = tokens * TOKEN_SUPPLY_ICO / totalDistributed */
      
    function computeAirdrop(address _participant) public constant returns (uint airdrop) {
        require(state == State.Successful);

        // return  0 is the airdrop was already claimed
        if( airdropClaimed[_participant] ) return 0;

        // return 0 if the account does not hold any crowdsale tokens
        if( icoTokensReceived[_participant] == 0 ) return 0;

        // airdrop amount
        uint tokens = icoTokensReceived[_participant];
        uint newBalance = tokens.mul(TOKEN_SUPPLY_ICO) / totalDistributed;
        airdrop = newBalance - tokens;
    }

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {

        if(state == State.stage1 && now > dateTimeContract.toTimestamp(2018,3,9,12)) { //Till March 9 12:00 UTC

            state = State.stage2;

        } else if(state == State.stage2 && now > dateTimeContract.toTimestamp(2018,3,16,12)) { //Till March 16 12:00 UTC

            state = State.stage3;
            
        } else if(state == State.stage3 && now > dateTimeContract.toTimestamp(2018,3,23,12)) { //From March 23 12:00 UTC

            state = State.stage4;
            
        } else if(now > ICOdeadline && state!=State.Successful) { //if we reach ico deadline and its not Successful yet

        state = State.Successful; //ico becomes Successful
        completedAt = now; //ICO is complete

        LogFundingSuccessful(totalRaised); //we log the finish
        finished(); //and execute closure

    }
}

    /**
    * @notice closure handler
    */
    function finished() public { //When finished eth are transfered to beneficiary

        require(state == State.Successful);
        require(beneficiary.send(this.balance));
        LogBeneficiaryPaid(beneficiary);

    }

    /*
    * @dev direct payments
    */
    function () public payable {
        
        contribute();

    }
}