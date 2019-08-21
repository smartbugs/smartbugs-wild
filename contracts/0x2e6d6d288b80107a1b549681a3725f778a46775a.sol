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

contract WETH9_ {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}

interface FundInterface {

    // EVENTS

    event PortfolioContent(uint holdings, uint price, uint decimals);
    event RequestUpdated(uint id);
    event Invested(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event SpendingApproved(address onConsigned, address ofAsset, uint amount);
    event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
    event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
    event OrderUpdated(uint id);
    event LogError(uint ERROR_CODE);
    event ErrorMessage(string errorMessage);

    // EXTERNAL METHODS
    // Compliance by Investor
    function requestInvestment(uint giveQuantity, uint shareQuantity, bool isNativeAsset) external;
    function requestRedemption(uint shareQuantity, uint receiveQuantity, bool isNativeAsset) external;
    function executeRequest(uint requestId) external;
    function cancelRequest(uint requestId) external;
    function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
    // Administration by Manager
    function enableInvestment() external;
    function disableInvestment() external;
    function enableRedemption() external;
    function disableRedemption() external;
    function shutDown() external;
    // Managing by Manager
    function makeOrder(uint exchangeId, address sellAsset, address buyAsset, uint sellQuantity, uint buyQuantity) external;
    function takeOrder(uint exchangeId, uint id, uint quantity) external;
    function cancelOrder(uint exchangeId, uint id) external;

    // PUBLIC METHODS
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
    // Fees by Manager
    function allocateUnclaimedFees();

    // PUBLIC VIEW METHODS
    // Get general information
    function getModules() view returns (address, address, address);
    function getLastOrderId() view returns (uint);
    function getLastRequestId() view returns (uint);
    function getNameHash() view returns (bytes32);
    function getManager() view returns (address);

    // Get accounting information
    function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
    function calcSharePrice() view returns (uint);
}

interface AssetInterface {
    /*
     * Implements ERC 20 standard.
     * https://github.com/ethereum/EIPs/blob/f90864a3d2b2b45c4decf95efd26b3f0c276051a/EIPS/eip-20-token-standard.md
     * https://github.com/ethereum/EIPs/issues/20
     *
     *  Added support for the ERC 223 "tokenFallback" method in a "transfer" function with a payload.
     *  https://github.com/ethereum/EIPs/issues/223
     */

    // Events
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    // There is no ERC223 compatible Transfer event, with `_data` included.

    //ERC 223
    // PUBLIC METHODS
    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    // ERC 20
    // PUBLIC METHODS
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    // PUBLIC VIEW METHODS
    function balanceOf(address _owner) view public returns (uint balance);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
}

interface ERC223Interface {
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value) returns (bool);
    function transfer(address to, uint value, bytes data) returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

contract Asset is DSMath, AssetInterface, ERC223Interface {

    // DATA STRUCTURES

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;

    // PUBLIC METHODS

    /**
     * @notice Send `_value` tokens to `_to` from `msg.sender`
     * @dev Transfers sender's tokens to a given address
     * @dev Similar to transfer(address, uint, bytes), but without _data parameter
     * @param _to Address of token receiver
     * @param _value Number of tokens to transfer
     * @return Returns success of function call
     */
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        uint codeLength;
        bytes memory empty;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }
 
        require(balances[msg.sender] >= _value); // sanity checks
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        // if (codeLength > 0) {
        //     ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        //     receiver.tokenFallback(msg.sender, _value, empty);
        // }
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    /**
     * @notice Send `_value` tokens to `_to` from `msg.sender` and trigger tokenFallback if sender is a contract
     * @dev Function that is called when a user or contract wants to transfer funds
     * @param _to Address of token receiver
     * @param _value Number of tokens to transfer
     * @param _data Data to be sent to tokenFallback
     * @return Returns success of function call
     */
    function transfer(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        require(balances[msg.sender] >= _value); // sanity checks
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        // if (codeLength > 0) {
        //     ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        //     receiver.tokenFallback(msg.sender, _value, _data);
        // }
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice Transfer `_value` tokens from `_from` to `_to` if `msg.sender` is allowed.
    /// @notice Restriction: An account can only use this function to send to itself
    /// @dev Allows for an approved third party to transfer tokens from one
    /// address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        // require(_to == msg.sender); // can only use transferFrom to send to self

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);
        return true;
    }

    /// @notice Allows `_spender` to transfer `_value` tokens from `msg.sender` to any address.
    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != 0x0);

        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        // require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // PUBLIC VIEW METHODS

    /// @dev Returns number of allowed tokens that a spender can transfer on
    /// behalf of a token owner.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    /// @return Returns remaining allowance for spender.
    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by the given address.
    /// @param _owner Address of token owner.
    /// @return Returns balance of owner.
    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }
}

interface ERC223ReceivingContract {

    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _from Transaction initiator, analogue of msg.sender
    /// @param _value Number of tokens to transfer.
    /// @param _data Data containing a function signature and/or parameters
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

interface NativeAssetInterface {

    // PUBLIC METHODS
    function deposit() public payable;
    function withdraw(uint wad) public;
}

interface SharesInterface {

    event Created(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event Annihilated(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);

    // VIEW METHODS

    function getName() view returns (string);
    function getSymbol() view returns (string);
    function getDecimals() view returns (uint);
    function getCreationTime() view returns (uint);
    function toSmallestShareUnit(uint quantity) view returns (uint);
    function toWholeShareUnit(uint quantity) view returns (uint);

}

contract Shares is Asset, SharesInterface {

    // FIELDS

    // Constructor fields
    string public name;
    string public symbol;
    uint public decimal;
    uint public creationTime;

    // METHODS

    // CONSTRUCTOR

    /// @param _name Name these shares
    /// @param _symbol Symbol of shares
    /// @param _decimal Amount of decimals sharePrice is denominated in, defined to be equal as deciamls in REFERENCE_ASSET contract
    /// @param _creationTime Timestamp of share creation
    function Shares(string _name, string _symbol, uint _decimal, uint _creationTime) {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        creationTime = _creationTime;
    }

    // PUBLIC METHODS
    // PUBLIC VIEW METHODS

    function getName() view returns (string) { return name; }
    function getSymbol() view returns (string) { return symbol; }
    function getDecimals() view returns (uint) { return decimal; }
    function getCreationTime() view returns (uint) { return creationTime; }
    function toSmallestShareUnit(uint quantity) view returns (uint) { return mul(quantity, 10 ** getDecimals()); }
    function toWholeShareUnit(uint quantity) view returns (uint) { return quantity / (10 ** getDecimals()); }
    function transfer(address _to, uint256 _value) public returns (bool) { require(_to == address(this)); }
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) { require(_to == address(this)); }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { require(_to == address(this)); }

