pragma solidity 0.4.25;

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





contract DragonParams is Upgradable {

    // 0 - attack, 1 - defense, 2 - stamina, 3 - speed, 4 - intelligence
    // typesFactors and geneTypesFactors are stored as value * 10
    uint8[5][11] _dragonTypesFactors_;
    uint8[5][10] _bodyPartsFactors_;
    uint8[5][10] _geneTypesFactors_;
    uint8[10] _experienceToNextLevel_;
    uint16[11] _dnaPoints_;
    uint8 _battlePoints_;
    uint8[99] _geneUpgradeDNAPoints_; // 99 levels

    // GETTERS BY INDEX

    function dragonTypesFactors(uint8 _index) external view returns (uint8[5]) {
        return _dragonTypesFactors_[_index];
    }

    function bodyPartsFactors(uint8 _index) external view returns (uint8[5]) {
        return _bodyPartsFactors_[_index];
    }

    function geneTypesFactors(uint8 _index) external view returns (uint8[5]) {
        return _geneTypesFactors_[_index];
    }

    function experienceToNextLevel(uint8 _index) external view returns (uint8) {
        return _experienceToNextLevel_[_index];
    }

    function dnaPoints(uint8 _index) external view returns (uint16) {
        return _dnaPoints_[_index];
    }

    function geneUpgradeDNAPoints(uint8 _index) external view returns (uint8) {
        return _geneUpgradeDNAPoints_[_index];
    }

    // GETTERS

    function getDragonTypesFactors() external view returns (uint8[55] result) {
        uint8 _index;
        for (uint8 i = 0; i < 11; i++) {
            for (uint8 j = 0; j < 5; j++) {
                result[_index] = _dragonTypesFactors_[i][j];
                _index++;
            }
        }
    }

    function _transformArray(uint8[5][10] _array) internal pure returns (uint8[50] result) {
        uint8 _index;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 5; j++) {
                result[_index] = _array[i][j];
                _index++;
            }
        }
    }

    function getBodyPartsFactors() external view returns (uint8[50]) {
        return _transformArray(_bodyPartsFactors_);
    }

    function getGeneTypesFactors() external view returns (uint8[50]) {
        return _transformArray(_geneTypesFactors_);
    }

    function getExperienceToNextLevel() external view returns (uint8[10]) {
        return _experienceToNextLevel_;
    }

    function getDNAPoints() external view returns (uint16[11]) {
        return _dnaPoints_;
    }

    function battlePoints() external view returns (uint8) {
        return _battlePoints_;
    }

    function getGeneUpgradeDNAPoints() external view returns (uint8[99]) {
        return _geneUpgradeDNAPoints_;
    }

    // SETTERS

    function setDragonTypesFactors(uint8[5][11] _types) external onlyOwner {
        _dragonTypesFactors_ = _types;
    }

    function setBodyPartsFactors(uint8[5][10] _bodyParts) external onlyOwner {
        _bodyPartsFactors_ = _bodyParts;
    }

    function setGeneTypesFactors(uint8[5][10] _geneTypes) external onlyOwner {
        _geneTypesFactors_ = _geneTypes;
    }

    function setLevelUpPoints(
        uint8[10] _experienceToNextLevel,
        uint16[11] _dnaPoints,
        uint8 _battlePoints
    ) external onlyOwner {
        _experienceToNextLevel_ = _experienceToNextLevel;
        _dnaPoints_ = _dnaPoints;
        _battlePoints_ = _battlePoints;
    }

    function setGeneUpgradeDNAPoints(uint8[99] _points) external onlyOwner {
        _geneUpgradeDNAPoints_ = _points;
    }
}