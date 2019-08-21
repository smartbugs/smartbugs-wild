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




contract SkillMarketplace is Upgradable {
    using SafeMath256 for uint256;

    mapping (uint256 => uint256) allTokensIndex;
    mapping (uint256 => uint256) tokenToPrice;

    uint256[] allTokens;

    function _checkTokenExistence(uint256 _id) internal view {
        require(tokenToPrice[_id] > 0, "skill is not on sale");
    }

    function sellToken(
        uint256 _tokenId,
        uint256 _price
    ) external onlyController {
        require(_price > 0, "price must be more than 0");

        if (tokenToPrice[_tokenId] == 0) {
            allTokensIndex[_tokenId] = allTokens.length;
            allTokens.push(_tokenId);
        }
        tokenToPrice[_tokenId] = _price;
    }

    function removeFromAuction(uint256 _tokenId) external onlyController {
        _checkTokenExistence(_tokenId);
        _remove(_tokenId);
    }

    function _remove(uint256 _tokenId) internal {
        require(allTokens.length > 0, "no auctions");

        delete tokenToPrice[_tokenId];

        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];

        allTokens[tokenIndex] = lastToken;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        allTokensIndex[_tokenId] = 0;
        allTokensIndex[lastToken] = tokenIndex;
    }

    // GETTERS

    function getAuction(uint256 _id) external view returns (uint256) {
        _checkTokenExistence(_id);
        return tokenToPrice[_id];
    }

    function getAllTokens() external view returns (uint256[]) {
        return allTokens;
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }
}