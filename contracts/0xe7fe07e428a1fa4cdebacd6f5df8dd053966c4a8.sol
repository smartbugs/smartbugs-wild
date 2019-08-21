pragma solidity ^0.4.24;
/**
 * Copyright YHT Community.
 * This software is copyrighted by the YHT community.
 * Prohibits any unauthorized copying and modification.
 * It is allowed through ABI calls.
 */

// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary

pragma solidity >=0.4.18;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}

contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}

/*
Begin solidity-cborutils

https://github.com/smartcontractkit/solidity-cborutils

MIT License

Copyright (c) 2018 SmartContract ChainLink, Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint _capacity) internal pure {
        uint capacity = _capacity;
        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(ptr, capacity))
        }
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private pure returns(uint) {
        if(a > b) {
            return a;
        }
        return b;
    }

    /**
     * @dev Appends a byte array to the end of the buffer. Resizes if doing so
     *      would exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {
        if(data.length + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, data.length) * 2);
        }

        uint dest;
        uint src;
        uint len = data.length;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + buffer length + sizeof(buffer length)
            dest := add(add(bufptr, buflen), 32)
            // Update buffer length
            mstore(bufptr, add(buflen, mload(data)))
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     * exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function append(buffer memory buf, uint8 data) internal pure {
        if(buf.buf.length + 1 > buf.capacity) {
            resize(buf, buf.capacity * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Address = buffer address + buffer length + sizeof(buffer length)
            let dest := add(add(bufptr, buflen), 32)
            mstore8(dest, data)
            // Update buffer length
            mstore(bufptr, add(buflen, 1))
        }
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     * exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        if(len + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, len) * 2);
        }

        uint mask = 256 ** len - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Address = buffer address + buffer length + sizeof(buffer length) + len
            let dest := add(add(bufptr, buflen), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length
            mstore(bufptr, add(buflen, len))
        }
        return buf;
    }
}

library CBOR {
    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
        if(value <= 23) {
            buf.append(uint8((major << 5) | value));
        } else if(value <= 0xFF) {
            buf.append(uint8((major << 5) | 24));
            buf.appendInt(value, 1);
        } else if(value <= 0xFFFF) {
            buf.append(uint8((major << 5) | 25));
            buf.appendInt(value, 2);
        } else if(value <= 0xFFFFFFFF) {
            buf.append(uint8((major << 5) | 26));
            buf.appendInt(value, 4);
        } else if(value <= 0xFFFFFFFFFFFFFFFF) {
            buf.append(uint8((major << 5) | 27));
            buf.appendInt(value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {
        buf.append(uint8((major << 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {
        encodeType(buf, MAJOR_TYPE_INT, value);
    }

    function encodeInt(Buffer.buffer memory buf, int value) internal pure {
        if(value >= 0) {
            encodeType(buf, MAJOR_TYPE_INT, uint(value));
        } else {
            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {
        encodeType(buf, MAJOR_TYPE_BYTES, value.length);
        buf.append(value);
    }

    function encodeString(Buffer.buffer memory buf, string value) internal pure {
        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
        buf.append(bytes(value));
    }

    function startArray(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }
}

/*
End solidity-cborutils
 */

contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Android = 0x40;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
      return oraclize_setNetwork();
      networkID; // silence the warning and remain backwards compatible
    }
    function oraclize_setNetwork() internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function __callback(bytes32 myid, string result) public {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) public {
      return;
      myid; result; proof; // Silence compiler warnings
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal pure returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function strCompare(string _a, string _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal pure returns (int) {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    using CBOR for Buffer.buffer;
    function stra2cbor(string[] arr) internal pure returns (bytes) {
        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint i = 0; i < arr.length; i++) {
            buf.encodeString(arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {
        safeMemoryCleaner();
        Buffer.buffer memory buf;
        Buffer.init(buf, 1024);
        buf.startArray();
        for (uint i = 0; i < arr.length; i++) {
            buf.encodeBytes(arr[i]);
        }
        buf.endSequence();
        return buf.buf;
    }

    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {
        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        require((_nbytes > 0) && (_nbytes <= 32));
        // Convert from seconds to ledger timer ticks
        _delay *= 10;
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            // the following variables can be relaxed
            // check relaxed random contract under ethereum-examples repo
            // for an idea on how to override and replace comit hash vars
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly {
            mstore(add(delay, 0x20), _delay)
        }

        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);

        bytes memory delay_bytes8_left = new bytes(8);

        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }

        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));
        return queryId;
    }

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(keccak256(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
        bool sigok;

        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = byte(1); //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        require(proofVerified);

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){
        bool match_ = true;

        require(prefix.length == n_random_bytes);

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {
        uint minLength = length + toOffset;

        // Buffer too small
        require(to.length >= minLength); // Should be a better way?

        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    // Duplicate Solidity's ecrecover, but catching the CALL return value
    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

            // NOTE: we can reuse the request memory because we deal with
            //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

            // Here we are loading the last 32 bytes. We exploit the fact that
            // 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))

            // Alternative solution:
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

    function safeMemoryCleaner() internal pure {
        assembly {
            let fmem := mload(0x40)
            codecopy(fmem, codesize, sub(msize, fmem))
        }
    }

}
// </ORACLIZE_API>


//==============================================================================
// Begin: This part comes from openzeppelin-solidity
//        https://github.com/OpenZeppelin/openzeppelin-solidity
//============================================================================== 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
//==============================================================================
// End: This part comes from openzeppelin-solidity
//==============================================================================


/**
 * @dev YHT interface, for mint and transfer earnings.
 */
contract YHTInterface {
  function mintToFounder(address to, uint256 amount, uint256 normalAmount) external;
  function mintToNormal(address to, uint256 amount, uint256 bonusRoundId) external;
  function transferExtraEarnings(address winner) external payable;
  function transferBonusEarnings() external payable returns(uint256);
  function withdrawForBet(address addr, uint256 value) external;
}

/**
 * The Lottery contract for Printing YHT 
 */
contract Lottery is usingOraclize, Ownable {
  using SafeMath for uint256;
  
  /**
   * @dev betting information for everyone
   */
  struct Bet {
    uint256 cycleCount;     //number of cycles during a bet, if it not equls Lottery.cycleCount the amount is zero
    uint256 amount;         //betting amount
  }
  
  struct BetCycle {
    uint256 amount;
    uint256 bonusRoundId;
  }
  
  struct Referrer {
    uint256 id;
    uint256 bindReferrerId;
    uint256 bindCycleCount;
    uint256 beBindCount;
    uint256 earnings;
  }

//settings begin
  // 41.77% will assigned to winner   
  // 39% will assigned to the people who hold YHT
  // 18% will put in the next prize pool 
  // 1.23% is fee
  uint256 constant private kTenThousand = 10000;                 // all rate is fraction of ten thousand
  uint256 constant private kRewardRate = 4177;                   // the winner will get of the prize pool     
  uint256 constant private kBonusRate = 3900;                    // assigned to peoples who hold YHT
  uint256 constant private kNextInitRate = 1800;                 // put in the next prize pool       
  uint256 constant private kFeeRate = 123;                       // fee 123
  uint256 constant private kReferrerRate = 700;                  // when bet, the referrer will get 7% of bet amount
  uint256 constant private kReferrerEarningsCycleCount = 15;     // promotional earnings only for the specified cycle
  uint8[] private kOpenRewardWeekdays = [ 2, 4, 6 ];             // every Tuesday, Thursday, Saturday open reward
  uint256 constant private kRandomBeforeTime = 3 minutes;        // before time of call Oraclize query function, at this point in time to compute the gas cost
  uint256 constant private kQueryRandomMaxTryCount = 3;          // max fail count of query Oraclize random function, if happen postpone to the next cycle
  uint256 constant private kCallbackTimeout = 90 minutes;        // oraclize callback timeout
  uint256 constant private kGwei = (10 ** 9);                    // 1 Gwei
  uint256 constant private kDefaultGasPrice = 3 * kGwei;         // 3 Gwei
  uint256 constant private kMaxGasPrice = 17 * kGwei;            // 17 Gwei
  
  /**
   * @dev YHT amount of output per cycle, distribute by betting proportion
   */
  uint256 constant private kMintTotalPerCycle = 271828182845904523536028;        
  uint256 constant private kMintHalveCycleCount = 314;           // halved production per 314 cycles       
  uint256 constant private kMintTotalMin = 100 * (10 ** 18);     // production reduced to 100, no longer output
  uint256 constant private kMintFounderAdditionalRate = 382;     // extra 3.82% for each cycle to the founder team
  uint256 constant private kQueryUrlCallbackGas = 150000;        // query url callback gas limits
  uint256 constant private kQueryRandomCallbackBaseFirstGas = 550000;  //query random callback base first gas limits
  uint256 constant private kQueryRandomCallbackBaseGas = 450000; // query random callback base gas limits
  uint256 constant private kQueryRandomCallbackPerGas = 918;     // query random callback per people gas limits 
//settings end

  YHTInterface public YHT;
  
  uint256 public cycleCount_;                                    // current number of cycles
  uint256 public nextOpenRewardTime_;                            // next open reward time
  
  bytes32 private queryId_;                                      // oraclize query id   
  uint256 private queryCallbackGasPrice_ = kDefaultGasPrice;     // gas price for oraclize random query callback, init is 3Gwei
  uint256 private queryTryCount_;                                // count of query Oraclize function
  uint256 public queryRandomTryTime_;                            // query random time
  
  uint256 public initAmount_;                                    // prize pool initial amount, from 15% of previous cycle
  uint256 public betAmount_;                                     // total amount in current cycle, initialization value is 1, so betAmount_ - 1 is actual Amount
  uint256 public betCount_;                                      // bet count of current cycle    
  uint256 public betTotalGasprice_;                              // bet total gas price, used to guss gasprice
  
  mapping(address => Bet) public bets_;                          // betting information of everyone
  mapping(uint256 => BetCycle) public betCycles_;                // bet cycle information
  mapping(uint256 => address) public betAddrs_;                  // all the bet address in current cycle
  uint256 public betAddrsCount_;                                 // the bet address count in current cycle    
  
  mapping(address => Referrer) public referrers_;                // referrer informations
  mapping(uint256 => address) public referrerIdToAddrs_;         // id => address
  uint256 public nextReferrerId_;                                // referrer id counter      
  uint256 public referrerEarnings_;                              // referrer earnings in current cycle

  event GasPriceUpdate(uint256 gasPrice);
  event RandomQuery(uint delay, uint N, uint callbackGas, uint256 gasPrice);
  event RandomSuccess(bytes data, uint256 tryCount);
  event RandomVerifyFailed(bytes data, uint256 tryCount);
  
  event NewBet(address indexed playerAddress, uint256 value, uint256 betValue, uint256 betAmount, uint256 betAddrsCount, uint256 betCount);
  event CycleNew(uint256 cycleCount, uint256 delay, uint256 nextOpenRewardTime, uint256 initAmount);
  event Divided(uint256 cycleCount, uint256 betAmount, uint256 initAmount, uint256 win, uint256 next, uint256 earnings);
  event LuckyMan(uint256 cycleCount, uint256 openRewardTime, address playerAddress, uint256 betValue, uint256 reward);
  event Withdraw(address addr, uint256 value);
  event ObtainReferrerEarnings(address indexed referrerAdress, uint256 beBindCount, address playerAddress, uint256 earnings);

  constructor() public {
  }

  /**
   * @dev make sure only call from Oraclize
   */  
  modifier onlyOraclize {
    require(msg.sender == oraclize_cbAddress());   
    _;
  }
  
  /**
   * @dev make sure no one can interact with contract until it has been activated.   
   */
  modifier isActivated() {
    require(YHT != address(0)); 
    _;
  }

  /**
  * @dev prevents contracts from interacting 
  */
  modifier isHuman() {
    address addr = msg.sender;
    uint256 codeLength;
    
    assembly {codeLength := extcodesize(addr)}
    require(codeLength == 0, "sorry humans only");
    _;
  }
  
  /**
   * @dev check bet value min and max
   */ 
  modifier isBetValueLimits(uint256 value) {
    require(value >= 1672621637, "too small, not a valid currency");  
    require(value < 250000 ether, "so stupid, one thousand SB");  
    _;  
  }
  
  /**
   * @dev check sender is YHT contract
   */ 
  modifier isYHT {
    require(msg.sender == address(YHT));
    _;
  }
  
  /**
   * @dev activate contract, this is a one time.
    pay some for Oraclize query and code execution
   */
  function activate(address yht) onlyOwner public payable  {
    // can only be ran once
    require(YHT == address(0));   
    require(msg.value >= 10 finney);

    // activate the contract                      
    YHT = YHTInterface(yht);

    // Set the proof of oraclize in order to make secure random number generations
    oraclize_setProof(proofType_Ledger);       
    // set oraclize call back gas price
    oraclize_setCustomGasPrice(queryCallbackGasPrice_); 

    // set first cycle 
    cycleCount_ = 1;

    /**
     * use 1 as the initialization value, avoid cost or recycle gas in the query callback
     */
    initAmount_ = 1;
    betAmount_ = 1; 
    betAddrsCount_ = 1;
    betCount_ = 1;
    betTotalGasprice_ = 1;
    queryTryCount_ = 1;
    queryRandomTryTime_ = 1;
    referrerEarnings_ = 1;
  }

  /**
   * @dev check query status, if query callback is not triggered or too later, reactivate
   */ 
  function check() private {
    uint256 nextOpenRewardTime = nextOpenRewardTime_; 
    if (nextOpenRewardTime == 0) {
      update();      
    }
    else if (nextOpenRewardTime < now) {
      if (now - nextOpenRewardTime > kCallbackTimeout && now - queryRandomTryTime_ > kCallbackTimeout) {
        setGasPriceUseTx();  
        checkQueryRandom();
      }
    }
  }
  
  /**
   * @dev get next reward time
   * @param openRewardWeekdays the weekday to be open reward, from small to big, the sunday is 0
   * @param currentTimestamp current time, use it to determine the next lottery time point 
   */
  function getNextOpenRewardTime(uint8[] openRewardWeekdays, uint256 currentTimestamp) pure public returns(uint) {
    uint8 currentWeekday = uint8((currentTimestamp / 1 days + 4) % 7);       
    uint256 morningTimestamp = (currentTimestamp - currentTimestamp % 1 days);
    
    // get number of days offset from next open reward time
    uint256 nextDay = 0;
    for (uint256 i = 0; i < openRewardWeekdays.length; ++i) {
      uint8 openWeekday = openRewardWeekdays[i];
      if (openWeekday > currentWeekday) {
        nextDay = openWeekday - currentWeekday;
        break;
      }
    }

    // not found offset day 
    if (nextDay == 0) {
      uint8 firstOpenWeekday = openRewardWeekdays[0];
      if (currentWeekday == 0) {      // current time is sunday
        assert(firstOpenWeekday == 0);
        nextDay = 7;    
      } 
      else {   
        uint8 remainDays = 7 - currentWeekday;      // the rest of the week
        nextDay = remainDays + firstOpenWeekday;    // add the first open time
      }  
    }
    
    assert(nextDay >= 1 && nextDay <= 7);
    uint256 nextOpenTimestamp = morningTimestamp + nextDay * 1 days;
    assert(nextOpenTimestamp > currentTimestamp);
    return nextOpenTimestamp;
  }  
  
  /**
   * @dev register query callback for cycle
   */
  function update() private {
    queryTryCount_ = 1;
    uint currentTime = now;  

    // not sure if the previous trigger was made in advance, so add a protection
    if (currentTime < nextOpenRewardTime_) {
      currentTime = nextOpenRewardTime_;    
    }
    
    nextOpenRewardTime_ = getNextOpenRewardTime(kOpenRewardWeekdays, currentTime);
    uint256 delay = nextOpenRewardTime_ - now;
    
    // before time of call query random function, at this point in time to compute the gas cost
    if (delay > kRandomBeforeTime) {
      delay -= kRandomBeforeTime;
    }

    queryId_ = oraclize_query(delay, "URL", "", kQueryUrlCallbackGas);
    emit CycleNew(cycleCount_, delay, nextOpenRewardTime_, initAmount_);
  }
  
  /**
   * @dev if has bet do query random, else to next update
   */ 
  function checkQueryRandom() private {
    if (betAmount_ > 1) {
      queryRandom();
    } 
    else {
      update();
    } 
  }
  
  /**
   * @dev set oraclize gas price
   */ 
  function setQueryCallbackGasPrice(uint256 gasPrice) private {
    queryCallbackGasPrice_ = gasPrice;  
    oraclize_setCustomGasPrice(gasPrice);       // set oraclize call back gas price
    emit GasPriceUpdate(gasPrice);   
  }
  
  /**
   * @dev when timeout too long, use tx.gasprice as oraclize callback gas price
   */ 
  function setGasPriceUseTx() private {
    uint256 gasPrice = tx.gasprice;
    if (gasPrice < kDefaultGasPrice) {
      gasPrice = kDefaultGasPrice;        
    } else if (gasPrice > kMaxGasPrice) {
      gasPrice = kMaxGasPrice;    
    }
    setQueryCallbackGasPrice(gasPrice);
  }

  /**
   * @dev set gas price and try query random
   */ 
  function updateGasPrice() private {
    if (betCount_ > 1) {
      uint256 gasPrice =  (betTotalGasprice_ - 1) / (betCount_ - 1);    
      assert(gasPrice > 0);
      setQueryCallbackGasPrice(gasPrice);    
    }
  }
  
  /**
   * @dev Oraclize callback
   */
  function __callback(bytes32 callbackId, string result, bytes proof) onlyOraclize public {
    require(callbackId == queryId_, "callbackId is error");  
    if (queryTryCount_ == 1) {
      updateGasPrice();        
      checkQueryRandom();
    }
    else {
      queryRandomCallback(callbackId, result, proof);       
    }
  }
    
  /**
   * @dev get the query random callback gas cost
   */
  function getQueryRandomCallbackGas() view private returns(uint256) {
    uint256 base = cycleCount_ == 1 ? kQueryRandomCallbackBaseFirstGas : kQueryRandomCallbackBaseGas;  
    return base + betAddrsCount_ * kQueryRandomCallbackPerGas;
  }

  /**
   * @dev compute the gas cost then register query random function
   */
  function queryRandom() private {
    ++queryTryCount_;
    queryRandomTryTime_ = now;
    
    /**
     * base code from https://github.com/oraclize/ethereum-examples/blob/master/solidity/random-datasource/randomExample.sol#L44
     */
    uint256 delay = 0;
    uint256 callbackGas = getQueryRandomCallbackGas();   
    // number of random bytes we want the datasource to return
    // the max range will be 2^(8*N)
    uint256 N = 32;
    
    // generates the oraclize query
    queryId_ = oraclize_newRandomDSQuery(delay, N, callbackGas); 
    emit RandomQuery(delay, N, callbackGas, queryCallbackGasPrice_);
  }
  
  /**
   * @dev Oraclize query random callback
   */  
  function queryRandomCallback(bytes32 callbackId, string result, bytes proof) private  {
    uint256 queryRandomTryCount = queryTryCount_ - 1;   
    bytes memory resultBytes = bytes(result);  
    
    if (resultBytes.length == 0 || oraclize_randomDS_proofVerify__returnCode(callbackId, result, proof) != 0) {
      emit RandomVerifyFailed(resultBytes, queryRandomTryCount);
      
      if (queryRandomTryCount < kQueryRandomMaxTryCount) {
         // try again  
        queryRandom();     
      }
      else {
        // if fails too many, ostpone to the next query       
        update();     
      }
    } 
    else {
      emit RandomSuccess(resultBytes, queryRandomTryCount);      
      // get correct random result, so do the end action
      currentCycleEnd(result);         
    }
  }
    
  /**
   * @dev ends the cycle, mint tokens and randomly out winner
   */
  function currentCycleEnd(string randomResult) private {
    if (betAmount_ > 1) {
      // mint tokens 
      mint();
      // randomly out winner    
      randomWinner(randomResult);
    } 
    else {
      // the amount of betting is zero, to the next query directly   
      update();     
    }
  }
  
  /**
   * @dev get mint count per cycle, halved production per 300 cycles.
   */ 
  function getMintCountOfCycle(uint256 cycleCount) pure public returns(uint256) {
    require(cycleCount > 0);
    // halve times
    uint256 times = (cycleCount - 1) / kMintHalveCycleCount;
    // equivalent to mintTotalPerCycle / 2**times 
    uint256 total = kMintTotalPerCycle >> times; 
    if (total < kMintTotalMin) {
      total = 0;      
    }
    return total;
  }
  
  /**
   * @dev mint tokens, just add total supply and mint extra to founder team.
   * mint for normal player will be triggered in the next transaction, can see checkLastMint function
   */
  function mint() private {
    uint256 normalTotal = getMintCountOfCycle(cycleCount_); 
    if (normalTotal > 0) {
      // extra to the founder team and add total supply
      uint256 founderAmount = normalTotal.mul(kMintFounderAdditionalRate) / kTenThousand;
      YHT.mintToFounder(owner, founderAmount, normalTotal);
    }
  }
  
  /**
   * @dev randomly out winner
   */
  function randomWinner(string randomResult) private {
    require(betAmount_ > 1);  

    // the [0, betAmount) range  
    uint256 value = uint256(sha3(randomResult)) % (betAmount_ - 1);

    // iteration get winner
    uint256 betAddrsCount = betAddrsCount_;
    for (uint256 i = 1; i < betAddrsCount; ++i) {
      address player = betAddrs_[i];    
      assert(player != address(0));
      uint256 weight = bets_[player].amount;
      if (value < weight) {
        // congratulations to the lucky man
        luckyWin(player, weight);
        return;
      }
      value -= weight;
    }

    // can't get here
    assert(false);
  }
  
  /**
   * @dev got winner & dividing the earnings & to next cycle
   */
  function luckyWin(address winner, uint256 betValue) private {
    require(betAmount_ > 1);

    // dividing the earnings
    uint256 betAmount = betAmount_ - 1; 
    uint256 amount = betAmount.add(initAmount_);  
    uint256 win = amount.mul(kRewardRate) / kTenThousand;
    uint256 next = amount.mul(kNextInitRate) / kTenThousand;
    uint256 earnings = amount.mul(kBonusRate) / kTenThousand;
    earnings = earnings.sub(referrerEarnings_ - 1);
    emit Divided(cycleCount_, betAmount, initAmount_, win, next, earnings);
    
    // transfer winner earnings
    YHT.transferExtraEarnings.value(win)(winner);
    emit LuckyMan(cycleCount_, nextOpenRewardTime_, winner, betValue, win);

    // transfer bonus earnings to people who hold YHT
    uint256 bonusRoundId = YHT.transferBonusEarnings.value(earnings)();
    
    // set init amount for next prize pool, clear bet information
    initAmount_ = next; 
    betCycles_[cycleCount_].amount = betAmount;
    betCycles_[cycleCount_].bonusRoundId = bonusRoundId;
    
    betAmount_ = 1;
    betAddrsCount_ = 1;
    betCount_ = 1;
    betTotalGasprice_ = 1;
    referrerEarnings_ = 1;
    
    // add cycleCount and to next
    ++cycleCount_;
    update(); 
  }
  
  /**
   * @dev player transfer to this contract for betting
   */
  function() isActivated isHuman isBetValueLimits(msg.value) public payable {
    bet(msg.sender, msg.value, 0);
  }
  
  /**
   * @dev bet with referrer
   */ 
  function betWithReferrer(uint256 referrerId) isActivated isHuman isBetValueLimits(msg.value) public payable {
    bet(msg.sender, msg.value, referrerId);       
  }
  
  /**
   * @dev use earnings to bet
   */  
  function betFromEarnings(uint256 value, uint256 referrerId) isActivated isHuman isBetValueLimits(value) public {
    YHT.withdrawForBet(msg.sender, value);
    bet(msg.sender, value, referrerId);
  }
  
  /**
   * @dev bet core 
   */
  function bet(address player, uint256 value, uint256 referrerId) private {
    checkMintStatus(player);   
    
    if (bets_[player].cycleCount == 0) {
      // first bet in current cycle, so update information
      bets_[player].cycleCount = cycleCount_;
      bets_[player].amount = value;
      betAddrs_[betAddrsCount_++] = player;

      // check referrer status
      checkReferrer(player, referrerId);
    } else {
      // not first bet in current cycle, add amount
      bets_[player].amount = bets_[player].amount.add(value);        
    }
    
    // update total amount in current cycle
    betAmount_ = betAmount_.add(value);
    
    // update bet count
    ++betCount_;
    
    //transfer earnings to referrer
    transferReferrerEarnings(player, value);
    
    //use to guess gas price
    betTotalGasprice_ = betTotalGasprice_.add(tx.gasprice);
    
    // log event
    emit NewBet(player, value, bets_[player].amount, betAmount_ - 1, betAddrsCount_ - 1, betCount_ - 1);
    
    // check status, sometime query maybe failed
    check();
  }
  
  /**
   * @dev check referrer in first bet, only first bet can bind referrer
   */ 
  function checkReferrer(address player, uint256 referrerId) private {
    if (referrers_[player].id == 0) {
      uint256 id = ++nextReferrerId_;       
        
      address referrerAddr = referrerIdToAddrs_[referrerId];
      if (referrerAddr != address(0)) {
        referrers_[player].bindReferrerId = referrerId;
        referrers_[player].bindCycleCount = cycleCount_;     
        ++referrers_[referrerAddr].beBindCount;
      }
      
      referrers_[player].id = id;
      referrerIdToAddrs_[id] = player;
    }
  }
  
  /**
   * @dev transfer earnings to referrer if has bind
   */ 
  function transferReferrerEarnings(address player, uint256 betValue) private {
    uint256 bindReferrerId = referrers_[player].bindReferrerId;
    if (bindReferrerId != 0) {
      uint256 bindCycleCount =  referrers_[player].bindCycleCount;
      // promotional earnings only for the specified cycle
      if (cycleCount_ - bindCycleCount < kReferrerEarningsCycleCount) {
        address referrerAddr = referrerIdToAddrs_[bindReferrerId];    
        assert(referrerAddr != address(0));
        uint256 earnings = betValue.mul(kReferrerRate) / kTenThousand; 
        referrers_[referrerAddr].earnings = referrers_[referrerAddr].earnings.add(earnings);
        referrerEarnings_ = referrerEarnings_.add(earnings); 
        emit ObtainReferrerEarnings(referrerAddr, referrers_[referrerAddr].beBindCount, player, earnings);
      } else {
         // recycling gas
         referrers_[player].bindReferrerId = 0;
         referrers_[player].bindCycleCount = 0;
      }
    }
  }
  
  /**
   * @dev get referrer earnings    
   */ 
  function getReferrerEarnings(address addr) view external returns(uint256) {
    return referrers_[addr].earnings;       
  }
  
  /**
   * @dev withdraw referrer earnings if exists
   */ 
  function checkReferrerEarnings(address addr) isYHT external {
    uint256 earnings = referrers_[addr].earnings;
    if (earnings > 0) {
       referrers_[addr].earnings = 0;
       YHT.transferExtraEarnings.value(earnings)(addr);
    }
  }
  
  /**
   * @dev get player last mint status
   */ 
  function getMintStatus(address addr) view private returns(uint256, uint256, bool) {
    uint256 lastMinAmount = 0;
    uint256 lastBonusRoundId = 0;
    bool isExpired = false;
      
    uint256 lastCycleCount = bets_[addr].cycleCount;   
    if (lastCycleCount != 0) {
      // if not current cycle, need mint token    
      if (lastCycleCount != cycleCount_) {
        uint256 lastTotal = getMintCountOfCycle(lastCycleCount);
        if (lastTotal > 0) {
          lastMinAmount = bets_[addr].amount.mul(lastTotal) / betCycles_[lastCycleCount].amount;
          lastBonusRoundId = betCycles_[lastCycleCount].bonusRoundId;
          assert(lastBonusRoundId != 0);
        }
        isExpired = true;
      }         
    }
    
    return (lastMinAmount, lastBonusRoundId, isExpired);
  }
  
  /**
   * @dev check player last mint status, mint for player if necessary
   */ 
  function checkMintStatus(address addr) private {
    (uint256 lastMinAmount, uint256 lastBonusRoundId, bool isExpired) = getMintStatus(addr);  
    if (lastMinAmount > 0) {
      YHT.mintToNormal(addr, lastMinAmount, lastBonusRoundId);
    }
    
    if (isExpired) {
      bets_[addr].cycleCount = 0;
      bets_[addr].amount = 0; 
    }
  }
  
  /**
   * @dev check last mint used by the YHT contract
   */ 
  function checkLastMintData(address addr) isYHT external {
    checkMintStatus(addr);  
  }
  
  /**
   * @dev clear warnings for unused variables
   */ 
  function unused(bool) pure private {} 
  
  /**
   * @dev get last mint informations used by the YHT contract
   */ 
  function getLastMintAmount(address addr) view external returns(uint256, uint256) {
    (uint256 lastMinAmount, uint256 lastBonusRoundId, bool isExpired) = getMintStatus(addr);
    unused(isExpired);
    return (lastMinAmount, lastBonusRoundId);
  }
  
 /**
  * @dev deposit  
  * In extreme cases, the remaining amount may not be able to pay the callback charges, everyone can reactivate
  */ 
  function deposit() public payable {
  }

  /**
   * @dev withdraw total fees to the founder team
   */
  function withdrawFee() onlyOwner public {
    uint256 gas = kQueryUrlCallbackGas + getQueryRandomCallbackGas();
    
    // the use of Oraclize requires the payment of a small fee
    uint256 remain = gas * queryCallbackGasPrice_ + 500 finney;   

    // total amount of Prize pool
    uint256 amount = (betAmount_ - 1).add(initAmount_); 

    // the balance available
    uint256 balance = address(this).balance.sub(amount).sub(remain);
    msg.sender.transfer(balance);
    emit Withdraw(msg.sender, balance);
  }

  /**
   * @dev get player bet value
   */
  function getPlayerBetValue(address addr) view public returns(uint256) {
    return bets_[addr].cycleCount == cycleCount_ ? bets_[addr].amount : 0;   
  } 
  
  /**
   * @dev get player informations at once
   */  
  function getPlayerInfos(address addr) view public returns(uint256[7], uint256[5]) {
    uint256[7] memory betValues = [
       cycleCount_,
       nextOpenRewardTime_,
       initAmount_,
       betAmount_ - 1,
       betAddrsCount_ - 1,
       betCount_ - 1,
       getPlayerBetValue(addr)
    ];
    uint256[5] memory referrerValues = [
      nextReferrerId_,
      referrers_[addr].id,
      referrers_[addr].bindReferrerId,
      referrers_[addr].bindCycleCount,
      referrers_[addr].beBindCount
    ];
    return (betValues, referrerValues);
  }
}