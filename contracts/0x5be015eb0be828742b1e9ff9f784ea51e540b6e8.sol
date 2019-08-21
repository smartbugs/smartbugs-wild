pragma solidity ^0.4.11;

/*
* 'LOOK' token sale contract
*
* Refer to https://lookscoin.com/ for further information.
* 
* Developer: LookRev
*
*/

/*
 * ERC20 Token Standard
 */
contract ERC20 {
    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _who) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool ok);
    function approve(address _spender, uint256 _value) returns (bool ok);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

  /**
   * Provides methods to safely add, subtract and multiply uint256 numbers.
   */
contract SafeMath {
    uint256 constant private MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Add two uint256 values, revert in case of overflow.
     *
     * @param a first value to add
     * @param b second value to add
     * @return a + b
     */
    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
        require (a <= MAX_UINT256 - b);
        return a + b;
    }

    /**
     * Subtract one uint256 value from another, throw in case of underflow.
     *
     * @param a value to subtract from
     * @param b value to subtract
     * @return a - b
     */
    function safeSub(uint256 a, uint256 b) internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    /**
     * Multiply two uint256 values, throw in case of overflow.
     *
     * @param a first value to multiply
     * @param b second value to multiply
     * @return a * b
     */
    function safeMul(uint256 a, uint256 b) internal returns (uint256) {
        if (a == 0 || b == 0) return 0;
        require (a <= MAX_UINT256 / b);
        return a * b;
    }
}

/*
    Provides support and utilities for contract ownership
*/
contract Ownable {
    address owner;
    address newOwner;

    function Ownable() {
        owner = msg.sender;
    }

    /**
     * Allows execution by the owner only.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * Transferring the contract ownership to the new owner.
     *
     * @param _newOwner new contractor owner
     */
    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != address(0)) {
          newOwner = _newOwner;
        }
    }

    /**
     * Accept the contract ownership by the new owner.
     *
     */
    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}

/**
* Standard Token Smart Contract that could be used as a base contract for
* ERC-20 token contracts.
*/
contract StandardToken is ERC20, Ownable, SafeMath {

    /**
     * Mapping from addresses of token holders to the numbers of tokens belonging
     * to these token holders.
     */
    mapping (address => uint256) balances;

    /**
     * Mapping from addresses of token holders to the mapping of addresses of
     * spenders to the allowances set by these token holders to these spenders.
     */
    mapping (address => mapping (address => uint256)) allowed;

    /**
     * Create new Standard Token contract.
     */
    function StandardToken() {
      // Do nothing
    }

    /**
     * Get number of tokens currently belonging to given owner.
     *
     * @param _owner address to get number of tokens currently belonging to the
     *        owner of
     * @return number of tokens currently belonging to the owner of given address
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * Transfer given number of tokens from message sender to given recipient.
     *
     * @param _to address to transfer tokens to the owner of
     * @param _amount number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer(address _to, uint256 _amount) returns (bool success) {
        // avoid wasting gas on 0 token transfers
        if(_amount <= 0) return false;
        if (msg.sender == _to) return false;
        if (balances[msg.sender] < _amount) return false;
        if (balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] = safeSub(balances[msg.sender],_amount);
            balances[_to] = safeAdd(balances[_to],_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        }
        return false;
    }

    /**
     * Transfer given number of tokens from given owner to given recipient.
     *
     * @param _from address to transfer tokens from the owner of
     * @param _to address to transfer tokens to the owner of
     * @param _amount number of tokens to transfer from given owner to given
     *        recipient
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
        // avoid wasting gas on 0 token transfers
        if(_amount <= 0) return false;
        if(_from == _to) return false;
        if (balances[_from] < _amount) return false;
        if (_amount > allowed[_from][msg.sender]) return false;

        balances[_from] = safeSub(balances[_from],_amount);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_amount);
        balances[_to] = safeAdd(balances[_to],_amount);
        Transfer(_from, _to, _amount);

        return false;
    }

    /**
     * Allow given spender to transfer given number of tokens from message sender.
     *
     * @param _spender address to allow the owner of to transfer tokens from
     *        message sender
     * @param _amount number of tokens to allow to transfer
     * @return true if token transfer was successfully approved, false otherwise
     */
    function approve(address _spender, uint256 _amount) returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_amount != 0) && (allowed[msg.sender][_spender] != 0)) {
           return false;
        }
        if (balances[msg.sender] < _amount) {
            return false;
        }
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
     }

    /**
     * Tell how many tokens given spender is currently allowed to transfer from
     * given owner.
     *
     * @param _owner address to get number of tokens allowed to be transferred
     *        from the owner of
     * @param _spender address to get number of tokens allowed to be transferred
     *        by the owner of
     * @return number of tokens given spender is currently allowed to transfer
     *         from given owner
     */
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }
}

/**
 * LOOK Token Sale Contract
 *
 * The token sale controller, allows contributing ether in exchange for LOOK coins.
 * The price (exchange rate with ETH) remains fixed for the entire duration of the token sale.
 * VIP ranking is recorded at the time when the token holding address first meet VIP holding level.
 * VIP ranking is valid for the lifetime of a token wallet address, as long as it meets VIP holding level.
 * VIP ranking is used to calculate priority when competing with other bids for the
 * same product or service on the platform. 
 * Higher VIP ranking (with earlier timestamp) has higher priority.
 * Higher VIP ranking address can outbid other lower ranking addresses once per selling window or promotion period.
 * Usage of the LOOK token, VIP ranking and bid priority will be described on token website.
 *
 */
