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

// File: openzeppelin-solidity/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

// File: contracts/utils/OwnableContract.sol

// empty block is used as this contract just inherits others.
contract OwnableContract is CanReclaimToken, Claimable { } /* solhint-disable-line no-empty-blocks */

// File: contracts/utils/IndexedMapping.sol

library IndexedMapping {

    struct Data {
        mapping(address=>bool) valueExists;
        mapping(address=>uint) valueIndex;
        address[] valueList;
    }

    function add(Data storage self, address val) internal returns (bool) {
        if (exists(self, val)) return false;

        self.valueExists[val] = true;
        self.valueIndex[val] = self.valueList.push(val) - 1;
        return true;
    }

    function remove(Data storage self, address val) internal returns (bool) {
        uint index;
        address lastVal;

        if (!exists(self, val)) return false;

        index = self.valueIndex[val];
        lastVal = self.valueList[self.valueList.length - 1];

        // replace value with last value
        self.valueList[index] = lastVal;
        self.valueIndex[lastVal] = index;
        self.valueList.length--;

        // remove value
        delete self.valueExists[val];
        delete self.valueIndex[val];

        return true;
    }

    function exists(Data storage self, address val) internal view returns (bool) {
        return self.valueExists[val];
    }

    function getValue(Data storage self, uint index) internal view returns (address) {
        return self.valueList[index];
    }

    function getValueList(Data storage self) internal view returns (address[]) {
        return self.valueList;
    }
}

// File: contracts/factory/MembersInterface.sol

interface MembersInterface {
    function setCustodian(address _custodian) external returns (bool);
    function addMerchant(address merchant) external returns (bool);
    function removeMerchant(address merchant) external returns (bool);
    function isCustodian(address addr) external view returns (bool);
    function isMerchant(address addr) external view returns (bool);
}

// File: contracts/factory/Members.sol

contract Members is MembersInterface, OwnableContract {

    address public custodian;

    using IndexedMapping for IndexedMapping.Data;
    IndexedMapping.Data internal merchants;

    constructor(address _owner) public {
        require(_owner != address(0), "invalid _owner address");
        owner = _owner;
    }

    event CustodianSet(address indexed custodian);

    function setCustodian(address _custodian) external onlyOwner returns (bool) {
        require(_custodian != address(0), "invalid custodian address");
        custodian = _custodian;

        emit CustodianSet(_custodian);
        return true;
    }

    event MerchantAdd(address indexed merchant);

    function addMerchant(address merchant) external onlyOwner returns (bool) {
        require(merchant != address(0), "invalid merchant address");
        require(merchants.add(merchant), "merchant add failed");

        emit MerchantAdd(merchant);
        return true;
    } 

    event MerchantRemove(address indexed merchant);

    function removeMerchant(address merchant) external onlyOwner returns (bool) {
        require(merchant != address(0), "invalid merchant address");
        require(merchants.remove(merchant), "merchant remove failed");

        emit MerchantRemove(merchant);
        return true;
    }

    function isCustodian(address addr) external view returns (bool) {
        return (addr == custodian);
    }

    function isMerchant(address addr) external view returns (bool) {
        return merchants.exists(addr);
    }

    function getMerchant(uint index) external view returns (address) {
        return merchants.getValue(index);
    }

    function getMerchants() external view returns (address[]) {
        return merchants.getValueList();
    }
}