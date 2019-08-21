// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: @gnosis.pm/util-contracts/contracts/Fixed192x64Math.sol

pragma solidity >=0.4.24 ^0.5.1;


/// @title Fixed192x64Math library - Allows calculation of logarithmic and exponential functions
/// @author Alan Lu - <alan.lu@gnosis.pm>
/// @author Stefan George - <stefan@gnosis.pm>
library Fixed192x64Math {

    enum EstimationMode { LowerBound, UpperBound, Midpoint }

    /*
     *  Constants
     */
    // This is equal to 1 in our calculations
    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    /*
     *  Public functions
     */
    /// @dev Returns natural exponential function value of given x
    /// @param x x
    /// @return e**x
    function exp(int x)
        public
        pure
        returns (uint)
    {
        // revert if x is > MAX_POWER, where
        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE) * ONE))
        require(x <= 2454971259878909886679);
        // return 0 if exp(x) is tiny, using
        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE) * ONE))
        if (x <= -818323753292969962227)
            return 0;

        // Transform so that e^x -> 2^x
        (uint lower, uint upper) = pow2Bounds(x * int(ONE) / int(LN2));
        return (upper - lower) / 2 + lower;
    }

    /// @dev Returns estimate of 2**x given x
    /// @param x exponent in fixed point
    /// @param estimationMode whether to return a lower bound, upper bound, or a midpoint
    /// @return estimate of 2**x in fixed point
    function pow2(int x, EstimationMode estimationMode)
        public
        pure
        returns (uint)
    {
        (uint lower, uint upper) = pow2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

    /// @dev Returns bounds for value of 2**x given x
    /// @param x exponent in fixed point
    /// @return {
    ///   "lower": "lower bound of 2**x in fixed point",
    ///   "upper": "upper bound of 2**x in fixed point"
    /// }
    function pow2Bounds(int x)
        public
        pure
        returns (uint lower, uint upper)
    {
        // revert if x is > MAX_POWER, where
        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE, 2) * ONE))
        require(x <= 3541774862152233910271);
        // return 0 if exp(x) is tiny, using
        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE, 2) * ONE))
        if (x < -1180591620717411303424)
            return (0, 1);

        // 2^x = 2^(floor(x)) * 2^(x-floor(x))
        //       ^^^^^^^^^^^^^^ is a bit shift of ceil(x)
        // so Taylor expand on z = x-floor(x), z in [0, 1)
        int shift;
        int z;
        if (x >= 0) {
            shift = x / int(ONE);
            z = x % int(ONE);
        }
        else {
            shift = (x+1) / int(ONE) - 1;
            z = x - (int(ONE) * shift);
        }
        assert(z >= 0);
        // 2^x = 1 + (ln 2) x + (ln 2)^2/2! x^2 + ...
        //
        // Can generate the z coefficients using mpmath and the following lines
        // >>> from mpmath import mp
        // >>> mp.dps = 100
        // >>> coeffs = [mp.log(2)**i / mp.factorial(i) for i in range(1, 21)]
        // >>> shifts = [64 - int(mp.log(c, 2)) for c in coeffs]
        // >>> print('\n'.join(hex(int(c * (1 << s))) + ', ' + str(s) for c, s in zip(coeffs, shifts)))
        int result = int(ONE) << 64;
        int zpow = z;
        result += 0xb17217f7d1cf79ab * zpow;
        zpow = zpow * z / int(ONE);
        result += 0xf5fdeffc162c7543 * zpow >> (66 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe35846b82505fc59 * zpow >> (68 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9d955b7dd273b94e * zpow >> (70 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xaec3ff3c53398883 * zpow >> (73 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xa184897c363c3b7a * zpow >> (76 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xffe5fe2c45863435 * zpow >> (80 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xb160111d2e411fec * zpow >> (83 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xda929e9caf3e1ed2 * zpow >> (87 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf267a8ac5c764fb7 * zpow >> (91 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf465639a8dd92607 * zpow >> (95 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1deb287e14c2f15 * zpow >> (99 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xc0b0c98b3687cb14 * zpow >> (103 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x98a4b26ac3c54b9f * zpow >> (107 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1b7421d82010f33 * zpow >> (112 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9c744d73cfc59c91 * zpow >> (116 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xcc2225a0e12d3eab * zpow >> (121 - 64);
        zpow = zpow * z / int(ONE);
        zpow = 0xfb8bb5eda1b4aeb9 * zpow >> (126 - 64);
        result += zpow;
        zpow = int(8 * ONE);

        shift -= 64;
        if (shift >= 0) {
            if (result >> (256-shift) == 0) {
                lower = uint(result) << shift;
                zpow <<= shift; // todo: is this safe?
                if (lower + uint(zpow) >= lower)
                    upper = lower + uint(zpow);
                else
                    upper = 2**256-1;
                return (lower, upper);
            }
            else
                return (2**256-1, 2**256-1);
        }
        zpow = (zpow >> (-shift)) + 1;
        lower = uint(result) >> (-shift);
        upper = lower + uint(zpow);
        return (lower, upper);
    }

    /// @dev Returns natural logarithm value of given x
    /// @param x x
    /// @return ln(x)
    function ln(uint x)
        public
        pure
        returns (int)
    {
        (int lower, int upper) = log2Bounds(x);
        return ((upper - lower) / 2 + lower) * int(ONE) / int(LOG2_E);
    }

    /// @dev Returns estimate of binaryLog(x) given x
    /// @param x logarithm argument in fixed point
    /// @param estimationMode whether to return a lower bound, upper bound, or a midpoint
    /// @return estimate of binaryLog(x) in fixed point
    function binaryLog(uint x, EstimationMode estimationMode)
        public
        pure
        returns (int)
    {
        (int lower, int upper) = log2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

    /// @dev Returns bounds for value of binaryLog(x) given x
    /// @param x logarithm argument in fixed point
    /// @return {
    ///   "lower": "lower bound of binaryLog(x) in fixed point",
    ///   "upper": "upper bound of binaryLog(x) in fixed point"
    /// }
    function log2Bounds(uint x)
        public
        pure
        returns (int lower, int upper)
    {
        require(x > 0);
        // compute ⌊log₂x⌋
        lower = floorLog2(x);

        uint y;
        if (lower < 0)
            y = x << uint(-lower);
        else
            y = x >> uint(lower);

        lower *= int(ONE);

        // y = x * 2^(-⌊log₂x⌋)
        // so 1 <= y < 2
        // and log₂x = ⌊log₂x⌋ + log₂y
        for (int m = 1; m <= 64; m++) {
            if(y == ONE) {
                break;
            }
            y = y * y / ONE;
            if(y >= 2 * ONE) {
                lower += int(ONE >> m);
                y /= 2;
            }
        }

        return (lower, lower + 4);
    }

    /// @dev Returns base 2 logarithm value of given x
    /// @param x x
    /// @return logarithmic value
    function floorLog2(uint x)
        public
        pure
        returns (int lo)
    {
        lo = -64;
        int hi = 193;
        // I use a shift here instead of / 2 because it floors instead of rounding towards 0
        int mid = (hi + lo) >> 1;
        while((lo + 1) < hi) {
            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)
                hi = mid;
            else
                lo = mid;
            mid = (hi + lo) >> 1;
        }
    }

    /// @dev Returns maximum of an array
    /// @param nums Numbers to look through
    /// @return Maximum number
    function max(int[] memory nums)
        public
        pure
        returns (int maxNum)
    {
        require(nums.length > 0);
        maxNum = -2**255;
        for (uint i = 0; i < nums.length; i++)
            if (nums[i] > maxNum)
                maxNum = nums[i];
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: erc-1155/contracts/IERC1155TokenReceiver.sol

pragma solidity ^0.5.0;

interface IERC1155TokenReceiver {
    /**
        @notice Handle the receipt of a single ERC1155 token type
        @dev The smart contract calls this function on the recipient
        after a `safeTransferFrom`. This function MAY throw to revert and reject the
        transfer. Return of other than the magic value MUST result in the
        transaction being reverted
        Note: the contract address is always the message sender
        @param _operator  The address which called `safeTransferFrom` function
        @param _from      The address which previously owned the token
        @param _id        An array containing the ids of the token being transferred
        @param _value     An array containing the amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types
        @dev The smart contract calls this function on the recipient
        after a `safeTransferFrom`. This function MAY throw to revert and reject the
        transfer. Return of other than the magic value MUST result in the
        transaction being reverted
        Note: the contract address is always the message sender
        @param _operator  The address which called `safeTransferFrom` function
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred
        @param _values    An array containing amounts of each token being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: erc-1155/contracts/IERC1155.sol

pragma solidity ^0.5.0;


/**
    @title ERC-1155 Multi Token Standard
    @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
/*interface*/ contract IERC1155 is IERC165 {
    /**
        @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero value transfers as well as minting or burning.
        Either event from address `0x0` signifies a minting operation.
        An event to address `0x0` signifies a burning or melting operation.
        The total value transferred from address 0x0 minus the total value transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
        This MAY emit a 0 value, from `0x0` to `0x0` with `_operator` assuming the role of the token creator to define a token ID with no initial balance at the time of creation.
    */
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    /**
        @dev MUST emit when an approval is updated.
    */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
        @dev MUST emit when the URI is updated for a token ID.
        The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @dev MUST emit when the Name is updated for a token ID.
    */
    event Name(string _value, uint256 indexed _id);

    /**
        @notice Transfers value amount of an _id from the _from address to the _to addresses specified. Each parameter array should be the same length, with each index correlating.
        @dev MUST emit TransferSingle event on success.
        Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
        MUST Throw if `_to` is the zero address.
        MUST Throw if `_id` is not a valid token ID.
        MUST Throw on any other error.
        When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return value is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`.
        @param _from    Source addresses
        @param _to      Target addresses
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, sent in call to `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    /**
        @notice Send multiple types of Tokens from a 3rd party in one transfer (with safety call).
        @dev MUST emit TransferBatch event on success.
        Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
        MUST Throw if `_to` is the zero address.
        MUST Throw if any of the `_ids` is not a valid token ID.
        MUST Throw on any other error.
        When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return value is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`.
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type
        @param _values  Transfer amounts per token type
        @param _data    Additional data with no specified format, sent in call to `_to`
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;

    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the Tokens
        @return        The _owner's balance of the Token types requested
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the Tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// File: erc-1155/contracts/ERC1155.sol

pragma solidity ^0.5.0;





// A sample implementation of core ERC1155 function.
contract ERC1155 is IERC1155
{
    using SafeMath for uint256;
    using Address for address;

    bytes4 constant public ERC1155_RECEIVED       = 0xf23a6e61;
    bytes4 constant public ERC1155_BATCH_RECEIVED = 0xbc197c81;

    // id => (owner => balance)
    mapping (uint256 => mapping(address => uint256)) internal balances;

    // owner => (operator => approved)
    mapping (address => mapping(address => bool)) internal operatorApproval;

/////////////////////////////////////////// ERC165 //////////////////////////////////////////////

    /*
        bytes4(keccak256('supportsInterface(bytes4)'));
    */
    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

    /*
        bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)")) ^
        bytes4(keccak256("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)")) ^
        bytes4(keccak256("balanceOf(address,uint256)")) ^
        bytes4(keccak256("balanceOfBatch(address[],uint256[])")) ^
        bytes4(keccak256("setApprovalForAll(address,bool)")) ^
        bytes4(keccak256("isApprovedForAll(address,address)"));
    */
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool) {
         if (_interfaceId == INTERFACE_SIGNATURE_ERC165 ||
             _interfaceId == INTERFACE_SIGNATURE_ERC1155) {
            return true;
         }

         return false;
    }

/////////////////////////////////////////// ERC1155 //////////////////////////////////////////////

    /**
        @notice Transfers value amount of an _id from the _from address to the _to addresses specified. Each parameter array should be the same length, with each index correlating.
        @dev MUST emit TransferSingle event on success.
        Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
        MUST Throw if `_to` is the zero address.
        MUST Throw if `_id` is not a valid token ID.
        MUST Throw on any other error.
        When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return value is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`.
        @param _from    Source addresses
        @param _to      Target addresses
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, sent in call to `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {

        require(_to != address(0), "_to must be non-zero.");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        // SafeMath will throw with insuficient funds _from
        // or if _id is not valid (balance will be 0)
        balances[_id][_from] = balances[_id][_from].sub(_value);
        balances[_id][_to]   = _value.add(balances[_id][_to]);

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        if (_to.isContract()) {
            require(IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _value, _data) == ERC1155_RECEIVED);
        }
    }

    /**
        @notice Send multiple types of Tokens from a 3rd party in one transfer (with safety call).
        @dev MUST emit TransferBatch event on success.
        Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
        MUST Throw if `_to` is the zero address.
        MUST Throw if any of the `_ids` is not a valid token ID.
        MUST Throw on any other error.
        When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return value is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`.
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type
        @param _values  Transfer amounts per token type
        @param _data    Additional data with no specified format, sent in call to `_to`
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {

        // MUST Throw on errors
        require(_to != address(0), "_to must be non-zero.");
        require(_ids.length == _values.length, "_ids and _values array lenght must match.");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 value = _values[i];

            // SafeMath will throw with insuficient funds _from
            // or if _id is not valid (balance will be 0)
            balances[id][_from] = balances[id][_from].sub(value);
            balances[id][_to]   = value.add(balances[id][_to]);
        }

        // MUST emit event
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        // Now that the balances are updated,
        // call onERC1155BatchReceived if the destination is a contract
        if (_to.isContract()) {
            require(IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _values, _data) == ERC1155_BATCH_RECEIVED);
        }
    }

    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        // The balance of any account can be calculated from the Transfer events history.
        // However, since we need to keep the balances to validate transfer request,
        // there is no extra cost to also privide a querry function.
        return balances[_id][_owner];
    }


    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the Tokens
        @return        The _owner's balance of the Token types requested
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {

        require(_owners.length == _ids.length);

        uint256[] memory balances_ = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            balances_[i] = balances[_ids[i]][_owners[i]];
        }

        return balances_;
    }

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApproval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the Tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApproval[_owner][_operator];
    }
}

// File: @gnosis.pm/hg-contracts/contracts/OracleConsumer.sol

pragma solidity ^0.5.1;


interface OracleConsumer {
    function receiveResult(bytes32 id, bytes calldata result) external;
}

// File: @gnosis.pm/hg-contracts/contracts/PredictionMarketSystem.sol

pragma solidity ^0.5.1;





contract PredictionMarketSystem is OracleConsumer, ERC1155 {

    /// @dev Emitted upon the successful preparation of a condition.
    /// @param conditionId The condition's ID. This ID may be derived from the other three parameters via ``keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))``.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    event ConditionPreparation(bytes32 indexed conditionId, address indexed oracle, bytes32 indexed questionId, uint outcomeSlotCount);

    event ConditionResolution(bytes32 indexed conditionId, address indexed oracle, bytes32 indexed questionId, uint outcomeSlotCount, uint[] payoutNumerators);

    /// @dev Emitted when a position is successfully split.
    event PositionSplit(address indexed stakeholder, IERC20 collateralToken, bytes32 indexed parentCollectionId, bytes32 indexed conditionId, uint[] partition, uint amount);
    /// @dev Emitted when positions are successfully merged.
    event PositionsMerge(address indexed stakeholder, IERC20 collateralToken, bytes32 indexed parentCollectionId, bytes32 indexed conditionId, uint[] partition, uint amount);
    event PayoutRedemption(address indexed redeemer, IERC20 indexed collateralToken, bytes32 indexed parentCollectionId, uint payout);

    /// Mapping key is an condition ID. Value represents numerators of the payout vector associated with the condition. This array is initialized with a length equal to the outcome slot count.
    mapping(bytes32 => uint[]) public payoutNumerators;
    mapping(bytes32 => uint) public payoutDenominator;

    /// @dev This function prepares a condition by initializing a payout vector associated with the condition.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    function prepareCondition(address oracle, bytes32 questionId, uint outcomeSlotCount) external {
        require(outcomeSlotCount <= 256, "too many outcome slots");
        bytes32 conditionId = keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount));
        require(payoutNumerators[conditionId].length == 0, "condition already prepared");
        payoutNumerators[conditionId] = new uint[](outcomeSlotCount);
        emit ConditionPreparation(conditionId, oracle, questionId, outcomeSlotCount);
    }

    /// @dev Called by the oracle for reporting results of conditions. Will set the payout vector for the condition with the ID ``keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))``, where oracle is the message sender, questionId is one of the parameters of this function, and outcomeSlotCount is derived from result, which is the result of serializing 32-byte EVM words representing payoutNumerators for each outcome slot of the condition.
    /// @param questionId The question ID the oracle is answering for
    /// @param result The oracle's answer
    function receiveResult(bytes32 questionId, bytes calldata result) external {
        require(result.length > 0, "results empty");
        require(result.length % 32 == 0, "results not 32-byte aligned");
        uint outcomeSlotCount = result.length / 32;
        require(outcomeSlotCount <= 256, "too many outcome slots");
        bytes32 conditionId = keccak256(abi.encodePacked(msg.sender, questionId, outcomeSlotCount));
        require(payoutNumerators[conditionId].length == outcomeSlotCount, "number of outcomes mismatch");
        require(payoutDenominator[conditionId] == 0, "payout denominator already set");
        for (uint i = 0; i < outcomeSlotCount; i++) {
            uint payoutNum;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                payoutNum := calldataload(add(0x64, mul(0x20, i)))
            }
            payoutDenominator[conditionId] = payoutDenominator[conditionId].add(payoutNum);

            require(payoutNumerators[conditionId][i] == 0, "payout numerator already set");
            payoutNumerators[conditionId][i] = payoutNum;
        }
        require(payoutDenominator[conditionId] > 0, "payout is all zeroes");
        emit ConditionResolution(conditionId, msg.sender, questionId, outcomeSlotCount, payoutNumerators[conditionId]);
    }

    /// @dev This function splits a position. If splitting from the collateral, this contract will attempt to transfer `amount` collateral from the message sender to itself. Otherwise, this contract will burn `amount` stake held by the message sender in the position being split. Regardless, if successful, `amount` stake will be minted in the split target positions. If any of the transfers, mints, or burns fail, the transaction will revert. The transaction will also revert if the given partition is trivial, invalid, or refers to more slots than the condition is prepared with.
    /// @param collateralToken The address of the positions' backing collateral token.
    /// @param parentCollectionId The ID of the outcome collections common to the position being split and the split target positions. May be null, in which only the collateral is shared.
    /// @param conditionId The ID of the condition to split on.
    /// @param partition An array of disjoint index sets representing a nontrivial partition of the outcome slots of the given condition.
    /// @param amount The amount of collateral or stake to split.
    function splitPosition(IERC20 collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[] calldata partition, uint amount) external {
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        bytes32 key;

        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        uint freeIndexSet = fullIndexSet;
        for (uint i = 0; i < partition.length; i++) {
            uint indexSet = partition[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            require((indexSet & freeIndexSet) == indexSet, "partition not disjoint");
            freeIndexSet ^= indexSet;
            key = keccak256(abi.encodePacked(collateralToken, getCollectionId(parentCollectionId, conditionId, indexSet)));
            balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].add(amount);
        }

        if (freeIndexSet == 0) {
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transferFrom(msg.sender, address(this), amount), "could not receive collateral tokens");
            } else {
                key = keccak256(abi.encodePacked(collateralToken, parentCollectionId));
                balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].sub(amount);
            }
        } else {
            key = keccak256(abi.encodePacked(collateralToken, getCollectionId(parentCollectionId, conditionId, fullIndexSet ^ freeIndexSet)));
            balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].sub(amount);
        }

        emit PositionSplit(msg.sender, collateralToken, parentCollectionId, conditionId, partition, amount);
    }

    function mergePositions(IERC20 collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[] calldata partition, uint amount) external {
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        bytes32 key;

        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        uint freeIndexSet = fullIndexSet;
        for (uint i = 0; i < partition.length; i++) {
            uint indexSet = partition[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            require((indexSet & freeIndexSet) == indexSet, "partition not disjoint");
            freeIndexSet ^= indexSet;
            key = keccak256(abi.encodePacked(collateralToken, getCollectionId(parentCollectionId, conditionId, indexSet)));
            balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].sub(amount);
        }

        if (freeIndexSet == 0) {
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transfer(msg.sender, amount), "could not send collateral tokens");
            } else {
                key = keccak256(abi.encodePacked(collateralToken, parentCollectionId));
                balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].add(amount);
            }
        } else {
            key = keccak256(abi.encodePacked(collateralToken, getCollectionId(parentCollectionId, conditionId, fullIndexSet ^ freeIndexSet)));
            balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].add(amount);
        }

        emit PositionsMerge(msg.sender, collateralToken, parentCollectionId, conditionId, partition, amount);
    }

    function redeemPositions(IERC20 collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[] calldata indexSets) external {
        require(payoutDenominator[conditionId] > 0, "result for condition not received yet");
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        uint totalPayout = 0;
        bytes32 key;

        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        for (uint i = 0; i < indexSets.length; i++) {
            uint indexSet = indexSets[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            key = keccak256(abi.encodePacked(collateralToken, getCollectionId(parentCollectionId, conditionId, indexSet)));

            uint payoutNumerator = 0;
            for (uint j = 0; j < outcomeSlotCount; j++) {
                if (indexSet & (1 << j) != 0) {
                    payoutNumerator = payoutNumerator.add(payoutNumerators[conditionId][j]);
                }
            }

            uint payoutStake = balances[uint(key)][msg.sender];
            if (payoutStake > 0) {
                totalPayout = totalPayout.add(payoutStake.mul(payoutNumerator).div(payoutDenominator[conditionId]));
                balances[uint(key)][msg.sender] = 0;
            }
        }

        if (totalPayout > 0) {
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transfer(msg.sender, totalPayout), "could not transfer payout to message sender");
            } else {
                key = keccak256(abi.encodePacked(collateralToken, parentCollectionId));
                balances[uint(key)][msg.sender] = balances[uint(key)][msg.sender].add(totalPayout);
            }
        }
        emit PayoutRedemption(msg.sender, collateralToken, parentCollectionId, totalPayout);
    }

    /// @dev Gets the outcome slot count of a condition.
    /// @param conditionId ID of the condition.
    /// @return Number of outcome slots associated with a condition, or zero if condition has not been prepared yet.
    function getOutcomeSlotCount(bytes32 conditionId) external view returns (uint) {
        return payoutNumerators[conditionId].length;
    }

    function getCollectionId(bytes32 parentCollectionId, bytes32 conditionId, uint indexSet) private pure returns (bytes32) {
        return bytes32(
            uint(parentCollectionId) +
            uint(keccak256(abi.encodePacked(conditionId, indexSet)))
        );
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @gnosis.pm/util-contracts/contracts/SignedSafeMath.sol

pragma solidity >=0.4.24 ^0.5.1;


/**
 * @title SignedSafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SignedSafeMath {
  int256 constant INT256_MIN = int256((uint256(1) << 255));

  /**
  * @dev Multiplies two signed integers, throws on overflow.
  */
  function mul(int256 a, int256 b) internal pure returns (int256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert((a != -1 || b != INT256_MIN) && c / a == b);
  }

  /**
  * @dev Integer division of two signed integers, truncating the quotient.
  */
  function div(int256 a, int256 b) internal pure returns (int256) {
    // assert(b != 0); // Solidity automatically throws when dividing by 0
    // Overflow only happens when the smallest negative int is multiplied by -1.
    assert(a != INT256_MIN || b != -1);
    return a / b;
  }

  /**
  * @dev Subtracts two signed integers, throws on overflow.
  */
  function sub(int256 a, int256 b) internal pure returns (int256 c) {
    c = a - b;
    assert((b >= 0 && c <= a) || (b < 0 && c > a));
  }

  /**
  * @dev Adds two signed integers, throws on overflow.
  */
  function add(int256 a, int256 b) internal pure returns (int256 c) {
    c = a + b;
    assert((b >= 0 && c >= a) || (b < 0 && c < a));
  }
}

// File: @gnosis.pm/hg-market-makers/contracts/MarketMaker.sol

pragma solidity ^0.5.1;






contract MarketMaker is Ownable, IERC1155TokenReceiver {
    using SignedSafeMath for int;
    using SafeMath for uint;
    /*
     *  Constants
     */    
    uint64 public constant FEE_RANGE = 10**18;

    /*
     *  Events
     */
    event AMMCreated(uint initialFunding);
    event AMMPaused();
    event AMMResumed();
    event AMMClosed();
    event AMMFundingChanged(int fundingChange);
    event AMMFeeChanged(uint64 newFee);
    event AMMFeeWithdrawal(uint fees);
    event AMMOutcomeTokenTrade(address indexed transactor, int[] outcomeTokenAmounts, int outcomeTokenNetCost, uint marketFees);
    
    /*
     *  Storage
     */
    PredictionMarketSystem public pmSystem;
    IERC20 public collateralToken;
    bytes32[] public conditionIds;
    uint public atomicOutcomeSlotCount;
    uint64 public fee;
    uint public funding;
    Stage public stage;
    enum Stage {
        Running,
        Paused,
        Closed
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stage _stage) {
        // Contract has to be in given stage
        require(stage == _stage);
        _;
    }

    constructor(PredictionMarketSystem _pmSystem, IERC20 _collateralToken, bytes32[] memory _conditionIds, uint64 _fee, uint initialFunding, address marketOwner)
        public
    {
        // Validate inputs
        require(address(_pmSystem) != address(0) && _fee < FEE_RANGE);
        pmSystem = _pmSystem;
        collateralToken = _collateralToken;
        conditionIds = _conditionIds;
        fee = _fee;

        atomicOutcomeSlotCount = 1;
        for (uint i = 0; i < conditionIds.length; i++) {
            atomicOutcomeSlotCount *= pmSystem.getOutcomeSlotCount(conditionIds[i]);
        }
        require(atomicOutcomeSlotCount > 1, "conditions must be valid");

        require(collateralToken.transferFrom(marketOwner, address(this), initialFunding) && collateralToken.approve(address(pmSystem), initialFunding));

        splitPositionThroughAllConditions(initialFunding, conditionIds.length, 0);

        funding = initialFunding;

        stage = Stage.Running;
        emit AMMCreated(funding);
    }

    function calcNetCost(int[] memory outcomeTokenAmounts) public view returns (int netCost);

    /// @dev Allows to fund the market with collateral tokens converting them into outcome tokens
    /// Note for the future: should combine splitPosition and mergePositions into one function, as code duplication causes things like this to happen.
    function changeFunding(int fundingChange)
        public
        onlyOwner
        atStage(Stage.Paused)
    {
        require(fundingChange != 0, "A fundingChange of zero is not a fundingChange at all. It is unacceptable.");
        // Either add or subtract funding based off whether the fundingChange parameter is negative or positive
        if (fundingChange > 0) {
            require(collateralToken.transferFrom(msg.sender, address(this), uint(fundingChange)) && collateralToken.approve(address(pmSystem), uint(fundingChange)));
            splitPositionThroughAllConditions(uint(fundingChange), conditionIds.length, 0);
            funding = funding.add(uint(fundingChange));
            emit AMMFundingChanged(fundingChange);
        }
        if (fundingChange < 0) {
            mergePositionsThroughAllConditions(uint(-fundingChange), conditionIds.length, 0);
            funding = funding.sub(uint(-fundingChange));
            require(collateralToken.transfer(owner(), uint(-fundingChange)));
            emit AMMFundingChanged(fundingChange);
        }
    }

    function pause() public onlyOwner atStage(Stage.Running) {
        stage = Stage.Paused;
        emit AMMPaused();
    }
    
    function resume() public onlyOwner atStage(Stage.Paused) {
        stage = Stage.Running;
        emit AMMResumed();
    }

    function changeFee(uint64 _fee) public onlyOwner atStage(Stage.Paused) {
        fee = _fee;
        emit AMMFeeChanged(fee);
    }

    /// @dev Allows market owner to close the markets by transferring all remaining outcome tokens to the owner
    function close()
        public
        onlyOwner
    {
        require(stage == Stage.Running || stage == Stage.Paused, "This Market has already been closed");
        for (uint i = 0; i < atomicOutcomeSlotCount; i++) {
            uint positionId = generateAtomicPositionId(i);
            pmSystem.safeTransferFrom(address(this), owner(), positionId, pmSystem.balanceOf(address(this), positionId), "");
        }
        stage = Stage.Closed;
        emit AMMClosed();
    }

    /// @dev Allows market owner to withdraw fees generated by trades
    /// @return Fee amount
    function withdrawFees()
        public
        onlyOwner
        returns (uint fees)
    {
        fees = collateralToken.balanceOf(address(this));
        // Transfer fees
        require(collateralToken.transfer(owner(), fees));
        emit AMMFeeWithdrawal(fees);
    }

    /// @dev Allows to trade outcome tokens and collateral with the market maker
    /// @param outcomeTokenAmounts Amounts of each atomic outcome token to buy or sell. If positive, will buy this amount of outcome token from the market. If negative, will sell this amount back to the market instead. The indices of this array range from 0 to product(all conditions' outcomeSlotCounts)-1. For example, with two conditions with three outcome slots each and one condition with two outcome slots, you will have 3*3*2=18 total atomic outcome tokens, and the indices will range from 0 to 17. The indices map to atomic outcome slots depending on the order of the conditionIds. Let's say the first condition has slots A, B, C the second has slots X, Y, and the third has slots I, J, K. We can associate each atomic outcome token with indices by this map:
    /// A&X&I == 0
    /// B&X&I == 1
    /// C&X&I == 2
    /// A&Y&I == 3
    /// B&Y&I == 4
    /// C&Y&I == 5
    /// A&X&J == 6
    /// B&X&J == 7
    /// C&X&J == 8
    /// A&Y&J == 9
    /// B&Y&J == 10
    /// C&Y&J == 11
    /// A&X&K == 12
    /// B&X&K == 13
    /// C&X&K == 14
    /// A&Y&K == 15
    /// B&Y&K == 16
    /// C&Y&K == 17
    /// This order is calculated via the generateAtomicPositionId function below: C&Y&I -> (2, 1, 0) -> 2 + 3 * (1 + 2 * (0 + 3 * (0 + 0)))
    /// @param collateralLimit If positive, this is the limit for the amount of collateral tokens which will be sent to the market to conduct the trade. If negative, this is the minimum amount of collateral tokens which will be received from the market for the trade. If zero, there is no limit.
    /// @return If positive, the amount of collateral sent to the market. If negative, the amount of collateral received from the market. If zero, no collateral was sent or received.
    function trade(int[] memory outcomeTokenAmounts, int collateralLimit)
        public
        atStage(Stage.Running)
        returns (int netCost)
    {
        require(outcomeTokenAmounts.length == atomicOutcomeSlotCount);

        // Calculate net cost for executing trade
        int outcomeTokenNetCost = calcNetCost(outcomeTokenAmounts);
        int fees;
        if(outcomeTokenNetCost < 0)
            fees = int(calcMarketFee(uint(-outcomeTokenNetCost)));
        else
            fees = int(calcMarketFee(uint(outcomeTokenNetCost)));

        require(fees >= 0);
        netCost = outcomeTokenNetCost.add(fees);

        require(
            (collateralLimit != 0 && netCost <= collateralLimit) ||
            collateralLimit == 0
        );

        if(outcomeTokenNetCost > 0) {
            require(
                collateralToken.transferFrom(msg.sender, address(this), uint(netCost)) &&
                collateralToken.approve(address(pmSystem), uint(outcomeTokenNetCost))
            );

            splitPositionThroughAllConditions(uint(outcomeTokenNetCost), conditionIds.length, 0);
        }

        for (uint i = 0; i < atomicOutcomeSlotCount; i++) {
            if(outcomeTokenAmounts[i] != 0) {
                uint positionId = generateAtomicPositionId(i);
                if(outcomeTokenAmounts[i] < 0) {
                    pmSystem.safeTransferFrom(msg.sender, address(this), positionId, uint(-outcomeTokenAmounts[i]), "");
                } else {
                    pmSystem.safeTransferFrom(address(this), msg.sender, positionId, uint(outcomeTokenAmounts[i]), "");
                }

            }
        }

        if(outcomeTokenNetCost < 0) {
            // This is safe since
            // 0x8000000000000000000000000000000000000000000000000000000000000000 ==
            // uint(-int(-0x8000000000000000000000000000000000000000000000000000000000000000))
            mergePositionsThroughAllConditions(uint(-outcomeTokenNetCost), conditionIds.length, 0);
            if(netCost < 0) {
                require(collateralToken.transfer(msg.sender, uint(-netCost)));
            }
        }

        emit AMMOutcomeTokenTrade(msg.sender, outcomeTokenAmounts, outcomeTokenNetCost, uint(fees));
    }

    /// @dev Calculates fee to be paid to market maker
    /// @param outcomeTokenCost Cost for buying outcome tokens
    /// @return Fee for trade
    function calcMarketFee(uint outcomeTokenCost)
        public
        view
        returns (uint)
    {
        return outcomeTokenCost * fee / FEE_RANGE;
    }

    function onERC1155Received(address operator, address /*from*/, uint256 /*id*/, uint256 /*value*/, bytes calldata /*data*/) external returns(bytes4) {
        if (operator == address(this)) {
            return 0xf23a6e61;
        }
        return 0x0;
    }

    function onERC1155BatchReceived(address _operator, address /*from*/, uint256[] calldata /*ids*/, uint256[] calldata /*values*/, bytes calldata /*data*/) external returns(bytes4) {
        if (_operator == address(this)) {
            return 0xf23a6e61;
        }
        return 0x0;
    }

    function generateBasicPartition(bytes32 conditionId)
        private
        view
        returns (uint[] memory partition)
    {
        partition = new uint[](pmSystem.getOutcomeSlotCount(conditionId));
        for(uint i = 0; i < partition.length; i++) {
            partition[i] = 1 << i;
        }
    }

    function generateAtomicPositionId(uint i)
        internal
        view
        returns (uint)
    {
        uint collectionId = 0;

        for(uint k = 0; k < conditionIds.length; k++) {
            uint curOutcomeSlotCount = pmSystem.getOutcomeSlotCount(conditionIds[k]);
            collectionId += uint(keccak256(abi.encodePacked(
                conditionIds[k],
                1 << (i % curOutcomeSlotCount))));
            i /= curOutcomeSlotCount;
        }
        return uint(keccak256(abi.encodePacked(
            collateralToken,
            collectionId)));
    }

    function splitPositionThroughAllConditions(uint amount, uint conditionsLeft, uint parentCollectionId)
        private
    {
        if(conditionsLeft == 0) return;
        conditionsLeft--;

        uint[] memory partition = generateBasicPartition(conditionIds[conditionsLeft]);
        pmSystem.splitPosition(collateralToken, bytes32(parentCollectionId), conditionIds[conditionsLeft], partition, amount);
        for(uint i = 0; i < partition.length; i++) {
            splitPositionThroughAllConditions(
                amount,
                conditionsLeft,
                parentCollectionId + uint(keccak256(abi.encodePacked(
                    conditionIds[conditionsLeft],
                    partition[i]))));
        }
    }

    function mergePositionsThroughAllConditions(uint amount, uint conditionsLeft, uint parentCollectionId)
        private
    {
        if(conditionsLeft == 0) return;
        conditionsLeft--;

        uint[] memory partition = generateBasicPartition(conditionIds[conditionsLeft]);
        for(uint i = 0; i < partition.length; i++) {
            mergePositionsThroughAllConditions(
                amount,
                conditionsLeft,
                parentCollectionId + uint(keccak256(abi.encodePacked(
                    conditionIds[conditionsLeft],
                    partition[i]))));
        }
        pmSystem.mergePositions(collateralToken, bytes32(parentCollectionId), conditionIds[conditionsLeft], partition, amount);
    }
}

// File: @gnosis.pm/hg-market-makers/contracts/LMSRMarketMaker.sol

pragma solidity ^0.5.1;





/// @title LMSR market maker contract - Calculates share prices based on share distribution and initial funding
/// @author Alan Lu - <alan.lu@gnosis.pm>
contract LMSRMarketMaker is MarketMaker {
    using SafeMath for uint;

    /*
     *  Constants
     */
    uint constant ONE = 0x10000000000000000;
    int constant EXP_LIMIT = 3394200909562557497344;

    constructor(PredictionMarketSystem _pmSystem, IERC20 _collateralToken, bytes32[] memory _conditionIds, uint64 _fee, uint _funding, address marketOwner)
        public
        MarketMaker(_pmSystem, _collateralToken, _conditionIds, _fee, _funding, marketOwner) {}


    /// @dev Calculates the net cost for executing a given trade.
    /// @param outcomeTokenAmounts Amounts of outcome tokens to buy from the market. If an amount is negative, represents an amount to sell to the market.
    /// @return Net cost of trade. If positive, represents amount of collateral which would be paid to the market for the trade. If negative, represents amount of collateral which would be received from the market for the trade.
    function calcNetCost(int[] memory outcomeTokenAmounts)
        public
        view
        returns (int netCost)
    {
        require(outcomeTokenAmounts.length == atomicOutcomeSlotCount);

        int[] memory otExpNums = new int[](atomicOutcomeSlotCount);
        for (uint i = 0; i < atomicOutcomeSlotCount; i++) {
            int balance = int(pmSystem.balanceOf(address(this), generateAtomicPositionId(i)));
            require(balance >= 0);
            otExpNums[i] = outcomeTokenAmounts[i].sub(balance);
        }

        int log2N = Fixed192x64Math.binaryLog(atomicOutcomeSlotCount * ONE, Fixed192x64Math.EstimationMode.UpperBound);

        (uint sum, int offset, ) = sumExpOffset(log2N, otExpNums, 0, Fixed192x64Math.EstimationMode.UpperBound);
        netCost = Fixed192x64Math.binaryLog(sum, Fixed192x64Math.EstimationMode.UpperBound);
        netCost = netCost.add(offset);
        netCost = (netCost.mul(int(ONE)) / log2N).mul(int(funding));

        // Integer division for negative numbers already uses ceiling,
        // so only check boundary condition for positive numbers
        if(netCost <= 0 || netCost / int(ONE) * int(ONE) == netCost) {
            netCost /= int(ONE);
        } else {
            netCost = netCost / int(ONE) + 1;
        }
    }

    /// @dev Returns marginal price of an outcome
    /// @param outcomeTokenIndex Index of outcome to determine marginal price of
    /// @return Marginal price of an outcome as a fixed point number
    function calcMarginalPrice(uint8 outcomeTokenIndex)
        public
        view
        returns (uint price)
    {
        int[] memory negOutcomeTokenBalances = new int[](atomicOutcomeSlotCount);
        for (uint i = 0; i < atomicOutcomeSlotCount; i++) {
            int negBalance = -int(pmSystem.balanceOf(address(this), generateAtomicPositionId(i)));
            require(negBalance <= 0);
            negOutcomeTokenBalances[i] = negBalance;
        }

        int log2N = Fixed192x64Math.binaryLog(negOutcomeTokenBalances.length * ONE, Fixed192x64Math.EstimationMode.Midpoint);
        // The price function is exp(quantities[i]/b) / sum(exp(q/b) for q in quantities)
        // To avoid overflow, calculate with
        // exp(quantities[i]/b - offset) / sum(exp(q/b - offset) for q in quantities)
        (uint sum, , uint outcomeExpTerm) = sumExpOffset(log2N, negOutcomeTokenBalances, outcomeTokenIndex, Fixed192x64Math.EstimationMode.Midpoint);
        return outcomeExpTerm / (sum / ONE);
    }

    /*
     *  Private functions
     */
    /// @dev Calculates sum(exp(q/b - offset) for q in quantities), where offset is set
    ///      so that the sum fits in 248-256 bits
    /// @param log2N Binary logarithm of the number of outcomes
    /// @param otExpNums Numerators of the exponents, denoted as q in the aforementioned formula
    /// @param outcomeIndex Index of exponential term to extract (for use by marginal price function)
    /// @return A result structure composed of the sum, the offset used, and the summand associated with the supplied index
    function sumExpOffset(int log2N, int[] memory otExpNums, uint8 outcomeIndex, Fixed192x64Math.EstimationMode estimationMode)
        private
        view
        returns (uint sum, int offset, uint outcomeExpTerm)
    {
        // Naive calculation of this causes an overflow
        // since anything above a bit over 133*ONE supplied to exp will explode
        // as exp(133) just about fits into 192 bits of whole number data.

        // The choice of this offset is subject to another limit:
        // computing the inner sum successfully.
        // Since the index is 8 bits, there has to be 8 bits of headroom for
        // each summand, meaning q/b - offset <= exponential_limit,
        // where that limit can be found with `mp.floor(mp.log((2**248 - 1) / ONE) * ONE)`
        // That is what EXP_LIMIT is set to: it is about 127.5

        // finally, if the distribution looks like [BIG, tiny, tiny...], using a
        // BIG offset will cause the tiny quantities to go really negative
        // causing the associated exponentials to vanish.

        require(log2N >= 0 && int(funding) >= 0);
        offset = Fixed192x64Math.max(otExpNums);
        offset = offset.mul(log2N) / int(funding);
        offset = offset.sub(EXP_LIMIT);
        uint term;
        for (uint8 i = 0; i < otExpNums.length; i++) {
            term = Fixed192x64Math.pow2((otExpNums[i].mul(log2N) / int(funding)).sub(offset), estimationMode);
            if (i == outcomeIndex)
                outcomeExpTerm = term;
            sum = sum.add(term);
        }
    }
}

// File: @gnosis.pm/hg-market-makers/contracts/LMSRMarketMakerFactory.sol

pragma solidity ^0.5.1;


contract LMSRMarketMakerFactory {
    event LMSRMarketMakerCreation(address indexed creator, LMSRMarketMaker lmsrMarketMaker, PredictionMarketSystem pmSystem, IERC20 collateralToken, bytes32[] conditionIds, uint64 fee, uint funding);

    function createLMSRMarketMaker(PredictionMarketSystem pmSystem, IERC20 collateralToken, bytes32[] memory conditionIds, uint64 fee, uint funding)
        public
        returns (LMSRMarketMaker lmsrMarketMaker)
    {
        lmsrMarketMaker = new LMSRMarketMaker(pmSystem, collateralToken, conditionIds, fee, funding, msg.sender);
        lmsrMarketMaker.transferOwnership(msg.sender);
        emit LMSRMarketMakerCreation(msg.sender, lmsrMarketMaker, pmSystem, collateralToken, conditionIds, fee, funding);
    }
}