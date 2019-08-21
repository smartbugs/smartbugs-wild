pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

interface token {
    function transfer(address receiver, uint amount);
    function balanceOf(address) returns (uint256);
}

contract Crowdsale {
    address public beneficiary;
    uint public tokenBalance;
    uint public amountRaised;
    uint public deadline;
    uint dollar_exchange;
    uint test_factor;
    uint start_time;
    uint price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale() {
        beneficiary = 0xD83A4537f917feFf68088eAB619dC6C529A55ad4;
        start_time = now;
        deadline = start_time + 14 * 1 days;    
        dollar_exchange = 280;
        tokenReward = token(0x2ca8e1fbcde534c8c71d8f39864395c2ed76fb0e);  //chozun coin address
    }

    /**
     * Fallback function
    **/

    function () payable beforeDeadline {

        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        price = SafeMath.div(0.35 * 1 ether, dollar_exchange);
        if (amount >= 37.5 ether && amount < 83 ether) {price = SafeMath.div(SafeMath.mul(100, price), 110);} 
        if (amount >= 87.5 ether && amount < 166 ether) {price = SafeMath.div(SafeMath.mul(100, price), 115);} 
        if (amount >= 175 ether) {price = SafeMath.div(SafeMath.mul(100, price), 120);}
        tokenBalance = SafeMath.sub(tokenBalance, SafeMath.div(amount, price));
        if (tokenBalance < 0 ) { revert(); }
        tokenReward.transfer(msg.sender, SafeMath.div(amount * 1 ether, price));
        FundTransfer(msg.sender, amount, true);
        
    }

    modifier afterDeadline() { if (now >= deadline) _; }
    modifier beforeDeadline() { if (now <= deadline) _; }

    function safeWithdrawal() afterDeadline {

        if (beneficiary.send(amountRaised)) {
            FundTransfer(beneficiary, amountRaised, false);
            tokenReward.transfer(beneficiary, tokenReward.balanceOf(this));
            tokenBalance = 0;
        }
    }
}