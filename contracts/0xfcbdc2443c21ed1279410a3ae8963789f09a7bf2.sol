pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
    /**
    * @dev constructor
    */
    function SafeMath() public {
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public newOwner;

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
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
    * @dev confirm ownership by a new owner
    */
    function confirmOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
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

contract TheAbyssCrowdsale is Ownable, SafeMath, Pausable {
    mapping (address => uint256) public balances;

    uint256 public constant TOKEN_PRICE_NUM = 2500;
    uint256 public constant TOKEN_PRICE_DENOM = 1;

    uint256 public constant PRESALE_ETHER_MIN_CONTRIB = 0.01 ether;
    uint256 public constant SALE_ETHER_MIN_CONTRIB = 0.1 ether;

    uint256 public constant PRESALE_CAP = 10000 ether;
    uint256 public constant HARD_CAP = 100000 ether;

    uint256 public constant PRESALE_START_TIME = 1413609200;
    uint256 public constant PRESALE_END_TIME = 1514764740;

    uint256 public constant SALE_START_TIME = 1515510000;
    uint256 public constant SALE_END_TIME = 1518739140;

    uint256 public totalEtherContributed = 0;
    uint256 public totalTokensToSupply = 0;
    address public wallet = 0x0;

    uint256 public bonusWindow1EndTime = 0;
    uint256 public bonusWindow2EndTime = 0;
    uint256 public bonusWindow3EndTime = 0;  

    event LogContribution(address indexed contributor, uint256 amountWei, uint256 tokenAmount, uint256 tokenBonus, uint256 timestamp);

    modifier checkContribution() {
        require(
            (now >= PRESALE_START_TIME && now < PRESALE_END_TIME && msg.value >= PRESALE_ETHER_MIN_CONTRIB) ||
            (now >= SALE_START_TIME && now < SALE_END_TIME && msg.value >= SALE_ETHER_MIN_CONTRIB)
        );
        _;
    }

    modifier checkCap() {
        require(
            (now >= PRESALE_START_TIME && now < PRESALE_END_TIME && safeAdd(totalEtherContributed, msg.value) <= PRESALE_CAP) ||
            (now >= SALE_START_TIME && now < SALE_END_TIME && safeAdd(totalEtherContributed, msg.value) <= HARD_CAP)
        );
        _;
    }

    function TheAbyssCrowdsale(address _wallet) public {
        require(_wallet != address(0));

        wallet = _wallet;

        bonusWindow1EndTime = SALE_START_TIME + 1 days;
        bonusWindow2EndTime = SALE_START_TIME + 4 days;
        bonusWindow3EndTime = SALE_START_TIME + 20 days;
    }

    function getBonus() internal constant returns (uint256, uint256) {
        uint256 numerator = 0;
        uint256 denominator = 100;

        if(now >= PRESALE_START_TIME && now < PRESALE_END_TIME) {
            numerator = 25;
        } else if(now >= SALE_START_TIME && now < SALE_END_TIME) {
            if(now < bonusWindow1EndTime) {
                numerator = 15;
            } else if(now < bonusWindow2EndTime) {
                numerator = 10;
            } else if(now < bonusWindow3EndTime) {
                numerator = 5;
            } else {
                numerator = 0;
            }
        }
        return (numerator, denominator);
    }

    function () payable public {
        processContribution();
    }

    function processContribution() private whenNotPaused checkContribution checkCap {
        uint256 bonusNum = 0;
        uint256 bonusDenom = 100;
        (bonusNum, bonusDenom) = getBonus();
        uint256 tokenBonusAmount = 0;
        uint256 tokenAmount = safeDiv(safeMul(msg.value, TOKEN_PRICE_NUM), TOKEN_PRICE_DENOM);

        if(bonusNum > 0) {
            tokenBonusAmount = safeDiv(safeMul(tokenAmount, bonusNum), bonusDenom);
        }

        uint256 tokenTotalAmount = safeAdd(tokenAmount, tokenBonusAmount);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokenTotalAmount);

        totalEtherContributed = safeAdd(totalEtherContributed, msg.value);
        totalTokensToSupply = safeAdd(totalTokensToSupply, tokenTotalAmount);
        LogContribution(msg.sender, msg.value, tokenAmount, tokenBonusAmount, now);
    }

    function transferFunds() public onlyOwner {
        wallet.transfer(this.balance);
    }
}