pragma solidity ^0.4.17;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies
/// and the implementation of "user permissions".
contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender
    /// account.
    function Ownable() public {
        owner = msg.sender;
    }

    /// @dev Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }

        _;
    }

    modifier onlyOwnerCandidate() {
        if (msg.sender != newOwnerCandidate) {
            revert();
        }

        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));

        newOwnerCandidate = _newOwnerCandidate;

        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the previously proposed owner.
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }
}

/// @title EtherWin
/// @dev the contract than handles the EtherWin app
contract EtherDick is Ownable {

    event NewBiggestDick(string name, string notes, uint256 size);

    struct BiggestDick {
        string name;
        string notes;
        uint256 size;
        uint256 timestamp;
        address who;
    }

    BiggestDick[] private biggestDicks;

    function EtherDick() public {
        biggestDicks.push(BiggestDick({
            name:       'Brian',
            notes:      'First dick',
            size:      9,
            timestamp:  block.timestamp,
            who:        address(0)
            }));
    }

    /// Makes you have the bigger dick
    function iHaveABiggerDick(string name, string notes) external payable {

        uint nameLen = bytes(name).length;
        uint notesLen = bytes(notes).length;

        require(msg.sender != address(0));
        require(nameLen > 2);
        require(nameLen <= 64);
        require(notesLen <= 140);
        require(msg.value > biggestDicks[biggestDicks.length - 1].size);

        BiggestDick memory bd = BiggestDick({
            name:       name,
            notes:      notes,
            size:       msg.value,
            timestamp:  block.timestamp,
            who:        msg.sender
        });

        biggestDicks.push(bd);

        NewBiggestDick(name, notes, msg.value);
    }

    // returns how many dicks there have been
    function howManyDicks() external view
            returns (uint) {

        return biggestDicks.length;
    }

    // returns who has the biggest dick
    function whoHasTheBiggestDick() external view
            returns (string name, string notes, uint256 size, uint256 timestamp, address who) {

        BiggestDick storage bd = biggestDicks[biggestDicks.length - 1];
        return (bd.name, bd.notes, bd.size, bd.timestamp, bd.who);
    }

    // returns the biggest dick at the given index
    function whoHadTheBiggestDick(uint position) external view
            returns (string name, string notes, uint256 size, uint256 timestamp, address who) {

        BiggestDick storage bd = biggestDicks[position];
        return (bd.name, bd.notes, bd.size, bd.timestamp, bd.who);
    }

    // fail safe for balance transfer
    function transferBalance(address to, uint256 amount) external onlyOwner {
        to.transfer(amount);
    }

}