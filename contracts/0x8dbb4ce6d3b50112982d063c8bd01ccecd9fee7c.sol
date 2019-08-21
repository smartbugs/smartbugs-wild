pragma solidity ^0.5.0;


contract IOwnable {

    address public owner;
    address public newOwner;

    event OwnerChanged(address _oldOwner, address _newOwner);

    function changeOwner(address _newOwner) public;
    function acceptOwnership() public;
}

contract IVerificationList is IOwnable {

    event Accept(address _address);
    event Reject(address _address);
    event SendToCheck(address _address);
    event RemoveFromList(address _address);
    
    function isAccepted(address _address) public view returns (bool);
    function isRejected(address _address) public view returns (bool);
    function isOnCheck(address _address) public view returns (bool);
    function isInList(address _address) public view returns (bool);
    function isNotInList(address _address) public view returns (bool);
    function isAcceptedOrNotInList(address _address) public view returns (bool);
    function getState(address _address) public view returns (uint8);
    
    function accept(address _address) public;
    function reject(address _address) public;
    function toCheck(address _address) public;
    function remove(address _address) public;
}

contract Ownable is IOwnable {

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit OwnerChanged(address(0), owner);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract VerificationList is IVerificationList, Ownable {

    enum States { NOT_IN_LIST, ON_CHECK, ACCEPTED, REJECTED }

    mapping (address => States) private states;

    modifier inList(address _address) {
        require(isInList(_address));
        _;
    }

    function isAccepted(address _address) public view returns (bool) {
        return states[_address] == States.ACCEPTED;
    }

    function isRejected(address _address) public view returns (bool) {
        return states[_address] == States.REJECTED;
    }

    function isOnCheck(address _address) public view returns (bool) {
        return states[_address] == States.ON_CHECK;
    }

    function isInList(address _address) public view returns (bool) {
        return states[_address] != States.NOT_IN_LIST;
    }
    
    function isNotInList(address _address) public view returns (bool) {
        return states[_address] == States.NOT_IN_LIST;
    }

    function isAcceptedOrNotInList(address _address) public view returns (bool) {
        return states[_address] == States.NOT_IN_LIST || states[_address] == States.ACCEPTED;
    }
    
    function getState(address _address) public view returns (uint8) {
        return uint8(states[_address]);
    }

    function accept(address _address) public onlyOwner inList(_address) {
        if (isAccepted(_address)) return;
        states[_address] = States.ACCEPTED;
        emit Accept(_address);
    }

    function reject(address _address) public onlyOwner inList(_address) {
        if (isRejected(_address)) return;
        states[_address] = States.REJECTED;
        emit Reject(_address);
    }

    function toCheck(address _address) public onlyOwner {
        if (isOnCheck(_address)) return;
        states[_address] = States.ON_CHECK;
        emit SendToCheck(_address);
    }

    function remove(address _address) public onlyOwner {
        if (isNotInList(_address)) return;
        states[_address] = States.NOT_IN_LIST;
        emit RemoveFromList(_address);
    }
}