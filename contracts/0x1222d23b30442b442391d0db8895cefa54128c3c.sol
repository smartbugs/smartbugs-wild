pragma solidity ^0.5.8;


/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


/**
 * @title TokenSale
 */
contract TokenSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // token for sale
    IERC20 public saleToken;

    // address where funds are collected
    address public fundCollector;

    // address where has tokens to sell
    address public tokenWallet;

    // use whitelist[user] to get whether the user was allowed to buy
    mapping(address => bool) public whitelist;

    // exchangeable token
    struct ExToken {
        bool accepted;
        uint256 rate;
    }

    // exchangeable tokens
    mapping(address => ExToken) private _exTokens;

    // bonus threshold
    uint256 public bonusThreshold;

    // tier-1 bonus
    uint256 public tierOneBonusTime;
    uint256 public tierOneBonusRate;

    // tier-2 bonus
    uint256 public tierTwoBonusTime;
    uint256 public tierTwoBonusRate;

    /**
     * @param setter who set fund collector
     * @param fundCollector address of fund collector
     */
    event FundCollectorSet(
        address indexed setter,
        address indexed fundCollector
    );

    /**
     * @param setter who set sale token
     * @param saleToken address of sale token
     */
    event SaleTokenSet(
        address indexed setter,
        address indexed saleToken
    );

    /**
     * @param setter who set token wallet
     * @param tokenWallet address of token wallet
     */
    event TokenWalletSet(
        address indexed setter,
        address indexed tokenWallet
    );

    /**
     * @param setter who set bonus threshold
     * @param bonusThreshold exceed the threshold will get bonus
     * @param tierOneBonusTime tier one bonus timestamp
     * @param tierOneBonusRate tier one bonus rate
     * @param tierTwoBonusTime tier two bonus timestamp
     * @param tierTwoBonusRate tier two bonus rate
     */
    event BonusConditionsSet(
        address indexed setter,
        uint256 bonusThreshold,
        uint256 tierOneBonusTime,
        uint256 tierOneBonusRate,
        uint256 tierTwoBonusTime,
        uint256 tierTwoBonusRate
    );

    /**
     * @param setter who set the whitelist
     * @param user address of the user
     * @param allowed whether the user allowed to buy
     */
    event WhitelistSet(
        address indexed setter,
        address indexed user,
        bool allowed
    );

    /**
     * event for logging exchangeable token updates
     * @param setter who set the exchangeable token
     * @param exToken the exchangeable token
     * @param accepted whether the exchangeable token was accepted
     * @param rate exchange rate of the exchangeable token
     */
    event ExTokenSet(
        address indexed setter,
        address indexed exToken,
        bool accepted,
        uint256 rate
    );

    /**
     * event for token purchase logging
     * @param buyer address of token buyer
     * @param exToken address of the exchangeable token
     * @param exTokenAmount amount of the exchangeable tokens
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed buyer,
        address indexed exToken,
        uint256 exTokenAmount,
        uint256 amount
    );

    /**
     * @param fundCollector address where collected funds will be forwarded to
     * @param saleToken address of the token being sold
     * @param tokenWallet address of wallet has tokens to sell
     */
    constructor (
        address fundCollector,
        address saleToken,
        address tokenWallet,
        uint256 bonusThreshold,
        uint256 tierOneBonusTime,
        uint256 tierOneBonusRate,
        uint256 tierTwoBonusTime,
        uint256 tierTwoBonusRate
    )
        public
    {
        _setFundCollector(fundCollector);
        _setSaleToken(saleToken);
        _setTokenWallet(tokenWallet);
        _setBonusConditions(
            bonusThreshold,
            tierOneBonusTime,
            tierOneBonusRate,
            tierTwoBonusTime,
            tierTwoBonusRate
        );

    }

    /**
     * @param fundCollector address of the fund collector
     */
    function setFundCollector(address fundCollector) external onlyOwner {
        _setFundCollector(fundCollector);
    }

    /**
     * @param collector address of the fund collector
     */
    function _setFundCollector(address collector) private {
        require(collector != address(0), "fund collector cannot be 0x0");
        fundCollector = collector;
        emit FundCollectorSet(msg.sender, collector);
    }

    /**
     * @param saleToken address of the sale token
     */
    function setSaleToken(address saleToken) external onlyOwner {
        _setSaleToken(saleToken);
    }

    /**
     * @param token address of the sale token
     */
    function _setSaleToken(address token) private {
        require(token != address(0), "sale token cannot be 0x0");
        saleToken = IERC20(token);
        emit SaleTokenSet(msg.sender, token);
    }

    /**
     * @param tokenWallet address of the token wallet
     */
    function setTokenWallet(address tokenWallet) external onlyOwner {
        _setTokenWallet(tokenWallet);
    }

    /**
     * @param wallet address of the token wallet
     */
    function _setTokenWallet(address wallet) private {
        require(wallet != address(0), "token wallet cannot be 0x0");
        tokenWallet = wallet;
        emit TokenWalletSet(msg.sender, wallet);
    }

    /**
     * @param threshold exceed the threshold will get bonus
     * @param t1BonusTime before t1 bonus timestamp will use t1 bonus rate
     * @param t1BonusRate tier-1 bonus rate
     * @param t2BonusTime before t2 bonus timestamp will use t2 bonus rate
     * @param t2BonusRate tier-2 bonus rate
     */
    function setBonusConditions(
        uint256 threshold,
        uint256 t1BonusTime,
        uint256 t1BonusRate,
        uint256 t2BonusTime,
        uint256 t2BonusRate
    )
        external
        onlyOwner
    {
        _setBonusConditions(
            threshold,
            t1BonusTime,
            t1BonusRate,
            t2BonusTime,
            t2BonusRate
        );
    }

    /**
     * @param threshold exceed the threshold will get bonus
     */
    function _setBonusConditions(
        uint256 threshold,
        uint256 t1BonusTime,
        uint256 t1BonusRate,
        uint256 t2BonusTime,
        uint256 t2BonusRate
    )
        private
        onlyOwner
    {
        require(threshold > 0," threshold cannot be zero.");
        require(t1BonusTime < t2BonusTime, "invalid bonus time");
        require(t1BonusRate >= t2BonusRate, "invalid bonus rate");

        bonusThreshold = threshold;
        tierOneBonusTime = t1BonusTime;
        tierOneBonusRate = t1BonusRate;
        tierTwoBonusTime = t2BonusTime;
        tierTwoBonusRate = t2BonusRate;

        emit BonusConditionsSet(
            msg.sender,
            threshold,
            t1BonusTime,
            t1BonusRate,
            t2BonusTime,
            t2BonusRate
        );
    }

    /**
     * @notice set allowed to ture to add the user into the whitelist
     * @notice set allowed to false to remove the user from the whitelist
     * @param user address of user
     * @param allowed whether allow the user to deposit/withdraw or not
     */
    function setWhitelist(address user, bool allowed) external onlyOwner {
        whitelist[user] = allowed;
        emit WhitelistSet(msg.sender, user, allowed);
    }

    /**
     * @dev checks the amount of tokens left in the allowance.
     * @return amount of tokens left in the allowance
     */
    function remainingTokens() external view returns (uint256) {
        return Math.min(
            saleToken.balanceOf(tokenWallet),
            saleToken.allowance(tokenWallet, address(this))
        );
    }

    /**
     * @param exToken address of the exchangeable token
     * @param accepted true: accepted; false: rejected
     * @param rate exchange rate
     */
    function setExToken(
        address exToken,
        bool accepted,
        uint256 rate
    )
        external
        onlyOwner
    {
        _exTokens[exToken].accepted = accepted;
        _exTokens[exToken].rate = rate;
        emit ExTokenSet(msg.sender, exToken, accepted, rate);
    }

    /**
     * @param exToken address of the exchangeable token
     * @return whether the exchangeable token is accepted or not
     */
    function accepted(address exToken) public view returns (bool) {
        return _exTokens[exToken].accepted;
    }

    /**
     * @param exToken address of the exchangeale token
     * @return amount of sale token a buyer gets per exchangeable token
     */
    function rate(address exToken) external view returns (uint256) {
        return _exTokens[exToken].rate;
    }

    /**
     * @dev get exchangeable sale token amount
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token (how much to pay)
     * @return purchased sale token amount
     */
    function exchangeableAmounts(
        address exToken,
        uint256 amount
    )
        external
        view
        returns (uint256)
    {
        return _getTokenAmount(exToken, amount);
    }

    /**
     * @dev buy tokens
     * @dev buyer must be in whitelist
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token
     */
    function buyTokens(
        address exToken,
        uint256 amount
    )
        external
    {
        require(_exTokens[exToken].accepted, "token was not accepted");
        require(amount != 0, "amount cannot 0");
        require(whitelist[msg.sender], "buyer must be in whitelist");
        // calculate token amount to sell
        uint256 tokens = _getTokenAmount(exToken, amount);
        require(tokens >= 10**19, "at least buy 10 tokens per purchase");
        _forwardFunds(exToken, amount);
        _processPurchase(msg.sender, tokens);
        emit TokensPurchased(msg.sender, exToken, amount, tokens);
    }

    /**
     * @dev buyer transfers amount of the exchangeable token to fund collector
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token will send to fund collector
     */
    function _forwardFunds(address exToken, uint256 amount) private {
        IERC20(exToken).safeTransferFrom(msg.sender, fundCollector, amount);
    }

    /**
     * @dev calculated purchased sale token amount
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token (how much to pay)
     * @return amount of purchased sale token
     */
    function _getTokenAmount(
        address exToken,
        uint256 amount
    )
        private
        view
        returns (uint256)
    {
        // round down value (v) by multiple (m) = (v / m) * m
        uint256 value = amount
            .div(100000000000000000)
            .mul(100000000000000000)
            .mul(_exTokens[exToken].rate);
        return _applyBonus(value);
    }

    function _applyBonus(
        uint256 amount
    )
        private
        view
        returns (uint256)
    {
        if (amount < bonusThreshold) {
            return amount;
        }

        if (block.timestamp <= tierOneBonusTime) {
            return amount.mul(tierOneBonusRate).div(100);
        } else if (block.timestamp <= tierTwoBonusTime) {
            return amount.mul(tierTwoBonusRate).div(100);
        } else {
            return amount;
        }
    }

    /**
     * @dev transfer sale token amounts from token wallet to beneficiary
     * @param beneficiary purchased tokens will transfer to this address
     * @param tokenAmount purchased token amount
     */
    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
        private
    {
        saleToken.safeTransferFrom(tokenWallet, beneficiary, tokenAmount);
    }
}