pragma solidity ^0.4.25;
/**
*
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT
* Web site         - https://two4ever.club
* Telegram_chat - https://t.me/two4everClub
* Twitter          - https://twitter.com/ClubTwo4ever
* Youtube          - https://www.youtube.com/channel/UCl4-t8RS3-kEJIGQN6Xbtng
* Email:           - mailto:admin(at sign)two4ever.club  
* 
* --- Contract configuration:
*   - Daily payment of a deposit of 2%
*   - Minimal contribution 0.01 eth
*   - Currency and payment - ETH
*   - Contribution allocation schemes:
*       -- 5% Referral program (3% first level, 2% second level)
*       -- 7% Advertising
*       -- 5% Operating Expenses
        -- 83% dividend payments
* 
* --- Referral Program:
*   - We have 2 level referral program.
*   - After your referral investment you will receive 3% of his investment 
*   as one time bonus from 1 level and 2% form his referrals.
*   - To become your referral, you future referral should specify your address
*   in field DATA, while transferring ETH.
*   - When making the every deposit, the referral must indicate your wallet in the data field!
*   - You must have a deposit in the contract, otherwise the person invited by you will not be assigned to you
*
* --- Awards:   
*   - The Best Investor
*       Largest investor becomes common referrer for investors without referrer 
*       and get a lump sum of 3% of their deposits. To become winner you must invest
*       more than previous winner.
* 
*   - The Best Promoter
*       Investor with the most referrals becomes common referrer for investors without referrer
*       and get a lump sum of 2% of their deposits. To become winner you must invite more than
*       previous winner.
*
* --- About the Project:
*   ETH cryptocurrency distribution project
*   Blockchain-enabled smart contracts have opened a new era of trustless relationships without intermediaries.
*   This technology opens incredible financial possibilities. Our automated investment distribution model
*   is written into a smart contract, uploaded to the Ethereum blockchain and can be freely accessed online.
*   In order to insure our investors' complete secuirty, full control over the project has been transferred
*   from the organizers to the smart contract: nobody can influence the system's permanent autonomous functioning.
* 
* --- How to invest:
*  1. Send from ETH wallet to the smart contract address any amount from 0.01 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
*     of your wallet.
* --- How to get dividends:
*     Send 0 air to the address of the contract. Be careful. You can get your dividends only once every 24 hours.
*  
* --- RECOMMENDED GAS PRICE: https://ethgasstation.info/
*     You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 
* have private keys.
* 
* Contracts reviewed and approved by pros!
* 
* Main contract - Two4ever. You can view the contract code by scrolling down.
*/
contract Storage {
// define investor model   
    struct investor {
        uint keyIndex;
        uint value;
        uint paymentTime;
        uint refs;
        uint refBonus;
    }
    // define bestAddress model for bestInvestor and bestPromoter
    struct bestAddress {
        uint value;
        address addr;
    }
    // statistic model
    struct recordStats {
        uint strg;
        uint invested;
    }
  
    struct Data {
        mapping(uint => recordStats) stats;
        mapping(address => investor) investors;
        address[] keys;
        bestAddress bestInvestor;
        bestAddress bestPromoter;
    }

    Data private d;

    // define log event when change value of  "bestInvestor" or "bestPromoter" changed
    event LogBestInvestorChanged(address indexed addr, uint when, uint invested);
    event LogBestPromoterChanged(address indexed addr, uint when, uint refs);

    //creating contract 
    constructor() public {
        d.keys.length++;
    }
    //insert new investor  
    function insert(address addr, uint value) public  returns (bool) {
        uint keyIndex = d.investors[addr].keyIndex;
        if (keyIndex != 0) return false;
        d.investors[addr].value = value;
        keyIndex = d.keys.length++;
        d.investors[addr].keyIndex = keyIndex;
        d.keys[keyIndex] = addr;
        updateBestInvestor(addr, d.investors[addr].value);
    
        return true;
    }
    // get full information about investor by "addr"
    function investorFullInfo(address addr) public view returns(uint, uint, uint, uint, uint) {
        return (
        d.investors[addr].keyIndex,
        d.investors[addr].value,
        d.investors[addr].paymentTime,
        d.investors[addr].refs,
        d.investors[addr].refBonus
        );
    }
    // get base information about investor by "addr"
    function investorBaseInfo(address addr) public view returns(uint, uint, uint, uint) {
        return (
        d.investors[addr].value,
        d.investors[addr].paymentTime,
        d.investors[addr].refs,
        d.investors[addr].refBonus
        );
    }
    // get short information about investor by "addr"
    function investorShortInfo(address addr) public view returns(uint, uint) {
        return (
        d.investors[addr].value,
        d.investors[addr].refBonus
        );
    }
    // get current  Best Investor 
    function getBestInvestor() public view returns(uint, address) {
        return (
        d.bestInvestor.value,
        d.bestInvestor.addr
        );
    }

    // get current  Best Promoter 
    function getBestPromoter() public view returns(uint, address) {
        return (
        d.bestPromoter.value,
        d.bestPromoter.addr
        );
    }

    // add referral bonus to address 
    function addRefBonus(address addr, uint refBonus) public  returns (bool) {
        if (d.investors[addr].keyIndex == 0) return false;
        d.investors[addr].refBonus += refBonus;
        return true;
    }

    // add referral bonus to address  and update current Best Promoter value
    function addRefBonusWithRefs(address addr, uint refBonus) public  returns (bool) {
        if (d.investors[addr].keyIndex == 0) return false;
        d.investors[addr].refBonus += refBonus;
        d.investors[addr].refs++;
        updateBestPromoter(addr, d.investors[addr].refs);
        return true;
    }

    //add  amount of invest by the address of  investor 
    function addValue(address addr, uint value) public  returns (bool) {
        if (d.investors[addr].keyIndex == 0) return false;
        d.investors[addr].value += value;
        updateBestInvestor(addr, d.investors[addr].value);
        return true;
    }

    // update statistics
    function updateStats(uint dt, uint invested, uint strg) public {
        d.stats[dt].invested += invested;
        d.stats[dt].strg += strg;
    }

    // get current statistics
    function stats(uint dt) public view returns (uint invested, uint strg) {
        return ( 
        d.stats[dt].invested,
        d.stats[dt].strg
        );
    }

    // update current "Best Investor"
    function updateBestInvestor(address addr, uint investorValue) internal {
        if(investorValue > d.bestInvestor.value){
            d.bestInvestor.value = investorValue;
            d.bestInvestor.addr = addr;
            emit LogBestInvestorChanged(addr, now, d.bestInvestor.value);
        }      
    }

    // update value of current "Best Promoter"
    function updateBestPromoter(address addr, uint investorRefs) internal {
        if(investorRefs > d.bestPromoter.value){
            d.bestPromoter.value = investorRefs;
            d.bestPromoter.addr = addr;
            emit LogBestPromoterChanged(addr, now, d.bestPromoter.value);
        }      
    }

    // set time of payment 
    function setPaymentTime(address addr, uint paymentTime) public  returns (bool) {
        if (d.investors[addr].keyIndex == 0) return false;
        d.investors[addr].paymentTime = paymentTime;
        return true;
    }

    // set referral bonus
    function setRefBonus(address addr, uint refBonus) public  returns (bool) {
        if (d.investors[addr].keyIndex == 0) return false;
        d.investors[addr].refBonus = refBonus;
        return true;
    }

    // check if contains such address in storage
    function contains(address addr) public view returns (bool) {
        return d.investors[addr].keyIndex > 0;
    }

    // return current number of investors
    function size() public view returns (uint) {
        return d.keys.length;
    }
}
//contract for restricting access to special functionality
contract Accessibility {

    address public owner;
    //access modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }
    //constructor with assignment of contract holder value
    constructor() public {
        owner = msg.sender;
    }
    // deletion of contract holder
    function waiver() internal {
        delete owner;
    }
}

