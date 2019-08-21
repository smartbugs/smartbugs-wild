pragma solidity 0.4.25;
/**
* @title VSTER ICO Contract
* @dev VSTER is an ERC-20 Standar Compliant Token
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public;
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title admined
 * @notice This contract is administered
 */
contract admined {
    //mapping to user levels
    mapping(address => uint8) public level;
    //0 normal user
    //1 basic admin
    //2 master admin

    /**
    * @dev This contructor takes the msg.sender as the first master admin
    */
    constructor() internal {
        level[msg.sender] = 2; //Set initial admin to contract creator
        emit AdminshipUpdated(msg.sender,2); //Log the admin set
    }

    /**
    * @dev This modifier limits function execution to the admin
    */
    modifier onlyAdmin(uint8 _level) { //A modifier to define admin-only functions
        require(level[msg.sender] >= _level ); //It require the user level to be more or equal than _level
        _;
    }

    /**
    * @notice This function transfer the adminship of the contract to _newAdmin
    * @param _newAdmin The new admin of the contract
    */
    function adminshipLevel(address _newAdmin, uint8 _level) onlyAdmin(2) public { //Admin can be set
        require(_newAdmin != address(0)); //The new admin must not be zero address
        level[_newAdmin] = _level; //New level is set
        emit AdminshipUpdated(_newAdmin,_level); //Log the admin set
    }

    /**
    * @dev Log Events
    */
    event AdminshipUpdated(address _newAdmin, uint8 _level);

}

