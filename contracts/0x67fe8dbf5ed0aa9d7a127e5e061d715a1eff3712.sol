pragma solidity ^0.4.24;

/**
 * @title ERC20
 * @dev   ERC20 Contract interface(s)
 */
contract ERC20
{
    function balanceOf    (address _owner) public constant returns (uint256 balance);
    function transfer     (               address _to, uint256 _value) public returns (bool success);
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success);
    function approve      (address _spender, uint256 _value) public returns (bool success);
    function allowance    (address _owner, address _spender) public constant returns (uint256 remaining);
    function totalSupply  () public constant returns (uint);

    event Transfer (address indexed _from,  address indexed _to,      uint _value);
    event Approval (address indexed _owner, address indexed _spender, uint _value);
}

/**
 * @title TokenRecipient 
 */
interface TokenRecipient
{
    /* fundtion definitions */
    function receiveApproval (address _from, uint256 _value, address _token, bytes _extraData) external;
}

/**
 * @title SafeMath math library
 * @dev   Math operations with safety checks that throw on error
 */
library SafeMath
{
    /**
     * @dev 'a + b', Adds two numbers, throws on overflow
     */
    function add (uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        c = a + b;
        require (c >= a); return c;
    }

    /**
     * @dev 'a - b', Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend)
     */
    function sub (uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        require (a >= b);
        c = a - b; return c;
    }

    /**
     * @dev 'a * b', multiplies two numbers, throws on overflow
     */
    function mul (uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        c = a * b;
        require (a == 0 || c / a == b); return c;
    }

    /**
     * @dev 'a / b', Integer division of two numbers, truncating the quotient
     */
    function div (uint256 a, uint256 b) internal pure returns (uint256 c)
    {
        require (b > 0);
        c = a / b; return c;
    }
}

/**
 * @title ERC20Token
 * @dev   Implementation of the ERC20 Token
 */
