pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }


contract TheAO {
	address public theAO;
	address public nameTAOPositionAddress;

	// Check whether an address is whitelisted and granted access to transact
	// on behalf of others
	mapping (address => bool) public whitelist;

	constructor() public {
		theAO = msg.sender;
	}

	/**
	 * @dev Checks if msg.sender is in whitelist.
	 */
	modifier inWhitelist() {
		require (whitelist[msg.sender] == true);
		_;
	}

	/**
	 * @dev Transfer ownership of The AO to new address
	 * @param _theAO The new address to be transferred
	 */
	function transferOwnership(address _theAO) public {
		require (msg.sender == theAO);
		require (_theAO != address(0));
		theAO = _theAO;
	}

	/**
	 * @dev Whitelist `_account` address to transact on behalf of others
	 * @param _account The address to whitelist
	 * @param _whitelist Either to whitelist or not
	 */
	function setWhitelist(address _account, bool _whitelist) public {
		require (msg.sender == theAO);
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

	/**
	 * @dev Multiplies two numbers, throws on overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		// Gas optimization: this is cheaper than asserting 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

	/**
	 * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	 */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	/**
	 * @dev Adds two numbers, throws on overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}






/**
 * @title TAOCurrency
 */
contract TAOCurrency is TheAO {
	using SafeMath for uint256;

	// Public variables of the contract
	string public name;
	string public symbol;
	uint8 public decimals;

	// To differentiate denomination of TAO Currency
	uint256 public powerOfTen;

	uint256 public totalSupply;

	// This creates an array with all balances
	// address is the address of nameId, not the eth public address
	mapping (address => uint256) public balanceOf;

	// This generates a public event on the blockchain that will notify clients
	// address is the address of TAO/Name Id, not eth public address
	event Transfer(address indexed from, address indexed to, uint256 value);

	// This notifies clients about the amount burnt
	// address is the address of TAO/Name Id, not eth public address
	event Burn(address indexed from, uint256 value);

	/**
	 * Constructor function
	 *
	 * Initializes contract with initial supply TAOCurrency to the creator of the contract
	 */
	constructor (string memory _name, string memory _symbol, address _nameTAOPositionAddress) public {
		name = _name;		// Set the name for display purposes
		symbol = _symbol;	// Set the symbol for display purposes

		powerOfTen = 0;
		decimals = 0;

		setNameTAOPositionAddress(_nameTAOPositionAddress);
	}

	/**
	 * @dev Checks if the calling contract address is The AO
	 *		OR
	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate
	 */
	modifier onlyTheAO {
		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));
		_;
	}

	/**
	 * @dev Check if `_id` is a Name or a TAO
	 */
	modifier isNameOrTAO(address _id) {
		require (AOLibrary.isName(_id) || AOLibrary.isTAO(_id));
		_;
	}

	/***** The AO ONLY METHODS *****/
	/**
	 * @dev Transfer ownership of The AO to new address
	 * @param _theAO The new address to be transferred
	 */
	function transferOwnership(address _theAO) public onlyTheAO {
		require (_theAO != address(0));
		theAO = _theAO;
	}

	/**
	 * @dev Whitelist `_account` address to transact on behalf of others
	 * @param _account The address to whitelist
	 * @param _whitelist Either to whitelist or not
	 */
	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}

	/**
	 * @dev The AO set the NameTAOPosition Address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 */
	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
	}

	/***** PUBLIC METHODS *****/
	/**
	 * @dev transfer TAOCurrency from other address
	 *
	 * Send `_value` TAOCurrency to `_to` in behalf of `_from`
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transferFrom(address _from, address _to, uint256 _value) public inWhitelist isNameOrTAO(_from) isNameOrTAO(_to) returns (bool) {
		_transfer(_from, _to, _value);
		return true;
	}

	/**
	 * @dev Create `mintedAmount` TAOCurrency and send it to `target`
	 * @param target Address to receive TAOCurrency
	 * @param mintedAmount The amount of TAOCurrency it will receive
	 * @return true on success
	 */
	function mint(address target, uint256 mintedAmount) public inWhitelist isNameOrTAO(target) returns (bool) {
		_mint(target, mintedAmount);
		return true;
	}

	/**
	 *
	 * @dev Whitelisted address remove `_value` TAOCurrency from the system irreversibly on behalf of `_from`.
	 *
	 * @param _from the address of the sender
	 * @param _value the amount of money to burn
	 */
	function whitelistBurnFrom(address _from, uint256 _value) public inWhitelist isNameOrTAO(_from) returns (bool success) {
		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
		balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the targeted balance
		totalSupply = totalSupply.sub(_value);              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}

	/***** INTERNAL METHODS *****/
	/**
	 * @dev Send `_value` TAOCurrency from `_from` to `_to`
	 * @param _from The address of sender
	 * @param _to The address of the recipient
	 * @param _value The amount to send
	 */
	function _transfer(address _from, address _to, uint256 _value) internal {
		require (_to != address(0));							// Prevent transfer to 0x0 address. Use burn() instead
		require (balanceOf[_from] >= _value);					// Check if the sender has enough
		require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows
		uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
		balanceOf[_from] = balanceOf[_from].sub(_value);        // Subtract from the sender
		balanceOf[_to] = balanceOf[_to].add(_value);            // Add the same to the recipient
		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
	}

	/**
	 * @dev Create `mintedAmount` TAOCurrency and send it to `target`
	 * @param target Address to receive TAOCurrency
	 * @param mintedAmount The amount of TAOCurrency it will receive
	 */
	function _mint(address target, uint256 mintedAmount) internal {
		balanceOf[target] = balanceOf[target].add(mintedAmount);
		totalSupply = totalSupply.add(mintedAmount);
		emit Transfer(address(0), address(this), mintedAmount);
		emit Transfer(address(this), target, mintedAmount);
	}
}


