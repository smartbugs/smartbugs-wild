pragma solidity ^0.4.25;

library SafeMath
{
	function mul(uint a, uint b) internal pure returns (uint)
	{
		if (a == 0)
		{
			return 0;
		}
		uint c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint)
	{
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint a, uint b) internal pure returns (uint)
	{
		assert(b <= a);
		return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint)
	{
		uint c = a + b;
		assert(c >= a);
		return c;
	}
}

contract ERC721
{
	function approve(address _to, uint _tokenId) public;
	function balanceOf(address _owner) public view returns (uint balance);
	function implementsERC721() public pure returns (bool);
	function ownerOf(uint _tokenId) public view returns (address addr);
	function takeOwnership(uint _tokenId) public;
	function totalSupply() public view returns (uint total);
	function transferFrom(address _from, address _to, uint _tokenId) public;
	function transfer(address _to, uint _tokenId) public;

	event LogTransfer(address indexed from, address indexed to, uint tokenId);
	event LogApproval(address indexed owner, address indexed approved, uint tokenId);
}

contract CryptoCricketToken is ERC721
{
	event LogBirth(uint tokenId, string name, uint internalTypeId, uint Price);
	event LogSnatch(uint tokenId, string tokenName, address oldOwner, address newOwner, uint oldPrice, uint newPrice);
	event LogTransfer(address from, address to, uint tokenId);

	string public constant name = "CryptoCricket";
	string public constant symbol = "CryptoCricketToken";

	uint private commision = 4;

	mapping (uint => uint) private startingPrice;

	/// @dev A mapping from player IDs to the address that owns them. All players have some valid owner address.
	mapping (uint => address) public playerIndexToOwner;

	// @dev A mapping from owner address to count of tokens that address owns. Used internally inside balanceOf() to resolve ownership count.
	mapping (address => uint) private ownershipTokenCount;

	/// @dev A mapping from PlayerIDs to an address that has been approved to call transferFrom(). Each Player can only have one approved address for transfer at any time. A zero value means no approval is outstanding.
	mapping (uint => address) public playerIndexToApproved;

	// @dev A mapping from PlayerIDs to the price of the token.
	mapping (uint => uint) private playerIndexToPrice;

	// @dev A mapping from PlayerIDs to the reward price of the token obtained while selling.
	mapping (uint => uint) private playerIndexToRewardPrice;

	// The addresses of the accounts (or contracts) that can execute actions within each roles.
	address public ceoAddress;
	address public devAddress;

	struct Player
	{
		string name;
		uint internalTypeId;
	}

	Player[] private players;

	/// @dev Access modifier for CEO-only functionality
	modifier onlyCEO()
	{
		require(msg.sender == ceoAddress);
		_;
	}

	modifier onlyDevORCEO()
	{
		require(msg.sender == devAddress || msg.sender == ceoAddress);
		_;
	}

	constructor(address _ceo, address _dev) public
	{
		ceoAddress = _ceo;
		devAddress = _dev;
		startingPrice[0] = 0.005 ether; // 2x
		startingPrice[1] = 0.007 ether; // 2.5x
		startingPrice[2] = 0.005 ether; // 1.5x
	}

	/// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
	/// @param _to The address to be granted transfer approval. Pass address(0) to
	///    clear all approvals.
	/// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
	/// @dev Required for ERC-721 compliance.
	function approve(address _to, uint _tokenId) public
	{
		require(owns(msg.sender, _tokenId));
		playerIndexToApproved[_tokenId] = _to;
		emit LogApproval(msg.sender, _to, _tokenId);
	}

	function getRewardPrice(uint buyingPrice, uint _internalTypeId) internal view returns(uint rewardPrice)
	{
		if(_internalTypeId == 0) //Cricket Board Card
		{
			rewardPrice = SafeMath.div(SafeMath.mul(buyingPrice, 200), 100);
		}
		else if(_internalTypeId == 1) //Country Card
		{
			rewardPrice = SafeMath.div(SafeMath.mul(buyingPrice, 250), 100);
		}
		else //Player Card
		{
			rewardPrice = SafeMath.div(SafeMath.mul(buyingPrice, 150), 100);
		}

		rewardPrice = uint(SafeMath.div(SafeMath.mul(rewardPrice, SafeMath.sub(100, commision)), 100));
		return rewardPrice;
	}


	/// For creating Player
	function createPlayer(string _name, uint _internalTypeId) public onlyDevORCEO
	{
		require (_internalTypeId >= 0 && _internalTypeId <= 2);
		Player memory _player = Player({name: _name, internalTypeId: _internalTypeId});
		uint newPlayerId = players.push(_player) - 1;
		playerIndexToPrice[newPlayerId] = startingPrice[_internalTypeId];
		playerIndexToRewardPrice[newPlayerId] = getRewardPrice(playerIndexToPrice[newPlayerId], _internalTypeId);

		emit LogBirth(newPlayerId, _name, _internalTypeId, startingPrice[_internalTypeId]);

		// This will assign ownership, and also emit the Transfer event as per ERC721 draft
		_transfer(address(0), address(this), newPlayerId);
	}

	function payout(address _to) public onlyCEO
	{
		if(_addressNotNull(_to))
		{
			_to.transfer(address(this).balance);
		}
		else
		{
			ceoAddress.transfer(address(this).balance);
		}
	}

	// Allows someone to send ether and obtain the token
	function purchase(uint _tokenId) public payable
	{
		address oldOwner = playerIndexToOwner[_tokenId];
		uint sellingPrice = playerIndexToPrice[_tokenId];

		require(oldOwner != msg.sender);
		require(_addressNotNull(msg.sender));
		require(msg.value >= sellingPrice);

		address newOwner = msg.sender;
		uint payment = uint(SafeMath.div(SafeMath.mul(sellingPrice, SafeMath.sub(100, commision)), 100));
		uint purchaseExcess = SafeMath.sub(msg.value, sellingPrice);
		uint _internalTypeId = players[_tokenId].internalTypeId;

		if(_internalTypeId == 0) //Cricket Board Card
		{
			playerIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 100);
		}
		else if(_internalTypeId == 1) //Country Card
		{
			playerIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 250), 100);
		}
		else //Player Card
		{
			playerIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 150), 100);
		}

		_transfer(oldOwner, newOwner, _tokenId);
		emit LogSnatch(_tokenId, players[_tokenId].name, oldOwner, newOwner, sellingPrice, playerIndexToPrice[_tokenId]);

		playerIndexToRewardPrice[_tokenId] = getRewardPrice(playerIndexToPrice[_tokenId], _internalTypeId);

		if (oldOwner != address(this))
		{
			oldOwner.transfer(payment);
		}
		msg.sender.transfer(purchaseExcess);
	}

	/// @param _owner The owner whose soccer player tokens we are interested in.
	/// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
	///    expensive (it walks the entire Players array looking for players belonging to owner),
	///    but it also returns a dynamic array, which is only supported for web3 calls, and
	///    not contract-to-contract calls.
	function tokensOfOwner(address _owner) public view returns(uint[] ownerTokens)
	{
		uint tokenCount = balanceOf(_owner);
		if (tokenCount == 0)
		{
			return new uint[](0);
		}
		else
		{
			uint[] memory result = new uint[](tokenCount);
			uint totalPlayers = totalSupply();
			uint resultIndex = 0;

			uint playerId;
			for (playerId = 0; playerId <= totalPlayers; playerId++)
			{
				if (playerIndexToOwner[playerId] == _owner)
				{
					result[resultIndex] = playerId;
					resultIndex++;
				}
			}
			return result;
		}
	}

	/// Owner initates the transfer of the token to another account
	/// @param _to The address for the token to be transferred to.
	/// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
	/// @dev Required for ERC-721 compliance.
	function transfer(address _to, uint _tokenId) public
	{
		require(owns(msg.sender, _tokenId));
		require(_addressNotNull(_to));

		_transfer(msg.sender, _to, _tokenId);
	}

	/// Third-party initiates transfer of token from address _from to address _to
	/// @param _from The address for the token to be transferred from.
	/// @param _to The address for the token to be transferred to.
	/// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
	/// @dev Required for ERC-721 compliance.
	function transferFrom(address _from, address _to, uint _tokenId) public
	{
		require(owns(_from, _tokenId));
		require(_approved(_to, _tokenId));
		require(_addressNotNull(_to));
		_transfer(_from, _to, _tokenId);
	}

	/// @dev Assigns ownership of a specific Player to an address.
	function _transfer(address _from, address _to, uint _tokenId) private
	{
		// Since the number of players is capped to 2^32 we can't overflow this
		ownershipTokenCount[_to]++;
		//transfer ownership
		playerIndexToOwner[_tokenId] = _to;

		// When creating new players _from is 0x0, but we can't account that address.
		if (_addressNotNull(_from))
		{
			ownershipTokenCount[_from]--;
			// clear any previously approved ownership exchange
			delete playerIndexToApproved[_tokenId];
		}

		// Emit the transfer event.
		emit LogTransfer(_from, _to, _tokenId);
	}

	/// Safety check on _to address to prevent against an unexpected 0x0 default.
	function _addressNotNull(address _to) private pure returns (bool)
	{
		return (_to != address(0));
	}

	/// For querying balance of a particular account
	/// @param _owner The address for balance query
	/// @dev Required for ERC-721 compliance.
	function balanceOf(address _owner) public view returns (uint balance)
	{
		return ownershipTokenCount[_owner];
	}

	/// @notice Returns all the relevant information about a specific player.
	/// @param _tokenId The tokenId of the player of interest.
	function getPlayer(uint _tokenId) public view returns (string playerName, uint internalTypeId, uint sellingPrice, address owner)
	{
		Player storage player = players[_tokenId];
		playerName = player.name;
		internalTypeId = player.internalTypeId;
		sellingPrice = playerIndexToPrice[_tokenId];
		owner = playerIndexToOwner[_tokenId];
	}

	/// For querying owner of token
	/// @param _tokenId The tokenID for owner inquiry
	/// @dev Required for ERC-721 compliance.
	function ownerOf(uint _tokenId) public view returns (address owner)
	{
		owner = playerIndexToOwner[_tokenId];
		require (_addressNotNull(owner));
	}

	/// For checking approval of transfer for address _to
	function _approved(address _to, uint _tokenId) private view returns (bool)
	{
		return playerIndexToApproved[_tokenId] == _to;
	}

	/// Check for token ownership
	function owns(address claimant, uint _tokenId) private view returns (bool)
	{
		return (claimant == playerIndexToOwner[_tokenId]);
	}

	function priceOf(uint _tokenId) public view returns (uint price)
	{
		return playerIndexToPrice[_tokenId];
	}

	function rewardPriceOf(uint _tokenId) public view returns (uint price)
	{
		return playerIndexToRewardPrice[_tokenId];
	}

	/// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
	/// @param _newCEO The address of the new CEO
	function setCEO(address _newCEO) public onlyCEO
	{
		require (_addressNotNull(_newCEO));
		ceoAddress = _newCEO;
	}

	/// @dev Assigns a new address to act as the Dev. Only available to the current CEO.
	/// @param _newDev The address of the new Dev
	function setDev(address _newDev) public onlyCEO
	{
		require (_addressNotNull(_newDev));
		devAddress = _newDev;
	}

	/// @notice Allow pre-approved user to take ownership of a token
	/// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
	/// @dev Required for ERC-721 compliance.
	function takeOwnership(uint _tokenId) public
	{
		address newOwner = msg.sender;
		address oldOwner = playerIndexToOwner[_tokenId];

		// Safety check to prevent against an unexpected 0x0 default.
		require(_addressNotNull(newOwner));

		// Making sure transfer is approved
		require(_approved(newOwner, _tokenId));

		_transfer(oldOwner, newOwner, _tokenId);
	}

	/// @dev Assigns a new commison percentage. Only available to the current CEO.
	/// @param _newCommision The new commison
	function updateCommision (uint _newCommision) public onlyCEO
	{
		require (_newCommision > 0 && _newCommision < 100);
		commision = _newCommision;
	}

	function implementsERC721() public pure returns (bool)
	{
		return true;
	}

	/// For querying totalSupply of token
	/// @dev Required for ERC-721 compliance.
	function totalSupply() public view returns (uint total)
	{
		return players.length;
	}
}