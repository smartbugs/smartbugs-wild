pragma solidity 0.5.9;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
	struct Role {
		mapping (address => bool) bearer;
	}

	/**
	 * @dev give an account access to this role
	 */
	function add(Role storage role, address account) internal {
		require(account != address(0));
		require(!has(role, account));

		role.bearer[account] = true;
	}

	/**
	 * @dev remove an account's access to this role
	 */
	function remove(Role storage role, address account) internal {
		require(account != address(0));
		require(has(role, account));

		role.bearer[account] = false;
	}

	/**
	 * @dev check if an account has this role
	 * @return bool
	 */
	function has(Role storage role, address account) internal view returns (bool) {
		require(account != address(0));
		return role.bearer[account];
	}
}
contract ETORoles {
	using Roles for Roles.Role;

	constructor() internal {
		_addAuditWriter(msg.sender);
		_addAssetSeizer(msg.sender);
		_addKycProvider(msg.sender);
		_addUserManager(msg.sender);
		_addOwner(msg.sender);
	}

	/*
	 * Audit Writer functions
	 */
	event AuditWriterAdded(address indexed account);
	event AuditWriterRemoved(address indexed account);

	Roles.Role private _auditWriters;

	modifier onlyAuditWriter() {
		require(isAuditWriter(msg.sender), "Sender is not auditWriter");
		_;
	}

	function isAuditWriter(address account) public view returns (bool) {
		return _auditWriters.has(account);
	}

	function addAuditWriter(address account) public onlyUserManager {
		_addAuditWriter(account);
	}

	function renounceAuditWriter() public {
		_removeAuditWriter(msg.sender);
	}

	function _addAuditWriter(address account) internal {
		_auditWriters.add(account);
		emit AuditWriterAdded(account);
	}

	function _removeAuditWriter(address account) internal {
		_auditWriters.remove(account);
		emit AuditWriterRemoved(account);
	}

	/*
	* KYC Provider functions
	*/
	event KycProviderAdded(address indexed account);
	event KycProviderRemoved(address indexed account);

	Roles.Role private _kycProviders;

	modifier onlyKycProvider() {
		require(isKycProvider(msg.sender), "Sender is not kycProvider");
		_;
	}

	function isKycProvider(address account) public view returns (bool) {
		return _kycProviders.has(account);
	}

	function addKycProvider(address account) public onlyUserManager {
		_addKycProvider(account);
	}

	function renounceKycProvider() public {
		_removeKycProvider(msg.sender);
	}

	function _addKycProvider(address account) internal {
		_kycProviders.add(account);
		emit KycProviderAdded(account);
	}

	function _removeKycProvider(address account) internal {
		_kycProviders.remove(account);
		emit KycProviderRemoved(account);
	}

	/*
	* Asset Seizer functions
	*/
	event AssetSeizerAdded(address indexed account);
	event AssetSeizerRemoved(address indexed account);

	Roles.Role private _assetSeizers;

	modifier onlyAssetSeizer() {
		require(isAssetSeizer(msg.sender), "Sender is not assetSeizer");
		_;
	}

	function isAssetSeizer(address account) public view returns (bool) {
		return _assetSeizers.has(account);
	}

	function addAssetSeizer(address account) public onlyUserManager {
		_addAssetSeizer(account);
	}

	function renounceAssetSeizer() public {
		_removeAssetSeizer(msg.sender);
	}

	function _addAssetSeizer(address account) internal {
		_assetSeizers.add(account);
		emit AssetSeizerAdded(account);
	}

	function _removeAssetSeizer(address account) internal {
		_assetSeizers.remove(account);
		emit AssetSeizerRemoved(account);
	}

	/*
	* User Manager functions
	*/
	event UserManagerAdded(address indexed account);
	event UserManagerRemoved(address indexed account);

	Roles.Role private _userManagers;

	modifier onlyUserManager() {
		require(isUserManager(msg.sender), "Sender is not UserManager");
		_;
	}

	function isUserManager(address account) public view returns (bool) {
		return _userManagers.has(account);
	}

	function addUserManager(address account) public onlyUserManager {
		_addUserManager(account);
	}

	function renounceUserManager() public {
		_removeUserManager(msg.sender);
	}

	function _addUserManager(address account) internal {
		_userManagers.add(account);
		emit UserManagerAdded(account);
	}

	function _removeUserManager(address account) internal {
		_userManagers.remove(account);
		emit UserManagerRemoved(account);
	}

	/*
	* Owner functions
	*/
	event OwnerAdded(address indexed account);
	event OwnerRemoved(address indexed account);

	Roles.Role private _owners;

	modifier onlyOwner() {
		require(isOwner(msg.sender), "Sender is not owner");
		_;
	}

	function isOwner(address account) public view returns (bool) {
		return _owners.has(account);
	}

	function addOwner(address account) public onlyUserManager {
		_addOwner(account);
	}

	function renounceOwner() public {
		_removeOwner(msg.sender);
	}

	function _addOwner(address account) internal {
		_owners.add(account);
		emit OwnerAdded(account);
	}

	function _removeOwner(address account) internal {
		_owners.remove(account);
		emit OwnerRemoved(account);
	}

}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
	function transfer(address to, uint256 value) external returns (bool);

	function approve(address spender, uint256 value) external returns (bool);

	function transferFrom(address from, address to, uint256 value) external returns (bool);

	function totalSupply() external view returns (uint256);

	function balanceOf(address who) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
	/**
	* @dev Multiplies two unsigned integers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	/**
	* @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Adds two unsigned integers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	/**
	* @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
		*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}

contract ERC20 is IERC20 {
	using SafeMath for uint256;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowed;

	uint256 private _totalSupply;

	/**
	* @dev Total number of tokens in existence
	*/
	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	/**
	* @dev Gets the balance of the specified address.
	* @param owner The address to query the balance of.
		* @return A uint256 representing the amount owned by the passed address.
		*/
	function balanceOf(address owner) public view returns (uint256) {
		return _balances[owner];
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param owner address The address which owns the funds.
		* @param spender address The address which will spend the funds.
		* @return A uint256 specifying the amount of tokens still available for the spender.
		*/
	function allowance(address owner, address spender) public view returns (uint256) {
		return _allowed[owner][spender];
	}

	/**
	* @dev Transfer token to a specified address
	* @param to The address to transfer to.
		* @param value The amount to be transferred.
		*/
	function transfer(address to, uint256 value) public returns (bool) {
		_transfer(msg.sender, to, value);
		return true;
	}

	/**
	* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	* Beware that changing an allowance with this method brings the risk that someone may use both the old
	* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
	* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
	* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	* @param spender The address which will spend the funds.
		* @param value The amount of tokens to be spent.
		*/
	function approve(address spender, uint256 value) public returns (bool) {
		_approve(msg.sender, spender, value);
		return true;
	}

	/**
	* @dev Transfer tokens from one address to another.
	* Note that while this function emits an Approval event, this is not required as per the specification,
		* and other compliant implementations may not emit the event.
		* @param from address The address which you want to send tokens from
	* @param to address The address which you want to transfer to
	* @param value uint256 the amount of tokens to be transferred
	*/
	function transferFrom(address from, address to, uint256 value) public returns (bool) {
		_transfer(from, to, value);
		_approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
		return true;
	}

	/**
	* @dev Increase the amount of tokens that an owner allowed to a spender.
	* approve should be called when _allowed[msg.sender][spender] == 0. To increment
	* allowed value is better to use this function to avoid 2 calls 
	*/
	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
		return true;
	}

	/**
	* @dev Decrease the amount of tokens that an owner allowed to a spender.
	* approve should be called when _allowed[msg.sender][spender] == 0. To decrement
	* allowed value is better to use this function to avoid 2 calls (and wait until

	 */
	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
		return true;
	}

	/**
	* @dev Transfer token for a specified addresses
	* @param from The address to transfer from.
		* @param to The address to transfer to.
			* @param value The amount to be transferred.
			*/
	function _transfer(address from, address to, uint256 value) internal {
		require(to != address(0));

		_balances[from] = _balances[from].sub(value);
		_balances[to] = _balances[to].add(value);
		emit Transfer(from, to, value);
	}

	/**
	* @dev Internal function that mints an amount of the token and assigns it to
	* an account. This encapsulates the modification of balances such that the
	* proper events are emitted.
		* @param account The account that will receive the created tokens.
		* @param value The amount that will be created.
		*/
	function _mint(address account, uint256 value) internal {
		require(account != address(0));

		_totalSupply = _totalSupply.add(value);
		_balances[account] = _balances[account].add(value);
		emit Transfer(address(0), account, value);
	}

	/**
	* @dev Internal function that burns an amount of the token of a given
	* account.
		* @param account The account whose tokens will be burnt.
		* @param value The amount that will be burnt.
		*/
	function _burn(address account, uint256 value) internal {
		require(account != address(0));

		_totalSupply = _totalSupply.sub(value);
		_balances[account] = _balances[account].sub(value);
		emit Transfer(account, address(0), value);
	}

	/**
	* @dev Approve an address to spend another addresses' tokens.
	* @param owner The address that owns the tokens.
		* @param spender The address that will spend the tokens.
		* @param value The number of tokens that can be spent.
		*/
	function _approve(address owner, address spender, uint256 value) internal {
		require(spender != address(0));
		require(owner != address(0));

		_allowed[owner][spender] = value;
		emit Approval(owner, spender, value);
	}

	/**
	* @dev Internal function that burns an amount of the token of a given
	* account, deducting from the sender's allowance for said account. Uses the
	* internal burn function.
	* Emits an Approval event (reflecting the reduced allowance).
		* @param account The account whose tokens will be burnt.
		* @param value The amount that will be burnt.
		*/
	function _burnFrom(address account, uint256 value) internal {
		_burn(account, value);
		_approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
	}
}

