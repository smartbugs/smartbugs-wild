pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
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
}

// File: contracts/Upcoin.sol

contract Upcoin {
    uint8 public decimals = 18;

    function isUpcoin() public pure returns (bool);
    function transferOrigin(address _to, uint256 _value) public returns (bool);
}

// File: contracts/Lottery.sol

contract Lottery is Ownable {
    using SafeMath for uint256;

    event LotteryFinished();
    event Roll(address indexed participant, uint256 prize);

    struct Prize {
        uint256 chance;
        uint256 left;
        uint256 min;
        uint256 max;
    }

    bool public lotteryFinished = false;

    uint256 private randomCount = 0;

    Prize[] private prizes;
    Upcoin private upcoin;


    modifier canRoll() {
        require(!lotteryFinished, "Lottery already finished");
        _;
    }

    modifier hasPrizes() {
        uint256 left = prizes[0].left;

        for (uint256 i = 1; i < prizes.length; i = i.add(1)) {
            if (prizes[i].left > left) {
                left = prizes[i].left;
            }
        }

        require(left > 0, "No more prizes left");
        _;
    }

    modifier isUpcoin() {
        require(address(upcoin) != address(0), "Token address must be not null");
        require(upcoin.isUpcoin(), "Token must be Upcoin instance");
        _;
    }

    constructor(address _address) public {
        upcoin = Upcoin(_address);

        prizes.push(Prize(2, 1, 500000, 500000));
        prizes.push(Prize(4, 3, 12001, 75000));
        prizes.push(Prize(6, 6, 5001, 12000));
        prizes.push(Prize(10, 40, 3001, 5000));
        prizes.push(Prize(15, 50, 1001, 3000));
        prizes.push(Prize(18, 400, 501, 1000));
        prizes.push(Prize(20, 500, 251, 500));
        prizes.push(Prize(25, 29000, 100, 250));
    }

    function finishLottery() public canRoll onlyOwner returns (bool) {
        lotteryFinished = true;

        emit LotteryFinished();

        return true;
    }

    function getRandomPrize() private returns (Prize) {
        uint256 chance = randomMinMax(0, 100);

        uint256 index = 0;
        uint256 percent = 0;

        while (prizes[index].left == 0) {
            percent = percent.add(prizes[index].chance);

            index = index.add(1);
        }

        Prize memory prize = prizes[index];

        uint256 start = index.add(1);

        if (start < prizes.length && chance > percent + prize.chance) {
            percent = percent.add(prize.chance);

            for (uint256 i = start; i < prizes.length; i = i.add(1)) {
                prize.chance = prizes[i].chance;

                if (prizes[i].left > 0 && chance <= percent + prize.chance) {
                    prize = prizes[i];

                    index = i;

                    break;
                } else {
                    percent = percent.add(prize.chance);
                }
            }
        }

        prize.left = prize.left.sub(1);

        prizes[index] = prize;

        return prize;
    }

    function getRandomAmount(uint256 _min, uint256 _max) private returns (uint256) {
        return randomMinMax(_min, _max) * 10 ** uint256(upcoin.decimals());
    }

    function random() private returns (uint256) {
        uint256 randomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), randomCount)));

        randomCount = randomCount.add(1);

        return randomness;
    }

    function randomMinMax(uint256 _min, uint256 _max) private returns (uint256) {
        if (_min == _max) {
            return _max;
        }

        if (_min > _max) {
            (_min, _max) = (_max, _min);
        }

        uint256 value = random() % _max;

        if (value < _min) {
            value = _min + random() % (_max - _min);
        }

        return value;
    }

    function roll(address _address) public onlyOwner canRoll hasPrizes isUpcoin returns (bool) {
        require(_address != address(0), "Participant address must be not null");

        Prize memory prize = getRandomPrize();

        uint256 amount = getRandomAmount(prize.min, prize.max);

        upcoin.transferOrigin(_address, amount);

        emit Roll(_address, amount);

        return true;
    }
}