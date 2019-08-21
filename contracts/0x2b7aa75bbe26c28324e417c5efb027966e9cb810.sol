pragma solidity ^0.4.19;


contract SafeMath {

	function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a && c >= b);
		return c;
	}

	function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b > 0);
		uint256 c = a / b;
		assert(a == b * c + a % b);
		return c;
	}
}


contract ERC20Token {

	// --------
	//	Events
	// ---------

	// publicize actions to external listeners.
	/// @notice Triggered when tokens are transferred.
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	/// @notice Triggered whenever approve(address _spender, uint256 _value) is called.
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// --------
	//	Getters
	// ---------

	/// @notice Get the total amount of token supply
	function totalSupply() public constant returns (uint256 _totalSupply);

	/// @notice Get the account balance of address _owner
	/// @param _owner The address from which the balance will be retrieved
	/// @return The balance
	function balanceOf(address _owner) public constant returns (uint256 balance);

	/// @param _owner The address of the account owning tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @return Amount of remaining tokens allowed to spent by the _spender from _owner account
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

	// --------
	//	Actions
	// ---------

	/// @notice send _value amount of tokens to _to address from msg.sender address
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return a boolean - whether the transfer was successful or not
	function transfer(address _to, uint256 _value) public returns (bool success);

	/// @notice send _value amount of tokens to _to address from _from address, on the condition it is approved by _from
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return a boolean - whether the transfer was successful or not
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

	/// @notice msg.sender approves _spender to spend multiple times up to _value amount of tokens
	/// If this function is called again it overwrites the current allowance with _value.
	/// @param _spender The address of the account able to transfer the tokens
	/// @param _value The amount of tokens to be approved for transfer
	/// @return a boolean - whether the approval was successful or not
	function approve(address _spender, uint256 _value) public returns (bool success);
}