interface INameTAOPosition {
	function senderIsAdvocate(address _sender, address _id) external view returns (bool);
	function senderIsListener(address _sender, address _id) external view returns (bool);
	function senderIsSpeaker(address _sender, address _id) external view returns (bool);
	function senderIsPosition(address _sender, address _id) external view returns (bool);
	function getAdvocate(address _id) external view returns (address);
	function nameIsAdvocate(address _nameId, address _id) external view returns (bool);
	function nameIsPosition(address _nameId, address _id) external view returns (bool);
	function initialize(address _id, address _advocateId, address _listenerId, address _speakerId) external returns (bool);
	function determinePosition(address _sender, address _id) external view returns (uint256);
}



interface IAOSetting {
	function getSettingValuesByTAOName(address _taoId, string calldata _settingName) external view returns (uint256, bool, address, bytes32, string memory);
	function getSettingTypes() external view returns (uint8, uint8, uint8, uint8, uint8);

	function settingTypeLookup(uint256 _settingId) external view returns (uint8);
}


interface INameAccountRecovery {
	function isCompromised(address _id) external view returns (bool);
}


interface INamePublicKey {
	function initialize(address _id, address _defaultKey, address _writerKey) external returns (bool);

	function isKeyExist(address _id, address _key) external view returns (bool);

	function getDefaultKey(address _id) external view returns (address);

	function whitelistAddKey(address _id, address _key) external returns (bool);
}


interface INameTAOLookup {
	function isExist(string calldata _name) external view returns (bool);

	function initialize(string calldata _name, address _nameTAOId, uint256 _typeId, string calldata _parentName, address _parentId, uint256 _parentTypeId) external returns (bool);

	function getById(address _id) external view returns (string memory, address, uint256, string memory, address, uint256);

	function getIdByName(string calldata _name) external view returns (address);
}


interface INameFactory {
	function nonces(address _nameId) external view returns (uint256);
	function incrementNonce(address _nameId) external returns (uint256);
	function ethAddressToNameId(address _ethAddress) external view returns (address);
	function setNameNewAddress(address _id, address _newAddress) external returns (bool);
	function nameIdToEthAddress(address _nameId) external view returns (address);
}













contract TokenERC20 {
	// Public variables of the token
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public totalSupply;

	// This creates an array with all balances
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);

	// This generates a public event on the blockchain that will notify clients
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	 * Constructor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor (uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
	}

	/**
	 * Internal transfer, only can be called by this contract
	 */
	function _transfer(address _from, address _to, uint _value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != address(0));
		// Check if the sender has enough
		require(balanceOf[_from] >= _value);
		// Check for overflows
		require(balanceOf[_to] + _value > balanceOf[_to]);
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		// Subtract from the sender
		balanceOf[_from] -= _value;
		// Add the same to the recipient
		balanceOf[_to] += _value;
		emit Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	/**
	 * Transfer tokens
	 *
	 * Send `_value` tokens to `_to` from your account
	 *
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transfer(address _to, uint256 _value) public returns (bool success) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	 * Transfer tokens from other address
	 *
	 * Send `_value` tokens to `_to` in behalf of `_from`
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowance[_from][msg.sender]);     // Check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	/**
	 * Set allowance for other address
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 */
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	 * Set allowance for other address and notify
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 * @param _extraData some extra information to send to the approved contract
	 */
	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, address(this), _extraData);
			return true;
		}
	}

	/**
	 * Destroy tokens
	 *
	 * Remove `_value` tokens from the system irreversibly
	 *
	 * @param _value the amount of money to burn
	 */
	function burn(uint256 _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
		balanceOf[msg.sender] -= _value;            // Subtract from the sender
		totalSupply -= _value;                      // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	/**
	 * Destroy tokens from other account
	 *
	 * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
	 *
	 * @param _from the address of the sender
	 * @param _value the amount of money to burn
	 */
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]);    // Check allowance
		balanceOf[_from] -= _value;                         // Subtract from the targeted balance
		allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
		totalSupply -= _value;                              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}
}


/**
 * @title TAO
 */
contract TAO {
	using SafeMath for uint256;

	address public vaultAddress;
	string public name;				// the name for this TAO
	address public originId;		// the ID of the Name that created this TAO. If Name, it's the eth address

	// TAO's data
	string public datHash;
	string public database;
	string public keyValue;
	bytes32 public contentId;

	/**
	 * 0 = TAO
	 * 1 = Name
	 */
	uint8 public typeId;

	/**
	 * @dev Constructor function
	 */
	constructor (string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _vaultAddress
	) public {
		name = _name;
		originId = _originId;
		datHash = _datHash;
		database = _database;
		keyValue = _keyValue;
		contentId = _contentId;

		// Creating TAO
		typeId = 0;

		vaultAddress = _vaultAddress;
	}

	/**
	 * @dev Checks if calling address is Vault contract
	 */
	modifier onlyVault {
		require (msg.sender == vaultAddress);
		_;
	}

	/**
	 * Will receive any ETH sent
	 */
	function () external payable {
	}

	/**
	 * @dev Allows Vault to transfer `_amount` of ETH from this TAO to `_recipient`
	 * @param _recipient The recipient address
	 * @param _amount The amount to transfer
	 * @return true on success
	 */
	function transferEth(address payable _recipient, uint256 _amount) public onlyVault returns (bool) {
		_recipient.transfer(_amount);
		return true;
	}

	/**
	 * @dev Allows Vault to transfer `_amount` of ERC20 Token from this TAO to `_recipient`
	 * @param _erc20TokenAddress The address of ERC20 Token
	 * @param _recipient The recipient address
	 * @param _amount The amount to transfer
	 * @return true on success
	 */
	function transferERC20(address _erc20TokenAddress, address _recipient, uint256 _amount) public onlyVault returns (bool) {
		TokenERC20 _erc20 = TokenERC20(_erc20TokenAddress);
		_erc20.transfer(_recipient, _amount);
		return true;
	}
}


