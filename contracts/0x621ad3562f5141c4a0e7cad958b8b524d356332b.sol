pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/// @title Interface for contracts conforming to ERC-721: Deed Standard
/// @author William Entriken (https://phor.net), et al.
/// @dev Specification at https://github.com/ethereum/EIPs/pull/841 (DRAFT)
interface ERC721 {

    // COMPLIANCE WITH ERC-165 (DRAFT) /////////////////////////////////////////

    /// @dev ERC-165 (draft) interface signature for itself
    // bytes4 internal constant INTERFACE_SIGNATURE_ERC165 = // 0x01ffc9a7
    //     bytes4(keccak256('supportsInterface(bytes4)'));

    /// @dev ERC-165 (draft) interface signature for ERC721
    // bytes4 internal constant INTERFACE_SIGNATURE_ERC721 = // 0xda671b9b
    //     bytes4(keccak256('ownerOf(uint256)')) ^
    //     bytes4(keccak256('countOfDeeds()')) ^
    //     bytes4(keccak256('countOfDeedsByOwner(address)')) ^
    //     bytes4(keccak256('deedOfOwnerByIndex(address,uint256)')) ^
    //     bytes4(keccak256('approve(address,uint256)')) ^
    //     bytes4(keccak256('takeOwnership(uint256)'));

    /// @notice Query a contract to see if it supports a certain interface
    /// @dev Returns `true` the interface is supported and `false` otherwise,
    ///  returns `true` for INTERFACE_SIGNATURE_ERC165 and
    ///  INTERFACE_SIGNATURE_ERC721, see ERC-165 for other interface signatures.
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool);

    // PUBLIC QUERY FUNCTIONS //////////////////////////////////////////////////

    /// @notice Find the owner of a deed
    /// @param _deedId The identifier for a deed we are inspecting
    /// @dev Deeds assigned to zero address are considered destroyed, and
    ///  queries about them do throw.
    /// @return The non-zero address of the owner of deed `_deedId`, or `throw`
    ///  if deed `_deedId` is not tracked by this contract
    function ownerOf(uint256 _deedId) external view returns (address _owner);

    /// @notice Count deeds tracked by this contract
    /// @return A count of the deeds tracked by this contract, where each one of
    ///  them has an assigned and queryable owner
    function countOfDeeds() public view returns (uint256 _count);

    /// @notice Count all deeds assigned to an owner
    /// @dev Throws if `_owner` is the zero address, representing destroyed deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @return The number of deeds owned by `_owner`, possibly zero
    function countOfDeedsByOwner(address _owner) public view returns (uint256 _count);

    /// @notice Enumerate deeds assigned to an owner
    /// @dev Throws if `_index` >= `countOfDeedsByOwner(_owner)` or if
    ///  `_owner` is the zero address, representing destroyed deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @param _index A counter between zero and `countOfDeedsByOwner(_owner)`,
    ///  inclusive
    /// @return The identifier for the `_index`th deed assigned to `_owner`,
    ///   (sort order not specified)
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);

    // TRANSFER MECHANISM //////////////////////////////////////////////////////

    /// @dev This event emits when ownership of any deed changes by any
    ///  mechanism. This event emits when deeds are created (`from` == 0) and
    ///  destroyed (`to` == 0). Exception: during contract creation, any
    ///  transfers may occur without emitting `Transfer`.
    event Transfer(address indexed from, address indexed to, uint256 indexed deedId);

    /// @dev This event emits on any successful call to
    ///  `approve(address _spender, uint256 _deedId)`. Exception: does not emit
    ///  if an owner revokes approval (`_to` == 0x0) on a deed with no existing
    ///  approval.
    event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);

    /// @notice Approve a new owner to take your deed, or revoke approval by
    ///  setting the zero address. You may `approve` any number of times while
    ///  the deed is assigned to you, only the most recent approval matters.
    /// @dev Throws if `msg.sender` does not own deed `_deedId` or if `_to` ==
    ///  `msg.sender`.
    /// @param _deedId The deed you are granting ownership of
    function approve(address _to, uint256 _deedId) external;

    /// @notice Become owner of a deed for which you are currently approved
    /// @dev Throws if `msg.sender` is not approved to become the owner of
    ///  `deedId` or if `msg.sender` currently owns `_deedId`.
    /// @param _deedId The deed that is being transferred
    function takeOwnership(uint256 _deedId) external;
    
    // SPEC EXTENSIONS /////////////////////////////////////////////////////////
    
    /// @notice Transfer a deed to a new owner.
    /// @dev Throws if `msg.sender` does not own deed `_deedId` or if
    ///  `_to` == 0x0.
    /// @param _to The address of the new owner.
    /// @param _deedId The deed you are transferring.
    function transfer(address _to, uint256 _deedId) external;
}


