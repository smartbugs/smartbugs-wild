pragma solidity ^0.4.17;

/*

ICO Syndicate Contract
========================

Buys ICO Tokens for a given ICO known contract address
Author: Bogdan

*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function transfer(address _to, uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract ICOSyndicate {
    // Store the amount of ETH deposited by each account.
    mapping (address => uint256) public balances;
    // Track whether the contract has bought the tokens yet.
    bool public bought_tokens;
    // Record ETH value of tokens currently held by contract.
    uint256 public contract_eth_value;
    // Emergency kill switch in case a critical bug is found.
    bool public kill_switch;

    // Maximum amount of user ETH contract will accept.  Reduces risk of hard cap related failure.
    uint256 public eth_cap = 30000 ether;
    // The developer address.
    address public developer = 0x91d97da49d3cD71B475F46d719241BD8bb6Af18f;
    // The crowdsale address.  Settable by the developer.
    address public sale;
    // The token address.  Settable by the developer.
    ERC20 public token;

    // Allows the developer to set the crowdsale and token addresses.
    function set_addresses(address _sale, address _token) public {
        // Only allow the developer to set the sale and token addresses.
        require(msg.sender == developer);
        // Only allow setting the addresses once.
        require(sale == 0x0);
        // Set the crowdsale and token addresses.
        sale = _sale;
        token = ERC20(_token);
    }

    // Allows the developer or anyone with the password to shut down everything except withdrawals in emergencies.
    function activate_kill_switch() public {
        // Only activate the kill switch if the sender is the developer or the password is correct.
        require(msg.sender == developer);
        // Irreversibly activate the kill switch.
        kill_switch = true;
    }

    // Withdraws all ETH deposited or tokens purchased by the given user and rewards the caller.
    function withdraw(address user) public {
        // Only allow withdrawals after the contract has had a chance to buy in.
        require(bought_tokens);
        // Short circuit to save gas if the user doesn't have a balance.
        if (balances[user] == 0) return;
        // If the contract failed to buy into the sale, withdraw the user's ETH.
        if (!bought_tokens) {
            // Store the user's balance prior to withdrawal in a temporary variable.
            uint256 eth_to_withdraw = balances[user];
            // Update the user's balance prior to sending ETH to prevent recursive call.
            balances[user] = 0;
            // Return the user's funds.  Throws on failure to prevent loss of funds.
            user.transfer(eth_to_withdraw);
        }
        // Withdraw the user's tokens if the contract has purchased them.
        else {
            // Retrieve current token balance of contract.
            uint256 contract_token_balance = token.balanceOf(address(this));
            // Disallow token withdrawals if there are no tokens to withdraw.
            require(contract_token_balance != 0);
            // Store the user's token balance in a temporary variable.
            uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
            // Update the value of tokens currently held by the contract.
            contract_eth_value -= balances[user];
            // Update the user's balance prior to sending to prevent recursive call.
            balances[user] = 0;
            // Send the funds.  Throws on failure to prevent loss of funds.
            require(token.transfer(user, tokens_to_withdraw));

        }

    }

    // Buys tokens in the crowdsale and rewards the caller, callable by anyone.
    function buy() public {
        // Short circuit to save gas if the contract has already bought tokens.
        if (bought_tokens) return;
        // Short circuit to save gas if kill switch is active.
        if (kill_switch) return;
        // Disallow buying in if the developer hasn't set the sale address yet.
        require(sale != 0x0);
        // Record that the contract has bought the tokens.
        bought_tokens = true;
        // Record the amount of ETH sent as the contract's current value.
        contract_eth_value = this.balance;
        // Transfer all the funds to the crowdsale address to buy tokens.
        // Throws if the crowdsale hasn't started yet or has already completed, preventing loss of funds.
        require(sale.call.value(contract_eth_value)());
    }

    // Default function.  Called when a user sends ETH to the contract.
    function () public payable {
        // Disallow deposits if kill switch is active.
        require(!kill_switch);
        // Only allow deposits if the contract hasn't already purchased the tokens.
        require(!bought_tokens);
        // Only allow deposits that won't exceed the contract's ETH cap.
        require(this.balance < eth_cap);
        // Update records of deposited ETH to include the received amount.
        balances[msg.sender] += msg.value;
    }
}