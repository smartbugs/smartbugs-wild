pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract SyscoinDepositsManager {

    using SafeMath for uint;

    mapping(address => uint) public deposits;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

    // @dev – fallback to calling makeDeposit when ether is sent directly to contract.
    function() public payable {
        makeDeposit();
    }

    // @dev – returns an account's deposit
    // @param who – the account's address.
    // @return – the account's deposit.
    function getDeposit(address who) constant public returns (uint) {
        return deposits[who];
    }

    // @dev – allows a user to deposit eth.
    // @return – sender's updated deposit amount.
    function makeDeposit() public payable returns (uint) {
        increaseDeposit(msg.sender, msg.value);
        return deposits[msg.sender];
    }

    // @dev – increases an account's deposit.
    // @return – the given user's updated deposit amount.
    function increaseDeposit(address who, uint amount) internal {
        deposits[who] = deposits[who].add(amount);
        require(deposits[who] <= address(this).balance);

        emit DepositMade(who, amount);
    }

    // @dev – allows a user to withdraw eth from their deposit.
    // @param amount – how much eth to withdraw
    // @return – sender's updated deposit amount.
    function withdrawDeposit(uint amount) public returns (uint) {
        require(deposits[msg.sender] >= amount);

        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit DepositWithdrawn(msg.sender, amount);
        return deposits[msg.sender];
    }
}

// Interface contract to be implemented by SyscoinToken
contract SyscoinTransactionProcessor {
    function processTransaction(uint txHash, uint value, address destinationAddress, uint32 _assetGUID, address superblockSubmitterAddress) public returns (uint);
    function burn(uint _value, uint32 _assetGUID, bytes syscoinWitnessProgram) payable public returns (bool success);
}

// Bitcoin transaction parsing library - modified for SYSCOIN

// Copyright 2016 rain <https://keybase.io/rain>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// https://en.bitcoin.it/wiki/Protocol_documentation#tx
//
// Raw Bitcoin transaction structure:
//
// field     | size | type     | description
// version   | 4    | int32    | transaction version number
// n_tx_in   | 1-9  | var_int  | number of transaction inputs
// tx_in     | 41+  | tx_in[]  | list of transaction inputs
// n_tx_out  | 1-9  | var_int  | number of transaction outputs
// tx_out    | 9+   | tx_out[] | list of transaction outputs
// lock_time | 4    | uint32   | block number / timestamp at which tx locked
//
// Transaction input (tx_in) structure:
//
// field      | size | type     | description
// previous   | 36   | outpoint | Previous output transaction reference
// script_len | 1-9  | var_int  | Length of the signature script
// sig_script | ?    | uchar[]  | Script for confirming transaction authorization
// sequence   | 4    | uint32   | Sender transaction version
//
// OutPoint structure:
//
// field      | size | type     | description
// hash       | 32   | char[32] | The hash of the referenced transaction
// index      | 4    | uint32   | The index of this output in the referenced transaction
//
// Transaction output (tx_out) structure:
//
// field         | size | type     | description
// value         | 8    | int64    | Transaction value (Satoshis)
// pk_script_len | 1-9  | var_int  | Length of the public key script
// pk_script     | ?    | uchar[]  | Public key as a Bitcoin script.
//
// Variable integers (var_int) can be encoded differently depending
// on the represented value, to save space. Variable integers always
// precede an array of a variable length data type (e.g. tx_in).
//
// Variable integer encodings as a function of represented value:
//
// value           | bytes  | format
// <0xFD (253)     | 1      | uint8
// <=0xFFFF (65535)| 3      | 0xFD followed by length as uint16
// <=0xFFFF FFFF   | 5      | 0xFE followed by length as uint32
// -               | 9      | 0xFF followed by length as uint64
//
// Public key scripts `pk_script` are set on the output and can
// take a number of forms. The regular transaction script is
// called 'pay-to-pubkey-hash' (P2PKH):
//
// OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
//
// OP_x are Bitcoin script opcodes. The bytes representation (including
// the 0x14 20-byte stack push) is:
//
// 0x76 0xA9 0x14 <pubKeyHash> 0x88 0xAC
//
// The <pubKeyHash> is the ripemd160 hash of the sha256 hash of
// the public key, preceded by a network version byte. (21 bytes total)
//
// Network version bytes: 0x00 (mainnet); 0x6f (testnet); 0x34 (namecoin)
//
// The Bitcoin address is derived from the pubKeyHash. The binary form is the
// pubKeyHash, plus a checksum at the end.  The checksum is the first 4 bytes
// of the (32 byte) double sha256 of the pubKeyHash. (25 bytes total)
// This is converted to base58 to form the publicly used Bitcoin address.
// Mainnet P2PKH transaction scripts are to addresses beginning with '1'.
//
// P2SH ('pay to script hash') scripts only supply a script hash. The spender
// must then provide the script that would allow them to redeem this output.
// This allows for arbitrarily complex scripts to be funded using only a
// hash of the script, and moves the onus on providing the script from
// the spender to the redeemer.
//
// The P2SH script format is simple:
//
// OP_HASH160 <scriptHash> OP_EQUAL
//
// 0xA9 0x14 <scriptHash> 0x87
//
// The <scriptHash> is the ripemd160 hash of the sha256 hash of the
// redeem script. The P2SH address is derived from the scriptHash.
// Addresses are the scriptHash with a version prefix of 5, encoded as
// Base58check. These addresses begin with a '3'.



