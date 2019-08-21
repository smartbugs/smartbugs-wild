pragma solidity ^0.5.9;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



// File: contracts/commons/Wallet.sol

pragma solidity ^0.5.9;



contract Wallet is Ownable {
    function execute(
        address payable _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {
        return _to.call.value(_value)(_data);
    }
}

interface NanoLoanEngine {
    function transferFrom(address from, address to, uint256 index) external returns (bool);
}

contract LoanPull is Ownable, Wallet {
    event Pulling(address _engine, address _from, address _to, uint256 _ids);
    event Pulled(uint256 _id, bool _success);

    function pullLoans(
        NanoLoanEngine _engine,
        address _from,
        address _to,
        uint256[] calldata _ids
    ) external onlyOwner {
        uint256 len = _ids.length;

        emit Pulling(address(_engine), _from, _to, len);

        for (uint256 i = 0; i < len; i++) {
            uint256 id = _ids[i];
            bool success = _engine.transferFrom(_from, _to, id);
            emit Pulled(id, success);
        }
    }
}