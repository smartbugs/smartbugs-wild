pragma solidity ^0.5.3;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Approvable is Ownable {
    mapping(address => bool) private _approvedAddress;


    modifier onlyApproved() {
        require(isApproved());
        _;
    }

    function isApproved() public view returns(bool) {
        return _approvedAddress[msg.sender] || isOwner();
    }

    function approveAddress(address _address) public onlyOwner {
        _approvedAddress[_address] = true;
    }

    function revokeApproval(address _address) public onlyOwner {
        _approvedAddress[_address] = false;
    }
}

contract StoringCreationMeta {
    uint public creationBlock;
    uint public creationTime;

    constructor() internal {
        creationBlock = block.number;
        creationTime = block.timestamp;
    }
}

contract UserRoles is StoringCreationMeta, Approvable {
    struct Roles {
        uint[] list;
        mapping(uint => uint) position;
    }
    mapping(address => Roles) userRoles;

    event RolesChanged(address indexed user, uint[] roles);
    // Known roles:
    // 1    - can create events

    function setRole(address _user, uint _role) public onlyApproved {
        _setRole(userRoles[_user], _role);
        emit RolesChanged(_user, userRoles[_user].list);
    }

    function setRoles(address _user, uint[] memory _roles) public onlyApproved {
        for(uint i = 0; i < _roles.length; ++i) {
            _setRole(userRoles[_user], _roles[i]);
        }
        emit RolesChanged(_user, userRoles[_user].list);
    }

    function setRoleForUsers(address[] memory _users, uint _role) public onlyApproved {
        for(uint i = 0; i < _users.length; ++i) {
            _setRole(userRoles[_users[i]], _role);
            emit RolesChanged(_users[i], userRoles[_users[i]].list);
        }
    }

    function _setRole(Roles storage _roles, uint _role) private {
        if (_roles.position[_role] != 0) {
            // Already has role
            return;
        } else {
            _roles.list.push(_role);
            _roles.position[_role] = _roles.list.length;
        }
    }

    function removeRole(address _user, uint _role) public onlyApproved {
        _removeRole(userRoles[_user], _role);
        emit RolesChanged(_user, userRoles[_user].list);
    }

    function removeRoles(address _user, uint[] memory _roles) public onlyApproved {
        for(uint i = 0; i < _roles.length; ++i) {
            _removeRole(userRoles[_user], _roles[i]);
        }
        emit RolesChanged(_user, userRoles[_user].list);
    }

    function _removeRole(Roles storage _roles, uint _role) private {
        if (_roles.position[_role] == 0) {
            // Role not present
            return;
        }

        uint nIndex = _roles.position[_role] - 1;
        uint lastIndex = _roles.list.length  - 1;
        uint lastItem = _roles.list[lastIndex];

        _roles.list[nIndex] = lastItem;
        _roles.position[lastItem] = nIndex + 1;
        _roles.position[_role] = 0;

        _roles.list.pop();
    }

    function hasRole(address _user, uint _role) public view returns(bool) {
        return userRoles[_user].position[_role] != 0;
    }

    function hasAnyRole(address _user, uint[] memory _roles) public view returns(bool) {
        for(uint i = 0; i < _roles.length; ++i) {
            if(hasRole(_user, _roles[i])) {
                return true;
            }
        }
        return false;
    }

    function getUserRoles(address _user) public view returns(uint[] memory) {
        return userRoles[_user].list;
    }

    function clearUserRoles(address _user) public onlyApproved {
        Roles storage _roles = userRoles[_user];

        for(uint i = 0; i < _roles.list.length; ++i) {
            _roles.position[_roles.list[i]] = 0;
        }

        delete _roles.list;
    }
}