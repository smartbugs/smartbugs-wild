pragma solidity 0.4.25;
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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable is usingOraclize {
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
        require(msg.sender == owner, 'only owner');
        _;
    }
    modifier notOwner() {
        require(msg.sender != owner, 'only not owner');
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

contract Pausable is Ownable {
    event Pause();
    event Resume();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, 'game is paused');
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to resume, returns to normal state
     */
    function resume() onlyOwner whenPaused public {
        paused = false;
        emit Resume();
    }
}

contract Boom3Rule is Pausable{
    using SafeMath for *;
    
    mapping(uint8 => uint16) public probabilityMap;
    
    constructor () public{
        __initOdds();
    }
    
    function __initOdds() internal{
        // odds by 100 percent
        probabilityMap[3] = uint16(21600); //sum3
        probabilityMap[4] = uint16(7200); //sum4
        probabilityMap[5] = uint16(3600); //sum5
        probabilityMap[6] = uint16(2160); //sum6
        probabilityMap[7] = uint16(1440); //sum7
        probabilityMap[8] = uint16(1029); //sum8
        probabilityMap[9] = uint16(864); //sum9
        probabilityMap[10] = uint16(800); //sum10
        probabilityMap[11] = uint16(800); //sum11
        probabilityMap[12] = uint16(864); //sum12
        probabilityMap[13] = uint16(1029); //sum13
        probabilityMap[14] = uint16(1440); //sum14
        probabilityMap[15] = uint16(2160); //sum15
        probabilityMap[16] = uint16(3600); //sum16
        probabilityMap[17] = uint16(7200); //sum17
        probabilityMap[18] = uint16(21600); //sum18
    }
    
     /**
     * @dev judge user is bet right
     * @param betNumbers user bet numbers
     * @param resultSum sum of result three numbers
     */
    function isBetRight(uint8[] betNumbers, uint8 resultSum) public pure returns (bool){
        for(uint8 i=0; i < betNumbers.length; i++){
            if(betNumbers[i] == resultSum){
                return true;
            }
        }
        return false;
    }
    
    /**
     * @dev calcu three numbers sum
     * @param _numbers result numbers
     */
    function sum(uint8[3] _numbers) public pure returns(uint8){
        return uint8(_numbers[0].add(_numbers[1]).add(_numbers[2]));
    }
    
}

library Boom3datasets {
    struct Player {
        uint256 val;    // winnings vault
        uint256 aff;    // invite rewards
        uint256 lrnd;   // last round played
        uint256 inum;   // invited user count
        address laff;   // last affiliate address used
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to this round
        uint256 keys;   // keys hold 
        uint256 mask;   // player mask in this round
        uint256 ico;    // ICO phase investment
        uint256 gen;    // boom share in this round
        uint256 share;  // share in this round
        uint256[] bets; // user bets
    }
    struct Bet {
        address user;
        uint256 time;
        uint8[] numbers;   // sum numbers
        uint16 odds;       // odds
        uint256 value;
        uint8[3] result;
        bool refund;
    }
    struct Round {
        uint256 start;        // time round started
        uint256 end;          // time ended, 0 means not end
        bool investEnded;     // has round end function been ran
        uint256 eth;          // total eth in
        uint256 pot;          // current eth to pot (during round) / final amount paid to holders (after boom)
        uint256 gen;          // eth value share to keys holders
        uint256 ico;          // invest value
        uint256 keys;         // keys
        uint256 mask;         // global mask
        Bet[] bets;
    }
    struct Phase {
        uint256 round;
        uint256 start;       // time phase started
        uint256 end;         // time ended, 0 means not end
        uint256 eth;         // total eth invest
        uint256 gen;
        uint256 mask;
        uint256 offset;      // offset: when eth not enough for all bet user, then use offset to decrease odds
        uint8[3] numbers;    // the three lottery number in order
    }
}

