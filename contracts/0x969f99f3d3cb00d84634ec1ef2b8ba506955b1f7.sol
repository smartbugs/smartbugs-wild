pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/WeSendReserve.sol

/**
 * @title WeSend sidechain SDT
 */
contract WeSendReserve is Ownable {
  using SafeMath for uint256;

  mapping (address => bool) internal authorized;
  mapping(address => uint256) internal deposits;
  mapping(address => uint256) internal releases;

  ERC20 public token;
  uint256 public minRelease = 1;

  event Deposit(address indexed from, uint256 amount);
  event Release(address indexed to, uint256 amount);

  modifier isAuthorized() {
    require(authorized[msg.sender]);
    _;
  }

  /**
  * @dev Constructor
  */
  function WeSendReserve(address _address) public {
    token = ERC20(_address);
  }

  /**
  * @param _address new minter address.
  */
  function setAuthorized(address _address) public onlyOwner {
    authorized[_address] = true;
  }

  /**
  * @param _address address to revoke.
  */
  function revokeAuthorized(address _address) public onlyOwner {
    authorized[_address] = false;
  }

  /**
  * @param _address The address to check deposits.
  */
  function getDeposits(address _address) public view returns (uint256) {
    return deposits[_address];
  }

  /**
  * @dev Constructor
  * @param _address The address to check releases.
  */
  function getWithdraws(address _address) public view returns (uint256) {
    return releases[_address];
  }

  /**
  * @param amount Amount to set
  */
  function setMinRelease(uint256 amount) public onlyOwner {
    minRelease = amount;
  }

  /**
  * @param _amount Amount to deposit.
  */
  function deposit(uint256 _amount) public returns (bool) {
    token.transferFrom(msg.sender, address(this), _amount);
    deposits[msg.sender] = deposits[msg.sender].add(_amount);
    Deposit(msg.sender, _amount);
    return true;
  }

  /**
  * @param _address Address to grant released tokens to.
  * @param _amount Amount to release.
  */
  function release(address _address, uint256 _amount) public isAuthorized returns (uint256) {
    require(_amount >= minRelease);
    token.transfer(_address, _amount);
    releases[_address] = releases[_address].add(_amount);
    Release(_address, _amount);
  }

}