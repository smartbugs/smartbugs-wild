pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

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

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

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
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract ERC20Capped is ERC20Mintable {

  uint256 private _cap;

  constructor(uint256 cap)
    public
  {
    require(cap > 0);
    _cap = cap;
  }

  /**
   * @return the cap for the token minting.
   */
  function cap() public view returns(uint256) {
    return _cap;
  }

  function _mint(address account, uint256 value) internal {
    require(totalSupply().add(value) <= _cap);
    super._mint(account, value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
  }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function balanceOf(address owner) public view returns (uint256 balance);
  function ownerOf(uint256 tokenId) public view returns (address owner);

  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId)
    public view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator)
    public view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId)
    public;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes data
  )
    public;
}

// File: contracts/AdminRole.sol

contract AdminRole {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private admins;

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return admins.has(account);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        admins.remove(account);
        emit AdminRemoved(account);
    }
}

// File: contracts/SpenderRole.sol

contract SpenderRole {
    using Roles for Roles.Role;

    event SpenderAdded(address indexed account);
    event SpenderRemoved(address indexed account);

    Roles.Role private spenders;

    modifier onlySpender() {
        require(isSpender(msg.sender));
        _;
    }

    function isSpender(address account) public view returns (bool) {
        return spenders.has(account);
    }

    function renounceSpender() public {
        _removeSpender(msg.sender);
    }

    function _addSpender(address account) internal {
        spenders.add(account);
        emit SpenderAdded(account);
    }

    function _removeSpender(address account) internal {
        spenders.remove(account);
        emit SpenderRemoved(account);
    }
}

// File: contracts/RecipientRole.sol

contract RecipientRole {
    using Roles for Roles.Role;

    event RecipientAdded(address indexed account);
    event RecipientRemoved(address indexed account);

    Roles.Role private recipients;

    modifier onlyRecipient() {
        require(isRecipient(msg.sender));
        _;
    }

    function isRecipient(address account) public view returns (bool) {
        return recipients.has(account);
    }

    function renounceRecipient() public {
        _removeRecipient(msg.sender);
    }

    function _addRecipient(address account) internal {
        recipients.add(account);
        emit RecipientAdded(account);
    }

    function _removeRecipient(address account) internal {
        recipients.remove(account);
        emit RecipientRemoved(account);
    }
}

// File: contracts/Fider.sol

