pragma solidity ^0.4.2;

contract Token {
	function balanceOf(address user) constant returns (uint256 balance);
	function transfer(address receiver, uint amount) returns(bool);
}

contract BonusDealer {
    address public owner;
    Token public nexium;
    uint public totalDistributed;
    address[] public paidAddress;
    mapping(address => uint) public paid;
    
    struct Bonus {
        uint bonusInNxc;
        uint step;
    }
    
    Bonus[] bonuses;
    
    event Paid(address);
    
    uint nxcBought;
    
    function BonusDealer(){
        nexium = Token(0x45e42D659D9f9466cD5DF622506033145a9b89Bc);
        owner = msg.sender;
        totalDistributed = 0;
        bonuses.length++;
        bonuses[0] = Bonus(0, 0);
        bonuses.length++;
        bonuses[1] = Bonus(80*1000, 4000*1000);
        bonuses.length++;
        bonuses[2] = Bonus(640*1000, 16000*1000);
        bonuses.length++;
        bonuses[3] = Bonus(3000*1000, 50000*1000);
        bonuses.length++;
        bonuses[4] = Bonus(8000*1000, 100000*1000);
        bonuses.length++;
        bonuses[5] = Bonus(40000*1000, 400000*1000);
        bonuses.length++;
        bonuses[6] = Bonus(78000*1000, 650000*1000);
        bonuses.length++;
        bonuses[7] = Bonus(140000*1000, 1000000*1000);
        bonuses.length++;
        bonuses[8] = Bonus(272000*1000, 1700000*1000);
    }
    
    function bonusCalculation(uint _nxcBought) returns(uint){
        nxcBought = _nxcBought;
        uint totalToPay = 0;
        uint toAdd = 1;
        while (toAdd != 0){
            toAdd = recursiveCalculation();
            totalToPay += toAdd;
        }
        
        return totalToPay;
    }
    
    function recursiveCalculation() internal returns(uint){
        var i = 8;
        while (i != 0 && bonuses[i].step > nxcBought) i--;
        nxcBought -= bonuses[i].step;
        return bonuses[i].bonusInNxc;
    }
    
    function payDiff(address backer, uint totalNxcBought){
        if (msg.sender != owner) throw;
        if (paid[backer] == 0) paidAddress[paidAddress.length++] = msg.sender;
        uint totalToPay = bonusCalculation(totalNxcBought);
        if(totalToPay <= paid[backer]) throw;
        totalToPay -= paid[backer];
        if (!nexium.transfer(backer, totalToPay)) throw;
        paid[backer] += totalToPay;
        totalDistributed += totalToPay;
        Paid(backer);
    }
    
    function withdrawNexiums(address a){
        if (msg.sender != owner) throw;
        nexium.transfer(a, nexium.balanceOf(this));
    }
    
    function(){
        throw;
    }
}