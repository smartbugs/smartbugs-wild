pragma solidity ^0.5.3;

contract Token {

    /// @return total amount of tokens
    function totalSupply() public view returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public  returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract Ownable {
    address public owner;
    
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract Stoppable is Ownable {
    bool public stopped;
    
    constructor() public {
        stopped = false;
    }
    
    modifier stoppable() {
        if (stopped) {
            revert();
        }
        _;
    }
    
    function stop() public onlyOwner {
        stopped = true;
    }
    
    function start() public onlyOwner {
        stopped = false;
    }
}

contract StandardToken is Token, Stoppable {

    function transfer(address _to, uint256 _value) public stoppable returns (bool success) {
        if (_value > 0 && balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public stoppable returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to] && _value > 0) {
            allowed[_from][msg.sender] -= _value;
            balances[_from] -= _value;
            balances[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public stoppable returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public stoppable view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
}


contract CCCToken is StandardToken {

    function () external {
        /// If ether is sent to this address, send it back.
        revert();
    }


    string public name = 'Coinchat Game';
    uint8 public decimals = 18;
    string public symbol = 'CCG';
    string public version = 'v201901311510';


    constructor() public {
        balances[msg.sender] = 10000000000000000000000000000;
        _totalSupply = 10000000000000000000000000000;
        name = "Coinchat Game";
        decimals = 18;
        symbol = "CCG";
    }
}