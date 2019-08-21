pragma solidity ^0.4.19;

/*
* LooksCoin token sale contract
*
* Refer to https://lookrev.com/tokensale/ for more information.
* 
* Developer: LookRev
*
*/

/*
 * ERC20 Token Standard
 */
contract ERC20 {
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

uint256 public totalSupply;
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
}

/**
* Provides methods to safely add, subtract and multiply uint256 numbers.
*/
contract SafeMath {
    /**
     * Add two uint256 values, revert in case of overflow.
     *
     * @param a first value to add
     * @param b second value to add
     * @return a + b
     */
    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
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
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * Divid uint256 values, throw in case of overflow.
     *
     * @param a first value numerator
     * @param b second value denominator
     * @return a / b
     */
    function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
        assert(b != 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
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
        if (_newOwner != 0x0) {
          newOwner = _newOwner;
        }
    }

    /**
     * Accept the contract ownership by the new owner.
     *
     */
    function acceptOwnership() {
        require(msg.sender == newOwner);
        owner = newOwner;
        OwnershipTransferred(owner, newOwner);
        newOwner = 0x0;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}

/**
* Standard Token Smart Contract
*/
contract StandardToken is ERC20, SafeMath {

    /**
     * Mapping from addresses of token holders to the numbers of tokens belonging
     * to these token holders.
     */
    mapping (address => uint256) balances;

    /**
     * Mapping from addresses of token holders to the mapping of addresses of
     * spenders to the allowances set by these token holders to these spenders.
     */
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * Mapping from addresses of token holders to the mapping of token amount spent.
     * Use by the token holders to spend their utility tokens.
     */
    mapping (address => mapping (address => uint256)) spentamount;

    /**
     * Mapping of the addition of the addresse of buyers.
     */
    mapping (address => bool) buyerAppended;

    /**
     * Mapping of the addition of addresses of buyers.
     */
    address[] buyers;

    /**
     * Mapping of the addresses of VIP token holders.
     */
    address[] vips;

    /**
    * Mapping for VIP rank for qualified token holders
    * Higher VIP ranking (with earlier timestamp) has higher bidding priority when
    * competing for the same product or service on platform. 
    * Higher VIP ranking address can outbid other lower ranking addresses only once per 
    * selling window or promotion period.
    * Usage of the VIP ranking and bid priority will be described on token website.
    */
    mapping (address => uint256) viprank;

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
     * @param _value number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(_to != 0x0);
        if (balances[msg.sender] < _value) return false;
        balances[msg.sender] = safeSub(balances[msg.sender],_value);
        balances[_to] = safeAdd(balances[_to],_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer given number of tokens from given owner to given recipient.
     *
     * @param _from address to transfer tokens from the owner of
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer from given owner to given
     *        recipient
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transferFrom(address _from, address _to, uint256 _value) 
        returns (bool success) {
        require(_to != 0x0);
        if(_from == _to) return false;
        if (balances[_from] < _value) return false;
        if (_value > allowed[_from][msg.sender]) return false;

        balances[_from] = safeSub(balances[_from],_value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
        balances[_to] = safeAdd(balances[_to],_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Allow given spender to transfer given number of tokens from message sender.
     *
     * @param _spender address to allow the owner of to transfer tokens from
     *        message sender
     * @param _value number of tokens to allow to transfer
     * @return true if token transfer was successfully approved, false otherwise
     */
    function approve(address _spender, uint256 _value) returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
           return false;
        }
        if (balances[msg.sender] < _value) {
            return false;
        }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
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
     function allowance(address _owner, address _spender) constant 
        returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }
}

/**
 * LooksCoin Token
 *
 * VIP ranking is recorded at the time when the token holding address first meet VIP coin 
 * holding level.
 * VIP ranking is valid for the lifetime of a token wallet address, as long as it meets 
 * VIP coin holding level.
 * VIP ranking is used to calculate priority when competing with other bids for the
 * same product or service on the platform. 
 * Higher VIP ranking (with earlier timestamp) has higher priority.
 * Higher VIP ranking address can outbid other lower ranking wallet addresse owners only once
 * per selling window or promotion period.
 * Usage of the LooksCoin, VIP ranking and bid priority will be described on token website.
 *
 */
contract LooksCoin is StandardToken, Ownable {

    uint256 public constant decimals = 0;

    /**
     * Minimium contribution to record a VIP rank
     * Token holding address needs have at least 24000 LooksCoin to be ranked as VIP
     * VIP rank can only be set through purchasing tokens
    */
    uint256 public constant VIP_MINIMUM = 24000;

    /**
     * Initial number of tokens.
     */
    uint256 constant INITIAL_TOKENS_COUNT = 100000000;

    /**
     * Crowdsale contract address.
     */
    address public tokenSaleContract = 0x0;

    /**
     * Init Placeholder
     */
    address coinmaster = address(0x33169f40d18c6c2590901db23000D84052a11F54);

    /**
     * Create new LooksCoin token Smart Contract.
     * Contract is needed in _tokenSaleContract address.
     *
     * @param _tokenSaleContract of crowdsale contract
     *
     */
    function LooksCoin(address _tokenSaleContract) {
        assert(_tokenSaleContract != 0x0);
        owner = coinmaster;
        tokenSaleContract = _tokenSaleContract;
        balances[owner] = INITIAL_TOKENS_COUNT;
        totalSupply = INITIAL_TOKENS_COUNT;
    }

    /**
     * Get name of this token.
     *
     * @return name of this token
     */
    function name() constant returns (string name) {
      return "LooksCoin";
    }

    /**
     * Get symbol of this token.
     *
     * @return symbol of this token
     */
    function symbol() constant returns (string symbol) {
      return "LOOKS";
    }

    /**
     * @dev Set new sale manage contract.
     * May only be called by owner.
     *
     * @param _newSaleManageContract new token sale manage contract.
     */
    function setSaleManageContract(address _newSaleManageContract) {
        require(msg.sender == owner);
        assert(_newSaleManageContract != 0x0);
        tokenSaleContract = _newSaleManageContract;
    }

    /**
     * Get VIP rank of a given owner.
     * VIP ranking is valid for the lifetime of a token wallet address, 
     * as long as it meets VIP holding level.
     *
     * @param _to participant address to get the vip rank
     * @return vip rank of the owner of given address
     */
    function getVIPRank(address _to) constant public returns (uint256 rank) {
        if (balances[_to] < VIP_MINIMUM) {
            return 0;
        }
        return viprank[_to];
    }

    /**
     * Check and update VIP rank of a given token buyer.
     * Contribution timestamp is recorded for VIP rank
     * Recorded timestamp for VIP ranking should always be earlier than the current time
     *
     * @param _to address to check the vip rank
     * @return rank vip rank of the owner of given address if any
     */
    function updateVIPRank(address _to) returns (uint256 rank) {
        // Contribution timestamp is recorded for VIP rank
        // Recorded timestamp for VIP ranking should always be earlier than current time
        if (balances[_to] >= VIP_MINIMUM && viprank[_to] == 0) {
            viprank[_to] = now;
            vips.push(_to);
        }
        return viprank[_to];
    }

    event TokenRewardsAdded(address indexed participant, uint256 balance);
    /**
     * Reward participant the tokens they purchased or earned
     *
     * @param _to address to credit tokens to the 
     * @param _value number of tokens to transfer to given recipient
     *
     * @return true if tokens were transferred successfully, false otherwise
     */
    function rewardTokens(address _to, uint256 _value) {
        require(msg.sender == tokenSaleContract || msg.sender == owner);
        assert(_to != 0x0);
        require(_value > 0);

        balances[_to] = safeAdd(balances[_to], _value);
        totalSupply = safeAdd(totalSupply, _value);
        updateVIPRank(_to);
        TokenRewardsAdded(_to, _value);
    }

    event SpentTokens(address indexed participant, address indexed recipient, uint256 amount);
    /**
     * Spend given number of tokens for a usage.
     *
     * @param _to address to spend utility tokens at
     * @param _value number of tokens to spend
     * @return true on success, false on error
     */
    function spend(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0);
        assert(_to != 0x0);
        if (balances[msg.sender] < _value) return false;

        balances[msg.sender] = safeSub(balances[msg.sender],_value);
        balances[_to] = safeAdd(balances[_to],_value);
        spentamount[msg.sender][_to] = safeAdd(spentamount[msg.sender][_to], _value);

        SpentTokens(msg.sender, _to, _value);
        if(!buyerAppended[msg.sender]) {
            buyerAppended[msg.sender] = true;
            buyers.push(msg.sender);
        }
        return true;
    }

    function getSpentAmount(address _who, address _to) constant returns (uint256) {
        return spentamount[_who][_to];
    }

    event Burn(address indexed burner, uint256 value);
    /**
     * Burn given number of tokens belonging to message sender.
     * It can be applied by account with address this.tokensaleContract
     *
     * @param _value number of tokens to burn
     * @return true on success, false on error
     */
    function burnTokens(address burner, uint256 _value) public returns (bool success) {
        require(msg.sender == burner || msg.sender == owner);
        assert(burner != 0x0);
        if (_value > totalSupply) return false;
        if (_value > balances[burner]) return false;
        
        balances[burner] = safeSub(balances[burner],_value);
        totalSupply = safeSub(totalSupply,_value);
        Burn(burner, _value);
        return true;
    }

    function getVIPOwner(uint256 index) constant returns (address) {
        return (vips[index]);
    }

    function getVIPCount() constant returns (uint256) {
        return vips.length;
    }

    function getBuyer(uint256 index) constant returns (address) {
        return (buyers[index]);
    }

    function getBuyersCount() constant returns (uint256) {
        return buyers.length;
    }
}

/**
 * LooksCoin CrowdSale Contract
 *
 * The token sale controller, allows contributing ether in exchange for LooksCoin.
 * The price (exchange rate with ETH) is 2400 LOOKS per ETH at crowdsale.
 * VIP ranking is recorded at the time when the token holding address first meet VIP coin holding level.
 * VIP ranking is valid for the lifetime of a token wallet address, as long as it meets VIP coin holding level.
 * VIP ranking is used to calculate priority when competing with other bids for the
 * same product or service on the platform. 
 * Higher VIP ranking (with earlier timestamp) has higher priority.
 * Higher VIP ranking address can outbid other lower ranking addresses only once per selling window 
 * or promotion period.
 * Usage of the LooksCoin, VIP ranking and bid priority will be described on token website.
 *
 * LooksCoin CrowdSale Bonus
 *******************************************************************************************************************
 * First Ten (10) VIP token holders get 20% bonus of the LOOKS tokens in their VIP addresses
 * Eleven (11th) to Fifty (50th) VIP token holders get 10% bonus of the LOOKS tokens in their VIP addresses
 * Fifty One (51th) to One Hundred (100th) VIP token holders get 5% bonus of the LOOKS tokens in their VIP addresses
 *******************************************************************************************************************
 *
 * Bonus tokens will be distributed by coin master when LooksCoin has 100 VIP rank token wallet addresses
 *
 */
contract LooksCoinCrowdSale {
    LooksCoin public looksCoin;
    ERC20 public preSaleToken;

    // initial price in wei (numerator)
    uint256 public constant TOKEN_PRICE_N = 1e18;
    // initial price in wei (denominator)
    uint256 public constant TOKEN_PRICE_D = 2400;
    // 1 ETH = 2,400 LOOKS tokens

    address saleController = 0x0;

    // Amount of imported tokens from preSale
    uint256 public importedTokens = 0;

    // Amount of tokens sold
    uint256 public tokensSold = 0;

    /**
     * Address of the owner of this smart contract.
     */
    address fundstorage = 0x0;

    /**
     * States of the crowdsale contract.
     */
    enum State{
        Pause,
        Init,
        Running,
        Stopped,
        Migrated
    }

    State public currentState = State.Running;    

    /**
     * Modifier.
     */
    modifier onCrowdSaleRunning() {
        // Checks, if CrowdSale is running and has not been paused
        require(currentState == State.Running);
        _;
    }

    /**
     * Create new LOOKS token Smart Contract, make message sender to be the
     * owner of smart contract, issue given number of tokens and give them to
     * message sender.
     */
    function LooksCoinCrowdSale() {
        saleController = msg.sender;
        fundstorage = msg.sender;
        looksCoin = new LooksCoin(this);

        preSaleToken = ERC20(0x253C7dd074f4BaCb305387F922225A4f737C08bd);
    }

    /**
    * @dev Set new state
    * @param _newState Value of new state
    */
    function setState(State _newState)
    {
        require(msg.sender == saleController);
        currentState = _newState;
    }

    /**
     * @dev Set new token sale controller.
     * May only be called by sale controller.
     *
     * @param _newSaleController new token sale controller.
     */
    function setSaleController(address _newSaleController) {
        require(msg.sender == saleController);
        assert(_newSaleController != 0x0);
        saleController = _newSaleController;
    }

    /**
     * Set new wallet address for the smart contract.
     * May only be called by smart contract owner.
     *
     * @param _fundstorage new wallet address of the smart contract
     */
    function setWallet(address _fundstorage) {
        require(msg.sender == saleController);
        assert(_fundstorage != 0x0);
        fundstorage = _fundstorage;
        WalletUpdated(fundstorage);
    }
    event WalletUpdated(address newWallet);

    /**
    * saves info if account's tokens were imported from pre-CrowdSale
    */
    mapping (address => bool) private importedFromPreSale;

    event TokensImport(address indexed participant, uint256 tokens, uint256 totalImport);
    /**
    * Imports account's tokens from pre-Sale. 
    * It can be done only by account owner or CrowdSale manager
    * @param _account Address of account which tokens will be imported
    */
    function importTokens(address _account) returns (bool success) {
        // only token holder or manager can do import
        require(currentState == State.Running);
        require(msg.sender == saleController || msg.sender == _account);
        require(!importedFromPreSale[_account]);

        // Token decimals in PreSale was 18
        uint256 preSaleBalance = preSaleToken.balanceOf(_account) / TOKEN_PRICE_N;

        if (preSaleBalance == 0) return false;

        looksCoin.rewardTokens(_account, preSaleBalance);
        importedTokens = importedTokens + preSaleBalance;
        importedFromPreSale[_account] = true;
        TokensImport(_account, preSaleBalance, importedTokens);
        return true;
    }

    // fallback
    function() public payable {
        buyTokens();
    }

    event TokensBought(address indexed buyer, uint256 ethers, uint256 tokens, uint256 tokensSold);
    /**
     * Accept ethers to buy tokens during the token sale
     * Minimium holdings to receive a VIP rank is 24000 LooksCoin
     */
    function buyTokens() payable returns (uint256 amount)
    {
        require(currentState == State.Running);
        assert(msg.sender != 0x0);
        require(msg.value > 0);

        // Calculate number of tokens for contributed wei
        uint256 tokens = msg.value * TOKEN_PRICE_D / TOKEN_PRICE_N;
        if (tokens == 0) return 0;

        looksCoin.rewardTokens(msg.sender, tokens);
        tokensSold = tokensSold + tokens;

        // Transfer the contributed ethers to the crowdsale fundstorage
        assert(fundstorage.send(msg.value));
        TokensBought(msg.sender, msg.value, tokens, tokensSold);
        return tokens;
    }
}