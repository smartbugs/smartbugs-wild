pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2018 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * Nametag - Canonical Profile Manager for Zer0net
 * 
 *           Designed to support the needs of the growing Zeronet community.
 *
 * Version 19.3.21
 *
 * Web    : https://d14na.org
 * Email  : support@d14na.org
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
 * ZeroCache Interface
 */
contract ZeroCacheInterface {
    function balanceOf(address _token, address _owner) public constant returns (uint balance);
    function transfer(address _to, address _token, uint _tokens) external returns (bool success);
    function transfer(address _token, address _from, address _to, uint _tokens, address _staekholder, uint _staek, uint _expires, uint _nonce, bytes _signature) external returns (bool success);
}


/*******************************************************************************
 *
 * @notice Nametag Manager.
 *
 * @dev Nametag is the canonical profile manager for Zer0net.
 */
contract Nametag is Owned {
    using SafeMath for uint;

    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /**
     * Set Namespace
     * 
     * Provides a "unique" name for generating "unique" data identifiers,
     * most commonly used as database "key-value" keys.
     * 
     * NOTE: Use of `namespace` is REQUIRED when generating ANY & ALL
     *       Zer0netDb keys; in order to prevent ANY accidental or
     *       malicious SQL-injection vulnerabilities / attacks.
     */
    string private _namespace = 'nametag';

    event Update(
        string indexed nametag,
        string indexed field,
        bytes data
    );
    
    event Permissions(
        address indexed owner,
        address indexed delegate,
        bytes permissions
    );
    
    event Respect(
        address indexed owner,
        address indexed peer,
        uint respect
    );
    
    /***************************************************************************
     *
     * Constructor
     */
    constructor() public {
        /* Initialize Zer0netDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);

        /* Initialize (aname) hash. */
        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));

        /* Set predecessor address. */
        _predecessor = _zer0netDb.getAddress(hash);

        /* Verify predecessor address. */
        if (_predecessor != 0x0) {
            /* Retrieve the last revision number (if available). */
            uint lastRevision = Nametag(_predecessor).getRevision();
            
            /* Set (current) revision number. */
            _revision = lastRevision + 1;
        }
    }

    /**
     * @dev Only allow access to an authorized Zer0net administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(_zer0netDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);

        _;      // function code is inserted here
    }

    /**
     * @dev Only allow access to "registered" nametag owner.
     */
    modifier onlyNametagOwner(
        string _nametag
    ) {
        /* Calculate owner hash. */
        bytes32 ownerHash = keccak256(abi.encodePacked(
            _namespace, '.',
            _nametag,
            '.owner'
        ));

        /* Retrieve nametag owner. */
        address nametagOwner = _zer0netDb.getAddress(ownerHash);

        /* Validate nametag owner. */
        require(msg.sender == nametagOwner);

        _;      // function code is inserted here
    }

    /**
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER
     */
    function () public payable {
        /* Cancel this transaction. */
        revert('Oops! Direct payments are NOT permitted here.');
    }


    /***************************************************************************
     * 
     * ACTIONS
     * 
     */

    /**
     * Give Respect (To Another Peer)
     */
    function giveRespect(
        address _peer,
        uint _respect
    ) public returns (bool success) {
        /* Set respect. */
        return _setRespect(msg.sender, _peer, _respect);
    }

    /**
     * Give Respect (To Another Peer by Relayer)
     */
    function giveRespect(
        address _peer,
        uint _respect,
        uint _expires,
        uint _nonce,
        bytes _signature
    ) external returns (bool success) {
        /* Make sure the signature has not expired. */
        if (block.number > _expires) {
            revert('Oops! That signature has already EXPIRED.');
        }

        /* Calculate encoded data hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            address(this),
            _peer,
            _respect, 
            _expires,
            _nonce
        ));

        bytes32 sigHash = keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', hash));

        /* Retrieve the authorized signer. */
        address signer = 
            _ecRecovery().recover(sigHash, _signature);

        /* Set respect. */
        return _setRespect(signer, _peer, _respect);
    }

    /**
     * Show Respect (For Another Peer)
     */
    function showRespectFor(
        address _peer
    ) external view returns (uint respect) {
        /* Show respect (value). */
        return _getRespect(msg.sender, _peer);
    }

    /**
     * Show Respect (Between Two Peers)
     */
    function showRespect(
        address _owner,
        address _peer
    ) external view returns (
        uint respect,
        uint reciprocal
    ) {
        /* Retriieve respect (value). */
        respect = _getRespect(_owner, _peer);

        /* Retriieve respect (value). */
        reciprocal = _getRespect(_peer, _owner);
    }


    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get Data
     * 
     * Retrieves the value for the given nametag id and data field.
     */
    function getData(
        string _nametag, 
        string _field
    ) external view returns (bytes data) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _nametag, '.', 
            _field
        ));
        
        /* Retrieve data. */
        data = _zer0netDb.getBytes(dataId);
    }

    /**
     * Get Permissions
     * 
     * Owners can grant authority to delegated accounts with pre-determined
     * abilities for managing the primary account.
     * 
     * This allows them to carry-out normal, everyday functions without 
     * exposing the security of a more secure account.
     */
    function getPermissions(
        string _nametag,
        address _owner,
        address _delegate
    ) external view returns (bytes permissions) {
        /* Set hash. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _nametag, '.', 
            _owner, '.', 
            _delegate, 
            '.permissions'
        ));
        
        /* Save data to database. */
        permissions = _zer0netDb.getBytes(dataId);
    }
    
    /**
     * Get Respect
     */
    function _getRespect(
        address _owner,
        address _peer
    ) private view returns (uint respect) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _owner, 
            '.respect.for.', 
            _peer
        ));
        
        /* Retrieve data from database. */
        respect = _zer0netDb.getUint(dataId);
    }
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
    

    /***************************************************************************
     * 
     * SETTERS
     * 
     */

    /**
     * Set (Nametag) Data
     * 
     * NOTE: Nametags are NOT permanent, and WILL become vacated after an 
     *       extended period of inactivity.
     * 
     *       *** LIMIT OF ONE AUTHORIZED ACCOUNT / ADDRESS PER NAMETAG ***
     */
    function setData(
        string _nametag, 
        string _field, 
        bytes _data
    ) external onlyNametagOwner(_nametag) returns (bool success) {
        /* Set data. */
        return _setData(
            _nametag, 
            _field, 
            _data
        );
    }

    /**
     * Set (Nametag) Data (by Relayer)
     */
    function setData(
        string _nametag, 
        string _field, 
        bytes _data,
        uint _expires,
        uint _nonce,
        bytes _signature
    ) external returns (bool success) {
        /* Make sure the signature has not expired. */
        if (block.number > _expires) {
            revert('Oops! That signature has already EXPIRED.');
        }

        /* Calculate encoded data hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            address(this),
            _nametag, 
            _field, 
            _data, 
            _expires,
            _nonce
        ));
        
        /* Validate signature. */
        if (!_validateSignature(_nametag, hash, _signature)) {
            revert('Oops! Your signature is INVALID.');
        }

        /* Set data. */
        return _setData(
            _nametag, 
            _field, 
            _data
        );
    }

    /**
     * @notice Set nametag info.
     * 
     * @dev Calculate the `_root` hash and use it to store a
     *      definition string in the eternal database.
     * 
     *      NOTE: Markdown will be the default format for definitions.
     */
    function _setData(
        string _nametag, 
        string _field, 
        bytes _data
    ) private returns (bool success) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _nametag, '.', 
            _field
        ));
        
        /* Save data to database. */
        _zer0netDb.setBytes(dataId, _data);

        /* Broadcast event. */
        emit Update(
            _nametag,
            _field,
            _data
        );

        /* Return success. */
        return true;
    }
    
    /**
     * Set Permissions
     */
    function setPermissions(
        string _nametag,
        address _delegate,
        bytes _permissions
    ) external returns (bool success) {
        /* Set permissions. */
        return _setPermissions(
            _nametag, 
            msg.sender, 
            _delegate, 
            _permissions
        );
    }

    /**
     * Set Permissions
     */
    function setPermissions(
        string _nametag,
        address _owner,
        address _delegate,
        bytes _permissions,
        uint _expires,
        uint _nonce,
        bytes _signature
    ) external returns (bool success) {
        /* Make sure the signature has not expired. */
        if (block.number > _expires) {
            revert('Oops! That signature has already EXPIRED.');
        }

        /* Calculate encoded data hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            address(this),
            _nametag,
            _owner, 
            _delegate, 
            _permissions, 
            _expires,
            _nonce
        ));

        /* Validate signature. */
        if (!_validateSignature(_nametag, hash, _signature)) {
            revert('Oops! Your signature is INVALID.');
        }

        /* Set permissions. */
        return _setPermissions(
            _nametag, 
            _owner, 
            _delegate, 
            _permissions
        );
    }

    /**
     * Set Permissions
     * 
     * Allows owners to delegate another Ethereum account
     * to proxy commands as if they are the primary account.
     * 
     * Permissions are encoded as TWO (2) bytes in a bytes array. ALL permissions
     * are assumed to be false, unless explicitly specified in this bytes array.
     * 
     * Proposed Permissions List
     * -------------------------
     * 
     * TODO Review Web3 JSON api for best (data access) structure.
     *      (see https://web3js.readthedocs.io/en/1.0/web3.html)
     * 
     *     Profile Management (0x10__)
     *         0x1001 => Modify Public Info
     *         0x1002 => Modify Private Info
     *         0x1003 => Modify Permissions
     * 
     *     HODL Management (0x20__)
     *         0x2001 => Deposit Tokens
     *         0x2002 => Withdraw Tokens
     * 
     *     SPEDN Management (0x30__)
     *         0x3001 => Transfer ANY ERC
     *         0x3002 => Transfer ERC-20
     *         0x3003 => Transfer ERC-721
     * 
     *     STAEK Management (0x40__)
     *         0x4001 => Increase Staek
     *         0x4002 => Decrease Staek
     *         0x4003 => Shift/Transfer Staek
     * 
     *     Exchange / Trade Execution (0x50__)
     *         0x5001 => Place Order (Maker)
     *         0x5002 => Place Order (Taker)
     *         0x5003 => Margin Account
     * 
     *     Voting & Governance (0x60__)
     *         0x6001 => Cast Vote
     * 
     * (this specification is in active development and subject to change)
     * 
     * NOTE: Permissions WILL NOT be transferred between owners.
     */
    function _setPermissions(
        string _nametag,
        address _owner,
        address _delegate,
        bytes _permissions
    ) private returns (bool success) {
        /* Set data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _nametag, '.', 
            _owner, '.', 
            _delegate, 
            '.permissions'
        ));
        
        /* Save data to database. */
        _zer0netDb.setBytes(dataId, _permissions);

        /* Broadcast event. */
        emit Permissions(_owner, _delegate, _permissions);

        /* Return success. */
        return true;
    }
    
    /**
     * Set Respect
     */
    function _setRespect(
        address _owner,
        address _peer,
        uint _respect
    ) private returns (bool success) {
        /* Validate respect. */
        if (_respect == 0) {
            revert('Oops! Your respect is TOO LOW.');
        }

        /* Validate respect. */
        if (_respect > 5) {
            revert('Oops! Your respect is TOO MUCH.');
        }

        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _owner, 
            '.respect.for.', 
            _peer
        ));
        
        /* Save data to database. */
        _zer0netDb.setUint(dataId, _respect);

        /* Broadcast event. */
        emit Respect(
            _owner,
            _peer, 
            _respect
        );
        
        /* Return success. */
        return true;
    }
    
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
        /* Initialize hash. */
        bytes32 hash = keccak256('aname.ecrecovery');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        ecrecovery = ECRecovery(aname);
    }

    /**
     * ZeroCache Interface
     *
     * Retrieves the current ZeroCache interface,
     * using the aname record from Zer0netDb.
     */
    function _zeroCache() private view returns (
        ZeroCacheInterface zeroCache
    ) {
        /* Initialize hash. */
        bytes32 hash = keccak256('aname.zerocache');

        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);

        /* Initialize interface. */
        zeroCache = ZeroCacheInterface(aname);
    }


    /***************************************************************************
     * 
     * UTILITIES
     * 
     */

    /**
     * Validate Signature
     */
    function _validateSignature(
        string _nametag,
        bytes32 _sigHash,
        bytes _signature
    ) private view returns (bool authorized) {
        /* Calculate owner hash. */
        bytes32 ownerHash = keccak256(abi.encodePacked(
            _namespace, '.',
            _nametag,
            '.owner'
        ));

        /* Retrieve nametag owner. */
        address nametagOwner = _zer0netDb.getAddress(ownerHash);

        /* Calculate signature hash. */
        bytes32 sigHash = keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', _sigHash));

        /* Retrieve the authorized signer. */
        address signer = 
            _ecRecovery().recover(sigHash, _signature);
        
        /* Validate signer. */
        authorized = (signer == nametagOwner);
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
    function _bytesToAddress(
        bytes _address
    ) private pure returns (address) {
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
     * Convert Bytes to Bytes32
     */
    function _bytesToBytes32(
        bytes _data,
        uint _offset
    ) private pure returns (bytes32 result) {
        /* Loop through each byte. */
        for (uint i = 0; i < 32; i++) {
            /* Shift bytes onto result. */
            result |= bytes32(_data[i + _offset] & 0xFF) >> (i * 8);
        }
    }
    
    /**
     * Convert Bytes32 to Bytes
     * 
     * NOTE: Since solidity v0.4.22, you can use `abi.encodePacked()` for this, 
     *       which returns bytes. (https://ethereum.stackexchange.com/a/55963)
     */
    function _bytes32ToBytes(
        bytes32 _data
    ) private pure returns (bytes result) {
        /* Pack the data. */
        return abi.encodePacked(_data);
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