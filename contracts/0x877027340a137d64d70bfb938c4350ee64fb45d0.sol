pragma solidity ^0.4.11;

contract RedEnvelope{
    address owner;
    uint remainSize = 0;
    uint min = 1000000000000000; // 0.001 ETH
    uint max;
    uint256 money;
    mapping (address => uint) earned;
    
    function RedEnvelope() {
        owner = msg.sender;
    }
    
    function despoit(uint count) returns (uint){
        if (msg.sender != owner) {
            throw;
        }
        remainSize += count;
        return remainSize;
    }
    
    function randomGen(uint seed, uint max) constant returns (uint randomNumber) {
        return(uint(sha3(block.blockhash(block.number - 1), seed)) % max);
    }

    function multiBlockRandomGen(uint seed, uint size) constant returns (uint randomNumber) {
        uint n = 0;
        for (uint i = 0; i < size; i++){
            if (uint(sha3(block.blockhash(block.number - i - 1), seed )) % 2 == 0)
                n += 2 ** i ;
        }
        return n;
    }
    
    function goodluck(uint seed) payable {
        if (earned[msg.sender] == 1) {
            throw;
        }
        if (remainSize == 0) {
            throw;
        }
        earned[msg.sender] = 1;
        remainSize -= 1;
        if (remainSize == 0) {
            msg.sender.transfer(this.balance);
            return;
        }
        max = this.balance / remainSize * 2;
        money = randomGen(seed, max);
        if (money < min) {
            money = min;
        }
        msg.sender.transfer(money);
    }
    
    function goodbye() {
        if (msg.sender != owner) {
            throw;
        }
        suicide(owner);
    }
}