pragma solidity >0.4.99 <0.6.0;


library Zero {
    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function requireNotZero(uint val) internal pure {
        require(val != 0, "require not zero value");
    }

    function notZero(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns(bool) {
        return addr == address(0);
    }

    function isZero(uint a) internal pure returns(bool) {
        return a == 0;
    }

    function notZero(uint a) internal pure returns(bool) {
        return a != 0;
    }
}


library Percent {
    struct percent {
        uint num;
        uint den;
    }

    function mul(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a*p.num/p.den;
    }

    function div(percent storage p, uint a) internal view returns (uint) {
        return a/p.num*p.den;
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
        uint b = mul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function add(percent storage p, uint a) internal view returns (uint) {
        return a + mul(p, a);
    }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
        return Percent.percent(p.num, p.den);
    }

    function mmul(percent memory p, uint a) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a*p.num/p.den;
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
        return a/p.num*p.den;
    }

    function msub(percent memory p, uint a) internal pure returns (uint) {
        uint b = mmul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function madd(percent memory p, uint a) internal pure returns (uint) {
        return a + mmul(p, a);
    }
}


library Address {
    function toAddress(bytes memory source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
        uint length;
        assembly { length := extcodesize(addr) }
        return length == 0;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Accessibility {
    address private owner;
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }
	
	constructor() public {
		owner = msg.sender;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }
}


contract InvestorsStorage is Accessibility {
    using SafeMath for uint;

    struct Investor {
        uint paymentTime;
        uint fundDepositType_1;
        uint fundDepositType_2;
        uint fundDepositType_3;
        uint referrerBonus;
        uint numberReferral;
    }
    uint public size;

    mapping (address => Investor) private investors;

    function isInvestor(address addr) public view returns (bool) {
        uint fundDeposit = investors[addr].fundDepositType_1.add(investors[addr].fundDepositType_2).add(investors[addr].fundDepositType_3);
        return fundDeposit > 0;
    }

    function investorInfo(address addr) public view returns(uint paymentTime,
        uint fundDepositType_1, uint fundDepositType_2, uint fundDepositType_3,
        uint referrerBonus, uint numberReferral) {
        paymentTime = investors[addr].paymentTime;
        fundDepositType_1 = investors[addr].fundDepositType_1;
        fundDepositType_2 = investors[addr].fundDepositType_2;
        fundDepositType_3 = investors[addr].fundDepositType_3;
        referrerBonus = investors[addr].referrerBonus;
        numberReferral = investors[addr].numberReferral;
    }

    function newInvestor(address addr, uint investment, uint paymentTime, uint typeDeposit) public onlyOwner returns (bool) {
        Investor storage inv = investors[addr];
        uint fundDeposit = inv.fundDepositType_1.add(inv.fundDepositType_2).add(inv.fundDepositType_3);
        if (fundDeposit != 0 || investment == 0) {
            return false;
        }
        if (typeDeposit < 0 || typeDeposit > 2) {
            return false;
        }

        if (typeDeposit == 0) {
            inv.fundDepositType_1 = investment;
        } else if (typeDeposit == 1) {
            inv.fundDepositType_2 = investment;
        } else if (typeDeposit == 2) {
            inv.fundDepositType_3 = investment;
        }

        inv.paymentTime = paymentTime;
        size++;
        return true;
    }

    function checkSetZeroFund(address addr, uint currentTime) public onlyOwner {
        uint numberDays = currentTime.sub(investors[addr].paymentTime) / 1 days;

        if (investors[addr].fundDepositType_1 > 0 && numberDays > 30) {
            investors[addr].fundDepositType_1 = 0;
        }
        if (investors[addr].fundDepositType_2 > 0 && numberDays > 90) {
            investors[addr].fundDepositType_2 = 0;
        }
        if (investors[addr].fundDepositType_3 > 0 && numberDays > 180) {
            investors[addr].fundDepositType_3 = 0;
        }
    }

    function addInvestment(address addr, uint investment, uint typeDeposit) public onlyOwner returns (bool) {
        if (typeDeposit == 0) {
            investors[addr].fundDepositType_1 = investors[addr].fundDepositType_1.add(investment);
        } else if (typeDeposit == 1) {
            investors[addr].fundDepositType_2 = investors[addr].fundDepositType_2.add(investment);
        } else if (typeDeposit == 2) {
            investors[addr].fundDepositType_3 = investors[addr].fundDepositType_3.add(investment);
        } else if (typeDeposit == 10) {
            investors[addr].referrerBonus = investors[addr].referrerBonus.add(investment);
        }

        return true;
    }

    function addReferral(address addr) public onlyOwner {
        investors[addr].numberReferral++;
    }

    function getCountReferral(address addr) public view onlyOwner returns (uint) {
        return investors[addr].numberReferral;
    }

    function getReferrerBonus(address addr) public onlyOwner returns (uint) {
        uint referrerBonus = investors[addr].referrerBonus;
        investors[addr].referrerBonus = 0;
        return referrerBonus;
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        uint fundDeposit = investors[addr].fundDepositType_1.add(investors[addr].fundDepositType_2).add(investors[addr].fundDepositType_3);
        if (fundDeposit == 0) {
            return false;
        }
        investors[addr].paymentTime = paymentTime;
        return true;
    }
}

contract Ethbank is Accessibility {
    using Percent for Percent.percent;
    using SafeMath for uint;

    // easy read for investors
    using Address for *;
    using Zero for *;

    bool public isDemo;
	uint public simulateDate;

    mapping(address => bool) private m_referrals;
    InvestorsStorage private m_investors;

    // automatically generates getters
    uint public constant minInvesment = 10 finney;
    address payable public advertisingAddress;
    uint public investmentsNumber;
    uint public totalEthRaised;


    // percents tariff
    Percent.percent private m_1_percent = Percent.percent(1,100);            // 1/100 *100% = 1%
    Percent.percent private m_2_percent = Percent.percent(2,100);            // 2/100 *100% = 2%
    Percent.percent private m_3_percent = Percent.percent(3,100);            // 3/100 *100% = 3%

    // percents referal
    Percent.percent private m_3_referal_percent = Percent.percent(3,100);        // 3/100 *100% = 3%
    Percent.percent private m_3_referrer_percent = Percent.percent(3,100);       // 3/100 *100% = 3%

    Percent.percent private m_5_referal_percent = Percent.percent(5,100);        // 5/100 *100% = 5%
    Percent.percent private m_4_referrer_percent = Percent.percent(4,100);       // 4/100 *100% = 4%

    Percent.percent private m_10_referal_percent = Percent.percent(10,100);      // 10/100 *100% = 10%
    Percent.percent private m_5_referrer_percent = Percent.percent(5,100);       // 5/100 *100% = 5%

    // percents advertising
    Percent.percent private m_advertisingPercent = Percent.percent(10, 100);      // 10/100  *100% = 10%

    // more events for easy read from blockchain
    event LogNewReferral(address indexed addr, address indexed referrerAddr, uint when, uint referralBonus);
    event LogNewInvesment(address indexed addr, uint when, uint investment, uint typeDeposit);
    event LogAutomaticReinvest(address indexed addr, uint when, uint investment, uint typeDeposit);
    event LogPayDividends(address indexed addr, uint when, uint dividends);
    event LogPayReferrerBonus(address indexed addr, uint when, uint referrerBonus);
    event LogNewInvestor(address indexed addr, uint when, uint typeDeposit);
    event LogBalanceChanged(uint when, uint balance);
    event ChangeTime(uint256 _newDate, uint256 simulateDate);

    modifier balanceChanged {
        _;
        emit LogBalanceChanged(getCurrentDate(), address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    constructor(address payable _advertisingAddress) public {
        advertisingAddress = _advertisingAddress;
        m_investors = new InvestorsStorage();
        investmentsNumber = 0;
    }

    function() external payable {
        if (msg.value.isZero()) {
            getMyDividends();
            return;
        } else {
			doInvest(msg.data.toAddress(), 0);
		}
    }

    function setAdvertisingAddress(address payable addr) public onlyOwner {
        addr.requireNotZero();
        advertisingAddress = addr;
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size();
    }

    function balanceETH() public view returns(uint) {
        return address(this).balance;
    }

    function advertisingPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_advertisingPercent.num, m_advertisingPercent.den);
    }

    function investorInfo(address investorAddr) public view returns(uint paymentTime, bool isReferral,
                        uint fundDepositType_1, uint fundDepositType_2, uint fundDepositType_3,
                        uint referrerBonus, uint numberReferral) {
        (paymentTime, fundDepositType_1, fundDepositType_2, fundDepositType_3, referrerBonus, numberReferral) = m_investors.investorInfo(investorAddr);
        isReferral = m_referrals[investorAddr];
    }

    function investorDividendsAtNow(address investorAddr) public view returns(uint dividends) {
        dividends = calcDividends(investorAddr);
    }

    function doInvest(address referrerAddr, uint typeDeposit) public payable notFromContract balanceChanged {
        uint investment = msg.value;
        require(investment >= minInvesment, "investment must be >= minInvesment");
        require(typeDeposit >= 0 && typeDeposit < 3, "wrong deposit type");

        bool senderIsInvestor = m_investors.isInvestor(msg.sender);

        if (referrerAddr.notZero() && !senderIsInvestor && !m_referrals[msg.sender] &&
        referrerAddr != msg.sender && m_investors.isInvestor(referrerAddr)) {

            m_referrals[msg.sender] = true;
            m_investors.addReferral(referrerAddr);
            uint countReferral = m_investors.getCountReferral(referrerAddr);
            uint referrerBonus = 0;
            uint referralBonus = 0;

            if (countReferral <= 9) {
                referrerBonus = m_3_referrer_percent.mmul(investment);
                referralBonus = m_3_referal_percent.mmul(investment);
            }
            if (countReferral > 9 && countReferral <= 29) {
                referrerBonus = m_4_referrer_percent.mmul(investment);
                referralBonus = m_5_referal_percent.mmul(investment);
            }
            if (countReferral > 29) {
                referrerBonus = m_5_referrer_percent.mmul(investment);
                referralBonus = m_10_referal_percent.mmul(investment);
            }

            assert(m_investors.addInvestment(referrerAddr, referrerBonus, 10)); // add referrer bonus
            assert(m_investors.addInvestment(msg.sender, referralBonus, 10)); // add referral bonus
            emit LogNewReferral(msg.sender, referrerAddr, getCurrentDate(), referralBonus);
        } else {
            // commission
            advertisingAddress.transfer(m_advertisingPercent.mul(investment));
        }

        // automatic reinvest - prevent burning dividends
        uint dividends = calcDividends(msg.sender);
        if (senderIsInvestor && dividends.notZero()) {
            investment = investment.add(dividends);
            emit LogAutomaticReinvest(msg.sender, getCurrentDate(), dividends, typeDeposit);
        }

        if (senderIsInvestor) {
            // update existing investor
            assert(m_investors.addInvestment(msg.sender, investment, typeDeposit));
            assert(m_investors.setPaymentTime(msg.sender, getCurrentDate()));
        } else {
            // create new investor
            assert(m_investors.newInvestor(msg.sender, investment, getCurrentDate(), typeDeposit));
            emit LogNewInvestor(msg.sender, getCurrentDate(), typeDeposit);
        }

        investmentsNumber++;
        totalEthRaised = totalEthRaised.add(msg.value);
        emit LogNewInvesment(msg.sender, getCurrentDate(), investment, typeDeposit);
    }

    function getMemInvestor(address investorAddr) internal view returns(InvestorsStorage.Investor memory) {
        (uint paymentTime,
        uint fundDepositType_1, uint fundDepositType_2,
        uint fundDepositType_3, uint referrerBonus, uint numberReferral) = m_investors.investorInfo(investorAddr);
        return InvestorsStorage.Investor(paymentTime, fundDepositType_1, fundDepositType_2, fundDepositType_3, referrerBonus, numberReferral);
    }

    function getMyDividends() public payable notFromContract balanceChanged {
        address payable investor = msg.sender;
        require(investor.notZero(), "require not zero address");
        uint currentTime = getCurrentDate();

        uint receivedEther = msg.value;
        require(receivedEther.isZero(), "amount ETH must be 0");

        //check if 1 day passed after last payment
        require(currentTime.sub(getMemInvestor(investor).paymentTime) > 24 hours, "must pass 24 hours after the investment");

        // calculate dividends
        uint dividends = calcDividends(msg.sender);
        require (dividends.notZero(), "cannot to pay zero dividends");

        m_investors.checkSetZeroFund(investor, currentTime);

        // update investor payment timestamp
        assert(m_investors.setPaymentTime(investor, currentTime));

        // transfer dividends to investor
        investor.transfer(dividends);
        emit LogPayDividends(investor, currentTime, dividends);
    }

    function getMyReferrerBonus() public notFromContract balanceChanged {
        uint referrerBonus = m_investors.getReferrerBonus(msg.sender);
        require (referrerBonus.notZero(), "cannot to pay zero referrer bonus");

        // transfer referrer bonus to investor
        msg.sender.transfer(referrerBonus);
        emit LogPayReferrerBonus(msg.sender, getCurrentDate(), referrerBonus);
    }

    function calcDividends(address investorAddress) internal view returns(uint dividends) {
        InvestorsStorage.Investor memory inv = getMemInvestor(investorAddress);
        dividends = 0;
        uint fundDeposit = inv.fundDepositType_1.add(inv.fundDepositType_2).add(inv.fundDepositType_3);
        uint numberDays = getCurrentDate().sub(inv.paymentTime) / 1 days;

        // safe gas if dividends will be 0
        if (fundDeposit.isZero() || numberDays.isZero()) {
            return 0;
        }

        if (inv.fundDepositType_1 > 0) {
            if (numberDays > 30) {
                dividends = 30 * m_1_percent.mmul(inv.fundDepositType_1);
                dividends = dividends.add(inv.fundDepositType_1);
            } else {
                dividends = numberDays * m_1_percent.mmul(inv.fundDepositType_1);
            }
        }
        if (inv.fundDepositType_2 > 0) {
            if (numberDays > 90) {
                dividends = dividends.add(90 * m_2_percent.mmul(inv.fundDepositType_2));
                dividends = dividends.add(inv.fundDepositType_2);
            } else {
                dividends = dividends.add(numberDays * m_2_percent.mmul(inv.fundDepositType_2));
            }
        }
        if (inv.fundDepositType_3 > 0) {
            if (numberDays > 180) {
                dividends = dividends.add(180 * m_3_percent.mmul(inv.fundDepositType_3));
                dividends = dividends.add(inv.fundDepositType_3);
            } else {
                dividends = dividends.add(numberDays * m_3_percent.mmul(inv.fundDepositType_3));
            }
        }
    }

    function getCurrentDate() public view returns (uint) {
        if (isDemo) {
            return simulateDate;
        }
        return now;
    }
	
    function setSimulateDate(uint256 _newDate) public onlyOwner {
        if (isDemo) {
            require(_newDate > simulateDate);
            emit ChangeTime(_newDate, simulateDate);
            simulateDate = _newDate;
        } 
    }

    function setDemo() public onlyOwner {
        if (investorsNumber() == 0) {
            isDemo = true;
        }
    }


}