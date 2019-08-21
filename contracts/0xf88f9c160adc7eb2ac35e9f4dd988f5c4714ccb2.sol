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

contract Project424_2 {
  using SafeMath for uint256;

  address constant MARKETING_ADDRESS = 0xcc1B012Dc66f51E6cE77122711A8F730eF5a97fa;
  address constant TEAM_ADDRESS = 0x155a3c1Ab0Ac924cB3079804f3784d4d13cF3a45;
  address constant REFUND_ADDRESS = 0x732445bfB4F9541ba4A295d31Fb830B2ffdA80F8;

  uint256 constant ONE_HUNDREDS_PERCENTS = 10000;      // 100%
  uint256 constant INCOME_MAX_PERCENT = 5000;          // 50%
  uint256 constant MARKETING_FEE = 1000;               // 10%
  uint256 constant WITHDRAWAL_PERCENT = 1500;          // 15%
  uint256 constant TEAM_FEE = 300;                     // 3%
  uint256 constant REFUND_FEE = 200;                   // 2%
  uint256 constant INCOME_PERCENT = 150;               // 1.5%
  uint256 constant BALANCE_WITHDRAWAL_PERCENT = 10;    // 0.1%
  uint256 constant BALANCE_INCOME_PERCENT = 1;         // 0.01%

  uint256 constant DAY = 86400;                        // 1 day

  uint256 constant SPECIAL_NUMBER = 4240 szabo;        // 0.00424 eth
  
  event AddInvestor(address indexed investor, uint256 amount);

  struct User {
    uint256 firstTime;
    uint256 deposit;
  }
  mapping(address => User) public users;

  function () payable external {
    User storage user = users[msg.sender];

    // deposits
    if ( msg.value != 0 && user.firstTime == 0 ) {
      user.firstTime = now;
      user.deposit = msg.value;
      AddInvestor(msg.sender, msg.value);
      
      MARKETING_ADDRESS.send(msg.value.mul(MARKETING_FEE).div(ONE_HUNDREDS_PERCENTS));
      TEAM_ADDRESS.send(msg.value.mul(TEAM_FEE).div(ONE_HUNDREDS_PERCENTS));
      REFUND_ADDRESS.send(msg.value.mul(REFUND_FEE).div(ONE_HUNDREDS_PERCENTS));

    } else if ( msg.value == SPECIAL_NUMBER && user.firstTime != 0 ) { // withdrawal
      uint256 withdrawalSum = userWithdrawalSum(msg.sender).add(SPECIAL_NUMBER);

      // check all funds
      if (withdrawalSum >= address(this).balance) {
        withdrawalSum = address(this).balance;
      }

      // deleting
      user.firstTime = 0;
      user.deposit = 0;

      msg.sender.send(withdrawalSum);
    } else {
      revert();
    }
  }

  function userWithdrawalSum(address wallet) public view returns(uint256) {
    User storage user = users[wallet];
    uint256 daysDuration = getDays(wallet);
    uint256 withdrawal = user.deposit;


    (uint256 getBalanceWithdrawalPercent, uint256 getBalanceIncomePercent) = getBalancePercents();
    uint currentDeposit = user.deposit;
    
    if (daysDuration == 0) {
      return withdrawal.sub(withdrawal.mul(WITHDRAWAL_PERCENT.add(getBalanceWithdrawalPercent)).div(ONE_HUNDREDS_PERCENTS));
    }

    for (uint256 i = 0; i < daysDuration; i++) {
      currentDeposit = currentDeposit.add(currentDeposit.mul(INCOME_PERCENT.add(getBalanceIncomePercent)).div(ONE_HUNDREDS_PERCENTS));

      if (currentDeposit >= user.deposit.add(user.deposit.mul(INCOME_MAX_PERCENT).div(ONE_HUNDREDS_PERCENTS))) {
        withdrawal = user.deposit.add(user.deposit.mul(INCOME_MAX_PERCENT).div(ONE_HUNDREDS_PERCENTS));

        break;
      } else {
        withdrawal = currentDeposit.sub(currentDeposit.mul(WITHDRAWAL_PERCENT.add(getBalanceWithdrawalPercent)).div(ONE_HUNDREDS_PERCENTS));
      }
    }
    
    return withdrawal;
  }
  
  function getDays(address wallet) public view returns(uint256) {
    User storage user = users[wallet];
    if (user.firstTime == 0) {
        return 0;
    } else {
        return (now.sub(user.firstTime)).div(DAY);
    }
  }

  function getBalancePercents() public view returns(uint256 withdrawalRate, uint256 incomeRate) {
    if (address(this).balance >= 100 ether) {
      if (address(this).balance >= 5000 ether) {
        withdrawalRate = 500;
        incomeRate = 50;
      } else {
        uint256 steps = (address(this).balance).div(100 ether);
        uint256 withdrawalUtility = 0;
        uint256 incomeUtility = 0;

        for (uint i = 0; i < steps; i++) {
          withdrawalUtility = withdrawalUtility.add(BALANCE_WITHDRAWAL_PERCENT);
          incomeUtility = incomeUtility.add(BALANCE_INCOME_PERCENT);
        }
        
        withdrawalRate = withdrawalUtility;
        incomeRate = incomeUtility;
      }
    } else {
      withdrawalRate = 0;
      incomeRate = 0;
    }
  }
}