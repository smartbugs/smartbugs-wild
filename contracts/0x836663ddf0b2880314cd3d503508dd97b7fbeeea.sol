pragma solidity ^0.4.18;

contract CyberShekel {

  uint8 Decimals = 0;
  uint256 total_supply = 1000000000000;
  address owner;

  function CyberShekel() public{
    owner = msg.sender;
    balanceOf[msg.sender] = total_supply;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 value);
  event Approval(address indexed _owner, address indexed _spender, uint256 value);

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;


  function name() pure public returns (string _name){
    return "CyberShekel";
  }

  function symbol() pure public returns (string _symbol){
    return "CSK";
  }

  function decimals() view public returns (uint8 _decimals){
    return Decimals;
  }

  function totalSupply() public constant returns (uint256 total){
      return total_supply;
  }

  function balanceOf(address tokenOwner) public constant returns (uint256 balance){
    return balanceOf[tokenOwner];
  }

  function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining){
    return allowance[tokenOwner][spender];
  }

  function transfer(address recipient, uint256 value) public returns (bool success){
    require(balanceOf[msg.sender] >= value);
    require(balanceOf[recipient] + value >= balanceOf[recipient]);
    balanceOf[msg.sender] -= value;
    balanceOf[recipient] += value;
    Transfer(msg.sender, recipient, value);

    return true;
  }

  function approve(address spender, uint256 value) public returns (bool success){
    allowance[msg.sender][spender] = value;
    Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address recipient, uint256 value) public
      returns (bool success){
    require(balanceOf[from] >= value);                                          //ensure from address has available balance
    require(balanceOf[recipient] + value >= balanceOf[recipient]);              //stop overflow
    require(value <= allowance[from][msg.sender]);                              //ensure msg.sender has enough allowance
    balanceOf[from] -= value;
    balanceOf[recipient] += value;
    allowance[from][msg.sender] -= value;
    Transfer(from, recipient, value);

    return true;
  }
  
}