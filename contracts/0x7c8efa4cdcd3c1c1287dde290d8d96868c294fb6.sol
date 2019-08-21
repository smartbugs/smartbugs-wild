pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
		if (_a == 0) {
			return 0;
		}
		uint256 c = _a * _b;
		assert(c / _a == _b);
		return c;
	}

	function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
		return _a / _b;
	}

	function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
		assert(_b <= _a);
		return _a - _b;
	}

	function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
		uint256 c = _a + _b;
		assert(c >= _a);
		return c;
	}
}

/**
 * @title Ownable
 * @dev The Ownable contract holds owner addresses, and provides basic authorization control
 * functions.
 */
contract Ownable {
	/**
	* @dev Allows to check if the given address has owner rights.
	* @param _owner The address to check for owner rights.
	* @return True if the address is owner, false if it is not.
	*/
	mapping(address => bool) public owners;
	
	/**
	* @dev The Ownable constructor adds the sender
	* account to the owners mapping.
	*/
	constructor() public {
		owners[msg.sender] = true;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwners() {
		require(owners[msg.sender], 'Owner message sender required.');
		_;
	}

	/**
	* @dev Allows the current owners to grant or revoke 
	* owner-level access rights to the contract.
	* @param _owner The address to grant or revoke owner rights.
	* @param _isAllowed Boolean granting or revoking owner rights.
	* @return True if the operation has passed or throws if failed.
	*/
	function setOwner(address _owner, bool _isAllowed) public onlyOwners {
		require(_owner != address(0), 'Non-zero owner-address required.');
		owners[_owner] = _isAllowed;
	}
}

/**
 * @title Destroyable
 * @dev Base contract that can be destroyed by the owners. All funds in contract will be sent back.
 */
contract Destroyable is Ownable {

	constructor() public payable {}

	/**
	* @dev Transfers The current balance to the message sender and terminates the contract.
	*/
	function destroy() public onlyOwners {
		selfdestruct(msg.sender);
	}

	/**
	* @dev Transfers The current balance to the specified _recipient and terminates the contract.
	* @param _recipient The address to send the current balance to.
	*/
	function destroyAndSend(address _recipient) public onlyOwners {
		require(_recipient != address(0), 'Non-zero recipient address required.');
		selfdestruct(_recipient);
	}
}

/**
 * @title BotOperated
 * @dev The BotOperated contract holds bot addresses, and provides basic authorization control
 * functions.
 */
contract BotOperated is Ownable {
	/**
	* @dev Allows to check if the given address has bot rights.
	* @param _bot The address to check for bot rights.
	* @return True if the address is bot, false if it is not.
	*/
	mapping(address => bool) public bots;

	/**
	 * @dev Throws if called by any account other than bot or owner.
	 */
	modifier onlyBotsOrOwners() {
		require(bots[msg.sender] || owners[msg.sender], 'Bot or owner message sender required.');
		_;
	}

	/**
	* @dev Throws if called by any account other than the bot.
	*/
	modifier onlyBots() {
		require(bots[msg.sender], 'Bot message sender required.');
		_;
	}

	/**
	* @dev The BotOperated constructor adds the sender
	* account to the bots mapping.
	*/
	constructor() public {
		bots[msg.sender] = true;
	}

	/**
	* @dev Allows the current owners to grant or revoke 
	* bot-level access rights to the contract.
	* @param _bot The address to grant or revoke bot rights.
	* @param _isAllowed Boolean granting or revoking bot rights.
	* @return True if the operation has passed or throws if failed.
	*/
	function setBot(address _bot, bool _isAllowed) public onlyOwners {
		require(_bot != address(0), 'Non-zero bot-address required.');
		bots[_bot] = _isAllowed;
	}
}

/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
*/
contract Pausable is BotOperated {
	event Pause();
	event Unpause();

	bool public paused = true;

	/**
	* @dev Modifier to allow actions only when the contract IS NOT paused.
	*/
	modifier whenNotPaused() {
		require(!paused, 'Unpaused contract required.');
		_;
	}

	/**
	* @dev Called by the owner to pause, triggers stopped state.
	* @return True if the operation has passed.
	*/
	function pause() public onlyBotsOrOwners {
		paused = true;
		emit Pause();
	}

	/**
	* @dev Called by the owner to unpause, returns to normal state.
	* @return True if the operation has passed.
	*/
	function unpause() public onlyBotsOrOwners {
		paused = false;
		emit Unpause();
	}
}

interface EternalDataStorage {
	function balances(address _owner) external view returns (uint256);

	function setBalance(address _owner, uint256 _value) external;

	function allowed(address _owner, address _spender) external view returns (uint256);

	function setAllowance(address _owner, address _spender, uint256 _amount) external;

	function totalSupply() external view returns (uint256);

	function setTotalSupply(uint256 _value) external;

	function frozenAccounts(address _target) external view returns (bool isFrozen);

	function setFrozenAccount(address _target, bool _isFrozen) external;

	function increaseAllowance(address _owner,  address _spender, uint256 _increase) external;

	function decreaseAllowance(address _owner,  address _spender, uint256 _decrease) external;
}

interface Ledger {
	function addTransaction(address _from, address _to, uint _tokens) external;
}

interface WhitelistData {
	function kycId(address _customer) external view returns (bytes32);
}


/**
 * @title ERC20Standard token
 * @dev Implementation of the basic standard token.
 * @notice https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Standard {
	
	using SafeMath for uint256;

	EternalDataStorage internal dataStorage;

	Ledger internal ledger;

	WhitelistData internal whitelist;

	/**
	 * @dev Triggered when tokens are transferred.
	 * @notice MUST trigger when tokens are transferred, including zero value transfers.
	 */
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	/**
	 * @dev Triggered whenever approve(address _spender, uint256 _value) is called.
	 * @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
	 */
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	modifier isWhitelisted(address _customer) {
		require(whitelist.kycId(_customer) != 0x0, 'Whitelisted customer required.');
		_;
	}

	/**
	 * @dev Constructor function that instantiates the EternalDataStorage, Ledger and Whitelist contracts.
	 * @param _dataStorage Address of the Data Storage Contract.
	 * @param _ledger Address of the Ledger Contract.
	 * @param _whitelist Address of the Whitelist Data Contract.
	 */
	constructor(address _dataStorage, address _ledger, address _whitelist) public {
		require(_dataStorage != address(0), 'Non-zero data storage address required.');
		require(_ledger != address(0), 'Non-zero ledger address required.');
		require(_whitelist != address(0), 'Non-zero whitelist address required.');

		dataStorage = EternalDataStorage(_dataStorage);
		ledger = Ledger(_ledger);
		whitelist = WhitelistData(_whitelist);
	}

	/**
	 * @dev Gets the total supply of tokens.
	 * @return totalSupplyAmount The total amount of tokens.
	 */
	function totalSupply() public view returns (uint256 totalSupplyAmount) {
		return dataStorage.totalSupply();
	}

	/**
	 * @dev Get the balance of the specified `_owner` address.
	 * @return balance The token balance of the given address.
	 */
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return dataStorage.balances(_owner);
	}

	/**
	 * @dev Transfer token to a specified address.
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 * @return success True if the transfer was successful, or throws.
	 */
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	/**
	 * @dev Transfer `_value` tokens to `_to` in behalf of `_from`.
	 * @param _from The address of the sender.
	 * @param _to The address of the recipient.
	 * @param _value The amount to send.
	 * @return success True if the transfer was successful, or throws.
	 */    
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		uint256 allowed = dataStorage.allowed(_from, msg.sender);
		require(allowed >= _value, 'From account has insufficient balance');

		allowed = allowed.sub(_value);
		dataStorage.setAllowance(_from, msg.sender, allowed);

		return _transfer(_from, _to, _value);
	}

	/**
	 * @dev Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount.
	 * approve will revert if allowance of _spender is 0. increaseApproval and decreaseApproval should
	 * be used instead to avoid exploit identified here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * @notice If this function is called again it overwrites the current allowance with `_value`.
	 * @param _spender The address authorized to spend.
	 * @param _value The max amount they can spend.
	 * @return success True if the operation was successful, or false.
	 */
	 
	function approve(address _spender, uint256 _value) public returns (bool success) {
		require
		(
			_value == 0 || dataStorage.allowed(msg.sender, _spender) == 0,
			'Approve value is required to be zero or account has already been approved.'
		);
		
		dataStorage.setAllowance(msg.sender, _spender, _value);
		
		emit Approval(msg.sender, _spender, _value);
		
		return true;
	}

	/**
	 * @dev Increase the amount of tokens that an owner allowed to a spender.
	 * This function must be called for increasing approval from a non-zero value
	 * as using approve will revert. It has been added as a fix to the exploit mentioned
	 * here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * @param _spender The address which will spend the funds.
	 * @param _addedValue The amount of tokens to increase the allowance by.
	 */
	function increaseApproval(address _spender, uint256 _addedValue) public {
		dataStorage.increaseAllowance(msg.sender, _spender, _addedValue);
		
		emit Approval(msg.sender, _spender, dataStorage.allowed(msg.sender, _spender));
	}

	/**
	 * @dev Decrease the amount of tokens that an owner allowed to a spender.
	 * This function must be called for decreasing approval from a non-zero value
	 * as using approve will revert. It has been added as a fix to the exploit mentioned
	 * here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * @param _spender The address which will spend the funds.
	 * @param _subtractedValue The amount of tokens to decrease the allowance by.
	 */
	function decreaseApproval(address _spender, uint256 _subtractedValue) public {		
		dataStorage.decreaseAllowance(msg.sender, _spender, _subtractedValue);
		
		emit Approval(msg.sender, _spender, dataStorage.allowed(msg.sender, _spender));
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner The address which owns the funds.
	* @param _spender The address which will spend the funds.
	* @return A uint256 specifying the amount of tokens still available for the spender.
	*/
	function allowance(address _owner, address _spender) public view returns (uint256) {
		return dataStorage.allowed(_owner, _spender);
	}

	/**
	 * @dev Internal transfer, can only be called by this contract.
	 * @param _from The address of the sender.
	 * @param _to The address of the recipient.
	 * @param _value The amount to send.
	 * @return success True if the transfer was successful, or throws.
	 */
	function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
		require(_to != address(0), 'Non-zero to-address required.');
		uint256 fromBalance = dataStorage.balances(_from);
		require(fromBalance >= _value, 'From-address has insufficient balance.');

		fromBalance = fromBalance.sub(_value);

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(_value);

		dataStorage.setBalance(_from, fromBalance);
		dataStorage.setBalance(_to, toBalance);

		ledger.addTransaction(_from, _to, _value);

		emit Transfer(_from, _to, _value);

		return true;
	}
}

