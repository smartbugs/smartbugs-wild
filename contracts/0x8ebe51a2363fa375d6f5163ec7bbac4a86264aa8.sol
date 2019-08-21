pragma solidity ^0.4.24;

library DataSet {

    enum RoundState {
        UNKNOWN,        // aim to differ from normal states
        STARTED,        // start current round
        STOPPED,        // stop current round
        DRAWN,          // draw winning number
        ASSIGNED        // assign to foundation, winner
    }

    struct Round {
        uint256                         count;              // record total numbers sold already
        uint256                         timestamp;          // timestamp refer to first bet(round start)
        uint256                         blockNumber;        // block number refer to last bet
        uint256                         drawBlockNumber;    // block number refer to draw winning number
        RoundState                      state;              // round state
        uint256                         pond;               // amount refer to current round
        uint256                         winningNumber;      // winning number
        address                         winner;             // winner's address
    }

}

/**
 * @title NumberCompressor
 * @dev Number compressor to storage the begin and end numbers into a uint256
 */
library NumberCompressor {

    uint256 constant private MASK = 16777215;   // 2 ** 24 - 1

    function encode(uint256 _begin, uint256 _end, uint256 _ceiling) internal pure returns (uint256)
    {
        require(_begin <= _end && _end < _ceiling, "number is invalid");

        return _begin << 24 | _end;
    }

    function decode(uint256 _value) internal pure returns (uint256, uint256)
    {
        uint256 end = _value & MASK;
        uint256 begin = (_value >> 24) & MASK;
        return (begin, end);
    }

}

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
}

contract Events {

    event onActivate
    (
        address indexed addr,
        uint256 timestamp,
        uint256 bonus,
        uint256 issued_numbers
    );

    event onDraw
    (
        uint256 timestatmp,
        uint256 blockNumber,
        uint256 roundID,
        uint256 winningNumber
    );

    event onStartRunnd
    (
        uint256 timestamp,
        uint256 roundID
    );

    event onBet
    (
        address indexed addr,
        uint256 timestamp,
        uint256 roundID,
        uint256 beginNumber,
        uint256 endNumber
    );

    event onAssign
    (
        address indexed operatorAddr,
        uint256 timestatmp,
        address indexed winnerAddr,
        uint256 roundID,
        uint256 pond,
        uint256 bonus,      // assigned to winner
        uint256 fund        // assigned to platform
    );

    event onRefund
    (
        address indexed operatorAddr,
        uint256 timestamp,
        address indexed playerAddr,
        uint256 count,
        uint256 amount
    );

    event onLastRefund
    (
        address indexed operatorAddr,
        uint256 timestamp,
        address indexed platformAddr,
        uint256 amout
    );

}

