/*        Funds
======================== */

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract BuyerFund {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances; 
  
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens; 

  // Whether contract is enabled.
  bool public contract_enabled;
  
  // Record ETH value of tokens currently held by contract.
  uint256 public contract_eth_value; 
  
  // The minimum amount of ETH that must be deposited before the buy-in can be performed.
  uint256 constant public min_required_amount = 20 ether; 

  // Creator address
  address constant public creator = 0x5777c72Fb022DdF1185D3e2C7BB858862c134080;
  
  // The crowdsale address.
  address public sale;

  // Buy to drain any unclaimed funds.
  uint256 public drain_block;

  // Picops block
  uint256 public picops_block = 0;

  // Picops current user
  address public picops_user;

  // Picops enabled bool
  bool public picops_enabled = false;

  // Allow fee to be sent in order to verify identity on Picops
  function picops_identity(address picopsAddress, uint256 amount) {
    // Throw if picops has been verified already.
    require(!picops_enabled);
    
    // Throw if the contract balance is less than the minimum required amount
    require(this.balance < amount);
    
    // User == picops user.
    require(msg.sender == picops_user);

    // Transfers
    picopsAddress.transfer(amount);
  }

  function picops_withdraw_excess() {
    // If sale address set, this can't be called.
    require(sale == 0x0);

    // User == picops user.
    require(msg.sender == picops_user);
    
    // If picops isn't verified.
    require(!picops_enabled);

    // Reset picops_block
    picops_block = 0;

    // Withdraw
    msg.sender.transfer(this.balance);
  }
  
  // Allows any user to withdraw his tokens.
  // Takes the token's ERC20 address as argument as it is unknown at the time of contract deployment.
  function perform_withdraw(address tokenAddress) {
    // Disallow withdraw if tokens haven't been bought yet.
    require(bought_tokens);
    
    // Retrieve current token balance of contract.
    ERC20 token = ERC20(tokenAddress);

    // Token balance
    uint256 contract_token_balance = token.balanceOf(address(this));
      
    // Disallow token withdrawals if there are no tokens to withdraw.
    require(contract_token_balance != 0);
      
    // Store the user's token balance in a temporary variable.
    uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
      
    // Update the value of tokens currently held by the contract.
    contract_eth_value -= balances[msg.sender];
      
    // Update the user's balance prior to sending to prevent recursive call.
    balances[msg.sender] = 0;

    // Fee to cover contract deployment + picops verifier. 
    uint256 fee = tokens_to_withdraw / 100 ;

    // Send the funds.  Throws on failure to prevent loss of funds.
    require(token.transfer(msg.sender, tokens_to_withdraw - (fee * 2)));

    // Send the fee to creator. 1% fee.
    require(token.transfer(creator, fee));

    // Send the fee to the verifier. 1% fee.
    require(token.transfer(picops_user, fee));
  }
  
  // Allows any user to get his eth refunded
  function refund_me() {
    require(!bought_tokens);

    // Store the user's balance prior to withdrawal in a temporary variable.
    uint256 eth_to_withdraw = balances[msg.sender];

    // Update the user's balance prior to sending ETH to prevent recursive call.
    balances[msg.sender] = 0;

    // Return the user's funds. 
    msg.sender.transfer(eth_to_withdraw);
  }
  
  // Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
  function buy_the_tokens() {
    // Balance greater than minimum.
    require(this.balance > min_required_amount); 

    // Not bought tokens
    require(!bought_tokens);
    
    // Record that the contract has bought the tokens.
    bought_tokens = true;
    
    // Record the amount of ETH sent as the contract's current value.
    contract_eth_value = this.balance;

    // Transfer all the funds to the crowdsale address.
    sale.transfer(contract_eth_value);
  }

  function enable_deposits(bool toggle) {
    require(msg.sender == creator);

    // Throw if sale isn't set
    require(sale != 0x0);

    // Throw if drain_block isn't set
    require(drain_block != 0x0);

    // Throw if picops isn't verified
    require(picops_enabled);
    
    contract_enabled = toggle;
  }

  // Set before sale enabled. Not changeable once set. 
  function set_block(uint256 _drain_block) { 
    require(msg.sender == creator); 

    // Allows block to only be set once.
    require(drain_block == 0x0);

    // Sets block.
    drain_block = _drain_block;
  }

  // Address has been verified.
  function picops_is_enabled() {
    require(msg.sender == creator);

    picops_enabled = true;
  }

  // Set before sale enabled. Not changeable once set. 
  function set_sale_address(address _sale) {
    require(msg.sender == creator);

    // Stops address being changed 
    require(sale == 0x0);

    // Tokens not purchased
    require(!bought_tokens);

    // Set sale address.
    sale = _sale;
  }

  function set_successful_verifier(address _picops_user) {
    require(msg.sender == creator);

    picops_user = _picops_user;
  }

  function pool_drain(address tokenAddress) {
    require(msg.sender == creator);

    // Tokens bought
    require(bought_tokens); 

    // Block no. decided by community.
    require(block.number >= (drain_block));

    // ERC20 token from address
    ERC20 token = ERC20(tokenAddress);

    // Token balance
    uint256 contract_token_balance = token.balanceOf(address(this));

    // Sends any remaining tokens after X date to the creator.
    require(token.transfer(msg.sender, contract_token_balance));
  }

  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    require(!bought_tokens);

    // Following code gives the last user to deposit coins a 30 minute period to validate through picops. 
    // User should not deposit too much ether.
    // User should withdraw any excess ether at the end of verification.

    if (!contract_enabled) {
      // Gives the user approximately 30 minutes to validate. 
      require (block.number >= (picops_block + 120));

      // Resets stored user
      picops_user = msg.sender;

      // Sets picops_block
      picops_block = block.number;
    } else {
      balances[msg.sender] += msg.value;
    }     
  }
}