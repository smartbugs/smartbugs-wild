contract Owned {

	address public owner;

	function Owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require (msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}
}

contract tokenRecipient { 
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); 
} 

contract IERC20Token {     

	function totalSupply() constant returns (uint256 totalSupply);
	function balanceOf(address _owner) constant returns (uint256 balance) {}  
	function transfer(address _to, uint256 _value) returns (bool success) {}
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
	function approve(address _spender, uint256 _value) returns (bool success) {}     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}       

	event Transfer(address indexed _from, address indexed _to, uint256 _value);     
	event Approval(address indexed _owner, address indexed _spender, uint256 _value); 
} 

contract EstatiumToken is IERC20Token, Owned {
  
	string public standard = "Estatium token v1.0";
	string public name = "Estatium";
	string public symbol = "EST";
	uint8 public decimals = 18;
	bool public tokenFrozen;
   
	uint256 supply = 0;
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowances;
    address public distributor;
      
	event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
	event TokenFrozen();
  
	function EstatiumToken() {
        supply += 84000000 * 10**18;
		balances[msg.sender] += 84000000 * 10**18;
		Mint(msg.sender, 84000000 * 10**18);
		Transfer(0x0, msg.sender, 84000000 * 10**18);
	}
  
	function totalSupply() constant returns (uint256 totalsupply) {
		return supply;
	}

	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) returns (bool success) {
		require(canSendtokens(msg.sender));
		require(balances[msg.sender] >= _value);
		require (balances[_to] + _value > balances[_to]);
		
        balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);

		return true;
	}     

	function approve(address _spender, uint256 _value) returns (bool success) {
		require(canSendtokens(msg.sender));
		allowances[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		approve(_spender, _value);
		spender.receiveApproval(msg.sender, _value, this, _extraData);
		return true;
	}
   
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		require(canSendtokens(msg.sender));  
		require (balances[_from] >= _value);
		require (balances[_to] + _value > balances[_to]);
		require (_value <= allowances[_from][msg.sender]);

		balances[_from] -= _value;
		balances[_to] += _value;
		allowances[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);

		return true;
	}
  
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowances[_owner][_spender];
	}

	function freezeTransfers() onlyOwner {
		tokenFrozen = !tokenFrozen;
		TokenFrozen();
	}

	function setDistributorAddress(address _newDistributorAddress) onlyOwner {
		distributor = _newDistributorAddress;
	}

    function burn(uint _value) {
        require (balances[msg.sender] >= _value);
        require(canSendtokens(msg.sender));

        balances[msg.sender] -= _value;
        supply -= _value;
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);
    }

    function canSendtokens(address _sender) internal constant returns (bool) {
        if (_sender == distributor || _sender == owner) {
            return true;
        }else {
            if (!tokenFrozen) {
                return true;
            }
        }
        return false;
    }
}