contract Winner is Events {

    using SafeMath for *;

    uint256     constant private    MIN_BET = 0.01 ether;                                   // min bet every time
    uint256     constant private    PRICE   = 0.01 ether;                                   // 0.01 ether every number
    uint256     constant private    MAX_DURATION = 30 days;                                 // max duration every round
    uint256     constant private    REFUND_RATE = 90;                                       // refund rate to player(%)
    address     constant private    platform = 0x1f79bfeCe98447ac5466Fd9b8F71673c780566Df;  // paltform's address
    uint256     private             curRoundID;                                             // current round
    uint256     private             drawnRoundID;                                           // already drawn round
    uint256     private             drawnBlockNumber;                                       // already drawn a round in block
    uint256     private             bonus;                                                  // bonus assigned to the winner
    uint256     private             issued_numbers;                                         // total numbers every round
    bool        private             initialized;                                            // game is initialized or not

    // (roundID => data) returns round data
    mapping (uint256 => DataSet.Round) private rounds;
    // (roundID => address => numbers) returns player's numbers in round
    mapping (uint256 => mapping(address => uint256[])) private playerNumbers;
    mapping (address => bool) private administrators;

    // default constructor
    constructor() public {
    }

    /**
     * @dev check sender must be administrators
     */
    modifier isAdmin() {
        require(administrators[msg.sender], "only administrators");
        _;
    }

    /**
     * @dev make sure no one can interact with contract until it has
     * been initialized.
     */
    modifier isInitialized () {
        require(initialized == true, "game is inactive");
        _;
    }

    /**
     * @dev prevent contract from interacting with external contracts.
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry, humans only");
        _;
    }

    /**
     * @dev check the bet's bound
     * @param _eth the eth amount
     * In order to ensure as many as possiable players envolve in the
     * game, you can only buy no more than 2 * issued_numbers every time.
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= MIN_BET, "the bet is too small");
        require(_eth <= PRICE.mul(issued_numbers).mul(2), "the bet is too big");
        _;
    }

    /**
     * @dev default to bet
     */
    function() public payable isHuman() isInitialized() isWithinLimits(msg.value)
    {
        bet(msg.value);
    }

    /**
     * @dev initiate game
     * @param _bonus the bonus assigned the winner every round
     * @param _issued_numbers the quantity of candidate numbers every round
     */
    function initiate(uint256 _bonus, uint256 _issued_numbers) public isHuman()
    {
        // can only be initialized once
        require(initialized == false, "it has been initialized already");
        require(_bonus > 0, "bonus is invalid");
        require(_issued_numbers > 0, "issued_numbers is invalid");

        // initiate global parameters
        initialized = true;
        administrators[msg.sender] = true;
        bonus = _bonus;
        issued_numbers = _issued_numbers;

        emit onActivate(msg.sender, block.timestamp, bonus, issued_numbers);

        // start the first round game
        curRoundID = 1;
        rounds[curRoundID].state = DataSet.RoundState.STARTED;
        rounds[curRoundID].timestamp = block.timestamp;
        drawnRoundID = 0;

        emit onStartRunnd(block.timestamp, curRoundID);
    }

    /**
     * @dev draw winning number
     */
    function drawNumber() private view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(

            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 1))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 2))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 3))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 4))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 5))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 6))))) / (block.timestamp))

        ))) % issued_numbers;

    }

    /**
     * @dev bet
     * @param _amount the amount for a bet
     */
    function bet(uint256 _amount) private
    {
        // 1. draw the winning number if it is necessary
        if (block.number != drawnBlockNumber
            && curRoundID > drawnRoundID
            && rounds[drawnRoundID + 1].count == issued_numbers
            && block.number >= rounds[drawnRoundID + 1].blockNumber + 7)
        {
            drawnBlockNumber = block.number;
            drawnRoundID += 1;

            rounds[drawnRoundID].winningNumber = drawNumber();
            rounds[drawnRoundID].state = DataSet.RoundState.DRAWN;
            rounds[drawnRoundID].drawBlockNumber = drawnBlockNumber;

            emit onDraw(block.timestamp, drawnBlockNumber, drawnRoundID, rounds[drawnRoundID].winningNumber);
        }

        // 2. bet
        uint256 amount = _amount;
        while (true)
        {
            // in every round, one can buy min(max, available) numbers.
            uint256 max = issued_numbers - rounds[curRoundID].count;
            uint256 available = amount.div(PRICE).min(max);

            if (available == 0)
            {
                // on condition that the PRICE is 0.01 eth, if the player pays 0.056 eth for
                // a bet, then the player can exchange only five number, as 0.056/0.01 = 5,
                // and the rest 0.06 eth distributed to the pond of current round.
                if (amount != 0)
                {
                    rounds[curRoundID].pond += amount;
                }
                break;
            }
            uint256[] storage numbers = playerNumbers[curRoundID][msg.sender];
            uint256 begin = rounds[curRoundID].count;
            uint256 end = begin + available - 1;
            uint256 compressedNumber = NumberCompressor.encode(begin, end, issued_numbers);
            numbers.push(compressedNumber);
            rounds[curRoundID].pond += available.mul(PRICE);
            rounds[curRoundID].count += available;
            amount -= available.mul(PRICE);

            emit onBet(msg.sender, block.timestamp, curRoundID, begin, end);

            if (rounds[curRoundID].count == issued_numbers)
            {
                // end current round and start the next round
                rounds[curRoundID].blockNumber = block.number;
                rounds[curRoundID].state = DataSet.RoundState.STOPPED;
                curRoundID += 1;
                rounds[curRoundID].state = DataSet.RoundState.STARTED;
                rounds[curRoundID].timestamp = block.timestamp;

                emit onStartRunnd(block.timestamp, curRoundID);
            }
        }
    }

    /**
     * @dev assign for a round
     * @param _roundID the round ID
     */
    function assign(uint256 _roundID) external isHuman() isInitialized()
    {
        assign2(msg.sender, _roundID);
    }

    /**
     * @dev assign for a round
     * @param _player the player's address
     * @param _roundID the round ID
     */
    function assign2(address _player, uint256 _roundID) public isHuman() isInitialized()
    {
        require(rounds[_roundID].state == DataSet.RoundState.DRAWN, "it's not time for assigning");

        uint256[] memory numbers = playerNumbers[_roundID][_player];
        require(numbers.length > 0, "player did not involve in");
        uint256 targetNumber = rounds[_roundID].winningNumber;
        for (uint256 i = 0; i < numbers.length; i ++)
        {
            (uint256 start, uint256 end) = NumberCompressor.decode(numbers[i]);
            if (targetNumber >= start && targetNumber <= end)
            {
                // assgin bonus to player, and the rest of the pond to platform
                uint256 fund = rounds[_roundID].pond.sub(bonus);
                _player.transfer(bonus);
                platform.transfer(fund);
                rounds[_roundID].state = DataSet.RoundState.ASSIGNED;
                rounds[_roundID].winner = _player;

                emit onAssign(msg.sender, block.timestamp, _player, _roundID, rounds[_roundID].pond, bonus, fund);

                break;
            }
        }
    }

    /**
     * @dev refund to player and platform
     */
    function refund() external isHuman() isInitialized()
    {
        refund2(msg.sender);
    }

    /**
     * @dev refund to player and platform
     * @param _player the player's address
     */
    function refund2(address _player) public isInitialized() isHuman()
    {
        require(block.timestamp.sub(rounds[curRoundID].timestamp) >= MAX_DURATION, "it's not time for refunding");

        // 1. count numbers owned by the player
        uint256[] storage numbers = playerNumbers[curRoundID][_player];
        require(numbers.length > 0, "player did not involve in");

        uint256 count = 0;
        for (uint256 i = 0; i < numbers.length; i ++)
        {
            (uint256 begin, uint256 end) = NumberCompressor.decode(numbers[i]);
            count += (end - begin + 1);
        }

        // 2. refund 90% to the player
        uint256 amount = count.mul(PRICE).mul(REFUND_RATE).div(100);
        rounds[curRoundID].pond = rounds[curRoundID].pond.sub(amount);
        _player.transfer(amount);

        emit onRefund(msg.sender, block.timestamp, _player, count, amount);

        // 3. refund the rest(abount 10% of the pond) to the platform if the player is the last to refund
        rounds[curRoundID].count -= count;
        if (rounds[curRoundID].count == 0)
        {
            uint256 last = rounds[curRoundID].pond;
            platform.transfer(last);
            rounds[curRoundID].pond = 0;

            emit onLastRefund(msg.sender, block.timestamp, platform, last);
        }
    }

    /**
     * @dev return player's numbers in the round
     * @param _roundID round ID
     * @param _palyer player's address
     * @return uint256[], player's numbers
     */
    function getPlayerRoundNumbers(uint256 _roundID, address _palyer) public view returns(uint256[])
    {
        return playerNumbers[_roundID][_palyer];
    }

    /**
     * @dev return round's information
     * @param _roundID round ID
     * @return uint256, quantity of round's numbers
     * @return uint256, block number refer to last bet
     * @return uint256, block number refer to draw winning number
     * @return uint256, round's running state
     * @return uint256, round's pond
     * @return uint256, round's winning number if drawn
     * @return address, round's winner if assigned
     */
    function getRoundInfo(uint256 _roundID) public view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, address)
    {
        return (
            rounds[_roundID].count,
            rounds[_roundID].blockNumber,
            rounds[_roundID].drawBlockNumber,
            uint256(rounds[_roundID].state),
            rounds[_roundID].pond,
            rounds[_roundID].winningNumber,
            rounds[_roundID].winner
        );
    }

    /**
     * @dev return game's information
     * @return bool, game is active or not
     * @return uint256, bonus assigned to the winner
     * @return uint256, total numbers every round
     * @return uint256, current round ID
     * @return uint256, already drawn round ID
     */
    function gameInfo() public view
        returns(bool, uint256, uint256, uint256, uint256)
    {
        return (
            initialized,
            bonus,
            issued_numbers,
            curRoundID,
            drawnRoundID
        );
    }
}

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public view returns (address);

    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () public payable {
        address _impl = implementation();
        require(_impl != address(0), "address invalid");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(address indexed implementation);

    // Storage position of the address of the current implementation
    bytes32 private constant implementationPosition = keccak256("you are the lucky man.proxy");

    /**
    * @dev Constructor function
    */
    constructor() public {}

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address impl) {
        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    /**
    * @dev Sets the address of the current implementation
    * @param newImplementation address representing the new implementation to be set
    */
    function setImplementation(address newImplementation) internal {
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
    }

    /**
    * @dev Upgrades the implementation address
    * @param newImplementation representing the address of the new implementation to be set
    */
    function _upgradeTo(address newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != newImplementation, "new address is the same");
        setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
}

/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    // Storage position of the owner of the contract
    bytes32 private constant proxyOwnerPosition = keccak256("you are the lucky man.proxy.owner");

    /**
    * @dev the constructor sets the original owner of the contract to the sender account.
    */
    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "owner only");
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function proxyOwner() public view returns (address owner) {
        bytes32 position = proxyOwnerPosition;
        assembly {
            owner := sload(position)
        }
    }

    /**
    * @dev Sets the address of the owner
    */
    function setUpgradeabilityOwner(address newProxyOwner) internal {
        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, newProxyOwner)
        }
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0), "address is invalid");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    /**
    * @dev Allows the proxy owner to upgrade the current version of the proxy.
    * @param implementation representing the address of the new implementation to be set.
    */
    function upgradeTo(address implementation) public onlyProxyOwner {
        _upgradeTo(implementation);
    }

    /**
    * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
    * to initialize whatever is needed through a low level call.
    * @param implementation representing the address of the new implementation to be set.
    * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
    * signature of the implementation to be called with the needed payload
    */
    function upgradeToAndCall(address implementation, bytes data) public payable onlyProxyOwner {
        upgradeTo(implementation);
        require(address(this).call.value(msg.value)(data), "data is invalid");
    }
}