pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancy_lock);
    reentrancy_lock = true;
    _;
    reentrancy_lock = false;
  }

}

contract Ethery is Pausable, ReentrancyGuard{
  event NewBet(uint id, address player, uint wager, uint targetBlock);
  event BetResolved(uint id, BetStatus status);
  
  bytes32 constant byteMask = bytes32(0xF);

  enum BetStatus { Pending, PlayerWon, HouseWon, Refunded }
  
  struct Bet {
    address player;
    uint wager;
    uint digits;
    bytes32 guess;
    BetStatus status;
    uint targetBlock;
  }
  
  Bet[] public bets;
  
  mapping (uint => address) public betToOwner;
  mapping (address => uint) ownerBetCount;
  
  uint resolverFee = 0.1 finney;
  uint maxPayout = 1 ether;
  uint pendingPay;
  
  function setResolverFee(uint _resolverFee) external onlyOwner {
    resolverFee = _resolverFee;
  }
  
  function getResolverFee() external view returns (uint){
    return resolverFee;
  }
  
  function setMaxPayout(uint _maxPayout) external onlyOwner {
    maxPayout = _maxPayout;
  }

  function getMaxPayout() external view returns (uint){
    return maxPayout;
  }
  
  function withDraw(uint _amount) external onlyOwner {
    require(_amount < this.balance - pendingPay);
    msg.sender.transfer(_amount);
  }
  
  function () public payable {}
  
  function createBet(uint _digits, bytes32 _guess, uint _targetBlock) public payable whenNotPaused {
    require(
      msg.value >= resolverFee &&
      _targetBlock > block.number &&
      block.number + 256 >= _targetBlock &&
      payout(msg.value, _digits) <= maxPayout &&
      payout(msg.value, _digits) <= this.balance - pendingPay
    );
    uint id = bets.push(Bet(msg.sender, msg.value, _digits, _guess, BetStatus.Pending, _targetBlock)) - 1;
    betToOwner[id] = msg.sender;
    ownerBetCount[msg.sender]++;
    pendingPay += payout(msg.value, _digits);
    NewBet(id, msg.sender, msg.value, _targetBlock);
  }
  
  function resolveBet(uint _betId) public nonReentrant returns (BetStatus) {
    Bet storage myBet = bets[_betId];  
    require(
      myBet.status == BetStatus.Pending &&    // only resolve pending bets
      myBet.targetBlock < block.number        // only resolve targetBlock > current block
    );
    
    pendingPay -= payout(myBet.wager, uint(myBet.digits));
    
    if (myBet.targetBlock + 255 < block.number) {    // too late to determine out come issue refund
      myBet.status = BetStatus.Refunded;
      betToOwner[_betId].transfer(myBet.wager);
    } else {
      bytes32 targetBlockHash = block.blockhash(myBet.targetBlock);
      if (isCorrectGuess(targetBlockHash, myBet.guess, uint(myBet.digits))) {
        myBet.status = BetStatus.PlayerWon;
        betToOwner[_betId].transfer(payout(myBet.wager, uint(myBet.digits)));
      } else {
        myBet.status = BetStatus.HouseWon;
      }
    }
    msg.sender.transfer(resolverFee);
    BetResolved(_betId, myBet.status);
    return myBet.status;
  }
  
  function isCorrectGuess(bytes32 _blockHash, bytes32 _guess, uint _digits) public pure returns (bool) {
    for (uint i = 0; i < uint(_digits); i++) {
      if (byteMask & _guess != _blockHash & byteMask) {
        return false;
      }
      _blockHash = _blockHash >> 4;
      _guess = _guess >> 4;
    }
    return true;
  }
  
  function payout(uint _wager, uint _digits) public view returns (uint) {
    uint baseWager = (100 - houseFee(_digits)) * (_wager - resolverFee) / 100;
    return baseWager * 16 ** _digits;
  }
  
  function houseFee(uint _digits) public pure returns (uint) {    // in percent
    require(0 < _digits && _digits <= 4);
    if (_digits == 1) { return 2; }
    else if(_digits == 2) { return 3; }
    else if(_digits == 3) { return 4; }
    else { return 5; }
  }
  
  function getBet(uint index) public view returns(address, uint, uint, bytes32, BetStatus, uint) {
    return (bets[index].player, bets[index].wager, bets[index].digits, bets[index].guess, bets[index].status, bets[index].targetBlock);
  }
  
  function getPlayerBets() external view returns(uint[]) {
    return getBetsByOwner(msg.sender);  
  }
  
  function getBetsByOwner(address _owner) private view returns(uint[]) {
    uint[] memory result = new uint[](ownerBetCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < bets.length; i++) {
      if (betToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
  
  function getTotalWins() external view returns(uint) {
    uint pays = 0;
    for (uint i = 0; i < bets.length; i++) {
      if (bets[i].status == BetStatus.PlayerWon) {
        pays += payout(bets[i].wager, bets[i].digits);
      }
    }
    return pays;
  }

  function recentWinners() external view returns(uint[]) {
    uint len = 5;
    uint[] memory result = new uint[](len);
    uint counter = 0;

    for (uint i = 1; i <= bets.length && counter < len; i++) {
      if (bets[bets.length - i].status == BetStatus.PlayerWon) {
        result[counter] = bets.length - i;
        counter++;
      }
    }
    return result;
  }

}