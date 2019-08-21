pragma solidity ^0.4.24;

/* - https://eth-invest.com/      version: 1.0.1
*  - Ref bonuses 8% per day, 0.33% every hour
*  - Invest dividends 8%
*  - Invest and get 120% But u can't get more than 120%
*  - Dont snooze, you can earn ETH only the first fifteen days!!!
*  - Invite your friends, you will get 4% for each other, they will get +2% to their deposit. Also, if u already got 120% u can get invite bonuses
*  - Have a nice day :)
*/
contract MainContract {
    address owner;
    address advertisingAddress;

    uint private constant minInvest = 10 finney; // 0.01 eth
    
    uint constant maxPayment = 360; // maxPayment value every hour your payment + 1; 24 hours * 15 days = 360 :)
    using Calc for uint;
    using PercentCalc for PercentCalc.percent;
    using Zero for *;
    using compileLibrary for *;

    struct User {
        uint idx;
        uint value;
        uint bonus;
        uint payValue;
        uint payTime;
    }

    mapping(address => User) investorsStorage;

    address[] users;

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    event logsDataPayable(uint value, uint time, address indexed addr);
    event logsDataConstructor(address creater, uint when, string text);
    event newInvestor(address indexed addr, uint when, uint value);
    event investToProject(address creater, uint when, string text);
    event logPaymentUser(uint value, uint when, address indexed addr, string text);
    event logPayDividends(uint value, uint when, address indexed addr, string text);
    event logPayBonus(uint value, uint when, address indexed addr, string text);
    event notEnoughETH(uint when, string text);
    
    constructor() public {
        owner = msg.sender;
        users.length++;
        emit logsDataConstructor(msg.sender, now, "constructor");
    }

    //     PercentCalc
    PercentCalc.percent private dividendPercent = PercentCalc.percent(8); // 8%
    PercentCalc.percent private refPercent = PercentCalc.percent(2); // 2%
    PercentCalc.percent private refPercentBonus = PercentCalc.percent(4); // 4% 
    PercentCalc.percent private advertisingPercent = PercentCalc.percent(5); // 5%
    PercentCalc.percent private ownerPercent = PercentCalc.percent(2); // 2%

    function() public payable {
        if (msg.value == 0) {
            fetchDividends();
            return;
        }

        require(msg.value >= minInvest, "value can't be < than 0.01");
        if (investorsStorage[msg.sender].idx > 0) { // dont send more if u have already invested!!! 
            sendValueToAdv(msg.value);
        } else {
            address ref = msg.data.toAddr();
            uint idx = investorsStorage[msg.sender].idx;
            uint value = msg.value;
            idx = users.length++;
            if (ref.notZero() && investorsStorage[ref].idx > 0) {
                setUserBonus(ref, msg.value);
                value += refPercent.getValueByPercent(value);
            }
            emit newInvestor(msg.sender, now, msg.value);
            investorsStorage[msg.sender] = User({
                idx : idx,
                value : value,
                bonus : 0,
                payValue: 0,
                payTime : now
                });
        }

        sendValueToOwner(msg.value);
        sendValueToAdv(msg.value);

        emit logsDataPayable(msg.value, now, msg.sender);
    }


    function setUserBonus(address addr, uint value) private {
        uint bonus = refPercentBonus.getValueByPercent(value);
        if (investorsStorage[addr].idx > 0) {
            investorsStorage[addr].bonus += bonus;
        } else {
            sendValueToAdv(bonus);
        }
    }

    function fetchDividends() private {
        User memory inv = findInvestorByAddress(msg.sender);
        require(inv.idx > 0, "Payer is not investor");
        uint payValueByTime = now.sub(inv.payTime).getDiffValue(1 hours);
        require(payValueByTime > 0, "the payment was earlier than 1 hours");
        uint newPayValye = payValueByTime + inv.payValue; // do not snooze
        if (newPayValye > maxPayment) {
            require(inv.bonus > 0, "you've already got 120%");
            sendUserBonus(msg.sender, inv.bonus);
        } else {
            uint dividendValue = (dividendPercent.getValueByPercent(inv.value) * payValueByTime) / 24;
            if (address(this).balance < dividendValue + inv.bonus) {
                emit notEnoughETH(now, "not enough Eth at address");
                return;
            }
            emit logPaymentUser(newPayValye, now, msg.sender, 'gotPercent value');
            investorsStorage[msg.sender].payValue += payValueByTime;
            if (inv.bonus > 0) {
                sendDividendsWithBonus(msg.sender, dividendValue, inv.bonus);
            } else {
                sendDividends(msg.sender, dividendValue);
            }
        }
    }


    function sendUserBonus(address addr, uint bonus) private {
        addr.transfer(bonus);
        investorsStorage[addr].bonus = 0;
        emit logPayBonus(bonus, now, addr, "Investor got bonuses!");
    }

    function setAdvertisingAddress(address addr) public onlyOwner {
        advertisingAddress = addr;
    }


    function sendDividends(address addr, uint value) private {
        updatePayTime(addr, now);
        emit logPayDividends(value, now, addr, "dividends");
        addr.transfer(value);
    }

    function sendDividendsWithBonus(address addr, uint value, uint bonus) private {
        updatePayTime(addr, now);
        addr.transfer(value + bonus);
        investorsStorage[addr].bonus = 0;
        emit logPayDividends(value + bonus, now, addr, "dividends with bonus");
    }

    function findInvestorByAddress(address addr) internal view returns (User) {
        return User(
            investorsStorage[addr].idx,
            investorsStorage[addr].value,
            investorsStorage[addr].bonus,
            investorsStorage[addr].payValue,
            investorsStorage[addr].payTime
        );
    }

    function sendValueToOwner(uint val) private {
        owner.transfer(ownerPercent.getValueByPercent(val));
    }

    function sendValueToAdv(uint val) private {
        advertisingAddress.transfer(advertisingPercent.getValueByPercent(val));
    }


    function updatePayTime(address addr, uint time) private returns (bool) {
        if (investorsStorage[addr].idx == 0) return false;
        investorsStorage[addr].payTime = time;
        return true;
    }
}




// Calc library
library Calc {
    function getDiffValue(uint _a, uint _b) internal pure returns (uint) {
        require(_b > 0);
        uint c = _a / _b;
        return c;
    }

    function sub(uint _a, uint _b) internal pure returns (uint) {
        require(_b <= _a);
        uint c = _a - _b;

        return c;
    }
}
// Percent Calc library
library PercentCalc {
    struct percent {
        uint val;
    }

    function getValueByPercent(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a * p.val / 100;
    }
}

library Zero {
    function notZero(address addr) internal pure returns (bool) {
        return !(addr == address(0));
    }
}


library compileLibrary {
    function toAddr(bytes source) internal pure returns (address addr) {
        assembly {addr := mload(add(source, 0x14))}
        return addr;
    }
}