pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
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

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
    }
  }
}
contract ZTRToken{
    function transfer(address _to, uint val);
}

contract ZTRTokenSale
{
    using SafeMath for uint;
    mapping (address => uint) public balanceOf;
    mapping (address => uint) public ethBalance;
    address public owner;
    address ZTRTokenContract;
    uint public fundingGoal;
    uint public fundingMax;
    uint public amountRaised;
    uint public start;
    uint public duration;
    uint public deadline;
    uint public unlockTime;
    uint public ZTR_ETH_initial_price;
    uint public ZTR_ETH_extra_price;
    uint public remaining;
    
    modifier admin { if (msg.sender == owner) _; }
    modifier afterUnlock { if(now>unlockTime) _;}
    modifier afterDeadline { if(now>deadline) _;}
    
    function ZTRTokenSale()
    {
        owner = msg.sender;
        ZTRTokenContract = 0x107bc486966eCdDAdb136463764a8Eb73337c4DF;
        fundingGoal = 5000 ether;//funds will be returned if this goal is not met
        fundingMax = 30000 ether;//The max amount that can be raised
        start = 1517702401;//beginning of the token sale
        duration = 3 weeks;//duration of the token sale
        deadline = start + duration;//end of the token sale
        unlockTime = deadline + 16 weeks;//unlock for selfdestruct
        ZTR_ETH_initial_price = 45000;//initial ztr price
        ZTR_ETH_extra_price = 23000;//ztr price after funding goal has been met
        remaining = 800000000000000000000000000;//counter for remaining tokens
    }
    function () payable public//order processing and crediting to escrow
    {
        require(now>start);
        require(now<deadline);
        require(amountRaised + msg.value < fundingMax);//funding hard cap has not been reached
        uint purchase = msg.value;
        ethBalance[msg.sender] = ethBalance[msg.sender].add(purchase);//track the amount of eth contributed for refunds
        if(amountRaised < fundingGoal)//funding goal has not been met yet
        {
            purchase = purchase.mul(ZTR_ETH_initial_price);
            amountRaised = amountRaised.add(msg.value);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(purchase);
            remaining.sub(purchase);
        }
        else//funding goal has been met, selling extra tokens
        {
            purchase = purchase.mul(ZTR_ETH_extra_price);
            amountRaised = amountRaised.add(msg.value);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(purchase);
            remaining.sub(purchase);
        }
    }
    
    function withdrawBeneficiary() public admin afterDeadline//withdrawl for the ZTrust Foundation
    {
        ZTRToken t = ZTRToken(ZTRTokenContract);
        t.transfer(msg.sender, remaining);
        require(amountRaised >= fundingGoal);//allow admin withdrawl if funding goal is reached and the sale is over
        owner.transfer(amountRaised);
    }
    
    function withdraw() afterDeadline//ETH/ZTR withdrawl for sale participants
    {
        if(amountRaised < fundingGoal)//funding goal was not met, withdraw ETH deposit
        {
            uint ethVal = ethBalance[msg.sender];
            ethBalance[msg.sender] = 0;
            msg.sender.transfer(ethVal);
        }
        else//funding goal was met, withdraw ZTR tokens
        {
            uint tokenVal = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            ZTRToken t = ZTRToken(ZTRTokenContract);
            t.transfer(msg.sender, tokenVal);
        }
    }
    
    function setDeadline(uint ti) public admin//setter
    {
        deadline = ti;
    }
    
    function setStart(uint ti) public admin//setter
    {
        start = ti;
    }
    
    function suicide() public afterUnlock //contract can be destroyed 4 months after the sale ends to save state
    {
        selfdestruct(owner);
    }
}