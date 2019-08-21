pragma solidity ^0.4.6;

contract token { 
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    
	string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	
    mapping (address => uint256) public coinBalanceOf;
    event CoinTransfer(address sender, address receiver, uint256 amount);

  /* Initializes contract with initial supply tokens to the creator of the contract */
  function token(
        uint256 initialSupply,	
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        coinBalanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return coinBalanceOf[_owner];
    }

  /* Very simple trade function */
    function sendCoin(address receiver, uint256 amount) returns(bool sufficient) {
        if (coinBalanceOf[msg.sender] < amount) return false;
        coinBalanceOf[msg.sender] -= amount;
        coinBalanceOf[receiver] += amount;
        CoinTransfer(msg.sender, receiver, amount);
        return true;
    }
}