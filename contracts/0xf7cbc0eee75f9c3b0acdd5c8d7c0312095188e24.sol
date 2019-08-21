pragma solidity ^0.4.15;

contract Dice1{
    
    uint public minbet = 10000000000000000; // bet minimum 0.01 ether
    uint public maxbet; // bet maximum
    uint public houseedge = 190; // 190%% house edge
    uint public luckynum;
    string public winlose;
    
    address public banker;
    
    event YouWin(address winner, uint betvalue, uint winvalue);
    event YouLose(address loser, uint betvalue);
    
    /* Constructor */
    function Dice1() payable{
        maxbet = msg.value/5;
        require(maxbet > minbet);
        
        banker = msg.sender;
    }
    
    // called by contract to generate random number between 0-9
    function _getrand09() returns(uint) {
        return uint(block.blockhash(block.number-1))%10;
    }
    
    // receive gambler's money and start betting
    function () payable {
        require(msg.value >= minbet);
        require(msg.value <=maxbet);
        require(this.balance >= msg.value*2);
        
        luckynum = _getrand09();
        if (luckynum < 5) {
            uint winvalue = msg.value*2*(10000-190)/10000;
            YouWin(msg.sender, msg.value, winvalue);
            msg.sender.transfer(winvalue);
            winlose = 'win';
        }
        else{
            YouLose(msg.sender, msg.value);
            msg.sender.transfer(1);
            winlose = 'lose';
        }
    }
    
    // get money back
    function kill() {
        require(msg.sender == banker);
        suicide(banker);
    }
}