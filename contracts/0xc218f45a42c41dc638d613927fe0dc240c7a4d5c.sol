pragma solidity 0.4.25;

contract PackInterface {
    
    function purchaseFor(address user, uint16 packCount, address referrer) public payable;
    
    function calculatePrice(uint base, uint16 packCount) public view returns (uint);
    
    function basePrice() public returns (uint);
}

contract MultiPurchaser {
    
    function purchaseFor(address pack, address[] memory users, uint16 packCount, address referrer) public payable {
        
        uint price = PackInterface(pack).calculatePrice(PackInterface(pack).basePrice(), packCount);
        
        for (uint i = 0; i < users.length; i++) {
            
            PackInterface(pack).purchaseFor.value(price)(users[i], packCount, referrer);
        }
    }
    
}