pragma solidity ^0.4.18;

library SafeMath {
	function smul(uint256 a, uint256 b) internal pure returns (uint256) {		
		if(a == 0) {
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b);
		return c;
	}
	
	function sdiv(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a / b;
		return c;
	}
	
	function ssub(uint256 a, uint256 b) internal pure returns (uint256) {
		require( b <= a);
		return a-b;
	}

	function sadd(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);
		return c;
	}
}

/*
 * Contract that is working with ERC223 tokens
 */
 contract ContractReceiver {

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}

/*
 * PetroleumToken is an ERC20 token with ERC223 Extensions
 */
contract PetroleumToken {
    
    using SafeMath for uint256;

    string public name 			= "Petroleum";
    string public symbol 		= "OIL";
    uint8 public decimals 		= 18;
    uint256 public totalSupply  = 1000000 * 10**18;
	bool public tokenCreated 	= false;
	bool public mintingFinished = false;

    address public owner;  
    mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

   function PetroleumToken() public {       
        require(tokenCreated == false);
        tokenCreated = true;
        owner = msg.sender;
        balances[owner] = totalSupply;
        require(balances[owner] > 0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

	modifier canMint() {
		require(!mintingFinished);
		_;
	}    
   
    function name() constant public returns (string _name) {
        return name;
    }
    
    function symbol() constant public returns (string _symbol) {
        return symbol;
    }
    
    function decimals() constant public returns (uint8 _decimals) {
        return decimals;
    }
   
    function totalSupply() constant public returns (uint256 _totalSupply) {
        return totalSupply;
    }   

    function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
       
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transfer(address _to, uint _value) public returns (bool success) {       
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    function isContract(address _addr) constant private returns (bool) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) {
            revert();
        }
        balances[msg.sender] = balanceOf(msg.sender).ssub(_value);
        balances[_to] = balanceOf(_to).sadd(_value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

   function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) {
            revert();
        }
        balances[msg.sender] = balanceOf(msg.sender).ssub(_value);
        balances[_to] = balanceOf(_to).sadd(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
   
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balanceOf(_to).ssub(_value);
        balances[_from] = balanceOf(_from).sadd(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].ssub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        
        address burner = msg.sender;
        balances[burner] = balances[burner].ssub(_value);
        totalSupply = totalSupply.ssub(_value);
        Burn(burner, _value);
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender].ssub(_value);
        totalSupply.ssub(_value);
        Burn(_from, _value);
        return true;
    }

	function mint(address _to, uint256 _value) onlyOwner canMint public returns (bool) {
		totalSupply = totalSupply.sadd(_value);
		balances[_to] = balances[_to].sadd(_value);
		Mint(_to, _value);
		Transfer(address(0), _to, _value);
		return true;
	}

	function finishMinting() onlyOwner canMint public returns (bool) {
		mintingFinished = true;
		MintFinished();
		return true;
	}
}