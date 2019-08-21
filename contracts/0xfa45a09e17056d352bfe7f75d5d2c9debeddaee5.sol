/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract SimpleToken is Ownable {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }


    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]); // Check there is enough balance.

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev public function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
}
contract Manageable is Ownable {
    mapping(address => bool) public listOfManagers;

    modifier onlyManager() {
        require(listOfManagers[msg.sender], "");
        _;
    }

    function addManager(address _manager) public onlyOwner returns (bool success) {
        if (!listOfManagers[_manager]) {
            require(_manager != address(0), "");
            listOfManagers[_manager] = true;
            success = true;
        }
    }

    function removeManager(address _manager) public onlyOwner returns (bool success) {
        if (listOfManagers[_manager]) {
            listOfManagers[_manager] = false;
            success = true;
        }
    }

    function getInfo(address _manager) public view returns (bool) {
        return listOfManagers[_manager];
    }
}


contract iRNG {
    function update(uint roundNumber, uint additionalNonce, uint period) public payable;
    function __callback(bytes32 _queryId, uint _result) public;
}


contract iKYCWhitelist {
    function isWhitelisted(address _participant) public view returns (bool);
}

contract BaseLottery is Manageable {
    using SafeMath for uint;

    enum RoundState {NOT_STARTED, ACCEPT_FUNDS, WAIT_RESULT, SUCCESS, REFUND}

    struct Round {
        RoundState state;
        uint ticketsCount;
        uint participantCount;
        TicketsInterval[] tickets;
        address[] participants;
        uint random;
        uint nonce; //xored participants addresses
        uint startRoundTime;
        uint[] winningTickets;
        address[] winners;
        uint roundFunds;
        mapping(address => uint) winnersFunds;
        mapping(address => uint) participantFunds;
        mapping(address => bool) sendGain;
    }

    struct TicketsInterval {
        address participant;
        uint firstTicket;
        uint lastTicket;
    }

    uint constant public NUMBER_OF_WINNERS = 10;
    uint constant public SHARE_DENOMINATOR = 10000;
    //uint constant public ORACLIZE_TIMEOUT = 86400;  // one day
    uint public ORACLIZE_TIMEOUT = 86400;  // only for tests
    uint[] public shareOfWinners = [5000, 2500, 1250, 620, 320, 160, 80, 40, 20, 10];
    address payable public organiser;
    uint constant public ORGANISER_PERCENT = 20;
    uint constant public ROUND_FUND_PERCENT = 80;

    iKYCWhitelist public KYCWhitelist;

    uint public period;
    address public mainLottery;
    address public management;
    address payable public rng;

    mapping (uint => Round) public rounds;

    uint public ticketPrice;
    uint public currentRound;

    event LotteryStarted(uint start);
    event RoundStateChanged(uint currentRound, RoundState state);
    event ParticipantAdded(uint round, address participant, uint ticketsCount, uint funds);
    event RoundProcecced(uint round, address[] winners, uint[] winningTickets, uint roundFunds);
    event RefundIsSuccess(uint round, address participant, uint funds);
    event RefundIsFailed(uint round, address participant);
    event Withdraw(address participant, uint funds, uint fromRound, uint toRound);
    event AddressIsNotAddedInKYC(address participant);
    event TicketPriceChanged(uint price);

    modifier onlyRng {
        require(msg.sender == address(rng), "");
        _;
    }

    modifier onlyLotteryContract {
        require(msg.sender == address(mainLottery) || msg.sender == management, "");
        _;
    }

    constructor (address payable _rng, uint _period) public {
        require(_rng != address(0), "");
        require(_period >= 60, "");

        rng = _rng;
        period = _period;
    }

    function setContracts(address payable _rng, address _mainLottery, address _management) public onlyOwner {
        require(_rng != address(0), "");
        require(_mainLottery != address(0), "");
        require(_management != address(0), "");

        rng = _rng;
        mainLottery = _mainLottery;
        management = _management;
    }

    function startLottery(uint _startPeriod) public payable onlyLotteryContract {
        currentRound = 1;
        uint time = getCurrentTime().add(_startPeriod).sub(period);
        rounds[currentRound].startRoundTime = time;
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;

        iRNG(rng).update.value(msg.value)(currentRound, 0, _startPeriod);

        emit LotteryStarted(time);
    }

    function buyTickets(address _participant) public payable onlyLotteryContract {
        uint funds = msg.value;

        updateRoundTimeAndState();
        addParticipant(_participant, funds.div(ticketPrice));
        updateRoundFundsAndParticipants(_participant, funds);

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period) &&
            rounds[currentRound].participantCount >= 10
        ) {
            _restartLottery();
        }
    }

    function buyBonusTickets(address _participant, uint _ticketsCount) public payable onlyLotteryContract {
        updateRoundTimeAndState();
        addParticipant(_participant, _ticketsCount);
        updateRoundFundsAndParticipants(_participant, uint(0));

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period) &&
            rounds[currentRound].participantCount >= 10
        ) {
            _restartLottery();
        }
    }

    function processRound(uint _round, uint _randomNumber) public payable onlyRng returns (bool) {
        if (rounds[_round].winners.length != 0) {
            return true;
        }

        if (checkRoundState(_round) == RoundState.REFUND) {
            return true;
        }

        if (rounds[_round].participantCount < 10) {
            rounds[_round].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(_round, rounds[_round].state);
            return true;
        }

        rounds[_round].random = _randomNumber;
        findWinTickets(_round);
        findWinners(_round);
        rounds[_round].state = RoundState.SUCCESS;
        emit RoundStateChanged(_round, rounds[_round].state);

        if (rounds[_round.add(1)].state == RoundState.NOT_STARTED) {
            currentRound = _round.add(1);
            rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
        }

        emit RoundProcecced(_round, rounds[_round].winners, rounds[_round].winningTickets, rounds[_round].roundFunds);
        getRandomNumber(_round + 1, rounds[_round].nonce);
        return true;
    }

    function restartLottery() public payable onlyOwner {
        _restartLottery();
    }

    function getRandomNumber(uint _round, uint _nonce) public payable onlyRng {
        iRNG(rng).update(_round, _nonce, period);
    }

    function setTicketPrice(uint _ticketPrice) public onlyLotteryContract {
        require(_ticketPrice > 0, "");

        emit TicketPriceChanged(_ticketPrice);
        ticketPrice = _ticketPrice;
    }

    function findWinTickets(uint _round) public {
        uint[10] memory winners = _findWinTickets(rounds[_round].random, rounds[_round].ticketsCount);

        for (uint i = 0; i < 10; i++) {
            rounds[_round].winningTickets.push(winners[i]);
        }
    }

    function _findWinTickets(uint _random, uint _ticketsNum) public pure returns (uint[10] memory) {
        uint random = _random;//uint(keccak256(abi.encodePacked(_random)));
        uint winnersNum = 10;

        uint[10] memory winTickets;
        uint shift = uint(256).div(winnersNum);

        for (uint i = 0; i < 10; i++) {
            winTickets[i] =
            uint(keccak256(abi.encodePacked(((random << (i.mul(shift))) >> (shift.mul(winnersNum.sub(1)).add(6)))))).mod(_ticketsNum);
        }

        return winTickets;
    }

    function refund(uint _round) public {
        if (checkRoundState(_round) == RoundState.REFUND
        && rounds[_round].participantFunds[msg.sender] > 0
        ) {
            uint amount = rounds[_round].participantFunds[msg.sender];
            rounds[_round].participantFunds[msg.sender] = 0;
            address(msg.sender).transfer(amount);
            emit RefundIsSuccess(_round, msg.sender, amount);
        } else {
            emit RefundIsFailed(_round, msg.sender);
        }
    }

    function checkRoundState(uint _round) public returns (RoundState) {
        if (rounds[_round].state == RoundState.WAIT_RESULT
        && getCurrentTime() > rounds[_round].startRoundTime.add(ORACLIZE_TIMEOUT)
        ) {
            rounds[_round].state = RoundState.REFUND;
            emit RoundStateChanged(_round, rounds[_round].state);
        }
        return rounds[_round].state;
    }

    function setOrganiser(address payable _organiser) public onlyOwner {
        require(_organiser != address(0), "");

        organiser = _organiser;
    }

    function setKYCWhitelist(address _KYCWhitelist) public onlyOwner {
        require(_KYCWhitelist != address(0), "");

        KYCWhitelist = iKYCWhitelist(_KYCWhitelist);
    }

    function getGain(uint _fromRound, uint _toRound) public {
        _transferGain(msg.sender, _fromRound, _toRound);
    }

    function sendGain(address payable _participant, uint _fromRound, uint _toRound) public onlyManager {
        _transferGain(_participant, _fromRound, _toRound);
    }

    function getTicketsCount(uint _round) public view returns (uint) {
        return rounds[_round].ticketsCount;
    }

    function getTicketPrice() public view returns (uint) {
        return ticketPrice;
    }

    function getCurrentTime() public view returns (uint) {
        return now;
    }

    function getPeriod() public view returns (uint) {
        return period;
    }

    function getRoundWinners(uint _round) public view returns (address[] memory) {
        return rounds[_round].winners;
    }

    function getRoundWinningTickets(uint _round) public view returns (uint[] memory) {
        return rounds[_round].winningTickets;
    }

    function getRoundParticipants(uint _round) public view returns (address[] memory) {
        return rounds[_round].participants;
    }

    function getWinningFunds(uint _round, address _winner) public view returns  (uint) {
        return rounds[_round].winnersFunds[_winner];
    }

    function getRoundFunds(uint _round) public view returns (uint) {
        return rounds[_round].roundFunds;
    }

    function getParticipantFunds(uint _round, address _participant) public view returns (uint) {
        return rounds[_round].participantFunds[_participant];
    }

    function getCurrentRound() public view returns (uint) {
        return currentRound;
    }

    function getRoundStartTime(uint _round) public view returns (uint) {
        return rounds[_round].startRoundTime;
    }

    function _restartLottery() internal {
        uint _now = getCurrentTime().sub(rounds[1].startRoundTime);
        rounds[currentRound].startRoundTime = getCurrentTime().sub(_now.mod(period));
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
        emit RoundStateChanged(currentRound, rounds[currentRound].state);
        iRNG(rng).update(currentRound, 0, period.sub(_now.mod(period)));
    }

    function _transferGain(address payable _participant, uint _fromRound, uint _toRound) internal {
        require(_fromRound <= _toRound, "");
        require(_participant != address(0), "");

        if (KYCWhitelist.isWhitelisted(_participant)) {
            uint funds;

            for (uint i = _fromRound; i <= _toRound; i++) {

                if (rounds[i].state == RoundState.SUCCESS
                && rounds[i].sendGain[_participant] == false) {

                    rounds[i].sendGain[_participant] = true;
                    funds = funds.add(getWinningFunds(i, _participant));
                }
            }

            require(funds > 0, "");
            _participant.transfer(funds);
            emit Withdraw(_participant, funds, _fromRound, _toRound);
        } else {
            emit AddressIsNotAddedInKYC(_participant);
        }
    }

    // find participant who has winning ticket
    // to start: _begin is 0, _end is last index in ticketsInterval array
    function getWinner(
        uint _round,
        uint _beginInterval,
        uint _endInterval,
        uint _winningTicket
    )
        internal
        returns (address)
    {
        if (_beginInterval == _endInterval) {
            return rounds[_round].tickets[_beginInterval].participant;
        }

        uint len = _endInterval.add(1).sub(_beginInterval);
        uint mid = _beginInterval.add((len.div(2))).sub(1);
        TicketsInterval memory interval = rounds[_round].tickets[mid];

        if (_winningTicket < interval.firstTicket) {
            return getWinner(_round, _beginInterval, mid, _winningTicket);
        } else if (_winningTicket > interval.lastTicket) {
            return getWinner(_round, mid.add(1), _endInterval, _winningTicket);
        } else {
            return interval.participant;
        }
    }

    function addParticipant(address _participant, uint _ticketsCount) internal {
        rounds[currentRound].participants.push(_participant);
        uint currTicketsCount = rounds[currentRound].ticketsCount;
        rounds[currentRound].ticketsCount = currTicketsCount.add(_ticketsCount);
        rounds[currentRound].tickets.push(TicketsInterval(
                _participant,
                currTicketsCount,
                rounds[currentRound].ticketsCount.sub(1))
        );
        rounds[currentRound].nonce = rounds[currentRound].nonce + uint(keccak256(abi.encodePacked(_participant)));
        emit ParticipantAdded(currentRound, _participant, _ticketsCount, _ticketsCount.mul(ticketPrice));
    }

    function updateRoundTimeAndState() internal {
        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period)
            && rounds[currentRound].participantCount >= 10
        ) {
            rounds[currentRound].state = RoundState.WAIT_RESULT;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
            currentRound = currentRound.add(1);
            rounds[currentRound].startRoundTime = rounds[currentRound-1].startRoundTime.add(period);
            rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
        }
    }

    function updateRoundFundsAndParticipants(address _participant, uint _funds) internal {

        if (rounds[currentRound].participantFunds[_participant] == 0) {
            rounds[currentRound].participantCount = rounds[currentRound].participantCount.add(1);
        }

        rounds[currentRound].participantFunds[_participant] =
        rounds[currentRound].participantFunds[_participant].add(_funds);

        rounds[currentRound].roundFunds =
        rounds[currentRound].roundFunds.add(_funds);
    }

    function findWinners(uint _round) internal {
        address winner;
        uint fundsToWinner;
        for (uint i = 0; i < NUMBER_OF_WINNERS; i++) {
            winner = getWinner(
                _round,
                0,
                (rounds[_round].tickets.length).sub(1),
                rounds[_round].winningTickets[i]
            );

            rounds[_round].winners.push(winner);
            fundsToWinner = rounds[_round].roundFunds.mul(shareOfWinners[i]).div(SHARE_DENOMINATOR);
            rounds[_round].winnersFunds[winner] = rounds[_round].winnersFunds[winner].add(fundsToWinner);
        }
    }

}contract FiatContract {
  function USD(uint _id) public pure returns (uint256);
}

