pragma solidity ^0.4.24;

/*

 /$$      /$$                               /$$$$$$$            /$$ /$$     /$$
| $$$    /$$$                              | $$__  $$          | $$| $$    |__/
| $$$$  /$$$$  /$$$$$$   /$$$$$$   /$$$$$$ | $$  \ $$  /$$$$$$ | $$| $$     /$$  /$$$$$$
| $$ $$/$$ $$ /$$__  $$ /$$__  $$ |____  $$| $$$$$$$  |____  $$| $$| $$    | $$ /$$__  $$
| $$  $$$| $$| $$$$$$$$| $$  \ $$  /$$$$$$$| $$__  $$  /$$$$$$$| $$| $$    | $$| $$  \ $$
| $$\  $ | $$| $$_____/| $$  | $$ /$$__  $$| $$  \ $$ /$$__  $$| $$| $$    | $$| $$  | $$
| $$ \/  | $$|  $$$$$$$|  $$$$$$$|  $$$$$$$| $$$$$$$/|  $$$$$$$| $$| $$ /$$| $$|  $$$$$$/
|__/     |__/ \_______/ \____  $$ \_______/|_______/  \_______/|__/|__/|__/|__/ \______/
                        /$$  \ $$
                       |  $$$$$$/
                        \______/


 [x] Probably Fair
 [x] Open Source
 [x] best referral system evar
 [x] 2 games in 1
 [x] Better than your mom's lottery, grandma's bingo, or poppop's ponies
 [x] made with <3.add(hate)

 Play it!

 Or don't?

 Nobody cares.

*/


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
      // Following should never be reached with a preceding return, however
      // this is just a placeholder function, ideally meant to be defined in
      // child contract when proofs are used
      myid; result; proof; // Silence compiler warnings
      oraclize = OraclizeI(0); // Additional compiler silence about making function pure/view.
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

    function getCodeSize(address _addr) view internal returns(uint _size) {
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

        oraclize_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));
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
        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(context_name, queryId)))))) return false;

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
        if (oraclize_randomDS_args[queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))){ //unonce, nbytes and sessionKeyHash match
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

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {

/**
* @dev Multiplies two numbers, throws on overflow.
*/
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add2(uint8 a, uint8 b)
        internal
        pure
        returns (uint8 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }


    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      // uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}


/* solhint-disable var-name-mixedcase */
/* solhint-disable const-name-snakecase */
/* solhint-disable code-complexity */
/* solhint-disable max-line-length */
/* solhint-disable func-name-mixedcase */


contract MegaBall is usingOraclize {
    using SafeMath for uint;
    ReferralInterface constant public referralContract = ReferralInterface(address(0x0bfb5147e4b459200edb21e220a3dc4137d01028));
    HourglassInterface constant public p3dContract = HourglassInterface(address(0xb3775fb83f7d12a36e0475abdd1fca35c091efbe));
    DiviesInterface constant private Divies = DiviesInterface(address(0xC0c001140319C5f114F8467295b1F22F86929Ad0));

    address constant public NULL_ADDRESS = address(0x000000000000000000000000000000000000000);
    /* main game events */
    event DrawValid(bool indexed status);
    event ReadyToFinalize(bool indexed isFinal);
    event TicketCreated(address indexed ticketOwner, address indexed ticketReferral, uint indexed stage);
    event StageCreated(uint indexed stageNumber);
    /* side game events */
    event RaffleWinnerPick(address indexed user, uint amount, uint indexed stage);
    event RaffleEntry(address indexed user, uint block);
    /* user withdraw event */
    event OnWithdraw(address indexed customerAddress, uint256 ethereumWithdrawn);

    /* modifiers */
    modifier hasBalance() {
        require(moneyballVault[msg.sender] > 0);
        _;
    }

    modifier onlyActiveStages(uint256 _stage) {
        require(_stage == SafeMath.sub(numberOfStages, 1));
        _;
    }

    modifier onlyAvailableStages(uint256 _stage) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        _;
    }

    modifier isValidRedemptionPeriod(uint256 _stage) {
        require(stages[_stage].redemptionEnd > now);
        _;
    }

    /*
      each stage has isolated predetermined price allocation
    */
    struct Payouts {
        uint256 NO_MONEYBALL_3_MATCHES;
        uint256 NO_MONEYBALL_4_MATCHES;
        uint256 NO_MONEYBALL_5_MATCHES;
        uint256 MONEYBALL_BASE_MATCHES;
        uint256 MONEYBALL_2_MATCHES;
        uint256 MONEYBALL_3_MATCHES;
        uint256 MONEYBALL_4_MATCHES;
        uint256 MONEYBALL_5_MATCHES;
    }

    /*
      each stage has isolated predetermined fund allocation on ticket purchase
      lotteryPortion/rafflePortion are same value can ditch for space
    */
    struct Splits {
        uint256 INCOMING_FUNDS_REFERRAL_SHARE;
        uint256 INCOMING_FUNDS_P3D_SHARE;
        uint256 INCOMING_FUNDS_LOTTERY_SHARE;
        uint256 INCOMING_FUNDS_RAFFLE_SHARE;
        uint256 INCOMING_FUNDS_DIVI_PORTION;
        uint256 INCOMING_DENOMINATION;
    }

    /* tickets are an individual entity */
    struct Ticket {
        uint8 n1;
        uint8 n2;
        uint8 n3;
        uint8 n4;
        uint8 n5;
        uint8 pb;
        uint8 numMatches;
        bool pbMatches;
        bool isRedeemed;
        bool isValidated;
        address owner;
    }

    /* Drawblocks represent future blocks in each stage */
    struct DrawBlocks {
        uint256 blocknumber1;
        uint256 blocknumber2;
        uint256 blocknumber3;
        uint256 blocknumber4;
        uint256 blocknumber5;
        uint256 blocknumberpb;
    }

    /* stages manage drawings, tickets, and peg round denominations */
    struct Stage {
        bool stageCompleted;
        Ticket finalTicket;
        DrawBlocks drawBlocks;
        bool allowTicketPurchases;
        bool readyToFinalize;
        bool isDrawFinalized;
        uint256 startBlock;
        uint256 endBlock;
        Payouts stagePayouts;
        Splits stageSplits;
        uint256 drawDate;
        uint256 redemptionEnd;
        mapping(address => Ticket[]) playerTickets;
    }

    mapping (address => uint256) private moneyballVault;

    /*
      fund allocation
    */
    uint256 public lotteryPortion = 0;
    uint256 public rafflePortion = 0;
    uint256 public buyP3dFunds = 0;
    uint256 public dividendFunds = 0;

    /*
      stage tracking and allocation
    */
    mapping(uint256 => Stage) public stages;
    uint256 public numberOfStages = 0;
    mapping(uint256 => address[]) public raffleDrawings;

    /* tickets for raffle */
    mapping(address => uint256) private playerRaffleTickets;

    uint256 public raffleTicketsPerDraw = 10;
    uint256 public raffleTicketsRewardPerBuy = 5;

    /* admin address, init in constructor */
    address public owner;

    /* eth to usd */
    uint256 public ETH_TO_USD = 0;

    /* starting denomination */
    uint256 public DENOMINATION = 7000000000000000;

    /* ticket price never goes below the floor */
    uint256 constant public denominationFloor = 10000000000000;
    /* ticket price never goes above the ceiling */
    uint256 constant public denominationCeiling = 10000000000000000000;

    /* 3 days */
    uint256 public drawingTimeOffset = 259200;
    uint256 public drawActiveTimestamp;

    /*
      active denomination can be update once per stage
      rewards sidegame draw tickets to msg.sender
      this is used for the next round entry cost to keep it flat
      vs the cost of USD and avoid spikes in jackpot value
    */
    uint256 public denominationUpdateTimeOffset = 0;
    uint256 public denominationActiveTimestamp;

    /* may want some direct eth/usd access in future for UI?, not tied into any logic */
    string public ethUsdUrl = 'json(https://api.coinmarketcap.com/v1/ticker/ethereum/?convert=USD).0.price_usd';

    constructor() public {
        owner = msg.sender;
    }

    /*
      Game is waiting until owner gives the go ahead
    */
    function initFirstStage()
    public
    {
        require(msg.sender == owner);
        require(numberOfStages == 0);

        denominationUpdateTimeOffset = SafeMath.div(drawingTimeOffset, 2);
        drawActiveTimestamp = SafeMath.sub(now, 100);
        denominationActiveTimestamp = SafeMath.sub(now, 100);

        CreateStage();
    }

    /*
      all money sent directly to contract from hourglass goes to side game fund
      its expected this will be p3d dividends, otherwise apply
      to p3dbuy balance
    */
    function()
    public
    payable
    {
        if (msg.sender != address(p3dContract)) {
            buyP3dFunds = buyP3dFunds.add(msg.value);
        }
    }

    function withdraw()
    external
    hasBalance
    {
        uint256 amount = moneyballVault[msg.sender];
        moneyballVault[msg.sender] = 0;

        emit OnWithdraw(msg.sender, amount);
        msg.sender.transfer(amount);
    }

    function __callback(bytes32 myid, string result) public {

        if (msg.sender != oraclize_cbAddress()) revert();
        /* not used for any logic */
        uint256 LOCAL_ETH_TO_USD = parseInt(result, 0);

    }

    function updateDenomination()
    external
    {
        require(denominationActiveTimestamp < now);
        require(numberOfStages > 4);
        denominationActiveTimestamp = SafeMath.add(now, denominationUpdateTimeOffset);
        uint256 USD_DENOM = calcEntryFee();

        if (USD_DENOM > denominationFloor && USD_DENOM < denominationCeiling) {
            DENOMINATION = USD_DENOM;
            playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].add(5);
        }
    }

    function updatePrice() public payable {
        require(msg.sender == owner);
        if (oraclize_getPrice("URL") < msg.value) {
            oraclize_query("URL", ethUsdUrl);
        }
    }


    function seedJackpot()
    public
    payable
    {
        require(msg.value >= 100000000000000000);
        uint256 incomingSplit = SafeMath.div(msg.value, 10);
        uint256 fiftyPercent = SafeMath.mul(incomingSplit, 5);
        uint256 thirtyPercent = SafeMath.mul(incomingSplit, 3);
        uint256 twentyPercent = SafeMath.mul(incomingSplit, 2);
        buyP3dFunds = buyP3dFunds.add(fiftyPercent);
        rafflePortion = rafflePortion.add(thirtyPercent);
        lotteryPortion = lotteryPortion.add(twentyPercent);
        buyP3d(msg.sender);
    }

    function createTicket(uint256 _stage,
    uint8 n1,
    uint8 n2,
    uint8 n3,
    uint8 n4,
    uint8 n5,
    uint8 pb,
    address _referredBy)
    external
    payable
    onlyActiveStages(_stage)
    {
        /* ensure drawing is open */
        require(stages[_stage].allowTicketPurchases);

        /* ensure drawing timestamp has not been surpassed */
        //require(now < stages[_stage].drawDate, "beyond draw date");

        /* ensure its proper value for given stage */
        require(msg.value == stages[_stage].stageSplits.INCOMING_DENOMINATION);

         /* ensure no matches between block of draws TC-0001 */
        require(isDrawValid(n1, n2, n3, n4, n5, pb));

        /* cant ref yourself or NULL */
        require(_referredBy != NULL_ADDRESS);
        require(_referredBy != msg.sender);

        /*
          not registered as referral user, assumed to be;
          megaball.io users, 3rd party app/ui/mobile creators,
          buy/aquire p3d funds to help secure the game
        */

        if (referralContract.isAnOwner(_referredBy) == false) {
            /* eth to games */
            lotteryPortion = lotteryPortion.add(stages[_stage].stageSplits.INCOMING_FUNDS_LOTTERY_SHARE);
            rafflePortion = rafflePortion.add(stages[_stage].stageSplits.INCOMING_FUNDS_RAFFLE_SHARE);
            /* eth to referral */
            moneyballVault[_referredBy] = moneyballVault[_referredBy].add(stages[_stage].stageSplits.INCOMING_FUNDS_REFERRAL_SHARE);
            /* eth to p3d */
            buyP3dFunds = buyP3dFunds.add(stages[_stage].stageSplits.INCOMING_FUNDS_P3D_SHARE);
            dividendFunds = dividendFunds.add(stages[_stage].stageSplits.INCOMING_FUNDS_DIVI_PORTION);
        }

        /*
          registered as referral user, contract sends all P3D allocation to DiviesInterface
          when user is not in referralContract Interface
        */
        if (referralContract.isAnOwner(_referredBy) == true) {
          /* eth to games */
          lotteryPortion = lotteryPortion.add(stages[_stage].stageSplits.INCOMING_FUNDS_LOTTERY_SHARE);
          rafflePortion = rafflePortion.add(stages[_stage].stageSplits.INCOMING_FUNDS_RAFFLE_SHARE);
          /* eth to referral */
          moneyballVault[_referredBy] = moneyballVault[_referredBy].add(stages[_stage].stageSplits.INCOMING_FUNDS_REFERRAL_SHARE);
          /* eth to p3d divi */
          dividendFunds = dividendFunds.add(stages[_stage].stageSplits.INCOMING_FUNDS_P3D_SHARE);
          dividendFunds = dividendFunds.add(stages[_stage].stageSplits.INCOMING_FUNDS_DIVI_PORTION);
        }

        /*
        require(stages[_stage].allowTicketPurchases, "ticket purchases disabled");
        require(now < stages[_stage].drawDate, "beyond draw date");
        require(msg.value == stages[_stage].stageSplits.INCOMING_DENOMINATION, "price invalid");
        require(isDrawValid(n1, n2, n3, n4, n5, pb), "numbers invalid");
        require(_referredBy != NULL_ADDRESS, "referral invalid");
        require(_referredBy != msg.sender, "referral invalid");
        */

        Ticket memory ticket = Ticket(n1, n2, n3, n4, n5, pb, 0, false, false, false, msg.sender);

        /* push ticket into users stage def */
        stages[_stage].playerTickets[msg.sender].push(ticket);

        /* allocate a sidegame entry */
        playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].add(raffleTicketsRewardPerBuy);
        emit TicketCreated(msg.sender, _referredBy, _stage);
    }

    function p3dDividends()
    public
    view
    returns (uint)
    {
        return p3dContract.myDividends(true);
    }

    function p3dBalance()
    public
    view
    returns (uint)
    {
        return p3dContract.balanceOf(this);
    }

    function getDrawBlocknumbers(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint, uint, uint, uint, uint, uint) {
        return (stages[_stage].drawBlocks.blocknumber1,
        stages[_stage].drawBlocks.blocknumber2,
        stages[_stage].drawBlocks.blocknumber3,
        stages[_stage].drawBlocks.blocknumber4,
        stages[_stage].drawBlocks.blocknumber5,
        stages[_stage].drawBlocks.blocknumberpb,
        block.number);
    }

    /* use this in tests to check finalize status */
    function isFinalizeValid(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (bool)
    {
      /* must be ready to finalize, this is set by setdraw blocks user function */
        require(stages[_stage].readyToFinalize);

        //require(stages[_stage].drawBlocks.blocknumberpb < block.number, "blocks must be surpassed");
        /* get current stage */
        Stage storage stageToFinalize = stages[_stage];

        /* make sure we can get hash of oldest draw */
        uint256 blockScope = SafeMath.sub(block.number, stages[_stage].drawBlocks.blocknumberpb);


        /* get the blockhashes of draw numbers */
        uint8 n1 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber1)) % 68));
        uint8 n2 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber2)) % 68));
        uint8 n3 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber3)) % 68));
        uint8 n4 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber4)) % 68));
        uint8 n5 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber5)) % 68));
        uint8 pb = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumberpb)) % 25));

        if (isDrawValid(n1, n2, n3, n4, n5, pb) && blockScope < 200) {return true;}

        return false;
    }

    /* finalize stage */
    function finalizeStage(uint256 _stage)
    external
    onlyActiveStages(_stage)
    {
        require(stages[_stage].readyToFinalize);
        require(!stages[_stage].isDrawFinalized);
        require(stages[_stage].drawBlocks.blocknumberpb < block.number);
        require(stages[_stage].drawDate < now);
        /*
        require(stages[_stage].readyToFinalize, "stage must be rdy to finalize");
        require(!stages[_stage].isDrawFinalized, "draw cannot be finalize");
        require(stages[_stage].drawBlocks.blocknumberpb < block.number, "blocks must be surpassed");
        require(stages[_stage].drawDate < now, "block time condition not met");
        */

        Stage storage stageToFinalize = stages[_stage];

        /* get the blockhashes of draw numbers */
        uint8 n1 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber1)) % 68));
        uint8 n2 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber2)) % 68));
        uint8 n3 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber3)) % 68));
        uint8 n4 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber4)) % 68));
        uint8 n5 = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumber5)) % 68));
        uint8 pb = SafeMath.add2(1, (uint8(blockhash(stageToFinalize.drawBlocks.blocknumberpb)) % 25));

        /* max number of blocks before draw resets */
        uint256 blockScope = SafeMath.sub(block.number, stages[_stage].drawBlocks.blocknumberpb);

        /* isdrawvalid checks boundries of numbers and ensures n1-n5 dont match */
        if (isDrawValid(n1, n2, n3, n4, n5, pb) && blockScope < 200) {
            Ticket memory ticket = Ticket(n1, n2, n3, n4, n5, pb, 0, false, false, false, NULL_ADDRESS);

            /* set drawing ticket, set draw final, set stage complete, emit */
            stages[_stage].finalTicket = ticket;
            stages[_stage].isDrawFinalized = true;
            stages[_stage].stageCompleted = true;
            stages[_stage].endBlock = block.number;
            emit DrawValid(true);

            /* allocate sidegame draws to finalizer */
            playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].add(raffleTicketsPerDraw);

            /* do raffle */
            uint256 playerCount = raffleDrawings[_stage].length;
            doRaffle(_stage, playerCount);

            /* we are gtg for a new stage */
            CreateStage();

        } else {
            /* reward invalid draws if necessary, low player count could repeatedly invalidate draws */
            playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].add(5);

            /* draw in valid, redo it */
            emit DrawValid(false);
            /* push draw blocks out */
            resetDrawBlocks(_stage);
        }
    }

    /*
    *   this can only be called once per round/stage for a reward by users
    *   blocks will get reset until a finalstate can be found with different function
    */
    function setDrawBlocks(uint256 _stage)
    external
    onlyActiveStages(_stage)
    {
        /* you can only interact with this function once per stage */
        require(stages[_stage].allowTicketPurchases);

        /* Must reach next draw period for stage before advancing  */
        require(stages[_stage].drawDate < now);

        /* can only be run manually once for reward */
        require(!stages[_stage].readyToFinalize);
        emit ReadyToFinalize(true);

        /* commit stage finalize structs */
        stages[_stage].allowTicketPurchases = false;
        stages[_stage].readyToFinalize = true;
        stages[_stage].drawBlocks.blocknumber1 = SafeMath.add(block.number, 11);
        stages[_stage].drawBlocks.blocknumber2 = SafeMath.add(block.number, 12);
        stages[_stage].drawBlocks.blocknumber3 = SafeMath.add(block.number, 13);
        stages[_stage].drawBlocks.blocknumber4 = SafeMath.add(block.number, 14);
        stages[_stage].drawBlocks.blocknumber5 = SafeMath.add(block.number, 15);
        stages[_stage].drawBlocks.blocknumberpb = SafeMath.add(block.number, 16);

        /* set draw block user gets free draw at sidegame */
        playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].add(raffleTicketsPerDraw);
    }

    /* get no MB match payouts */
    function getPayoutsNMB(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint, uint) {
        return (stages[_stage].stagePayouts.NO_MONEYBALL_3_MATCHES,
        stages[_stage].stagePayouts.NO_MONEYBALL_4_MATCHES,
        stages[_stage].stagePayouts.NO_MONEYBALL_5_MATCHES);
    }

    /* gets MB match payouts */
    function getPayoutsMB(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint, uint, uint, uint) {
        return (
        stages[_stage].stagePayouts.MONEYBALL_BASE_MATCHES,
        stages[_stage].stagePayouts.MONEYBALL_2_MATCHES,
        stages[_stage].stagePayouts.MONEYBALL_3_MATCHES,
        stages[_stage].stagePayouts.MONEYBALL_4_MATCHES,
        stages[_stage].stagePayouts.MONEYBALL_5_MATCHES);
    }

    /* get number of players in raffle drawing */
    function getRafflePlayerCount(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint)
    {
        return raffleDrawings[_stage].length;
    }

    /* get stage denom */
    function getStageDenomination(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint)
    {
        return stages[_stage].stageSplits.INCOMING_DENOMINATION;
    }

    /* get stage blocks */
    function getStageBlocks(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint)
    {
        return (stages[_stage].startBlock, stages[_stage].endBlock);
    }

    function checkRedemptionPeriod(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint, uint)
    {
        return ( stages[_stage].drawDate, stages[_stage].redemptionEnd, now);
    }

    function getStageStatus(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (bool, bool, bool, bool)
    {
        return (stages[_stage].stageCompleted, stages[_stage].readyToFinalize, stages[_stage].isDrawFinalized, stages[_stage].allowTicketPurchases);
    }

    /* get tickets for msg sender by stage an ticket position */
    function getTicketByPosition(uint256 _stage, uint256 _position)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint, uint, uint, uint, uint)
    {
        return (stages[_stage].playerTickets[msg.sender][_position].n1,
        stages[_stage].playerTickets[msg.sender][_position].n2,
        stages[_stage].playerTickets[msg.sender][_position].n3,
        stages[_stage].playerTickets[msg.sender][_position].n4,
        stages[_stage].playerTickets[msg.sender][_position].n5,
        stages[_stage].playerTickets[msg.sender][_position].pb);
    }

    /* allow ticket lookups, external service can index and search more easily */
    function getTicket(uint256 _stage, uint256 _position, address _player)
    public
    view
    returns (uint, uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        return (stages[_stage].playerTickets[_player][_position].n1,
        stages[_stage].playerTickets[_player][_position].n2,
        stages[_stage].playerTickets[_player][_position].n3,
        stages[_stage].playerTickets[_player][_position].n4,
        stages[_stage].playerTickets[_player][_position].n5,
        stages[_stage].playerTickets[_player][_position].pb);
    }


    /* get drawn ticket for a given stage */
    function getDrawnTicket(uint256 _stage)
    public
    view
    returns (uint, uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        return (stages[_stage].finalTicket.n1,
        stages[_stage].finalTicket.n2,
        stages[_stage].finalTicket.n3,
        stages[_stage].finalTicket.n4,
        stages[_stage].finalTicket.n5,
        stages[_stage].finalTicket.pb);
    }

    /* get ticket count for stage for msg.sender */
    function getTicketCount(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint256)
    {
        return stages[_stage].playerTickets[msg.sender].length;
    }

    /* check redeem status */
    function isTicketRedeemed(uint256 _stage, uint256 _position)
    public
    view
    onlyAvailableStages(_stage)
    returns (bool)
    {
        return stages[_stage].playerTickets[msg.sender][_position].isRedeemed;
    }

    function stageMoveDetail(uint256 _stage)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint, uint)
    {
        uint256 blocks = 0;
        uint256 time = 0;

        if (stages[_stage].drawBlocks.blocknumberpb > block.number)
        {
            blocks = stages[_stage].drawBlocks.blocknumberpb - block.number;
            blocks++;
        }

        if (stages[_stage].drawDate > now)
        {
            time = stages[_stage].drawDate - now;
            time++;
        }

        return ( blocks, time );
    }

    /*
    *   validate and claim ticket can be run on any ticket
    *   its only intended to be run by owner on a winning ticket
    *   UI determines this for the user
    */
    function validateAndClaimTicket(uint256 _stage, uint256 position)
    external
    isValidRedemptionPeriod(_stage)
    onlyAvailableStages(_stage)
    {
        /* draw for stage must have occured */
        require(stages[_stage].isDrawFinalized);

        /* only ticket owner can call this function */
        require(stages[_stage].playerTickets[msg.sender][position].owner == msg.sender);

        /* tix not validated */
        require(stages[_stage].playerTickets[msg.sender][position].isValidated == false);
        /* player is msg.sender */
        address player = stages[_stage].playerTickets[msg.sender][position].owner;

        /* allocate count var */
        uint8 count = 0;

        /* count matches */
        if (checkPlayerN1(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN2(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN3(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN4(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN5(_stage, position, player)) {count = SafeMath.add2(count, 1);}


        /* set ticket match count */
        stages[_stage].playerTickets[player][position].numMatches = count;

        /* set ticket pb match bool */
        stages[_stage].playerTickets[player][position].pbMatches = cmp(stages[_stage].finalTicket.pb, stages[_stage].playerTickets[player][position].pb);
        /* ticket has been validated */
        stages[_stage].playerTickets[player][position].isValidated = true;
        /* pay the ticket */
        redeemTicket(_stage, position, player);
    }

    /*
    *  balance functions
    *  players main game balance
    */
    function getMoneyballBalance() public view returns (uint) {
        return moneyballVault[msg.sender];
    }

    /* contract balance */
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }


    /* check number validity, also used in truffle numbercheck tests */
    function isDrawValid(uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5, uint8 _pb)
    public
    pure
    returns (bool) {
        /* n1 */
        if (checkNumbers(_n1, _n2)) {return false;}
        if (checkNumbers(_n1, _n3)) {return false;}
        if (checkNumbers(_n1, _n4)) {return false;}
        if (checkNumbers(_n1, _n5)) {return false;}
        /* n2 */
        if (checkNumbers(_n2, _n3)) {return false;}
        if (checkNumbers(_n2, _n4)) {return false;}
        if (checkNumbers(_n2, _n5)) {return false;}
        /* n3 */
        if (checkNumbers(_n3, _n4)) {return false;}
        if (checkNumbers(_n3, _n5)) {return false;}
        /* n4 */
        if (checkNumbers(_n4, _n5)) {return false;}

        return isSubmittedNumberWithinBounds(_n1, _n2, _n3, _n4, _n5, _pb);
    }

    function addPlayerToRaffle(address _player) external {
      /* you can only interact with active stage */
        uint256 stage = numberOfStages.sub(1);
        require(playerRaffleTickets[msg.sender] >= raffleTicketsPerDraw);
        require(stages[stage].allowTicketPurchases);
        require(raffleDrawings[stage].length < 20000000000);
        playerRaffleTickets[msg.sender] = playerRaffleTickets[msg.sender].sub(raffleTicketsPerDraw);
        raffleDrawings[stage].push(NULL_ADDRESS);
        raffleDrawings[stage].push(_player);
        raffleDrawings[stage].push(NULL_ADDRESS);
        emit RaffleEntry(msg.sender, block.number);
    }

    /* ditchable for default  public version */
    /* gets number of tickets user has, tickets are used to create reward/side draws */
    function getPlayerRaffleTickets() public view returns (uint) {
        return playerRaffleTickets[msg.sender];
    }

    /* check if numbers same */
    function checkNumbers(uint8 _n1, uint8 _n2)
    private
    pure
    returns (bool)
    {
        if (_n1 == _n2) {return true;}
        return false;
    }

    /* entry fee is based on oraclize getPrice for URL */
    function basePrice() private view returns (uint) {
        uint256 price = oraclize_getPrice("URL");
        return price;
    }

    /* make entry be slightly random, this is protected by denom floor and ceiling */
    function calcEntryFee() private view returns (uint) {
        uint256 modBase = SafeMath.add(3, (uint8(blockhash(block.number - 1)) % 3));
        uint256 price = SafeMath.mul(basePrice(), modBase);
        return price;
    }

    /*
     this function is used for other things name it better
    */
    function calculatePayoutDenomination(uint256 _denomination, uint256 _multiple)
    private
    pure
    returns (uint256)
    {
        return SafeMath.mul(_denomination, _multiple);
    }

    /* 1% split of denomination */
    function calculateOnePercentTicketCostSplit(uint256 _denomination)
    private
    pure
    returns (uint256)
    {
        return SafeMath.div(_denomination, 100);
    }

    /*
      Game buys p3d at stage creation, if money available
    */
    function buyP3d(address player)
    private
    {
        uint256 funds = buyP3dFunds;
        if (funds > 0) {
            p3dContract.buy.value(funds)(player);
            buyP3dFunds = 0;
        }

        uint256 lsend = dividendFunds;

        if (lsend > 0) {
            dividendFunds = 0;
            Divies.deposit.value(lsend)();
        }
    }

    /*
      withdraws dividends and allocates to sidegame, if divs available
    */
    function withdrawP3dDividends()
    private
    {
        uint256 dividends = p3dContract.myDividends(true);
        if (dividends > 0) {
            p3dContract.withdraw();
            rafflePortion = rafflePortion.add(dividends);
        }
    }

    /*
      create stage generates a new stage w/ new round denominations
    */
    function CreateStage()
    private
    {
        /* Must reach original draw period before creating new stage */
        require(drawActiveTimestamp < now);

        /* reinit the draw offset to prevent new stage spam */
        drawActiveTimestamp = SafeMath.add(now, drawingTimeOffset);

        Ticket memory ticket = Ticket(0, 0, 0, 0, 0, 0, 0, false, false, false, NULL_ADDRESS);
        Payouts memory stagePayouts = Payouts(
        calculatePayoutDenomination(DENOMINATION, 4),
        calculatePayoutDenomination(DENOMINATION, 50),
        calculatePayoutDenomination(DENOMINATION, 500000),
        calculatePayoutDenomination(DENOMINATION, 2),
        calculatePayoutDenomination(DENOMINATION, 4),
        calculatePayoutDenomination(DENOMINATION, 50),
        calculatePayoutDenomination(DENOMINATION, 25000),
        calculatePayoutDenomination(DENOMINATION, 1));

        /* get 1% split based on current DENOMINATION */
        uint256 ONE_PERCENT = calculateOnePercentTicketCostSplit(DENOMINATION);
        uint256 JACKPOT_PORTION = calculatePayoutDenomination(ONE_PERCENT, 45);
        uint256 SIDEGAME_PORTION = calculatePayoutDenomination(ONE_PERCENT, 45);
        uint256 REFERRAL_PORTION = calculatePayoutDenomination(ONE_PERCENT, 6);
        uint256 CREATOR_PORTION = calculatePayoutDenomination(ONE_PERCENT, 2);
        uint256 P3D_PORTION = calculatePayoutDenomination(ONE_PERCENT, 2);

        Splits memory stageSplits = Splits(REFERRAL_PORTION,
        P3D_PORTION,
        JACKPOT_PORTION,
        SIDEGAME_PORTION,
        CREATOR_PORTION,
        DENOMINATION);

        DrawBlocks memory drawBlocks = DrawBlocks(0, 0, 0, 0, 0, 0);

        uint256 blockStart = SafeMath.add(block.number, 10);

        uint256 redemptionGracePeriod = SafeMath.mul(drawingTimeOffset, 5);
        redemptionGracePeriod = redemptionGracePeriod.add(drawActiveTimestamp);

        stages[numberOfStages] = Stage(false,
        ticket,
        drawBlocks,
        true,
        false,
        false,
        blockStart,
        0,
        stagePayouts,
        stageSplits,
        drawActiveTimestamp,
        redemptionGracePeriod);

        if (numberOfStages >= 1) {
            buyP3d(owner);
            withdrawP3dDividends();
            denominationActiveTimestamp = SafeMath.add(now, denominationUpdateTimeOffset);
        }

        numberOfStages = numberOfStages.add(1);

        emit StageCreated(numberOfStages);


        if (numberOfStages >= 4) {
            raffleTicketsRewardPerBuy = 1;
        }
    }

    /* called by finalize stage when invalid draw occurs */
    function resetDrawBlocks(uint256 _stage)
    private
    {
        emit ReadyToFinalize(true);
        /*
        *  on draws we have number collisions reset stage draw timer
        *  minimum of 5 minutes, blocknumbers can also block finalizestage
        */
        drawActiveTimestamp = SafeMath.add(drawActiveTimestamp, 300);
        stages[_stage].drawDate = drawActiveTimestamp;

        stages[_stage].drawBlocks.blocknumber1 = SafeMath.add(block.number, 11);
        stages[_stage].drawBlocks.blocknumber2 = SafeMath.add(block.number, 12);
        stages[_stage].drawBlocks.blocknumber3 = SafeMath.add(block.number, 13);
        stages[_stage].drawBlocks.blocknumber4 = SafeMath.add(block.number, 14);
        stages[_stage].drawBlocks.blocknumber5 = SafeMath.add(block.number, 15);
        stages[_stage].drawBlocks.blocknumberpb = SafeMath.add(block.number, 16);
    }

    /*
    * do raffle is called in finalizeStage when a valid draw status has
    * been found
    */
    function doRaffle(uint256 _stage, uint256 rafflePlayerCount)
    private
    {
        if (rafflePlayerCount > 6) {
            Stage storage stageToFinalize = stages[_stage];
            uint256 sideGameFunds = rafflePortion;
            uint256 sideGameFundWinSharePercentTwentyFive = SafeMath.div(sideGameFunds, 4);
            uint256 sideGameFundWinSharePercentTen = SafeMath.div(sideGameFunds, 10);
            uint256 sideGameFundWinSharePercentFive = SafeMath.div(sideGameFunds, 20);
            uint256 sideGameFundWinSharePercentOne = SafeMath.div(sideGameFunds, 100);

            /*
            fucntion was more readable like this
            address raffleOneWinner = raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumberpb)) % rafflePlayerCount)];
            payRafflePlayer(raffleOneWinner, sideGameFundWinSharePercentTwentyFive);

            changed to get around stack depth issues

            */

            payRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumberpb)) % rafflePlayerCount)]), sideGameFundWinSharePercentTwentyFive, _stage);
            payRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumber5)) % rafflePlayerCount)]), sideGameFundWinSharePercentTen, _stage);
            payRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumber4)) % rafflePlayerCount)]), sideGameFundWinSharePercentFive, _stage);
            payRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumber3)) % rafflePlayerCount)]), sideGameFundWinSharePercentFive, _stage);
            payRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumber2)) % rafflePlayerCount)]), sideGameFundWinSharePercentOne, _stage);

            /* give away some of the main pot too */
            uint256 jackpotFunds = lotteryPortion;
            uint256 jackpotFundsTenPercent = SafeMath.div(jackpotFunds, 10);
            payMainRafflePlayer(address(raffleDrawings[_stage][(uint256(blockhash(stageToFinalize.drawBlocks.blocknumber1)) % rafflePlayerCount)]), jackpotFundsTenPercent, _stage);
        }
    }

    function payRafflePlayer(address _player, uint256 _amount, uint256 _stage)
    private
    {
        require(rafflePortion > _amount);
        emit RaffleWinnerPick(_player, _amount, _stage);
        /* we only pay real non NULL_ADDRESS address */
        if (_player != NULL_ADDRESS) {
            rafflePortion = rafflePortion.sub(_amount);
            moneyballVault[_player] = moneyballVault[_player].add(_amount);
        }
    }

    function payMainRafflePlayer(address _player, uint256 _amount, uint256 _stage)
    private
    {
        require(lotteryPortion > _amount);
        emit RaffleWinnerPick(_player, _amount, _stage);
        /* we only pay real non NULL_ADDRESS address */
        if (_player != NULL_ADDRESS) {
            lotteryPortion = lotteryPortion.sub(_amount);
            moneyballVault[_player] = moneyballVault[_player].add(_amount);
        }
    }

    function payTicket(uint256 _amount, address _player)
    private
    {
        require(lotteryPortion > _amount);
        lotteryPortion = lotteryPortion.sub(_amount);
        moneyballVault[_player] = moneyballVault[_player].add(_amount);
    }

    function redeemTicket(uint256 _stage, uint256 position, address player)
    private
    {
        /* ticket must be validated */
        require(stages[_stage].playerTickets[player][position].isValidated);
        /* ticket must never have been redeemed */
        require(!stages[_stage].playerTickets[player][position].isRedeemed);

        uint8 numMatches = stages[_stage].playerTickets[player][position].numMatches;
        bool pbMatches = stages[_stage].playerTickets[player][position].pbMatches;

        stages[_stage].playerTickets[player][position].isRedeemed = true;

        if (pbMatches) {
            playerRaffleTickets[player] = playerRaffleTickets[player].add(5);
            if (numMatches <= 1) {
                payTicket(stages[_stage].stagePayouts.MONEYBALL_BASE_MATCHES, player);
            }
            if (numMatches == 2) {
                payTicket(stages[_stage].stagePayouts.MONEYBALL_2_MATCHES, player);
            }
            if (numMatches == 3) {
                payTicket(stages[_stage].stagePayouts.MONEYBALL_3_MATCHES, player);
            }
            if (numMatches == 4) {
                payTicket(stages[_stage].stagePayouts.MONEYBALL_4_MATCHES, player);
            }
            if (numMatches == 5) {
                uint256 LOCAL_lotteryPortion = lotteryPortion;
                uint256 jackpotValue = SafeMath.div(LOCAL_lotteryPortion, 2);
                payTicket(jackpotValue, player);
            }
        }

        if (!pbMatches) {
            if (numMatches == 3) {
                payTicket(stages[_stage].stagePayouts.NO_MONEYBALL_3_MATCHES, player);
                playerRaffleTickets[player] = playerRaffleTickets[player].add(5);
            }
            if (numMatches == 4) {
                payTicket(stages[_stage].stagePayouts.NO_MONEYBALL_4_MATCHES, player);
                playerRaffleTickets[player] = playerRaffleTickets[player].add(5);
            }
            if (numMatches == 5) {
                payTicket(stages[_stage].stagePayouts.NO_MONEYBALL_5_MATCHES, player);
                playerRaffleTickets[player] = playerRaffleTickets[player].add(5);
            }
        }

    }

    /*
    *   check value of a given ticket
    */
    function checkTicketValue(uint256 _stage, uint256 position)
    public
    view
    onlyAvailableStages(_stage)
    returns (uint)
    {
        address player = msg.sender;
        uint8 count = 0;

        /* count matches */
        if (checkPlayerN1(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN2(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN3(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN4(_stage, position, player)) {count = SafeMath.add2(count, 1);}
        if (checkPlayerN5(_stage, position, player)) {count = SafeMath.add2(count, 1);}

        uint8 numMatches = count;
        /* set ticket pb match bool */
        bool pbMatches = cmp(stages[_stage].finalTicket.pb, stages[_stage].playerTickets[player][position].pb);

        if (pbMatches) {
            if (numMatches <= 1) {
                return stages[_stage].stagePayouts.MONEYBALL_BASE_MATCHES;
            }
            if (numMatches == 2) {
                return stages[_stage].stagePayouts.MONEYBALL_2_MATCHES;
            }
            if (numMatches == 3) {
                return stages[_stage].stagePayouts.MONEYBALL_3_MATCHES;
            }
            if (numMatches == 4) {
                return stages[_stage].stagePayouts.MONEYBALL_4_MATCHES;
            }
            if (numMatches == 5) {
                uint256 LOCAL_lotteryPortion = lotteryPortion;
                uint256 jackpotValue = SafeMath.div(LOCAL_lotteryPortion, 2);
                return jackpotValue;
            }
        }

        if (!pbMatches) {
            if (numMatches == 3) {
                return stages[_stage].stagePayouts.NO_MONEYBALL_3_MATCHES;
            }
            if (numMatches == 4) {
                return stages[_stage].stagePayouts.NO_MONEYBALL_4_MATCHES;
            }
            if (numMatches == 5) {
                return stages[_stage].stagePayouts.NO_MONEYBALL_5_MATCHES;
            }
        }

        return 0;
    }

    /*
      ticket checking of final draw ticket vs player ticket positions for stage
    */
    function checkPlayerN1(uint256 _stage, uint256 position, address player) private view returns (bool) {
        if (cmp(stages[_stage].finalTicket.n1, stages[_stage].playerTickets[player][position].n1)) {return true;}
        if (cmp(stages[_stage].finalTicket.n2, stages[_stage].playerTickets[player][position].n1)) {return true;}
        if (cmp(stages[_stage].finalTicket.n3, stages[_stage].playerTickets[player][position].n1)) {return true;}
        if (cmp(stages[_stage].finalTicket.n4, stages[_stage].playerTickets[player][position].n1)) {return true;}
        if (cmp(stages[_stage].finalTicket.n5, stages[_stage].playerTickets[player][position].n1)) {return true;}

        return false;
    }

    function checkPlayerN2(uint256 _stage, uint256 position, address player) private view returns (bool) {
        if (cmp(stages[_stage].finalTicket.n1, stages[_stage].playerTickets[player][position].n2)) {return true;}
        if (cmp(stages[_stage].finalTicket.n2, stages[_stage].playerTickets[player][position].n2)) {return true;}
        if (cmp(stages[_stage].finalTicket.n3, stages[_stage].playerTickets[player][position].n2)) {return true;}
        if (cmp(stages[_stage].finalTicket.n4, stages[_stage].playerTickets[player][position].n2)) {return true;}
        if (cmp(stages[_stage].finalTicket.n5, stages[_stage].playerTickets[player][position].n2)) {return true;}

        return false;
    }

    function checkPlayerN3(uint256 _stage, uint256 position, address player) private view returns (bool) {
        if (cmp(stages[_stage].finalTicket.n1, stages[_stage].playerTickets[player][position].n3)) {return true;}
        if (cmp(stages[_stage].finalTicket.n2, stages[_stage].playerTickets[player][position].n3)) {return true;}
        if (cmp(stages[_stage].finalTicket.n3, stages[_stage].playerTickets[player][position].n3)) {return true;}
        if (cmp(stages[_stage].finalTicket.n4, stages[_stage].playerTickets[player][position].n3)) {return true;}
        if (cmp(stages[_stage].finalTicket.n5, stages[_stage].playerTickets[player][position].n3)) {return true;}

        return false;
    }

    function checkPlayerN4(uint256 _stage, uint256 position, address player) private view returns (bool) {
        if (cmp(stages[_stage].finalTicket.n1, stages[_stage].playerTickets[player][position].n4)) {return true;}
        if (cmp(stages[_stage].finalTicket.n2, stages[_stage].playerTickets[player][position].n4)) {return true;}
        if (cmp(stages[_stage].finalTicket.n3, stages[_stage].playerTickets[player][position].n4)) {return true;}
        if (cmp(stages[_stage].finalTicket.n4, stages[_stage].playerTickets[player][position].n4)) {return true;}
        if (cmp(stages[_stage].finalTicket.n5, stages[_stage].playerTickets[player][position].n4)) {return true;}

        return false;
    }

    function checkPlayerN5(uint256 _stage, uint256 position, address player) private view returns (bool) {
        if (cmp(stages[_stage].finalTicket.n1, stages[_stage].playerTickets[player][position].n5)) {return true;}
        if (cmp(stages[_stage].finalTicket.n2, stages[_stage].playerTickets[player][position].n5)) {return true;}
        if (cmp(stages[_stage].finalTicket.n3, stages[_stage].playerTickets[player][position].n5)) {return true;}
        if (cmp(stages[_stage].finalTicket.n4, stages[_stage].playerTickets[player][position].n5)) {return true;}
        if (cmp(stages[_stage].finalTicket.n5, stages[_stage].playerTickets[player][position].n5)) {return true;}

        return false;
    }

    /* check match position */
    function cmp(uint8 _draw, uint8 _player)
    private
    pure
    returns (bool)
    {
        if (_draw == _player) {return true;}
        return false;
    }

    /* check number boundries */
    function isSubmittedNumberWithinBounds(uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5, uint8 _pb)
    private
    pure
    returns (bool)
    {
        if (_n1 > 69 || _n1 == 0) {return false;}
        if (_n2 > 69 || _n2 == 0) {return false;}
        if (_n3 > 69 || _n3 == 0) {return false;}
        if (_n4 > 69 || _n4 == 0) {return false;}
        if (_n5 > 69 || _n5 == 0) {return false;}
        if (_pb > 26 || _pb == 0) {return false;}
        return true;
    }

}

interface ReferralInterface {
    function isAnOwner(address _referralAddress) external view returns(bool);
}

interface HourglassInterface {
    function buy(address _playerAddress) payable external returns(uint256);
    function withdraw() external;
    function myDividends(bool _includeReferralBonus) external view returns(uint256);
    function balanceOf(address _playerAddress) external view returns(uint256);
}

interface DiviesInterface {
    function deposit() external payable;
}