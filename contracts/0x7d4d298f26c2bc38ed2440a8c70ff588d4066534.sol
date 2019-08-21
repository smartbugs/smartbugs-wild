pragma solidity ^0.4.19;

/*
GECO TEMP
Version 1.01
Release date: 2018-11-29
*/

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

contract GECO is Ownable {
  using SafeMath for uint256;
  
  event IncomingTransfer(address indexed to, uint256 amount);
  event ContractFinished();
    
  address public wallet;
  uint256 public endTime;
  uint256 public totalSupply;
  mapping(address => uint256) balances;
  bool public contractFinished = false;
  
  function GECO(address _wallet, uint256 _endTime) public {
    require(_wallet != address(0));
    require(_endTime >= now);
    
    wallet = _wallet;
    endTime = _endTime;
  }
  
  function () external payable {
    require(!contractFinished);
    require(now <= endTime);
      
    totalSupply = totalSupply.add(msg.value);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    wallet.transfer(msg.value);
    IncomingTransfer(msg.sender, msg.value);
  }
  
  function finishContract() onlyOwner public returns (bool) {
    contractFinished = true;
    ContractFinished();
    return true;
  }
  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  
  function changeEndTime(uint256 _endTime) onlyOwner public {
    endTime = _endTime;
  }
}