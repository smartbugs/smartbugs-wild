pragma solidity ^0.4.18;

/**
* REKTCOIN.CASH
* GOT REKT? COME TO STEEMFEST 2018 IN KRAKOW! - GET AWAY FROM THOSE CANDLES - HAVE A DRINK AND A GOOD TIME - THEN MOON.
*
* ALL PROCEEDINGS GO TOWARDS FUNDING STEEMFEST - REKTCOIN.CASH LEAD SPONSOR OF STEEMFEST 2018
**/

// File: contracts\configs\RektCoinCashConfig.sol


/**
 * @title RektCoinCashConfig
 *
 * @dev The static configuration for the RektCoin.cash.
 */
contract RektCoinCashConfig {
    // The name of the token.
    string constant NAME = "RektCoin.Cash";

    // The symbol of the token.
    string constant SYMBOL = "RKTC";

    // The number of decimals for the token.
    uint8 constant DECIMALS = 18;  // Same as ethers.

    // Decimal factor for multiplication purposes.
    uint constant DECIMALS_FACTOR = 10 ** uint(DECIMALS);
}

// File: contracts\interfaces\ERC20TokenInterface.sol

/**
 * @dev The standard ERC20 Token interface.
 */
contract ERC20TokenInterface {
    uint public totalSupply;  /* shorthand for public function and a property */
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

}

// File: contracts\libraries\SafeMath.sol

/**
 * @dev Library that helps prevent integer overflows and underflows,
 * inspired by https://github.com/OpenZeppelin/zeppelin-solidity
 */
library SafeMath {
    function plus(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);

        return c;
    }

    function minus(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);

        return a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        uint c = a / b;

        return c;
    }
}

// File: contracts\traits\ERC20Token.sol

/**
 * @title ERC20Token
 *
 * @dev Implements the operations declared in the `ERC20TokenInterface`.
 */
contract ERC20Token is ERC20TokenInterface {
    using SafeMath for uint;

    // Token account balances.
    mapping (address => uint) balances;

    // Delegated number of tokens to transfer.
    mapping (address => mapping (address => uint)) allowed;



    /**
     * @dev Checks the balance of a certain address.
     *
     * @param _account The address which's balance will be checked.
     *
     * @return Returns the balance of the `_account` address.
     */
    function balanceOf(address _account) public constant returns (uint balance) {
        return balances[_account];
    }

    /**
     * @dev Transfers tokens from one address to another.
     *
     * @param _to The target address to which the `_value` number of tokens will be sent.
     * @param _value The number of tokens to send.
     *
     * @return Whether the transfer was successful or not.
     */
    function transfer(address _to, uint _value) public returns (bool success) {
        if (balances[msg.sender] < _value || _value == 0) {

            return false;
        }

        balances[msg.sender] -= _value;
        balances[_to] = balances[_to].plus(_value);


        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @dev Send `_value` tokens to `_to` from `_from` if `_from` has approved the process.
     *
     * @param _from The address of the sender.
     * @param _to The address of the recipient.
     * @param _value The number of tokens to be transferred.
     *
     * @return Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value || _value == 0) {
            return false;
        }

        balances[_to] = balances[_to].plus(_value);
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;


        Transfer(_from, _to, _value);

        return true;
    }

    /**
     * @dev Allows another contract to spend some tokens on your behalf.
     *
     * @param _spender The address of the account which will be approved for transfer of tokens.
     * @param _value The number of tokens to be approved for transfer.
     *
     * @return Whether the approval was successful or not.
     */
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Shows the number of tokens approved by `_owner` that are allowed to be transferred by `_spender`.
     *
     * @param _owner The account which allowed the transfer.
     * @param _spender The account which will spend the tokens.
     *
     * @return The number of tokens to be transferred.
     */
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}

// File: contracts\traits\HasOwner.sol

/**
 * @title HasOwner
 *
 * @dev Allows for exclusive access to certain functionality.
 */
contract HasOwner {
    // Current owner.
    address public owner;

    // Conditionally the new owner.
    address public newOwner;

    /**
     * @dev The constructor.
     *
     * @param _owner The address of the owner.
     */
    function HasOwner(address _owner) internal {
        owner = _owner;
    }

    /**
     * @dev Access control modifier that allows only the current owner to call the function.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The event is fired when the current owner is changed.
     *
     * @param _oldOwner The address of the previous owner.
     * @param _newOwner The address of the new owner.
     */
    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);

    /**
     * @dev Transfering the ownership is a two-step process, as we prepare
     * for the transfer by setting `newOwner` and requiring `newOwner` to accept
     * the transfer. This prevents accidental lock-out if something goes wrong
     * when passing the `newOwner` address.
     *
     * @param _newOwner The address of the proposed new owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    /**
     * @dev The `newOwner` finishes the ownership transfer process by accepting the
     * ownership.
     */
    function acceptOwnership() public {
        require(msg.sender == newOwner);

        OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}

