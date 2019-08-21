pragma solidity ^0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract DBC {

    // MODIFIERS

    modifier pre_cond(bool condition) {
        require(condition);
        _;
    }

    modifier post_cond(bool condition) {
        _;
        assert(condition);
    }

    modifier invariant(bool condition) {
        require(condition);
        _;
        assert(condition);
    }
}

contract Owned is DBC {

    // FIELDS

    address public owner;

    // NON-CONSTANT METHODS

    function Owned() { owner = msg.sender; }

    function changeOwner(address ofNewOwner) pre_cond(isOwner()) { owner = ofNewOwner; }

    // PRE, POST, INVARIANT CONDITIONS

    function isOwner() internal returns (bool) { return msg.sender == owner; }

}

contract AssetRegistrar is DBC, Owned {

    // TYPES

    struct Asset {
        address breakIn; // Break in contract on destination chain
        address breakOut; // Break out contract on this chain; A way to leave
        bytes32 chainId; // On which chain this asset resides
        uint decimal; // Decimal, order of magnitude of precision, of the Asset as in ERC223 token standard
        bool exists; // Is this asset registered
        string ipfsHash; // Same as url but for ipfs
        string name; // Human-readable name of the Asset as in ERC223 token standard
        uint price; // Price of asset quoted against `QUOTE_ASSET` * 10 ** decimals
        string symbol; // Human-readable symbol of the Asset as in ERC223 token standard
        uint timestamp; // Timestamp of last price update of this asset
        string url; // URL for additional information of Asset
    }

    // FIELDS

    // Methods fields
    mapping (address => Asset) public information;

    // METHODS

    // PUBLIC METHODS

    /// @notice Registers an Asset residing in a chain
    /// @dev Pre: Only registrar owner should be able to register
    /// @dev Post: Address ofAsset is registered
    /// @param ofAsset Address of asset to be registered
    /// @param name Human-readable name of the Asset as in ERC223 token standard
    /// @param symbol Human-readable symbol of the Asset as in ERC223 token standard
    /// @param decimal Human-readable symbol of the Asset as in ERC223 token standard
    /// @param url Url for extended information of the asset
    /// @param ipfsHash Same as url but for ipfs
    /// @param chainId Chain where the asset resides
    /// @param breakIn Address of break in contract on destination chain
    /// @param breakOut Address of break out contract on this chain
    function register(
        address ofAsset,
        string name,
        string symbol,
        uint decimal,
        string url,
        string ipfsHash,
        bytes32 chainId,
        address breakIn,
        address breakOut
    )
        pre_cond(isOwner())
        pre_cond(!information[ofAsset].exists)
    {
        Asset asset = information[ofAsset];
        asset.name = name;
        asset.symbol = symbol;
        asset.decimal = decimal;
        asset.url = url;
        asset.ipfsHash = ipfsHash;
        asset.breakIn = breakIn;
        asset.breakOut = breakOut;
        asset.exists = true;
        assert(information[ofAsset].exists);
    }

    /// @notice Updates description information of a registered Asset
    /// @dev Pre: Owner can change an existing entry
    /// @dev Post: Changed Name, Symbol, URL and/or IPFSHash
    /// @param ofAsset Address of the asset to be updated
    /// @param name Human-readable name of the Asset as in ERC223 token standard
    /// @param symbol Human-readable symbol of the Asset as in ERC223 token standard
    /// @param url Url for extended information of the asset
    /// @param ipfsHash Same as url but for ipfs
    function updateDescriptiveInformation(
        address ofAsset,
        string name,
        string symbol,
        string url,
        string ipfsHash
    )
        pre_cond(isOwner())
        pre_cond(information[ofAsset].exists)
    {
        Asset asset = information[ofAsset];
        asset.name = name;
        asset.symbol = symbol;
        asset.url = url;
        asset.ipfsHash = ipfsHash;
    }

    /// @notice Deletes an existing entry
    /// @dev Owner can delete an existing entry
    /// @param ofAsset address for which specific information is requested
    function remove(
        address ofAsset
    )
        pre_cond(isOwner())
        pre_cond(information[ofAsset].exists)
    {
        delete information[ofAsset]; // Sets exists boolean to false
        assert(!information[ofAsset].exists);
    }

    // PUBLIC VIEW METHODS

    // Get asset specific information
    function getName(address ofAsset) view returns (string) { return information[ofAsset].name; }
    function getSymbol(address ofAsset) view returns (string) { return information[ofAsset].symbol; }
    function getDecimals(address ofAsset) view returns (uint) { return information[ofAsset].decimal; }

}

