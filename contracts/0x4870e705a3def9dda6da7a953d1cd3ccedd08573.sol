pragma solidity ^0.4.11;

/**
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

/*
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

  mapping (address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

/*
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/// @title Moeda Loaylty Points token contract
contract MoedaToken is StandardToken, Ownable {
    string public constant name = "Moeda Loyalty Points";
    string public constant symbol = "MDA";
    uint8 public constant decimals = 18;

    // don't allow creation of more than this number of tokens
    uint public constant MAX_TOKENS = 20000000 ether;
    
    // transfers are locked during the sale
    bool public saleActive;

    // only emitted during the crowdsale
    event Created(address indexed donor, uint256 tokensReceived);

    // determine whether transfers can be made
    modifier onlyAfterSale() {
        if (saleActive) {
            throw;
        }
        _;
    }

    modifier onlyDuringSale() {
        if (!saleActive) {
            throw;
        }
        _;
    }

    /// @dev Create moeda token and lock transfers
    function MoedaToken() {
        saleActive = true;
    }

    /// @dev unlock transfers
    function unlock() onlyOwner {
        saleActive = false;
    }

    /// @dev create tokens, only usable while saleActive
    /// @param recipient address that will receive the created tokens
    /// @param amount the number of tokens to create
    function create(address recipient, uint256 amount)
    onlyOwner onlyDuringSale {
        if (amount == 0) throw;
        if (safeAdd(totalSupply, amount) > MAX_TOKENS) throw;

        balances[recipient] = safeAdd(balances[recipient], amount);
        totalSupply = safeAdd(totalSupply, amount);

        Created(recipient, amount);
    }

    // transfer tokens
    // only allowed after sale has ended
    function transfer(address _to, uint _value) onlyAfterSale returns (bool) {
        return super.transfer(_to, _value);
    }

    // transfer tokens
    // only allowed after sale has ended
    function transferFrom(address from, address to, uint value) onlyAfterSale 
    returns (bool)
    {
        return super.transferFrom(from, to, value);
    }
}

/// @title Moeda crowdsale
contract Crowdsale is Ownable, SafeMath {
    bool public crowdsaleClosed;        // whether the crowdsale has been closed 
                                        // manually
    address public wallet;              // recipient of all crowdsale funds
    MoedaToken public moedaToken;       // token that will be sold during sale
    uint256 public etherReceived;       // total ether received
    uint256 public totalTokensSold;     // number of tokens sold
    uint256 public startBlock;          // block where sale starts
    uint256 public endBlock;            // block where sale ends

    // used to scale token amounts to 18 decimals
    uint256 public constant TOKEN_MULTIPLIER = 10 ** 18;

    // number of tokens allocated to presale (prior to crowdsale)
    uint256 public constant PRESALE_TOKEN_ALLOCATION = 5000000 * TOKEN_MULTIPLIER;

    // recipient of presale tokens
    address public PRESALE_WALLET = "0x30B3C64d43e7A1E8965D934Fa96a3bFB33Eee0d2";
    
    // smallest possible donation
    uint256 public constant DUST_LIMIT = 1 finney;

    // token generation rates (tokens per eth)
    uint256 public constant TIER1_RATE = 160;
    uint256 public constant TIER2_RATE = 125;
    uint256 public constant TIER3_RATE = 80;

    // limits for each pricing tier (how much can be bought)
    uint256 public constant TIER1_CAP =  31250 ether;
    uint256 public constant TIER2_CAP =  71250 ether;
    uint256 public constant TIER3_CAP = 133750 ether; // Total ether cap

    // Log a purchase
    event Purchase(address indexed donor, uint256 amount, uint256 tokenAmount);

    // Log transfer of tokens that were sent to this contract by mistake
    event TokenDrain(address token, address to, uint256 amount);

    modifier onlyDuringSale() {
        if (crowdsaleClosed) {
            throw;
        }

        if (block.number < startBlock) {
            throw;
        }

        if (block.number >= endBlock) {
            throw;
        }
        _;
    }

    /// @dev Initialize a new Crowdsale contract
    /// @param _wallet address of multisig wallet that will store received ether
    /// @param _startBlock block at which to start the sale
    /// @param _endBlock block at which to end the sale
    function Crowdsale(address _wallet, uint _startBlock, uint _endBlock) {
        if (_wallet == address(0)) throw;
        if (_startBlock <= block.number) throw;
        if (_endBlock <= _startBlock) throw;
        
        crowdsaleClosed = false;
        wallet = _wallet;
        moedaToken = new MoedaToken();
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    /// @dev Determine the lowest rate to acquire tokens given an amount of 
    /// donated ethers
    /// @param totalReceived amount of ether that has been received
    /// @return pair of the current tier's donation limit and a token creation rate
    function getLimitAndPrice(uint256 totalReceived)
    constant returns (uint256, uint256) {
        uint256 limit = 0;
        uint256 price = 0;

        if (totalReceived < TIER1_CAP) {
            limit = TIER1_CAP;
            price = TIER1_RATE;
        }
        else if (totalReceived < TIER2_CAP) {
            limit = TIER2_CAP;
            price = TIER2_RATE;
        }
        else if (totalReceived < TIER3_CAP) {
            limit = TIER3_CAP;
            price = TIER3_RATE;
        } else {
            throw; // this shouldn't happen
        }

        return (limit, price);
    }

    /// @dev Determine how many tokens we can get from each pricing tier, in
    /// case a donation's amount overlaps multiple pricing tiers.
    ///
    /// @param totalReceived ether received by contract plus spent by this donation
    /// @param requestedAmount total ether to spend on tokens in a donation
    /// @return amount of tokens to get for the requested ether donation
    function getTokenAmount(uint256 totalReceived, uint256 requestedAmount) 
    constant returns (uint256) {

        // base case, we've spent the entire donation and can stop
        if (requestedAmount == 0) return 0;
        uint256 limit = 0;
        uint256 price = 0;
        
        // 1. Determine cheapest token price
        (limit, price) = getLimitAndPrice(totalReceived);

        // 2. Since there are multiple pricing levels based on how much has been
        // received so far, we need to determine how much can be spent at
        // any given tier. This in case a donation will overlap more than one 
        // tier
        uint256 maxETHSpendableInTier = safeSub(limit, totalReceived);
        uint256 amountToSpend = min256(maxETHSpendableInTier, requestedAmount);

        // 3. Given a price determine how many tokens the unspent ether in this 
        // donation will get you
        uint256 tokensToReceiveAtCurrentPrice = safeMul(amountToSpend, price);

        // You've spent everything you could at this level, continue to the next
        // one, in case there is some ETH left unspent in this donation.
        uint256 additionalTokens = getTokenAmount(
            safeAdd(totalReceived, amountToSpend),
            safeSub(requestedAmount, amountToSpend));

        return safeAdd(tokensToReceiveAtCurrentPrice, additionalTokens);
    }

    /// grant tokens to buyer when we receive ether
    /// @dev buy tokens, only usable while crowdsale is active
    function () payable onlyDuringSale {
        if (msg.value < DUST_LIMIT) throw;
        if (safeAdd(etherReceived, msg.value) > TIER3_CAP) throw;

        uint256 tokenAmount = getTokenAmount(etherReceived, msg.value);

        moedaToken.create(msg.sender, tokenAmount);
        etherReceived = safeAdd(etherReceived, msg.value);
        totalTokensSold = safeAdd(totalTokensSold, tokenAmount);
        Purchase(msg.sender, msg.value, tokenAmount);

        if (!wallet.send(msg.value)) throw;
    }

    /// @dev close the crowdsale manually and unlock the tokens
    /// this will only be successful if not already executed,
    /// if endBlock has been reached, or if the cap has been reached
    function finalize() onlyOwner {
        if (block.number < startBlock) throw;
        if (crowdsaleClosed) throw;

        // if amount remaining is too small we can allow sale to end earlier
        uint256 amountRemaining = safeSub(TIER3_CAP, etherReceived);
        if (block.number < endBlock && amountRemaining >= DUST_LIMIT) throw;

        // create and assign presale tokens to presale wallet
        moedaToken.create(PRESALE_WALLET, PRESALE_TOKEN_ALLOCATION);

        // unlock tokens for spending
        moedaToken.unlock();
        crowdsaleClosed = true;
    }

    /// @dev Drain tokens that were sent here by mistake
    /// because people will.
    /// @param _token address of token to transfer
    /// @param _to address where tokens will be transferred
    function drainToken(address _token, address _to) onlyOwner {
        if (_token == address(0)) throw;
        if (_to == address(0)) throw;
        ERC20 token = ERC20(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(_to, balance);
        TokenDrain(_token, _to, balance);
    }
}