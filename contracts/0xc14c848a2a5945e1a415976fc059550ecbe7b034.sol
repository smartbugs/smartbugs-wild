pragma solidity ^0.4.25;


contract Line {

    address private owner;

    uint constant public jackpotNumerator = 50;
    uint constant public winNumerator = 5;
    uint constant public giftNumerator = 1;
    uint constant public denominator = 100;
    uint constant public ownerDenominator = 100;

    uint public jackpot = 0;

    address[] internal addresses;
    mapping(address => SpinRec) internal spinsByAddr;
    mapping(bytes32 => SpinRec) internal spinsByQuery;

    struct SpinRec {
        uint id;
        bytes32 queryId;
        uint bet;
        uint token;
    }

    event Jackpot(uint line, address addr, uint date, uint prize, uint left);
    event Win(uint line, address addr, uint date, uint prize, uint left);
    event Gift(uint line, address addr, uint date, uint prize, uint left);
    
    event Spin(address addr, uint bet, uint jackpot, bytes32 queryId);
    event Reveal(uint line, address addr, uint bet, bytes32 queryId);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function getQueryId() constant public returns (uint256) {
        return uint256(spinsByAddr[msg.sender].queryId);
    }

    function getTokenFor(uint256 queryId) constant public returns (uint) {
        return spinsByQuery[bytes32(queryId)].token;
    }

    function getToken() constant public returns (uint) {
        return spinsByAddr[msg.sender].token;
    }

    function getQueryIdBytes() constant public returns (bytes32) {
        return spinsByAddr[msg.sender].queryId;
    }

    function getTokenForBytes(bytes32 queryId) constant public returns (uint) {
        return spinsByQuery[queryId].token;
    }

    function revealResult(uint token, bytes32 queryId) internal {

        SpinRec storage spin = spinsByQuery[queryId];

        require(spin.id != 0);

        spin.token = token;
        address player = addresses[spin.id];
        spinsByAddr[player].token = token;

        emit Reveal(token, player, spin.bet, queryId);

        uint prizeNumerator = 0;

        if (token == 444) {
            prizeNumerator = jackpotNumerator;
        } else if (token == 333 || token == 222 || token == 111) {
            prizeNumerator = winNumerator;
        } else if (token%10 == 4 || token/10%10 == 4 || token/100%10 == 4) {
            prizeNumerator = giftNumerator;
        }

        uint balance = address(this).balance;
        uint prize = 0;
        if (prizeNumerator > 0) {
            prize =  balance / 100 * prizeNumerator;
            if (player.send(prize)) {
                if (prizeNumerator == jackpotNumerator) {
                    emit Jackpot(token, player, now, prize, balance);
                } else if (prizeNumerator == winNumerator) {
                    emit Win(token, player, now, prize, balance);
                } else {
                    emit Gift(token, player, now, prize, balance);
                }
                owner.transfer(spin.bet / ownerDenominator);
            }
        }
    }
    
    function recordSpin(bytes32 queryId) internal {
        
        SpinRec storage spin = spinsByAddr[msg.sender];

        if (spin.id == 0) {

            msg.sender.transfer(0 wei); 

            spin.id = addresses.length;
            addresses.push(msg.sender);
        }

        spin.bet = msg.value;
        spin.queryId = queryId;
        spinsByQuery[queryId] = spin;
    }
    
    constructor() public {
        
        delete addresses;
        addresses.length = 1;
        owner = msg.sender;
    }

    function waiver() private {
        
        delete owner;
    }
    
    function reset() onlyOwner public {
        
        owner.transfer(address(this).balance);
    }

    uint nonce;

    function random() internal returns (uint) {

        bytes32 output = keccak256(abi.encodePacked(now, msg.sender, nonce));

        uint rand = uint256(output) % 1024;
        nonce++;
        return rand;
    }

    function() payable public {
        
        require(msg.value > 10);
        jackpot += msg.value;

        uint rand = random();
        bytes32 queryId = bytes32(nonce);

        recordSpin(queryId);

        emit Spin(msg.sender, msg.value, jackpot, queryId);

        revealResult(rand%345+100, queryId);
    }
}