pragma solidity 0.4.25;

/// @title provides subject to role checking logic
contract IAccessPolicy {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice We don't make this function constant to allow for state-updating access controls such as rate limiting.
    /// @dev checks if subject belongs to requested role for particular object
    /// @param subject address to be checked against role, typically msg.sender
    /// @param role identifier of required role
    /// @param object contract instance context for role checking, typically contract requesting the check
    /// @param verb additional data, in current AccessControll implementation msg.sig
    /// @return if subject belongs to a role
    function allowed(
        address subject,
        bytes32 role,
        address object,
        bytes4 verb
    )
        public
        returns (bool);
}

/// @title enables access control in implementing contract
/// @dev see AccessControlled for implementation
contract IAccessControlled {

    ////////////////////////
    // Events
    ////////////////////////

    /// @dev must log on access policy change
    event LogAccessPolicyChanged(
        address controller,
        IAccessPolicy oldPolicy,
        IAccessPolicy newPolicy
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev allows to change access control mechanism for this contract
    ///     this method must be itself access controlled, see AccessControlled implementation and notice below
    /// @notice it is a huge issue for Solidity that modifiers are not part of function signature
    ///     then interfaces could be used for example to control access semantics
    /// @param newPolicy new access policy to controll this contract
    /// @param newAccessController address of ROLE_ACCESS_CONTROLLER of new policy that can set access to this contract
    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public;

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy);

}

contract StandardRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    // @notice Soldity somehow doesn't evaluate this compile time
    // @dev role which has rights to change permissions and set new policy in contract, keccak256("AccessController")
    bytes32 internal constant ROLE_ACCESS_CONTROLLER = 0xac42f8beb17975ed062dcb80c63e6d203ef1c2c335ced149dc5664cc671cb7da;
}

/// @title Granular code execution permissions
/// @notice Intended to replace existing Ownable pattern with more granular permissions set to execute smart contract functions
///     for each function where 'only' modifier is applied, IAccessPolicy implementation is called to evaluate if msg.sender belongs to required role for contract being called.
///     Access evaluation specific belong to IAccessPolicy implementation, see RoleBasedAccessPolicy for details.
/// @dev Should be inherited by a contract requiring such permissions controll. IAccessPolicy must be provided in constructor. Access policy may be replaced to a different one
///     by msg.sender with ROLE_ACCESS_CONTROLLER role
contract AccessControlled is IAccessControlled, StandardRoles {

    ////////////////////////
    // Mutable state
    ////////////////////////

    IAccessPolicy private _accessPolicy;

    ////////////////////////
    // Modifiers
    ////////////////////////

    /// @dev limits function execution only to senders assigned to required 'role'
    modifier only(bytes32 role) {
        require(_accessPolicy.allowed(msg.sender, role, this, msg.sig));
        _;
    }

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(IAccessPolicy policy) internal {
        require(address(policy) != 0x0);
        _accessPolicy = policy;
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    //
    // Implements IAccessControlled
    //

    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
        // ROLE_ACCESS_CONTROLLER must be present
        // under the new policy. This provides some
        // protection against locking yourself out.
        require(newPolicy.allowed(newAccessController, ROLE_ACCESS_CONTROLLER, this, msg.sig));

        // We can now safely set the new policy without foot shooting.
        IAccessPolicy oldPolicy = _accessPolicy;
        _accessPolicy = newPolicy;

        // Log event
        emit LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);
    }

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy)
    {
        return _accessPolicy;
    }
}

