pragma solidity ^0.4.24;

/*
* dP     dP   .88888.  888888ba  dP            .88888.   .d888888  8888ba.88ba   88888888b .d88888b  
* 88     88  d8'   `8b 88    `8b 88           d8'   `88 d8'    88  88  `8b  `8b  88        88.    "' 
* 88aaaaa88a 88     88 88     88 88           88        88aaaaa88a 88   88   88 a88aaaa    `Y88888b. 
* 88     88  88     88 88     88 88           88   YP88 88     88  88   88   88  88              `8b 
* 88     88  Y8.   .8P 88    .8P 88           Y8.   .88 88     88  88   88   88  88        d8'   .8P 
* dP     dP   `8888P'  8888888P  88888888P     `88888'  88     88  dP   dP   dP  88888888P  Y88888P  
*ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*
* Official Website: www.hodl-games.com | All rights reserved. Deployed by Wizard of 0x & James
*
*ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

contract TheWarRedNation
{
    struct _Tx {
        address txuser;
        uint txvalue;
    }
    _Tx[] public Tx;
    uint public counter;

    address owner;


    modifier onlyowner
    {
        if (msg.sender == owner)
        _;
    }
    constructor () public {
        owner = msg.sender;

    }

    function() public payable {
        require(msg.value>=0.01 ether);
        Sort();
    }

    function Sort() internal
    {
       uint feecounter;
       feecounter=msg.value/5;
	   owner.send(feecounter);
	   feecounter=0;
	   uint txcounter=Tx.length;
	   counter=Tx.length;
	   Tx.length++;
	   Tx[txcounter].txuser=msg.sender;
	   Tx[txcounter].txvalue=msg.value;
    }

    function Count(uint end, uint start) public onlyowner {
        while (end>start) {
            Tx[end].txuser.send((Tx[end].txvalue/1000)*200);
            end-=1;
        }
    }

}