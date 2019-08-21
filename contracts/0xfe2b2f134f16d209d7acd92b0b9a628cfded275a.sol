pragma solidity ^0.4.21;



// File: contracts/library/SafeMath.sol

/**
 * @title Safe Math
 *
 * @dev Library for safe mathematical operations.
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}

// File: contracts/token/ERC20Token.sol

/**
 * @dev The standard ERC20 Token contract base.
 */
contract ERC20Token {
    uint256 public totalSupply;  /* shorthand for public function and a property */

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



// File: contracts/component/TokenSafe.sol

/**
 * @title TokenSafe
 *
 * @dev Abstract contract that serves as a base for the token safes. It is a multi-group token safe, where each group
 *      has it's own release time and multiple accounts with locked tokens.
 */
contract TokenSafe {
    using SafeMath for uint;

    // The ERC20 token contract.
    ERC20Token token;

    struct Group {
        // The release date for the locked tokens
        // Note: Unix timestamp fits in uint32, however block.timestamp is uint256
        uint256 releaseTimestamp;
        // The total remaining tokens in the group.
        uint256 remaining;
        // The individual account token balances in the group.
        mapping (address => uint) balances;
    }

    // The groups of locked tokens
    mapping (uint8 => Group) public groups;

    /**
     * @dev The constructor.
     *
     * @param _token The address of the  contract.
     */
    constructor(address _token) public {
        token = ERC20Token(_token);
    }

    /**
     * @dev The function initializes a group with a release date.
     *
     * @param _id Group identifying number.
     * @param _releaseTimestamp Unix timestamp of the time after which the tokens can be released
     */
    function init(uint8 _id, uint _releaseTimestamp) internal {
        require(_releaseTimestamp > 0);

        Group storage group = groups[_id];
        group.releaseTimestamp = _releaseTimestamp;
    }

    /**
     * @dev Add new account with locked token balance to the specified group id.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be added.
     * @param _balance The number of tokens to be locked.
     */
    function add(uint8 _id, address _account, uint _balance) internal {
        Group storage group = groups[_id];
        group.balances[_account] = group.balances[_account].plus(_balance);
        group.remaining = group.remaining.plus(_balance);
    }

    /**
     * @dev Allows an account to be released if it meets the time constraints of the group.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be released.
     */
    function release(uint8 _id, address _account) public {
        Group storage group = groups[_id];
        require(now >= group.releaseTimestamp);

        uint tokens = group.balances[_account];
        require(tokens > 0);

        group.balances[_account] = 0;
        group.remaining = group.remaining.minus(tokens);

        if (!token.transfer(_account, tokens)) {
            revert();
        }
    }
}






// File: contracts/token/StandardToken.sol

/**
 * @title Standard Token
 *
 * @dev The standard abstract implementation of the ERC20 interface.
 */
contract StandardToken is ERC20Token {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev The constructor assigns the token name, symbols and decimals.
     */
    constructor(string _name, string _symbol, uint8 _decimals) internal {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /**
     * @dev Get the balance of an address.
     *
     * @param _address The address which's balance will be checked.
     *
     * @return The current balance of the address.
     */
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    /**
     * @dev Checks the amount of tokens that an owner allowed to a spender.
     *
     * @param _owner The address which owns the funds allowed for spending by a third-party.
     * @param _spender The third-party address that is allowed to spend the tokens.
     *
     * @return The number of tokens available to `_spender` to be spent.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Give permission to `_spender` to spend `_value` number of tokens on your behalf.
     * E.g. You place a buy or sell order on an exchange and in that example, the
     * `_spender` address is the address of the contract the exchange created to add your token to their
     * website and you are `msg.sender`.
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     *
     * @return Whether the approval process was successful or not.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Transfers `_value` number of tokens to the `_to` address.
     *
     * @param _to The address of the recipient.
     * @param _value The number of tokens to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        executeTransfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @dev Allows another contract to spend tokens on behalf of the `_from` address and send them to the `_to` address.
     *
     * @param _from The address which approved you to spend tokens on their behalf.
     * @param _to The address where you want to send tokens.
     * @param _value The number of tokens to be sent.
     *
     * @return Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].minus(_value);
        executeTransfer(_from, _to, _value);

        return true;
    }

    /**
     * @dev Internal function that this reused by the transfer functions
     */
    function executeTransfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        require(_value != 0 && _value <= balances[_from]);

        balances[_from] = balances[_from].minus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(_from, _to, _value);
    }
}






// File: contracts/token/MintableToken.sol

/**
 * @title Mintable Token
 *
 * @dev Allows the creation of new tokens.
 */
contract MintableToken is StandardToken {
    /// @dev The only address allowed to mint coins
    address public minter;

    /// @dev Indicates whether the token is still mintable.
    bool public mintingDisabled = false;

    /**
     * @dev Event fired when minting is no longer allowed.
     */
    event MintingDisabled();

    /**
     * @dev Allows a function to be executed only if minting is still allowed.
     */
    modifier canMint() {
        require(!mintingDisabled);
        _;
    }

    /**
     * @dev Allows a function to be called only by the minter
     */
    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

    /**
     * @dev The constructor assigns the minter which is allowed to mind and disable minting
     */
    constructor(address _minter) internal {
        minter = _minter;
    }

    /**
    * @dev Creates new `_value` number of tokens and sends them to the `_to` address.
    *
    * @param _to The address which will receive the freshly minted tokens.
    * @param _value The number of tokens that will be created.
    */
    function mint(address _to, uint256 _value) public onlyMinter canMint {
        totalSupply = totalSupply.plus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(0x0, _to, _value);
    }

    /**
    * @dev Disable the minting of new tokens. Cannot be reversed.
    *
    * @return Whether or not the process was successful.
    */
    function disableMinting() public onlyMinter canMint {
        mintingDisabled = true;

        emit MintingDisabled();
    }
}

// File: contracts/token/BurnableToken.sol

/**
 * @title Burnable Token
 *
 * @dev Allows tokens to be destroyed.
 */
contract BurnableToken is StandardToken {
    /**
     * @dev Event fired when tokens are burned.
     *
     * @param _from The address from which tokens will be removed.
     * @param _value The number of tokens to be destroyed.
     */
    event Burn(address indexed _from, uint256 _value);

    /**
     * @dev Burnes `_value` number of tokens.
     *
     * @param _value The number of tokens that will be burned.
     */
    function burn(uint256 _value) public {
        require(_value != 0);

        address burner = msg.sender;
        require(_value <= balances[burner]);

        balances[burner] = balances[burner].minus(_value);
        totalSupply = totalSupply.minus(_value);

        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
}

// File: contracts/trait/HasOwner.sol

/**
 * @title HasOwner
 *
 * @dev Allows for exclusive access to certain functionality.
 */
contract HasOwner {
    // The current owner.
    address public owner;

    // Conditionally the new owner.
    address public newOwner;

    /**
     * @dev The constructor.
     *
     * @param _owner The address of the owner.
     */
    constructor(address _owner) public {
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

        emit OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}

// File: contracts/token/PausableToken.sol

/**
 * @title Pausable Token
 *
 * @dev Allows you to pause/unpause transfers of your token.
 **/
contract PausableToken is StandardToken, HasOwner {

    /// Indicates whether the token contract is paused or not.
    bool public paused = false;

    /**
     * @dev Event fired when the token contracts gets paused.
     */
    event Pause();

    /**
     * @dev Event fired when the token contracts gets unpaused.
     */
    event Unpause();

    /**
     * @dev Allows a function to be called only when the token contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Pauses the token contract.
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev Unpauses the token contract.
     */
    function unpause() public onlyOwner {
        require(paused);

        paused = false;
        emit Unpause();
    }

    /// Overrides of the standard token's functions to add the paused/unpaused functionality.

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}









// File: contracts/token/StandardMintableToken.sol

contract StandardMintableToken is MintableToken {
    constructor(address _minter, string _name, string _symbol, uint8 _decimals)
        StandardToken(_name, _symbol, _decimals)
        MintableToken(_minter)
        public
    {
    }
}












/**
 * @title CoinwareToken
 */

contract CoinwareToken is MintableToken, BurnableToken, PausableToken {
    constructor(address _owner, address _minter)
        StandardToken(
            "CoinwareToken",   // Token name
            "CWT", // Token symbol
            18  // Token decimals
        )
        HasOwner(_owner)
        MintableToken(_minter)
        public
    {
    }
}