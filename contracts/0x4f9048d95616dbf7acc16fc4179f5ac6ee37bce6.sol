pragma solidity ^0.4.17;

contract Lottery {
    
    address public manager;
    address[] public players;
    address public winner;
    event Transfer(address indexed to, uint256 value);
    
    function Lottery () public {
        manager = msg.sender;
    }
    
    //投注
    function enter() public payable {
        //最小金额
        require(msg.value > .01 ether);
        
        players.push(msg.sender);
        
    }
    
    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }
    
    function pickWinner() public restricted returns (address[]) {
        uint index = random() % players.length;
        winner =  players[index];
        winner.transfer(this.balance);
        emit Transfer(winner,this.balance);
        players = new address[](0);
        return players;
    }
    
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    function getContractBalance() public view returns (uint) {
        return this.balance;
    }

    function getPlayers() public view returns (address[]){
        return players;
    }
}