contract Math {

    ////////////////////////
    // Internal functions
    ////////////////////////

    // absolute difference: |v1 - v2|
    function absDiff(uint256 v1, uint256 v2)
        internal
        pure
        returns(uint256)
    {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    // divide v by d, round up if remainder is 0.5 or more
    function divRound(uint256 v, uint256 d)
        internal
        pure
        returns(uint256)
    {
        return add(v, d/2) / d;
    }

    // computes decimal decimalFraction 'frac' of 'amount' with maximum precision (multiplication first)
    // both amount and decimalFraction must have 18 decimals precision, frac 10**18 represents a whole (100% of) amount
    // mind loss of precision as decimal fractions do not have finite binary expansion
    // do not use instead of division
    function decimalFraction(uint256 amount, uint256 frac)
        internal
        pure
        returns(uint256)
    {
        // it's like 1 ether is 100% proportion
        return proportion(amount, frac, 10**18);
    }

    // computes part/total of amount with maximum precision (multiplication first)
    // part and total must have the same units
    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        pure
        returns(uint256)
    {
        return divRound(mul(amount, part), total);
    }

    //
    // Open Zeppelin Math library below
    //

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}

/// @title standard access roles of the Platform
/// @dev constants are kept in CODE not in STORAGE so they are comparatively cheap
contract AccessRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    // NOTE: All roles are set to the keccak256 hash of the
    // CamelCased role name, i.e.
    // ROLE_LOCKED_ACCOUNT_ADMIN = keccak256("LockedAccountAdmin")

    // May issue (generate) Neumarks
    bytes32 internal constant ROLE_NEUMARK_ISSUER = 0x921c3afa1f1fff707a785f953a1e197bd28c9c50e300424e015953cbf120c06c;

    // May burn Neumarks it owns
    bytes32 internal constant ROLE_NEUMARK_BURNER = 0x19ce331285f41739cd3362a3ec176edffe014311c0f8075834fdd19d6718e69f;

    // May create new snapshots on Neumark
    bytes32 internal constant ROLE_SNAPSHOT_CREATOR = 0x08c1785afc57f933523bc52583a72ce9e19b2241354e04dd86f41f887e3d8174;

    // May enable/disable transfers on Neumark
    bytes32 internal constant ROLE_TRANSFER_ADMIN = 0xb6527e944caca3d151b1f94e49ac5e223142694860743e66164720e034ec9b19;

    // may reclaim tokens/ether from contracts supporting IReclaimable interface
    bytes32 internal constant ROLE_RECLAIMER = 0x0542bbd0c672578966dcc525b30aa16723bb042675554ac5b0362f86b6e97dc5;

    // represents legally platform operator in case of forks and contracts with legal agreement attached. keccak256("PlatformOperatorRepresentative")
    bytes32 internal constant ROLE_PLATFORM_OPERATOR_REPRESENTATIVE = 0xb2b321377653f655206f71514ff9f150d0822d062a5abcf220d549e1da7999f0;

    // allows to deposit EUR-T and allow addresses to send and receive EUR-T. keccak256("EurtDepositManager")
    bytes32 internal constant ROLE_EURT_DEPOSIT_MANAGER = 0x7c8ecdcba80ce87848d16ad77ef57cc196c208fc95c5638e4a48c681a34d4fe7;

    // allows to register identities and change associated claims keccak256("IdentityManager")
    bytes32 internal constant ROLE_IDENTITY_MANAGER = 0x32964e6bc50f2aaab2094a1d311be8bda920fc4fb32b2fb054917bdb153a9e9e;

    // allows to replace controller on euro token and to destroy tokens without withdraw kecckak256("EurtLegalManager")
    bytes32 internal constant ROLE_EURT_LEGAL_MANAGER = 0x4eb6b5806954a48eb5659c9e3982d5e75bfb2913f55199877d877f157bcc5a9b;

    // allows to change known interfaces in universe kecckak256("UniverseManager")
    bytes32 internal constant ROLE_UNIVERSE_MANAGER = 0xe8d8f8f9ea4b19a5a4368dbdace17ad71a69aadeb6250e54c7b4c7b446301738;

    // allows to exchange gas for EUR-T keccak("GasExchange")
    bytes32 internal constant ROLE_GAS_EXCHANGE = 0x9fe43636e0675246c99e96d7abf9f858f518b9442c35166d87f0934abef8a969;

    // allows to set token exchange rates keccak("TokenRateOracle")
    bytes32 internal constant ROLE_TOKEN_RATE_ORACLE = 0xa80c3a0c8a5324136e4c806a778583a2a980f378bdd382921b8d28dcfe965585;
}

contract IBasicToken {

    ////////////////////////
    // Events
    ////////////////////////

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply()
        public
        constant
        returns (uint256);

    /// @param owner The address that's balance is being requested
    /// @return The balance of `owner` at the current block
    function balanceOf(address owner)
        public
        constant
        returns (uint256 balance);

    /// @notice Send `amount` tokens to `to` from `msg.sender`
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint256 amount)
        public
        returns (bool success);

}