contract Fider is ERC20Detailed, ERC20Burnable, ERC20Capped, ERC20Pausable, AdminRole, SpenderRole, RecipientRole {
    using SafeERC20 for IERC20;

    address private root;

    modifier onlyRoot() {
        require(msg.sender == root, "This operation can only be performed by root account");
        _;
    }

    constructor(string name, string symbol, uint8 decimals, uint256 cap)
    ERC20Detailed(name, symbol, decimals) ERC20Capped(cap) ERC20Mintable()  ERC20() public {
        // Contract deployer (root) is automatically added as a minter in the MinterRole constructor
        // We revert this in here in order to separate the responsibilities of Root and Minter
        _removeMinter(msg.sender);

        // Contract deployer (root) is automatically added as a pauser in the PauserRole constructor
        // We revert this in here in order to separate the responsibilities of Root and Pauser
        _removePauser(msg.sender);

        root = msg.sender;
    }

    /*** ACCESS CONTROL MANAGEMENT ***/

    /**
    * This is particularly for the cases where there is a chance that the keys are compromised
    * but no one has attacked/abused them yet, this function gives company the option to be on
    * the safe side and start using another address.
    * @dev Transfers control of the contract to a newRoot.
    * @param _newRoot The address to transfer ownership to.
    */
    function transferRoot(address _newRoot) external onlyRoot {
        require(_newRoot != address(0));
        root = _newRoot;
    }

    /**
    * Designates a given account as an authorized Minter, where minter are the only ones who
    * can call the mint function to create new tokens.
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will be able to mint
    */
    function addMinter(address account) public onlyRoot {
        _addMinter(account);
    }

    /**
    * Revokes a given account as an authorized Minter, where minter are the only ones who
    * can call the mint function to create new tokens.
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will not be able to mint anymore
    */
    function removeMinter(address account) external onlyRoot {
        _removeMinter(account);
    }

    /**
    * Designates a given account as an authorized Pauser, where pausers are the only ones who
    * can call the pause and unpause functions to freeze or unfreeze the transfer functions.
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will be able to pause/unpause the token
    */
    function addPauser(address account) public onlyRoot {
        _addPauser(account);
    }

    /**
    * Revokes a given account as an authorized Pauser, where pausers are the only ones who
    * can call the pause and unpause functions to freeze or unfreeze the transfer functions.
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will not be able to pause/unpause the token anymore
    */
    function removePauser(address account) external onlyRoot {
        _removePauser(account);
    }

    /**
    * Designates a given account as an authorized Admin, where admins are the only ones who
    * can call the addRecipient, removeRecipient, addSpender and removeSpender functions
    * to authorize or revoke spenders and recipients
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will be able to administer spenders and recipients
    */
    function addAdmin(address account) external onlyRoot {
        _addAdmin(account);
    }

    /**
    * Revokes a given account as an authorized Admin, where admins are the only ones who
    * can call the addRecipient, removeRecipient, addSpender and removeSpender functions
    * to authorize or revoke spenders and recipients
    * This function can only be called by Root, which is the account who deployed the contract.
    * @param account address The account who will not be able to administer spenders and recipients anymore
    */
    function removeAdmin(address account) external onlyRoot {
        _removeAdmin(account);
    }

    /**
    * Designates a given account as an authorized Spender, where spenders are the only ones who
    * can call the transfer, approve, increaseAllowance, decreaseAllowance and transferFrom functions
    * to send tokens to other accounts
    * This function can only be called by an authorized admin
    * @param account address The account who will be able to send tokens
    */
    function addSpender(address account) external onlyAdmin {
        _addSpender(account);
    }

    /**
    * Revokes a given account as an authorized Spender, where spenders are the only ones who
    * can call the transfer, approve, increaseAllowance, decreaseAllowance and transferFrom functions
    * to send tokens to other accounts
    * This function can only be called by an authorized admin
    * @param account address The account who will not be able to send tokens anymore
    */
    function removeSpender(address account) external onlyAdmin {
        _removeSpender(account);
    }

    /**
    * Designates a given account as an authorized Recipient, where recipients are the only ones who
    * can be on the receiving end of a transfer, either through a normal transfer, or through a third
    * party payment process (approve/transferFrom or increaseAllowance/transferFrom)
    * This function can only be called by an authorized admin
    * @param account address The account who will be able to receive tokens
    */
    function addRecipient(address account) external onlyAdmin {
        _addRecipient(account);
    }

    /**
    * Revokes a given account as an authorized Recipient, where recipients are the only ones who
    * can be on the receiving end of a transfer, either through a normal transfer, or through a third
    * party payment process (approve/transferFrom or increaseAllowance/transferFrom)
    * This function can only be called by an authorized admin
    * @param account address The account who will not be able to receive tokens anymore
    */
    function removeRecipient(address account) external onlyAdmin {
        _removeRecipient(account);
    }

    /*** MINTING ***/

    /**
    * @dev Function to mint tokens
    * @param to The address that will receive the minted tokens. Must be an authorized spender.
    * @param value The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        require(isSpender(to), "To must be an authorized spender");
        return super.mint(to, value);
    }

    /*** BURNING ***/

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance
    * This function can only be called by an authorized minter.
    * @param from address The address which you want to burn tokens from
    * @param value uint256 The amount of tokens to be burned
    */
    function burnFrom(address from, uint256 value) public onlyMinter {
        _burnFrom(from, value);
    }

    /*** TRANSFER ***/

    /**
    * @dev Transfer token for a specified address
    * This function can only be called by an authorized spender.
    * @param to The address to transfer to. Must be an authorized recipient.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public onlySpender returns (bool) {
        require(isRecipient(to), "To must be an authorized recipient");
        return super.transfer(to, value);
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * This function can only be called by an authorized spender
    * @param spender The address which will spend the funds. Must be an authorized spender or minter.
    * @param value The amount of tokens to be spent.
    */
    function approve(address spender, uint256 value) public onlySpender returns (bool) {
        require(isSpender(spender) || isMinter(spender), "Spender must be an authorized spender or a minter");
        return super.approve(spender, value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * This function can only be called by an authorized spender.
    * @param from address The address which you want to send tokens from. Must be an authorized spender.
    * @param to address The address which you want to transfer to. Must be an authorized recipient.
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 value) public onlySpender returns (bool) {
        require(isSpender(from), "From must be an authorized spender");
        require(isRecipient(to), "To must be an authorized recipient");
        return super.transferFrom(from, to, value);
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * This function can only be called by an authorized spender.
    * @param spender The address which will spend the funds. Must be an authorized spender or minter.
    * @param addedValue The amount of tokens to increase the allowance by.
    */
    function increaseAllowance(address spender, uint256 addedValue) public onlySpender returns (bool) {
        require(isSpender(spender) || isMinter(spender), "Spender must be an authorized spender or a minter");
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * This function can only be called by an authorized spender.
     * @param spender The address which will spend the funds. Must be an authorized spender or minter.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public onlySpender returns (bool) {
        require(isSpender(spender) || isMinter(spender), "Spender must be an authorized spender or a minter");
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /** RECOVERING ASSETS MISTAKENLY SENT TO CONTRACT **/

    /**
    * @dev Disallows direct send by setting a default function without the `payable` flag.
    */
    function() external {
    }

    /**
    * @dev Transfer all Ether held by the contract to the root.
    */
    function reclaimEther() external onlyRoot {
        root.transfer(address(this).balance);
    }

    /**
    * @dev Reclaim all IERC20 compatible tokens
    * @param _token IERC20 The address of the token contract
    */
    function reclaimERC20Token(IERC20 _token) external onlyRoot {
        uint256 balance = _token.balanceOf(this);
        _token.safeTransfer(root, balance);
    }
}