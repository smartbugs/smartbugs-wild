pragma solidity ^0.4.23;


contract PublicInterface { 
    function getRabbitSirePrice(uint32 _bunny) public view returns(uint);
    function setRabbitSirePrice( uint32 _bunny, uint count) external;
}

contract SetSire {  
    event ChengeSex(uint32 bunnyId, uint256 price);

    address public pubAddress; 

    PublicInterface publicContract; 
 
    constructor() public { 
        transferContract(0x2Ed020b084F7a58Ce7AC5d86496dC4ef48413a24);
    }
    
    function transferContract(address _pubAddress) public {
        require(_pubAddress != address(0)); 
        pubAddress = _pubAddress;
        publicContract = PublicInterface(_pubAddress);
    } 


    function setRabbitSirePrice (
        uint32 bunny_1, 
        uint price_1,
        uint32 bunny_2, 
        uint price_2,
        uint32 bunny_3, 
        uint price_3,
        uint32 bunny_4, 
        uint price_4,
        uint32 bunny_5, 
        uint price_5,
        uint32 bunny_6, 
        uint price_6
    ) public {

        if(publicContract.getRabbitSirePrice(bunny_1) == 0 && price_1 != 0){ 
            publicContract.setRabbitSirePrice(bunny_1, price_1);
          emit ChengeSex(bunny_1,  publicContract.getRabbitSirePrice(bunny_1));
        }

        if(publicContract.getRabbitSirePrice(bunny_2) == 0 && price_2 != 0){ 
            publicContract.setRabbitSirePrice(bunny_2, price_2);
          emit ChengeSex(bunny_2,  publicContract.getRabbitSirePrice(bunny_2));
        }

        if(publicContract.getRabbitSirePrice(bunny_3) == 0 && price_3 != 0){ 
            publicContract.setRabbitSirePrice(bunny_3, price_3);
          emit ChengeSex(bunny_3,  publicContract.getRabbitSirePrice(bunny_3));
        }

        if(publicContract.getRabbitSirePrice(bunny_4) == 0 && price_4 != 0){ 
            publicContract.setRabbitSirePrice(bunny_4, price_4);
          emit ChengeSex(bunny_4,  publicContract.getRabbitSirePrice(bunny_4));
        }

        if(publicContract.getRabbitSirePrice(bunny_5) == 0 && price_5 != 0){ 
            publicContract.setRabbitSirePrice(bunny_5, price_5);
          emit ChengeSex(bunny_5,  publicContract.getRabbitSirePrice(bunny_5));
        }

        if(publicContract.getRabbitSirePrice(bunny_6) == 0 && price_6 != 0){ 
            publicContract.setRabbitSirePrice(bunny_6, price_6);
          emit ChengeSex(bunny_6,  publicContract.getRabbitSirePrice(bunny_6));
        }
    }
}