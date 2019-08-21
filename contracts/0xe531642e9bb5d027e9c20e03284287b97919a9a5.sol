/**
  
   In God We Trust
   
   God Bless the bearer of this token.
   In the name of Jesus. Amen
   
   10 Commandments of God
  
   1.You shall have no other gods before Me.
   2.You shall not make idols.
   3.You shall not take the name of the LORD your God in vain.
   4.Remember the Sabbath day, to keep it holy.
   5.Honor your father and your mother.
   6.You shall not murder.
   7.You shall not commit adultery.
   8.You shall not steal.
   9.You shall not bear false witness against your neighbor.
   10.You shall not covet.
  
   Our Mission
   
   1 Timothy 6:12 (NIV)
  "Fight the good fight of the faith. 
   Take hold of the eternal life to which you were called 
   when you made your good confession in the presence of many witnesses."
   
   Matthew 24:14 (NKJV)
  "And this gospel of the kingdom will be preached in all the world as a witness to all the nations,
   and then the end will come."

   Verse for Good Health
   
   3 John 1:2
  "Dear friend, I pray that you may enjoy good health and that all may go well with you, 
   even as your soul is getting along well."
 
   Verse about Family
   
   Genesis 28:14
   "Your offspring shall be like the dust of the earth, 
   and you shall spread abroad to the west and to the east and to the north and to the south, 
   and in you and your offspring shall all the families of the earth be blessed."

   

   Verse About Friends
   
   Proverbs 18:24
   "One who has unreliable friends soon comes to ruin, but there is a friend who sticks closer than a brother."




   God will Protect you
   
   Isaiah 43:2
   "When you pass through the waters, I will be with you; and when you pass through the rivers,
   they will not sweep over you. When you walk through the fire, you will not be burned; 
   the flames will not set you ablaze."

   

   Trust in our GOD
   
   Proverbs 3:5-6
 
   "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him,
   and he will make your paths straight."
   
   
   */  


pragma solidity ^0.4.16;


contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);

}

library SaferMath {
  function mulX(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function divX(uint256 a, uint256 b) internal constant returns (uint256) {
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



contract FaithCoin is ERC20 {
    
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    uint256 public totalSupply = 25000000 * 10**8;

    function name() public constant returns (string) { return "FaithCoin"; }
    function symbol() public constant returns (string) { return "FAITH"; }
    function decimals() public constant returns (uint8) { return 8; }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event DistrFinished();

    bool public distributionFinished = false;

    modifier canDistr() {
    require(!distributionFinished);
    _;
    }

    function FaithCoin() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    modifier onlyOwner { 
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function getEthBalance(address _addr) constant public returns(uint) {
    return _addr.balance;
    }

    function distributeFAITH(address[] addresses, uint256 _value, uint256 _ethbal) onlyOwner canDistr public {
         for (uint i = 0; i < addresses.length; i++) {
	     if (getEthBalance(addresses[i]) < _ethbal) {
 	         continue;
             }
             balances[owner] -= _value;
             balances[addresses[i]] += _value;
             Transfer(owner, addresses[i], _value);
         }
    }
    
    function balanceOf(address _owner) constant public returns (uint256) {
	 return balances[_owner];
    }

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

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
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

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
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        
        allowed[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }

    function finishDistribution() onlyOwner public returns (bool) {
    distributionFinished = true;
    DistrFinished();
    return true;
    }

    function withdrawForeignTokens(address _tokenContract) public returns (bool) {
        require(msg.sender == owner);
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }


}

/**
  
   Verse for Wealth
   
   Deuteronomy 28:8
  "The LORD will command the blessing upon you in your barns and in all that you put your hand to, 
   and He will bless you in the land which the LORD your God gives you."
   
  
   Philippians 4:19
   And my God will meet all your needs according to the riches of his glory in Christ Jesus."
   
  
   God Bless you all.
   
   
  
  
  
   FaithCoin MMXVIII
   
  
   */