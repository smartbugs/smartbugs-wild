pragma solidity ^0.4.24;

contract Whiskey {
    
   event Selling(
        address seller,
        address buyer,
        uint price
    );

    uint public totalSupply = 201;
    bool private initedCopper = false;
    bool private initedBronze = false;
    bool private initedSilver = false;
    bool private initedGold = false;
    bool private initedPlatinum = false;
    
    struct Bottle {
        uint    id;
        uint    price;
        uint    sellPrice;
        address owner;
        string  name;
        string  info;
        bool    infoLocked;
        bool    saleLocked;
    }
    
    Bottle[202] public bottle;
    
    constructor() public {
            bottle[1].id = 1;
            bottle[1].price = 1 ether;
            bottle[1].sellPrice = 1 ether;
            bottle[1].owner = msg.sender;
            bottle[1].infoLocked = false;
            bottle[1].saleLocked = false;
            bottle[201].id = 201;
            bottle[201].price = 50000 ether;
            bottle[201].sellPrice = 5000 ether;
            bottle[201].owner = msg.sender;
            bottle[201].infoLocked = false;
            bottle[201].saleLocked = false;
    }
    
    function initCopper() public {
        if (initedCopper == false){
            for (uint i = 2; i < 31; i++) {
                bottle[i].id = i;
                bottle[i].price = 15 ether;
                bottle[i].sellPrice = 15 ether;
                bottle[i].owner = msg.sender;
                bottle[i].infoLocked = false;
                bottle[i].saleLocked = false;
            }
            initedCopper = true;
        }
    }
    
    function initBronze() public {
        if (initedBronze == false) {
            for (uint i = 31; i < 71; i++) {
                bottle[i].id = i;
                bottle[i].price = 35 ether;
                bottle[i].sellPrice = 35 ether;
                bottle[i].owner = msg.sender;
                bottle[i].infoLocked = false;
                bottle[i].saleLocked = false;
            }
            initedBronze = true;
        }
    }
    
    function initSilver() public {
         if (initedSilver == false) {
             for (uint i = 71; i < 131; i++) {
                bottle[i].id = i;
                bottle[i].price = 50 ether;
                bottle[i].sellPrice = 50 ether;
                bottle[i].owner = msg.sender;
                bottle[i].infoLocked = false;
                bottle[i].saleLocked = false;
            }
            initedSilver = true;
         }
    }
    
    function initGold() public {
         if (initedGold == false) {
             for (uint i = 131; i < 171; i++) {
                bottle[i].id = i;
                bottle[i].price = 65 ether;
                bottle[i].sellPrice = 65 ether;
                bottle[i].owner = msg.sender;
                bottle[i].infoLocked = false;
                bottle[i].saleLocked = false;
            }
            initedGold = true;    
        }
    }
    
    function initPlatinum() public {
        if (initedPlatinum == false) {
            for (uint i = 171; i < 201; i++) {
                bottle[i].id = i;
                bottle[i].price = 85 ether;
                bottle[i].sellPrice = 85 ether;
                bottle[i].owner = msg.sender;
                bottle[i].infoLocked = false;
                bottle[i].saleLocked = false;
            }
            initedPlatinum = true;
        }
    }
    
    function sell(uint price, uint id) public {
        if (bottle[id].owner == msg.sender && price > bottle[id].price){
            bottle[id].sellPrice = price;
            bottle[id].saleLocked = false;
        }
    }
    
    function cancelSell (uint id) public {
        if (bottle[id].owner == msg.sender) {
            bottle[id].sellPrice = 0;
            bottle[id].saleLocked = true;
        }
    }
    
    function buy(uint id) public payable {
        if(bottle[id].sellPrice != msg.value || bottle[id].saleLocked == true) {
        	revert();
        }
        address seller = bottle[id].owner;
        bottle[id].owner.transfer(msg.value);     
        bottle[id].owner = msg.sender;
        bottle[id].price = msg.value;
        bottle[id].infoLocked = false;
        bottle[id].saleLocked = true;
        emit Selling(seller, msg.sender, msg.value);
        
    }
    
    function changeInfo(uint id, string name, string info) public {

        if(bottle[id].owner == msg.sender) {
            bottle[id].name = name;
            bottle[id].info = info;
            bottle[id].infoLocked = true;    
        }
    }
    
    function gift(uint id, address newOwner) public {
        if(bottle[id].owner == msg.sender) {
            bottle[id].owner = newOwner;
            bottle[id].infoLocked = false;
        }
    }
}