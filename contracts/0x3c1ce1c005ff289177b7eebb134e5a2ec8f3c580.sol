pragma solidity >=0.4.25 <0.6.0;

/**
 * Minimum recomendation: 10(GWEI) & 121000 Gas 
   Minimum send to this contract = 0.2 eth
   Approximately 2.5 mill tokens = 10.000 ETH "hard goal"
   Deadline 4/aug/2019
 */

interface token {
    function transfer(address receiver, uint amount) external;
}

contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract LightCrowdsale is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMath for uint;

    address payable public beneficiary; // wallet to send eth to
    uint public fundingGoal; // maximum amount to raise
    uint public amountRaised; // current amount raised
    uint public minAmountWei; // min amount for crowdsale
    uint public deadline; // time when crowdsale to close
    uint public price; // price for token
    token public tokenReward; // token
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor
     *
     * Setup the owner
     */
    constructor(
        address payable ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint finneyCostOfEachToken,
        address addressOfTokenUsedAsReward,
        uint minAmountFinney
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = finneyCostOfEachToken * 1 finney;
        minAmountWei = minAmountFinney * 1 finney;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function() payable external {
        buyTokens(msg.sender);
    }

    function buyTokens(address sender) public nonReentrant payable {
        checkGoalReached();
        require(!crowdsaleClosed);
        require(sender != address(0));
        uint amount = msg.value;
        require(balanceOf[sender] >= amount);
        require(amount != 0);
        require(amount >= minAmountWei);

        uint senderBalance = balanceOf[sender];
        balanceOf[sender] = senderBalance.add(amount);
        amountRaised = amountRaised.add(amount);
        uint tokenToSend = amount.div(price) * 1 ether;
        tokenReward.transfer(sender, tokenToSend);
        emit FundTransfer(sender, amount, true);

        if (beneficiary.send(amount)) {
            emit FundTransfer(beneficiary, amount, false);
        }

        checkGoalReached();
    }

    modifier afterDeadline() {if (now >= deadline) _;}

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            crowdsaleClosed = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        if (now > deadline) {
            crowdsaleClosed = true;
            emit GoalReached(beneficiary, amountRaised);
        }
    }
}