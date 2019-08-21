pragma solidity ^0.4.23;

/**
 * @title SafeMaths
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract HotLot {
    using SafeMath for uint256;

    uint256 public INTERVAL_TIME = 8 hours;
    uint256 public JACKPOT_INTERVAL_TIME = 72 hours;
    uint256 public constant PERCENT_REWARD_TO_JACKPOT = 20;
    uint256 public constant PERCENT_REWARD_TOP_RANK = 30;
    uint256 public constant PERCENT_REWARD_TOP1 = 60;
    uint256 public constant PERCENT_REWARD_TOP2 = 30;
    uint256 public constant PERCENT_REWARD_TOP3 = 10;
    uint256 public DEPOSIT_AMOUNT = 0.02 * (10 ** 18);

    address public owner;
    address public winner1;
    uint256 public winnerAmount1 = 0;
    address public winner2;
    uint256 public winnerAmount2 = 0;
    address public winner3;
    uint256 public winnerAmount3 = 0;

    address public winnerJackpot1;
    uint256 public winnerJackpotAmount1 = 0;
    address public winnerJackpot2;
    uint256 public winnerJackpotAmount2 = 0;
    address public winnerJackpot3;
    uint256 public winnerJackpotAmount3 = 0;

    uint256 public amountRound = 0;
    uint256 public amountJackpot = 0;
    uint256 public roundTime;
    uint256 public jackpotTime;
    uint256 public countPlayerRound = 0;
    uint256 public countPlayerJackpot = 0;
    uint256 public countRound = 0;
    uint256 public countJackpot = 0;
    uint256 private _seed;

    struct Player {
        address wallet;
        bool playing;
        bool playingJackpot;
    }

    Player[] public players;

    event DepositSuccess(address _from, uint256 _amount, uint256 countRound, uint256 countJackpot);
    event RewardRoundWinner(
        address wallet1, 
        uint256 amount1, 
        address wallet2, 
        uint256 amount2, 
        address wallet3, 
        uint256 amount3, 
        uint256 rewardRank
    );
    event RewardJackpotWinner(
        address wallet1, uint256 amount1, 
        address wallet2, uint256 amount2, 
        address wallet3, uint256 amount3, 
        uint256 rewardRank
    );

    function HotLot() public {
        owner = msg.sender;
        roundTime = now.add(INTERVAL_TIME);
        jackpotTime = now.add(JACKPOT_INTERVAL_TIME);
    }

    /**
    * Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function () payable {
        deposit();
    }

    /**
    * Deposit from player
    */
    function deposit() public payable {
        require(msg.value >= DEPOSIT_AMOUNT);

        players.push(Player({
            wallet: msg.sender,
            playing: true,
            playingJackpot: true
        }));

        amountRound = amountRound.add(msg.value);
        countPlayerRound = countPlayerRound.add(1);
        countPlayerJackpot = countPlayerJackpot.add(1);

        emit DepositSuccess(msg.sender, msg.value, countRound, countJackpot);

        if (now >= roundTime && amountRound > 0 && countPlayerRound > 1) {
            roundTime = now.add(INTERVAL_TIME);
            executeRound();

            if (now >= jackpotTime && amountJackpot > 0 && countPlayerJackpot > 1) {
                jackpotTime = now.add(JACKPOT_INTERVAL_TIME);
                executeJackpot();
            }
        }
    }

    function executeRound() private {
        uint256 count = 0;
        address wallet1;
        address wallet2;
        address wallet3;
        uint256 luckyNumber1 = generateLuckyNumber(countPlayerRound);
        uint256 luckyNumber2 = generateLuckyNumber(countPlayerRound);
        uint256 luckyNumber3 = generateLuckyNumber(countPlayerRound);

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].playing) {
                count = count.add(1);
                if (count == luckyNumber1) {
                    wallet1 = players[i].wallet;
                }
                if (count == luckyNumber2) {
                    wallet2 = players[i].wallet;
                }
                if (count == luckyNumber3) {
                    wallet3 = players[i].wallet;
                }
                players[i].playing = false;
            }
        }

        countRound = countRound.add(1);
        uint256 rewardRank = amountRound.mul(PERCENT_REWARD_TOP_RANK).div(100);
        uint256 amountToJackpot = amountRound.mul(PERCENT_REWARD_TO_JACKPOT).div(100);
        uint256 reward = amountRound.sub(rewardRank.add(amountToJackpot));

        amountJackpot = amountJackpot.add(amountToJackpot);

        winnerAmount1 = reward.mul(PERCENT_REWARD_TOP1).div(100);
        winner1 = wallet1;
        winnerAmount2 = reward.mul(PERCENT_REWARD_TOP2).div(100);
        winner2 = wallet2;
        winnerAmount3 = reward.sub(winnerAmount1.add(winnerAmount2));
        winner3 = wallet3;

        amountRound = 0;
        countPlayerRound = 0;

        winner1.transfer(winnerAmount1);
        winner2.transfer(winnerAmount2);
        winner3.transfer(winnerAmount3);
        owner.transfer(rewardRank);

        emit RewardRoundWinner(
            winner1, 
            winnerAmount1, 
            winner2, 
            winnerAmount2, 
            winner3, 
            winnerAmount3, 
            rewardRank
        );
    }

    function executeJackpot() private {
        uint256 count = 0;
        address wallet1;
        address wallet2;
        address wallet3;
        uint256 luckyNumber1 = generateLuckyNumber(countPlayerJackpot);
        uint256 luckyNumber2 = generateLuckyNumber(countPlayerJackpot);
        uint256 luckyNumber3 = generateLuckyNumber(countPlayerJackpot);

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].playingJackpot) {
                count = count.add(1);
                if (count == luckyNumber1) {
                    wallet1 = players[i].wallet;
                }
                if (count == luckyNumber2) {
                    wallet2 = players[i].wallet;
                }
                if (count == luckyNumber3) {
                    wallet3 = players[i].wallet;
                }
                players[i].playing = false;
            }
        }

        uint256 rewardRank = amountJackpot.mul(PERCENT_REWARD_TOP_RANK).div(100);
        uint256 reward = amountJackpot.sub(rewardRank);

        winnerJackpotAmount1 = reward.mul(PERCENT_REWARD_TOP1).div(100);
        winnerJackpot1 = wallet1;
        winnerJackpotAmount2 = reward.mul(PERCENT_REWARD_TOP2).div(100);
        winnerJackpot2 = wallet2;
        winnerJackpotAmount3 = reward.sub(winnerJackpotAmount1.add(winnerJackpotAmount2));
        winnerJackpot3 = wallet3;

        countJackpot = countJackpot.add(1);
        amountJackpot = 0;
        countPlayerJackpot = 0;
        delete players;

        owner.transfer(rewardRank);
        winnerJackpot1.transfer(winnerJackpotAmount1);
        winnerJackpot2.transfer(winnerJackpotAmount2);
        winnerJackpot3.transfer(winnerJackpotAmount3);

        emit RewardJackpotWinner(
            winnerJackpot1, 
            winnerJackpotAmount1, 
            winnerJackpot2, 
            winnerJackpotAmount2, 
            winnerJackpot3, 
            winnerJackpotAmount3, 
            rewardRank
        );
    }

    function maxRandom() public returns (uint256 number) {
        _seed = uint256(keccak256(
            _seed,
            block.blockhash(block.number - 1),
            block.coinbase,
            block.difficulty,
            players.length,
            countPlayerJackpot,
            countPlayerRound,
            winnerJackpot1,
            winnerJackpotAmount1,
            winnerAmount1,
            winner1,
            now
        ));

        return _seed;
    }

    function generateLuckyNumber(uint256 maxNumber) private returns (uint256 number) {
        return (maxRandom() % maxNumber) + 1;
    }

    /**
    * Allows the current owner to transfer control of the contract to a newOwner.
    * _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        require(_newOwner != address(0x0));

        owner = _newOwner;
    }
    
    function setIntervalTime(uint256 _time) public onlyOwner {
        require(_time > 0);
        INTERVAL_TIME = _time;
    }
    
    function setIntervalJackpotTime(uint256 _time) public onlyOwner {
        require(_time > 0);
        JACKPOT_INTERVAL_TIME = _time;
    }
    
    function setMinAmountDeposit(uint256 _amount) public onlyOwner {
        require(_amount > 0);
        DEPOSIT_AMOUNT = _amount;
    }
}