    // INTERNAL METHODS

    /// @param recipient Address the new shares should be sent to
    /// @param shareQuantity Number of shares to be created
    function createShares(address recipient, uint shareQuantity) internal {
        totalSupply = add(totalSupply, shareQuantity);
        balances[recipient] = add(balances[recipient], shareQuantity);
        Created(msg.sender, now, shareQuantity);
    }

    /// @param recipient Address the new shares should be taken from when destroyed
    /// @param shareQuantity Number of shares to be annihilated
    function annihilateShares(address recipient, uint shareQuantity) internal {
        totalSupply = sub(totalSupply, shareQuantity);
        balances[recipient] = sub(balances[recipient], shareQuantity);
        Annihilated(msg.sender, now, shareQuantity);
    }
}

contract RestrictedShares is Shares {

    // CONSTRUCTOR

    /// @param _name Name these shares
    /// @param _symbol Symbol of shares
    /// @param _decimal Amount of decimals sharePrice is denominated in, defined to be equal as deciamls in REFERENCE_ASSET contract
    /// @param _creationTime Timestamp of share creation
    function RestrictedShares(
        string _name,
        string _symbol,
        uint _decimal,
        uint _creationTime
    ) Shares(_name, _symbol, _decimal, _creationTime) {}

    // PUBLIC METHODS

    /**
     * @notice Send `_value` tokens to `_to` from `msg.sender`
     * @dev Transfers sender's tokens to a given address
     * @dev Similar to transfer(address, uint, bytes), but without _data parameter
     * @param _to Address of token receiver
     * @param _value Number of tokens to transfer
     * @return Returns success of function call
     */
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        require(msg.sender == address(this) || _to == address(this));
        uint codeLength;
        bytes memory empty;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        require(balances[msg.sender] >= _value); // sanity checks
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    /**
     * @notice Send `_value` tokens to `_to` from `msg.sender` and trigger tokenFallback if sender is a contract
     * @dev Function that is called when a user or contract wants to transfer funds
     * @param _to Address of token receiver
     * @param _value Number of tokens to transfer
     * @param _data Data to be sent to tokenFallback
     * @return Returns success of function call
     */
    function transfer(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        require(msg.sender == address(this) || _to == address(this));
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        require(balances[msg.sender] >= _value); // sanity checks
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice Allows `_spender` to transfer `_value` tokens from `msg.sender` to any address.
    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint _value) public returns (bool) {
        require(msg.sender == address(this));
        require(_spender != 0x0);

        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

}

interface ComplianceInterface {

    // PUBLIC VIEW METHODS

    /// @notice Checks whether investment is permitted for a participant
    /// @param ofParticipant Address requesting to invest in a Melon fund
    /// @param giveQuantity Quantity of Melon token times 10 ** 18 offered to receive shareQuantity
    /// @param shareQuantity Quantity of shares times 10 ** 18 requested to be received
    /// @return Whether identity is eligible to invest in a Melon fund.
    function isInvestmentPermitted(
        address ofParticipant,
        uint256 giveQuantity,
        uint256 shareQuantity
    ) view returns (bool);

    /// @notice Checks whether redemption is permitted for a participant
    /// @param ofParticipant Address requesting to redeem from a Melon fund
    /// @param shareQuantity Quantity of shares times 10 ** 18 offered to redeem
    /// @param receiveQuantity Quantity of Melon token times 10 ** 18 requested to receive for shareQuantity
    /// @return Whether identity is eligible to redeem from a Melon fund.
    function isRedemptionPermitted(
        address ofParticipant,
        uint256 shareQuantity,
        uint256 receiveQuantity
    ) view returns (bool);
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

contract Fund is DSMath, DBC, Owned, RestrictedShares, FundInterface, ERC223ReceivingContract {
    // TYPES

    struct Modules { // Describes all modular parts, standardised through an interface
        PriceFeedInterface pricefeed; // Provides all external data
        ComplianceInterface compliance; // Boolean functions regarding invest/redeem
        RiskMgmtInterface riskmgmt; // Boolean functions regarding make/take orders
    }

    struct Calculations { // List of internal calculations
        uint gav; // Gross asset value
        uint managementFee; // Time based fee
        uint performanceFee; // Performance based fee measured against QUOTE_ASSET
        uint unclaimedFees; // Fees not yet allocated to the fund manager
        uint nav; // Net asset value
        uint highWaterMark; // A record of best all-time fund performance
        uint totalSupply; // Total supply of shares
        uint timestamp; // Time when calculations are performed in seconds
    }

    enum RequestStatus { active, cancelled, executed }
    enum RequestType { invest, redeem, tokenFallbackRedeem }
    struct Request { // Describes and logs whenever asset enter and leave fund due to Participants
        address participant; // Participant in Melon fund requesting investment or redemption
        RequestStatus status; // Enum: active, cancelled, executed; Status of request
        RequestType requestType; // Enum: invest, redeem, tokenFallbackRedeem
        address requestAsset; // Address of the asset being requested
        uint shareQuantity; // Quantity of Melon fund shares
        uint giveQuantity; // Quantity in Melon asset to give to Melon fund to receive shareQuantity
        uint receiveQuantity; // Quantity in Melon asset to receive from Melon fund for given shareQuantity
        uint timestamp;     // Time of request creation in seconds
        uint atUpdateId;    // Pricefeed updateId when this request was created
    }

    enum OrderStatus { active, partiallyFilled, fullyFilled, cancelled }
    enum OrderType { make, take }
    struct Order { // Describes and logs whenever assets enter and leave fund due to Manager
        uint exchangeId; // Id as returned from exchange
        OrderStatus status; // Enum: active, partiallyFilled, fullyFilled, cancelled
        OrderType orderType; // Enum: make, take
        address sellAsset; // Asset (as registered in Asset registrar) to be sold
        address buyAsset; // Asset (as registered in Asset registrar) to be bought
        uint sellQuantity; // Quantity of sellAsset to be sold
        uint buyQuantity; // Quantity of sellAsset to be bought
        uint timestamp; // Time of order creation in seconds
        uint fillQuantity; // Buy quantity filled; Always less than buy_quantity
    }

    struct Exchange {
        address exchange; // Address of the exchange
        ExchangeInterface exchangeAdapter; //Exchange adapter contracts respective to the exchange
        bool isApproveOnly; // True in case of exchange implementation which requires  are approved when an order is made instead of transfer
    }

    // FIELDS

    // Constant fields
    uint public constant MAX_FUND_ASSETS = 90; // Max ownable assets by the fund supported by gas limits
    // Constructor fields
    uint public MANAGEMENT_FEE_RATE; // Fee rate in QUOTE_ASSET per delta improvement in WAD
    uint public PERFORMANCE_FEE_RATE; // Fee rate in QUOTE_ASSET per managed seconds in WAD
    address public VERSION; // Address of Version contract
    Asset public QUOTE_ASSET; // QUOTE asset as ERC20 contract
    NativeAssetInterface public NATIVE_ASSET; // Native asset as ERC20 contract
    // Methods fields
    Modules public module; // Struct which holds all the initialised module instances
    Exchange[] public exchanges; // Array containing exchanges this fund supports
    Calculations public atLastUnclaimedFeeAllocation; // Calculation results at last allocateUnclaimedFees() call
    bool public isShutDown; // Security feature, if yes than investing, managing, allocateUnclaimedFees gets blocked
    Request[] public requests; // All the requests this fund received from participants
    bool public isInvestAllowed; // User option, if false fund rejects Melon investments
    bool public isRedeemAllowed; // User option, if false fund rejects Melon redemptions; Redemptions using slices always possible
    Order[] public orders; // All the orders this fund placed on exchanges
    mapping (uint => mapping(address => uint)) public exchangeIdsToOpenMakeOrderIds; // exchangeIndex to: asset to open make order ID ; if no open make orders, orderID is zero
    address[] public ownedAssets; // List of all assets owned by the fund or for which the fund has open make orders
    mapping (address => bool) public isInAssetList; // Mapping from asset to whether the asset exists in ownedAssets
    mapping (address => bool) public isInOpenMakeOrder; // Mapping from asset to whether the asset is in a open make order as buy asset

    // METHODS

    // CONSTRUCTOR

    /// @dev Should only be called via Version.setupFund(..)
    /// @param withName human-readable descriptive name (not necessarily unique)
    /// @param ofQuoteAsset Asset against which mgmt and performance fee is measured against and which can be used to invest/redeem using this single asset
    /// @param ofManagementFee A time based fee expressed, given in a number which is divided by 1 WAD
    /// @param ofPerformanceFee A time performance based fee, performance relative to ofQuoteAsset, given in a number which is divided by 1 WAD
    /// @param ofCompliance Address of compliance module
    /// @param ofRiskMgmt Address of risk management module
    /// @param ofPriceFeed Address of price feed module
    /// @param ofExchanges Addresses of exchange on which this fund can trade
    /// @param ofExchangeAdapters Addresses of exchange adapters
    /// @return Deployed Fund with manager set as ofManager
    function Fund(
        address ofManager,
        string withName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofNativeAsset,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofExchangeAdapters
    )
        RestrictedShares(withName, "MLNF", 18, now)
    {
        isInvestAllowed = true;
        isRedeemAllowed = true;
        owner = ofManager;
        require(ofManagementFee < 10 ** 18); // Require management fee to be less than 100 percent
        MANAGEMENT_FEE_RATE = ofManagementFee; // 1 percent is expressed as 0.01 * 10 ** 18
        require(ofPerformanceFee < 10 ** 18); // Require performance fee to be less than 100 percent
        PERFORMANCE_FEE_RATE = ofPerformanceFee; // 1 percent is expressed as 0.01 * 10 ** 18
        VERSION = msg.sender;
        module.compliance = ComplianceInterface(ofCompliance);
        module.riskmgmt = RiskMgmtInterface(ofRiskMgmt);
        module.pricefeed = PriceFeedInterface(ofPriceFeed);
        // Bridged to Melon exchange interface by exchangeAdapter library
        for (uint i = 0; i < ofExchanges.length; ++i) {
            ExchangeInterface adapter = ExchangeInterface(ofExchangeAdapters[i]);
            bool isApproveOnly = adapter.isApproveOnly();
            exchanges.push(Exchange({
                exchange: ofExchanges[i],
                exchangeAdapter: adapter,
                isApproveOnly: isApproveOnly
            }));
        }
        // Require Quote assets exists in pricefeed
        QUOTE_ASSET = Asset(ofQuoteAsset);
        NATIVE_ASSET = NativeAssetInterface(ofNativeAsset);
        // Quote Asset and Native asset always in owned assets list
        ownedAssets.push(ofQuoteAsset);
        isInAssetList[ofQuoteAsset] = true;
        ownedAssets.push(ofNativeAsset);
        isInAssetList[ofNativeAsset] = true;
        require(address(QUOTE_ASSET) == module.pricefeed.getQuoteAsset()); // Sanity check
        atLastUnclaimedFeeAllocation = Calculations({
            gav: 0,
            managementFee: 0,
            performanceFee: 0,
            unclaimedFees: 0,
            nav: 0,
            highWaterMark: 10 ** getDecimals(),
            totalSupply: totalSupply,
            timestamp: now
        });
    }

    // EXTERNAL METHODS

    // EXTERNAL : ADMINISTRATION

    function enableInvestment() external pre_cond(isOwner()) { isInvestAllowed = true; }
    function disableInvestment() external pre_cond(isOwner()) { isInvestAllowed = false; }
    function enableRedemption() external pre_cond(isOwner()) { isRedeemAllowed = true; }
    function disableRedemption() external pre_cond(isOwner()) { isRedeemAllowed = false; }
    function shutDown() external pre_cond(msg.sender == VERSION) { isShutDown = true; }


    // EXTERNAL : PARTICIPATION

    /// @notice Give melon tokens to receive shares of this fund
    /// @dev Recommended to give some leeway in prices to account for possibly slightly changing prices
    /// @param giveQuantity Quantity of Melon token times 10 ** 18 offered to receive shareQuantity
    /// @param shareQuantity Quantity of shares times 10 ** 18 requested to be received
    function requestInvestment(
        uint giveQuantity,
        uint shareQuantity,
        bool isNativeAsset
    )
        external
        pre_cond(!isShutDown)
        pre_cond(isInvestAllowed) // investment using Melon has not been deactivated by the Manager
        pre_cond(module.compliance.isInvestmentPermitted(msg.sender, giveQuantity, shareQuantity))    // Compliance Module: Investment permitted
    {
        requests.push(Request({
            participant: msg.sender,
            status: RequestStatus.active,
            requestType: RequestType.invest,
            requestAsset: isNativeAsset ? address(NATIVE_ASSET) : address(QUOTE_ASSET),
            shareQuantity: shareQuantity,
            giveQuantity: giveQuantity,
            receiveQuantity: shareQuantity,
            timestamp: now,
            atUpdateId: module.pricefeed.getLastUpdateId()
        }));
        RequestUpdated(getLastRequestId());
    }

    /// @notice Give shares of this fund to receive melon tokens
    /// @dev Recommended to give some leeway in prices to account for possibly slightly changing prices
    /// @param shareQuantity Quantity of shares times 10 ** 18 offered to redeem
    /// @param receiveQuantity Quantity of Melon token times 10 ** 18 requested to receive for shareQuantity
    function requestRedemption(
        uint shareQuantity,
        uint receiveQuantity,
        bool isNativeAsset
      )
        external
        pre_cond(!isShutDown)
        pre_cond(isRedeemAllowed) // Redemption using Melon has not been deactivated by Manager
        pre_cond(module.compliance.isRedemptionPermitted(msg.sender, shareQuantity, receiveQuantity)) // Compliance Module: Redemption permitted
    {
        requests.push(Request({
            participant: msg.sender,
            status: RequestStatus.active,
            requestType: RequestType.redeem,
            requestAsset: isNativeAsset ? address(NATIVE_ASSET) : address(QUOTE_ASSET),
            shareQuantity: shareQuantity,
            giveQuantity: shareQuantity,
            receiveQuantity: receiveQuantity,
            timestamp: now,
            atUpdateId: module.pricefeed.getLastUpdateId()
        }));
        RequestUpdated(getLastRequestId());
    }

    /// @notice Executes active investment and redemption requests, in a way that minimises information advantages of investor
    /// @dev Distributes melon and shares according to the request
    /// @param id Index of request to be executed
    /// @dev Active investment or redemption request executed
    function executeRequest(uint id)
        external
        pre_cond(!isShutDown)
        pre_cond(requests[id].status == RequestStatus.active)
        pre_cond(requests[id].requestType != RequestType.redeem || requests[id].shareQuantity <= balances[requests[id].participant]) // request owner does not own enough shares
        pre_cond(
            totalSupply == 0 ||
            (
                now >= add(requests[id].timestamp, module.pricefeed.getInterval()) &&
                module.pricefeed.getLastUpdateId() >= add(requests[id].atUpdateId, 2)
            )
        )   // PriceFeed Module: Wait at least one interval time and two updates before continuing (unless it is the first investment)
         // PriceFeed Module: No recent updates for fund asset list
    {
        // sharePrice quoted in QUOTE_ASSET and multiplied by 10 ** fundDecimals
        // based in QUOTE_ASSET and multiplied by 10 ** fundDecimals
        require(module.pricefeed.hasRecentPrice(address(QUOTE_ASSET)));
        require(module.pricefeed.hasRecentPrices(ownedAssets));
        var (isRecent, , ) = module.pricefeed.getInvertedPrice(address(QUOTE_ASSET));
        // TODO: check precision of below otherwise use; uint costQuantity = toWholeShareUnit(mul(request.shareQuantity, calcSharePrice()));
        // By definition quoteDecimals == fundDecimals
        Request request = requests[id];

        uint costQuantity = toWholeShareUnit(mul(request.shareQuantity, calcSharePrice()));
        if (request.requestAsset == address(NATIVE_ASSET)) {
            var (isPriceRecent, invertedNativeAssetPrice, nativeAssetDecimal) = module.pricefeed.getInvertedPrice(address(NATIVE_ASSET));
            if (!isPriceRecent) {
                revert();
            }
            costQuantity = mul(costQuantity, invertedNativeAssetPrice) / 10 ** nativeAssetDecimal;
        }

        if (
            isInvestAllowed &&
            request.requestType == RequestType.invest &&
            costQuantity <= request.giveQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transferFrom(request.participant, this, costQuantity)); // Allocate Value
            createShares(request.participant, request.shareQuantity); // Accounting
        } else if (
            isRedeemAllowed &&
            request.requestType == RequestType.redeem &&
            request.receiveQuantity <= costQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transfer(request.participant, costQuantity)); // Return value
            annihilateShares(request.participant, request.shareQuantity); // Accounting
        } else if (
            isRedeemAllowed &&
            request.requestType == RequestType.tokenFallbackRedeem &&
            request.receiveQuantity <= costQuantity
        ) {
            request.status = RequestStatus.executed;
            assert(AssetInterface(request.requestAsset).transfer(request.participant, costQuantity)); // Return value
            annihilateShares(this, request.shareQuantity); // Accounting
        } else {
            revert(); // Invalid Request or invalid giveQuantity / receiveQuantity
        }
    }

    /// @notice Cancels active investment and redemption requests
    /// @param id Index of request to be executed
    function cancelRequest(uint id)
        external
        pre_cond(requests[id].status == RequestStatus.active) // Request is active
        pre_cond(requests[id].participant == msg.sender || isShutDown) // Either request creator or fund is shut down
    {
        requests[id].status = RequestStatus.cancelled;
    }

    /// @notice Redeems by allocating an ownership percentage of each asset to the participant
    /// @dev Independent of running price feed!
    /// @param shareQuantity Number of shares owned by the participant, which the participant would like to redeem for individual assets
    /// @return Whether all assets sent to shareholder or not
    function redeemAllOwnedAssets(uint shareQuantity)
        external
        returns (bool success)
    {
        return emergencyRedeem(shareQuantity, ownedAssets);
    }

    // EXTERNAL : MANAGING

    /// @notice Makes an order on the selected exchange
    /// @dev These are orders that are not expected to settle immediately.  Sufficient balance (== sellQuantity) of sellAsset
    /// @param sellAsset Asset (as registered in Asset registrar) to be sold
    /// @param buyAsset Asset (as registered in Asset registrar) to be bought
    /// @param sellQuantity Quantity of sellAsset to be sold
    /// @param buyQuantity Quantity of buyAsset to be bought
    function makeOrder(
        uint exchangeNumber,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    )
        external
        pre_cond(isOwner())
        pre_cond(!isShutDown)
    {
        require(buyAsset != address(this)); // Prevent buying of own fund token
        require(quantityHeldInCustodyOfExchange(sellAsset) == 0); // Curr only one make order per sellAsset allowed. Please wait or cancel existing make order.
        require(module.pricefeed.existsPriceOnAssetPair(sellAsset, buyAsset)); // PriceFeed module: Requested asset pair not valid
        var (isRecent, referencePrice, ) = module.pricefeed.getReferencePrice(sellAsset, buyAsset);
        require(isRecent);  // Reference price is required to be recent
        require(
            module.riskmgmt.isMakePermitted(
                module.pricefeed.getOrderPrice(
                    sellAsset,
                    buyAsset,
                    sellQuantity,
                    buyQuantity
                ),
                referencePrice,
                sellAsset,
                buyAsset,
                sellQuantity,
                buyQuantity
            )
        ); // RiskMgmt module: Make order not permitted
        require(isInAssetList[buyAsset] || ownedAssets.length < MAX_FUND_ASSETS); // Limit for max ownable assets by the fund reached
        require(AssetInterface(sellAsset).approve(exchanges[exchangeNumber].exchange, sellQuantity)); // Approve exchange to spend assets

        // Since there is only one openMakeOrder allowed for each asset, we can assume that openMakeOrderId is set as zero by quantityHeldInCustodyOfExchange() function
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("makeOrder(address,address,address,uint256,uint256)")), exchanges[exchangeNumber].exchange, sellAsset, buyAsset, sellQuantity, buyQuantity));
        exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset] = exchanges[exchangeNumber].exchangeAdapter.getLastOrderId(exchanges[exchangeNumber].exchange);

        // Success defined as non-zero order id
        require(exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset] != 0);

        // Update ownedAssets array and isInAssetList, isInOpenMakeOrder mapping
        isInOpenMakeOrder[buyAsset] = true;
        if (!isInAssetList[buyAsset]) {
            ownedAssets.push(buyAsset);
            isInAssetList[buyAsset] = true;
        }

        orders.push(Order({
            exchangeId: exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset],
            status: OrderStatus.active,
            orderType: OrderType.make,
            sellAsset: sellAsset,
            buyAsset: buyAsset,
            sellQuantity: sellQuantity,
            buyQuantity: buyQuantity,
            timestamp: now,
            fillQuantity: 0
        }));

        OrderUpdated(exchangeIdsToOpenMakeOrderIds[exchangeNumber][sellAsset]);
    }

    /// @notice Takes an active order on the selected exchange
    /// @dev These are orders that are expected to settle immediately
    /// @param id Active order id
    /// @param receiveQuantity Buy quantity of what others are selling on selected Exchange
    function takeOrder(uint exchangeNumber, uint id, uint receiveQuantity)
        external
        pre_cond(isOwner())
        pre_cond(!isShutDown)
    {
        // Get information of order by order id
        Order memory order; // Inverse variable terminology! Buying what another person is selling
        (
            order.sellAsset,
            order.buyAsset,
            order.sellQuantity,
            order.buyQuantity
        ) = exchanges[exchangeNumber].exchangeAdapter.getOrder(exchanges[exchangeNumber].exchange, id);
        // Check pre conditions
        require(order.sellAsset != address(this)); // Prevent buying of own fund token
        require(module.pricefeed.existsPriceOnAssetPair(order.buyAsset, order.sellAsset)); // PriceFeed module: Requested asset pair not valid
        require(isInAssetList[order.sellAsset] || ownedAssets.length < MAX_FUND_ASSETS); // Limit for max ownable assets by the fund reached
        var (isRecent, referencePrice, ) = module.pricefeed.getReferencePrice(order.buyAsset, order.sellAsset);
        require(isRecent); // Reference price is required to be recent
        require(receiveQuantity <= order.sellQuantity); // Not enough quantity of order for what is trying to be bought
        uint spendQuantity = mul(receiveQuantity, order.buyQuantity) / order.sellQuantity;
        require(AssetInterface(order.buyAsset).approve(exchanges[exchangeNumber].exchange, spendQuantity)); // Could not approve spending of spendQuantity of order.buyAsset
        require(
            module.riskmgmt.isTakePermitted(
            module.pricefeed.getOrderPrice(
                order.buyAsset,
                order.sellAsset,
                order.buyQuantity, // spendQuantity
                order.sellQuantity // receiveQuantity
            ),
            referencePrice,
            order.buyAsset,
            order.sellAsset,
            order.buyQuantity,
            order.sellQuantity
        )); // RiskMgmt module: Take order not permitted

        // Execute request
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("takeOrder(address,uint256,uint256)")), exchanges[exchangeNumber].exchange, id, receiveQuantity));

        // Update ownedAssets array and isInAssetList mapping
        if (!isInAssetList[order.sellAsset]) {
            ownedAssets.push(order.sellAsset);
            isInAssetList[order.sellAsset] = true;
        }

        order.exchangeId = id;
        order.status = OrderStatus.fullyFilled;
        order.orderType = OrderType.take;
        order.timestamp = now;
        order.fillQuantity = receiveQuantity;
        orders.push(order);
        OrderUpdated(id);
    }

    /// @notice Cancels orders that were not expected to settle immediately, i.e. makeOrders
    /// @dev Reduce exposure with exchange interaction
    /// @param id Active order id of this order array with order owner of this contract on selected Exchange
    function cancelOrder(uint exchangeNumber, uint id)
        external
        pre_cond(isOwner() || isShutDown)
    {
        // Get information of fund order by order id
        Order order = orders[id];

        // Execute request
        require(address(exchanges[exchangeNumber].exchangeAdapter).delegatecall(bytes4(keccak256("cancelOrder(address,uint256)")), exchanges[exchangeNumber].exchange, order.exchangeId));

        order.status = OrderStatus.cancelled;
        OrderUpdated(id);
    }


    // PUBLIC METHODS

    // PUBLIC METHODS : ERC223

    /// @dev Standard ERC223 function that handles incoming token transfers.
    /// @dev This type of redemption can be seen as a "market order", where price is calculated at execution time
    /// @param ofSender  Token sender address.
    /// @param tokenAmount Amount of tokens sent.
    /// @param metadata  Transaction metadata.
    function tokenFallback(
        address ofSender,
        uint tokenAmount,
        bytes metadata
    ) {
        if (msg.sender != address(this)) {
            // when ofSender is a recognized exchange, receive tokens, otherwise revert
            for (uint i; i < exchanges.length; i++) {
                if (exchanges[i].exchange == ofSender) return; // receive tokens and do nothing
            }
            revert();
        } else {    // otherwise, make a redemption request
            requests.push(Request({
                participant: ofSender,
                status: RequestStatus.active,
                requestType: RequestType.tokenFallbackRedeem,
                requestAsset: address(QUOTE_ASSET), // redeem in QUOTE_ASSET
                shareQuantity: tokenAmount,
                giveQuantity: tokenAmount,              // shares being sent
                receiveQuantity: 0,          // value of the shares at request time
                timestamp: now,
                atUpdateId: module.pricefeed.getLastUpdateId()
            }));
            RequestUpdated(getLastRequestId());
        }
    }


    // PUBLIC METHODS : ACCOUNTING

    /// @notice Calculates gross asset value of the fund
    /// @dev Decimals in assets must be equal to decimals in PriceFeed for all entries in AssetRegistrar
    /// @dev Assumes that module.pricefeed.getPrice(..) returns recent prices
    /// @return gav Gross asset value quoted in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    function calcGav() returns (uint gav) {
        // prices quoted in QUOTE_ASSET and multiplied by 10 ** assetDecimal
        address[] memory tempOwnedAssets; // To store ownedAssets
        tempOwnedAssets = ownedAssets;
        delete ownedAssets;
        for (uint i = 0; i < tempOwnedAssets.length; ++i) {
            address ofAsset = tempOwnedAssets[i];
            // assetHoldings formatting: mul(exchangeHoldings, 10 ** assetDecimal)
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(this)), // asset base units held by fund
                quantityHeldInCustodyOfExchange(ofAsset)
            );
            // assetPrice formatting: mul(exchangePrice, 10 ** assetDecimal)
            var (isRecent, assetPrice, assetDecimals) = module.pricefeed.getPrice(ofAsset);
            if (!isRecent) {
                revert();
            }
            // gav as sum of mul(assetHoldings, assetPrice) with formatting: mul(mul(exchangeHoldings, exchangePrice), 10 ** shareDecimals)
            gav = add(gav, mul(assetHoldings, assetPrice) / (10 ** uint256(assetDecimals)));   // Sum up product of asset holdings of this vault and asset prices
            if (assetHoldings != 0 || ofAsset == address(QUOTE_ASSET) || ofAsset == address(NATIVE_ASSET) || isInOpenMakeOrder[ofAsset]) { // Check if asset holdings is not zero or is address(QUOTE_ASSET) or in open make order
                ownedAssets.push(ofAsset);
            } else {
                isInAssetList[ofAsset] = false; // Remove from ownedAssets if asset holdings are zero
            }
            PortfolioContent(assetHoldings, assetPrice, assetDecimals);
        }
    }

    /**
    @notice Calculates unclaimed fees of the fund manager
    @param gav Gross asset value in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    @return {
      "managementFees": "A time (seconds) based fee in QUOTE_ASSET and multiplied by 10 ** shareDecimals",
      "performanceFees": "A performance (rise of sharePrice measured in QUOTE_ASSET) based fee in QUOTE_ASSET and multiplied by 10 ** shareDecimals",
      "unclaimedfees": "The sum of both managementfee and performancefee in QUOTE_ASSET and multiplied by 10 ** shareDecimals"
    }
    */
    function calcUnclaimedFees(uint gav)
        view
        returns (
            uint managementFee,
            uint performanceFee,
            uint unclaimedFees)
    {
        // Management fee calculation
        uint timePassed = sub(now, atLastUnclaimedFeeAllocation.timestamp);
        uint gavPercentage = mul(timePassed, gav) / (1 years);
        managementFee = wmul(gavPercentage, MANAGEMENT_FEE_RATE);

        // Performance fee calculation
        // Handle potential division through zero by defining a default value
        uint valuePerShareExclMgmtFees = totalSupply > 0 ? calcValuePerShare(sub(gav, managementFee), totalSupply) : toSmallestShareUnit(1);
        if (valuePerShareExclMgmtFees > atLastUnclaimedFeeAllocation.highWaterMark) {
            uint gainInSharePrice = sub(valuePerShareExclMgmtFees, atLastUnclaimedFeeAllocation.highWaterMark);
            uint investmentProfits = wmul(gainInSharePrice, totalSupply);
            performanceFee = wmul(investmentProfits, PERFORMANCE_FEE_RATE);
        }

        // Sum of all FEES
        unclaimedFees = add(managementFee, performanceFee);
    }

    /// @notice Calculates the Net asset value of this fund
    /// @param gav Gross asset value of this fund in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    /// @param unclaimedFees The sum of both managementFee and performanceFee in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    /// @return nav Net asset value in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    function calcNav(uint gav, uint unclaimedFees)
        view
        returns (uint nav)
    {
        nav = sub(gav, unclaimedFees);
    }

    /// @notice Calculates the share price of the fund
    /// @dev Convention for valuePerShare (== sharePrice) formatting: mul(totalValue / numShares, 10 ** decimal), to avoid floating numbers
    /// @dev Non-zero share supply; value denominated in [base unit of melonAsset]
    /// @param totalValue the total value in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    /// @param numShares the number of shares multiplied by 10 ** shareDecimals
    /// @return valuePerShare Share price denominated in QUOTE_ASSET and multiplied by 10 ** shareDecimals
    function calcValuePerShare(uint totalValue, uint numShares)
        view
        pre_cond(numShares > 0)
        returns (uint valuePerShare)
    {
        valuePerShare = toSmallestShareUnit(totalValue) / numShares;
    }

    /**
    @notice Calculates essential fund metrics
    @return {
      "gav": "Gross asset value of this fund denominated in [base unit of melonAsset]",
      "managementFee": "A time (seconds) based fee",
      "performanceFee": "A performance (rise of sharePrice measured in QUOTE_ASSET) based fee",
      "unclaimedFees": "The sum of both managementFee and performanceFee denominated in [base unit of melonAsset]",
      "feesShareQuantity": "The number of shares to be given as fees to the manager",
      "nav": "Net asset value denominated in [base unit of melonAsset]",
      "sharePrice": "Share price denominated in [base unit of melonAsset]"
    }
    */
    function performCalculations()
        view
        returns (
            uint gav,
            uint managementFee,
            uint performanceFee,
            uint unclaimedFees,
            uint feesShareQuantity,
            uint nav,
            uint sharePrice
        )
    {
        gav = calcGav(); // Reflects value independent of fees
        (managementFee, performanceFee, unclaimedFees) = calcUnclaimedFees(gav);
        nav = calcNav(gav, unclaimedFees);

        // The value of unclaimedFees measured in shares of this fund at current value
        feesShareQuantity = (gav == 0) ? 0 : mul(totalSupply, unclaimedFees) / gav;
        // The total share supply including the value of unclaimedFees, measured in shares of this fund
        uint totalSupplyAccountingForFees = add(totalSupply, feesShareQuantity);
        sharePrice = nav > 0 ? calcValuePerShare(nav, totalSupplyAccountingForFees) : toSmallestShareUnit(1); // Handle potential division through zero by defining a default value
    }

    /// @notice Converts unclaimed fees of the manager into fund shares
    /// @dev Only Owner
    function allocateUnclaimedFees()
        pre_cond(isOwner())
    {
        var (
            gav,
            managementFee,
            performanceFee,
            unclaimedFees,
            feesShareQuantity,
            nav,
            sharePrice
        ) = performCalculations();

        createShares(owner, feesShareQuantity); // Updates totalSupply by creating shares allocated to manager

        // Update Calculations
        uint highWaterMark = atLastUnclaimedFeeAllocation.highWaterMark >= sharePrice ? atLastUnclaimedFeeAllocation.highWaterMark : sharePrice;
        atLastUnclaimedFeeAllocation = Calculations({
            gav: gav,
            managementFee: managementFee,
            performanceFee: performanceFee,
            unclaimedFees: unclaimedFees,
            nav: nav,
            highWaterMark: highWaterMark,
            totalSupply: totalSupply,
            timestamp: now
        });

        FeesConverted(now, feesShareQuantity, unclaimedFees);
        CalculationUpdate(now, managementFee, performanceFee, nav, sharePrice, totalSupply);
    }

    // PUBLIC : REDEEMING

    /// @notice Redeems by allocating an ownership percentage only of requestedAssets to the participant
    /// @dev Independent of running price feed! Note: if requestedAssets != ownedAssets then participant misses out on some owned value
    /// @param shareQuantity Number of shares owned by the participant, which the participant would like to redeem for individual assets
    /// @param requestedAssets List of addresses that consitute a subset of ownedAssets.
    /// @return Whether all assets sent to shareholder or not
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets)
        public
        pre_cond(balances[msg.sender] >= shareQuantity)  // sender owns enough shares
        returns (bool)
    {
        uint[] memory ownershipQuantities = new uint[](requestedAssets.length);

        // Check whether enough assets held by fund
        for (uint i = 0; i < requestedAssets.length; ++i) {
            address ofAsset = requestedAssets[i];
            uint assetHoldings = add(
                uint(AssetInterface(ofAsset).balanceOf(this)),
                quantityHeldInCustodyOfExchange(ofAsset)
            );

            if (assetHoldings == 0) continue;

            // participant's ownership percentage of asset holdings
            ownershipQuantities[i] = mul(assetHoldings, shareQuantity) / totalSupply;

            // CRITICAL ERR: Not enough fund asset balance for owed ownershipQuantitiy, eg in case of unreturned asset quantity at address(exchanges[i].exchange) address
            if (uint(AssetInterface(ofAsset).balanceOf(this)) < ownershipQuantities[i]) {
                isShutDown = true;
                ErrorMessage("CRITICAL ERR: Not enough assetHoldings for owed ownershipQuantitiy");
                return false;
            }
        }

        // Annihilate shares before external calls to prevent reentrancy
        annihilateShares(msg.sender, shareQuantity);

        // Transfer ownershipQuantity of Assets
        for (uint j = 0; j < ownershipQuantities.length; ++j) {
            // Failed to send owed ownershipQuantity from fund to participant
            if (!AssetInterface(ofAsset).transfer(msg.sender, ownershipQuantities[j])) {
                revert();
            }
        }
        Redeemed(msg.sender, now, shareQuantity);
        return true;
    }

    // PUBLIC : FEES

    /// @dev Quantity of asset held in exchange according to associated order id
    /// @param ofAsset Address of asset
    /// @return Quantity of input asset held in exchange
    function quantityHeldInCustodyOfExchange(address ofAsset) returns (uint) {
        uint totalSellQuantity;     // quantity in custody across exchanges
        uint totalSellQuantityInApprove; // quantity of asset in approve (allowance) but not custody of exchange
        for (uint i; i < exchanges.length; i++) {
            if (exchangeIdsToOpenMakeOrderIds[i][ofAsset] == 0) {
                continue;
            }
            var (sellAsset, , sellQuantity, ) = exchanges[i].exchangeAdapter.getOrder(exchanges[i].exchange, exchangeIdsToOpenMakeOrderIds[i][ofAsset]);
            if (sellQuantity == 0) {
                exchangeIdsToOpenMakeOrderIds[i][ofAsset] = 0;
            }
            totalSellQuantity = add(totalSellQuantity, sellQuantity);
            if (exchanges[i].isApproveOnly) {
                totalSellQuantityInApprove += sellQuantity;
            }
        }
        if (totalSellQuantity == 0) {
            isInOpenMakeOrder[sellAsset] = false;
        }
        return sub(totalSellQuantity, totalSellQuantityInApprove); // Since quantity in approve is not actually in custody
    }

    // PUBLIC VIEW METHODS

    /// @notice Calculates sharePrice denominated in [base unit of melonAsset]
    /// @return sharePrice Share price denominated in [base unit of melonAsset]
    function calcSharePrice() view returns (uint sharePrice) {
        (, , , , , sharePrice) = performCalculations();
        return sharePrice;
    }

    function getModules() view returns (address, address, address) {
        return (
            address(module.pricefeed),
            address(module.compliance),
            address(module.riskmgmt)
        );
    }

    function getLastOrderId() view returns (uint) { return orders.length - 1; }
    function getLastRequestId() view returns (uint) { return requests.length - 1; }
    function getNameHash() view returns (bytes32) { return bytes32(keccak256(name)); }
    function getManager() view returns (address) { return owner; }
}