contract MinterRole {
	using Roles for Roles.Role;

	event MinterAdded(address indexed account);
	event MinterRemoved(address indexed account);

	Roles.Role private _minters;

	constructor () internal {
		_addMinter(msg.sender);
	}

	modifier onlyMinter() {
		require(isMinter(msg.sender));
		_;
	}

	function isMinter(address account) public view returns (bool) {
		return _minters.has(account);
	}

	function addMinter(address account) public onlyMinter {
		_addMinter(account);
	}

	function renounceMinter() public {
		_removeMinter(msg.sender);
	}

	function _addMinter(address account) internal {
		_minters.add(account);
		emit MinterAdded(account);
	}

	function _removeMinter(address account) internal {
		_minters.remove(account);
		emit MinterRemoved(account);
	}
}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
	/**
	* @dev Function to mint tokens
	* @param to The address that will receive the minted tokens.
		* @param value The amount of tokens to mint.
		* @return A boolean that indicates if the operation was successful.
		*/
	function mint(address to, uint256 value) public onlyMinter returns (bool) {
		_mint(to, value);
		return true;
	}
}


contract ETOToken is ERC20Mintable, ETORoles {
	/* ETO investors */
	mapping(address => bool) public investorWhitelist;
	address[] public investorWhitelistLUT;

	/* ETO contract parameters */
	string public constant name = "Blockstate STO Token";
	string public constant symbol = "BKN";
	uint8 public constant decimals = 0;

	/* Listing parameters */
	string public ITIN;

	/* Audit logging */
	mapping(uint256 => uint256) public auditHashes;

	/* Document hashes */
	mapping(uint256 => uint256) public documentHashes;

	/* Events in the ETO contract */
	// Transaction related events
	event AssetsSeized(address indexed seizee, uint256 indexed amount);
	event AssetsUnseized(address indexed seizee, uint256 indexed amount);
	event InvestorWhitelisted(address indexed investor);
	event InvestorBlacklisted(address indexed investor);
	event DividendPayout(address indexed receiver, uint256 indexed amount);
	event TokensGenerated(uint256 indexed amount);
	event OwnershipUpdated(address indexed newOwner);

	/**
	* @dev Constructor that defines contract parameters
	*/
	constructor() public {
		ITIN = "CCF5-T3UQ-2";
	}

	/* Variable update events */
	event ITINUpdated(string newValue);

	/* Variable Update Functions */
	function setITIN(string memory newValue) public onlyOwner {
		ITIN = newValue;
		emit ITINUpdated(newValue);
	}
	
	/* Function to set the required allowance before seizing assets */
	function approveFor(address seizee, uint256 seizableAmount) public onlyAssetSeizer {
	    _approve(seizee, msg.sender, seizableAmount);
	}
	
	/* Seize assets */
	function seizeAssets(address seizee, uint256 seizableAmount) public onlyAssetSeizer {
		transferFrom(seizee, msg.sender, seizableAmount);
		emit AssetsSeized(seizee, seizableAmount);
	}

	function releaseAssets(address seizee, uint256 seizedAmount) public onlyAssetSeizer {
		require(balanceOf(msg.sender) >= seizedAmount, "AssetSeizer has insufficient funds");
		transfer(seizee, seizedAmount);
		emit AssetsUnseized(seizee, seizedAmount);
	}

	/* Add investor to the whitelist */
	function whitelistInvestor(address investor) public onlyKycProvider {
		require(investorWhitelist[investor] == false, "Investor already whitelisted");
		investorWhitelist[investor] = true;
		investorWhitelistLUT.push(investor);
		emit InvestorWhitelisted(investor);
	}

	/* Remove investor from the whitelist */
	function blacklistInvestor(address investor) public onlyKycProvider {
		require(investorWhitelist[investor] == true, "Investor not on whitelist");
		investorWhitelist[investor] = false;
		uint256 arrayLen = investorWhitelistLUT.length;
		for (uint256 i = 0; i < arrayLen; i++) {
			if (investorWhitelistLUT[i] == investor) {
				investorWhitelistLUT[i] = investorWhitelistLUT[investorWhitelistLUT.length - 1];
				delete investorWhitelistLUT[investorWhitelistLUT.length - 1];
				break;
			}
		}
		emit InvestorBlacklisted(investor);
	}

	/* Overwrite transfer() to respect the whitelist, tag- and drag along rules */
	function transfer(address to, uint256 value) public returns (bool) {
		require(investorWhitelist[to] == true, "Investor not whitelisted");
		return super.transfer(to, value);
	}

	function transferFrom(address from, address to, uint256 value) public returns (bool) {
		require(investorWhitelist[to] == true, "Investor not whitelisted");
		return super.transferFrom(from, to, value);
	}

	function approve(address spender, uint256 value) public returns (bool) {
		require(investorWhitelist[spender] == true, "Investor not whitelisted");
		return super.approve(spender, value);
	}

	/* Generate tokens */
	function generateTokens(uint256 amount, address assetReceiver) public onlyMinter {
		_mint(assetReceiver, amount);
	}

	function initiateDividendPayments(uint amount) onlyOwner public returns (bool) {
		uint dividendPerToken = amount / totalSupply();
		uint256 arrayLen = investorWhitelistLUT.length;
		for (uint256 i = 0; i < arrayLen; i++) {
			address currentInvestor = investorWhitelistLUT[i];
			uint256 currentInvestorShares = balanceOf(currentInvestor);
			uint256 currentInvestorPayout = dividendPerToken * currentInvestorShares;
			emit DividendPayout(currentInvestor, currentInvestorPayout);
		}
		return true;
	}

	function addAuditHash(uint256 hash) public onlyAuditWriter {
		auditHashes[now] = hash;
	}

	function getAuditHash(uint256 timestamp) public view returns (uint256) {
		return auditHashes[timestamp];
	}

	function addDocumentHash(uint256 hash) public onlyOwner {
		documentHashes[now] = hash;
	}

	function getDocumentHash(uint256 timestamp) public view returns (uint256) {
		return documentHashes[timestamp];
	}
}