/// @title The internal clock auction functionality.
/// Inspired by CryptoKitties' clock auction
contract ClockAuctionBase {

    // Address of the ERC721 contract this auction is linked to.
    ERC721 public deedContract;

    // Fee per successful auction in 1/1000th of a percentage.
    uint256 public fee;
    
    // Total amount of ether yet to be paid to auction beneficiaries.
    uint256 public outstandingEther = 0 ether;
    
    // Amount of ether yet to be paid per beneficiary.
    mapping (address => uint256) public addressToEtherOwed;
    
    /// @dev Represents a deed auction.
    /// Care has been taken to ensure the auction fits in
    /// two 256-bit words.
    struct Auction {
        address seller;
        uint128 startPrice;
        uint128 endPrice;
        uint64 duration;
        uint64 startedAt;
    }

    mapping (uint256 => Auction) identifierToAuction;
    
    // Events
    event AuctionCreated(address indexed seller, uint256 indexed deedId, uint256 startPrice, uint256 endPrice, uint256 duration);
    event AuctionSuccessful(address indexed buyer, uint256 indexed deedId, uint256 totalPrice);
    event AuctionCancelled(uint256 indexed deedId);
    
    /// @dev Modifier to check whether the value can be stored in a 64 bit uint.
    modifier fitsIn64Bits(uint256 _value) {
        require (_value == uint256(uint64(_value)));
        _;
    }
    
    /// @dev Modifier to check whether the value can be stored in a 128 bit uint.
    modifier fitsIn128Bits(uint256 _value) {
        require (_value == uint256(uint128(_value)));
        _;
    }
    
    function ClockAuctionBase(address _deedContractAddress, uint256 _fee) public {
        deedContract = ERC721(_deedContractAddress);
        
        // Contract must indicate support for ERC721 through its interface signature.
        require(deedContract.supportsInterface(0xda671b9b));
        
        // Fee must be between 0 and 100%.
        require(0 <= _fee && _fee <= 100000);
        fee = _fee;
    }
    
    /// @dev Checks whether the given auction is active.
    /// @param auction The auction to check for activity.
    function _activeAuction(Auction storage auction) internal view returns (bool) {
        return auction.startedAt > 0;
    }
    
    /// @dev Put the deed into escrow, thereby taking ownership of it.
    /// @param _deedId The identifier of the deed to place into escrow.
    function _escrow(uint256 _deedId) internal {
        // Throws if the transfer fails
        deedContract.takeOwnership(_deedId);
    }
    
    /// @dev Create the auction.
    /// @param _deedId The identifier of the deed to create the auction for.
    /// @param auction The auction to create.
    function _createAuction(uint256 _deedId, Auction auction) internal {
        // Add the auction to the auction mapping.
        identifierToAuction[_deedId] = auction;
        
        // Trigger auction created event.
        AuctionCreated(auction.seller, _deedId, auction.startPrice, auction.endPrice, auction.duration);
    }
    
    /// @dev Bid on an auction.
    /// @param _buyer The address of the buyer.
    /// @param _value The value sent by the sender (in ether).
    /// @param _deedId The identifier of the deed to bid on.
    function _bid(address _buyer, uint256 _value, uint256 _deedId) internal {
        Auction storage auction = identifierToAuction[_deedId];
        
        // The auction must be active.
        require(_activeAuction(auction));
        
        // Calculate the auction's current price.
        uint256 price = _currentPrice(auction);
        
        // Make sure enough funds were sent.
        require(_value >= price);
        
        address seller = auction.seller;
    
        if (price > 0) {
            uint256 totalFee = _calculateFee(price);
            uint256 proceeds = price - totalFee;
            
            // Assign the proceeds to the seller.
            // We do not send the proceeds directly, as to prevent
            // malicious sellers from denying auctions (and burning
            // the buyer's gas).
            _assignProceeds(seller, proceeds);
        }
        
        AuctionSuccessful(_buyer, _deedId, price);
        
        // The bid was won!
        _winBid(seller, _buyer, _deedId, price);
        
        // Remove the auction (we do this at the end, as
        // winBid might require some additional information
        // that will be removed when _removeAuction is
        // called. As we do not transfer funds here, we do
        // not have to worry about re-entry attacks.
        _removeAuction(_deedId);
    }

    /// @dev Perform the bid win logic (in this case: transfer the deed).
    /// @param _seller The address of the seller.
    /// @param _winner The address of the winner.
    /// @param _deedId The identifier of the deed.
    /// @param _price The price the auction was bought at.
    function _winBid(address _seller, address _winner, uint256 _deedId, uint256 _price) internal {
        _transfer(_winner, _deedId);
    }
    
    /// @dev Cancel an auction.
    /// @param _deedId The identifier of the deed for which the auction should be cancelled.
    /// @param auction The auction to cancel.
    function _cancelAuction(uint256 _deedId, Auction auction) internal {
        // Remove the auction
        _removeAuction(_deedId);
        
        // Transfer the deed back to the seller
        _transfer(auction.seller, _deedId);
        
        // Trigger auction cancelled event.
        AuctionCancelled(_deedId);
    }
    
    /// @dev Remove an auction.
    /// @param _deedId The identifier of the deed for which the auction should be removed.
    function _removeAuction(uint256 _deedId) internal {
        delete identifierToAuction[_deedId];
    }
    
    /// @dev Transfer a deed owned by this contract to another address.
    /// @param _to The address to transfer the deed to.
    /// @param _deedId The identifier of the deed.
    function _transfer(address _to, uint256 _deedId) internal {
        // Throws if the transfer fails
        deedContract.transfer(_to, _deedId);
    }
    
    /// @dev Assign proceeds to an address.
    /// @param _to The address to assign proceeds to.
    /// @param _value The proceeds to assign.
    function _assignProceeds(address _to, uint256 _value) internal {
        outstandingEther += _value;
        addressToEtherOwed[_to] += _value;
    }
    
    /// @dev Calculate the current price of an auction.
    function _currentPrice(Auction storage _auction) internal view returns (uint256) {
        require(now >= _auction.startedAt);
        
        uint256 secondsPassed = now - _auction.startedAt;
        
        if (secondsPassed >= _auction.duration) {
            return _auction.endPrice;
        } else {
            // Negative if the end price is higher than the start price!
            int256 totalPriceChange = int256(_auction.endPrice) - int256(_auction.startPrice);
            
            // Calculate the current price based on the total change over the entire
            // auction duration, and the amount of time passed since the start of the
            // auction.
            int256 currentPriceChange = totalPriceChange * int256(secondsPassed) / int256(_auction.duration);
            
            // Calculate the final price. Note this once again
            // is representable by a uint256, as the price can
            // never be negative.
            int256 price = int256(_auction.startPrice) + currentPriceChange;
            
            // This never throws.
            assert(price >= 0);
            
            return uint256(price);
        }
    }
    
    /// @dev Calculate the fee for a given price.
    /// @param _price The price to calculate the fee for.
    function _calculateFee(uint256 _price) internal view returns (uint256) {
        // _price is guaranteed to fit in a uint128 due to the createAuction entry
        // modifiers, so this cannot overflow.
        return _price * fee / 100000;
    }
}


