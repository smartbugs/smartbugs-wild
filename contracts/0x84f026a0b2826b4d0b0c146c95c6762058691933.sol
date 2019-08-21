pragma solidity ^0.4.24;

interface CitizenInterface {
    /*----------  READ FUNCTIONS  ----------*/
    function getUsername(address _address) public view returns (string);
    function getRef(address _address) public view returns (address);
}

interface F2mInterface {
    function pushDividends() public payable;
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

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
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
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
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

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
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

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
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

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

contract Helper {
    uint256 constant public GAS_COST = 0.002 ether;
    uint256 constant public MAX_BLOCK_DISTANCE = 254;
    uint256 constant public ZOOM = 1000000000;

    function getKeyBlockNr(uint256 _estKeyBlockNr)
        public
        view
        returns(uint256)
    {
        require(block.number > _estKeyBlockNr, "blockHash not avaiable");
        uint256 jump = (block.number - _estKeyBlockNr) / MAX_BLOCK_DISTANCE * MAX_BLOCK_DISTANCE;
        return _estKeyBlockNr + jump;
    }

    function getSeed(uint256 _keyBlockNr)
        public
        view
        returns (uint256)
    {
        // Key Block not mined atm
        if (block.number <= _keyBlockNr) return block.number;
        return uint256(blockhash(_keyBlockNr));
    }

    function getWinTeam(
        uint256 _seed,
        uint256 _trueAmount,
        uint256 _falseAmount
    )
        public
        pure
        returns (bool)
    {
        uint256 _sum = _trueAmount + _falseAmount;
        if (_sum == 0) return true;
        return (_seed % _sum) < _trueAmount;
    }

    function getWinningPerWei(
        uint256 _winTeam,
        uint256 _lostTeam
    )
        public
        pure
        returns (uint256)
    {
        return _lostTeam * ZOOM / _winTeam;
    }

    function getMin(
        uint256 a,
        uint256 b
    )
        public
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}

contract SimpleDice is Helper{
    using SafeMath for uint256;

    event Payment(address indexed _winner, uint _amount, bool _success);

    modifier onlyDevTeam() {
        require(msg.sender == devTeam, "only development team");
        _;
    }

    modifier betable() {
        uint256 _keyBlock = rounds[curRoundId].keyBlock;
        require(msg.value >= MIN_BET, "betAmount too low");
        require(block.number <= _keyBlock, "round locked");
        _;
    }

    modifier roundLocked() {
        uint256 _keyBlock = rounds[curRoundId].keyBlock;
        require(block.number > _keyBlock, "still betable");
        _;
    }

    struct Bet{
        address buyer;
        uint256 amount;
    }

    struct Round {
        mapping(bool => Bet[]) bets;
        mapping(bool => uint256) betSum;

        uint256 keyBlock;
        bool finalized;
        bool winTeam;
        uint256 cashoutFrom;
        uint256 winningPerWei; // Zoomed
    }
    
    uint256 constant public TAXED_PERCENT = 95;
    uint256 constant public BLOCK_TIME = 15;
    uint256 constant public DURATION = 300; // 5 min.
    uint256 constant public MIN_BET = 0.05 ether;
    uint256 constant public F2M_PERCENT = 10;
    uint256 constant public MAX_ROUND = 888888888;

    uint256 public MAX_CASHOUT_PER_BLOCK = 100;

    address public devTeam;
    F2mInterface public f2mContract;
    uint256 public fund;

    uint256 public curRoundId;
    mapping(uint256 => Round) public rounds;
    mapping(address => mapping(uint256 => mapping(bool => uint256))) pRoundBetSum;

    CitizenInterface public citizenContract;

    constructor(address _devTeam, address _citizen) public {
        devTeam = _devTeam;
        citizenContract = CitizenInterface(_citizen);
        initRound();
    }

    function devTeamWithdraw()
        public
        onlyDevTeam()
    {
        require(fund > 0, "nothing to withdraw");
        uint256 _toF2m = fund / 100 * F2M_PERCENT;
        uint256 _toDevTeam = fund - _toF2m;
        fund = 0;
        f2mContract.pushDividends.value(_toF2m)();
        devTeam.transfer(_toDevTeam);
    }

    function initRound()
        private
    {
        curRoundId++;
        Round memory _round;
        _round.keyBlock = MAX_ROUND; // block.number + 1 + DURATION / BLOCK_TIME;
        rounds[curRoundId] = _round;
    }

    function finalize()
        private
    {
        uint256 _keyBlock = getKeyBlockNr(rounds[curRoundId].keyBlock);
        uint256 _seed = getSeed(_keyBlock);
        bool _winTeam = _seed % 2 == 0;
        //getWinTeam(_seed, rounds[curRoundId].betSum[true], rounds[curRoundId].betSum[false]);
        rounds[curRoundId].winTeam = _winTeam;
        // winAmount Per Wei zoomed 
        rounds[curRoundId].winningPerWei = getWinningPerWei(rounds[curRoundId].betSum[_winTeam], rounds[curRoundId].betSum[!_winTeam]);
        rounds[curRoundId].finalized = true;
        fund = address(this).balance - rounds[curRoundId].betSum[_winTeam] - rounds[curRoundId].betSum[!_winTeam];
    }

    function payment(
        address _buyer,
        uint256 _winAmount
    ) 
        private
    {
        bool success = _buyer.send(_winAmount);
        emit Payment(_buyer, _winAmount, success);
    }

    function distribute()
        private
    {
        address _buyer;
        uint256 _betAmount;
        uint256 _winAmount;
        uint256 _from = rounds[curRoundId].cashoutFrom;
        bool _winTeam = rounds[curRoundId].winTeam;
        uint256 _teamBets = rounds[curRoundId].bets[_winTeam].length;
        uint256 _to = getMin(_teamBets, _from + MAX_CASHOUT_PER_BLOCK);
        uint256 _perWei = rounds[curRoundId].winningPerWei;
        
        //GAS BURNING 
        while (_from < _to) {
            _buyer = rounds[curRoundId].bets[_winTeam][_from].buyer;
            _betAmount = rounds[curRoundId].bets[_winTeam][_from].amount;
            _winAmount = _betAmount / ZOOM * _perWei + _betAmount;
            payment(_buyer, _winAmount);
            _from++;
        }
        rounds[curRoundId].cashoutFrom = _from;
    }

    function isDistributed()
        public
        view
        returns (bool)
    {
        bool _winTeam = rounds[curRoundId].winTeam;
        return (rounds[curRoundId].cashoutFrom == rounds[curRoundId].bets[_winTeam].length);
    }

    function endRound()
        public
        roundLocked()
    {
        if (!rounds[curRoundId].finalized) finalize();
        distribute();
        if (isDistributed()) initRound();
    }

    // _team = {true, false}
    function bet(
        bool _team
    )
        public
        payable
        betable()
    {
        // active timer if both Teams got player(s)
        if (rounds[curRoundId].betSum[_team] == 0 && rounds[curRoundId].betSum[!_team] > 0) 
            rounds[curRoundId].keyBlock = block.number + 1 + DURATION / BLOCK_TIME;
        address _sender = msg.sender;
        uint256 _betAmount = (msg.value).sub(GAS_COST);
        address _ref = getRef(msg.sender);
        _ref.transfer(_betAmount / 100);
        _betAmount = _betAmount / 100 * TAXED_PERCENT;
        
        Bet memory _bet = Bet(_sender, _betAmount);
        rounds[curRoundId].bets[_team].push(_bet);
        rounds[curRoundId].betSum[_team] += _betAmount;

        pRoundBetSum[_sender][curRoundId][_team] += _betAmount;
    }

    // BACKEND FUNCTION

    function distributeSetting(uint256 _limit)
        public
        onlyDevTeam()
    {
        require(_limit >= 1, "cashout at least for one each tx");
        MAX_CASHOUT_PER_BLOCK = _limit;
    }

    function setF2mContract(address _address)
        public
    {
        require(address(f2mContract) == 0x0, "already set");
        f2mContract = F2mInterface(_address);
    }

    // READING FUNCTIONS

    // if return true
    // Backend : call endRound()
    function isLocked() 
        public
        view
        returns(bool)
    {
        return rounds[curRoundId].keyBlock <= block.number;
    }

    function getRef(address _address)
        public
        view
        returns(address)
    {
        address _ref = citizenContract.getRef(_address);
        return _ref;
    }

    function getUsername(address _address)
        public
        view
        returns (string)
    {
        return citizenContract.getUsername(_address);
    }

    function getBlockDist()
        public
        view
        returns(uint256)
    {
        if (rounds[curRoundId].keyBlock == MAX_ROUND) return MAX_ROUND;
        if (rounds[curRoundId].keyBlock <= block.number) return 0;
        return rounds[curRoundId].keyBlock - block.number;

    }

    function getRoundResult(uint256 _rId)
        public
        view
        returns(
            uint256, // _trueAmount,
            uint256, // _falseAmount,
            uint256, // _trueBets
            uint256, // _falseBets
            uint256, // curBlock
            uint256, // keyBlock
            bool,
            bool // winTeam
        )
    {
        Round storage _round = rounds[_rId];
        return(
            _round.betSum[true],
            _round.betSum[false],
            _round.bets[true].length,
            _round.bets[false].length,
            block.number,
            _round.keyBlock,
            _round.finalized,
            _round.winTeam
        );
    }

    function getCurRoundResult()
        public
        view
        returns(
            uint256, // _trueAmount
            uint256, // _falseAmount
            uint256, // _trueBets
            uint256, // _falseBets
            uint256, // curBlock
            uint256, // keyBlock
            bool, // finalized
            bool // winTeam
        )
    {
        Round storage _round = rounds[curRoundId];
        return(
            _round.betSum[true],
            _round.betSum[false],
            _round.bets[true].length,
            _round.bets[false].length,
            block.number,
            _round.keyBlock,
            _round.finalized,
            _round.winTeam
        );
    }

    function getPRoundBetSum(address _player, uint256 _rId)
        public
        view
        returns(string, uint256[2])
    {
        string memory _username = getUsername(_player);
        return (_username, [pRoundBetSum[_player][_rId][true], pRoundBetSum[_player][_rId][false]]);
    }

    function getRoundBetById(uint256 _rId, bool _team, uint256 _id)
        public
        view
        returns(address, string, uint256)
    {
        address _address = rounds[_rId].bets[_team][_id].buyer;
        string memory _username = getUsername(_address);
        return (_address, _username, rounds[_rId].bets[_team][_id].amount);
    }
}