contract LooksCoin is StandardToken {

    /**
     * Address of the owner of this smart contract.
     */
    address wallet = 0x0;

    /**
    * Mapping for VIP rank for qualified token holders
    * Higher VIP ranking (with earlier timestamp) has higher bidding priority when competing 
    * for the same item on platform. 
    * Higher VIP ranking address can outbid other lower ranking addresses once per selling window or promotion period.
    * Usage of the VIP ranking and bid priority will be described on token website.
    */
    mapping (address => uint256) viprank;

    /**
     * Minimium contribution to record a VIP block
     * Token holding address needs at least 10 ETH worth of LOOK tokens to be ranked as VIP
    */
    uint256 public VIP_MINIMUM = 1000000;

    /**
     * Initial number of tokens.
     */
    uint256 constant INITIAL_TOKENS_COUNT = 20000000000;

    /**
     * Total number of tokens ins circulation.
     */
    uint256 tokensCount;

    // initial price in wei (numerator)
    uint256 public constant TOKEN_PRICE_N = 1e13;
    // initial price in wei (denominator)
    uint256 public constant TOKEN_PRICE_D = 1;
    // 1 ETH = 100000 LOOK tokens
    // 200000 ETH = 20000000000 LOOK tokens

    /**
     * Create new LOOK token Smart Contract, make message sender to be the
     * owner of smart contract, issue given number of tokens and give them to
     * message sender.
     */
    function LooksCoin() payable {
        owner = msg.sender;
        wallet = msg.sender;
        tokensCount = INITIAL_TOKENS_COUNT;
        balances[owner] = tokensCount;
    }

    /**
     * Get name of this token.
     *
     * @return name of this token
     */
    function name() constant returns (string name) {
      return "LOOK";
    }

    /**
     * Get symbol of this token.
     *
     * @return symbol of this token
     */
    function symbol() constant returns (string symbol) {
      return "LOOK";
    }

    /**
     * Get number of decimals for this token.
     *
     * @return number of decimals for this token
     */
    function decimals () constant returns (uint8 decimals) {
      return 6;
    }

    /**
     * Get total number of tokens in circulation.
     *
     * @return total number of tokens in circulation
     */
    function totalSupply() constant returns (uint256 supply) {
      return tokensCount;
    }

    /**
     * Set new wallet address for the smart contract.
     * May only be called by smart contract owner.
     *
     * @param _wallet new wallet address of the smart contract
     */
    function setWallet(address _wallet) onlyOwner {
        wallet = _wallet;
        WalletUpdated(wallet);
    }
    event WalletUpdated(address newWallet);

    /**
     * Get VIP rank of a given owner.
     * VIP ranking is valid for the lifetime of a token wallet address, as long as it meets VIP holding level.
     *
     * @param participant address to get the vip rank
     * @return vip rank of the owner of given address
     */
    function getVIPRank(address participant) constant returns (uint256 rank) {
        if (balances[participant] < VIP_MINIMUM) {
            return 0;
        }
        return viprank[participant];
    }

    // fallback
    function() payable {
        buyToken();
    }

    /**
     * Accept ethers and other currencies to buy tokens during the token sale
     */
    function buyToken() public payable returns (uint256 amount)
    {
        // Calculate number of tokens for contributed ETH
        uint256 tokens = safeMul(msg.value, TOKEN_PRICE_D) / TOKEN_PRICE_N;

        // Add tokens purchased to account's balance and total supply
        balances[msg.sender] = safeAdd(balances[msg.sender],tokens);
        tokensCount = safeAdd(tokensCount,tokens);

        // Log the tokens purchased 
        Transfer(0x0, msg.sender, tokens);
        // - buyer = participant
        // - ethers = msg.value
        // - participantTokenBalance = balances[participant]
        // - tokens = tokens
        // - totalTokensCount = tokensCount
        TokensBought(msg.sender, msg.value, balances[msg.sender], tokens, tokensCount);

        // Contribution timestamp is recorded for VIP rank
        // Recorded timestamp for VIP ranking should always be earlier than the current time
        if (balances[msg.sender] >= VIP_MINIMUM && viprank[msg.sender] == 0) {
            viprank[msg.sender] = now;
        }

        // Transfer the contributed ethers to the crowdsale wallet
        assert(wallet.send(msg.value));
        return tokens;
    }

    event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 participantTokenBalance, uint256 tokens, uint256 totalTokensCount);

    /**
     * Transfer given number of tokens from message sender to given recipient.
     *
     * @param _to address to transfer tokens to the owner of
     * @param _amount number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer(address _to, uint256 _amount) returns (bool success) {
        return StandardToken.transfer(_to, _amount);
    }

    /**
     * Transfer given number of tokens from given owner to given recipient.
     *
     * @param _from address to transfer tokens from the owner of
     * @param _to address to transfer tokens to the owner of
     * @param _amount number of tokens to transfer from given owner to given
     *        recipient
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success)
    {
        return StandardToken.transferFrom(_from, _to, _amount);
    }

    /**
     * Burn given number of tokens belonging to message sender.
     *
     * @param _amount number of tokens to burn
     * @return true on success, false on error
     */
    function burnTokens(uint256 _amount) returns (bool success) {
        if (_amount <= 0) return false;
        if (_amount > tokensCount) return false;
        if (_amount > balances[msg.sender]) return false;
        balances[msg.sender] = safeSub(balances[msg.sender],_amount);
        tokensCount = safeSub(tokensCount,_amount);
        Transfer(msg.sender, 0x0, _amount);
        return true;
    }
}