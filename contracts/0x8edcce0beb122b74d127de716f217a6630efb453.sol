pragma solidity ^0.4.18;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
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

/**
* @title admined
* @notice This contract is administered
*/
contract admined {
    address public admin; //Admin address is public
    
    /**
    * @dev This contructor takes the msg.sender as the first administer
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    /**
    * @dev This modifier limits function execution to the admin
    */
    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    /**
    * @notice This function transfer the adminship of the contract to _newAdmin
    * @param _newAdmin The new admin of the contract
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    /**
    * @dev Log Events
    */
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}


contract ICO is admined {
    using SafeMath for uint256;
    //This ico have 5 stages
    enum State {
        EarlyBird,
        PreSale,
        TokenSale,
        ITO,
        Successful
    }
    //public variables
    uint256 public priceOfEthOnEUR;
    State public state = State.EarlyBird; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public price; //Price rate for base calculation
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
        string _url,
        uint256 _initialRate);
    event LogContributorsPayout(address _addr, uint _amount);
    event PriceUpdate(uint256 _newPrice);
    event StageDistributed(State _stage, uint256 _stageDistributed);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    * @param _initialEURPriceOfEth is the current price in EUR for a single ether
    */
    function ICO (string _campaignUrl, token _addressOfTokenUsedAsReward, uint256 _initialEURPriceOfEth) public {
        creator = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = token(_addressOfTokenUsedAsReward);
        priceOfEthOnEUR = _initialEURPriceOfEth;
        price = SafeMath.div(priceOfEthOnEUR.mul(6666666666666666667),1000000000000000000);
        
        LogFunderInitialized(
            creator,
            campaignUrl,
            price
            );
        PriceUpdate(price);
    }

    function updatePriceOfEth(uint256 _newPrice) onlyAdmin public {
        priceOfEthOnEUR = _newPrice;
        price = SafeMath.div(priceOfEthOnEUR.mul(6666666666666666667),1000000000000000000);
        PriceUpdate(price);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        uint256 tokenBought;
        totalRaised = totalRaised.add(msg.value);

        if (state == State.EarlyBird){

            tokenBought = msg.value.mul(price);
            tokenBought = tokenBought.mul(4); //4x
            require(stageDistributed.add(tokenBought) <= 200000000 * (10 ** 18));

        } else if (state == State.PreSale){

            tokenBought = msg.value.mul(price);
            tokenBought = tokenBought.mul(15); //1.5x
            tokenBought = tokenBought.div(10);
            require(stageDistributed.add(tokenBought) <= 500000000 * (10 ** 18));

        } else if (state == State.TokenSale){

            tokenBought = msg.value.mul(price); //1x
            require(stageDistributed.add(tokenBought) <= 500000000 * (10 ** 18));

        } else if (state == State.ITO){

            tokenBought = msg.value.mul(price); //1x
            require(stageDistributed.add(tokenBought) <= 800000000 * (10 ** 18));

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
            
            if(state == State.EarlyBird && now > startTime.add(38 days)){ //38 days - 25.12.2017 to 01.02.2018
                
                StageDistributed(state,stageDistributed);

                state = State.PreSale;
                stageDistributed = 0;
            
            } else if(state == State.PreSale && now > startTime.add(127 days)){ //89 days(+38) - 01.02.2018 to 01.05.2018
                
                StageDistributed(state,stageDistributed);

                state = State.TokenSale;
                stageDistributed = 0;

            } else if(state == State.TokenSale && now > startTime.add(219 days)){ //92 days(+127) - 01.05.2018 to 01.08.2018
            
                StageDistributed(state,stageDistributed);

                state = State.ITO;
                stageDistributed = 0;

            } else if(state == State.ITO && now > startTime.add(372 days)){ //153 days(+219) - 01.08.2018 to 01.01.2019
                
                StageDistributed(state,stageDistributed);

                state = State.Successful; //ico becomes Successful
                completedAt = now; //ICO is complete
                LogFundingSuccessful(totalRaised); //we log the finish
                finished(); //and execute closure
            
            }
        }
    }

    /**
    * @notice function to withdraw eth to creator address
    */
    function payOut() public {
        require(msg.sender == creator); //Only the creator can withdraw funds
        require(creator.send(this.balance));
        LogBeneficiaryPaid(creator);
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

    function () public payable {
        contribute();
    }
}