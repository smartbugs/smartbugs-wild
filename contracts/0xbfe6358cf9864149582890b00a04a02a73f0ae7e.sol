pragma solidity =0.5.1;

contract Pmes {

    address public owner;
    uint256 public nextCid = 1;

    struct Content {
        string cus;
        string description;
        address owner;
        uint256 readPrice;
        uint256 writePrice;
    }
    mapping(uint256 => string[]) public reviews;
    enum OfferStatus {Cancelled, Rejected, Opened, Accepted}
    struct Offer {
        uint256 id;
        string buyerAccessString;
        string sellerPublicKey;
        string sellerAccessString;
        OfferStatus status;
        uint256 cid;
        address buyerId;
        uint256 offerType;
        uint256 price;
    }

    mapping(uint256 => Content) public contents;
    mapping(string => uint256)  CusToCid;
    function getCid(string memory cus) public view returns (uint256) {
        return CusToCid[cus];
    }

    uint256 public nextOfferId = 1;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => mapping(address => uint256)) public CidBuyerIdToOfferId;

    mapping(uint256 => uint256[]) public CidToOfferIds;
    mapping(address => uint256[]) public BuyerIdToOfferIds;

    // Access level mapping [address]
    // 0 - access denied
    // 1 - can edit existing content
    // 2 - can add content
    // 3 - can saleAccess
    // 4 - can changeOwner
    // 5 - can setAccessLevel
    mapping(address => uint256) public publishersMap;

    event postContent(uint256); // makeCid
    event postOffer(uint256, uint256, uint256, address); // makeOffer
    event acceptOffer(uint256); // sellContent, changeOwner
    event postReview(); // newReview

    constructor() public
    {
        // to prevent repeated calls
        require (owner == address(0x0));
        // set owner address
        owner = msg.sender;
    }

    function setAccessLevel(
        address publisherAddress,
        uint256 accessLevel
    )
        public
        minAccessLevel(5)
    {
        publishersMap[publisherAddress] = accessLevel;
    }

    function makeCid(
        string memory cus,
        address ownerId,
        string memory description,
        uint256 readPrice,
        uint256 writePrice
    )
        public
        minAccessLevel(2)
        returns (uint256)
    {
        // To prevent create already exist
        uint256 cid = CusToCid[cus];
        require(cid == 0, "Content already uploaded");

        cid = nextCid++;
        CusToCid[cus] = cid;

        contents[cid] = Content(cus, description, ownerId, readPrice, writePrice);
        emit postContent(cid);

        return cid;
    }

    function setReadPrice(uint256 cid, uint256 price) public minAccessLevel(1) {
        require(cid > 0 && cid < nextCid);
        contents[cid].readPrice = price;
    }

    function setWritePrice(uint256 cid, uint256 price) public minAccessLevel(1) {
        require(cid > 0 && cid < nextCid);
        contents[cid].writePrice = price;
    }

    function addReview(uint256 cid, address buyerId, string memory review) public minAccessLevel(1) {
        uint256 offerId = CidBuyerIdToOfferId[cid][buyerId];
        require(offerId != 0);
        require(offers[offerId].status == OfferStatus.Accepted);

        reviews[cid].push(review);
        emit postReview();
    }

    function setDescription(uint256 cid, string memory description) public minAccessLevel(1) {
        require(cid > 0 && cid < nextCid);
        contents[cid].description = description;
    }

    function changeOwner(
        uint256 cid,
        address buyerId,
        string memory sellerPublicKey,
        string memory sellerAccessString
    )
        public
        minAccessLevel(4)
    {
        uint256 offerId = CidBuyerIdToOfferId[cid][buyerId];
        require(offers[offerId].status == OfferStatus.Opened);
        contents[cid].owner = buyerId;
        offers[offerId].sellerAccessString = sellerAccessString;
        offers[offerId].sellerPublicKey = sellerPublicKey;
        offers[offerId].status = OfferStatus.Accepted;
        emit acceptOffer(cid);
    }

    function sellContent(
        uint256 cid,
        address buyerId,
        string memory sellerPublicKey,
        string memory sellerAccessString
    )
        public
        minAccessLevel(3)
    {
        uint256 offerId = CidBuyerIdToOfferId[cid][buyerId];
        require(offers[offerId].status == OfferStatus.Opened);
        offers[offerId].sellerAccessString = sellerAccessString;
        offers[offerId].sellerPublicKey = sellerPublicKey;
        offers[offerId].status = OfferStatus.Accepted;
        emit acceptOffer(cid);
    }

    function makeOffer(
        uint256 cid,
        address buyerId,
        uint256 offerType,
        uint256 price,
        string memory buyerAccessString
    )
        public
        minAccessLevel(2)
    {
        require(cid > 0 && cid < nextCid, "Wrong cid");
        // require(CidBuyerIdToOfferId[cid][buyerId] == 0, "");
        require(
            offers[CidBuyerIdToOfferId[cid][buyerId]].status != OfferStatus.Accepted &&
            offers[CidBuyerIdToOfferId[cid][buyerId]].status != OfferStatus.Opened,
            "Offer already exist"
        );

        offers[nextOfferId] = Offer(
            offers[CidBuyerIdToOfferId[cid][buyerId]].id + 1,
            buyerAccessString, 
            "none", 
            "none", 
            OfferStatus.Opened, 
            cid, 
            buyerId, 
            offerType, 
            price
        );

        CidBuyerIdToOfferId[cid][buyerId] = nextOfferId;

        CidToOfferIds[cid].push(nextOfferId);
        BuyerIdToOfferIds[buyerId].push(nextOfferId);

        emit postOffer(cid, offerType, price, buyerId);
        
        nextOfferId++;
    }

    function cancelOffer(uint256 cid, address buyerId) public minAccessLevel(2) {
        uint256 offerId = CidBuyerIdToOfferId[cid][buyerId];
        require(offers[offerId].status == OfferStatus.Opened);
        offers[offerId].status = OfferStatus.Cancelled;
    }

    function rejectOffer(uint256 cid, address buyerId) public minAccessLevel(2) {
        uint256 offerId = CidBuyerIdToOfferId[cid][buyerId];
        require(offers[offerId].status == OfferStatus.Opened);
        offers[offerId].status = OfferStatus.Rejected;
    }

    modifier minAccessLevel(uint256 level) {
        if(msg.sender != owner) {
            require(publishersMap[msg.sender] >= level);
        }
        _;
    }
}