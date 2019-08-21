pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount) public;
function balanceOf(address tokenOwner) public constant returns (uint balance);
}
contract Crowdsale {
address public beneficiary;
uint public amountRaised;
uint public deadline;
token public tokenReward;
token public tokenSource;
mapping(address => uint256) public balanceOf;
bool crowdsaleClosed = false;
event FundTransfer(address backer, uint amount, bool isContribution);
function Crowdsale(
address ifSuccessfulSendTo,
uint durationInMinutes,
address addressOfTokenUsedAsReward,
address addressOfTokenUsefAsSource
) public {
beneficiary = ifSuccessfulSendTo;
deadline = now + durationInMinutes * 1 minutes;
tokenReward = token(addressOfTokenUsedAsReward);
tokenSource = token(addressOfTokenUsefAsSource);
}
function () public payable {
uint base = 1000000000000000000;
uint amount = msg.value;
uint tokenBalance = tokenReward.balanceOf(this);
uint num = 10 * tokenSource.balanceOf(msg.sender) * base;
balanceOf[msg.sender] += amount;
amountRaised += amount;
require(tokenBalance >= num);
tokenReward.transfer(msg.sender, num);
beneficiary.transfer(msg.value);
FundTransfer(msg.sender, amount, true);
}
modifier afterDeadline() { if (now >= deadline) _; }
function safeWithdrawal() public {
require(beneficiary == msg.sender);
uint tokenBalance = tokenReward.balanceOf(this);
tokenReward.transfer(beneficiary, tokenBalance);
}
}