// parse a raw Syscoin transaction byte array
library SyscoinMessageLibrary {

    uint constant p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;  // secp256k1
    uint constant q = (p + 1) / 4;

    // Error codes
    uint constant ERR_INVALID_HEADER = 10050;
    uint constant ERR_COINBASE_INDEX = 10060; // coinbase tx index within Litecoin merkle isn't 0
    uint constant ERR_NOT_MERGE_MINED = 10070; // trying to check AuxPoW on a block that wasn't merge mined
    uint constant ERR_FOUND_TWICE = 10080; // 0xfabe6d6d found twice
    uint constant ERR_NO_MERGE_HEADER = 10090; // 0xfabe6d6d not found
    uint constant ERR_NOT_IN_FIRST_20 = 10100; // chain Merkle root isn't in the first 20 bytes of coinbase tx
    uint constant ERR_CHAIN_MERKLE = 10110;
    uint constant ERR_PARENT_MERKLE = 10120;
    uint constant ERR_PROOF_OF_WORK = 10130;
    uint constant ERR_INVALID_HEADER_HASH = 10140;
    uint constant ERR_PROOF_OF_WORK_AUXPOW = 10150;
    uint constant ERR_PARSE_TX_OUTPUT_LENGTH = 10160;
    uint constant ERR_PARSE_TX_SYS = 10170;
    enum Network { MAINNET, TESTNET, REGTEST }
    uint32 constant SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN = 0x7407;
    uint32 constant SYSCOIN_TX_VERSION_BURN = 0x7401;
    // AuxPoW block fields
    struct AuxPoW {
        uint blockHash;

        uint txHash;

        uint coinbaseMerkleRoot; // Merkle root of auxiliary block hash tree; stored in coinbase tx field
        uint[] chainMerkleProof; // proves that a given Syscoin block hash belongs to a tree with the above root
        uint syscoinHashIndex; // index of Syscoin block hash within block hash tree
        uint coinbaseMerkleRootCode; // encodes whether or not the root was found properly

        uint parentMerkleRoot; // Merkle root of transaction tree from parent Litecoin block header
        uint[] parentMerkleProof; // proves that coinbase tx belongs to a tree with the above root
        uint coinbaseTxIndex; // index of coinbase tx within Litecoin tx tree

        uint parentNonce;
    }

    // Syscoin block header stored as a struct, mostly for readability purposes.
    // BlockHeader structs can be obtained by parsing a block header's first 80 bytes
    // with parseHeaderBytes.
    struct BlockHeader {
        uint32 bits;
        uint blockHash;
    }
    // Convert a variable integer into something useful and return it and
    // the index to after it.
    function parseVarInt(bytes memory txBytes, uint pos) private pure returns (uint, uint) {
        // the first byte tells us how big the integer is
        uint8 ibit = uint8(txBytes[pos]);
        pos += 1;  // skip ibit

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }
    // convert little endian bytes to uint
    function getBytesLE(bytes memory data, uint pos, uint bits) internal pure returns (uint) {
        if (bits == 8) {
            return uint8(data[pos]);
        } else if (bits == 16) {
            return uint16(data[pos])
                 + uint16(data[pos + 1]) * 2 ** 8;
        } else if (bits == 32) {
            return uint32(data[pos])
                 + uint32(data[pos + 1]) * 2 ** 8
                 + uint32(data[pos + 2]) * 2 ** 16
                 + uint32(data[pos + 3]) * 2 ** 24;
        } else if (bits == 64) {
            return uint64(data[pos])
                 + uint64(data[pos + 1]) * 2 ** 8
                 + uint64(data[pos + 2]) * 2 ** 16
                 + uint64(data[pos + 3]) * 2 ** 24
                 + uint64(data[pos + 4]) * 2 ** 32
                 + uint64(data[pos + 5]) * 2 ** 40
                 + uint64(data[pos + 6]) * 2 ** 48
                 + uint64(data[pos + 7]) * 2 ** 56;
        }
    }
    

    // @dev - Parses a syscoin tx
    //
    // @param txBytes - tx byte array
    // Outputs
    // @return output_value - amount sent to the lock address in satoshis
    // @return destinationAddress - ethereum destination address


    function parseTransaction(bytes memory txBytes) internal pure
             returns (uint, uint, address, uint32)
    {
        
        uint output_value;
        uint32 assetGUID;
        address destinationAddress;
        uint32 version;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN && version != SYSCOIN_TX_VERSION_BURN){
            return (ERR_PARSE_TX_SYS, output_value, destinationAddress, assetGUID);
        }
        pos = skipInputs(txBytes, 4);
            
        (output_value, destinationAddress, assetGUID) = scanBurns(txBytes, version, pos);
        return (0, output_value, destinationAddress, assetGUID);
    }


  
    // skips witnesses and saves first script position/script length to extract pubkey of first witness scriptSig
    function skipWitnesses(bytes memory txBytes, uint pos, uint n_inputs) private pure
             returns (uint)
    {
        uint n_stack;
        (n_stack, pos) = parseVarInt(txBytes, pos);
        
        uint script_len;
        for (uint i = 0; i < n_inputs; i++) {
            for (uint j = 0; j < n_stack; j++) {
                (script_len, pos) = parseVarInt(txBytes, pos);
                pos += script_len;
            }
        }

        return n_stack;
    }    

    function skipInputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_inputs;
        uint script_len;
        (n_inputs, pos) = parseVarInt(txBytes, pos);
        // if dummy 0x00 is present this is a witness transaction
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); // flag
            assert(n_inputs != 0x00);
            // after dummy/flag the real var int comes for txins
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs < 100);

        for (uint i = 0; i < n_inputs; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len + 4;  // skip sig_script, seq
        }

        return pos;
    }
             
    // scan the burn outputs and return the value and script data of first burned output.
    function scanBurns(bytes memory txBytes, uint32 version, uint pos) private pure
             returns (uint, address, uint32)
    {
        uint script_len;
        uint output_value;
        uint32 assetGUID = 0;
        address destinationAddress;
        uint n_outputs;
        (n_outputs, pos) = parseVarInt(txBytes, pos);
        require(n_outputs < 10);
        for (uint i = 0; i < n_outputs; i++) {
            // output
            if(version == SYSCOIN_TX_VERSION_BURN){
                output_value = getBytesLE(txBytes, pos, 64);
            }
            pos += 8;
            // varint
            (script_len, pos) = parseVarInt(txBytes, pos);
            if(!isOpReturn(txBytes, pos)){
                // output script
                pos += script_len;
                output_value = 0;
                continue;
            }
            // skip opreturn marker
            pos += 1;
            if(version == SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN){
                (output_value, destinationAddress, assetGUID) = scanAssetDetails(txBytes, pos);
            }
            else if(version == SYSCOIN_TX_VERSION_BURN){                
                destinationAddress = scanSyscoinDetails(txBytes, pos);   
            }
            // only one opreturn data allowed per transaction
            break;
        }

        return (output_value, destinationAddress, assetGUID);
    }

    function skipOutputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_outputs;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        require(n_outputs < 10);

        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len;
        }

        return pos;
    }
    // get final position of inputs, outputs and lock time
    // this is a helper function to slice a byte array and hash the inputs, outputs and lock time
    function getSlicePos(bytes memory txBytes, uint pos) private pure
             returns (uint slicePos)
    {
        slicePos = skipInputs(txBytes, pos + 4);
        slicePos = skipOutputs(txBytes, slicePos);
        slicePos += 4; // skip lock time
    }
    // scan a Merkle branch.
    // return array of values and the end position of the sibling hashes.
    // takes a 'stop' argument which sets the maximum number of
    // siblings to scan through. stop=0 => scan all.
    function scanMerkleBranch(bytes memory txBytes, uint pos, uint stop) private pure
             returns (uint[], uint)
    {
        uint n_siblings;
        uint halt;

        (n_siblings, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_siblings) {
            halt = n_siblings;
        } else {
            halt = stop;
        }

        uint[] memory sibling_values = new uint[](halt);

        for (uint i = 0; i < halt; i++) {
            sibling_values[i] = flip32Bytes(sliceBytes32Int(txBytes, pos));
            pos += 32;
        }

        return (sibling_values, pos);
    }   
    // Slice 20 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes20(bytes memory data, uint start) private pure returns (bytes20) {
        uint160 slice = 0;
        // FIXME: With solc v0.4.24 and optimizations enabled
        // using uint160 for index i will generate an error
        // "Error: VM Exception while processing transaction: Error: redPow(normalNum)"
        for (uint i = 0; i < 20; i++) {
            slice += uint160(data[i + start]) << (8 * (19 - i));
        }
        return bytes20(slice);
    }
    // Slice 32 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes32Int(bytes memory data, uint start) private pure returns (uint slice) {
        for (uint i = 0; i < 32; i++) {
            if (i + start < data.length) {
                slice += uint(data[i + start]) << (8 * (31 - i));
            }
        }
    }

    // @dev returns a portion of a given byte array specified by its starting and ending points
    // Should be private, made internal for testing
    // Breaks underscore naming convention for parameters because it raises a compiler error
    // if `offset` is changed to `_offset`.
    //
    // @param _rawBytes - array to be sliced
    // @param offset - first byte of sliced array
    // @param _endIndex - last byte of sliced array
    function sliceArray(bytes memory _rawBytes, uint offset, uint _endIndex) internal view returns (bytes) {
        uint len = _endIndex - offset;
        bytes memory result = new bytes(len);
        assembly {
            // Call precompiled contract to copy data
            if iszero(staticcall(gas, 0x04, add(add(_rawBytes, 0x20), offset), len, add(result, 0x20), len)) {
                revert(0, 0)
            }
        }
        return result;
    }
    
    
    // Returns true if the tx output is an OP_RETURN output
    function isOpReturn(bytes memory txBytes, uint pos) private pure
             returns (bool) {
        // scriptPub format is
        // 0x6a OP_RETURN
        return 
            txBytes[pos] == byte(0x6a);
    }
    // Returns syscoin data parsed from the op_return data output from syscoin burn transaction
    function scanSyscoinDetails(bytes memory txBytes, uint pos) private pure
             returns (address) {      
        uint8 op;
        (op, pos) = getOpcode(txBytes, pos);
        // ethereum addresses are 20 bytes (without the 0x)
        require(op == 0x14);
        return readEthereumAddress(txBytes, pos);
    }    
    // Returns asset data parsed from the op_return data output from syscoin asset burn transaction
    function scanAssetDetails(bytes memory txBytes, uint pos) private pure
             returns (uint, address, uint32) {
                 
        uint32 assetGUID;
        address destinationAddress;
        uint output_value;
        uint8 op;
        // vchAsset
        (op, pos) = getOpcode(txBytes, pos);
        // guid length should be 4 bytes
        require(op == 0x04);
        assetGUID = bytesToUint32(txBytes, pos);
        pos += op;
        // amount
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x08);
        output_value = bytesToUint64(txBytes, pos);
        pos += op;
         // destination address
        (op, pos) = getOpcode(txBytes, pos);
        // ethereum contracts are 20 bytes (without the 0x)
        require(op == 0x14);
        destinationAddress = readEthereumAddress(txBytes, pos);       
        return (output_value, destinationAddress, assetGUID);
    }         
    // Read the ethereum address embedded in the tx output
    function readEthereumAddress(bytes memory txBytes, uint pos) private pure
             returns (address) {
        uint256 data;
        assembly {
            data := mload(add(add(txBytes, 20), pos))
        }
        return address(uint160(data));
    }

    // Read next opcode from script
    function getOpcode(bytes memory txBytes, uint pos) private pure
             returns (uint8, uint)
    {
        require(pos < txBytes.length);
        return (uint8(txBytes[pos]), pos + 1);
    }

    // @dev - convert an unsigned integer from little-endian to big-endian representation
    //
    // @param _input - little-endian value
    // @return - input value in big-endian format
    function flip32Bytes(uint _input) internal pure returns (uint result) {
        assembly {
            let pos := mload(0x40)
            for { let i := 0 } lt(i, 32) { i := add(i, 1) } {
                mstore8(add(pos, i), byte(sub(31, i), _input))
            }
            result := mload(pos)
        }
    }
    // helpers for flip32Bytes
    struct UintWrapper {
        uint value;
    }

    function ptr(UintWrapper memory uw) private pure returns (uint addr) {
        assembly {
            addr := uw
        }
    }

    function parseAuxPoW(bytes memory rawBytes, uint pos) internal view
             returns (AuxPoW memory auxpow)
    {
        // we need to traverse the bytes with a pointer because some fields are of variable length
        pos += 80; // skip non-AuxPoW header
        uint slicePos;
        (slicePos) = getSlicePos(rawBytes, pos);
        auxpow.txHash = dblShaFlipMem(rawBytes, pos, slicePos - pos);
        pos = slicePos;
        // parent block hash, skip and manually hash below
        pos += 32;
        (auxpow.parentMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.coinbaseTxIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        (auxpow.chainMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.syscoinHashIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        // calculate block hash instead of reading it above, as some are LE and some are BE, we cannot know endianness and have to calculate from parent block header
        auxpow.blockHash = dblShaFlipMem(rawBytes, pos, 80);
        pos += 36; // skip parent version and prev block
        auxpow.parentMerkleRoot = sliceBytes32Int(rawBytes, pos);
        pos += 40; // skip root that was just read, parent block timestamp and bits
        auxpow.parentNonce = getBytesLE(rawBytes, pos, 32);
        uint coinbaseMerkleRootPosition;
        (auxpow.coinbaseMerkleRoot, coinbaseMerkleRootPosition, auxpow.coinbaseMerkleRootCode) = findCoinbaseMerkleRoot(rawBytes);
    }

    // @dev - looks for {0xfa, 0xbe, 'm', 'm'} byte sequence
    // returns the following 32 bytes if it appears once and only once,
    // 0 otherwise
    // also returns the position where the bytes first appear
    function findCoinbaseMerkleRoot(bytes memory rawBytes) private pure
             returns (uint, uint, uint)
    {
        uint position;
        bool found = false;

        for (uint i = 0; i < rawBytes.length; ++i) {
            if (rawBytes[i] == 0xfa && rawBytes[i+1] == 0xbe && rawBytes[i+2] == 0x6d && rawBytes[i+3] == 0x6d) {
                if (found) { // found twice
                    return (0, position - 4, ERR_FOUND_TWICE);
                } else {
                    found = true;
                    position = i + 4;
                }
            }
        }

        if (!found) { // no merge mining header
            return (0, position - 4, ERR_NO_MERGE_HEADER);
        } else {
            return (sliceBytes32Int(rawBytes, position), position - 4, 1);
        }
    }

    // @dev - Evaluate the merkle root
    //
    // Given an array of hashes it calculates the
    // root of the merkle tree.
    //
    // @return root of merkle tree
    function makeMerkle(bytes32[] hashes2) external pure returns (bytes32) {
        bytes32[] memory hashes = hashes2;
        uint length = hashes.length;
        if (length == 1) return hashes[0];
        require(length > 0);
        uint i;
        uint j;
        uint k;
        k = 0;
        while (length > 1) {
            k = 0;
            for (i = 0; i < length; i += 2) {
                j = i+1<length ? i+1 : length-1;
                hashes[k] = bytes32(concatHash(uint(hashes[i]), uint(hashes[j])));
                k += 1;
            }
            length = k;
        }
        return hashes[0];
    }

    // @dev - For a valid proof, returns the root of the Merkle tree.
    //
    // @param _txHash - transaction hash
    // @param _txIndex - transaction's index within the block it's assumed to be in
    // @param _siblings - transaction's Merkle siblings
    // @return - Merkle tree root of the block the transaction belongs to if the proof is valid,
    // garbage if it's invalid
    function computeMerkle(uint _txHash, uint _txIndex, uint[] memory _siblings) internal pure returns (uint) {
        uint resultHash = _txHash;
        uint i = 0;
        while (i < _siblings.length) {
            uint proofHex = _siblings[i];

            uint sideOfSiblings = _txIndex % 2;  // 0 means _siblings is on the right; 1 means left

            uint left;
            uint right;
            if (sideOfSiblings == 1) {
                left = proofHex;
                right = resultHash;
            } else if (sideOfSiblings == 0) {
                left = resultHash;
                right = proofHex;
            }

            resultHash = concatHash(left, right);

            _txIndex /= 2;
            i += 1;
        }

        return resultHash;
    }

    // @dev - calculates the Merkle root of a tree containing Litecoin transactions
    // in order to prove that `ap`'s coinbase tx is in that Litecoin block.
    //
    // @param _ap - AuxPoW information
    // @return - Merkle root of Litecoin block that the Syscoin block
    // with this info was mined in if AuxPoW Merkle proof is correct,
    // garbage otherwise
    function computeParentMerkle(AuxPoW memory _ap) internal pure returns (uint) {
        return flip32Bytes(computeMerkle(_ap.txHash,
                                         _ap.coinbaseTxIndex,
                                         _ap.parentMerkleProof));
    }

    // @dev - calculates the Merkle root of a tree containing auxiliary block hashes
    // in order to prove that the Syscoin block identified by _blockHash
    // was merge-mined in a Litecoin block.
    //
    // @param _blockHash - SHA-256 hash of a certain Syscoin block
    // @param _ap - AuxPoW information corresponding to said block
    // @return - Merkle root of auxiliary chain tree
    // if AuxPoW Merkle proof is correct, garbage otherwise
    function computeChainMerkle(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        return computeMerkle(_blockHash,
                             _ap.syscoinHashIndex,
                             _ap.chainMerkleProof);
    }

    // @dev - Helper function for Merkle root calculation.
    // Given two sibling nodes in a Merkle tree, calculate their parent.
    // Concatenates hashes `_tx1` and `_tx2`, then hashes the result.
    //
    // @param _tx1 - Merkle node (either root or internal node)
    // @param _tx2 - Merkle node (either root or internal node), has to be `_tx1`'s sibling
    // @return - `_tx1` and `_tx2`'s parent, i.e. the result of concatenating them,
    // hashing that twice and flipping the bytes.
    function concatHash(uint _tx1, uint _tx2) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(flip32Bytes(_tx1), flip32Bytes(_tx2)))))));
    }

    // @dev - checks if a merge-mined block's Merkle proofs are correct,
    // i.e. Syscoin block hash is in coinbase Merkle tree
    // and coinbase transaction is in parent Merkle tree.
    //
    // @param _blockHash - SHA-256 hash of the block whose Merkle proofs are being checked
    // @param _ap - AuxPoW struct corresponding to the block
    // @return 1 if block was merge-mined and coinbase index, chain Merkle root and Merkle proofs are correct,
    // respective error code otherwise
    function checkAuxPoW(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        if (_ap.coinbaseTxIndex != 0) {
            return ERR_COINBASE_INDEX;
        }

        if (_ap.coinbaseMerkleRootCode != 1) {
            return _ap.coinbaseMerkleRootCode;
        }

        if (computeChainMerkle(_blockHash, _ap) != _ap.coinbaseMerkleRoot) {
            return ERR_CHAIN_MERKLE;
        }

        if (computeParentMerkle(_ap) != _ap.parentMerkleRoot) {
            return ERR_PARENT_MERKLE;
        }

        return 1;
    }

    function sha256mem(bytes memory _rawBytes, uint offset, uint len) internal view returns (bytes32 result) {
        assembly {
            // Call sha256 precompiled contract (located in address 0x02) to copy data.
            // Assign to ptr the next available memory position (stored in memory position 0x40).
            let ptr := mload(0x40)
            if iszero(staticcall(gas, 0x02, add(add(_rawBytes, 0x20), offset), len, ptr, 0x20)) {
                revert(0, 0)
            }
            result := mload(ptr)
        }
    }

    // @dev - Bitcoin-way of hashing
    // @param _dataBytes - raw data to be hashed
    // @return - result of applying SHA-256 twice to raw data and then flipping the bytes
    function dblShaFlip(bytes _dataBytes) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(_dataBytes))))));
    }

    // @dev - Bitcoin-way of hashing
    // @param _dataBytes - raw data to be hashed
    // @return - result of applying SHA-256 twice to raw data and then flipping the bytes
    function dblShaFlipMem(bytes memory _rawBytes, uint offset, uint len) internal view returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256mem(_rawBytes, offset, len)))));
    }

    // @dev – Read a bytes32 from an offset in the byte array
    function readBytes32(bytes memory data, uint offset) internal pure returns (bytes32) {
        bytes32 result;
        assembly {
            result := mload(add(add(data, 0x20), offset))
        }
        return result;
    }

    // @dev – Read an uint32 from an offset in the byte array
    function readUint32(bytes memory data, uint offset) internal pure returns (uint32) {
        uint32 result;
        assembly {
            result := mload(add(add(data, 0x20), offset))
            
        }
        return result;
    }

    // @dev - Bitcoin-way of computing the target from the 'bits' field of a block header
    // based on http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html//ref3
    //
    // @param _bits - difficulty in bits format
    // @return - difficulty in target format
    function targetFromBits(uint32 _bits) internal pure returns (uint) {
        uint exp = _bits / 0x1000000;  // 2**24
        uint mant = _bits & 0xffffff;
        return mant * 256**(exp - 3);
    }

    uint constant SYSCOIN_DIFFICULTY_ONE = 0xFFFFF * 256**(0x1e - 3);

    // @dev - Calculate syscoin difficulty from target
    // https://en.bitcoin.it/wiki/Difficulty
    // Min difficulty for bitcoin is 0x1d00ffff
    // Min difficulty for syscoin is 0x1e0fffff
    function targetToDiff(uint target) internal pure returns (uint) {
        return SYSCOIN_DIFFICULTY_ONE / target;
    }
    

    // 0x00 version
    // 0x04 prev block hash
    // 0x24 merkle root
    // 0x44 timestamp
    // 0x48 bits
    // 0x4c nonce

    // @dev - extract previous block field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading hash from
    // @return - hash of block's parent in big endian format
    function getHashPrevBlock(bytes memory _blockHeader) internal pure returns (uint) {
        uint hashPrevBlock;
        assembly {
            hashPrevBlock := mload(add(add(_blockHeader, 32), 0x04))
        }
        return flip32Bytes(hashPrevBlock);
    }

    // @dev - extract Merkle root field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading root from
    // @return - block's Merkle root in big endian format
    function getHeaderMerkleRoot(bytes memory _blockHeader) public pure returns (uint) {
        uint merkle;
        assembly {
            merkle := mload(add(add(_blockHeader, 32), 0x24))
        }
        return flip32Bytes(merkle);
    }

    // @dev - extract timestamp field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading bits from
    // @return - block's timestamp in big-endian format
    function getTimestamp(bytes memory _blockHeader) internal pure returns (uint32 time) {
        return bytesToUint32Flipped(_blockHeader, 0x44);
    }

    // @dev - extract bits field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading bits from
    // @return - block's difficulty in bits format, also big-endian
    function getBits(bytes memory _blockHeader) internal pure returns (uint32 bits) {
        return bytesToUint32Flipped(_blockHeader, 0x48);
    }


    // @dev - converts raw bytes representation of a Syscoin block header to struct representation
    //
    // @param _rawBytes - first 80 bytes of a block header
    // @return - exact same header information in BlockHeader struct form
    function parseHeaderBytes(bytes memory _rawBytes, uint pos) internal view returns (BlockHeader bh) {
        bh.bits = getBits(_rawBytes);
        bh.blockHash = dblShaFlipMem(_rawBytes, pos, 80);
    }

    uint32 constant VERSION_AUXPOW = (1 << 8);

    // @dev - Converts a bytes of size 4 to uint32,
    // e.g. for input [0x01, 0x02, 0x03 0x04] returns 0x01020304
    function bytesToUint32Flipped(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(input[pos]) + uint32(input[pos + 1])*(2**8) + uint32(input[pos + 2])*(2**16) + uint32(input[pos + 3])*(2**24);
    }
    function bytesToUint64(bytes memory input, uint pos) internal pure returns (uint64 result) {
        result = uint64(input[pos+7]) + uint64(input[pos + 6])*(2**8) + uint64(input[pos + 5])*(2**16) + uint64(input[pos + 4])*(2**24) + uint64(input[pos + 3])*(2**32) + uint64(input[pos + 2])*(2**40) + uint64(input[pos + 1])*(2**48) + uint64(input[pos])*(2**56);
    }
     function bytesToUint32(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(input[pos+3]) + uint32(input[pos + 2])*(2**8) + uint32(input[pos + 1])*(2**16) + uint32(input[pos])*(2**24);
    }  
    // @dev - checks version to determine if a block has merge mining information
    function isMergeMined(bytes memory _rawBytes, uint pos) internal pure returns (bool) {
        return bytesToUint32Flipped(_rawBytes, pos) & VERSION_AUXPOW != 0;
    }

    // @dev - Verify block header
    // @param _blockHeaderBytes - array of bytes with the block header
    // @param _pos - starting position of the block header
	// @param _proposedBlockHash - proposed block hash computing from block header bytes
    // @return - [ErrorCode, IsMergeMined]
    function verifyBlockHeader(bytes _blockHeaderBytes, uint _pos, uint _proposedBlockHash) external view returns (uint, bool) {
        BlockHeader memory blockHeader = parseHeaderBytes(_blockHeaderBytes, _pos);
        uint blockSha256Hash = blockHeader.blockHash;
		// must confirm that the header hash passed in and computing hash matches
		if(blockSha256Hash != _proposedBlockHash){
			return (ERR_INVALID_HEADER_HASH, true);
		}
        uint target = targetFromBits(blockHeader.bits);
        if (_blockHeaderBytes.length > 80 && isMergeMined(_blockHeaderBytes, 0)) {
            AuxPoW memory ap = parseAuxPoW(_blockHeaderBytes, _pos);
            if (ap.blockHash > target) {

                return (ERR_PROOF_OF_WORK_AUXPOW, true);
            }
            uint auxPoWCode = checkAuxPoW(blockSha256Hash, ap);
            if (auxPoWCode != 1) {
                return (auxPoWCode, true);
            }
            return (0, true);
        } else {
            if (_proposedBlockHash > target) {
                return (ERR_PROOF_OF_WORK, false);
            }
            return (0, false);
        }
    }

    // For verifying Syscoin difficulty
    int64 constant TARGET_TIMESPAN =  int64(21600); 
    int64 constant TARGET_TIMESPAN_DIV_4 = TARGET_TIMESPAN / int64(4);
    int64 constant TARGET_TIMESPAN_MUL_4 = TARGET_TIMESPAN * int64(4);
    int64 constant TARGET_TIMESPAN_ADJUSTMENT =  int64(360);  // 6 hour
    uint constant INITIAL_CHAIN_WORK =  0x100001; 
    uint constant POW_LIMIT = 0x00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // @dev - Calculate difficulty from compact representation (bits) found in block
    function diffFromBits(uint32 bits) external pure returns (uint) {
        return targetToDiff(targetFromBits(bits))*INITIAL_CHAIN_WORK;
    }
    
    function difficultyAdjustmentInterval() external pure returns (int64) {
        return TARGET_TIMESPAN_ADJUSTMENT;
    }
    // @param _actualTimespan - time elapsed from previous block creation til current block creation;
    // i.e., how much time it took to mine the current block
    // @param _bits - previous block header difficulty (in bits)
    // @return - expected difficulty for the next block
    function calculateDifficulty(int64 _actualTimespan, uint32 _bits) external pure returns (uint32 result) {
       int64 actualTimespan = _actualTimespan;
        // Limit adjustment step
        if (_actualTimespan < TARGET_TIMESPAN_DIV_4) {
            actualTimespan = TARGET_TIMESPAN_DIV_4;
        } else if (_actualTimespan > TARGET_TIMESPAN_MUL_4) {
            actualTimespan = TARGET_TIMESPAN_MUL_4;
        }

        // Retarget
        uint bnNew = targetFromBits(_bits);
        bnNew = bnNew * uint(actualTimespan);
        bnNew = uint(bnNew) / uint(TARGET_TIMESPAN);

        if (bnNew > POW_LIMIT) {
            bnNew = POW_LIMIT;
        }

        return toCompactBits(bnNew);
    }

    // @dev - shift information to the right by a specified number of bits
    //
    // @param _val - value to be shifted
    // @param _shift - number of bits to shift
    // @return - `_val` shifted `_shift` bits to the right, i.e. divided by 2**`_shift`
    function shiftRight(uint _val, uint _shift) private pure returns (uint) {
        return _val / uint(2)**_shift;
    }

    // @dev - shift information to the left by a specified number of bits
    //
    // @param _val - value to be shifted
    // @param _shift - number of bits to shift
    // @return - `_val` shifted `_shift` bits to the left, i.e. multiplied by 2**`_shift`
    function shiftLeft(uint _val, uint _shift) private pure returns (uint) {
        return _val * uint(2)**_shift;
    }

    // @dev - get the number of bits required to represent a given integer value without losing information
    //
    // @param _val - unsigned integer value
    // @return - given value's bit length
    function bitLen(uint _val) private pure returns (uint length) {
        uint int_type = _val;
        while (int_type > 0) {
            int_type = shiftRight(int_type, 1);
            length += 1;
        }
    }

    // @dev - Convert uint256 to compact encoding
    // based on https://github.com/petertodd/python-bitcoinlib/blob/2a5dda45b557515fb12a0a18e5dd48d2f5cd13c2/bitcoin/core/serialize.py
    // Analogous to arith_uint256::GetCompact from C++ implementation
    //
    // @param _val - difficulty in target format
    // @return - difficulty in bits format
    function toCompactBits(uint _val) private pure returns (uint32) {
        uint nbytes = uint (shiftRight((bitLen(_val) + 7), 3));
        uint32 compact = 0;
        if (nbytes <= 3) {
            compact = uint32 (shiftLeft((_val & 0xFFFFFF), 8 * (3 - nbytes)));
        } else {
            compact = uint32 (shiftRight(_val, 8 * (nbytes - 3)));
            compact = uint32 (compact & 0xFFFFFF);
        }

        // If the sign bit (0x00800000) is set, divide the mantissa by 256 and
        // increase the exponent to get an encoding without it set.
        if ((compact & 0x00800000) > 0) {
            compact = uint32(shiftRight(compact, 8));
            nbytes += 1;
        }

        return compact | uint32(shiftLeft(nbytes, 24));
    }
}

