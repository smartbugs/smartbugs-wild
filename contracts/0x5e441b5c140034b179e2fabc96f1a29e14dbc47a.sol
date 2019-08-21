pragma solidity ^0.4.8;

/**
 * Climatecoin extended ERC20 token contract created on February the 17th, 2018 by Rincker Productions in the Netherlands 
 *
 * For terms and conditions visit https://climatecoin.eu
 */

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == 0x0) revert();
        owner = newOwner;
    }
}

/**
 * Overflow aware uint math functions.
 */
contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  /*function assert(bool assertion) internal {
    if (!assertion) revert();
  }*/
}

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;


    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/* ClimateCoin Contract */
contract ClimateCoinToken is owned, SafeMath, StandardToken {
    string public code = "CLI";                                     // Set the name for display purposes
    string public name = "ClimateCoin";                                     // Set the name for display purposes
    string public symbol = "К";                                             // Set the symbol for display purposes U+041A HTML-code: &#1050;
    address public ClimateCoinAddress = this;                               // Address of the ClimateCoin token
    uint8 public decimals = 2;                                              // Amount of decimals for display purposes
    uint256 public totalSupply = 10000000;                                  // Set total supply of ClimateCoins (eight trillion)
    uint256 public buyPriceEth = 1 finney;                                  // Buy price for ClimateCoins
    uint256 public sellPriceEth = 1 finney;                                 // Sell price for ClimateCoins
    uint256 public gasForCLI = 5 finney;                                    // Eth from contract against CLI to pay tx (10 times sellPriceEth)
    uint256 public CLIForGas = 10;                                          // CLI to contract against eth to pay tx
    uint256 public gasReserve = 0.2 ether;                                    // Eth amount that remains in the contract for gas and can't be sold
    uint256 public minBalanceForAccounts = 10 finney;                       // Minimal eth balance of sender and recipient
    bool public directTradeAllowed = false;                                 // Halt trading CLI by sending to the contract directly
    
    /* include mintable */
    
    event Mint(address indexed to, uint value);
    event MintFinished();

    bool public mintingFinished = false;
    
     modifier canMint() {
    if(mintingFinished) revert();
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint _amount) public onlyOwner canMint returns (bool) {
    totalSupply = safeAdd(totalSupply,_amount);
    balances[_to] = safeAdd(balances[_to],_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
  /* end mintable */


/* Initializes contract with initial supply tokens to the creator of the contract */
    function ClimateCoinToken() public {
        balances[msg.sender] = totalSupply;                                 // Give the creator all tokens
    }


/* Constructor parameters */
    function setEtherPrices(uint256 newBuyPriceEth, uint256 newSellPriceEth) onlyOwner public {
        buyPriceEth = newBuyPriceEth;                                       // Set prices to buy and sell CLI
        sellPriceEth = newSellPriceEth;
    }
    function setGasForCLI(uint newGasAmountInWei) onlyOwner public {
        gasForCLI = newGasAmountInWei;
    }
    function setCLIForGas(uint newCLIAmount) onlyOwner public {
        CLIForGas = newCLIAmount;
    }
    function setGasReserve(uint newGasReserveInWei) onlyOwner public {
        gasReserve = newGasReserveInWei;
    }
    function setMinBalance(uint minimumBalanceInWei) onlyOwner public {
        minBalanceForAccounts = minimumBalanceInWei;
    }


/* Halts or unhalts direct trades without the sell/buy functions below */
    function haltDirectTrade() onlyOwner public {
        directTradeAllowed = false;
    }
    function unhaltDirectTrade() onlyOwner public {
        directTradeAllowed = true;
    }


/* Transfer function extended by check of eth balances and pay transaction costs with CLI if not enough eth */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (_value < CLIForGas) revert();                                      // Prevents drain and spam
        if (msg.sender != owner && _to == ClimateCoinAddress && directTradeAllowed) {
            sellClimateCoinsAgainstEther(_value);                             // Trade ClimateCoins against eth by sending to the token contract
            return true;
        }

        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {               // Check if sender has enough and for overflows
            balances[msg.sender] = safeSub(balances[msg.sender], _value);   // Subtract CLI from the sender

            if (msg.sender.balance >= minBalanceForAccounts && _to.balance >= minBalanceForAccounts) {    // Check if sender can pay gas and if recipient could
                balances[_to] = safeAdd(balances[_to], _value);             // Add the same amount of CLI to the recipient
                Transfer(msg.sender, _to, _value);                          // Notify anyone listening that this transfer took place
                return true;
            } else {
                balances[this] = safeAdd(balances[this], CLIForGas);        // Pay CLIForGas to the contract
                balances[_to] = safeAdd(balances[_to], safeSub(_value, CLIForGas));  // Recipient balance -CLIForGas
                Transfer(msg.sender, _to, safeSub(_value, CLIForGas));      // Notify anyone listening that this transfer took place

                if(msg.sender.balance < minBalanceForAccounts) {
                    if(!msg.sender.send(gasForCLI)) revert();                  // Send eth to sender
                  }
                if(_to.balance < minBalanceForAccounts) {
                    if(!_to.send(gasForCLI)) revert();                         // Send eth to recipient
                }
            }
        } else { revert(); }
    }


/* User buys ClimateCoins and pays in Ether */
    function buyClimateCoinsAgainstEther() public payable returns (uint amount) {
        if (buyPriceEth == 0 || msg.value < buyPriceEth) revert();             // Avoid dividing 0, sending small amounts and spam
        amount = msg.value / buyPriceEth;                                   // Calculate the amount of ClimateCoins
        if (balances[this] < amount) revert();                                 // Check if it has enough to sell
        balances[msg.sender] = safeAdd(balances[msg.sender], amount);       // Add the amount to buyer's balance
        balances[this] = safeSub(balances[this], amount);                   // Subtract amount from ClimateCoin balance
        Transfer(this, msg.sender, amount);                                 // Execute an event reflecting the change
        return amount;
    }


/* User sells ClimateCoins and gets Ether */
    function sellClimateCoinsAgainstEther(uint256 amount) public returns (uint revenue) {
        if (sellPriceEth == 0 || amount < CLIForGas) revert();                // Avoid selling and spam
        if (balances[msg.sender] < amount) revert();                           // Check if the sender has enough to sell
        revenue = safeMul(amount, sellPriceEth);                            // Revenue = eth that will be send to the user
        if (safeSub(this.balance, revenue) < gasReserve) revert();             // Keep min amount of eth in contract to provide gas for transactions
        if (!msg.sender.send(revenue)) {                                    // Send ether to the seller. It's important
            revert();                                                          // To do this last to avoid recursion attacks
        } else {
            balances[this] = safeAdd(balances[this], amount);               // Add the amount to ClimateCoin balance
            balances[msg.sender] = safeSub(balances[msg.sender], amount);   // Subtract the amount from seller's balance
            Transfer(this, msg.sender, revenue);                            // Execute an event reflecting on the change
            return revenue;                                                 // End function and returns
        }
    }


/* refund to owner */
    function refundToOwner (uint256 amountOfEth, uint256 cli) public onlyOwner {
        uint256 eth = safeMul(amountOfEth, 1 ether);
        if (!msg.sender.send(eth)) {                                        // Send ether to the owner. It's important
            revert();                                                          // To do this last to avoid recursion attacks
        } else {
            Transfer(this, msg.sender, eth);                                // Execute an event reflecting on the change
        }
        if (balances[this] < cli) revert();                                    // Check if it has enough to sell
        balances[msg.sender] = safeAdd(balances[msg.sender], cli);          // Add the amount to buyer's balance
        balances[this] = safeSub(balances[this], cli);                      // Subtract amount from seller's balance
        Transfer(this, msg.sender, cli);                                    // Execute an event reflecting the change
    }

/* This unnamed function is called whenever someone tries to send ether to it and possibly sells ClimateCoins */
    function() public payable {
        if (msg.sender != owner) {
            if (!directTradeAllowed) revert();
            buyClimateCoinsAgainstEther();                                    // Allow direct trades by sending eth to the contract
        }
    }
}