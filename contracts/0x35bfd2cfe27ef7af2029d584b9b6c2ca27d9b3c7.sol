pragma solidity ^0.4.25;

/**
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT  4% DAILY
*
* How to invest?
* Send any sum to smart contract address.
* The minimum investment amount is 0.01 ETH 
* The recommended gas limit is 200000 
* The contract remembers the address of your wallet, as well as the amount and time of a deposit. 
* Every 24 hours after the deposit you have 4% of the amount invested by you.
* You can receive a payment at any time by sending 0 ETH to the address of the contract. 
* 
*  Web          - http://easyethprofit.org
*  Telegram_chat: https://t.me/EasyEthProfit
*/

contract EasyEthProfit{
    mapping (address => uint256) invested;
    mapping (address => uint256) dateInvest;
    uint constant public FEE = 4;
    uint constant public ADMIN_FEE = 10;
    address private adminAddr;
    
    constructor() public{
        adminAddr = msg.sender;
    }

    function () external payable {
        address sender = msg.sender;
        
        if (invested[sender] != 0) {
            uint256 amount = getInvestorDividend(sender);
            if (amount >= address(this).balance){
                amount = address(this).balance;
            }
            sender.send(amount);
        }

        dateInvest[sender] = now;
        invested[sender] += msg.value;

        if (msg.value > 0){
            adminAddr.send(msg.value * ADMIN_FEE / 100);
        }
    }
    
    function getInvestorDividend(address addr) public view returns(uint256) {
        return invested[addr] * FEE / 100 * (now - dateInvest[addr]) / 1 days;
    }

}