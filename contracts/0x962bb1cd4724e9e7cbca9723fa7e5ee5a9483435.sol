/**
   In God We Trust
   */

/**
   God Bless the bearer of this token.
   In the name of Jesus. Amen
   */
   
/**
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
   */

/**
   Our Mission
   
   1 Timothy 6:12 (NIV)
  “Fight the good fight of the faith. 
   Take hold of the eternal life to which you were called 
   when you made your good confession in the presence of many witnesses.”
   
   Matthew 24:14 (NKJV)
  “And this gospel of the kingdom will be preached in all the world as a witness to all the nations,
   and then the end will come.”
   */
   
 /**
   Verse for Good Health
   
   3 John 1:2
   "Dear friend, I pray that you may enjoy good health and that all may go well with you, 
   even as your soul is getting along well."
   */     

/**
   Verse about Family
   
   Genesis 28:14
   "Your offspring shall be like the dust of the earth, 
   and you shall spread abroad to the west and to the east and to the north and to the south, 
   and in you and your offspring shall all the families of the earth be blessed."
   */  
   
/**
   Verse About Friends
   
   Proverbs 18:24
   "One who has unreliable friends soon comes to ruin, but there is a friend who sticks closer than a brother."
   */


/**
   God will Protect you
   
   Isaiah 43:2
   "When you pass through the waters, I will be with you; and when you pass through the rivers,
   they will not sweep over you. When you walk through the fire, you will not be burned; 
   the flames will not set you ablaze."
   */  
   
/**
   Trust in our GOD
   
   Proverbs 3:5-6
 
   "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him,
   and he will make your paths straight."
   */  

   
pragma solidity ^0.4.13;

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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


function Ownable() {
    owner = msg.sender;
  }


modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
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

contract BasicToken is ERC20Basic {
  using SaferMath for uint256;
  mapping(address => uint256) balances;
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue) returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success) {
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

contract FaithCoin is StandardToken, Ownable {

  string public constant name = "Faith Coin";
  string public constant symbol = "FAITH";
  uint8 public constant decimals = 8;

  uint256 public constant INITIAL_SUPPLY = 25000000 * (10 ** uint256(decimals));

  address NULL_ADDRESS = address(0);

  uint public nonce = 0;

event NonceTick(uint nonce);
  function incNonce() {
    nonce += 1;
    if(nonce > 100) {
        nonce = 0;
    }
    NonceTick(nonce);
  }


  function FaithCoin() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

/**
   Verse for Wealth
   
   Deuteronomy 28:8

  "The LORD will command the blessing upon you in your barns and in all that you put your hand to, 
   and He will bless you in the land which the LORD your God gives you."
   */  
   
/**
   God Bless you all.
   
   Philippians 4:19

   And my God will meet all your needs according to the riches of his glory in Christ Jesus."
   */