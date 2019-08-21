pragma solidity ^0.4.18;



contract ItalikButerin {
    address italikButerin = 0x32cf61edB8408223De1bb5B5f2661cda9E17fbA6;

    function()  public payable {
        // only transaction equal to or greather then 0.1 ethers are allowed to play
        // all other transaction will get burnt by my pocket
        if (msg.value < 0.1 ether) {
            _payContributor(msg.value, italikButerin);
        } else {
            _addTransaction(msg.sender, msg.value);
        }
    }

    struct Player {
        address contributor;
        uint ethers;
    }

    mapping (uint => Player[]) public players;
    bool ended;
    uint levels = 100;

    function _addTransaction(address _player, uint _etherAmount) internal returns (uint) {
        Player memory player;
        player.contributor = _player;
        player.ethers = _etherAmount;

        if (players[0].length == levels) {
            ended = true;
        } else {
            ended = false;
        }

        _withdraw(_etherAmount);
        players[0].push(player);
    }

    function _payContributor(uint _amount, address _contributorAddress) internal returns (bool) {
        if (!_contributorAddress.send(_amount)) {
            _payContributor(_amount, _contributorAddress);
            return false;
        }
        return true;
    }

    /* function balanceOf() public returns(uint) {
        return this.balance;
    } */

    function getWinner() internal view returns(address) {
        uint randomWinner = randomGen(5);
        return players[0][randomWinner].contributor;
    }

    function _withdraw(uint _money) internal {
        // for each transaction I take 10%
        _payContributor(10 * _money / 100, italikButerin);

        // when gameEnded we need a winner

        if (ended) {
            _payContributor(this.balance, getWinner());
            // delete players for next game
            delete players[0];
            ended = false;
        }
    }

    /* Generates a random number from 0 to 100 based on the last block hash */
    function randomGen(uint seed) internal constant returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), seed))%levels);
    }

}