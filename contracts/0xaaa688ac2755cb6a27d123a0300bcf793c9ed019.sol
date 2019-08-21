pragma solidity ^0.4.24;

contract ERC721Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) public view returns (address _owner);

    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;

    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;

    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

    //    function safeTransferFrom(
    //        address _from,
    //        address _to,
    //        uint256 _tokenId,
    //        bytes _data
    //    )
    //    public;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);

    function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
    function name() public view returns (string _name);

    function symbol() public view returns (string _symbol);

    function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

contract ToonInterface is ERC721 {

    function isToonInterface() external pure returns (bool);

    /**
    * @notice   Returns an address of the toon author. 0x0 if
    *           the toon has been created by us.
    */
    function authorAddress() external view returns (address);

    /**
    * @notice   Returns maximum supply. In other words there will
    *           be never more toons that that number. It has to
    *           be constant.
    *           If there is no limit function returns 0.
    */
    function maxSupply() external view returns (uint256);

    function getToonInfo(uint _id) external view returns (
        uint genes,
        uint birthTime,
        address owner
    );

}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}

contract Withdrawable {

    mapping(address => uint) private pendingWithdrawals;

    event Withdrawal(address indexed receiver, uint amount);
    event BalanceChanged(address indexed _address, uint oldBalance, uint newBalance);

    /**
    * Returns amount of wei that given address is able to withdraw.
    */
    function getPendingWithdrawal(address _address) public view returns (uint) {
        return pendingWithdrawals[_address];
    }

    /**
    * Add pending withdrawal for an address.
    */
    function addPendingWithdrawal(address _address, uint _amount) internal {
        require(_address != 0x0);

        uint oldBalance = pendingWithdrawals[_address];
        pendingWithdrawals[_address] += _amount;

        emit BalanceChanged(_address, oldBalance, oldBalance + _amount);
    }

    /**
    * Withdraws all pending withdrawals.
    */
    function withdraw() external {
        uint amount = getPendingWithdrawal(msg.sender);
        require(amount > 0);

        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);

        emit Withdrawal(msg.sender, amount);
        emit BalanceChanged(msg.sender, amount, 0);
    }

}

