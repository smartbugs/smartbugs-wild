pragma solidity ^ 0.4 .24;
library MathForInterset {
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0);
        uint256 c = _a / _b;
        return c;
    }
}
contract Hermes {
    using MathForInterset
    for uint;
    uint constant public MINIMUM_INVEST = 10000000000000000 wei;
    uint public DAY_VALUE = 0;
    uint public DAY_LIMIT = 200 ether;//first limit
    uint public DEPOSIT_AMOUNT;
    uint public PERCENT_FOR_MARKETING = 1500000000;
    address[] public ADDRESSES;
    mapping(address => Investor) public INVESTORS;
    address public ADMIN_ADDR;
    struct Investor {
        uint id;
        uint percentCount;
        uint deposit;
        uint date;
        address referrer;
        uint reinvestID;
        uint actualValue;
        uint stage;
        uint startReinvestDate;
        uint dayLimitValue;
    }
    event reinvest(address addr, uint active);
    event payout(address addr, uint amount, string eventType);
    constructor() public {
        ADMIN_ADDR = msg.sender;
    }

    function Invest(address _referrer) private {
        if (msg.value == 0 ether) {

            if (msg.sender == ADMIN_ADDR) {
                payAll();
            } else {
                paySelfByAddress(msg.sender);
            }
        } else {
            if (INVESTORS[msg.sender].deposit == 0) {
                require(DAY_VALUE + msg.value < DAY_LIMIT, "DAY LIMIT!!!");
                require(INVESTORS[msg.sender].dayLimitValue + msg.value < DAY_LIMIT / 2, "DAY LIMIT!!!");
                INVESTORS[msg.sender].dayLimitValue += msg.value;
                DAY_VALUE += msg.value;
                ADDRESSES.push(msg.sender);
                uint id = ADDRESSES.length;
                ADMIN_ADDR.transfer((msg.value.mul(PERCENT_FOR_MARKETING).div(10000000000)).mul(1));
                DEPOSIT_AMOUNT += msg.value;
                if (msg.value >= MINIMUM_INVEST) {
                    if (INVESTORS[_referrer].deposit != 0) {
                        if (INVESTORS[_referrer].deposit >= 3 ether) {
                            uint value = (msg.value.mul(200000000).div(10000000000));
                            msg.sender.transfer(value);
                            value = (msg.value.mul(250000000).div(10000000000));
                            _referrer.transfer(value);
                            if (INVESTORS[_referrer].stage < 1) {

                                INVESTORS[_referrer].stage = 1;
                            }
                        }
                        address nextReferrer = _referrer;
                        for (uint i = 0; i < 4; i++) {
                            if (INVESTORS[nextReferrer].referrer == address(0x0)) {
                                break;
                            }
                            if (INVESTORS[INVESTORS[nextReferrer].referrer].reinvestID != 3) {
                                if (INVESTORS[INVESTORS[nextReferrer].referrer].deposit >= 3 ether) {
                                    if (INVESTORS[INVESTORS[nextReferrer].referrer].stage <= 2) {
                                        if (INVESTORS[INVESTORS[nextReferrer].referrer].stage <= i + 2) {
                                            value = (msg.value.mul(100000000).div(10000000000));
                                            INVESTORS[INVESTORS[nextReferrer].referrer].stage = i + 2;
                                            INVESTORS[nextReferrer].referrer.transfer(value);
                                        }
                                    }
                                }
                                if (INVESTORS[INVESTORS[nextReferrer].referrer].deposit >= 5 ether) {
                                    if (INVESTORS[INVESTORS[nextReferrer].referrer].stage < i + 2) {
                                        INVESTORS[INVESTORS[nextReferrer].referrer].stage = i + 2;
                                    }
                                    if (i + 2 == 2) {
                                        value = (msg.value.mul(150000000).div(10000000000));
                                    }
                                    if (i + 2 == 3) {
                                        value = (msg.value.mul(75000000).div(10000000000));
                                    }
                                    if (i + 2 == 4) {
                                        value = (msg.value.mul(50000000).div(10000000000));
                                    }
                                    if (i + 2 == 5) {
                                        value = (msg.value.mul(25000000).div(10000000000));
                                    }
                                    INVESTORS[nextReferrer].referrer.transfer(value);
                                }
                            }
                            nextReferrer = INVESTORS[nextReferrer].referrer;
                            if (nextReferrer == address(0x0)) {
                                break;
                            }
                        }
                    } else {
                        _referrer = address(0x0);
                    }
                } else {
                    _referrer = address(0x0);
                }
                INVESTORS[msg.sender] = Investor(id, 0, msg.value, now, _referrer, 0, msg.value, 0, 0, msg.value);
            } else {
                require(DAY_VALUE + msg.value < DAY_LIMIT, "DAY LIMIT!!!");
                require(INVESTORS[msg.sender].dayLimitValue + msg.value < DAY_LIMIT / 2, "DAY LIMIT!!!");
                INVESTORS[msg.sender].dayLimitValue += msg.value;
                DAY_VALUE += msg.value;
                if (INVESTORS[msg.sender].reinvestID == 3) {
                    INVESTORS[msg.sender].reinvestID = 0;
                }
                INVESTORS[msg.sender].deposit += msg.value;
                INVESTORS[msg.sender].actualValue += msg.value;
                DEPOSIT_AMOUNT += msg.value;
                ADMIN_ADDR.transfer((msg.value.mul(PERCENT_FOR_MARKETING).div(10000000000)).mul(1));
                if (msg.value == 0.000012 ether) {
                    require(INVESTORS[msg.sender].reinvestID == 0, "REINVEST BLOCK");
                    INVESTORS[msg.sender].reinvestID = 1;
                    INVESTORS[msg.sender].startReinvestDate = now;
                    emit reinvest(msg.sender, 1);
                }
                if (msg.value == 0.000013 ether) {
                    uint interval = 0;
                    uint interest = 0;
                    require(INVESTORS[msg.sender].reinvestID == 1, "REINVEST BLOCK");

                    if ((DEPOSIT_AMOUNT >= 0 ether) && (DEPOSIT_AMOUNT < 1000 ether)) {
                        interest = 125000000; //1.25
                    }
                    if ((DEPOSIT_AMOUNT >= 1000 ether) && (DEPOSIT_AMOUNT <= 2000 ether)) {
                        interest = 100000000; //1
                    }
                    if ((DEPOSIT_AMOUNT >= 2000 ether) && (DEPOSIT_AMOUNT <= 3000 ether)) {
                        interest = 75000000; //0.75
                    }
                    if (DEPOSIT_AMOUNT > 3000 ether) {
                        interest = 60000000; //0.6
                    }
                    ////
                    interval = (now - INVESTORS[msg.sender].startReinvestDate) / 1 days;
                    interest = (interest + INVESTORS[msg.sender].stage * 10000000) * interval;
                    value = (INVESTORS[msg.sender].deposit.mul(interest).div(10000000000)).mul(1);
                    INVESTORS[msg.sender].percentCount += interest;
                    INVESTORS[msg.sender].deposit += value;
                    INVESTORS[msg.sender].actualValue = INVESTORS[msg.sender].deposit;
                    INVESTORS[msg.sender].reinvestID = 0;
                    emit reinvest(msg.sender, 0);
                }
            }
        }
    }

    function() payable public {
        require(msg.value >= MINIMUM_INVEST || msg.value == 0.000012 ether || msg.value == 0 ether || msg.value == 0.000013 ether, "Too small amount, minimum 0.01 ether");
        require(INVESTORS[msg.sender].percentCount < 10000000000, "You can't invest");
        require(INVESTORS[msg.sender].reinvestID != 1 || msg.value == 0.000013 ether, "You can't invest");
        Invest(bytesToAddress(msg.data));
    }



    function paySelfByAddress(address addr) public {

        uint interest = 0;
        if ((DEPOSIT_AMOUNT >= 0) && (DEPOSIT_AMOUNT < 1000 ether)) {
            interest = 125000000; //1.25
        }
        if ((DEPOSIT_AMOUNT >= 1000 ether) && (DEPOSIT_AMOUNT <= 2000 ether)) {
            interest = 100000000; //1
        }
        if ((DEPOSIT_AMOUNT >= 2000 ether) && (DEPOSIT_AMOUNT <= 3000 ether)) {
            interest = 75000000; //0.75
        }
        if (DEPOSIT_AMOUNT >= 3000 ether) {
            interest = 60000000; //0.6
        }
        Investor storage stackObject = INVESTORS[addr];
        uint value = 0;
        uint interval = (now - INVESTORS[addr].date) / 1 days;
        if (interval > 0) {
            interest = ((INVESTORS[addr].stage * 10000000) + interest) * interval;
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if (INVESTORS[addr].reinvestID == 1) {
                uint residualInterest = 0;
                value = (stackObject.actualValue.mul(interest).div(10000000000));
                residualInterest = (((stackObject.actualValue + value) - stackObject.deposit).mul(10000000000)).div(stackObject.deposit);
                if (INVESTORS[addr].percentCount + residualInterest >= 10000000000) {

                    value = (stackObject.deposit * 2) - INVESTORS[addr].actualValue;
                    INVESTORS[addr].reinvestID = 2;
                    INVESTORS[addr].percentCount = 10000000000;
                }
                INVESTORS[addr].actualValue += value;
                INVESTORS[addr].date = now;
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if (INVESTORS[addr].reinvestID == 0 || INVESTORS[addr].reinvestID == 2) {
                if (INVESTORS[addr].percentCount != 10000000000) {
                    if (INVESTORS[addr].percentCount + interest >= 10000000000) {
                        interest = 10000000000 - INVESTORS[addr].percentCount;

                    }
                    INVESTORS[addr].percentCount += interest;
                    value = (stackObject.deposit.mul(interest).div(10000000000));
                    addr.transfer(value);
                    emit payout(addr, value, "Interest payment");
                    INVESTORS[addr].date = now;
                } else {
                    if (INVESTORS[addr].reinvestID == 2) {
                        interest = 2000000000 * interval;
                    }
                    value = (stackObject.deposit.mul(interest).div(10000000000));
                    if (INVESTORS[addr].actualValue < value) {
                        value = INVESTORS[addr].actualValue;
                    }
                    INVESTORS[addr].actualValue -= value;
                    addr.transfer(value);
                    emit payout(addr, value, "Body payout");
                    INVESTORS[addr].date = now;
                    if (INVESTORS[addr].actualValue == 0) {
                        INVESTORS[addr].reinvestID = 3;
                        INVESTORS[addr].deposit = 0;
                        INVESTORS[addr].percentCount = 0;
                        INVESTORS[addr].actualValue = 0;
                    }
                }
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
    }


    function payAll() private {
        DAY_VALUE = 0;
        //////////////////////////////////////////////
        for (uint i = 0; i < ADDRESSES.length; i++) {
            INVESTORS[ADDRESSES[i]].dayLimitValue = 0;
            paySelfByAddress(ADDRESSES[i]);
        }

        if (address(this).balance < 1000 ether) {
            DAY_LIMIT = 200 ether;
        }
        if (address(this).balance >= 1000 ether && address(this).balance < 2000 ether) {
            DAY_LIMIT = 400 ether;
        }
        if (address(this).balance >= 2000 && address(this).balance < 4000 ether) {
            DAY_LIMIT = 600 ether;
        }
        if (address(this).balance >= 4000 ether) {
            DAY_LIMIT = 1000000000 ether;
        }
    }

    function bytesToAddress(bytes bys) private pure returns(address addr) {
        assembly {
            addr: = mload(add(bys, 20))
        }
    }
}