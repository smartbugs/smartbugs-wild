pragma solidity ^0.4.25;


contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
   
}

contract Escrow {
  
  event Deposit(uint tokens);
  address dai_0x_address = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; // ContractA Address
  mapping ( address => uint256 ) public balances;

  function deposit(uint tokens) public returns (bool success){
    // add the deposited tokens into existing balance 
    balances[msg.sender]+= tokens;
    // transfer the tokens from the sender to this contract
    ERC20(dai_0x_address).transferFrom(msg.sender, address(this), tokens);
    emit Deposit(tokens);
    return true;
  }

  function withdraw(uint256 tokens) public {
        require(balances[msg.sender] >= tokens, "Insufficient balance.");
        balances[msg.sender] -= tokens;
        ERC20(dai_0x_address).transfer(msg.sender, tokens);
  }
  
  function reallocate(address to, uint256 tokens) public {
        require(balances[msg.sender] >= tokens, "Insufficient balance.");
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
   }

}