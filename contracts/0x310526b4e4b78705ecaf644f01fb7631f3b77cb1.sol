pragma solidity 0.4.25;

library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint256 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not a contract owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _validateAddress(newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "contract is not paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract Controllable is Ownable {
    mapping(address => bool) controllers;

    modifier onlyController {
        require(_isController(msg.sender), "no controller rights");
        _;
    }

    function _isController(address _controller) internal view returns (bool) {
        return controllers[_controller];
    }

    function _setControllers(address[] _controllers) internal {
        for (uint256 i = 0; i < _controllers.length; i++) {
            _validateAddress(_controllers[i]);
            controllers[_controllers[i]] = true;
        }
    }
}

contract Upgradable is Controllable {
    address[] internalDependencies;
    address[] externalDependencies;

    function getInternalDependencies() public view returns(address[]) {
        return internalDependencies;
    }

    function getExternalDependencies() public view returns(address[]) {
        return externalDependencies;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        for (uint256 i = 0; i < _newDependencies.length; i++) {
            _validateAddress(_newDependencies[i]);
        }
        internalDependencies = _newDependencies;
    }

    function setExternalDependencies(address[] _newDependencies) public onlyOwner {
        externalDependencies = _newDependencies;
        _setControllers(_newDependencies);
    }
}

contract Gold {
    function remoteTransfer(address _to, uint256 _value) external;
}

contract GladiatorBattleStorage {
    function challengesAmount() external view returns (uint256);
    function battleOccurred(uint256) external view returns (bool);
    function challenges(uint256) external view returns (bool, uint256, uint256);
    function battleBlockNumber(uint256) external view returns (uint256);
    function creator(uint256) external view returns (address, uint256);
    function opponent(uint256) external view returns (address, uint256);
    function winner(uint256) external view returns (address, uint256);
}

contract GladiatorBattleSpectatorsStorage {
    function challengeBetsValue(uint256, bool) external view returns (uint256);
    function challengeBalance(uint256) external view returns (uint256);
    function challengeBetsAmount(uint256, bool) external view returns (uint256);
    function betsAmount() external view returns (uint256);
    function allBets(uint256) external view returns (address, uint256, bool, uint256, bool);
    function payOut(address, bool, uint256) external;
    function setChallengeBalance(uint256, uint256) external;
    function setChallengeBetsAmount(uint256, bool, uint256) external;
    function setChallengeBetsValue(uint256, bool, uint256) external;
    function addBet(address, uint256, bool, uint256) external returns (uint256);
    function deactivateBet(uint256) external;
    function addChallengeBet(uint256, uint256) external;
    function removeChallengeBet(uint256, uint256) external;
    function addUserChallenge(address, uint256, uint256) external;
    function removeUserChallenge(address, uint256) external;
    function userChallengeBetId(address, uint256) external view returns (uint256);
    function challengeWinningBetsAmount(uint256) external view returns (uint256);
    function setChallengeWinningBetsAmount(uint256, uint256) external;
    function getUserBet(address, uint256) external view returns (uint256, bool, uint256, bool);
}

