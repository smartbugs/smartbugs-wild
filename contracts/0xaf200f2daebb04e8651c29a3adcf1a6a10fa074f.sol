pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath128 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint128 a, uint128 b) internal pure returns (uint128 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath64 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint64 a, uint64 b) internal pure returns (uint64 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath32 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint32 a, uint32 b) internal pure returns (uint32 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath16 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint16 a, uint16 b) internal pure returns (uint16 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath8 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     *  as the code is not actually created until after the constructor finishes.
     * @param addr address to check
     * @return whether the target address is a contract
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
        return size > 0;
    }

}


/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 *
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 *
 */

library ECRecovery {

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        //Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

}

contract MintibleUtility is Ownable {
    using SafeMath     for uint256;
    using SafeMath128  for uint128;
    using SafeMath64   for uint64;
    using SafeMath32   for uint32;
    using SafeMath16   for uint16;
    using SafeMath8    for uint8;
    using AddressUtils for address;
    using ECRecovery   for bytes32;

    uint256 private nonce;

    bool public paused;

    modifier notPaused() {
        require(!paused);
        _;
    }

    /*
     * @dev Uses binary search to find the index of the off given
     */
    function getIndexFromOdd(uint32 _odd, uint32[] _odds) internal pure returns (uint) {
        uint256 low = 0;
        uint256 high = _odds.length.sub(1);

        while (low < high) {
            uint256 mid = (low.add(high)) / 2;
            if (_odd >= _odds[mid]) {
                low = mid.add(1);
            } else {
                high = mid;
            }
        }

        return low;
    }

    /*
     * Using the `nonce` and a range, it generates a random value using `keccak256` and random distribution
     */
    function rand(uint32 min, uint32 max) internal returns (uint32) {
        nonce++;
        return uint32(keccak256(abi.encodePacked(nonce, uint(blockhash(block.number.sub(1)))))) % (min.add(max)).sub(min);
    }


    /*
     *  Sub array utility functions
     */

    function getUintSubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint256[]) {
        uint256[] memory ret = new uint256[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = _arr[i];
        }

        return ret;
    }

    function getUint32SubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint32[]) {
        uint32[] memory ret = new uint32[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = uint32(_arr[i]);
        }

        return ret;
    }

    function getUint64SubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint64[]) {
        uint64[] memory ret = new uint64[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = uint64(_arr[i]);
        }

        return ret;
    }
}

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public;
}

/*
 * An interface extension of ERC721
 */
contract MintibleI is ERC721 {
    function getLastModifiedNonce(uint256 _id) public view returns (uint);
    function payFee(uint256 _id) public payable;
}

/**
 * This contract assumes that it was approved beforehand
 */
contract MintibleMarketplace is MintibleUtility {

    event EtherOffer(address from, address to, address contractAddress, uint256 id, uint256 price);
    event InvalidateSignature(bytes signature);

    mapping(bytes32 => bool) public consumed;
    mapping(address => bool) public implementsMintibleInterface;

    /*
     * @dev Function that verifies that `_contractAddress` implements the `MintibleI`
     */
    function setImplementsMintibleInterface(address _contractAddress) public notPaused {
        require(isPayFeeSafe(_contractAddress) && isGetLastModifiedNonceSafe(_contractAddress));

        implementsMintibleInterface[_contractAddress] = true;
    }

    /*
     * @dev This function consumes a signature to buy an item for ether
     */
    function consumeEtherOffer(
        address _from,
        address _contractAddress,
        uint256 _id,
        uint256 _expiryBlock,
        uint128 _uuid,
        bytes   _signature
    ) public payable notPaused {

        uint itemNonce;

        if (implementsMintibleInterface[_contractAddress]) {
            itemNonce = MintibleI(_contractAddress).getLastModifiedNonce(_id);
        }

        bytes32 hash = keccak256(abi.encodePacked(address(this), _contractAddress, _id, msg.value, _expiryBlock, _uuid, itemNonce));

        // Ensure this hash wasn't already consumed
        require(!consumed[hash]);
        consumed[hash] = true;

        validateConsumedHash(_from, hash, _signature);

        // Verify the expiration date of the signature
        require(block.number < _expiryBlock);

        // 1% marketplace fee
        uint256 marketplaceFee = msg.value.mul(10 finney) / 1 ether;
        // 2.5% creator fee
        uint256 creatorFee = msg.value.mul(25 finney) / 1 ether;
        // How much the seller receives
        uint256 amountReceived = msg.value.sub(marketplaceFee);

        // Transfer token to buyer
        MintibleI(_contractAddress).transferFrom(_from, msg.sender, _id);

        // Increase balance of creator if contract implements MintibleI
        if (implementsMintibleInterface[_contractAddress]) {
            amountReceived = amountReceived.sub(creatorFee);

            MintibleI(_contractAddress).payFee.value(creatorFee)(_id);
        }

        // Transfer funds to seller
        _from.transfer(amountReceived);

        emit EtherOffer(_from, msg.sender, _contractAddress, _id, msg.value);
    }

    // Sets a hash
    function invalidateSignature(bytes32 _hash, bytes _signature) public notPaused {

        bytes32 signedHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', _hash));
        require(signedHash.recover(_signature) == msg.sender);
        consumed[_hash] = true;

        emit InvalidateSignature(_signature);
    }

    /*
     * @dev Transfer `address(this).balance` to `owner`
     */
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    /*
     * @dev This function validates that the `_hash` and `_signature` match the `_signer`
     */
    function validateConsumedHash(address _signer, bytes32 _hash, bytes _signature) private pure {
        bytes32 signedHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', _hash));

        // Verify signature validity
        require(signedHash.recover(_signature) == _signer);
    }

    /*
     * Function that verifies whether `payFee(uint256)` was implemented at the given address
     */
    function isPayFeeSafe(address _addr)
        private
        returns (bool _isImplemented)
    {
        bytes32 sig = bytes4(keccak256("payFee(uint256)"));

        assembly {
            let x := mload(0x40)    // get free memory
            mstore(x, sig)          // store signature into it
            mstore(add(x, 0x04), 1) // Send an id of 1 only for testing purposes

            let _success := call(
                20000,   // 20000 gas is the exact value needed for this call
                _addr,  // to _addr
                0,      // 0 value
                x,      // input is x
                0x24,   // input length is 4 + 32 bytes
                x,      // store output to x
                0x0     // No output
            )

            _isImplemented := _success
        }
    }

    /*
     * Function that verifies whether `payFee(uint256)` was implemented at the given address
     */
    function isGetLastModifiedNonceSafe(address _addr)
        private
        returns (bool _isImplemented)
    {
        bytes32 sig = bytes4(keccak256("getLastModifiedNonce(uint256)"));

        assembly {
            let x := mload(0x40)    // get free memory
            mstore(x, sig)          // store signature into it
            mstore(add(x, 0x04), 1) // Send an id of 1 only for testing purposes

            let _success := call(
                20000,  // 20000 gas is the exact value needed for this call
                _addr,  // to _addr
                0,      // 0 value
                x,      // input is x
                0x24,   // input length is 4 + 32 bytes
                x,      // store output to x
                0x0     // No output
            )

            _isImplemented := _success
        }
    }
}