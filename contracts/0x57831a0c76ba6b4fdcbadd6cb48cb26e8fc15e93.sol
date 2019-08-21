pragma solidity ^0.4.24;

/// @title Contract that manages addresses and access modifiers for certain operations.
/// @author Dapper Labs Inc. (https://www.dapperlabs.com)
contract OffersAccessControl {

    // The address of the account that can replace ceo, coo, cfo, lostAndFound
    address public ceoAddress;
    // The address of the account that can adjust configuration variables and fulfill offer
    address public cooAddress;
    // The address of the CFO account that receives all the fees
    address public cfoAddress;
    // The address where funds of failed "push"es go to
    address public lostAndFoundAddress;

    // The total amount of ether (in wei) in escrow owned by CFO
    uint256 public totalCFOEarnings;
    // The total amount of ether (in wei) in escrow owned by lostAndFound
    uint256 public totalLostAndFoundBalance;

    /// @notice Keeps track whether the contract is frozen.
    ///  When frozen is set to be true, it cannot be set back to false again,
    ///  and all whenNotFrozen actions will be blocked.
    bool public frozen = false;

    /// @notice Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "only CEO is allowed to perform this operation");
        _;
    }

    /// @notice Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress, "only COO is allowed to perform this operation");
        _;
    }

    /// @notice Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(
            msg.sender == cfoAddress &&
            msg.sender != address(0),
            "only CFO is allowed to perform this operation"
        );
        _;
    }

    /// @notice Access modifier for CEO-only or CFO-only functionality
    modifier onlyCeoOrCfo() {
        require(
            msg.sender != address(0) &&
            (
                msg.sender == ceoAddress ||
                msg.sender == cfoAddress
            ),
            "only CEO or CFO is allowed to perform this operation"
        );
        _;
    }

    /// @notice Access modifier for LostAndFound-only functionality
    modifier onlyLostAndFound() {
        require(
            msg.sender == lostAndFoundAddress &&
            msg.sender != address(0),
            "only LostAndFound is allowed to perform this operation"
        );
        _;
    }

    /// @notice Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0), "new CEO address cannot be the zero-account");
        ceoAddress = _newCEO;
    }

    /// @notice Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0), "new COO address cannot be the zero-account");
        cooAddress = _newCOO;
    }

    /// @notice Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0), "new CFO address cannot be the zero-account");
        cfoAddress = _newCFO;
    }

    /// @notice Assigns a new address to act as the LostAndFound account. Only available to the current CEO.
    /// @param _newLostAndFound The address of the new lostAndFound address
    function setLostAndFound(address _newLostAndFound) external onlyCEO {
        require(_newLostAndFound != address(0), "new lost and found cannot be the zero-account");
        lostAndFoundAddress = _newLostAndFound;
    }

    /// @notice CFO withdraws the CFO earnings
    function withdrawTotalCFOEarnings() external onlyCFO {
        // Obtain reference
        uint256 balance = totalCFOEarnings;
        totalCFOEarnings = 0;
        cfoAddress.transfer(balance);
    }

    /// @notice LostAndFound account withdraws all the lost and found amount
    function withdrawTotalLostAndFoundBalance() external onlyLostAndFound {
        // Obtain reference
        uint256 balance = totalLostAndFoundBalance;
        totalLostAndFoundBalance = 0;
        lostAndFoundAddress.transfer(balance);
    }

    /// @notice Modifier to allow actions only when the contract is not frozen
    modifier whenNotFrozen() {
        require(!frozen, "contract needs to not be frozen");
        _;
    }

    /// @notice Modifier to allow actions only when the contract is frozen
    modifier whenFrozen() {
        require(frozen, "contract needs to be frozen");
        _;
    }

    /// @notice Called by CEO or CFO role to freeze the contract.
    ///  Only intended to be used if a serious exploit is detected.
    /// @notice Allow two C-level roles to call this function in case either CEO or CFO key is compromised.
    /// @notice This is a one-way process; there is no un-freezing.
    /// @dev A frozen contract will be frozen forever, there's no way to undo this action.
    function freeze() external onlyCeoOrCfo whenNotFrozen {
        frozen = true;
    }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/// @title Contract that manages configuration values and fee structure for offers.