/**
 * @title Name
 */
contract Name is TAO {
	/**
	 * @dev Constructor function
	 */
	constructor (string memory _name, address _originId, string memory _datHash, string memory _database, string memory _keyValue, bytes32 _contentId, address _vaultAddress)
		TAO (_name, _originId, _datHash, _database, _keyValue, _contentId, _vaultAddress) public {
		// Creating Name
		typeId = 1;
	}
}


/**
 * @title AOLibrary
 */
library AOLibrary {
	using SafeMath for uint256;

	uint256 constant private _MULTIPLIER_DIVISOR = 10 ** 6; // 1000000 = 1
	uint256 constant private _PERCENTAGE_DIVISOR = 10 ** 6; // 100% = 1000000

	/**
	 * @dev Check whether or not the given TAO ID is a TAO
	 * @param _taoId The ID of the TAO
	 * @return true if yes. false otherwise
	 */
	function isTAO(address _taoId) public view returns (bool) {
		return (_taoId != address(0) && bytes(TAO(address(uint160(_taoId))).name()).length > 0 && TAO(address(uint160(_taoId))).originId() != address(0) && TAO(address(uint160(_taoId))).typeId() == 0);
	}

	/**
	 * @dev Check whether or not the given Name ID is a Name
	 * @param _nameId The ID of the Name
	 * @return true if yes. false otherwise
	 */
	function isName(address _nameId) public view returns (bool) {
		return (_nameId != address(0) && bytes(TAO(address(uint160(_nameId))).name()).length > 0 && Name(address(uint160(_nameId))).originId() != address(0) && Name(address(uint160(_nameId))).typeId() == 1);
	}

	/**
	 * @dev Check if `_tokenAddress` is a valid ERC20 Token address
	 * @param _tokenAddress The ERC20 Token address to check
	 */
	function isValidERC20TokenAddress(address _tokenAddress) public view returns (bool) {
		if (_tokenAddress == address(0)) {
			return false;
		}
		TokenERC20 _erc20 = TokenERC20(_tokenAddress);
		return (_erc20.totalSupply() >= 0 && bytes(_erc20.name()).length > 0 && bytes(_erc20.symbol()).length > 0);
	}

	/**
	 * @dev Checks if the calling contract address is The AO
	 *		OR
	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate
	 * @param _sender The address to check
	 * @param _theAO The AO address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 * @return true if yes, false otherwise
	 */
	function isTheAO(address _sender, address _theAO, address _nameTAOPositionAddress) public view returns (bool) {
		return (_sender == _theAO ||
			(
				(isTAO(_theAO) || isName(_theAO)) &&
				_nameTAOPositionAddress != address(0) &&
				INameTAOPosition(_nameTAOPositionAddress).senderIsAdvocate(_sender, _theAO)
			)
		);
	}

	/**
	 * @dev Return the divisor used to correctly calculate percentage.
	 *		Percentage stored throughout AO contracts covers 4 decimals,
	 *		so 1% is 10000, 1.25% is 12500, etc
	 */
	function PERCENTAGE_DIVISOR() public pure returns (uint256) {
		return _PERCENTAGE_DIVISOR;
	}

	/**
	 * @dev Return the divisor used to correctly calculate multiplier.
	 *		Multiplier stored throughout AO contracts covers 6 decimals,
	 *		so 1 is 1000000, 0.023 is 23000, etc
	 */
	function MULTIPLIER_DIVISOR() public pure returns (uint256) {
		return _MULTIPLIER_DIVISOR;
	}

	/**
	 * @dev deploy a TAO
	 * @param _name The name of the TAO
	 * @param _originId The Name ID the creates the TAO
	 * @param _datHash The datHash of this TAO
	 * @param _database The database for this TAO
	 * @param _keyValue The key/value pair to be checked on the database
	 * @param _contentId The contentId related to this TAO
	 * @param _nameTAOVaultAddress The address of NameTAOVault
	 */
	function deployTAO(string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _nameTAOVaultAddress
		) public returns (TAO _tao) {
		_tao = new TAO(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);
	}

	/**
	 * @dev deploy a Name
	 * @param _name The name of the Name
	 * @param _originId The eth address the creates the Name
	 * @param _datHash The datHash of this Name
	 * @param _database The database for this Name
	 * @param _keyValue The key/value pair to be checked on the database
	 * @param _contentId The contentId related to this Name
	 * @param _nameTAOVaultAddress The address of NameTAOVault
	 */
	function deployName(string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _nameTAOVaultAddress
		) public returns (Name _myName) {
		_myName = new Name(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);
	}

	/**
	 * @dev Calculate the new weighted multiplier when adding `_additionalPrimordialAmount` at `_additionalWeightedMultiplier` to the current `_currentPrimordialBalance` at `_currentWeightedMultiplier`
	 * @param _currentWeightedMultiplier Account's current weighted multiplier
	 * @param _currentPrimordialBalance Account's current primordial ion balance
	 * @param _additionalWeightedMultiplier The weighted multiplier to be added
	 * @param _additionalPrimordialAmount The primordial ion amount to be added
	 * @return the new primordial weighted multiplier
	 */
	function calculateWeightedMultiplier(uint256 _currentWeightedMultiplier, uint256 _currentPrimordialBalance, uint256 _additionalWeightedMultiplier, uint256 _additionalPrimordialAmount) public pure returns (uint256) {
		if (_currentWeightedMultiplier > 0) {
			uint256 _totalWeightedIons = (_currentWeightedMultiplier.mul(_currentPrimordialBalance)).add(_additionalWeightedMultiplier.mul(_additionalPrimordialAmount));
			uint256 _totalIons = _currentPrimordialBalance.add(_additionalPrimordialAmount);
			return _totalWeightedIons.div(_totalIons);
		} else {
			return _additionalWeightedMultiplier;
		}
	}

	/**
	 * @dev Calculate the primordial ion multiplier on a given lot
	 *		Total Primordial Mintable = T
	 *		Total Primordial Minted = M
	 *		Starting Multiplier = S
	 *		Ending Multiplier = E
	 *		To Purchase = P
	 *		Multiplier for next Lot of Amount = (1 - ((M + P/2) / T)) x (S-E)
	 *
	 * @param _purchaseAmount The amount of primordial ion intended to be purchased
	 * @param _totalPrimordialMintable Total Primordial ion mintable
	 * @param _totalPrimordialMinted Total Primordial ion minted so far
	 * @param _startingMultiplier The starting multiplier in (10 ** 6)
	 * @param _endingMultiplier The ending multiplier in (10 ** 6)
	 * @return The multiplier in (10 ** 6)
	 */
	function calculatePrimordialMultiplier(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {
		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {
			/**
			 * Let temp = M + (P/2)
			 * Multiplier = (1 - (temp / T)) x (S-E)
			 */
			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));

			/**
			 * Multiply multiplier with _MULTIPLIER_DIVISOR/_MULTIPLIER_DIVISOR to account for 6 decimals
			 * so, Multiplier = (_MULTIPLIER_DIVISOR/_MULTIPLIER_DIVISOR) * (1 - (temp / T)) * (S-E)
			 * Multiplier = ((_MULTIPLIER_DIVISOR * (1 - (temp / T))) * (S-E)) / _MULTIPLIER_DIVISOR
			 * Multiplier = ((_MULTIPLIER_DIVISOR - ((_MULTIPLIER_DIVISOR * temp) / T)) * (S-E)) / _MULTIPLIER_DIVISOR
			 * Take out the division by _MULTIPLIER_DIVISOR for now and include in later calculation
			 * Multiplier = (_MULTIPLIER_DIVISOR - ((_MULTIPLIER_DIVISOR * temp) / T)) * (S-E)
			 */
			uint256 multiplier = (_MULTIPLIER_DIVISOR.sub(_MULTIPLIER_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier));
			/**
			 * Since _startingMultiplier and _endingMultiplier are in 6 decimals
			 * Need to divide multiplier by _MULTIPLIER_DIVISOR
			 */
			return multiplier.div(_MULTIPLIER_DIVISOR);
		} else {
			return 0;
		}
	}

	/**
	 * @dev Calculate the bonus percentage of network ion on a given lot
	 *		Total Primordial Mintable = T
	 *		Total Primordial Minted = M
	 *		Starting Network Bonus Multiplier = Bs
	 *		Ending Network Bonus Multiplier = Be
	 *		To Purchase = P
	 *		AO Bonus % = B% = (1 - ((M + P/2) / T)) x (Bs-Be)
	 *
	 * @param _purchaseAmount The amount of primordial ion intended to be purchased
	 * @param _totalPrimordialMintable Total Primordial ion intable
	 * @param _totalPrimordialMinted Total Primordial ion minted so far
	 * @param _startingMultiplier The starting Network ion bonus multiplier
	 * @param _endingMultiplier The ending Network ion bonus multiplier
	 * @return The bonus percentage
	 */
	function calculateNetworkBonusPercentage(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {
		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {
			/**
			 * Let temp = M + (P/2)
			 * B% = (1 - (temp / T)) x (Bs-Be)
			 */
			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));

			/**
			 * Multiply B% with _PERCENTAGE_DIVISOR/_PERCENTAGE_DIVISOR to account for 6 decimals
			 * so, B% = (_PERCENTAGE_DIVISOR/_PERCENTAGE_DIVISOR) * (1 - (temp / T)) * (Bs-Be)
			 * B% = ((_PERCENTAGE_DIVISOR * (1 - (temp / T))) * (Bs-Be)) / _PERCENTAGE_DIVISOR
			 * B% = ((_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be)) / _PERCENTAGE_DIVISOR
			 * Take out the division by _PERCENTAGE_DIVISOR for now and include in later calculation
			 * B% = (_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be)
			 * But since Bs and Be are in 6 decimals, need to divide by _PERCENTAGE_DIVISOR
			 * B% = (_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be) / _PERCENTAGE_DIVISOR
			 */
			uint256 bonusPercentage = (_PERCENTAGE_DIVISOR.sub(_PERCENTAGE_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier)).div(_PERCENTAGE_DIVISOR);
			return bonusPercentage;
		} else {
			return 0;
		}
	}

	/**
	 * @dev Calculate the bonus amount of network ion on a given lot
	 *		AO Bonus Amount = B% x P
	 *
	 * @param _purchaseAmount The amount of primordial ion intended to be purchased
	 * @param _totalPrimordialMintable Total Primordial ion intable
	 * @param _totalPrimordialMinted Total Primordial ion minted so far
	 * @param _startingMultiplier The starting Network ion bonus multiplier
	 * @param _endingMultiplier The ending Network ion bonus multiplier
	 * @return The bonus percentage
	 */
	function calculateNetworkBonusAmount(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {
		uint256 bonusPercentage = calculateNetworkBonusPercentage(_purchaseAmount, _totalPrimordialMintable, _totalPrimordialMinted, _startingMultiplier, _endingMultiplier);
		/**
		 * Since bonusPercentage is in _PERCENTAGE_DIVISOR format, need to divide it with _PERCENTAGE DIVISOR
		 * when calculating the network ion bonus amount
		 */
		uint256 networkBonus = bonusPercentage.mul(_purchaseAmount).div(_PERCENTAGE_DIVISOR);
		return networkBonus;
	}

	/**
	 * @dev Calculate the maximum amount of Primordial an account can burn
	 *		_primordialBalance = P
	 *		_currentWeightedMultiplier = M
	 *		_maximumMultiplier = S
	 *		_amountToBurn = B
	 *		B = ((S x P) - (P x M)) / S
	 *
	 * @param _primordialBalance Account's primordial ion balance
	 * @param _currentWeightedMultiplier Account's current weighted multiplier
	 * @param _maximumMultiplier The maximum multiplier of this account
	 * @return The maximum burn amount
	 */
	function calculateMaximumBurnAmount(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _maximumMultiplier) public pure returns (uint256) {
		return (_maximumMultiplier.mul(_primordialBalance).sub(_primordialBalance.mul(_currentWeightedMultiplier))).div(_maximumMultiplier);
	}

	/**
	 * @dev Calculate the new multiplier after burning primordial ion
	 *		_primordialBalance = P
	 *		_currentWeightedMultiplier = M
	 *		_amountToBurn = B
	 *		_newMultiplier = E
	 *		E = (P x M) / (P - B)
	 *
	 * @param _primordialBalance Account's primordial ion balance
	 * @param _currentWeightedMultiplier Account's current weighted multiplier
	 * @param _amountToBurn The amount of primordial ion to burn
	 * @return The new multiplier
	 */
	function calculateMultiplierAfterBurn(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToBurn) public pure returns (uint256) {
		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.sub(_amountToBurn));
	}

	/**
	 * @dev Calculate the new multiplier after converting network ion to primordial ion
	 *		_primordialBalance = P
	 *		_currentWeightedMultiplier = M
	 *		_amountToConvert = C
	 *		_newMultiplier = E
	 *		E = (P x M) / (P + C)
	 *
	 * @param _primordialBalance Account's primordial ion balance
	 * @param _currentWeightedMultiplier Account's current weighted multiplier
	 * @param _amountToConvert The amount of network ion to convert
	 * @return The new multiplier
	 */
	function calculateMultiplierAfterConversion(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToConvert) public pure returns (uint256) {
		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.add(_amountToConvert));
	}

	/**
	 * @dev count num of digits
	 * @param number uint256 of the nuumber to be checked
	 * @return uint8 num of digits
	 */
	function numDigits(uint256 number) public pure returns (uint8) {
		uint8 digits = 0;
		while(number != 0) {
			number = number.div(10);
			digits++;
		}
		return digits;
	}
}










