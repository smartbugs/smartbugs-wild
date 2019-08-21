pragma solidity 0.4.19;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
* @notice Website: Ze.cash
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

contract FiatContract {
 
  function USD(uint _id) constant returns (uint256);

}

contract token {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

}

/**
* @title Admin parameters
* @dev Define administration parameters for this contract
*/
contract admined { //This token contract is administered
    address public admin; //Admin address is public

    /**
    * @dev Contract constructor
    * define initial administrator
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

   /**
    * @dev Function to set new admin address
    * @param _newAdmin The address to transfer administration to
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != address(0));
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

contract ICO is admined{
    using SafeMath for uint256;
    //This ico have 2 stages
    enum State {
        Sale,
        Successful
    }
    //public variables
    State public state = State.Sale; //Set initial stage
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public totalRaised; //eth in wei
    uint256 public totalDistributed; //tokens distributed
    uint256 public completedAt; //Time stamp when the ico finish
    token public tokenReward; //Address of the valit token used as reward
    address public creator; //Address of the contract deployer
    string public campaignUrl; //Web site of the campaing
    string public version = '1';

    FiatContract price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591); // MAINNET ADDRESS
    //FiatContract price = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909); // TESTNET ADDRESS (ROPSTEN)

    uint256 remanent;

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

        uint256 tokenBought; //Variable to store amount of tokens bought
        uint256 tokenPrice = price.USD(0); //1 cent value in wei

        tokenPrice = tokenPrice.div(10 ** 8);
        totalRaised = totalRaised.add(msg.value); //Save the total eth totalRaised (in wei)

        tokenBought = msg.value.div(tokenPrice);
        tokenBought = tokenBought.mul(10 **10);
        
        totalDistributed = totalDistributed.add(tokenBought);
        
        tokenReward.transfer(msg.sender,tokenBought);
        
        LogFundingReceived(msg.sender, msg.value, totalRaised);
        LogContributorsPayout(msg.sender,tokenBought);
    }

    function finishFunding() onlyAdmin public {

        state = State.Successful; //ico becomes Successful
        completedAt = now; //ICO is complete
        LogFundingSuccessful(totalRaised); //we log the finish
        claimTokens();
        claimEth();
            
    }

    function claimTokens() onlyAdmin public{

        remanent = tokenReward.balanceOf(this);
        tokenReward.transfer(msg.sender,remanent);
        
        LogContributorsPayout(msg.sender,remanent);
    }

    function claimEth() onlyAdmin public { //When finished eth are transfered to creator
        
        require(msg.sender.send(this.balance));

        LogBeneficiaryPaid(msg.sender);
        
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