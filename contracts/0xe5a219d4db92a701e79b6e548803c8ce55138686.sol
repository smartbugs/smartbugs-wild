pragma solidity ^0.4.16;
//https://github.com/genkifs/staticoin

contract owned  {
  address owner;
  function owned() {
    owner = msg.sender;
  }
  function changeOwner(address newOwner) onlyOwner {
    owner = newOwner;
  }
  modifier onlyOwner() {
    if (msg.sender==owner) 
    _;
  }
}

contract mortal is owned() {
  function kill() onlyOwner {
    if (msg.sender == owner) selfdestruct(owner);
  }
}

library ERC20Lib {
//Inspired by https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736
  struct TokenStorage {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 totalSupply;
  }
  
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	modifier onlyPayloadSize(uint numwords) {
		/**
		* @dev  Checks for short addresses  
		* @param numwords number of parameters passed 
		*/
        assert(msg.data.length >= numwords * 32 + 4);
        _;
	}
  
	modifier validAddress(address _address) { 
		/**
		* @dev  validates an address.  
		* @param _address checks that it isn't null or this contract address
		*/		
        require(_address != 0x0); 
        require(_address != address(msg.sender)); 
        _; 
    } 
	
	modifier IsWallet(address _address) {
		/**
		* @dev Transfer tokens from msg.sender to another address.  
		* Cannot Allows execution if the transfer to address code size is 0
		* @param _address address to check that its not a contract
		*/		
		uint codeLength;
		assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_address)
        }
		assert(codeLength==0);		
        _; 
    } 

   function safeMul(uint a, uint b) returns (uint) { 
     uint c = a * b; 
     assert(a == 0 || c / a == b); 
     return c; 
   } 
 
   function safeSub(uint a, uint b) returns (uint) { 
     assert(b <= a); 
     return a - b; 
   }  
 
   function safeAdd(uint a, uint b) returns (uint) { 
     uint c = a + b; 
     assert(c>=a && c>=b); 
     return c; 
   } 
	
	function init(TokenStorage storage self, uint _initial_supply) {
		self.totalSupply = _initial_supply;
		self.balances[msg.sender] = _initial_supply;
	}
  
	function transfer(TokenStorage storage self, address _to, uint256 _value) 
		onlyPayloadSize(3)
		IsWallet(_to)		
		returns (bool success) {				
		/**
		* @dev Transfer tokens from msg.sender to another address.  
		* Cannot be used to send tokens to a contract, this means contracts cannot mint coins to themselves
		* Contracts have to use the approve and transfer method
		* this is based on https://github.com/Dexaran/ERC223-token-standard
		* @param _to address The address where the coin is to be transfered
		* @param _value uint256 the amount of tokens to be transferred
		*/
       if (self.balances[msg.sender] >= _value && self.balances[_to] + _value > self.balances[_to]) {
            self.balances[msg.sender] = safeSub(self.balances[msg.sender], _value);
            self.balances[_to] = safeAdd(self.balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
  
	function transferFrom(TokenStorage storage self, address _from, address _to, uint256 _value) 
		onlyPayloadSize(4) 
		validAddress(_from)
		validAddress(_to)
		returns (bool success) {
		/**
		* @dev Transfer tokens from one address to another.  Requires allowance to be set.
		* @param _from address The address which you want to send tokens from
		* @param _to address The address which you want to transfer to
		* @param _value uint256 the amount of tokens to be transferred
		*/
        if (self.balances[_from] >= _value && self.allowed[_from][msg.sender] >= _value && self.balances[_to] + _value > self.balances[_to]) {
			var _allowance = self.allowed[_from][msg.sender];
            self.balances[_to] = safeAdd(self.balances[_to], _value);
            self.balances[_from] = safeSub(self.balances[_from], _value);
            self.allowed[_from][msg.sender] = safeSub(_allowance, _value);
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
     
    function balanceOf(TokenStorage storage self, address _owner) constant 
		onlyPayloadSize(2) 
		validAddress(_owner)
		returns (uint256 balance) {
		/**
		* @dev returns the amount given to an account
		* @param _owner The address to be queried
		* @return Balance of _owner.
		*/
        return self.balances[_owner];
    }
	 
    function approve(TokenStorage storage self, address _spender, uint256 _value) 
		onlyPayloadSize(3) 
		validAddress(_spender)	
		returns (bool success) {
	/**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
		//require user to set to zero before resetting to nonzero
		if ((_value != 0) && (self.allowed[msg.sender][_spender] != 0)) { 
           return false; 
        } else {
			self.allowed[msg.sender][_spender] = _value;
			Approval(msg.sender, _spender, _value);
			return true;
		}
    }
		
	function allowance(TokenStorage storage self, address _owner, address _spender) constant 
		onlyPayloadSize(3) 
		validAddress(_owner)	
		validAddress(_spender)	
		returns (uint256 remaining) {
			/**
			* @dev allows queries of how much a given address is allowed to spend on behalf of another account
			* @param _owner address The address which owns the funds.
			* @param _spender address The address which will spend the funds.
			* @return remaining uint256 specifying the amount of tokens still available for the spender.
			*/
        return self.allowed[_owner][_spender];
    }
	
	function increaseApproval(TokenStorage storage self, address _spender, uint256 _addedValue)  
		onlyPayloadSize(3) 
		validAddress(_spender)	
		returns (bool success) { 
		/**
		* @dev Allows to increment allowed value
		* better to use this function to avoid 2 calls
		* @param _spender address The address which will spend the funds.
		* @param _addedValue amount to increase alowance by.
		* @return True if allowance increased
		*/
        uint256 oldValue = self.allowed[msg.sender][_spender]; 
        self.allowed[msg.sender][_spender] = safeAdd(oldValue, _addedValue); 
        return true; 
    } 
	
	function decreaseApproval(TokenStorage storage self,address _spender, uint256 _subtractedValue)  
		onlyPayloadSize(3) 
		validAddress(_spender)	
		returns (bool success) { 
		/**
		* @dev Allows to decrement allowed value
		* better to use this function to avoid 2 calls
		* @param _spender address The address which will spend the funds.
		* @param _subtractedValue amount to decrease allowance by.
		* @return True if allowance decreased
		*/
		uint256 oldValue = self.allowed[msg.sender][_spender]; 
		if (_subtractedValue > oldValue) { 
			self.allowed[msg.sender][_spender] = 0; 
		} else { 
			self.allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue); 
		} 
		return true; 
	} 

    /* Approves and then calls the receiving contract with any additional paramteres*/
    function approveAndCall(TokenStorage storage self, address _spender, uint256 _value, bytes _extraData)
		onlyPayloadSize(4) 
		validAddress(_spender)   
		returns (bool success) {
	//require user to set to zero before resetting to nonzero
			/**
			* @dev Approves and then calls the receiving contract with any additional paramteres
			* @param _owner address The address which owns the funds.
			* @param _spender address The address which will spend the funds.
			* @param _value address The address which will spend the funds.
			* @param _extraData is the additional paramters passed
			* @return True if successful.
			*/
		if ((_value != 0) && (self.allowed[msg.sender][_spender] != 0)) { 
				return false; 
			} else {
			self.allowed[msg.sender][_spender] = _value;
			Approval(msg.sender, _spender, _value);
			//call the receiveApproval function on the contract you want to be notified. 
			//This crafts the function signature manually so one doesn't have to include a contract in here just for this.
			//it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
			if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
			return true;
		}
    }	
	
	function mintCoin(TokenStorage storage self, address target, uint256 mintedAmount, address owner) 
		internal
		returns (bool success) {
			/**
			* @dev Approves and then calls the receiving contract with any additional paramteres
			* @param target address the address which will receive the funds.
			* @param mintedAmount the amount of funds to be sent.
			* @param owner the contract responsable for controling the amount of funds.
			* @return True if successful.
			*/
        self.balances[target] = safeAdd(self.balances[target], mintedAmount);//balances[target] += mintedAmount;
        self.totalSupply = safeAdd(self.totalSupply, mintedAmount);//totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount); // Deliver coin to the mint
        Transfer(owner, target, mintedAmount); // mint delivers to address
		return true;
    }

    function meltCoin(TokenStorage storage self, address target, uint256 meltedAmount, address owner) 
		internal
		returns (bool success) {
			/**
			* @dev Approves and then calls the receiving contract with any additional paramteres
			* @param target address the address which will return the funds.
			* @param meltedAmount the amount of funds to be returned.
			* @param owner the contract responsable for controling the amount of funds.
			* @return True if successful.
			*/
        if(self.balances[target]<meltedAmount){
            return false;
        }
		self.balances[target] = safeSub(self.balances[target], meltedAmount); //balances[target] -= meltedAmount;
		self.totalSupply = safeSub(self.totalSupply, meltedAmount); //totalSupply -= meltedAmount;
		Transfer(target, owner, meltedAmount); // address delivers to minter
		Transfer(owner, 0, meltedAmount); // minter delivers coin to the burn address
		return true;
    }
}

/** @title StandardToken. */
contract StandardToken is owned{
    using ERC20Lib for ERC20Lib.TokenStorage;
    ERC20Lib.TokenStorage public token;

	string public name;                   //Long token name
    uint8 public decimals=18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.
    uint public INITIAL_SUPPLY = 0;		// mintable coin has zero inital supply (and can fall back to zero)

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);   
   
    function StandardToken() {
		token.init(INITIAL_SUPPLY);
    }

    function totalSupply() constant returns (uint) {
		return token.totalSupply;
    }

    function balanceOf(address who) constant returns (uint) {
		return token.balanceOf(who);
    }

    function allowance(address owner, address _spender) constant returns (uint) {
		return token.allowance(owner, _spender);
    }

	function transfer(address to, uint value) returns (bool ok) {
		return token.transfer(to, value);
	}

	function transferFrom(address _from, address _to, uint _value) returns (bool ok) {
		return token.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint value) returns (bool ok) {
		return token.approve(_spender, value);
	}
   
	function increaseApproval(address _spender, uint256 _addedValue) returns (bool ok) {  
		return token.increaseApproval(_spender, _addedValue);
	}    
 
	function decreaseApproval(address _spender, uint256 _subtractedValue) returns (bool ok) {  
		return token.decreaseApproval(_spender, _subtractedValue);
	}

	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool ok){
		return token.approveAndCall(_spender,_value,_extraData);
    }
	
	function mintCoin(address target, uint256 mintedAmount) onlyOwner returns (bool ok) {
		return token.mintCoin(target,mintedAmount,owner);
    }

    function meltCoin(address target, uint256 meltedAmount) onlyOwner returns (bool ok) {
		return token.meltCoin(target,meltedAmount,owner);
    }
}

/** @title Coin. */
contract Coin is StandardToken, mortal{
    I_minter public mint;				  //Minter interface  
    event EventClear();

    function Coin(string _tokenName, string _tokenSymbol, address _minter) { 
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        changeOwner(_minter);
        mint=I_minter(_minter); 
	}
}

/** @title RiskCoin. */
contract RiskCoin is Coin{
    function RiskCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 
	
    function() payable {
		/** @dev direct any ETH sent to this RiskCoin address to the minter.NewRisk function
		*/
        mint.NewRiskAdr.value(msg.value)(msg.sender);
    }  
}

/** @title StatiCoin. */
contract StatiCoin is Coin{
    function StatiCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 

    function() payable {        
		/** @dev direct any ETH sent to this StatiCoin address to the minter.NewStatic function
        */
        mint.NewStaticAdr.value(msg.value)(msg.sender);
    }  
}

/** @title I_coin. */
contract I_coin is mortal {

    event EventClear();

	I_minter public mint;
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals=18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = '';       //human 0.1 standard. Just an arbitrary versioning scheme.
	
    function mintCoin(address target, uint256 mintedAmount) returns (bool success) {}
    function meltCoin(address target, uint256 meltedAmount) returns (bool success) {}
    function approveAndCall(address _spender, uint256 _value, bytes _extraData){}

    function setMinter(address _minter) {}   
	function increaseApproval (address _spender, uint256 _addedValue) returns (bool success) {}    
	function decreaseApproval (address _spender, uint256 _subtractedValue) 	returns (bool success) {} 

    // @param _owner The address from which the balance will be retrieved
    // @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}    


    // @notice send `_value` token to `_to` from `msg.sender`
    // @param _to The address of the recipient
    // @param _value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}


    // @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    // @param _from The address of the sender
    // @param _to The address of the recipient
    // @param _value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    // @notice `msg.sender` approves `_addr` to spend `_value` tokens
    // @param _spender The address of the account able to transfer the tokens
    // @param _value The amount of wei to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
	// @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
	
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	// @return total amount of tokens
    uint256 public totalSupply;
}

/** @title I_minter. */
contract I_minter { 
    event EventCreateStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventCreateRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventBankrupt();
	
    function Leverage() constant returns (uint128)  {}
    function RiskPrice(uint128 _currentPrice,uint128 _StaticTotal,uint128 _RiskTotal, uint128 _ETHTotal) constant returns (uint128 price)  {}
    function RiskPrice(uint128 _currentPrice) constant returns (uint128 price)  {}     
    function PriceReturn(uint _TransID,uint128 _Price) {}
    function NewStatic() external payable returns (uint _TransID)  {}
    function NewStaticAdr(address _Risk) external payable returns (uint _TransID)  {}
    function NewRisk() external payable returns (uint _TransID)  {}
    function NewRiskAdr(address _Risk) external payable returns (uint _TransID)  {}
    function RetRisk(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function RetStatic(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function Strike() constant returns (uint128)  {}
}