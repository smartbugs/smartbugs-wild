pragma solidity ^0.4.15;

contract InputValidator {


    /**
     * ERC20 Short Address Attack fix
     */
    modifier safe_arguments(uint _numArgs) {
        assert(msg.data.length == _numArgs * 32 + 4);
        _;
    }
}

contract Owned {

    // The address of the account that is the current owner 
    address internal owner;


    /**
     * The publisher is the inital owner
     */
    function Owned() {
        owner = msg.sender;
    }


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner);

        _;
    }
}

contract IOwnership {

    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) constant returns (bool);


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() constant returns (address);
}

contract Ownership is IOwnership, Owned {


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public constant returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public constant returns (address) {
        return owner;
    }
}

contract ITransferableOwnership {

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner);
}

contract TransferableOwnership is ITransferableOwnership, Ownership {


    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) public only_owner {
        owner = _newOwner;
    }
}


/**
 * @title ERC20 compatible token interface
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
 * - Short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract IToken { 

    /** 
     * Get the total supply of tokens
     * 
     * @return The total supply
     */
    function totalSupply() constant returns (uint);


    /** 
     * Get balance of `_owner` 
     * 
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) constant returns (uint);


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) returns (bool);


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) returns (bool);


    /** 
     * `msg.sender` approves `_spender` to spend `_value` tokens
     * 
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint _value) returns (bool);


    /** 
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     * 
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint);
}


/**
 * @title ERC20 compatible token
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
 * - Short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract Token is IToken, InputValidator {

    // Ethereum token standard
    string public standard = "Token 0.3";
    string public name;        
    string public symbol;
    uint8 public decimals = 8;

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
     * Construct 
     * 
     * @param _name The full token name
     * @param _symbol The token symbol (aberration)
     */
    function Token(string _name, string _symbol) {
        name = _name;
        symbol = _symbol;
        balances[msg.sender] = 0;
        totalTokenSupply = 0;
    }


    /** 
     * Get the total token supply
     * 
     * @return The total supply
     */
    function totalSupply() public constant returns (uint) {
        return totalTokenSupply;
    }


    /** 
     * Get balance of `_owner` 
     * 
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public constant returns (uint) {
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
    function allowance(address _owner, address _spender) public constant returns (uint) {
      return allowed[_owner][_spender];
    }
}


/**
 * @title ManagedToken interface
 *
 * Adds the following functionallity to the basic ERC20 token
 * - Locking
 * - Issuing
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract IManagedToken is IToken { 

    /** 
     * Returns true if the token is locked
     * 
     * @return Whether the token is locked
     */
    function isLocked() constant returns (bool);


    /**
     * Unlocks the token so that the transferring of value is enabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() returns (bool);


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the tokens where sucessfully issued or not
     */
    function issue(address _to, uint _value) returns (bool);
}


/**
 * @title ManagedToken
 *
 * Adds the following functionallity to the basic ERC20 token
 * - Locking
 * - Issuing
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract ManagedToken is IManagedToken, Token, TransferableOwnership {

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
     * Construct 
     * 
     * @param _name The full token name
     * @param _symbol The token symbol (aberration)
     * @param _locked Whether the token should be locked initially
     */
    function ManagedToken(string _name, string _symbol, bool _locked) Token(_name, _symbol) {
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
     * @return Wheter the token is locked
     */
    function isLocked() public constant returns (bool) {
        return locked;
    }


    /**
     * Unlocks the token so that the transferring of value is enabled 
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
}


/**
 * @title Token retrieve interface
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract ITokenRetreiver {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retreiveTokens(address _tokenContract);
}

/**
 * @title GLA (Gladius) token
 *
 * #created 26/09/2017
 * #author Frank Bonnet
 */
contract GLAToken is ManagedToken, ITokenRetreiver {


    /**
     * Starts with a total supply of zero and the creator starts with 
     * zero tokens (just like everyone else)
     */
    function GLAToken() ManagedToken("Gladius Token", "GLA", true) {}


    /**
     * Failsafe mechanism
     * 
     * Allows owner to retreive tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retreiveTokens(address _tokenContract) public only_owner {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(owner, tokenBalance);
        }
    }


    /**
     * Prevents accidental sending of ether
     */
    function () payable {
        revert();
    }
}