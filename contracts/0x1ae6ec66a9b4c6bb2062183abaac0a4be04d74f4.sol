pragma solidity ^0.4.22;

//standard library for uint
library SafeMath { 
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

  function pow(uint256 a, uint256 b) internal pure returns (uint256){ //power function
    if (b == 0){
      return 1;
    }
    uint256 c = a**b;
    assert (c >= a);
    return c;
  }
}

//standard contract to identify owner
contract Ownable {

  address public owner;

  address public newOwner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }
}
contract SHAREToken is Ownable { //ERC - 20 token contract
  using SafeMath for uint;
  // Triggered when tokens are transferred.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // Triggered whenever approve(address _spender, uint256 _value) is called.
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  string public constant symbol = "SVX";
  string public constant name = "SHARE";
  uint8 public constant decimals = 6;
  uint256 _totalSupply = 200000000 * ((uint)(10) ** (uint)(decimals)); //include decimals;

  // Balances for each account
  mapping(address => uint256) balances;

  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping (address => uint256)) allowed;

  function totalSupply() public view returns (uint256) { //standard ERC-20 function
    return _totalSupply;
  }

  function balanceOf(address _address) public view returns (uint256 balance) {//standard ERC-20 function
    return balances[_address];
  }
  
  bool public locked = true;
  function changeLockTransfer (bool _request) public onlyOwner {
    locked = _request;
  }
  
  //standard ERC-20 function
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(this != _to && _to != address(0));
    require(!locked);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(msg.sender,_to,_amount);
    return true;
  }

  //standard ERC-20 function
  function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success){
    require(this != _to && _to != address(0));
    require(!locked);
    balances[_from] = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(_from,_to,_amount);
    return true;
  }

  //standard ERC-20 function
  function approve(address _spender, uint256 _amount)public returns (bool success) { 
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  //standard ERC-20 function
  function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  address public tokenHolder;
  
  constructor() public {
    owner = 0x4fD26ff0Af100C017BEA88Bd6007FcB68C237960;
    tokenHolder = 0x4fD26ff0Af100C017BEA88Bd6007FcB68C237960;
    balances[tokenHolder] = _totalSupply;
    emit Transfer(address(this), tokenHolder, _totalSupply);
  }

  address public crowdsaleContract;

  function setCrowdsaleContract (address _address) public{
    require(crowdsaleContract == address(0));

    crowdsaleContract = _address;
  }

  uint public crowdsaleBalance = 120000000 * ((uint)(10) ** (uint)(decimals)); //include decimals;
  
  function sendCrowdsaleTokens (address _address, uint _value) public {
    require(msg.sender == crowdsaleContract);

    balances[tokenHolder] = balances[tokenHolder].sub(_value);
    balances[_address] = balances[_address].add(_value);
    
    crowdsaleBalance = crowdsaleBalance.sub(_value);
    
    emit Transfer(tokenHolder,_address,_value);    
  }

  uint public teamBalance = 20000000 * ((uint)(10) ** (uint)(decimals)); 
  uint public foundersBalance = 40000000 * ((uint)(10) ** (uint)(decimals));
  uint public platformReferral = 10000000 * ((uint)(10) ** (uint)(decimals));
  uint public bountyBalance = 6000000 * ((uint)(10) ** (uint)(decimals));
  uint public advisorsBalance = 4000000 * ((uint)(10) ** (uint)(decimals));

  function sendTeamBalance (address[] _addresses, uint[] _values) external onlyOwner {
    uint buffer = 0;
    for(uint i = 0; i < _addresses.length; i++){
      balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);
      buffer = buffer.add(_values[i]);
      emit Transfer(tokenHolder,_addresses[i],_values[i]);
    }
    teamBalance = teamBalance.sub(buffer);
    balances[tokenHolder] = balances[tokenHolder].sub(buffer);
  }

  function sendFoundersBalance (address[] _addresses, uint[] _values) external onlyOwner {
    uint buffer = 0;
    for(uint i = 0; i < _addresses.length; i++){
      balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);
      buffer = buffer.add(_values[i]);
      emit Transfer(tokenHolder,_addresses[i],_values[i]);
    }
    foundersBalance = foundersBalance.sub(buffer);
    balances[tokenHolder] = balances[tokenHolder].sub(buffer);
  }

  function platformReferralBalance (address[] _addresses, uint[] _values) external onlyOwner {
    uint buffer = 0;
    for(uint i = 0; i < _addresses.length; i++){
      balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);
      buffer = buffer.add(_values[i]);
      emit Transfer(tokenHolder,_addresses[i],_values[i]);
    }
    platformReferral = platformReferral.sub(buffer);
    balances[tokenHolder] = balances[tokenHolder].sub(buffer);
  }

  function sendBountyBalance (address[] _addresses, uint[] _values) external onlyOwner {
    uint buffer = 0;
    for(uint i = 0; i < _addresses.length; i++){
      balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);
      buffer = buffer.add(_values[i]);
      emit Transfer(tokenHolder,_addresses[i],_values[i]);
    }
    bountyBalance = bountyBalance.sub(buffer);
    balances[tokenHolder] = balances[tokenHolder].sub(buffer);
  }

  function sendAdvisorsBalance (address[] _addresses, uint[] _values) external onlyOwner {
    uint buffer = 0;
    for(uint i = 0; i < _addresses.length; i++){
      balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);
      buffer = buffer.add(_values[i]);
      emit Transfer(tokenHolder,_addresses[i],_values[i]);
    }
    advisorsBalance = advisorsBalance.sub(buffer);
    balances[tokenHolder] = balances[tokenHolder].sub(buffer);
  }

  function burnTokens (uint _value) external {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    emit Transfer(msg.sender, 0, _value);
    _totalSupply = _totalSupply.sub(_value);
  }

  function burnUnsoldTokens () public onlyOwner {
    balances[tokenHolder] = balances[tokenHolder].sub(crowdsaleBalance);
    emit Transfer(address(tokenHolder), 0, crowdsaleBalance);
    _totalSupply = _totalSupply.sub(crowdsaleBalance);
    crowdsaleBalance = 0;
  }

}