contract ESportsConstants {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = uint8(TOKEN_DECIMALS);
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    uint constant RATE = 240; // = 1 ETH
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ESportsFreezingStorage is Ownable {
    // Timestamp when token release is enabled
    uint64 public releaseTime;

    // ERC20 basic token contract being held
    // ERC20Basic token;
    ESportsToken token;
    
    function ESportsFreezingStorage(ESportsToken _token, uint64 _releaseTime) { //ERC20Basic
        require(_releaseTime > now);
        
        releaseTime = _releaseTime;
        token = _token;
    }

    function release(address _beneficiary) onlyOwner returns(uint) {
        //require(now >= releaseTime);
        if (now < releaseTime) return 0;

        uint amount = token.balanceOf(this);
        //require(amount > 0);
        if (amount == 0)  return 0;

        // token.safeTransfer(beneficiary, amount);
        //require(token.transfer(_beneficiary, amount));
        bool result = token.transfer(_beneficiary, amount);
        if (!result) return 0;
        
        return amount;
    }
}

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
    using SafeMath for uint256;

    enum State {Active, Refunding, Closed}

    mapping (address => uint256) public deposited;

    address public wallet;

    State public state;

    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function RefundVault(address _wallet) {
        require(_wallet != 0x0);
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address investor) onlyOwner payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor, uint weiRaised) onlyOwner {
        require(state == State.Refunding);

        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        
        Refunded(investor, depositedValue);
    }
}

