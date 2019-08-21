pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public admin;
  uint256 public lockedIn;
  uint256 public OWNER_AMOUNT;
  uint256 public OWNER_PERCENT = 2;
  uint256 public OWNER_MIN = 0.0001 ether;
  
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor(address addr, uint256 percent, uint256 min) public {
    require(addr != address(0), 'invalid addr');
    owner = msg.sender;
    admin = addr;
    OWNER_PERCENT = percent;
    OWNER_MIN = min;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender==owner || msg.sender==admin);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  function _cash() public view returns(uint256){
      return address(this).balance;
  }

  function kill() onlyOwner public{
    require(lockedIn == 0, "invalid lockedIn");
    selfdestruct(owner);
  }
  
  function setAdmin(address addr) onlyOwner public{
      require(addr != address(0), 'invalid addr');
      admin = addr;
  }
  
  function setOwnerPercent(uint256 percent) onlyOwner public{
      OWNER_PERCENT = percent;
  }
  
  function setOwnerMin(uint256 min) onlyOwner public{
      OWNER_MIN = min;
  }
  
  function _fee() internal returns(uint256){
      uint256 fe = msg.value*OWNER_PERCENT/100;
      if(fe < OWNER_MIN){
          fe = OWNER_MIN;
      }
      OWNER_AMOUNT += fe;
      return fe;
  }
  
  function cashOut() onlyOwner public{
    require(OWNER_AMOUNT > 0, 'invalid OWNER_AMOUNT');
    owner.send(OWNER_AMOUNT);
  }

  modifier isHuman() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength == 0, "sorry humans only");
      _;
  }

  modifier isContract() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength > 0, "sorry contract only");
      _;
  }
}

/**
 * luck100.win - Fair Ethereum game platform
 * 
 * Multiple dice
 * 
 * Winning rules:
 * 
 * result = sha3(txhashA + txhashB + blockhash(startN+n*10)) % 6 + 1
 * 
 * 1.After the contract is created, the starting block startN is obtained. 
 * After that, each new 10 blocks in Ethereum automatically generates one game;
 * 
 * 2.The player chooses a bet of 1-6 and bets up to 5 digits at the same time;
 * 
 * 3.In the same game, player A gets the transaction hash txhashA after successful bet, 
 * and player B gets the transaction hash txhashB after successful bet...;
 * 
 * 4.Take the last block of the board, hash blockhash;
 * 
 * 5.TxhashA, txhashB... and blockhash are subjected to sha3 encryption operation, 
 * and then modulo with 6 to get the result of the lottery.
 */

