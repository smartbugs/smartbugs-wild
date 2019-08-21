// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.2;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.2;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.2;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

// File: contracts/interfaces/IIssuer.sol

pragma solidity 0.5.4;


interface IIssuer {
    event Issued(address indexed payee, uint amount);
    event Claimed(address indexed payee, uint amount);
    event FinishedIssuing(address indexed issuer);

    function issue(address payee, uint amount) external;
    function claim() external;
    function airdrop(address payee, uint amount) external;
    function isRunning() external view returns (bool);
}

// File: contracts/interfaces/IERC1594.sol

pragma solidity 0.5.4;


/// @title IERC1594 Security Token Standard
/// @dev See https://github.com/SecurityTokenStandard/EIP-Spec
interface IERC1594 {
    // Issuance / Redemption Events
    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);

    // Transfers
    function transferWithData(address _to, uint256 _value, bytes calldata _data) external;
    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;

    // Token Redemption
    function redeem(uint256 _value, bytes calldata _data) external;
    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;

    // Token Issuance
    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;
    function isIssuable() external view returns (bool);

    // Transfer Validity
    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32);
    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32);
}

// File: contracts/interfaces/IHasIssuership.sol

pragma solidity 0.5.4;


interface IHasIssuership {
    event IssuershipTransferred(address indexed from, address indexed to);

    function transferIssuership(address newIssuer) external;
}

// File: contracts/roles/IssuerStaffRole.sol

pragma solidity 0.5.4;



// @notice IssuerStaffs are capable of managing over the Issuer contract.
contract IssuerStaffRole {
    using Roles for Roles.Role;

    event IssuerStaffAdded(address indexed account);
    event IssuerStaffRemoved(address indexed account);

    Roles.Role internal _issuerStaffs;

    modifier onlyIssuerStaff() {
        require(isIssuerStaff(msg.sender), "Only IssuerStaffs can execute this function.");
        _;
    }

    constructor() internal {
        _addIssuerStaff(msg.sender);
    }

    function isIssuerStaff(address account) public view returns (bool) {
        return _issuerStaffs.has(account);
    }

    function addIssuerStaff(address account) public onlyIssuerStaff {
        _addIssuerStaff(account);
    }

    function renounceIssuerStaff() public {
        _removeIssuerStaff(msg.sender);
    }

    function _addIssuerStaff(address account) internal {
        _issuerStaffs.add(account);
        emit IssuerStaffAdded(account);
    }

    function _removeIssuerStaff(address account) internal {
        _issuerStaffs.remove(account);
        emit IssuerStaffRemoved(account);
    }
}

// File: contracts/issuance/Issuer.sol

pragma solidity 0.5.4;









/**
 * @notice The Issuer issues claims for TENX tokens which users can claim to receive tokens.
 */
contract Issuer is IIssuer, IHasIssuership, IssuerStaffRole, Ownable, Pausable, ReentrancyGuard {
    struct Claim {
        address issuer;
        ClaimState status;
        uint amount;
    }

    enum ClaimState { NONE, ISSUED, CLAIMED }
    mapping(address => Claim) public claims;

    bool public isRunning = true;
    IERC1594 public token; // Mints tokens to payee's address

    event Issued(address indexed payee, address indexed issuer, uint amount);
    event Claimed(address indexed payee, uint amount);

    /**
    * @notice Modifier to check that the Issuer contract is currently running.
    */
    modifier whenRunning() {
        require(isRunning, "Issuer contract has stopped running.");
        _;
    }    

    /**
    * @notice Modifier to check the status of a claim.
    * @param _payee Payee address
    * @param _state Claim status    
    */
    modifier atState(address _payee, ClaimState _state) {
        Claim storage c = claims[_payee];
        require(c.status == _state, "Invalid claim source state.");
        _;
    }

    /**
    * @notice Modifier to check the status of a claim.
    * @param _payee Payee address
    * @param _state Claim status
    */
    modifier notAtState(address _payee, ClaimState _state) {
        Claim storage c = claims[_payee];
        require(c.status != _state, "Invalid claim source state.");
        _;
    }

    constructor(IERC1594 _token) public {
        token = _token;
    }

    /**
     * @notice Transfer the token's Issuer role from this contract to another address. Decommissions this Issuer contract.
     */
    function transferIssuership(address _newIssuer) 
        external onlyOwner whenRunning 
    {
        require(_newIssuer != address(0), "New Issuer cannot be zero address.");
        isRunning = false;
        IHasIssuership t = IHasIssuership(address(token));
        t.transferIssuership(_newIssuer);
    }

    /**
    * @notice Issue a new claim.
    * @param _payee The address of the _payee.
    * @param _amount The amount of tokens the payee will receive.
    */
    function issue(address _payee, uint _amount) 
        external onlyIssuerStaff whenRunning whenNotPaused notAtState(_payee, ClaimState.CLAIMED) 
    {
        require(_payee != address(0), "Payee must not be a zero address.");
        require(_payee != msg.sender, "Issuers cannot issue for themselves");
        require(_amount > 0, "Claim amount must be positive.");
        claims[_payee] = Claim({
            status: ClaimState.ISSUED,
            amount: _amount,
            issuer: msg.sender
        });
        emit Issued(_payee, msg.sender, _amount);
    }

    /**
    * @notice Function for users to redeem a claim of tokens.
    * @dev To claim, users must call this contract from their claim address. Tokens equal to the claim amount will be minted to the claim address.
    */
    function claim() 
        external whenRunning whenNotPaused atState(msg.sender, ClaimState.ISSUED) 
    {
        address payee = msg.sender;
        Claim storage c = claims[payee];
        c.status = ClaimState.CLAIMED; // Marks claim as claimed
        emit Claimed(payee, c.amount);

        token.issue(payee, c.amount, ""); // Mints tokens to payee's address
    }

    /**
    * @notice Function to mint tokens to users directly in a single step. Skips the issued state.
    * @param _payee The address of the _payee.
    * @param _amount The amount of tokens the payee will receive.    
    */
    function airdrop(address _payee, uint _amount) 
        external onlyIssuerStaff whenRunning whenNotPaused atState(_payee, ClaimState.NONE) nonReentrant 
    {
        require(_payee != address(0), "Payee must not be a zero address.");
        require(_payee != msg.sender, "Issuers cannot airdrop for themselves");
        require(_amount > 0, "Claim amount must be positive.");
        claims[_payee] = Claim({
            status: ClaimState.CLAIMED,
            amount: _amount,
            issuer: msg.sender
        });
        emit Claimed(_payee, _amount);

        token.issue(_payee, _amount, ""); // Mints tokens to payee's address
    }
}