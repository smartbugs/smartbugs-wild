pragma solidity ^0.4.18;

/**
 * IMultiOwned
 *
 * Interface that allows multiple owners
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
interface IMultiOwned {

    /**
     * Returns true if `_account` is an owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool);


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() public view returns (uint);


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) public view returns (address);


     /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) public;


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) public;
}


/**
 * MultiOwned
 *
 * Allows multiple owners
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract MultiOwned is IMultiOwned {

    // Owners
    mapping (address => uint) private owners;
    address[] private ownersIndex;


     /**
     * Access is restricted to owners only
     */
    modifier only_owner() {
        require(isOwner(msg.sender));
        _;
    }


    /**
     * The publisher is the initial owner
     */
    function MultiOwned() public {
        ownersIndex.push(msg.sender);
        owners[msg.sender] = 0;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool) {
        return owners[_account] < ownersIndex.length && _account == ownersIndex[owners[_account]];
    }


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() public view returns (uint) {
        return ownersIndex.length;
    }


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) public view returns (address) {
        return ownersIndex[_index];
    }


    /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) public only_owner {
        if (!isOwner(_account)) {
            owners[_account] = ownersIndex.push(_account) - 1;
        }
    }


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) public only_owner {
        if (isOwner(_account)) {
            uint indexToDelete = owners[_account];
            address keyToMove = ownersIndex[ownersIndex.length - 1];
            ownersIndex[indexToDelete] = keyToMove;
            owners[keyToMove] = indexToDelete; 
            ownersIndex.length--;
        }
    }
}


/**
 * IObservable
 *
 * Allows observers to register and unregister with the 
 * implementing smart-contract that is observable
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
interface IObservable {


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) public view returns (bool);


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() public view returns (uint);


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) public view returns (address);


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) public;


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) public;
}


/**
 * Abstract Observable
 *
 * Allows observers to register and unregister with the the 
 * implementing smart-contract that is observable
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract Observable is IObservable {


    // Observers
    mapping (address => uint) private observers;
    address[] private observerIndex;


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) public view returns (bool) {
        return observers[_account] < observerIndex.length && _account == observerIndex[observers[_account]];
    }


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() public view returns (uint) {
        return observerIndex.length;
    }


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) public view returns (address) {
        return observerIndex[_index];
    }


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) public {
        require(canRegisterObserver(_observer));
        if (!isObserver(_observer)) {
            observers[_observer] = observerIndex.push(_observer) - 1;
        }
    }


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) public {
        require(canUnregisterObserver(_observer));
        if (isObserver(_observer)) {
            uint indexToDelete = observers[_observer];
            address keyToMove = observerIndex[observerIndex.length - 1];
            observerIndex[indexToDelete] = keyToMove;
            observers[keyToMove] = indexToDelete;
            observerIndex.length--;
        }
    }


    /**
     * Returns whether it is allowed to register `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal view returns (bool);


    /**
     * Returns whether it is allowed to unregister `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal view returns (bool);
}



/**
 * ITokenObserver
 *
 * Allows a token smart-contract to notify observers 
 * when tokens are received
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
interface ITokenObserver {


    /**
     * Called by the observed token smart-contract in order 
     * to notify the token observer when tokens are received
     *
     * @param _from The address that the tokens where send from
     * @param _value The amount of tokens that was received
     */
    function notifyTokensReceived(address _from, uint _value) public;
}


/**
 * TokenObserver
 *
 * Allows observers to be notified by an observed token smart-contract
 * when tokens are received
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract TokenObserver is ITokenObserver {


    /**
     * Called by the observed token smart-contract in order 
     * to notify the token observer when tokens are received
     *
     * @param _from The address that the tokens where send from
     * @param _value The amount of tokens that was received
     */
    function notifyTokensReceived(address _from, uint _value) public {
        onTokensReceived(msg.sender, _from, _value);
    }


    /**
     * Event handler
     * 
     * Called by `_token` when a token amount is received
     *
     * @param _token The token contract that received the transaction
     * @param _from The account or contract that send the transaction
     * @param _value The value of tokens that where received
     */
    function onTokensReceived(address _token, address _from, uint _value) internal;
}



