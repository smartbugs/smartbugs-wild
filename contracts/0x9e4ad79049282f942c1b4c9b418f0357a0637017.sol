pragma solidity ^ 0.4.17;

/*
Old contract: (2016-2017) 0x3F2D17ed39876c0864d321D8a533ba8080273EdE

1. Transfer Ether to contract for get tokens
The exchange rate is calculated at the time of receipt of payment and is:

_emissionPrice = this.balance / _totalSupply * 2

2. Transfer tokens back to the contract for withdraw ETH 
in proportion to your share of the reserve fund (contract balance), the tokens themselves are destroyed (burned).

_burnPrice = this.balance / _totalSupply

*/

// ----------------------------------------------------------------------------
// Safe maths from OpenZeppelin
// ----------------------------------------------------------------------------
library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns(uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
	function totalSupply() public constant returns(uint256 totalSupplyReturn);

	function balanceOf(address _owner) public constant returns(uint256 balance);

	function transfer(address _to, uint256 _value) public returns(bool success);

	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);

	function approve(address _spender, uint256 _value) public returns(bool success);

	function allowance(address _owner, address _spender) public constant returns(uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Noxon is ERC20Interface {
	using SafeMath for uint;

	string public constant symbol = "NOXON";
	string public constant name = "NOXON";
	uint8 public constant decimals = 0; //warning! dividing rounds down, the remainder of the division is the profit of the contract
	uint256 _totalSupply = 0;
	uint256 _burnPrice;
	uint256 _emissionPrice;
	uint256 initialized;
	
	bool public emissionlocked = false;
	// Owner of this contract
	address public owner;
	address public manager;

	// Balances for each account
	mapping(address => uint256) balances;

	// Owner of account approves the transfer of an amount to another account
	mapping(address => mapping(address => uint256)) allowed;

	// Functions with this modifier can only be executed by the owner
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	address newOwner;
	address newManager;
	// BK Ok - Only owner can assign new proposed owner
	function changeOwner(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	// BK Ok - Only new proposed owner can accept ownership 
	function acceptOwnership() public {
		if (msg.sender == newOwner) {
			owner = newOwner;
			newOwner = address(0);
		}
	}


	function changeManager(address _newManager) public onlyOwner {
		newManager = _newManager;
	}


	function acceptManagership() public {
		if (msg.sender == newManager) {
			manager = newManager;
            newManager = address(0);
		}
	}

	// Constructor
	
	function Noxon() public {
        require(_totalSupply == 0);
		owner = msg.sender;
		manager = owner;
        
	}
	function NoxonInit() public payable onlyOwner returns (bool) {
		require(_totalSupply == 0);
		require(initialized == 0);
		require(msg.value > 0);
		Transfer(0, msg.sender, 1);
		balances[owner] = 1; //owner got 1 token
		_totalSupply = balances[owner];
		_burnPrice = msg.value;
		_emissionPrice = _burnPrice.mul(2);
		initialized = block.timestamp;
		return true;
	}

	//The owner can turn off accepting new ether
	function lockEmission() public onlyOwner {
		emissionlocked = true;
	}

	function unlockEmission() public onlyOwner {
		emissionlocked = false;
	}

	function totalSupply() public constant returns(uint256) {
		return _totalSupply;
	}

	function burnPrice() public constant returns(uint256) {
		return _burnPrice;
	}

	function emissionPrice() public constant returns(uint256) {
		return _emissionPrice;
	}

	// What is the balance of a particular account?
	function balanceOf(address _owner) public constant returns(uint256 balance) {
		return balances[_owner];
	}

	// Transfer the balance from owner's account to another account
	function transfer(address _to, uint256 _amount) public returns(bool success) {

		// if you send TOKENS to the contract they will be burned and you will return part of Ether from smart contract
		if (_to == address(this)) {
			return burnTokens(_amount);
		} else {

			if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
				balances[msg.sender] = balances[msg.sender].sub(_amount);
				balances[_to] = balances[_to].add(_amount);
				Transfer(msg.sender, _to, _amount);
				return true;
			} else {
				return false;
			}

		}
	}

	function burnTokens(uint256 _amount) private returns(bool success) {

		_burnPrice = getBurnPrice();
		uint256 _burnPriceTmp = _burnPrice;

		if (balances[msg.sender] >= _amount && _amount > 0) {

			// subtracts the amount from seller's balance and suply
			balances[msg.sender] = balances[msg.sender].sub(_amount);
			_totalSupply = _totalSupply.sub(_amount);

			//do not allow sell last share (fear of dividing by zero)
			assert(_totalSupply >= 1);

			// sends ether to the seller
			msg.sender.transfer(_amount.mul(_burnPrice));

			//check new burn price
			_burnPrice = getBurnPrice();

			//only growth required 
			assert(_burnPrice >= _burnPriceTmp);

			//send event
			TokenBurned(msg.sender, _amount.mul(_burnPrice), _burnPrice, _amount);
			return true;
		} else {
			return false;
		}
	}

	event TokenBought(address indexed buyer, uint256 ethers, uint _emissionedPrice, uint amountOfTokens);
	event TokenBurned(address indexed buyer, uint256 ethers, uint _burnedPrice, uint amountOfTokens);

	function () public payable {
	    //buy tokens

		//save tmp for double check in the end of function
		//_burnPrice never changes when someone buy tokens
		uint256 _burnPriceTmp = _burnPrice;

		require(emissionlocked == false);
		require(_burnPrice > 0 && _emissionPrice > _burnPrice);
		require(msg.value > 0);

		// calculate the amount
		uint256 amount = msg.value / _emissionPrice;

		//check overflow
		require(balances[msg.sender] + amount > balances[msg.sender]);

		// adds the amount to buyer's balance
		balances[msg.sender] = balances[msg.sender].add(amount);
		_totalSupply = _totalSupply.add(amount);

        uint mg = msg.value / 2;
		//send 50% to manager
		manager.transfer(mg);
		TokenBought(msg.sender, msg.value, _emissionPrice, amount);

		//are prices unchanged?   
		_burnPrice = getBurnPrice();
		_emissionPrice = _burnPrice.mul(2);

		//"only growth"
		assert(_burnPrice >= _burnPriceTmp);
	}
    
	function getBurnPrice() public returns(uint) {
		return this.balance / _totalSupply;
	}

	event EtherReserved(uint etherReserved);
	//add Ether to reserve fund without issue new tokens (prices will growth)

	function addToReserve() public payable returns(bool) {
	    uint256 _burnPriceTmp = _burnPrice;
		if (msg.value > 0) {
			_burnPrice = getBurnPrice();
			_emissionPrice = _burnPrice.mul(2);
			EtherReserved(msg.value);
			
			//"only growth" check 
		    assert(_burnPrice >= _burnPriceTmp);
			return true;
		} else {
			return false;
		}
	}

	// Send _value amount of tokens from address _from to address _to
	// The transferFrom method is used for a withdraw workflow, allowing contracts to send
	// tokens on your behalf, for example to "deposit" to a contract address and/or to charge
	// fees in sub-currencies; the command should fail unless the _from account has
	// deliberately authorized the sender of the message via some mechanism; we propose
	// these standardized APIs for approval:
	function transferFrom(
		address _from,
		address _to,
		uint256 _amount
	) public returns(bool success) {
		if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to] && _to != address(this) //not allow burn tockens from exhanges
		) {
			balances[_from] = balances[_from].sub(_amount);
			allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
			balances[_to] = balances[_to].add(_amount);
			Transfer(_from, _to, _amount);
			return true;
		} else {
			return false;
		}
	}

	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	// If this function is called again it overwrites the current allowance with _value.
	function approve(address _spender, uint256 _amount) public returns(bool success) {
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
		return allowed[_owner][_spender];
	}

	function transferAnyERC20Token(address tokenAddress, uint amount)
	public
	onlyOwner returns(bool success) {
		return ERC20Interface(tokenAddress).transfer(owner, amount);
	}

	function burnAll() external returns(bool) {
		return burnTokens(balances[msg.sender]);
	}
    
    
}

contract TestProcess {
    Noxon main;
    
    function TestProcess() payable {
        main = new Noxon();
    }
   
    function () payable {
        
    }
     
    function init() returns (uint) {
       
        if (!main.NoxonInit.value(12)()) throw;    //init and set burn price as 12 and emission price to 24 
        if (!main.call.value(24)()) revert(); //buy 1 token
 
        assert(main.balanceOf(address(this)) == 2); 
        
        if (main.call.value(23)()) revert(); //send small amount (must be twhrowed)
        assert(main.balanceOf(address(this)) == 2); 
    }
    
    
    
    function test1() returns (uint) {
        if (!main.call.value(26)()) revert(); //check floor round (26/24 must issue 1 token)
        assert(main.balanceOf(address(this)) == 3); 
        assert(main.emissionPrice() == 24); //24.6 but round floor
        return main.balance;
    }
    
    function test2() returns (uint){
        if (!main.call.value(40)()) revert(); //check floor round (40/24 must issue 1 token)
        assert(main.balanceOf(address(this)) == 4); 
        //assert(main.emissionPrice() == 28);
        //return main.burnPrice();
    } 
    
    function test3() {
        if (!main.transfer(address(main),2)) revert();
        assert(main.burnPrice() == 14);
    } 
    
}