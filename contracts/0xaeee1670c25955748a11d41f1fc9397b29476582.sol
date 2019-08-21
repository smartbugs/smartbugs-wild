pragma solidity ^0.4.24;

contract Random {

    address private ownerAddr;

    uint[] public randoms;

    constructor() public{
        ownerAddr = msg.sender;
    }

    function getRandomOne(uint range) public returns (uint){
        require(msg.sender == ownerAddr);
        require(range > 0);

        getRandoms(range, 1);
        return randoms[0];
    }

    function getRandoms(uint range, uint num) public returns (uint[]){
        require(msg.sender == ownerAddr);
        require(range >= num);

        randoms = new uint[](num);
        uint randNonce = 0;
        for (uint i = 0; i < num; i++) {
            randNonce++;
            uint random = uint(keccak256(abi.encodePacked(now, randNonce))) % range + 1;
            while (!checkUnique(random)) {
                randNonce++;
                random = uint(keccak256(abi.encodePacked(now, randNonce))) % range + 1;
            }
            randoms[i] = random;
        }
        return randoms;
    }

    function checkUnique(uint random) private view returns (bool){
        for (uint i = 0; i < randoms.length; i++) {
            if (randoms[i] == random) {
                return false;
            }
        }
        return true;
    }
}