/// @author Dapper Labs Inc. (https://www.dapperlabs.com)
contract OffersConfig is OffersAccessControl {

    /* ************************* */
    /* ADJUSTABLE CONFIGURATIONS */
    /* ************************* */

    // The duration (in seconds) of all offers that are created. This parameter is also used in calculating
    // new expiration times when extending offers.
    uint256 public globalDuration;
    // The global minimum offer value (price + offer fee, in wei)
    uint256 public minimumTotalValue;
    // The minimum overbid increment % (expressed in basis points, which is 1/100 of a percent)
    // For basis points, values 0-10,000 map to 0%-100%
    uint256 public minimumPriceIncrement;

    /* *************** */
    /* ADJUSTABLE FEES */
    /* *************** */

    // Throughout the various contracts there will be various symbols used for the purpose of a clear display
    // of the underlying mathematical formulation. Specifically,
    //
    //          - T: This is the total amount of funds associated with an offer, comprised of 1) the offer
    //                  price which the bidder is proposing the owner of the token receive, and 2) an amount
    //                  that is the maximum the main Offers contract will ever take - this is when the offer
    //                  is cancelled, or fulfilled. In other scenarios, the amount taken by the main contract
    //                  may be less, depending on other configurations.
    //
    //          - S: This is called the offerCut, expressed as a basis point. This determines the maximum amount
    //                  of ether the main contract can ever take in the various possible outcomes of an offer
    //                  (cancelled, expired, overbid, fulfilled, updated).
    //
    //          - P: This simply refers to the price that the bidder is offering the owner receive, upon
    //                  fulfillment of the offer process.
    //
    //          - Below is the formula that ties the symbols listed above together (S is % for brevity):
    //                  T = P + S * P

    // Flat fee (in wei) the main contract takes when offer has been expired or overbid. The fee serves as a
    // disincentive for abuse and allows recoupment of ether spent calling batchRemoveExpired on behalf of users.
    uint256 public unsuccessfulFee;
    // This is S, the maximum % the main contract takes on each offer. S represents the total amount paid when
    // an offer has been fulfilled or cancelled.
    uint256 public offerCut;

    /* ****** */
    /* EVENTS */
    /* ****** */

    event GlobalDurationUpdated(uint256 value);
    event MinimumTotalValueUpdated(uint256 value);
    event MinimumPriceIncrementUpdated(uint256 value);
    event OfferCutUpdated(uint256 value);
    event UnsuccessfulFeeUpdated(uint256 value);

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @notice Sets the minimumTotalValue value. This would impact offers created after this has been set, but
    ///  not existing offers.
    /// @notice Only callable by COO, when not frozen.
    /// @param _newMinTotal The minimumTotalValue value to set
    function setMinimumTotalValue(uint256 _newMinTotal) external onlyCOO whenNotFrozen {
        _setMinimumTotalValue(_newMinTotal, unsuccessfulFee);
        emit MinimumTotalValueUpdated(_newMinTotal);
    }

    /// @notice Sets the globalDuration value. All offers that are created or updated will compute a new expiration
    ///  time based on this.
    /// @notice Only callable by COO, when not frozen.
    /// @dev Need to check for underflow since function argument is 256 bits, and the offer expiration time is
    ///  packed into 64 bits in the Offer struct.
    /// @param _newDuration The globalDuration value to set.
    function setGlobalDuration(uint256 _newDuration) external onlyCOO whenNotFrozen {
        require(_newDuration == uint256(uint64(_newDuration)), "new globalDuration value must not underflow");
        globalDuration = _newDuration;
        emit GlobalDurationUpdated(_newDuration);
    }

    /// @notice Sets the offerCut value. All offers will compute a fee taken by this contract based on this
    ///  configuration.
    /// @notice Only callable by COO, when not frozen.
    /// @dev As this configuration is a basis point, the value to set must be less than or equal to 10000.
    /// @param _newOfferCut The offerCut value to set.
    function setOfferCut(uint256 _newOfferCut) external onlyCOO whenNotFrozen {
        _setOfferCut(_newOfferCut);
        emit OfferCutUpdated(_newOfferCut);
    }

    /// @notice Sets the unsuccessfulFee value. All offers that are unsuccessful (overbid or expired)
    ///  will have a flat fee taken by the main contract before being refunded to bidders.
    /// @notice Given Tmin (_minTotal), flat fee (_unsuccessfulFee),
    ///  Tmin ≥ (2 * flat fee) guarantees that offer prices ≥ flat fee, always. This is important to prevent the
    ///  existence of offers that, when overbid or expired, would result in the main contract taking too big of a cut.
    ///  In the case of a sufficiently low offer price, eg. the same as unsuccessfulFee, the most the main contract can
    ///  ever take is simply the amount of unsuccessfulFee.
    /// @notice Only callable by COO, when not frozen.
    /// @param _newUnsuccessfulFee The unsuccessfulFee value to set.
    function setUnsuccessfulFee(uint256 _newUnsuccessfulFee) external onlyCOO whenNotFrozen {
        require(minimumTotalValue >= (2 * _newUnsuccessfulFee), "unsuccessful value must be <= half of minimumTotalValue");
        unsuccessfulFee = _newUnsuccessfulFee;
        emit UnsuccessfulFeeUpdated(_newUnsuccessfulFee);
    }

    /// @notice Sets the minimumPriceIncrement value. All offers that are overbid must have a price greater
    ///  than the minimum increment computed from this basis point.
    /// @notice Only callable by COO, when not frozen.
    /// @dev As this configuration is a basis point, the value to set must be less than or equal to 10000.
    /// @param _newMinimumPriceIncrement The minimumPriceIncrement value to set.
    function setMinimumPriceIncrement(uint256 _newMinimumPriceIncrement) external onlyCOO whenNotFrozen {
        _setMinimumPriceIncrement(_newMinimumPriceIncrement);
        emit MinimumPriceIncrementUpdated(_newMinimumPriceIncrement);
    }

    /// @notice Utility function used internally for the setMinimumTotalValue method.
    /// @notice Given Tmin (_minTotal), flat fee (_unsuccessfulFee),
    ///  Tmin ≥ (2 * flat fee) guarantees that offer prices ≥ flat fee, always. This is important to prevent the
    ///  existence of offers that, when overbid or expired, would result in the main contract taking too big of a cut.
    ///  In the case of a sufficiently low offer price, eg. the same as unsuccessfulFee, the most the main contract can
    ///  ever take is simply the amount of unsuccessfulFee.
    /// @param _newMinTotal The minimumTotalValue value to set.
    /// @param _unsuccessfulFee The unsuccessfulFee value used to check if the _minTotal specified
    ///  is too low.
    function _setMinimumTotalValue(uint256 _newMinTotal, uint256 _unsuccessfulFee) internal {
        require(_newMinTotal >= (2 * _unsuccessfulFee), "minimum value must be >= 2 * unsuccessful fee");
        minimumTotalValue = _newMinTotal;
    }

    /// @dev As offerCut is a basis point, the value to set must be less than or equal to 10000.
    /// @param _newOfferCut The offerCut value to set.
    function _setOfferCut(uint256 _newOfferCut) internal {
        require(_newOfferCut <= 1e4, "offer cut must be a valid basis point");
        offerCut = _newOfferCut;
    }

    /// @dev As minimumPriceIncrement is a basis point, the value to set must be less than or equal to 10000.
    /// @param _newMinimumPriceIncrement The minimumPriceIncrement value to set.
    function _setMinimumPriceIncrement(uint256 _newMinimumPriceIncrement) internal {
        require(_newMinimumPriceIncrement <= 1e4, "minimum price increment must be a valid basis point");
        minimumPriceIncrement = _newMinimumPriceIncrement;
    }
}

