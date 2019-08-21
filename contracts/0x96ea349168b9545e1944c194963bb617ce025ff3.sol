pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


interface SaleInterface {
    function saleTokensPerUnit() external view returns(uint256);
    function extraTokensPerUnit() external view returns(uint256);
    function unitContributions(address) external view returns(uint256);
    function disbursementHandler() external view returns(address);
}





contract Saft is SaleInterface, Ownable {

  uint256 public c_saleTokensPerUnit;
  uint256 public c_extraTokensPerUnit;
  mapping(address => uint256) public c_unitContributions;
  address public c_disbursementHandler;

  constructor (uint256 _saleTokensPerUnit, uint256 _extraTokensPerUnit, address _disbursementHandler) Ownable() public {
    c_saleTokensPerUnit = _saleTokensPerUnit;
    c_extraTokensPerUnit = _extraTokensPerUnit;
    c_disbursementHandler = _disbursementHandler;
  }

  function saleTokensPerUnit() external view returns (uint256) { return c_saleTokensPerUnit; }
  function extraTokensPerUnit() external view returns (uint256) { return c_extraTokensPerUnit; }
  function unitContributions(address contributor) external view returns (uint256) { return c_unitContributions[contributor]; }
  function disbursementHandler() external view returns (address) { return c_disbursementHandler; }

  function setSaleTokensPerUnit(uint256 _saleTokensPerUnit) public onlyOwner {
    c_saleTokensPerUnit = _saleTokensPerUnit;
  }

  function setExtraTokensPerUnit(uint256 _extraTokensPerUnit) public onlyOwner {
    c_extraTokensPerUnit = _extraTokensPerUnit;
  }

  function setUnitContributions(address contributor, uint256 units) public onlyOwner {
    c_unitContributions[contributor] = units;
  }

  function setDisbursementHandler(address _disbursementHandler) public onlyOwner {
    c_disbursementHandler = _disbursementHandler;
  }
}