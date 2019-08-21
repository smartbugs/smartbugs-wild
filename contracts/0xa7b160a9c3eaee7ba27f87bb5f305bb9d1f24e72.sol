pragma solidity ^0.4.23;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
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

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}


contract GetAchieveICO is Ownable {
    using SafeMath for uint;
    
    address public beneficiary;
    uint256 public decimals;
    uint256 public softCap;            // in Wei
    uint256 public hardCap;            // in Wei
    uint256 public amountRaised;       // in Wei
    uint256 public amountSold;         // Amount of sold tokens with decimals
    uint256 public maxAmountToSell;    // Amount of tokens to sell for current Round [Pre Sale - 192M GAT, Sale - 228M GAT]
    
    uint256 deadline1;  // Pre Sale deadline
    uint256 deadline2;  // Sale deadline
    uint256 oneWeek;    // 1 week timeline
    
    uint256 public price;       // Current price
    uint256 price0;             // Sale period price (ICO)
    uint256 price1;             // Pre Sale period price Round 1
    uint256 price2;             // Pre Sale period price Round 2
    uint256 price3;             // Pre Sale period price Round 3
    uint256 price4;             // Pre Sale period price Round 4
    uint256 price5;             // Pre Sale period price Round 5
    uint256 price6;             // Pre Sale period price Round 6
    uint256 price7;             // Pre Sale period price Round 7
    
    ERC20 public token;
    mapping(address => uint256) balances;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = true;     // Closed till manually start by the owner

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);
    

    /**
     * Constructor function
     *
     * Initialization
     */
    constructor(
        address wallet,
        ERC20 addressOfToken
    ) public {
        beneficiary = wallet;
        decimals = 18;
        softCap = 4000 * 1 ether;
        hardCap = 12000 * 1 ether;
        maxAmountToSell = 192000000 * 10 ** decimals;    // Pre Sale 192M GAT. Then 228M GAT will be added in time of Sale period
        // Price rates
        price0 = 40;        // 0.000040 ETH (in Wei)
        price1 = 20;        // 0.000020 ETH (in Wei)
        price2 = 24;        // 0.000024 ETH (in Wei)
        price3 = 24;        // 0.000024 ETH (in Wei)
        price4 = 28;        // 0.000028 ETH (in Wei)
        price5 = 28;        // 0.000028 ETH (in Wei)
        price6 = 32;        // 0.000032 ETH (in Wei)
        price7 = 32;        // 0.000032 ETH (in Wei)
        price = price1;     // Set Pre Sale Round 1 token price as current
        oneWeek = 7 * 1 days;
        deadline2 = now + 50 * oneWeek; // Just for blocking checkGoalReached() function call till Crowdsale start
        token = addressOfToken;
    }
    
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(!crowdsaleClosed);
        require(_validateSaleDate());
        require(msg.sender != address(0));
        uint256 amount = msg.value;
        require(amount != 0);
        require(amount >= 10000000000000000);       // min 0.01 ETH
        require(amount <= hardCap);                 // Hard cap
        
        uint256 tokens = amount.mul(10 ** 6);       // Add 6 zeros in the end of 'amount' to use correct price rate
        tokens = tokens.div(price);                 // Amount of tokens to sell for the current price rate
        require(amountSold.add(tokens) <= maxAmountToSell);     // Check token oversell for the current Round
        balances[msg.sender] = balances[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        amountSold = amountSold.add(tokens);        // Update amount of sold tokens
        
        token.transfer(msg.sender, tokens);
        emit FundTransfer(msg.sender, amount, true);
    }
    
    /**
     * @dev Validation of Pre Sale period
     * @return bool
     */
    function _validateSaleDate() internal returns (bool) {
        // Pre Sale
        if(now <= deadline1) {
            uint256 dateDif = deadline1.sub(now);
            if (dateDif <= 2 * 1 days) {
                price = price7;     // Round 7
                return true;
            } else if (dateDif <= 4 * 1 days) {
                price = price6;     // Round 6
                return true;
            } else if (dateDif <= 6 * 1 days) {
                price = price5;     // Round 5
                return true;
            } else if (dateDif <= 8 * 1 days) {
                price = price4;     // Round 4
                return true;
            } else if (dateDif <= 10 * 1 days) {
                price = price3;     // Round 3
                return true;
            } else if (dateDif <= 12 * 1 days) {
                price = price2;     // Round 2
                return true;
            } else if (dateDif <= 14 * 1 days) {
                price = price1;     // Round 1
                return true;
            } else {
                price = 25;         // Default average value
                return true;
            }
        }
        // Sale
        if (now >= (deadline1.add(oneWeek)) && now <= deadline2) {
            maxAmountToSell = 420000000 * 10 ** decimals;    // Pre Sale + Sale = 192M GAT + 228M GAT
            price = price0;             // Sale token price
            return true;
        }
        // After Sale
        if (now >= deadline2) {
            crowdsaleClosed = true;     // Crowdsale period is finished
            return false;
        }
        
        return false;
    }
    
    /**
    * @dev Start Sale
    */
    function startCrowdsale() onlyOwner public returns (bool) {
        deadline1 = now + 2 * oneWeek;                      // Set Pre Sale deadline 2 weeks
        deadline2 = deadline1 + oneWeek + 8 * oneWeek;      // Set Sale deadline 8 weeks
        crowdsaleClosed = false;    // Start Crowdsale period
        return true;
    }

    modifier afterDeadline() { if (now >= deadline2) _; }

    /**
     * Check if goal was reached
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() onlyOwner afterDeadline public {
        if (amountRaised >= softCap) {
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;     // Close Crowdsale
    }


    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() afterDeadline public {
        require(!fundingGoalReached);
        require(crowdsaleClosed);
        
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        if (amount > 0) {
            if (msg.sender.send(amount)) {
               emit FundTransfer(msg.sender, amount, false);
            } else {
                balances[msg.sender] = amount;
            }
        }
    }
    
    /**
     * Withdraw the funds
     */
    function safeWithdrawFunds(uint256 amount) onlyOwner public returns (bool) {
        require(beneficiary == msg.sender);
        
        if (beneficiary.send(amount)) {
            return true;
        } else {
            return false;
        }
    }
    
    
    /**
     * Withdraw rest of tokens from smart contract balance to the owner's wallet
     * if funding goal is not reached and Crowdsale is already closed.
     * 
     * Can be used for Airdrop if funding goal is not reached.
     */
    function safeWithdrawTokens(uint256 amount) onlyOwner afterDeadline public returns (bool) {
        require(!fundingGoalReached);
        require(crowdsaleClosed);
        
        token.transfer(beneficiary, amount);
        emit FundTransfer(beneficiary, amount, false);
    }
}