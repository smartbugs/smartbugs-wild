pragma solidity 0.4.24;


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Basic.sol
// 
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function allowance(address approver, address spender) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed approver, address indexed spender, uint256 value);
}



//
// base contract for all our horizon contracts and tokens
//
contract HorizonContractBase {
    // The owner of the contract, set at contract creation to the creator.
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    // Contract authorization - only allow the owner to perform certain actions.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}




 

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
 * Source: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * VOXToken trader contract for the Talketh.io ICO by Horizon-Globex.com of Switzerland.
 *
 * Author: Horizon Globex GmbH Development Team
 *
 */


contract VOXTrader is HorizonContractBase {
    using SafeMath for uint256;

    struct TradeOrder {
        uint256 quantity;
        uint256 price;
        uint256 expiry;
    }

    // The owner of this contract.
    address public owner;

    // The balances of all accounts.
    mapping (address => TradeOrder) public orderBook;

    // The contract containing the tokens that we trade.
    address public tokenContract;

    // The price paid for the last sale of tokens on this contract.
    uint256 public lastSellPrice;

    // The lowest price an asks can be placed.
    uint256 public sellCeiling;

    // The highest price an ask can be placed.
    uint256 public sellFloor;

    // The percentage taken off transferred tokens during a buy.
    uint256 public tokenFeePercent;
    
    // The minimum fee when buying tokens (if the calculated percent is less than this value);
    uint256 public tokenFeeMin;
    
    // The percentage taken off the cost of buying tokens in Ether.
    uint256 public etherFeePercent;
    
    // The minimum Ether fee when buying tokens (if the calculated percent is less than this value);
    uint256 public etherFeeMin;

    // A sell order was put into the order book.
    event TokensOffered(address indexed who, uint256 quantity, uint256 price, uint256 expiry);

    // A user bought tokens from another user.
    event TokensPurchased(address indexed purchaser, address indexed seller, uint256 quantity, uint256 price);

    // A user bought phone credit using a top-up voucher, buy VOX Tokens on thier behalf to convert to phone credit.
    event VoucherRedeemed(uint256 voucherCode, address voucherOwner, address tokenSeller, uint256 quantity);


    /**
     * @notice Set owner and the target ERC20 contract containing the tokens it trades.
     *
     * @param tokenContract_    The ERC20 contract whose tokens this contract trades.
     */
    constructor(address tokenContract_) public {
        owner = msg.sender;
        tokenContract = tokenContract_;
    }

    /**
     * @notice Get the trade order for the specified address.
     *
     * @param who    The address to get the trade order of.
     */
    function getOrder(address who) public view returns (uint256 quantity, uint256 price, uint256 expiry) {
        TradeOrder memory order = orderBook[who];
        return (order.quantity, order.price, order.expiry);
    }

    /**
     * @notice Offer tokens for sale, you must call approve on the ERC20 contract first, giving approval to
     * the address of this contract.
     *
     * @param quantity  The number of tokens to offer for sale.
     * @param price     The unit price of the tokens.
     * @param expiry    The date and time this order ends.
     */
    function sell(uint256 quantity, uint256 price, uint256 expiry) public {
        require(quantity > 0, "You must supply a quantity.");
        require(price > 0, "The sale price cannot be zero.");
        require(expiry > block.timestamp, "Cannot have an expiry date in the past.");
        require(price >= sellFloor, "The ask is below the minimum allowed.");
        require(sellCeiling == 0 || price <= sellCeiling, "The ask is above the maximum allowed.");
		//require(!willLosePrecision(quantity), "The ask quantity will lose precision when multiplied by price, the bottom 9 digits must be zeroes.");
		//require(!willLosePrecision(price), "The ask price will lose precision when multiplied by quantity, the bottom 9 digits must be zeroes.");

        uint256 allowed = ERC20Interface(tokenContract).allowance(msg.sender, this);
        require(allowed >= quantity, "You must approve the transfer of tokens before offering them for sale.");

        uint256 balance = ERC20Interface(tokenContract).balanceOf(msg.sender);
        require(balance >= quantity, "Not enough tokens owned to complete the order.");

        orderBook[msg.sender] = TradeOrder(quantity, price, expiry);
        emit TokensOffered(msg.sender, quantity, price, expiry);
    }

    /**
     * @notice Buy tokens from an existing sell order.
     *
     * @param seller    The current owner of the tokens for sale.
     * @param quantity  The number of tokens to buy.
     * @param price     The ask price of the tokens.
    */
    function buy(address seller, uint256 quantity, uint256 price) public payable {
        TradeOrder memory order = orderBook[seller];
        require(order.price == price, "Buy price does not match the listed sell price.");
        require(block.timestamp < order.expiry, "Sell order has expired.");

        uint256 tradeQuantity = order.quantity > quantity ? quantity : order.quantity;
        uint256 cost = multiplyAtPrecision(tradeQuantity, order.price, 9);
        require(msg.value >= cost, "You did not send enough Ether to purchase the tokens.");

        uint256 tokenFee;
        uint256 etherFee;
        (tokenFee, etherFee) = calculateFee(tradeQuantity, cost);

        if(!ERC20Interface(tokenContract).transferFrom(seller, msg.sender, tradeQuantity.sub(tokenFee))) {
            revert("Unable to transfer tokens from seller to buyer.");
        }

        // Send any tokens taken as fees to the owner account to be burned.
        if(tokenFee > 0 && !ERC20Interface(tokenContract).transferFrom(seller, owner, tokenFee)) {
            revert("Unable to transfer tokens from seller to buyer.");
        }

        // Deduct the sold tokens from the sell order.
        order.quantity = order.quantity.sub(tradeQuantity);
        orderBook[seller] = order;

        // Pay the seller.
        seller.transfer(cost.sub(etherFee));
        if(etherFee > 0)
            owner.transfer(etherFee);

        lastSellPrice = price;

        emit TokensPurchased(msg.sender, seller, tradeQuantity, price);
    }

    /**
     * @notice Set the percent fee applied to tokens that are transferred.
     *
     * @param percent   The new percentage value at 18 decimal places.
     */
    function setTokenFeePercent(uint256 percent) public onlyOwner {
        require(percent <= 100000000000000000000, "Percent must be between 0 and 100.");
        tokenFeePercent = percent;
    }

    /**
     * @notice Set the minimum number of tokens to be deducted during a buy.
     *
     * @param min   The new minimum value.
     */
    function setTokenFeeMin(uint256 min) public onlyOwner {
        tokenFeeMin = min;
    }

    /**
     * @notice Set the percent fee applied to the Ether used to pay for tokens.
     *
     * @param percent   The new percentage value at 18 decimal places.
     */
    function setEtherFeePercent(uint256 percent) public onlyOwner {
        require(percent <= 100000000000000000000, "Percent must be between 0 and 100.");
        etherFeePercent = percent;
    }

    /**
     * @notice Set the minimum amount of Ether to be deducted during a buy.
     *
     * @param min   The new minimum value.
     */
    function setEtherFeeMin(uint256 min) public onlyOwner {
        etherFeeMin = min;
    }

    /**
     * @notice Calculate the company's fee for facilitating the transfer of tokens.  The fee can be deducted
     * from the number of tokens the buyer purchased or the amount of ether being paid to the seller or both.
     *
     * @param tokens    The number of tokens being transferred.
     * @param ethers    The amount of Ether to pay for the tokens.
     * @return tokenFee The number of tokens taken as a fee during a transfer.
     * @return etherFee The amount of Ether taken as a fee during a transfer. 
     */
    function calculateFee(uint256 tokens, uint256 ethers) public view returns (uint256 tokenFee, uint256 etherFee) {
        tokenFee = multiplyAtPrecision(tokens, tokenFeePercent / 100, 9);
        if(tokenFee < tokenFeeMin)
            tokenFee = tokenFeeMin;

        etherFee = multiplyAtPrecision(ethers, etherFeePercent / 100, 9);
        if(etherFee < etherFeeMin)
            etherFee = etherFeeMin;            

        return (tokenFee, etherFee);
    }

    /**
     * @notice Buy from multiple sellers at once to fill a single large order.
     *
     * @dev This function is to reduce the transaction costs and to make the purchase a single transaction.
     *
     * @param sellers       The list of sellers whose tokens make up this buy.
     * @param lastQuantity  The quantity of tokens to buy from the last seller on the list (the other asks
     *                      are bought in full).
     */
    function multiBuy(address[] sellers, uint256 lastQuantity) public payable {

        for (uint i = 0; i < sellers.length; i++) {
            TradeOrder memory to = orderBook[sellers[i]];
            if(i == sellers.length-1) {
                buy(sellers[i], lastQuantity, to.price);
            }
            else {
                buy(sellers[i], to.quantity, to.price);
            }
        }
    }

    /**
     * @notice A user has redeemed a top-up voucher for phone credit.  This is executed by the owner as it is an internal process
     * to convert a voucher to phone credit via VOX Tokens.
     *
     * @param voucherCode   The code on the e.g. scratch card that is to be redeemed for call credit.
     * @param voucherOwner  The wallet id of the user redeeming the voucher.
     * @param tokenSeller   The wallet id selling the VOX Tokens that are converted to phone crdit.
     * @param quantity      The number of vouchers to purchase on behalf of the voucher owner to fulfill the voucher.
     */
    function redeemVoucher(uint256 voucherCode, address voucherOwner, address tokenSeller, uint256 quantity) public onlyOwner payable {

        // Send ether to the token owner and as we buy them as the owner they get burned.
        buy(tokenSeller, quantity, orderBook[tokenSeller].price);

        // Log the event so the system can detect the successful top-up and transfer credit to the voucher owner.
        emit VoucherRedeemed(voucherCode, voucherOwner, tokenSeller, quantity);
    }

    /**
     * @notice Set the highest price an ask can be listed.
     *
     * @param ceiling   The new maximum price allowed for a sale.
     */
    function setSellCeiling(uint256 ceiling) public onlyOwner {
        sellCeiling = ceiling;
    }

    /**
     * @notice Set the lowest price an ask can be listed.
     *
     * @param floor   The new minimum price allowed for a sale.
     */
    function setSellFloor(uint256 floor) public onlyOwner {
        sellFloor = floor;
    }

    /**
     * @dev Multiply two large numbers using a reduced number of digits e.g. multiply two 10^18 numbers as
     * 10^9 numbers to give a 10^18 result.
     *
     * @param num1      The first number to multiply.
     * @param num2      The second number to multiply.
     * @param digits    The number of trailing digits to remove.
     * @return          The product of the two numbers at the given precision.
     */
    function multiplyAtPrecision(uint256 num1, uint256 num2, uint8 digits) public pure returns (uint256) {
        return removeLowerDigits(num1, digits) * removeLowerDigits(num2, digits);
    }

    /**
     * @dev Strip off the lower n digits of a number, but only if they are zero (to prevent loss of precision).
     *
     * @param value     The numeric value to remove the lower digits from.
     * @param digits    The number of digits to remove.
     * @return          The original value (e.g. 10^18) as a smaller number (e.g. 10^9).
     */
    function removeLowerDigits(uint256 value, uint8 digits) public pure returns (uint256) {
        uint256 divisor = 10 ** uint256(digits);
        uint256 div = value / divisor;
        uint256 mult = div * divisor;

        require(mult == value, "The lower digits bring stripped off must be non-zero");

        return div;
    }
}