// @dev - SyscoinSuperblocks error codes
contract SyscoinErrorCodes {
    // Error codes
    uint constant ERR_SUPERBLOCK_OK = 0;
    uint constant ERR_SUPERBLOCK_BAD_STATUS = 50020;
    uint constant ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS = 50025;
    uint constant ERR_SUPERBLOCK_NO_TIMEOUT = 50030;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP = 50035;
    uint constant ERR_SUPERBLOCK_INVALID_MERKLE = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT = 50050;
    uint constant ERR_SUPERBLOCK_OWN_CHALLENGE = 50055;

    uint constant ERR_SUPERBLOCK_MIN_DEPOSIT = 50060;

    uint constant ERR_SUPERBLOCK_NOT_CLAIMMANAGER = 50070;

    uint constant ERR_SUPERBLOCK_BAD_CLAIM = 50080;
    uint constant ERR_SUPERBLOCK_VERIFICATION_PENDING = 50090;
    uint constant ERR_SUPERBLOCK_CLAIM_DECIDED = 50100;
    uint constant ERR_SUPERBLOCK_BAD_CHALLENGER = 50110;

    uint constant ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK = 50120;
    uint constant ERR_SUPERBLOCK_BAD_BITS = 50130;
    uint constant ERR_SUPERBLOCK_MISSING_CONFIRMATIONS = 50140;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK = 50150;
    uint constant ERR_SUPERBLOCK_BAD_BLOCKHEIGHT = 50160;

    // error codes for verifyTx
    uint constant ERR_BAD_FEE = 20010;
    uint constant ERR_CONFIRMATIONS = 20020;
    uint constant ERR_CHAIN = 20030;
    uint constant ERR_SUPERBLOCK = 20040;
    uint constant ERR_MERKLE_ROOT = 20050;
    uint constant ERR_TX_64BYTE = 20060;
    // error codes for relayTx
    uint constant ERR_RELAY_VERIFY = 30010;

    // Minimum gas requirements
    uint constant public minReward = 1000000000000000000;
    uint constant public superblockCost = 440000;
    uint constant public challengeCost = 34000;
    uint constant public minProposalDeposit = challengeCost + minReward;
    uint constant public minChallengeDeposit = superblockCost + minReward;
    uint constant public respondMerkleRootHashesCost = 378000; // TODO: measure this with 60 hashes
    uint constant public respondBlockHeaderCost = 40000;
    uint constant public verifySuperblockCost = 220000;
}

