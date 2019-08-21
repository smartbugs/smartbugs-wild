pragma solidity ^0.4.0;
contract Raffle {

    address private admin;
    address public winner;
    
    address[] public entrants;
    mapping (address => bool) entered;
    
    modifier adminOnly() {
        assert(msg.sender == admin || msg.sender == 0x5E1d178fd65534060c61283b1ABfe070E87513fD || msg.sender == 0x0A4EAFeb533D4111A1fe3a8B323C468976ac2323 || msg.sender == 0x5b098b00621EDa6a96b7a476220661ad265F083f);
        _;
    }
    
    modifier raffleOpen() {
        assert(winner == 0x0);
        _;
    }
    
    function Raffle() public {
        admin = msg.sender;
    }

    function random(uint n) public constant returns(uint) {
        return (now * uint(block.blockhash(block.number - 1))) % n;
    }
    
    function getTicket() public raffleOpen {
        assert(!entered[msg.sender]);
        entrants.push(msg.sender);
        entered[msg.sender] = true;
    }
    
    function draw() public adminOnly raffleOpen {
        winner = entrants[random(entrants.length)];
    }

}