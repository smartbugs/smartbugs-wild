pragma solidity ^0.4.25;

contract Roulette {
    uint256 private topSecretNumber;
    uint256 public lastPlayed;
    uint256 public betPrice = 0.1 ether;
    address public owner;

    struct Game {
        address player;
        uint256 number;
    }
    Game[] public gamesPlayed;

    constructor() payable public {
        owner = msg.sender;
        shuffle();
    }

    function shuffle() internal {
        // randomly set topSecretNumber with a value between 1 and 20
        topSecretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 20 + 1;
    }

    function play(uint256 number) payable public {
        require(msg.value >= betPrice && number <= 10);

        Game game;
        game.player = msg.sender;
        game.number = number;
        gamesPlayed.push(game);

        if (number == topSecretNumber) {
            // win!
            msg.sender.transfer(address(this).balance);
        }

        shuffle();
        lastPlayed = now;
    }

   function kill() public {
        if (msg.sender == owner && now > lastPlayed + 1 days) {
            selfdestruct(msg.sender);
        }
    }

    function withdraw() payable public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    
    function withdraw(uint256 amount) payable public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }
    
    function() public payable {}
}