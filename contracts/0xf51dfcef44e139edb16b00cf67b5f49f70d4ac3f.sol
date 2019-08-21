pragma solidity ^0.4.18;

/*
Game Name: MyCryptoBuilding
Game Link: https://mycryptobuilding.net/
*/

contract MyCryptoBuilding {

    address ownerAddress = 0x9aFbaA3003D9e75C35FdE2D1fd283b13d3335f00;
    
    modifier onlyOwner() {
        require (msg.sender == ownerAddress);
        _;
    }

    address buildingOwnerAddress;
    uint256 buildingPrice;
    
    struct Appartement {
        address ownerAddress;
        uint256 curPrice;
    }
    Appartement[] appartments;

    /*
    This function allows players to purchase the building. 
    The price is automatically multiplied by 1.5 after each purchase.
    */
    function purchaseBuilding() public payable {
        require(msg.value == buildingPrice);

        // Calculate the 2% & 5% value
        uint256 commission2percent = ((msg.value / 100)*2);
        uint256 commission5percent = ((msg.value / 10)/2);

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission5percent * 3); // => 85%
        buildingOwnerAddress.transfer(commissionOwner);

        // Transfer 2% commission to the appartments owner
        for (uint8 i = 0; i < 5; i++) {
            appartments[i].ownerAddress.transfer(commission2percent);
        }

        // Transfer the 5% commission to the developer
        ownerAddress.transfer(commission5percent); // => 5%                   

        // Update the company owner and set the new price
        buildingOwnerAddress = msg.sender;
        buildingPrice = buildingPrice + (buildingPrice / 2);
    }

    // This function allows user to purchase an appartment
    function purchaseAppartment(uint _appartmentId) public payable {
        require(msg.value == appartments[_appartmentId].curPrice);

        // Calculate the 10% & 5% value
        uint256 commission10percent = (msg.value / 10);
        uint256 commission5percent = ((msg.value / 10)/2);

        // Calculate the owner commission on this sale & transfer the commission.      
        uint256 commissionOwner = msg.value - (commission5percent + commission10percent); // => 85%
        appartments[_appartmentId].ownerAddress.transfer(commissionOwner);

        // Transfer 10% commission to the building owner
        buildingOwnerAddress.transfer(commission10percent);

        // Transfer the 5% commission to the developer
        ownerAddress.transfer(commission5percent); // => 5%                   

        // Update the company owner and set the new price
        appartments[_appartmentId].ownerAddress = msg.sender;
        appartments[_appartmentId].curPrice = appartments[_appartmentId].curPrice + (appartments[_appartmentId].curPrice / 2);
    }
    
    
    // These functions will return the details of a company and the building
    function getAppartment(uint _appartmentId) public view returns (
        address ownerAddress,
        uint256 curPrice
    ) {
        Appartement storage _appartment = appartments[_appartmentId];

        ownerAddress = _appartment.ownerAddress;
        curPrice = _appartment.curPrice;
    }
    function getBuilding() public view returns (
        address ownerAddress,
        uint256 curPrice
    ) {
        ownerAddress = buildingOwnerAddress;
        curPrice = buildingPrice;
    }

    /**
    @dev Multiplies two numbers, throws on overflow. => From the SafeMath library
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    @dev Integer division of two numbers, truncating the quotient. => From the SafeMath library
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    // Initiate functions that will create the companies
    function InitiateGame() public onlyOwner {
        buildingOwnerAddress = ownerAddress;
        buildingPrice = 225000000000000000;
        appartments.push(Appartement(ownerAddress, 75000000000000000));
        appartments.push(Appartement(ownerAddress, 75000000000000000));
        appartments.push(Appartement(ownerAddress, 75000000000000000));
        appartments.push(Appartement(ownerAddress, 75000000000000000));
        appartments.push(Appartement(ownerAddress, 75000000000000000));

    }
}