/**
 * @title MintableToken
 * @dev ERC20Standard modified with mintable token creation.
 */
contract MintableToken is ERC20Standard, Ownable {

	/**
	 * @dev Hardcap - maximum allowed amount of tokens to be minted
	 */
	uint104 public constant MINTING_HARDCAP = 1e30;

	/**
	* @dev Auto-generated function to check whether the minting has finished.
	* @return True if the minting has finished, or false.
	*/
	bool public mintingFinished = false;

	event Mint(address indexed _to, uint256 _amount);
	
	event MintFinished();

	modifier canMint() {
		require(!mintingFinished, 'Uninished minting required.');
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	*/
	function mint(address _to, uint256 _amount) public onlyOwners canMint() {
		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.add(_amount);
		
		require(totalSupply <= MINTING_HARDCAP, 'Total supply of token in circulation must be below hardcap.');
		
		dataStorage.setTotalSupply(totalSupply);

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(_amount);
		dataStorage.setBalance(_to, toBalance);

		ledger.addTransaction(address(0), _to, _amount);

		emit Transfer(address(0), _to, _amount);

		emit Mint(_to, _amount);
	}

	/**
	* @dev Function to permanently stop minting new tokens.
	*/
	function finishMinting() public onlyOwners {
		mintingFinished = true;
		emit MintFinished();
	}
}

/**
 * @title BurnableToken
 * @dev ERC20Standard token that can be irreversibly burned(destroyed).
 */
contract BurnableToken is ERC20Standard {

	event Burn(address indexed _burner, uint256 _value);
	
	/**
	 * @dev Remove tokens from the system irreversibly.
	 * @notice Destroy tokens from your account.
	 * @param _value The amount of tokens to burn.
	 */
	function burn(uint256 _value) public {
		uint256 senderBalance = dataStorage.balances(msg.sender);
		require(senderBalance >= _value, 'Burn value less than account balance required.');
		senderBalance = senderBalance.sub(_value);
		dataStorage.setBalance(msg.sender, senderBalance);

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.sub(_value);
		dataStorage.setTotalSupply(totalSupply);

		emit Burn(msg.sender, _value);

		emit Transfer(msg.sender, address(0), _value);
	}

	/**
	 * @dev Remove specified `_value` tokens from the system irreversibly on behalf of `_from`.
	 * @param _from The address from which to burn tokens.
	 * @param _value The amount of money to burn.
	 */
	function burnFrom(address _from, uint256 _value) public {
		uint256 fromBalance = dataStorage.balances(_from);
		require(fromBalance >= _value, 'Burn value less than from-account balance required.');

		uint256 allowed = dataStorage.allowed(_from, msg.sender);
		require(allowed >= _value, 'Burn value less than account allowance required.');

		fromBalance = fromBalance.sub(_value);
		dataStorage.setBalance(_from, fromBalance);

		allowed = allowed.sub(_value);
		dataStorage.setAllowance(_from, msg.sender, allowed);

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.sub(_value);
		dataStorage.setTotalSupply(totalSupply);

		emit Burn(_from, _value);

		emit Transfer(_from, address(0), _value);
	}
}

/**
 * @title PausableToken
 * @dev ERC20Standard modified with pausable transfers.
 **/
contract PausableToken is ERC20Standard, Pausable {
	
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
		return super.approve(_spender, _value);
	}
}

