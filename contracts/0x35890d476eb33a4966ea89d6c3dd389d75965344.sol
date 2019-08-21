pragma solidity ^0.4.25;

/**
 * EtherDice - fully transparent and decentralized betting
 *
 * Web              - https://etherdice.biz
 * Telegram chat    - https://t.me/EtherDice
 * Telegram channel - https://t.me/EtherDiceInfo
 *
 * Recommended gas limit: 200000
 * Recommended gas price: https://ethgasstation.info/
 */
contract EtherDice {
    
    address public constant OWNER = 0x8026F25c6f898b4afE03d05F87e6c2AFeaaC3a3D;
    address public constant MANAGER = 0xD25BD6c44D6cF3C0358AB30ed5E89F2090409a79;
    uint constant public FEE_PERCENT = 2;
    
    uint public minBet;
    uint public maxBet;
    uint public currentIndex;
    uint public lockBalance;
    uint public betsOfBlock;
    uint entropy;
    
    struct Bet {
        address player;
        uint deposit;
        uint block;
    }

    Bet[] public bets;

    event PlaceBet(uint num, address player, uint bet, uint payout, uint roll, uint time);

    // Modifier on methods invokable only by contract owner and manager
    modifier onlyOwner {
        require(OWNER == msg.sender || MANAGER == msg.sender);
        _;
    }

    // This function called every time anyone sends a transaction to this contract
    function() public payable {
        if (msg.value > 0) {
            createBet(msg.sender, msg.value);
        }
        
        placeBets();
    }
    
    // Records a new bet to the public storage
    function createBet(address _player, uint _deposit) internal {
        
        require(_deposit >= minBet && _deposit <= maxBet); // check deposit limits
        
        uint lastBlock = bets.length > 0 ? bets[bets.length-1].block : 0;
        
        require(block.number != lastBlock || betsOfBlock < 50); // maximum 50 bets per block
        
        uint fee = _deposit * FEE_PERCENT / 100;
        uint betAmount = _deposit - fee; 
        
        require(betAmount * 2 + fee <= address(this).balance - lockBalance); // profit check
        
        sendOwner(fee);
        
        betsOfBlock = block.number != lastBlock ? 1 : betsOfBlock + 1;
        lockBalance += betAmount * 2;
        bets.push(Bet(_player, _deposit, block.number));
    }

    // process all the bets of previous players
    function placeBets() internal {
        
        for (uint i = currentIndex; i < bets.length; i++) {
            
            Bet memory bet = bets[i];
            
            if (bet.block < block.number) {
                
                uint betAmount = bet.deposit - bet.deposit * FEE_PERCENT / 100;
                lockBalance -= betAmount * 2;

                // Bets made more than 256 blocks ago are considered failed - this has to do
                // with EVM limitations on block hashes that are queryable 
                if (block.number - bet.block <= 256) {
                    entropy = uint(keccak256(abi.encodePacked(blockhash(bet.block), entropy)));
                    uint roll = entropy % 100 + 1;
                    uint payout = roll < 50 ? betAmount * 2 : 0;
                    send(bet.player, payout);
                    emit PlaceBet(i + 1, bet.player, bet.deposit, payout, roll, now); 
                }
            } else {
                break;
            }
        }
        
        currentIndex = i;
    }
    
    // Safely sends the ETH by the passed parameters
    function send(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
            _receiver.send(_amount);
        }
    }
    
    // Sends funds to the owner and manager
    function sendOwner(uint _amount) internal {
        send(OWNER, _amount * 7 / 10);
        send(MANAGER, _amount * 3 / 10);
    }
    
    // Funds withdrawal
    function withdraw(uint _amount) public onlyOwner {
        require(_amount <= address(this).balance - lockBalance);
        sendOwner(_amount);
    }
    
    // Set limits for deposits
    function configure(uint _minBet, uint _maxBet) onlyOwner public {
        require(_minBet >= 0.001 ether && _minBet <= _maxBet);
        minBet = _minBet;
        maxBet = _maxBet;
    }

    // This function deliberately left empty. It's primary use case is to top up the bank roll
    function deposit() public payable {}
    
    // Returns the number of bets created
    function totalBets() public view returns(uint) {
        return bets.length;
    }
}