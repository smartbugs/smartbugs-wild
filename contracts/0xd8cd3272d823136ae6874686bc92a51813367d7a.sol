pragma solidity >=0.4.22 <0.6.0;
contract KingOfTheHillCards {

    struct Card {
        uint256 nonce;
        address owner;
        bool exists;
    }
    
    mapping(uint256 => Card) public cards;
    uint256[] public cardsLUT;//Look Up Table

    constructor() public {}
    
    function add(uint256 hash, uint256 nonce) public {
        require(!cards[hash].exists);
        cards[hash].nonce = nonce;
        cards[hash].owner = msg.sender;
        cards[hash].exists = true;
        cardsLUT.push(hash);
    }
    
    function transfer(uint256 hash, address to) public {
        require(cards[hash].owner == msg.sender);
        cards[hash].owner = to;
    }
}