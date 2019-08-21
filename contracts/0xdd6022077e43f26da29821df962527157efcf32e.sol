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

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    }

contract ICO {
    using SafeMath for uint256;
    //This ico have 4 stages
    enum State {
        EarlyPreSale,
        PreSale,
        Crowdsale,
        Successful
    }
    //public variables
    State public state = State.EarlyPreSale; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256[2] public price = [6667,5000]; //Price rates for base calculation
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens distributed
    uint256 public stageDistributed; //tokens distributed on the actual stage
    uint256 public completedAt; //Time stamp when the ico finish
    token public tokenReward; //Address of the valit token used as reward
    address public creator; //Address of the contract deployer
    string public campaignUrl; //Web site of the campaing
    string public version = '1';

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        string _url);
    event LogContributorsPayout(address _addr, uint _amount);
    event StageDistributed(State _stage, uint256 _stageDistributed);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    function ICO (string _campaignUrl, token _addressOfTokenUsedAsReward) public {
        creator = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = token(_addressOfTokenUsedAsReward);

        LogFunderInitialized(
            creator,
            campaignUrl
            );
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        require(msg.value >= 100 finney);

        uint256 tokenBought; //Variable to store amount of tokens bought
        totalRaised = totalRaised.add(msg.value); //Save the total eth totalRaised (in wei)

        if (state == State.EarlyPreSale){

            tokenBought = msg.value.mul(price[0]); //Base price rate
            tokenBought = tokenBought.mul(12); // 12/10 = 1.2
            tokenBought = tokenBought.div(10); // 1.2 => 100% + 20% Bonus               
            
            require(stageDistributed.add(tokenBought) <= 60000000 * (10 ** 18)); //Cannot exceed 60.000.000 distributed

        } else if (state == State.PreSale){

            tokenBought = msg.value.mul(price[0]); //Base price rate
            tokenBought = tokenBought.mul(11); // 11/10 = 1.1
            tokenBought = tokenBought.div(10); // 1.1 => 100% + 10% Bonus               
            
            require(stageDistributed.add(tokenBought) <= 60000000 * (10 ** 18)); //Cannot exceed 60.000.000 distributed

        } else if (state == State.Crowdsale){

            tokenBought = msg.value.mul(price[1]); //Base price rate

            require(stageDistributed.add(tokenBought) <= 80000000 * (10 ** 18)); //Cannot exceed 80.000.000 distributed

        }

        totalDistributed = totalDistributed.add(tokenBought);
        stageDistributed = stageDistributed.add(tokenBought);
        
        tokenReward.transfer(msg.sender, tokenBought);
        
        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender, tokenBought);
        
        checkIfFundingCompleteOrExpired();
    }

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {
        
        if(state!=State.Successful){ //if we are on ICO period and its not Successful
            
            if(state == State.EarlyPreSale && now > startTime.add(8 days)){

                StageDistributed(state,stageDistributed);

                state = State.PreSale;
                stageDistributed = 0;
            
            } else if(state == State.PreSale && now > startTime.add(15 days)){

                StageDistributed(state,stageDistributed);

                state = State.Crowdsale;
                stageDistributed = 0;

            } else if(state == State.Crowdsale && now > startTime.add(36 days)){

                StageDistributed(state,stageDistributed);

                state = State.Successful; //ico becomes Successful
                completedAt = now; //ICO is complete
                LogFundingSuccessful(totalRaised); //we log the finish
                finished(); //and execute closure
            
            }
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

    /**
    * @notice Function to handle eth transfers
    * @dev BEWARE: if a call to this functions doesn't have
    * enought gas, transaction could not be finished
    */

    function () public payable {
        contribute();
    }
}