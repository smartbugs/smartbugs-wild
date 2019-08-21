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

contract Name {
    using SafeMath256 for uint256;

    uint8 constant MIN_NAME_LENGTH = 2;
    uint8 constant MAX_NAME_LENGTH = 32;

    function _convertName(string _input) internal pure returns(bytes32 _initial, bytes32 _lowercase) {
        bytes memory _initialBytes = bytes(_input);
        assembly {
            _initial := mload(add(_initialBytes, 32))
        }
        _lowercase = _toLowercase(_input);
    }


    function _toLowercase(string _input) internal pure returns(bytes32 result) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length >= 2, "string must be between 2 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length.sub(1)] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i = i.add(1))
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint256(_temp[i]).add(32));

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 ||
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require(_temp[i.add(1)] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        assembly {
            result := mload(add(_temp, 32))
        }
    }
}




//////////////CONTRACT//////////////





contract User is Upgradable, Name {
    mapping (bytes32 => bool) public existingNames;
    mapping (address => bytes32) public names;

    function getName(address _user) external view returns (bytes32) {
        return names[_user];
    }

    function setName(
        address _user,
        string _name
    ) external onlyController returns (bytes32) {
        (
            bytes32 _initial, // initial name that converted to bytes32
            bytes32 _lowercase // name to lowercase
        ) = _convertName(_name);
        require(!existingNames[_lowercase], "this username already exists");
        require(names[_user] == 0x0, "username is already set");
        names[_user] = _initial;
        existingNames[_lowercase] = true;

        return _initial;
    }
}