/**
 * ITokenRetriever
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
interface ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public;
}


/**
 * TokenRetriever
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 18/10/2017
 * #author Frank Bonnet
 */
contract TokenRetriever is ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }
}


/**
 * Input validation
 *
 * Validates argument length
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract InputValidator {


    /**
     * ERC20 Short Address Attack fix
     */
    modifier safe_arguments(uint _numArgs) {
        assert(msg.data.length == _numArgs * 32 + 4);
        _;
    }
}


/**
 * ERC20 compatible token interface
 *
 * - Implements ERC 20 Token standard
 * - Implements short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
interface IToken { 

    /** 
     * Get the total supply of tokens
     * 
     * @return The total supply
     */
    function totalSupply() public view returns (uint);


    /** 
     * Get balance of `_owner` 
     * 
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public view returns (uint);


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public returns (bool);


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool);


    /** 
     * `msg.sender` approves `_spender` to spend `_value` tokens
     * 
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint _value) public returns (bool);


    /** 
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     * 
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public view returns (uint);
}


/**
 * ERC20 compatible token
 *
 * - Implements ERC 20 Token standard
 * - Implements short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract Token is IToken, InputValidator {

    // Ethereum token standard
    string public standard = "Token 0.3.1";
    string public name;        
    string public symbol;
    uint8 public decimals;

    // Token state
    uint internal totalTokenSupply;

    // Token balances
    mapping (address => uint) internal balances;

    // Token allowances
    mapping (address => mapping (address => uint)) internal allowed;


    // Events
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    /** 
     * Construct ERC20 token
     * 
     * @param _name The full token name
     * @param _symbol The token symbol (aberration)
     * @param _decimals The token precision
     */
    function Token(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = 0;
        totalTokenSupply = 0;
    }


    /** 
     * Get the total token supply
     * 
     * @return The total supply
     */
    function totalSupply() public view returns (uint) {
        return totalTokenSupply;
    }


    /** 
     * Get balance of `_owner` 
     * 
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public safe_arguments(2) returns (bool) {

        // Check if the sender has enough tokens
        require(balances[msg.sender] >= _value);   

        // Check for overflows
        require(balances[_to] + _value >= balances[_to]);

        // Transfer tokens
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        // Notify listeners
        Transfer(msg.sender, _to, _value);
        return true;
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not 
     */
    function transferFrom(address _from, address _to, uint _value) public safe_arguments(3) returns (bool) {

        // Check if the sender has enough
        require(balances[_from] >= _value);

        // Check for overflows
        require(balances[_to] + _value >= balances[_to]);

        // Check allowance
        require(_value <= allowed[_from][msg.sender]);

        // Transfer tokens
        balances[_to] += _value;
        balances[_from] -= _value;

        // Update allowance
        allowed[_from][msg.sender] -= _value;

        // Notify listeners
        Transfer(_from, _to, _value);
        return true;
    }


    /** 
     * `msg.sender` approves `_spender` to spend `_value` tokens
     * 
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint _value) public safe_arguments(2) returns (bool) {

        // Update allowance
        allowed[msg.sender][_spender] = _value;

        // Notify listeners
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /** 
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     * 
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public view returns (uint) {
      return allowed[_owner][_spender];
    }
}



/**
 * IManagedToken
 *
 * Adds the following functionality to the basic ERC20 token
 * - Locking
 * - Issuing
 * - Burning 
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
interface IManagedToken { 

    /** 
     * Returns true if the token is locked
     * 
     * @return Whether the token is locked
     */
    function isLocked() public view returns (bool);


    /**
     * Locks the token so that the transfering of value is disabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function lock() public returns (bool);


    /**
     * Unlocks the token so that the transfering of value is enabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() public returns (bool);


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the tokens where sucessfully issued or not
     */
    function issue(address _to, uint _value) public returns (bool);


    /**
     * Burns `_value` tokens of `_from`
     *
     * @param _from The address that owns the tokens to be burned
     * @param _value The amount of tokens to be burned
     * @return Whether the tokens where sucessfully burned or not 
     */
    function burn(address _from, uint _value) public returns (bool);
}