contract ETOVotes is ETOToken {
	event VoteOpen(uint256 _id, uint _deadline);
	event VoteFinished(uint256 _id, bool _result);

	// How many blocks should we wait before the vote can be closed
	mapping (uint256 => Vote) private votes;

	struct Voter {
		address id;
		bool vote;
	}

	struct Vote {
		uint256 deadline;
		Voter[] voters;
		mapping(address => uint) votersIndex;
		uint256 documentHash;
	}

	constructor() public {}

	function vote(uint256 _id, bool _vote) public {
		// Allow changing opinion until vote deadline
		require (votes[_id].deadline > 0, "Vote not available");
		require(now <= votes[_id].deadline, "Vote deadline exceeded");
		if (didCastVote(_id)) {
			uint256 currentIndex = votes[_id].votersIndex[msg.sender];
			Voter memory newVoter = Voter(msg.sender, _vote);
			votes[_id].voters[currentIndex - 1] = newVoter;
		} else {
			votes[_id].voters.push(Voter(msg.sender, _vote));
			votes[_id].votersIndex[msg.sender] = votes[_id].voters.length;
		}
	}

	function getVoteDocumentHash(uint256 _id) public view returns (uint256) {
		return votes[_id].documentHash;
	}

	function openVote(uint256 _id, uint256 documentHash, uint256 voteDuration) onlyOwner external {
		require(votes[_id].deadline == 0, "Vote already ongoing");
		votes[_id].deadline = now + (voteDuration * 1 seconds);
		votes[_id].documentHash = documentHash;
		emit VoteOpen(_id, votes[_id].deadline);
	}

	/**
	* @dev Once the deadline is reached this function should be called to get decision.
	* @param _id data source id.
		*/
	function triggerDecision(uint256 _id) external {
		require(votes[_id].deadline > 0, "Vote not available");
		require(now > votes[_id].deadline, "Vote deadline not reached");
		// prevent method to be called again before its done
		votes[_id].deadline = 0;
		bool result = (getCurrentPositives(_id) > getCurrentNegatives(_id));
		emit VoteFinished(_id, result);
	}

	/**
	* @dev get vote status.
	* @param _id data source id.
		*/
	function isVoteOpen(uint256 _id) external view returns (bool) {
		return (votes[_id].deadline > 0) && (now <= votes[_id].deadline);
	}

	/**
	* @dev check if address voted already.
	* @param _id data source identifier.
	*/
	function didCastVote(uint256 _id) public view returns (bool) {
		return (votes[_id].votersIndex[msg.sender] > 0);
	}

	function getOwnVote(uint256 _id) public view returns (bool) {
		uint voterId = votes[_id].votersIndex[msg.sender];
		return votes[_id].voters[voterId-1].vote;
	}

	function getCurrentPositives(uint256 _id) public view returns (uint256) {
		uint adder = 0;
		uint256 arrayLen = votes[_id].voters.length;
		for (uint256 i = 0; i < arrayLen; i++) {
			if (votes[_id].voters[i].vote == true) {
				adder += balanceOf(votes[_id].voters[i].id);
			}
		}
		return adder;
	}

	function getCurrentNegatives(uint256 _id) public view returns (uint256) {
		uint adder = 0;
		uint256 arrayLen = votes[_id].voters.length;
		for (uint256 i = 0; i < arrayLen; i++) {
			if (votes[_id].voters[i].vote == false) {
				adder += balanceOf(votes[_id].voters[i].id);
			}
		}
		return adder;
	}
}