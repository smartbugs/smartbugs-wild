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




//////////////CONTRACT//////////////




contract DragonLeaderboard is Upgradable {
    using SafeMath256 for uint256;

    struct Leaderboard {
        uint256 id;
        uint32 coolness;
    }

    Leaderboard[10] leaderboard;

    uint8[10] rewardCoefficients = [50, 45, 40, 35, 30, 25, 20, 15, 10, 5]; // multiplied by 10
    uint8 constant COEFFS_MULTIPLIER = 10;
    uint256 rewardPeriod = 24 hours;
    uint256 lastRewardDate;

    constructor() public {
        lastRewardDate = now;
    }

    function update(uint256 _id, uint32 _coolness) external onlyController {
        uint256 _index;
        bool _isIndex;
        uint256 _existingIndex;
        bool _isExistingIndex;

        // if coolness is more than coolness of the last dragon
        if (_coolness > leaderboard[leaderboard.length.sub(1)].coolness) {

            for (uint256 i = 0; i < leaderboard.length; i = i.add(1)) {
                // if a place for a dragon is found
                if (_coolness > leaderboard[i].coolness && !_isIndex) {
                    _index = i;
                    _isIndex = true;
                }
                // if dragon is already in leaderboard
                if (leaderboard[i].id == _id && !_isExistingIndex) {
                    _existingIndex = i;
                    _isExistingIndex = true;
                }
                if(_isIndex && _isExistingIndex) break;
            }
            // if dragon stayed at the same place
            if (_isExistingIndex && _index >= _existingIndex) {
                leaderboard[_existingIndex] = Leaderboard(_id, _coolness);
            } else if (_isIndex) {
                _add(_index, _existingIndex, _isExistingIndex, _id, _coolness);
            }
        }
    }

    function _add(
        uint256 _index,
        uint256 _existingIndex,
        bool _isExistingIndex,
        uint256 _id,
        uint32 _coolness
    ) internal {
        uint256 _length = leaderboard.length;
        uint256 _indexTo = _isExistingIndex ? _existingIndex : _length.sub(1);

        // shift other dragons
        for (uint256 i = _indexTo; i > _index; i = i.sub(1)){
            leaderboard[i] = leaderboard[i.sub(1)];
        }

        leaderboard[_index] = Leaderboard(_id, _coolness);
    }

    function getDragonsFromLeaderboard() external view returns (uint256[10] result) {
        for (uint256 i = 0; i < leaderboard.length; i = i.add(1)) {
            result[i] = leaderboard[i].id;
        }
    }

    function updateRewardTime() external onlyController {
        require(lastRewardDate.add(rewardPeriod) < now, "too early");
        lastRewardDate = now;
    }

    function getRewards(uint256 _hatchingPrice) external view returns (uint256[10] rewards) {
        for (uint8 i = 0; i < 10; i++) {
            rewards[i] = _hatchingPrice.mul(rewardCoefficients[i]).div(COEFFS_MULTIPLIER);
        }
    }

    function getDate() external view returns (uint256, uint256) {
        return (lastRewardDate, rewardPeriod);
    }
}