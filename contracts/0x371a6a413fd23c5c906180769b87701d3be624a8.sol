pragma solidity 0.5.4;


interface IWhitelist {
    function approved(address user) external view returns (bool);
}

contract Whitelist is IWhitelist {
    mapping(address => bool) public approved;
    mapping(address => bool) public admins;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender]);
        _;
    }

    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function addAdmin(address user) external onlyOwner {
        if (!admins[user]) {
            admins[user] = true;
        }
    }

    function removeAdmin(address user) external onlyOwner {
        if (admins[user]) {
            admins[user] = false;
        }
    }

    function add(address user) external onlyAdmin {
        if (!approved[user]) {
            approved[user] = true;
        }
    }

    function add(address[] calldata users) external onlyAdmin {
        for (uint256 i = 0; i < users.length; ++i) {
            if (!approved[users[i]]) {
                approved[users[i]] = true;
            }
        }
    }

    function remove(address user) external onlyAdmin {
        if (approved[user]) {
            approved[user] = false;
        }
    }

    function remove(address[] calldata users) external onlyAdmin {
        for (uint256 i = 0; i < users.length; ++i) {
            if (approved[users[i]]) {
                approved[users[i]] = false;
            }
        }
    }

    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0));

        emit OwnershipTransferred(owner, _owner);

        owner = _owner;
    }
}