//main contract
contract Two4ever is Accessibility  {
    //connecting needed libraries
    using Helper for *;
    using Math for *;
    // define internal model of percents
    struct percent {
        uint val;
        uint den;
    }
  // contract name
    string public  name;
  // define storage
    Storage private strg;
  // collection of key value pairs ffor referrals
    mapping(address => address) private referrals;
  //variable for admin address
    address public adminAddr;
  //variable for  advertise address
    address public advertiseAddr;
  // time  when start current wave
    uint public waveStartup;

    uint public totalInvestors;
    uint public totalInvested;
  // define constants
  //size of minimal investing
    uint public constant minInvesment = 10 finney; // 0.01 eth
  //max size of balance 
    uint public constant maxBalance = 100000 ether; 
  // time period when dividends can be accrued
    uint public constant dividendsPeriod = 24 hours; //24 hours

  // define contracts percents 
    // percent of main dividends 
    percent private dividends;
    // percent of admin interest 
    percent private adminInterest ;
   // percent of 1-st level referral 
    percent private ref1Bonus ;
   // percent of 2-nd level referral 
    percent private ref2Bonus ;
   // percent of advertising interest 
    percent private advertisePersent ;
    // event call when Balance has Changed
    event LogBalanceChanged(uint when, uint balance);

  // custom modifier for  event broadcasting
    modifier balanceChanged {
        _;
        emit LogBalanceChanged(now, address(this).balance);
    }
    // constructor
    // creating  contract. This function call once when contract is publishing.
    constructor()  public {
        name = "two4ever.club";
      // set admin address by account address who  has published
        adminAddr = msg.sender;
        advertiseAddr = msg.sender;
    //define value of main percents
        dividends = percent(2, 100); //  2%
        adminInterest = percent(5, 100); //  5%
        ref1Bonus = percent(3, 100); //  3%
        ref2Bonus = percent(2, 100); //  2%
        advertisePersent = percent(7, 100); //  7% 
    // start new wave 
        startNewWave();
    }
    // set the value of the wallet address for advertising expenses
    function setAdvertisingAddress(address addr) public onlyOwner {
        if(addr.notEmptyAddr())
        {
            advertiseAddr = addr;
        }
    }
    //set the value of the wallet address for operating expenses
    function setAdminsAddress(address addr) public onlyOwner {
        if(addr.notEmptyAddr())
        {
            adminAddr = addr;
        }
    }
    // deletion of contract holder
    function doWaiver() public onlyOwner {
        waiver();
    }

    //functions is calling when transfer money to address of this contract
    function() public payable {
    // investor get him dividends when send value = 0   to address of this contract
        if (msg.value == 0) {
            getDividends();
            return;
        }

    // getting referral address from data of request 
        address a = msg.data.toAddr();
    //call invest function
        invest(a);
    }
    // private function for get dividends
    function _getMydividends(bool withoutThrow) private {
    // get  investor info
        Storage.investor memory investor = getMemInvestor(msg.sender);
    //check if investor exists
        if(investor.keyIndex <= 0){
            if(withoutThrow){
                return;
            }
            revert("sender is not investor");
    }

    // calculate how many days have passed after last payment
        uint256 daysAfter = now.sub(investor.paymentTime).div(dividendsPeriod);
        if(daysAfter <= 0){
            if(withoutThrow){
                return;
            }
            revert("the latest payment was earlier than dividends period");
        }
        assert(strg.setPaymentTime(msg.sender, now));

    // calc valaue of dividends
        uint value = Math.div(Math.mul(dividends.val,investor.value),dividends.den) * daysAfter;
    // add referral bonus to dividends
        uint divid = value+ investor.refBonus; 
    // check if enough money on balance of contract for payment
        if (address(this).balance < divid) {
            startNewWave();
            return;
        }
  
    // send dividends and ref bonus
        if (investor.refBonus > 0) {
            assert(strg.setRefBonus(msg.sender, 0));
    //send dividends and referral bonus to investor
            msg.sender.transfer(value+investor.refBonus);
        } else {
    //send dividends to investor
            msg.sender.transfer(value);
        }      
    }
    // public function for calling get dividends
    function getDividends() public balanceChanged {
        _getMydividends(false);
    }
    // function for investing money from investor
    function invest(address ref) public payable balanceChanged {
    //check minimum requirements
        require(msg.value >= minInvesment, "msg.value must be >= minInvesment");
        require(address(this).balance <= maxBalance, "the contract eth balance limit");
    //save current money value
        uint value = msg.value;
    // ref system works only once for sender-referral
        if (!referrals[msg.sender].notEmptyAddr()) {
      //process first level of referrals
            if (notZeroNotSender(ref) && strg.contains(ref)) {
          //calc the reward
                uint reward = Math.div(Math.mul(ref1Bonus.val,value),ref1Bonus.den);
                assert(strg.addRefBonusWithRefs(ref, reward)); // referrer 1 bonus
                referrals[msg.sender] = ref;

        //process second level of referrals
                if (notZeroNotSender(referrals[ref]) && strg.contains(referrals[ref]) && ref != referrals[ref]) { 
         //calc the reward
                    reward = Math.div(Math.mul(ref2Bonus.val, value),ref2Bonus.den);
                    assert(strg.addRefBonus(referrals[ref], reward)); // referrer 2 bonus
                }
                }else{
         // get current Best Investor  
                Storage.bestAddress memory bestInvestor = getMemBestInvestor();
        // get current Best Promoter  
                Storage.bestAddress memory bestPromoter = getMemBestPromoter();

                if(notZeroNotSender(bestInvestor.addr)){
                    assert(strg.addRefBonus(bestInvestor.addr, Math.div(Math.mul(ref1Bonus.val, value),ref1Bonus.den))); // referrer 1 bonus
                    referrals[msg.sender] = bestInvestor.addr;
                }
                if(notZeroNotSender(bestPromoter.addr)){
                    assert(strg.addRefBonus(bestPromoter.addr, Math.div(Math.mul(ref2Bonus.val, value),ref2Bonus.den))); // referrer 2 bonus
                    referrals[msg.sender] = bestPromoter.addr;
                }
            }
    }

        _getMydividends(true);

    // send admins share
        adminAddr.transfer(Math.div(Math.mul(adminInterest.val, msg.value),adminInterest.den));
    // send advertise share 
        advertiseAddr.transfer(Math.div(Math.mul(advertisePersent.val, msg.value),advertisePersent.den));
    
    // update statistics
        if (strg.contains(msg.sender)) {
            assert(strg.addValue(msg.sender, value));
            strg.updateStats(now, value, 0);
        } else {
            assert(strg.insert(msg.sender, value));
            strg.updateStats(now, value, 1);
        }
    
        assert(strg.setPaymentTime(msg.sender, now));
    //increase count of investments
        totalInvestors++;
    //increase amount of investments
        totalInvested += msg.value;
    }
/*views */
    // show number of investors
    function investorsNumber() public view returns(uint) {
        return strg.size()-1;
    // -1 because see Storage constructor where keys.length++ 
    }
    //show current contract balance
    function balanceETH() public view returns(uint) {
        return address(this).balance;
    }
    // show value of dividend percent
    function DividendsPercent() public view returns(uint) {
        return dividends.val;
    }
    // show value of admin percent
    function AdminPercent() public view returns(uint) {
        return adminInterest.val;
    }
     // show value of advertise persent
    function AdvertisePersent() public view returns(uint) {
        return advertisePersent.val;
    }
    // show value of referral of 1-st level percent
    function FirstLevelReferrerPercent() public view returns(uint) {
        return ref1Bonus.val; 
    }
    // show value of referral of 2-nd level percent
    function SecondLevelReferrerPercent() public view returns(uint) {
        return ref2Bonus.val;
    }
    // show value of statisctics by date
    function statistic(uint date) public view returns(uint amount, uint user) {
        (amount, user) = strg.stats(date);
    }
    // show investor info  by address
    function investorInfo(address addr) public view returns(uint value, uint paymentTime, uint refsCount, uint refBonus, bool isReferral) {
        (value, paymentTime, refsCount, refBonus) = strg.investorBaseInfo(addr);
        isReferral = referrals[addr].notEmptyAddr();
    }
  // show best investor info
    function bestInvestor() public view returns(uint invested, address addr) {
        (invested, addr) = strg.getBestInvestor();
    }
  // show best promoter info
    function bestPromoter() public view returns(uint refs, address addr) {
        (refs, addr) = strg.getBestPromoter();
    }
  // return full investor info by address
    function getMemInvestor(address addr) internal view returns(Storage.investor) {
        (uint a, uint b, uint c, uint d, uint e) = strg.investorFullInfo(addr);
        return Storage.investor(a, b, c, d, e);
    }
  //return best investor  info 
    function getMemBestInvestor() internal view returns(Storage.bestAddress) {
        (uint value, address addr) = strg.getBestInvestor();
        return Storage.bestAddress(value, addr);
    }
  //return best investor promoter 
    function getMemBestPromoter() internal view returns(Storage.bestAddress) {
        (uint value, address addr) = strg.getBestPromoter();
        return Storage.bestAddress(value, addr);
    }
    // check if address is not empty and not equal sender address
    function notZeroNotSender(address addr) internal view returns(bool) {
        return addr.notEmptyAddr() && addr != msg.sender;
    }

/**end views */
// start wave  
    function startNewWave() private {
        strg = new Storage();
        totalInvestors = 0;
        waveStartup = now;
    }
}

