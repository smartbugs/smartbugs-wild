pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function setStartTime(uint _startTime) external;
}

/**
 * @title BitDegree Crowdsale
 */
contract BitDegreeCrowdsale {
    using SafeMath for uint256;

    // Investor contributions
    mapping(address => uint256) balances;

    // The token being sold
    token public reward;

    // Owner of the token
    address public owner;

    // Start and end timestamps
    uint public startTime;
    uint public endTime;

    // Address where funds are collected
    address public wallet;

    // Amount of tokens that were sold
    uint256 public tokensSold;

    // Soft cap in BDG tokens
    uint256 constant public softCap = 6250000 * (10**18);

    // Hard cap in BDG tokens
    uint256 constant public hardCap = 336600000 * (10**18);

    // Switched to true once token contract is notified of when to enable token transfers
    bool private isStartTimeSet = false;

    /**
     * @dev Event for token purchase logging
     * @param purchaser Address that paid for the tokens
     * @param beneficiary Address that got the tokens
     * @param value The amount that was paid (in wei)
     * @param amount The amount of tokens that were bought
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev Event for refund logging
     * @param receiver The address that received the refund
     * @param amount The amount that is being refunded (in wei)
     */
    event Refund(address indexed receiver, uint256 amount);

    /**
     * @param _startTime Unix timestamp for the start of the token sale
     * @param _endTime Unix timestamp for the end of the token sale
     * @param _wallet Ethereum address to which the invested funds are forwarded
     * @param _token Address of the token that will be rewarded for the investors
     * @param _owner Address of the owner of the smart contract who can execute restricted functions
     */
    function BitDegreeCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _token, address _owner)  public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != address(0));
        require(_token != address(0));
        require(_owner != address(0));

        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
        owner = _owner;
        reward = token(_token);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Fallback function that can be used to buy tokens. Or in case of the owner, return ether to allow refunds.
     */
    function () external payable {
        if(msg.sender == wallet) {
            require(hasEnded() && tokensSold < softCap);
        } else {
            buyTokens(msg.sender);
        }
    }

    /**
     * @dev Function for buying tokens
     * @param beneficiary The address that should receive bought tokens
     */
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 returnToSender = 0;

        // Retrieve the current token rate
        uint256 rate = getRate();

        // Calculate token amount to be transferred
        uint256 tokens = weiAmount.mul(rate);

        // Distribute only the remaining tokens if final contribution exceeds hard cap
        if(tokensSold.add(tokens) > hardCap) {
            tokens = hardCap.sub(tokensSold);
            weiAmount = tokens.div(rate);
            returnToSender = msg.value.sub(weiAmount);
        }

        // update state
        tokensSold = tokensSold.add(tokens);

        // update balance
        balances[beneficiary] = balances[beneficiary].add(weiAmount);

        assert(reward.transferFrom(owner, beneficiary, tokens));
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        // Forward funds
        wallet.transfer(weiAmount);

        // Allow transfers 2 weeks after hard cap is reached
        if(tokensSold == hardCap) {
            reward.setStartTime(now + 2 weeks);
        }

        // Notify token contract about sale end time
        if(!isStartTimeSet) {
            isStartTimeSet = true;
            reward.setStartTime(endTime + 2 weeks);
        }

        // Return funds that are over hard cap
        if(returnToSender > 0) {
            msg.sender.transfer(returnToSender);
        }
    }

    /**
     * @dev Internal function that is used to determine the current rate for token / ETH conversion
     * @return The current token rate
     */
    function getRate() internal constant returns (uint256) {
        if(now < (startTime + 1 weeks)) {
            return 11500;
        }

        if(now < (startTime + 2 weeks)) {
            return 11000;
        }

        if(now < (startTime + 3 weeks)) {
            return 10500;
        }

        return 10000;
    }

    /**
     * @dev Internal function that is used to check if the incoming purchase should be accepted.
     * @return True if the transaction can buy tokens
     */
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool hardCapNotReached = tokensSold < hardCap;
        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    /**
     * @return True if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        return now > endTime || tokensSold >= hardCap;
    }

    /**
     * @dev Returns ether to token holders in case soft cap is not reached.
     */
    function claimRefund() external {
        require(hasEnded());
        require(tokensSold < softCap);

        uint256 amount = balances[msg.sender];

        if(address(this).balance >= amount) {
            balances[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                Refund(msg.sender, amount);
            }
        }
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) external constant returns (uint256 balance) {
        return balances[_owner];
    }

}