/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 *
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint;

    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint32 public startTime;
    uint32 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint public rate;

    // amount of raised money in wei
    uint public weiRaised;

    /**
     * @dev Amount of already sold tokens.
     */
    uint public soldTokens;

    /**
     * @dev Maximum amount of tokens to mint.
     */
    uint public hardCap;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

    function Crowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);
        require(_hardCap > _rate);

        // token = createTokenContract();
        token = MintableToken(_token);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        hardCap = _hardCap;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    // function createTokenContract() internal returns (MintableToken) {
    //     return new MintableToken();
    // }

    /**
     * @dev this method might be overridden for implementing any sale logic.
     * @return Actual rate.
     */
    function getRate() internal constant returns (uint) {
        return rate;
    }

    // Fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender, msg.value);
    }

    // Low level token purchase function
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        // Total minted tokens
        uint totalSupply = token.totalSupply();

        // Actual token minting rate (with considering bonuses and discounts)
        uint actualRate = getRate();

        require(validPurchase(amountWei, actualRate, totalSupply));

        // Calculate token amount to be created
        // uint tokens = rate.mul(msg.value).div(1 ether);
        uint tokens = amountWei.mul(actualRate);

        if (msg.value == 0) { // if it is a btc purchase then check existence all tokens (no change)
            require(tokens.add(totalSupply) <= hardCap);
        }

        // Change, if minted token would be less
        uint change = 0;

        // If hard cap reached
        if (tokens.add(totalSupply) > hardCap) {
            // Rest tokens
            uint maxTokens = hardCap.sub(totalSupply);
            uint realAmount = maxTokens.div(actualRate);

            // Rest tokens rounded by actualRate
            tokens = realAmount.mul(actualRate);
            change = amountWei.sub(realAmount);
            amountWei = realAmount;
        }

        // Bonuses
        postBuyTokens(beneficiary, tokens);

        // Update state
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        if (msg.value != 0) {
            if (change != 0) {
                msg.sender.transfer(change);
            }
            forwardFunds(amountWei);
        }
    }

    // Send ether to the fund collection wallet
    // Override to create custom fund forwarding mechanisms
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }

    // Trasfer bonuses and adding delayed bonuses
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
    }

    /**
     * @dev Check if the specified purchase is valid.
     * @return true if the transaction can buy tokens
     */
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    /**
     * @dev Because of discount hasEnded might be true, but validPurchase returns false.
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap.sub(getRate());
    }

    /**
     * @return true if crowdsale event has started
     */
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. 
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    function FinalizableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token)
            Crowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner {
        require(!isFinalized);
        require(hasEnded());

        isFinalized = true;

        finalization();
        Finalized();        
    }

    /**
     * @dev Can be overriden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }
}

/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

    // minimum amount of funds to be raised in weis
    uint public goal;

    // refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

    function RefundableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token, uint _goal)
            FinalizableCrowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
        require(_goal > 0);
        vault = new RefundVault(wallet);
        goal = _goal;
    }

    // We're overriding the fund forwarding from Crowdsale.
    // In addition to sending the funds, we want to call
    // the RefundVault deposit function
    function forwardFunds(uint amountWei) internal {
        if (goalReached()) {
            wallet.transfer(amountWei);
        }
        else {
            vault.deposit.value(amountWei)(msg.sender);
        }
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender, weiRaised);
    }

    // vault finalization task, called when owner calls finalize()
    function finalization() internal {
        super.finalization();

        if (goalReached()) {
            vault.close();
        }
        else {
            vault.enableRefunds();
        }
    }

    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }
}

contract ESportsMainCrowdsale is ESportsConstants, RefundableCrowdsale {
    uint constant OVERALL_AMOUNT_TOKENS = 60000000 * TOKEN_DECIMAL_MULTIPLIER; // overall 100.00%
    uint constant TEAM_BEN_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    uint constant TEAM_PHIL_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant COMPANY_COLD_STORAGE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
    uint constant INVESTOR_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
    uint constant BONUS_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00% // Pre-sale
	uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
    uint constant PRE_SALE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%

    // Mainnet addresses
    address constant TEAM_BEN_ADDRESS = 0x2E352Ed15C4321f4dd7EdFc19402666dE8713cd8;
    address constant TEAM_PHIL_ADDRESS = 0x4466de3a8f4f0a0f5470b50fdc9f91fa04e00e34;
    address constant INVESTOR_ADDRESS = 0x14f8d0c41097ca6fddb6aa4fd6a3332af3741847;
    address constant BONUS_ADDRESS = 0x5baee4a9938d8f59edbe4dc109119983db4b7bd6;
    address constant COMPANY_COLD_STORAGE_ADDRESS = 0x700d6ae53be946085bb91f96eb1cf9e420236762;
    address constant PRE_SALE_ADDRESS = 0xcb2809926e615245b3af4ebce5af9fbe1a6a4321;
    
    address btcBuyer = 0x1eee4c7d88aadec2ab82dd191491d1a9edf21e9a;

    ESportsBonusProvider public bonusProvider;

    bool private isInit = false;
    
	/**
     * Constructor function
     */
    function ESportsMainCrowdsale(
        uint32 _startTime,
        uint32 _endTime,
        uint _softCapWei, // 4000000 EUR
        address _wallet,
        address _token
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        RATE,
        OVERALL_AMOUNT_TOKENS,
        _wallet,
        _token,
        _softCapWei
	) {
	}

    /**
     * @dev Release delayed bonus tokens
     * @return Amount of got bonus tokens
     */
    function releaseBonus() returns(uint) {
        return bonusProvider.releaseBonus(msg.sender, soldTokens);
    }

    /**
     * @dev Trasfer bonuses and adding delayed bonuses
     * @param _beneficiary Future bonuses holder
     * @param _tokens Amount of bonus tokens
     */
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
        uint bonuses = bonusProvider.getBonusAmount(_beneficiary, soldTokens, _tokens, startTime);
        bonusProvider.addDelayedBonus(_beneficiary, soldTokens, _tokens);

        if (bonuses > 0) {
            bonusProvider.sendBonus(_beneficiary, bonuses);
        }
    }

    /**
     * @dev Initialization of crowdsale. Starts once after deployment token contract
     * , deployment crowdsale contract and changу token contract's owner 
     */
    function init() onlyOwner public returns(bool) {
        require(!isInit);

        ESportsToken ertToken = ESportsToken(token);
        isInit = true;

        ESportsBonusProvider bProvider = new ESportsBonusProvider(ertToken, COMPANY_COLD_STORAGE_ADDRESS);
        // bProvider.transferOwnership(owner);
        bonusProvider = bProvider;

        mintToFounders(ertToken);

        require(token.mint(INVESTOR_ADDRESS, INVESTOR_TOKENS));
        require(token.mint(COMPANY_COLD_STORAGE_ADDRESS, COMPANY_COLD_STORAGE_TOKENS));
        require(token.mint(PRE_SALE_ADDRESS, PRE_SALE_TOKENS));

        // bonuses
        require(token.mint(BONUS_ADDRESS, BONUS_TOKENS));
        require(token.mint(bonusProvider, BUFFER_TOKENS)); // mint bonus token to bonus provider
        
        ertToken.addExcluded(INVESTOR_ADDRESS);
        ertToken.addExcluded(BONUS_ADDRESS);
        ertToken.addExcluded(COMPANY_COLD_STORAGE_ADDRESS);
        ertToken.addExcluded(PRE_SALE_ADDRESS);

        ertToken.addExcluded(address(bonusProvider));

        return true;
    }

    /**
     * @dev Mint of tokens in the name of the founders and freeze part of them
     */
    function mintToFounders(ESportsToken ertToken) internal {
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(20).div(100), startTime + 1 years);
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 3 years);
        ertToken.mintTimelocked(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(30).div(100), startTime + 5 years);
        require(token.mint(TEAM_BEN_ADDRESS, TEAM_BEN_TOKENS.mul(20).div(100)));

        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(20).div(100), startTime + 1 years);
        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 3 years);
        ertToken.mintTimelocked(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(30).div(100), startTime + 5 years);
        require(token.mint(TEAM_PHIL_ADDRESS, TEAM_PHIL_TOKENS.mul(20).div(100)));
    }

    /**
     * @dev Purchase for bitcoin. Can start only btc buyer
     */
    function buyForBitcoin(address _beneficiary, uint _amountWei) public returns(bool) {
        require(msg.sender == btcBuyer);

        buyTokens(_beneficiary, _amountWei);
        
        return true;
    }

    /**
     * @dev Set new address who can buy tokens for bitcoin
     */
    function setBtcBuyer(address _newBtcBuyerAddress) onlyOwner returns(bool) {
        require(_newBtcBuyerAddress != 0x0);

        btcBuyer = _newBtcBuyerAddress;

        return true;
    }

    /**
     * @dev Finish the crowdsale
     */
    function finalization() internal {
        super.finalization();
        token.finishMinting();

        bonusProvider.releaseThisBonuses();

        if (goalReached()) {
            ESportsToken(token).allowMoveTokens();
        }
        token.transferOwnership(owner); // change token owner
    }
}

