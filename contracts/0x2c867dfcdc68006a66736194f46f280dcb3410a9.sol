pragma solidity ^0.4.24;

contract Sansara {
    address public owner;
    address public commissions;
    address public techSupport;
    address public salary;
    address public advert;
    uint constant public MASS_TRANSACTION_LIMIT = 150;
    uint constant public MINIMUM_INVEST = 1e16 wei;
    uint constant public INTEREST = 1;
    uint constant public COMMISSIONS_FEE = 1;
    uint constant public TECH_SUPPORT_FEE = 1;
    uint constant public SALARY_FEE = 3;
    uint constant public ADV_FEE = 8;
    uint constant public CASHBACK_FEE = 2;
    uint constant public REF_FEE = 5;

    uint public depositAmount;
    uint public round;
    uint public lastPaymentDate;
    address[] public addresses;
    mapping(address => Investor) public investors;
    bool public pause;

    struct Investor
    {
        uint id;
        uint deposit;
        uint deposits;
        uint date;
        uint investDate;
        address referrer;
    }
    
    event Invest(address addr, uint amount, address referrer);
    event Payout(address addr, uint amount, string eventType, address from);
    event NextRoundStarted(uint round, uint date, uint deposit);

    modifier onlyOwner {if (msg.sender == owner) _;}

    constructor() public {
        owner = msg.sender;
        addresses.length = 1;
        round = 1;
    }

    function transferOwnership(address addr) onlyOwner public {
        owner = addr;
    }
    
    function setProvisionAddresses(address tech, address sal, address adv, address comm) onlyOwner public {
        techSupport = tech;
        salary = sal;
        advert = adv;
        commissions = comm;
    }

    function addInvestors(address[] _addr, uint[] _deposit, uint[] _date, address[] _referrer) onlyOwner public {
        // add initiated investors
        for (uint i = 0; i < _addr.length; i++) {
            uint id = addresses.length;
            if (investors[_addr[i]].deposit == 0) {
                addresses.push(_addr[i]);
                depositAmount += investors[_addr[i]].deposit;
            }

            investors[_addr[i]] = Investor(id, _deposit[i], 1, _date[i], _date[i], _referrer[i]);
            emit Invest(_addr[i], _deposit  [i], _referrer[i]);
        }
        lastPaymentDate = now;
    }

    function() payable public {
        if (owner == msg.sender) {
            return;
        }

        if (0 == msg.value) {
            payoutSelf();
            return;
        }

        require(false == pause, "Sansara is restarting. Please wait.");
        require(msg.value >= MINIMUM_INVEST, "Too small amount, minimum 0.01 ether");
        Investor storage user = investors[msg.sender];

        if (user.id == 0) {
            // ensure that payment not from hacker contract
            msg.sender.transfer(0 wei);
            addresses.push(msg.sender);
            user.id = addresses.length;
            user.date = now;

            // referrer
            address referrer = bytesToAddress(msg.data);
            if (investors[referrer].deposit > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }
        } else {
            payoutSelf();
        }

        // save investor
        user.deposit += msg.value;
        user.deposits += 1;
        user.investDate = now;

        emit Invest(msg.sender, msg.value, user.referrer);

        depositAmount += msg.value;
        lastPaymentDate = now;

        techSupport.transfer((msg.value / 100) * TECH_SUPPORT_FEE);
        advert.transfer((msg.value / 100) * ADV_FEE);
        salary.transfer((msg.value / 100) * SALARY_FEE);
        commissions.transfer((msg.value / 100) * COMMISSIONS_FEE);

        uint bonusAmount = (msg.value / 100) * REF_FEE; // referrer commission for all deposits
        uint cashbackAmount = (msg.value / 100) * CASHBACK_FEE;

        if (user.referrer > 0x0) {
            if (user.referrer.send(bonusAmount)) {
                emit Payout(user.referrer, bonusAmount, "referral", msg.sender);
            }

            if (msg.sender.send(cashbackAmount)) {
                emit Payout(msg.sender, cashbackAmount, "cash-back", 0);
            }
        } else {
            advert.transfer(bonusAmount + cashbackAmount);
        }
    }

    function payout(uint offset) public
    {
        if (pause == true) {
            doRestart();
            return;
        }

        uint txs;
        uint amount;

        for (uint idx = addresses.length - offset - 1; idx >= 1 && txs < MASS_TRANSACTION_LIMIT; idx--) {
            address addr = addresses[idx];
            if (investors[addr].date + 20 hours > now || investors[addr].investDate + 400 days < now) {
                continue;
            }

            amount = getInvestorDividendsAmount(addr);
            investors[addr].date = now;

            if (address(this).balance < amount) {
                pause = true;
                return;
            }

            if (addr.send(amount)) {
                emit Payout(addr, amount, "bulk-payout", 0);
            }

            txs++;
        }
    }

    function payoutSelf() private {
        require(investors[msg.sender].id > 0, "Investor not found.");
        uint amount = getInvestorDividendsAmount(msg.sender);

        investors[msg.sender].date = now;
        if (address(this).balance < amount) {
            pause = true;
            return;
        }

        msg.sender.transfer(amount);
        emit Payout(msg.sender, amount, "self-payout", 0);
    }

    function doRestart() private {
        uint txs;
        address addr;

        for (uint i = addresses.length - 1; i > 0; i--) {
            addr = addresses[i];
            addresses.length -= 1;
            delete investors[addr];
            if (txs++ == MASS_TRANSACTION_LIMIT) {
                return;
            }
        }

        emit NextRoundStarted(round, now, depositAmount);
        pause = false;
        round += 1;
        depositAmount = 0;
        lastPaymentDate = now;
    }

    function getInvestorCount() public view returns (uint) {
        return addresses.length - 1;
    }

    function getInvestorDividendsAmount(address addr) public view returns (uint) {
        return investors[addr].deposit / 100 * INTEREST * (now - investors[addr].date) / 1 days;
    }

    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}