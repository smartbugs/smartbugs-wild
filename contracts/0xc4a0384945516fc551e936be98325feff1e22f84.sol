pragma solidity 0.4 .24;

/**
Welcome to the first innovational investment project – SmartRocket.
The all you need is to make a deposit and wait for your profit: 4% of your deposit per day.

To make a deposit send any amount of ETH to the smart contract address.
You can reinvest your deposit via sending more ETH to the smart contract above the sum you have sent before.

All the deposits are accumulated and the percentage is calculated from the total investment.
6% of your deposit goes to marketing, promotion and charity.
3% of your deposit goes to the backup budget. Backup budget is a bank, that is formed from all the investments and, if the growth of the project slows down due to some reasons, the calculated necessary sum of money will be transferred to the smart contract to protect the “late investors”. This scheme is about that everyone in the project helps each other.
The project fund forms from 91% of all deposits + 3% (the whole backup budget, if it is needed).

You can get paid any time you want, but not more frequently, than once per minute!
To get your % you need to send 0 ETH to the smart contract address.

You can get only 217% of your revenue. After you got paid 217% of your investments (100% of your deposit plus 117% of profit), smart contract automatically deletes you from the project and you can re-enter it to continue getting profit. This scheme in addition to the most optimized profit percentage (4%) allows the project to exist for a long time.

You have an option of getting more, than 217% of your revenue. For this you need not to withdraw your percents until accumulating the sum you need.
For example, if you want to get 300% of your revenue, you need to wait 75 days since you have made a deposit (25 days (100% of your dep – 4% per day for 25 days) x 3)

!_IMPORTANT_! – GAS LIMIT for ALL TRANSACTIONS is 150000. All unused gas will be returned to you automatically.



*/

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0);
        uint256 c = a / b;
        return c;
    }
}
contract SmartRocket {
    using SafeMath
    for uint;

    mapping(address => uint) public TimeOfInvestments;
    mapping(address => uint) public CalculatedProfit;
    mapping(address => uint) public SumOfInvestments;
    uint public WithdrawPeriod = 1 minutes;
    uint public HappyInvestors = 0;
    address public constant PromotionBank = 0x3B2CCc7B82f18eCAB670FA4802cFAE8e8957661d;
    address public constant BackUpBank = 0x0674D98b3f6f3045981029FDCD8adE493071ba37;

    modifier AreYouGreedy() {
        require(now >= TimeOfInvestments[msg.sender].add(WithdrawPeriod), "Don’t hurry, dude, not yet");
        _;
    }

    modifier AreYouLucky() {
        require(SumOfInvestments[msg.sender] > 0, "You are not with us, yet");
        _;
    }

    function() external payable {
        if (msg.value > 0) {
            if (SumOfInvestments[msg.sender] == 0) {
                HappyInvestors += 1;
            }
            if (SumOfInvestments[msg.sender] > 0 && now > TimeOfInvestments[msg.sender].add(WithdrawPeriod)) {
                PrepareToBeRich();
            }
            SumOfInvestments[msg.sender] = SumOfInvestments[msg.sender].add(msg.value);
            TimeOfInvestments[msg.sender] = now;
            PromotionBank.transfer(msg.value.mul(6).div(100));
            BackUpBank.transfer(msg.value.mul(3).div(100));
        } else {
            PrepareToBeRich();
        }
    }

    function PrepareToBeRich() AreYouGreedy AreYouLucky internal {
        if ((SumOfInvestments[msg.sender].mul(217).div(100)) <= CalculatedProfit[msg.sender]) {
            SumOfInvestments[msg.sender] = 0;
            CalculatedProfit[msg.sender] = 0;
            TimeOfInvestments[msg.sender] = 0;
        } else {
            uint GetYourMoney = YourPercent();
            CalculatedProfit[msg.sender] += GetYourMoney;
            TimeOfInvestments[msg.sender] = now;
            msg.sender.transfer(GetYourMoney);
        }
    }
//calculating the percent rate per day (1day=24hours=1440minutes); 1/36000*1440=0.04 (4% per day)
    function YourPercent() public view returns(uint) {
        uint withdrawalAmount = ((SumOfInvestments[msg.sender].mul(1).div(36000)).mul(now.sub(TimeOfInvestments[msg.sender]).div(WithdrawPeriod)));
        return (withdrawalAmount);
    }
}