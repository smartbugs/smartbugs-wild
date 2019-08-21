/**
 * Source Code first verified at https://etherscan.io
 * WorldTrade asset Smart Contract v4.1
*/

pragma solidity ^0.4.16;


/*
 * @title Standard Token Contract
 *
 * ERC20-compliant tokens => https://github.com/ethereum/EIPs/issues/20
 * A token is a fungible virtual good that can be traded.
 * ERC-20 Tokens comply to the standard described in the Ethereum ERC-20 proposal.
 * Basic, standardized Token contract. Defines the functions to check token balances
 * send tokens, send tokens on behalf of a 3rd party and the corresponding approval process.
 *
 */
contract Token {

	// **** BASE FUNCTIONALITY
	// @notice For debugging purposes when using solidity online browser
	function whoAmI()  constant returns (address) {
	    return msg.sender;
	}

	// SC owners:
	
	address owner;
	
	function isOwner() returns (bool) {
		if (msg.sender == owner) return true;
		return false;
	}

	// **** EVENTS

	// @notice A generic error log
	event Error(string error);


	// **** DATA
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public initialSupply; // Initial and total token supply
	uint256 public totalSupply;
	// bool allocated = false; // True after defining token parameters and initial mint
	
	// Public variables of the token, all used for display
	// HumanStandardToken is a specialisation of ERC20 defining these parameters
	string public name;
	string public symbol;
	uint8 public decimals;
	string public standard = 'H0.1';

	// **** METHODS
	
	// Get total amount of tokens, totalSupply is a public var actually
	// function totalSupply() constant returns (uint256 totalSupply) {}
	
	// Get the account balance of another account with address _owner
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}
 
 	// Send _amount amount of tokens to address _to
	function transfer(address _to, uint256 _amount) returns (bool success) {
		if (balances[msg.sender] < _amount) {
			Error('transfer: the amount to transfer is higher than your token balance');
			return false;
		}
		balances[msg.sender] -= _amount;
		balances[_to] += _amount;
		Transfer(msg.sender, _to, _amount);

		return true;
	}
 
 	// Send _amount amount of tokens from address _from to address _to
 	// The transferFrom method is used for a withdraw workflow, allowing contracts to send 
 	// tokens on your behalf, for example to "deposit" to a contract address and/or to charge 
 	// fees in sub-currencies; the command should fail unless the _from account has 
 	// deliberately authorized the sender of the message via some mechanism
	function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
		if (balances[_from] < _amount) {
			Error('transfer: the amount to transfer is higher than the token balance of the source');
			return false;
		}
		if (allowed[_from][msg.sender] < _amount) {
			Error('transfer: the amount to transfer is higher than the maximum token transfer allowed by the source');
			return false;
		}
		balances[_from] -= _amount;
		balances[_to] += _amount;
		allowed[_from][msg.sender] -= _amount;
		Transfer(_from, _to, _amount);

		return true;
	}
 
 	// Allow _spender to withdraw from your account, multiple times, up to the _amount amount. 
 	// If this function is called again it overwrites the current allowance with _amount.
	function approve(address _spender, uint256 _amount) returns (bool success) {
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		
		return true;
	}
 
 	// Returns the amount which _spender is still allowed to withdraw from _owner
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
	
	// Constructor: set up token properties and owner token balance
	function Token() {
		// This is the constructor, so owner should be equal to msg.sender, and this method should be called just once
		owner = msg.sender;
		
		// make sure owner address is configured
		// if(owner == 0x0) throw;

		// owner address can call this function
		// if (msg.sender != owner ) throw;

		// call this function just once
		// if (allocated) throw;

		initialSupply = 50000000 * 1000000; // 50M tokens, 6 decimals
		totalSupply = initialSupply;
		
		name = "WorldTrade";
		symbol = "WTE";
		decimals = 6;

		balances[owner] = totalSupply;
		Transfer(this, owner, totalSupply);

		// allocated = true;
	}

	// **** EVENTS
	
	// Triggered when tokens are transferred
	event Transfer(address indexed _from, address indexed _to, uint256 _amount);
	
	// Triggered whenever approve(address _spender, uint256 _amount) is called
	event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}


// Interface of issuer contract, just to cast the contract address and make it callable from the asset contract
contract IFIssuers {
	
	// **** DATA
	
	// **** FUNCTIONS
	function isIssuer(address _issuer) constant returns (bool);
}


