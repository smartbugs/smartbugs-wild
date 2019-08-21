pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
}

/**
 * @title Secret Note
 */
contract SecretNote is Ownable {
    struct UserInfo {
        mapping(bytes32 => bytes32) notes;
        bytes32[] noteKeys;
        uint256 index; // 1-based
    }

    mapping(address => UserInfo) private registerUsers;
    address[] private userIndex;

    event SecretNoteUpdated(address indexed _sender, bytes32 indexed _noteKey, bool _success);

    function SecretNote() public {
    }

    function userExisted(address _user) public constant returns (bool) {
        if (userIndex.length == 0) {
            return false;
        }

        return (userIndex[registerUsers[_user].index - 1] == _user);
    }

    function () public payable {
    }

    /**
     * @dev for owner to withdraw ETH from donators if there is any.  :)
     * @param _to The address where withdraw to
     * @param _amount The amount of ETH to withdraw
     */
    function withdraw(address _to, uint _amount) public onlyOwner {
        _to.transfer(_amount);
    }

    /**
     * @dev For owner to check registered user count
     */
    function getUserCount() public view onlyOwner returns (uint256) {
        return userIndex.length;
    }

    /**
     * @dev For owner to check registered user address based on index
     * @param _index Starting from 1
     */
    function getUserAddress(uint256 _index) public view onlyOwner returns (address) {
        require(_index > 0);
        return userIndex[_index - 1];
    }

    /**
     * @dev For user to get their own secret note
     * @param _noteKey The key identifier for particular note
     */
    function getNote(bytes32 _noteKey) public view returns (bytes32) {
        return registerUsers[msg.sender].notes[_noteKey];
    }

    /**
     * @dev For user to get their own secret note keys count
     */
    function getNoteKeysCount() public view returns (uint256) {
        return registerUsers[msg.sender].noteKeys.length;
    }

    /**
     * @dev For user to get their own secret note key by index
     * @param _index The 0-based index for particular note
     */
    function getNoteKeyByIndex(uint256 _index) public view returns (bytes32) {
        return registerUsers[msg.sender].noteKeys[_index];
    }

    /**
     * @dev For user to update their own secret note
     * @param _noteKey The key identifier for particular note
     * @param _content The note path hash
     */
    function setNote(bytes32 _noteKey, bytes32 _content) public payable {
        require(_noteKey != "");
        require(_content != "");

        var userAddr = msg.sender;
        var user = registerUsers[userAddr];
        if (user.notes[_noteKey] == "") {
            user.noteKeys.push(_noteKey);
        }
        user.notes[_noteKey] = _content;

        if (user.index == 0) {
            userIndex.push(userAddr);
            user.index = userIndex.length;
        }
        SecretNoteUpdated(userAddr, _noteKey, true);
    }

    /**
     * @dev Destroy one's account
     */
    function destroyAccount() public returns (bool) {
        var userAddr = msg.sender;
        require(userExisted(userAddr));

        uint delIndex = registerUsers[userAddr].index;
        address userToMove = userIndex[userIndex.length - 1];

        if (userToMove == userAddr) {
            delete(registerUsers[userAddr]);
            userIndex.length = 0;
            return true;
        }

        userIndex[delIndex - 1] = userToMove;
        registerUsers[userToMove].index = delIndex;
        userIndex.length--;
        delete(registerUsers[userAddr]);
        return true;
    }
}