contract ERC20Token is ERC20
{
    using SafeMath for uint256;

    /* balance of each account */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public totalSupply;

    /**
     * @dev   Creates a ERC20 Contract with its name, symbol, decimals, and total supply of token
     * @param _name name of token
     * @param _symbol name of symbol
     * @param _decimals decimals
     * @param _initSupply total supply of tokens
     */
    constructor (string _name, string _symbol, uint8 _decimals, uint256 _initSupply) public
    {
        name        = _name;                                    // set the name   for display purpose
        symbol      = _symbol;                                  // set the symbol for display purpose
        decimals    = _decimals;                                // 18 decimals is the strongly suggested 
        totalSupply = _initSupply * (10 ** uint256 (decimals)); // update total supply with the decimal amount
        balances[msg.sender] = totalSupply;                     // give the creator all initial tokens

        emit Transfer (address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Get the token balance for account `_owner`
     */
    function balanceOf (address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    /* function to access name, symbol, decimals, total-supply of token. */
    function name        () public view returns (string  _name    ) { return name;        } 
    function symbol      () public view returns (string  _symbol  ) { return symbol;      } 
    function decimals    () public view returns (uint8   _decimals) { return decimals;    }
    function totalSupply () public view returns (uint256 _supply  ) { return totalSupply; }

    /**
     * @dev Internal transfer, only can be called by this contract
     */
    function _transfer (address _from, address _to, uint256 _value) internal
    {
        require (_to != 0x0);                               // prevent transfer to 0x0 address
        require (balances[_from] >= _value);                // check if the sender has enough
        require (balances[_to  ] +  _value > balances[_to]);// check for overflows

        uint256 previous = balances[_from] + balances[_to]; // save this for an assertion in the future

        balances[_from] = balances[_from].sub (_value);     // subtract from the sender
        balances[_to  ] = balances[_to  ].add (_value);     // add the same to the recipient
        emit Transfer (_from, _to, _value);

        /* Asserts are used to use static analysis to find bugs in your code. They should never fail */
        assert (balances[_from] + balances[_to] == previous);
    }

    /**
     * @dev    Transfer the balance from owner's account to another account "_to" 
     *         owner's account must have sufficient balance to transfer
     *         0 value transfers are allowed
     * @param  _to The address of the recipient
     * @param  _value The amount to send
     * @return true if the operation was successful.
     */
    function transfer (address _to, uint256 _value) public returns (bool success)
    {
        _transfer (msg.sender, _to, _value); return true;
    }

    /**
     * @dev    Send `_value` amount of tokens from `_from` account to `_to` account
     *         The calling account must already have sufficient tokens approved for
     *         spending from the `_from` account
     * @param  _from The address of the sender
     * @param  _to The address of the recipient
     * @param  _value The amount to send
     * @return true if the operation was successful.
     */
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success)
    {
        require (allowed[_from][msg.sender] >= _value); // check allowance 
        allowed [_from][msg.sender] = allowed [_from][msg.sender].sub (_value);

        _transfer (_from, _to, _value); return true;
    }

    /**
     * @dev    Get the amount of tokens approved by the owner that can be transferred
     *         to the spender's account
     * @param  _owner The address owner
     * @param  _spender The address authorized to spend
     * @return The amount of tokens remained for the approved by the owner that can
     *         be transferred
     */
    function allowance (address _owner, address _spender) public constant returns (uint remaining)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev    Set allowance for other address
     *         Allow `_spender` to withdraw from your account, multiple times,
     *         up to the `_value` amount. If this function is called again it
     *         overwrites the current allowance with _value.
     *         Token owner can approve for `spender` to transferFrom (...) `tokens`
     *         from the token owner's account
     * @param  _spender The address authorized to spend
     * @param  _value the max amount they can spend
     * @return true if the operation was successful.
     */
    function approve (address _spender, uint256 _value) public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval (msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev    Set allowance for other address and notify
     *         Allows `_spender` to spend no more than `_value` tokens in your behalf,
     *         and then ping the contract about it
     * @param  _spender   the address authorized to spend
     * @param  _value     the max amount they can spend
     * @param  _extraData some extra information to send to the approved contract
     * @return true if the operation was successful.
     */
    function approveAndCall (address _spender, uint256 _value, bytes _extraData) public returns (bool success)
    {
        TokenRecipient spender = TokenRecipient (_spender);

        if (approve (_spender, _value))
        {
            spender.receiveApproval (msg.sender, _value, address (this), _extraData);
            return true;
        }
    }
}

/**
 * @title  Ownable
 * @notice For user and inter-contract ownership and safe ownership transfers.
 * @dev    The Ownable contract has an owner address, and provides basic
 *         authorization control functions
 */
contract Ownable
{
    address public owner;   /* the address of the contract's owner  */

    /* logged on change & renounce of owner */
    event OwnershipTransferred (address indexed _owner, address indexed _to);
    event OwnershipRenounced   (address indexed _owner);

    /**
     * @dev Sets the original 'owner' of the contract to the sender account
     */
    constructor () public 
    {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner
     */
    modifier onlyOwner 
    {
        require (msg.sender == owner);
        _;
    }

    /**
     * @dev   Allows the current owner to transfer control of the contract to a '_to'
     * @param _to The address to transfer ownership to
     */
    function transferOwnership (address _to) public onlyOwner
    {
        require (_to != address(0));
        emit OwnershipTransferred (owner, _to);
        owner = _to;
    }

    /**
     * @dev   Allows the current owner to relinquish control of the contract.
     *        This will remove all ownership of the contract, _safePhrase must
     *        be equal to "This contract is to be disowned"
     * @param _safePhrase Input string to prevent one's mistake
     */
    function renounceOwnership (bytes32 _safePhrase) public onlyOwner
    {
        require (_safePhrase == "This contract is to be disowned.");
        emit OwnershipRenounced (owner);
        owner = address(0);
    }
}

/**
 * @title ExpERC20Token
 */
contract ExpERC20Token is ERC20Token, Ownable
{
    /**
     * @dev   Creates a ERC20 Contract with its name, symbol, decimals, and total supply of token
     * @param _name name of token
     * @param _symbol name of symbol
     * @param _decimals decimals
     * @param _initSupply total supply of tokens
     */
    constructor (
        string   _name,     // name of token
        string   _symbol,   // name of symbol
        uint8    _decimals, // decimals
        uint256 _initSupply // total supply of tokens
    ) ERC20Token (_name, _symbol, _decimals, _initSupply) public {}

    /**
     * @notice Only the creator can alter the name & symbol
     * @param  _name   newer token name   to be changed
     * @param  _symbol newer token symbol to be changed
     */
    function changeName (string _name, string _symbol) onlyOwner public
    {
        name   = _name;
        symbol = _symbol;
    }

    /* ======================================================================
     * Burnable functions
     */

    /* This notifies clients about the amount burnt */
    event Burn (address indexed from, uint256 value);

    /**
     * Internal burn, only can be called by this contract
     */
    function _burn (address _from, uint256 _value) internal
    {
        require (balances[_from] >= _value);            // check if the sender has enough

        balances[_from] = balances[_from].sub (_value); // subtract from the sender
        totalSupply = totalSupply.sub (_value);         // updates totalSupply
        emit Burn (_from, _value);
    }

    /**
     * @dev    remove `_value` tokens from the system irreversibly
     * @param  _value the amount of money to burn
     * @return true if the operation was successful.
     */
    function burn (uint256 _value) public returns (bool success)
    {
        _burn (msg.sender, _value); return true;
    }

    /**
     * @dev    remove `_value` tokens from the system irreversibly on behalf of `_from`
     * @param  _from the address of the sender
     * @param  _value the amount of money to burn
     * @return true if the operation was successful.
     */
    function burnFrom (address _from, uint256 _value) public returns (bool success)
    {
        require (allowed [_from][msg.sender] >= _value);
        allowed [_from][msg.sender] = allowed [_from][msg.sender].sub (_value);
        _burn (_from, _value); return true;
    }


    /* ======================================================================
     * Mintable functions
     */

    /* event for mint's */
    event Mint (address indexed _to, uint256 _amount);
    event MintFinished ();

    bool public mintingFinished = false;

    /* Throws if it is not mintable status */
    modifier canMint ()
    {
        require (!mintingFinished);
        _;
    }

    /* Throws if called by any account other than the owner */
    modifier hasMintPermission ()
    {
        require (msg.sender == owner);
        _;
    }

    /**
     * @dev    Function to mint tokens
     * @param  _to The address that will receive the minted tokens.
     * @param  _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint (address _to, uint256 _amount) hasMintPermission canMint public returns (bool)
    {
        totalSupply   = totalSupply.add  (_amount);
        balances[_to] = balances[_to].add (_amount);

        emit Mint (_to, _amount);
        emit Transfer (address (0), this, _amount);
        emit Transfer (       this,  _to, _amount);
        return true;
    }

    /**
     * @dev    Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting () onlyOwner canMint public returns (bool)
    {
        mintingFinished = true;
        emit MintFinished ();
        return true;
    }


    /* ======================================================================
     * Lockable Token
     */

    bool public tokenLocked = false;

    /* event for Token's lock or unlock */
    event Lock (address indexed _target, bool _locked);

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds (address target, bool frozen);

    /**
     * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
     * @param  _target address to be frozen
     * @param  _freeze either to freeze it or not
     */
    function freezeAccount (address _target, bool _freeze) onlyOwner public
    {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds (_target, _freeze);
    }

    /* Throws if it is not locked status */
    modifier whenTokenUnlocked ()
    {
        require (!tokenLocked);
        _;
    }

    /* Internal token-lock, only can be called by this contract */
    function _lock (bool _value) internal
    {
        require (tokenLocked != _value);
        tokenLocked = _value;
        emit Lock (this, tokenLocked);
    }

    /**
     * @dev    function to check token is lock or not 
     */
    function isTokenLocked () public view returns (bool success)
    {
        return tokenLocked;
    }

    /**
     * @dev    function to lock/unlock this token
     * @param  _value flag to be locked or not
     */
    function lock (bool _value) onlyOwner public returns (bool)
    {
        _lock (_value); return true;
    }

    /**
     * @dev    Transfer the balance from owner's account to another account "_to" 
     *         owner's account must have sufficient balance to transfer
     *         0 value transfers are allowed
     * @param  _to The address of the recipient
     * @param  _value The amount to send
     * @return true if the operation was successful.
     */
    function transfer (address _to, uint256 _value) whenTokenUnlocked public returns (bool success)
    {
        require (!frozenAccount[msg.sender]);   // check if sender is frozen
        require (!frozenAccount[_to  ]);        // check if recipient is frozen

        return super.transfer (_to, _value);
    }

    /**
     * @dev    Send `_value` amount of tokens from `_from` account to `_to` account
     *         The calling account must already have sufficient tokens approved for
     *         spending from the `_from` account
     * @param  _from The address of the sender
     * @param  _to The address of the recipient
     * @param  _value The amount to send
     * @return true if the operation was successful.
     */
    function transferFrom (address _from, address _to, uint256 _value) whenTokenUnlocked public returns (bool success)
    {
        require (!frozenAccount[msg.sender]);   // check if sender is frozen
        require (!frozenAccount[_from]);        // check if token-owner is frozen
        require (!frozenAccount[_to  ]);        // check if recipient is frozen

        return super.transferFrom (_from, _to, _value);
    }

    /**
     * @dev    Set allowance for other address
     *         Allow `_spender` to withdraw from your account, multiple times,
     *         up to the `_value` amount. If this function is called again it
     *         overwrites the current allowance with _value.
     *         Token owner can approve for `spender` to transferFrom (...) `tokens`
     *         from the token owner's account
     * @param  _spender The address authorized to spend
     * @param  _value the max amount they can spend
     * @return true if the operation was successful.
     */
    function approve (address _spender, uint256 _value) whenTokenUnlocked public returns (bool success)
    {
        require (!frozenAccount[msg.sender]);   // check if sender is frozen
        require (!frozenAccount[_spender  ]);   // check if token-owner is frozen

        return super.approve (_spender, _value);
    }

    /**
     * @dev    Set allowance for other address and notify
     *         Allows `_spender` to spend no more than `_value` tokens in your behalf,
     *         and then ping the contract about it
     * @param  _spender   the address authorized to spend
     * @param  _value     the max amount they can spend
     * @param  _extraData some extra information to send to the approved contract
     * @return true if the operation was successful.
     */
    function approveAndCall (address _spender, uint256 _value, bytes _extraData) whenTokenUnlocked public returns (bool success)
    {
        require (!frozenAccount[msg.sender]);   // check if sender is frozen
        require (!frozenAccount[_spender  ]);   // check if token-owner is frozen

        return super.approveAndCall (_spender, _value, _extraData);
    }

    /* ======================================================================
     * buy & sell functions 
     */

    uint256 public sellPrice;
    uint256 public buyPrice;

    /* Internal transfer, only can be called by this contract */
    function _transfer (address _from, address _to, uint _value) internal
    {
        require (_to != 0x0);                                   // prevent transfer to 0x0 address
        require (balances[_from] >= _value);                    // check if the sender has enough
        require (balances[_to  ]  + _value >= balances[_to]);   // check for overflows

        require (!frozenAccount[_from]);                        // check if sender is frozen
        require (!frozenAccount[_to  ]);                        // check if recipient is frozen

        balances[_from] = balances[_from].sub (_value);         // Subtract from the sender
        balances[_to  ] = balances[_to  ].add (_value);         // Add the same to the recipient
        emit Transfer (_from, _to, _value);
    }

    /**
     * @notice allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
     * @param  _sellPrice Price the users can sell to the contract
     * @param  _buyPrice  Price users can buy from the contract
     */
    function setPrices (uint256 _sellPrice, uint256 _buyPrice) onlyOwner public
    {
        sellPrice = _sellPrice;
        buyPrice  = _buyPrice ;
    }

    /**
     * @notice Buy tokens from contract by sending ether
     */
    function buy () whenTokenUnlocked payable public
    {
        uint amount = msg.value / buyPrice;     // calculates the amount
        _transfer (this, msg.sender, amount);   // makes the transfers
    }

    /**
     *  @notice sell `_amount` tokens to contract
     *  @param  _amount amount of tokens to be sold
     */
    function sell (uint256 _amount) whenTokenUnlocked public
    {
        require (balances[this] >= _amount * sellPrice);    // checks if the contract has enough ether to buy
        _transfer (msg.sender, this, _amount);              // makes the transfers
        msg.sender.transfer (_amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }


}