/// @title Base contract for CryptoKitties Offers. Holds all common structs, events, and base variables.
/// @author Dapper Labs Inc. (https://www.dapperlabs.com)
contract OffersBase is OffersConfig {
    /*** EVENTS ***/

    /// @notice The OfferCreated event is emitted when an offer is created through
    ///  createOffer method.
    /// @param tokenId The token id that a bidder is offering to buy from the owner.
    /// @param bidder The creator of the offer.
    /// @param expiresAt The timestamp when the offer will be expire.
    /// @param total The total eth value the bidder sent to the Offer contract.
    /// @param offerPrice The eth price that the owner of the token will receive
    ///  if the offer is accepted.
    event OfferCreated(
        uint256 tokenId,
        address bidder,
        uint256 expiresAt,
        uint256 total,
        uint256 offerPrice
    );

    /// @notice The OfferCancelled event is emitted when an offer is cancelled before expired.
    /// @param tokenId The token id that the cancelled offer was offering to buy.
    /// @param bidder The creator of the offer.
    /// @param bidderReceived The eth amount that the bidder received as refund.
    /// @param fee The eth amount that CFO received as the fee for the cancellation.
    event OfferCancelled(
        uint256 tokenId,
        address bidder,
        uint256 bidderReceived,
        uint256 fee
    );

    /// @notice The OfferFulfilled event is emitted when an active offer has been fulfilled, meaning
    ///  the bidder now owns the token, and the orignal owner receives the eth amount from the offer.
    /// @param tokenId The token id that the fulfilled offer was offering to buy.
    /// @param bidder The creator of the offer.
    /// @param owner The original owner of the token who accepted the offer.
    /// @param ownerReceived The eth amount that the original owner received from the offer
    /// @param fee The eth amount that CFO received as the fee for the successfully fulfilling.
    event OfferFulfilled(
        uint256 tokenId,
        address bidder,
        address owner,
        uint256 ownerReceived,
        uint256 fee
    );

    /// @notice The OfferUpdated event is emitted when an active offer was either extended the expiry
    ///  or raised the price.
    /// @param tokenId The token id that the updated offer was offering to buy.
    /// @param bidder The creator of the offer, also is whom updated the offer.
    /// @param newExpiresAt The new expiry date of the updated offer.
    /// @param totalRaised The total eth value the bidder sent to the Offer contract to raise the offer.
    ///  if the totalRaised is 0, it means the offer was extended without raising the price.
    event OfferUpdated(
        uint256 tokenId,
        address bidder,
        uint256 newExpiresAt,
        uint256 totalRaised
    );

    /// @notice The ExpiredOfferRemoved event is emitted when an expired offer gets removed. The eth value will
    ///  be returned to the bidder's account, excluding the fee.
    /// @param tokenId The token id that the removed offer was offering to buy
    /// @param bidder The creator of the offer.
    /// @param bidderReceived The eth amount that the bidder received from the offer.
    /// @param fee The eth amount that CFO received as the fee.
    event ExpiredOfferRemoved(
      uint256 tokenId,
      address bidder,
      uint256 bidderReceived,
      uint256 fee
    );

    /// @notice The BidderWithdrewFundsWhenFrozen event is emitted when a bidder withdrew their eth value of
    ///  the offer when the contract is frozen.
    /// @param tokenId The token id that withdrawed offer was offering to buy
    /// @param bidder The creator of the offer, also is whom withdrawed the fund.
    /// @param amount The total amount that the bidder received.
    event BidderWithdrewFundsWhenFrozen(
        uint256 tokenId,
        address bidder,
        uint256 amount
    );


    /// @dev The PushFundsFailed event is emitted when the Offer contract fails to send certain amount of eth
    ///  to an address, e.g. sending the fund back to the bidder when the offer was overbidden by a higher offer.
    /// @param tokenId The token id of an offer that the sending fund is involved.
    /// @param to The address that is supposed to receive the fund but failed for any reason.
    /// @param amount The eth amount that the receiver fails to receive.
    event PushFundsFailed(
        uint256 tokenId,
        address to,
        uint256 amount
    );

    /*** DATA TYPES ***/

    /// @dev The Offer struct. The struct fits in two 256-bits words.
    struct Offer {
        // Time when offer expires
        uint64 expiresAt;
        // Bidder The creator of the offer
        address bidder;
        // Offer cut in basis points, which ranges from 0-10000.
        // It's the cut that CFO takes when the offer is successfully accepted by the owner.
        // This is stored in the offer struct so that it won't be changed if COO updates
        // the `offerCut` for new offers.
        uint16 offerCut;
        // Total value (in wei) a bidder sent in msg.value to create the offer
        uint128 total;
        // Fee (in wei) that CFO takes when the offer is expired or overbid.
        // This is stored in the offer struct so that it won't be changed if COO updates
        // the `unsuccessfulFee` for new offers.
        uint128 unsuccessfulFee;
    }

    /*** STORAGE ***/
    /// @notice Mapping from token id to its corresponding offer.
    /// @dev One token can only have one offer.
    ///  Making it public so that solc-0.4.24 will generate code to query offer by a given token id.
    mapping (uint256 => Offer) public tokenIdToOffer;

    /// @notice computes the minimum offer price to overbid a given offer with its offer price.
    ///  The new offer price has to be a certain percentage, which defined by `minimumPriceIncrement`,
    ///  higher than the previous offer price.
    /// @dev This won't overflow, because `_offerPrice` is in uint128, and `minimumPriceIncrement`
    ///  is 16 bits max.
    /// @param _offerPrice The amount of ether in wei as the offer price
    /// @return The minimum amount of ether in wei to overbid the given offer price
    function _computeMinimumOverbidPrice(uint256 _offerPrice) internal view returns (uint256) {
        return _offerPrice * (1e4 + minimumPriceIncrement) / 1e4;
    }

    /// @notice Computes the offer price that the owner will receive if the offer is accepted.
    /// @dev This is safe against overflow because msg.value and the total supply of ether is capped within 128 bits.
    /// @param _total The total value of the offer. Also is the msg.value that the bidder sent when
    ///  creating the offer.
    /// @param _offerCut The percentage in basis points that will be taken by the CFO if the offer is fulfilled.
    /// @return The offer price that the owner will receive if the offer is fulfilled.
    function _computeOfferPrice(uint256 _total, uint256 _offerCut) internal pure returns (uint256) {
        return _total * 1e4 / (1e4 + _offerCut);
    }

    /// @notice Check if an offer exists or not by checking the expiresAt field of the offer.
    ///  True if exists, False if not.
    /// @dev Assuming the expiresAt field is from the offer struct in storage.
    /// @dev Since expiry check always come right after the offer existance check, it will save some gas by checking
    /// both existance and expiry on one field, as it only reads from the storage once.
    /// @param _expiresAt The time at which the offer we want to validate expires.
    /// @return True or false (if the offer exists not).
    function _offerExists(uint256 _expiresAt) internal pure returns (bool) {
        return _expiresAt > 0;
    }

    /// @notice Check if an offer is still active by checking the expiresAt field of the offer. True if the offer is,
    ///  still active, False if the offer has expired,
    /// @dev Assuming the expiresAt field is from the offer struct in storage.
    /// @param _expiresAt The time at which the offer we want to validate expires.
    /// @return True or false (if the offer has expired or not).
    function _isOfferActive(uint256 _expiresAt) internal view returns (bool) {
        return now < _expiresAt;
    }

    /// @dev Try pushing the fund to an address.
    /// @notice If sending the fund to the `_to` address fails for whatever reason, then the logic
    ///  will continue and the amount will be kept under the LostAndFound account. Also an event `PushFundsFailed`
    ///  will be emitted for notifying the failure.
    /// @param _tokenId The token id for the offer.
    /// @param _to The address the main contract is attempting to send funds to.
    /// @param _amount The amount of funds (in wei) the main contract is attempting to send.
    function _tryPushFunds(uint256 _tokenId, address _to, uint256 _amount) internal {
        // Sending the amount of eth in wei, and handling the failure.
        // The gas spent transferring funds has a set upper limit
        bool success = _to.send(_amount);
        if (!success) {
            // If failed sending to the `_to` address, then keep the amount under the LostAndFound account by
            // accumulating totalLostAndFoundBalance.
            totalLostAndFoundBalance = totalLostAndFoundBalance + _amount;

            // Emitting the event lost amount.
            emit PushFundsFailed(_tokenId, _to, _amount);
        }
    }
}

