pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/interfaces/IRegistry.sol

// limited ContractRegistry definition
interface IRegistry {
  function owner()
    external
    returns(address);

  function updateContractAddress(
    string _name,
    address _address
  )
    external
    returns (address);

  function getContractAddress(
    string _name
  )
    external
    view
    returns (address);
}

// File: contracts/interfaces/IBrickblockToken.sol

// limited BrickblockToken definition
interface IBrickblockToken {
  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (bool);

  function balanceOf(
    address _address
  )
    external
    view
    returns (uint256);

  function approve(
    address _spender,
    uint256 _value
  )
    external
    returns (bool);
}

// File: contracts/interfaces/IFeeManager.sol

interface IFeeManager {
  function claimFee(
    uint256 _value
  )
    external
    returns (bool);

  function payFee()
    external
    payable
    returns (bool);
}

// File: contracts/interfaces/IAccessToken.sol

interface IAccessToken {
  function lockBBK(
    uint256 _value
  )
    external
    returns (bool);

  function unlockBBK(
    uint256 _value
  )
    external
    returns (bool);

  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool);

  function distribute(
    uint256 _amount
  )
    external
    returns (bool);

  function burn(
    address _address,
    uint256 _value
  )
    external
    returns (bool);
}

// File: contracts/BrickblockAccount.sol

/* solium-disable security/no-block-members */


contract BrickblockAccount is Ownable {
  uint8 public constant version = 1;
  uint256 public releaseTimeOfCompanyBBKs;
  IRegistry private registry;

  constructor
  (
    address _registryAddress,
    uint256 _releaseTimeOfCompanyBBKs
  )
    public
  {
    require(_releaseTimeOfCompanyBBKs > block.timestamp);
    releaseTimeOfCompanyBBKs = _releaseTimeOfCompanyBBKs;
    registry = IRegistry(_registryAddress);
  }

  function pullFunds()
    external
    onlyOwner
    returns (bool)
  {
    IBrickblockToken bbk = IBrickblockToken(
      registry.getContractAddress("BrickblockToken")
    );
    uint256 _companyFunds = bbk.balanceOf(address(bbk));
    return bbk.transferFrom(address(bbk), address(this), _companyFunds);
  }

  function lockBBK
  (
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    IAccessToken act = IAccessToken(
      registry.getContractAddress("AccessToken")
    );
    IBrickblockToken bbk = IBrickblockToken(
      registry.getContractAddress("BrickblockToken")
    );

    require(bbk.approve(address(act), _value));

    return act.lockBBK(_value);
  }

  function unlockBBK(
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    IAccessToken act = IAccessToken(
      registry.getContractAddress("AccessToken")
    );
    return act.unlockBBK(_value);
  }

  function claimFee(
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    IFeeManager fmr = IFeeManager(
      registry.getContractAddress("FeeManager")
    );
    return fmr.claimFee(_value);
  }

  function withdrawEthFunds(
    address _address,
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    require(address(this).balance >= _value);
    _address.transfer(_value);
    return true;
  }

  function withdrawActFunds(
    address _address,
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    IAccessToken act = IAccessToken(
      registry.getContractAddress("AccessToken")
    );
    return act.transfer(_address, _value);
  }

  function withdrawBbkFunds(
    address _address,
    uint256 _value
  )
    external
    onlyOwner
    returns (bool)
  {
    require(block.timestamp >= releaseTimeOfCompanyBBKs);
    IBrickblockToken bbk = IBrickblockToken(
      registry.getContractAddress("BrickblockToken")
    );
    return bbk.transfer(_address, _value);
  }

  // ensure that we can be paid ether
  function()
    public
    payable
  {}
}