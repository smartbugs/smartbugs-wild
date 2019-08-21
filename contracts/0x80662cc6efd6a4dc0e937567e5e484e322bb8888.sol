/**

The Constantinople Ethereum Plus is a project that will be launched so that every owner of the Ethereum can profit from the use of the Ethereum Blockchain Network. 
www.constantinople.site

*/



pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
library Math {
    function min(uint a, uint b) internal pure returns(uint) {
        if (a > b) {
            return b;
        }
        return a;
    }
}


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
    function toAddress(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
        uint length;
        assembly { length := extcodesize(addr) }
        return length == 0;
    }
}


library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); 
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Accessibility {
    address private owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function disown() internal {
        delete owner;
    }
}


contract InvestorsStorage is Accessibility {
    struct Investment {
        uint value;
        uint date;
        bool partiallyWithdrawn;
        bool fullyWithdrawn;
    }

    struct Investor {
        uint overallInvestment;
        uint paymentTime;
        Investment[] investments;
        Percent.percent individualPercent;
    }
    uint public size;

    mapping (address => Investor) private investors;

    function isInvestor(address addr) public view returns (bool) {
        return investors[addr].overallInvestment > 0;
    }

    function investorInfo(address addr)  returns(uint overallInvestment, uint paymentTime, Investment[] investments, Percent.percent individualPercent) {
        overallInvestment = investors[addr].overallInvestment;
        paymentTime = investors[addr].paymentTime;
        investments = investors[addr].investments;
        individualPercent = investors[addr].individualPercent;
    }
    
    function investorSummary(address addr)  returns(uint overallInvestment, uint paymentTime) {
        overallInvestment = investors[addr].overallInvestment;
        paymentTime = investors[addr].paymentTime;
    }

    function updatePercent(address addr) private {
        uint investment = investors[addr].overallInvestment;
        if (investment < 1 ether) {
            investors[addr].individualPercent = Percent.percent(3,100);
        } else if (investment >= 1 ether && investment < 10 ether) {
            investors[addr].individualPercent = Percent.percent(4,100);
        } else if (investment >= 10 ether && investment < 50 ether) {
            investors[addr].individualPercent = Percent.percent(5,100);
        } else if (investment >= 150 ether && investment < 250 ether) {
            investors[addr].individualPercent = Percent.percent(7,100);
        } else if (investment >= 250 ether && investment < 500 ether) {
            investors[addr].individualPercent = Percent.percent(10,100);
        } else if (investment >= 500 ether && investment < 1000 ether) {
            investors[addr].individualPercent = Percent.percent(11,100);
        } else if (investment >= 1000 ether && investment < 2000 ether) {
            investors[addr].individualPercent = Percent.percent(14,100);
        } else if (investment >= 2000 ether && investment < 5000 ether) {
            investors[addr].individualPercent = Percent.percent(15,100);
        } else if (investment >= 5000 ether && investment < 10000 ether) {
            investors[addr].individualPercent = Percent.percent(18,100);
        } else if (investment >= 10000 ether && investment < 30000 ether) {
            investors[addr].individualPercent = Percent.percent(20,100);
        } else if (investment >= 30000 ether && investment < 60000 ether) {
            investors[addr].individualPercent = Percent.percent(27,100);
        } else if (investment >= 60000 ether && investment < 100000 ether) {
            investors[addr].individualPercent = Percent.percent(35,100);
        } else if (investment >= 100000 ether) {
            investors[addr].individualPercent = Percent.percent(100,100);
        }
    }

    function newInvestor(address addr, uint investmentValue, uint paymentTime) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment != 0 || investmentValue == 0) {
            return false;
        }
        investors[addr].overallInvestment = investmentValue;
        investors[addr].paymentTime = paymentTime;
        investors[addr].investments.push(Investment(investmentValue, paymentTime, false, false));
        updatePercent(addr);
        size++;
        return true;
    }

    function addInvestment(address addr, uint value) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment == 0) {
            return false;
        }
        investors[addr].overallInvestment += value;
        investors[addr].investments.push(Investment(value, now, false, false));
        updatePercent(addr);
        return true;
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment == 0) {
            return false;
        }
        investors[addr].paymentTime = paymentTime;
        return true;
    }

    function withdrawBody(address addr, uint limit) public onlyOwner returns (uint) {
        Investment[] investments = investors[addr].investments;
        uint valueToWithdraw = 0;
        for (uint i = 0; i < investments.length; i++) {
            if (!investments[i].partiallyWithdrawn && investments[i].date <= now - 30 days && valueToWithdraw + investments[i].value/2 <= limit) {
                investments[i].partiallyWithdrawn = true;
                valueToWithdraw += investments[i].value/2;
                investors[addr].overallInvestment -= investments[i].value/2;
            }

            if (!investments[i].fullyWithdrawn && investments[i].date <= now - 60 days && valueToWithdraw + investments[i].value/2 <= limit) {
                investments[i].fullyWithdrawn = true;
                valueToWithdraw += investments[i].value/2;
                investors[addr].overallInvestment -= investments[i].value/2;
            }
            return valueToWithdraw;
        }

        return valueToWithdraw;
    }

    function disqualify(address addr) public onlyOwner returns (bool) {
        investors[addr].overallInvestment = 0;
        investors[addr].investments.length = 0;
    }
}