contract GladiatorBattleSpectators is Upgradable {
    using SafeMath256 for uint256;

    Gold goldTokens;
    GladiatorBattleSpectatorsStorage _storage_;
    GladiatorBattleStorage battleStorage;

    uint256 constant MULTIPLIER = 10**6; // for more accurate calculations

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return b > a ? 0 : a.sub(b);
    }

    function _validateChallengeId(uint256 _challengeId) internal view {
        require(
            _challengeId > 0 &&
            _challengeId < battleStorage.challengesAmount(),
            "wrong challenge id"
        );
    }

    function _validateBetId(uint256 _betId) internal view {
        require(
            _betId > 0 &&
            _betId < _storage_.betsAmount(),
            "wrong bet id"
        );
        ( , , , , bool _active) = _storage_.allBets(_betId);
        require(_active, "the bet is not active");
    }

    function _getChallengeCurrency(
        uint256 _challengeId
    ) internal view returns (bool isGold) {
        (isGold, , ) = battleStorage.challenges(_challengeId);
    }

    function _getChallengeBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (uint256) {
        return _storage_.challengeBetsAmount(_challengeId, _willCreatorWin);
    }

    function _getChallengeBetsValue(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (uint256) {
        return _storage_.challengeBetsValue(_challengeId, _willCreatorWin);
    }

    function _getChallengeBalance(
        uint256 _challengeId
    ) internal view returns (uint256) {
        return _storage_.challengeBalance(_challengeId);
    }

    function _setChallengeBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        _storage_.setChallengeBetsAmount(_challengeId, _willCreatorWin, _value);
    }

    function _setChallengeBetsValue(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        _storage_.setChallengeBetsValue(_challengeId, _willCreatorWin, _value);
    }

    function _setChallengeBalance(
        uint256 _challengeId,
        uint256 _value
    ) internal {
        _storage_.setChallengeBalance(_challengeId, _value);
    }

    function _updateBetsValues(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value,
        bool _increase // or decrease
    ) internal {
        uint256 _betsAmount = _getChallengeBetsAmount(_challengeId, _willCreatorWin);
        uint256 _betsValue = _getChallengeBetsValue(_challengeId, _willCreatorWin);
        uint256 _betsTotalValue = _getChallengeBalance(_challengeId);

        if (_increase) {
            _betsAmount = _betsAmount.add(1);
            _betsValue = _betsValue.add(_value);
            _betsTotalValue = _betsTotalValue.add(_value);
        } else {
            _betsAmount = _betsAmount.sub(1);
            _betsValue = _betsValue.sub(_value);
            _betsTotalValue = _betsTotalValue.sub(_value);
        }

        _setChallengeBetsAmount(_challengeId, _willCreatorWin, _betsAmount);
        _setChallengeBetsValue(_challengeId, _willCreatorWin, _betsValue);
        _setChallengeBalance(_challengeId, _betsTotalValue);
    }

    function _checkThatOpponentIsSelected(
        uint256 _challengeId
    ) internal view returns (bool) {
        ( , uint256 _dragonId) = battleStorage.opponent(_challengeId);
        require(_dragonId != 0, "the opponent is not selected");
    }

    function _hasBattleOccurred(uint256 _challengeId) internal view returns (bool) {
        return battleStorage.battleOccurred(_challengeId);
    }

    function _checkThatBattleHasNotOccurred(
        uint256 _challengeId
    ) internal view {
        require(!_hasBattleOccurred(_challengeId), "the battle has already occurred");
    }

    function _checkThatBattleHasOccurred(
        uint256 _challengeId
    ) internal view {
        require(_hasBattleOccurred(_challengeId), "the battle has not yet occurred");
    }

    function _checkThatWeDoNotKnowTheResult(
        uint256 _challengeId
    ) internal view {
        uint256 _blockNumber = battleStorage.battleBlockNumber(_challengeId);
        require(
            _blockNumber > block.number || _blockNumber < _safeSub(block.number, 256),
            "we already know the result"
        );
    }

    function _isWinningBet(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (bool) {
        (address _winner, ) = battleStorage.winner(_challengeId);
        (address _creator, ) = battleStorage.creator(_challengeId);
        bool _isCreatorWinner = _winner == _creator;
        return _isCreatorWinner == _willCreatorWin;
    }

    function _checkWinner(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view {
        require(_isWinningBet(_challengeId, _willCreatorWin), "you did not win the bet");
    }

    function _checkThatBetIsActive(bool _active) internal pure {
        require(_active, "bet is not active");
    }

    function _payForBet(
        uint256 _value,
        bool _isGold,
        uint256 _bet
    ) internal {
        if (_isGold) {
            require(_value == 0, "specify isGold as false to send eth");
            goldTokens.remoteTransfer(address(_storage_), _bet);
        } else {
            require(_value == _bet, "wrong eth amount");
            address(_storage_).transfer(_value);
        }
    }

    function() external payable {}

    function _create(
        address _user,
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        uint256 _betId = _storage_.addBet(_user, _challengeId, _willCreatorWin, _value);
        _storage_.addChallengeBet(_challengeId, _betId);
        _storage_.addUserChallenge(_user, _challengeId, _betId);
    }

    function placeBet(
        address _user,
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value,
        uint256 _ethValue
    ) external onlyController returns (bool isGold) {
        _validateChallengeId(_challengeId);
        _checkThatOpponentIsSelected(_challengeId);
        _checkThatBattleHasNotOccurred(_challengeId);
        _checkThatWeDoNotKnowTheResult(_challengeId);
        require(_value > 0, "a bet must be more than 0");

        isGold = _getChallengeCurrency(_challengeId);
        _payForBet(_ethValue, isGold, _value);

        uint256 _existingBetId = _storage_.userChallengeBetId(_user, _challengeId);
        require(_existingBetId == 0, "you have already placed a bet");

        _create(_user, _challengeId, _willCreatorWin, _value);

        _updateBetsValues(_challengeId, _willCreatorWin, _value, true);
    }

    function _remove(
        address _user,
        uint256 _challengeId,
        uint256 _betId
    ) internal {
        _storage_.deactivateBet(_betId);
        _storage_.removeChallengeBet(_challengeId, _betId);
        _storage_.removeUserChallenge(_user, _challengeId);
    }

    function removeBet(
        address _user,
        uint256 _challengeId
    ) external onlyController {
        _validateChallengeId(_challengeId);

        uint256 _betId = _storage_.userChallengeBetId(_user, _challengeId);
        (
            address _realUser,
            uint256 _realChallengeId,
            bool _willCreatorWin,
            uint256 _value,
            bool _active
        ) = _storage_.allBets(_betId);

        require(_realUser == _user, "not your bet");
        require(_realChallengeId == _challengeId, "wrong challenge");
        _checkThatBetIsActive(_active);

        if (_hasBattleOccurred(_challengeId)) {
            require(!_isWinningBet(_challengeId, _willCreatorWin), "request a reward instead");
            uint256 _opponentBetsAmount = _getChallengeBetsAmount(_challengeId, !_willCreatorWin);
            require(_opponentBetsAmount == 0, "your bet lost");
        } else {
            _checkThatWeDoNotKnowTheResult(_challengeId);
        }

        _remove(_user, _challengeId, _betId);

        bool _isGold = _getChallengeCurrency(_challengeId);
        _storage_.payOut(_user, _isGold, _value);

        _updateBetsValues(_challengeId, _willCreatorWin, _value, false);
    }

    function _updateWinningBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal returns (bool) {
        uint256 _betsAmount = _getChallengeBetsAmount(_challengeId, _willCreatorWin);
        uint256 _existingWinningBetsAmount = _storage_.challengeWinningBetsAmount(_challengeId);
        uint256 _winningBetsAmount = _existingWinningBetsAmount == 0 ? _betsAmount : _existingWinningBetsAmount;
        _winningBetsAmount = _winningBetsAmount.sub(1);
        _storage_.setChallengeWinningBetsAmount(_challengeId, _winningBetsAmount);
        return _winningBetsAmount == 0;
    }

    function requestReward(
        address _user,
        uint256 _challengeId
    ) external onlyController returns (uint256 reward, bool isGold) {
        _validateChallengeId(_challengeId);
        _checkThatBattleHasOccurred(_challengeId);
        (
            uint256 _betId,
            bool _willCreatorWin,
            uint256 _value,
            bool _active
        ) = _storage_.getUserBet(_user, _challengeId);
        _checkThatBetIsActive(_active);

        _checkWinner(_challengeId, _willCreatorWin);

        bool _isLast = _updateWinningBetsAmount(_challengeId, _willCreatorWin);

        uint256 _betsValue = _getChallengeBetsValue(_challengeId, _willCreatorWin);
        uint256 _opponentBetsValue = _getChallengeBetsValue(_challengeId, !_willCreatorWin);

        uint256 _percentage = _value.mul(MULTIPLIER).div(_betsValue);
        reward = _opponentBetsValue.mul(85).div(100).mul(_percentage).div(MULTIPLIER); // 15% to winner in the battle
        reward = reward.add(_value);

        uint256 _challengeBalance = _getChallengeBalance(_challengeId);
        require(_challengeBalance >= reward, "not enough coins, something went wrong");

        reward = _isLast ? _challengeBalance : reward; // get rid of inaccuracies of calculations

        isGold = _getChallengeCurrency(_challengeId);
        _storage_.payOut(_user, isGold, reward);

        _setChallengeBalance(_challengeId, _challengeBalance.sub(reward));
        _storage_.deactivateBet(_betId);
    }


    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        goldTokens = Gold(_newDependencies[0]);
        _storage_ = GladiatorBattleSpectatorsStorage(_newDependencies[1]);
        battleStorage = GladiatorBattleStorage(_newDependencies[2]);
    }
}