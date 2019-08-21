pragma solidity ^0.4.24;

contract J8TTokenInterface {
  function balanceOf(address who) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  function approve(address spender, uint256 value) public returns (bool);
}

contract FeeInterface {
  function getFee(uint _base, uint _amount) external view returns (uint256 fee);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;
  address private _admin;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  event AdministrationTransferred(
    address indexed previousAdmin,
    address indexed newAdmin
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @return the address of the admin.
   */
  function admin() public view returns(address) {
    return _admin;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyAdmin() {
    require(isAdmin());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @return true if `msg.sender` is the admin of the contract.
   */
  function isAdmin() public view returns(bool) {
    return msg.sender == _admin;
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

  /**
   * @dev Allows the current owner to transfer admin control of the contract to a newAdmin.
   * @param newAdmin The address to transfer admin powers to.
   */
  function transferAdministration(address newAdmin) public onlyOwner {
    _transferAdministration(newAdmin);
  }

  /**
   * @dev Transfers admin control of the contract to a newAdmin.
   * @param newAdmin The address to transfer admin power to.
   */
  function _transferAdministration(address newAdmin) internal {
    require(newAdmin != address(0));
    require(newAdmin != address(this));
    emit AdministrationTransferred(_admin, newAdmin);
    _admin = newAdmin;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */

contract Pausable is Ownable {

  event Paused();
  event Unpaused();

  bool private _paused = false;

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
    require(!_paused, "Contract is paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Contract is not paused");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}


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

contract WalletCoordinator is Pausable {

  using SafeMath for uint256;

  J8TTokenInterface public tokenContract;
  FeeInterface public feeContract;
  address public custodian;

  event TransferSuccess(
    address indexed fromAddress,
    address indexed toAddress,
    uint amount,
    uint networkFee
  );

  event TokenAddressUpdated(
    address indexed oldAddress,
    address indexed newAddress
  );

  event FeeContractAddressUpdated(
    address indexed oldAddress,
    address indexed newAddress
  );

  event CustodianAddressUpdated(
    address indexed oldAddress,
    address indexed newAddress
  );

  /**
   * @dev Allows the current smart contract to transfer amount of tokens from fromAddress to toAddress
   */
  function transfer(address _fromAddress, address _toAddress, uint _amount, uint _baseFee) public onlyAdmin whenNotPaused {
    require(_amount > 0, "Amount must be greater than zero");
    require(_fromAddress != _toAddress,  "Addresses _fromAddress and _toAddress are equal");
    require(_fromAddress != address(0), "Address _fromAddress is 0x0");
    require(_fromAddress != address(this), "Address _fromAddress is smart contract address");
    require(_toAddress != address(0), "Address _toAddress is 0x0");
    require(_toAddress != address(this), "Address _toAddress is smart contract address");

    uint networkFee = feeContract.getFee(_baseFee, _amount);
    uint fromBalance = tokenContract.balanceOf(_fromAddress);

    require(_amount <= fromBalance, "Insufficient account balance");

    require(tokenContract.transferFrom(_fromAddress, _toAddress, _amount.sub(networkFee)), "transferFrom did not succeed");
    require(tokenContract.transferFrom(_fromAddress, custodian, networkFee), "transferFrom fee did not succeed");

    emit TransferSuccess(_fromAddress, _toAddress, _amount, networkFee);
  }

  function getFee(uint _base, uint _amount) public view returns (uint256) {
    return feeContract.getFee(_base, _amount);
  }

  function setTokenInterfaceAddress(address _newAddress) external onlyOwner whenPaused returns (bool) {
    require(_newAddress != address(this), "The new token address is equal to the smart contract address");
    require(_newAddress != address(0), "The new token address is equal to 0x0");
    require(_newAddress != address(tokenContract), "The new token address is equal to the old token address");

    address _oldAddress = tokenContract;
    tokenContract = J8TTokenInterface(_newAddress);

    emit TokenAddressUpdated(_oldAddress, _newAddress);

    return true;
  }

  function setFeeContractAddress(address _newAddress) external onlyOwner whenPaused returns (bool) {
    require(_newAddress != address(this), "The new fee contract address is equal to the smart contract address");
    require(_newAddress != address(0), "The new fee contract address is equal to 0x0");

    address _oldAddress = feeContract;
    feeContract = FeeInterface(_newAddress);

    emit FeeContractAddressUpdated(_oldAddress, _newAddress);

    return true;
  }

  function setCustodianAddress(address _newAddress) external onlyOwner returns (bool) {
    require(_newAddress != address(this), "The new custodian address is equal to the smart contract address");
    require(_newAddress != address(0), "The new custodian address is equal to 0x0");

    address _oldAddress = custodian;
    custodian = _newAddress;

    emit CustodianAddressUpdated(_oldAddress, _newAddress);

    return true;
  }
}