contract ClockAuction is ClockAuctionBase, Pausable {
    function ClockAuction(address _deedContractAddress, uint256 _fee) 
        ClockAuctionBase(_deedContractAddress, _fee)
        public
    {}
    
    /// @notice Update the auction fee.
    /// @param _fee The new fee.
    function setFee(uint256 _fee) external onlyOwner {
        require(0 <= _fee && _fee <= 100000);
    
        fee = _fee;
    }
    
    /// @notice Get the auction for the given deed.
    /// @param _deedId The identifier of the deed to get the auction for.
    /// @dev Throws if there is no auction for the given deed.
    function getAuction(uint256 _deedId) external view returns (
            address seller,
            uint256 startPrice,
            uint256 endPrice,
            uint256 duration,
            uint256 startedAt
        )
    {
        Auction storage auction = identifierToAuction[_deedId];
        
        // The auction must be active
        require(_activeAuction(auction));
        
        return (
            auction.seller,
            auction.startPrice,
            auction.endPrice,
            auction.duration,
            auction.startedAt
        );
    }

    /// @notice Create an auction for a given deed.
    /// Must previously have been given approval to take ownership of the deed.
    /// @param _deedId The identifier of the deed to create an auction for.
    /// @param _startPrice The starting price of the auction.
    /// @param _endPrice The ending price of the auction.
    /// @param _duration The duration in seconds of the dynamic pricing part of the auction.
    function createAuction(uint256 _deedId, uint256 _startPrice, uint256 _endPrice, uint256 _duration)
        public
        fitsIn128Bits(_startPrice)
        fitsIn128Bits(_endPrice)
        fitsIn64Bits(_duration)
        whenNotPaused
    {
        // Get the owner of the deed to be auctioned
        address deedOwner = deedContract.ownerOf(_deedId);
    
        // Caller must either be the deed contract or the owner of the deed
        // to prevent abuse.
        require(
            msg.sender == address(deedContract) ||
            msg.sender == deedOwner
        );
    
        // The duration of the auction must be at least 60 seconds.
        require(_duration >= 60);
    
        // Throws if placing the deed in escrow fails (the contract requires
        // transfer approval prior to creating the auction).
        _escrow(_deedId);
        
        // Auction struct
        Auction memory auction = Auction(
            deedOwner,
            uint128(_startPrice),
            uint128(_endPrice),
            uint64(_duration),
            uint64(now)
        );
        
        _createAuction(_deedId, auction);
    }
    
    /// @notice Cancel an auction
    /// @param _deedId The identifier of the deed to cancel the auction for.
    function cancelAuction(uint256 _deedId) external whenNotPaused {
        Auction storage auction = identifierToAuction[_deedId];
        
        // The auction must be active.
        require(_activeAuction(auction));
        
        // The auction can only be cancelled by the seller
        require(msg.sender == auction.seller);
        
        _cancelAuction(_deedId, auction);
    }
    
    /// @notice Bid on an auction.
    /// @param _deedId The identifier of the deed to bid on.
    function bid(uint256 _deedId) external payable whenNotPaused {
        // Throws if the bid does not succeed.
        _bid(msg.sender, msg.value, _deedId);
    }
    
    /// @dev Returns the current price of an auction.
    /// @param _deedId The identifier of the deed to get the currency price for.
    function getCurrentPrice(uint256 _deedId) external view returns (uint256) {
        Auction storage auction = identifierToAuction[_deedId];
        
        // The auction must be active.
        require(_activeAuction(auction));
        
        return _currentPrice(auction);
    }
    
    /// @notice Withdraw ether owed to a beneficiary.
    /// @param beneficiary The address to withdraw the auction balance for.
    function withdrawAuctionBalance(address beneficiary) external {
        // The sender must either be the beneficiary or the core deed contract.
        require(
            msg.sender == beneficiary ||
            msg.sender == address(deedContract)
        );
        
        uint256 etherOwed = addressToEtherOwed[beneficiary];
        
        // Ensure ether is owed to the beneficiary.
        require(etherOwed > 0);
         
        // Set ether owed to 0   
        delete addressToEtherOwed[beneficiary];
        
        // Subtract from total outstanding balance. etherOwed is guaranteed
        // to be less than or equal to outstandingEther, so this cannot
        // underflow.
        outstandingEther -= etherOwed;
        
        // Transfer ether owed to the beneficiary (not susceptible to re-entry
        // attack, as the ether owed is set to 0 before the transfer takes place).
        beneficiary.transfer(etherOwed);
    }
    
    /// @notice Withdraw (unowed) contract balance.
    function withdrawFreeBalance() external {
        // Calculate the free (unowed) balance. This never underflows, as
        // outstandingEther is guaranteed to be less than or equal to the
        // contract balance.
        uint256 freeBalance = this.balance - outstandingEther;
        
        address deedContractAddress = address(deedContract);

        require(
            msg.sender == owner ||
            msg.sender == deedContractAddress
        );
        
        deedContractAddress.transfer(freeBalance);
    }
}


contract SaleAuction is ClockAuction {
    function SaleAuction(address _deedContractAddress, uint256 _fee) ClockAuction(_deedContractAddress, _fee) public {}
    
    /// @dev Allows other contracts to check whether this is the expected contract.
    bool public isSaleAuction = true;
}