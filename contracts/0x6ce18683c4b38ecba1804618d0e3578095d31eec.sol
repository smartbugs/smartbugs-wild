pragma solidity 0.4.24;

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}


contract PurchasePackInterface {
    function basePrice() public returns (uint);
    function purchaseFor(address user, uint16 packCount, address referrer) public payable;
}









contract Vault is Ownable { 

    function () public payable {

    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount);
        owner.transfer(amount);
    }

    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }
}



contract DiscountPack is Vault {

    PurchasePackInterface private pack;
    uint public basePrice;
    uint public baseDiscount;

    constructor(PurchasePackInterface packToDiscount) public {
        pack = packToDiscount;

        baseDiscount = uint(7) * pack.basePrice() / uint(100);
        basePrice = pack.basePrice() - baseDiscount;
    }

    event PackDiscount(address purchaser, uint16 packs, uint discount);
 
    function() public payable {}

    function purchase(uint16 packs) public payable {
        uint discountedPrice = packs * basePrice;
        uint discount = packs * baseDiscount;
        uint fullPrice = discountedPrice + discount;

        require(msg.value >= discountedPrice, "Not enough value for the desired pack count.");
        require(address(this).balance >= discount, "This contract is out of front money.");

        // This should route the referral back to this contract
        pack.purchaseFor.value(fullPrice)(msg.sender, packs, this);
        emit PackDiscount(msg.sender, packs, discount);
    }

    function fraction(uint value, uint8 num, uint8 denom) internal pure returns (uint) {
        return (uint(num) * value) / uint(denom);
    }
}


contract DiscountShinyLegendaryPack is DiscountPack {
    constructor(PurchasePackInterface packToDiscount) public payable DiscountPack(packToDiscount) {
        
    }
}