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
 * Single dice
 * 
 * Winning rules:
 * 
 * result = sha3(txhash + blockhash(betBN+3)) % 6 + 1
 * 
 * 1.The player chooses a bet of 1-6 and bets up to 5 digits at the same time;
 * 
 * 2.After the player bets successfully, get the transaction hash txhash;
 * 
 * 3.Take the block that the player bets to count the new 3rd Ethereum block hash blockhash;
 * 
 * 4.Txhash and blockhash are subjected to sha3 encryption operation, and then modulo with 6 to 
 * get the result of the lottery.
 */


contract Dice1Contract is Ownable{
    event betEvent(address indexed addr, uint256 betBlockNumber, uint256 betMask, uint256 amount);
    event openEvent(address indexed addr, uint256 openBlockNumber, uint256 openNumber, bytes32 txhash, bool isWin);
    struct Bet{
        uint256 betBlockNumber;
        uint256 openBlockNumber;
        uint256 betMask;
        uint256 openNumber;
        uint256 amount;
        uint256 winAmount;
        bytes32 txhash;
        bytes32 openHash;
        bool isWin;
    }
    mapping(address=>mapping(uint256=>Bet)) betList;
    uint256 constant MIN_BET = 0.01 ether;
    uint8 public N = 3;
    uint8 constant M = 6;
    uint16[M] public MASKS = [0, 32, 48, 56, 60, 62];
    uint16[M] public AMOUNTS = [0, 101, 253, 510, 1031, 2660];
    uint16[M] public ODDS = [0, 600, 300, 200, 150, 120];
    
    constructor(address addr, uint256 percent, uint256 min) Ownable(addr, percent, min) public{
        
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
        betList[msg.sender][block.number] = Bet({
            betBlockNumber:block.number,
            openBlockNumber:block.number+N,
            betMask:betMask,
            openNumber:0,
            amount:msg.value,
            winAmount:winAmount,
            txhash:0,
            openHash:0,
            isWin:false
        });
        emit betEvent(msg.sender, block.number, betMask, msg.value);
    }
    
    function setN(uint8 n) onlyOwner public{
        N = n;
    }
    
    function open(address addr, uint256 bn, bytes32 txhash) onlyOwner public{
        uint256 openBlockNumber = betList[addr][bn].openBlockNumber;
        bytes32 openBlockHash = blockhash(openBlockNumber);
        require(uint256(openBlockHash)>0, 'invalid openBlockNumber');
        _open(addr, bn, txhash, openBlockHash);
    }
    
    function open2(address addr, uint256 bn, bytes32 txhash, bytes32 openBlockHash) onlyOwner public{
        _open(addr, bn, txhash, openBlockHash);
    }
    
    function _open(address addr, uint256 bn, bytes32 txhash, bytes32 openBlockHash) private{
        Bet storage bet = betList[addr][bn];
        require(bet.betBlockNumber==bn && bet.openNumber==0, 'invalid bet');
        lockedIn -= bet.winAmount;
        bytes32 openHash = keccak256(abi.encodePacked(txhash, openBlockHash));
        uint256 r = uint256(openHash) % M;
        uint256 t = bet.betMask & (2**r);
        bet.openNumber = r+1;
        bet.txhash = txhash;
        bet.openHash = openHash;
        if(t > 0){
            bet.isWin = true;
            addr.send(bet.winAmount);
        }
        emit openEvent(addr, bet.openBlockNumber, bet.openNumber, txhash, bet.isWin);
    }
    
    function getBet(address addr, uint256 bn) view public returns(uint256,uint256,uint256,uint256,uint256,uint256,bytes32,bytes32,bool){
        Bet memory bet = betList[addr][bn];
        return (bet.betBlockNumber, bet.openBlockNumber, bet.betMask, bet.openNumber, bet.amount, bet.winAmount, bet.txhash, bet.openHash, bet.isWin);
    }
    
    function output() view public returns(uint8,uint256,uint256,uint16[M],uint16[M],uint16[M]){
        return (N, OWNER_PERCENT, OWNER_MIN, MASKS, AMOUNTS, ODDS);
    }
}