pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

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

contract Main {

    using SafeMath for uint;

    // The nested mapping is used to implement the round-based logic
    mapping(uint => mapping(address => uint)) public balance;
    mapping(uint => mapping(address => uint)) public time;
    mapping(uint => mapping(address => uint)) public percentWithdraw;
    mapping(uint => mapping(address => uint)) public allPercentWithdraw;
    mapping(uint => uint) public investorsByRound;

    uint public stepTime = 24 hours;
    uint public countOfInvestors = 0;
    uint public totalRaised;
    uint public rounds_counter;
    uint public projectPercent = 10;
    uint public totalWithdrawed = 0;
    bool public started;

    address public ownerAddress;

    event Invest(uint indexed round, address indexed investor, uint256 amount);
    event Withdraw(uint indexed round, address indexed investor, uint256 amount);

    modifier userExist() {
        require(balance[rounds_counter][msg.sender] > 0, "Address not found");
        _;
    }

    modifier checkTime() {
        require(now >= time[rounds_counter][msg.sender].add(stepTime), "Too fast payout request");
        _;
    }

    modifier onlyStarted() {
        require(started == true);
        _;
    }

    // @dev This function is processing all the logic with withdraw
    function collectPercent() userExist checkTime internal {

        // Check that user already has received 200%
        // In this case - remove him from the db
        if ((balance[rounds_counter][msg.sender].mul(2)) <= allPercentWithdraw[rounds_counter][msg.sender]) {
            balance[rounds_counter][msg.sender] = 0;
            time[rounds_counter][msg.sender] = 0;
            percentWithdraw[rounds_counter][msg.sender] = 0;
        } else {
            // User has not reached the limit yet
            // Process the withdraw and update the stats

            uint payout = payoutAmount();  // Get the amount of weis to send

            percentWithdraw[rounds_counter][msg.sender] = percentWithdraw[rounds_counter][msg.sender].add(payout);
            allPercentWithdraw[rounds_counter][msg.sender] = allPercentWithdraw[rounds_counter][msg.sender].add(payout);

            // Send Ethers
            msg.sender.transfer(payout);
            totalWithdrawed = totalWithdrawed.add(payout);

            emit Withdraw(rounds_counter, msg.sender, payout);
        }

    }

    // @dev The withdraw percentage depends on two things:
    // @dev first one is total amount of Ethers on the contract balance
    // @dev and second one is the deposit size of current investor
    function percentRate() public view returns(uint) {

        uint contractBalance = address(this).balance;
        uint user_balance = balance[rounds_counter][msg.sender];
        uint contract_depending_percent = 0;

        // Check the contract balance and add some additional percents
        // Because of the Solidity troubles with floats
        // 20 means 2%, 15 means 1.5%, 10 means 1%
        if (contractBalance >= 10000 ether) {
            contract_depending_percent = 20;
        } else if (contractBalance >= 5000 ether) {
            contract_depending_percent = 15;
        } else if (contractBalance >= 1000 ether) {
            contract_depending_percent = 10;
        }

        // Check the investor's balance
        if (user_balance < 9999999999999999999) {          // < 9.999999 Ethers
          return (30 + contract_depending_percent);
        } else if (user_balance < 29999999999999999999) {  // < 29.999999 Ethers
          return (35 + contract_depending_percent);
        } else if (user_balance < 49999999999999999999) {  // < 49.999999 Ethers
          return (40 + contract_depending_percent);
        } else {                                        // <= 100 Ethers
          return (45 + contract_depending_percent);
        }

    }


    // @dev This function returns the amount in weis for withdraw
    function payoutAmount() public view returns(uint256) {
        // Minimum percent is 3%, maximum percent is 6.5% per 24 hours
        uint256 percent = percentRate();

        uint256 different = now.sub(time[rounds_counter][msg.sender]).div(stepTime);

        // 1000 instead of 100, because in case of 3%
        // 'percent' equals to 30 and so on
        uint256 rate = balance[rounds_counter][msg.sender].mul(percent).div(1000);

        uint256 withdrawalAmount = rate.mul(different).sub(percentWithdraw[rounds_counter][msg.sender]);

        return withdrawalAmount;
    }

    // @dev This function is called each time when user sends Ethers
    function deposit() private {
        if (msg.value > 0) { // User wants to invest
            require(balance[rounds_counter][msg.sender] == 0);  // User can invest only once

            if (balance[rounds_counter][msg.sender] == 0) {  // New investor
              countOfInvestors = countOfInvestors.add(1);
              investorsByRound[rounds_counter] = investorsByRound[rounds_counter].add(1);
            }

            // If already has some investments and the time gap is correct
            // make a withdraw
            if (
              balance[rounds_counter][msg.sender] > 0 &&
              now > time[rounds_counter][msg.sender].add(stepTime)
            ) {
                collectPercent();
                percentWithdraw[rounds_counter][msg.sender] = 0;
            }

            balance[rounds_counter][msg.sender] = balance[rounds_counter][msg.sender].add(msg.value);
            time[rounds_counter][msg.sender] = now;

            // Send fee to the owner
            ownerAddress.transfer(msg.value.mul(projectPercent).div(100));
            totalRaised = totalRaised.add(msg.value);

            emit Invest(rounds_counter, msg.sender, msg.value);
        } else {  // User wants to withdraw his profit
            collectPercent();
        }
    }

    // @dev This function is called when user sends Ethers
    function() external payable onlyStarted {
        // Maximum deposit per address - 100 Ethers
        require(balance[rounds_counter][msg.sender].add(msg.value) <= 100 ether, "More than 100 ethers");

        // Check that contract has less than 10%
        // of total collected investments
        if (address(this).balance < totalRaised.div(100).mul(10)) {
            startNewRound();
        }

        deposit();
    }

    // @dev In the case of new round - reset all the stats
    // @dev and start new round with the rest of the balance on the contract
    function startNewRound() internal {
        rounds_counter = rounds_counter.add(1);
        totalRaised = address(this).balance;
    }

    // @dev Enable the game
    function start() public {
        require(ownerAddress == msg.sender);
        started = true;
    }

    constructor() public {
        ownerAddress = msg.sender;
        started = false;
    }

}