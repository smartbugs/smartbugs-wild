pragma solidity ^0.4.18;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EZToken {
    using SafeMath for uint256;

    // Public variables of the token
    string public name = "EZToken" ;
    string public symbol = "EZT";
    uint8 public decimals = 8;
    uint256 totalSupply_ = 0;
    uint256 constant icoSupply = 11500000;
    uint256 constant foundersSupply = 3500000;
    uint256 constant yearlySupply = 3500000;
    
    
    
    mapping (address => uint) public freezedAccounts;

    
    uint constant founderFronzenUntil = 1530403200;  //2018-07-01
    uint constant year1FronzenUntil = 1546300800; //2019-01-01
    uint constant year2FronzenUntil = 1577836800; //2020-01-01
    uint constant year3FronzenUntil = 1609459200; //2021-01-01
    uint constant year4FronzenUntil = 1640995200; //2022-01-01
    uint constant year5FronzenUntil = 1672531200; //2023-01-01
    uint constant year6FronzenUntil = 1704067200; //2024-01-01
    uint constant year7FronzenUntil = 1735689600; //2025-01-01
    uint constant year8FronzenUntil = 1767225600; //2026-01-01
    uint constant year9FronzenUntil = 1798761600; //2027-01-01
    uint constant year10FronzenUntil = 1830297600; //2028-01-01
    
    // This creates an array with all balances
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;


    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function EZToken(address _founderAddress, address _year1, address _year2, address _year3, address _year4, address _year5, address _year6, address _year7, address _year8, address _year9, address _year10 ) public {
        totalSupply_ = 50000000 * 10 ** uint256(decimals);
        
        balances[msg.sender] = icoSupply * 10 ** uint256(decimals);                 
        Transfer(address(0), msg.sender, icoSupply);
        
        _setFreezedBalance(_founderAddress, foundersSupply, founderFronzenUntil);

        _setFreezedBalance(_year1, yearlySupply, year1FronzenUntil);
        _setFreezedBalance(_year2, yearlySupply, year2FronzenUntil);
        _setFreezedBalance(_year3, yearlySupply, year3FronzenUntil);
        _setFreezedBalance(_year4, yearlySupply, year4FronzenUntil);
        _setFreezedBalance(_year5, yearlySupply, year5FronzenUntil);
        _setFreezedBalance(_year6, yearlySupply, year6FronzenUntil);
        _setFreezedBalance(_year7, yearlySupply, year7FronzenUntil);
        _setFreezedBalance(_year8, yearlySupply, year8FronzenUntil);
        _setFreezedBalance(_year9, yearlySupply, year9FronzenUntil);
        _setFreezedBalance(_year10, yearlySupply, year10FronzenUntil);
    }
    
    /**
    * Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * Set balance and freeze time for address
     */
    function _setFreezedBalance(address _owner, uint256 _amount, uint _lockedUntil) internal {
        require(_owner != address(0));
        require(balances[_owner] == 0);
        freezedAccounts[_owner] = _lockedUntil;
        balances[_owner] = _amount * 10 ** uint256(decimals);     
    }

    /**
     * Get the token balance for account `_owner`
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    /**
     * Returns the amount of tokens approved by the owner that can be
     * transferred to the spender's account
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(freezedAccounts[msg.sender] == 0 || freezedAccounts[msg.sender] < now);
        require(freezedAccounts[_to] == 0 || freezedAccounts[_to] < now);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(freezedAccounts[_from] == 0 || freezedAccounts[_from] < now);
        require(freezedAccounts[_to] == 0 || freezedAccounts[_to] < now);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    

    /**
     * Set allowed for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    /**
    * Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(burner, _value);
    }
}