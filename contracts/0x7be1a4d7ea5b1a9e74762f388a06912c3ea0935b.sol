pragma solidity >=0.5.0 <0.6.0;

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
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract SignerRole {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () internal {
        _addSigner(msg.sender);
    }

    modifier onlySigner() {
        require(isSigner(msg.sender));
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(msg.sender);
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

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

contract DistributionConfigurable is PauserRole {

  /**
    Structures
   */

  struct DistributionConfig {
    address lockedWallet;
    address unlockWallet;
    uint256 ratioDTV;
    uint256 ratioDecimals;
  }

  /**
    State variables
   */

  DistributionConfig[] public distributionConfigs;

  /**
    Events
   */

  event DistributionConfigAdded(
    address indexed lockedWallet,
    address indexed unlockWallet,
    uint256 ratioDTV,
    uint256 ratioDecimals
  );

  event DistributionConfigEdited(
    uint256 indexed index,
    address indexed lockedWallet,
    address indexed unlockWallet,
    uint256 previousRatioDTV,
    uint256 previousRatioDecimals,
    uint256 ratioDTV,
    uint256 ratioDecimals
  );

  event DistributionConfigDeleted(
    uint256 indexed index,
    address indexed lockedWallet,
    address indexed unlockWallet,
    uint256 ratioDTV,
    uint256 ratioDecimals
  );

  /**
    External views
   */

  function distributionConfigsLength()
    external view
    returns (uint256 length)
  {
    return distributionConfigs.length;
  }

  /**
    Public
   */

  function addDistributionConfig(
    address lockedWallet,
    address unlockWallet,
    uint256 ratioDTV,
    uint256 ratioDecimals
  ) public onlyPauser {
    require(lockedWallet != address(0), "lockedWallet address cannot be zero");
    require(unlockWallet != address(0), "unlockWallet address cannot be zero");
    require(lockedWallet != unlockWallet, "lockedWallet and unlockWallet addresses cannot be the same");
    require(ratioDTV > 0, "ratioDTV cannot be zero");
    require(ratioDecimals > 0, "ratioDecimals cannot be zero");
    distributionConfigs.push(DistributionConfig({
      lockedWallet: lockedWallet,
      unlockWallet: unlockWallet,
      ratioDTV: ratioDTV,
      ratioDecimals: ratioDecimals
    }));
    emit DistributionConfigAdded(
      lockedWallet,
      unlockWallet,
      ratioDTV,
      ratioDecimals
    );
  }

  function editDistributionConfig(
    uint256 index,
    uint256 ratioDTV,
    uint256 ratioDecimals
  ) public onlyPauser {
    require(index < distributionConfigs.length, "index is out of bound");
    require(ratioDTV > 0, "ratioDTV cannot be zero");
    require(ratioDecimals > 0, "ratioDecimals cannot be zero");
    emit DistributionConfigEdited(
      index,
      distributionConfigs[index].lockedWallet,
      distributionConfigs[index].unlockWallet,
      distributionConfigs[index].ratioDTV,
      distributionConfigs[index].ratioDecimals,
      ratioDTV,
      ratioDecimals
    );
    distributionConfigs[index].ratioDTV = ratioDTV;
    distributionConfigs[index].ratioDecimals = ratioDecimals;
  }

  function deleteDistributionConfig(
    uint256 index
  ) public onlyPauser {
    require(index < distributionConfigs.length, "index is out of bound");
    emit DistributionConfigDeleted(
      index,
      distributionConfigs[index].lockedWallet,
      distributionConfigs[index].unlockWallet,
      distributionConfigs[index].ratioDTV,
      distributionConfigs[index].ratioDecimals
    );
    // Replace the element to delete and shift elements of the array.
    for (uint i = index; i<distributionConfigs.length-1; i++){
      distributionConfigs[i] = distributionConfigs[i+1];
    }
    distributionConfigs.length--;
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

contract ATD is Ownable, Pausable, SignerRole, DistributionConfigurable {
  using SafeMath for uint256;

  /**
    State variables
   */

  ERC20Detailed public token;

  /**
    Constructor
   */

  constructor(
    ERC20Detailed _token
  ) public {
    token = _token;
  }

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
    uint256 amount
  );

  event TotalDistributed(
    uint256 indexed date,
    uint256 dailyTradedVolume,
    uint256 amount
  );

  /**
    Publics
   */

  function distribute(
    uint256 dailyTradedVolume
  ) public whenNotPaused onlySigner {
    require(
      dailyTradedVolume.div(10 ** uint256(token.decimals())) > 0,
      "dailyTradedVolume is not in token unit"
    );
    uint256 total = 0;
    for (uint256 i = 0; i < distributionConfigs.length; i++) {
      DistributionConfig storage dc = distributionConfigs[i];
      uint256 amount = dailyTradedVolume.mul(dc.ratioDTV).div(10 ** dc.ratioDecimals);
      token.transferFrom(dc.lockedWallet, dc.unlockWallet, amount);
      total = total.add(amount);
      emit Distributed(
        now,
        dc.lockedWallet,
        dc.unlockWallet,
        dc.ratioDTV,
        dc.ratioDecimals,
        dailyTradedVolume,
        amount
      );
    }
    emit TotalDistributed(now, dailyTradedVolume, total);
  }

  function destroy() public onlyOwner {
    selfdestruct(msg.sender);
  }

  function removePauser(address account) public onlyOwner {
    _removePauser(account);
  }

  function removeSigner(address account) public onlyOwner {
    _removeSigner(account);
  }

}