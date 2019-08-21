pragma solidity ^0.4.24;

/**
 * @title Owned
 * @dev Basic contract to define an owner.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /**
     * @dev Throws if the sender is not the owner.
     */
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Lets the owner transfer ownership of the contract to a new owner.
     * @param _newOwner The new owner.
     */
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

/**
 * @title DappRegistry
 * @dev Registry of dapp contracts and methods that have been authorised by Argent. 
 * Registered methods can be authorised immediately for a dapp key and a wallet while 
 * the authoirsation of unregistered methods is delayed for 24 hours. 
 * @author Julien Niset - <julien@argent.xyz>
 */
contract DappRegistry is Owned {

    // [contract][signature][bool]
    mapping (address => mapping (bytes4 => bool)) internal authorised;

    event Registered(address indexed _contract, bytes4[] _methods);
    event Deregistered(address indexed _contract, bytes4[] _methods);

    /**
     * @dev Registers a list of methods for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     */
    function register(address _contract, bytes4[] _methods) external onlyOwner {
        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = true;
        }
        emit Registered(_contract, _methods);
    }

    /**
     * @dev Deregisters a list of methods for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     */
    function deregister(address _contract, bytes4[] _methods) external onlyOwner {
        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = false;
        }
        emit Deregistered(_contract, _methods);
    }

    /**
     * @dev Checks if a list of methods are registered for a dapp contract.
     * @param _contract The dapp contract.
     * @param _method The dapp methods.
     * @return true if all the methods are registered.
     */
    function isRegistered(address _contract, bytes4 _method) external view returns (bool) {
        return authorised[_contract][_method];
    }  

    /**
     * @dev Checks if a list of methods are registered for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     * @return true if all the methods are registered.
     */
    function isRegistered(address _contract, bytes4[] _methods) external view returns (bool) {
        for(uint i = 0; i < _methods.length; i++) {
            if (!authorised[_contract][_methods[i]]) {
                return false;
            }
        }
        return true;
    }  
}