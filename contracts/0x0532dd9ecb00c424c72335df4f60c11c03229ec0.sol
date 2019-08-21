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
 * @title Obirum Crowdsale
 */
contract ObirumCrowdsale{
    using SafeMath for uint256;

    /** Constants
    * ----------
    * kRate - Ether to Obirum rate. 1 ether is 20000 tokens.
    * kMinStake - Min amount of Ether that can be contributed.
    * kMaxStake - Max amount of Ether that can be contributed.
    */
    uint256 public constant kRate = 20000;
    uint256 public constant kMinStake = 0.1 ether;
    uint256 public constant kMaxStake = 200 ether;

    uint256[9] internal stageLimits = [
        100 ether,
        300 ether,
        1050 ether,
        3050 ether,
        8050 ether,
        18050 ether,
        28050 ether,
        38050 ether,
        48050 ether
    ];
    uint128[9] internal stageDiscounts = [
        300,
        250,
        200,
        150,
        135,
        125,
        115,
        110,
        105
    ];

    // Investor contributions
    mapping(address => uint256) balances;

    uint256 public weiRaised;
    uint8 public currentStage = 0;

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

    // Soft cap in OBR tokens
    uint256 constant public softCap = 106000000 * (10**18);

    // Hard cap in OBR tokens
    uint256 constant public hardCap = 1151000000 * (10**18);

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
    function ObirumCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _token, address _owner)  public {
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
        require(currentStage < getStageCount());
        
        uint256 value = msg.value;
        weiRaised = weiRaised.add(value);
        uint256 limit = getStageLimit(currentStage);
        uint256 dif = 0;
        uint256 returnToSender = 0;
    
        if(weiRaised > limit){
            dif = weiRaised.sub(limit);
            value = value.sub(dif);
            
            if(currentStage == getStageCount() - 1){
                returnToSender = dif;
                weiRaised = weiRaised.sub(dif);
                dif = 0;
            }
        }
        
        mintTokens(value, beneficiary);
        
        if(dif > 0){
            currentStage = currentStage + 1;
            mintTokens(dif, beneficiary);
        }

        // Allow transfers 2 weeks after hard cap is reached
        if(tokensSold == hardCap) {
            reward.setStartTime(now + 2 weeks);
        }

        // // Return funds that are over hard cap
        if(returnToSender > 0) {
            msg.sender.transfer(returnToSender);
        }
    }
    
    function mintTokens(uint256 value, address sender) private{
        uint256 tokens = value.mul(kRate).mul(getStageDiscount(currentStage)).div(100);
        
        // update state
        tokensSold = tokensSold.add(tokens);
        
        // update balance
        balances[sender] = balances[sender].add(value);
        reward.transferFrom(owner, sender, tokens);
        
        TokenPurchase(msg.sender, sender, value, tokens);
        
        // Forward funds
        wallet.transfer(value);
    }

    /**
     * @dev Internal function that is used to check if the incoming purchase should be accepted.
     * @return True if the transaction can buy tokens
     */
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0 && msg.value >= kMinStake && msg.value <= kMaxStake;
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

    function getStageLimit(uint8 _stage) public view returns (uint256) {
        return stageLimits[_stage];
    }

    function getStageDiscount(uint8 _stage) public view returns (uint128) {
        return stageDiscounts[_stage];
    }

    function getStageCount() public view returns (uint8) {
        return uint8(stageLimits.length);
    }
}