contract ClockAuctionBase is Withdrawable, Pausable {

    // Represents an auction on an NFT
    struct Auction {
        // Address of a contract
        address _contract;
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ToonInterface[] public toonContracts;
    mapping(address => uint256) addressToIndex;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Values 0-10,000 map to 0%-100%
    // Author's share from the owner cut.
    uint256 public authorShare;

    // Map from token ID to their corresponding auction.
    //    mapping(uint256 => Auction) tokenIdToAuction;
    mapping(address => mapping(uint256 => Auction)) tokenToAuction;

    event AuctionCreated(address indexed _contract, uint256 indexed tokenId,
        uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(address indexed _contract, uint256 indexed tokenId,
        uint256 totalPrice, address indexed winner);
    event AuctionCancelled(address indexed _contract, uint256 indexed tokenId);

    /**
    * @notice   Adds a new toon contract.
    */
    function addToonContract(address _toonContractAddress) external onlyOwner {
        ToonInterface _interface = ToonInterface(_toonContractAddress);
        require(_interface.isToonInterface());

        uint _index = toonContracts.push(_interface) - 1;
        addressToIndex[_toonContractAddress] = _index;
    }

    /// @dev Returns true if the claimant owns the token.
    /// @param _contract - address of a toon contract
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _contract, address _claimant, uint256 _tokenId)
    internal
    view
    returns (bool) {
        ToonInterface _interface = _interfaceByAddress(_contract);
        address _owner = _interface.ownerOf(_tokenId);

        return (_owner == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _contract, address _owner, uint256 _tokenId) internal {
        ToonInterface _interface = _interfaceByAddress(_contract);
        // it will throw if transfer fails
        _interface.transferFrom(_owner, this, _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _contract, address _receiver, uint256 _tokenId) internal {
        ToonInterface _interface = _interfaceByAddress(_contract);
        // it will throw if transfer fails
        _interface.transferFrom(this, _receiver, _tokenId);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(address _contract, uint256 _tokenId, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        _isAddressSupportedContract(_contract);
        tokenToAuction[_contract][_tokenId] = _auction;

        emit AuctionCreated(
            _contract,
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(address _contract, uint256 _tokenId, address _seller) internal {
        _removeAuction(_contract, _tokenId);
        _transfer(_contract, _seller, _tokenId);
        emit AuctionCancelled(_contract, _tokenId);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(address _contract, uint256 _tokenId, uint256 _bidAmount)
    internal
    returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenToAuction[_contract][_tokenId];
        ToonInterface _interface = _interfaceByAddress(auction._contract);

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_contract, _tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut;
            uint256 authorCut;
            uint256 sellerProceeds;
            (auctioneerCut, authorCut, sellerProceeds) = _computeCut(_interface, price);

            if (authorCut > 0) {
                address authorAddress = _interface.authorAddress();
                addPendingWithdrawal(authorAddress, authorCut);
            }

            addPendingWithdrawal(owner, auctioneerCut);

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the auction
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelAuction(). )
            seller.transfer(sellerProceeds);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or
        // equal to the price so this cannot underflow.
        uint256 bidExcess = _bidAmount - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the auction is
        // removed before any transfers occur.
        msg.sender.transfer(bidExcess);

        // Tell the world!
        emit AuctionSuccessful(_contract, _tokenId, price, msg.sender);

        return price;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(address _contract, uint256 _tokenId) internal {
        delete tokenToAuction[_contract][_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction)
    internal
    view
    returns (uint256)
    {
        uint256 secondsPassed = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
    internal
    pure
    returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in
        //  _addAuction())
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(ToonInterface _interface, uint256 _price) internal view returns (
        uint256 ownerCutValue,
        uint256 authorCutValue,
        uint256 sellerProceeds
    ) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.

        uint256 _totalCut = _price * ownerCut / 10000;
        uint256 _authorCut = 0;
        uint256 _ownerCut = 0;
        if (_interface.authorAddress() != 0x0) {
            _authorCut = _totalCut * authorShare / 10000;
        }

        _ownerCut = _totalCut - _authorCut;
        uint256 _sellerProfit = _price - _ownerCut - _authorCut;
        require(_sellerProfit + _ownerCut + _authorCut == _price);

        return (_ownerCut, _authorCut, _sellerProfit);
    }

    function _interfaceByAddress(address _address) internal view returns (ToonInterface) {
        uint _index = addressToIndex[_address];
        ToonInterface _interface = toonContracts[_index];
        require(_address == address(_interface));

        return _interface;
    }

    function _isAddressSupportedContract(address _address) internal view returns (bool) {
        uint _index = addressToIndex[_address];
        ToonInterface _interface = toonContracts[_index];
        return _address == address(_interface);
    }
}

contract ClockAuction is ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    bool public isSaleClockAuction = true;

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _ownerCut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    /// @param _authorShare - percent share of the author of the toon.
    ///  Calculated from the ownerCut
    constructor(uint256 _ownerCut, uint256 _authorShare) public {
        require(_ownerCut <= 10000);
        require(_authorShare <= 10000);

        ownerCut = _ownerCut;
        authorShare = _authorShare;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        address _contract,
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
    external
    whenNotPaused
    {
        require(_isAddressSupportedContract(_contract));
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        _escrow(_contract, _seller, _tokenId);

        Auction memory auction = Auction(
            _contract,
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_contract, _tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(address _contract, uint256 _tokenId)
    external
    payable
    whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_contract, _tokenId, msg.value);
        _transfer(_contract, msg.sender, _tokenId);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(address _contract, uint256 _tokenId)
    external
    {
        Auction storage auction = tokenToAuction[_contract][_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_contract, _tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(address _contract, uint256 _tokenId)
    whenPaused
    onlyOwner
    external
    {
        Auction storage auction = tokenToAuction[_contract][_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_contract, _tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(address _contract, uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt,
        uint256 currentPrice
    ) {
        Auction storage auction = tokenToAuction[_contract][_tokenId];

        if (!_isOnAuction(auction)) {
            return (0x0, 0, 0, 0, 0, 0);
        }

        return (
        auction.seller,
        auction.startingPrice,
        auction.endingPrice,
        auction.duration,
        auction.startedAt,
        getCurrentPrice(_contract, _tokenId)
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(address _contract, uint256 _tokenId)
    public
    view
    returns (uint256)
    {
        Auction storage auction = tokenToAuction[_contract][_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}