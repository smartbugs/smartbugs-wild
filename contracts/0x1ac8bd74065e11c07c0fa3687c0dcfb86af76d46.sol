pragma solidity >=0.4.22 <0.6.0;

contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }


}
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner)public view returns (uint256 balance);
    function transfer(address _to, uint256 _value)public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success);
    function approve(address _spender, uint256 _value)public returns (bool success);
    function allowance(address _owner, address _spender)public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StdToken is ERC20,SafeMath {

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != address(0x0));
        _;
    }
    bool public active=true;
    modifier isActive(){
      require(active==true);
      _;
    }
    mapping(address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function transfer(address _to, uint _value) public isActive () validAddress(_to)  returns (bool success){
    if(balances[msg.sender]<_value)revert();
    if(msg.sender != _to){
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  }

    function transferFrom(address _from, address _to, uint256 _value)public isActive() validAddress(_to)  returns (bool success) {
        if (_value <= 0) revert();
        if (balances[_from] < _value) revert();
        if (balances[_to] + _value < balances[_to]) revert();
        if (_value > allowed[_from][msg.sender]) revert();
        balances[_from] = safeSub(balances[_from], _value);                           
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

  function balanceOf(address _owner)public view returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value)public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender)public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}


contract Ownable {
  address owner;

  constructor ()public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner)public onlyOwner {
    if (newOwner != owner) {
      owner = newOwner;
    }
  }
}


contract GAPi_Coin is StdToken,Ownable{
    string public name="GAPi Coin";
    string public symbol="GAPi";
    uint public decimals = 18;

    constructor ()public{
        totalSupply= 500 * (10**6) * (10**decimals);
        balances[owner] = 500 * (10**6) * (10**decimals);
    }    
    function activeEnd()external onlyOwner{
        active=false;
    }
    function activeStart()external onlyOwner{
        active=true;
    }
    function Mint(uint _value)public onlyOwner returns(uint256){
        if(_value>0){
        balances[owner] = safeAdd(balances[owner],_value*(10**decimals));
        return totalSupply;
        }
    }
    function burn(uint _value)public onlyOwner returns(uint256){
        if(_value>0 && balances[msg.sender] >= _value){
            balances[owner] = safeSub(balances[owner],_value*(10**decimals));
            return totalSupply;
        }
    }
    function wihtdraw()public onlyOwner returns(bool success){
        if(address(this).balance > 0){
            msg.sender.transfer(address(this).balance);
            return true;
        }
    }
}