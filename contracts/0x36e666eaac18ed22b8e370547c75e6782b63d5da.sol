pragma solidity ^0.4.25;

//https://github.com/OpenZeppelin/openzeppelin-solidity
//Lock related functions are fixed or added by TSN

library SafeMath {                             //SafeMath.sol
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) { return 0; }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
  using SafeMath for uint256;
  address public owner;                                              //Ownable.sol
  string public name = "HOTPICK";                                      //DetailedERC20.sol
  string public symbol = "PICK";                                    //DetailedERC20.sol
  uint256 public decimals = 18;                                        //DetailedERC20.sol  
  uint256 totalSupply_ = 20e8 * (10**18);             //BasicToken.sol
  bool public paused = false;                                         //Pausable.sol
  mapping(address => uint256) balances;                              //BasicToken.sol
  mapping(address => mapping (address => uint256)) internal allowed; //StandardToken.sol
  mapping(address => uint256) internal locked;          // new
  event Burn(address indexed burner, uint256 value);                               //BurnableToken.sol
  event Approval(address indexed owner, address indexed spender,uint256 value);    //ERC20.sol
  event Transfer(address indexed from, address indexed to, uint256 value);         //ERC20Basic.sol
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //Ownable.sol
  event Pause();                                                                   //Pausable.sol
  event Unpause();                                                                 //Pausable.sol
  event Lock(address indexed LockedAddress, uint256 LockAmount);             // new. lock each address by amount
  event Unlock(address indexed LockedAddress);           // new

  constructor() public { 
    owner = msg.sender;
    balances[owner] = totalSupply_ ;
  }

  modifier onlyOwner()         {require(msg.sender == owner); _;}  //Ownable.sol
  modifier whenPaused()        {require(paused); _; }              //Pausable.sol
  modifier whenNotPaused()     {require(!paused); _;}              //Pausable.sol

  function balanceOf(address _owner) public view returns (uint256) {  //BasicToken.sol
    return balances[_owner];
  }

  function totalSupply() public view returns (uint256) {  //BasicToken.sol
    return totalSupply_;
  }
  
  function burn(uint256 _value) public { //BurnableToken.sol
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {  //BurnableToken.sol
    require(_value <= balances[_who]);
    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
  
  function burnFrom(address _from, uint256 _value) public {  //StandardBurnableToken.sol
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
  
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
      //StandardToken.sol, PausableToken.sol
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) { //StandardToken.sol
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused returns(bool){
      //StandardToken.sol, PausableToken.sol
    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused returns(bool) {
      //StandardToken.sol, PausableToken.sol
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) { allowed[msg.sender][_spender] = 0;
    } else                           { allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);}
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {//BasicToken.sol, PausableToken.sol
    require(_to != address(0));
    require(locked[msg.sender].add(_value) <= balances[msg.sender]);  //Added
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {  
      //StandardToken.sol, PausableToken.sol
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(locked[_from].add(_value) <= balances[_from]); //Added
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function transferOwnership(address _newOwner) public onlyOwner {   //Ownable.sol
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {   //Ownable.sol
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  function pause() onlyOwner whenNotPaused public {   //Pausable.sol, stop whole transfer
    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {   //Pausable.sol
    paused = false;
    emit Unpause();
  }

  function destroyAndSend(address _recipient) onlyOwner public {   //Destructible.sol
    selfdestruct(_recipient);
  }

  function burnOf(address _who, uint256 _value) public onlyOwner { // burn by owner
    _burn(_who, _value);
  }
  
  function multiTransfer(address[] _to, uint256[] _amount) whenNotPaused public returns (bool) {
    require(_to.length == _amount.length);
    uint256 i;
    uint256 amountSum = 0;
    for (i=0; i < _amount.length; i++){
      require(_amount[i] > 0);
      require(_to[i] != address(0));
      amountSum = amountSum.add(_amount[i]);
    }
    require(locked[msg.sender].add(amountSum) <= balances[msg.sender]);  //Added
    require(amountSum <= balances[msg.sender]);
    for (i=0; i < _to.length; i++){
      balances[_to[i]] = balances[_to[i]].add(_amount[i]);
      emit Transfer(msg.sender, _to[i], _amount[i]);
    }
    balances[msg.sender] = balances[msg.sender].sub(amountSum);
    return true;
  }
  
  function lock(address _lockAddress, uint256 _lockAmount) public onlyOwner returns (bool) {  // stop _lockAddress's transfer
    require(_lockAddress != address(0));
    require(_lockAddress != owner);
    locked[_lockAddress] = _lockAmount; //Added
    emit Lock(_lockAddress, _lockAmount);
    return true;
  }

  function unlock(address _lockAddress) public onlyOwner returns (bool) {
    require(_lockAddress != address(0));
    require(_lockAddress != owner);
    locked[_lockAddress] = 0; //Added
    emit Unlock(_lockAddress);
    return true;
  }

  function multiLock(address[] _lockAddress, uint256[] _lockAmount) public onlyOwner {
    require(_lockAmount.length == _lockAddress.length);
    for (uint i=0; i < _lockAddress.length; i++){
      lock(_lockAddress[i], _lockAmount[i]);
    }
  }

  function multiUnlock(address[] _lockAddress) public onlyOwner {
    for (uint i=0; i < _lockAddress.length; i++){
      unlock(_lockAddress[i]);
    }
  }

  function checkLock(address _address) public view onlyOwner returns (uint256) { //Added
    return locked[_address];
  }

}