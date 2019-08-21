pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Champion is Ownable {
    uint8 constant NUMBER = 1;
    uint8 constant STRING = 0;
    
    uint8 constant GS_NOT_STARTED = 0;
    uint8 constant GS_IN_PROCESS = 1;
    uint8 constant GS_WAITING_USERS = 2;
    uint8 constant BILLIONS_STEP = 35; 
    
    uint256 public game = 0;
    
    uint8 public currentGameStatus;
    
    uint256 public currentGameBlockNumber;
    
    uint256[] public allGames;
    
    mapping(uint256 => uint256) internal gameStartBlock;
    
    mapping(uint256 => address[]) internal gamePlayers;
    
    mapping(uint256 => address) public winners;
    
    mapping(uint256 => mapping(address => uint256[])) internal playerNumbersInGame;

    mapping(uint256 => uint256) gamePrize;
    
    function Champion() {
        currentGameStatus = GS_NOT_STARTED;
        game = block.number;
    }

    function getAllGamesCount() constant returns(uint256) {
        return allGames.length;
    }

    function getWinner(uint256 _game) constant returns (address) {
        return winners[_game];
    }
    
    function setWinner(uint256 _game, address _winner) private returns (bool) {
        winners[_game] = _winner;
    }
    
    function getStartBlock(uint256 _game) 
            constant returns (uint256) 
    {
        return gameStartBlock[_game];
    }

    function getPlayersCountByGame(uint256 _game) 
            constant returns (uint256)
    {
        return gamePlayers[_game].length;
    }
    
    function getPlayerNumbersInGame(uint256 _gameBlock, address _palayer) 
            constant returns (uint256[])
    {
        return playerNumbersInGame[_gameBlock][_palayer];
    }

    function getGamePrize(uint256 _game) constant returns (uint256) {
        return gamePrize[_game];
    }
    
    function setGamePrize(uint256 _game, uint256 _amount) onlyOwner {
        gamePrize[_game] = _amount;
    }

    function isNumber(uint256 _game) private constant returns (bool) {
        bytes32 hash = block.blockhash(_game);
        require(hash != 0x0);
        
        byte b = byte(hash[31]);
        uint hi = uint8(b) / 16;
        uint lo = uint8(b) - 16 * uint8(hi);
        
        if (lo <= 9) {
            return true;
        }
        
        return false;
    }
    
    function startGame() onlyOwner returns (bool) {
        require(currentGameStatus == GS_WAITING_USERS);
        currentGameStatus = GS_IN_PROCESS;
        currentGameBlockNumber = game;
        game = block.number;
        
        allGames.push(currentGameBlockNumber);
        
        uint256 startBlock = block.number - 1;
        gameStartBlock[currentGameBlockNumber] = startBlock;
        
        return true;
    }

    function finishCurrentGame() onlyOwner returns (address) {
        return finishGame(currentGameBlockNumber);
    }

    function finishGame(uint256 _game) onlyOwner returns (address) {
        require(_game != 0);
        require(winners[_game] == 0x0);
        require(currentGameStatus == GS_IN_PROCESS);

        uint256 steps = getCurrentGameSteps();
        uint256 startBlock = getStartBlock(_game);
        require(startBlock + steps < block.number);
        
        uint256 lMin = 0;
        uint256 lMax = 0;
        uint256 rMin = 0;
        uint256 rMax = 0;
        
        (lMin, lMax, rMin, rMax) = processSteps(_game);
        
        address winner = gamePlayers[_game][rMax];
            
        setWinner(
            _game, 
            winner
        );
                        
        currentGameBlockNumber = 0;
        currentGameStatus = GS_WAITING_USERS;
        
        return winner;
    }
    
    function getCurrentGameSteps() constant returns (uint256) {
        return getStepsCount(currentGameBlockNumber);
    }

    function getStepsCount(uint256 _game) 
            constant returns (uint256 y) {
        uint256 x = getPlayersCountByGame(_game);
        assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let value := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, value), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }
    
    function getGameRules(uint256 _game) 
            constant returns (uint8 left, uint8 right) {
        if (isNumber(_game)) {
            left = NUMBER;
            right = STRING;
        } else {
            left = STRING;
            right = NUMBER;
        }

        return (left, right);
    }

    function processSteps(uint256 _gameBlock) 
            internal returns (uint256 lMin, uint256 lMax, uint256 rMin, uint256 rMax) {
        require(_gameBlock != 0);
        
        lMin = 0;
        lMax = 0;
        rMin = 0;
        rMax = gamePlayers[_gameBlock].length - 1;
        
        if (isEvenNumber(rMax)) {
            lMax = rMax / 2;
            rMin = rMax / 2 + 1;
        } else {
            lMax = rMax / 2;
            rMin = rMax / 2 + 1;
        }

        uint8 left = 0;
        uint8 right = 0;
        (left, right) = getGameRules(_gameBlock);

        for (uint8 i = 1; i <= BILLIONS_STEP; i++) {
            bool isNumberRes = isNumber(getStartBlock(_gameBlock) + i);
            
            if ((isNumberRes && left == NUMBER) ||
                (!isNumberRes && left == STRING)
            ) {
                if (lMin == lMax) {
                    rMin = lMin;
                    rMax = lMax;
                    break;
                }
                
                rMax = lMax;
            } else if (isNumberRes && right == NUMBER ||
                (!isNumberRes && right == STRING)
            ) {
                if (rMin == rMax) {
                    lMin = rMin;
                    lMax = rMax;
                    break;
                }
                
                lMin = rMin;
            }
            
            if (rMax - lMin != 1) {
                lMax = lMin + (rMax - lMin) / 2;
                rMin = lMin + (rMax - lMin) / 2 + 1;
            } else {
                lMax = lMin;
                rMin = rMax;
            }
        }
        
        return (lMin, lMax, rMin, rMax);
    }

    function processStepsByStep(uint256 _gameBlock, uint256 step) 
            constant returns (uint256 lMin, uint256 lMax, uint256 rMin, uint256 rMax) {
        require(_gameBlock != 0);
        require((getStartBlock(_gameBlock) + i) < block.number);
        
        lMin = 0;
        lMax = 0;
        rMin = 0;
        rMax = gamePlayers[_gameBlock].length - 1;
        
        if (isEvenNumber(rMax)) {
            lMax = rMax / 2;
            rMin = rMax / 2 + 1;
        } else {
            lMax = rMax / 2;
            rMin = rMax / 2 + 1;
        }
        
        if (step == 0) {
            return (lMin, lMax, rMin, rMax);
        } 
        
        uint8 left = 0;
        uint8 right = 0;
        (left, right) = getGameRules(_gameBlock);

        for (uint i = 1; i <= step; i++) {
            bool isNumberRes = isNumber(getStartBlock(_gameBlock) + i);
            
            if ((isNumberRes && left == NUMBER) ||
                (!isNumberRes && left == STRING)
            ) {
                if (lMin == lMax) {
                    rMin = lMin;
                    rMax = lMax;
                    break;
                }
                
                rMax = lMax;
            } else if (isNumberRes && right == NUMBER ||
                (!isNumberRes && right == STRING)
            ) {
                if (rMin == rMax) {
                    lMin = rMin;
                    lMax = rMax;
                    break;
                }
                
                lMin = rMin;
            }
            
            if (rMax - lMin != 1) {
                lMax = lMin + (rMax - lMin) / 2;
                rMin = lMin + (rMax - lMin) / 2 + 1;
            } else {
                lMax = lMin;
                rMin = rMax;
            }
        }
        
        return (lMin, lMax, rMin, rMax);
    }

    function isEvenNumber(uint _v1) 
            internal constant returns (bool) {
        uint v1u = _v1 * 100;
        uint v2 = 2;
        
        uint vuResult = v1u / v2;
        uint vResult = _v1 / v2;
        
        if (vuResult != vResult * 100) {
            return false;
        }
        
        return true;
    }
    
    function buyTicket(address _player) onlyOwner 
            returns (uint256 playerNumber, uint256 gameNumber) {
        if (currentGameStatus == GS_NOT_STARTED) {
            currentGameStatus = GS_WAITING_USERS;
        }
        
        playerNumber = gamePlayers[game].length;

        gamePlayers[game].push(_player);
        
        playerNumbersInGame[game][_player].push(playerNumber);
                
        return (playerNumber, game);
    }
}