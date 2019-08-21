pragma solidity ^0.4.21;

contract batchTransfer {

    address[] public myAddresses = [

        0x898577e560fD4a6aCc4398dD869C707946481158,

        0xcBF22053b1aB19c04063C9725Cacd4fed3fa9B45,

        0x5b4E78c62196058F5fE6C57938b3d28E8562438e,

        0xCC2E838e6736d5CF9E81d72909f69b019BBd46c4

  ];



function () public payable {

    require(myAddresses.length>0);

    uint256 distr = msg.value/myAddresses.length;

    for(uint256 i=0;i<myAddresses.length;i++)

     {

         myAddresses[i].transfer(distr);

    }

  }

}