contract VSTERICO is admined {

    using SafeMath for uint256;
    //This ico have these possible states
    enum State {
        PRESALE,
        MAINSALE,
        Successful
    }
    //Public variables

    //Time-state Related
    State public state = State.PRESALE; //Set initial stage
    uint256 constant public PRESALEStart = 1548979200; //Human time (GMT): Friday, 1 February 2019 0:00:00
    uint256 constant public MAINSALEStart = 1554163200; //Human time (GMT): Tuesday, 2 April 2019 0:00:00
    uint256 constant public SaleDeadline = 1564531200; //Human time (GMT): Wednesday, 31 July 2019 0:00:00
    uint256 public completedAt; //Set when ico finish
    //Token-eth related
    uint256 public totalRaised; //eth collected in wei
    uint256 public totalRefDistributed; //total tokens distributed to referrals
    uint256 public totalEthRefDistributed; //total eth distributed to specified referrals
    uint256 public totalDistributed; //Sale tokens distributed
    ERC20Basic public tokenReward = ERC20Basic(0xA2e13c4f0431B6f2B06BBE61a24B61CCBe13136A); //Token contract address
    mapping(address => bool) referral; //Determine the referral type

    //Contract details
    address public creator; //Creator address
    address public fundsWallet = 0x62e0b52F0a7AD4bB7b87Ce41e132bCBC7173EB96;
    string public version = '0.2'; //Contract version

    //Price related
    uint256 public USDPriceInWei; // 0.1 cent (0.001$) in wei
    string public USDPrice;

    //events for log
    event LogFundrisingInitialized(address indexed _creator);
    event LogFundingReceived(address indexed _addr, uint _amount, uint _currentTotal, address _referral);
    event LogBeneficiaryPaid(address indexed _beneficiaryAddress);
    event LogContributorsPayout(address indexed _addr, uint _amount);
    event LogFundingSuccessful(uint _totalRaised);

    //Modifier to prevent execution if ico has ended or is holded
    modifier notFinished() {
        require(state != State.Successful);
        _;
    }

    /**
    * @notice ICO constructor
    * @param _initialUSDInWei initial usd value on wei
    */
    constructor(uint _initialUSDInWei) public {

        creator = msg.sender; //Creator is set from deployer address
        USDPriceInWei = _initialUSDInWei;

        emit LogFundrisingInitialized(creator); //Log contract initialization

    }

    function setReferralType(address _user, bool _type) onlyAdmin(1) public {
      referral[_user] = _type;
    }

    /**
    * @notice contribution handler
    */
    function contribute(address _target, uint256 _value, address _reff) public notFinished payable {
        require(now > PRESALEStart); //This time must be equal or greater than the start time

        address user;
        uint remaining;
        uint256 tokenBought;
        uint256 temp;
        uint256 refBase;

        //If the address is not zero the caller must be an admin
        if(_target != address(0) && level[msg.sender] >= 1){
          user = _target; //user is set by admin
          remaining = _value.mul(1e18); //value contributed is set by admin
          refBase = _value; //value for referral calc
        } else { //If the address is zero or the caller is not an admin
          user = msg.sender; //user is same as caller
          remaining = msg.value.mul(1e18); //value is same as sent
          refBase = msg.value; //value for referral calc
        }

        totalRaised = totalRaised.add(remaining.div(1e18)); //ether received updated

        //Tokens bought calculation
        while(remaining > 0){

          (temp,remaining) = tokenBuyCalc(remaining);
          tokenBought = tokenBought.add(temp);

        }

        temp = 0; //Clear temporal variable

        totalDistributed = totalDistributed.add(tokenBought); //Whole tokens sold updated

        //Check for presale limit
        if(state == State.PRESALE){
          require(totalDistributed <= 5000000 * (10**18));
        }

        //Transfer tokens to user
        tokenReward.transfer(user,tokenBought);

        //Referral checks
        if(_reff != address(0) && _reff != user){ //referral cannot be zero or self

          //Check if referral receives eth or tokens
          if(referral[_reff] == true){ //If eth
            //Check current rate
            if(state == State.PRESALE){//Presale Rate
              //100%/10 = 10%
              _reff.transfer(refBase.div(10));
              totalEthRefDistributed = totalEthRefDistributed.add(refBase.div(10));

            } else {//Mainsale rate
              //100%/20= 5%
              _reff.transfer(refBase.div(20));
              totalEthRefDistributed = totalEthRefDistributed.add(refBase.div(20));

            }
          } else {//if tokens
            //Check current rate
            if(state == State.PRESALE){//Presale Rate
              //100%/10 = 10%
              tokenReward.transfer(_reff,tokenBought.div(10));
              totalRefDistributed = totalRefDistributed.add(tokenBought.div(10));
            } else {//Mainsale rate
              //100%/20= 5%
              tokenReward.transfer(_reff,tokenBought.div(20));
              totalRefDistributed = totalRefDistributed.add(tokenBought.div(20));
            }
          }
        }

        emit LogFundingReceived(user, msg.value, totalRaised, _reff); //Log the purchase

        fundsWallet.transfer(address(this).balance); //Eth is send to fundsWallet
        emit LogBeneficiaryPaid(fundsWallet); //Log transaction

        checkIfFundingCompleteOrExpired(); //Execute state checks
    }


    /**
    * @notice tokenBought calculation function
    * @param _value is the amount of eth multiplied by 1e18
    */
    function tokenBuyCalc(uint _value) internal view returns (uint sold,uint remaining) {

      uint256 tempPrice = USDPriceInWei; //0.001$ in wei

      //Determine state to set current price
      if(state == State.PRESALE){ //Presale price

            tempPrice = tempPrice.mul(400); //0.001$ * 400 = 0.4$
            sold = _value.div(tempPrice); //here occurs decimal correction

            return (sold,0);

      } else { //state == State.MAINSALE - Mainsale price

            tempPrice = tempPrice.mul(600); //0.001$ * 600 = 0.6$
            sold = _value.div(tempPrice); //here occurs decimal correction

            return (sold,0);

        }
}

    /**
    * @notice Process to check contract current status
    */
    function checkIfFundingCompleteOrExpired() public {

        if ( now > SaleDeadline && state != State.Successful){ //If deadline is reached and not yet successful

            state = State.Successful; //ICO becomes Successful
            completedAt = now; //ICO is complete

            emit LogFundingSuccessful(totalRaised); //we log the finish
            successful(); //and execute closure

        } else if(state == State.PRESALE && now >= MAINSALEStart ) {

            state = State.MAINSALE; //We get on next stage

        }

    }

    /**
    * @notice successful closure handler
    */
    function successful() public {
        require(state == State.Successful); //When successful

        uint256 temp = tokenReward.balanceOf(address(this)); //Remanent tokens handle

        tokenReward.transfer(creator,temp); //Transfer remanent tokens
        emit LogContributorsPayout(creator,temp); //Log transaction

        fundsWallet.transfer(address(this).balance); //Eth is send to fundsWallet
        emit LogBeneficiaryPaid(fundsWallet); //Log transaction
    }

    /**
    * @notice set usd price on wei
    * @param _value wei value
    */
    function setPrice(uint _value, string _price) public onlyAdmin(2) {

      USDPriceInWei = _value;
      USDPrice = _price;

    }

    /**
    * @notice Function to claim any token stuck on contract
    * @param _address Address of target token
    */
    function externalTokensRecovery(ERC20Basic _address) onlyAdmin(2) public{
        require(state == State.Successful); //Only when sale finish

        uint256 remainder = _address.balanceOf(address(this)); //Check remainder tokens
        _address.transfer(msg.sender,remainder); //Transfer tokens to admin

    }

    /*
    * @dev Direct payments handler
    */
    function () public payable {

        //Forward to contribute function
        //zero address, no custom value, no referral
        contribute(address(0),0,address(0));

    }
}