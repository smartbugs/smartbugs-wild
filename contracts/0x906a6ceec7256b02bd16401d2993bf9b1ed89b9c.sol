pragma solidity 0.4.19;
/**
* @title PREVIP CCS SALE CONTRACT
* @dev ERC-20 Token Standard Compliant
* @notice Contact ico@cacaoshares.com
* @author Fares A. Akel C.
* ================================================
* CACAO SHARES IS A DIGITAL ASSET
* THAT ENABLES ANYONE TO OWN CACAO TREES
* OF THE CRIOLLO TYPE IN SUR DEL LAGO, VENEZUELA
* ================================================
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

/**
* @title Fiat currency contract
* @dev This contract will return the value of 0.01$ USD in wei
*/
contract FiatContract {
 
  function USD(uint _id) constant returns (uint256);

}

/**
* @title DateTime contract
* @dev This contract will return the unix value of any date
*/
contract DateTimeAPI {
        
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);

}

/**
* @title ERC20 Token interface
*/
contract token {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

}

/**
* @title PREVIPCCS sale main contract
*/
contract PREVIPCCS {


    FiatContract price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591); // MAINNET ADDRESS
    //FiatContract price = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909); // TESTNET ADDRESS (ROPSTEN)

    DateTimeAPI dateTimeContract = DateTimeAPI(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);//Main
    //DateTimeAPI dateTimeContract = DateTimeAPI(0x1F0a2ba4B115bd3e4007533C52BBd30C17E8B222);//Ropsten

    using SafeMath for uint256;
    //This sale have 2 stages
    enum State {
        PreVIP,
        Successful
    }
    //public variables
    State public state = State.PreVIP; //Set initial stage
    uint256 public startTime = dateTimeContract.toTimestamp(2018,2,13,15); //From Feb 14 00:00 (JST - GMT+9)
    uint256 public PREVIPdeadline = dateTimeContract.toTimestamp(2018,2,28,15); //Stop Mar 1 00:00 (JST - GMT+9)
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens distributed
    uint256 public completedAt; //Time stamp when the sale finish
    token public tokenReward; //Address of the valid token used as reward
    address public creator; //Address of the contract deployer
    string public campaignUrl; //Web site of the campaign
    string public version = '1';

    //events for log
    event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
    event LogBeneficiaryPaid(address _beneficiaryAddress);
    event LogFundingSuccessful(uint _totalRaised);
    event LogFunderInitialized(
        address _creator,
        string _url);
    event LogContributorsPayout(address _addr, uint _amount);

    modifier notFinished() {
        require(state != State.Successful);
        _;
    }
    /**
    * @notice PREVIPCCS constructor
    * @param _campaignUrl is the ICO _url
    * @param _addressOfTokenUsedAsReward is the token totalDistributed
    */
    function PREVIPCCS (string _campaignUrl, token _addressOfTokenUsedAsReward) public {
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
        require(now >= startTime);
        require(msg.value >= 1 szabo);

        uint256 tokenBought; //Variable to store amount of tokens bought
        uint256 tokenPrice = price.USD(0); //1 cent value in wei

        totalRaised = totalRaised.add(msg.value); //Save the total eth totalRaised (in wei)

        tokenPrice = tokenPrice.mul(36); //0.36$ USD value in wei 
        tokenPrice = tokenPrice.div(10 ** 8); //Change base 18 to 10

        tokenBought = msg.value.div(tokenPrice); //Base 18/ Base 10 = Base 8
        tokenBought = tokenBought.mul(10 **10); //Base 8 to Base 18
        
        //Discount calculation
        if (msg.value >= 10 ether){
            tokenBought = tokenBought.mul(123);
            tokenBought = tokenBought.div(100); //+10% discount reflected as +23% bonus
        } else if (msg.value >= 1 ether){
            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.div(10); //+5% discount reflected as +10% bonus
        }

        totalDistributed = totalDistributed.add(tokenBought); //Save to total tokens distributed
        
        tokenReward.transfer(msg.sender,tokenBought); //Send Tokens
        
        //LOGS
        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender,tokenBought);

        checkIfFundingCompleteOrExpired();
    }

    /**
    * @notice Function to know how many tokens you will receive at current time
    * @param _amountOfWei How much ETH you will invest in Wei (1ETH = 10^18 WEI)
    */
    function calculateTokens(uint256 _amountOfWei) public view returns(uint256) {
        require(_amountOfWei >= 1 szabo);
        
        uint256 tokenBought; //Variable to store amount of tokens bought
        uint256 tokenPrice = price.USD(0); //1 cent value in wei

        tokenPrice = tokenPrice.mul(36); //0.36$ USD value in wei 
        tokenPrice = tokenPrice.div(10 ** 8); //Change base 18 to 10

        tokenBought = _amountOfWei.div(tokenPrice); //Base 18/ Base 10 = Base 8
        tokenBought = tokenBought.mul(10 **10); //Base 8 to Base 18

        //Discount calculation
        if (_amountOfWei >= 10 ether){
            tokenBought = tokenBought.mul(123);
            tokenBought = tokenBought.div(100); //+10% discount reflected as +23% bonus
        } else if (_amountOfWei >= 1 ether){
            tokenBought = tokenBought.mul(11);
            tokenBought = tokenBought.div(10); //+5% discount reflected as +10% bonus
        }

        return tokenBought;

    }

    /**
    * @notice Function to know how many tokens left on contract
    */
    function remainigTokens() public view returns(uint256) {
        return tokenReward.balanceOf(this);
    } 

    /**
    * @notice check status
    */
    function checkIfFundingCompleteOrExpired() public {

        if(now > PREVIPdeadline && state != State.Successful){

            state = State.Successful; //Sale becomes Successful
            completedAt = now; //PreVIP finished

            LogFundingSuccessful(totalRaised); //we log the finish

            finished();
        }
    }

    /**
    * @notice Function for closure handle
    */
    function finished() public { //When finished eth are transfered to creator
        require(state == State.Successful); //Only when sale finish
        
        uint256 remainder = tokenReward.balanceOf(this); //Remaining tokens on contract

        require(creator.send(this.balance)); //Funds send to creator
        tokenReward.transfer(creator,remainder); //remainder tokens send to creator

        LogBeneficiaryPaid(creator);
        LogContributorsPayout(creator, remainder);

    }

    /**
    * @notice Function to claim any token stuck on contract
    */
    function claimTokens(token _address) public{
        require(state == State.Successful); //Only when sale finish
        require(msg.sender == creator);

        uint256 remainder = _address.balanceOf(this); //Check remainder tokens
        _address.transfer(creator,remainder); //Transfer tokens to creator
        
    }

    /**
    * @notice Function to claim any eth stuck on contract
    */
    function claimEth() public { //When finished eth are transfered to creator
        require(state == State.Successful); //Only when sale finish
        require(msg.sender == creator);

        require(creator.send(this.balance)); //Funds send to creator
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