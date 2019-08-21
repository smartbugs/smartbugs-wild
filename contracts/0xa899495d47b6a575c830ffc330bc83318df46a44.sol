pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
pragma solidity ^0.4.11;

contract StakeTreeMVP {
  using SafeMath for uint256;

  uint public version = 1;

  struct Funder {
    bool exists;
    uint balance;
    uint withdrawalEntry;
  }
  mapping(address => Funder) public funders;

  bool public live = true; // For sunsetting contract
  uint public totalCurrentFunders = 0; // Keeps track of total funders
  uint public withdrawalCounter = 0; // Keeps track of how many withdrawals have taken place
  uint public sunsetWithdrawDate;
 
  address public beneficiary; // Address for beneficiary
  uint public sunsetWithdrawalPeriod; // How long it takes for beneficiary to swipe contract when put into sunset mode
  uint public withdrawalPeriod; // How long the beneficiary has to wait withdraw
  uint public minimumFundingAmount; // Setting used for setting minimum amounts to fund contract with
  uint public lastWithdrawal; // Last withdrawal time
  uint public nextWithdrawal; // Next withdrawal time

  uint public contractStartTime; // For accounting purposes

  function StakeTreeMVP(
    address beneficiaryAddress, 
    uint withdrawalPeriodInit, 
    uint withdrawalStart, 
    uint sunsetWithdrawPeriodInit,
    uint minimumFundingAmountInit) {

    beneficiary = beneficiaryAddress;
    withdrawalPeriod = withdrawalPeriodInit;
    sunsetWithdrawalPeriod = sunsetWithdrawPeriodInit;

    lastWithdrawal = withdrawalStart; 
    nextWithdrawal = lastWithdrawal + withdrawalPeriod;

    minimumFundingAmount = minimumFundingAmountInit;

    contractStartTime = now;
  }

  // Modifiers
  modifier onlyByBeneficiary() {
    require(msg.sender == beneficiary);
    _;
  }

  modifier onlyByFunder() {
    require(isFunder(msg.sender));
    _;
  }

  modifier onlyAfterNextWithdrawalDate() {
    require(now >= nextWithdrawal);
    _;
  }

  modifier onlyWhenLive() {
    require(live);
    _;
  }

  modifier onlyWhenSunset() {
    require(!live);
    _;
  }

  /*
  * External accounts can pay directly to contract to fund it.
  */
  function () payable {
    fund();
  }

  /*
  * Additional api for contracts to use as well
  * Can only happen when live and over a minimum amount set by the beneficiary
  */

  function fund() public payable onlyWhenLive {
    require(msg.value >= minimumFundingAmount);

    // Only increase total funders when we have a new funder
    if(!isFunder(msg.sender)) {
      totalCurrentFunders = totalCurrentFunders.add(1); // Increase total funder count

      funders[msg.sender] = Funder({
        exists: true,
        balance: msg.value,
        withdrawalEntry: withdrawalCounter // Set the withdrawal counter. Ie at which withdrawal the funder "entered" the patronage contract
      });
    }
    else {
      // If the funder is already in the pool let's update things while we're at it
      // This calculates their actual balance left and adds their top up amount
      funders[msg.sender].balance = getRefundAmountForFunder(msg.sender).add(msg.value);
      // Reset withdrawal counter
      funders[msg.sender].withdrawalEntry = withdrawalCounter;
    }
  }

  // Pure functions

  /*
  * This function calculates how much the beneficiary can withdraw.
  * Due to no floating points in Solidity, we will lose some fidelity
  * if there's wei on the last digit. The beneficiary loses a neglibible amount
  * to withdraw but this benefits the beneficiary again on later withdrawals.
  * We multiply by 10 (which corresponds to the 10%) 
  * then divide by 100 to get the actual part.
  */
  function calculateWithdrawalAmount(uint startAmount) public returns (uint){
    return startAmount.mul(10).div(100); // 10%
  }

  /*
  * This function calculates the refund amount for the funder.
  * Due to no floating points in Solidity, we will lose some fidelity.
  * The funder loses a neglibible amount to refund. 
  * The left over wei gets pooled to the fund.
  */
  function calculateRefundAmount(uint amount, uint withdrawalTimes) public returns (uint) {    
    for(uint i=0; i<withdrawalTimes; i++){
      amount = amount.mul(9).div(10);
    }
    return amount;
  }

  // Getter functions

  /*
  * To calculate the refund amount we look at how many times the beneficiary
  * has withdrawn since the funder added their funds. 
  * We use that deduct 10% for each withdrawal.
  */

  function getRefundAmountForFunder(address addr) public constant returns (uint) {
    uint amount = funders[addr].balance;
    uint withdrawalTimes = getHowManyWithdrawalsForFunder(addr);
    return calculateRefundAmount(amount, withdrawalTimes);
  }

  function getBeneficiary() public constant returns (address) {
    return beneficiary;
  }

  function getCurrentTotalFunders() public constant returns (uint) {
    return totalCurrentFunders;
  }

  function getWithdrawalCounter() public constant returns (uint) {
    return withdrawalCounter;
  }

  function getWithdrawalEntryForFunder(address addr) public constant returns (uint) {
    return funders[addr].withdrawalEntry;
  }

  function getContractBalance() public constant returns (uint256 balance) {
    balance = this.balance;
  }

  function getFunderBalance(address funder) public constant returns (uint256) {
    return getRefundAmountForFunder(funder);
  }

  function isFunder(address addr) public constant returns (bool) {
    return funders[addr].exists;
  }

  function getHowManyWithdrawalsForFunder(address addr) private constant returns (uint) {
    return withdrawalCounter.sub(getWithdrawalEntryForFunder(addr));
  }

  // State changing functions
  function setMinimumFundingAmount(uint amount) external onlyByBeneficiary {
    require(amount > 0);
    minimumFundingAmount = amount;
  }

  function withdraw() external onlyByBeneficiary onlyAfterNextWithdrawalDate onlyWhenLive  {
    // Check
    uint amount = calculateWithdrawalAmount(this.balance);

    // Effects
    withdrawalCounter = withdrawalCounter.add(1);
    lastWithdrawal = now; // For tracking purposes
    nextWithdrawal = nextWithdrawal + withdrawalPeriod; // Fixed period increase

    // Interaction
    beneficiary.transfer(amount);
  }

  // Refunding by funder
  // Only funders can refund their own funding
  // Can only be sent back to the same address it was funded with
  // We also remove the funder if they succesfully exit with their funds
  function refund() external onlyByFunder {
    // Check
    uint walletBalance = this.balance;
    uint amount = getRefundAmountForFunder(msg.sender);
    require(amount > 0);

    // Effects
    removeFunder();

    // Interaction
    msg.sender.transfer(amount);

    // Make sure this worked as intended
    assert(this.balance == walletBalance-amount);
  }

  // Used when the funder wants to remove themselves as a funder
  // without refunding. Their eth stays in the pool
  function removeFunder() public onlyByFunder {
    delete funders[msg.sender];
    totalCurrentFunders = totalCurrentFunders.sub(1);
  }

  /*
  * The beneficiary can decide to stop using this contract.
  * They use this sunset function to put it into sunset mode.
  * The beneficiary can then swipe rest of the funds after a set time
  * if funders have not withdrawn their funds.
  */

  function sunset() external onlyByBeneficiary onlyWhenLive {
    sunsetWithdrawDate = now.add(sunsetWithdrawalPeriod);
    live = false;
  }

  function swipe(address recipient) external onlyWhenSunset onlyByBeneficiary {
    require(now >= sunsetWithdrawDate);

    recipient.transfer(this.balance);
  }
}