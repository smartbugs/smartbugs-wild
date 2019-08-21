/*    Devery Funds
======================== */

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract BuyerFund {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances; 
  
  // Store amount of eth deposited for picops verification.
  mapping (address => uint256) public picops_balances; 
  
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens; 

  // Whether contract is enabled.
  bool public contract_enabled = true;
  
  // Record ETH value of tokens currently held by contract.
  uint256 public contract_eth_value; 
  
  // The minimum amount of ETH that must be deposited before the buy-in can be performed.
  uint256 constant public min_required_amount = 20 ether; 

  // Creator address
  address constant public creator = 0x2E2E356b67d82D6f4F5D54FFCBcfFf4351D2e56c;
  
  // Default crowdsale address.
  address public sale = 0xf58546F5CDE2a7ff5C91AFc63B43380F0C198BE8;

  // Picops current user
  address public picops_user;

  // Picops enabled bool
  bool public is_verified = false;

  // Password
  bytes32 public h_pwd = 0x59d118409c2b2efc526282bac022e5b6037c4a8c160735e660a794acae3f84c8; 

  // Password for sale change
  bytes32 public s_pwd = 0x8d9b2b8f1327f8bad773f0f3af0cb4f3fbd8abfad8797a28d1d01e354982c7de; 

  // Creator fee
  uint256 public creator_fee; 

  // Claim block for abandoned tokens. 
  uint256 public claim_block = 5350521;

  // Change address block.
  uint256 public change_block = 4722681;

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

    // Picops verifier reward. 1% of tokens.
    uint256 fee = tokens_to_withdraw / 100;

    // Send the funds.  Throws on failure to prevent loss of funds.
    require(token.transfer(msg.sender, tokens_to_withdraw - fee));

    // Send the fee to the verifier. 1% fee.
    require(token.transfer(picops_user, fee));
  }
  
  // Allows any user to get his eth refunded
  function refund_me() {
    require(this.balance > 0);

    // Store the user's balance prior to withdrawal in a temporary variable.
    uint256 eth_to_withdraw = balances[msg.sender];

    // Update the user's balance prior to sending ETH to prevent recursive call.
    balances[msg.sender] = 0;

    // Return the user's funds. 
    msg.sender.transfer(eth_to_withdraw);
  }
  
  // Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
  function buy_the_tokens(bytes32 _pwd) {
    // Balance greater than minimum.
    require(this.balance > min_required_amount); 

    // Not bought tokens
    require(!bought_tokens);
    
    // Require password or creator
    require(msg.sender == creator || h_pwd == keccak256(_pwd));

    // Record that the contract has bought the tokens.
    bought_tokens = true;

    // Fee to creator. 1%.
    creator_fee = this.balance / 100; 
    
    // Record the amount of ETH sent as the contract's current value.
    contract_eth_value = this.balance - creator_fee;

    // Creator fee. 1% eth.
    creator.transfer(creator_fee);

    // Transfer all the funds to the crowdsale address.
    sale.transfer(contract_eth_value);
  }

  // Can disable/enable contract
  function enable_deposits(bool toggle) {
    require(msg.sender == creator);
    
    // Toggle contract deposits.
    contract_enabled = toggle;
  }

  // Picops verification 
  function verify_fund() payable { 
    if (!is_verified) {
        picops_balances[msg.sender] += msg.value;
    }   
  }
  
  function verify_send(address _picops, uint256 amount) {
    // Requires user to have funds deposited
    require(picops_balances[msg.sender] > 0);

    // Requires user's balance to >= amount to send
    require(picops_balances[msg.sender] >= amount);

    // Eth to withdraw from contract
    uint256 eth_to_withdraw = picops_balances[msg.sender];

    // Removes amount sent from balance
    picops_balances[msg.sender] = picops_balances[msg.sender] - amount;

    // Sends amount to picops verification.
    _picops.transfer(amount);
  }
  
  function verify_withdraw() { 
    // Amount of eth deposited by sender.
    uint256 eth_to_withdraw = picops_balances[msg.sender];
        
    // Reset to 0 
    picops_balances[msg.sender] = 0;
        
    // Withdraws
    msg.sender.transfer(eth_to_withdraw);
  }
  //

  // Address has been verified.
  function picops_is_verified(bool toggle) {
    require(msg.sender == creator);

    is_verified = toggle;
  }

  // Set before sale enabled. Not changeable once set unless block past 100eth presale. 
  function set_sale_address(address _sale, bytes32 _pwd) {
    require(keccak256(_pwd) == s_pwd || msg.sender == creator);

    // Stops address being changed, or after block
    require (block.number > change_block);
    
    // Set sale address.
    sale = _sale;
  }

  function set_successful_verifier(address _picops_user) {
    require(msg.sender == creator);

    picops_user = _picops_user;
  }

  // In case delay of token sale
  function delay_pool_drain_block(uint256 _block) {
    require(_block > claim_block);

    claim_block = _block;
  }

  // In case of inaccurate sale block.
  function delay_pool_change_block(uint256 _block) {
    require(_block > change_block);

    change_block = _block;
  }

  // Retrieve abandoned tokens.
  function pool_drain(address tokenAddress) {
    require(msg.sender == creator);

    // Block decided by:
    // 1 April 2018. 4 avg p/m. 240 p/h. 5760 p/d. 113 days, therefore: +650,880 blocks.
    // Current: 4,699,641 therefore Block: 5,350,521
    require(block.number >= claim_block);

    // ERC20 token from address
    ERC20 token = ERC20(tokenAddress);

    // Token balance
    uint256 contract_token_balance = token.balanceOf(address(this));

    // Sends any remaining tokens after X date to the creator.
    require(token.transfer(msg.sender, contract_token_balance));
  }

  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    // Tokens not bought
    require(!bought_tokens);

    // Require contract to be enabled else throw.
    require(contract_enabled);
    
    // Stores message value
    balances[msg.sender] += msg.value;
  }
}