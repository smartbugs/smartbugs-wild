pragma solidity ^0.4.15;

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() constant returns (uint256 tS);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
 
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) returns (bool success);
 
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    // Used only once for burning excess tokens after ICO.
    function burnExcess(uint256 _value) returns (bool success);

    // Used for burning 100 tokens for every completed poll up to maximum of 10% of totalSupply.
    function burnPoll(uint256 _value) returns (bool success);
 
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Triggered whenever tokens are destroyed
    event Burn(address indexed from, uint256 value);
}
 
contract POLLToken is ERC20Interface {

    string public constant symbol = "POLL";
    string public constant name = "ClearPoll Token";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 10000000 * 10 ** uint256(decimals);
    
    address public owner;
    
    bool public excessTokensBurnt = false;

    uint256 public pollCompleted = 0;
    
    uint256 public pollBurnInc = 100 * 10 ** uint256(decimals);

    uint256 public pollBurnQty = 0;

    bool public pollBurnCompleted = false;

    uint256 public pollBurnQtyMax;

    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;

    // Handle ether mistakenly sent to contract
    function () payable {
      if (msg.value > 0) {
          if (!owner.send(msg.value)) revert();
      }
    }

    function POLLToken() {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    // Get the total token supply
    function totalSupply() constant returns (uint256 tS) {
        tS = _totalSupply;
    }
 
    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from, address _to, uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Used only once for burning excess tokens after ICO.
    function burnExcess(uint256 _value) public returns (bool success) {
        require(balanceOf(msg.sender) >= _value && msg.sender == owner && !excessTokensBurnt);
        balances[msg.sender] -= _value;
        _totalSupply -= _value;
        Burn(msg.sender, _value);
        pollBurnQtyMax = totalSupply() / 10;
        excessTokensBurnt = true;
        return true;
    }   

    // Used for burning 100 tokens for every completed poll up to maximum of 10% of totalSupply.
    function burnPoll(uint256 _value) public returns (bool success) {    	
        require(msg.sender == owner && excessTokensBurnt && _value > pollCompleted && !pollBurnCompleted);
        uint256 burnQty;
        if ((_value * pollBurnInc) <= pollBurnQtyMax) {
            burnQty = (_value-pollCompleted) * pollBurnInc;
            balances[msg.sender] -= burnQty;
            _totalSupply -= burnQty;
            Burn(msg.sender, burnQty);
            pollBurnQty += burnQty;
            pollCompleted = _value;
            if (pollBurnQty == pollBurnQtyMax) pollBurnCompleted = true;
            return true;
        } else if (pollBurnQty < pollBurnQtyMax) {
			burnQty = pollBurnQtyMax - pollBurnQty;
            balances[msg.sender] -= burnQty;
            _totalSupply -= burnQty;
            Burn(msg.sender, burnQty);
            pollBurnQty += burnQty;
            pollCompleted = _value;
            pollBurnCompleted = true;
            return true;
        } else {
            return false;
        }
    }

}