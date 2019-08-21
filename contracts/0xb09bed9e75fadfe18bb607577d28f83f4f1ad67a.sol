pragma solidity 0.4.25;

/**
 *  - GAIN UP TO 200% IN 20 DAYS
 *
 *  - Minimal contribution 0.05 eth
 *  - Currency and payment - ETH
 *  - Contribution allocation schemes:
 *    -- 91 % payments (7 % to referrer (see Referral Program below))
 *    -- 6 % marketing
 *    -- 3 % administration fee
 *
 *
 *  Percentage of your profit depends on balance of the contract:
 *
 *              balance     |   %   |  profit
 *            -------------------------------
 *            <  500 ETH    |  6 %  |   120 %
 *            >  500 ETH    |  7 %  |   140 %
 *            > 1500 ETH    |  8 %  |   160 %
 *            > 2500 ETH    |  9 %  |   180 %
 *            > 5000 ETH    | 10 %  |   200 %
 *
 *
 *    Referral program:
 *    Add your referrer address to DATA field when you invest or reinvest ETH:
 *     - You will get instant cashback 2 % of your Deposit
 *     - Your referrer will get bonus 7 % while withdrawing Dividends
 *
 *     -- You can add new referrer every time you invest money
 *     -- Referrer MUST be a participant of the project
 *     -- You can't be referrer for yourself
 *     -- If you have no referrer 7 % goes to marketing expenses
 *
 *
 *  How to use:
 *  1. Send ETH (more than 0.05) to make an investment
 *  2a. Claim your profit at any time by sending 0 ether transaction
 *  Also you can send less than 0.05 ETH and you will get back your sended amount and dividends.
 *  OR
 *  2b. Send more ETH to reinvest AND get your profit at the same time
 *
 *  Any deposit brings money only 20 days from the time of investment.
 *
 *  RECOMMENDED GAS LIMIT: 250000
 *  RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 *
 *  Contract reviewed and approved by experts!
 *
 */



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

contract SmartDoubler {
    using SafeMath for uint;

    address public owner;
    address marketing;
    address admin;

    mapping (address => uint) index;
    mapping (address => mapping (uint => uint)) deposit;
    mapping (address => mapping (uint => uint)) finish;
    mapping (address => uint) checkpoint;

    mapping (address => uint) refBonus;

    event LogInvestment(address indexed _addr, uint _value);
    event LogPayment(address indexed _addr, uint _value);
    event LogReferralInvestment(address indexed _referrer, address indexed _referral, uint _value);

    constructor(address _marketing, address _admin) public {
        owner = msg.sender;
        marketing = _marketing;
        admin = _admin;
    }

    function renounceOwnership() external {
        require(msg.sender == owner);
        owner = 0x0;
    }

    function bytesToAddress(bytes _source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(_source,0x14))
        }
        return parsedreferrer;
    }

    function refSystem() internal {
        address _referrer = bytesToAddress(bytes(msg.data));
        if (_referrer != msg.sender && getInfo3(_referrer) > 0) {
            marketing.transfer(msg.value * 6 / 100);
            msg.sender.transfer(msg.value * 2 / 100);
            refBonus[_referrer] += msg.value * 7 / 100;

            emit LogReferralInvestment(_referrer, msg.sender, msg.value);
        } else {
            marketing.transfer(msg.value * 15 / 100);
        }
    }

    function getInterest() public view returns (uint) {

        if (address(this).balance >= 5000e18) {
            return 10;
        }
        if (address(this).balance >= 2500e18) {
            return 9;
        }
        if (address(this).balance >= 1500e18) {
            return 8;
        }
        if (address(this).balance >= 500e18) {
            return 7;
        } else {
            return 6;
        }
    }

    function() external payable {
        if (msg.value < 50000000000000000) {
            msg.sender.transfer(msg.value);
            withdraw();
        } else {
            invest();
        }
    }

    function invest() public payable {

        require(msg.value >= 50000000000000000);
        admin.transfer(msg.value * 3 / 100);

        if (getInfo3(msg.sender) + getInfo4(msg.sender) > 0) {
            withdraw();
            if (deposit[msg.sender][0] > 0) {
                index[msg.sender] += 1;
            }
        }

        checkpoint[msg.sender] = block.timestamp;
        finish[msg.sender][index[msg.sender]] = block.timestamp + (20 * 1 days);
        deposit[msg.sender][index[msg.sender]] = msg.value;

        if (msg.data.length != 0) {
            refSystem();
        } else {
            marketing.transfer(msg.value * 15 / 100);
        }

        emit LogInvestment(msg.sender, msg.value);
    }

    function withdraw() public {

        uint _payout = refBonus[msg.sender];
        refBonus[msg.sender] = 0;

        for (uint i = 0; i <= index[msg.sender]; i++) {
            if (checkpoint[msg.sender] < finish[msg.sender][i]) {
                if (block.timestamp > finish[msg.sender][i]) {
                    _payout = _payout.add((deposit[msg.sender][i].mul(getInterest()).div(100)).mul(finish[msg.sender][i].sub(checkpoint[msg.sender])).div(1 days));
                } else {
                    _payout = _payout.add((deposit[msg.sender][i].mul(getInterest()).div(100)).mul(block.timestamp.sub(checkpoint[msg.sender])).div(1 days));
                }
            }
        }

        if (_payout > 0) {
            checkpoint[msg.sender] = block.timestamp;
            msg.sender.transfer(_payout);

            emit LogPayment(msg.sender, _payout);
        }
    }

    function getInfo1(address _address) public view returns(uint Invested) {
        uint _sum;
        for (uint i = 0; i <= index[_address]; i++) {
            if (block.timestamp < finish[_address][i]) {
                _sum += deposit[_address][i];
            }
        }
        Invested = _sum;
    }

    function getInfo2(address _address, uint _number) public view returns(uint Deposit_N) {
        if (block.timestamp < finish[_address][_number - 1]) {
            Deposit_N = deposit[_address][_number - 1];
        } else {
            Deposit_N = 0;
        }
    }

    function getInfo3(address _address) public view returns(uint Dividends) {
        uint _payout;
        for (uint i = 0; i <= index[_address]; i++) {
            if (checkpoint[_address] < finish[_address][i]) {
                if (block.timestamp > finish[_address][i]) {
                    _payout = _payout.add((deposit[_address][i].mul(getInterest()).div(100)).mul(finish[_address][i].sub(checkpoint[_address])).div(1 days));
                } else {
                    _payout = _payout.add((deposit[_address][i].mul(getInterest()).div(100)).mul(block.timestamp.sub(checkpoint[_address])).div(1 days));
                }
            }
        }
        Dividends = _payout;
    }

    function getInfo4(address _address) public view returns(uint Bonuses) {
        Bonuses = refBonus[_address];
    }
}