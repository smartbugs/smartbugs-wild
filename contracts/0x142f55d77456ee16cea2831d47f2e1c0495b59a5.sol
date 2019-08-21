pragma solidity ^0.4.25;


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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;


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
    _owner = msg.sender;
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
    emit OwnershipRenounced(_owner);
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


contract AirDropStore is Ownable {
    using SafeMath for uint256;
    
    address[] public arrayAirDrops;
    mapping (address => uint256) public indexOfAirDropAddress;
    
    event addToAirDropList(address _address);
    event removeFromAirDropList(address _address);
    
    function getArrayAirDropsLength() public view returns (uint256) {
        return arrayAirDrops.length;
    }
    
    function addAirDropAddress(address _address) public onlyOwner {
        arrayAirDrops.push(_address);
        indexOfAirDropAddress[_address] = arrayAirDrops.length.sub(1);
    
        emit addToAirDropList(_address);
    }
    
    function addAirDropAddresses(address[] _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            arrayAirDrops.push(_addresses[i]);
            indexOfAirDropAddress[_addresses[i]] = arrayAirDrops.length.sub(1);

            emit addToAirDropList(_addresses[i]);
        }
    }
    
    function removeAirDropAddress(address _address) public onlyOwner {
        uint256 index =  indexOfAirDropAddress[_address];

        arrayAirDrops[index] = address(0);
        emit removeFromAirDropList(_address);
    }
    
    function removeAirDropAddresses(address[] _addresses) public onlyOwner {
        uint256 index;
        
        for (uint i = 0; i < _addresses.length; i++) {
        
            index =  indexOfAirDropAddress[_addresses[i]];

            arrayAirDrops[index] = address(0);
            emit removeFromAirDropList(_addresses[i]);
        }
    }
}