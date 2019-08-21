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

contract ERC721Token {
    function ownerOf(uint256) public view returns (address);
    function exists(uint256) public view returns (bool);
    function getAllTokens() external view returns (uint256[]);
    function totalSupply() public view returns (uint256);

}

contract EggStorage is ERC721Token {
    function push(address, uint256[2], uint8) public returns (uint256);
    function get(uint256) external view returns (uint256[2], uint8);
    function remove(address, uint256) external;
}




//////////////CONTRACT//////////////




contract EggCore is Upgradable {
    EggStorage _storage_;

    function getAmount() external view returns (uint256) {
        return _storage_.totalSupply();
    }

    function getAllEggs() external view returns (uint256[]) {
        return _storage_.getAllTokens();
    }

    function isOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return _user == _storage_.ownerOf(_tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _storage_.ownerOf(_tokenId);
    }

    function create(
        address _sender,
        uint256[2] _parents,
        uint8 _dragonType
    ) external onlyController returns (uint256) {
        return _storage_.push(_sender, _parents, _dragonType);
    }

    function remove(address _owner, uint256 _id) external onlyController {
        _storage_.remove(_owner, _id);
    }

    function get(uint256 _id) external view returns (uint256[2], uint8) {
        require(_storage_.exists(_id), "egg doesn't exist");
        return _storage_.get(_id);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _storage_ = EggStorage(_newDependencies[0]);
    }
}