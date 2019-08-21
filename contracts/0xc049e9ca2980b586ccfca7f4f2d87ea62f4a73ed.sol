pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * ZeroFilters - A crowd-sourced database of "malicious / suspicious" endpoints
 *               as reported by "trusted" users within the community.
 *
 *               List of Currently Supported Filters*
 *               -----------------------------------
 *
 *                   1. ABUSE
 *                      - animal | animals
 *                      - child | children
 *                      - man | men
 *                      - woman | women
 *
 *                   2. HARASSMENT
 *                      - bullying
 *
 *                   3. REVENGE
 *                      - porn
 *
 *                   4. TERRORISM
 *                      - ISIS
 *
 *               * This is NOT a complete listing of ALL content violations.
 *                 We are continuing to work along with the community in
 *                 sculpting a transparent and comprehensive package of
 *                 acceptable resource usage.
 *
 * Version 19.3.11
 *
 * https://d14na.org
 * support@d14na.org
 */


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
 * @notice ZeroFilters
 *
 * @dev A key-value store.
 */
contract ZeroFilters is Owned {
    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;

    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /* Set namespace. */
    string _NAMESPACE = 'zerofilters';

    event Filter(
        bytes32 indexed dataId,
        bytes metadata
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
            uint lastRevision = ZeroFilters(_predecessor).getRevision();

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
            abi.encodePacked(msg.sender, '.has.auth.for.zerofilters'))) == true);

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
     * Calculate Data Id by Hash
     */
    function calcIdByHash(
        bytes32 _hash
    ) public view returns (bytes32 dataId) {
        /* Calculate the data id. */
        dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hash.', _hash));
    }

    /**
     * Calculate Data Id by Hostname
     */
    function calcIdByHostname(
        string _hostname
    ) external view returns (bytes32 dataId) {
        /* Calculate the data id. */
        dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hostname.', _hostname));
    }

    /**
     * Calculate Data Id by Owner
     */
    function calcIdByOwner(
        address _owner
    ) external view returns (bytes32 dataId) {
        /* Calculate the data id. */
        dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.owner.', _owner));
    }

    /**
     * Calculate Data Id by Regular Expression
     */
    function calcIdByRegex(
        string _regex
    ) external view returns (bytes32 dataId) {
        /* Calculate the data id. */
        dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.regex.', _regex));
    }


    /***************************************************************************
     *
     * GETTERS
     *
     */

    /**
     * Get Info
     */
    function getInfo(
        bytes32 _dataId
    ) external view returns (bytes info) {
        /* Return info. */
        return _getInfo(_dataId);
    }

    /**
     * Get Info by Hash
     */
    function getInfoByHash(
        bytes32 _hash
    ) external view returns (bytes info) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hash.', _hash));

        /* Return info. */
        return _getInfo(dataId);
    }

    /**
     * Get Info by Hostname
     */
    function getInfoByHostname(
        string _hostname
    ) external view returns (bytes info) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hostname.', _hostname));

        /* Return info. */
        return _getInfo(dataId);
    }

    /**
     * Get Info by Owner
     */
    function getInfoByOwner(
        address _owner
    ) external view returns (bytes info) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.owner.', _owner));

        /* Return info. */
        return _getInfo(dataId);
    }

    /**
     * Get Info by Regular Expression
     */
    function getInfoByRegex(
        string _regex
    ) external view returns (bytes info) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.regex.', _regex));

        /* Return info. */
        return _getInfo(dataId);
    }

    /**
     * Get Info
     *
     * Retrieves the JSON-formatted, byte-encoded data stored at
     * the location of `_dataId`.
     */
    function _getInfo(
        bytes32 _dataId
    ) private view returns (bytes info) {
        /* Retrieve info. */
        info = _zer0netDb.getBytes(_dataId);
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
     * Set Info by Hash
     */
    function setInfoByHash(
        bytes32 _hash,
        bytes _data
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hash.', _hash));

        /* Set info. */
        return _setInfo(dataId, _data);
    }

    /**
     * Set Info by Hostname
     */
    function setInfoByHostname(
        string _hostname,
        bytes _data
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.hostname.', _hostname));

        /* Set info. */
        return _setInfo(dataId, _data);
    }

    /**
     * Set Info by Owner
     */
    function setInfoByOwner(
        address _owner,
        bytes _data
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.owner.', _owner));

        /* Set info. */
        return _setInfo(dataId, _data);
    }

    /**
     * Set Info by Regular Expression
     */
    function setInfoByRegex(
        string _regex,
        bytes _data
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate the data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _NAMESPACE, '.regex.', _regex));

        /* Set info. */
        return _setInfo(dataId, _data);
    }

    /**
     * Set Info
     *
     * JSON-formatted data, encoded into bytes.
     */
    function _setInfo(
        bytes32 _dataId,
        bytes _data
    ) private returns (bool success) {
        /* Set data. */
        _zer0netDb.setBytes(_dataId, _data);

        /* Broadcast event. */
        emit Filter(_dataId, _data);

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


    /***************************************************************************
     *
     * UTILITIES
     *
     */

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