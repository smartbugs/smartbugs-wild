pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * ZeroCache - AmTrust (First Edition)
 * 
 *             -----------------------------------------------------------------
 * 
 *             !!! WARNING WARNING WARNING !!!
 *             !!! THIS IS HIGHLY EXPERIMENTAL SOFTWARE !!!
 *             !!! USE AT YOUR OWN RISK !!!
 *             
 *             -----------------------------------------------------------------
 *             
 *             Our team at D14na has been hard at work over the Crypto Winter;
 *             and we are very proud to announce the premier release of a still
 *             experimental, but really fun and social new way to "Do Crypto!"
 * 
 *             TL;DR
 *             -----
 * 
 *             A meta-currency / smart wallet built for the purpose of promoting 
 *             and supporting the core economic needs of the Zeronet community:
 *                 1. Electronic Commerce
 *                 2. Zite Monetization
 *                 3. Wealth Management
 * 
 *             ALL transactions are guaranteed by Solidty contracts managed by a 
 *             growing community of federated nodes.
 * 
 *             For more information, please visit: 
 *             https://0net.io/zerocache.bit
 *
 * Version 19.2.21
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
 * ECRecovery
 *
 * Contract function to validate signature of pre-approved token transfers.
 * (borrowed from LavaWallet)
 */
contract ECRecovery {
    function recover(bytes32 hash, bytes sig) public pure returns (address);
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
 * Wrapped ETH (WETH) Interface
 */
contract WETHInterface {
    function() public payable;
    function deposit() public payable ;
    function withdraw(uint wad) public;
    function totalSupply() public view returns (uint);
    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);
}


/*******************************************************************************
 *
 * ERC-165 Interface
 */
contract ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


/*******************************************************************************
 *
 * ERC-1155 Interface
 */
// TODO Add interface functions
//      (see https://github.com/enjin/erc-1155/blob/master/contracts/IERC1155.sol)
//      (and https://blog.enjincoin.io/erc-1155-the-crypto-item-standard-ac9cf1c5a226)


/*******************************************************************************
 *
 * @notice ZeroCache DOES NOT HOLD ANY "OFFICIAL" AFFILIATION with ZeroNet Core,
 *         ZeroNet.io nor any of its brands and affiliates.
 *
 *         ZeroCache IS THE "OFFICIAL" META-CURRENCY OF THE GROWING COMMUNITY
 *         OF ZER0NET-SPONSORED PRODUCTS AND SERVICES.
 *
 * @dev In conjunction with the ZeroCache Daemon, this contract manages the
 *      ability to dynamically allocate the assets of a "smart" crypto wallet,
 *      in real-time, based on a user's pre-selected financial profile.
 *
 *      Initial support for the following cryptos:
 *          - Ethereum (WETH)   : HODL as a long-term growth investment.
 *          - MakerDAO (DAI)    : SPEDN on digital goods and services.
 *          - ZeroGold (0GOLD)  : STAEK to access premium features and services.
 */
