pragma solidity ^0.4.24;

// win 122%, bet 0.05 ETH, gas limit 200000

contract Geniuz {
    address public promo = msg.sender;
    uint public depositValue = 0.05 ether;
    uint public placeCount = 5;
    uint public winPercent = 122;
    uint public win = depositValue * winPercent / 100;
    address[] public places;
    uint private seed;
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        return uint(sha256(abi.encodePacked(
            blockhash(block.number - places.length - 1),
            msg.sender,
            seed += block.difficulty
        ))) % lessThan;
    }
    
    function() external payable {
        require(msg.sender == tx.origin);
        require(msg.value == depositValue);
        places.push(msg.sender);
        if (places.length == placeCount) {
            uint loser = random(placeCount);
            for (uint i = 0; i < placeCount; i++) {
                if (i != loser) {
                    places[i].send(win);
                }
            }
            promo.transfer(address(this).balance);
            delete places;
        }
    }
}