/// @title Contract that manages funds from creation to fulfillment for offers made on any ERC-721 token.
/// @author Dapper Labs Inc. (https://www.dapperlabs.com)
/// @notice This generic contract interfaces with any ERC-721 compliant contract
contract Offers is OffersBase {

    // This is the main Offers contract. In order to keep our code separated into logical sections,
    // we've broken it up into multiple files using inheritance. This allows us to keep related code
    // collocated while still avoiding a single large file, which would be harder to maintain. The breakdown
    // is as follows:
    //
    //      - OffersBase: This contract defines the fundamental code that the main contract uses.
    //              This includes our main data storage, data types, events, and internal functions for
    //              managing offers in their lifecycle.
    //
    //      - OffersConfig: This contract manages the various configuration values that determine the
    //              details of the offers that get created, cancelled, overbid, expired, and fulfilled,
    //              as well as the fee structure that the offers will be operating with.
    //
    //      - OffersAccessControl: This contract manages the various addresses and constraints for
    //              operations that can be executed only by specific roles. The roles are: CEO, CFO,
    //              COO, and LostAndFound. Additionally, this contract exposes functions for the CFO
    //              to withdraw earnings and the LostAndFound account to withdraw any lost funds.

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    /// @notice Creates the main Offers smart contract instance and sets initial configuration values
    /// @param _nftAddress The address of the ERC-721 contract managing NFT ownership
    /// @param _cooAddress The address of the COO to set
    /// @param _globalDuration The initial globalDuration value to set
    /// @param _minimumTotalValue The initial minimumTotalValue value to set
    /// @param _minimumPriceIncrement The initial minimumPriceIncrement value to set
    /// @param _unsuccessfulFee The initial unsuccessfulFee value to set
    /// @param _offerCut The initial offerCut value to set
    constructor(
      address _nftAddress,
      address _cooAddress,
      uint256 _globalDuration,
      uint256 _minimumTotalValue,
      uint256 _minimumPriceIncrement,
      uint256 _unsuccessfulFee,
      uint256 _offerCut
    ) public {
        // The creator of the contract is the ceo
        ceoAddress = msg.sender;

        // Get reference of the address of the NFT contract
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721), "NFT Contract needs to support ERC721 Interface");
        nonFungibleContract = candidateContract;

        setCOO(_cooAddress);

        // Set initial claw-figuration values
        globalDuration = _globalDuration;
        unsuccessfulFee = _unsuccessfulFee;
        _setOfferCut(_offerCut);
        _setMinimumPriceIncrement(_minimumPriceIncrement);
        _setMinimumTotalValue(_minimumTotalValue, _unsuccessfulFee);
    }

    /// @notice Creates an offer on a token. This contract receives bidders funds and refunds the previous bidder
    ///  if this offer overbids a previously active (unexpired) offer.
    /// @notice When this offer overbids a previously active offer, this offer must have a price greater than
    ///  a certain percentage of the previous offer price, which the minimumOverbidPrice basis point specifies.
    ///  A flat fee is also taken from the previous offer before refund the previous bidder.
    /// @notice When there is a previous offer that has already expired but not yet been removed from storage,
    ///  the new offer can be created with any total value as long as it is greater than the minimumTotalValue.
    /// @notice Works only when contract is not frozen.
    /// @param _tokenId The token a bidder wants to create an offer for.
    function createOffer(uint256 _tokenId) external payable whenNotFrozen {
        // T = msg.value
        // Check that the total amount of the offer isn't below the meow-nimum
        require(msg.value >= minimumTotalValue, "offer total value must be above minimumTotalValue");

        uint256 _offerCut = offerCut;

        // P, the price that owner will see and receive if the offer is accepted.
        uint256 offerPrice = _computeOfferPrice(msg.value, _offerCut);

        Offer storage previousOffer = tokenIdToOffer[_tokenId];
        uint256 previousExpiresAt = previousOffer.expiresAt;

        uint256 toRefund = 0;

        // Check if tokenId already has an offer
        if (_offerExists(previousExpiresAt)) {
            uint256 previousOfferTotal = uint256(previousOffer.total);

            // If the previous offer is still active, the new offer needs to match the previous offer's price
            // plus a minimum required increment (minimumOverbidPrice).
            // We calculate the previous offer's price, the corresponding minimumOverbidPrice, and check if the
            // new offerPrice is greater than or equal to the minimumOverbidPrice
            // The owner is fur-tunate to have such a desirable kitty
            if (_isOfferActive(previousExpiresAt)) {
                uint256 previousPriceForOwner = _computeOfferPrice(previousOfferTotal, uint256(previousOffer.offerCut));
                uint256 minimumOverbidPrice = _computeMinimumOverbidPrice(previousPriceForOwner);
                require(offerPrice >= minimumOverbidPrice, "overbid price must match minimum price increment criteria");
            }

            uint256 cfoEarnings = previousOffer.unsuccessfulFee;
            // Bidder gets refund: T - flat fee
            // The in-fur-ior offer gets refunded for free, how nice.
            toRefund = previousOfferTotal - cfoEarnings;

            totalCFOEarnings += cfoEarnings;
        }

        uint256 newExpiresAt = now + globalDuration;

        // Get a reference of previous bidder address before overwriting with new offer.
        // This is only needed if there is refund
        address previousBidder;
        if (toRefund > 0) {
            previousBidder = previousOffer.bidder;
        }

        tokenIdToOffer[_tokenId] = Offer(
            uint64(newExpiresAt),
            msg.sender,
            uint16(_offerCut),
            uint128(msg.value),
            uint128(unsuccessfulFee)
        );

        // Postpone the refund until the previous offer has been overwritten by the new offer.
        if (toRefund > 0) {
            // Finally, sending funds to this bidder. If failed, the fund will be kept in escrow
            // under lostAndFound's address
            _tryPushFunds(
                _tokenId,
                previousBidder,
                toRefund
            );
        }

        emit OfferCreated(
            _tokenId,
            msg.sender,
            newExpiresAt,
            msg.value,
            offerPrice
        );
    }

    /// @notice Cancels an offer that must exist and be active currently. This moves funds from this contract
    ///  back to the the bidder, after a cut has been taken.
    /// @notice Works only when contract is not frozen.
    /// @param _tokenId The token specified by the offer a bidder wants to cancel
    function cancelOffer(uint256 _tokenId) external whenNotFrozen {
        // Check that offer exists and is active currently
        Offer storage offer = tokenIdToOffer[_tokenId];
        uint256 expiresAt = offer.expiresAt;
        require(_offerExists(expiresAt), "offer to cancel must exist");
        require(_isOfferActive(expiresAt), "offer to cancel must not be expired");

        address bidder = offer.bidder;
        require(msg.sender == bidder, "caller must be bidder of offer to be cancelled");

        // T
        uint256 total = uint256(offer.total);
        // P = T - S; Bidder gets all of P, CFO gets all of T - P
        uint256 toRefund = _computeOfferPrice(total, offer.offerCut);
        uint256 cfoEarnings = total - toRefund;

        // Remove offer from storage
        delete tokenIdToOffer[_tokenId];

        // Add to CFO's balance
        totalCFOEarnings += cfoEarnings;

        // Transfer money in escrow back to bidder
        _tryPushFunds(_tokenId, bidder, toRefund);

        emit OfferCancelled(
            _tokenId,
            bidder,
            toRefund,
            cfoEarnings
        );
    }

    /// @notice Fulfills an offer that must exist and be active currently. This moves the funds of the
    ///  offer held in escrow in this contract to the owner of the token, and atomically transfers the
    ///  token from the owner to the bidder. A cut is taken by this contract.
    /// @notice We also acknowledge the paw-sible difficulties of keeping in-sync with the Ethereum
    ///  blockchain, and have allowed for fulfilling offers by specifying the _minOfferPrice at which the owner
    ///  of the token is happy to accept the offer. Thus, the owner will always receive the latest offer
    ///  price, which can only be at least the _minOfferPrice that was specified. Specifically, this
    ///  implementation is designed to prevent the edge case where the owner accidentally accepts an offer
    ///  with a price lower than intended. For example, this can happen when the owner fulfills the offer
    ///  precisely when the offer expires and is subsequently replaced with a new offer priced lower.
    /// @notice Works only when contract is not frozen.
    /// @dev We make sure that the token is not on auction when we fulfill an offer, because the owner of the
    ///  token would be the auction contract instead of the user. This function requires that this Offers contract
    ///  is approved for the token in order to make the call to transfer token ownership. This is sufficient
    ///  because approvals are cleared on transfer (including transfer to the auction).
    /// @param _tokenId The token specified by the offer that will be fulfilled.
    /// @param _minOfferPrice The minimum price at which the owner of the token is happy to accept the offer.
    function fulfillOffer(uint256 _tokenId, uint128 _minOfferPrice) external whenNotFrozen {
        // Check that offer exists and is active currently
        Offer storage offer = tokenIdToOffer[_tokenId];
        uint256 expiresAt = offer.expiresAt;
        require(_offerExists(expiresAt), "offer to fulfill must exist");
        require(_isOfferActive(expiresAt), "offer to fulfill must not be expired");

        // Get the owner of the token
        address owner = nonFungibleContract.ownerOf(_tokenId);

        require(msg.sender == cooAddress || msg.sender == owner, "only COO or the owner can fulfill order");

        // T
        uint256 total = uint256(offer.total);
        // P = T - S
        uint256 offerPrice = _computeOfferPrice(total, offer.offerCut);

        // Check if the offer price is below the minimum that the owner is happy to accept the offer for
        require(offerPrice >= _minOfferPrice, "cannot fulfill offer – offer price too low");

        // Get a reference of the bidder address befur removing offer from storage
        address bidder = offer.bidder;

        // Remove offer from storage
        delete tokenIdToOffer[_tokenId];

        // Transfer token on behalf of owner to bidder
        nonFungibleContract.transferFrom(owner, bidder, _tokenId);

        // NFT has been transferred! Now calculate fees and transfer fund to the owner
        // T - P, the CFO's earnings
        uint256 cfoEarnings = total - offerPrice;
        totalCFOEarnings += cfoEarnings;

        // Transfer money in escrow to owner
        _tryPushFunds(_tokenId, owner, offerPrice);

        emit OfferFulfilled(
            _tokenId,
            bidder,
            owner,
            offerPrice,
            cfoEarnings
        );
    }

    /// @notice Removes any existing and inactive (expired) offers from storage. In doing so, this contract
    ///  takes a flat fee from the total amount attached to each offer before sending the remaining funds
    ///  back to the bidder.
    /// @notice Nothing will be done if the offer for a token is either non-existent or active.
    /// @param _tokenIds The array of tokenIds that will be removed from storage
    function batchRemoveExpired(uint256[] _tokenIds) external whenNotFrozen {
        uint256 len = _tokenIds.length;

        // Use temporary accumulator
        uint256 cumulativeCFOEarnings = 0;

        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = _tokenIds[i];
            Offer storage offer = tokenIdToOffer[tokenId];
            uint256 expiresAt = offer.expiresAt;

            // Skip the offer if not exist
            if (!_offerExists(expiresAt)) {
                continue;
            }
            // Skip if the offer has not expired yet
            if (_isOfferActive(expiresAt)) {
                continue;
            }

            // Get a reference of the bidder address before removing offer from storage
            address bidder = offer.bidder;

            // CFO gets the flat fee
            uint256 cfoEarnings = uint256(offer.unsuccessfulFee);

            // Bidder gets refund: T - flat
            uint256 toRefund = uint256(offer.total) - cfoEarnings;

            // Ensure the previous offer has been removed before refunding
            delete tokenIdToOffer[tokenId];

            // Add to cumulative balance of CFO's earnings
            cumulativeCFOEarnings += cfoEarnings;

            // Finally, sending funds to this bidder. If failed, the fund will be kept in escrow
            // under lostAndFound's address
            _tryPushFunds(
                tokenId,
                bidder,
                toRefund
            );

            emit ExpiredOfferRemoved(
                tokenId,
                bidder,
                toRefund,
                cfoEarnings
            );
        }

        // Add to CFO's balance if any expired offer has been removed
        if (cumulativeCFOEarnings > 0) {
            totalCFOEarnings += cumulativeCFOEarnings;
        }
    }

    /// @notice Updates an existing and active offer by setting a new expiration time and, optionally, raise
    ///  the price of the offer.
    /// @notice As the offers are always using the configuration values currently in storage, the updated
    ///  offer may be adhering to configuration values that are different at the time of its original creation.
    /// @dev We check msg.value to determine if the offer price should be raised. If 0, only a new
    ///  expiration time is set.
    /// @param _tokenId The token specified by the offer that will be updated.
    function updateOffer(uint256 _tokenId) external payable whenNotFrozen {
        // Check that offer exists and is active currently
        Offer storage offer = tokenIdToOffer[_tokenId];
        uint256 expiresAt = uint256(offer.expiresAt);
        require(_offerExists(expiresAt), "offer to update must exist");
        require(_isOfferActive(expiresAt), "offer to update must not be expired");

        require(msg.sender == offer.bidder, "caller must be bidder of offer to be updated");

        uint256 newExpiresAt = now + globalDuration;

        // Check if the caller wants to raise the offer as well
        if (msg.value > 0) {
            // Set the new price
            offer.total += uint128(msg.value);
        }

        offer.expiresAt = uint64(newExpiresAt);

        emit OfferUpdated(_tokenId, msg.sender, newExpiresAt, msg.value);

    }

    /// @notice Sends funds of each existing offer held in escrow back to bidders. The function is callable
    ///  by anyone.
    /// @notice Works only when contract is frozen. In this case, we want to allow all funds to be returned
    ///  without taking any fees.
    /// @param _tokenId The token specified by the offer a bidder wants to withdraw funds for.
    function bidderWithdrawFunds(uint256 _tokenId) external whenFrozen {
        // Check that offer exists
        Offer storage offer = tokenIdToOffer[_tokenId];
        require(_offerExists(offer.expiresAt), "offer to withdraw funds from must exist");
        require(msg.sender == offer.bidder, "only bidders can withdraw their funds in escrow");

        // Get a reference of the total to withdraw before removing offer from storage
        uint256 total = uint256(offer.total);

        delete tokenIdToOffer[_tokenId];

        // Send funds back to bidders!
        msg.sender.transfer(total);

        emit BidderWithdrewFundsWhenFrozen(_tokenId, msg.sender, total);
    }

    /// @notice we don't accept any value transfer.
    function() external payable {
        revert("we don't accept any payments!");
    }
}