// File: contracts\traits\Freezable.sol

/**
 * @title Freezable
 * @dev This trait allows to freeze the transactions in a Token
 */
contract Freezable is HasOwner {
  bool public frozen = false;

  /**
   * @dev Modifier makes methods callable only when the contract is not frozen.
   */
  modifier requireNotFrozen() {
    require(!frozen);
    _;
  }

  /**
   * @dev Allows the owner to "freeze" the contract.
   */
  function freeze() onlyOwner public {
    frozen = true;
  }

  /**
   * @dev Allows the owner to "unfreeze" the contract.
   */
  function unfreeze() onlyOwner public {
    frozen = false;
  }
}

// File: contracts\traits\FreezableERC20Token.sol

/**
 * @title FreezableERC20Token
 *
 * @dev Extends ERC20Token and adds ability to freeze all transfers of tokens.
 */
contract FreezableERC20Token is ERC20Token, Freezable {
    /**
     * @dev Overrides the original ERC20Token implementation by adding whenNotFrozen modifier.
     *
     * @param _to The target address to which the `_value` number of tokens will be sent.
     * @param _value The number of tokens to send.
     *
     * @return Whether the transfer was successful or not.
     */
    function transfer(address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Send `_value` tokens to `_to` from `_from` if `_from` has approved the process.
     *
     * @param _from The address of the sender.
     * @param _to The address of the recipient.
     * @param _value The number of tokens to be transferred.
     *
     * @return Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Allows another contract to spend some tokens on your behalf.
     *
     * @param _spender The address of the account which will be approved for transfer of tokens.
     * @param _value The number of tokens to be approved for transfer.
     *
     * @return Whether the approval was successful or not.
     */
    function approve(address _spender, uint _value) public requireNotFrozen returns (bool success) {
        return super.approve(_spender, _value);
    }

}

// File: contracts\RektCoinCash.sol

/**
 * @title RektCoin.cash
 *
 * @dev A standard token implementation of the ERC20 token standard with added
 *      HasOwner trait and initialized using the configuration constants.
 */
contract RektCoinCash is RektCoinCashConfig, HasOwner, FreezableERC20Token {
    // The name of the token.
    string public name;

    // The symbol for the token.
    string public symbol;

    // The decimals of the token.
    uint8 public decimals;

    /**
     * @dev The constructor. Initially sets `totalSupply` and the balance of the
     *      `owner` address according to the initialization parameter.
     */
    function RektCoinCash(uint _totalSupply) public
        HasOwner(msg.sender)
    {
        name = NAME;
        symbol = SYMBOL;
        decimals = DECIMALS;
        totalSupply = _totalSupply;
        balances[owner] = _totalSupply;
    }
}

// File: contracts\configs\RektCoinCashSponsorfundraiserConfig.sol

/**
 * @title RektCoinCashSponsorfundraiserConfig
 *
 * @dev The static configuration for the RektCoin.cash sponsorfundraiser.
 */
contract RektCoinCashSponsorfundraiserConfig is RektCoinCashConfig {
    // The number of RKTC per 1 ETH.
    uint constant CONVERSION_RATE = 1000000;

    // The public sale hard cap of the sponsorfundraiser.
    uint constant TOKENS_HARD_CAP = 294553323 * DECIMALS_FACTOR;

    // The start date of the sponsorfundraiser: Sun, 09 Sep 2018 09:09:09 +0000
    uint constant START_DATE = 1536484149;

    // The end date of the sponsorfundraiser:  Wed, 07 Nov 2018 19:00:00 +0000 // start of SteemFest 2018 in Kraków
    uint constant END_DATE =  1541617200;

    // Maximum gas price limit
    uint constant MAX_GAS_PRICE = 90000000000 wei; // 90 gwei/shanon

    // Minimum individual contribution
    uint constant MIN_CONTRIBUTION =  0.1337 ether;

    // Individual limit in ether
    uint constant INDIVIDUAL_ETHER_LIMIT =  1337 ether;
}

// File: contracts\traits\TokenSafe.sol

/**
 * @title TokenSafe
 *
 * @dev A multi-bundle token safe contract that contains locked tokens released after a date for the specific bundle type.
 */
contract TokenSafe {
    using SafeMath for uint;

    struct AccountsBundle {
        // The total number of tokens locked.
        uint lockedTokens;
        // The release date for the locked tokens
        // Note: Unix timestamp fits uint32, however block.timestamp is uint
        uint releaseDate;
        // The balances for the RKTC locked token accounts.
        mapping (address => uint) balances;
    }

    // The account bundles of locked tokens grouped by release date
    mapping (uint8 => AccountsBundle) public bundles;

    // The `ERC20TokenInterface` contract.
    ERC20TokenInterface token;

    /**
     * @dev The constructor.
     *
     * @param _token The address of the RektCoin.cash contract.
     */
    function TokenSafe(address _token) public {
        token = ERC20TokenInterface(_token);
    }

}

// File: contracts\RektCoinCashSafe.sol

/**
 * @title RektCoinCashSafe
 *
 * @dev The RektCoin.cash safe containing all details about locked tokens.
 */
contract RektCoinCashSafe is TokenSafe, RektCoinCashSponsorfundraiserConfig {

    /**
     * @dev The constructor.
     *
     * @param _token The address of the RektCoin.cash contract.
     */
    function RektCoinCashSafe(address _token) public TokenSafe(_token)
    {
        token = ERC20TokenInterface(_token);


    }


}

// File: contracts\traits\Whitelist.sol

contract Whitelist is HasOwner
{
    // Whitelist mapping
    mapping(address => bool) public whitelist;

    /**
     * @dev The constructor.
     */
    function Whitelist(address _owner) public
        HasOwner(_owner)
    {

    }

    /**
     * @dev Access control modifier that allows only whitelisted address to call the method.
     */
    modifier onlyWhitelisted {
        require(whitelist[msg.sender]);
        _;
    }

    /**
     * @dev Internal function that sets whitelist status in batch.
     *
     * @param _entries An array with the entries to be updated
     * @param _status The new status to apply
     */
    function setWhitelistEntries(address[] _entries, bool _status) internal {
        for (uint32 i = 0; i < _entries.length; ++i) {
            whitelist[_entries[i]] = _status;
        }
    }

    /**
     * @dev Public function that allows the owner to whitelist multiple entries
     *
     * @param _entries An array with the entries to be whitelisted
     */
    function whitelistAddresses(address[] _entries) public onlyOwner {
        setWhitelistEntries(_entries, true);
    }

    /**
     * @dev Public function that allows the owner to blacklist multiple entries
     *
     * @param _entries An array with the entries to be blacklist
     */
    function blacklistAddresses(address[] _entries) public onlyOwner {
        setWhitelistEntries(_entries, false);
    }
}

// File: contracts\RektCoinCashSponsorfundraiser.sol

/**
 * @title RektCoinCashSponsorfundraiser
 *
 * @dev The RektCoin.cash sponsorfundraiser contract.
 */
contract RektCoinCashSponsorfundraiser is RektCoinCash, RektCoinCashSponsorfundraiserConfig, Whitelist {
    // Indicates whether the sponsorfundraiser has ended or not.
    bool public finalized = false;

    // The address of the account which will receive the funds gathered by the sponsorfundraiser.
    address public beneficiary;

    // The number of RKTC participants will receive per 1 ETH.
    uint public conversionRate;

    // Sponsorfundraiser start date.
    uint public startDate;

    // Sponsorfundraiser end date.
    uint public endDate;

    // Sponsorfundraiser tokens hard cap.
    uint public hardCap;

    // The `RektCoinCashSafe` contract.
    RektCoinCashSafe public rektCoinCashSafe;

    // The minimum amount of ether allowed in the public sale
    uint internal minimumContribution;

    // The maximum amount of ether allowed per address
    uint internal individualLimit;

    // Number of tokens sold during the sponsorfundraiser.
    uint private tokensSold;



    /**
     * @dev The event fires every time a new buyer enters the sponsorfundraiser.
     *
     * @param _address The address of the buyer.
     * @param _ethers The number of ethers sent.
     * @param _tokens The number of tokens received by the buyer.
     * @param _newTotalSupply The updated total number of tokens currently in circulation.
     * @param _conversionRate The conversion rate at which the tokens were bought.
     */
    event FundsReceived(address indexed _address, uint _ethers, uint _tokens, uint _newTotalSupply, uint _conversionRate);

    /**
     * @dev The event fires when the beneficiary of the sponsorfundraiser is changed.
     *
     * @param _beneficiary The address of the new beneficiary.
     */
    event BeneficiaryChange(address _beneficiary);

    /**
     * @dev The event fires when the number of RKTC per 1 ETH is changed.
     *
     * @param _conversionRate The new number of RKTC per 1 ETH.
     */
    event ConversionRateChange(uint _conversionRate);

    /**
     * @dev The event fires when the sponsorfundraiser is successfully finalized.
     *
     * @param _beneficiary The address of the beneficiary.
     * @param _ethers The number of ethers transfered to the beneficiary.
     * @param _totalSupply The total number of tokens in circulation.
     */
    event Finalized(address _beneficiary, uint _ethers, uint _totalSupply);

    /**
     * @dev The constructor.
     *
     * @param _beneficiary The address which will receive the funds gathered by the sponsorfundraiser.
     */
    function RektCoinCashSponsorfundraiser(address _beneficiary) public
        RektCoinCash(0)
        Whitelist(msg.sender)
    {
        require(_beneficiary != 0);

        beneficiary = _beneficiary;
        conversionRate = CONVERSION_RATE;
        startDate = START_DATE;
        endDate = END_DATE;
        hardCap = TOKENS_HARD_CAP;
        tokensSold = 0;
        minimumContribution = MIN_CONTRIBUTION;
        individualLimit = INDIVIDUAL_ETHER_LIMIT * CONVERSION_RATE;

        rektCoinCashSafe = new RektCoinCashSafe(this);

        // Freeze the transfers for the duration of the sponsorfundraiser. Removed this, you can immediately transfer your RKTC to any ether address you like!
        // freeze();
    }

    /**
     * @dev Changes the beneficiary of the sponsorfundraiser.
     *
     * @param _beneficiary The address of the new beneficiary.
     */
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != 0);

        beneficiary = _beneficiary;

        BeneficiaryChange(_beneficiary);
    }

    /**
     * @dev Sets converstion rate of 1 ETH to RKTC. Can only be changed before the sponsorfundraiser starts.
     *
     * @param _conversionRate The new number of RektCoin.cashs per 1 ETH.
     */
    function setConversionRate(uint _conversionRate) public onlyOwner {
        require(now < startDate);
        require(_conversionRate > 0);

        conversionRate = _conversionRate;
        individualLimit = INDIVIDUAL_ETHER_LIMIT * _conversionRate;

        ConversionRateChange(_conversionRate);
    }



    /**
     * @dev The default function which will fire every time someone sends ethers to this contract's address.
     */
    function() public payable {
        buyTokens();
    }

    /**
     * @dev Creates new tokens based on the number of ethers sent and the conversion rate.
     */
    //function buyTokens() public payable onlyWhitelisted {
    function buyTokens() public payable {
        require(!finalized);
        require(now >= startDate);
        require(now <= endDate);
        require(tx.gasprice <= MAX_GAS_PRICE);  // gas price limit
        require(msg.value >= minimumContribution);  // required minimum contribution
        require(tokensSold <= hardCap);

        // Calculate the number of tokens the buyer will receive.
        uint tokens = msg.value.mul(conversionRate);
        balances[msg.sender] = balances[msg.sender].plus(tokens);

        // Ensure that the individual contribution limit has not been reached
        require(balances[msg.sender] <= individualLimit);



        tokensSold = tokensSold.plus(tokens);
        totalSupply = totalSupply.plus(tokens);

        Transfer(0x0, msg.sender, tokens);

        FundsReceived(
            msg.sender,
            msg.value,
            tokens,
            totalSupply,
            conversionRate
        );
    }



    /**
     * @dev Finalize the sponsorfundraiser if `endDate` has passed or if `hardCap` is reached.
     */
    function finalize() public onlyOwner {
        require((totalSupply >= hardCap) || (now >= endDate));
        require(!finalized);

        address contractAddress = this;
        Finalized(beneficiary, contractAddress.balance, totalSupply);

        /// Send the total number of ETH gathered to the beneficiary.
        beneficiary.transfer(contractAddress.balance);

        /// Finalize the sponsorfundraiser. Keep in mind that this cannot be undone.
        finalized = true;

        // Unfreeze transfers
        unfreeze();
    }

    /**
     * @dev allow owner to collect balance of contract during donation period
     */

    function collect() public onlyOwner {

        address contractAddress = this;
        /// Send the total number of ETH gathered to the beneficiary.
        beneficiary.transfer(contractAddress.balance);

    }
}