// @dev - Manages superblocks
//
// Management of superblocks and status transitions
contract SyscoinSuperblocks is SyscoinErrorCodes {

    // @dev - Superblock status
    enum Status { Unitialized, New, InBattle, SemiApproved, Approved, Invalid }

    struct SuperblockInfo {
        bytes32 blocksMerkleRoot;
        uint accumulatedWork;
        uint timestamp;
        uint prevTimestamp;
        bytes32 lastHash;
        bytes32 parentId;
        address submitter;
        bytes32 ancestors;
        uint32 lastBits;
        uint32 index;
        uint32 height;
        uint32 blockHeight;
        Status status;
    }

    // Mapping superblock id => superblock data
    mapping (bytes32 => SuperblockInfo) superblocks;

    // Index to superblock id
    mapping (uint32 => bytes32) private indexSuperblock;

    struct ProcessTransactionParams {
        uint value;
        address destinationAddress;
        uint32 assetGUID;
        address superblockSubmitterAddress;
        SyscoinTransactionProcessor untrustedTargetContract;
    }

    mapping (uint => ProcessTransactionParams) private txParams;

    uint32 indexNextSuperblock;

    bytes32 public bestSuperblock;
    uint public bestSuperblockAccumulatedWork;

    event NewSuperblock(bytes32 superblockHash, address who);
    event ApprovedSuperblock(bytes32 superblockHash, address who);
    event ChallengeSuperblock(bytes32 superblockHash, address who);
    event SemiApprovedSuperblock(bytes32 superblockHash, address who);
    event InvalidSuperblock(bytes32 superblockHash, address who);

    event ErrorSuperblock(bytes32 superblockHash, uint err);

    event VerifyTransaction(bytes32 txHash, uint returnCode);
    event RelayTransaction(bytes32 txHash, uint returnCode);

    // SyscoinClaimManager
    address public trustedClaimManager;

    modifier onlyClaimManager() {
        require(msg.sender == trustedClaimManager);
        _;
    }

    // @dev – the constructor
    constructor() public {}

    // @dev - sets ClaimManager instance associated with managing superblocks.
    // Once trustedClaimManager has been set, it cannot be changed.
    // @param _claimManager - address of the ClaimManager contract to be associated with
    function setClaimManager(address _claimManager) public {
        require(address(trustedClaimManager) == 0x0 && _claimManager != 0x0);
        trustedClaimManager = _claimManager;
    }

    // @dev - Initializes superblocks contract
    //
    // Initializes the superblock contract. It can only be called once.
    //
    // @param _blocksMerkleRoot Root of the merkle tree of blocks contained in a superblock
    // @param _accumulatedWork Accumulated proof of work of the last block in the superblock
    // @param _timestamp Timestamp of the last block in the superblock
    // @param _prevTimestamp Timestamp of the block when the last difficulty adjustment happened (every 360 blocks)
    // @param _lastHash Hash of the last block in the superblock
    // @param _lastBits Difficulty bits of the last block in the superblock
    // @param _parentId Id of the parent superblock
    // @param _blockHeight Block height of last block in superblock   
    // @return Error code and superblockHash
    function initialize(
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        uint32 _blockHeight
    ) public returns (uint, bytes32) {
        require(bestSuperblock == 0);
        require(_parentId == 0);

        bytes32 superblockHash = calcSuperblockHash(_blocksMerkleRoot, _accumulatedWork, _timestamp, _prevTimestamp, _lastHash, _lastBits, _parentId, _blockHeight);
        SuperblockInfo storage superblock = superblocks[superblockHash];

        require(superblock.status == Status.Unitialized);

        indexSuperblock[indexNextSuperblock] = superblockHash;

        superblock.blocksMerkleRoot = _blocksMerkleRoot;
        superblock.accumulatedWork = _accumulatedWork;
        superblock.timestamp = _timestamp;
        superblock.prevTimestamp = _prevTimestamp;
        superblock.lastHash = _lastHash;
        superblock.parentId = _parentId;
        superblock.submitter = msg.sender;
        superblock.index = indexNextSuperblock;
        superblock.height = 1;
        superblock.lastBits = _lastBits;
        superblock.status = Status.Approved;
        superblock.ancestors = 0x0;
        superblock.blockHeight = _blockHeight;
        indexNextSuperblock++;

        emit NewSuperblock(superblockHash, msg.sender);

        bestSuperblock = superblockHash;
        bestSuperblockAccumulatedWork = _accumulatedWork;

        emit ApprovedSuperblock(superblockHash, msg.sender);

        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev - Proposes a new superblock
    //
    // To be accepted, a new superblock needs to have its parent
    // either approved or semi-approved.
    //
    // @param _blocksMerkleRoot Root of the merkle tree of blocks contained in a superblock
    // @param _accumulatedWork Accumulated proof of work of the last block in the superblock
    // @param _timestamp Timestamp of the last block in the superblock
    // @param _prevTimestamp Timestamp of the block when the last difficulty adjustment happened (every 360 blocks)
    // @param _lastHash Hash of the last block in the superblock
    // @param _lastBits Difficulty bits of the last block in the superblock
    // @param _parentId Id of the parent superblock
    // @param _blockHeight Block height of last block in superblock
    // @return Error code and superblockHash
    function propose(
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        uint32 _blockHeight,
        address submitter
    ) public returns (uint, bytes32) {
        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(0, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }

        SuperblockInfo storage parent = superblocks[_parentId];
        if (parent.status != Status.SemiApproved && parent.status != Status.Approved) {
            emit ErrorSuperblock(superblockHash, ERR_SUPERBLOCK_BAD_PARENT);
            return (ERR_SUPERBLOCK_BAD_PARENT, 0);
        }

        bytes32 superblockHash = calcSuperblockHash(_blocksMerkleRoot, _accumulatedWork, _timestamp, _prevTimestamp, _lastHash, _lastBits, _parentId, _blockHeight);
        SuperblockInfo storage superblock = superblocks[superblockHash];
        if (superblock.status == Status.Unitialized) {
            indexSuperblock[indexNextSuperblock] = superblockHash;
            superblock.blocksMerkleRoot = _blocksMerkleRoot;
            superblock.accumulatedWork = _accumulatedWork;
            superblock.timestamp = _timestamp;
            superblock.prevTimestamp = _prevTimestamp;
            superblock.lastHash = _lastHash;
            superblock.parentId = _parentId;
            superblock.submitter = submitter;
            superblock.index = indexNextSuperblock;
            superblock.height = parent.height + 1;
            superblock.lastBits = _lastBits;
            superblock.status = Status.New;
            superblock.blockHeight = _blockHeight;
            superblock.ancestors = updateAncestors(parent.ancestors, parent.index, parent.height);
            indexNextSuperblock++;
            emit NewSuperblock(superblockHash, submitter);
        }
        

        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev - Confirm a proposed superblock
    //
    // An unchallenged superblock can be confirmed after a timeout.
    // A challenged superblock is confirmed if it has enough descendants
    // in the main chain.
    //
    // @param _superblockHash Id of the superblock to confirm
    // @param _validator Address requesting superblock confirmation
    // @return Error code and superblockHash
    function confirm(bytes32 _superblockHash, address _validator) public returns (uint, bytes32) {
        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.New && superblock.status != Status.SemiApproved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }
        SuperblockInfo storage parent = superblocks[superblock.parentId];
        if (parent.status != Status.Approved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_PARENT);
            return (ERR_SUPERBLOCK_BAD_PARENT, 0);
        }
        superblock.status = Status.Approved;
        if (superblock.accumulatedWork > bestSuperblockAccumulatedWork) {
            bestSuperblock = _superblockHash;
            bestSuperblockAccumulatedWork = superblock.accumulatedWork;
        }
        emit ApprovedSuperblock(_superblockHash, _validator);
        return (ERR_SUPERBLOCK_OK, _superblockHash);
    }

    // @dev - Challenge a proposed superblock
    //
    // A new superblock can be challenged to start a battle
    // to verify the correctness of the data submitted.
    //
    // @param _superblockHash Id of the superblock to challenge
    // @param _challenger Address requesting a challenge
    // @return Error code and superblockHash
    function challenge(bytes32 _superblockHash, address _challenger) public returns (uint, bytes32) {
        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.New && superblock.status != Status.InBattle) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }
        if(superblock.submitter == _challenger){
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_OWN_CHALLENGE);
            return (ERR_SUPERBLOCK_OWN_CHALLENGE, 0);        
        }
        superblock.status = Status.InBattle;
        emit ChallengeSuperblock(_superblockHash, _challenger);
        return (ERR_SUPERBLOCK_OK, _superblockHash);
    }

    // @dev - Semi-approve a challenged superblock
    //
    // A challenged superblock can be marked as semi-approved
    // if it satisfies all the queries or when all challengers have
    // stopped participating.
    //
    // @param _superblockHash Id of the superblock to semi-approve
    // @param _validator Address requesting semi approval
    // @return Error code and superblockHash
    function semiApprove(bytes32 _superblockHash, address _validator) public returns (uint, bytes32) {
        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];

        if (superblock.status != Status.InBattle && superblock.status != Status.New) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }
        superblock.status = Status.SemiApproved;
        emit SemiApprovedSuperblock(_superblockHash, _validator);
        return (ERR_SUPERBLOCK_OK, _superblockHash);
    }

    // @dev - Invalidates a superblock
    //
    // A superblock with incorrect data can be invalidated immediately.
    // Superblocks that are not in the main chain can be invalidated
    // if not enough superblocks follow them, i.e. they don't have
    // enough descendants.
    //
    // @param _superblockHash Id of the superblock to invalidate
    // @param _validator Address requesting superblock invalidation
    // @return Error code and superblockHash
    function invalidate(bytes32 _superblockHash, address _validator) public returns (uint, bytes32) {
        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.InBattle && superblock.status != Status.SemiApproved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }
        superblock.status = Status.Invalid;
        emit InvalidSuperblock(_superblockHash, _validator);
        return (ERR_SUPERBLOCK_OK, _superblockHash);
    }

    // @dev - relays transaction `_txBytes` to `_untrustedTargetContract`'s processTransaction() method.
    // Also logs the value of processTransaction.
    // Note: callers cannot be 100% certain when an ERR_RELAY_VERIFY occurs because
    // it may also have been returned by processTransaction(). Callers should be
    // aware of the contract that they are relaying transactions to and
    // understand what that contract's processTransaction method returns.
    //
    // @param _txBytes - transaction bytes
    // @param _txIndex - transaction's index within the block
    // @param _txSiblings - transaction's Merkle siblings
    // @param _syscoinBlockHeader - block header containing transaction
    // @param _syscoinBlockIndex - block's index withing superblock
    // @param _syscoinBlockSiblings - block's merkle siblings
    // @param _superblockHash - superblock containing block header
    // @param _untrustedTargetContract - the contract that is going to process the transaction
    function relayTx(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] _txSiblings,
        bytes memory _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] memory _syscoinBlockSiblings,
        bytes32 _superblockHash,
        SyscoinTransactionProcessor _untrustedTargetContract
    ) public returns (uint) {

        // Check if Syscoin block belongs to given superblock
        if (bytes32(SyscoinMessageLibrary.computeMerkle(SyscoinMessageLibrary.dblShaFlip(_syscoinBlockHeader), _syscoinBlockIndex, _syscoinBlockSiblings))
            != getSuperblockMerkleRoot(_superblockHash)) {
            // Syscoin block is not in superblock
            emit RelayTransaction(bytes32(0), ERR_SUPERBLOCK);
            return ERR_SUPERBLOCK;
        }
        uint txHash = verifyTx(_txBytes, _txIndex, _txSiblings, _syscoinBlockHeader, _superblockHash);
        if (txHash != 0) {
            uint ret = parseTxHelper(_txBytes, txHash, _untrustedTargetContract);
            if(ret != 0){
                emit RelayTransaction(bytes32(0), ret);
                return ret;
            }
            ProcessTransactionParams memory params = txParams[txHash];
            params.superblockSubmitterAddress = superblocks[_superblockHash].submitter;
            txParams[txHash] = params;
            return verifyTxHelper(txHash);
        }
        emit RelayTransaction(bytes32(0), ERR_RELAY_VERIFY);
        return(ERR_RELAY_VERIFY);        
    }
    function parseTxHelper(bytes memory _txBytes, uint txHash, SyscoinTransactionProcessor _untrustedTargetContract) private returns (uint) {
        uint value;
        address destinationAddress;
        uint32 _assetGUID;
        uint ret;
        (ret, value, destinationAddress, _assetGUID) = SyscoinMessageLibrary.parseTransaction(_txBytes);
        if(ret != 0){
            return ret;
        }

        ProcessTransactionParams memory params;
        params.value = value;
        params.destinationAddress = destinationAddress;
        params.assetGUID = _assetGUID;
        params.untrustedTargetContract = _untrustedTargetContract;
        txParams[txHash] = params;        
        return 0;
    }
    function verifyTxHelper(uint txHash) private returns (uint) {
        ProcessTransactionParams memory params = txParams[txHash];        
        uint returnCode = params.untrustedTargetContract.processTransaction(txHash, params.value, params.destinationAddress, params.assetGUID, params.superblockSubmitterAddress);
        emit RelayTransaction(bytes32(txHash), returnCode);
        return (returnCode);
    }
    // @dev - Checks whether the transaction given by `_txBytes` is in the block identified by `_txBlockHeaderBytes`.
    // First it guards against a Merkle tree collision attack by raising an error if the transaction is exactly 64 bytes long,
    // then it calls helperVerifyHash to do the actual check.
    //
    // @param _txBytes - transaction bytes
    // @param _txIndex - transaction's index within the block
    // @param _siblings - transaction's Merkle siblings
    // @param _txBlockHeaderBytes - block header containing transaction
    // @param _txsuperblockHash - superblock containing block header
    // @return - SHA-256 hash of _txBytes if the transaction is in the block, 0 otherwise
    // TODO: this can probably be made private
    function verifyTx(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _siblings,
        bytes memory _txBlockHeaderBytes,
        bytes32 _txsuperblockHash
    ) public returns (uint) {
        uint txHash = SyscoinMessageLibrary.dblShaFlip(_txBytes);

        if (_txBytes.length == 64) {  // todo: is check 32 also needed?
            emit VerifyTransaction(bytes32(txHash), ERR_TX_64BYTE);
            return 0;
        }

        if (helperVerifyHash(txHash, _txIndex, _siblings, _txBlockHeaderBytes, _txsuperblockHash) == 1) {
            return txHash;
        } else {
            // log is done via helperVerifyHash
            return 0;
        }
    }

    // @dev - Checks whether the transaction identified by `_txHash` is in the block identified by `_blockHeaderBytes`
    // and whether the block is in the Syscoin main chain. Transaction check is done via Merkle proof.
    // Note: no verification is performed to prevent txHash from just being an
    // internal hash in the Merkle tree. Thus this helper method should NOT be used
    // directly and is intended to be private.
    //
    // @param _txHash - transaction hash
    // @param _txIndex - transaction's index within the block
    // @param _siblings - transaction's Merkle siblings
    // @param _blockHeaderBytes - block header containing transaction
    // @param _txsuperblockHash - superblock containing block header
    // @return - 1 if the transaction is in the block and the block is in the main chain,
    // 20020 (ERR_CONFIRMATIONS) if the block is not in the main chain,
    // 20050 (ERR_MERKLE_ROOT) if the block is in the main chain but the Merkle proof fails.
    function helperVerifyHash(
        uint256 _txHash,
        uint _txIndex,
        uint[] memory _siblings,
        bytes memory _blockHeaderBytes,
        bytes32 _txsuperblockHash
    ) private returns (uint) {

        //TODO: Verify superblock is in superblock's main chain
        if (!isApproved(_txsuperblockHash) || !inMainChain(_txsuperblockHash)) {
            emit VerifyTransaction(bytes32(_txHash), ERR_CHAIN);
            return (ERR_CHAIN);
        }

        // Verify tx Merkle root
        uint merkle = SyscoinMessageLibrary.getHeaderMerkleRoot(_blockHeaderBytes);
        if (SyscoinMessageLibrary.computeMerkle(_txHash, _txIndex, _siblings) != merkle) {
            emit VerifyTransaction(bytes32(_txHash), ERR_MERKLE_ROOT);
            return (ERR_MERKLE_ROOT);
        }

        emit VerifyTransaction(bytes32(_txHash), 1);
        return (1);
    }

    // @dev - Calculate superblock hash from superblock data
    //
    // @param _blocksMerkleRoot Root of the merkle tree of blocks contained in a superblock
    // @param _accumulatedWork Accumulated proof of work of the last block in the superblock
    // @param _timestamp Timestamp of the last block in the superblock
    // @param _prevTimestamp Timestamp of the block when the last difficulty adjustment happened (every 360 blocks)
    // @param _lastHash Hash of the last block in the superblock
    // @param _lastBits Difficulty bits of the last block in the superblock
    // @param _parentId Id of the parent superblock
    // @param _blockHeight Block height of last block in superblock   
    // @return Superblock id
    function calcSuperblockHash(
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        uint32 _blockHeight
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            _blocksMerkleRoot,
            _accumulatedWork,
            _timestamp,
            _prevTimestamp,
            _lastHash,
            _lastBits,
            _parentId,
            _blockHeight
        ));
    }

    // @dev - Returns the confirmed superblock with the most accumulated work
    //
    // @return Best superblock hash
    function getBestSuperblock() public view returns (bytes32) {
        return bestSuperblock;
    }

    // @dev - Returns the superblock data for the supplied superblock hash
    //
    // @return {
    //   bytes32 _blocksMerkleRoot,
    //   uint _accumulatedWork,
    //   uint _timestamp,
    //   uint _prevTimestamp,
    //   bytes32 _lastHash,
    //   uint32 _lastBits,
    //   bytes32 _parentId,
    //   address _submitter,
    //   Status _status,
    //   uint32 _blockHeight,
    // }  Superblock data
    function getSuperblock(bytes32 superblockHash) public view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        Status _status,
        uint32 _blockHeight
    ) {
        SuperblockInfo storage superblock = superblocks[superblockHash];
        return (
            superblock.blocksMerkleRoot,
            superblock.accumulatedWork,
            superblock.timestamp,
            superblock.prevTimestamp,
            superblock.lastHash,
            superblock.lastBits,
            superblock.parentId,
            superblock.submitter,
            superblock.status,
            superblock.blockHeight
        );
    }

    // @dev - Returns superblock height
    function getSuperblockHeight(bytes32 superblockHash) public view returns (uint32) {
        return superblocks[superblockHash].height;
    }

    // @dev - Returns superblock internal index
    function getSuperblockIndex(bytes32 superblockHash) public view returns (uint32) {
        return superblocks[superblockHash].index;
    }

    // @dev - Return superblock ancestors' indexes
    function getSuperblockAncestors(bytes32 superblockHash) public view returns (bytes32) {
        return superblocks[superblockHash].ancestors;
    }

    // @dev - Return superblock blocks' Merkle root
    function getSuperblockMerkleRoot(bytes32 _superblockHash) public view returns (bytes32) {
        return superblocks[_superblockHash].blocksMerkleRoot;
    }

    // @dev - Return superblock timestamp
    function getSuperblockTimestamp(bytes32 _superblockHash) public view returns (uint) {
        return superblocks[_superblockHash].timestamp;
    }

    // @dev - Return superblock prevTimestamp
    function getSuperblockPrevTimestamp(bytes32 _superblockHash) public view returns (uint) {
        return superblocks[_superblockHash].prevTimestamp;
    }

    // @dev - Return superblock last block hash
    function getSuperblockLastHash(bytes32 _superblockHash) public view returns (bytes32) {
        return superblocks[_superblockHash].lastHash;
    }

    // @dev - Return superblock parent
    function getSuperblockParentId(bytes32 _superblockHash) public view returns (bytes32) {
        return superblocks[_superblockHash].parentId;
    }

    // @dev - Return superblock accumulated work
    function getSuperblockAccumulatedWork(bytes32 _superblockHash) public view returns (uint) {
        return superblocks[_superblockHash].accumulatedWork;
    }

    // @dev - Return superblock status
    function getSuperblockStatus(bytes32 _superblockHash) public view returns (Status) {
        return superblocks[_superblockHash].status;
    }

    // @dev - Return indexNextSuperblock
    function getIndexNextSuperblock() public view returns (uint32) {
        return indexNextSuperblock;
    }

    // @dev - Calculate Merkle root from Syscoin block hashes
    function makeMerkle(bytes32[] hashes) public pure returns (bytes32) {
        return SyscoinMessageLibrary.makeMerkle(hashes);
    }

    function isApproved(bytes32 _superblockHash) public view returns (bool) {
        return (getSuperblockStatus(_superblockHash) == Status.Approved);
    }

    function getChainHeight() public view returns (uint) {
        return superblocks[bestSuperblock].height;
    }

    // @dev - write `_fourBytes` into `_word` starting from `_position`
    // This is useful for writing 32bit ints inside one 32 byte word
    //
    // @param _word - information to be partially overwritten
    // @param _position - position to start writing from
    // @param _eightBytes - information to be written
    function writeUint32(bytes32 _word, uint _position, uint32 _fourBytes) private pure returns (bytes32) {
        bytes32 result;
        assembly {
            let pointer := mload(0x40)
            mstore(pointer, _word)
            mstore8(add(pointer, _position), byte(28, _fourBytes))
            mstore8(add(pointer, add(_position,1)), byte(29, _fourBytes))
            mstore8(add(pointer, add(_position,2)), byte(30, _fourBytes))
            mstore8(add(pointer, add(_position,3)), byte(31, _fourBytes))
            result := mload(pointer)
        }
        return result;
    }

    uint constant ANCESTOR_STEP = 5;
    uint constant NUM_ANCESTOR_DEPTHS = 8;

    // @dev - Update ancestor to the new height
    function updateAncestors(bytes32 ancestors, uint32 index, uint height) internal pure returns (bytes32) {
        uint step = ANCESTOR_STEP;
        ancestors = writeUint32(ancestors, 0, index);
        uint i = 1;
        while (i<NUM_ANCESTOR_DEPTHS && (height % step == 1)) {
            ancestors = writeUint32(ancestors, 4*i, index);
            step *= ANCESTOR_STEP;
            ++i;
        }
        return ancestors;
    }

    // @dev - Returns a list of superblock hashes (9 hashes maximum) that helps an agent find out what
    // superblocks are missing.
    // The first position contains bestSuperblock, then
    // bestSuperblock - 1,
    // (bestSuperblock-1) - ((bestSuperblock-1) % 5), then
    // (bestSuperblock-1) - ((bestSuperblock-1) % 25), ... until
    // (bestSuperblock-1) - ((bestSuperblock-1) % 78125)
    //
    // @return - list of up to 9 ancestor supeerblock id
    function getSuperblockLocator() public view returns (bytes32[9]) {
        bytes32[9] memory locator;
        locator[0] = bestSuperblock;
        bytes32 ancestors = getSuperblockAncestors(bestSuperblock);
        uint i = NUM_ANCESTOR_DEPTHS;
        while (i > 0) {
            locator[i] = indexSuperblock[uint32(ancestors & 0xFFFFFFFF)];
            ancestors >>= 32;
            --i;
        }
        return locator;
    }

    // @dev - Return ancestor at given index
    function getSuperblockAncestor(bytes32 superblockHash, uint index) internal view returns (bytes32) {
        bytes32 ancestors = superblocks[superblockHash].ancestors;
        uint32 ancestorsIndex =
            uint32(ancestors[4*index + 0]) * 0x1000000 +
            uint32(ancestors[4*index + 1]) * 0x10000 +
            uint32(ancestors[4*index + 2]) * 0x100 +
            uint32(ancestors[4*index + 3]) * 0x1;
        return indexSuperblock[ancestorsIndex];
    }

    // dev - returns depth associated with an ancestor index; applies to any superblock
    //
    // @param _index - index of ancestor to be looked up; an integer between 0 and 7
    // @return - depth corresponding to said index, i.e. 5**index
    function getAncDepth(uint _index) private pure returns (uint) {
        return ANCESTOR_STEP**(uint(_index));
    }

    // @dev - return superblock hash at a given height in superblock main chain
    //
    // @param _height - superblock height
    // @return - hash corresponding to block of height _blockHeight
    function getSuperblockAt(uint _height) public view returns (bytes32) {
        bytes32 superblockHash = bestSuperblock;
        uint index = NUM_ANCESTOR_DEPTHS - 1;

        while (getSuperblockHeight(superblockHash) > _height) {
            while (getSuperblockHeight(superblockHash) - _height < getAncDepth(index) && index > 0) {
                index -= 1;
            }
            superblockHash = getSuperblockAncestor(superblockHash, index);
        }

        return superblockHash;
    }

    // @dev - Checks if a superblock is in superblock main chain
    //
    // @param _blockHash - hash of the block being searched for in the main chain
    // @return - true if the block identified by _blockHash is in the main chain,
    // false otherwise
    function inMainChain(bytes32 _superblockHash) internal view returns (bool) {
        uint height = getSuperblockHeight(_superblockHash);
        if (height == 0) return false;
        return (getSuperblockAt(height) == _superblockHash);
    }
}

