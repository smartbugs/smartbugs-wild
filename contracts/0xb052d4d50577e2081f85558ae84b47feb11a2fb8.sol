pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }


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


interface IAOIonLot {
	function createPrimordialLot(address _account, uint256 _primordialAmount, uint256 _multiplier, uint256 _networkBonusAmount) external returns (bytes32);

	function createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier) external returns (bytes32);

	function lotById(bytes32 _lotId) external view returns (bytes32, address, uint256, uint256);

	function totalLotsByAddress(address _lotOwner) external view returns (uint256);

	function createBurnLot(address _account, uint256 _amount, uint256 _multiplierAfterBurn) external returns (bool);

	function createConvertLot(address _account, uint256 _amount, uint256 _multiplierAfterConversion) external returns (bool);
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
 * @title AOIonLot
 */
contract AOIonLot is TheAO {
	using SafeMath for uint256;

	address public aoIonAddress;

	uint256 public totalLots;
	uint256 public totalBurnLots;
	uint256 public totalConvertLots;

	/**
	 * Stores Lot creation data (during network exchange)
	 */
	struct Lot {
		bytes32 lotId;
		uint256 multiplier;	// This value is in 10^6, so 1000000 = 1
		address lotOwner;
		uint256 amount;
	}

	/**
	 * Struct to store info when account burns primordial ion
	 */
	struct BurnLot {
		bytes32 burnLotId;
		address lotOwner;
		uint256 amount;
	}

	/**
	 * Struct to store info when account converts network ion to primordial ion
	 */
	struct ConvertLot {
		bytes32 convertLotId;
		address lotOwner;
		uint256 amount;
	}

	// Mapping from Lot ID to Lot object
	mapping (bytes32 => Lot) internal lots;

	// Mapping from Burn Lot ID to BurnLot object
	mapping (bytes32 => BurnLot) internal burnLots;

	// Mapping from Convert Lot ID to ConvertLot object
	mapping (bytes32 => ConvertLot) internal convertLots;

	// Mapping from owner to list of owned lot IDs
	mapping (address => bytes32[]) internal ownedLots;

	// Mapping from owner to list of owned burn lot IDs
	mapping (address => bytes32[]) internal ownedBurnLots;

	// Mapping from owner to list of owned convert lot IDs
	mapping (address => bytes32[]) internal ownedConvertLots;

	// Event to be broadcasted to public when a lot is created
	// multiplier value is in 10^6 to account for 6 decimal points
	event LotCreation(address indexed lotOwner, bytes32 indexed lotId, uint256 multiplier, uint256 primordialAmount, uint256 networkBonusAmount);

	// Event to be broadcasted to public when burn lot is created (when account burns primordial ions)
	event BurnLotCreation(address indexed lotOwner, bytes32 indexed burnLotId, uint256 burnAmount, uint256 multiplierAfterBurn);

	// Event to be broadcasted to public when convert lot is created (when account convert network ions to primordial ions)
	event ConvertLotCreation(address indexed lotOwner, bytes32 indexed convertLotId, uint256 convertAmount, uint256 multiplierAfterConversion);

	/**
	 * @dev Constructor function
	 */
	constructor(address _aoIonAddress, address _nameTAOPositionAddress) public {
		setAOIonAddress(_aoIonAddress);
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
	 * @dev Check if calling address is AOIon
	 */
	modifier onlyAOIon {
		require (msg.sender == aoIonAddress);
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
	 * @dev The AO set the AOIon Address
	 * @param _aoIonAddress The address of AOIon
	 */
	function setAOIonAddress(address _aoIonAddress) public onlyTheAO {
		require (_aoIonAddress != address(0));
		aoIonAddress = _aoIonAddress;
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
	 * @dev Create a lot with `primordialAmount` of primordial ions with `_multiplier` for an `account`
	 *		during network exchange, and reward `_networkBonusAmount` if exist
	 * @param _account Address of the lot owner
	 * @param _primordialAmount The amount of primordial ions to be stored in the lot
	 * @param _multiplier The multiplier for this lot in (10 ** 6)
	 * @param _networkBonusAmount The network ion bonus amount
	 * @return Created lot Id
	 */
	function createPrimordialLot(address _account, uint256 _primordialAmount, uint256 _multiplier, uint256 _networkBonusAmount) external onlyAOIon returns (bytes32) {
		return _createWeightedMultiplierLot(_account, _primordialAmount, _multiplier, _networkBonusAmount);
	}

	/**
	 * @dev Create a lot with `amount` of ions at `weightedMultiplier` for an `account`
	 * @param _account Address of lot owner
	 * @param _amount The amount of ions
	 * @param _weightedMultiplier The multiplier of the lot (in 10^6)
	 * @return bytes32 of new created lot ID
	 */
	function createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier) external onlyAOIon returns (bytes32) {
		require (_account != address(0));
		require (_amount > 0);
		return _createWeightedMultiplierLot(_account, _amount, _weightedMultiplier, 0);
	}

	/**
	 * @dev Return the lot information at a given ID
	 * @param _lotId The lot ID in question
	 * @return id of the lot
	 * @return The lot owner address
	 * @return multiplier of the lot in (10 ** 6)
	 * @return Primordial ion amount in the lot
	 */
	function lotById(bytes32 _lotId) external view returns (bytes32, address, uint256, uint256) {
		Lot memory _lot = lots[_lotId];
		return (_lot.lotId, _lot.lotOwner, _lot.multiplier, _lot.amount);
	}

	/**
	 * @dev Return all lot IDs owned by an address
	 * @param _lotOwner The address of the lot owner
	 * @return array of lot IDs
	 */
	function lotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {
		return ownedLots[_lotOwner];
	}

	/**
	 * @dev Return the total lots owned by an address
	 * @param _lotOwner The address of the lot owner
	 * @return total lots owner by the address
	 */
	function totalLotsByAddress(address _lotOwner) external view returns (uint256) {
		return ownedLots[_lotOwner].length;
	}

	/**
	 * @dev Return the lot information at a given index of the lots list of the requested owner
	 * @param _lotOwner The address owning the lots list to be accessed
	 * @param _index uint256 representing the index to be accessed of the requested lots list
	 * @return id of the lot
	 * @return The address of the lot owner
	 * @return multiplier of the lot in (10 ** 6)
	 * @return Primordial ion amount in the lot
	 */
	function lotOfOwnerByIndex(address _lotOwner, uint256 _index) public view returns (bytes32, address, uint256, uint256) {
		require (_index < ownedLots[_lotOwner].length);
		Lot memory _lot = lots[ownedLots[_lotOwner][_index]];
		return (_lot.lotId, _lot.lotOwner, _lot.multiplier, _lot.amount);
	}

	/**
	 * @dev Store burn lot information
	 * @param _account The address of the account
	 * @param _amount The amount of primordial ions to burn
	 * @param _multiplierAfterBurn The owner's weighted multiplier after burn
	 * @return true on success
	 */
	function createBurnLot(address _account, uint256 _amount, uint256 _multiplierAfterBurn) external onlyAOIon returns (bool) {
		totalBurnLots++;

		// Generate burn lot Id
		bytes32 burnLotId = keccak256(abi.encodePacked(this, _account, totalBurnLots));

		// Make sure no one owns this lot yet
		require (burnLots[burnLotId].lotOwner == address(0));

		BurnLot storage burnLot = burnLots[burnLotId];
		burnLot.burnLotId = burnLotId;
		burnLot.lotOwner = _account;
		burnLot.amount = _amount;
		ownedBurnLots[_account].push(burnLotId);
		emit BurnLotCreation(burnLot.lotOwner, burnLot.burnLotId, burnLot.amount, _multiplierAfterBurn);
		return true;
	}

	/**
	 * @dev Return all Burn Lot IDs owned by an address
	 * @param _lotOwner The address of the burn lot owner
	 * @return array of Burn Lot IDs
	 */
	function burnLotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {
		return ownedBurnLots[_lotOwner];
	}

	/**
	 * @dev Return the total burn lots owned by an address
	 * @param _lotOwner The address of the burn lot owner
	 * @return total burn lots owner by the address
	 */
	function totalBurnLotsByAddress(address _lotOwner) public view returns (uint256) {
		return ownedBurnLots[_lotOwner].length;
	}

	/**
	 * @dev Return the burn lot information at a given ID
	 * @param _burnLotId The burn lot ID in question
	 * @return id of the lot
	 * @return The address of the burn lot owner
	 * @return Primordial ion amount in the burn lot
	 */
	function burnLotById(bytes32 _burnLotId) public view returns (bytes32, address, uint256) {
		BurnLot memory _burnLot = burnLots[_burnLotId];
		return (_burnLot.burnLotId, _burnLot.lotOwner, _burnLot.amount);
	}

	/**
	 * @dev Store convert lot information
	 * @param _account The address of the account
	 * @param _amount The amount to convert
	 * @param _multiplierAfterConversion The owner's weighted multiplier after conversion
	 * @return true on success
	 */
	function createConvertLot(address _account, uint256 _amount, uint256 _multiplierAfterConversion) external onlyAOIon returns (bool) {
		// Store convert lot info
		totalConvertLots++;

		// Generate convert lot Id
		bytes32 convertLotId = keccak256(abi.encodePacked(this, _account, totalConvertLots));

		// Make sure no one owns this lot yet
		require (convertLots[convertLotId].lotOwner == address(0));

		ConvertLot storage convertLot = convertLots[convertLotId];
		convertLot.convertLotId = convertLotId;
		convertLot.lotOwner = _account;
		convertLot.amount = _amount;
		ownedConvertLots[_account].push(convertLotId);
		emit ConvertLotCreation(convertLot.lotOwner, convertLot.convertLotId, convertLot.amount, _multiplierAfterConversion);
		return true;
	}

	/**
	 * @dev Return all Convert Lot IDs owned by an address
	 * @param _lotOwner The address of the convert lot owner
	 * @return array of Convert Lot IDs
	 */
	function convertLotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {
		return ownedConvertLots[_lotOwner];
	}

	/**
	 * @dev Return the total convert lots owned by an address
	 * @param _lotOwner The address of the convert lot owner
	 * @return total convert lots owner by the address
	 */
	function totalConvertLotsByAddress(address _lotOwner) public view returns (uint256) {
		return ownedConvertLots[_lotOwner].length;
	}

	/**
	 * @dev Return the convert lot information at a given ID
	 * @param _convertLotId The convert lot ID in question
	 * @return id of the lot
	 * @return The address of the convert lot owner
	 * @return Primordial ion amount in the convert lot
	 */
	function convertLotById(bytes32 _convertLotId) public view returns (bytes32, address, uint256) {
		ConvertLot memory _convertLot = convertLots[_convertLotId];
		return (_convertLot.convertLotId, _convertLot.lotOwner, _convertLot.amount);
	}

	/***** INTERNAL METHOD *****/
	/**
	 * @dev Actual creating a lot with `amount` of ions at `weightedMultiplier` for an `account`
	 * @param _account Address of lot owner
	 * @param _amount The amount of ions
	 * @param _weightedMultiplier The multiplier of the lot (in 10^6)
	 * @param _networkBonusAmount The network ion bonus amount
	 * @return bytes32 of new created lot ID
	 */
	function _createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier, uint256 _networkBonusAmount) internal returns (bytes32) {
		totalLots++;

		// Generate lotId
		bytes32 lotId = keccak256(abi.encodePacked(address(this), _account, totalLots));

		// Make sure no one owns this lot yet
		require (lots[lotId].lotOwner == address(0));

		Lot storage lot = lots[lotId];
		lot.lotId = lotId;
		lot.multiplier = _weightedMultiplier;
		lot.lotOwner = _account;
		lot.amount = _amount;
		ownedLots[_account].push(lotId);

		emit LotCreation(lot.lotOwner, lot.lotId, lot.multiplier, lot.amount, _networkBonusAmount);
		return lotId;
	}
}