/**
 * ManagedToken
 *
 * Adds the following functionality to the basic ERC20 token
 * - Locking
 * - Issuing
 * - Burning 
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract ManagedToken is IManagedToken, Token, MultiOwned {

    // Token state
    bool internal locked;


    /**
     * Allow access only when not locked
     */
    modifier only_when_unlocked() {
        require(!locked);
        _;
    }


    /** 
     * Construct managed ERC20 token
     * 
     * @param _name The full token name
     * @param _symbol The token symbol (aberration)
     * @param _decimals The token precision
     * @param _locked Whether the token should be locked initially
     */
    function ManagedToken(string _name, string _symbol, uint8 _decimals, bool _locked) public 
        Token(_name, _symbol, _decimals) {
        locked = _locked;
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public only_when_unlocked returns (bool) {
        return super.transfer(_to, _value);
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) public only_when_unlocked returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }


    /** 
     * `msg.sender` approves `_spender` to spend `_value` tokens
     * 
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint _value) public returns (bool) {
        return super.approve(_spender, _value);
    }


    /** 
     * Returns true if the token is locked
     * 
     * @return Whether the token is locked
     */
    function isLocked() public view returns (bool) {
        return locked;
    }


    /**
     * Locks the token so that the transfering of value is enabled 
     *
     * @return Whether the locking was successful or not
     */
    function lock() public only_owner returns (bool)  {
        locked = true;
        return locked;
    }


    /**
     * Unlocks the token so that the transfering of value is enabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() public only_owner returns (bool)  {
        locked = false;
        return !locked;
    }


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _to, uint _value) public only_owner safe_arguments(2) returns (bool) {
        
        // Check for overflows
        require(balances[_to] + _value >= balances[_to]);

        // Create tokens
        balances[_to] += _value;
        totalTokenSupply += _value;

        // Notify listeners 
        Transfer(0, this, _value);
        Transfer(this, _to, _value);
        return true;
    }


    /**
     * Burns `_value` tokens of `_recipient`
     *
     * @param _from The address that owns the tokens to be burned
     * @param _value The amount of tokens to be burned
     * @return Whether the tokens where sucessfully burned or not
     */
    function burn(address _from, uint _value) public only_owner safe_arguments(2) returns (bool) {

        // Check if the token owner has enough tokens
        require(balances[_from] >= _value);

        // Check for overflows
        require(balances[_from] - _value <= balances[_from]);

        // Burn tokens
        balances[_from] -= _value;
        totalTokenSupply -= _value;

        // Notify listeners 
        Transfer(_from, 0, _value);
        return true;
    }
}


/**
 * ATM Security token (KATM)
 *
 * KATM maintaining the primary security functions of the ATM token as 
 * outlined within the whitepaper.
 *
 * Those who bear ATMS will be entitled to profit sharing in the form of dividends, 
 * and is considered the "Security" token.
 *
 * #created 30/10/2017
 * #author Frank Bonnet
 */
contract KATMToken is ManagedToken, Observable, TokenRetriever {

    
    /**
     * Construct the managed security token
     */
    function KATMToken() public ManagedToken("KATM Security", "KATM", 8, false) {}


    /**
     * Returns whether sender is allowed to register `_observer`
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal view returns (bool) {
        return _observer != address(this) && isOwner(msg.sender);
    }


    /**
     * Returns whether sender is allowed to unregister `_observer`
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal view returns (bool) {
        return msg.sender == _observer || isOwner(msg.sender);
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public returns (bool) {
        bool result = super.transfer(_to, _value);
        if (isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(msg.sender, _value);
        }

        return result;
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        bool result = super.transferFrom(_from, _to, _value);
        if (isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(_from, _value);
        }

        return result;
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public only_owner {
        super.retrieveTokens(_tokenContract);
    }


    /**
     * Prevents the accidental sending of ether
     */
    function () public payable {
        revert();
    }
}