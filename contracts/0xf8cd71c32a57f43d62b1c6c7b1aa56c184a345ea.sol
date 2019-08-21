pragma solidity ^0.4.25;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract Ownable {
    address public owner;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Ethebit is Ownable{

    using SafeMath for uint256;

    mapping(address => uint256) investments;
    mapping(address => uint256) joined;
    mapping(address => uint256) withdrawals;
    mapping(address => uint256) referrerBalance;
    mapping(uint256 => address) refLinkToAddress;
    mapping(address => uint256) refAddressToLink;

    uint256 public minimum = 0.01 ether;
    uint256 percentDay = 83;
    uint256 public countInvestor;
    uint256 public amountWeiRaised;
    uint256 public lastInvestment;
    uint256 public lastInvestmentTime;
    uint256 countReferralLink = 100;
    address public lastInvestorAddress;

    uint256 DAYS_PROFIT = 30;

    address public wallet;
    address public support;

    event Invest(address indexed investor, uint256 amount);
    event Withdraw(address indexed investor, uint256 amount);
    event ReferrerWithdraw(address indexed investor, uint256 amount);
    event ReferrerProfit(address indexed hunter, address indexed referral, uint256 amount);
    event MakeReferralLink(address indexed investor, uint256 refNumber);

    constructor(address _wallet, address _support) public {
        //No more owner for this contract
        owner = address(0);

        wallet = _wallet;
        support = _support;
    }

    function() payable public {
        invest(0);
    }

    function invest(uint256 _refLink) public payable returns (uint256) {
        require(msg.value >= minimum);
        address _investor = msg.sender;
        uint256 currentDay = now;
        if (currentDay < 1542240000) { //Thu, 15 Nov 2018 00:00:00 GMT
            revert();
        }
        if (investments[_investor] == 0) {
            countInvestor = countInvestor.add(1);
        }
        if (investments[_investor] > 0){
            withdrawProfit();
        }
        investments[_investor] = investments[_investor].add(msg.value);
        joined[_investor] = currentDay;
        amountWeiRaised = amountWeiRaised.add(msg.value);
        lastInvestment = msg.value;
        lastInvestmentTime = currentDay;
        lastInvestorAddress = _investor;
        if (_refLink > 100) {
            makeReferrerProfit(_refLink);
        } else {
            support.transfer(msg.value.mul(10).div(100)); //test's
        }

        wallet.transfer(msg.value.mul(10).div(100)); //test's
        emit Invest(_investor, msg.value);
        return _refLink;
    }

    function getBalance(address _address) view public returns (uint256 _result) {
        _result = 0;
        if (investments[_address] > 0) {
            uint256 currentDay = now;
            uint256 minutesCount = currentDay.sub(joined[_address]).div(1 minutes);
            uint256 daysAfter = minutesCount.div(1440);
            if (daysAfter > DAYS_PROFIT) {
                daysAfter = DAYS_PROFIT;
            }
            uint256 percent = investments[_address].mul(percentDay).div(10000);
            uint256 different = percent.mul(daysAfter);
            if (different > withdrawals[_address]) {
                _result = different.sub(withdrawals[_address]);
                _result = different;
            }
        }
    }

    function withdrawProfit() public returns (uint256 _result){
        address _address = msg.sender;
        require(joined[msg.sender] > 0);
        _result = getBalance(_address);
        if (address(this).balance > _result){
            if (_result > 0){
                withdrawals[_address] = withdrawals[_address].add(_result);
                _address.transfer(_result); //test's
                emit Withdraw(_address, _result);
            }
        }
    }

    function getMyDeposit() public returns (uint256 _result){
        address _address = msg.sender;
        require(joined[_address] > 0);
        _result = 0;
        uint256 currentDay = now;
        uint256 daysCount = currentDay.sub(joined[_address]).div(1 days);
        require(daysCount > DAYS_PROFIT);

        uint256 profit = getBalance(_address);
        uint256 myDeposit = investments[_address];
        uint256 depositAndProfit = myDeposit.add(profit);
        require(depositAndProfit >= 0);
        if (address(this).balance > depositAndProfit) {
            withdrawals[_address] = 0;
            investments[_address] = 0;
            joined[_address] = 0;
            _address.transfer(depositAndProfit); //test's
            emit Withdraw(_address, depositAndProfit);
            _result = depositAndProfit;
        }
    }

    function makeReferrerProfit(uint256 _referralLink) public payable {
        address referral = msg.sender;
        address referrer = refLinkToAddress[_referralLink];
        require(referrer != address(0));
        uint256 profitReferrer = 0;
        if (msg.value > 0) {
            profitReferrer = msg.value.mul(10).div(100);
            referrerBalance[referrer] = referrerBalance[referrer].add(profitReferrer);
            emit ReferrerProfit(referrer, referral, profitReferrer);
        }
    }

    function getMyReferrerProfit() public returns (uint256 _result){
        address _address = msg.sender;
        require(joined[_address] > 0);
        _result = checkReferrerBalance(_address);

        require(_result >= minimum);
        if (address(this).balance > _result) {
            referrerBalance[_address] = 0;
            _address.transfer(_result);
            emit ReferrerWithdraw(_address, _result);
        }
    }

    function makeReferralLink() public returns (uint256 _result){
        address _address = msg.sender;

        if (refAddressToLink[_address] == 0) {
            countReferralLink = countReferralLink.add(1);
            refLinkToAddress[countReferralLink] = _address;
            refAddressToLink[_address] = countReferralLink;
            _result = countReferralLink;
            emit MakeReferralLink(_address, _result);
        } else {
            _result = refAddressToLink[_address];
        }
    }

    function getReferralLink() public view returns (uint256){
        return refAddressToLink[msg.sender];
    }

    function checkReferrerBalance(address _hunter) public view returns (uint256) {
        return referrerBalance[_hunter];
    }

    function checkBalance() public view returns (uint256) {
        return getBalance(msg.sender);
    }

    function checkWithdrawals(address _investor) public view returns (uint256) {
        return withdrawals[_investor];
    }

    function checkInvestments(address _investor) public view returns (uint256) {
        return investments[_investor];
    }
}