/// @title allows deriving contract to recover any token or ether that it has balance of
/// @notice note that this opens your contracts to claims from various people saying they lost tokens and they want them back
///     be ready to handle such claims
/// @dev use with care!
///     1. ROLE_RECLAIMER is allowed to claim tokens, it's not returning tokens to original owner
///     2. in derived contract that holds any token by design you must override `reclaim` and block such possibility.
///         see ICBMLockedAccount as an example
contract Reclaimable is AccessControlled, AccessRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    IBasicToken constant internal RECLAIM_ETHER = IBasicToken(0x0);

    ////////////////////////
    // Public functions
    ////////////////////////

    function reclaim(IBasicToken token)
        public
        only(ROLE_RECLAIMER)
    {
        address reclaimer = msg.sender;
        if(token == RECLAIM_ETHER) {
            reclaimer.transfer(address(this).balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
    }
}

/// @title uniquely identifies deployable (non-abstract) platform contract
/// @notice cheap way of assigning implementations to knownInterfaces which represent system services
///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces
///         EIP820 still in the making
/// @dev ids are generated as follows keccak256("neufund-platform:<contract name>")
///      ids roughly correspond to ABIs
contract IContractId {
    /// @param id defined as above
    /// @param version implementation version
    function contractId() public pure returns (bytes32 id, uint256 version);
}

contract IERC20Allowance {

    ////////////////////////
    // Events
    ////////////////////////

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param owner The address of the account that owns the token
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of owner that spender is allowed
    ///  to spend
    function allowance(address owner, address spender)
        public
        constant
        returns (uint256 remaining);

    /// @notice `msg.sender` approves `spender` to spend `amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param spender The address of the account able to transfer the tokens
    /// @param amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address spender, uint256 amount)
        public
        returns (bool success);

    /// @notice Send `amount` tokens to `to` from `from` on the condition it
    ///  is approved by `from`
    /// @param from The address holding the tokens being transferred
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool success);

}

contract IERC20Token is IBasicToken, IERC20Allowance {

}

contract ITokenMetadata {

    ////////////////////////
    // Public functions
    ////////////////////////

    function symbol()
        public
        constant
        returns (string);

    function name()
        public
        constant
        returns (string);

    function decimals()
        public
        constant
        returns (uint8);
}

contract IERC223Token is IERC20Token, ITokenMetadata {

    /// @dev Departure: We do not log data, it has no advantage over a standard
    ///     log event. By sticking to the standard log event we
    ///     stay compatible with constracts that expect and ERC20 token.

    // event Transfer(
    //    address indexed from,
    //    address indexed to,
    //    uint256 amount,
    //    bytes data);


    /// @dev Departure: We do not use the callback on regular transfer calls to
    ///     stay compatible with constracts that expect and ERC20 token.

    // function transfer(address to, uint256 amount)
    //     public
    //     returns (bool);

    ////////////////////////
    // Public functions
    ////////////////////////

    function transfer(address to, uint256 amount, bytes data)
        public
        returns (bool);
}

contract IGasExchange {

    ////////////////////////
    // Events
    ////////////////////////

    /// @notice logged on eur-t to gas (ether) exchange
    /// gasRecipient obtained amountWei gas, there is additional fee of exchangeFeeEurUlps
    event LogGasExchange(
        address indexed gasRecipient,
        uint256 amountEurUlps,
        uint256 exchangeFeeFrac,
        uint256 amountWei,
        uint256 rate
    );

    event LogSetExchangeRate(
        address indexed numeratorToken,
        address indexed denominatorToken,
        uint256 rate
    );

    event LogReceivedEther(
        address sender,
        uint256 amount,
        uint256 balance
    );

    ////////////////////////
    // Public methods
    ////////////////////////

    /// @notice will exchange amountEurUlps of gasRecipient balance into ether
    /// @dev EuroTokenController has permanent allowance for gasExchange contract to make such exchange possible when gasRecipient has no Ether
    ///     (chicken and egg problem is solved). The rate from token rate oracle will be used
    ///     exchangeFeeFraction will be deduced before the exchange happens
    /// @dev you should probably apply access modifier in the implementation
    function gasExchange(address gasRecipient, uint256 amountEurUlps, uint256 exchangeFeeFraction)
        public;

    /// @notice see above. allows for batching gas exchanges
    function gasExchangeMultiple(address[] gasRecipients, uint256[] amountsEurUlps, uint256 exchangeFeeFraction)
        public;

    /// sets current euro to ether exchange rate, also sets inverse
    /// ROLE_TOKEN_RATE_ORACLE is allowed to provide rates. we do not implement decentralized oracle here
    /// there is no so actual working decentralized oracle ecosystem
    /// the closes is MakerDao Medianizer at https://etherscan.io/address/0x729D19f657BD0614b4985Cf1D82531c67569197B#code but it's still centralized and only USD/ETH
    /// Oraclize is centralized and you still need to pay fees.
    /// Gnosis does not seem to be working
    /// it seems that for Neufund investor it's best to trust Platform Operator to provide correct information, Platform is aligned via NEU and has no incentive to lie
    /// SimpleExchange is replaceable via Universe. when proper oracle is available we'll move to it
    /// @param numeratorToken token to be converted from
    /// @param denominatorToken token to be converted to
    /// @param rateFraction a decimal fraction (see Math.decimalFraction) of numeratorToken to denominatorToken
    /// example: to set rate of eur to eth you provide (euroToken, etherToken, 0.0016129032258064516129032*10**18)
    /// example: to set rate of eth to eur you provide (etherToken, euroToken, 620*10**18)
    /// @dev you should probably apply access modifier in the implementation
    function setExchangeRate(IERC223Token numeratorToken, IERC223Token denominatorToken, uint256 rateFraction)
        public;

    /// @notice see above. allows for batching gas exchanges
    /// @dev you should probably apply access modifier in the implementation
    function setExchangeRates(IERC223Token[] numeratorTokens, IERC223Token[] denominatorTokens, uint256[] rateFractions)
        public;
}

