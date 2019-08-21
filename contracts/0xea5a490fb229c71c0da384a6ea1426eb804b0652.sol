pragma solidity ^0.4.24;

/*******************************************************************************
 *
 * Copyright (c) 2018 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * Zitetags - A Zeronet registrar, for managing Namecoin (.bit) addresses used 
 *            by Zeronet users/clients to simplify addressing of requested 
 *            zites (0net websites), by NOT having to enter the full 
 *            Bitcoin (address) public key.
 * 
 *            For example, D14na's zite has a Bitcoin public key of
 *            [ 1D14naQY4s65YR6xrJDBHk9ufj2eLbK49C ], but can be referenced 
 *            using any of the following zitetag variations:
 *                1. d14na
 *                2. #d14na
 *                3. d14na.bit
 * 
 *            NOTE: The following prefixes may sometimes be applied:
 *                      1. zero://
 *                      2. http://127.0.0.1:43110/
 *                      3. https://0net.io/
 *               
 *
 * Version 18.10.21
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
 * @notice Zitetags Registrar Contract.
 *
 * @dev Zitetags are Namecoin (.bit) addresses that are used
 *      (similar to Twitter hashtags and traditional domain names) as a
 *      convenient alternative to users/clients when entering a 
 *      zite's Bitcoin public key.
 */
contract Zitetags is Owned {
    using SafeMath for uint;

    /* Initialize version number. */
    uint public version;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface public zer0netDb;

    /* Initialize zitetag update notification/log event. */
    event ZitetagUpdate(
        bytes32 indexed zitetagId, 
        string zitetag, 
        string info
    );

    /* Constructor. */
    constructor() public {
        /* Set the version number. */
        version = now;

        /* Initialize Zer0netDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);
    }

    /**
     * @dev Only allow access to an authorized Zer0net administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(zer0netDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.zitetags'))) == true);

        _;      // function code is inserted here
    }

    /**
     * @notice Retrieves the registration info for the given zitetag.
     * 
     * @dev Use the calculated hash to query the eternal database 
     *      for the `_zitetag` info.
     */
    function getInfo(string _zitetag) external view returns (string) {
        /* Calculate the zitetag's hash. */
        bytes32 hash = keccak256(abi.encodePacked('zitetag.', _zitetag));
        
        /* Retrieve the zitetag's info. */
        string memory info = zer0netDb.getString(hash);

        /* Return info. */
        return (info);
    }

    /**
     * @notice Set the zitetag's registration info.
     * 
     * @dev Calculate the `_zitetag` hash and use it to store the
     *      registration details in the eternal database.
     * 
     *      NOTE: JSON will be the object type for registration details.
     */
    function setInfo(
        string _zitetag, 
        string _info
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate the zitetag's hash. */
        bytes32 hash = keccak256(abi.encodePacked('zitetag.', _zitetag));
        
        /* Set the zitetag's info. */
        zer0netDb.setString(hash, _info);

        /* Emit event notification. */
        emit ZitetagUpdate(hash, _zitetag, _info);

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