pragma solidity ^0.4.18;

/*
This is the pre-sale contract for MyEtherCity's lands. You can join our pre-sale on https://myethercity.com/  
Game Name: MyEtherCity
Game Link: https://myethercity.com/
*/

contract MyEtherCity {

    address ceoAddress = 0x699dE541253f253a4eFf0D3c006D70c43F2E2DaE;
    address cfoAddress = 0x50f75eAD8CEE4376704d39842B14F400b4263cca;
    
    modifier onlyCeo() {
        require (msg.sender == ceoAddress);
        _;
    }

    uint256 curPriceLand = 1000000000000000;
    uint256 stepPriceLand = 2000000000000000;
    
    // How many lands an addres own
    mapping (address => uint) public addressLandsCount;
    
    struct Land {
        address ownerAddress;
        uint256 pricePaid;
        uint256 curPrice;
        bool isForSale;
    }
    Land[] lands;

    /*
    This function allows players to purchase lands during our pre-sale.
    The price of lands is raised by 0.002 eth after each successful purchase.
    */
    function purchaseLand() public payable {
        // We verify that the amount paid is the right amount
        require(msg.value == curPriceLand);
        
        // We verify that we don't create more than 300 lands
        require(lands.length < 300);
        
        // We create the land
        lands.push(Land(msg.sender, msg.value, 0, false));
        addressLandsCount[msg.sender]++;
        
        // We increase the price of the lands
        curPriceLand = curPriceLand + stepPriceLand;
        
        // We transfer the amount paid to the cfo
        cfoAddress.transfer(msg.value);
    }
    
    
    // These functions will return the details of a piece of land
    function getLand(uint _landId) public view returns (
        address ownerAddress,
        uint256 pricePaid,
        uint256 curPrice,
        bool isForSale
    ) {
        Land storage _land = lands[_landId];

        ownerAddress = _land.ownerAddress;
        pricePaid = _land.pricePaid;
        curPrice = _land.curPrice;
        isForSale = _land.isForSale;
    }
    
    // Get all the lands owned by a specific address
    function getSenderLands(address _senderAddress) public view returns(uint[]) {
        uint[] memory result = new uint[](addressLandsCount[_senderAddress]);
        uint counter = 0;
        for (uint i = 0; i < lands.length; i++) {
          if (lands[i].ownerAddress == _senderAddress) {
            result[counter] = i;
            counter++;
          }
        }
        return result;
    }
    
    // This function will return the data about the pre-sale (how many lands purchased, current price)
    function getPreSaleData() public view returns(uint, uint256) {
        return(lands.length, curPriceLand);
    } 
}