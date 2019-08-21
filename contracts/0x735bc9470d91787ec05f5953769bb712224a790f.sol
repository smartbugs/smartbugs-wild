pragma solidity ^0.5.4;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


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

contract MultiSend {
  function multiSend(address _token, address[] memory addresses, uint amount) public {
    ERC20 token = ERC20(_token);
    for(uint i = 0; i < addresses.length; i++) {
      require(token.transferFrom(msg.sender, addresses[i], amount));
    }
  }
  
  function multiSendEth(address payable[] memory addresses, uint[] memory values) public payable {
    for(uint i = 0; i < addresses.length; i++) {
      addresses[i].transfer(values[i]);
    }
    msg.sender.transfer(address(this).balance);
  }
  
  function multiSendEthEqual(address payable[] memory addresses, uint amount) public payable {
    for(uint i = 0; i < addresses.length; i++) {
      addresses[i].transfer(amount);
    }
    msg.sender.transfer(address(this).balance);
  }
}