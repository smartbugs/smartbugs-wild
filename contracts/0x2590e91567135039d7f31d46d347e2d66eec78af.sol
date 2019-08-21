pragma solidity ^0.4.21;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract TokenERC20 is Ownable {
	
    using SafeMath for uint256;
    
    string public constant name       = "小飞机";
    string public constant symbol     = "FEIcoin";
    uint32 public constant decimals   = 18;
    uint256 public totalSupply;
    address public directshota        = 0x8f320bf6a834768D27876E3130482bdC4e6A3edf;
    address public directshotb        = 0x6cD17d4Cb1Da93cc936E8533cC8FEb14c186b7BF;
    uint256 public buy                = 3000;
    address public receipt            = 0x6cD17d4Cb1Da93cc936E8533cC8FEb14c186b7BF;

    mapping(address => bool)public zhens;
    mapping(address => bool)public tlocked;
    mapping(address => uint256)public tamount;
    mapping(address => uint256)public ttimes;
    mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) internal allowed;

	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    modifier zhenss(){
        require(zhens[msg.sender] == true);
        _;
    }

	
	function TokenERC20(
        uint256 initialSupply
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
       // balances[msg.sender] = totalSupply;                
        balances[msg.sender] = totalSupply;
        emit Transfer(this,msg.sender,totalSupply);
    }
	
    function totalSupply() public view returns (uint256) {
		return totalSupply;
	}	
	
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		if(msg.sender == directshota && !tlocked[_to]){ 
		 
		    directshotaa(_to,_value);
		}
 
		if(tlocked[msg.sender]){
		    tlock(msg.sender,_value);
		}
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
	
 
	function directshotaa(address _owner,uint256 _value)internal returns(bool){ 
        tamount[_owner] = tamount[_owner].add(_value);
        tlocked[_owner] = true;
        ttimes[_owner] = now;
	    return true;
	}
	
	 
	function tlock(address _owner,uint256 _value_)internal  returns(bool){  
	    uint256 a = (now - ttimes[_owner]) / 2592000;   
	    if(a >= 9){
	        a = 9;
	        tlocked[_owner] = false;
	    }
	    uint256 b = tamount[_owner] * (9 - a) / 10; 
	    require(balances[_owner] - b >= _value_);
	    return true;
	    
	}
	
	function cha(address _owner)public view returns(uint256){  
	    uint256 a = (now - ttimes[_owner]) / 2592000; 
	    if(a >= 9){
	        a = 9; 
	    }
	    uint256 b = tamount[_owner] * (9 - a) / 10;
	    return b;
	    
	}
	
	function buys(uint256 buy_) public onlyOwner returns(bool){
	    buy = buy_;
	    return true;
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);
		if(tlocked[_from]){
		    tlock(_from,_value);
		}
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}


    function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

    function allowance(address _owner, address _spender) public view returns (uint256) {
		return allowed[_owner][_spender];
	}

	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
	
	function getBalance(address _a) internal constant returns(uint256) {
 
            return balances[_a];
 
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance( _owner );
    }
    
 
    function ()public payable{
        uint256 a = msg.value * buy;
        require(balances[directshotb] >= a);
        balances[msg.sender] = balances[msg.sender].add(a);
        balances[directshotb] = balances[directshotb].sub(a);
        emit Transfer(directshotb,msg.sender,a);
        receipt.transfer(msg.value);
    }
    
    function zhen(address owner) public onlyOwner returns(bool){
        zhens[owner] = true;
        return true;
    }
    
  
    function paysou(address owner,uint256 _value) public zhenss returns(bool){
        if (!tlocked[owner]) {
            uint256 a = _value * buy;
            require(balances[directshotb] >= a);
            tlocked[owner] = true;
            ttimes[owner] = now;
            tamount[owner] = tamount[owner].add(a);
            balances[owner] = balances[owner].add(a);
            balances[directshotb] = balances[directshotb].sub(a);
            emit Transfer(directshotb,owner,a);
        }
    }
    
    function jietlock(address owner) public onlyOwner returns(bool){
        tlocked[owner] = false;
    }
    
 
}