pragma solidity ^0.4.0;
contract SolarSystem {

    address public owner;

    //planet object
    struct Planet {
        string name;
        address owner;
        uint price;
        uint ownerPlanet;
    }
    
    function SolarSystem() public {
        owner = msg.sender;
    }
    
    //initiate
    function bigBang() public {
        if(msg.sender == owner){
            planets[0]  = Planet("The Sun",         msg.sender, 10000000000000000000, 0);
            planets[1]  = Planet("Mercury",         msg.sender,     1500000000000000, 0);
            planets[2]  = Planet("Venus",           msg.sender,     1000000000000000, 0);
            planets[3]  = Planet("Earth",           msg.sender,    50000000000000000, 0);
            planets[4]  = Planet("ISS",             msg.sender,    50000000000000000, 0);
            planets[5]  = Planet("The Moon",        msg.sender,      700000000000000, 3);
            planets[6]  = Planet("Mars",            msg.sender,    30000000000000000, 0);
            planets[7]  = Planet("Curiosity",       msg.sender,    10000000000000000, 6);
            planets[8]  = Planet("Tesla Roadster",  msg.sender,   500000000000000000, 0);
            planets[9]  = Planet("Jupiter",         msg.sender,   300000000000000000, 0);
            planets[10] = Planet("Callisto",        msg.sender,      900000000000000, 8);
            planets[11] = Planet("IO",              msg.sender,     1000000000000000, 8);
            planets[12] = Planet("Europa",          msg.sender,     2000000000000000, 8);
            planets[13] = Planet("Saturn",          msg.sender,   200000000000000000, 0);
            planets[14] = Planet("Titan",           msg.sender,      800000000000000, 13);
            planets[15] = Planet("Tethys",          msg.sender,      500000000000000, 13);
            planets[16] = Planet("Uranus",          msg.sender,   150000000000000000, 0);
            planets[17] = Planet("Titania",         msg.sender,       80000000000000, 16);
            planets[18] = Planet("Ariel",           msg.sender,     1000000000000000, 16);
            planets[19] = Planet("Neptune",         msg.sender,    50000000000000000, 0);
            planets[20] = Planet("Triton",          msg.sender,        9000000000000, 19);
            planets[21] = Planet("Pluto",           msg.sender,      800000000000000, 0);
        }
    }
    
    //list the current sale price of a planet
    function listSales(uint id) public{
        if(msg.sender == owner){
            Sale(planets[id].name, planets[id].price, msg.sender);
        }
    }
    
    //list of planets
    mapping (uint => Planet) planets;
    
    //register when a planet is offered for sale
    event Sale(string name, uint price, address new_owner);
    
    //register price increase
    event PriceIncrease(string name, uint price, address new_owner);
    
    //register price decrease
    event PriceDecrease(string name, uint price, address new_owner);
    
    //change message
    event ChangeMessage(string name, string message);
    
    //buy a planet
    function buyPlanet(uint id) public payable {
        if(msg.value >= planets[id].price){
            //distribute the money
            uint cut = (msg.value*2)/100;
            planets[id].owner.transfer(msg.value-cut);
            planets[planets[id].ownerPlanet].owner.transfer(cut);
            //change owner
            planets[id].owner = msg.sender;
            planets[id].price += (msg.value*5)/100;
            Sale(planets[id].name, planets[id].price, msg.sender);
            if(msg.value > planets[id].price){
                msg.sender.transfer(msg.value-planets[id].price);
            }
        }
        else{
            msg.sender.transfer(msg.value);
        }
    }
    
    //increase price with 5%
    function increasePrice(uint id) public {
        if(planets[id].owner == msg.sender){
            uint inc = (planets[id].price*5)/100;
            planets[id].price += inc;
            PriceIncrease(planets[id].name, planets[id].price, msg.sender);
        }
    }
    
    //decrease price with 5%
    function decreasePrice(uint id) public {
        if(planets[id].owner == msg.sender){
            uint dec = (planets[id].price*5)/100;
            planets[id].price -= dec;
            PriceDecrease(planets[id].name, planets[id].price, msg.sender);
        }
    }
    
    function changeMessage(uint id, string message) public {
         if(planets[id].owner == msg.sender){
            ChangeMessage(planets[id].name, message);
        }
    }
}