pragma solidity >=0.5.4 <0.6.0;

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


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }





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


interface INameAccountRecovery {
	function isCompromised(address _id) external view returns (bool);
}


interface INameFactory {
	function nonces(address _nameId) external view returns (uint256);
	function incrementNonce(address _nameId) external returns (uint256);
	function ethAddressToNameId(address _ethAddress) external view returns (address);
	function setNameNewAddress(address _id, address _newAddress) external returns (bool);
	function nameIdToEthAddress(address _nameId) external view returns (address);
}


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


interface ITAOFactory {
	function nonces(address _taoId) external view returns (uint256);
	function incrementNonce(address _taoId) external returns (uint256);
}


interface ITAOPool {
	function createPool(address _taoId, bool _ethosCapStatus, uint256 _ethosCapAmount) external returns (bool);
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
 * @title TAOController
 */
contract TAOController is TheAO {
	address public nameFactoryAddress;
	address public nameAccountRecoveryAddress;

	INameFactory internal _nameFactory;
	INameTAOPosition internal _nameTAOPosition;
	INameAccountRecovery internal _nameAccountRecovery;

	/**
	 * @dev Constructor function
	 */
	constructor(address _nameFactoryAddress) public {
		setNameFactoryAddress(_nameFactoryAddress);
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

	/**
	 * @dev Check if `_id` is a Name or a TAO
	 */
	modifier isNameOrTAO(address _id) {
		require (AOLibrary.isName(_id) || AOLibrary.isTAO(_id));
		_;
	}

	/**
	 * @dev Check is msg.sender address is a Name
	 */
	 modifier senderIsName() {
		require (_nameFactory.ethAddressToNameId(msg.sender) != address(0));
		_;
	 }

	/**
	 * @dev Check if msg.sender is the current advocate of TAO ID
	 */
	modifier onlyAdvocate(address _id) {
		require (_nameTAOPosition.senderIsAdvocate(msg.sender, _id));
		_;
	}

	/**
	 * @dev Only allowed if sender's Name is not compromised
	 */
	modifier senderNameNotCompromised() {
		require (!_nameAccountRecovery.isCompromised(_nameFactory.ethAddressToNameId(msg.sender)));
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
	 * @dev The AO sets NameFactory address
	 * @param _nameFactoryAddress The address of NameFactory
	 */
	function setNameFactoryAddress(address _nameFactoryAddress) public onlyTheAO {
		require (_nameFactoryAddress != address(0));
		nameFactoryAddress = _nameFactoryAddress;
		_nameFactory = INameFactory(_nameFactoryAddress);
	}

	/**
	 * @dev The AO sets NameTAOPosition address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 */
	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
		_nameTAOPosition = INameTAOPosition(_nameTAOPositionAddress);
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








contract Logos is TAOCurrency {
	address public nameFactoryAddress;
	address public nameAccountRecoveryAddress;

	INameFactory internal _nameFactory;
	INameTAOPosition internal _nameTAOPosition;
	INameAccountRecovery internal _nameAccountRecovery;

	// Mapping of a Name ID to the amount of Logos positioned by others to itself
	// address is the address of nameId, not the eth public address
	mapping (address => uint256) public positionFromOthers;

	// Mapping of Name ID to other Name ID and the amount of Logos positioned by itself
	mapping (address => mapping(address => uint256)) public positionOnOthers;

	// Mapping of a Name ID to the total amount of Logos positioned by itself on others
	mapping (address => uint256) public totalPositionOnOthers;

	// Mapping of Name ID to it's advocated TAO ID and the amount of Logos earned
	mapping (address => mapping(address => uint256)) public advocatedTAOLogos;

	// Mapping of a Name ID to the total amount of Logos earned from advocated TAO
	mapping (address => uint256) public totalAdvocatedTAOLogos;

	// Event broadcasted to public when `from` address position `value` Logos to `to`
	event PositionFrom(address indexed from, address indexed to, uint256 value);

	// Event broadcasted to public when `from` address unposition `value` Logos from `to`
	event UnpositionFrom(address indexed from, address indexed to, uint256 value);

	// Event broadcasted to public when `nameId` receives `amount` of Logos from advocating `taoId`
	event AddAdvocatedTAOLogos(address indexed nameId, address indexed taoId, uint256 amount);

	// Event broadcasted to public when Logos from advocating `taoId` is transferred from `fromNameId` to `toNameId`
	event TransferAdvocatedTAOLogos(address indexed fromNameId, address indexed toNameId, address indexed taoId, uint256 amount);

	/**
	 * @dev Constructor function
	 */
	constructor(string memory _name, string memory _symbol, address _nameFactoryAddress, address _nameTAOPositionAddress)
		TAOCurrency(_name, _symbol, _nameTAOPositionAddress) public {
		setNameFactoryAddress(_nameFactoryAddress);
		setNameTAOPositionAddress(_nameTAOPositionAddress);
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

	/**
	 * @dev Check if msg.sender is the current advocate of _id
	 */
	modifier onlyAdvocate(address _id) {
		require (_nameTAOPosition.senderIsAdvocate(msg.sender, _id));
		_;
	}

	/**
	 * @dev Only allowed if Name is not compromised
	 */
	modifier nameNotCompromised(address _id) {
		require (!_nameAccountRecovery.isCompromised(_id));
		_;
	}

	/**
	 * @dev Only allowed if sender's Name is not compromised
	 */
	modifier senderNameNotCompromised() {
		require (!_nameAccountRecovery.isCompromised(_nameFactory.ethAddressToNameId(msg.sender)));
		_;
	}

	/***** THE AO ONLY METHODS *****/
	/**
	 * @dev The AO sets NameFactory address
	 * @param _nameFactoryAddress The address of NameFactory
	 */
	function setNameFactoryAddress(address _nameFactoryAddress) public onlyTheAO {
		require (_nameFactoryAddress != address(0));
		nameFactoryAddress = _nameFactoryAddress;
		_nameFactory = INameFactory(_nameFactoryAddress);
	}

	/**
	 * @dev The AO set the NameTAOPosition Address
	 * @param _nameTAOPositionAddress The address of NameTAOPosition
	 */
	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
		_nameTAOPosition = INameTAOPosition(_nameTAOPositionAddress);
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

	/***** PUBLIC METHODS *****/
	/**
	 * @dev Get the total sum of Logos for an address
	 * @param _target The address to check
	 * @return The total sum of Logos (own + positioned + advocated TAOs)
	 */
	function sumBalanceOf(address _target) public isName(_target) view returns (uint256) {
		return balanceOf[_target].add(positionFromOthers[_target]).add(totalAdvocatedTAOLogos[_target]);
	}

	/**
	 * @dev Return the amount of Logos that are available to be positioned on other
	 * @param _sender The sender address to check
	 * @return The amount of Logos that are available to be positioned on other
	 */
	function availableToPositionAmount(address _sender) public isName(_sender) view returns (uint256) {
		return balanceOf[_sender].sub(totalPositionOnOthers[_sender]);
	}

	/**
	 * @dev `_from` Name position `_value` Logos onto `_to` Name
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to position
	 * @return true on success
	 */
	function positionFrom(address _from, address _to, uint256 _value) public isName(_from) isName(_to) nameNotCompromised(_from) nameNotCompromised(_to) onlyAdvocate(_from) senderNameNotCompromised returns (bool) {
		require (_from != _to);	// Can't position Logos to itself
		require (availableToPositionAmount(_from) >= _value); // should have enough balance to position
		require (positionFromOthers[_to].add(_value) >= positionFromOthers[_to]); // check for overflows

		positionOnOthers[_from][_to] = positionOnOthers[_from][_to].add(_value);
		totalPositionOnOthers[_from] = totalPositionOnOthers[_from].add(_value);
		positionFromOthers[_to] = positionFromOthers[_to].add(_value);

		emit PositionFrom(_from, _to, _value);
		return true;
	}

	/**
	 * @dev `_from` Name unposition `_value` Logos from `_to` Name
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to unposition
	 * @return true on success
	 */
	function unpositionFrom(address _from, address _to, uint256 _value) public isName(_from) isName(_to) nameNotCompromised(_from) nameNotCompromised(_to) onlyAdvocate(_from) senderNameNotCompromised returns (bool) {
		require (_from != _to);	// Can't unposition Logos to itself
		require (positionOnOthers[_from][_to] >= _value);

		positionOnOthers[_from][_to] = positionOnOthers[_from][_to].sub(_value);
		totalPositionOnOthers[_from] = totalPositionOnOthers[_from].sub(_value);
		positionFromOthers[_to] = positionFromOthers[_to].sub(_value);

		emit UnpositionFrom(_from, _to, _value);
		return true;
	}

	/**
	 * @dev Add `_amount` logos earned from advocating a TAO `_taoId` to its Advocate
	 * @param _taoId The ID of the advocated TAO
	 * @param _amount the amount to reward
	 * @return true on success
	 */
	function addAdvocatedTAOLogos(address _taoId, uint256 _amount) public inWhitelist isTAO(_taoId) returns (bool) {
		require (_amount > 0);
		address _nameId = _nameTAOPosition.getAdvocate(_taoId);

		advocatedTAOLogos[_nameId][_taoId] = advocatedTAOLogos[_nameId][_taoId].add(_amount);
		totalAdvocatedTAOLogos[_nameId] = totalAdvocatedTAOLogos[_nameId].add(_amount);

		emit AddAdvocatedTAOLogos(_nameId, _taoId, _amount);
		return true;
	}

	/**
	 * @dev Transfer logos earned from advocating a TAO `_taoId` from `_fromNameId` to the Advocate of `_taoId`
	 * @param _fromNameId The ID of the Name that sends the Logos
	 * @param _taoId The ID of the advocated TAO
	 * @return true on success
	 */
	function transferAdvocatedTAOLogos(address _fromNameId, address _taoId) public inWhitelist isName(_fromNameId) isTAO(_taoId) returns (bool) {
		address _toNameId = _nameTAOPosition.getAdvocate(_taoId);
		require (_fromNameId != _toNameId);
		require (totalAdvocatedTAOLogos[_fromNameId] >= advocatedTAOLogos[_fromNameId][_taoId]);

		uint256 _amount = advocatedTAOLogos[_fromNameId][_taoId];
		advocatedTAOLogos[_fromNameId][_taoId] = 0;
		totalAdvocatedTAOLogos[_fromNameId] = totalAdvocatedTAOLogos[_fromNameId].sub(_amount);
		advocatedTAOLogos[_toNameId][_taoId] = advocatedTAOLogos[_toNameId][_taoId].add(_amount);
		totalAdvocatedTAOLogos[_toNameId] = totalAdvocatedTAOLogos[_toNameId].add(_amount);

		emit TransferAdvocatedTAOLogos(_fromNameId, _toNameId, _taoId, _amount);
		return true;
	}
}



/**
 * @title TAOPool
 *
 * This contract acts as the bookkeeper of TAO Currencies that are staked on TAO
 */
contract TAOPool is TAOController, ITAOPool {
	using SafeMath for uint256;

	address public taoFactoryAddress;
	address public pathosAddress;
	address public ethosAddress;
	address public logosAddress;

	ITAOFactory internal _taoFactory;
	TAOCurrency internal _pathos;
	TAOCurrency internal _ethos;
	Logos internal _logos;

	struct Pool {
		address taoId;
		/**
		 * If true, has ethos cap. Otherwise, no ethos cap.
		 */
		bool ethosCapStatus;
		uint256 ethosCapAmount;	// Creates a cap for the amount of Ethos that can be staked into this pool

		/**
		 * If true, Pool is live and can be staked into.
		 */
		bool status;
	}

	struct EthosLot {
		bytes32 ethosLotId;					// The ID of this Lot
		address nameId;						// The ID of the Name that staked Ethos
		uint256 lotQuantity;				// Amount of Ethos being staked to the Pool from this Lot
		address taoId;						// Identifier for the Pool this Lot is adding to
		uint256 poolPreStakeSnapshot;		// Amount of Ethos contributed to the Pool prior to this Lot Number
		uint256 poolStakeLotSnapshot;		// poolPreStakeSnapshot + lotQuantity
		uint256 lotValueInLogos;
		uint256 logosWithdrawn;				// Amount of Logos withdrawn from this Lot
		uint256 timestamp;
	}

	uint256 public contractTotalEthosLot;		// Total Ethos lot from all pools
	uint256 public contractTotalPathosStake;	// Total Pathos stake from all pools (how many Pathos stakes are there in contract)
	uint256 public contractTotalEthos;			// Quantity of Ethos that has been staked to all Pools
	uint256 public contractTotalPathos;			// Quantity of Pathos that has been staked to all Pools
	uint256 public contractTotalLogosWithdrawn;		// Quantity of Logos that has been withdrawn from all Pools

	// Mapping from TAO ID to Pool
	mapping (address => Pool) public pools;

	// Mapping from Ethos Lot ID to Ethos Lot
	mapping (bytes32 => EthosLot) public ethosLots;

	// Mapping from Pool's TAO ID to total Ethos Lots in the Pool
	mapping (address => uint256) public poolTotalEthosLot;

	// Mapping from Pool's TAO ID to quantity of Logos that has been withdrawn from the Pool
	mapping (address => uint256) public poolTotalLogosWithdrawn;

	// Mapping from a Name ID to its Ethos Lots
	mapping (address => bytes32[]) internal ownerEthosLots;

	// Mapping from a Name ID to quantity of Ethos staked from all Ethos lots
	mapping (address => uint256) public totalEthosStaked;

	// Mapping from a Name ID to quantity of Pathos staked from all Ethos lots
	mapping (address => uint256) public totalPathosStaked;

	// Mapping from a Name ID to total Logos withdrawn from all Ethos lots
	mapping (address => uint256) public totalLogosWithdrawn;

	// Mapping from a Name ID to quantity of Ethos staked from all Ethos lots on a Pool
	mapping (address => mapping (address => uint256)) public namePoolEthosStaked;

	// Mapping from a Name ID to quantity of Pathos staked on a Pool
	mapping (address => mapping (address => uint256)) public namePoolPathosStaked;

	// Mapping from a Name ID to quantity of Logos withdrawn from a Pool
	mapping (address => mapping (address => uint256)) public namePoolLogosWithdrawn;

	// Event to be broadcasted to public when Pool is created
	event CreatePool(address indexed taoId, bool ethosCapStatus, uint256 ethosCapAmount, bool status);

	// Event to be broadcasted to public when Pool's status is updated
	// If status == true, start Pool
	// Otherwise, stop Pool
	event UpdatePoolStatus(address indexed taoId, bool status, uint256 nonce);

	// Event to be broadcasted to public when Pool's Ethos cap is updated
	event UpdatePoolEthosCap(address indexed taoId, bool ethosCapStatus, uint256 ethosCapAmount, uint256 nonce);

	/**
	 * Event to be broadcasted to public when nameId stakes Ethos
	 */
	event StakeEthos(address indexed taoId, bytes32 indexed ethosLotId, address indexed nameId, uint256 lotQuantity, uint256 poolPreStakeSnapshot, uint256 poolStakeLotSnapshot, uint256 lotValueInLogos, uint256 timestamp);

	// Event to be broadcasted to public when nameId stakes Pathos
	event StakePathos(address indexed taoId, bytes32 indexed stakeId, address indexed nameId, uint256 stakeQuantity, uint256 currentPoolTotalStakedPathos, uint256 timestamp);

	// Event to be broadcasted to public when nameId withdraws Logos from Ethos Lot
	event WithdrawLogos(address indexed nameId, bytes32 indexed ethosLotId, address indexed taoId, uint256 withdrawnAmount, uint256 currentLotValueInLogos, uint256 currentLotLogosWithdrawn, uint256 timestamp);

	/**
	 * @dev Constructor function
	 */
	constructor(address _nameFactoryAddress, address _taoFactoryAddress, address _nameTAOPositionAddress, address _pathosAddress, address _ethosAddress, address _logosAddress)
		TAOController(_nameFactoryAddress) public {
		setTAOFactoryAddress(_taoFactoryAddress);
		setNameTAOPositionAddress(_nameTAOPositionAddress);
		setPathosAddress(_pathosAddress);
		setEthosAddress(_ethosAddress);
		setLogosAddress(_logosAddress);
	}

	/**
	 * @dev Check if calling address is TAO Factory address
	 */
	modifier onlyTAOFactory {
		require (msg.sender == taoFactoryAddress);
		_;
	}

	/***** The AO ONLY METHODS *****/
	/**
	 * @dev The AO set the TAOFactory Address
	 * @param _taoFactoryAddress The address of TAOFactory
	 */
	function setTAOFactoryAddress(address _taoFactoryAddress) public onlyTheAO {
		require (_taoFactoryAddress != address(0));
		taoFactoryAddress = _taoFactoryAddress;
		_taoFactory = ITAOFactory(_taoFactoryAddress);
	}

	/**
	 * @dev The AO set the Pathos Address
	 * @param _pathosAddress The address of Pathos
	 */
	function setPathosAddress(address _pathosAddress) public onlyTheAO {
		require (_pathosAddress != address(0));
		pathosAddress = _pathosAddress;
		_pathos = TAOCurrency(_pathosAddress);
	}

	/**
	 * @dev The AO set the Ethos Address
	 * @param _ethosAddress The address of Ethos
	 */
	function setEthosAddress(address _ethosAddress) public onlyTheAO {
		require (_ethosAddress != address(0));
		ethosAddress = _ethosAddress;
		_ethos = TAOCurrency(_ethosAddress);
	}

	/**
	 * @dev The AO set the Logos Address
	 * @param _logosAddress The address of Logos
	 */
	function setLogosAddress(address _logosAddress) public onlyTheAO {
		require (_logosAddress != address(0));
		logosAddress = _logosAddress;
		_logos = Logos(_logosAddress);
	}

	/***** PUBLIC METHODS *****/
	/**
	 * @dev Check whether or not Pool exist for a TAO ID
	 * @param _id The ID to be checked
	 * @return true if yes, false otherwise
	 */
	function isExist(address _id) public view returns (bool) {
		return pools[_id].taoId != address(0);
	}

	/**
	 * @dev Create a pool for a TAO
	 */
	function createPool(
		address _taoId,
		bool _ethosCapStatus,
		uint256 _ethosCapAmount
	) external isTAO(_taoId) onlyTAOFactory returns (bool) {
		// Make sure ethos cap amount is provided if ethos cap is enabled
		if (_ethosCapStatus) {
			require (_ethosCapAmount > 0);
		}
		// Make sure the pool is not yet created
		require (pools[_taoId].taoId == address(0));

		Pool storage _pool = pools[_taoId];
		_pool.taoId = _taoId;
		_pool.status = true;
		_pool.ethosCapStatus = _ethosCapStatus;
		if (_ethosCapStatus) {
			_pool.ethosCapAmount = _ethosCapAmount;
		}

		emit CreatePool(_pool.taoId, _pool.ethosCapStatus, _pool.ethosCapAmount, _pool.status);
		return true;
	}

	/**
	 * @dev Start/Stop a Pool
	 * @param _taoId The TAO ID of the Pool
	 * @param _status The status to set. true = start. false = stop
	 */
	function updatePoolStatus(address _taoId, bool _status) public isTAO(_taoId) onlyAdvocate(_taoId) senderNameNotCompromised {
		require (pools[_taoId].taoId != address(0));
		pools[_taoId].status = _status;

		uint256 _nonce = _taoFactory.incrementNonce(_taoId);
		require (_nonce > 0);

		emit UpdatePoolStatus(_taoId, _status, _nonce);
	}

	/**
	 * @dev Update Ethos cap of a Pool
	 * @param _taoId The TAO ID of the Pool
	 * @param _ethosCapStatus The ethos cap status to set
	 * @param _ethosCapAmount The ethos cap amount to set
	 */
	function updatePoolEthosCap(address _taoId, bool _ethosCapStatus, uint256 _ethosCapAmount) public isTAO(_taoId) onlyAdvocate(_taoId) senderNameNotCompromised {
		require (pools[_taoId].taoId != address(0));
		// If there is an ethos cap
		if (_ethosCapStatus) {
			require (_ethosCapAmount > 0 && _ethosCapAmount > _pathos.balanceOf(_taoId));
		}

		pools[_taoId].ethosCapStatus = _ethosCapStatus;
		if (_ethosCapStatus) {
			pools[_taoId].ethosCapAmount = _ethosCapAmount;
		}

		uint256 _nonce = _taoFactory.incrementNonce(_taoId);
		require (_nonce > 0);

		emit UpdatePoolEthosCap(_taoId, _ethosCapStatus, _ethosCapAmount, _nonce);
	}

	/**
	 * @dev A Name stakes Ethos in Pool `_taoId`
	 * @param _taoId The TAO ID of the Pool
	 * @param _quantity The amount of Ethos to be staked
	 */
	function stakeEthos(address _taoId, uint256 _quantity) public isTAO(_taoId) senderIsName senderNameNotCompromised {
		Pool memory _pool = pools[_taoId];
		address _nameId = _nameFactory.ethAddressToNameId(msg.sender);
		require (_pool.status == true && _quantity > 0 && _ethos.balanceOf(_nameId) >= _quantity);

		// If there is an ethos cap
		if (_pool.ethosCapStatus) {
			require (_ethos.balanceOf(_taoId).add(_quantity) <= _pool.ethosCapAmount);
		}

		// Create Ethos Lot for this transaction
		contractTotalEthosLot++;
		poolTotalEthosLot[_taoId]++;

		// Generate Ethos Lot ID
		bytes32 _ethosLotId = keccak256(abi.encodePacked(this, msg.sender, contractTotalEthosLot));

		EthosLot storage _ethosLot = ethosLots[_ethosLotId];
		_ethosLot.ethosLotId = _ethosLotId;
		_ethosLot.nameId = _nameId;
		_ethosLot.lotQuantity = _quantity;
		_ethosLot.taoId = _taoId;
		_ethosLot.poolPreStakeSnapshot = _ethos.balanceOf(_taoId);
		_ethosLot.poolStakeLotSnapshot = _ethos.balanceOf(_taoId).add(_quantity);
		_ethosLot.lotValueInLogos = _quantity;
		_ethosLot.timestamp = now;

		ownerEthosLots[_nameId].push(_ethosLotId);

		// Update contract variables
		totalEthosStaked[_nameId] = totalEthosStaked[_nameId].add(_quantity);
		namePoolEthosStaked[_nameId][_taoId] = namePoolEthosStaked[_nameId][_taoId].add(_quantity);
		contractTotalEthos = contractTotalEthos.add(_quantity);

		require (_ethos.transferFrom(_nameId, _taoId, _quantity));

		emit StakeEthos(_ethosLot.taoId, _ethosLot.ethosLotId, _ethosLot.nameId, _ethosLot.lotQuantity, _ethosLot.poolPreStakeSnapshot, _ethosLot.poolStakeLotSnapshot, _ethosLot.lotValueInLogos, _ethosLot.timestamp);
	}

	/**
	 * @dev Retrieve number of Ethos Lots a `_nameId` has
	 * @param _nameId The Name ID of the Ethos Lot's owner
	 * @return Total Ethos Lots the owner has
	 */
	function ownerTotalEthosLot(address _nameId) public view returns (uint256) {
		return ownerEthosLots[_nameId].length;
	}

	/**
	 * @dev Get list of owner's Ethos Lot IDs from `_from` to `_to` index
	 * @param _nameId The Name Id of the Ethos Lot's owner
	 * @param _from The starting index, (i.e 0)
	 * @param _to The ending index, (i.e total - 1)
	 * @return list of owner's Ethos Lot IDs
	 */
	function ownerEthosLotIds(address _nameId, uint256 _from, uint256 _to) public view returns (bytes32[] memory) {
		require (_from >= 0 && _to >= _from && ownerEthosLots[_nameId].length > _to);
		bytes32[] memory _ethosLotIds = new bytes32[](_to.sub(_from).add(1));
		for (uint256 i = _from; i <= _to; i++) {
			_ethosLotIds[i.sub(_from)] = ownerEthosLots[_nameId][i];
		}
		return _ethosLotIds;
	}

	/**
	 * @dev Return the amount of Pathos that can be staked on Pool
	 * @param _taoId The TAO ID of the Pool
	 * @return The amount of Pathos that can be staked
	 */
	function availablePathosToStake(address _taoId) public isTAO(_taoId) view returns (uint256) {
		if (pools[_taoId].status == true) {
			return _ethos.balanceOf(_taoId).sub(_pathos.balanceOf(_taoId));
		} else {
			return 0;
		}
	}

	/**
	 * @dev A Name stakes Pathos in Pool `_taoId`
	 * @param _taoId The TAO ID of the Pool
	 * @param _quantity The amount of Pathos to stake
	 */
	function stakePathos(address _taoId, uint256 _quantity) public isTAO(_taoId) senderIsName senderNameNotCompromised {
		Pool memory _pool = pools[_taoId];
		address _nameId = _nameFactory.ethAddressToNameId(msg.sender);
		require (_pool.status == true && _quantity > 0 && _pathos.balanceOf(_nameId) >= _quantity && _quantity <= availablePathosToStake(_taoId));

		// Update contract variables
		contractTotalPathosStake++;
		totalPathosStaked[_nameId] = totalPathosStaked[_nameId].add(_quantity);
		namePoolPathosStaked[_nameId][_taoId] = namePoolPathosStaked[_nameId][_taoId].add(_quantity);
		contractTotalPathos = contractTotalPathos.add(_quantity);

		// Generate Pathos Stake ID
		bytes32 _stakeId = keccak256(abi.encodePacked(this, msg.sender, contractTotalPathosStake));

		require (_pathos.transferFrom(_nameId, _taoId, _quantity));

		// Also add advocated TAO logos to Advocate of _taoId
		require (_logos.addAdvocatedTAOLogos(_taoId, _quantity));

		emit StakePathos(_taoId, _stakeId, _nameId, _quantity, _pathos.balanceOf(_taoId), now);
	}

	/**
	 * @dev Name that staked Ethos withdraw Logos from Ethos Lot `_ethosLotId`
	 * @param _ethosLotId The ID of the Ethos Lot
	 */
	function withdrawLogos(bytes32 _ethosLotId) public senderIsName senderNameNotCompromised {
		EthosLot storage _ethosLot = ethosLots[_ethosLotId];
		address _nameId = _nameFactory.ethAddressToNameId(msg.sender);
		require (_ethosLot.nameId == _nameId && _ethosLot.lotValueInLogos > 0);

		uint256 logosAvailableToWithdraw = lotLogosAvailableToWithdraw(_ethosLotId);

		require (logosAvailableToWithdraw > 0 && logosAvailableToWithdraw <= _ethosLot.lotValueInLogos);

		// Update lot variables
		_ethosLot.logosWithdrawn = _ethosLot.logosWithdrawn.add(logosAvailableToWithdraw);
		_ethosLot.lotValueInLogos = _ethosLot.lotValueInLogos.sub(logosAvailableToWithdraw);

		// Update contract variables
		contractTotalLogosWithdrawn = contractTotalLogosWithdrawn.add(logosAvailableToWithdraw);
		poolTotalLogosWithdrawn[_ethosLot.taoId] = poolTotalLogosWithdrawn[_ethosLot.taoId].add(logosAvailableToWithdraw);
		totalLogosWithdrawn[_ethosLot.nameId] = totalLogosWithdrawn[_ethosLot.nameId].add(logosAvailableToWithdraw);
		namePoolLogosWithdrawn[_ethosLot.nameId][_ethosLot.taoId] = namePoolLogosWithdrawn[_ethosLot.nameId][_ethosLot.taoId].add(logosAvailableToWithdraw);

		// Mint logos to seller
		require (_logos.mint(_nameId, logosAvailableToWithdraw));

		emit WithdrawLogos(_ethosLot.nameId, _ethosLot.ethosLotId, _ethosLot.taoId, logosAvailableToWithdraw, _ethosLot.lotValueInLogos, _ethosLot.logosWithdrawn, now);
	}

	/**
	 * @dev Name gets Ethos Lot `_ethosLotId` available Logos to withdraw
	 * @param _ethosLotId The ID of the Ethos Lot
	 * @return The amount of Logos available to withdraw
	 */
	function lotLogosAvailableToWithdraw(bytes32 _ethosLotId) public view returns (uint256) {
		EthosLot memory _ethosLot = ethosLots[_ethosLotId];
		require (_ethosLot.nameId != address(0));

		uint256 logosAvailableToWithdraw = 0;

		if (_pathos.balanceOf(_ethosLot.taoId) > _ethosLot.poolPreStakeSnapshot && _ethosLot.lotValueInLogos > 0) {
			logosAvailableToWithdraw = (_pathos.balanceOf(_ethosLot.taoId) >= _ethosLot.poolStakeLotSnapshot) ? _ethosLot.lotQuantity : _pathos.balanceOf(_ethosLot.taoId).sub(_ethosLot.poolPreStakeSnapshot);
			if (logosAvailableToWithdraw > 0) {
				logosAvailableToWithdraw = logosAvailableToWithdraw.sub(_ethosLot.logosWithdrawn);
			}
		}
		return logosAvailableToWithdraw;
	}
}