interface PriceFeedInterface {

    // EVENTS

    event PriceUpdated(uint timestamp);

    // PUBLIC METHODS

    function update(address[] ofAssets, uint[] newPrices);

    // PUBLIC VIEW METHODS

    // Get asset specific information
    function getName(address ofAsset) view returns (string);
    function getSymbol(address ofAsset) view returns (string);
    function getDecimals(address ofAsset) view returns (uint);
    // Get price feed operation specific information
    function getQuoteAsset() view returns (address);
    function getInterval() view returns (uint);
    function getValidity() view returns (uint);
    function getLastUpdateId() view returns (uint);
    // Get asset specific information as updated in price feed
    function hasRecentPrice(address ofAsset) view returns (bool isRecent);
    function hasRecentPrices(address[] ofAssets) view returns (bool areRecent);
    function getPrice(address ofAsset) view returns (bool isRecent, uint price, uint decimal);
    function getPrices(address[] ofAssets) view returns (bool areRecent, uint[] prices, uint[] decimals);
    function getInvertedPrice(address ofAsset) view returns (bool isRecent, uint invertedPrice, uint decimal);
    function getReferencePrice(address ofBase, address ofQuote) view returns (bool isRecent, uint referencePrice, uint decimal);
    function getOrderPrice(
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (uint orderPrice);
    function existsPriceOnAssetPair(address sellAsset, address buyAsset) view returns (bool isExistent);
}

contract PriceFeed is PriceFeedInterface, AssetRegistrar, DSMath {

    // FIELDS

    // Constructor fields
    address public QUOTE_ASSET; // Asset of a portfolio against which all other assets are priced
    /// Note: Interval is purely self imposed and for information purposes only
    uint public INTERVAL; // Frequency of updates in seconds
    uint public VALIDITY; // Time in seconds for which data is considered recent
    uint updateId;        // Update counter for this pricefeed; used as a check during investment

    // METHODS

    // CONSTRUCTOR

    /// @dev Define and register a quote asset against which all prices are measured/based against
    /// @param ofQuoteAsset Address of quote asset
    /// @param quoteAssetName Name of quote asset
    /// @param quoteAssetSymbol Symbol for quote asset
    /// @param quoteAssetDecimals Decimal places for quote asset
    /// @param quoteAssetUrl URL related to quote asset
    /// @param quoteAssetIpfsHash IPFS hash associated with quote asset
    /// @param quoteAssetChainId Chain ID associated with quote asset (e.g. "1" for main Ethereum network)
    /// @param quoteAssetBreakIn Break-in address for the quote asset
    /// @param quoteAssetBreakOut Break-out address for the quote asset
    /// @param interval Number of seconds between pricefeed updates (this interval is not enforced on-chain, but should be followed by the datafeed maintainer)
    /// @param validity Number of seconds that datafeed update information is valid for
    function PriceFeed(
        address ofQuoteAsset, // Inital entry in asset registrar contract is Melon (QUOTE_ASSET)
        string quoteAssetName,
        string quoteAssetSymbol,
        uint quoteAssetDecimals,
        string quoteAssetUrl,
        string quoteAssetIpfsHash,
        bytes32 quoteAssetChainId,
        address quoteAssetBreakIn,
        address quoteAssetBreakOut,
        uint interval,
        uint validity
    ) {
        QUOTE_ASSET = ofQuoteAsset;
        register(
            QUOTE_ASSET,
            quoteAssetName,
            quoteAssetSymbol,
            quoteAssetDecimals,
            quoteAssetUrl,
            quoteAssetIpfsHash,
            quoteAssetChainId,
            quoteAssetBreakIn,
            quoteAssetBreakOut
        );
        INTERVAL = interval;
        VALIDITY = validity;
    }

    // PUBLIC METHODS

    /// @dev Only Owner; Same sized input arrays
    /// @dev Updates price of asset relative to QUOTE_ASSET
    /** Ex:
     *  Let QUOTE_ASSET == MLN (base units), let asset == EUR-T,
     *  let Value of 1 EUR-T := 1 EUR == 0.080456789 MLN, hence price 0.080456789 MLN / EUR-T
     *  and let EUR-T decimals == 8.
     *  Input would be: information[EUR-T].price = 8045678 [MLN/ (EUR-T * 10**8)]
     */
    /// @param ofAssets list of asset addresses
    /// @param newPrices list of prices for each of the assets
    function update(address[] ofAssets, uint[] newPrices)
        pre_cond(isOwner())
        pre_cond(ofAssets.length == newPrices.length)
    {
        updateId += 1;
        for (uint i = 0; i < ofAssets.length; ++i) {
            require(information[ofAssets[i]].timestamp != now); // prevent two updates in one block
            require(information[ofAssets[i]].exists);
            information[ofAssets[i]].timestamp = now;
            information[ofAssets[i]].price = newPrices[i];
        }
        PriceUpdated(now);
    }

    // PUBLIC VIEW METHODS

    // Get pricefeed specific information
    function getQuoteAsset() view returns (address) { return QUOTE_ASSET; }
    function getInterval() view returns (uint) { return INTERVAL; }
    function getValidity() view returns (uint) { return VALIDITY; }
    function getLastUpdateId() view returns (uint) { return updateId; }

    /// @notice Whether price of asset has been updated less than VALIDITY seconds ago
    /// @param ofAsset Existend asset in AssetRegistrar
    /// @return isRecent Price information ofAsset is recent
    function hasRecentPrice(address ofAsset)
        view
        pre_cond(information[ofAsset].exists)
        returns (bool isRecent)
    {
        return sub(now, information[ofAsset].timestamp) <= VALIDITY;
    }

    /// @notice Whether prices of assets have been updated less than VALIDITY seconds ago
    /// @param ofAssets All asstes existend in AssetRegistrar
    /// @return isRecent Price information ofAssets array is recent
    function hasRecentPrices(address[] ofAssets)
        view
        returns (bool areRecent)
    {
        for (uint i; i < ofAssets.length; i++) {
            if (!hasRecentPrice(ofAssets[i])) {
                return false;
            }
        }
        return true;
    }

    /**
    @notice Gets price of an asset multiplied by ten to the power of assetDecimals
    @dev Asset has been registered
    @param ofAsset Asset for which price should be returned
    @return {
      "isRecent": "Whether the returned price is valid (as defined by VALIDITY)",
      "price": "Price formatting: mul(exchangePrice, 10 ** decimal), to avoid floating numbers",
      "decimal": "Decimal, order of magnitude of precision, of the Asset as in ERC223 token standard",
    }
    */
    function getPrice(address ofAsset)
        view
        returns (bool isRecent, uint price, uint decimal)
    {
        return (
            hasRecentPrice(ofAsset),
            information[ofAsset].price,
            information[ofAsset].decimal
        );
    }

    /**
    @notice Price of a registered asset in format (bool areRecent, uint[] prices, uint[] decimals)
    @dev Convention for price formatting: mul(price, 10 ** decimal), to avoid floating numbers
    @param ofAssets Assets for which prices should be returned
    @return {
        "areRecent":    "Whether all of the prices are fresh, given VALIDITY interval",
        "prices":       "Array of prices",
        "decimals":     "Array of decimal places for returned assets"
    }
    */
    function getPrices(address[] ofAssets)
        view
        returns (bool areRecent, uint[] prices, uint[] decimals)
    {
        areRecent = true;
        for (uint i; i < ofAssets.length; i++) {
            var (isRecent, price, decimal) = getPrice(ofAssets[i]);
            if (!isRecent) {
                areRecent = false;
            }
            prices[i] = price;
            decimals[i] = decimal;
        }
    }

    /**
    @notice Gets inverted price of an asset
    @dev Asset has been initialised and its price is non-zero
    @dev Existing price ofAssets quoted in QUOTE_ASSET (convention)
    @param ofAsset Asset for which inverted price should be return
    @return {
        "isRecent": "Whether the price is fresh, given VALIDITY interval",
        "invertedPrice": "Price based (instead of quoted) against QUOTE_ASSET",
        "decimal": "Decimal places for this asset"
    }
    */
    function getInvertedPrice(address ofAsset)
        view
        returns (bool isRecent, uint invertedPrice, uint decimal)
    {
        // inputPrice quoted in QUOTE_ASSET and multiplied by 10 ** assetDecimal
        var (isInvertedRecent, inputPrice, assetDecimal) = getPrice(ofAsset);

        // outputPrice based in QUOTE_ASSET and multiplied by 10 ** quoteDecimal
        uint quoteDecimal = getDecimals(QUOTE_ASSET);

        return (
            isInvertedRecent,
            mul(10 ** uint(quoteDecimal), 10 ** uint(assetDecimal)) / inputPrice,
            quoteDecimal
        );
    }

    /**
    @notice Gets reference price of an asset pair
    @dev One of the address is equal to quote asset
    @dev either ofBase == QUOTE_ASSET or ofQuote == QUOTE_ASSET
    @param ofBase Address of base asset
    @param ofQuote Address of quote asset
    @return {
        "isRecent": "Whether the price is fresh, given VALIDITY interval",
        "referencePrice": "Reference price",
        "decimal": "Decimal places for this asset"
    }
    */
    function getReferencePrice(address ofBase, address ofQuote)
        view
        returns (bool isRecent, uint referencePrice, uint decimal)
    {
        if (getQuoteAsset() == ofQuote) {
            (isRecent, referencePrice, decimal) = getPrice(ofBase);
        } else if (getQuoteAsset() == ofBase) {
            (isRecent, referencePrice, decimal) = getInvertedPrice(ofQuote);
        } else {
            revert(); // no suitable reference price available
        }
    }

    /// @notice Gets price of Order
    /// @param sellAsset Address of the asset to be sold
    /// @param buyAsset Address of the asset to be bought
    /// @param sellQuantity Quantity in base units being sold of sellAsset
    /// @param buyQuantity Quantity in base units being bought of buyAsset
    /// @return orderPrice Price as determined by an order
    function getOrderPrice(
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    )
        view
        returns (uint orderPrice)
    {
        return mul(buyQuantity, 10 ** uint(getDecimals(sellAsset))) / sellQuantity;
    }

    /// @notice Checks whether data exists for a given asset pair
    /// @dev Prices are only upated against QUOTE_ASSET
    /// @param sellAsset Asset for which check to be done if data exists
    /// @param buyAsset Asset for which check to be done if data exists
    /// @return Whether assets exist for given asset pair
    function existsPriceOnAssetPair(address sellAsset, address buyAsset)
        view
        returns (bool isExistent)
    {
        return
            hasRecentPrice(sellAsset) && // Is tradable asset (TODO cleaner) and datafeed delivering data
            hasRecentPrice(buyAsset) && // Is tradable asset (TODO cleaner) and datafeed delivering data
            (buyAsset == QUOTE_ASSET || sellAsset == QUOTE_ASSET) && // One asset must be QUOTE_ASSET
            (buyAsset != QUOTE_ASSET || sellAsset != QUOTE_ASSET); // Pair must consists of diffrent assets
    }
}