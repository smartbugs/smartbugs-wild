pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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
}

library SafeBonus {
    using SafeMath for uint256;

    function addBonus(uint256 value, uint256 percentages) internal pure returns (uint256) {
        return value.add(value.mul(percentages).div(100));
    }
}

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface token {
    function transfer(address receiver, uint amount) public;
}

contract VesaPreICO is Ownable {
    using SafeMath for uint256;
    using SafeBonus for uint256;

    address public beneficiary;
    uint8 public constant durationInDays = 31;
    uint public constant fundingGoal = 140 ether;
    uint public constant fundingGoalHardCap = 1400 ether;
    uint public amountRaised;
    uint public start;
    uint public deadline;
    uint public constant bonusPrice = 1857142857000000;
    uint public constant bonusPriceDeltaPerHour = 28571428570000;
    uint public constant bonusPeriodDurationInHours = 10;
    uint public constant price = 2142857142857140;
    uint public constant minSum = 142857142900000000;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function VesaPreICO() public {
        beneficiary = 0x94e1F1Fa284061184B583a61633CaC75e03cFdBC;
        start = now;
        deadline = start + durationInDays * 1 days;
        tokenReward = token(0xb1c74c1D82824428e484072069041deD079eD921);
    }

    function isAfterDeadline() internal view returns (bool) { return now >= deadline; } 

    function isSoftCapAchieved() internal view returns (bool) { return amountRaised >= fundingGoal; } 

    function isHardCapAchieved() internal view returns (bool) { return amountRaised >= fundingGoalHardCap; }

    function isCompanyCanBeFinished() internal view returns (bool) { return isAfterDeadline() || isHardCapAchieved(); }

    modifier afterDeadline() { if (isAfterDeadline()) _; }

    modifier companyCanBeFinished() { if (isCompanyCanBeFinished()) _; }

    function getPrice() public view returns (uint) {
        require(!crowdsaleClosed);

        if ( now >= (start + bonusPeriodDurationInHours.mul(1 hours))) {
            return price;
        } else {
            uint hoursLeft = now.sub(start).div(1 hours);
            return bonusPrice.add(bonusPriceDeltaPerHour.mul(hoursLeft));
        }
    }

    function getBonus(uint amount) public view returns (uint) {
        require(!crowdsaleClosed);

        if (amount < 2857142857000000000) { return 0; }                                       // < 2.857142857
        if (amount >= 2857142857000000000 && amount < 7142857143000000000) { return 6; }      // 2.857142857-7,142857143 ETH
        if (amount >= 7142857143000000000 && amount < 14285714290000000000) { return 8; }     // 7,142857143-14,28571429 ETH
        if (amount >= 14285714290000000000 && amount < 25000000000000000000) { return 10; }   // 14,28571429-25 ETH
        if (amount >= 25000000000000000000 && amount < 85000000000000000000) { return 15; }   // 25-85 ETH
        if (amount >= 85000000000000000000 && amount < 285000000000000000000) { return 17; }  // 85-285 ETH
        if (amount >= 285000000000000000000) { return 20; }                                   // >285 ETH
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () public payable {
        require(!crowdsaleClosed);
        require(msg.value > minSum);
        uint amount = msg.value;
        balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);

        uint currentPrice = getPrice();
        uint currentBonus = getBonus(amount);

        uint tokensToTransfer = amount.mul(10 ** 18).div(currentPrice);
        uint tokensToTransferWithBonuses = tokensToTransfer.addBonus(currentBonus);

        tokenReward.transfer(msg.sender, tokensToTransferWithBonuses);
        FundTransfer(msg.sender, amount, true);
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public companyCanBeFinished {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() public companyCanBeFinished {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }

    function tokensWithdrawal(address receiver, uint amount) public onlyOwner {
        tokenReward.transfer(receiver, amount);
    }

}