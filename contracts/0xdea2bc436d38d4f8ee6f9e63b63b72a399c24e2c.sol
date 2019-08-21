pragma solidity ^0.4.18;




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



contract VLBBonusStore is Ownable {
    mapping(address => uint8) public rates;

    function collectRate(address investor) onlyOwner public returns (uint8) {
        require(investor != address(0));
        uint8 rate = rates[investor];
        if (rate != 0) {
            delete rates[investor];
        }
        return rate;
    }

    function addRate(address investor, uint8 rate) onlyOwner public {
        require(investor != address(0));
        rates[investor] = rate;
    }
}
contract VLBRefundVault is Ownable {
    using SafeMath for uint256;

    enum State {Active, Refunding, Closed}
    State public state;

    mapping (address => uint256) public deposited;

    address public wallet;

    event Closed();
    event FundsDrained(uint256 weiAmount);
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function VLBRefundVault(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function unhold() onlyOwner public {
        require(state == State.Active);
        FundsDrained(this.balance);
        wallet.transfer(this.balance);
    }

    function close() onlyOwner public {
        require(state == State.Active);
        state = State.Closed;
        Closed();
        FundsDrained(this.balance);
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyOwner public {
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
}


interface Token {
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function tokensWallet() public returns (address);
}

/**
 * @title VLBCrowdsale
 * @dev VLB crowdsale contract borrows Zeppelin Finalized, Capped and Refundable crowdsales implementations
 */
contract VLBCrowdsale is Ownable {
    using SafeMath for uint;

    /**
     * @dev escrow address
     */
    address public escrow;

    /**
     * @dev token contract
     */
    Token public token;

    /**
     * @dev refund vault used to hold funds while crowdsale is running
     */
    VLBRefundVault public vault;

    /**
     * @dev refund vault used to hold funds while crowdsale is running
     */
    VLBBonusStore public bonuses;

    /**
     * @dev tokensale start time: Dec 17, 2017 12:00:00 UTC (1513512000)
     */
    uint startTime = 1513512000;

    /**
     * @dev tokensale end time: Apr 09, 2018 12:00:00 UTC (1523275200)
     */
    uint endTime = 1523275200;

    /**
     * @dev minimum purchase amount for presale
     */
    uint256 public constant MIN_SALE_AMOUNT = 5 * 10**17; // 0.5 ether

    /**
     * @dev minimum and maximum amount of funds to be raised in USD
     */
    uint256 public constant USD_GOAL = 4 * 10**6;  // $4M
    uint256 public constant USD_CAP  = 12 * 10**6; // $12M

    /**
     * @dev amount of raised money in wei
     */
    uint256 public weiRaised;

    /**
     * @dev tokensale finalization flag
     */
    bool public isFinalized = false;

    /**
     * @dev tokensale pause flag
     */
    bool public paused = false;

    /**
     * @dev refunding satge flag
     */
    bool public refunding = false;

    /**
     * @dev min cap reach flag
     */
    bool public isMinCapReached = false;

    /**
     * @dev ETH x USD exchange rate
     */
    uint public ETHUSD;

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
     * @dev event for tokensale pause logging
    */    
    event Pause();

    /**
     * @dev event for tokensale uppause logging
    */    
    event Unpause();

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
     * @dev Modifier to make a function callable only when its called by escrow.
     */
    modifier onlyEscrow() {
        require(msg.sender == escrow);
        _;
    }

    /**
     * @dev Crowdsale in the constructor takes addresses of
     *      the just deployed VLBToken and VLBRefundVault contracts
     * @param _tokenAddress address of the VLBToken deployed contract
     */
    function VLBCrowdsale(address _tokenAddress, address _wallet, address _escrow, uint rate) public {
        require(_tokenAddress != address(0));
        require(_wallet != address(0));
        require(_escrow != address(0));

        escrow = _escrow;

        // Set initial exchange rate
        ETHUSD = rate;

        // VLBTokenwas deployed separately
        token = Token(_tokenAddress);

        vault = new VLBRefundVault(_wallet);
        bonuses = new VLBBonusStore();
    }

    /**
     * @dev fallback function can be used to buy tokens
     */
    function() public payable {
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

        weiRaised = weiRaised.add(weiAmount);

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(getConversionRate());

        uint8 rate = bonuses.collectRate(beneficiary);
        if (rate != 0) {
            tokens = tokens.mul(rate).div(100);
        }

        if (!token.transferFrom(token.tokensWallet(), beneficiary, tokens)) {
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
        bool withinCap = !capReached(weiRaised.add(_value));

        // For presale we want to decline all payments less then minPresaleAmount
        bool withinAmount = msg.value >= MIN_SALE_AMOUNT;

        return nonZeroPurchase && withinPeriod && withinCap && withinAmount;
    }

    /**
     * @dev finish presale stage and move vault to
     *      refund state if GOAL was not reached
     */
    function unholdFunds() onlyOwner public {
        if (goalReached()) {
            isMinCapReached = true;
            vault.unhold();
        } else {
            revert();
        }
    }
    
    /**
     * @dev check if crowdsale still active based on current time and cap
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        bool timeIsUp = now > endTime;
        return timeIsUp || capReached();
    }

    /**
     * @dev finalize crowdsale. this method triggers vault and token finalization
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        if (goalReached()) {
            vault.close();
        } else {
            refunding = true;
            vault.enableRefunds();
        }

        isFinalized = true;
        Finalized();
    }

    /**
     * @dev add previous investor compensaton rate
     */
    function addRate(address investor, uint8 rate) onlyOwner public {
        require(investor != address(0));
        bonuses.addRate(investor, rate);
    }

    /**
     * @dev check if soft cap goal is reached in USD
     */
    function goalReached() public view returns (bool) {        
        return isMinCapReached || weiRaised.mul(ETHUSD).div(10**20) >= USD_GOAL;
    }

    /**
     * @dev check if hard cap goal is reached in USD
     */
    function capReached() internal view returns (bool) {
        return weiRaised.mul(ETHUSD).div(10**20) >= USD_CAP;
    }

    /**
     * @dev check if hard cap goal is reached in USD
     */
    function capReached(uint256 raised) internal view returns (bool) {
        return raised.mul(ETHUSD).div(10**20) >= USD_CAP;
    }

    /**
     * @dev if crowdsale is unsuccessful, investors can claim refunds here
     */
    function claimRefund() public {
        require(isFinalized && refunding);

        vault.refund(msg.sender);
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
    
    /**
     * @dev called by the escrow to update current ETH x USD exchange rate
     */
    function updateExchangeRate(uint rate) onlyEscrow public {
        ETHUSD = rate;
    } 

    /**
     * @dev returns current token price based on current presale time frame
     */
    function getConversionRate() public constant returns (uint256) {
        if (now >= startTime + 106 days) {
            return 650;
        } else if (now >= startTime + 99 days) {
            return 676;
        } else if (now >= startTime + 92 days) {
            return 715;
        } else if (now >= startTime + 85 days) {
            return 780;
        } else if (now >= startTime) {
            return 845;
        }
        return 0;
    }

    /**
     * @dev killer method that can bu used by owner to
     *      kill the contract and send funds to owner
     */
    function kill() onlyOwner whenPaused public {
        selfdestruct(owner);
    }
}