contract ITokenExchangeRateOracle {
    /// @notice provides actual price of 'numeratorToken' in 'denominatorToken'
    ///     returns timestamp at which price was obtained in oracle
    function getExchangeRate(address numeratorToken, address denominatorToken)
        public
        constant
        returns (uint256 rateFraction, uint256 timestamp);

    /// @notice allows to retreive multiple exchange rates in once call
    function getExchangeRates(address[] numeratorTokens, address[] denominatorTokens)
        public
        constant
        returns (uint256[] rateFractions, uint256[] timestamps);
}

/// @title simple exchange providing EUR to ETH exchange rate and gas exchange
/// see below discussion on oracle type used
contract SimpleExchange is
    ITokenExchangeRateOracle,
    IGasExchange,
    IContractId,
    Reclaimable,
    Math
{
    ////////////////////////
    // Data types
    ////////////////////////

    struct TokenRate {
        // rate of numerator token to denominator token
        uint128 rateFraction;
        // timestamp of where rate was updated
        uint128 timestamp;
    }

    ////////////////////////
    // Immutable state
    ////////////////////////

    // ether token to store and transfer ether
    IERC223Token private ETHER_TOKEN;
    // euro token to store and transfer euro
    IERC223Token private EURO_TOKEN;

    ////////////////////////
    // Mutable state
    ////////////////////////

    // rate from numerator to denominator
    mapping (address => mapping (address => TokenRate)) private _rates;

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(
        IAccessPolicy accessPolicy,
        IERC223Token euroToken,
        IERC223Token etherToken
    )
        AccessControlled(accessPolicy)
        Reclaimable()
        public
    {
        EURO_TOKEN = euroToken;
        ETHER_TOKEN = etherToken;
    }

    ////////////////////////
    // Public methods
    ////////////////////////

    //
    // Implements IGasExchange
    //

    function gasExchange(address gasRecipient, uint256 amountEurUlps, uint256 exchangeFeeFraction)
        public
        only(ROLE_GAS_EXCHANGE)
    {
        // fee must be less than 100%
        assert(exchangeFeeFraction < 10**18);
        (uint256 rate, uint256 rateTimestamp) = getExchangeRatePrivate(EURO_TOKEN, ETHER_TOKEN);
        // require if rate older than 1 hours
        require(block.timestamp - rateTimestamp < 1 hours, "NF_SEX_OLD_RATE");
        gasExchangePrivate(gasRecipient, amountEurUlps, exchangeFeeFraction, rate);
    }

    function gasExchangeMultiple(
        address[] gasRecipients,
        uint256[] amountsEurUlps,
        uint256 exchangeFeeFraction
    )
        public
        only(ROLE_GAS_EXCHANGE)
    {
        // fee must be less than 100%
        assert(exchangeFeeFraction < 10**18);
        require(gasRecipients.length == amountsEurUlps.length);
        (uint256 rate, uint256 rateTimestamp) = getExchangeRatePrivate(EURO_TOKEN, ETHER_TOKEN);
        // require if rate older than 1 hours
        require(block.timestamp - rateTimestamp < 1 hours, "NF_SEX_OLD_RATE");
        uint256 idx;
        while(idx < gasRecipients.length) {
            gasExchangePrivate(gasRecipients[idx], amountsEurUlps[idx], exchangeFeeFraction, rate);
            idx += 1;
        }
    }

    /// @notice please read method description in the interface
    /// @dev we always set a rate and an inverse rate! so you call once with eur/eth and you also get eth/eur
    function setExchangeRate(IERC223Token numeratorToken, IERC223Token denominatorToken, uint256 rateFraction)
        public
        only(ROLE_TOKEN_RATE_ORACLE)
    {
        setExchangeRatePrivate(numeratorToken, denominatorToken, rateFraction);
    }

    function setExchangeRates(IERC223Token[] numeratorTokens, IERC223Token[] denominatorTokens, uint256[] rateFractions)
        public
        only(ROLE_TOKEN_RATE_ORACLE)
    {
        require(numeratorTokens.length == denominatorTokens.length);
        require(numeratorTokens.length == rateFractions.length);
        for(uint256 idx = 0; idx < numeratorTokens.length; idx++) {
            setExchangeRatePrivate(numeratorTokens[idx], denominatorTokens[idx], rateFractions[idx]);
        }
    }

    //
    // Implements ITokenExchangeRateOracle
    //

    function getExchangeRate(address numeratorToken, address denominatorToken)
        public
        constant
        returns (uint256 rateFraction, uint256 timestamp)
    {
        return getExchangeRatePrivate(numeratorToken, denominatorToken);
    }

    function getExchangeRates(address[] numeratorTokens, address[] denominatorTokens)
        public
        constant
        returns (uint256[] rateFractions, uint256[] timestamps)
    {
        require(numeratorTokens.length == denominatorTokens.length);
        uint256 idx;
        rateFractions = new uint256[](numeratorTokens.length);
        timestamps = new uint256[](denominatorTokens.length);
        while(idx < numeratorTokens.length) {
            (uint256 rate, uint256 timestamp) = getExchangeRatePrivate(numeratorTokens[idx], denominatorTokens[idx]);
            rateFractions[idx] = rate;
            timestamps[idx] = timestamp;
            idx += 1;
        }
    }

    //
    // Implements IContractId
    //

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x434a1a753d1d39381c462f37c155e520ae6f86ad79289abca9cde354a0cebd68, 0);
    }

    //
    // Override default function
    //

    function () external payable {
        emit LogReceivedEther(msg.sender, msg.value, address(this).balance);
    }

    ////////////////////////
    // Private methods
    ////////////////////////

    function gasExchangePrivate(
        address gasRecipient,
        uint256 amountEurUlps,
        uint256 exchangeFeeFraction,
        uint256 rate
    )
        private
    {
        // exchange declared amount - the exchange fee, no overflow, fee < 0
        uint256 amountEthWei = decimalFraction(amountEurUlps - decimalFraction(amountEurUlps, exchangeFeeFraction), rate);
        // take all euro tokens
        assert(EURO_TOKEN.transferFrom(gasRecipient, this, amountEurUlps));
        // transfer ether to gasRecipient
        gasRecipient.transfer(amountEthWei);

        emit LogGasExchange(gasRecipient, amountEurUlps, exchangeFeeFraction, amountEthWei, rate);
    }

    function getExchangeRatePrivate(address numeratorToken, address denominatorToken)
        private
        constant
        returns (uint256 rateFraction, uint256 timestamp)
    {
        TokenRate storage requested_rate = _rates[numeratorToken][denominatorToken];
        TokenRate storage inversed_requested_rate = _rates[denominatorToken][numeratorToken];
        if (requested_rate.timestamp > 0) {
            return (requested_rate.rateFraction, requested_rate.timestamp);
        }
        else if (inversed_requested_rate.timestamp > 0) {
            uint256 invRateFraction = proportion(10**18, 10**18, inversed_requested_rate.rateFraction);
            return (invRateFraction, inversed_requested_rate.timestamp);
        }
        // will return (0, 0) == (rateFraction, timestamp)
    }

    function setExchangeRatePrivate(
        IERC223Token numeratorToken,
        IERC223Token denominatorToken,
        uint256 rateFraction
    )
        private
    {
        require(numeratorToken != denominatorToken, "NF_SEX_SAME_N_D");
        assert(rateFraction > 0);
        assert(rateFraction < 2**128);
        uint256 invRateFraction = proportion(10**18, 10**18, rateFraction);

        // Inversion of rate biger than 10**36 is not possible and it will always be 0.
        // require(invRateFraction < 2**128, "NF_SEX_OVR_INV");
        require(denominatorToken.decimals() == numeratorToken.decimals(), "NF_SEX_DECIMALS");
        // TODO: protect against outliers

        if (_rates[denominatorToken][numeratorToken].timestamp > 0) {
            _rates[denominatorToken][numeratorToken] = TokenRate({
                rateFraction: uint128(invRateFraction),
                timestamp: uint128(block.timestamp)
            });
        }
        else {
            _rates[numeratorToken][denominatorToken] = TokenRate({
                rateFraction: uint128(rateFraction),
                timestamp: uint128(block.timestamp)
            });
        }

        emit LogSetExchangeRate(numeratorToken, denominatorToken, rateFraction);
        emit LogSetExchangeRate(denominatorToken, numeratorToken, invRateFraction);
    }
}