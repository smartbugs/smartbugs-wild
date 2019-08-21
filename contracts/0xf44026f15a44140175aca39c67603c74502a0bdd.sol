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




//////////////CONTRACT//////////////




contract UpgradeController is Ownable {
    function migrate(address _oldAddress, address _newAddress) external onlyOwner {
        require(_oldAddress != _newAddress, "addresses are equal");
        Upgradable _oldContract = Upgradable(_oldAddress);
        Upgradable _newContract = Upgradable(_newAddress);
        Upgradable _externalDependency;
        Upgradable _internalDependency;
        address[] memory _externalDependenciesOfInternal;
        address[] memory _internalDependenciesOfExternal;
        address[] memory _externalDependencies = _oldContract.getExternalDependencies();
        address[] memory _internalDependencies = _oldContract.getInternalDependencies();
        require(
            _externalDependencies.length > 0 ||
            _internalDependencies.length > 0,
            "no dependencies"
        );
        uint256 i;
        uint256 j;

        for (i = 0; i < _externalDependencies.length; i++) {
            _externalDependency = Upgradable(_externalDependencies[i]);
            _internalDependenciesOfExternal = _externalDependency.getInternalDependencies();

            for (j = 0; j < _internalDependenciesOfExternal.length; j++) {
                if (_internalDependenciesOfExternal[j] == _oldAddress) {
                    _internalDependenciesOfExternal[j] = _newAddress;
                    break;
                }
            }

            _externalDependency.setInternalDependencies(_internalDependenciesOfExternal);
        }

        for (i = 0; i < _internalDependencies.length; i++) {
            _internalDependency = Upgradable(_internalDependencies[i]);
            _externalDependenciesOfInternal = _internalDependency.getExternalDependencies();

            for (j = 0; j < _externalDependenciesOfInternal.length; j++) {
                if (_externalDependenciesOfInternal[j] == _oldAddress) {
                    _externalDependenciesOfInternal[j] = _newAddress;
                    break;
                }
            }

            _internalDependency.setExternalDependencies(_externalDependenciesOfInternal);
        }

        _newContract.setInternalDependencies(_internalDependencies);
        _newContract.setExternalDependencies(_externalDependencies);

        // Return old contract ownership to original owner for
        // cases when we want to transfer some data manually
        returnOwnership(_oldAddress);
    }

    // Return ownership to original owner. That's important for cases when
    // the new contract have an additional dependency that couldn't be
    // transferred from the old contract. After that original owner
    // have to transfer ownership to this contract again.
    function returnOwnership(address _address) public onlyOwner {
        Upgradable(_address).transferOwnership(owner);
    }

    function pause(address _address) external onlyOwner {
        Pausable(_address).pause();
    }

    function unpause(address _address) external onlyOwner {
        Pausable(_address).unpause();
    }
}