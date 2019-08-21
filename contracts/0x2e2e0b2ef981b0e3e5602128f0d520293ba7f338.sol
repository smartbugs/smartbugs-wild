pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }
 
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
 
}


library Address {
    function toAddress(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }
}


/**
*/
contract SInv {
    //use of library of safe mathematical operations    
    using SafeMath for uint;
    using Address for *;

    // array containing information about beneficiaries
    mapping(address => uint) public userDeposit;
    //Mapping for how much the User got from Refs
    mapping(address=>uint) public RefBonus;
    //How much the user earned to date
    mapping(address=>uint) public UserEarnings;
    //array containing information about the time of payment
    mapping(address => uint) public userTime;
    //array containing information on interest paid
    mapping(address => uint) public persentWithdraw;
    //fund fo transfer percent
    address public projectFund =  0xB3cE9796aCDC1855bd6Cec85a3403f13C918f1F2;
    //percentage deducted to the advertising fund
    uint projectPercent = 5; // 0,5%
    //time through which you can take dividends
    uint public chargingTime = 24 hours;
    uint public startPercent = 250*10;
    uint public countOfInvestors;
    uint public daysOnline;
    uint public dividendsPaid;

    constructor() public {
        daysOnline = block.timestamp;
    }    
    
    modifier isIssetUser() {
        require(userDeposit[msg.sender] > 0, "Deposit not found");
        _;
    }
 
    modifier timePayment() {
        require(now >= userTime[msg.sender].add(chargingTime), "Too fast payout request");
        _;
    }
    
    function() external payable {
        if (msg.value > 0) {
            //makeDeposit(MyPersonalRefName[msg.data.toAddress()]);
            makeDepositA(msg.data.toAddress());
        }
        else {
            collectPercent();
        }
    }

    //return of interest on the deposit
    function collectPercent() isIssetUser timePayment public {
            uint payout;
            uint multipl;
            (payout,multipl) = payoutAmount(msg.sender);
            userTime[msg.sender] += multipl*chargingTime;
            persentWithdraw[msg.sender] += payout;
            msg.sender.transfer(payout);
            UserEarnings[msg.sender]+=payout;
            dividendsPaid += payout;
            uint UserInitDeposit=userDeposit[msg.sender];
            projectFund.transfer(UserInitDeposit.mul(projectPercent).div(1000));
    }

    //When User decides to reinvest instead of paying out (to get more dividends per day)
    function Reinvest() isIssetUser timePayment external {
        uint payout;
        uint multipl;
        (payout,multipl) = payoutAmount(msg.sender);
        userTime[msg.sender] += multipl*chargingTime;
        userDeposit[msg.sender]+=payout;
        UserEarnings[msg.sender]+=payout;
        uint UserInitDeposit=userDeposit[msg.sender];
        projectFund.transfer(UserInitDeposit.mul(projectPercent).div(1000));
    }
 
    //make a contribution to the system
    function makeDeposit(bytes32 referrer) public payable {
        if (msg.value > 0) {
            if (userDeposit[msg.sender] == 0) {
                countOfInvestors += 1;

                //only give ref bonus if the customer gave a valid ref information
                if((RefNameToAddress[referrer] != address(0x0) && referrer > 0 && TheGuyWhoReffedMe[msg.sender] == address(0x0) && RefNameToAddress[referrer] != msg.sender)) {
                    //get the Address of the guy who reffed mit through his _Ref String and save it in the mapping
                    TheGuyWhoReffedMe[msg.sender] = RefNameToAddress[referrer];
                    newRegistrationwithRef();
                }
            }
            if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
                collectPercent();
            }

            userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
            userTime[msg.sender] = now;

        } else {
            collectPercent();
        }
    }
    
    //function call for fallback
    function makeDepositA(address referrer) public payable {
        if (msg.value > 0) {
            if (userDeposit[msg.sender] == 0) {
                countOfInvestors += 1;
                //only give ref bonus if the customer gave a valid ref information //or has already a ref
                if((referrer != address(0x0) && referrer > 0 && TheGuyWhoReffedMe[msg.sender] == address(0x0) && referrer != msg.sender)) {
                    //get the Address of the guy who reffed mit through his _Ref String and save it in the mapping
                    TheGuyWhoReffedMe[msg.sender] = referrer;
                    newRegistrationwithRef();
                }
            }
            if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
                collectPercent();
            }
            userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
            userTime[msg.sender] = now;

        } else {
            collectPercent();
        }
    }
     
    function getUserEarnings(address addr) public view returns(uint)
    {
        return UserEarnings[addr];
    }
 
    //calculation of the current interest rate on the deposit
    function persentRate() public view returns(uint) {
        return(startPercent);
 
    }
 
    // Withdraw of your referral earnings
    function PayOutRefBonus() external
    {       
        //Check if User has Bonus
        require(RefBonus[msg.sender]>0,"You didn't earn any bonus");
        uint payout = RefBonus[msg.sender];
        //payout the Refbonus
        msg.sender.transfer(payout);
        //Set to 0 since its payed out
        RefBonus[msg.sender]=0;
    }
 
 
    //refund of the amount available for withdrawal on deposit
    function payoutAmount(address addr) public view returns(uint,uint) {
        uint rate = userDeposit[addr].mul(startPercent).div(100000);
        uint interestRate = now.sub(userTime[addr]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate);
        return (withdrawalAmount, interestRate);
    }

 
    mapping (address=>address) public TheGuyWhoReffedMe;
 
    mapping (address=>bytes32) public MyPersonalRefName;
    //for bidirectional search
    mapping (bytes32=>address) public RefNameToAddress;
    
    // referral counter
    mapping (address=>uint256) public referralCounter;
    // referral earnings counter
    mapping (address=>uint256) public referralEarningsCounter;

    //public function to register your ref
    function createMyPersonalRefName(bytes32 _RefName) external payable
    {  
        //ref name shouldn't be 0
        require(_RefName > 0);

        //Check if RefName is already registered
        require(RefNameToAddress[_RefName]==0, "Somebody else owns this Refname");
 
        //check if User already has a ref Name
        require(MyPersonalRefName[msg.sender] == 0, "You already registered a Ref");  
 
        //If not registered
        MyPersonalRefName[msg.sender]= _RefName;

        RefNameToAddress[_RefName]=msg.sender;

    }
 
    function newRegistrationwithRef() private
    {
        //Give Bonus to refs
        CheckFirstGradeRefAdress();
        CheckSecondGradeRefAdress();
        CheckThirdGradeRefAdress();
    }
 
    //first grade ref gets 1% extra
    function CheckFirstGradeRefAdress() private
    {  
        //   3 <-- This one
        //  /
        // 4
 
        //Check if Exist
        if(TheGuyWhoReffedMe[msg.sender]>0) {
        //Send the Ref his 1%
            RefBonus[TheGuyWhoReffedMe[msg.sender]] += msg.value * 2/100;
            referralEarningsCounter[TheGuyWhoReffedMe[msg.sender]] += msg.value * 2/100;
            referralCounter[TheGuyWhoReffedMe[msg.sender]]++;
        }
    }
 
    //second grade ref gets 0,5% extra
    function CheckSecondGradeRefAdress() private
    {
        //     2 <-- This one
        //    /
        //   3
        //  /
        // 4
        //Check if Exist
        if(TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]>0) {
        //Send the Ref his 0,5%
            RefBonus[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]] += msg.value * 2/200;
            referralEarningsCounter[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]] += msg.value * 2/200;
            referralCounter[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]]++;
        }
    }
 
    //third grade ref gets 0,25% extra
    function CheckThirdGradeRefAdress() private
    {
        //       1 <-- This one
        //      /
        //     2
        //    /
        //   3
        //  /
        // 4
        //Check if Exist
        if (TheGuyWhoReffedMe[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]]>0) {

            RefBonus[TheGuyWhoReffedMe[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]]] += msg.value * 2/400;
            referralEarningsCounter[TheGuyWhoReffedMe[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]]] += msg.value * 2/400;
            referralCounter[TheGuyWhoReffedMe[TheGuyWhoReffedMe[TheGuyWhoReffedMe[msg.sender]]]]++;
        }
    }
    
    //Returns your personal RefName, when it is registered
    function getMyRefName(address addr) public view returns(bytes32)
    {
        return (MyPersonalRefName[addr]);
    }

    function getMyRefNameAsString(address addr) public view returns(string) {
        return bytes32ToString(MyPersonalRefName[addr]);
    }

    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}