pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol

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

// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol

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

// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

// File: contracts/IBounty.sol

interface IBounty {

  function packageBounty(
    address owner,
    uint256 needHopsAmount,
    address[] tokenAddress,
    uint256[] tokenAmount)
    external returns (bool);
  
  function openBounty(uint256 bountyId)
    external returns (bool);
  
  function checkBounty(uint256 bountyId)
    external view returns (address, uint256, address[], uint256[]);

  /* Events */
  event BountyEvt (
    uint256 bountyId,
    address owner,
    uint256 needHopsAmount,
    address[] tokenAddress,
    uint256[] tokenAmount
  );

  event OpenBountyEvt (
    uint256 bountyId,
    address sender,
    uint256 needHopsAmount,
    address[] tokenAddress,
    uint256[] tokenAmount
  );
}

// File: contracts/Role/WhitelistAdminRole.sol

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
  using Roles for Roles.Role;

  event WhitelistAdminAdded(address indexed account);
  event WhitelistAdminRemoved(address indexed account);

  Roles.Role private _whitelistAdmins;

  constructor () internal {
    _addWhitelistAdmin(msg.sender);
  }

  modifier onlyWhitelistAdmin() {
    require(isWhitelistAdmin(msg.sender));
    _;
  }

  function isWhitelistAdmin(address account) public view returns (bool) {
    return _whitelistAdmins.has(account);
  }

  function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
    _addWhitelistAdmin(account);
  }

  function renounceWhitelistAdmin() public {
    _removeWhitelistAdmin(msg.sender);
  }

  function _addWhitelistAdmin(address account) internal {
    _whitelistAdmins.add(account);
    emit WhitelistAdminAdded(account);
  }

  function _removeWhitelistAdmin(address account) internal {
    _whitelistAdmins.remove(account);
    emit WhitelistAdminRemoved(account);
  }
}

// File: contracts/Role/WhitelistedRole.sol

/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
  using Roles for Roles.Role;

  event WhitelistedAdded(address indexed account);
  event WhitelistedRemoved(address indexed account);

  Roles.Role private _whitelisteds;

  modifier onlyWhitelisted() {
    require(isWhitelisted(msg.sender));
    _;
  }

  function isWhitelisted(address account) public view returns (bool) {
    return _whitelisteds.has(account);
  }

  function addWhitelisted(address account) public onlyWhitelistAdmin {
    _addWhitelisted(account);
  }

  function removeWhitelisted(address account) public onlyWhitelistAdmin {
    _removeWhitelisted(account);
  }

  function renounceWhitelisted() public {
    _removeWhitelisted(msg.sender);
  }

  function _addWhitelisted(address account) internal {
    _whitelisteds.add(account);
    emit WhitelistedAdded(account);
  }

  function _removeWhitelisted(address account) internal {
    _whitelisteds.remove(account);
    emit WhitelistedRemoved(account);
  }
}

// File: contracts/SafeMath.sol

/**
 * @title SafeMath
 */
library SafeMath {
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
  /**
    * @dev gives square root of given x.
    */
  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
  /**
    * @dev gives square. batchplies x by x
    */
  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
  /**
    * @dev x to the power of y 
    */
  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i=1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}

// File: contracts/Bounty.sol

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address tokenOwner, address spender) external view returns (uint256);
  function burnFrom(address from, uint256 value) external;
}

interface IERC721 {
  function mintTo(address to) external returns (bool, uint256);
  function ownerOf(uint256 tokenId) external view returns (address);
  function burn(uint256 tokenId) external;
  function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract Bounty is WhitelistedRole, IBounty, Pausable {

  using SafeMath for *;

  address public erc20Address;
  address public bountyNFTAddress;

  struct Bounty {
    uint256 needHopsAmount;
    address[] tokenAddress;
    uint256[] tokenAmount;
  }

  bytes32[] public planBaseIds;

  mapping (uint256 => Bounty) bountyIdToBounty;

  constructor (address _erc20Address, address _bountyNFTAddress) {
    erc20Address = _erc20Address;
    bountyNFTAddress = _bountyNFTAddress;
  }

  function packageBounty (
    address owner,
    uint256 needHopsAmount,
    address[] tokenAddress,
    uint256[] tokenAmount
  ) whenNotPaused external returns (bool) {
    require(isWhitelisted(msg.sender)||isWhitelistAdmin(msg.sender));
    Bounty memory bounty = Bounty(needHopsAmount, tokenAddress, tokenAmount);
    (bool success, uint256 bountyId) = IERC721(bountyNFTAddress).mintTo(owner);
    require(success);
    bountyIdToBounty[bountyId] = bounty;
    emit BountyEvt(bountyId, owner, needHopsAmount, tokenAddress, tokenAmount);
  }

  function openBounty(uint256 bountyId)
    whenNotPaused external returns (bool) {
    Bounty storage bounty = bountyIdToBounty[bountyId];
    require(IERC721(bountyNFTAddress).ownerOf(bountyId) == msg.sender);

    require(IERC721(bountyNFTAddress).isApprovedForAll(msg.sender, address(this)));
    require(IERC20(erc20Address).balanceOf(msg.sender) >= bounty.needHopsAmount);
    require(IERC20(erc20Address).allowance(msg.sender, address(this)) >= bounty.needHopsAmount);
    IERC20(erc20Address).burnFrom(msg.sender, bounty.needHopsAmount);

    for (uint8 i = 0; i < bounty.tokenAddress.length; i++) {
      require(IERC20(bounty.tokenAddress[i]).transfer(msg.sender, bounty.tokenAmount[i]));
    }

    IERC721(bountyNFTAddress).burn(bountyId);
    delete bountyIdToBounty[bountyId];

    emit OpenBountyEvt(bountyId, msg.sender, bounty.needHopsAmount, bounty.tokenAddress, bounty.tokenAmount);
  }

  function checkBounty(uint256 bountyId) external view returns (
    address,
    uint256,
    address[],
    uint256[]) {
    Bounty storage bounty = bountyIdToBounty[bountyId];
    address owner = IERC721(bountyNFTAddress).ownerOf(bountyId);
    return (owner, bounty.needHopsAmount, bounty.tokenAddress, bounty.tokenAmount);
  }
}