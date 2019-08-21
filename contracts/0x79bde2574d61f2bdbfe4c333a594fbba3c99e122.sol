pragma solidity 0.4.24;

contract LuckyoneGuess
{
    using SafeMath for *;

    address public master;

    mapping(uint256 => mapping(uint256 => uint256)) results;

    bool public paused = false;

    constructor() public {
        master = msg.sender;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier onlyMaster() {
        require(msg.sender == master);
        _;
    }

    function pause() public whenNotPaused onlyMaster {
        paused = true;
    }

    function unpause() public whenPaused onlyMaster {
        paused = false;
    }

    function makeRandomResult(uint256 guessType, uint256 period, uint256 seed, uint256 maxNumber) onlyMaster
        public returns (bool)  {
        require(guessType > 0);
        require(period > 0);
        require(seed >= 0);
        require(maxNumber > 0);
        require(results[guessType][period] <= 0);
        require(maxNumber <= 1000000);
        uint256 random = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                (guessType).add
                (period).add
                (seed)))) % maxNumber;
        results[guessType][period] = random;
        return true;
    }

    function getResult(uint256 guessType, uint256 period)
        public view returns (uint256){
        require(guessType > 0);
        require(period > 0);
        require(results[guessType][period] > 0);
        return results[guessType][period];
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }
}