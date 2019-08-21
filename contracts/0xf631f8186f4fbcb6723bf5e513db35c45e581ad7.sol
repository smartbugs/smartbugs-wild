pragma solidity ^0.4.25;

contract ERC20Interface {

    string public constant name = "CWC-ER";
    string public constant symbol = "CWC-ER";
    uint8 public constant decimals = 18;

    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
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


contract CWCToken is ERC20Interface, SafeMath {

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;


  mapping (address => uint256) public balanceOf;

  mapping (address => mapping (address => uint256)) public allowanceOf;

   constructor() public {
      name = "CWC-ER";
      symbol = "CWC-ER";
      decimals = 18;
      totalSupply = 100000000 * 10 ** uint256(decimals);
      balanceOf[msg.sender] = totalSupply;
   }

    function _transfer(address _from, address _to, uint _value) internal {
       require(_to != 0x0);
       require(balanceOf[_from] >= _value);
       require(balanceOf[_to] + _value > balanceOf[_to]);
       uint previousBalances = balanceOf[_from] + balanceOf[_to];
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
      emit Transfer(_from, _to, _value);
       assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
       _transfer(msg.sender, _to, _value);
       return true;
   }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       require(allowanceOf[_from][msg.sender] >= _value);
       allowanceOf[_from][msg.sender] -= _value;
       _transfer(_from, _to, _value);
       return true;
   }

    function approve(address _spender, uint256 _value) public returns (bool success) {
       allowanceOf[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
       return true;
   }

   function allowance(address _owner, address _spender) view public returns (uint remaining){
     return allowanceOf[_owner][_spender];
   }

  function totalSupply() public constant returns (uint totalsupply){
      return totalSupply;
  }

  function balanceOf(address tokenOwner) public constant returns(uint balance){
      return balanceOf[tokenOwner];
  }

}