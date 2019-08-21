pragma solidity ^0.4.16;

    contract ERC20 {
     function totalSupply() constant returns (uint256 totalSupply);
     function balanceOf(address _owner) constant returns (uint256 balance);
     function transfer(address _to, uint256 _value) returns (bool success);
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
 
  // PayBits is ERC20 Token
  contract PayBits is ERC20 {
     string public constant symbol = "PYB";
     string public constant name = "PayBits";
     uint8 public constant decimals = 18;
     uint256 _totalSupply = 21000000 * 10**18;
     

     address public owner;
  
     mapping(address => uint256) balances;
  
     mapping(address => mapping (address => uint256)) allowed;
     
        // Total Supply of Token will be 21 Million only
     function PayBits() {
         owner = msg.sender;
         balances[owner] = 21000000 * 10**18;
     }
     
     modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
     
     // To Distribute AirDrops for Applicants of Round 1
     function AirDropPayBitsR1(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
             balances[owner] -= 400000000000000000000;
             balances[addresses[i]] += 400000000000000000000;
             Transfer(owner, addresses[i], 400000000000000000000);
         }
     }
      // To Distribute AirDrops for Applicants of Round 2
      function AirDropPayBitsR2(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
             balances[owner] -= 300000000000000000000;
             balances[addresses[i]] += 300000000000000000000;
             Transfer(owner, addresses[i], 300000000000000000000);
         }
     }
      // To Distribute AirDrops for Applicants of Round 3
     function AirDropPayBitsR3(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
             balances[owner] -= 200000000000000000000;
             balances[addresses[i]] += 200000000000000000000;
             Transfer(owner, addresses[i], 200000000000000000000);
         }
     }
     
     // To Distribute AirDrops of Remaining Token To Bounty (Press Release Post, Article submission, Blog submission, Social Sharing Etc)
     function AirDropPayBitsBounty(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
             balances[owner] -= 100000000000000000000;
             balances[addresses[i]] += 100000000000000000000;
             Transfer(owner, addresses[i], 100000000000000000000);
         }
     }
        // Total Supply of Coin will be 21 Million only 
     function totalSupply() constant returns (uint256 totalSupply) {
         totalSupply = _totalSupply;
     }
  
        // For Future Development 20% of token will be used
     function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
     }
 
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
     
     
     function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) returns (bool success) {
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
 
     function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
    }
}