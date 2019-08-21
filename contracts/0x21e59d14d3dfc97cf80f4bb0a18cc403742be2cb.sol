/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 5, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract ERC20Basic {}
contract ERC20 is ERC20Basic {}
contract Ownable {}
contract BasicToken is ERC20Basic {}
contract StandardToken is ERC20, BasicToken {}
contract Pausable is Ownable {}
contract PausableToken is StandardToken, Pausable {}
contract MintableToken is StandardToken, Ownable {}

contract PDataToken is MintableToken, PausableToken {
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool);
  function balanceOf(address who) public view returns (uint256);
}

contract SVPContract {
  //storage
  address public owner;
  PDataToken public saved_token;

  //modifiers
  modifier onlyOwner
  {
    require(owner == msg.sender);
    _;
  }
  
  
  //Events
  event Transfer(address indexed to, uint indexed value);
  event OwnerChanged(address indexed owner);


  //constructor
  constructor (PDataToken _company_token) public {
    owner = msg.sender;
    saved_token = _company_token;
  }


  /// @dev Fallback function: don't accept ETH
  function()
    public
    payable
  {
    revert();
  }

  function setOwner(address _owner) 
    public 
    onlyOwner 
  {
    require(_owner != 0);
    
    owner = _owner;
    emit OwnerChanged(owner);
  }
  
  function sendPayment(uint256 amount, address final_account) 
  public 
  onlyOwner {
    saved_token.transfer(final_account, amount);
    emit Transfer(final_account, amount);
  }
}