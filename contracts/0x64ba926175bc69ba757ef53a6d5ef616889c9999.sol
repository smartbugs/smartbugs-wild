pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
// Guess the number, win a prize!

contract CashMoney {
    uint256 private current;
    uint256 private last;
    WinnerLog private winnerLog;
    uint256 private first;
    address public owner;
    uint256 public min_bet = 0.001 ether;
    uint256[5] public bonuses = [5 ether, 2 ether, 1.5 ether, 1 ether, 0.5 ether];

    struct Guess {
        uint256 playerNo;
        uint256 time;
    }
    
    struct Player {
        bool exists;
        bytes name;
        uint256 playerNo;
    }
    
    Guess[] guesses;
    //mapping( address => bool ) public winners;
    mapping( address => Player ) private players;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPlayer {
        require(players[msg.sender].exists);
        _;
    }
    
    function getWL() public view returns(address) {
        return winnerLog;
    }
    
    constructor(address[] players_, uint256[] nums, bytes[] names, address winnerLog_) public payable {
        owner = msg.sender;
        every_day_im_shufflin();
        
        for (uint256 i = 0; i < players_.length; i++) {
            players[players_[i]] = Player(true, names[i], nums[i]);
        }
        
        first = now;
        
        winnerLog = WinnerLog(winnerLog_);
    }
    
    function every_day_im_shufflin() internal {
        // EVERY DAY IM SHUFFLIN
        current = uint8(keccak256(abi.encodePacked(blockhash(block.number-2)))) % 11;
    }
    
    function getName() public view returns(bytes){
        return players[msg.sender].name;
    }
    
    function updateSelf(uint256 number, bytes name) public onlyPlayer {
        players[msg.sender].playerNo = number;
        players[msg.sender].name = name;
        players[msg.sender].exists = true;
    }

    
    function do_guess(uint256 number) payable public onlyPlayer {
        require(msg.value >= min_bet && number <= 10);
        // YOWO - You Only Win Once
        require(!winnerLog.isWinner(msg.sender));
        
        Guess storage guess;
        guess.playerNo = players[msg.sender].playerNo;
        guess.time = now;
        
        guesses.push(guess);
        
        if (number == current) {
            // you win!
            winnerLog.logWinner(msg.sender, players[msg.sender].playerNo, players[msg.sender].name);
            
            uint256 winnerNum = winnerLog.getWinnerAddrs().length;
            
            // should always be true
            assert(winnerNum > 0);
            
            if (winnerNum <= bonuses.length) {
                msg.sender.transfer(msg.value+bonuses[winnerNum-1]);
            } else {
                msg.sender.transfer(msg.value);
            }
        } else {
            revert("that wasn't very cash money of you");
        }
        
        every_day_im_shufflin();
        
        last = now;
    }
    
    function kill() public onlyOwner {
        selfdestruct(msg.sender);
    }
    
    function() public payable {
    }
}

contract WinnerLog {
    address public owner;
    event NewWinner(
        address sender,
        string name,
        uint256 number
    );
    
    
    struct Player {
        uint256 number;
        string name;
        bool exists;
    }

    mapping(address => bool) winners;
    address[] public winner_addr_list;
    string[] public winner_name_list;
    mapping( address => Player ) private players;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPlayer {
        require(players[msg.sender].exists);
        _;
    }

    function isWinner(address addr) public view returns (bool) {
        return winners[addr];
    }

    function getWinnerAddrs() public view returns (address[]) {
        return winner_addr_list;
    }
    
    function getWinnerNames() public view returns (string[]) {
        return winner_name_list;
    }
    
    constructor(address[] players_, uint256[] nums, string[] names) public {
        owner = msg.sender;
        for (uint256 i = 0; i < players_.length; i++) {
            players[players_[i]] = Player(nums[i], names[i], true);
        }
    }

    function addPlayer(address addr, uint256 number, string name) public onlyOwner {
        players[addr] = Player(number, name, true);
    }

    function logWinner(address addr, uint256 playerNo, bytes name) public onlyPlayer { 
            winners[addr] = true;
            winner_name_list.push(string(name));
            winner_addr_list.push(addr);
            emit NewWinner(msg.sender, string(name), playerNo);
    }
}