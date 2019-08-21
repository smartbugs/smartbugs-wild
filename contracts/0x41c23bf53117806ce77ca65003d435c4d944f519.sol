/**
 * @title Contractus contract
 * Funds distribution:
 * 90% - deposit funds
 * 3%  - support
 * 7% -  marketing
 * Allows you to receive income up to 2 deposit amounts and above if you continue to keep the deposit. 
 * You can receive income 200% or more only once. In this case the deposit is closed. 
 * Thus, the longer you keep the deposit open and do not withdraw your income, the more your potential gain becomes.
 *Payments are terminated after the completion of 200%. To re-enter the game, you must replenish your deposit.
 * You can receive your income at any time, based on a 2.5% per day calculation to 200%
 * 
 * This contract is a game - a lottery, in which prizes - payments on the deposit. 
 * The contract is not a pyramid, since all deposits have a finite period of validity of payments. 
 * You should not use this contract for investment purposes. Only for the game - lottery.
 * By sending funds to this contract, you should understand that it is possible that the balance 
 * of the contract will not be enough to pay all players. 
 * Contract developers have not left themselves any functions for the withdrawal of players' funds, 
 * but this is just a game - remember this.
 */



pragma solidity ^0.4.24;
contract Contractus {
    mapping (address => uint256) public balances;
    mapping (address => uint256) public timestamp;
    mapping (address => uint256) public receiveFunds;
    uint256 internal totalFunds;
    
    address support;
    address marketing;

    constructor() public {
        support = msg.sender;
        marketing = 0x53B83d7be0D19b9935363Af1911b7702Cc73805e;
    }

    function showTotal() public view returns (uint256) {
        return totalFunds;
    }

    function showProfit(address _investor) public view returns (uint256) {
        return receiveFunds[_investor];
    }

    function showBalance(address _investor) public view returns (uint256) {
        return balances[_investor];
    }

    /**
     * The function will show you whether your deposit will remain in the game after the withdrawal of revenue or close after reaching 200%
     * A value of "true" means that your deposit will be closed after withdrawal of funds
     */
    function isLastWithdraw(address _investor) public view returns(bool) {
        address investor = _investor;
        uint256 profit = calcProfit(investor);
        bool result = !((balances[investor] == 0) || (balances[investor] * 2 > receiveFunds[investor] + profit));
        return result;
    }

    function calcProfit(address _investor) internal view returns (uint256) {
        uint256 profit = balances[_investor]*25/1000*(now-timestamp[_investor])/86400; // a seconds in one day
        return profit;
    }


    function () external payable {
        require(msg.value > 0,"Zero. Access denied.");
        totalFunds +=msg.value;
        address investor = msg.sender;
        support.transfer(msg.value * 3 / 100);
        marketing.transfer(msg.value * 7 / 100);

        uint256 profit = calcProfit(investor);
        investor.transfer(profit);

        if (isLastWithdraw(investor)){
            /**
             * @title Closing of the deposit
             * 
             *  You have received 200% (or more) of your contribution.
             *  Under the terms of the game, your contribution is closed, the statistics are reset.
             *  You can start playing again. We wish you good luck!
             */
            balances[investor] = 0;
            receiveFunds[investor] = 0;
           
        }
        else {
        receiveFunds[investor] += profit;
        balances[investor] += msg.value;
            
        }
        timestamp[investor] = now;
    }

}