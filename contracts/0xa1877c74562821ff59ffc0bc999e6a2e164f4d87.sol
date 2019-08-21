pragma solidity ^0.4.8;


contract token {function transfer(address receiver, uint amount){ }}

contract Crowdsale {
    uint public amountRaised; uint public resAmount; uint public soldTokens;
    mapping(address => uint256) public balanceOf;
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    bool public crowdsaleClosed = true;
    bool public minimumTargetReached = false;

    // initialization
    address public beneficiary = 0xC1fa2C60Ea649A477e40c0510744f2881C0486D9;/*ifSuccessfulSendTo*/
    uint public price = 0.0015 ether;/*costOfEachToken*/
    uint public minimumTarget = 1500000 * price;/*minimumTargetInTokens*/
    uint public maximumTarget = 9803020 * price;/*maximumTargetInTokens*/
    uint public deadline =  now + 43200 * 1 minutes;/*durationInMinutes*/
    token public tokenReward = token(0x2Fd8019ce2AAc3bf9DB18D851A57EFe1a6151BBF);/*addressOfTokenUsedAsReward*/


    // the function without name is the default function that is called whenever anyone sends funds to a contract
    function () payable {
        if (crowdsaleClosed || (maximumTarget - amountRaised) < msg.value) throw;
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        resAmount += amount;
        soldTokens += amount / price;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);

        if (amountRaised >= minimumTarget && !minimumTargetReached) {
            minimumTargetReached = true;
            GoalReached(beneficiary, minimumTarget);
        }

        // funds are sending to beneficiary account after minimumTarget will be reached
        if (minimumTargetReached) {
            if (beneficiary.send(amount)) {
                FundTransfer(beneficiary, amount, false);
                resAmount -= amount;
            }
        }
    }

    // dev function for withdraw any amount from amountRaised (active only if minimumTarget is reached)
    function devWithdrawal(uint num, uint den) {
        if (!minimumTargetReached || !(beneficiary == msg.sender)) throw;
        uint wAmount = num / den;
        if (beneficiary.send(wAmount)) {
            FundTransfer(beneficiary, wAmount, false);
            resAmount -= wAmount;
        }
    }

    // dev function for withdraw resAmount (active only if minimumTarget is reached)
    function devResWithdrawal() {
        if (!minimumTargetReached || !(beneficiary == msg.sender)) throw;
        if (beneficiary.send(resAmount)) {
            FundTransfer(beneficiary, resAmount, false);
            resAmount -= resAmount;
        }
    }

    // dev function for close crowdsale  
    function closeCrowdsale(bool closeType) {
         if (beneficiary == msg.sender) {
            crowdsaleClosed = closeType;
         }
    }


    modifier afterDeadline() { if (now >= deadline) _; }

    // checks if the minimumTarget has been reached
    function checkTargetReached() afterDeadline {
        if (amountRaised >= minimumTarget) {
            minimumTargetReached = true;
        }
    }

    // function for return non sold tokens to dev account after crowdsale
    function returnTokens(uint tokensAmount) afterDeadline {
        if (!crowdsaleClosed) throw;
        if (beneficiary == msg.sender) {
            tokenReward.transfer(beneficiary, tokensAmount);
        }
    }

    // return your funds after deadline if minimumTarget is not reached (active if crowdsale close)
    function safeWithdrawal() afterDeadline {
        if (!crowdsaleClosed) throw;
        if (!minimumTargetReached && crowdsaleClosed) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                    resAmount -= amount;
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
    }
}