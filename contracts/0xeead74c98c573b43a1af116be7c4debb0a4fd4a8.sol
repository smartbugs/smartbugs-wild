pragma solidity ^0.4.21;

contract Line {
    
    address private owner;

    uint constant public jackpotNumerator = 50;
    uint constant public winNumerator = 5;
    uint constant public denominator = 100;
    
    uint public jackpot = 0;

    event Jackpot(uint line, address addr, uint date, uint prize, uint left);
    event Win(uint line, address addr, uint date, uint prize, uint left);
    event JackpotIncreased(uint date, uint jackpot);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Line() public {
        owner = msg.sender;
    }

    function waiver() private {
        delete owner;
    }

    function() payable public {

        jackpot += msg.value;
        
        uint token = random();
        
        uint prizeNumerator = 0;
        
        if (token == 777) {
            prizeNumerator = jackpotNumerator;
        }
        
        if (token == 666 || token == 555 || token == 444 
         || token == 333 || token == 222 || token == 111) {
            prizeNumerator = winNumerator;
        }
        
        if (prizeNumerator > 0) {
            msg.sender.transfer(0 wei); // supposed to reject contracts
            uint prize = this.balance / 100 * prizeNumerator;
            if (msg.sender.send(prize)) {
                if (prizeNumerator == jackpotNumerator) {
                    emit Jackpot(token, msg.sender, now, prize, this.balance);
                } else {
                    emit Win(token, msg.sender, now, prize, this.balance);
                }
                owner.transfer(this.balance / 100); // owners fee
            }
        } else {
            emit JackpotIncreased(now, jackpot);
        }
    }

    function reset() onlyOwner public {
        owner.transfer(this.balance);
    }

    uint nonce;

    function random() internal returns (uint) {
        uint rand = uint(keccak256(now, msg.sender, nonce)) % 778;
        nonce++;
        return rand;
    }
}