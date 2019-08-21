pragma solidity ^0.4.19;

//*************** SafeMath ***************

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
  }

  function div(uint256 a, uint256 b) internal pure  returns (uint256) {
      assert(b > 0);
      uint256 c = a / b;
      return c;
  }

  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
      assert(b <= a);
      return a - b;
  }

  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
  }
}

//*************** Ownable

contract Ownable {
  address public owner;

  function Ownable() public {
      owner = msg.sender;
  }

  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function transferOwnership(address newOwner)public onlyOwner {
      if (newOwner != address(0)) {
        owner = newOwner;
      }
  }

}

//************* ERC20

contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who)public constant returns (uint256);
  function transfer(address to, uint256 value)public returns (bool);
  function transferFrom(address from, address to, uint256 value)public returns (bool);
  function allowance(address owner, address spender)public constant returns (uint256);
  function approve(address spender, uint256 value)public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event PreICOTokenPushed(address indexed buyer, uint256 amount);
  event TokenPurchase(address indexed purchaser, uint256 value,uint256 amount);  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//*************HeroChain Token

contract HeroChainToken is ERC20,Ownable {
	using SafeMath for uint256;

	// Token Info.
	string public name;
	string public symbol;

	uint8 public constant decimals = 18;

	address[] private walletArr;
	uint walletIdx = 0;

	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) allowed;

	event TokenPurchase(address indexed purchaser, uint256 value,uint256 amount);
	event FundTransfer(address fundWallet, uint256 amount);

	function HeroChainToken( 
		uint256 _totalSupply, 
		string _name, 
		string _symbol,  
		address _wallet1

	) public {  		

	require(_wallet1 != 0x0);
		
	balanceOf[msg.sender] = _totalSupply;
	totalSupply = _totalSupply;
	name = _name;
	symbol = _symbol;
	
	walletArr.push(_wallet1);
	
	}

	function balanceOf(address _who)public constant returns (uint256 balance) {
	    return balanceOf[_who];
	}

	function _transferFrom(address _from, address _to, uint256 _value)  internal {
	    require(_to != 0x0);
	    require(balanceOf[_from] >= _value);
	    require(balanceOf[_to] + _value >= balanceOf[_to]);

	    balanceOf[_from] = balanceOf[_from].sub(_value);
	    balanceOf[_to] = balanceOf[_to].add(_value);

	    Transfer(_from, _to, _value);
	}

	function transfer(address _to, uint256 _value) public returns (bool){	    
	    _transferFrom(msg.sender,_to,_value);
	    return true;
	}

	function push(address _buyer, uint256 _amount) public onlyOwner {
	    uint256 val=_amount*(10**18);
	    _transferFrom(msg.sender,_buyer,val);
	    PreICOTokenPushed(_buyer, val);
	}

	function ()public payable {
	    _tokenPurchase( msg.value);
	}

	function _tokenPurchase( uint256 _value) internal {
	   
	    require(_value >= 0.1 ether);

	    address wallet = walletArr[walletIdx];
	    walletIdx = (walletIdx+1) % walletArr.length;

	    wallet.transfer(msg.value);
	    FundTransfer(wallet, msg.value);
	}

	function supply()  internal constant  returns (uint256) {
	    return balanceOf[owner];
	}

	function getCurrentTimestamp() internal view returns (uint256){
	    return now;
	}

	function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
	    return allowed[_owner][_spender];
	}

	function approve(address _spender, uint256 _value)public returns (bool) {
	    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

	    allowed[msg.sender][_spender] = _value;
	    Approval(msg.sender, _spender, _value);
	    return true;
	}
	
	function transferFrom(address _from, address _to, uint256 _value)public returns (bool) {
	    var _allowance = allowed[_from][msg.sender];

	    require (_value <= _allowance);
		
	     _transferFrom(_from,_to,_value);

	    allowed[_from][msg.sender] = _allowance.sub(_value);
	    Transfer(_from, _to, _value);
	    return true;
	  }
	
}