/**
 * @title FreezableToken
 * @dev ERC20Standard modified with freezing accounts ability.
 */
contract FreezableToken is ERC20Standard, Ownable {

	event FrozenFunds(address indexed _target, bool _isFrozen);

	/**
	 * @dev Allow or prevent target address from sending & receiving tokens.
	 * @param _target Address to be frozen or unfrozen.
	 * @param _isFrozen Boolean indicating freeze or unfreeze operation.
	 */ 
	function freezeAccount(address _target, bool _isFrozen) public onlyOwners {
		require(_target != address(0), 'Non-zero to-be-frozen-account address required.');
		dataStorage.setFrozenAccount(_target, _isFrozen);
		emit FrozenFunds(_target, _isFrozen);
	}

	/**
	 * @dev Checks whether the target is frozen or not.
	 * @param _target Address to check.
	 * @return isFrozen A boolean that indicates whether the account is frozen or not. 
	 */
	function isAccountFrozen(address _target) public view returns (bool isFrozen) {
		return dataStorage.frozenAccounts(_target);
	}

	/**
	 * @dev Overrided _transfer function that uses freeze functionality
	 */
	function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
		assert(!dataStorage.frozenAccounts(_from));

		assert(!dataStorage.frozenAccounts(_to));
		
		return super._transfer(_from, _to, _value);
	}
}

