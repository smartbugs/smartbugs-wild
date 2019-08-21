pragma solidity ^0.4.15;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        if (a != 0 && c / a != b) revert();
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        if (b > a) revert();
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert();
        return c;
    }
}

contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

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
    function transfer(address _to, uint256 _value) public returns (bool) {
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
    function balanceOf(address _owner) public constant returns (uint256 balance) {
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

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
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
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
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue)
    returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
    returns (bool success) {
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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();

    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

/**
 * @title IRBTokens
 * @dev IRB Token contract based on Zeppelin StandardToken contract
 */
contract IRBToken is StandardToken, Ownable {
    using SafeMath for uint256;

    /**
     * @dev ERC20 descriptor variables
     */
    string public constant name = "IRB Tokens";

    string public constant symbol = "IRB";

    uint8 public decimals = 18;

    /**
     * @dev 489.58 millions s the initial Token sale
     */
    uint256 public constant crowdsaleTokens = 489580 * 10 ** 21;

    /**
     * @dev 10.42 millions is the initial Token presale
     */
    uint256 public constant preCrowdsaleTokens = 10420 * 10 ** 21;

    // TODO: TestRPC addresses, replace to real
    // PRE Crowdsale Tokens Wallet
    address public constant preCrowdsaleTokensWallet = 0x0CD95a59fAd089c4EBCCEB54f335eC8f61Caa80e;
    // Crowdsale Tokens Wallet
    address public constant crowdsaleTokensWallet = 0x48545E41696Dc51020C35cA8C36b678101a98437;

    /**
     * @dev Address of PRE Crowdsale contract which will be compared
     *       against in the appropriate modifier check
     */
    address public preCrowdsaleContractAddress;

    /**
     * @dev Address of Crowdsale contract which will be compared
     *       against in the appropriate modifier check
     */
    address public crowdsaleContractAddress;

    /**
     * @dev variable that holds flag of ended pre tokensake
     */
    bool isPreFinished = false;

    /**
     * @dev variable that holds flag of ended tokensake
     */
    bool isFinished = false;

    /**
     * @dev Modifier that allow only the Crowdsale contract to be sender
     */
    modifier onlyPreCrowdsaleContract() {
        require(msg.sender == preCrowdsaleContractAddress);
        _;
    }

    /**
     * @dev Modifier that allow only the Crowdsale contract to be sender
     */
    modifier onlyCrowdsaleContract() {
        require(msg.sender == crowdsaleContractAddress);
        _;
    }

    /**
     * @dev event for the burnt tokens after crowdsale logging
     * @param tokens amount of tokens available for crowdsale
     */
    event TokensBurnt(uint256 tokens);

    /**
     * @dev event for the tokens contract move to the active state logging
     * @param supply amount of tokens left after all the unsold was burned
     */
    event Live(uint256 supply);

    /**
     * @dev Contract constructor
     */
    function IRBToken() {
        // Issue pre crowdsale tokens
        balances[preCrowdsaleTokensWallet] = balanceOf(preCrowdsaleTokensWallet).add(preCrowdsaleTokens);
        Transfer(address(0), preCrowdsaleTokensWallet, preCrowdsaleTokens);

        // Issue crowdsale tokens
        balances[crowdsaleTokensWallet] = balanceOf(crowdsaleTokensWallet).add(crowdsaleTokens);
        Transfer(address(0), crowdsaleTokensWallet, crowdsaleTokens);

        // 500 millions tokens overall
        totalSupply = crowdsaleTokens.add(preCrowdsaleTokens);
    }

    /**
     * @dev back link IRBToken contract with IRBPreCrowdsale one
     * @param _preCrowdsaleAddress non zero address of IRBPreCrowdsale contract
     */
    function setPreCrowdsaleAddress(address _preCrowdsaleAddress) onlyOwner external {
        require(_preCrowdsaleAddress != address(0));
        preCrowdsaleContractAddress = _preCrowdsaleAddress;

        // Allow pre crowdsale contract
        uint256 balance = balanceOf(preCrowdsaleTokensWallet);
        allowed[preCrowdsaleTokensWallet][preCrowdsaleContractAddress] = balance;
        Approval(preCrowdsaleTokensWallet, preCrowdsaleContractAddress, balance);
    }

    /**
     * @dev back link IRBToken contract with IRBCrowdsale one
     * @param _crowdsaleAddress non zero address of IRBCrowdsale contract
     */
    function setCrowdsaleAddress(address _crowdsaleAddress) onlyOwner external {
        require(isPreFinished);
        require(_crowdsaleAddress != address(0));
        crowdsaleContractAddress = _crowdsaleAddress;

        // Allow crowdsale contract
        uint256 balance = balanceOf(crowdsaleTokensWallet);
        allowed[crowdsaleTokensWallet][crowdsaleContractAddress] = balance;
        Approval(crowdsaleTokensWallet, crowdsaleContractAddress, balance);
    }

    /**
     * @dev called only by linked IRBPreCrowdsale contract to end precrowdsale.
     */
    function endPreTokensale() onlyPreCrowdsaleContract external {
        require(!isPreFinished);
        uint256 preCrowdsaleLeftovers = balanceOf(preCrowdsaleTokensWallet);

        if (preCrowdsaleLeftovers > 0) {
            balances[preCrowdsaleTokensWallet] = 0;
            balances[crowdsaleTokensWallet] = balances[crowdsaleTokensWallet].add(preCrowdsaleLeftovers);
            Transfer(preCrowdsaleTokensWallet, crowdsaleTokensWallet, preCrowdsaleLeftovers);
        }

        isPreFinished = true;
    }

    /**
     * @dev called only by linked IRBCrowdsale contract to end crowdsale.
     */
    function endTokensale() onlyCrowdsaleContract external {
        require(!isFinished);
        uint256 crowdsaleLeftovers = balanceOf(crowdsaleTokensWallet);

        if (crowdsaleLeftovers > 0) {
            totalSupply = totalSupply.sub(crowdsaleLeftovers);

            balances[crowdsaleTokensWallet] = 0;
            Transfer(crowdsaleTokensWallet, address(0), crowdsaleLeftovers);
            TokensBurnt(crowdsaleLeftovers);
        }

        isFinished = true;
        Live(totalSupply);
    }
}


/**
 * @title RefundVault.
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract IRBPreRefundVault is Ownable {
    using SafeMath for uint256;

    enum State {Active, Refunding, Closed}
    State public state;

    mapping (address => uint256) public deposited;

    uint256 public totalDeposited;

    address public constant wallet = 0x26dB9eF39Bbfe437f5b384c3913E807e5633E7cE;

    address preCrowdsaleContractAddress;

    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    event Withdrawal(address indexed receiver, uint256 weiAmount);

    function IRBPreRefundVault() {
        state = State.Active;
    }

    modifier onlyCrowdsaleContract() {
        require(msg.sender == preCrowdsaleContractAddress);
        _;
    }

    function setPreCrowdsaleAddress(address _preCrowdsaleAddress) external onlyOwner {
        require(_preCrowdsaleAddress != address(0));
        preCrowdsaleContractAddress = _preCrowdsaleAddress;
    }

    function deposit(address investor) onlyCrowdsaleContract external payable {
        require(state == State.Active);
        uint256 amount = msg.value;
        deposited[investor] = deposited[investor].add(amount);
        totalDeposited = totalDeposited.add(amount);
    }

    function close() onlyCrowdsaleContract external {
        require(state == State.Active);
        state = State.Closed;
        totalDeposited = 0;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyCrowdsaleContract external {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

    /**
     * @dev withdraw method that can be used by crowdsale contract's owner
     *      for the withdrawal funds to the owner
     */
    function withdraw(uint value) onlyCrowdsaleContract external returns (bool success) {
        require(state == State.Active);
        require(totalDeposited >= value);
        totalDeposited = totalDeposited.sub(value);
        wallet.transfer(value);
        Withdrawal(wallet, value);
        return true;
    }

    /**
     * @dev killer method that can be used by owner to
     *      kill the contract and send funds to owner
     */
    function kill() onlyOwner {
        require(state == State.Closed);
        selfdestruct(owner);
    }
}



/**
 * @title IRBPreCrowdsale
 * @dev IRB pre crowdsale contract borrows Zeppelin Finalized, Capped and Refundable crowdsales implementations
 */
contract IRBPreCrowdsale is Ownable, Pausable {
    using SafeMath for uint;

    /**
     * @dev token contract
     */
    IRBToken public token;

    /**
     * @dev refund vault used to hold funds while crowdsale is running
     */
    IRBPreRefundVault public vault;

    /**
     * @dev tokensale(presale) start time: Dec 12, 2017, 11:00:00 + 3
     */
    uint startTime = 1513065600;

    /**
     * @dev tokensale end time: Jan 14, 2018 23:59:59 +3
     */
    uint endTime = 1515963599;

    /**
     * @dev minimum purchase amount for presale
     */
    uint256 public constant minPresaleAmount = 108 * 10 ** 15; // 400 IRB

    /**
     * @dev minimum and maximum amount of funds to be raised in weis
     */
    uint256 public constant goal = 1125 * 10 ** 18;  // 1.125 Kether
    uint256 public constant cap = 2250 * 10 ** 18; // 2.25 Kether

    /**
     * @dev amount of raised money in wei
     */
    uint256 public weiRaised;

    /**
     * @dev tokensale finalization flag
     */
    bool public isFinalized = false;

    /**
     * @dev event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev event for tokensale final logging
     */
    event Finalized();

    /**
     * @dev Pre Crowdsale in the constructor takes addresses of
     *      the just deployed IRBToken and IRBPreRefundVault contracts
     * @param _tokenAddress address of the IRBToken deployed contract
     * @param _vaultAddress address of the IRBPreRefundVault deployed contract
     */
    function IRBPreCrowdsale(address _tokenAddress, address _vaultAddress) {
        require(_tokenAddress != address(0));
        require(_vaultAddress != address(0));

        // IRBToken and IRBPreRefundVault was deployed separately
        token = IRBToken(_tokenAddress);
        vault = IRBPreRefundVault(_vaultAddress);
    }

    /**
     * @dev fallback function can be used to buy tokens
     */
    function() payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev main function to buy tokens
     * @param beneficiary target wallet for tokens can vary from the sender one
     */
    function buyTokens(address beneficiary) whenNotPaused public payable {
        require(beneficiary != address(0));
        require(validPurchase(msg.value));

        uint256 weiAmount = msg.value;

        // buyer and beneficiary could be two different wallets
        address buyer = msg.sender;

        // calculate token amount to be created
        uint256 tokens = convertAmountToTokens(weiAmount);

        weiRaised = weiRaised.add(weiAmount);

        if (!token.transferFrom(token.preCrowdsaleTokensWallet(), beneficiary, tokens)) {
            revert();
        }

        TokenPurchase(buyer, beneficiary, weiAmount, tokens);

        vault.deposit.value(weiAmount)(buyer);
    }

    /**
     * @dev check if the current purchase valid based on time and amount of passed ether
     * @param _value amount of passed ether
     * @return true if investors can buy at the moment
     */
    function validPurchase(uint256 _value) internal constant returns (bool) {
        bool nonZeroPurchase = _value != 0;
        bool withinPeriod = now >= startTime && now <= endTime;
        bool withinCap = weiRaised.add(_value) <= cap;
        // For presale we want to decline all payments less then minPresaleAmount
        bool withinAmount = msg.value >= minPresaleAmount;

        return nonZeroPurchase && withinPeriod && withinCap && withinAmount;
    }

    /**
     * @dev check if crowdsale still active based on current time and cap
     * consider minPresaleAmount
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        bool capReached = weiRaised.add(minPresaleAmount) >= cap;
        bool timeIsUp = now > endTime;
        return timeIsUp || capReached;
    }

    /**
     * @dev if crowdsale is unsuccessful, investors can claim refunds here
     */
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender);
    }

    /**
     * @dev finalize crowdsale. this method triggers vault and token finalization
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        // trigger vault and token finalization
        if (goalReached()) {
            vault.close();
        }
        else {
            vault.enableRefunds();
        }

        token.endPreTokensale();

        isFinalized = true;

        Finalized();
    }

    /**
     * @dev check if hard cap goal is reached
     */
    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }

    /**
    * @dev withdraw method that can be used by owner for
    *      withdraw funds from vault to owner
    */
    function withdraw(uint256 amount) onlyOwner public {
        require(!isFinalized);
        require(goalReached());
        require(amount > 0);

        vault.withdraw(amount);
    }

    /**
     * @dev returns current token price
     */
    function convertAmountToTokens(uint256 amount) public constant returns (uint256) {
        // 1 token = 0.00027 ETH
        uint256 tokens = amount.div(27).mul(100000);
        // bonus +25%
        uint256 bonus = tokens.div(4);

        return tokens.add(bonus);
    }

    /**
     * @dev killer method that can bu used by owner to
     *      kill the contract and send funds to owner
     */
    function kill() onlyOwner whenPaused {
        selfdestruct(owner);
    }
}