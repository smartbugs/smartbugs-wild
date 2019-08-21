pragma solidity ^0.4.23;

/*********************************************************************************
 *********************************************************************************
 *
 * Name of the project: Senddox registration service
 * Version: 0.6
 * Author: Ethernity.live 
 *
 *********************************************************************************
 ********************************************************************************/

 /* New ERC20 contract interface */

contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) constant returns (uint256);
	function transfer(address to, uint256 value) returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}


// Interface for Storage
contract GlobalStorageMultiId { 
	uint256 public regPrice;
	function registerUser(bytes32 _id) payable returns(bool);
	function changeAddress(bytes32 _id , address _newAddress) returns(bool);
	function setUint(bytes32 _id , bytes32 _key , uint _data , bool _overwrite) returns(bool);
	function getUint(bytes32 _id , bytes32 _key) constant returns(uint);
	event Error(string _string);
	event RegisteredUser(address _address , bytes32 _id);
	event ChangedAdd(bytes32 _id , address _old , address _new);
}

contract UpgDocs {
	function confirm(bytes32 _storKey) returns(bool);
	event DocsUpgraded(address _oldAddress,address _newAddress);
}

// The Token
contract RegDocuments {
	string public version;
	address public admin;
	address public owner;
	uint public price;
	bool registered;
	address storageAddress;
	bytes32 public storKey;
	uint public adminPerc;

	GlobalStorageMultiId public Storage;

	event RegDocument(address indexed from);
	event DocsUpgraded(address _oldAddress,address _newAddress);
	event ReceivedPayment(address indexed _address,uint256 _value);

	// Modifiers

	modifier onlyAdmin() {
		if ( msg.sender != admin && msg.sender != owner ) revert();
		_;
	}

	modifier onlyOwner() {
		if ( msg.sender != owner ) revert();
		_;
	}


	// Constructor
	constructor() {     
		price = 0.01 ether;  
		admin = msg.sender;        
		owner = 0xc238ff50c09787e7b920f711850dd945a40d3232;
		version = "v0.6";
		// storageAddress = 0xabc66b985ce66ba651f199555dd4236dbcd14daa; // Kovan
		// storageAddress = 0xb94cde73d07e0fcd7768cd0c7a8fb2afb403327a; // Rinkeby
		storageAddress = 0x8f49722c61a9398a1c5f5ce6e5feeef852831a64; // Mainnet
		adminPerc = 2;
		Storage = GlobalStorageMultiId(storageAddress);
	}


	// GlobalStorage functions
	// ----------------------------------------

	function getStoragePrice() onlyAdmin constant returns(uint) {
		return Storage.regPrice();
	}

	function registerDocs(bytes32 _storKey) onlyAdmin payable {
		// Register key with IntelligentStorage
		require(!registered); // It only does it one time
		uint _value = Storage.regPrice();
		storKey = _storKey;
		Storage.registerUser.value(_value)(_storKey);
		registered = true;
	}

	function upgradeDocs(address _newAddress) onlyAdmin {
		// This is to update this contract to a new address and transfer ownership of Storage to the new address
		UpgDocs newDocs = UpgDocs(_newAddress);
		require(newDocs.confirm(storKey));
		Storage.changeAddress(storKey,_newAddress);
		_newAddress.send(this.balance);
	}

	function confirm(bytes32 _storKey) returns(bool) {
		// This is called from older version, to register key for IntelligentStorage
		require(!registered);
		storKey = _storKey;
		registered = true;
		emit DocsUpgraded(msg.sender,this);
		return true;
	}

	// Admin functions
	// -------------------------------------

	function changeOwner(address _newOwnerAddress) onlyOwner returns(bool){
		owner = _newOwnerAddress;
		return true;
	}

	function changeAdmin(address _newAdmin) onlyOwner returns(bool) {
		admin = _newAdmin;
		return true;
	}

	function sendToken(address _token,address _to , uint _value) onlyOwner returns(bool) {
		// To send ERC20 tokens sent accidentally
		ERC20Basic Token = ERC20Basic(_token);
		require(Token.transfer(_to, _value));
		return true;
	}

	function changePerc(uint _newperc) onlyAdmin public {
		adminPerc = _newperc;
	}

	function changePrice(uint _newPrice) onlyAdmin public {
		price = _newPrice;
	}

	// Main functions
	// -----------------------------------------------------

	function() payable public {
		// Invoked by users to pay for the service
		uint a = getUint(msg.sender);
		setUint(msg.sender, a + msg.value);
		admin.send(msg.value * adminPerc / 100);
		owner.send(this.balance);
		emit ReceivedPayment(msg.sender, msg.value);
	}

	function sendCredits(address[] _addresses, uint _amountEach) onlyAdmin public returns (bool success) {
		// Invoked by admin to give balance to users
		for (uint8 i=0; i<_addresses.length; i++){
			uint a = getUint(_addresses[i]);
			setUint(_addresses[i], a + _amountEach);
			emit ReceivedPayment(_addresses[i],_amountEach);
		}
	}

	function getBalance(address _address) constant returns(uint) {
		return getUint(_address);
	}

	function regDoc(address _address, string _hash) onlyAdmin returns (bool success) {
		uint a = getUint(_address);
		require(a >= price);
		setUint(_address, a - price);
		emit RegDocument(_address);
		return true;
		}

	function getPrice() constant returns(uint) {
		return price;
	}

	// Internal functions

	function setUint(address _address, uint _value) internal {
		Storage.setUint(storKey, bytes32(_address), _value, true);
	}

	function getUint(address _address) internal constant returns(uint) {
		return Storage.getUint(storKey, bytes32(_address));

	}

}