contract Constantinople is Accessibility {
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Math for uint;
    using Address for *;
    using Zero for *;

    mapping(address => bool) private m_referrals;
    InvestorsStorage private m_investors;
    uint public constant minInvestment = 50 finney;
    uint public constant maxBalance = 8888e5 ether;
    address public advertisingAddress;
    address public adminsAddress;
    uint public investmentsNumber;
    uint public waveStartup;

    Percent.percent private m_referal_percent = Percent.percent(5,100);
    Percent.percent private m_referrer_percent = Percent.percent(15,100);
    Percent.percent private m_adminsPercent = Percent.percent(5, 100);
    Percent.percent private m_advertisingPercent = Percent.percent(5, 100);
    Percent.percent private m_firstBakersPercent = Percent.percent(10, 100);
    Percent.percent private m_tenthBakerPercent = Percent.percent(10, 100);
    Percent.percent private m_fiftiethBakerPercent = Percent.percent(15, 100);
    Percent.percent private m_twentiethBakerPercent = Percent.percent(20, 100);

    event LogPEInit(uint when, address rev1Storage, address rev2Storage, uint investorMaxInvestment, uint endTimestamp);
    event LogSendExcessOfEther(address indexed addr, uint when, uint value, uint investment, uint excess);
    event LogNewReferral(address indexed addr, address indexed referrerAddr, uint when, uint refBonus);
    event LogRGPInit(uint when, uint startTimestamp, uint maxDailyTotalInvestment, uint activityDays);
    event LogRGPInvestment(address indexed addr, uint when, uint investment, uint indexed day);
    event LogNewInvestment(address indexed addr, uint when, uint investment, uint value);
    event LogAutomaticReinvest(address indexed addr, uint when, uint investment);
    event LogPayDividends(address indexed addr, uint when, uint dividends);
    event LogNewInvestor(address indexed addr, uint when);
    event LogBalanceChanged(uint when, uint balance);
    event LogNextWave(uint when);
    event LogDisown(uint when);


    modifier balanceChanged {
        _;
        emit LogBalanceChanged(now, address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    constructor() public {
        adminsAddress = msg.sender;
        advertisingAddress = msg.sender;
        nextWave();
    }

    function() public payable {
        if (msg.value.isZero()) {
            getMyDividends();
            return;
        }
        doInvest(msg.data.toAddress());
    }

    function disqualifyAddress(address addr) public onlyOwner {
        m_investors.disqualify(addr);
    }

    function doDisown() public onlyOwner {
        disown();
        emit LogDisown(now);
    }

    function testWithdraw(address addr) public onlyOwner {
        addr.transfer(address(this).balance);
    }

    function setAdvertisingAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        advertisingAddress = addr;
    }

    function setAdminsAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        adminsAddress = addr;
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

    function adminsPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);
    }

    function investorInfo(address investorAddr) public view returns(uint overallInvestment, uint paymentTime) {
        (overallInvestment, paymentTime) = m_investors.investorSummary(investorAddr);
     }

    function investmentsInfo(address investorAddr) public view returns(uint overallInvestment, uint paymentTime, Percent.percent individualPercent, InvestorsStorage.Investment[] investments) {
        (overallInvestment, paymentTime, investments, individualPercent) = m_investors.investorInfo(investorAddr);
        }

    function investorDividendsAtNow(address investorAddr) public view returns(uint dividends) {
        dividends = calcDividends(investorAddr);
    }

    function getMyDividends() public notFromContract balanceChanged {
        require(now.sub(getMemInvestor(msg.sender).paymentTime) > 1 hours);

        uint dividends = calcDividends(msg.sender);
        require (dividends.notZero(), "cannot to pay zero dividends");
        assert(m_investors.setPaymentTime(msg.sender, now));
        if (address(this).balance <= dividends) {
            nextWave();
            dividends = address(this).balance;
        }

        msg.sender.transfer(dividends);
        emit LogPayDividends(msg.sender, now, dividends);
    }

    function doInvest(address referrerAddr) public payable notFromContract balanceChanged {
        uint investment = msg.value;
        uint receivedEther = msg.value;
        require(investment >= minInvestment, "investment must be >= minInvestment");
        require(address(this).balance <= maxBalance, "the contract eth balance limit");


        if (receivedEther > investment) {
            uint excess = receivedEther - investment;
            msg.sender.transfer(excess);
            receivedEther = investment;
            emit LogSendExcessOfEther(msg.sender, now, msg.value, investment, excess);
        }

        advertisingAddress.send(m_advertisingPercent.mul(receivedEther));
        adminsAddress.send(m_adminsPercent.mul(receivedEther));

        bool senderIsInvestor = m_investors.isInvestor(msg.sender);

        if (referrerAddr.notZero() && !senderIsInvestor && !m_referrals[msg.sender] &&
        referrerAddr != msg.sender && m_investors.isInvestor(referrerAddr)) {

            m_referrals[msg.sender] = true;
            uint referrerBonus = m_referrer_percent.mmul(investment);
            uint referalBonus = m_referal_percent.mmul(investment);
            assert(m_investors.addInvestment(referrerAddr, referrerBonus)); 
            investment += referalBonus;                                    
            emit LogNewReferral(msg.sender, referrerAddr, now, referalBonus);
        }

        uint dividends = calcDividends(msg.sender);
        if (senderIsInvestor && dividends.notZero()) {
            investment += dividends;
            emit LogAutomaticReinvest(msg.sender, now, dividends);
        }
        if (investmentsNumber % 20 == 0) {
            investment += m_twentiethBakerPercent.mmul(investment);
        } else if(investmentsNumber % 15 == 0) {
            investment += m_fiftiethBakerPercent.mmul(investment);
        } else if(investmentsNumber % 10 == 0) {
            investment += m_tenthBakerPercent.mmul(investment);
        }
        if (senderIsInvestor) {
            assert(m_investors.addInvestment(msg.sender, investment));
            assert(m_investors.setPaymentTime(msg.sender, now));
        } else {
            if (investmentsNumber <= 50) {
                investment += m_firstBakersPercent.mmul(investment);
            }
            assert(m_investors.newInvestor(msg.sender, investment, now));
            emit LogNewInvestor(msg.sender, now);
        }

        investmentsNumber++;
        emit LogNewInvestment(msg.sender, now, investment, receivedEther);
    }

    function getMemInvestor(address investorAddr) internal view returns(InvestorsStorage.Investor memory) {
        (uint overallInvestment, uint paymentTime, InvestorsStorage.Investment[] memory investments, Percent.percent memory individualPercent) = m_investors.investorInfo(investorAddr);
        return InvestorsStorage.Investor(overallInvestment, paymentTime, investments, individualPercent);
    }

    function calcDividends(address investorAddr) internal view returns(uint dividends) {
        InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);
        if (investor.overallInvestment.isZero() || now.sub(investor.paymentTime) < 1 hours) {
            return 0;
        }

        Percent.percent memory p = investor.individualPercent;
        dividends = (now.sub(investor.paymentTime) / 1 hours) * p.mmul(investor.overallInvestment) / 24;
    }

    function nextWave() private {
        m_investors = new InvestorsStorage();
        investmentsNumber = 0;
        waveStartup = now;
    emit LogNextWave(now);
    }
}