contract SecureERC20Token is ERC20Token {

	// State variables

	// balances dictionary that maps addresses to balances
	mapping (address => uint256) private balances;

	// locked account dictionary that maps addresses to boolean
	mapping (address => bool) private lockedAccounts;

	 // allowed dictionary that allow transfer rights to other addresses.
	mapping (address => mapping(address => uint256)) private allowed;

	// The Token's name: e.g. 'Gilgamesh Tokens'
	string public name;

	// Symbol of the token: e.q 'GIL'
	string public symbol;

	// Number of decimals of the smallest unit: e.g '18'
	uint8 public decimals;

	// Number of total tokens: e,g: '1000000000'
	uint256 public totalSupply;

	// token version
	uint8 public version = 1;

	// address of the contract admin
	address public admin;

	// address of the contract minter
	address public minter;

	// creationBlock is the block number that the Token was created
	uint256 public creationBlock;

	// Flag that determines if the token is transferable or not
	// disable actionable ERC20 token methods
	bool public isTransferEnabled;

	event AdminOwnershipTransferred(address indexed previousAdmin, address indexed newAdmin);
	event MinterOwnershipTransferred(address indexed previousMinter, address indexed newMinter);
	event TransferStatus(address indexed sender, bool status);

	// @notice Constructor to create Gilgamesh ERC20 Token
	function SecureERC20Token(
		uint256 initialSupply,
		string _name,
		string _symbol,
		uint8 _decimals,
		bool _isTransferEnabled
	) public {
		// assign all tokens to the deployer
		balances[msg.sender] = initialSupply;

		totalSupply = initialSupply; // set initial supply of Tokens
		name = _name;				 // set token name
		decimals = _decimals;		 // set the decimals
		symbol = _symbol;			 // set the token symbol
		isTransferEnabled = _isTransferEnabled;
		creationBlock = block.number;
		minter = msg.sender;		// by default the contract deployer is the minter
		admin = msg.sender;			// by default the contract deployer is the admin
	}

	// --------------
	// ERC20 Methods
	// --------------

	/// @notice Get the total amount of token supply
	function totalSupply() public constant returns (uint256 _totalSupply) {
		return totalSupply;
	}

	/// @notice Get the account balance of address _owner
	/// @param _owner The address from which the balance will be retrieved
	/// @return The balance
	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balances[_owner];
	}

	/// @notice send _value amount of tokens to _to address from msg.sender address
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return a boolean - whether the transfer was successful or not
	function transfer(address _to, uint256 _value) public returns (bool success) {
		// if transfer is not enabled throw an error and stop execution.
		require(isTransferEnabled);

		// continue with transfer
		return doTransfer(msg.sender, _to, _value);
	}

	/// @notice send _value amount of tokens to _to address from _from address, on the condition it is approved by _from
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return a boolean - whether the transfer was successful or not
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		// if transfer is not enabled throw an error and stop execution.
		require(isTransferEnabled);

		// if from allowed transferrable rights to sender for amount _value
		if (allowed[_from][msg.sender] < _value) revert();

		// subtreact allowance
		allowed[_from][msg.sender] -= _value;

		// continue with transfer
		return doTransfer(_from, _to, _value);
	}

	/// @notice msg.sender approves _spender to spend _value tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @param _value The amount of tokens to be approved for transfer
	/// @return a boolean - whether the approval was successful or not
	function approve(address _spender, uint256 _value)
	public
	is_not_locked(_spender)
	returns (bool success) {
		// if transfer is not enabled throw an error and stop execution.
		require(isTransferEnabled);

		// user can only reassign an allowance of 0 if value is greater than 0
		// sender should first change the allowance to zero by calling approve(_spender, 0)
		// race condition is explained below:
		// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		if(_value != 0 && allowed[msg.sender][_spender] != 0) revert();

		if (
			// if sender balance is less than _value return false;
			balances[msg.sender] < _value
		) {
			// transaction failure
			return false;
		}

		// allow transfer rights from msg.sender to _spender for _value token amount
		allowed[msg.sender][_spender] = _value;

		// log approval event
		Approval(msg.sender, _spender, _value);

		// transaction successful
		return true;
	}

	/// @param _owner The address of the account owning tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @return Amount of remaining tokens allowed to spent by the _spender from _owner account
	function allowance(address _owner, address _spender)
	public
	constant
	returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	// --------------
	// Contract Custom Methods - Non ERC20
	// --------------

	/* Public Methods */

	/// @notice only the admin is allowed to lock accounts.
	/// @param _owner the address of the account to be locked
	function lockAccount(address _owner)
	public
	is_not_locked(_owner)
	validate_address(_owner)
	onlyAdmin {
		lockedAccounts[_owner] = true;
	}

	/// @notice only the admin is allowed to unlock accounts.
	/// @param _owner the address of the account to be unlocked
	function unlockAccount(address _owner)
	public
	is_locked(_owner)
	validate_address(_owner)
	onlyAdmin {
		lockedAccounts[_owner] = false;
	}

	/// @notice only the admin is allowed to burn tokens - in case if the user haven't verified identity or performed fraud
	/// @param _owner the address of the account that their tokens needs to be burnt
	function burnUserTokens(address _owner)
	public
	validate_address(_owner)
	onlyAdmin {
		// if user balance is 0 ignore
		if (balances[_owner] == 0) revert();

		// should never happen but just in case
		if (balances[_owner] > totalSupply) revert();

		// decrease the total supply
		totalSupply -= balances[_owner];

		// burn it all
		balances[_owner] = 0;
	}

	/// @notice only the admin is allowed to change the minter.
	/// @param newMinter the address of the minter
	function changeMinter(address newMinter)
	public
	validate_address(newMinter)
	onlyAdmin {
		if (minter == newMinter) revert();
		MinterOwnershipTransferred(minter, newMinter);
		minter = newMinter;
	}

	/// @notice only the admin is allowed to change the admin.
	/// @param newAdmin the address of the new admin
	function changeAdmin(address newAdmin)
	public
	validate_address(newAdmin)
	onlyAdmin {
		if (admin == newAdmin) revert();
		AdminOwnershipTransferred(admin, newAdmin);
		admin = newAdmin;
	}

	/// @notice mint new tokens by the minter
	/// @param _owner the owner of the newly tokens
	/// @param _amount the amount of new token to be minted
	function mint(address _owner, uint256 _amount)
	public
	onlyMinter
	validate_address(_owner)
	returns (bool success) {
		// preventing overflow on the totalSupply
		if (totalSupply + _amount < totalSupply) revert();

		// preventing overflow on the receiver account
		if (balances[_owner] + _amount < balances[_owner]) revert();

		// increase the total supply
		totalSupply += _amount;

		// assign the additional supply to the target account.
		balances[_owner] += _amount;

		// contract has minted new token by the minter
		Transfer(0x0, msg.sender, _amount);

		// minter has transferred token to the target account
		Transfer(msg.sender, _owner, _amount);

		return true;
	}

	/// @notice Enables token holders to transfer their tokens freely if true
	/// after the crowdsale is finished it will be true
	/// for security reasons can be switched to false
	/// @param _isTransferEnabled boolean
	function enableTransfers(bool _isTransferEnabled) public onlyAdmin {
		isTransferEnabled = _isTransferEnabled;
		TransferStatus(msg.sender, isTransferEnabled);
	}

	/* Internal Methods */

	///	@dev this is the actual transfer function and it can only be called internally
	/// @notice send _value amount of tokens to _to address from _from address
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return a boolean - whether the transfer was successful or not
	function doTransfer(address _from, address _to, uint256 _value)
	validate_address(_to)
	is_not_locked(_from)
	internal
	returns (bool success) {
		if (
			// if the value is not more than 0 fail
			_value <= 0 ||
			// if the sender doesn't have enough balance fail
			balances[_from] < _value ||
			// if token supply overflows (total supply exceeds 2^256 - 1) fail
			balances[_to] + _value < balances[_to]
		) {
			// transaction failed
			return false;
		}

		// decrease the number of tokens from sender address.
		balances[_from] -= _value;

		// increase the number of tokens for _to address
		balances[_to] += _value;

		// log transfer event
		Transfer(_from, _to, _value);

		// transaction successful
		return true;
	}

	// --------------
	// Modifiers
	// --------------
	modifier onlyMinter() {
		// if sender is not the minter stop the execution
		if (msg.sender != minter) revert();
		// if the sender is the minter continue
		_;
	}

	modifier onlyAdmin() {
		// if sender is not the admin stop the execution
		if (msg.sender != admin) revert();
		// if the sender is the admin continue
		_;
	}

	modifier validate_address(address _address) {
		if (_address == address(0)) revert();
		_;
	}

	modifier is_not_locked(address _address) {
		if (lockedAccounts[_address] == true) revert();
		_;
	}

	modifier is_locked(address _address) {
		if (lockedAccounts[_address] != true) revert();
		_;
	}
}


