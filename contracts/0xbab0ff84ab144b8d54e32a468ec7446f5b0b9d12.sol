pragma solidity ^0.4.11;

contract EthLot {
    address public owner;
    uint public price = 10000000000000000;
    uint public fee = 256000000000000000;
    uint public currentRound = 0;
    uint8 public placesSold;
    uint[] public places = [
        768000000000000000,
        614400000000000000,
        460800000000000000,
        307200000000000000,
        153600000000000000
    ];
    uint public rand1;
    uint8 public rand2;
    
    mapping (uint => mapping (uint8 => address)) public map;
    mapping (address => uint256) public balanceOf;
    
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    event BalanceChanged(address receiver, uint newBalance);
    event RoundChanged(uint newRound);
    event Placed(uint round, uint8 place, address backer);
    event Finished(uint round, uint8 place1, uint8 place2, uint8 place3, uint8 place4, uint8 place5);
    
    function EthLot() public {
        owner = msg.sender;
    }
    
    function withdraw() external {
        require(balanceOf[msg.sender] > 0);
        
        msg.sender.transfer(balanceOf[msg.sender]);
        FundTransfer(msg.sender, balanceOf[msg.sender], false);
        
        balanceOf[msg.sender] = 0;
        BalanceChanged(msg.sender, 0);
    }
    
    function place(uint8 cell) external payable {
        require(map[currentRound][cell] == 0x0 && msg.value == price);
        
        map[currentRound][cell] = msg.sender;
        Placed(currentRound, cell, msg.sender);
        rand1 += uint(msg.sender) + block.timestamp;
        rand2 -= uint8(msg.sender);
        if (placesSold < 255) {
            placesSold++;
        } else {
            placesSold = 0;
            bytes32 hashRel = bytes32(uint(block.blockhash(block.number - rand2 - 1)) + block.timestamp + rand1);
            
            uint8 place1 = uint8(hashRel[31]);
            uint8 place2 = uint8(hashRel[30]);
            uint8 place3 = uint8(hashRel[29]);
            uint8 place4 = uint8(hashRel[28]);
            uint8 place5 = uint8(hashRel[27]);
            
            if (place2 == place1) {
                place2++;
            }
            
            if (place3 == place1) {
                place3++;
            }
            if (place3 == place2) {
                place3++;
            }
            
            if (place4 == place1) {
                place4++;
            }
            if (place4 == place2) {
                place4++;
            }
            if (place4 == place3) {
                place4++;
            }
            
            if (place5 == place1) {
                place5++;
            }
            if (place5 == place2) {
                place5++;
            }
            if (place5 == place3) {
                place5++;
            }
            if (place5 == place4) {
                place5++;
            }
            
            balanceOf[map[currentRound][place1]] += places[0];
            balanceOf[map[currentRound][place2]] += places[1];
            balanceOf[map[currentRound][place3]] += places[2];
            balanceOf[map[currentRound][place4]] += places[3];
            balanceOf[map[currentRound][place5]] += places[4];
            balanceOf[owner] += fee;
            
            BalanceChanged(map[currentRound][place1], balanceOf[map[currentRound][place1]]);
            BalanceChanged(map[currentRound][place2], balanceOf[map[currentRound][place2]]);
            BalanceChanged(map[currentRound][place3], balanceOf[map[currentRound][place3]]);
            BalanceChanged(map[currentRound][place4], balanceOf[map[currentRound][place4]]);
            BalanceChanged(map[currentRound][place5], balanceOf[map[currentRound][place5]]);
            BalanceChanged(owner, balanceOf[owner]);
            
            Finished(currentRound, place1, place2, place3, place4, place5);
            
            currentRound++;
            RoundChanged(currentRound);
        }
    }
}