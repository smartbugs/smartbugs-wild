// Author : shift

pragma solidity ^0.4.13;

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

/*
  This contract stores twice every key value in order to be able to redistribute funds
  when the bonus tokens are received (which is typically X months after the initial buy).
*/

contract SECRETSanity {

  modifier onlyOwner {
    require(msg.sender == developer);
    _;
  }

  //Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  mapping (address => uint256) public balances_bonus;
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens = false;
  // Record ETH value of tokens currently held by contract.
  uint256 public contract_eth_value;
  uint256 public contract_eth_value_bonus;
  //Set by the owner in order to allow the withdrawal of bonus tokens.
  bool bonus_received;
  //The address of the contact.
  address public sale = 0x6997f780521E233130249fc00bD7e0a7F2ddbbCF;
  // Token address
  ERC20 public token;
  address constant public developer = 0xEE06BdDafFA56a303718DE53A5bc347EfbE4C68f;
  uint256 fees;
  
  // Allows any user to withdraw his tokens.
  function withdraw() {
    // Disallow withdraw if tokens haven't been bought yet.
    require(bought_tokens);
    uint256 contract_token_balance = token.balanceOf(address(this));
    // Disallow token withdrawals if there are no tokens to withdraw.
    require(contract_token_balance != 0);
    uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
    // Update the value of tokens currently held by the contract.
    contract_eth_value -= balances[msg.sender];
    // Update the user's balance prior to sending to prevent recursive call.
    balances[msg.sender] = 0;
    // Send the funds.  Throws on failure to prevent loss of funds.
    require(token.transfer(msg.sender, tokens_to_withdraw));
  }

  function withdraw_bonus() {
  /*
    Special function to withdraw the bonus tokens after the 6 months lockup.
    bonus_received has to be set to true.
  */
    require(bought_tokens);
    require(bonus_received);
    uint256 contract_token_balance = token.balanceOf(address(this));
    require(contract_token_balance != 0);
    uint256 tokens_to_withdraw = (balances_bonus[msg.sender] * contract_token_balance) / contract_eth_value_bonus;
    contract_eth_value_bonus -= balances_bonus[msg.sender];
    balances_bonus[msg.sender] = 0;
    require(token.transfer(msg.sender, tokens_to_withdraw));
  }
  
  // Allows any user to get his eth refunded before the purchase is made.
  function refund_me() {
    require(!bought_tokens);
    // Store the user's balance prior to withdrawal in a temporary variable.
    uint256 eth_to_withdraw = balances[msg.sender];
    // Update the user's balance prior to sending ETH to prevent recursive call.
    balances[msg.sender] = 0;
    //Updates the balances_bonus too
    balances_bonus[msg.sender] = 0;
    // Return the user's funds.  Throws on failure to prevent loss of funds.
    msg.sender.transfer(eth_to_withdraw);
  }
  
  // Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
  function buy_the_tokens() onlyOwner {
    require(!bought_tokens);
    require(sale != 0x0);
    //Record that the contract has bought the tokens.
    bought_tokens = true;
    //Sent before so the contract_eth_value contains the correct balance
    developer.transfer(fees);
    //Record the amount of ETH sent as the contract's current value.
    contract_eth_value = this.balance;
    contract_eth_value_bonus = this.balance;
    // Transfer all the funds to the crowdsale address.
    sale.transfer(contract_eth_value);
  }
  
  function set_token_address(address _token) onlyOwner {
    require(_token != 0x0);
    token = ERC20(_token);
  }

  function set_bonus_received() onlyOwner {
    bonus_received = true;
  }

  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    require(!bought_tokens);
    //Fee is taken on the ETH
    uint256 fee = msg.value / 50;
    fees += fee;
    //Updates both of the balances
    balances[msg.sender] += (msg.value-fee);
    balances_bonus[msg.sender] += (msg.value-fee);
  }
}