interface ExchangeInterface {

    // EVENTS

    event OrderUpdated(uint id);

    // METHODS
    // EXTERNAL METHODS

    function makeOrder(
        address onExchange,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) external returns (uint);
    function takeOrder(address onExchange, uint id, uint quantity) external returns (bool);
    function cancelOrder(address onExchange, uint id) external returns (bool);


    // PUBLIC METHODS
    // PUBLIC VIEW METHODS

    function isApproveOnly() view returns (bool);
    function getLastOrderId(address onExchange) view returns (uint);
    function isActive(address onExchange, uint id) view returns (bool);
    function getOwner(address onExchange, uint id) view returns (address);
    function getOrder(address onExchange, uint id) view returns (address, address, uint, uint);
    function getTimestamp(address onExchange, uint id) view returns (uint);

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

interface RiskMgmtInterface {

    // METHODS
    // PUBLIC VIEW METHODS

    /// @notice Checks if the makeOrder price is reasonable and not manipulative
    /// @param orderPrice Price of Order
    /// @param referencePrice Reference price obtained through PriceFeed contract
    /// @param sellAsset Asset (as registered in Asset registrar) to be sold
    /// @param buyAsset Asset (as registered in Asset registrar) to be bought
    /// @param sellQuantity Quantity of sellAsset to be sold
    /// @param buyQuantity Quantity of buyAsset to be bought
    /// @return If makeOrder is permitted
    function isMakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);

