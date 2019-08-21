pragma solidity ^0.4.24;

/* - version: 1.0.0
*  - Ref bonuses 2-3%
*  - Invest dividends 3-4% if you invest more than 10 ETH you'll get 4%!
*
*/
contract MainContract {
    address owner;

    address advertisingAddress;

    uint private constant minInvest = 5 finney; // 0.005 eth
    using Calc for uint;
    using PercentCalc for PercentCalc.percent;
    using Zero for *;
    using compileLibrary for *;

    struct User {
        uint idx;
        uint value;
        uint bonus;
        bool invested10Eth;
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

    event logPayDividends(uint value, uint when, address indexed addr, string text);

    event logPayBonus(uint value, uint when, address indexed addr, string text);

    event notEnoughETH(uint when, string text);

    constructor() public {
        owner = msg.sender;
        users.length++;
        emit logsDataConstructor(msg.sender, now, "constructor");
    }

    //     PercentCalc
    PercentCalc.percent private dividendPercent = PercentCalc.percent(3); // 3%
    PercentCalc.percent private refPercent = PercentCalc.percent(2); // 2%
    PercentCalc.percent private advertisingPercent = PercentCalc.percent(8); // 8%
    PercentCalc.percent private ownerPercent = PercentCalc.percent(5); // 5%

    // dividend percent Bonus
    PercentCalc.percent private dividendPercentBonus = PercentCalc.percent(4); // 4%
    PercentCalc.percent private refPercentBonus = PercentCalc.percent(3); // 3%
    //     PercentCalc

    function() public payable {
        if (msg.value == 0) {
            fetchDividends();
            return;
        }

        require(msg.value >= minInvest, "value can't be < than 0.005");

        if (investorsStorage[msg.sender].idx > 0) {
            investorsStorage[msg.sender].value += msg.value;
            
            if (!investorsStorage[msg.sender].invested10Eth && msg.value >= 10 ether) {
                investorsStorage[msg.sender].invested10Eth = true;
            }
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
                invested10Eth: msg.value >= 10 ether,
                payTime : now
            });
        }

        sendValueToOwner(msg.value);
        sendValueToAdv(msg.value);

        emit logsDataPayable(msg.value, now, msg.sender);
    }


    function setUserBonus(address addr, uint value) private {
        uint bonus = refPercent.getValueByPercent(value);
        if (investorsStorage[addr].idx > 0) {
            if (investorsStorage[addr].invested10Eth) bonus = refPercentBonus.getValueByPercent(value);
            investorsStorage[addr].bonus += bonus;
            emit logPayBonus(bonus, now, addr, "investor got bonuses!");
        } else {
            sendValueToAdv(bonus);
        }
    }

    function fetchDividends() private {
        User memory inv = findInvestorByAddress(msg.sender);
        require(inv.idx > 0, "payer is not investor");
        uint payValueByTime = now.sub(inv.payTime).getDiffValue(12 hours);
        require(payValueByTime > 0, "the payment was earlier than 12 hours");

        uint dividendValue = (dividendPercent.getValueByPercent(inv.value) * payValueByTime) / 2;
        if (inv.invested10Eth) dividendValue = (dividendPercentBonus.getValueByPercent(inv.value) * payValueByTime) / 2;

        if (address(this).balance < dividendValue + inv.bonus) {
            emit notEnoughETH(now, "not enough eth");
            return;
        }

        if (inv.bonus > 0) {
            sendDividendsWithBonus(msg.sender, dividendValue, inv.bonus);
        } else {
            sendDividends(msg.sender, dividendValue);
        }
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
        emit logPayDividends(value + bonus, now, addr, "dividends with bonus");
        addr.transfer(value + bonus);
        investorsStorage[addr].bonus = 0;
    }

    function findInvestorByAddress(address addr) internal view returns (User) {
        return User(
            investorsStorage[addr].idx,
            investorsStorage[addr].value,
            investorsStorage[addr].bonus,
            investorsStorage[addr].invested10Eth,
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