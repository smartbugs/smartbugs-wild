pragma solidity ^0.4.16;
/**
* @title UNR ICO CONTRACT
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


contract UNRICO is admined {
    using SafeMath for uint256;
    //This ico have 3 stages
    enum State {
        Ongoin,
        Successful
    }
    //public variables
    uint256 public priceOfEthOnUSD;
    State public state = State.Ongoin; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256[5] public price;
    uint256 public HardCap;
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens
    uint256 public ICOdeadline = startTime.add(27 days);//27 days deadline
    uint256 public completedAt;
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
    event PriceUpdate(uint256 _newPrice);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice ICO constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    * @param _initialUsdPriceOfEth is the current price in USD for a single ether
    */
    function UNRICO (string _campaignUrl, token _addressOfTokenUsedAsReward, uint256 _initialUsdPriceOfEth) public {
        creator = msg.sender;
        beneficiary = msg.sender;
        campaignUrl = _campaignUrl;
        tokenReward = token(_addressOfTokenUsedAsReward);
        priceOfEthOnUSD = _initialUsdPriceOfEth;
        HardCap = SafeMath.div(7260000*10**18,priceOfEthOnUSD); //7,260,000$
        price[0] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1666666));
        price[1] = SafeMath.div(1 * 10 ** 11, priceOfEthOnUSD.mul(125));
        price[2] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1111111));
        price[3] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1052631));
        price[4] = SafeMath.div(1 * 10 ** 10, priceOfEthOnUSD.mul(10));

        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            ICOdeadline);
        PriceUpdate(priceOfEthOnUSD);
    }

    function updatePriceOfEth(uint256 _newPrice) onlyAdmin public {
        priceOfEthOnUSD = _newPrice;
        price[0] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1666666));
        price[1] = SafeMath.div(1 * 10 ** 11, priceOfEthOnUSD.mul(125));
        price[2] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1111111));
        price[3] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1052631));
        price[4] = SafeMath.div(1 * 10 ** 10, priceOfEthOnUSD.mul(10));
        HardCap = SafeMath.div(7260000*10**18,priceOfEthOnUSD); //7,260,000$
        PriceUpdate(_newPrice);
    }

    /**
    * @notice contribution handler
    */
    function contribute() public notFinished payable {

        uint256 tokenBought;
        uint256 required;
        totalRaised = totalRaised.add(msg.value);

        if(totalDistributed < 2000000 * (10 ** 8)){
            tokenBought = msg.value.div(price[0]);
            required = SafeMath.div(10000,6);
            require(tokenBought >= required);
        }
        else if (totalDistributed < 20000000 * (10 ** 8)){
            tokenBought = msg.value.div(price[1]);
            required = SafeMath.div(10000,8);
            require(tokenBought >= required);
        }
        else if (totalDistributed < 40000000 * (10 ** 8)){
            tokenBought = msg.value.div(price[2]);
            required = SafeMath.div(10000,9);
            require(tokenBought >= required);
        }
        else if (totalDistributed < 60000000 * (10 ** 8)){
            tokenBought = msg.value.div(price[3]);
            required = SafeMath.div(100000,95);
            require(tokenBought >= required);
        }
        else if (totalDistributed < 80000000 * (10 ** 8)){
            tokenBought = msg.value.div(price[4]);
            required = 1000;
            require(tokenBought >= required);

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
            if(state == State.Ongoin && totalRaised >= HardCap){ //if we are Ongoin and we pass the HardCap
                state = State.Successful; //We are on Successful state
                completedAt = now; //ICO is complete
            }
        }
        else if(now > ICOdeadline && state!=State.Successful ) { //if we reach ico deadline and its not Successful yet
            state = State.Successful; //ico becomes Successful
            completedAt = now; //ICO is complete
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