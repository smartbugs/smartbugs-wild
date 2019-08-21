pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {

    function totalSupply() public constant returns (uint supply);
    
    function balanceOf(address _owner) public constant returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    
    function approve(address _spender, uint _value) public returns (bool success);
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    event Burn(address indexed _from, uint _value);
}


contract StandardToken is ERC20 {

    using SafeMath for uint;

    uint public totalSupply;

    mapping (address => uint) balances;
    
    mapping (address => mapping (address => uint)) allowed;

    function totalSupply() public constant returns (uint) {
        return totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && _value > 0);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

contract Controlled {

    address public controller;

    constructor() public {
        controller = msg.sender;
    }

    function changeController(address _newController) public only_controller {
        controller = _newController;
    }
    
    function getController() constant public returns (address) {
        return controller;
    }

    modifier only_controller { 
        require(msg.sender == controller);
        _; 
    }

}


contract IVPToken is StandardToken, Controlled {
    
    using SafeMath for uint;

    string public constant name = "IVP Token";

    string public constant symbol = "IVP";

    uint8 public constant decimals = 9;
    
    // for token circulation on platforms that integrate Theta before unlockTime
    mapping (address => bool) internal frozenAccount;

    constructor() public {
        totalSupply = 1000*10000*10000 * 10 ** uint256(decimals); 
        balances[msg.sender] = totalSupply; 
    }

    function transfer(address _to, uint _amount) can_transfer(msg.sender, _to) public returns (bool success) {
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _amount) can_transfer(_from, _to) public returns (bool success) {
        return super.transferFrom(_from, _to, _amount);
    }

    function mint(address _owner, uint _amount) external only_controller returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_owner] = balances[_owner].add(_amount);

        emit Transfer(0, _owner, _amount);
        return true;
    }
    
    function burn(uint _amount) public returns (bool) {
    	require(balances[msg.sender] >= _amount && _amount > 0);
    	
    	totalSupply = totalSupply.sub(_amount);
    	balances[msg.sender] = balances[msg.sender].sub(_amount);
    	
        emit Burn(msg.sender, _amount);
        return true;
    }

    function burnFrom(address _from, uint _amount) public returns (bool) {
    	require(balances[_from] >= _amount && _amount > 0 && allowed[_from][msg.sender] >= _amount);
    	
    	totalSupply = totalSupply.sub(_amount);
    	balances[_from] = balances[_from].sub(_amount);
    	allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    	
        emit Burn(_from, _amount);
        return true;
    }
    
    function freezeAccount(address _addr, bool _isFrozen) only_controller public {
    	frozenAccount[_addr] = _isFrozen;
    }

    function isFrozenAccount(address _addr) constant public returns(bool) {
        return frozenAccount[_addr];
    }

    modifier can_transfer(address _from, address _to) {
        require(!isFrozenAccount(_from) && !isFrozenAccount(_to));
        _;
    }

}