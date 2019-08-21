pragma solidity >=0.5.0 <0.6.0;

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

contract HistoricATD is Ownable, Pausable {

  /**
    Constructor
   */

  // constructor() public {}

  /**
    Events
   */

  event Distributed(
    uint256 indexed date,
    address indexed lockedWallet,
    address indexed unlockWallet,
    uint256 ratioDTV,
    uint256 ratioDecimals,
    uint256 dailyTradedVolume,
    uint256 amount,
    bytes32 transaction
  );

  event TotalDistributed(
    uint256 indexed date,
    uint256 dailyTradedVolume,
    uint256 amount,
    bytes32 transaction
  );

  /**
    Publics
   */

  function emitDistribute(
    uint256[] memory dates,
    uint256[] memory dailyTradedVolumes,
    address[] memory lockedWallets,
    address[] memory unlockWallets,
    uint256[] memory ratioDTVs,
    uint256[] memory ratioDecimals,
    uint256[] memory amounts,
    bytes32[] memory transactions
  ) public whenNotPaused {
    require(dates.length == dailyTradedVolumes.length, "dailyTradedVolumes length is different");
    require(dates.length == lockedWallets.length, "lockedWallets length is different");
    require(dates.length == unlockWallets.length, "unlockWallets length is different");
    require(dates.length == ratioDTVs.length, "ratioDTVs length is different");
    require(dates.length == ratioDecimals.length, "ratioDecimals length is different");
    require(dates.length == amounts.length, "amounts length is different");
    require(dates.length == transactions.length, "transactions length is different");
    for (uint256 i = 0; i < dates.length; i++) {
      emit Distributed(
        dates[i],
        lockedWallets[i],
        unlockWallets[i],
        ratioDTVs[i],
        ratioDecimals[i],
        dailyTradedVolumes[i],
        amounts[i],
        transactions[i]
      );
    }
  }

  function emitDistributeTotal(
    uint256[] memory dates,
    uint256[] memory dailyTradedVolumes,
    uint256[] memory totals,
    bytes32[] memory transactions
  ) public whenNotPaused {
    require(dates.length == dailyTradedVolumes.length, "dailyTradedVolumes length is different");
    require(dates.length == totals.length, "totals length is different");
    require(dates.length == transactions.length, "transactions length is different");
    for (uint256 i = 0; i < dates.length; i++) {
      emit TotalDistributed(dates[i], dailyTradedVolumes[i], totals[i], transactions[i]);
    }
  }

  function destroy() public onlyOwner {
    selfdestruct(msg.sender);
  }

  function removePauser(address account) public onlyOwner {
    _removePauser(account);
  }

}