contract DiceLuck100 is Ownable{
    event betEvent(uint256 indexed gameIdx, uint256 betIdx, address addr, uint256 betBlockNumber, uint256 betMask, uint256 amount);
    event openEvent(uint256 indexed gameIdx, uint256 openBlockNumber, uint256 openNumber, bytes32 txhash, uint256 winNum);
    struct Bet{
        address addr;
        uint256 betBlockNumber;
        uint256 betMask;
        uint256 amount;
        uint256 winAmount;
        bool isWin;
    }
    struct Game{
        uint256 openBlockNumber;
        uint256 openNumber;
        uint256 locked;
        bytes32 txhash;
        bytes32 openHash;
        Bet[] bets;
    }
    mapping(uint256=>Game) gameList;
    Game _eg;
    uint256 public firstBN;
    uint256 constant MIN_BET = 0.01 ether;
    uint8 public N = 10;
    uint8 constant M = 6;
    uint16[M] public MASKS = [0, 32, 48, 56, 60, 62];
    uint16[M] public AMOUNTS = [0, 101, 253, 510, 1031, 2660];
    uint16[M] public ODDS = [0, 600, 300, 200, 150, 120];
    
    constructor(address addr, uint256 percent, uint256 min) Ownable(addr, percent, min) public{
        firstBN = block.number;
    }
    
    function() public payable{
        uint8 diceNum = uint8(msg.data.length);
        uint256 betMask = 0;
        uint256 t = 0;
        for(uint8 i=0;i<diceNum;i++){
            t = uint256(msg.data[i]);
            if(t==0 || t>M){
                diceNum--;
                continue;
            }
            betMask += 2**(t-1);
        }
        if(diceNum==0) return ;
        _placeBet(betMask, diceNum);
    }
    
    function placeBet(uint256 betMask, uint8 diceNum) public payable{
        _placeBet(betMask, diceNum);
    }
    
    function _placeBet(uint256 betMask, uint8 diceNum) private{
        require(diceNum>0 && diceNum<M, 'invalid diceNum');
        uint256 MAX_BET = AMOUNTS[diceNum]/100*(10**18);
        require(msg.value>=MIN_BET && msg.value<=MAX_BET, 'invalid amount');
        require(betMask>0 && betMask<=MASKS[diceNum], 'invalid betMask');
        uint256 fee = _fee();
        uint256 winAmount = (msg.value-fee)*ODDS[diceNum]/100;
        lockedIn += winAmount;
        uint256 gameIdx = (block.number-firstBN-1)/N;
        if(gameList[gameIdx].openBlockNumber == 0){
            gameList[gameIdx] = _eg;
            gameList[gameIdx].openBlockNumber = firstBN + (gameIdx+1)*N;
        }
        gameList[gameIdx].locked += winAmount;
        gameList[gameIdx].bets.push(Bet({
            addr:msg.sender,
            betBlockNumber:block.number,
            betMask:betMask,
            amount:msg.value,
            winAmount:winAmount,
            isWin:false
        }));
        emit betEvent(gameIdx, gameList[gameIdx].bets.length-1, msg.sender, block.number, betMask, msg.value);
    }
    
    function setN(uint8 n) onlyOwner public{
        uint256 gameIdx = (block.number-firstBN-1)/N;
        firstBN = firstBN + (gameIdx+1)*N;
        N = n;
    }
    
    function open(uint256 gameIdx, bytes32 txhash, uint256 txNum) onlyOwner public{
        uint256 openBlockNumber = gameList[gameIdx].openBlockNumber;
        bytes32 openBlockHash = blockhash(openBlockNumber);
        require(uint256(openBlockHash)>0, 'invalid openBlockNumber');
        _open(gameIdx, txhash, openBlockHash, txNum);
    }
    
    function open2(uint256 gameIdx, bytes32 txhash, bytes32 openBlockHash, uint256 txNum) onlyOwner public{
        _open(gameIdx, txhash, openBlockHash, txNum);
    }
    
    function _open(uint256 gameIdx, bytes32 txhash, bytes32 openBlockHash, uint256 txNum) private{
        Game storage game = gameList[gameIdx];
        uint256 betNum = game.bets.length;
        uint256 openBN = firstBN + (gameIdx+1)*N;
        require(openBN==game.openBlockNumber && game.openNumber==0 && betNum==txNum, 'invalid bet');
        lockedIn -= game.locked;
        bytes32 openHash = keccak256(abi.encodePacked(txhash, openBlockHash));
        uint256 r = uint256(openHash) % M;
        uint256 R = 2**r;
        game.openNumber = r+1;
        game.txhash = txhash;
        game.openHash = openHash;
        uint256 t = 0;
        uint256 winNum = 0;
        for(uint256 i=0;i<betNum;i++){
            t = game.bets[i].betMask & R;
            if(t > 0){
                game.bets[i].isWin = true;
                (game.bets[i].addr).send(game.bets[i].winAmount);
                winNum++;
            }
        }
        emit openEvent(gameIdx, game.openBlockNumber, game.openNumber, txhash, winNum);
    }
    
    function getGame(uint256 gameIdx) view public returns(uint256,uint256,uint256,uint256,uint256,uint256,bytes32,bytes32){
        Game memory g = gameList[gameIdx];
        uint256 amount = 0;
        uint256 winAmount = 0;
        uint256 winNum = 0;
        for(uint256 i=0;i<g.bets.length;i++){
            amount += g.bets[i].amount;
            if(g.bets[i].isWin){
                winNum++;
                winAmount += g.bets[i].winAmount;
            }
        }
        return (g.openBlockNumber, g.openNumber, g.bets.length, winNum, amount, winAmount, g.txhash, g.openHash);
    }
    
    function getBets(uint256 gameIdx) view public returns(address[] addrs,uint256[] bns,uint256[] masks,uint256[] amounts,uint256[] winAmounts,bool[] isWins){
        uint256 betNum = gameList[gameIdx].bets.length;
        addrs = new address[](betNum);
        bns = new uint256[](betNum);
        masks = new uint256[](betNum);
        amounts = new uint256[](betNum);
        winAmounts = new uint256[](betNum);
        isWins = new bool[](betNum);
        for(uint256 i=0;i<betNum;i++){
            Bet memory b = gameList[gameIdx].bets[i];
            addrs[i] = b.addr;
            bns[i] = b.betBlockNumber;
            masks[i] = b.betMask;
            amounts[i] = b.amount;
            winAmounts[i] = b.winAmount;
            isWins[i] = b.isWin;
        }
    }
    
    
    function withdraw() onlyOwner public{
        msg.sender.transfer(address(this).balance);
    }
    
    function output() view public returns(uint256, uint8,uint256,uint256,uint16[M],uint16[M],uint16[M]){
        return (firstBN, N, OWNER_PERCENT, OWNER_MIN, MASKS, AMOUNTS, ODDS);
    }
}