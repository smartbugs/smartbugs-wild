pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
}

contract Token {
    
    using SafeMath for uint256;
     
    string public symbol = "LPN";
    string public name = "Litepool";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 35000000;
    uint256 ratePerWei = 1300;
    address owner = 0x5367B63897eDE5076cD7A970a0fd85750e27F745;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Debug(string message, uint number);
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
 
    function Token() public {
        balances[owner] = _totalSupply * 10 ** 18;
    }
   
   function changeBuyPrice(uint price) public
   {
       if (msg.sender == owner){
        ratePerWei = price;
       }
   }
    
    function totalSupply() public constant returns (uint256 supply) {        
        return _totalSupply;
    }
 
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) internal returns (bool success) {
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
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool success) {
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
 
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
     // fallback function can be used to buy tokens
      function () public payable {
       // require(msg.sender != owner);   //owner should not be buying any tokens
        buy(msg.sender);
    }
    function buy(address beneficiary) payable public returns (uint tokenAmount) {
        
        uint weiAmount = msg.value;
        tokenAmount = weiAmount.mul(ratePerWei);
        require(balances[owner] >= tokenAmount);               // checks if it has enough to sell
        balances[beneficiary] = balances[beneficiary].add(tokenAmount);  // adds the amount to buyer's balance
        balances[owner] = balances[owner].sub(tokenAmount);     // subtracts amount from seller's balance
        owner.transfer(msg.value);
        Transfer(owner, msg.sender, tokenAmount);               // execute an event reflecting the change
        return tokenAmount;                                    // ends function and returns
    }
}