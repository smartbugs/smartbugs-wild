pragma solidity ^0.4.18;

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

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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

  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public{
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

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
contract BurnableToken is StandardToken {

  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }

  event Burn(address indexed burner, uint indexed value);

}


contract WAEP is MintableToken, BurnableToken {
    
    string public constant name = "WeAre Pre-ICO Token";
    
    string public constant symbol = "WAEP";
    
    uint32 public constant decimals = 18;
    
    function WAEP() public{
		owner = msg.sender;
    }
    
}

contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    WAEP public token ;
    uint start; //15dec
    uint end; //15feb
    uint softcapUSD;
    uint hardcapUSD;
    uint public risedUSD;
    uint hardcapTokens;
    uint oneTokenInWei;
    uint sale1 = 1000000*10**18;
    uint sale2 = 2000000*10**18;
    uint sale3 = 3000000*10**18;

    mapping (address => bool) refunded;
    mapping (address => uint256) saleBalances ;  
    function Crowdsale() public{
        owner = msg.sender;
        start = 1513339200; //15dec
        end = 1518696000; //15feb
        softcapUSD = 350000*10**18;
        hardcapUSD = 3500000*10**18;
        hardcapTokens = 1000000000*10**18;
		oneTokenInWei = 1532355690402860; // init price $652.59 usd per eth
		token = new WAEP();
    }
    
    function setEthPrice(uint _new) onlyOwner {
        oneTokenInWei = _new;
    }
    
    function buyByBot(uint _usd, uint _tokens, address _to) onlyOwner {
        require( risedUSD + _usd < hardcapUSD );
        risedUSD += _usd*10**18;
        token.mint(_to, _tokens*10**18);
    }
    
    function() external payable {
        require(now > start && now < end);
        require( risedUSD + msg.value.mul(10**18).div(oneTokenInWei) < hardcapUSD );
        uint discountPrice ;
        
        if ( risedUSD < sale1 ) {                
            discountPrice = oneTokenInWei.div(100).mul(60);
        } else if ( risedUSD < sale2 ) {                
            discountPrice = oneTokenInWei.div(100).mul(70);
        } else if ( risedUSD < sale3 ) {                
            discountPrice = oneTokenInWei.div(100).mul(80);
        } else {
           discountPrice = oneTokenInWei ;
        }

        uint256 tokenAdd = msg.value.mul(10**18).div(discountPrice);
        require(token.totalSupply() + tokenAdd < hardcapTokens);
        risedUSD += msg.value.mul(10**18).div(oneTokenInWei);
        saleBalances[msg.sender] = saleBalances[msg.sender].add(msg.value);
        token.mint(msg.sender, tokenAdd);
    }
    
    function getEth() public onlyOwner {
        owner.transfer(this.balance);
    }
    
    function mint(address _to, uint _value) public onlyOwner {
        require(_value > 0);
        token.mint(_to, _value*10**18);
    }

    function refund() public {
        require (now > end  && risedUSD < softcapUSD );
        require (!refunded[msg.sender]);
        require (saleBalances[msg.sender] != 0) ;
        uint refund = saleBalances[msg.sender];
        require(msg.sender.send(refund));
        refunded[msg.sender] = true;
    }
}