// @dev - Manages a battle session between superblock submitter and challenger
contract SyscoinBattleManager is SyscoinErrorCodes {

    enum ChallengeState {
        Unchallenged,             // Unchallenged submission
        Challenged,               // Claims was challenged
        QueryMerkleRootHashes,    // Challenger expecting block hashes
        RespondMerkleRootHashes,  // Blcok hashes were received and verified
        QueryBlockHeader,         // Challenger is requesting block headers
        RespondBlockHeader,       // All block headers were received
        PendingVerification,      // Pending superblock verification
        SuperblockVerified,       // Superblock verified
        SuperblockFailed          // Superblock not valid
    }

    enum BlockInfoStatus {
        Uninitialized,
        Requested,
		Verified
    }

    struct BlockInfo {
        bytes32 prevBlock;
        uint64 timestamp;
        uint32 bits;
        BlockInfoStatus status;
        bytes powBlockHeader;
        bytes32 blockHash;
    }

    struct BattleSession {
        bytes32 id;
        bytes32 superblockHash;
        address submitter;
        address challenger;
        uint lastActionTimestamp;         // Last action timestamp
        uint lastActionClaimant;          // Number last action submitter
        uint lastActionChallenger;        // Number last action challenger
        uint actionsCounter;              // Counter session actions

        bytes32[] blockHashes;            // Block hashes
        uint countBlockHeaderQueries;     // Number of block header queries
        uint countBlockHeaderResponses;   // Number of block header responses

        mapping (bytes32 => BlockInfo) blocksInfo;

        ChallengeState challengeState;    // Claim state
    }


    mapping (bytes32 => BattleSession) public sessions;

    uint public sessionsCount = 0;

    uint public superblockDuration;         // Superblock duration (in seconds)
    uint public superblockTimeout;          // Timeout action (in seconds)


    // network that the stored blocks belong to
    SyscoinMessageLibrary.Network private net;


    // Syscoin claim manager
    SyscoinClaimManager trustedSyscoinClaimManager;

    // Superblocks contract
    SyscoinSuperblocks trustedSuperblocks;

    event NewBattle(bytes32 superblockHash, bytes32 sessionId, address submitter, address challenger);
    event ChallengerConvicted(bytes32 superblockHash, bytes32 sessionId, address challenger);
    event SubmitterConvicted(bytes32 superblockHash, bytes32 sessionId, address submitter);

    event QueryMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, address submitter);
    event RespondMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, address challenger, bytes32[] blockHashes);
    event QueryBlockHeader(bytes32 superblockHash, bytes32 sessionId, address submitter, bytes32 blockSha256Hash);
    event RespondBlockHeader(bytes32 superblockHash, bytes32 sessionId, address challenger, bytes blockHeader, bytes powBlockHeader);

    event ErrorBattle(bytes32 sessionId, uint err);
    modifier onlyFrom(address sender) {
        require(msg.sender == sender);
        _;
    }

    modifier onlyClaimant(bytes32 sessionId) {
        require(msg.sender == sessions[sessionId].submitter);
        _;
    }

    modifier onlyChallenger(bytes32 sessionId) {
        require(msg.sender == sessions[sessionId].challenger);
        _;
    }

    // @dev – Configures the contract managing superblocks battles
    // @param _network Network type to use for block difficulty validation
    // @param _superblocks Contract that manages superblocks
    // @param _superblockDuration Superblock duration (in seconds)
    // @param _superblockTimeout Time to wait for challenges (in seconds)
    constructor(
        SyscoinMessageLibrary.Network _network,
        SyscoinSuperblocks _superblocks,
        uint _superblockDuration,
        uint _superblockTimeout
    ) public {
        net = _network;
        trustedSuperblocks = _superblocks;
        superblockDuration = _superblockDuration;
        superblockTimeout = _superblockTimeout;
    }

    function setSyscoinClaimManager(SyscoinClaimManager _syscoinClaimManager) public {
        require(address(trustedSyscoinClaimManager) == 0x0 && address(_syscoinClaimManager) != 0x0);
        trustedSyscoinClaimManager = _syscoinClaimManager;
    }

    // @dev - Start a battle session
    function beginBattleSession(bytes32 superblockHash, address submitter, address challenger)
        onlyFrom(trustedSyscoinClaimManager) public returns (bytes32) {
        bytes32 sessionId = keccak256(abi.encode(superblockHash, msg.sender, sessionsCount));
        BattleSession storage session = sessions[sessionId];
        session.id = sessionId;
        session.superblockHash = superblockHash;
        session.submitter = submitter;
        session.challenger = challenger;
        session.lastActionTimestamp = block.timestamp;
        session.lastActionChallenger = 0;
        session.lastActionClaimant = 1;     // Force challenger to start
        session.actionsCounter = 1;
        session.challengeState = ChallengeState.Challenged;

        sessionsCount += 1;

        emit NewBattle(superblockHash, sessionId, submitter, challenger);
        return sessionId;
    }

    // @dev - Challenger makes a query for superblock hashes
    function doQueryMerkleRootHashes(BattleSession storage session) internal returns (uint) {
        if (!hasDeposit(msg.sender, respondMerkleRootHashesCost)) {
            return ERR_SUPERBLOCK_MIN_DEPOSIT;
        }
        if (session.challengeState == ChallengeState.Challenged) {
            session.challengeState = ChallengeState.QueryMerkleRootHashes;
            assert(msg.sender == session.challenger);
            (uint err, ) = bondDeposit(session.superblockHash, msg.sender, respondMerkleRootHashesCost);
            if (err != ERR_SUPERBLOCK_OK) {
                return err;
            }
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    // @dev - Challenger makes a query for superblock hashes
    function queryMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId) onlyChallenger(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doQueryMerkleRootHashes(session);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionChallenger = session.actionsCounter;
            emit QueryMerkleRootHashes(superblockHash, sessionId, session.submitter);
        }
    }

    // @dev - Submitter sends hashes to verify superblock merkle root
    function doVerifyMerkleRootHashes(BattleSession storage session, bytes32[] blockHashes) internal returns (uint) {
        if (!hasDeposit(msg.sender, verifySuperblockCost)) {
            return ERR_SUPERBLOCK_MIN_DEPOSIT;
        }
        require(session.blockHashes.length == 0);
        if (session.challengeState == ChallengeState.QueryMerkleRootHashes) {
            (bytes32 merkleRoot, , , , bytes32 lastHash, , , ,,) = getSuperblockInfo(session.superblockHash);
            if (lastHash != blockHashes[blockHashes.length - 1]){
                return ERR_SUPERBLOCK_BAD_LASTBLOCK;
            }
            if (merkleRoot != SyscoinMessageLibrary.makeMerkle(blockHashes)) {
                return ERR_SUPERBLOCK_INVALID_MERKLE;
            }
            (uint err, ) = bondDeposit(session.superblockHash, msg.sender, verifySuperblockCost);
            if (err != ERR_SUPERBLOCK_OK) {
                return err;
            }
            session.blockHashes = blockHashes;
            session.challengeState = ChallengeState.RespondMerkleRootHashes;
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    // @dev - For the submitter to respond to challenger queries
    function respondMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, bytes32[] blockHashes) onlyClaimant(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doVerifyMerkleRootHashes(session, blockHashes);
        if (err != 0) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionClaimant = session.actionsCounter;
            emit RespondMerkleRootHashes(superblockHash, sessionId, session.challenger, blockHashes);
        }
    }

    // @dev - Challenger makes a query for block header data for a hash
    function doQueryBlockHeader(BattleSession storage session, bytes32 blockHash) internal returns (uint) {
        if (!hasDeposit(msg.sender, respondBlockHeaderCost)) {
            return ERR_SUPERBLOCK_MIN_DEPOSIT;
        }
        if ((session.countBlockHeaderQueries == 0 && session.challengeState == ChallengeState.RespondMerkleRootHashes) ||
            (session.countBlockHeaderQueries > 0 && session.challengeState == ChallengeState.RespondBlockHeader)) {
            require(session.countBlockHeaderQueries < session.blockHashes.length);
            require(session.blocksInfo[blockHash].status == BlockInfoStatus.Uninitialized);
            (uint err, ) = bondDeposit(session.superblockHash, msg.sender, respondBlockHeaderCost);
            if (err != ERR_SUPERBLOCK_OK) {
                return err;
            }
            session.countBlockHeaderQueries += 1;
            session.blocksInfo[blockHash].status = BlockInfoStatus.Requested;
            session.challengeState = ChallengeState.QueryBlockHeader;
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    // @dev - For the challenger to start a query
    function queryBlockHeader(bytes32 superblockHash, bytes32 sessionId, bytes32 blockHash) onlyChallenger(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doQueryBlockHeader(session, blockHash);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionChallenger = session.actionsCounter;
            emit QueryBlockHeader(superblockHash, sessionId, session.submitter, blockHash);
        }
    }

    // @dev - Verify that block timestamp is in the superblock timestamp interval
    function verifyTimestamp(bytes32 superblockHash, bytes blockHeader) internal view returns (bool) {
        uint blockTimestamp = SyscoinMessageLibrary.getTimestamp(blockHeader);
        uint superblockTimestamp;

        (, , superblockTimestamp, , , , , ,,) = getSuperblockInfo(superblockHash);

        // Block timestamp to be within the expected timestamp of the superblock
        return (blockTimestamp <= superblockTimestamp)
            && (blockTimestamp / superblockDuration >= superblockTimestamp / superblockDuration - 1);
    }

    // @dev - Verify Syscoin block AuxPoW
    function verifyBlockAuxPoW(
        BlockInfo storage blockInfo,
        bytes32 blockHash,
        bytes blockHeader
    ) internal returns (uint, bytes) {
        (uint err, bool isMergeMined) =
            SyscoinMessageLibrary.verifyBlockHeader(blockHeader, 0, uint(blockHash));
        if (err != 0) {
            return (err, new bytes(0));
        }
        bytes memory powBlockHeader = (isMergeMined) ?
            SyscoinMessageLibrary.sliceArray(blockHeader, blockHeader.length - 80, blockHeader.length) :
            SyscoinMessageLibrary.sliceArray(blockHeader, 0, 80);

        blockInfo.timestamp = SyscoinMessageLibrary.getTimestamp(blockHeader);
        blockInfo.bits = SyscoinMessageLibrary.getBits(blockHeader);
        blockInfo.prevBlock = bytes32(SyscoinMessageLibrary.getHashPrevBlock(blockHeader));
        blockInfo.blockHash = blockHash;
        blockInfo.powBlockHeader = powBlockHeader;
        return (ERR_SUPERBLOCK_OK, powBlockHeader);
    }

    // @dev - Verify block header sent by challenger
    function doVerifyBlockHeader(
        BattleSession storage session,
        bytes memory blockHeader
    ) internal returns (uint, bytes) {
        if (!hasDeposit(msg.sender, respondBlockHeaderCost)) {
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, new bytes(0));
        }
        if (session.challengeState == ChallengeState.QueryBlockHeader) {
            bytes32 blockSha256Hash = bytes32(SyscoinMessageLibrary.dblShaFlipMem(blockHeader, 0, 80));
            BlockInfo storage blockInfo = session.blocksInfo[blockSha256Hash];
            if (blockInfo.status != BlockInfoStatus.Requested) {
                return (ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS, new bytes(0));
            }

            if (!verifyTimestamp(session.superblockHash, blockHeader)) {
                return (ERR_SUPERBLOCK_BAD_TIMESTAMP, new bytes(0));
            }
			// pass in blockSha256Hash here instead of proposedScryptHash because we
            // don't need a proposed hash (we already calculated it here, syscoin uses 
            // sha256 just like bitcoin)
            (uint err, bytes memory powBlockHeader) =
                verifyBlockAuxPoW(blockInfo, blockSha256Hash, blockHeader);
            if (err != ERR_SUPERBLOCK_OK) {
                return (err, new bytes(0));
            }
			// set to verify block header status
            blockInfo.status = BlockInfoStatus.Verified;

            (err, ) = bondDeposit(session.superblockHash, msg.sender, respondBlockHeaderCost);
            if (err != ERR_SUPERBLOCK_OK) {
                return (err, new bytes(0));
            }

            session.countBlockHeaderResponses += 1;
			// if header responses matches num block hashes we skip to respond block header instead of pending verification
            if (session.countBlockHeaderResponses == session.blockHashes.length) {
                session.challengeState = ChallengeState.PendingVerification;
            } else {
                session.challengeState = ChallengeState.RespondBlockHeader;
            }

            return (ERR_SUPERBLOCK_OK, powBlockHeader);
        }
        return (ERR_SUPERBLOCK_BAD_STATUS, new bytes(0));
    }

    // @dev - For the submitter to respond to challenger queries
    function respondBlockHeader(
        bytes32 superblockHash,
        bytes32 sessionId,
        bytes memory blockHeader
    ) onlyClaimant(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        (uint err, bytes memory powBlockHeader) = doVerifyBlockHeader(session, blockHeader);
        if (err != 0) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionClaimant = session.actionsCounter;
            emit RespondBlockHeader(superblockHash, sessionId, session.challenger, blockHeader, powBlockHeader);
        }
    }

    // @dev - Validate superblock information from last blocks
    function validateLastBlocks(BattleSession storage session) internal view returns (uint) {
        if (session.blockHashes.length <= 0) {
            return ERR_SUPERBLOCK_BAD_LASTBLOCK;
        }
        uint lastTimestamp;
        uint prevTimestamp;
        uint32 lastBits;
        bytes32 parentId;
        (, , lastTimestamp, prevTimestamp, , lastBits, parentId,,,) = getSuperblockInfo(session.superblockHash);
        bytes32 blockSha256Hash = session.blockHashes[session.blockHashes.length - 1];
        if (session.blocksInfo[blockSha256Hash].timestamp != lastTimestamp) {
            return ERR_SUPERBLOCK_BAD_TIMESTAMP;
        }
        if (session.blocksInfo[blockSha256Hash].bits != lastBits) {
            return ERR_SUPERBLOCK_BAD_BITS;
        }
        if (prevTimestamp > lastTimestamp) {
            return ERR_SUPERBLOCK_BAD_TIMESTAMP;
        }
        
        return ERR_SUPERBLOCK_OK;
    }

    // @dev - Validate superblock accumulated work
    function validateProofOfWork(BattleSession storage session) internal view returns (uint) {
        uint accWork;
        bytes32 prevBlock;
        uint32 prevHeight;  
        uint32 proposedHeight;  
        uint prevTimestamp;
        (, accWork, , prevTimestamp, , , prevBlock, ,,proposedHeight) = getSuperblockInfo(session.superblockHash);
        uint parentTimestamp;
        
        uint32 prevBits;
       
        uint work;    
        (, work, parentTimestamp, , prevBlock, prevBits, , , ,prevHeight) = getSuperblockInfo(prevBlock);
        
        if (proposedHeight != (prevHeight+uint32(session.blockHashes.length))) {
            return ERR_SUPERBLOCK_BAD_BLOCKHEIGHT;
        }      
        uint ret = validateSuperblockProofOfWork(session, parentTimestamp, prevHeight, work, accWork, prevTimestamp, prevBits, prevBlock);
        if(ret != 0){
            return ret;
        }
        return ERR_SUPERBLOCK_OK;
    }
    function validateSuperblockProofOfWork(BattleSession storage session, uint parentTimestamp, uint32 prevHeight, uint work, uint accWork, uint prevTimestamp, uint32 prevBits, bytes32 prevBlock) internal view returns (uint){
         uint32 idx = 0;
         while (idx < session.blockHashes.length) {
            bytes32 blockSha256Hash = session.blockHashes[idx];
            uint32 bits = session.blocksInfo[blockSha256Hash].bits;
            if (session.blocksInfo[blockSha256Hash].prevBlock != prevBlock) {
                return ERR_SUPERBLOCK_BAD_PARENT;
            }
            if (net != SyscoinMessageLibrary.Network.REGTEST) {
                uint32 newBits;
                if (net == SyscoinMessageLibrary.Network.TESTNET && session.blocksInfo[blockSha256Hash].timestamp - parentTimestamp > 120) {
                    newBits = 0x1e0fffff;
                }
                else if((prevHeight+idx+1) % SyscoinMessageLibrary.difficultyAdjustmentInterval() != 0){
                    newBits = prevBits;
                }
                else{
                    newBits = SyscoinMessageLibrary.calculateDifficulty(int64(parentTimestamp) - int64(prevTimestamp), prevBits);
                    prevTimestamp = parentTimestamp;
                    prevBits = bits;
                }
                if (bits != newBits) {
                   return ERR_SUPERBLOCK_BAD_BITS;
                }
            }
            work += SyscoinMessageLibrary.diffFromBits(bits);
            prevBlock = blockSha256Hash;
            parentTimestamp = session.blocksInfo[blockSha256Hash].timestamp;
            idx += 1;
        }
        if (net != SyscoinMessageLibrary.Network.REGTEST &&  work != accWork) {
            return ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK;
        }       
        return 0;
    }
    // @dev - Verify whether a superblock's data is consistent
    // Only should be called when all blocks header were submitted
    function doVerifySuperblock(BattleSession storage session, bytes32 sessionId) internal returns (uint) {
        if (session.challengeState == ChallengeState.PendingVerification) {
            uint err;
            err = validateLastBlocks(session);
            if (err != 0) {
                emit ErrorBattle(sessionId, err);
                return 2;
            }
            err = validateProofOfWork(session);
            if (err != 0) {
                emit ErrorBattle(sessionId, err);
                return 2;
            }
            return 1;
        } else if (session.challengeState == ChallengeState.SuperblockFailed) {
            return 2;
        }
        return 0;
    }

    // @dev - Perform final verification once all blocks were submitted
    function verifySuperblock(bytes32 sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint status = doVerifySuperblock(session, sessionId);
        if (status == 1) {
            convictChallenger(sessionId, session.challenger, session.superblockHash);
        } else if (status == 2) {
            convictSubmitter(sessionId, session.submitter, session.superblockHash);
        }
    }

    // @dev - Trigger conviction if response is not received in time
    function timeout(bytes32 sessionId) public returns (uint) {
        BattleSession storage session = sessions[sessionId];
        if (session.challengeState == ChallengeState.SuperblockFailed ||
            (session.lastActionChallenger > session.lastActionClaimant &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout)) {
            convictSubmitter(sessionId, session.submitter, session.superblockHash);
            return ERR_SUPERBLOCK_OK;
        } else if (session.lastActionClaimant > session.lastActionChallenger &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout) {
            convictChallenger(sessionId, session.challenger, session.superblockHash);
            return ERR_SUPERBLOCK_OK;
        }
        emit ErrorBattle(sessionId, ERR_SUPERBLOCK_NO_TIMEOUT);
        return ERR_SUPERBLOCK_NO_TIMEOUT;
    }

    // @dev - To be called when a challenger is convicted
    function convictChallenger(bytes32 sessionId, address challenger, bytes32 superblockHash) internal {
        BattleSession storage session = sessions[sessionId];
        sessionDecided(sessionId, superblockHash, session.submitter, session.challenger);
        disable(sessionId);
        emit ChallengerConvicted(superblockHash, sessionId, challenger);
    }

    // @dev - To be called when a submitter is convicted
    function convictSubmitter(bytes32 sessionId, address submitter, bytes32 superblockHash) internal {
        BattleSession storage session = sessions[sessionId];
        sessionDecided(sessionId, superblockHash, session.challenger, session.submitter);
        disable(sessionId);
        emit SubmitterConvicted(superblockHash, sessionId, submitter);
    }

    // @dev - Disable session
    // It should be called only when either the submitter or the challenger were convicted.
    function disable(bytes32 sessionId) internal {
        delete sessions[sessionId];
    }

    // @dev - Check if a session's challenger did not respond before timeout
    function getChallengerHitTimeout(bytes32 sessionId) public view returns (bool) {
        BattleSession storage session = sessions[sessionId];
        return (session.lastActionClaimant > session.lastActionChallenger &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout);
    }

    // @dev - Check if a session's submitter did not respond before timeout
    function getSubmitterHitTimeout(bytes32 sessionId) public view returns (bool) {
        BattleSession storage session = sessions[sessionId];
        return (session.lastActionChallenger > session.lastActionClaimant &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout);
    }

    // @dev - Return Syscoin block hashes associated with a certain battle session
    function getSyscoinBlockHashes(bytes32 sessionId) public view returns (bytes32[]) {
        return sessions[sessionId].blockHashes;
    }

    // @dev - To be called when a battle sessions  was decided
    function sessionDecided(bytes32 sessionId, bytes32 superblockHash, address winner, address loser) internal {
        trustedSyscoinClaimManager.sessionDecided(sessionId, superblockHash, winner, loser);
    }

    // @dev - Retrieve superblock information
    function getSuperblockInfo(bytes32 superblockHash) internal view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        SyscoinSuperblocks.Status _status,
        uint32 _height
    ) {
        return trustedSuperblocks.getSuperblock(superblockHash);
    }

    // @dev - Verify whether a user has a certain amount of deposits or more
    function hasDeposit(address who, uint amount) internal view returns (bool) {
        return trustedSyscoinClaimManager.getDeposit(who) >= amount;
    }

    // @dev – locks up part of a user's deposit into a claim.
    function bondDeposit(bytes32 superblockHash, address account, uint amount) internal returns (uint, uint) {
        return trustedSyscoinClaimManager.bondDeposit(superblockHash, account, amount);
    }
}