contract Boom3Events is Boom3Rule {
    
	// fired whenever theres a withdraw
    event onWithdraw
    (
        address indexed playerAddress,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    event onUserValChange
    (
        bytes32 indexed reason,
        address indexed playerAddress,
        uint256 amount
    );
    
}

contract Boom3Lucky is Boom3Events{
    using SafeMath for *;
    
    string constant public name = "Boom3Lucky";
    string constant public symbol = "BOOM3";
    
    uint256 public roundId; // round id
    address public COMMUNITY_ADDRESS = 0xFF1d9dd4B37B879150e43fE364AbBc9310C508D5; // community distribution address
    uint256 public INVEST_TIME = 48 hours;
    uint256 public SINGLE_KEY_PRICE = 0.0005 ether; // fixed price for buy one ticket
    uint256 public MIN_START_ETH_NUM = 30 ether; // when ico value got this, start game
    uint256 public ORACLIZE_GAS_PRICE = 8000000000;
    uint256 public ORACLIZE_GAS_LIMIT = 450000;
    uint256 public ORACLIZE_QUERY_MAXTIME = 6 hours;
    
    //****************
    // PLAYER DATA
    //****************
    mapping (address => Boom3datasets.Player) public playerInfo;   // (uAddr => data) player data
    mapping (address => mapping(uint256 => Boom3datasets.PlayerRounds)) public playerRoundInfo;   // (pID => (rID => roundInfo)) holders info in one round
    mapping (bytes32 => uint256[2]) public randomQueryMap;
    
    //****************
    // ROUND DATA
    //****************
    mapping (uint256 => Boom3datasets.Round) public roundInfo;   // (rID => data) round data
    
    constructor () public{
        __newRound(0);
    }

    /**
     * @dev prevents contracts from interacting with this contract
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
     /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenRoundStart() {
        if(!roundInfo[roundId].investEnded && (block.timestamp - roundInfo[roundId].start) >= INVEST_TIME){
            roundInfo[roundId].investEnded = true;
        }
        require(roundInfo[roundId].investEnded, 'round not start');
        _;
    }
    
    //****************
    // Private Func
    //****************
    
    /**
     * @dev calcu keys by eth value
     */
    function __eth2keys(uint256 _eth) private view returns(uint256){
        return _eth.mul(1000000000000000000) / SINGLE_KEY_PRICE;
    }
    
    /**
     * @dev add keys for user
     * @param _roundId round id
     * @param _user user address
     * @param _keys keys amount to add
     */
    function __addKeys(address _user, uint256 _roundId, uint256 _keys) private{
        playerRoundInfo[_user][_roundId].keys = playerRoundInfo[_user][_roundId].keys.add(_keys);
        roundInfo[_roundId].keys = roundInfo[_roundId].keys.add(_keys);
    }
    
    /**
     * @dev add value for user
     * @param reason  1 win, 2 gen, 3 aff, 4 boom
     * @param _user user address
     */
    function __addVal(bytes32 reason, address _user, uint256 _value) private{
        playerInfo[_user].val = playerInfo[_user].val.add(_value);
        emit onUserValChange(reason, _user, _value);
    }
    
    /**
     * @dev distributes eth based on fees to com, aff
     * @param _rID roundId
     * @param _pID bet user address
     * @param _aff bet value
     */
    function __dealInvite(address _pID, uint256 _rID, uint256 _aff) private {
        address _affID = playerInfo[_pID].laff;
        // decide what to do with affiliate share of fees
        // affiliate must not be self, and must have a name registered
        if (_affID != address(0)) {
            __addVal('aff', _affID, _aff);
            playerInfo[_affID].aff = playerInfo[_affID].aff.add(_aff);
        } else {
            // send aff to round pot
            roundInfo[_rID].pot = roundInfo[_rID].pot.add(_aff);
        }
    }
    
    /**
     * @dev user bet, return 100 times of real odds
     * @param _numbers sum number list
     */
    function __calcuOdds(uint8[] _numbers) private view returns(uint16){
        uint256 _t;
        for(uint16 j = 0; j < _numbers.length; j++){
            require(_numbers[j] >=3 && _numbers[j] <= 18, 'sum type error');
            _t = _t.add(100000000 / probabilityMap[_numbers[j]]);
        }
        return uint16(70000000/ _t);
    }
    
     /**
     * @dev calcu user last round UnMaskedEarnings and add to balance
     * @param _pID user address
     */
    function __dealLastRound(address _pID) private{
        uint256 _rID = playerInfo[_pID].lrnd;
        if( _rID == 0 || _rID == roundId ){
            return;
        }
        if(playerRoundInfo[_pID][_rID].gen != 0){
            return;
        }
        uint256 boomedValue = getBoomShare(_pID, _rID);
        if(boomedValue > 0){
            __addVal("boom", _pID, boomedValue);
            playerRoundInfo[_pID][_rID].gen = boomedValue;
        }
        __addShare(_pID, _rID);
    }
    
    /**
     * @dev calcu UnMaskedEarnings and add to balance
     * @param _pID user address
     * @param _rID roundId
     */
    function __addShare(address _pID, uint256 _rID) private{
        uint256 _unMaskedEarnings = __calcUnMaskedEarnings(_pID, _rID);
        if (_unMaskedEarnings > 0){
            // zero out their earnings by updating mask
            playerRoundInfo[_pID][_rID].mask = playerRoundInfo[_pID][_rID].mask.add(_unMaskedEarnings);
            playerRoundInfo[_pID][_rID].share = playerRoundInfo[_pID][_rID].share.add(_unMaskedEarnings);
            __addVal("share", _pID, _unMaskedEarnings);
        }
    }
    
    /**
     * @dev get result number for current phase
     * @param _index global bet list index
     */
    function __sendRandomQuery(uint256 _index) private returns(bool){
        oraclize_setCustomGasPrice(ORACLIZE_GAS_PRICE);
        uint256 fee = oraclize_getPrice("URL", ORACLIZE_GAS_LIMIT);
        require(roundInfo[roundId].pot >= fee, 'pot balance not enough to use Oraclize');
        bytes32 queryId = oraclize_query("URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data",'\n{"jsonrpc":"2.0","method":"generateIntegers","params":{"apiKey":"00000000-0000-0000-0000-000000000000","n":3,"min":1,"max":6,"replacement":true,"base":10},"id":1}', ORACLIZE_GAS_LIMIT);
        randomQueryMap[queryId] = [roundId, _index];
        roundInfo[roundId].pot = roundInfo[roundId].pot.sub(fee);
        return true;
    }
    
    /**
     * @dev get result number for current phase
     * @param _roundId rid when bet
     * @param betInfo Bet Detail
     */
    function __distributeBetValue(uint256 _roundId, Boom3datasets.Bet betInfo) private{
        address _user = betInfo.user;
        uint256 _value = betInfo.value;
        playerRoundInfo[_user][_roundId].eth  = playerRoundInfo[_user][_roundId].eth.add(_value);
        // 20% can used to buy key
        uint256 _keys = __eth2keys(_value.mul(20)/100);
        __addKeys(_user, _roundId, _keys);
        // 10% to share
        uint256 dust = __updateMasks(_user, _roundId, _value.mul(10)/100, _keys);
        // 5% inviter rewards
        __dealInvite(_user, _roundId,  _value.mul(5) / 100);
        // pay 2% out to community rewards
        COMMUNITY_ADDRESS.transfer(_value.mul(2) / 100);
        // update invest total count in current phase
        // 2% to community and 5% to inviter, 10% to share
        uint256 realValue = _value.mul(83).div(100);
        roundInfo[_roundId].eth = roundInfo[_roundId].eth.add(_value);
        roundInfo[_roundId].pot = roundInfo[_roundId].pot.add(realValue.add(dust));
    }
    
    /**
     * @dev judge is right and deal relate things
     * @param _roundId rid when bet
     * @param betInfo Bet Detail
     */
    function __dealResult(uint256 _roundId, Boom3datasets.Bet memory betInfo) private returns (bool){
        // deal user result
        bool lucky = Boom3Rule.isBetRight(betInfo.numbers, Boom3Rule.sum(betInfo.result));
        if (lucky) {
            uint256 win = betInfo.odds.mul(betInfo.value).div(100);
            if(roundInfo[_roundId].pot >= win){
                roundInfo[_roundId].pot = roundInfo[_roundId].pot.sub(win);
                __addVal("bet", betInfo.user, win);
            }else{
                // send all value to user
                __addVal("bet", betInfo.user, roundInfo[_roundId].pot);
                roundInfo[_roundId].pot = 0;
            }
        }
        // check is got max or min balance
        if(roundInfo[_roundId].pot <= roundInfo[roundId].ico.mul(5).div(10) || roundInfo[_roundId].pot >= roundInfo[roundId].ico.mul(3)){
            __endRound();
        }
        return true;
    }
    
    /**
     * @dev ends the round
     */
    function __endRound() private {
        uint256 _pot = roundInfo[roundId].pot;
        if(_pot > 0 ){
            uint256 _gen = _pot; // share all
            uint256 _res = 0;
            
            // calculate ppt for round mask
            uint256 _ppt = (_gen.mul(1000000000000000000)) / (roundInfo[roundId].keys);
            uint256 _dust = _gen.sub((_ppt.mul(roundInfo[roundId].keys)) / 1000000000000000000);
            if (_dust > 0){
                _gen = _gen.sub(_dust);
                _res = _res.add(_dust);
            }
            
            // distribute pot to key holders
            roundInfo[roundId].gen = _gen;
            roundInfo[roundId].pot = 0;
        }
        
        roundInfo[roundId].end = now;
        __newRound(_res);
    }
    
    /**
     * @dev start new round
     */
    function __newRound(uint256 _res) private {
        // start next round
        roundId++;
        roundInfo[roundId].start = now;
        roundInfo[roundId].pot = _res;
    }
    

    /**
     * @dev updates masks for round and player when keys are bought, called when bet or withdrawn
     * @return dust left over 
     */
    function __updateMasks(address _user, uint256 _rID, uint256 _gen, uint256 _keys) private returns(uint256) {
        // calc profit per key & round mask based on this buy:  (dust goes to pot)
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (roundInfo[_rID].keys);
        roundInfo[_rID].mask = _ppt.add(roundInfo[_rID].mask);
            
        // calculate player earning from their own buy (only based on the keys
        // they just bought).  & update player earnings mask
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        playerRoundInfo[_user][_rID].mask = (((roundInfo[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(playerRoundInfo[_user][_rID].mask);
        
        // calculate & return dust
        return(_gen.sub((_ppt.mul(roundInfo[_rID].keys)) / (1000000000000000000)));
    }
    
    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @param _roundId uint256
     * @param _user user addres
     * @return earnings in wei format
     */
    function __calcUnMaskedEarnings(address _user, uint256 _roundId) private view returns(uint256)
    {
        return(  (((roundInfo[_roundId].mask).mul(playerRoundInfo[_user][_roundId].keys)) / (1000000000000000000)).sub(playerRoundInfo[_user][_roundId].mask)  );
    }
    
    //****************
    // Public Write Func
    //****************
    
    /**
     * @dev init share invest
     */
    function invest(uint256 investValue) public payable isHuman whenNotPaused returns(bool){
        require(roundInfo[roundId].investEnded == false, "init invent ended");
        require( investValue >= 0.01 ether && investValue <= 2 ether, "value not right");
        // calcu current roundId
        uint256 period = (now - roundInfo[roundId].start) / INVEST_TIME;
        if( roundInfo[roundId].ico == 0 && period > 0 ){
            roundId = roundId + period;
            roundInfo[roundId].start = roundInfo[roundId - period].start + period.mul(INVEST_TIME);
        }else{
            require(playerRoundInfo[msg.sender][roundId].ico < 2 ether, "more than user max invent num");
        }
        __dealLastRound(msg.sender);
        require( msg.value.add(playerInfo[msg.sender].val) >= investValue, 'value not enough');
        if(msg.value < investValue){
            playerInfo[msg.sender].val = playerInfo[msg.sender].val.sub(investValue.sub(msg.value));
        }
        // add value
        roundInfo[roundId].eth = roundInfo[roundId].eth.add(investValue);
        roundInfo[roundId].pot = roundInfo[roundId].pot.add(investValue);
        // send keys
        __addKeys(msg.sender, roundId,  __eth2keys(investValue));
        playerRoundInfo[msg.sender][roundId].eth = playerRoundInfo[msg.sender][roundId].eth.add(investValue);
        playerRoundInfo[msg.sender][roundId].ico = playerRoundInfo[msg.sender][roundId].ico.add(investValue);
        roundInfo[roundId].ico = roundInfo[roundId].ico.add(investValue);
        // judge is start the game
        if(roundInfo[roundId].pot >= MIN_START_ETH_NUM){
            roundInfo[roundId].investEnded = true;
        }
        playerInfo[msg.sender].lrnd = roundId;
        return true;
    }
    
    /**
     * @dev user bet
     * @param _numbers , sum list
     * @param inviter inviter address
     */
    function bet(uint8[] _numbers, uint256 betValue, address inviter) public payable isHuman whenNotPaused whenRoundStart returns(bool){
        require( _numbers.length <= 16 , "_numbers length error");
        require( betValue >= 0.05 ether, "bet value error");
        __dealLastRound(msg.sender);
        __addShare(msg.sender, roundId);
        require( msg.value.add(playerInfo[msg.sender].val) >= betValue, 'value not enough');
        if(msg.value < betValue){
            playerInfo[msg.sender].val = playerInfo[msg.sender].val.sub(betValue.sub(msg.value));
        }
        // check value
        playerInfo[msg.sender].lrnd = roundId;
        uint _index = roundInfo[roundId].bets.length;
        roundInfo[roundId].bets.push(
            Boom3datasets.Bet({
                user: msg.sender,
                time: now,
                numbers: _numbers,
                odds: __calcuOdds(_numbers),
                value: betValue,
                result: [0, 0, 0],
                refund: false
            })
        );
        playerRoundInfo[msg.sender][roundId].bets.push(_index);
        // save valid inviter if not inviter before
        if (playerInfo[msg.sender].laff == address(0) && inviter != address(0) && inviter != msg.sender) {
            playerInfo[msg.sender].laff = inviter;
            playerInfo[inviter].inum++;
        }
        // use oraclize
        __sendRandomQuery(_index);
        return true;
    }
    
     /**
     * @dev user get his balance back
     */
    function withdraw() public isHuman whenNotPaused returns(bool){
        address _pID = msg.sender;
        // current round has do ico or bet
        if(playerRoundInfo[_pID][roundId].keys > 0){
            __addShare(_pID, roundId);
        }
        // last round
        __dealLastRound(_pID);
        
        uint256 _val = playerInfo[_pID].val;
        if (_val > 0){
            playerInfo[_pID].val = 0;
            // do transfer
            msg.sender.transfer(_val);
            // fire withdraw event
            emit Boom3Events.onWithdraw(_pID, _val, now);
        }
        return true;
    }
    
    /**
     * @dev in case of oraclize query timeout or error, user can get they money back
     * @param _roundId roundId
     * @param _index betIndex
     */
    function refund(uint256 _roundId, uint256 _index) public isHuman whenNotPaused {
        Boom3datasets.Bet memory betInfo = roundInfo[_roundId].bets[_index]; 
        require(block.timestamp - betInfo.time >= ORACLIZE_QUERY_MAXTIME
			&& (msg.sender == owner || msg.sender == betInfo.user)
			&& !betInfo.refund && betInfo.result[0] == 0);
		roundInfo[_roundId].bets[_index].refund = true;
		betInfo.user.transfer(betInfo.value);
    }
    
    /**
     * @dev callback func for oraclize
     * @param _queryId oraclize queryId
     * @param _numStr random.org response
     */
    function __callback(bytes32 _queryId, string _numStr) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        uint256 _roundId = randomQueryMap[_queryId][0];
        uint256 _index   = randomQueryMap[_queryId][1];
        
        // if user have get money back
        if(roundInfo[_roundId].bets[_index].refund){
            return;
        }
        
        bytes32 _numBytes;
        assembly {
            _numBytes := mload(add(_numStr, 32))
        }
        uint8[3] memory _numbers = [uint8(_numBytes[1]) - 48, uint8(_numBytes[4]) - 48, uint8(_numBytes[7]) - 48];
        roundInfo[_roundId].bets[_index].result = _numbers;
        
        Boom3datasets.Bet memory betInfo = roundInfo[_roundId].bets[_index];
        
        if(roundInfo[_roundId].end > 0){
            // is boomed this round, return bet value to user
            __addVal("refund", betInfo.user, betInfo.value);
            roundInfo[_roundId].bets[_index].refund = true;
            return ;
        }
        
        __distributeBetValue(_roundId, betInfo);
        
        __dealResult(_roundId, betInfo);
    }
    
    //****************
    // Public Read Func
    //****************
    
   /**
     * @dev returns player info based on address.  if no address is given, it will 
     * use msg.sender
     * @param _addr address of the player you want to lookup 
     * @return general vault 
     * @return affiliate vault 
	 * @return player round eth
     */
    function getPlayerInfo(address _addr) public view isHuman returns(uint256, uint256, uint256, uint256, address)
    {
        if (_addr == address(0)){
            _addr == msg.sender;
        }
        uint256 val;
        if(playerRoundInfo[_addr][roundId].keys > 0){
            // this round share
            val = val.add(__calcUnMaskedEarnings( _addr, roundId));
        }else{
            uint256 _rID = playerInfo[msg.sender].lrnd;
            if(_rID > 0){
                val = val.add(__calcUnMaskedEarnings(_addr, _rID));
                if(playerRoundInfo[_addr][_rID].gen == 0){
                    val = val.add(getBoomShare(_addr, _rID));
                }
            }
        }
        
        return (
            playerInfo[_addr].val.add(val),
            playerInfo[_addr].aff,
            playerInfo[_addr].lrnd,
            playerInfo[_addr].inum,
            playerInfo[_addr].laff
        );
    }
    
    /**
     * @dev return user share value in this round
     * @param _addr address of the player you want to lookup 
     * @return share value
     */
    function getShare(address _addr, uint256 _roundId) public view isHuman returns(uint256)
    {
        if(_roundId == 0){
            _roundId = roundId;
        }
        if (_addr == address(0)){
            _addr == msg.sender;
        }
        return playerRoundInfo[_addr][_roundId].share + __calcUnMaskedEarnings(_addr, _roundId);
    }
    
    /**
     * @dev returns player info based on address.  if no address is given, it will 
     * use msg.sender
     * @param _roundId roundId
     * @param _addr address of the player you want to lookup 
     * @return general vault 
     */
    function getBoomShare(address _addr, uint256 _roundId) public view returns(uint256)
    {
        if (_addr == address(0)){
            _addr == msg.sender;
        }
        return (
            roundInfo[_roundId].gen.mul(playerRoundInfo[_addr][_roundId].keys) / roundInfo[_roundId].keys
        );
    }
    
    /**
     * @dev calculate round bet count
     */
    function getRoundBetCount(uint256 _roundId) public view returns (uint256){
        return roundInfo[_roundId].bets.length;
    }
    
    /**
     * @dev get bet detail
     */
    function getRoundBetInfo(uint256 _roundId, uint256 _index) public view returns (address, uint256, uint8[], uint16, uint256, uint8[3], bool){
        require(_index < roundInfo[_roundId].bets.length, 'param index error');
        Boom3datasets.Bet memory _bet =  roundInfo[_roundId].bets[_index];
        return (
            _bet.user,
            _bet.time,
            _bet.numbers,
            _bet.odds,
            _bet.value,
            _bet.result,
            _bet.refund
        );
    }
    
    /**
     * @dev get user bet count
     */
    function getUserBetCount(address _user, uint256 _roundId) public view returns (uint256){
        return playerRoundInfo[_user][_roundId].bets.length;
    }
    
    /**
     * @dev get user bet info index list
     */
    function getUserBetList(address _user, uint256 _roundId, uint256 _start) public view returns (uint256[]){
        uint256 n = playerRoundInfo[_user][_roundId].bets.length;
        require(_start < n, '_start param error');
        uint256[] memory list = new uint256[](_start < 20 ? _start + 1 : 20);
        for(uint256 i = 0; i < 20; i++){
            list[i] = playerRoundInfo[_user][_roundId].bets[_start];
            if(_start > 0){
                _start--;
            }else{
                break;
            }
        }
        return list;
    }
    
    //****************
    // Admin Func
    //****************
    
    function changeMinStartValue(uint256 _value) onlyOwner public returns (bool){
        MIN_START_ETH_NUM = _value;
        return true;
    }
    
    function changeGasPrice(uint256 _price) onlyOwner public returns (bool){
        ORACLIZE_GAS_PRICE = _price;
        return true;
    }
    
    /**
     * @dev in case same situation, manager can share all pot to key holders
     */
    function makeBoomed() onlyOwner public returns (bool){
        __endRound();
        return true;
    }
}