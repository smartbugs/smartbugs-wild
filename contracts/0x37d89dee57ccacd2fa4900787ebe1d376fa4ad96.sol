pragma solidity 0.4.25;


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
 * A version of the Trustee contract (https://www.investopedia.com/terms/r/regulationd.asp) with the
 * added role of Transfer Agent to perform specialised actions.
 *
 * Part of the kycware.com ICO by Horizon-Globex.com of Switzerland.
 *
 * Author: Horizon Globex GmbH Development Team
 */
contract Trustee {
    using SafeMath for uint256;

    /**
     * The details of the tokens bought.
     */
    struct Holding {
        // The number of tokens purchased.
        uint256 quantity;

        // The date and time when the tokens are no longer restricted.
        uint256 releaseDate;

        // Whether the holder is an affiliate of the company or not.
        bool isAffiliate;
    }

    // Restrict functionality to the creator of the contract - the token issuer.
    modifier onlyIssuer {
        require(msg.sender == issuer, "You must be issuer/owner to execute this function.");
        _;
    }

    // Restrict functionaly to the official Transfer Agent.
    modifier onlyTransferAgent {
        require(msg.sender == transferAgent, "You must be the Transfer Agent to execute this function.");
        _;
    }

    // The creator/owner of this contract, set at contract creation to the address that created the contract.
    address public issuer;

    // The collection of all held tokens by user.
    mapping(address => Holding) public heldTokens;

    // The ERC20 Token contract, needed to transfer tokens back to their original owner when the holding
    // period ends.
    address public tokenContract;

    // The authorised Transfer Agent who performs specialist actions on this contract.
    address public transferAgent;

    // Number of seconds in one standard year.
    uint256 public oneYear = 0;//31536000;

    // Emitted when someone subject to Regulation D buys tokens and they are held here.
    event TokensHeld(address indexed who, uint256 tokens, uint256 releaseDate);

    // Emitted when the tokens have passed their release date and have been returned to the original owner.
    event TokensReleased(address indexed who, uint256 tokens);

    // The Transfer Agent moved tokens from an address to a new wallet, for escheatment obligations.
    event TokensTransferred(address indexed from, address indexed to, uint256 tokens);

    // The Transfer Agent was unable to verify a token holder and needed to push out the release date.
    event ReleaseDateExtended(address who, uint256 newReleaseDate);

    // Extra restrictions apply to company affiliates, notify when the status of an address changes.
    event AffiliateStatusChanged(address who, bool isAffiliate);

    /**
     * @notice Create this contract and assign the ERC20 contract where the tokens are returned once the
     * holding period has complete.
     *
     * @param erc20Contract The address of the ERC20 contract.
     */
    constructor(address erc20Contract) public {
        issuer = msg.sender;
        tokenContract = erc20Contract;
    }

    /**
     * @notice Set the address of the Transfer Agent.
     */
    function setTransferAgent(address who) public onlyIssuer {
        transferAgent = who;
    }

    /**
     * @notice Keep a US Citizen's tokens for one year.
     *
     * @param who           The wallet of the US Citizen.
     * @param quantity      The number of tokens to store.
     */
    function hold(address who, uint256 quantity) public onlyIssuer {
        require(who != 0x0, "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        Holding memory holding = Holding(quantity, block.timestamp+oneYear, false);
        heldTokens[who] = holding;
        emit TokensHeld(who, holding.quantity, holding.releaseDate);
    }
	
    /**
     * @notice Hold tokens post-ICO with a variable release date on those tokens.
     *
     * @param who           The wallet of the US Citizen.
     * @param quantity      The number of tokens to store.
	 * @param addedTime		The number of seconds to add to the current date to calculate the release date.
     */
    function postIcoHold(address who, uint256 quantity, uint256 addedTime) public onlyTransferAgent {
        require(who != 0x0, "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        Holding memory holding = Holding(quantity, block.timestamp+addedTime, false);
        heldTokens[who] = holding;
        emit TokensHeld(who, holding.quantity, holding.releaseDate);
    }

    /**
    * @notice Check if a user's holding are eligible for release.
    *
    * @param who        The user to check the holding of.
    * @return           True if can be released, false if not.
    */
    function canRelease(address who) public view returns (bool) {
        Holding memory holding = heldTokens[who];
        if(holding.releaseDate == 0 || holding.quantity == 0)
            return false;

        return block.timestamp > holding.releaseDate;
    }

    /**
     * @notice Release the tokens once the holding period expires, transferring them back to the ERC20 contract to the holder.
     *
     * NOTE: This function preserves the isAffiliate flag of the holder.
     *
     * @param who       The owner of the tokens.
     * @return          True on successful release, false on error.
     */
    function release(address who) public onlyTransferAgent returns (bool) {
        Holding memory holding = heldTokens[who];
        require(!holding.isAffiliate, "To release tokens for an affiliate use partialRelease().");

        if(block.timestamp > holding.releaseDate) {

            bool res = ERC20Interface(tokenContract).transfer(who, holding.quantity);
            if(res) {
                heldTokens[who] = Holding(0, 0, holding.isAffiliate);
                emit TokensReleased(who, holding.quantity);
                return true;
            }
        }

        return false;
    }
	
    /**
     * @notice Release some of an affiliate's tokens to a broker/trading wallet.
     *
     * @param who       		The owner of the tokens.
	 * @param tradingWallet		The broker/trader receiving the tokens.
	 * @param amount 			The number of tokens to release to the trading wallet.
     */
    function partialRelease(address who, address tradingWallet, uint256 amount) public onlyTransferAgent returns (bool) {
        require(tradingWallet != 0, "The destination wallet cannot be null.");
        require(!isExistingHolding(tradingWallet), "The destination wallet must be a new fresh wallet.");
        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate, "Only affiliates can use this function; use release() for non-affiliates.");
        require(amount <= holding.quantity, "The holding has less than the specified amount of tokens.");

        if(block.timestamp > holding.releaseDate) {

            // Send the tokens currently held by this contract on behalf of 'who' to the nominated wallet.
            bool res = ERC20Interface(tokenContract).transfer(tradingWallet, amount);
            if(res) {
                heldTokens[who] = Holding(holding.quantity.sub(amount), holding.releaseDate, holding.isAffiliate);
                emit TokensReleased(who, amount);
                return true;
            }
        }

        return false;
    }

    /**
     * @notice Under special circumstances the Transfer Agent needs to move tokens around.
     *
     * @dev As the release date is accurate to one second it is very unlikely release dates will
     * match so an address that does not have a holding in this contract is required as the target.
     *
     * @param from      The current holder of the tokens.
     * @param to        The recipient of the tokens - must be a 'clean' address.
     * @param amount    The number of tokens to move.
     */
    function transfer(address from, address to, uint256 amount) public onlyTransferAgent returns (bool) {
        require(to != 0x0, "Cannot transfer tokens to the null address.");
        require(amount > 0, "Cannot transfer zero tokens.");
        Holding memory fromHolding = heldTokens[from];
        require(fromHolding.quantity >= amount, "Not enough tokens to perform the transfer.");
        require(!isExistingHolding(to), "Cannot overwrite an existing holding, use a new wallet.");

        heldTokens[from] = Holding(fromHolding.quantity.sub(amount), fromHolding.releaseDate, fromHolding.isAffiliate);
        heldTokens[to] = Holding(amount, fromHolding.releaseDate, false);

        emit TokensTransferred(from, to, amount);

        return true;
    }

    /**
     * @notice The Transfer Agent may need to add time to the release date if they are unable to verify
     * the holder in a timely manner.
     *
     * @param who       The holder of the tokens.
     * @param sconds    The number of seconds to add to the release date.  NOTE: 'seconds' appears to
     *                  be a reserved word.
     */
    function addTime(address who, uint sconds) public onlyTransferAgent returns (bool) {
        require(sconds > 0, "Time added cannot be zero.");

        Holding memory holding = heldTokens[who];
        heldTokens[who] = Holding(holding.quantity, holding.releaseDate.add(sconds), holding.isAffiliate);

        emit ReleaseDateExtended(who, heldTokens[who].releaseDate);

        return true;
    }

    /**
     * @notice Company affiliates have added restriction, allow the Transfer Agent set/clear this flag
     * as needed.
     *
     * @param who           The address being affiliated/unaffiliated.
     * @param isAffiliate   Whether the address is an affiliate or not.
     */
    function setAffiliate(address who, bool isAffiliate) public onlyTransferAgent returns (bool) {
        require(who != 0, "The null address cannot be used.");

        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate != isAffiliate, "Attempt to set the same affiliate status that is already set.");

        heldTokens[who] = Holding(holding.quantity, holding.releaseDate, isAffiliate);

        emit AffiliateStatusChanged(who, isAffiliate);

        return true;
    }

    /**
     * @notice Check if a wallet is already in use, only new/fresh/clean wallets can hold tokens.
     *
     * @param who   The wallet to check.
     * @return      True if the wallet is in use, false otherwise.
     */
    function isExistingHolding(address who) public view returns (bool) {
        Holding memory h = heldTokens[who];
        return (h.quantity != 0 || h.releaseDate != 0);
    }
}