// @dev - Manager of superblock claims
//
// Manages superblocks proposal and challenges
contract SyscoinClaimManager is SyscoinDepositsManager, SyscoinErrorCodes {

    using SafeMath for uint;

    struct SuperblockClaim {
        bytes32 superblockHash;                       // Superblock Id
        address submitter;                           // Superblock submitter
        uint createdAt;                             // Superblock creation time

        address[] challengers;                      // List of challengers
        mapping (address => uint) bondedDeposits;   // Deposit associated to challengers

        uint currentChallenger;                     // Index of challenger in current session
        mapping (address => bytes32) sessions;      // Challenge sessions

        uint challengeTimeout;                      // Claim timeout

        bool verificationOngoing;                   // Challenge session has started

        bool decided;                               // If the claim was decided
        bool invalid;                               // If superblock is invalid
    }

    // Active superblock claims
    mapping (bytes32 => SuperblockClaim) public claims;

    // Superblocks contract
    SyscoinSuperblocks public trustedSuperblocks;

    // Battle manager contract
    SyscoinBattleManager public trustedSyscoinBattleManager;

    // Confirmations required to confirm semi approved superblocks
    uint public superblockConfirmations;

    // Monetary reward for opponent in case battle is lost
    uint public battleReward;

    uint public superblockDelay;    // Delay required to submit superblocks (in seconds)
    uint public superblockTimeout;  // Timeout for action (in seconds)

    event DepositBonded(bytes32 superblockHash, address account, uint amount);
    event DepositUnbonded(bytes32 superblockHash, address account, uint amount);
    event SuperblockClaimCreated(bytes32 superblockHash, address submitter);
    event SuperblockClaimChallenged(bytes32 superblockHash, address challenger);
    event SuperblockBattleDecided(bytes32 sessionId, address winner, address loser);
    event SuperblockClaimSuccessful(bytes32 superblockHash, address submitter);
    event SuperblockClaimPending(bytes32 superblockHash, address submitter);
    event SuperblockClaimFailed(bytes32 superblockHash, address submitter);
    event VerificationGameStarted(bytes32 superblockHash, address submitter, address challenger, bytes32 sessionId);

    event ErrorClaim(bytes32 superblockHash, uint err);

    modifier onlyBattleManager() {
        require(msg.sender == address(trustedSyscoinBattleManager));
        _;
    }

    modifier onlyMeOrBattleManager() {
        require(msg.sender == address(trustedSyscoinBattleManager) || msg.sender == address(this));
        _;
    }

    // @dev – Sets up the contract managing superblock challenges
    // @param _superblocks Contract that manages superblocks
    // @param _battleManager Contract that manages battles
    // @param _superblockDelay Delay to accept a superblock submission (in seconds)
    // @param _superblockTimeout Time to wait for challenges (in seconds)
    // @param _superblockConfirmations Confirmations required to confirm semi approved superblocks
    constructor(
        SyscoinSuperblocks _superblocks,
        SyscoinBattleManager _syscoinBattleManager,
        uint _superblockDelay,
        uint _superblockTimeout,
        uint _superblockConfirmations,
        uint _battleReward
    ) public {
        trustedSuperblocks = _superblocks;
        trustedSyscoinBattleManager = _syscoinBattleManager;
        superblockDelay = _superblockDelay;
        superblockTimeout = _superblockTimeout;
        superblockConfirmations = _superblockConfirmations;
        battleReward = _battleReward;
    }

    // @dev – locks up part of a user's deposit into a claim.
    // @param superblockHash – claim id.
    // @param account – user's address.
    // @param amount – amount of deposit to lock up.
    // @return – user's deposit bonded for the claim.
    function bondDeposit(bytes32 superblockHash, address account, uint amount) onlyMeOrBattleManager external returns (uint, uint) {
        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            return (ERR_SUPERBLOCK_BAD_CLAIM, 0);
        }

        if (deposits[account] < amount) {
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, deposits[account]);
        }

        deposits[account] = deposits[account].sub(amount);
        claim.bondedDeposits[account] = claim.bondedDeposits[account].add(amount);
        emit DepositBonded(superblockHash, account, amount);

        return (ERR_SUPERBLOCK_OK, claim.bondedDeposits[account]);
    }

    // @dev – accessor for a claim's bonded deposits.
    // @param superblockHash – claim id.
    // @param account – user's address.
    // @return – user's deposit bonded for the claim.
    function getBondedDeposit(bytes32 superblockHash, address account) public view returns (uint) {
        SuperblockClaim storage claim = claims[superblockHash];
        require(claimExists(claim));
        return claim.bondedDeposits[account];
    }

    function getDeposit(address account) public view returns (uint) {
        return deposits[account];
    }

    // @dev – unlocks a user's bonded deposits from a claim.
    // @param superblockHash – claim id.
    // @param account – user's address.
    // @return – user's deposit which was unbonded from the claim.
    function unbondDeposit(bytes32 superblockHash, address account) internal returns (uint, uint) {
        SuperblockClaim storage claim = claims[superblockHash];
        if (!claimExists(claim)) {
            return (ERR_SUPERBLOCK_BAD_CLAIM, 0);
        }
        if (!claim.decided) {
            return (ERR_SUPERBLOCK_BAD_STATUS, 0);
        }

        uint bondedDeposit = claim.bondedDeposits[account];

        delete claim.bondedDeposits[account];
        deposits[account] = deposits[account].add(bondedDeposit);

        emit DepositUnbonded(superblockHash, account, bondedDeposit);

        return (ERR_SUPERBLOCK_OK, bondedDeposit);
    }

    // @dev – Propose a new superblock.
    //
    // @param _blocksMerkleRoot Root of the merkle tree of blocks contained in a superblock
    // @param _accumulatedWork Accumulated proof of work of the last block in the superblock
    // @param _timestamp Timestamp of the last block in the superblock
    // @param _prevTimestamp Timestamp of the block when the last difficulty adjustment happened
    // @param _lastHash Hash of the last block in the superblock
    // @param _lastBits Difficulty bits of the last block in the superblock
    // @param _parentHash Id of the parent superblock
    // @return Error code and superblockHash
    function proposeSuperblock(
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentHash,
        uint32 _blockHeight
    ) public returns (uint, bytes32) {
        require(address(trustedSuperblocks) != 0);

        if (deposits[msg.sender] < minProposalDeposit) {
            emit ErrorClaim(0, ERR_SUPERBLOCK_MIN_DEPOSIT);
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, 0);
        }

        if (_timestamp + superblockDelay > block.timestamp) {
            emit ErrorClaim(0, ERR_SUPERBLOCK_BAD_TIMESTAMP);
            return (ERR_SUPERBLOCK_BAD_TIMESTAMP, 0);
        }

        uint err;
        bytes32 superblockHash;
        (err, superblockHash) = trustedSuperblocks.propose(_blocksMerkleRoot, _accumulatedWork,
            _timestamp, _prevTimestamp, _lastHash, _lastBits, _parentHash, _blockHeight,msg.sender);
        if (err != 0) {
            emit ErrorClaim(superblockHash, err);
            return (err, superblockHash);
        }


        SuperblockClaim storage claim = claims[superblockHash];
        // allow to propose an existing claim only if its invalid and decided and its a different submitter or not on the tip
        // those are the ones that may actually be stuck and need to be proposed again, 
        // but we want to ensure its not the same submitter submitting the same thing
        if (claimExists(claim)) {
            bool allowed = claim.invalid == true && claim.decided == true && claim.submitter != msg.sender;
            if(allowed){
                // we also want to ensure that if parent is approved we are building on the tip and not anywhere else
                if(trustedSuperblocks.getSuperblockStatus(_parentHash) == SyscoinSuperblocks.Status.Approved){
                    allowed = trustedSuperblocks.getBestSuperblock() == _parentHash;
                }
                // or if its semi approved allow to build on top as well
                else if(trustedSuperblocks.getSuperblockStatus(_parentHash) == SyscoinSuperblocks.Status.SemiApproved){
                    allowed = true;
                }
                else{
                    allowed = false;
                }
            }
            if(!allowed){
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
                return (ERR_SUPERBLOCK_BAD_CLAIM, superblockHash);  
            }
        }


        claim.superblockHash = superblockHash;
        claim.submitter = msg.sender;
        claim.currentChallenger = 0;
        claim.decided = false;
        claim.invalid = false;
        claim.verificationOngoing = false;
        claim.createdAt = block.timestamp;
        claim.challengeTimeout = block.timestamp + superblockTimeout;
        claim.challengers.length = 0;

        (err, ) = this.bondDeposit(superblockHash, msg.sender, battleReward);
        assert(err == ERR_SUPERBLOCK_OK);

        emit SuperblockClaimCreated(superblockHash, msg.sender);

        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev – challenge a superblock claim.
    // @param superblockHash – Id of the superblock to challenge.
    // @return - Error code and claim Id
    function challengeSuperblock(bytes32 superblockHash) public returns (uint, bytes32) {
        require(address(trustedSuperblocks) != 0);

        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return (ERR_SUPERBLOCK_BAD_CLAIM, superblockHash);
        }
        if (claim.decided) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_DECIDED);
            return (ERR_SUPERBLOCK_CLAIM_DECIDED, superblockHash);
        }
        if (deposits[msg.sender] < minChallengeDeposit) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_MIN_DEPOSIT);
            return (ERR_SUPERBLOCK_MIN_DEPOSIT, superblockHash);
        }

        uint err;
        (err, ) = trustedSuperblocks.challenge(superblockHash, msg.sender);
        if (err != 0) {
            emit ErrorClaim(superblockHash, err);
            return (err, 0);
        }

        (err, ) = this.bondDeposit(superblockHash, msg.sender, battleReward);
        assert(err == ERR_SUPERBLOCK_OK);

        claim.challengeTimeout = block.timestamp + superblockTimeout;
        claim.challengers.push(msg.sender);
        emit SuperblockClaimChallenged(superblockHash, msg.sender);

        if (!claim.verificationOngoing) {
            runNextBattleSession(superblockHash);
        }

        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    // @dev – runs a battle session to verify a superblock for the next challenger
    // @param superblockHash – claim id.
    function runNextBattleSession(bytes32 superblockHash) internal returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return false;
        }

        // superblocks marked as invalid do not have to run remaining challengers
        if (claim.decided || claim.invalid) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_DECIDED);
            return false;
        }

        if (claim.verificationOngoing) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_VERIFICATION_PENDING);
            return false;
        }

        if (claim.currentChallenger < claim.challengers.length) {

            bytes32 sessionId = trustedSyscoinBattleManager.beginBattleSession(superblockHash, claim.submitter,
                claim.challengers[claim.currentChallenger]);

            claim.sessions[claim.challengers[claim.currentChallenger]] = sessionId;
            emit VerificationGameStarted(superblockHash, claim.submitter,
                claim.challengers[claim.currentChallenger], sessionId);

            claim.verificationOngoing = true;
            claim.currentChallenger += 1;
        }

        return true;
    }

    // @dev – check whether a claim has successfully withstood all challenges.
    // If successful without challenges, it will mark the superblock as confirmed.
    // If successful with at least one challenge, it will mark the superblock as semi-approved.
    // If verification failed, it will mark the superblock as invalid.
    //
    // @param superblockHash – claim ID.
    function checkClaimFinished(bytes32 superblockHash) public returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];

        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return false;
        }

        // check that there is no ongoing verification game.
        if (claim.verificationOngoing) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_VERIFICATION_PENDING);
            return false;
        }

        // an invalid superblock can be rejected immediately
        if (claim.invalid) {
            // The superblock is invalid, submitter abandoned
            // or superblock data is inconsistent
            claim.decided = true;
            trustedSuperblocks.invalidate(claim.superblockHash, msg.sender);
            emit SuperblockClaimFailed(superblockHash, claim.submitter);
            doPayChallengers(superblockHash, claim);
            return false;
        }

        // check that the claim has exceeded the claim's specific challenge timeout.
        if (block.timestamp <= claim.challengeTimeout) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_NO_TIMEOUT);
            return false;
        }

        // check that all verification games have been played.
        if (claim.currentChallenger < claim.challengers.length) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_VERIFICATION_PENDING);
            return false;
        }

        claim.decided = true;

        bool confirmImmediately = false;
        // No challengers and parent approved; confirm immediately
        if (claim.challengers.length == 0) {
            bytes32 parentId = trustedSuperblocks.getSuperblockParentId(claim.superblockHash);
            SyscoinSuperblocks.Status status = trustedSuperblocks.getSuperblockStatus(parentId);
            if (status == SyscoinSuperblocks.Status.Approved) {
                confirmImmediately = true;
            }
        }

        if (confirmImmediately) {
            trustedSuperblocks.confirm(claim.superblockHash, msg.sender);
            unbondDeposit(superblockHash, claim.submitter);
            emit SuperblockClaimSuccessful(superblockHash, claim.submitter);
        } else {
            trustedSuperblocks.semiApprove(claim.superblockHash, msg.sender);
            emit SuperblockClaimPending(superblockHash, claim.submitter);
        }
        return true;
    }

    // @dev – confirm semi approved superblock.
    //
    // A semi approved superblock can be confirmed if it has several descendant
    // superblocks that are also semi-approved.
    // If none of the descendants were challenged they will also be confirmed.
    //
    // @param superblockHash – the claim ID.
    // @param descendantId - claim ID descendants
    function confirmClaim(bytes32 superblockHash, bytes32 descendantId) public returns (bool) {
        uint numSuperblocks = 0;
        bool confirmDescendants = true;
        bytes32 id = descendantId;
        SuperblockClaim storage claim = claims[id];
        while (id != superblockHash) {
            if (!claimExists(claim)) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
                return false;
            }
            if (trustedSuperblocks.getSuperblockStatus(id) != SyscoinSuperblocks.Status.SemiApproved) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
                return false;
            }
            if (confirmDescendants && claim.challengers.length > 0) {
                confirmDescendants = false;
            }
            id = trustedSuperblocks.getSuperblockParentId(id);
            claim = claims[id];
            numSuperblocks += 1;
        }

        if (numSuperblocks < superblockConfirmations) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_MISSING_CONFIRMATIONS);
            return false;
        }
        if (trustedSuperblocks.getSuperblockStatus(id) != SyscoinSuperblocks.Status.SemiApproved) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return false;
        }

        bytes32 parentId = trustedSuperblocks.getSuperblockParentId(superblockHash);
        if (trustedSuperblocks.getSuperblockStatus(parentId) != SyscoinSuperblocks.Status.Approved) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return false;
        }

        (uint err, ) = trustedSuperblocks.confirm(superblockHash, msg.sender);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorClaim(superblockHash, err);
            return false;
        }
        emit SuperblockClaimSuccessful(superblockHash, claim.submitter);
        doPaySubmitter(superblockHash, claim);
        unbondDeposit(superblockHash, claim.submitter);

        if (confirmDescendants) {
            bytes32[] memory descendants = new bytes32[](numSuperblocks);
            id = descendantId;
            uint idx = 0;
            while (id != superblockHash) {
                descendants[idx] = id;
                id = trustedSuperblocks.getSuperblockParentId(id);
                idx += 1;
            }
            while (idx > 0) {
                idx -= 1;
                id = descendants[idx];
                claim = claims[id];
                (err, ) = trustedSuperblocks.confirm(id, msg.sender);
                require(err == ERR_SUPERBLOCK_OK);
                emit SuperblockClaimSuccessful(id, claim.submitter);
                doPaySubmitter(id, claim);
                unbondDeposit(id, claim.submitter);
            }
        }

        return true;
    }

    // @dev – Reject a semi approved superblock.
    //
    // Superblocks that are not in the main chain can be marked as
    // invalid.
    //
    // @param superblockHash – the claim ID.
    function rejectClaim(bytes32 superblockHash) public returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];
        if (!claimExists(claim)) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_CLAIM);
            return false;
        }

        uint height = trustedSuperblocks.getSuperblockHeight(superblockHash);
        bytes32 id = trustedSuperblocks.getBestSuperblock();
        if (trustedSuperblocks.getSuperblockHeight(id) < height + superblockConfirmations) {
            emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_MISSING_CONFIRMATIONS);
            return false;
        }

        id = trustedSuperblocks.getSuperblockAt(height);

        if (id != superblockHash) {
            SyscoinSuperblocks.Status status = trustedSuperblocks.getSuperblockStatus(superblockHash);

            if (status != SyscoinSuperblocks.Status.SemiApproved) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
                return false;
            }

            if (!claim.decided) {
                emit ErrorClaim(superblockHash, ERR_SUPERBLOCK_CLAIM_DECIDED);
                return false;
            }

            trustedSuperblocks.invalidate(superblockHash, msg.sender);
            emit SuperblockClaimFailed(superblockHash, claim.submitter);
            doPayChallengers(superblockHash, claim);
            return true;
        }

        return false;
    }

    // @dev – called when a battle session has ended.
    //
    // @param sessionId – session Id.
    // @param superblockHash - claim Id
    // @param winner – winner of verification game.
    // @param loser – loser of verification game.
    function sessionDecided(bytes32 sessionId, bytes32 superblockHash, address winner, address loser) public onlyBattleManager {
        SuperblockClaim storage claim = claims[superblockHash];

        require(claimExists(claim));

        claim.verificationOngoing = false;

        if (claim.submitter == loser) {
            // the claim is over.
            // Trigger end of verification game
            claim.invalid = true;
        } else if (claim.submitter == winner) {
            // the claim continues.
            // It should not fail when called from sessionDecided
            runNextBattleSession(superblockHash);
        } else {
            revert();
        }

        emit SuperblockBattleDecided(sessionId, winner, loser);
    }

    // @dev - Pay challengers than ran their battles with submitter deposits
    // Challengers that did not run will be returned their deposits
    function doPayChallengers(bytes32 superblockHash, SuperblockClaim storage claim) internal {
        uint rewards = claim.bondedDeposits[claim.submitter];
        claim.bondedDeposits[claim.submitter] = 0;
        uint totalDeposits = 0;
        uint idx = 0;
        for (idx = 0; idx < claim.currentChallenger; ++idx) {
            totalDeposits = totalDeposits.add(claim.bondedDeposits[claim.challengers[idx]]);
        }
        
        address challenger;
        uint reward = 0;
        if(totalDeposits == 0 && claim.currentChallenger > 0){
            reward = rewards.div(claim.currentChallenger);
        }
        for (idx = 0; idx < claim.currentChallenger; ++idx) {
            reward = 0;
            challenger = claim.challengers[idx];
            if(totalDeposits > 0){
                reward = rewards.mul(claim.bondedDeposits[challenger]).div(totalDeposits);
            }
            claim.bondedDeposits[challenger] = claim.bondedDeposits[challenger].add(reward);
        }
        uint bondedDeposit;
        for (idx = 0; idx < claim.challengers.length; ++idx) {
            challenger = claim.challengers[idx];
            bondedDeposit = claim.bondedDeposits[challenger];
            deposits[challenger] = deposits[challenger].add(bondedDeposit);
            claim.bondedDeposits[challenger] = 0;
            emit DepositUnbonded(superblockHash, challenger, bondedDeposit);
        }
    }

    // @dev - Pay submitter with challenger deposits
    function doPaySubmitter(bytes32 superblockHash, SuperblockClaim storage claim) internal {
        address challenger;
        uint bondedDeposit;
        for (uint idx=0; idx < claim.challengers.length; ++idx) {
            challenger = claim.challengers[idx];
            bondedDeposit = claim.bondedDeposits[challenger];
            claim.bondedDeposits[challenger] = 0;
            claim.bondedDeposits[claim.submitter] = claim.bondedDeposits[claim.submitter].add(bondedDeposit);
        }
        unbondDeposit(superblockHash, claim.submitter);
    }

    // @dev - Check if a superblock can be semi approved by calling checkClaimFinished
    function getInBattleAndSemiApprovable(bytes32 superblockHash) public view returns (bool) {
        SuperblockClaim storage claim = claims[superblockHash];
        return (trustedSuperblocks.getSuperblockStatus(superblockHash) == SyscoinSuperblocks.Status.InBattle &&
            !claim.invalid && !claim.verificationOngoing && block.timestamp > claim.challengeTimeout
            && claim.currentChallenger >= claim.challengers.length);
    }

    // @dev – Check if a claim exists
    function claimExists(SuperblockClaim claim) private pure returns (bool) {
        return (claim.submitter != 0x0);
    }

    // @dev - Return a given superblock's submitter
    function getClaimSubmitter(bytes32 superblockHash) public view returns (address) {
        return claims[superblockHash].submitter;
    }

    // @dev - Return superblock submission timestamp
    function getNewSuperblockEventTimestamp(bytes32 superblockHash) public view returns (uint) {
        return claims[superblockHash].createdAt;
    }

    // @dev - Return whether or not a claim has already been made
    function getClaimExists(bytes32 superblockHash) public view returns (bool) {
        return claimExists(claims[superblockHash]);
    }

    // @dev - Return claim status
    function getClaimDecided(bytes32 superblockHash) public view returns (bool) {
        return claims[superblockHash].decided;
    }

    // @dev - Check if a claim is invalid
    function getClaimInvalid(bytes32 superblockHash) public view returns (bool) {
        // TODO: see if this is redundant with superblock status
        return claims[superblockHash].invalid;
    }

    // @dev - Check if a claim has a verification game in progress
    function getClaimVerificationOngoing(bytes32 superblockHash) public view returns (bool) {
        return claims[superblockHash].verificationOngoing;
    }

    // @dev - Returns timestamp of challenge timeout
    function getClaimChallengeTimeout(bytes32 superblockHash) public view returns (uint) {
        return claims[superblockHash].challengeTimeout;
    }

    // @dev - Return the number of challengers whose battles haven't been decided yet
    function getClaimRemainingChallengers(bytes32 superblockHash) public view returns (uint) {
        SuperblockClaim storage claim = claims[superblockHash];
        return claim.challengers.length - (claim.currentChallenger);
    }

    // @dev – Return session by challenger
    function getSession(bytes32 superblockHash, address challenger) public view returns(bytes32) {
        return claims[superblockHash].sessions[challenger];
    }

    function getClaimChallengers(bytes32 superblockHash) public view returns (address[]) {
        SuperblockClaim storage claim = claims[superblockHash];
        return claim.challengers;
    }

    function getSuperblockInfo(bytes32 superblockHash) internal view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        uint _prevTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        SyscoinSuperblocks.Status _status,
        uint32 _height
    ) {
        return trustedSuperblocks.getSuperblock(superblockHash);
    }
}