// Math library with simple arithmetical functions
library Math {
    //multiplying
    function mul(uint256 num1, uint256 num2) internal pure returns (uint256) {
        return  num1 * num2;
        if (num1 == 0) {
            return 0;
        }
        return num1 * num2;   
    }
    //divide
    function div(uint256 num1, uint256 num2) internal pure returns (uint256) {
        uint256 result = 0;
        require(num2 > 0); 
        result = num1 / num2;
        return result;
    }
    //subtract 
    function sub(uint256 num1, uint256 num2) internal pure returns (uint256) {
        require(num2 <= num1);
        uint256 result = 0;
        result = num1 - num2;
        return result;
    }
    //add 
    function add(uint256 num1, uint256 num2) internal pure returns (uint256) {
        uint256 result = num1 + num2;
        require(result >= num1);

        return result;
    }
    //module
    function mod(uint256 num1, uint256 num2) internal pure returns (uint256) {
        require(num2 != 0);
        return num1 % num2;
    } 
}
// Helper library with simple additional functions
library Helper{
    //check if the address is not empty
    function notEmptyAddr(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }
     //check if the address is  empty
    function isEmptyAddr(address addr) internal pure returns(bool) {
        return addr == address(0);
    }
    // convert to address 
    function toAddr(uint source) internal pure returns(address) {
        return address(source);
    }
    //convert  from bytes to address
    function toAddr(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }
}