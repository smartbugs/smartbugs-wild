pragma solidity ^0.4.24;


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers from ERC721 asset contracts.
 * See (https://github.com/OpenZeppelin/openzeppelin-solidity)
 */
contract ERC721Receiver {

	/**
	 * @dev Magic value to be returned upon successful reception of an NFT.
	 * Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
	 * which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
	 */
	bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

	/**
	 * @notice Handle the receipt of an NFT
	 * @dev The ERC721 smart contract calls this function on the recipient
	 * after a `safetransfer`. This function MAY throw to revert and reject the
	 * transfer. Return of other than the magic value MUST result in the
	 * transaction being reverted.
	 * Note: the contract address is always the message sender.
	 * @param _operator The address which called `safeTransferFrom` function
	 * @param _from The address which previously owned the token
	 * @param _tokenId The NFT identifier which is being transferred
	 * @param _data Additional data with no specified format
	 * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
	 */
	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}


/**
 * @title PixelCon Market
 * @notice This is the main market contract for buying and selling PixelCons. Listings are created by transferring PixelCons to this contract through
 * the PixelCons contract. Listings can be removed from the market at any time. An admin user has the ability to change market parameters such as min 
 * and max acceptable values, as well as the ability to lock the market from any new listings and/or purchases. The admin cannot prevent users from
 * removing their listings at any time.
 * @author PixelCons
 */
contract PixelConMarket is ERC721Receiver {

	/** @dev Different contract lock states */
	uint8 private constant LOCK_NONE = 0;
	uint8 private constant LOCK_NO_LISTING = 1;
	uint8 private constant LOCK_REMOVE_ONLY = 2;

	/** @dev Math constants */
	uint256 private constant WEI_PER_GWEI = 1000000000;
	uint256 private constant FEE_RATIO = 100000;


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////// Structs ///////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** @dev Market listing data */
	struct Listing {
		uint64 startAmount; //gwei
		uint64 endAmount; //gwei
		uint64 startDate;
		uint64 duration;
		//// ^256bits ////
		address seller;
		uint32 sellerIndex;
		uint64 forSaleIndex;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////// Storage ///////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** @dev Market modifiable parameters */
	uint32 internal devFee; //percent*100000
	uint32 internal priceUpdateInterval; //seconds
	uint32 internal startDateRoundValue; //seconds
	uint32 internal durationRoundValue; //seconds
	uint64 internal maxDuration; //seconds
	uint64 internal minDuration; //seconds
	uint256 internal maxPrice; //wei
	uint256 internal minPrice; //wei

	/** @dev Admin data */
	PixelCons internal pixelconsContract;
	address internal admin;
	uint8 internal systemLock;

	////////////////// Listings //////////////////

	/** @dev Links a seller to the PixelCon indexes he/she has for sale */
	mapping(address => uint64[]) internal sellerPixelconIndexes;

	/** @dev Links a PixelCon index to market listing */
	mapping(uint64 => Listing) internal marketPixelconListings;

	/** @dev Keeps track of all PixelCons for sale by index */
	uint64[] internal forSalePixelconIndexes;


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////// Events ////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** @dev Market listing events */
	event Create(uint64 indexed _tokenIndex, address indexed _seller, uint256 _startPrice, uint256 _endPrice, uint64 _duration);
	event Purchase(uint64 indexed _tokenIndex, address indexed _buyer, uint256 _price);
	event Remove(uint64 indexed _tokenIndex, address indexed _operator);


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////// Modifiers ///////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**  @dev Requires sender be the designated admin */
	modifier onlyAdmin {
		require(msg.sender == admin, "Only the admin can call this function");
		_;
	}

	/** @dev Small validators for quick validation of function parameters */
	modifier validAddress(address _address) {
		require(_address != address(0), "Invalid address");
		_;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////// Market Admin ///////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * @notice Contract constructor
	 * @param _admin Admin address
	 * @param _pixelconContract PixelCon contract address
	 */
	constructor(address _admin, address _pixelconContract) public 
	{
		require(_admin != address(0), "Invalid address");
		require(_pixelconContract != address(0), "Invalid address");
		admin = _admin;
		pixelconsContract = PixelCons(_pixelconContract);
		systemLock = LOCK_REMOVE_ONLY;

		//default values
		devFee = 1000;
		priceUpdateInterval = 1 * 60 * 60;
		startDateRoundValue = 5 * 60;
		durationRoundValue = 5 * 60;
		maxDuration = 30 * 24 * 60 * 60;
		minDuration = 1 * 24 * 60 * 60;
		maxPrice = 100000000000000000000;
		minPrice = 1000000000000000;
	}

	/**
	 * @notice Change the market admin
	 * @dev Only the market admin can access this function
	 * @param _newAdmin The new admin address
	 */
	function adminChange(address _newAdmin) public onlyAdmin validAddress(_newAdmin) 
	{
		admin = _newAdmin;
	}

	/**
	 * @notice Set the lock state of the market
	 * @dev Only the market admin can access this function
	 * @param _lock Flag for locking the market
	 * @param _allowPurchase Flag for allowing purchases while locked
	 */
	function adminSetLock(bool _lock, bool _allowPurchase) public onlyAdmin 
	{
		if (_lock) {
			if (_allowPurchase) systemLock = LOCK_NO_LISTING;
			else systemLock = LOCK_REMOVE_ONLY;
		} else {
			systemLock = LOCK_NONE;
		}
	}

	/**
	 * @notice Set the market parameters
	 * @dev Only the market admin can access this function
	 * @param _devFee Developer fee required to purchase market listing (percent*100000)
	 * @param _priceUpdateInterval Amount of time before prices update (seconds)
	 * @param _startDateRoundValue Value to round market listing start dates to (seconds)
	 * @param _durationRoundValue Value to round market listing durations to (seconds)
	 * @param _maxDuration Maximum market listing duration (seconds)
	 * @param _minDuration Minimum market listing duration (seconds)
	 * @param _maxPrice Maximum market listing price (wei)
	 * @param _minPrice Minimum market listing price (wei)
	 */
	function adminSetDetails(uint32 _devFee, uint32 _priceUpdateInterval, uint32 _startDateRoundValue, uint32 _durationRoundValue,
		uint64 _maxDuration, uint64 _minDuration, uint256 _maxPrice, uint256 _minPrice) public onlyAdmin 
	{
		devFee = _devFee;
		priceUpdateInterval = _priceUpdateInterval;
		startDateRoundValue = _startDateRoundValue;
		durationRoundValue = _durationRoundValue;
		maxDuration = _maxDuration;
		minDuration = _minDuration;
		maxPrice = _maxPrice;
		minPrice = _minPrice;
	}

	/**
	 * @notice Withdraw all contract funds to `(_to)`
	 * @dev Only the market admin can access this function
	 * @param _to Address to withdraw the funds to
	 */
	function adminWithdraw(address _to) public onlyAdmin validAddress(_to) 
	{
		_to.transfer(address(this).balance);
	}

	/**
	 * @notice Close and destroy the market
	 * @dev Only the market admin can access this function
	 * @param _to Address to withdraw the funds to
	 */
	function adminClose(address _to) public onlyAdmin validAddress(_to) 
	{
		require(forSalePixelconIndexes.length == uint256(0), "Cannot close with active listings");
		selfdestruct(_to);
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////// Market Core ////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * @notice Get all market parameters
	 * @return All market parameters
	 */
	function getMarketDetails() public view returns(uint32, uint32, uint32, uint32, uint64, uint64, uint256, uint256) 
	{
		return (devFee, priceUpdateInterval, startDateRoundValue, durationRoundValue, maxDuration, minDuration, maxPrice, minPrice);
	}

	////////////////// Listings //////////////////

	/**
	 * @notice Create market listing
	 * @dev This is an internal function called by the ERC721 receiver function during the safe transfer of a PixelCon
	 * @param _seller Address of the seller
	 * @param _tokenId TokenId of the PixelCon
	 * @param _startPrice Start price of the listing (wei)
	 * @param _endPrice End price of the listing (wei)
	 * @param _duration Duration of the listing (seconds)
	 */
	function makeListing(address _seller, uint256 _tokenId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) internal 
	{
		require(_startPrice <= maxPrice, "Start price is higher than the max allowed");
		require(_startPrice >= minPrice, "Start price is lower than the min allowed");
		require(_endPrice <= maxPrice, "End price is higher than the max allowed");
		require(_endPrice >= minPrice, "End price is lower than the min allowed");

		//convert price units from Wei to Gwei
		_startPrice = _startPrice / WEI_PER_GWEI;
		_endPrice = _endPrice / WEI_PER_GWEI;
		require(_endPrice > uint256(0), "End price cannot be zero (gwei)");
		require(_startPrice >= _endPrice, "Start price is lower than the end price");
		require(_startPrice < uint256(2 ** 64), "Start price is out of bounds");
		require(_endPrice < uint256(2 ** 64), "End price is out of bounds");

		//calculate the start date
		uint256 startDate = (now / uint256(startDateRoundValue)) * uint256(startDateRoundValue);
		require(startDate < uint256(2 ** 64), "Start date is out of bounds");

		//round the duration value
		_duration = (_duration / uint256(durationRoundValue)) * uint256(durationRoundValue);
		require(_duration > uint256(0), "Duration cannot be zero");
		require(_duration <= uint256(maxDuration), "Duration is higher than the max allowed");
		require(_duration >= uint256(minDuration), "Duration is lower than the min allowed");

		//get pixelcon index
		uint64 pixelconIndex = pixelconsContract.getTokenIndex(_tokenId);

		//create the listing object
		Listing storage listing = marketPixelconListings[pixelconIndex];
		listing.startAmount = uint64(_startPrice);
		listing.endAmount = uint64(_endPrice);
		listing.startDate = uint64(startDate);
		listing.duration = uint64(_duration);
		listing.seller = _seller;

		//store references
		uint64[] storage sellerTokens = sellerPixelconIndexes[_seller];
		uint sellerTokensIndex = sellerTokens.length;
		uint forSaleIndex = forSalePixelconIndexes.length;
		require(sellerTokensIndex < uint256(2 ** 32 - 1), "Max number of market listings has been exceeded for seller");
		require(forSaleIndex < uint256(2 ** 64 - 1), "Max number of market listings has been exceeded");
		listing.sellerIndex = uint32(sellerTokensIndex);
		listing.forSaleIndex = uint64(forSaleIndex);
		sellerTokens.length++;
		sellerTokens[sellerTokensIndex] = pixelconIndex;
		forSalePixelconIndexes.length++;
		forSalePixelconIndexes[forSaleIndex] = pixelconIndex;
		emit Create(pixelconIndex, _seller, _startPrice, _endPrice, uint64(_duration));
	}

	/**
	 * @notice Check if a market listing exists for PixelCon #`(_pixelconIndex)`
	 * @param _pixelconIndex Index of the PixelCon to check
	 * @return True if market listing exists
	 */
	function exists(uint64 _pixelconIndex) public view returns(bool) 
	{
		return (marketPixelconListings[_pixelconIndex].seller != address(0));
	}

	/**
	 * @notice Get the current total number of market listings
	 * @return Number of current market listings
	 */
	function totalListings() public view returns(uint256) 
	{
		return forSalePixelconIndexes.length;
	}

	/**
	 * @notice Get the details of the market listings for PixelCon #`(_pixelconIndex)`
	 * @dev Throws if market listing does not exist
	 * @param _pixelconIndex Index of the PixelCon to get details for
	 * @return All market listing data
	 */
	function getListing(uint64 _pixelconIndex) public view returns(address _seller, uint256 _startPrice, uint256 _endPrice, uint256 _currPrice,
		uint64 _startDate, uint64 _duration, uint64 _timeLeft) 
	{
		Listing storage listing = marketPixelconListings[_pixelconIndex];
		require(listing.seller != address(0), "Market listing does not exist");

		//return all data
		_seller = listing.seller;
		_startPrice = uint256(listing.startAmount) * WEI_PER_GWEI;
		_endPrice = uint256(listing.endAmount) * WEI_PER_GWEI;
		_currPrice = calcCurrentPrice(uint256(listing.startAmount), uint256(listing.endAmount), uint256(listing.startDate), uint256(listing.duration));
		_startDate = listing.startDate;
		_duration = listing.duration;
		_timeLeft = calcTimeLeft(uint256(listing.startDate), uint256(listing.duration));
	}

	/**
	 * @notice Remove the PixelCon #`(_pixelconIndex)` listing from the market
	 * @dev Throws if market listing does not exist or if the sender is not the seller/admin
	 * @param _pixelconIndex Index of the PixelCon to remove listing for
	 */
	function removeListing(uint64 _pixelconIndex) public 
	{
		Listing storage listing = marketPixelconListings[_pixelconIndex];
		require(listing.seller != address(0), "Market listing does not exist");
		require(msg.sender == listing.seller || msg.sender == admin, "Insufficient permissions");

		//get data
		uint256 tokenId = pixelconsContract.tokenByIndex(_pixelconIndex);
		address seller = listing.seller;

		//clear the listing from storage
		clearListingData(seller, _pixelconIndex);

		//transfer pixelcon back to seller
		pixelconsContract.transferFrom(address(this), seller, tokenId);
		emit Remove(_pixelconIndex, msg.sender);
	}

	/**
	 * @notice Purchase PixelCon #`(_pixelconIndex)` to address `(_to)`
	 * @dev Throws if market listing does not exist or if the market is locked
	 * @param _to Address to send the PixelCon to
	 * @param _pixelconIndex Index of the PixelCon to purchase
	 */
	function purchase(address _to, uint64 _pixelconIndex) public payable validAddress(_to) 
	{
		Listing storage listing = marketPixelconListings[_pixelconIndex];
		require(systemLock != LOCK_REMOVE_ONLY, "Market is currently locked");
		require(listing.seller != address(0), "Market listing does not exist");
		require(listing.seller != msg.sender, "Seller cannot purchase their own listing");

		//calculate current price based on the time
		uint256 currPrice = calcCurrentPrice(uint256(listing.startAmount), uint256(listing.endAmount), uint256(listing.startDate), uint256(listing.duration));
		require(currPrice != uint256(0), "Market listing has expired");
		require(msg.value >= currPrice + (currPrice * uint256(devFee)) / FEE_RATIO, "Insufficient value sent");

		//get data
		uint256 tokenId = pixelconsContract.tokenByIndex(_pixelconIndex);
		address seller = listing.seller;

		//clear the listing from storage
		clearListingData(seller, _pixelconIndex);

		//transfer pixelcon to buyer and value to seller
		pixelconsContract.transferFrom(address(this), _to, tokenId);
		seller.transfer(currPrice);
		emit Purchase(_pixelconIndex, msg.sender, currPrice);
	}

	////////////////// Web3 Only //////////////////

	/**
	 * @notice Get market listing data for the given indexes
	 * @dev This function is for web3 calls only, as it returns a dynamic array
	 * @param _indexes PixelCon indexes to get market listing details for
	 * @return Market listing data for the given indexes
	 */
	function getBasicData(uint64[] _indexes) public view returns(uint64[], address[], uint256[], uint64[]) 
	{
		uint64[] memory tokenIndexes = new uint64[](_indexes.length);
		address[] memory sellers = new address[](_indexes.length);
		uint256[] memory currPrices = new uint256[](_indexes.length);
		uint64[] memory timeLeft = new uint64[](_indexes.length);

		for (uint i = 0; i < _indexes.length; i++) {
			Listing storage listing = marketPixelconListings[_indexes[i]];
			if (listing.seller != address(0)) {
				//listing exists
				tokenIndexes[i] = _indexes[i];
				sellers[i] = listing.seller;
				currPrices[i] = calcCurrentPrice(uint256(listing.startAmount), uint256(listing.endAmount), uint256(listing.startDate), uint256(listing.duration));
				timeLeft[i] = calcTimeLeft(uint256(listing.startDate), uint256(listing.duration));
			} else {
				//listing does not exist
				tokenIndexes[i] = 0;
				sellers[i] = 0;
				currPrices[i] = 0;
				timeLeft[i] = 0;
			}
		}
		return (tokenIndexes, sellers, currPrices, timeLeft);
	}

	/**
	 * @notice Get all PixelCon indexes being sold by `(_seller)`
	 * @dev This function is for web3 calls only, as it returns a dynamic array
	 * @param _seller Address of seller to get selling PixelCon indexes for
	 * @return All PixelCon indexes being sold by the given seller
	 */
	function getForSeller(address _seller) public view validAddress(_seller) returns(uint64[]) 
	{
		return sellerPixelconIndexes[_seller];
	}

	/**
	 * @notice Get all PixelCon indexes being sold on the market
	 * @dev This function is for web3 calls only, as it returns a dynamic array
	 * @return All PixelCon indexes being sold on the market
	 */
	function getAllListings() public view returns(uint64[]) 
	{
		return forSalePixelconIndexes;
	}

	/**
	 * @notice Get the PixelCon indexes being sold from listing index `(_startIndex)` to `(_endIndex)`
	 * @dev This function is for web3 calls only, as it returns a dynamic array
	 * @return The PixelCon indexes being sold in the given range
	 */
	function getListingsInRange(uint64 _startIndex, uint64 _endIndex) public view returns(uint64[])
	{
		require(_startIndex <= totalListings(), "Start index is out of bounds");
		require(_endIndex <= totalListings(), "End index is out of bounds");
		require(_startIndex <= _endIndex, "End index is less than the start index");

		uint64 length = _endIndex - _startIndex;
		uint64[] memory indexes = new uint64[](length);
		for (uint i = 0; i < length; i++)	{
			indexes[i] = forSalePixelconIndexes[_startIndex + i];
		}
		return indexes;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////// ERC-721 Receiver Implementation //////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * @notice Handle ERC721 token transfers
	 * @dev This function only accepts tokens from the PixelCons contracts and expects parameter data stuffed into the bytes
	 * @param _operator Address of who is doing the transfer
	 * @param _from Address of the last owner
	 * @param _tokenId Id of the token being received
	 * @param _data Miscellaneous data related to the transfer
	 * @return The ERC721 safe transfer receive confirmation
	 */
	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4) 
	{
		//only receive tokens from the PixelCons contract
		require(systemLock == LOCK_NONE, "Market is currently locked");
		require(msg.sender == address(pixelconsContract), "Market only accepts transfers from the PixelCons contract");
		require(_tokenId != uint256(0), "Invalid token ID");
		require(_operator != address(0), "Invalid operator address");
		require(_from != address(0), "Invalid from address");

		//extract parameters from byte array
		require(_data.length == 32 * 3, "Incorrectly formatted data");
		uint256 startPrice;
		uint256 endPrice;
		uint256 duration;
		assembly {
			startPrice := mload(add(_data, 0x20))
			endPrice := mload(add(_data, 0x40))
			duration := mload(add(_data, 0x60))
		}

		//add listing for the received token
		makeListing(_from, _tokenId, startPrice, endPrice, duration);

		//all good
		return ERC721_RECEIVED;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////// Utils ////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * @dev Clears the listing data for the given PixelCon index and seller address
	 * @param _seller Address of the seller to clear listing data for
	 * @param _pixelconIndex Index of the PixelCon to clear listing data for
	 */
	function clearListingData(address _seller, uint64 _pixelconIndex) internal 
	{
		Listing storage listing = marketPixelconListings[_pixelconIndex];

		//clear sellerPixelconIndexes reference
		uint64[] storage sellerTokens = sellerPixelconIndexes[_seller];
		uint64 replacementSellerTokenIndex = sellerTokens[sellerTokens.length - 1];
		delete sellerTokens[sellerTokens.length - 1];
		sellerTokens.length--;
		if (listing.sellerIndex < sellerTokens.length) {
			//we just removed the last token index in the array, but if this wasn't the one to remove, then swap it with the one to remove 
			sellerTokens[listing.sellerIndex] = replacementSellerTokenIndex;
			marketPixelconListings[replacementSellerTokenIndex].sellerIndex = listing.sellerIndex;
		}

		//clear forSalePixelconIndexes reference
		uint64 replacementForSaleTokenIndex = forSalePixelconIndexes[forSalePixelconIndexes.length - 1];
		delete forSalePixelconIndexes[forSalePixelconIndexes.length - 1];
		forSalePixelconIndexes.length--;
		if (listing.forSaleIndex < forSalePixelconIndexes.length) {
			//we just removed the last token index in the array, but if this wasn't the one to remove, then swap it with the one to remove 
			forSalePixelconIndexes[listing.forSaleIndex] = replacementForSaleTokenIndex;
			marketPixelconListings[replacementForSaleTokenIndex].forSaleIndex = listing.forSaleIndex;
		}

		//clear the listing object 
		delete marketPixelconListings[_pixelconIndex];
	}

	/**
	 * @dev Calculates the current price of a listing given all its details
	 * @param _startAmount Market listing start price amount (gwei)
	 * @param _endAmount Market listing end price amount (gwei)
	 * @param _startDate Market listing start date (seconds)
	 * @param _duration Market listing duration (seconds)
	 * @return The current listing price (wei)
	 */
	function calcCurrentPrice(uint256 _startAmount, uint256 _endAmount, uint256 _startDate, uint256 _duration) internal view returns(uint256) 
	{
		uint256 timeDelta = now - _startDate;
		if (timeDelta > _duration) return uint256(0);

		timeDelta = timeDelta / uint256(priceUpdateInterval);
		uint256 durationTotal = _duration / uint256(priceUpdateInterval);
		return (_startAmount - ((_startAmount - _endAmount) * timeDelta) / durationTotal) * WEI_PER_GWEI;
	}

	/**
	 * @dev Calculates the total time left for a listing given its details
	 * @param _startDate Market listing start date (seconds)
	 * @param _duration Market listing duration (seconds)
	 * @return Time left before market listing ends (seconds)
	 */
	function calcTimeLeft(uint256 _startDate, uint256 _duration) internal view returns(uint64) 
	{
		uint256 timeDelta = now - _startDate;
		if (timeDelta > _duration) return uint64(0);

		return uint64(_duration - timeDelta);
	}
}


/**
 * @title PixelCons (Sub-set interface)
 * @notice ERC721 token contract
 * @dev This is a subset of the PixelCon Core contract
 * @author PixelCons
 */
contract PixelCons {

	/**
	 * @notice Transfer the ownership of PixelCon `(_tokenId)` to `(_to)`
	 * @dev Throws if the sender is not the owner, approved, or operator
	 * @param _from Current owner
	 * @param _to Address to receive the PixelCon
	 * @param _tokenId ID of the PixelCon to be transferred
	 */
	function transferFrom(address _from, address _to, uint256 _tokenId) public;
	
	/**
	 * @notice Get the index of PixelCon `(_tokenId)`
	 * @dev Throws if PixelCon does not exist
	 * @param _tokenId ID of the PixelCon to query the index of
	 * @return Index of the given PixelCon ID
	 */
	function getTokenIndex(uint256 _tokenId) public view returns(uint64);

	/**
	 * @notice Get the ID of PixelCon #`(_tokenIndex)`
	 * @dev Throws if index is out of bounds
	 * @param _tokenIndex Counter less than `totalSupply()`
	 * @return `_tokenIndex`th PixelCon ID
	 */
	function tokenByIndex(uint256 _tokenIndex) public view returns(uint256);
}