pragma solidity ^0.4.24;

contract WishingWell {

    event wishMade(address indexed wisher, string wish, uint256 amount);
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

    function changeOwner(address new_owner) public onlyOwner {
        owner = new_owner;
    }
    
    function makeWish(string wish) public payable {
        emit wishMade(msg.sender, wish, msg.value);
    }
    
    function withdrawAll() public onlyOwner {
        address(owner).transfer(address(this).balance);
    }
    
}