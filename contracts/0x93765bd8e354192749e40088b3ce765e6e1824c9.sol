pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ryancoin {
    using SafeMath for uint256;
    
    uint256 public constant _initialSupply = 15000000 * (10 ** uint256(decimals));
    uint256 _totalSupply = 0;
    uint256 _totalSold = 0;
    
    string public constant symbol = "RYC";
    string public constant name = "Ryancoin";
    uint8 public constant decimals = 6;
    uint256 public rate = 1 ether / (500 * (10 ** uint256(decimals)));
    address public owner;
    
    bool public _contractStatus = true;
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed; //control allow to spend
    mapping (address => bool)  _frozenAccount;
    mapping (address => bool)  _tokenAccount;

    address[] tokenHolders;
    
    //Event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event UpdateStatus(string newStatus);
    event Burn(address target, uint256 _value);
    event MintedToken(address target, uint256 _value);
    event FrozenFunds(address target, bool _value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function Ryancoin()  {
        owner = msg.sender;
        _totalSupply = _initialSupply;
        balances[owner] = _totalSupply;
        setTokenHolders(owner);
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0);
        owner = newOwner;
    }
    
    function stopContract() public onlyOwner {
        _contractStatus = false;
        UpdateStatus("Contract is stop");
    }
    
    function enableContract() public onlyOwner {
        _contractStatus = true;
        UpdateStatus("Contract is enable");
    }
    
    function totalSupply() public constant returns (uint256){
        return _totalSupply;
    }
    
    function totalSold() public constant returns (uint256){
        return _totalSold;
    }
    
    function totalRate() public constant returns (uint256){
        return rate;
    }
    
   
    function updateRate(uint256 _value) onlyOwner public returns (bool success){
        require(_value > 0);
        rate = 1 ether / (_value * (10 ** uint256(decimals)));
        return true;
    }
    
    function () payable public {
        createTokens(); //send money to contract owner
    }
    
    function createTokens() public payable{
        require(msg.value > 0 && msg.value > rate && _contractStatus);
        
        uint256 tokens = msg.value.div(rate);
        
        require(tokens + _totalSold < _totalSupply);
        
        require(
            balances[owner]  >= tokens
            && tokens > 0
        );
        
        _transfer(owner, msg.sender, tokens);
        Transfer(owner, msg.sender, tokens);
        _totalSold = _totalSold.add(tokens);
        
        owner.transfer(msg.value); //transfer ether to contract ower
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success){
        //Check contract is stop
        require(_contractStatus);
        require(!_frozenAccount[msg.sender]);
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check value more than 0
        require(_value > 0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint256 previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Set token holder list
        setTokenHolders(_to);
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);
    }
    
    function transferFromOwner(address _from, address _to, uint256 _value) onlyOwner public returns (bool success){
        _transfer(_from, _to, _value);
        return true;
    }
    
    function setTokenHolders(address _holder) internal {
        if (_tokenAccount[_holder]) return;
        tokenHolders.push(_holder) -1;
        _tokenAccount[_holder] = true;
    }
    
    function getTokenHolders() view public returns (address[]) {
        return tokenHolders;
    }
    
    function countTokenHolders() view public returns (uint) {
        return tokenHolders.length;
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(balances[msg.sender] >= _value);    // Check if the sender has enough
        balances[msg.sender] -= _value;             // Subtract from the sender
        _totalSupply -= _value;                     // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }
    
    function burnFromOwner(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(_from != address(0));
        require(_value > 0);
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        balances[_from] -= _value;                         // Subtract from the targeted balance
        _totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
    
    function mintToken(address _target, uint256 _mintedAmount) onlyOwner public {
        require(_target != address(0));
        require(_mintedAmount > 0);
        balances[_target] += _mintedAmount;
        _totalSupply += _mintedAmount;
        setTokenHolders(_target);
        Transfer(0, owner, _mintedAmount);
        Transfer(owner, _target, _mintedAmount);
        MintedToken(_target, _mintedAmount);
    }
    
    function getfreezeAccount(address _target) public constant returns (bool freeze) {
        require(_target != 0x0);
        return _frozenAccount[_target];
    }
    
    function freezeAccount(address _target, bool freeze) onlyOwner public {
        require(_target != 0x0);
        _frozenAccount[_target] = freeze;
        FrozenFunds(_target, freeze);
    }
    
     /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_from != address(0));
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return true;
    }
  
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
     }
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        require(_owner != address(0));
        require(_spender != address(0));
        return allowed[_owner][_spender];
    }
    
    /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        require(_spender != address(0));
        require(_addedValue > 0);
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        require(_spender != address(0));
        require(_subtractedValue > 0);
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
  }
    
}