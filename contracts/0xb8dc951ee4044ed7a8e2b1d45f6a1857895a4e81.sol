/**
 *  Crowdsale for Fast Invest Tokens.
 *  Raised Ether will be stored safely at the wallet.
 *
 *  Based on OpenZeppelin framework.
 *  https://openzeppelin.org
 *
 *  Author: Paulius Tumosa
 **/

pragma solidity ^0.4.18;

/**
 * Safe Math library from OpenZeppelin framework
 * https://openzeppelin.org
 *
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
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

/**
 * @title FastInvestTokenCrowdsale
 *
 * Crowdsale have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract FastInvestTokenCrowdsale {
    using SafeMath for uint256;

    address public owner;

    // The token being sold
    token public tokenReward;

    // Tokens will be transfered from this address
    address internal tokenOwner;

    // Address where funds are collected
    address internal wallet;

    // Start and end timestamps where investments are allowed
    uint256 public startTime;
    uint256 public endTime;

    // Amount of tokens sold
    uint256 public tokensSold = 0;

    // Amount of raised money in wei
    uint256 public weiRaised = 0;

    // Funding goal and soft cap
    uint256 constant public SOFT_CAP        = 38850000000000000000000000;
    uint256 constant public FUNDING_GOAL    = 388500000000000000000000000;

    // Tokens per ETH rates before and after the soft cap is reached
    uint256 constant public RATE = 1000;
    uint256 constant public RATE_SOFT = 1200;

    // The balances in ETH of all investors
    mapping (address => uint256) public balanceOf;

    /**
     * Event for token purchase logging
     *
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function FastInvestTokenCrowdsale(address _tokenAddress, address _wallet, uint256 _start, uint256 _end) public {
        require(_tokenAddress != address(0));
        require(_wallet != address(0));

        owner = msg.sender;
        tokenOwner = msg.sender;
        wallet = _wallet;

        tokenReward = token(_tokenAddress);

        require(_start < _end);
        startTime = _start;
        endTime = _end;

    }

    // Fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // Low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 tokens = 0;

        // Calculate token amount
        if (tokensSold < SOFT_CAP) {
            tokens = weiAmount.mul(RATE_SOFT);

            if (tokensSold.add(tokens) > SOFT_CAP) {
                uint256 softTokens = SOFT_CAP.sub(tokensSold);
                uint256 amountLeft = weiAmount.sub(softTokens.div(RATE_SOFT));

                tokens = softTokens.add(amountLeft.mul(RATE));
            }

        } else  {
            tokens = weiAmount.mul(RATE);
        }

        require(tokens > 0);
        require(tokensSold.add(tokens) <= FUNDING_GOAL);

        forwardFunds();
        assert(tokenReward.transferFrom(tokenOwner, beneficiary, tokens));

        balanceOf[beneficiary] = balanceOf[beneficiary].add(weiAmount);

        // Update totals
        weiRaised  = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokens);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    }

    // Send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool hasTokens = tokensSold < FUNDING_GOAL;

        return withinPeriod && nonZeroPurchase && hasTokens;
    }

    function setStart(uint256 _start) public onlyOwner {
        startTime = _start;
    }

    function setEnd(uint256 _end) public onlyOwner {
        require(startTime < _end);
        endTime = _end;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }

}