/**
 * @title Voice
 */
contract Voice is TheAO {
	using SafeMath for uint256;

	// Public variables of the contract
	string public name;
	string public symbol;
	uint8 public decimals = 4;

	uint256 constant public MAX_SUPPLY_PER_NAME = 100 * (10 ** 4);

	uint256 public totalSupply;

	// Mapping from Name ID to bool value whether or not it has received Voice
	mapping (address => bool) public hasReceived;

	// Mapping from Name/TAO ID to its total available balance
	mapping (address => uint256) public balanceOf;

	// Mapping from Name ID to TAO ID and its staked amount
	mapping (address => mapping(address => uint256)) public taoStakedBalance;

	// This generates a public event on the blockchain that will notify clients
	event Mint(address indexed nameId, uint256 value);
	event Stake(address indexed nameId, address indexed taoId, uint256 value);
	event Unstake(address indexed nameId, address indexed taoId, uint256 value);

	/**
	 * Constructor function
	 */
	constructor (string memory _name, string memory _symbol) public {
		name = _name;						// Set the name for display purposes
		symbol = _symbol;					// Set the symbol for display purposes
	}

	/**
	 * @dev Checks if the calling contract address is The AO
	 *		OR
	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate
	 */
	modifier onlyTheAO {
		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));
		_;
	}

	/**
	 * @dev Check if `_taoId` is a TAO
	 */
	modifier isTAO(address _taoId) {
		require (AOLibrary.isTAO(_taoId));
		_;
	}

	/**
	 * @dev Check if `_nameId` is a Name
	 */
	modifier isName(address _nameId) {
		require (AOLibrary.isName(_nameId));
		_;
	}

	/***** The AO ONLY METHODS *****/
	/**
	 * @dev Transfer ownership of The AO to new address
	 * @param _theAO The new address to be transferred
	 */
	function transferOwnership(address _theAO) public onlyTheAO {
		require (_theAO != address(0));
		theAO = _theAO;
	}

	/**
	 * @dev Whitelist `_account` address to transact on behalf of others
	 * @param _account The address to whitelist
	 * @param _whitelist Either to whitelist or not
	 */
	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}

	/**
	 * @dev The AO set the NameTAOPosition Address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 */
	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
	}

	/***** PUBLIC METHODS *****/
	/**
	 * @dev Create `MAX_SUPPLY_PER_NAME` Voice and send it to `_nameId`
	 * @param _nameId Address to receive Voice
	 * @return true on success
	 */
	function mint(address _nameId) public inWhitelist isName(_nameId) returns (bool) {
		// Make sure _nameId has not received Voice
		require (hasReceived[_nameId] == false);

		hasReceived[_nameId] = true;
		balanceOf[_nameId] = balanceOf[_nameId].add(MAX_SUPPLY_PER_NAME);
		totalSupply = totalSupply.add(MAX_SUPPLY_PER_NAME);
		emit Mint(_nameId, MAX_SUPPLY_PER_NAME);
		return true;
	}

	/**
	 * @dev Get staked balance of `_nameId`
	 * @param _nameId The Name ID to be queried
	 * @return total staked balance
	 */
	function stakedBalance(address _nameId) public isName(_nameId) view returns (uint256) {
		return MAX_SUPPLY_PER_NAME.sub(balanceOf[_nameId]);
	}

	/**
	 * @dev Stake `_value` Voice on `_taoId` from `_nameId`
	 * @param _nameId The Name ID that wants to stake
	 * @param _taoId The TAO ID to stake
	 * @param _value The amount to stake
	 * @return true on success
	 */
	function stake(address _nameId, address _taoId, uint256 _value) public inWhitelist isName(_nameId) isTAO(_taoId) returns (bool) {
		require (_value > 0 && _value <= MAX_SUPPLY_PER_NAME);
		require (balanceOf[_nameId] >= _value);							// Check if the targeted balance is enough
		balanceOf[_nameId] = balanceOf[_nameId].sub(_value);			// Subtract from the targeted balance
		taoStakedBalance[_nameId][_taoId] = taoStakedBalance[_nameId][_taoId].add(_value);	// Add to the targeted staked balance
		balanceOf[_taoId] = balanceOf[_taoId].add(_value);
		emit Stake(_nameId, _taoId, _value);
		return true;
	}

	/**
	 * @dev Unstake `_value` Voice from `_nameId`'s `_taoId`
	 * @param _nameId The Name ID that wants to unstake
	 * @param _taoId The TAO ID to unstake
	 * @param _value The amount to unstake
	 * @return true on success
	 */
	function unstake(address _nameId, address _taoId, uint256 _value) public inWhitelist isName(_nameId) isTAO(_taoId) returns (bool) {
		require (_value > 0 && _value <= MAX_SUPPLY_PER_NAME);
		require (taoStakedBalance[_nameId][_taoId] >= _value);	// Check if the targeted staked balance is enough
		require (balanceOf[_taoId] >= _value);	// Check if the total targeted staked balance is enough
		taoStakedBalance[_nameId][_taoId] = taoStakedBalance[_nameId][_taoId].sub(_value);	// Subtract from the targeted staked balance
		balanceOf[_taoId] = balanceOf[_taoId].sub(_value);
		balanceOf[_nameId] = balanceOf[_nameId].add(_value);			// Add to the targeted balance
		emit Unstake(_nameId, _taoId, _value);
		return true;
	}
}