contract ESportsBonusProvider is ESportsConstants, Ownable {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments

    using SafeMath for uint;

    ESportsToken public token;
    address public returnAddressBonuses;
    mapping (address => uint256) investorBonuses;

    uint constant FIRST_WEEK = 7 days;
    uint constant BONUS_THRESHOLD_ETR = 20000 * RATE * TOKEN_DECIMAL_MULTIPLIER; // 5 000 000 EUR -> 20 000 ETH -> ETR

    function ESportsBonusProvider(ESportsToken _token, address _returnAddressBonuses) {
        token = _token;
        returnAddressBonuses = _returnAddressBonuses;
    }

    function getBonusAmount(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public constant returns (uint) {
        uint bonus = 0;
        
        // Apply bonus for amount
        if (now < _startTime + FIRST_WEEK && now >= _startTime) {
            bonus = bonus.add(_amountTokens.div(10)); // 1
        }

        return bonus;
    }

    function addDelayedBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens
    ) onlyOwner public returns (uint) {
        uint bonus = 0;

        if (_totalSold < BONUS_THRESHOLD_ETR) {
            uint amountThresholdBonus = _amountTokens.div(10); // 2
            investorBonuses[_buyer] = investorBonuses[_buyer].add(amountThresholdBonus); 
            bonus = bonus.add(amountThresholdBonus);
        }

        return bonus;
    }

    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investorBonuses[_buyer] > 0);

        uint amountBonusTokens = investorBonuses[_buyer];
        investorBonuses[_buyer] = 0;
        require(token.transfer(_buyer, amountBonusTokens));

        return amountBonusTokens;
    }

    function getDelayedBonusAmount(address _buyer) public constant returns(uint) {
        return investorBonuses[_buyer];
    }

    function sendBonus(address _buyer, uint _amountBonusTokens) onlyOwner public {
        require(token.transfer(_buyer, _amountBonusTokens));
    }

    function releaseThisBonuses() onlyOwner public {
        uint remainBonusTokens = token.balanceOf(this); // send all remaining bonuses
        require(token.transfer(returnAddressBonuses, remainBonusTokens));
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  	function allowance(address owner, address spender) constant returns (uint256);
  	function transferFrom(address from, address to, uint256 value) returns (bool);
  	function approve(address spender, uint256 value) returns (bool);
  	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

contract ESportsToken is ESportsConstants, MintableToken {
    using SafeMath for uint;

    event Burn(address indexed burner, uint value);
    event MintTimelocked(address indexed beneficiary, uint amount);

    /**
     * @dev Pause token transfer. After successfully finished crowdsale it becomes false
     */
    bool public paused = true;
    /**
     * @dev Accounts who can transfer token even if paused. Works only during crowdsale
     */
    mapping(address => bool) excluded;

    mapping (address => ESportsFreezingStorage[]) public frozenFunds;

    function name() constant public returns (string _name) {
        return "ESports Token";
    }

    function symbol() constant public returns (string _symbol) {
        return "ERT";
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
    
    function allowMoveTokens() onlyOwner {
        paused = false;
    }

    function addExcluded(address _toExclude) onlyOwner {
        addExcludedInternal(_toExclude);
    }
    
    function addExcludedInternal(address _toExclude) private {
        excluded[_toExclude] = true;
    }

    /**
     * @dev Wrapper of token.transferFrom
     */
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        require(!paused || excluded[_from]);

        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Wrapper of token.transfer 
     */
    function transfer(address _to, uint _value) returns (bool) {
        require(!paused || excluded[msg.sender]);

        return super.transfer(_to, _value);
    }

    /**
     * @dev Mint timelocked tokens
     */
    function mintTimelocked(address _to, uint _amount, uint32 _releaseTime)
            onlyOwner canMint returns (ESportsFreezingStorage) {
        ESportsFreezingStorage timelock = new ESportsFreezingStorage(this, _releaseTime);
        mint(timelock, _amount);

        frozenFunds[_to].push(timelock);
        addExcludedInternal(timelock);

        MintTimelocked(_to, _amount);

        return timelock;
    }

    /**
     * @dev Release frozen tokens
     * @return Total amount of released tokens
     */
    function returnFrozenFreeFunds() public returns (uint) {
        uint total = 0;
        ESportsFreezingStorage[] storage frozenStorages = frozenFunds[msg.sender];
        // for (uint x = 0; x < frozenStorages.length; x++) {
        //     uint amount = balanceOf(frozenStorages[x]);
        //     if (frozenStorages[x].call(bytes4(sha3("release(address)")), msg.sender))
        //         total = total.add(amount);
        // }
        for (uint x = 0; x < frozenStorages.length; x++) {
            uint amount = frozenStorages[x].release(msg.sender);
            total = total.add(amount);
        }
        
        return total;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint _value) public {
        require(!paused || excluded[msg.sender]);
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        
        Burn(msg.sender, _value);
    }
}