contract Asset is Token {
	// **** DATA
	
	/** Asset states
	*
	* - Released: Once issued the asset stays as released until sent for free to someone specified by issuer
	* - ForSale: The asset belongs to a user and is open to be sold
	* - Unfungible: The asset cannot be sold, remaining to the user it belongs to.
	*/
	enum assetStatus { Released, ForSale, Unfungible }
	// https://ethereum.stackexchange.com/questions/1807/enums-in-solidity
	
	struct asst {
		uint256 assetId;
		address assetOwner;
		address issuer;
		string content; // a JSON object containing the image data of the asset and its title
		uint256 sellPrice; // in WorldTrade tokens, how many of them for this asset
		assetStatus status; // behaviour (tradability) of the asset depends upon its status
	}

	mapping (uint256 => asst) assetsById;
	uint256 lastAssetId; // Last assetId
	address public SCIssuers; // Contract that defines who is an issuer and who is not
	uint256 assetFeeIssuer; // Fee percentage for Issuer on every asset sale transaction
	uint256 assetFeeWorldTrade; // Fee percentage for WorldTrade on every asset sale transaction
	

	// **** METHODS
	
	// Constructor
	function Asset(address _SCIssuers) {
		SCIssuers = _SCIssuers;
	}
	
	// Queries the asset, knowing the id
	function getAssetById(uint256 assetId) constant returns (uint256 _assetId, address _assetOwner, address _issuer, string _content, uint256 _sellPrice, uint256 _status) {
		return (assetsById[assetId].assetId, assetsById[assetId].assetOwner, assetsById[assetId].issuer, assetsById[assetId].content, assetsById[assetId].sellPrice, uint256(assetsById[assetId].status));
	}

	// Seller sends an owned asset to a buyer, providing its allowance matches token price and transfer the tokens from buyer
	function sendAssetTo(uint256 assetId, address assetBuyer) returns (bool) {
		// assetId must not be zero
		if (assetId == 0) {
			Error('sendAssetTo: assetId must not be zero');
			return false;
		}

		// Check whether the asset belongs to the seller
		if (assetsById[assetId].assetOwner != msg.sender) {
			Error('sendAssetTo: the asset does not belong to you, the seller');
			return false;
		}
		
		if (assetsById[assetId].sellPrice > 0) { // for non-null token paid transactions
			// Check whether there is balance enough from the buyer to get its tokens
			if (balances[assetBuyer] < assetsById[assetId].sellPrice) {
				Error('sendAssetTo: there is not enough balance from the buyer to get its tokens');
				return false;
			}

			// Check whether there is allowance enough from the buyer to get its tokens
			if (allowance(assetBuyer, msg.sender) < assetsById[assetId].sellPrice) {
				Error('sendAssetTo: there is not enough allowance from the buyer to get its tokens');
				return false;
			}

			// Get the buyer tokens
			if (!transferFrom(assetBuyer, msg.sender, assetsById[assetId].sellPrice)) {
				Error('sendAssetTo: transferFrom failed'); // This shouldn't happen ever, but just in case...
				return false;
			}
		}
		
		// Set the asset status to Unfungible
		assetsById[assetId].status = assetStatus.Unfungible;
		
		// Transfer the asset to the buyer
		assetsById[assetId].assetOwner = assetBuyer;
		
		// Event log
		SendAssetTo(assetId, assetBuyer);
		
		return true;
	}
	
	// Buyer gets an asset providing it is in ForSale status, and pays the corresponding tokens to the seller/owner. amount must match assetPrice to have a deal.
	function buyAsset(uint256 assetId, uint256 amount) returns (bool) {
		// assetId must not be zero
		if (assetId == 0) {
			Error('buyAsset: assetId must not be zero');
			return false;
		}

		// Check whether the asset is in ForSale status
		if (assetsById[assetId].status != assetStatus.ForSale) {
			Error('buyAsset: the asset is not for sale');
			return false;
		}
		
		// Check whether the asset price is the same as amount
		if (assetsById[assetId].sellPrice != amount) {
			Error('buyAsset: the asset price does not match the specified amount');
			return false;
		}
		
		if (assetsById[assetId].sellPrice > 0) { // for non-null token paid transactions
			// Check whether there is balance enough from the buyer to pay the asset
			if (balances[msg.sender] < assetsById[assetId].sellPrice) {
				Error('buyAsset: there is not enough token balance to buy this asset');
				return false;
			}
			
			// Calculate the seller income
			uint256 sellerIncome = assetsById[assetId].sellPrice * (1000 - assetFeeIssuer - assetFeeWorldTrade) / 1000;

			// Send the buyer's tokens to the seller
			if (!transfer(assetsById[assetId].assetOwner, sellerIncome)) {
				Error('buyAsset: seller token transfer failed'); // This shouldn't happen ever, but just in case...
				return false;
			}
			
			// Send the issuer's fee
			uint256 issuerIncome = assetsById[assetId].sellPrice * assetFeeIssuer / 1000;
			if (!transfer(assetsById[assetId].issuer, issuerIncome)) {
				Error('buyAsset: issuer token transfer failed'); // This shouldn't happen ever, but just in case...
				return false;
			}
			
			// Send the WorldTrade's fee
			uint256 WorldTradeIncome = assetsById[assetId].sellPrice * assetFeeWorldTrade / 1000;
			if (!transfer(owner, WorldTradeIncome)) {
				Error('buyAsset: WorldTrade token transfer failed'); // This shouldn't happen ever, but just in case...
				return false;
			}
		}
				
		// Set the asset status to Unfungible
		assetsById[assetId].status = assetStatus.Unfungible;
		
		// Transfer the asset to the buyer
		assetsById[assetId].assetOwner = msg.sender;
		
		// Event log
		BuyAsset(assetId, amount);
		
		return true;
	}
	
	
	// To limit issue functions just to authorized issuers
	modifier onlyIssuer() {
	    if (!IFIssuers(SCIssuers).isIssuer(msg.sender)) {
	    	Error('onlyIssuer function called by user that is not an authorized issuer');
	    } else {
	    	_;
	    }
	}

	
	// To be called by issueAssetTo() and properly authorized issuers
	function issueAsset(string content, uint256 sellPrice) onlyIssuer internal returns (uint256 nextAssetId) {
		// Find out next asset Id
		nextAssetId = lastAssetId + 1;
		
		assetsById[nextAssetId].assetId = nextAssetId;
		assetsById[nextAssetId].assetOwner = msg.sender;
		assetsById[nextAssetId].issuer = msg.sender;
		assetsById[nextAssetId].content = content;
		assetsById[nextAssetId].sellPrice = sellPrice;
		assetsById[nextAssetId].status = assetStatus.Released;
		
		// Update lastAssetId
		lastAssetId++;

		// Event log
		IssueAsset(nextAssetId, msg.sender, sellPrice);
		
		return nextAssetId;
	}
	
	// Issuer sends a new free asset to a given user as a gift
	function issueAssetTo(string content, address to) returns (bool) {
		uint256 assetId = issueAsset(content, 0); // 0 tokens, as a gift
		if (assetId == 0) {
			Error('issueAssetTo: asset has not been properly issued');
			return (false);
		}
		
		// The brand new asset is inmediatly sent to the recipient
		return(sendAssetTo(assetId, to));
	}
	
	// Seller can block tradability of its assets
	function setAssetUnfungible(uint256 assetId) returns (bool) {
		// assetId must not be zero
		if (assetId == 0) {
			Error('setAssetUnfungible: assetId must not be zero');
			return false;
		}

		// Check whether the asset belongs to the caller
		if (assetsById[assetId].assetOwner != msg.sender) {
			Error('setAssetUnfungible: only owners of the asset are allowed to update its status');
			return false;
		}
		
		assetsById[assetId].status = assetStatus.Unfungible;

		// Event log
		SetAssetUnfungible(assetId, msg.sender);
		
		return true;
	}

	// Seller updates the price of its assets and its status to ForSale
	function setAssetPrice(uint256 assetId, uint256 sellPrice) returns (bool) {
		// assetId must not be zero
		if (assetId == 0) {
			Error('setAssetPrice: assetId must not be zero');
			return false;
		}

		// Check whether the asset belongs to the caller
		if (assetsById[assetId].assetOwner != msg.sender) {
			Error('setAssetPrice: only owners of the asset are allowed to set its price and update its status');
			return false;
		}
		
		assetsById[assetId].sellPrice = sellPrice;
		assetsById[assetId].status = assetStatus.ForSale;

		// Event log
		SetAssetPrice(assetId, msg.sender, sellPrice);
		
		return true;
	}

	// Owner updates the fees for assets sale transactions
	function setAssetSaleFees(uint256 feeIssuer, uint256 feeWorldTrade) returns (bool) {
		// Check this is called by owner
		if (!isOwner()) {
			Error('setAssetSaleFees: only Owner is authorized to update asset sale fees.');
			return false;
		}
		
		// Check new fees are consistent
		if (feeIssuer + feeWorldTrade > 1000) {
			Error('setAssetSaleFees: added fees exceed 100.0%. Not updated.');
			return false;
		}
		
		assetFeeIssuer = feeIssuer;
		assetFeeWorldTrade = feeWorldTrade;

		// Event log
		SetAssetSaleFees(feeIssuer, feeWorldTrade);
		
		return true;
	}



	// **** EVENTS

	// Triggered when a seller sends its asset to a buyer and receives the corresponding tokens
	event SendAssetTo(uint256 assetId, address assetBuyer);
	
	// Triggered when a buyer sends its tokens to a seller and receives the specified asset
	event BuyAsset(uint256 assetId, uint256 amount);

	// Triggered when the admin issues a new asset
	event IssueAsset(uint256 nextAssetId, address assetOwner, uint256 sellPrice);
	
	// Triggered when the user updates its asset status to Unfungible
	event SetAssetUnfungible(uint256 assetId, address assetOwner);

	// Triggered when the user updates its asset price and status to ForSale
	event SetAssetPrice(uint256 assetId, address assetOwner, uint256 sellPrice);
	
	// Triggered when the owner updates the asset sale fees
	event SetAssetSaleFees(uint256 feeIssuer, uint256 feeWorldTrade);
}