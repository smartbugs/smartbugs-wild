pragma solidity ^0.4.18; // solhint-disable-line

contract FootieToken {

	/*** EVENTS ***/

	/// @dev The Birth event is fired whenever a new team comes into existence.
	event Birth(uint256 teamId, string name, address owner);

	/// @dev Transfer event as defined in current draft of ERC721. 
	///  ownership is assigned, including births.
	event Transfer(address from, address to, uint256 teamId);

	/// @dev The TeamSold event is fired, as you might expect, whenever a team is sold.
	event TeamSold(uint256 index, uint256 oldPrice, uint256 newPrice, address prevOwner, address newOwne, string name);


	/*** CONSTANTS ***/

	/// @notice Name and symbol of the non fungible token, as defined in ERC721.
	string public constant NAME = "CryptoFootie"; // solhint-disable-line
	string public constant SYMBOL = "FootieToken"; // solhint-disable-line

	uint256 private startingPrice = 0.002 ether;
	uint256 private constant TEAM_CREATION_LIMIT = 1000;
	uint256 private princeIncreasePercentage = 24;


	/*** STORAGE ***/

	/// @dev A mapping from team IDs to the address that owns them. All teams have
	///  some valid owner address.
	mapping (uint256 => address) private teamIndexToOwner;

	// @dev A mapping from the owner address to count of teams that address owns.
	//  Used internally inside balanceOf() to resolve ownership count.
	mapping (address => uint256) private ownershipTeamCount;

	/// @dev A mapping from teamIDs to an address that has been approved to call
	///  transferFrom(). Each tram can only have one approved address for transfer
	///  at any time. A zero value means no approval is outstanding.
	mapping (uint256 => address) private teamIndexToApproved;

	// @dev A mapping from teamIDs to the price of the token.
	mapping (uint256 => uint256) private teamIndexToPrice;

	// @dev A mapping from teamIDs to the price of the token.
	mapping (uint256 => uint256) private teamIndexToGoals;

	// The address of the account that can execute actions within each roles.
	address public creatorAddress;

	// Keeps track of how many teams have been created
	uint256 public teamsCreatedCount;


	/*** DATATYPES ***/
	struct Team {
		string name;
	}
	Team[] private teams;


	/*** ACCESS MODIFIERS ***/
	/// @dev Access modifier for Creator-only functionality
	modifier onlyCreator() {
		require(msg.sender == creatorAddress);
		_;
	}


	/*** CONSTRUCTOR ***/
	function FootieToken() public {
		creatorAddress = msg.sender;
	}

	function _createTeam(string _name, uint256 _price) public onlyCreator {
		require(teamsCreatedCount < TEAM_CREATION_LIMIT);
		// set initial price
		if (_price <= 0) {
			_price = startingPrice;
		}

		// increase the number of teams created so far
		teamsCreatedCount++;

		Team memory _team = Team({
			name: _name
		});
		uint256 newteamId = teams.push(_team) - 1;

		// It's probably never going to happen, 4 billion tokens are A LOT, but
		// let's just be 100% sure we never let this happen.
		require(newteamId == uint256(uint32(newteamId)));

		// send event to DAPP or anyone interested
		Birth(newteamId, _name, creatorAddress);

		teamIndexToPrice[newteamId] = _price;

		// This will assign ownership, and also emit the Transfer event as
		// per ERC721 draft
		_transfer(creatorAddress, creatorAddress, newteamId);
	}

	/// @notice Returns all the relevant information about a specific team.
	/// @param _index The index (teamId) of the team of interest.
	function getTeam(uint256 _index) public view returns (string teamName, uint256 sellingPrice, address owner, uint256 goals) {
		Team storage team = teams[_index];
		teamName = team.name;
		sellingPrice = teamIndexToPrice[_index];
		owner = teamIndexToOwner[_index];
		goals = teamIndexToGoals[_index];
	}
	
	/// For querying balance of a particular account
	/// @param _owner The address for balance query
	/// @dev Required for ERC-721 compliance.
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return ownershipTeamCount[_owner];
	}

	/// For querying owner of token
	/// @param _index The teamID for owner inquiry
	/// @dev Required for ERC-721 compliance.
	function ownerOf(uint256 _index) public view returns (address owner) {
		owner = teamIndexToOwner[_index];
		require(owner != address(0));
	}

	// Allows someone to send ether and buy a team
	function buyTeam(uint256 _index) public payable {
		address oldOwner = teamIndexToOwner[_index];
		address newOwner = msg.sender;

		uint256 sellingPrice = teamIndexToPrice[_index];

		// Making sure token owner is not sending to self
		require(oldOwner != newOwner);

		// Safety check to prevent against an unexpected 0x0 default.
		require(_addressNotNull(newOwner));

		// Making sure sent amount is greater than or equal to the sellingPrice
		require(msg.value >= sellingPrice);


		// 96% goes to old owner
		uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 96), 100));

		// 4% goes to the contract creator address
		uint256 fee = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 4), 100));
		
		// any excess (the new owner payed more than needed) will be refunded to the new owner
		uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);

		// Update price
		teamIndexToPrice[_index] = sellingPrice + SafeMath.div(SafeMath.mul(sellingPrice, princeIncreasePercentage), 100);

		//Update transaction count
		teamIndexToGoals[_index] = teamIndexToGoals[_index] + 1;

		// send the money to the previous owner
		oldOwner.transfer(payment);
		// pay fee
		creatorAddress.transfer(fee);

		// store the transfer
		_transfer(oldOwner, newOwner, _index);

		TeamSold(_index, sellingPrice, teamIndexToPrice[_index], oldOwner, newOwner, teams[_index].name);

		msg.sender.transfer(purchaseExcess);
	}



	/*** PRIVATE FUNCTIONS ***/

	/// Safety check on _to address to prevent against an unexpected 0x0 default.
	function _addressNotNull(address _to) private pure returns (bool) {
		return _to != address(0);
	}

	/// @dev Assigns ownership of a specific Person to an address.
	function _transfer(address _from, address _to, uint256 _index) private {
		// Since the number of persons is capped to 2^32 we can't overflow this
		ownershipTeamCount[_to]++;
		//transfer ownership
		teamIndexToOwner[_index] = _to;

		// Emit the transfer event.
		Transfer(_from, _to, _index);
	}

}





library SafeMath {

	/**
	* @dev Multiplies two numbers, throws on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two numbers, truncating the quotient.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	/**
	* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	/**
	* @dev Adds two numbers, throws on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
	return c;
	}
}