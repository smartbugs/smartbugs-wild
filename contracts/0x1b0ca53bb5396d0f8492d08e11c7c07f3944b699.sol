pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * ZeroPriceIndex - Management system for maintaining the trade prices of
 *                  ERC tokens & collectibles listed within ZeroCache.
 *
 * Version 19.2.9
 *
 * https://d14na.org
 * support@d14na.org
 */


/*******************************************************************************
 *
 * SafeMath
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/*******************************************************************************
 *
 * ERC Token Standard #20 Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/*******************************************************************************
 *
 * ApproveAndCallFallBack
 *
 * Contract function to receive approval and execute function in one call
 * (borrowed from MiniMeToken)
 */
contract ApproveAndCallFallBack {
    function approveAndCall(address spender, uint tokens, bytes data) public;
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


/*******************************************************************************
 *
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }
}


/*******************************************************************************
 * 
 * Zer0netDb Interface
 */
contract Zer0netDbInterface {
    /* Interface getters. */
    function getAddress(bytes32 _key) external view returns (address);
    function getBool(bytes32 _key)    external view returns (bool);
    function getBytes(bytes32 _key)   external view returns (bytes);
    function getInt(bytes32 _key)     external view returns (int);
    function getString(bytes32 _key)  external view returns (string);
    function getUint(bytes32 _key)    external view returns (uint);

    /* Interface setters. */
    function setAddress(bytes32 _key, address _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setString(bytes32 _key, string _value) external;
    function setUint(bytes32 _key, uint _value) external;

    /* Interface deletes. */
    function deleteAddress(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
}


/*******************************************************************************
 *
 * @notice Zero(Cache) Price Index
 *
 * @dev Manages the current trade prices of ZeroCache tokens.
 */
contract ZeroPriceIndex is Owned {
    using SafeMath for uint;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /* Initialize price notification. */
    event PriceSet(
        bytes32 indexed key, 
        uint value
    );

    /**
     * Set Zero(Cache) Price Index namespaces
     * 
     * NOTE: Keep all namespaces lowercase.
     */
    string private _NAMESPACE = 'zpi';

    /* Set Dai Stablecoin (trade pair) base. */
    string private _TRADE_PAIR_BASE = 'DAI';

    /**
     * Initialize Core Tokens
     * 
     * NOTE: All tokens are traded against DAI Stablecoin.
     */
    string[3] _CORE_TOKENS = [
        'WETH',     // Wrapped Ether
        '0GOLD',    // ZeroGold
        '0xBTC'     // 0xBitcoin Token
    ];

    /***************************************************************************
     *
     * Constructor
     */
    constructor() public {
        /* Initialize Zer0netDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);
    }

    /**
     * @dev Only allow access to an authorized Zer0net administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(_zer0netDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.zero.price.index'))) == true);

        _;      // function code is inserted here
    }
    
    /**
     * Get Trade Price
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function tradePriceOf(
        string _token
    ) external view returns (uint price) {
        /* Initailze hash. */
        bytes32 hash = 0x0;
        
        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _NAMESPACE, '.', _token, '.', _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        price = _zer0netDb.getUint(hash);
    }

    /**
     * Get (All) Core Trade Prices
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function coreTradePrices() external view returns (uint[3] prices) {
        /* Initailze hash. */
        bytes32 hash = 0x0;
        
        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _NAMESPACE, '.WETH.', _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        prices[0] = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _NAMESPACE, '.0GOLD.', _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        prices[1] = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _NAMESPACE, '.0xBTC.', _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        prices[2] = _zer0netDb.getUint(hash);
    }

    /**
     * Set Trade Price
     * 
     * NOTE: All trades are made against DAI stablecoin.
     * 
     * Keys for trade pairs are encoded using the 'exact' symbol,
     * as listed in their respective contract:
     * 
     *     Wrapped Ether `0PI.WETH.DAI`
     *     0x3f1c44ba685cff388a95a3e7ae4b6f00efe4793f0629b97577c1aa17090665ad
     * 
     *     ZeroGold `0PI.0GOLD.DAI`
     *     0xeb7bb6c531569208c3173a7af7030a37a5a4b6d9f1518a8ae9ec655bde099fec
     * 
     *     0xBitcoin Token `0PI.0xBTC.DAI`
     *     0xcaf604185158d62d93f6252c02ca8238aecf42f5560c4c98d13cd1391bc54d42
     */
    function setTradePrice(
        string _token,
        uint _value
    ) external onlyAuthBy0Admin returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _NAMESPACE, '.', _token, '.', _TRADE_PAIR_BASE
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _value);
        
        /* Broadcast event. */
        emit PriceSet(hash, _value);
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set Core Prices
     * 
     * NOTE: All trades are made against DAI stablecoin.
     * 
     * NOTE: Use of `string[]` is still experimental, 
     *       so we are required to `setCorePrices` by sending
     *       `_values` in the proper format.
     */
    function setAllCoreTradePrices(
        uint[] _values
    ) external onlyAuthBy0Admin returns (bool success) {
        /* Iterate Core Tokens for updating. */    
        for (uint i = 0; i < _CORE_TOKENS.length; i++) {
            /* Set hash. */
            bytes32 hash = keccak256(abi.encodePacked(
                _NAMESPACE, '.', _CORE_TOKENS[i], '.', _TRADE_PAIR_BASE
            ));
    
            /* Set value in Zer0net Db. */
            _zer0netDb.setUint(hash, _values[i]);
            
            /* Broadcast event. */
            emit PriceSet(hash, _values[i]);
        }
        
        /* Return success. */
        return true;
    }
    
    /**
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER
     */
    function () public payable {
        /* Cancel this transaction. */
        revert('Oops! Direct payments are NOT permitted here.');
    }

    /**
     * Transfer Any ERC20 Token
     *
     * @notice Owner can transfer out any accidentally sent ERC20 tokens.
     *
     * @dev Provides an ERC20 interface, which allows for the recover
     *      of any accidentally sent ERC20 tokens.
     */
    function transferAnyERC20Token(
        address tokenAddress, uint tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}