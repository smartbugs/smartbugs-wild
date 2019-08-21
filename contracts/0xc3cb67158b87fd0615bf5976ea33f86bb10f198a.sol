pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public ethAddress;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
    ethAddress = msg.sender;
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


contract Token {
    uint256 public _totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title       Token
 * @dev         ERC-20 Standard Token
 */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

/// @title ERC-20 Auction Base
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
/// @author Fazri Zubair, Farhan Khwaja (Lucid Sight, Inc.)
contract AuctionBase {
    // Represents an auction on an FT (ERC-20)
    struct Auction {
        // Current owner of FT (ERC-20)
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
        // Token Quantity
        uint256 tokenQuantity;
        // Token Address
        address tokenAddress;
        // Auction number of this auction wrt tokenAddress
        uint256 auctionNumber;
    }

    /// ERC-20 Auction Contract Address
    address public cryptiblesAuctionContract;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut = 375;

    // Map to keep a track on number of auctions by an owner
    mapping (address => uint256) auctionCounter;

    // Map from token,owner to their corresponding auction.
    mapping (address => mapping (uint256 => Auction)) tokensAuction;

    event AuctionCreated(address tokenAddress, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 quantity, uint256 auctionNumber, uint64 startedAt);
    event AuctionWinner(address tokenAddress, uint256 totalPrice, address winner, uint256 quantity, uint256 auctionNumber);
    event AuctionCancelled(address tokenAddress, address sellerAddress, uint256 auctionNumber, uint256 quantity);
    event EtherWithdrawed(uint256 value);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _totalTokens - Check total tokens being put on auction against user balance
    function _owns(address _tokenAddress, address _claimant, uint256 _totalTokens) internal view returns (bool) {
        StandardToken tokenContract = StandardToken(_tokenAddress);
        return (tokenContract.balanceOf(_claimant) >= _totalTokens);
    }

    /// @dev Escrows the ERC-20 Token, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _totalTokens - Number of tokens (ERC-20) to 
    function _escrow(address _tokenAddress, address _owner, uint256 _totalTokens) internal {
        // it will throw if transfer fails
        StandardToken tokenContract = StandardToken(_tokenAddress);
        tokenContract.transferFrom(_owner, this, _totalTokens);
    }

    /// @dev Transfers an Erc-20 Token owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer ERC-20 Token to.
    /// @param _totalTokens - Tokens to transfer
    function _transfer(address _tokenAddress, address _receiver, uint256 _totalTokens) internal {
        // it will throw if transfer fails
        StandardToken tokenContract = StandardToken(_tokenAddress);
        tokenContract.transfer(_receiver, _totalTokens);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenAddress The address of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(address _tokenAddress, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute.
        require(_auction.duration >= 1 minutes);
        
        AuctionCreated(
            _tokenAddress,
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration),
            uint256(_auction.tokenQuantity),
            uint256(_auction.auctionNumber),
            uint64(_auction.startedAt)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(address _tokenAddress, uint256 _auctionNumber) internal {
        // Get a reference to the auction struct
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        address seller = auction.seller;
        uint256 tokenQuantity = auction.tokenQuantity;

        _removeAuction(_tokenAddress, _auctionNumber);
        _transfer(_tokenAddress, seller, tokenQuantity);
        AuctionCancelled(_tokenAddress, seller, _auctionNumber, tokenQuantity);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(address _tokenAddress, uint256 _auctionNumber, uint256 _bidAmount)
        internal
    {
        // Get a reference to the auction struct
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenAddress will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;
        uint256 quantity = auction.tokenQuantity;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenAddress, _auctionNumber);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

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
        AuctionWinner(_tokenAddress, price, msg.sender, quantity, _auctionNumber);
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenAddress - Address of FT (ERC-20) on auction.
    /// @param _auctionNumber - Auction Number corresponding the auction bidding on
    function _removeAuction(address _tokenAddress, uint256 _auctionNumber) internal {
        delete tokensAuction[_tokenAddress][_auctionNumber];
    }

    /// @dev Returns true if the FT (ERC-20) is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an FT (ERC-20) on auction. Broken into two
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
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }
    
    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Kitties on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(address _tokenAddress, address _approved, uint256 _tokenQuantity) internal {
        StandardToken tokenContract = StandardToken(_tokenAddress);
        tokenContract.approve(_approved, _tokenQuantity);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
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
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/// @title Clock auction for fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, AuctionBase {

    /// @dev Constructor creates a reference to the FT (ERC-20) ownership contract
    /// @param _contractAddr - Address of the SaleClockAuction Contract. Setting the variable.
    function ClockAuction(address _contractAddr) public {
        require(ownerCut <= 10000);
        cryptiblesAuctionContract = _contractAddr;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the FT (ERC-20) contract, but can be called either by
    ///  the owner or the FT (ERC-20) contract.
    function withdrawBalance() external {
        require(
            msg.sender == owner ||
            msg.sender == ethAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = msg.sender.send(this.balance);

    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenAddress - Address of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _totalQuantity - Token Quantity to Auction
    function createAuction(
        address _tokenAddress,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _totalQuantity
    )
        external
        whenNotPaused
    {
        // Checking whether user has enough balance
        require(_owns(_tokenAddress, msg.sender, _totalQuantity));
        
        // We can't approve our ERC-20 Tokens minted earlier as they will need to be
        // approved by the owner and not by our contract
        // _approve(_tokenAddress, msg.sender, _tokenQuantity);

        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(this == address(cryptiblesAuctionContract));

        uint256 auctionNumber = auctionCounter[_tokenAddress];
        
        // Defaults to 0, incrementing the counter
        if(auctionNumber == uint256(0)){
            auctionNumber = 1;
        }else{
            auctionNumber += 1;
        }

        auctionCounter[_tokenAddress] = auctionNumber;
        
        _escrow(_tokenAddress, msg.sender, _totalQuantity);

        Auction memory auction = Auction(
            msg.sender,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now),
            uint256(_totalQuantity),
            _tokenAddress,
            auctionNumber
        );

        tokensAuction[_tokenAddress][auctionNumber] = auction;

        _addAuction(_tokenAddress, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the FT (ERC-20) if enough Ether is supplied.
    /// @param _tokenAddress - Address of token to bid on.
    /// @param _auctionNumber - Auction Number corresponding the auction bidding on
    function bid(address _tokenAddress, uint256 _auctionNumber)
        external
        payable
        whenNotPaused
    {
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenAddress, _auctionNumber, msg.value);
        _transfer(_tokenAddress, msg.sender, auction.tokenQuantity);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the FT (ERC-20) to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenAddress - Address of token on auction
    /// @param _auctionNumber - Auction Number for the token
    function cancelAuction(address _tokenAddress, uint256 _auctionNumber)
        external
    {
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenAddress, _auctionNumber);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and FT (ERC-20)s are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenAddress - Address of the FT (ERC-20) on auction to cancel.
    /// @param _auctionNumber - Auction Number for the token
    function cancelAuctionWhenPaused(address _tokenAddress, uint256 _auctionNumber)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenAddress, _auctionNumber);
    }

    /// @dev Returns auction info for an FT (ERC-20) on auction.
    /// @param _tokenAddress - Address of FT (ERC-20) on auction.
    /// @param _auctionNumber - Auction Number for the token
    function getAuction(address _tokenAddress, uint256 _auctionNumber)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt,
        uint256 tokenQuantity,
        address tokenAddress,
        uint256 auctionNumber
    ) {
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt,
            auction.tokenQuantity,
            auction.tokenAddress,
            auction.auctionNumber
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenAddress - Address of the token price we are checking.
    /// @param _auctionNumber - Auction Number for the token
    function getCurrentPrice(address _tokenAddress, uint256 _auctionNumber)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokensAuction[_tokenAddress][_auctionNumber];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}


/// @title Sale Clock auction 
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction call.
    bool public isSaleClockAuction = true;

    function SaleClockAuction() public
        ClockAuction(this) {
        }
    
    /// @dev Creates and begins a new auction.
    /// @param _tokenAddress - Address of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _tokenQuantity - Token Quantity to auction
    function createAuction(
        address _tokenAddress,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _tokenQuantity
    )
        external
    {
        require(_owns(_tokenAddress, msg.sender, _tokenQuantity));

        // We can't approve our ERC-20 Tokens minted earlier as they will need to be
        // approved by the owner and not by our contract
        // _approve(_tokenAddress, msg.sender, _tokenQuantity);

        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(this == address(cryptiblesAuctionContract));

        uint256 auctionNumber = auctionCounter[_tokenAddress];
        
        // Defaults to 0, incrementing the counter
        if(auctionNumber == 0){
            auctionNumber = 1;
        }else{
            auctionNumber += 1;
        }

        auctionCounter[_tokenAddress] = auctionNumber;
        
        _escrow(_tokenAddress, msg.sender, _tokenQuantity);

        Auction memory auction = Auction(
            msg.sender,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now),
            uint256(_tokenQuantity),
            _tokenAddress,
            auctionNumber
        );

        tokensAuction[_tokenAddress][auctionNumber] = auction;
        
        _addAuction(_tokenAddress, auction);
    }

    /// @dev works the same as default bid method.
    /// @param _tokenAddress - Address of token to auction, sender must be owner.
    /// @param _auctionNumber - Auction number associated with the Token Address
    function bid(address _tokenAddress, uint256 _auctionNumber)
        external
        payable
    {
        uint256 quantity = tokensAuction[_tokenAddress][_auctionNumber].tokenQuantity;
        _bid(_tokenAddress, _auctionNumber, msg.value);
        _transfer(_tokenAddress,msg.sender, quantity);
    }

    /// @dev Function to chnage the OwnerCut only accessible by the Owner of the contract
    /// @param _newCut - Sets the ownerCut to new value
    function setOwnerCut(uint256 _newCut) external onlyOwner {
        require(_newCut <= 10000);
        ownerCut = _newCut;
    }
}