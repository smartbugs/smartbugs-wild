pragma solidity ^0.4.4;

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }


    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract PancaCoin is StandardToken { 
    
    address owner = msg.sender;
    string public constant name = "PancaCoin";
    string public constant symbol = "PANCA";
    uint public constant decimals = 2;
    uint256 public totalSupply = 1000000000e2;
    uint256 public totalDistributed;
    uint256 public constant requestMinimum = 1 ether / 1000; // 0.01 Ether
    uint256 public tokensPerEth = 1000000e2;
    uint public target0drop = 2000;
    
    event Airdrop(address indexed _owner, uint _amount, uint _balance);
    event Burn(address indexed burner, uint256 value);
    event TokensPerEthUpdated(uint _tokensPerEth);
    modifier Dev {
        require(msg.sender == owner);
        _;
    }

    function Distribute(address _participant, uint _amount) Dev internal {

        require( _amount > 0 );      
        require( totalDistributed < totalSupply );
        balances[_participant] = balances[_participant] + (_amount);
        totalDistributed = totalDistributed + (_amount);

        // log
        emit Airdrop(_participant, _amount, balances[_participant]);
        emit Transfer(address(0), _participant, _amount);
    }
    
    function DistributeAirdrop(address _participant, uint _amount) Dev external {        
        Distribute(_participant, _amount);
    }

    function DistributeAirdropMultiple(address[] _addresses, uint _amount) Dev external {        
        for (uint i = 0; i < _addresses.length; i++) Distribute(_addresses[i], _amount);
    }

    function updateTokensPerEth(uint _tokensPerEth) Dev public  {        
        tokensPerEth = _tokensPerEth;
        emit TokensPerEthUpdated(_tokensPerEth);
    }


    function burn(uint256 _value) Dev public {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = (_value);
        totalSupply = totalSupply-(_value);
        totalDistributed = totalDistributed-(_value);
        emit Burn(burner, _value);
    }
    

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    

    function withdraw(uint256 _wdamount) Dev public {
        uint256 wantAmount = _wdamount;
        owner.transfer(wantAmount);
    }


}