/**
 * @title ERC20Extended
 * @dev Standard ERC20 token with extended functionalities.
 */
contract ERC20Extended is FreezableToken, PausableToken, BurnableToken, MintableToken, Destroyable {
	/**
	* @dev Auto-generated function that returns the name of the token.
	* @return The name of the token.
	*/
	string public constant name = 'ORBISE10';

	/**
	* @dev Auto-generated function that returns the symbol of the token.
	* @return The symbol of the token.
	*/
	string public constant symbol = 'ORBT';

	/**
	* @dev Auto-generated function that returns the number of decimals of the token.
	* @return The number of decimals of the token.
	*/
	uint8 public constant decimals = 18;

	/**
	* @dev Constant for the minimum allowed amount of tokens one can buy
	*/
	uint72 public constant MINIMUM_BUY_AMOUNT = 200e18;

	/**
	* @dev Auto-generated function that gets the price at which the token is sold.
	* @return The sell price of the token.
	*/
	uint256 public sellPrice;

	/**
	* @dev Auto-generated function that gets the price at which the token is bought.
	* @return The buy price of the token.
	*/
	uint256 public buyPrice;

	/**
	* @dev Auto-generated function that gets the address of the wallet of the contract.
	* @return The address of the wallet.
	*/
	address public wallet;

	/**
	* @dev Constructor function that calculates the total supply of tokens, 
	* sets the initial sell and buy prices and
	* passes arguments to base constructors.
	* @param _dataStorage Address of the Data Storage Contract.
	* @param _ledger Address of the Data Storage Contract.
	* @param _whitelist Address of the Whitelist Data Contract.
	*/
	constructor
	(
		address _dataStorage,
		address _ledger,
		address _whitelist
	)
		ERC20Standard(_dataStorage, _ledger, _whitelist)
		public 
	{
	}

	/**
	* @dev Fallback function that allows the contract
	* to receive Ether directly.
	*/
	function() public payable { }

	/**
	* @dev Function that sets both the sell and the buy price of the token.
	* @param _sellPrice The price at which the token will be sold.
	* @param _buyPrice The price at which the token will be bought.
	*/
	function setPrices(uint256 _sellPrice, uint256 _buyPrice) public onlyBotsOrOwners {
		sellPrice = _sellPrice;
		buyPrice = _buyPrice;
	}

	/**
	* @dev Function that sets the current wallet address.
	* @param _walletAddress The address of wallet to be set.
	*/
	function setWallet(address _walletAddress) public onlyOwners {
		require(_walletAddress != address(0), 'Non-zero wallet address required.');
		wallet = _walletAddress;
	}

	/**
	* @dev Send Ether to buy tokens at the current token sell price.
	* @notice buy function has minimum allowed amount one can buy
	*/
	function buy() public payable whenNotPaused isWhitelisted(msg.sender) {
		uint256 amount = msg.value.mul(1e18);
		
		amount = amount.div(sellPrice);

		require(amount >= MINIMUM_BUY_AMOUNT, "Buy amount too small");
		
		_transfer(this, msg.sender, amount);
	}
	
	/**
	* @dev Sell `_amount` tokens at the current buy price.
	* @param _amount The amount to sell.
	*/
	function sell(uint256 _amount) public whenNotPaused {
		uint256 toBeTransferred = _amount.mul(buyPrice);

		require(toBeTransferred >= 1e18, "Sell amount too small");

		toBeTransferred = toBeTransferred.div(1e18);

		require(address(this).balance >= toBeTransferred, 'Contract has insufficient balance.');
		_transfer(msg.sender, this, _amount);
		
		msg.sender.transfer(toBeTransferred);
	}

	/**
	* @dev Get the contract balance in WEI.
	*/
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	/**
	* @dev Withdraw `_amount` ETH to the wallet address.
	* @param _amount The amount to withdraw.
	*/
	function withdraw(uint256 _amount) public onlyOwners {
		require(address(this).balance >= _amount, 'Unable to withdraw specified amount.');
		require(wallet != address(0), 'Non-zero wallet address required.');
		wallet.transfer(_amount);
	}

	/**
	* @dev Transfer, which is used when Orbise is bought with different currency than ETH.
	* @param _to The address of the recipient.
	* @param _value The amount of Orbise Tokens to transfer.
	* @return success True if operation is executed successfully.
	*/
	function nonEtherPurchaseTransfer(address _to, uint256 _value) public isWhitelisted(_to) onlyBots whenNotPaused returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}
}