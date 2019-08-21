pragma solidity ^0.4.8;


contract PreICO {
    bool public isPreIco;
    address manager;

    uint256 maxPreOrderAmount = 500000000000000000000; //in wei
    uint256 maxAmountSupply = 1875000000000000000000;

    struct dataHolder {
        uint256 balance;
        bool init;
    }
    mapping(address => dataHolder) holders;
    address[] listHolders;

    function PreICO(){
        manager = msg.sender;
        isPreIco = false;
    }

    modifier isManager(){
        if (msg.sender!=manager) throw;
        _;
    }

    function kill() isManager {
        suicide(manager);
    }

    function getMoney() isManager {
        if(manager.send(this.balance)==false) throw;
    }

    function startPreICO() isManager {
        isPreIco = true;
    }

    function stopPreICO() isManager {
        isPreIco = false;
    }

    function countHolders() constant returns(uint256){
        return listHolders.length;
    }

    function getItemHolder(uint256 index) constant returns(address){
        if(index >= listHolders.length || listHolders.length == 0) return address(0x0);
        return listHolders[index];
    }

    function balancsHolder(address who) constant returns(uint256){
        return holders[who].balance;
    }

    function() payable
    {
        if(isPreIco == false) throw;

        uint256 amount = msg.value;

        uint256 return_amount = 0;

        if(this.balance + msg.value > maxAmountSupply){
            amount = maxAmountSupply - this.balance ;
            return_amount = msg.value - amount;
        }

        if(holders[msg.sender].init == false){
            listHolders.push(msg.sender);
            holders[msg.sender].init = true;
        }

        if((amount+holders[msg.sender].balance) > maxPreOrderAmount){
            return_amount += ((amount+holders[msg.sender].balance) - maxPreOrderAmount);
            holders[msg.sender].balance = maxPreOrderAmount;
        }
        else{
            holders[msg.sender].balance += amount;
        }

        if(return_amount>0){
            if(msg.sender.send(return_amount)==false) throw;
        }

        if(this.balance == maxAmountSupply){
            isPreIco = false;
        }
    }
}