    /// @notice Checks if the takeOrder price is reasonable and not manipulative
    /// @param orderPrice Price of Order
    /// @param referencePrice Reference price obtained through PriceFeed contract
    /// @param sellAsset Asset (as registered in Asset registrar) to be sold
    /// @param buyAsset Asset (as registered in Asset registrar) to be bought
    /// @param sellQuantity Quantity of sellAsset to be sold
    /// @param buyQuantity Quantity of buyAsset to be bought
    /// @return If takeOrder is permitted
    function isTakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);
}

interface VersionInterface {

    // EVENTS

    event FundUpdated(uint id);

    // PUBLIC METHODS

    function shutDown() external;

    function setupFund(
        string ofFundName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofExchangeAdapters,
        uint8 v,
        bytes32 r,
        bytes32 s
    );
    function shutDownFund(address ofFund);

    // PUBLIC VIEW METHODS

    function getNativeAsset() view returns (address);
    function getFundById(uint withId) view returns (address);
    function getLastFundId() view returns (uint);
    function getFundByManager(address ofManager) view returns (address);
    function termsAndConditionsAreSigned(uint8 v, bytes32 r, bytes32 s) view returns (bool signed);

}

contract Version is DBC, Owned, VersionInterface {
    // FIELDS

    // Constant fields
    bytes32 public constant TERMS_AND_CONDITIONS = 0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad; // Hashed terms and conditions as displayed on IPFS.
    // Constructor fields
    string public VERSION_NUMBER; // SemVer of Melon protocol version
    address public NATIVE_ASSET; // Address of wrapped native asset contract
    address public GOVERNANCE; // Address of Melon protocol governance contract
    // Methods fields
    bool public isShutDown; // Governance feature, if yes than setupFund gets blocked and shutDownFund gets opened
    address[] public listOfFunds; // A complete list of fund addresses created using this version
    mapping (address => address) public managerToFunds; // Links manager address to fund address created using this version

    // EVENTS

    event FundUpdated(address ofFund);

    // METHODS

    // CONSTRUCTOR

    /// @param versionNumber SemVer of Melon protocol version
    /// @param ofGovernance Address of Melon governance contract
    /// @param ofNativeAsset Address of wrapped native asset contract
    function Version(
        string versionNumber,
        address ofGovernance,
        address ofNativeAsset
    ) {
        VERSION_NUMBER = versionNumber;
        GOVERNANCE = ofGovernance;
        NATIVE_ASSET = ofNativeAsset;
    }

    // EXTERNAL METHODS

    function shutDown() external pre_cond(msg.sender == GOVERNANCE) { isShutDown = true; }

    // PUBLIC METHODS

    /// @param ofFundName human-readable descriptive name (not necessarily unique)
    /// @param ofQuoteAsset Asset against which performance fee is measured against
    /// @param ofManagementFee A time based fee, given in a number which is divided by 10 ** 15
    /// @param ofPerformanceFee A time performance based fee, performance relative to ofQuoteAsset, given in a number which is divided by 10 ** 15
    /// @param ofCompliance Address of participation module
    /// @param ofRiskMgmt Address of risk management module
    /// @param ofPriceFeed Address of price feed module
    /// @param ofExchanges Addresses of exchange on which this fund can trade
    /// @param ofExchangeAdapters Addresses of exchange adapters
    /// @param v ellipitc curve parameter v
    /// @param r ellipitc curve parameter r
    /// @param s ellipitc curve parameter s
    function setupFund(
        string ofFundName,
        address ofQuoteAsset,
        uint ofManagementFee,
        uint ofPerformanceFee,
        address ofCompliance,
        address ofRiskMgmt,
        address ofPriceFeed,
        address[] ofExchanges,
        address[] ofExchangeAdapters,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) {
        require(!isShutDown);
        require(termsAndConditionsAreSigned(v, r, s));
        // Either novel fund name or previous owner of fund name
        require(managerToFunds[msg.sender] == 0); // Add limitation for simpler migration process of shutting down and setting up fund
        address ofFund = new Fund(
            msg.sender,
            ofFundName,
            ofQuoteAsset,
            ofManagementFee,
            ofPerformanceFee,
            NATIVE_ASSET,
            ofCompliance,
            ofRiskMgmt,
            ofPriceFeed,
            ofExchanges,
            ofExchangeAdapters
        );
        listOfFunds.push(ofFund);
        managerToFunds[msg.sender] = ofFund;
        FundUpdated(ofFund);
    }

    /// @dev Dereference Fund and trigger selfdestruct
    /// @param ofFund Address of the fund to be shut down
    function shutDownFund(address ofFund)
        pre_cond(isShutDown || managerToFunds[msg.sender] == ofFund)
    {
        Fund fund = Fund(ofFund);
        delete managerToFunds[msg.sender];
        fund.shutDown();
        FundUpdated(ofFund);
    }

    // PUBLIC VIEW METHODS

    /// @dev Proof that terms and conditions have been read and understood
    /// @param v ellipitc curve parameter v
    /// @param r ellipitc curve parameter r
    /// @param s ellipitc curve parameter s
    /// @return signed Whether or not terms and conditions have been read and understood
    function termsAndConditionsAreSigned(uint8 v, bytes32 r, bytes32 s) view returns (bool signed) {
        return ecrecover(
            // Parity does prepend \x19Ethereum Signed Message:\n{len(message)} before signing.
            //  Signature order has also been changed in 1.6.7 and upcoming 1.7.x,
            //  it will return rsv (same as geth; where v is [27, 28]).
            // Note that if you are using ecrecover, v will be either "00" or "01".
            //  As a result, in order to use this value, you will have to parse it to an
            //  integer and then add 27. This will result in either a 27 or a 28.
            //  https://github.com/ethereum/wiki/wiki/JavaScript-API#web3ethsign
            keccak256("\x19Ethereum Signed Message:\n32", TERMS_AND_CONDITIONS),
            v,
            r,
            s
        ) == msg.sender; // Has sender signed TERMS_AND_CONDITIONS
    }

    function getNativeAsset() view returns (address) { return NATIVE_ASSET; }
    function getFundById(uint withId) view returns (address) { return listOfFunds[withId]; }
    function getLastFundId() view returns (uint) { return listOfFunds.length - 1; }
    function getFundByManager(address ofManager) view returns (address) { return managerToFunds[ofManager]; }
}