contract Pathos is TAOCurrency {
	/**
	 * @dev Constructor function
	 */
	constructor(string memory _name, string memory _symbol, address _nameTAOPositionAddress)
		TAOCurrency(_name, _symbol, _nameTAOPositionAddress) public {}
}





contract Ethos is TAOCurrency {
	/**
	 * @dev Constructor function
	 */
	constructor(string memory _name, string memory _symbol, address _nameTAOPositionAddress)
		TAOCurrency(_name, _symbol, _nameTAOPositionAddress) public {}
}


/**
 * @title NameFactory
 *
 * The purpose of this contract is to allow node to create Name
 */
contract NameFactory is TheAO, INameFactory {
	using SafeMath for uint256;

	address public voiceAddress;
	address public nameTAOVaultAddress;
	address public nameTAOLookupAddress;
	address public namePublicKeyAddress;
	address public nameAccountRecoveryAddress;
	address public settingTAOId;
	address public aoSettingAddress;
	address public pathosAddress;
	address public ethosAddress;

	Voice internal _voice;
	INameTAOLookup internal _nameTAOLookup;
	INameTAOPosition internal _nameTAOPosition;
	INamePublicKey internal _namePublicKey;
	INameAccountRecovery internal _nameAccountRecovery;
	IAOSetting internal _aoSetting;
	Pathos internal _pathos;
	Ethos internal _ethos;

	address[] internal names;

	// Mapping from eth address to Name ID
	mapping (address => address) internal _ethAddressToNameId;

	// Mapping from Name ID to eth address
	mapping (address => address) internal _nameIdToEthAddress;

	// Mapping from Name ID to its nonce
	mapping (address => uint256) internal _nonces;

	// Event to be broadcasted to public when a Name is created
	event CreateName(address indexed ethAddress, address nameId, uint256 index, string name);

	// Event to be broadcasted to public when Primordial contributor is rewarded
	event RewardContributor(address indexed nameId, uint256 pathosAmount, uint256 ethosAmount);

	/**
	 * @dev Constructor function
	 */
	constructor(address _voiceAddress) public {
		setVoiceAddress(_voiceAddress);
	}

	/**
	 * @dev Checks if the calling contract address is The AO
	 *		OR
	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate
	 */
	modifier onlyTheAO {
		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));
		_;
	}

	/**
	 * @dev Checks if calling address can update Name's nonce
	 */
	modifier canUpdateNonce {
		require (msg.sender == nameTAOPositionAddress || msg.sender == namePublicKeyAddress || msg.sender == nameAccountRecoveryAddress);
		_;
	}

	/***** The AO ONLY METHODS *****/
	/**
	 * @dev Transfer ownership of The AO to new address
	 * @param _theAO The new address to be transferred
	 */
	function transferOwnership(address _theAO) public onlyTheAO {
		require (_theAO != address(0));
		theAO = _theAO;
	}

	/**
	 * @dev Whitelist `_account` address to transact on behalf of others
	 * @param _account The address to whitelist
	 * @param _whitelist Either to whitelist or not
	 */
	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}

	/**
	 * @dev The AO set the Voice Address
	 * @param _voiceAddress The address of Voice
	 */
	function setVoiceAddress(address _voiceAddress) public onlyTheAO {
		require (_voiceAddress != address(0));
		voiceAddress = _voiceAddress;
		_voice = Voice(voiceAddress);
	}

	/**
	 * @dev The AO set the NameTAOVault Address
	 * @param _nameTAOVaultAddress The address of NameTAOVault
	 */
	function setNameTAOVaultAddress(address _nameTAOVaultAddress) public onlyTheAO {
		require (_nameTAOVaultAddress != address(0));
		nameTAOVaultAddress = _nameTAOVaultAddress;
	}

	/**
	 * @dev The AO set the NameTAOLookup Address
	 * @param _nameTAOLookupAddress The address of NameTAOLookup
	 */
	function setNameTAOLookupAddress(address _nameTAOLookupAddress) public onlyTheAO {
		require (_nameTAOLookupAddress != address(0));
		nameTAOLookupAddress = _nameTAOLookupAddress;
		_nameTAOLookup = INameTAOLookup(nameTAOLookupAddress);
	}

	/**
	 * @dev The AO set the NameTAOPosition Address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 */
	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
		_nameTAOPosition = INameTAOPosition(nameTAOPositionAddress);
	}

	/**
	 * @dev The AO set the NamePublicKey Address
	 * @param _namePublicKeyAddress The address of NamePublicKey
	 */
	function setNamePublicKeyAddress(address _namePublicKeyAddress) public onlyTheAO {
		require (_namePublicKeyAddress != address(0));
		namePublicKeyAddress = _namePublicKeyAddress;
		_namePublicKey = INamePublicKey(namePublicKeyAddress);
	}

	/**
	 * @dev The AO set the NameAccountRecovery Address
	 * @param _nameAccountRecoveryAddress The address of NameAccountRecovery
	 */
	function setNameAccountRecoveryAddress(address _nameAccountRecoveryAddress) public onlyTheAO {
		require (_nameAccountRecoveryAddress != address(0));
		nameAccountRecoveryAddress = _nameAccountRecoveryAddress;
		_nameAccountRecovery = INameAccountRecovery(nameAccountRecoveryAddress);
	}

	/**
	 * @dev The AO sets setting TAO ID
	 * @param _settingTAOId The new setting TAO ID to set
	 */
	function setSettingTAOId(address _settingTAOId) public onlyTheAO {
		require (AOLibrary.isTAO(_settingTAOId));
		settingTAOId = _settingTAOId;
	}

	/**
	 * @dev The AO sets AO Setting address
	 * @param _aoSettingAddress The address of AOSetting
	 */
	function setAOSettingAddress(address _aoSettingAddress) public onlyTheAO {
		require (_aoSettingAddress != address(0));
		aoSettingAddress = _aoSettingAddress;
		_aoSetting = IAOSetting(_aoSettingAddress);
	}

	/**
	 * @dev The AO sets Pathos address
	 * @param _pathosAddress The address of Pathos
	 */
	function setPathosAddress(address _pathosAddress) public onlyTheAO {
		require (_pathosAddress != address(0));
		pathosAddress = _pathosAddress;
		_pathos = Pathos(_pathosAddress);
	}

	/**
	 * @dev The AO sets Ethos address
	 * @param _ethosAddress The address of Ethos
	 */
	function setEthosAddress(address _ethosAddress) public onlyTheAO {
		require (_ethosAddress != address(0));
		ethosAddress = _ethosAddress;
		_ethos = Ethos(_ethosAddress);
	}

	/**
	 * @dev NameAccountRecovery contract replaces eth address associated with a Name
	 * @param _id The ID of the Name
	 * @param _newAddress The new eth address
	 * @return true on success
	 */
	function setNameNewAddress(address _id, address _newAddress) external returns (bool) {
		require (msg.sender == nameAccountRecoveryAddress);
		require (AOLibrary.isName(_id));
		require (_newAddress != address(0));
		require (_ethAddressToNameId[_newAddress] == address(0));
		require (_nameIdToEthAddress[_id] != address(0));

		address _currentEthAddress = _nameIdToEthAddress[_id];
		_ethAddressToNameId[_currentEthAddress] = address(0);
		_ethAddressToNameId[_newAddress] = _id;
		_nameIdToEthAddress[_id] = _newAddress;
		return true;
	}

	/***** PUBLIC METHODS *****/
	/**
	 * @dev Get the nonce given a Name ID
	 * @param _nameId The Name ID to check
	 * @return The nonce of the Name
	 */
	function nonces(address _nameId) external view returns (uint256) {
		return _nonces[_nameId];
	}

	/**
	 * @dev Increment the nonce of a Name
	 * @param _nameId The ID of the Name
	 * @return current nonce
	 */
	function incrementNonce(address _nameId) external canUpdateNonce returns (uint256) {
		// Check if _nameId exist
		require (_nonces[_nameId] > 0);
		_nonces[_nameId]++;
		return _nonces[_nameId];
	}

	/**
	 * @dev Create a Name
	 * @param _name The name of the Name
	 * @param _datHash The datHash to this Name's profile
	 * @param _database The database for this Name
	 * @param _keyValue The key/value pair to be checked on the database
	 * @param _contentId The contentId related to this Name
	 * @param _writerKey The writer public key for this Name
	 */
	function createName(string memory _name, string memory _datHash, string memory _database, string memory _keyValue, bytes32 _contentId, address _writerKey) public {
		require (bytes(_name).length > 0);
		require (!_nameTAOLookup.isExist(_name));

		// Only one Name per ETH address
		require (_ethAddressToNameId[msg.sender] == address(0));

		// The address is the Name ID (which is also a TAO ID)
		address nameId = address(AOLibrary.deployName(_name, msg.sender, _datHash, _database, _keyValue, _contentId, nameTAOVaultAddress));

		// Only one ETH address per Name
		require (_nameIdToEthAddress[nameId] == address(0));

		// Increment the nonce
		_nonces[nameId]++;

		_ethAddressToNameId[msg.sender] = nameId;
		_nameIdToEthAddress[nameId] = msg.sender;

		// Store the name lookup information
		require (_nameTAOLookup.initialize(_name, nameId, 1, 'human', msg.sender, 2));

		// Store the Advocate/Listener/Speaker information
		require (_nameTAOPosition.initialize(nameId, nameId, nameId, nameId));

		// Store the public key information
		require (_namePublicKey.initialize(nameId, msg.sender, _writerKey));

		names.push(nameId);

		// Need to mint Voice for this Name
		require (_voice.mint(nameId));

		// Reward primordial contributor Name with Pathos/Ethos
		_rewardContributor(nameId);

		emit CreateName(msg.sender, nameId, names.length.sub(1), _name);
	}

	/**
	 * @dev Get the Name ID given an ETH address
	 * @param _ethAddress The ETH address to check
	 * @return The Name ID
	 */
	function ethAddressToNameId(address _ethAddress) external view returns (address) {
		return _ethAddressToNameId[_ethAddress];
	}

	/**
	 * @dev Get the ETH address given a Name ID
	 * @param _nameId The Name ID to check
	 * @return The ETH address
	 */
	function nameIdToEthAddress(address _nameId) external view returns (address) {
		return _nameIdToEthAddress[_nameId];
	}

	/**
	 * @dev Get Name information
	 * @param _nameId The ID of the Name to be queried
	 * @return The name of the Name
	 * @return The originId of the Name (in this case, it's the creator node's ETH address)
	 * @return The datHash of the Name
	 * @return The database of the Name
	 * @return The keyValue of the Name
	 * @return The contentId of the Name
	 * @return The typeId of the Name
	 */
	function getName(address _nameId) public view returns (string memory, address, string memory, string memory, string memory, bytes32, uint8) {
		Name _name = Name(address(uint160(_nameId)));
		return (
			_name.name(),
			_name.originId(),
			_name.datHash(),
			_name.database(),
			_name.keyValue(),
			_name.contentId(),
			_name.typeId()
		);
	}

	/**
	 * @dev Get total Names count
	 * @return total Names count
	 */
	function getTotalNamesCount() public view returns (uint256) {
		return names.length;
	}

	/**
	 * @dev Get list of Name IDs
	 * @param _from The starting index
	 * @param _to The ending index
	 * @return list of Name IDs
	 */
	function getNameIds(uint256 _from, uint256 _to) public view returns (address[] memory) {
		require (_from >= 0 && _to >= _from);
		require (names.length > 0);

		address[] memory _names = new address[](_to.sub(_from).add(1));
		if (_to > names.length.sub(1)) {
			_to = names.length.sub(1);
		}
		for (uint256 i = _from; i <= _to; i++) {
			_names[i.sub(_from)] = names[i];
		}
		return _names;
	}

	/**
	 * @dev Check whether or not the signature is valid
	 * @param _data The signed string data
	 * @param _nonce The signed uint256 nonce (should be Name's current nonce + 1)
	 * @param _validateAddress The ETH address to be validated (optional)
	 * @param _name The name of the Name
	 * @param _signatureV The V part of the signature
	 * @param _signatureR The R part of the signature
	 * @param _signatureS The S part of the signature
	 * @return true if valid. false otherwise
	 */
	function validateNameSignature(
		string memory _data,
		uint256 _nonce,
		address _validateAddress,
		string memory _name,
		uint8 _signatureV,
		bytes32 _signatureR,
		bytes32 _signatureS
	) public view returns (bool) {
		require (_nameTAOLookup.isExist(_name));
		address _nameId = _nameTAOLookup.getIdByName(_name);
		require (_nameId != address(0));
		address _signatureAddress = _getValidateSignatureAddress(_data, _nonce, _signatureV, _signatureR, _signatureS);
		if (_validateAddress != address(0)) {
			return (
				_nonce == _nonces[_nameId].add(1) &&
				_signatureAddress == _validateAddress &&
				_namePublicKey.isKeyExist(_nameId, _validateAddress)
			);
		} else {
			return (
				_nonce == _nonces[_nameId].add(1) &&
				_signatureAddress == _namePublicKey.getDefaultKey(_nameId)
			);
		}
	}

	/***** INTERNAL METHODS *****/
	/**
	 * @dev Return the address that signed the data and nonce when validating signature
	 * @param _data the data that was signed
	 * @param _nonce The signed uint256 nonce
	 * @param _v part of the signature
	 * @param _r part of the signature
	 * @param _s part of the signature
	 * @return the address that signed the message
	 */
	function _getValidateSignatureAddress(string memory _data, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s) internal view returns (address) {
		bytes32 _hash = keccak256(abi.encodePacked(address(this), _data, _nonce));
		return ecrecover(_hash, _v, _r, _s);
	}

	/**
	 * @dev Reward primordial contributor Name with pathos/ethos
	 */
	function _rewardContributor(address _nameId) internal {
		if (settingTAOId != address(0)) {
			(,,,, string memory primordialContributorName) = _aoSetting.getSettingValuesByTAOName(settingTAOId, 'primordialContributorName');
			(uint256 primordialContributorPathos,,,,) = _aoSetting.getSettingValuesByTAOName(settingTAOId, 'primordialContributorPathos');
			(uint256 primordialContributorEthos,,,,) = _aoSetting.getSettingValuesByTAOName(settingTAOId, 'primordialContributorEthos');
			(uint256 primordialContributorEarning,,,,) = _aoSetting.getSettingValuesByTAOName(settingTAOId, 'primordialContributorEarning');
			address _primordialContributorNameId = _nameTAOLookup.getIdByName(primordialContributorName);
			if (_primordialContributorNameId == _nameId) {
				_pathos.mint(_nameId, primordialContributorPathos);
				_ethos.mint(_nameId, primordialContributorEthos);
			} else if (_primordialContributorNameId != address(0)) {
				_pathos.mint(_primordialContributorNameId, primordialContributorEarning);
				_ethos.mint(_primordialContributorNameId, primordialContributorEarning);
				emit RewardContributor(_nameId, primordialContributorEarning, primordialContributorEarning);
			}
		}
	}
}