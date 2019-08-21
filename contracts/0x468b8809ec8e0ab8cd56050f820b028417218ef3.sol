// File: contracts/Ownable.sol

pragma solidity 0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev The constructor sets the original owner of the contract to the sender account.
     */
    constructor() public {
        setOwner(msg.sender);
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "msg.sender should be onlyPendingOwner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "msg.sender should be owner");
        _;
    }

    /**
     * @dev Tells the address of the pendingOwner
     * @return The address of the pendingOwner
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }
    
    /**
     * @dev Tells the address of the owner
     * @return the address of the owner
     */
    function owner() public view returns (address ) {
        return _owner;
    }
    
    /**
    * @dev Sets a new owner address
    * @param _newOwner The newOwner to set
    */
    function setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0); 
    }
    
}

// File: contracts/Operable.sol

pragma solidity 0.5.0;


contract Operable is Ownable {

    address private _operator; 

    event OperatorChanged(address indexed previousOperator, address indexed newOperator);

    /**
     * @dev Tells the address of the operator
     * @return the address of the operator
     */
    function operator() external view returns (address) {
        return _operator;
    }
    
    /**
     * @dev Only the operator can operate store
     */
    modifier onlyOperator() {
        require(msg.sender == _operator, "msg.sender should be operator");
        _;
    }

    /**
     * @dev update the storgeOperator
     * @param _newOperator The newOperator to update  
     */
    function updateOperator(address _newOperator) public onlyOwner {
        require(_newOperator != address(0), "Cannot change the newOperator to the zero address");
        emit OperatorChanged(_operator, _newOperator);
        _operator = _newOperator;
    }

}

// File: contracts/BlacklistStore.sol

pragma solidity 0.5.0;


contract BlacklistStore is Operable {

    mapping (address => uint256) public blacklisted;

    /**
     * @dev Checks if account is blacklisted
     * @param _account The address to check
     * @param _status The address status    
     */
    function setBlacklist(address _account, uint256 _status) public onlyOperator {
        blacklisted[_account] = _status;
    }

}