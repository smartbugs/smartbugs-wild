pragma solidity ^0.4.24;

contract Owned {
    
    /// 'owner' is the only address that can call a function with 
    /// this modifier
    address public owner;
    address internal newOwner;
    
    ///@notice The constructor assigns the message sender to be 'owner'
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    event updateOwner(address _oldOwner, address _newOwner);
    
    ///change the owner
    function changeOwner(address _newOwner) public onlyOwner returns(bool) {
        require(owner != _newOwner);
        newOwner = _newOwner;
        return true;
    }
    
    /// accept the ownership
    function acceptNewOwner() public returns(bool) {
        require(msg.sender == newOwner);
        emit updateOwner(owner, newOwner);
        owner = newOwner;
        return true;
    }
}

contract SafeMath {
    // @dev safe Mul function
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    // @dev safe Sub function
    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    // @dev safe Add function
    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

}

contract Pausable is Owned{
    
    bool private _paused = false;
    
    event Paused();
    event Unpaused();
    
    // @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }
    
    // @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(_paused);
        _;
    }
    
    // @dev called by the owner to pause
    function pause() whenNotPaused public onlyOwner {
        _paused = true;
        emit Paused();
    } 
    
    // @dev called by the owner to unpause, returns to normal state.
    function unpause() whenPaused public onlyOwner {
        _paused = false;
        emit Unpaused();
    }
    
    // @dev return true if the contract is paused, false otherwise.
    function paused() view public returns(bool) {
        return _paused;
    }
}


contract ERC20Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    
    /// user tokens
    mapping (address => uint256) public balances;
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract CUSEtoken is ERC20Token, Pausable, SafeMath {
    
    string public name = "USE Call Option";
    string public symbol = "CUSE";
    uint public decimals = 18;
    
    uint256 public totalSupply = 0;
    
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool success) {
    //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowances[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
          balances[_to] += _value;
          balances[_from] -= _value;
          allowances[_from][msg.sender] -= _value;
          emit Transfer(_from, _to, _value);
          return true;
        } else { return false; }
    }
    
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    
    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
    
    function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        allowances[msg.sender][_spender] = safeAdd(allowances[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }
    
    function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        allowances[msg.sender][_spender] = safeSub(allowances[msg.sender][_spender], _subtractedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }
    
    mapping (address => uint256) public balances;
    
    mapping (address => mapping (address => uint256)) allowances;
}

contract CUSEcontract is CUSEtoken{
    
    address public usechainAddress;
    uint constant public INITsupply = 9e27;
    uint constant public CUSE12 = 75e24;
    uint constant public USEsold = 3811759890e18;
    function () payable public {
        revert();
    }
    
    constructor(address _usechainAddress) public {
        usechainAddress = _usechainAddress;
        totalSupply = INITsupply - CUSE12 - USEsold;
        balances[usechainAddress] = totalSupply;
        emit Transfer(address(this), usechainAddress, totalSupply);
    }

}