contract ZeroCache is Owned {
    using SafeMath for uint;

    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /* Initialize account balances. */
    mapping(address => mapping (address => uint)) private _balances;

    /* Initialize expired signature flags. */
    mapping(bytes32 => bool) private _expiredSignatures;
    
    /* Initialize revision depth. */
    // NOTE: Allows for balance and transaction aggregation
    //       from legacy ZeroCache contract instance(s).
    // FIXME Determine the MAXIMUM depth and set here.
    //       Estimated to be between 100-200
    uint private _MAX_REVISION_DEPTH = 0;
    
    event Deposit(
        address indexed token, 
        address owner, 
        uint tokens,
        bytes data
    );

    event Migrate(
        address indexed token, 
        address owner, 
        uint tokens
    );

    event Skipped(
        address sender, 
        address receiver, 
        address token,
        uint tokens
    );

    event Staek(
        address sender, 
        address staekholder, 
        uint tokens
    );

    event Transfer(
        address indexed token, 
        address sender, 
        address receiver, 
        uint tokens
    );

    event Withdraw(
        address indexed token, 
        address owner, 
        uint tokens
    );
    
    /***************************************************************************
     *
     * Constructor
     */
    constructor() public {
        /* Set predecessor address. */
        _predecessor = 0x0;

        /* Verify predecessor address. */
        if (_predecessor != 0x0) {
            /* Retrieve the last revision number (if available). */
            uint lastRevision = ZeroCache(_predecessor).getRevision();
            
            /* Set (current) revision number. */
            _revision = lastRevision + 1;
        }
        
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
            abi.encodePacked(msg.sender, '.has.auth.for.zerocache'))) == true);

        _;      // function code is inserted here
    }

    /**
     * Fallback (default)
     * 
     * Accepts direct ETH transfers to be wrapped for owner into one of the
     * canonical Wrapped ETH (WETH) contracts:
     *     - Mainnet : 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
     *     - Ropsten : 0xc778417E063141139Fce010982780140Aa0cD5Ab
     *     - Kovan   : 0xd0A1E359811322d97991E03f863a0C30C2cF029C
     *     - Rinkeby : 0xc778417E063141139Fce010982780140Aa0cD5Ab
     * (source https://blog.0xproject.com/canonical-weth-a9aa7d0279dd)
     * 
     * NOTE: We are forced to hard-code all possible network contract
     *       (addresses) into this fallback since the WETH contract 
     *       DOES NOT provide enough gas for us to lookup the 
     *       specific address for our network.
     * 
     * NOTE: This contract requires ~50k gas to wrap ETH using the 
     *       fallback/wrap functions. However, it will require ~80k 
     *       to initialize on first-use.
     */
    function () public payable {
        /* Initialize WETH contract flag. */
        bool isWethContract = false;
        
        /* Initialize WETH contracts array. */
        address[4] memory contracts;
        
        /* Set Mainnet. */
        contracts[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        /* Set Ropsten. */
        contracts[1] = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

        /* Set Kovan. */
        contracts[2] = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

        /* Set Rinkeby. */
        contracts[3] = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
        
        /* Loop through all network contracts. */
        for (uint i = 0; i < contracts.length; i++) {
            /* Validate sender. */
            if (msg.sender == contracts[i]) {
                /* Set flag. */
                isWethContract = true;
            }
        }

        /* DO NOT (re-)wrap incoming ETH from Wrapped ETH contract. */
        if (!isWethContract) {
            _wrap(msg.sender);
        }
    }


    /***************************************************************************
     * 
     * ACTIONS
     * 
     */

    /**
     * Wrap
     */
    function wrap() external payable returns (bool success) {
        /* Return wrap success. */
        return _wrap(msg.sender);
    }
    
    /**
     * Wrap
     * 
     * NOTE: This function is primarily used to support instance 
     *       migration(s) of WETH.
     */
    function wrap(
        address _owner
    ) external payable returns (bool success) {
        return _wrap(_owner);
    }

    /**
     * Wrap
     * 
     * Send Ether into this method. It gets wrapped and then deposited 
     * in this contract as a token balance assigned to the sender.
     */
    function _wrap(
        address _owner
    ) private returns (bool success) {
        /* Set WETH address. */
        address wethAddress = _weth();

        /* Forward this payable ether into the wrapping contract. */
        // NOTE: Transfer ETH before balance credit to prevent re-entry attack.
        success = wethAddress.call
            .gas(200000)
            .value(msg.value)
            (abi.encodeWithSignature("deposit()"));
            
        /* Validate transfer. */
        if (success) {
            /* Increase WETH balance by sent value. */
            _balances[wethAddress][_owner] = 
                _balances[wethAddress][_owner].add(msg.value);
            
            /* Initialize empty data (for event log). */
            bytes memory data;
    
            /* Broadcast event. */
            emit Deposit(
                wethAddress, 
                _owner, 
                msg.value, 
                data
            );
        } else {
            /* Report error. */
            revert('An error occurred while wrapping your ETH.');
        }
    }

    /**
     * Unwrap
     */
    function unwrap(
        uint _tokens
    ) public returns (bool success) {
        return _unwrap(msg.sender, _tokens);
    }

    /**
     * Unwrap
     * 
     * We allow administrative unwrapping of WETH held
     * in the ZeroCache, FOR COMPLIANCE PURPOSES ONLY.
     * 
     * NOTE: This function is reserved for exclusive use by
     *       Zer0net Administration ONLY.
     * 
     *       Tokens unwrapped by an administrator can
     *       ONLY be transferred to the ORIGINAL owner.
     */
    function unwrap(
        address _owner, 
        uint _tokens
    ) onlyAuthBy0Admin external returns (bool success) {
        return _unwrap(_owner, _tokens);
    }

    /**
     * Unwrap
     * 
     * Allows an owner to unwrap their Ether from the 
     * canonical WETH contract.
     */
    function _unwrap(
        address _owner, 
        uint _tokens
    ) private returns (bool success) {
        /* Set WETH address. */
        address wethAddress = _weth();

        /* Validate balance. */
        if (_balances[wethAddress][_owner] < _tokens) {
            revert('Oops! You DO NOT have enough WETH.');
        }

        /* Decrease WETH balance by sent value. */
        // NOTE: Decrease balance before transfer to prevent re-entry attack.
        _balances[wethAddress][_owner] = 
            _balances[wethAddress][_owner].sub(_tokens);

        /* Withdraw ETH from Wrapper contract. */
        success = wethAddress.call
            .gas(200000)
            (abi.encodeWithSignature("withdraw(uint256)", _tokens));

        /* Validate withdrawal. */
        if (success) {
            /* Transfer "unwrapped" Ether (ETH) back to owner. */
            _owner.transfer(_tokens);
    
            /* Broadcast event. */
            emit Withdraw(
                wethAddress,
                _owner,
                _tokens
            );
        } else {
            /* Report error. */
            revert('An error occurred while unwrapping your ETH.');
        }
    }
    
    /**
     * Deposit
     * 
     * Provides support for "pre-approved" token deposits.
     * 
     * NOTE: Required pre-allowance/approval is required in order
     *       to successfully complete the transfer.
     */
    function deposit(
        address _token, 
        address _from, 
        uint _tokens, 
        bytes _data
    ) external returns (bool success) {
        /* Make deposit. */
        return _deposit(_token, _from, _tokens, _data);
    }

    /**
     * Receive Approval
     * 
     * Will typically be called from `approveAndCall`.
     * 
     * NOTE: Owner can assign ANY address to receive the deposit 
     *       (including their own). By default, owner will be used.
     */
    function receiveApproval(
        address _from, 
        uint _tokens, 
        address _token, 
        bytes _data
    ) public returns (bool success) {
        /* Make deposit. */
        return _deposit(_token, _from, _tokens, _data);
    }

    /**
     * Deposit
     * 
     * Deposits ANY ERC20-compatible token into this contract;
     * to be managed as ZeroCache. 
     * 
     * NOTE: Owners maintain 100% control* of their token(s) 
     *       at all times.
     * 
     *       * Administrators have the ability to return tokens
     *         back to their ORIGINAL owners AT ANY TIME.
     *         FOR COMPLIANCE PURPOSES ONLY
     */
    function _deposit(
        address _token,
        address _from, 
        uint _tokens,
        bytes _data
    ) private returns (bool success) {
        /* Transfer the ERC-20 tokens into Cache. */
        // NOTE: Transfer tokens before credit to prevent re-entry attack.
        ERC20Interface(_token).transferFrom(
            _from, address(this), _tokens);
        
        /* Initialize receiver (address). */
        address receiver = 0x0;
        
        /**
         * If `_data` is an `address`, then set the value to `receiver`.
         * e.g. when `approveAndCall` is made from a contract 
         * (representing the owner).
         */
        if (_data.length == 20) {
            /* Retrieve the receiver's address from `data` payload. */
            receiver = _bytesToAddress(_data);
        } else {
            /* Set receiver to `from` (also the token owner). */
            receiver = _from;
        }

        /* Increase receiver balance. */
        _balances[_token][receiver] = 
            _balances[_token][receiver].add(_tokens);

        /* Broadcast event. */
        emit Deposit(_token, receiver, _tokens, _data);

        /* Return success. */
        return true;
    }

    /**
     * Withdraw
     */
    function withdraw(
        address _token, 
        uint _tokens
    ) public returns (bool success) {
        return _withdraw(msg.sender, _token, _tokens);
    }
    
    /**
     * Withdraw
     * 
     * We allow administrative withdrawls of tokens held
     * in the ZeroCache, FOR COMPLIANCE PURPOSES ONLY.
     * 
     * NOTE: This function is reserved for exclusive use by
     *       Zer0net Administration ONLY.
     * 
     *       Tokens withdrawn by an administrator can
     *       ONLY be transferred to the ORIGINAL owner.
     */
    function withdraw(
        address _owner, 
        address _token, 
        uint _tokens
    ) onlyAuthBy0Admin external returns (bool success) {
        return _withdraw(_owner, _token, _tokens);
    }

    /**
     * Withdraw
     * 
     * Allows the withdrawl of tokens held in the ZeroCache
     * back to the ORIGINAL owner.
     */
    function _withdraw(
        address _owner, 
        address _token, 
        uint _tokens
    ) private returns (bool success) {
        /* Validate balance. */
        if (_balances[_token][_owner] < _tokens) {
            revert('Oops! You DO NOT have enough tokens.');
        }

        /* Decrease owner balance by token amount. */
        // NOTE: Decrease balance before transfer to prevent re-entry attack.
        _balances[_token][_owner] = 
            _balances[_token][_owner].sub(_tokens);

        /* Transfer requested tokens to owner. */
        ERC20Interface(_token).transfer(_owner, _tokens);

        /* Broadcast event. */
        emit Withdraw(_token, _owner, _tokens);
    
        /* Return success. */
        return true;
    }

    /**
     * Transfer
     *
     * Transfers the "specified" ERC-20 tokens held by the sender
     * to the receiver's account.
     */
    function transfer(
        address _to,
        address _token,
        uint _tokens
    ) external returns (bool success) {
        return _transfer(
            msg.sender, _to, _token, _tokens);
    }

    /**
     * (Relayed) Transfer
     * 
     * This transfer requires an off-chain (EC) signature, from the 
     * account holder, detailing the transaction.
     * 
     * Staekholder
     * -----------
     * 
     * Users may choose to boost the speed of execution for their 
     * transfer request, decreasing the delivery time to near instant 
     * (highest priority for miners to process) confirmation. 
     * 
     * A staek of ZeroGold is required to be added to the request, 
     * in an amount specified by your preferred staekholder.
     * 
     * This staek is 100% optional, as Standard Delivery will be 
     * FREE FOREVER!
     * 
     * TODO: Let's implement GasToken to provide staekholders an opportunity
     *       to hedge against the volatility of future gas prices.
     *       (source: https://gastoken.io/)
     */
    function transfer(
        address _token,       // contract address
        address _from,        // sender's address
        address _to,          // receiver's address
        uint _tokens,         // quantity of tokens
        address _staekholder, // staekholder
        uint _staek,          // staek amount
        uint _expires,        // expiration time
        uint _nonce,          // unique integer
        bytes _signature      // signed message
    ) external returns (bool success) {
        /* Calculate transfer hash. */
        bytes32 transferHash = keccak256(abi.encodePacked(
            address(this), 
            _token, 
            _from,
            _to,
            _tokens,
            _staekholder,
            _staek,
            _expires,
            _nonce
        ));

        /* Validate request has authorized signature. */
        bool requestHasAuthSig = _requestHasAuthSig(
            _from,
            transferHash,
            _expires,
            _signature
        );
        
        /* Validate authorization. */
        if (!requestHasAuthSig) {
            revert('Oops! This relay request is NOT valid.');
        }
        
        /* Validate boost fee and pay (if necessary). */
        if (_staekholder != 0x0 && _staek > 0) {
            _addStaek(_from, _staekholder, _staek);
        }

        /* Request token transfer. */
        return _transfer(
            _from, _to, _token, _tokens);
    }

    /**
     * Transfer
     *
     * Transfers the "specified" ERC-20 token(s) held by the sender
     * to the receiver's account.
     */
    function _transfer(
        address _from,
        address _to,
        address _token,
        uint _tokens
    ) private returns (bool success) {
        /* Validate balance. */
        if (_balances[_token][_from] < _tokens) {
            revert('Oops! You DO NOT have enough tokens.');
        }

        /* Remove the transfer value from sender's balance. */
        // NOTE: We decrease balance before adding to prevent re-entry attack.
        _balances[_token][_from] = _balances[_token][_from].sub(_tokens);

        /* Add the transfer value to the receiver's balance. */
        _balances[_token][_to] = _balances[_token][_to].add(_tokens);

        /* Broadcast event. */
        emit Transfer(
            _token, 
            _from, 
            _to, 
            _tokens
        );

        /* Return success. */
        return true;
    }
    
    /**
     * Multi Transfer
     *
     * Transfers multiple ERC-20 tokens held by the sender
     * to multiple receiver accounts.
     */
    function multiTransfer(
        address[] _to,
        address[] _token,
        uint[] _tokens
    ) external returns (bool success) {
        return _multiTransfer(msg.sender, _to, _token, _tokens);
    }
    
    //----------------------------------------------------------------
    //----------------------------------------------------------------
    // NOTE: We DO NOT yet offer support for RELAYED Multi Transfers.
    //----------------------------------------------------------------
    //----------------------------------------------------------------

    /**
     * Transfer Multiple Tokens (w/ Single Transaction)
     * 
     * WARNING: Sending to multiple receipients is very risky,
     *          as there is NO way to control the gas costs per
     *          transaction (ie. contract addresses are limitless).
     * 
     *          For this reason, we SKIP ALL transfers to contract
     *          addresses. You can monitor the `Skipped` event.
     */
    function _multiTransfer(
        address _from,
        address[] _to,
        address[] _token,
        uint[] _tokens
    ) private returns (bool success) {
        /* Loop through all receivers. */
        for (uint i = 0; i < _to.length; i++) {
            /* Set token. */
            address token = _token[i];
           
            /* Set token value. */
            uint tokens = _tokens[i];
           
            /* Set receiver. */
            address to = _to[i];
            
            /* Validate receiver address. */
            if (_ownerIsContract(to)) {
                /* Broadcast event. */
                emit Skipped(_from, to, token, tokens);
            } else {
                /* Transfer tokens. */
                _transfer(
                    _from, to, token, tokens);
            }
        }
        
        /* Return success. */
        return true;
    }

    /**
     * Add Staek (to Relay Transfer)
     *
     * This is an (optional) staek provided by the sender, which 
     * transfers ZeroGold from the sender's account to the specified 
     * staekholder account.
     * 
     * NOTE: Staek is only a temporary hold, until fees are collected
     *       by the sender's preferred staekholder.
     */
    function _addStaek(
        address _owner,
        address _staekholder,
        uint _tokens
    ) private returns (bool success) {
        /* Set ZeroGold address. */
        address zgAddress = _zeroGold();

        /* Validate available balance. */
        if (_balances[zgAddress][_owner] < _tokens) {
            revert('Oops! You DO NOT have enough ZeroGold to staek.');
        }

        /* Decrease owner balance by token amount. */
        // NOTE: Decrease balance before transfer to prevent re-entry attack.
        _balances[zgAddress][_owner] = 
            _balances[zgAddress][_owner].sub(_tokens);

        /* Transfer specified tokens to staekholder account. */
        _zeroGold().transfer(_staekholder, _tokens);

        /* Broadcast event. */
        emit Staek(
            _owner, 
            _staekholder, 
            _tokens
        );

        /* Return success. */
        return true;
    }

    /**
     * Cancel
     *
     * Cancels a previously authorized/signed transfer request, 
     * by invalidating the signature on-chain.
     */
    function cancel(
        address _token,       // contract address
        address _from,        // sender's address
        address _to,          // receiver's address
        uint _tokens,         // quantity of tokens
        address _staekholder, // staekholder
        uint _staek,          // staek amount
        uint _expires,        // expiration time
        uint _nonce,          // unique integer
        bytes _signature      // signed message
    ) external returns (bool success) {
        /* Calculate cancel hash. */
        bytes32 cancelHash = keccak256(abi.encodePacked(
            address(this), 
            _token, 
            _from,
            _to,
            _tokens,
            _staekholder,
            _staek,
            _expires,
            _nonce
        ));

        /* Validate request has authorized signature. */
        bool requestHasAuthSig = _requestHasAuthSig(
            _from,
            cancelHash,
            _expires,
            _signature
        );
        
        /* Validate authorization. */
        if (!requestHasAuthSig) {
            revert('Oops! This cancel request is NOT valid.');
        }
        
        /* Return success. */
        return true;
    }

    /**
     * Migrate
     */
    function migrate(
        address[] _tokens
    ) external returns (bool success) {
        return _migrate(msg.sender, _tokens);
    }
    
    /**
     * Migrate
     * 
     * THIS FUNCTION IS UN-IMPLMENTED
     * 
     * NOTE: There is no ADMIN migration function available
     *       as a protection against UNAUTHORIZED transfer(s) to 
     *       possible rogue instance(s) of ZeroCache.
     */

    /**
     * Migrate
     * 
     * Allows for the full balance transfer of a multiple token(s)
     * from legacy instance(s) to the LATEST instance of ZeroCache.
     */
    function _migrate(
        address _owner, 
        address[] _tokens
    ) private returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256('aname.zerocache');

        /* Retrieve value from Zer0net Db. */
        address latestCache = _zer0netDb.getAddress(hash);

        /* Loop through all tokens. */
        for (uint i = 0; i < _tokens.length; i++) {
            /* Set token. */
            address token = _tokens[i];
            
            /* Retrieve balance. */
            // NOTE: Explicitly set depth to `0`, to retrieve the
            //       balance for ONLY this instance.
            uint balance = balanceOf(token, _owner, 0);
            
            /* Decrease owner balance to ZERO. */
            // NOTE: Balance is ZEROED here to prevent re-entry attack.
            _balances[token][_owner] = 0;

            /* Validate WETH contract (requires `unwrap`). */
            if (token == address(_weth())) {
                /* Set WETH address. */
                address wethAddress = _weth();
        
                /* Withdraw ETH from Wrapper contract. */
                success = wethAddress.call
                    .gas(100000)
                    (abi.encodeWithSignature("withdraw(uint256)", balance));
        
                /* (Re-)Wrap ETH into LATEST instance. */
                // NOTE: ETH will be wrapped on `_owner` behalf.
                success = latestCache.call
                    .gas(100000)
                    .value(balance)
                    (abi.encodeWithSignature("wrap(address)", _owner));
            } else {
                /* Set data to owner (address). */
                // NOTE: Required to assign tokens after being received
                //       by the new contract instance.
                bytes memory data = abi.encodePacked(_owner);

                /* (Re-)Deposit tokens into LATEST instance. */
                // NOTE: Tokens will be credited to `_owner` (aka `data`).
                ApproveAndCallFallBack(token)
                    .approveAndCall(latestCache, balance, data);

                /* Set success. */
                success = true;
            }

            /* Broadcast event. */
            emit Migrate(token, _owner, balance);
        }
    }
    

    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get Revision (Number)
     */
    function getRevision() public view returns (uint) {
        return _revision;
    }
    
    /**
     * Get Predecessor (Address)
     */
    function getPredecessor() public view returns (address) {
        return _predecessor;
    }
    
    /**
     * Get Successor (Address)
     */
    function getSuccessor() public view returns (address) {
        return _successor;
    }
    
    /**
     * Get the token balance for account `tokenOwner`
     */
    function balanceOf(
        address _token,
        address _owner
    ) external constant returns (uint balance) {
        /* Return balance. */
        return balanceOf(
            _token, _owner, _MAX_REVISION_DEPTH);
    }

    /**
     * Get the token balance for account `tokenOwner`
     * 
     * NOTE: Supports a virtually unlimited depth, 
     *       limited ONLY by the supplied gas amount.
     */
    function balanceOf(
        address _token,
        address _owner,
        uint _depth
    ) public constant returns (uint balance) {
        /* Retrieve (current) balance. */
        balance = _balances[_token][_owner];
        
        /* Initialize legacy instance (to current predecessor). */
        address legacyInstance = getPredecessor();
        
        /* Validate legacy instance. */
        if (legacyInstance != 0x0) {
            /* Initialize total legacy balance. */
            uint totalLegacyBalance = 0;
            
            /* Loop through legacy instances for balance. */
            for (uint i = 0; i < _depth; i++) {
                /* Retrieve balance. */
                uint legacyBalance = ZeroCache(legacyInstance)
                    .balanceOf(_token, _owner);
                    
                /* Add to legacy balance total. */
                totalLegacyBalance = totalLegacyBalance.add(legacyBalance);
    
                /* Set the next legacy instance / predecessor (if available). */
                legacyInstance = ZeroCache(legacyInstance).getPredecessor();
                
                /* Validate legacy instance. */
                if (legacyInstance == 0x0) {
                    /* Break the loop. */
                    break;
                }
            }
            
            /* Add total legacy balance. */
            balance = balance.add(totalLegacyBalance);
        }
    }

    
    /***************************************************************************
     * 
     * SETTERS
     * 
     */

    /**
     * Set Successor
     * 
     * This is the contract address that replaced this current instnace.
     */
    function setSuccessor(
        address _newSuccessor
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Set successor contract. */
        _successor = _newSuccessor;
        
        /* Return success. */
        return true;
    }


    /***************************************************************************
     * 
     * INTERFACES
     * 
     */

    /**
     * Supports Interface (EIP-165)
     * 
     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)
     * 
     * NOTE: Must support the following conditions:
     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)
     *       2. (false) when interfaceID is 0xffffffff
     *       3. (true) for any other interfaceID this contract implements
     *       4. (false) for any other interfaceID
     */
    function supportsInterface(
        bytes4 _interfaceID
    ) external pure returns (bool) {
        /* Initialize constants. */
        bytes4 InvalidId = 0xffffffff;
        bytes4 ERC165Id = 0x01ffc9a7;

        /* Validate condition #2. */
        if (_interfaceID == InvalidId) {
            return false;
        }

        /* Validate condition #1. */
        if (_interfaceID == ERC165Id) {
            return true;
        }
        
        // TODO Add additional interfaces here.
        
        /* Return false (for condition #4). */
        return false;
    }

    /**
     * ECRecovery Interface
     */
    function _ecRecovery() private view returns (
        ECRecovery ecrecovery
    ) {
        /* Initailze hash. */
        bytes32 hash = keccak256('aname.ecrecovery');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        ecrecovery = ECRecovery(aname);
    }

    /**
     * Wrapped Ether (WETH) Interface
     * 
     * Retrieves the current WETH interface,
     * using the aname record from Zer0netDb.
     */
    function _weth() private view returns (
        WETHInterface weth
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.WETH');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        weth = WETHInterface(aname);
    }

    /**
     * MakerDAO DAI Interface
     * 
     * Retrieves the current DAI interface,
     * using the aname record from Zer0netDb.
     */
    function _dai() private view returns (
        ERC20Interface dai
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.DAI');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        dai = ERC20Interface(aname);
    }

    /**
     * ZeroGold Interface
     * 
     * Retrieves the current ZeroGold interface,
     * using the aname record from Zer0netDb.
     */
    function _zeroGold() private view returns (
        ERC20Interface zeroGold
    ) {
        /* Initailze hash. */
        // NOTE: ERC tokens are case-sensitive.
        bytes32 hash = keccak256('aname.0GOLD');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        zeroGold = ERC20Interface(aname);
    }


    /***************************************************************************
     * 
     * UTILITIES
     * 
     */

    /**
     * Request Hash Authorized Signature
     * 
     * Validates ALL signature requests by:
     *     1. Uses ECRecovery to validate the signature.
     *     2. Verify expiration against the current block number.
     *     3. Sets a flag to block re-use of signature.
     */
    function _requestHasAuthSig(
        address _from,
        bytes32 _authHash,
        uint _expires,
        bytes _signature
    ) private returns (bool success) {
        /* Calculate signature hash. */
        bytes32 sigHash = keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', _authHash));

        /* Validate signature expiration. */
        if (_expiredSignatures[sigHash]) {
            return false;
        }

        /* Set expiration flag. */
        // NOTE: Set a flag here to prevent double-spending.
        _expiredSignatures[sigHash] = true;
        
        /* Validate the expiration time. */
        if (block.number > _expires) {
            return false;
        }
        
        /* Retrieve the authorized account (address). */
        address authorizedAccount = 
            _ecRecovery().recover(sigHash, _signature);

        /* Validate the signer matches owner of the tokens. */
        if (_from != authorizedAccount) {
            return false;
        }

        /* Return success. */    
        return true;
    }

    /**
     * Is (Owner) Contract
     * 
     * Tests if a specified account / address is a contract.
     */
    function _ownerIsContract(
        address _owner
    ) private view returns (bool isContract) {
        /* Initialize code length. */
        uint codeLength;

        /* Run assembly. */
        assembly {
            /* Retrieve the size of the code on target address. */
            codeLength := extcodesize(_owner)
        }
        
        /* Set test result. */
        isContract = (codeLength > 0);
    }

    /**
     * Bytes-to-Address
     * 
     * Converts bytes into type address.
     */
    function _bytesToAddress(bytes _address) private pure returns (address) {
        uint160 m = 0;
        uint160 b = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            b = uint160(_address[i]);
            m += (b);
        }

        return address(m);
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
        address _tokenAddress, 
        uint _tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);
    }
}