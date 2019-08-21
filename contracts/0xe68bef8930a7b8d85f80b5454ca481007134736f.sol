pragma solidity ^0.4.24;

contract Ownable {
    address public owner;
    mapping (address => bool) private distributors;

    constructor () internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrDistributor() {
        require(distributors[msg.sender] == true || msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    function setDistributor(address _distributor, bool _allowed) external onlyOwner {
        distributors[_distributor] = _allowed;
    }
}

contract Airdrop is Ownable {

    function () payable public {}

    function airdrop(address[] _to, uint256[] _values) external onlyOwnerOrDistributor {
        require(_to.length == _values.length);
        for (uint256 i = 0; i < _to.length; i++) {
            _to[i].transfer(_values[i]);
        }
    }
}