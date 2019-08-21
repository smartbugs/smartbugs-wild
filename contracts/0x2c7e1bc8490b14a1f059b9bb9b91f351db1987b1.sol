pragma solidity 0.5.2;

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "");
        owner = newOwner;
    }

}

contract Manageable is Ownable {
    mapping(address => bool) public listOfManagers;

    modifier onlyManager() {
        require(listOfManagers[msg.sender], "");
        _;
    }

    function addManager(address _manager) public onlyOwner returns (bool success) {
        if (!listOfManagers[_manager]) {
            require(_manager != address(0), "");
            listOfManagers[_manager] = true;
            success = true;
        }
    }

    function removeManager(address _manager) public onlyOwner returns (bool success) {
        if (listOfManagers[_manager]) {
            listOfManagers[_manager] = false;
            success = true;
        }
    }

    function getInfo(address _manager) public view returns (bool) {
        return listOfManagers[_manager];
    }
}

contract KYCWhitelist is Manageable {
    mapping(address => bool) public whitelist;

    event AddressIsAdded(address participant);
    event AddressIsRemoved(address participant);

    function addParticipant(address _participant) public onlyManager {
        require(_participant != address(0), "");

        whitelist[_participant] = true;
        emit AddressIsAdded(_participant);
    }

    function removeParticipant(address _participant) public onlyManager {
        require(_participant != address(0), "");

        whitelist[_participant] = false;
        emit AddressIsRemoved(_participant);
    }

    function isWhitelisted(address _participant) public view returns (bool) {
        return whitelist[_participant];
    }
}