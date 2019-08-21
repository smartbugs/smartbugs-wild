pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ECRecovery.sol

/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 *
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 *
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * @dev and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      "\x19Ethereum Signed Message:\n32",
      hash
    );
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
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
}

// File: contracts/LuckySeven.sol

contract LuckySeven is Ownable {

  using SafeMath for uint256;

  uint256 public minBet;
  uint256 public maxBet;
  bool public paused;
  address public signer;
  address public house;

  mapping (address => uint256) public balances;
  mapping (address => bool) public diceRolled;
  mapping (address => bytes) public betSignature;
  mapping (address => uint256) public betAmount;
  mapping (address => uint256) public betValue;
  mapping (bytes => bool) usedSignatures;

  mapping (address => uint256) public totalDiceRollsByAddress;
  mapping (address => uint256) public totalBetsByAddress;
  mapping (address => uint256) public totalBetsWonByAddress;
  mapping (address => uint256) public totalBetsLostByAddress;

  uint256 public pendingBetsBalance;
  uint256 public belowSevenBets;
  uint256 public aboveSevenBets;
  uint256 public luckySevenBets;

  uint256 public betsWon;
  uint256 public betsLost;

  event Event (
      string name,
      address indexed _better,
      uint256 num1,
      uint256 num2
  );

  constructor(uint256 _minBet, uint256 _maxBet, address _signer, address _house) public {
    minBet = _minBet;
    maxBet = _maxBet;
    signer = _signer;
    house = _house;
  }

  function setSigner(address _signer) public onlyOwner {
    signer = _signer;
  }

  function setHouse(address _house) public onlyOwner {
    // note previous house balance
    uint256 existingHouseBalance = balances[house];

    // drain existing house
    balances[house] = 0;

    // update house
    house = _house;

    // update balance for new house
    balances[house] = balances[house].add(existingHouseBalance);
  }

  function setMinBet(uint256 _minBet) public onlyOwner {
    minBet = _minBet;
  }

  function setMaxBet(uint256 _maxBet) public onlyOwner {
    maxBet = _maxBet;
  }

  function setPaused(bool _paused) public onlyOwner {
    paused = _paused;
  }

  function () external payable {
    topup();
  }

  function topup() payable public {
    require(msg.value > 0);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
  }

  function withdraw(uint256 amount) public {
    require(amount > 0);
    require(balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    msg.sender.transfer(amount);
  }

  function rollDice(bytes signature) public {
    require(!paused);

    // validate hash is not used before
    require(!usedSignatures[signature]);

    // mark the hash as used
    usedSignatures[signature] = true;

    // no existing bet placed
    require(betAmount[msg.sender] == 0);

    // set dice rolled to true
    diceRolled[msg.sender] = true;
    betSignature[msg.sender] = signature;

    totalDiceRollsByAddress[msg.sender] = totalDiceRollsByAddress[msg.sender].add(1);
    emit Event('dice-rolled', msg.sender, 0, 0);
  }

  function placeBet(uint256 amount, uint256 value) public {
    require(!paused);

    // validate inputs
    require(amount >= minBet && amount <= maxBet);
    require(value >= 1 && value <= 3);

    // validate dice rolled
    require(diceRolled[msg.sender]);

    // validate no existing bet placed
    require(betAmount[msg.sender] == 0);

    // validate user has balance to place the bet
    require(balances[msg.sender] >= amount);

    // transfer balance to house
    balances[msg.sender] = balances[msg.sender].sub(amount);
    balances[house] = balances[house].add(amount);
    pendingBetsBalance = pendingBetsBalance.add(amount);

    // store bet amount and value
    betValue[msg.sender] = value;
    betAmount[msg.sender] = amount;

    totalBetsByAddress[msg.sender] = totalBetsByAddress[msg.sender].add(1);
    emit Event('bet-placed', msg.sender, amount, 0);
  }

  function completeBet(bytes32 hash) public returns (uint256, uint256){
    // validate there is bet placed
    require(betAmount[msg.sender] > 0);

    // validate input hash
    require(ECRecovery.recover(hash, betSignature[msg.sender]) == signer);

    // compute dice number and calculate amount won
    uint256 num1 = (
      uint256(
        ECRecovery.toEthSignedMessageHash(
          keccak256(
            abi.encodePacked(hash)
          )
        )
      ) % 6
    ) + 1;

    uint256 num2 = (
      uint256(
        ECRecovery.toEthSignedMessageHash(
          sha256(
            abi.encodePacked(hash)
          )
        )
      ) % 6
    ) + 1;
    uint256 num = num1 + num2;
    uint256 value = betValue[msg.sender];
    uint256 winRate = 0;
    if (num <= 6) {
      belowSevenBets = belowSevenBets.add(1);
      if (value == 1) {
        winRate = 2;
      }
    } else if (num == 7) {
      luckySevenBets = luckySevenBets.add(1);
      if (value == 2) {
        winRate = 3;
      }
    } else {
      aboveSevenBets = aboveSevenBets.add(1);
      if (value == 3) {
        winRate = 2;
      }
    }

    uint256 amountWon = betAmount[msg.sender] * winRate;

    // transfer balance from house
    if (amountWon > 0) {
      balances[house] = balances[house].sub(amountWon);
      balances[msg.sender] = balances[msg.sender].add(amountWon);
      totalBetsWonByAddress[msg.sender] = totalBetsWonByAddress[msg.sender].add(1);
      betsWon = betsWon.add(1);
      emit Event('bet-won', msg.sender, amountWon, num);
    } else {
      totalBetsLostByAddress[msg.sender] = totalBetsLostByAddress[msg.sender].add(1);
      betsLost = betsLost.add(1);
      emit Event('bet-lost', msg.sender, betAmount[msg.sender], num);
    }
    pendingBetsBalance = pendingBetsBalance.sub(betAmount[msg.sender]);

    // reset diceRolled and amount
    diceRolled[msg.sender] = false;
    betAmount[msg.sender] = 0;
    betValue[msg.sender] = 0;
    betSignature[msg.sender] = '0x';

    return (amountWon, num);
  }
}