contract GilgameshToken is SecureERC20Token {
	// @notice Constructor to create Gilgamesh ERC20 Token
	function GilgameshToken()
	public
	SecureERC20Token(
		0, // no token in the begning
		"Gilgamesh Token", // Token Name
		"GIL", // Token Symbol
		18, // Decimals
		false // Enable token transfer
	) {}

}


/*
	Copyright 2017, Skiral Inc
*/
contract GilgameshTokenSale is SafeMath{

	// creationBlock is the block number that the Token was created
	uint256 public creationBlock;

	// startBlock token sale starting block
	uint256 public startBlock;

	// endBlock token sale ending block
	// end block is not a valid block for crowdfunding. endBlock - 1 is the last valid block
	uint256 public endBlock;

	// total Wei rasised
	uint256 public totalRaised = 0;

	// Has Gilgamesh stopped the sale
	bool public saleStopped = false;

	// Has Gilgamesh finalized the sale
	bool public saleFinalized = false;

	// Minimum purchase - 0.1 Ether
	uint256 constant public minimumInvestment = 100 finney;

	// Maximum hard Cap
	uint256 public hardCap = 50000 ether;

	// number of wei GIL tokens for sale - 60 Million GIL Tokens
	uint256 public tokenCap = 60000000 * 10**18;

	// Minimum cap
	uint256 public minimumCap = 1250 ether;

	/* Contract Info */

	// the deposit address for the Eth that is raised.
	address public fundOwnerWallet;

	// the deposit address for the tokens that is minted for the dev team.
	address public tokenOwnerWallet;

	// owner the address of the contract depoloyer
	address public owner;

	// List of stage bonus percentages in every stage
	// this will get generated in the constructor
	uint[] public stageBonusPercentage;

	// number of participants
	uint256 public totalParticipants;

	// a map of userId to wei
	mapping(uint256 => uint256) public paymentsByUserId;

	// a map of user address to wei
	mapping(address => uint256) public paymentsByAddress;

	// total number of bonus stages.
	uint8 public totalStages;

	// max bonus percentage on first stage
	uint8 public stageMaxBonusPercentage;

	// number of wei-GIL tokens for 1 wei (18 decimals)
	uint256 public tokenPrice;

	// the team owns 25% of the tokens - 3 times more than token purchasers.
	uint8 public teamTokenRatio = 3;

	// GIL token address
	GilgameshToken public token;

	// if Ether or Token cap has been reached
	bool public isCapReached = false;

	// log when token sale has been initialized
	event LogTokenSaleInitialized(
		address indexed owner,
		address indexed fundOwnerWallet,
		uint256 startBlock,
		uint256 endBlock,
		uint256 creationBlock
	);

	// log each contribution
	event LogContribution(
		address indexed contributorAddress,
		address indexed invokerAddress,
		uint256 amount,
		uint256 totalRaised,
		uint256 userAssignedTokens,
		uint256 indexed userId
	);

	// log when crowd fund is finalized
	event LogFinalized(address owner, uint256 teamTokens);

	// Constructor
	function GilgameshTokenSale(
		uint256 _startBlock, // starting block number
		uint256 _endBlock, // ending block number
		address _fundOwnerWallet, // fund owner wallet address - transfer ether to this address during and after fund has been closed
		address _tokenOwnerWallet, // token fund owner wallet address - transfer GIL tokens to this address after fund is finalized
		uint8 _totalStages, // total number of bonus stages
		uint8 _stageMaxBonusPercentage, // maximum percentage for bonus in the first stage
		uint256 _tokenPrice, // price of each GIL token in wei
		address _gilgameshToken, // address of the gilgamesh ERC20 token contract
		uint256 _minimumCap, // minimum cap, minimum amount of wei to be raised
		uint256 _tokenCap // tokenCap
	)
	public
	validate_address(_fundOwnerWallet) {

		if (
			_gilgameshToken == 0x0 ||
			_tokenOwnerWallet == 0x0 ||
			// start block needs to be in the future
			_startBlock < getBlockNumber()  ||
			// start block should be less than ending block
			_startBlock >= _endBlock  ||
			// minimum number of stages is 2
			_totalStages < 2 ||
			// verify stage max bonus
			_stageMaxBonusPercentage < 0  ||
			_stageMaxBonusPercentage > 100 ||
			// stage bonus percentage needs to be devisible by number of stages
			_stageMaxBonusPercentage % (_totalStages - 1) != 0 ||
			// total number of blocks needs to be devisible by the total stages
			(_endBlock - _startBlock) % _totalStages != 0
		) revert();

		owner = msg.sender; // make the contract creator the `owner`
		token = GilgameshToken(_gilgameshToken);
		endBlock = _endBlock;
		startBlock = _startBlock;
		creationBlock = getBlockNumber();
		fundOwnerWallet = _fundOwnerWallet;
		tokenOwnerWallet = _tokenOwnerWallet;
		tokenPrice = _tokenPrice;
		totalStages = _totalStages;
		minimumCap = _minimumCap;
		stageMaxBonusPercentage = _stageMaxBonusPercentage;
		totalRaised = 0; //	total number of wei raised
		tokenCap = _tokenCap;

		// spread bonuses evenly between stages - e.g 27 / 9 = 3%
		uint spread = stageMaxBonusPercentage / (totalStages - 1);

		// loop through [10 to 1] => ( 9 to 0) * 3% = [27%, 24%, 21%, 18%, 15%, 12%, 9%, 6%, 3%, 0%]
		for (uint stageNumber = totalStages; stageNumber > 0; stageNumber--) {
			stageBonusPercentage.push((stageNumber - 1) * spread);
		}

		LogTokenSaleInitialized(
			owner,
			fundOwnerWallet,
			startBlock,
			endBlock,
			creationBlock
		);
	}

	// --------------
	// Public Funtions
	// --------------

	/// @notice Function to stop sale for an emergency.
	/// @dev Only Gilgamesh Dev can do it after it has been activated.
	function emergencyStopSale()
	public
	only_sale_active
	onlyOwner {
		saleStopped = true;
	}

	/// @notice Function to restart stopped sale.
	/// @dev Only Gilgamesh Dev can do it after it has been disabled and sale has stopped.
	/// can it's in a valid time range for sale
	function restartSale()
	public
	only_during_sale_period
	only_sale_stopped
	onlyOwner {
		// if sale is finalized fail
		if (saleFinalized) revert();
		saleStopped = false;
	}

	/// @notice Function to change the fund owner wallet address
	/// @dev Only Gilgamesh Dev can trigger this function
	function changeFundOwnerWalletAddress(address _fundOwnerWallet)
	public
	validate_address(_fundOwnerWallet)
	onlyOwner {
		fundOwnerWallet = _fundOwnerWallet;
	}

	/// @notice Function to change the token fund owner wallet address
	/// @dev Only Gilgamesh Dev can trigger this function
	function changeTokenOwnerWalletAddress(address _tokenOwnerWallet)
	public
	validate_address(_tokenOwnerWallet)
	onlyOwner {
		tokenOwnerWallet = _tokenOwnerWallet;
	}

	/// @notice finalize the sale
	/// @dev Only Gilgamesh Dev can trigger this function
	function finalizeSale()
	public
	onlyOwner {
		doFinalizeSale();
	}

	/// @notice change hard cap and if it reaches hard cap finalize sale
	function changeCap(uint256 _cap)
	public
	onlyOwner {
		if (_cap < minimumCap) revert();
		if (_cap <= totalRaised) revert();

		hardCap = _cap;

		if (totalRaised + minimumInvestment >= hardCap) {
			isCapReached = true;
			doFinalizeSale();
		}
	}

	/// @notice change minimum cap, in case Ether price fluctuates.
	function changeMinimumCap(uint256 _cap)
	public
	onlyOwner {
		if (minimumCap < _cap) revert();
		minimumCap = _cap;
	}

	/// @notice remove conttact only when sale has been finalized
	/// transfer all the fund to the contract owner
	/// @dev only Gilgamesh Dev can trigger this function
	function removeContract()
	public
	onlyOwner {
		if (!saleFinalized) revert();
		selfdestruct(msg.sender);
	}

	/// @notice only the owner is allowed to change the owner.
	/// @param _newOwner the address of the new owner
	function changeOwner(address _newOwner)
	public
	validate_address(_newOwner)
	onlyOwner {
		require(_newOwner != owner);
		owner = _newOwner;
	}

	/// @dev The fallback function is called when ether is sent to the contract
	/// Payable is a required solidity modifier to receive ether
	/// every contract only has one unnamed function
	/// 2300 gas available for this function
	/*function () public payable {
		return deposit();
	}*/

	/**
	* Pay on a behalf of the sender.
	*
	* @param customerId Identifier in the central database, UUID v4
	*
	*/
	/// @dev allow purchasers to deposit ETH for GIL Tokens.
	function depositForMySelf(uint256 userId)
	public
	only_sale_active
	minimum_contribution()
	payable {
		deposit(userId, msg.sender);
	}

	///	@dev deposit() is an public function that accepts a userId and userAddress
	///	contract receives ETH in return of GIL tokens
	function deposit(uint256 userId, address userAddress)
	public
	payable
	only_sale_active
	minimum_contribution()
	validate_address(userAddress) {
		// if it passes hard cap throw
		if (totalRaised + msg.value > hardCap) revert();

		uint256 userAssignedTokens = calculateTokens(msg.value);

		// if user tokens are 0 throw
		if (userAssignedTokens <= 0) revert();

		// if number of tokens exceed the token cap stop execution
		if (token.totalSupply() + userAssignedTokens > tokenCap) revert();

		// send funds to fund owner wallet
		if (!fundOwnerWallet.send(msg.value)) revert();

		// mint tokens for the user
		if (!token.mint(userAddress, userAssignedTokens)) revert();

		// save total number wei raised
		totalRaised = safeAdd(totalRaised, msg.value);

		// if cap is reached mark it
		if (totalRaised >= hardCap) {
			isCapReached = true;
		}

		// if token supply has exceeded or reached the token cap stop
		if (token.totalSupply() >= tokenCap) {
			isCapReached = true;
		}

		// increase the number of participants for the first transaction
		if (paymentsByUserId[userId] == 0) {
			totalParticipants++;
		}

		// increase the amount that the user has payed
		paymentsByUserId[userId] += msg.value;

		// total wei based on address
		paymentsByAddress[userAddress] += msg.value;

		// log contribution event
		LogContribution(
			userAddress,
			msg.sender,
			msg.value,
			totalRaised,
			userAssignedTokens,
			userId
		);
	}

	/// @notice calculate number of tokens need to be issued based on the amount received
	/// @param amount number of wei received
	function calculateTokens(uint256 amount)
	public
	view
	returns (uint256) {
		// return 0 if the crowd fund has ended or it hasn't started
		if (!isDuringSalePeriod(getBlockNumber())) return 0;

		// get the current stage number by block number
		uint8 currentStage = getStageByBlockNumber(getBlockNumber());

		// if current stage is more than the total stage return 0 - something is wrong
		if (currentStage > totalStages) return 0;

		// calculate number of tokens that needs to be issued for the purchaser
		uint256 purchasedTokens = safeMul(amount, tokenPrice);
		// calculate number of tokens that needs to be rewraded to the purchaser
		uint256 rewardedTokens = calculateRewardTokens(purchasedTokens, currentStage);
		// add purchasedTokens and rewardedTokens
		return safeAdd(purchasedTokens, rewardedTokens);
	}

	/// @notice calculate reward based on amount of tokens that will be issued to the purchaser
	/// @param amount number tokens that will be minted for the purchaser
	/// @param stageNumber number of current stage in the crowd fund process
	function calculateRewardTokens(uint256 amount, uint8 stageNumber)
	public
	view
	returns (uint256 rewardAmount) {
		// throw if it's invalid stage number
		if (
			stageNumber < 1 ||
			stageNumber > totalStages
		) revert();

		// get stage index for the array
		uint8 stageIndex = stageNumber - 1;

		// calculate reward - e.q 100 token creates 100 * 20 /100 = 20 tokens for reward
		return safeDiv(safeMul(amount, stageBonusPercentage[stageIndex]), 100);
	}

	/// @notice get crowd fund stage by block number
	/// @param _blockNumber block number
	function getStageByBlockNumber(uint256 _blockNumber)
	public
	view
	returns (uint8) {
		// throw error, if block number is out of range
		if (!isDuringSalePeriod(_blockNumber)) revert();

		uint256 totalBlocks = safeSub(endBlock, startBlock);
		uint256 numOfBlockPassed = safeSub(_blockNumber, startBlock);

		// since numbers round down we need to add one to number of stage
		return uint8(safeDiv(safeMul(totalStages, numOfBlockPassed), totalBlocks) + 1);
	}

	// --------------
	// Internal Funtions
	// --------------

	/// @notice check if the block number is during the sale period
	/// @param _blockNumber block number
	function isDuringSalePeriod(uint256 _blockNumber)
	view
	internal
	returns (bool) {
		return (_blockNumber >= startBlock && _blockNumber < endBlock);
	}

	/// @notice finalize the crowdfun sale
	/// @dev Only Gilgamesh Dev can trigger this function
	function doFinalizeSale()
	internal
	onlyOwner {

		if (saleFinalized) revert();

		// calculate the number of tokens that needs to be assigned to Gilgamesh team
		uint256 teamTokens = safeMul(token.totalSupply(), teamTokenRatio);

		if (teamTokens > 0){
			// mint tokens for the team
			if (!token.mint(tokenOwnerWallet, teamTokens)) revert();
		}

		// if there is any fund drain it
		if(this.balance > 0) {
			// send ether funds to fund owner wallet
			if (!fundOwnerWallet.send(this.balance)) revert();
		}

		// finalize sale flag
		saleFinalized = true;

		// stop sale flag
		saleStopped = true;

		// log finalized
		LogFinalized(tokenOwnerWallet, teamTokens);
	}

	/// @notice returns block.number
	function getBlockNumber() constant internal returns (uint) {
		return block.number;
	}

	// --------------
	// Modifiers
	// --------------

	/// continue only when sale has stopped
	modifier only_sale_stopped {
		if (!saleStopped) revert();
		_;
	}


	/// validates an address - currently only checks that it isn't null
	modifier validate_address(address _address) {
		if (_address == 0x0) revert();
		_;
	}

	/// continue only during the sale period
	modifier only_during_sale_period {
		// if block number is less than starting block fail
		if (getBlockNumber() < startBlock) revert();
		// if block number has reach to the end block fail
		if (getBlockNumber() >= endBlock) revert();
		// otherwise safe to continue
		_;
	}

	/// continue when sale is active and valid
	modifier only_sale_active {
		// if sale is finalized fail
		if (saleFinalized) revert();
		// if sale is stopped fail
		if (saleStopped) revert();
		// if cap is reached
		if (isCapReached) revert();
		// if block number is less than starting block fail
		if (getBlockNumber() < startBlock) revert();
		// if block number has reach to the end block fail
		if (getBlockNumber() >= endBlock) revert();
		// otherwise safe to continue
		_;
	}

	/// continue if minimum contribution has reached
	modifier minimum_contribution() {
		if (msg.value < minimumInvestment) revert();
		_;
	}

	/// continue when the invoker is the owner
	modifier onlyOwner() {
		if (msg.sender != owner) revert();
		_;
	}
}