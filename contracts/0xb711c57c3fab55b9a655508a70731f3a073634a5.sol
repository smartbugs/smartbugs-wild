pragma solidity ^0.4.23;

// File: contracts/ERC20Basic.sol

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

// File: contracts/Ownerable.sol

contract Ownerable {
    /// @notice The address of the owner is the only address that can call
    ///  a function with this modifier
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    constructor() public { owner = msg.sender;}

    /// @notice Changes the owner of the contract
    /// @param _newOwner The new owner of the contract
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

// File: contracts/RegXAddr.sol

contract RegXAddr is Ownerable {

  bool public registable;
  ERC20Basic private atxToken;

  address[] public ethAddrs;
  mapping (address => address) public eth2xbc;

  constructor () public {
    atxToken = ERC20Basic(0x1A0F2aB46EC630F9FD638029027b552aFA64b94c);
  }

  function setRegistable(bool _registable) public onlyOwner {
    registable = _registable;
  }

  function registeredCount() public view returns (uint256) {
    return ethAddrs.length;
  }
  
  function xbc2eth(address _xaddr) public view returns (address) {
    require(_xaddr != 0x0);
      
    for(uint i=0; i<ethAddrs.length; i++) {
      if(eth2xbc[ethAddrs[i]] == _xaddr) {
	return ethAddrs[i];
      }
    }
    return 0x0;
  }

  function registerXAddress (address _xaddr) public returns (bool){
    require(registable);
    require(_xaddr != 0x0);
    require(msg.sender != 0x0);

    uint256 atxBalance = atxToken.balanceOf(msg.sender);
    require(atxBalance > 0);
      
    if(eth2xbc[msg.sender] == 0x0) {
      ethAddrs.push(msg.sender);
    }
    eth2xbc[msg.sender] = _xaddr;

    emit RegisterXAddress(msg.sender, _xaddr, atxBalance);
    return true;
  }

  function reset() public onlyOwner {
    for(uint i=0; i<ethAddrs.length; i++) {
      delete eth2xbc[ ethAddrs[i] ];
    }
    delete ethAddrs;
  }


  event RegisterXAddress (address indexed ethaddr, address indexed xbcaddr, uint256 balance);
}