contract RealToken is Ownable, SimpleToken {
  FiatContract public price;
  BaseLottery public lottery;
    
  using SafeMath for uint256;

  string public constant name = "DreamPot Token";
  string public constant symbol = "DPT";
  uint32 public constant decimals = 0;

  address payable public ethBank;

  uint256 public factor;

  event GetEth(address indexed from, uint256 value);

  constructor() public {
    price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    ethBank = address(uint160(owner()));
    factor = 100;
  }

  function setLotteryBank(address bank) public onlyOwner {
    require(bank != address(0));
    ethBank = address(uint160(bank));
  }

  function setRoundFactor(uint256 newFactor) public onlyOwner {
    factor = newFactor;
  }
  
  function AddTokens(address addrTo) public payable {
    uint256 ethCent = price.USD(0);
    uint256 usdv = ethCent.div(1000);
    usdv = usdv.mul(factor);
    
    uint256 tokens = msg.value.div(usdv);
    ethBank.transfer(msg.value);
    emit GetEth(addrTo, msg.value);
    _mint(addrTo, tokens);
  }
  
  function() external payable {
  }
}
contract IChecker {
    function update() public payable;
}


contract SuperJackPot is BaseLottery {

    IChecker public checker;

    modifier onlyChecker {
        require(msg.sender == address(checker), "");
        _;
    }

    constructor(
        address payable _rng,
        uint _period,
        address _checker
    )
        public
        BaseLottery(_rng, _period) {
            require(_checker != address(0), "");

            checker = IChecker(_checker);
    }

    function () external payable {

    }

    function processLottery() public payable onlyChecker {
        rounds[currentRound].state = RoundState.WAIT_RESULT;
        emit RoundStateChanged(currentRound, rounds[currentRound].state);
        currentRound = currentRound.add(1);
        rounds[currentRound].startRoundTime = getCurrentTime();
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
        emit RoundStateChanged(currentRound, rounds[currentRound].state);
        iRNG(rng).update.value(msg.value)(currentRound, rounds[currentRound].nonce, 0);
    }

    function startLottery(uint _startPeriod) public payable onlyLotteryContract {
        _startPeriod;
        currentRound = 1;
        uint time = getCurrentTime();
        rounds[currentRound].startRoundTime = time;
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
        emit RoundStateChanged(currentRound, rounds[currentRound].state);
        emit LotteryStarted(time);
        checker.update.value(msg.value)();
    }

    function setChecker(address _checker) public onlyOwner {
        require(_checker != address(0), "");

        checker = IChecker(_checker);
    }

    function processRound(uint _round, uint _randomNumber) public payable onlyRng returns (bool) {
        rounds[_round].random = _randomNumber;
        rounds[_round].winningTickets.push(_randomNumber.mod(rounds[_round].ticketsCount));

        address winner = getWinner(
            _round,
            0,
            (rounds[_round].tickets.length).sub(1),
            rounds[_round].winningTickets[0]
        );

        rounds[_round].winners.push(winner);
        rounds[_round].winnersFunds[winner] = rounds[_round].roundFunds;
        rounds[_round].state = RoundState.SUCCESS;

        emit RoundStateChanged(_round, rounds[_round].state);
        emit RoundProcecced(_round, rounds[_round].winners, rounds[_round].winningTickets, rounds[_round].roundFunds);

        currentRound = currentRound.add(1);
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;

        emit RoundStateChanged(_round, rounds[_round].state);
        return true;
    }

    function buyTickets(address _participant) public payable onlyLotteryContract {
        require(msg.value > 0, "");

        uint ticketsCount = msg.value.div(ticketPrice);
        addParticipant(_participant, ticketsCount);

        updateRoundFundsAndParticipants(_participant, msg.value);
    }
}