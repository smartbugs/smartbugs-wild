pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
    
    function balanceOf(address _owner) public constant returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
}


contract TimelockedSafe {

    using SafeMath for uint;

	uint constant public decimals = 18;

	uint constant public oneMonth = 30 days;

    address public adminAddress;

    address public withdrawAddress;

    uint public lockingPeriodInMonths; // all tokens are locked for a certain period

    uint public vestingPeriodInMonths; // after the locking period ends the vesting period starts, but each month
                                       // there is a token withdraw limit as defined below

    uint public monthlyWithdrawLimitInWei; // monthly withdraw limit during the vesting period

    Token public token;

    uint public startTime;

    function TimelockedSafe(address _adminAddress, address _withdrawAddress,
    	uint _lockingPeriodInMonths, uint _vestingPeriodInMonths,
    	uint _monthlyWithdrawLimitInWei, address _token) public {
        require(_adminAddress != 0);
    	require(_withdrawAddress != 0);

    	// just to prevent mistakenly passing in a value with incorrect token unit
    	require(_monthlyWithdrawLimitInWei > 100 * (10 ** decimals));

        adminAddress = _adminAddress;
    	withdrawAddress = _withdrawAddress;
    	lockingPeriodInMonths = _lockingPeriodInMonths;
    	vestingPeriodInMonths = _vestingPeriodInMonths;
    	monthlyWithdrawLimitInWei = _monthlyWithdrawLimitInWei;
    	token = Token(_token);
    	startTime = now;
    }

    function withdraw(uint _withdrawAmountInWei) public returns (bool) {    	
    	uint timeElapsed = now.sub(startTime);
    	uint monthsElapsed = (timeElapsed.div(oneMonth)).add(1);
    	require(monthsElapsed >= lockingPeriodInMonths);

    	uint fullyVestedTimeInMonths = lockingPeriodInMonths.add(vestingPeriodInMonths);
    	uint remainingVestingPeriodInMonths = 0;
    	if (monthsElapsed < fullyVestedTimeInMonths) {
    		remainingVestingPeriodInMonths = fullyVestedTimeInMonths.sub(monthsElapsed);
    	}

    	address timelockedSafeAddress = address(this);
    	uint minimalBalanceInWei = remainingVestingPeriodInMonths.mul(monthlyWithdrawLimitInWei);
    	uint currentTokenBalanceInWei = token.balanceOf(timelockedSafeAddress);
    	require(currentTokenBalanceInWei.sub(_withdrawAmountInWei) >= minimalBalanceInWei);

    	require(token.transfer(withdrawAddress, _withdrawAmountInWei));

    	return true;
    }

    function changeStartTime(uint _newStartTime) public only(adminAddress) {
        startTime = _newStartTime;
    }

    function changeTokenAddress(address _newTokenAddress) public only(adminAddress) {
        token = Token(_newTokenAddress);
    }

    function changeWithdrawAddress(address _newWithdrawAddress) public only(adminAddress) {
        withdrawAddress = _newWithdrawAddress;
    }

    function changeLockingPeriod(uint _newLockingPeriodInMonths) public only(adminAddress) {
        lockingPeriodInMonths = _newLockingPeriodInMonths;
    }

    function changeVestingPeriod(uint _newVestingPeriodInMonths) public only(adminAddress) {
        vestingPeriodInMonths = _newVestingPeriodInMonths;
    }

    function changeMonthlyWithdrawLimit(uint _newMonthlyWithdrawLimitInWei) public only(adminAddress) {
        monthlyWithdrawLimitInWei = _newMonthlyWithdrawLimitInWei;
    }

    function finalizeConfig() public only(adminAddress) {
        adminAddress = 0x0; // config finalized, give up control 
    }

    modifier only(address x) {
        require(msg.sender == x);
        _;
    }

}