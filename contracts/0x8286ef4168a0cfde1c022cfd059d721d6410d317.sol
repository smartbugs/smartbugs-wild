pragma solidity ^0.5.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenDistribution {

    mapping (address => Investor) private _investors;
    address[] investorAddresses;

    struct Investor {
        uint256 total;
        uint256 released;
    }

    uint256 public initTimestamp;
    uint256 public totalAmount;
    IERC20 token;

    // fraction of tokens to be distributed every month.
    // we use 140 as denominator of a fraction.
    // if monthlyFraction[0] = 5 this means that 5/140 of total is to be distributed 
    // in "month 1".
    // note that numbers in this array sum up to 140, which means that after 17 months
    // 140/140 of total will be distributed.
    uint16[17] monthlyFraction = [
        5,   // 1
        15,  // 2
        20,  // 3
        5,   // 4
        5,   // 5
        5,   // 6
        5,   // 7
        5,   // 8
        5,   // 9
        5,   // 10
        5,   // 11
        5,   // 12
        5,   // 13
        5,   // 14
        5,   // 15
        20,  // 16
        20  // 17
    ];

    constructor(address _token, address[] memory investors, uint256[] memory tokenAmounts) public {
        token = IERC20(_token);
        initTimestamp = block.timestamp;
        require(investors.length == tokenAmounts.length);
    
        for (uint i = 0; i < investors.length; i++) {
            address investor_address = investors[i];
            investorAddresses.push(investor_address);
            require(_investors[investor_address].total == 0); // prevent duplicate addresses
            _investors[investor_address].total = tokenAmounts[i] * 1000000;
            _investors[investor_address].released = 0;
            totalAmount += tokenAmounts[i];
        }
    }

    function fractionToAmount(uint256 total, uint256 numerator) internal pure returns (uint256) {
        return (total * numerator) / 140;
    }

    function computeUnlockedAmount(Investor storage inv) internal view returns (uint256) {
        uint256 total = inv.total;
        // first month is immediately unlocked
        uint256 unlocked = fractionToAmount(total, monthlyFraction[0]);
        uint256 daysPassed = getDaysPassed();
        if (daysPassed > 510) {
            return total; // after 17 months we unlock all tokens
        }

        uint256 monthsPassed = daysPassed / 30;
        if (monthsPassed >= 17) {
            return total;
        }

        // unlock up until the current month.
        // E.g. monthsPassed == 1 then this loop is not executed
        // if monthsPassed == 2 then this loop is executed once with m=1 and so on.
        for (uint m = 1; m < monthsPassed; m++) {
            unlocked += fractionToAmount(total, monthlyFraction[m]);
        }
    
        // do daily unlock starting from second month
        if (monthsPassed > 0) {
            uint256 daysSinceStartOfAMonth = daysPassed - monthsPassed * 30;
            if (daysSinceStartOfAMonth > 30)
            daysSinceStartOfAMonth = 30;
            uint256 unlockedThisMonths = fractionToAmount(total, monthlyFraction[monthsPassed]);
            unlocked += (unlockedThisMonths * daysSinceStartOfAMonth) / 30;
        }
        
        if (unlocked > total) {
            return total;
        } 
        else return unlocked;
    }

    function distributedTokensFor(address account) public {
        Investor storage inv = _investors[account];
        uint256 unlocked = computeUnlockedAmount(inv);
        if (unlocked > inv.released) {
            uint256 delta = unlocked - inv.released;
            inv.released = unlocked;
            token.transfer(account, delta);
        }
    }
    
    function distributedTokens() public {
        for (uint i = 0; i < investorAddresses.length; i++) {
            distributedTokensFor(investorAddresses[i]);
        }
    }

    function amountOfTokensToUnlock(address account) external view returns (uint256) {
        Investor storage inv = _investors[account];
        uint256 unlocked = computeUnlockedAmount(inv);
        return (unlocked - inv.released);
    }
    
    function getDaysPassed() public view returns (uint) {
        return (block.timestamp - initTimestamp) / 86400;
    }

}