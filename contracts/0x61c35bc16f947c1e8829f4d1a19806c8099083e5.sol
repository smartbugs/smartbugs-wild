pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface RegistryInterface {
    struct RegisteredDerivative {
        address derivativeAddress;
        address derivativeCreator;
    }

    // Registers a new derivative. Only authorized derivative creators can call this method.
    function registerDerivative(address[] calldata counterparties, address derivativeAddress) external;

    // Adds a new derivative creator to this list of authorized creators. Only the owner of this contract can call
    // this method.   
    function addDerivativeCreator(address derivativeCreator) external;

    // Removes a derivative creator to this list of authorized creators. Only the owner of this contract can call this
    // method.  
    function removeDerivativeCreator(address derivativeCreator) external;

    // Returns whether the derivative has been registered with the registry (and is therefore an authorized participant
    // in the UMA system).
    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered);

    // Returns a list of all derivatives that are associated with a particular party.
    function getRegisteredDerivatives(address party) external view returns (RegisteredDerivative[] memory derivatives);

    // Returns all registered derivatives.
    function getAllRegisteredDerivatives() external view returns (RegisteredDerivative[] memory derivatives);

    // Returns whether an address is authorized to register new derivatives.
    function isDerivativeCreatorAuthorized(address derivativeCreator) external view returns (bool isAuthorized);
}

contract Withdrawable is Ownable {
    // Withdraws ETH from the contract.
    function withdraw(uint amount) external onlyOwner {
        msg.sender.transfer(amount);
    }

    // Withdraws ERC20 tokens from the contract.
    function withdrawErc20(address erc20Address, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        require(erc20.transfer(msg.sender, amount));
    }
}

contract Registry is RegistryInterface, Withdrawable {

    using SafeMath for uint;

    // Array of all registeredDerivatives that are approved to use the UMA Oracle.
    RegisteredDerivative[] private registeredDerivatives;

    // This enum is required because a WasValid state is required to ensure that derivatives cannot be re-registered.
    enum PointerValidity {
        Invalid,
        Valid,
        WasValid
    }

    struct Pointer {
        PointerValidity valid;
        uint128 index;
    }

    // Maps from derivative address to a pointer that refers to that RegisteredDerivative in registeredDerivatives.
    mapping(address => Pointer) private derivativePointers;

    // Note: this must be stored outside of the RegisteredDerivative because mappings cannot be deleted and copied
    // like normal data. This could be stored in the Pointer struct, but storing it there would muddy the purpose
    // of the Pointer struct and break separation of concern between referential data and data.
    struct PartiesMap {
        mapping(address => bool) parties;
    }

    // Maps from derivative address to the set of parties that are involved in that derivative.
    mapping(address => PartiesMap) private derivativesToParties;

    // Maps from derivative creator address to whether that derivative creator has been approved to register contracts.
    mapping(address => bool) private derivativeCreators;

    modifier onlyApprovedDerivativeCreator {
        require(derivativeCreators[msg.sender]);
        _;
    }

    function registerDerivative(address[] calldata parties, address derivativeAddress)
        external
        onlyApprovedDerivativeCreator
    {
        // Create derivative pointer.
        Pointer storage pointer = derivativePointers[derivativeAddress];

        // Ensure that the pointer was not valid in the past (derivatives cannot be re-registered or double
        // registered).
        require(pointer.valid == PointerValidity.Invalid);
        pointer.valid = PointerValidity.Valid;

        registeredDerivatives.push(RegisteredDerivative(derivativeAddress, msg.sender));

        // No length check necessary because we should never hit (2^127 - 1) derivatives.
        pointer.index = uint128(registeredDerivatives.length.sub(1));

        // Set up PartiesMap for this derivative.
        PartiesMap storage partiesMap = derivativesToParties[derivativeAddress];
        for (uint i = 0; i < parties.length; i = i.add(1)) {
            partiesMap.parties[parties[i]] = true;
        }

        address[] memory partiesForEvent = parties;
        emit RegisterDerivative(derivativeAddress, partiesForEvent);
    }

    function addDerivativeCreator(address derivativeCreator) external onlyOwner {
        if (!derivativeCreators[derivativeCreator]) {
            derivativeCreators[derivativeCreator] = true;
            emit AddDerivativeCreator(derivativeCreator);
        }
    }

    function removeDerivativeCreator(address derivativeCreator) external onlyOwner {
        if (derivativeCreators[derivativeCreator]) {
            derivativeCreators[derivativeCreator] = false;
            emit RemoveDerivativeCreator(derivativeCreator);
        }
    }

    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered) {
        return derivativePointers[derivative].valid == PointerValidity.Valid;
    }

    function getRegisteredDerivatives(address party) external view returns (RegisteredDerivative[] memory derivatives) {
        // This is not ideal - we must statically allocate memory arrays. To be safe, we make a temporary array as long
        // as registeredDerivatives. We populate it with any derivatives that involve the provided party. Then, we copy
        // the array over to the return array, which is allocated using the correct size. Note: this is done by double
        // copying each value rather than storing some referential info (like indices) in memory to reduce the number
        // of storage reads. This is because storage reads are far more expensive than extra memory space (~100:1).
        RegisteredDerivative[] memory tmpDerivativeArray = new RegisteredDerivative[](registeredDerivatives.length);
        uint outputIndex = 0;
        for (uint i = 0; i < registeredDerivatives.length; i = i.add(1)) {
            RegisteredDerivative storage derivative = registeredDerivatives[i];
            if (derivativesToParties[derivative.derivativeAddress].parties[party]) {
                // Copy selected derivative to the temporary array.
                tmpDerivativeArray[outputIndex] = derivative;
                outputIndex = outputIndex.add(1);
            }
        }

        // Copy the temp array to the return array that is set to the correct size.
        derivatives = new RegisteredDerivative[](outputIndex);
        for (uint j = 0; j < outputIndex; j = j.add(1)) {
            derivatives[j] = tmpDerivativeArray[j];
        }
    }

    function getAllRegisteredDerivatives() external view returns (RegisteredDerivative[] memory derivatives) {
        return registeredDerivatives;
    }

    function isDerivativeCreatorAuthorized(address derivativeCreator) external view returns (bool isAuthorized) {
        return derivativeCreators[derivativeCreator];
    }

    event RegisterDerivative(address indexed derivativeAddress, address[] parties);
    event AddDerivativeCreator(address indexed addedDerivativeCreator);
    event RemoveDerivativeCreator(address indexed removedDerivativeCreator);

}