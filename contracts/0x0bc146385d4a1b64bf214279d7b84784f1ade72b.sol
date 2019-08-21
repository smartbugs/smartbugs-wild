/* MZT1 is a game that players can buy blocks (1000*1000 blocks), paint on blocks and bet which color has the maximum blocks on the map.
 * The game is part of Mizhen family, so the game sends profit to MZBoss which is the share of Mizhen.
 * The fee of buying, paiting and betting will go to MZBoss and community.
 * Players can buy and own a block, and other players can pay higher price to buy the same block.
 * Every time a block changes its owner, the price is 30% higher.
 * The first buyer of a block will pay ETH to the pot.
 * From the second buyer the taxed payment goes to the previous buyer and the pot.
 * Plays can also pay to the owner to paint on a block.
 * Plays can also bet which color has maximum blocks on the map. 
 * Every 24 hours the pot will open and distribute profit to players who win the bet.
 * The profit of pot will also go to the last player of the 24 hours who paint on any block.
 * If no one did anything in the previous 24 hours, the distribution will be 75% of the pot.
 * Otherwise, 10% of the pot will be distributed.
 * After fee to MZBoss and community, 50% will go to the last painter, the other 50% will go to the winners of color betting.
 * The bet on color will never disappear, there is no concept of round. It is going on forever.
 *
 * Smart Contract Security Audit by:
 * 1 Callisto Network, 2 Jan, 3 Mason
 * 
 * Mizhen Team
 */
 
// <ORACLIZE_API>
// Release targetted at solc 0.4.25 to silence compiler warning/error messages, compatible down to 0.4.22
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

// This api is currently targeted at 0.4.22 to 0.4.25 (stable builds), please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary

pragma solidity >=0.4.22;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version

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
// </ORACLIZE_API>
contract MZBoss {
    uint256 constant internal magnitude = 1e18; // related to payoutsTo_, profitPershare_, profitPerSharePot_, profitPerShareNew_
    mapping(address => int256) internal payoutsTo_;
    uint256 public tokenSupply_ = 0; // total sold tokens 
    uint256 public profitPerShare_ = 0 ;
    uint256 public _totalProfitPot = 0;
    address constant internal _communityAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E;
    /**
     * profit distribution from game pot
     */
    function potDistribution()
        public
        payable
    {
        require(msg.value > 0);
        uint256 _incomingEthereum = msg.value;
        if(tokenSupply_ > 0){
            
            // profit per share 
            uint256 profitPerSharePot_ = SafeMath.mul(_incomingEthereum, magnitude) / (tokenSupply_);
            
            // update profitPerShare_, adding profit from game pot
            profitPerShare_ = SafeMath.add(profitPerShare_, profitPerSharePot_);
            
        } else {
            // send to community
            payoutsTo_[_communityAddress] -=  (int256) (_incomingEthereum);
            
        }
        
        //update _totalProfitPot
        _totalProfitPot = SafeMath.add(_incomingEthereum, _totalProfitPot); 
    }
}

contract MZT1 is usingOraclize {
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with profits
    modifier onlyStronghands() {
        address _customerAddress = msg.sender;
        require(dividendsOf(_customerAddress) > 0);
        _;
    }
    
    // administrators can:
    // -> change the name of the contract
    // -> add address for extended function
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress] == true);
        _;
    }
    
    // There will be extended functions for the game
    // address of the extended contract only.
    modifier onlyExtendFunction(){ 
        address _customerAddress = msg.sender;
        require(extendFunctionAddress_[_customerAddress] == true);
        _;
    }

    // Check if the player has enough ETH to paint on a block, _input is block information (ID;color)
    modifier enoughToSetCheck(uint256[] _setBlockIDArray_, uint8[] _setColorArray_) { 
        uint256 _ethereum = msg.value;
        uint256 totalSetExpense_ = SafeMath.mul(_setBlockIDArray_.length, Cons.setCheckPriceInitial_);

        require((_setBlockIDArray_.length == _setColorArray_.length)&&(_ethereum >= totalSetExpense_)&&(totalSetExpense_ >= Cons.setCheckPriceInitial_));
        _;
    }
    
    // Check if the play has enough ETH to buy a block, _input is block ID
    modifier enoughToBuyCheck(uint256[] _buyBlockIDArray_){  
        uint256 _ethereum = msg.value;
        
        require((_ethereum >= buyPriceArray(_buyBlockIDArray_)) && (buyPriceArray(_buyBlockIDArray_) >= Cons.buyPriceInitial_));
        _;
    }
    
    // Check if the play has enough ETH to guess color
    modifier enoughToGuess(uint256 colorGuess_){  
        address _customerAddress = msg.sender;
        uint256 _incomingEthereum = SafeMath.add(msg.value, dividendsOf(_customerAddress));
        
        require((_incomingEthereum >= Cons.setCheckPriceInitial_)&&(colorGuess_ > 0) && (colorGuess_ < 6));
        _;
    }
    

    /*==============================
    =            EVENTS            =
    ==============================*/
    
    // fired whenever a player set color
    event onSetColor
    (
        address indexed playerAddress,
        uint256[] ColorSetID,
        uint8[] ColorSetColor,
        uint256 timeStamp
    );
    
    // fired whenever a player buy a block
    event onBuyBlock
    (
        address indexed playerAddress,
        uint256[] buyBlockID,
        uint256[] buyBlockPrice,
        uint256 timeStamp
    );
    
    // fired whenever a player guess color
    event onGuessColor
    (
        address indexed playerAddress,
        uint256 investETH,
        uint256 totalBet,
        uint8 color_,
        uint256 timeStamp
    );
    
    // fired whenever a player withdraw
    event onWithdraw
    (
        address indexed playerAddress,
        uint256 withdrawETH,
        uint256 timeStamp
    );
    
    // fired whenever the pot open
    event onPotOpen
    (
        uint256 totalDistribution,
        uint256 toLastAddress,
        address lastPlayerAddress
        
    );
    
    // fired the winner color
    event onWinnerColor
    (
        uint256 totalRed,
        uint256 totalYellow,
        uint256 totalBlue,
        uint256 totalBlack,
        uint256 totalGreen,
        uint256 winningPerShareRed,
        uint256 winningPerShareYellow,
        uint256 winningPerShareBlue,
        uint256 winningPerShareBlack,
        uint256 winningPerShareGreen
        
    );
    
    // fired whenever a player buy a block
    event onExtendFunction
    (
        address indexed playerAddress,
        uint256[] BlockID,
        uint8[] BlockColor,
        uint256[] buyBlockPrice,
        address[] BlockOwner
    );
    
    
    
    // Events used to track contract actions
    event LogOraclizeQuery(string description);
    event LogResultReceived(uint number, bytes Proof);
    event newRandomNumber_bytes(bytes);
    event newRandomNumber_uint(uint);


    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Mizhen Game One";
    string public symbol = "MZONE";
    
    struct ConstantSETS{
        
    uint8 decimals;
    uint8 dividendFee_; // percentage of fee sent to MZBoss token holders 
    uint8 toCommunity_ ; // percentage of fee sent to community. 
    uint256 magnitude; // 
    uint256 winningLast_; // winning percentage of last painter
    uint256 ratioToPrevious_; // percentage of buying payment to the previous owner
    uint256 ratioToOwner_ ; // percentage of painting payment to the owner of the block
    uint256 oneDay_ ; // 86400 seconds
    uint256 setCheckPriceInitial_; // initial price of paiting color on a block
    uint256 buyPriceInitial_ ; // initial price of buying a block
    uint256 buyPriceAdd_; // price ratio of buying a block every time, 30% increase every time
    }
    
    ConstantSETS internal Cons = ConstantSETS(18,5,5,1e18,50,90,50,86400,1e14,5e15,130);
    
    uint256 public constant totalBlock_ = 1000000;
    uint256 public totalNumberColor_ = 14;
    
    uint256 public timeUpdate_; // time update every 24 hours, this will not be precise 24 hours. it will be updated when the first player come after 24 hours.
    uint256 public timeNearest_; // time of nearest paiting, to check if there is any paiting in last 24 hours
    uint256 public timeCutoff_;
    uint256 public totalVolumn_ = 0; // record total received ETH
    uint256 public setColorLastDay_; // number of people who set color in the last one day

    // Define variables
    uint public randomNumber; // number obtained from random.org
    mapping(bytes32 => bool) validIds; // used for validating Query IDs
    uint constant gasLimitForOraclize = 200000; // gas limit for Oraclize callback
    bool public sendRandomRequest = true;
    uint internal constant winningNumber = 2;
    uint256 public gasPriceCallBack = 5000000000 wei;
    uint256 public callbackGas = 800000;
    uint256 public timeRequest_;
    bytes32 internal queryIdRequest;
   /*================================
    =            DATASETS            =
    ================================*/

    mapping (address => mapping (uint256 => uint256)) public ethereumBalanceLedgerColor_; // betting ledger of different address on differet color

    // information of a block, paiting price, buying price, owner and color. ID is from 0 to 999999 
    mapping (uint256 => uint256) public blockSetPrice_; // price of paiting on a block
    mapping (uint256 => uint256) public blockBuyPrice_; // price of buying a block
    mapping (uint256 => address) public blockAddress_; // owner of block
    mapping (uint256 => uint8) public blockColor_; // color of block
    uint256[] public changedBlockID_; // ID of blocks that have been painted.
    
    // help to record player's dividends
    mapping (address => int256) public payoutsTo_;

    // information about color betting
    mapping (uint256 => uint256) public totalGuess; // total ETH  that bet a color, 1 red, 2 yellow, 3 blue, 4 black, 5 green
    mapping (uint256 => uint256) public winningPerShare_; // accumulated winning per share of ETH of different color, 1 red, 2 yellow, 3 blue, 4 black, 5 green
    mapping (uint256 => uint256) public winningPerShareNew_; // winning per share of each 24 hours
    mapping (uint256  => uint256) public totalColor_; // total count of a color, 1 red, 2 yellow, 3 blue, 4 black, 5 green

    uint256 public _totalProfitPot = 0; // total ETH in the pot
    address constant internal _communityAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E;
    address constant internal _MZBossAddress = 0x16d29707a5F507f9252Ae5b7fc5E86399725C663;
    address public _lastAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E; // address of last painter 
    
    bool public timeStart = true; // time start 
    
    // administrator list (see above on what they can do)
    mapping(address => bool) public administrators;
    // extend function address list
    mapping(address => bool) public extendFunctionAddress_; 
    mapping (uint256 => uint256) public priceAssume_;
    mapping(address => uint256) public ownBlockNumber_; // total number of block a play owns

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor ()
        public
    
    {
        // add administrators here
        administrators[0x6dAd1d9D24674bC9199237F93beb6E25b55Ec763] = true;
        extendFunctionAddress_[0x3e9439D4AeC0756Cc6f10FFda053523e8A518DD3] = true; //
        
        // set Oraclize proof type
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        oraclize_setProof(proofType_Ledger);
      
        // set gas price for Oraclize callback
        
        oraclize_setCustomGasPrice(gasPriceCallBack); // 5 Gwei

    }
    
    /**
     * 
     * random number
     */
    
    // Callback function for Oraclize once it retreives the data 
    function __callback(bytes32 queryId, string result, bytes proof) 
        public 
    {
        // only allow Oraclize to call this function
        require(msg.sender == oraclize_cbAddress());
      
        // validate the ID 
        require(validIds[queryId]);
        
        // log the new number that was obtained
        emit LogResultReceived(randomNumber, proof); 
      
        // reset mapping of this ID to false
        // this ensures the callback for a given queryID never called twice
        validIds[queryId] = false;
        
        if (oraclize_randomDS_proofVerify__returnCode(queryId, result, proof) != 0) {

        } else {
            // the proof verification has passed
            // for simplicity of use, let's also convert the random bytes to uint if we need
            uint maxRange = 3;
            randomNumber = uint(keccak256(bytes(result))) % maxRange; // this is an efficient way to get the uint out in the [0, maxRange] range

            emit newRandomNumber_uint(randomNumber); // this is the resulting random number (uint)
            
            sendRandomRequest = true;
            
            if (randomNumber == winningNumber){
                
                setColorLastDay_ = 0;
                winnerCheck(now); 
            }
        }
    }
    
    /**
     * 
     * paint color on a block, _input formate (ID:color,ID:color,ID:color)
     * (blockID_: 0-999999) (setColor_: 1 red, 2 yellow, 3 blue, 4 black, 5 green, 6-14 see website, more comming)
     */ 
    function setColor(uint256[] _setBlockIDArray_, uint8[] _setColorArray_)   
        enoughToSetCheck(_setBlockIDArray_, _setColorArray_)
        public
        payable
    {
        
        uint256 _incomingEthereum = msg.value;
        
        // sent to MZBoss and community address
        uint256 _toMZBoss = SafeMath.mul(_incomingEthereum, Cons.dividendFee_) / 100; 
        uint256 _communityDistribution = SafeMath.mul(_incomingEthereum, Cons.toCommunity_) / 100;
        
        payoutsTo_[_MZBossAddress] = payoutsTo_[_MZBossAddress] + (int256)(_toMZBoss);
        payoutsTo_[_communityAddress] = payoutsTo_[_communityAddress] + (int256)(_communityDistribution);
        
        // record total ETH into the game
        totalVolumn_ = SafeMath.add(totalVolumn_, _incomingEthereum);
        
        
        // Check if it is time to open the pot, if it is, go to check winner and distribute pot
        if (SafeMath.sub(now, timeUpdate_) > Cons.oneDay_){
            if(timeCutoff_ == 0) timeCutoff_ = now;
            
            if((now - timeRequest_) > Cons.oneDay_){
                sendRandomRequest = true;
                validIds[queryIdRequest] = false;
                randomNumberRequest(now);
            }else{
                randomNumberRequest(now);
            }
        }else{
            // track the time of the latest action, used for potopen
            timeNearest_ = now;
        } 

        // update information based on the input
        blockSetUpdate(_setBlockIDArray_, _setColorArray_);
        
        _lastAddress = msg.sender;
        
        // keep track number of pepple paint in the day, so people know the percentage that will be distributed when pot opens
        setColorLastDay_ = SafeMath.add(setColorLastDay_, 1);
  
    }
    
    /**
     * 
     * function of buying a block, _input formate (ID,ID,ID)
     */ 
    function buyBlock(uint[] _buyBlockIDArray_) 
        enoughToBuyCheck(_buyBlockIDArray_)
        public
        payable
    {
        uint256 _incomingEthereum = msg.value;
        
        // record total ETH into the game
        totalVolumn_ = SafeMath.add(totalVolumn_, _incomingEthereum);
        
        // sent to MZBoss and community address
        uint256 _toMZBoss = SafeMath.mul(_incomingEthereum, Cons.dividendFee_) / 100; 
        uint256 _communityDistribution = SafeMath.mul(_incomingEthereum, Cons.toCommunity_) / 100;
        
        payoutsTo_[_MZBossAddress] = payoutsTo_[_MZBossAddress] + (int256)(_toMZBoss);
        payoutsTo_[_communityAddress] = payoutsTo_[_communityAddress] + (int256)(_communityDistribution);
        
        // Check if it is time to open the pot, if it is, go to check winner and distribute pot
        if (SafeMath.sub(now, timeUpdate_) > Cons.oneDay_){
            if(timeCutoff_ == 0) timeCutoff_ = now;
            
            if((now - timeRequest_) > Cons.oneDay_){
                sendRandomRequest = true;
                validIds[queryIdRequest] = false;
                randomNumberRequest(now);
            }else{
                randomNumberRequest(now);
            }
        }else{
            // track the time of the latest action, used for potopen
            timeNearest_ = now;
        } 
        
        // update block information based on purchase input
        blockBuyUpdate(_buyBlockIDArray_);
        
    }
    
    /**
     * player can bet on color
     */
    function guessColor(uint8 colorGuess_) 
        enoughToGuess(colorGuess_)
        public
        payable
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _incomingEthereum = SafeMath.add(msg.value, dividendsOf(_customerAddress));
        
        // record total ETH into the game
        totalVolumn_ = SafeMath.add(totalVolumn_, msg.value);
        
        // go to guess color core function
        guessColorCore(_incomingEthereum, colorGuess_); 
        
        // Check if it is time to open the pot, if it is, go to check winner and distribute pot
        if (SafeMath.sub(now, timeUpdate_) > Cons.oneDay_){
            if(timeCutoff_ == 0) timeCutoff_ = now;
            
            if((now - timeRequest_) > Cons.oneDay_){
                sendRandomRequest = true;
                validIds[queryIdRequest] = false;
                randomNumberRequest(now);
            }else{
                randomNumberRequest(now);
            }
        }else{
            // track the time of the latest action, used for potopen
            timeNearest_ = now;
        } 
           
        // payoutsTo_ is int256, so convert _incomingEthereum to int256
        payoutsTo_[_customerAddress] = payoutsTo_[_customerAddress] + (int256) (dividendsOf(_customerAddress)); 
        
        emit onGuessColor(_customerAddress, msg.value, _incomingEthereum, colorGuess_, now);
    }
    
    
    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyStronghands()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        
        // get the dividends of the player 
        uint256 _dividends = dividendsOf(_customerAddress);
 
        // update dividend tracker, in order to calculate with payoutsTo which is int256, _dividends need to be casted to int256 first
        payoutsTo_[_customerAddress] = payoutsTo_[_customerAddress] + (int256)(_dividends);
        
        // send eth
        _customerAddress.transfer(_dividends);
        
        emit onWithdraw(_customerAddress, _dividends, now);
        
    }


    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case we need to replace ourselves.
     */
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }
    
    
    /**
     * We are going to extend functions of the game with more smart contract
     */
    function setExtendFunctionAddress(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        extendFunctionAddress_[_identifier] = _status;
    }
    
    /**
     * If we want to rebrand, we can.
     */
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
    
    /**
     * If we want to change symbol, we can.
     */
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }
    
    /**
     * After the game is online, the administrator can set the start time only once.
     */
    function setTime()
        onlyAdministrator()
        public
    {
        if (timeStart){
            timeUpdate_ = now; 
            timeStart = false;
        }else{
            timeStart = false;
        }
    }
    
    /**
     * If we want to change totalNumberColor and totalBlock, we can.
     */
    function setColorBlock(uint256 _Color)
        onlyAdministrator()
        public
    {
        totalNumberColor_ = _Color;

    }
    
    /**
     * set gas price for random number
     */
    function setGasFee(uint256 callbackGas_, uint256 gasPriceCallBack_)
        onlyAdministrator()
        public
    {
        callbackGas = callbackGas_;
        gasPriceCallBack = gasPriceCallBack_;

    }
    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    
    /**
     * Method to view the current price for painting
     * 
     */
    function blockSetPrice(uint256 blockID_) 
        public
        view
        returns(uint256)
    {
        uint256 blockPrice_ = blockSetPrice_[blockID_];
        
        if (blockPrice_ == 0){
            blockPrice_ = Cons.setCheckPriceInitial_;
        }
        
        return blockPrice_;
    }
    
    /**
     * Method to view the current price for buying
     * 
     */
    function blockBuyPrice(uint256 blockID_) 
        public
        view
        returns(uint256)
    {
        uint256 blockPrice_ = blockBuyPrice_[blockID_];
        
        if (blockPrice_ == 0){
            blockPrice_ = Cons.buyPriceInitial_;
        }
        return blockPrice_;
    }
    
    /**
     * Method to view the current price for buying
     * 
     */
    function blockColor(uint256 blockID_) 
        public
        view
        returns(uint256)
    {
        return blockColor_[blockID_];
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        public 
        view
        returns(uint256)
    {
        // update profit of each color
        uint256 profitRed_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][1], winningPerShare_[1]) / Cons.magnitude;
        uint256 profitYellow_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][2], winningPerShare_[2]) / Cons.magnitude;
        uint256 profitBlue_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][3], winningPerShare_[3]) / Cons.magnitude;
        uint256 profitBlack_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][4], winningPerShare_[4]) / Cons.magnitude;
        uint256 profitGreen_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][5], winningPerShare_[5]) / Cons.magnitude;
        uint256 totalProfit_ = SafeMath.add(SafeMath.add(SafeMath.add(SafeMath.add(profitRed_, profitYellow_), profitBlue_), profitBlack_), profitGreen_);

        if ((int256(totalProfit_) - payoutsTo_[_customerAddress]) > 0 )
        
           return uint256(int256(totalProfit_) - payoutsTo_[_customerAddress]);     
        else 
        
           return 0;
    }
    
    /**
     * Retrieve the payoutsTo_ of any single address.
     */
    function payoutsTo(address _customerAddress)
        public
        view
        returns(int256)
    {
        return payoutsTo_[_customerAddress];
    }
    
    /**
     * total amount of ETH on different color bet
     */
    function colorTotalGuess(uint256 colorGuess_)
        public
        view
        returns(uint256)
    {
        return totalGuess[colorGuess_];
    }
    
    /**
     * player's amount of ETH on different color bet
     */
    function playerColorGuess(address _customerAddress, uint256 colorGuess_)
        public
        view
        returns(uint256)
    {
        return ethereumBalanceLedgerColor_[_customerAddress][colorGuess_];
    }
    
    /**
     * total number of blocks for each color
     */
    function totalColorNumber(uint256 colorID_)
        public
        view
        returns(uint256)
    {
        return totalColor_[colorID_];
    }
    
    /**
     * total blocks owned by a player
     */
    function ownBlockNumber(address _customerAddress)
        public
        view
        returns(uint256)
    {
        return ownBlockNumber_[_customerAddress];
    }
    
    /**
     * display winningPerShareNew_
     */
    function winningPerShareNew()
        public
        view
        returns(uint256)
    {
        uint256 value_ = 0;
        for (uint256 i = 1; i < 6; i++) {
            if(winningPerShareNew_[i] > 0)
            value_ = winningPerShareNew_[i];
            
        }
            
        return value_;
    }
    
    /**
     * painted block
     */
        
    function setColorUpdate(uint256 loop_)
        public
        view
        returns(uint256[], uint8[])
    {
            uint256 n =  (changedBlockID_.length)/100000;
            uint256 j = loop_ - 1;
        
            uint256 start_ = j * 100000;
            uint256 k = start_ + 100000;
            
            uint256 length_ = changedBlockID_.length - (n * 100000);
            if ((n > 0)&&(j < n)){
                length_ = 100000;
            }
            uint8[] memory blockColorArray_ = new uint8[](length_);
            uint256[] memory changedBlockIDArray_ = new uint256[](length_);
            for(uint256 i = start_; (i < changedBlockID_.length) && (i < k); i++) { 
                
                changedBlockIDArray_[i-start_] = changedBlockID_[i];
                blockColorArray_[i-start_] = blockColor_[changedBlockID_[i]];
            }
            return (changedBlockIDArray_, blockColorArray_);
        
    }
    /**
     * number of painted blocks 
     */
    function paintedBlockNumber()
        public
        view
        returns(uint256)
    {
        return changedBlockID_.length;
    }
    
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /**
     * Core function of bet on a color
     */
     function guessColorCore(uint256 _incomingEthereum, uint256 colorGuess_)
        private
    {

        address _customerAddress = msg.sender;
        
        // sent to MZBoss and community address
        uint256 _toMZBoss = SafeMath.mul(_incomingEthereum, Cons.dividendFee_) / 100; 
        uint256 _communityDistribution = SafeMath.mul(_incomingEthereum, Cons.toCommunity_) / 100;
        
        payoutsTo_[_MZBossAddress] = payoutsTo_[_MZBossAddress] + (int256)(_toMZBoss);
        payoutsTo_[_communityAddress] = payoutsTo_[_communityAddress] + (int256)(_communityDistribution);
 
        // after tax
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, SafeMath.add(_communityDistribution, _toMZBoss));

        // add the payment to the total ETH that bet on the color
        totalGuess[colorGuess_] = SafeMath.add(totalGuess[colorGuess_], _taxedEthereum);
        
        // update the player's ledger
        ethereumBalanceLedgerColor_[_customerAddress][colorGuess_] = SafeMath.add(ethereumBalanceLedgerColor_[_customerAddress][colorGuess_], _taxedEthereum);
 
        // update total pot
        _totalProfitPot = SafeMath.add(_totalProfitPot, _taxedEthereum);
        
        // calculate the current total winningPerShare_ of the color and pre deducte them from player's account
        uint256 profitExtra_ = SafeMath.mul(ethereumBalanceLedgerColor_[_customerAddress][colorGuess_], winningPerShare_[colorGuess_]) / Cons.magnitude;
        
        // update player's payoutsTo_
        payoutsTo_[_customerAddress] = payoutsTo_[_customerAddress] + (int256)(profitExtra_);
    }
    
    /**
     * random number check
     */
    function randomNumberRequest(uint256 timeNew_)
        internal
    {
        
        // send query // require ETH to cover callback gas costs
        uint N = 1; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place

        if((sendRandomRequest == true) && (_totalProfitPot > SafeMath.mul(callbackGas, gasPriceCallBack))){ 

            queryIdRequest = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId
        
            // log that query was sent
            emit LogOraclizeQuery("Oraclize query was sent, standing by for the answer..");
          
            // add query ID to mapping
            validIds[queryIdRequest] = true;
            sendRandomRequest = false;
            timeRequest_ = timeNew_;
            _totalProfitPot = SafeMath.sub(_totalProfitPot, SafeMath.mul(callbackGas, gasPriceCallBack));
        }
           
    }
    
    /**
     * check the winner color and distribute pot
     */
    function winnerCheck(uint256 timeNew_)
        private
    {

        timeUpdate_ = timeNew_;
        
        // check there is any action in last 24 hours, which will activate the distribution of 75% of the pot
        if (SafeMath.sub(timeCutoff_, timeNearest_) > Cons.oneDay_){
            
            uint256 _profitToDistributeTotal = SafeMath.mul(_totalProfitPot, 75)/100;

        }else{
            // otherwise just distribution 10%
            _profitToDistributeTotal = SafeMath.mul(_totalProfitPot, 10)/100;
        }
        
        // udpate pot
        _totalProfitPot = SafeMath.sub(_totalProfitPot, _profitToDistributeTotal);
        timeCutoff_ = 0;
        timeNearest_ = timeNew_; 
        // open the pot
        potOpen(_profitToDistributeTotal);
    }
    
    
    /**
     * open pot and check color every 24 hours, distribute profit
     */
    function potOpen(uint256 _profitToDistribute) 
        private
    {
   
        // sent to MZBoss and community address
        uint256 _toMZBoss = SafeMath.mul(_profitToDistribute, Cons.dividendFee_) / 100; 
        uint256 _communityDistribution = SafeMath.mul(_profitToDistribute, Cons.toCommunity_) / 100;
        
        payoutsTo_[_MZBossAddress] = payoutsTo_[_MZBossAddress] + (int256)(_toMZBoss);
        payoutsTo_[_communityAddress] = payoutsTo_[_communityAddress] + (int256)(_communityDistribution);
        
        sendPotProfit((uint256)(payoutsTo_[_MZBossAddress]));
        _communityAddress.transfer((uint256)(payoutsTo_[_communityAddress]));
        
        payoutsTo_[_MZBossAddress] = 0;
        payoutsTo_[_communityAddress] = 0;
        
        // after tax
        uint256 _taxedEthereum = SafeMath.sub(_profitToDistribute, SafeMath.add(_communityDistribution, _toMZBoss));
        
        // profit go to the last painter    
        uint256 _distributionToLast = SafeMath.mul(_taxedEthereum, Cons.winningLast_)/100;
        
        // update the payoutsTo_ of the last painter    
        payoutsTo_[_lastAddress] = payoutsTo_[_lastAddress] - (int256)(_distributionToLast);
        
        // the rest goes to the color winner    
        uint256 _profitToColorBet = SafeMath.sub(_taxedEthereum, _distributionToLast);

        // activate result and distribution of color betting
        winnerColor(_profitToColorBet);
        
        emit onPotOpen(_profitToDistribute, _distributionToLast, _lastAddress);
    }
    
    /**
     * update block painting information
     */
    function blockSetUpdate(uint256[] _blockIDArray_, uint8[] _setColorArray_)  
        private
    {
        
        address _customerAddress = msg.sender;
        uint256 timeNew_ = now;
        
        for (uint i = 0; i < _blockIDArray_.length; i++) { 
            
            uint256 blockID_ = _blockIDArray_[i];
            uint8 setColor_ = _setColorArray_[i]; 
            
            if ((blockID_ >= 0) && (blockID_ < totalBlock_)&&(setColor_ > 0) && (setColor_ < totalNumberColor_+1)){
                
            // update block price
            if (blockSetPrice_[blockID_] == 0){
    
                blockSetPrice_[blockID_] = Cons.setCheckPriceInitial_;
                changedBlockID_.push(blockID_);
                
            }else{
                uint8 _originalColor = blockColor_[blockID_];
                // update color count of the replaced color
                totalColor_[_originalColor] = totalColor_[_originalColor] - 1;
            }
        
            // update color count of the new color
            totalColor_[setColor_] = totalColor_[setColor_] + 1;
        
            // calculate incomming after tax
            uint256 blockExpense = SafeMath.mul(blockSetPrice_[blockID_], (100 - Cons.dividendFee_ - Cons.toCommunity_))/100; 
        
            // update block color and price
            blockColor_[blockID_] = setColor_;

            // get the owner address of the block
            address owner_ = blockAddress_[blockID_];

            // if there is no owner, the money goes to the pot
            if (owner_ == 0x0) {
            
                _totalProfitPot = SafeMath.add(_totalProfitPot, blockExpense);
            
            }else{

                // otherwise 50% goes to the owner
                uint256 toOwner_ = SafeMath.mul(blockExpense, Cons.ratioToOwner_)/100;
           
                // update owner's payoutsTo_ 
                payoutsTo_[owner_] = payoutsTo_[owner_] - (int256)(toOwner_); 
           
                // half of the rest goes to the pot (25%)
                uint256 _toPot = SafeMath.sub(blockExpense, toOwner_)/2;
                _totalProfitPot = SafeMath.add(_totalProfitPot, _toPot);
                
                // the other half of the rest sent to MZBoss and community address
                uint256 _toMZBoss = SafeMath.mul(_toPot, 13) / 25; 
                uint256 _communityDistribution = SafeMath.mul(_toPot, 12) / 25;
                
                payoutsTo_[_communityAddress] = payoutsTo_[_communityAddress] + (int256)(_communityDistribution);
                payoutsTo_[_MZBossAddress] = payoutsTo_[_MZBossAddress] + (int256)(_toMZBoss);
            }  
            
            }

        }   

        emit onSetColor(_customerAddress, _blockIDArray_, _setColorArray_, timeNew_);
    }
    
    /**
     * update block purchase information
     */
    function blockBuyUpdate(uint256[] _blockIDArray_)  
        private
    {
        address _customerAddress = msg.sender;
        uint256[] memory buyBlockPrice_ = new uint256[](_blockIDArray_.length);
        
        for (uint i = 0; i < _blockIDArray_.length; i++) { 
            
            uint256 blockID_ = _blockIDArray_[i]; 
        
            if ((blockID_ >= 0) && (blockID_ < totalBlock_)){
                
                uint256 priceNow_ = blockBuyPrice_[blockID_];
            
                // update block price
                if (blockAddress_[blockID_] == 0x0){
                
                    priceNow_ = Cons.buyPriceInitial_;
                    
                    uint256 afterTax_ = SafeMath.mul(priceNow_, (100 - Cons.dividendFee_ - Cons.toCommunity_))/100;
                
                    _totalProfitPot = SafeMath.add(_totalProfitPot, afterTax_);
                
                }else{
            
                    // get address of previous owner
                    address previous_ = blockAddress_[blockID_];
                    afterTax_ = SafeMath.mul(priceNow_, (100 - Cons.dividendFee_ - Cons.toCommunity_))/100;
            
                    // 90% to previous owner
                    uint256 toPrevious_ = SafeMath.mul(afterTax_, Cons.ratioToPrevious_)/100;
                    
                    // update payoutsTo_of previous owner
                    payoutsTo_[previous_] = payoutsTo_[previous_] - (int256)(toPrevious_); 
                    
                    // the rest goes to pot
                    _totalProfitPot = SafeMath.add(_totalProfitPot, SafeMath.sub(afterTax_, toPrevious_));
                    
                    // update number of blocks owned by previous owner
                    ownBlockNumber_[previous_] = SafeMath.sub(ownBlockNumber_[previous_], 1);
                }
                
                // update block purchase price
                blockBuyPrice_[blockID_] = SafeMath.mul(priceNow_, Cons.buyPriceAdd_)/100;
                
                buyBlockPrice_[i] = blockBuyPrice_[blockID_];
                
                //owner of the block
                blockAddress_[blockID_] = _customerAddress;
                
                // number of blocks owned by the new owner
                ownBlockNumber_[_customerAddress] = SafeMath.add(ownBlockNumber_[_customerAddress], 1);
            
            }
        
        } 

        // track the time 
        uint256 timeNew_ = now;
        
        emit onBuyBlock(_customerAddress, _blockIDArray_, buyBlockPrice_, timeNew_);
 
    }
    
    /** send eth to MZBoss
	 *
	 */
	function sendPotProfit(uint256 valueToSend)
	    private
	{
		
		MZBoss m = MZBoss(_MZBossAddress);
		m.potDistribution.value(valueToSend)();
	}
	
    /**
     * convert buy color input array and check purchase expense is enough or not
     */
    
    function buyPriceArray(uint256[] _buyBlockIDArray_) 
        private
        returns (uint256)
    {
        
        uint256 totalBuyExpense_ = 0;
        
        for (uint i = 0; i < _buyBlockIDArray_.length; i++) {

            uint256 ID_ = _buyBlockIDArray_[i];
            
            if ((ID_ >= 0) && (ID_ < totalBlock_)){
                
                priceAssume_[ID_] = blockBuyPrice(ID_);
            
            }
        }
        for (i = 0; i < _buyBlockIDArray_.length; i++) {

            ID_ = _buyBlockIDArray_[i];
            
            if ((ID_ >= 0) && (ID_ < totalBlock_)){
                
               totalBuyExpense_ = SafeMath.add(totalBuyExpense_, priceAssume_[ID_]);

               priceAssume_[ID_] = SafeMath.mul(priceAssume_[ID_], Cons.buyPriceAdd_)/100;

            }
        }
        return totalBuyExpense_;
        
    }
    
    
    /**
     * reserve extended function 
     */ 
    function extendFunctionUpdate(uint256[] _blockIDArray_, address[] _blockAddressArray_, uint256[] _blockBuyPriceArray_, uint8[] _blockColorArray_) 
        onlyExtendFunction()
        public
    {
        address _customerAddress = msg.sender;
        
        // update information with incomming array
        for (uint i = 0; i < _blockIDArray_.length; i++) {
            uint256 blockIDUpdate_ = _blockIDArray_[i];
            uint8 blockColorUpdate_ = _blockColorArray_[i];
            
            if ((blockIDUpdate_ >= 0) && (blockIDUpdate_ < totalBlock_) && (blockColorUpdate_ > 0) && (blockColorUpdate_ < totalNumberColor_+1)) {
                
                if (blockSetPrice_[blockIDUpdate_] == 0){
                    
                    changedBlockID_.push(blockIDUpdate_);
                    blockSetPrice_[blockIDUpdate_] = Cons.setCheckPriceInitial_;
                
                }
                
                blockBuyPrice_[blockIDUpdate_] = _blockBuyPriceArray_[i];
                
                // update color count of the replaced color
                if(blockColor_[blockIDUpdate_] > 0){
                           
                    totalColor_[blockColor_[blockIDUpdate_]] = totalColor_[blockColor_[blockIDUpdate_]] - 1;
                }      
                
                    blockColor_[blockIDUpdate_] = _blockColorArray_[i];
                
                    // update color count of the new color
                    totalColor_[_blockColorArray_[i]] = totalColor_[_blockColorArray_[i]] + 1;
                
                if(blockAddress_[blockIDUpdate_] != 0x0){
                    
                    ownBlockNumber_[blockAddress_[blockIDUpdate_]] = ownBlockNumber_[blockAddress_[blockIDUpdate_]] - 1;
                }
                
                blockAddress_[blockIDUpdate_] = _blockAddressArray_[i];
                
                if(blockAddress_[blockIDUpdate_] != 0x0){
                    
                    ownBlockNumber_[blockAddress_[blockIDUpdate_]] = ownBlockNumber_[blockAddress_[blockIDUpdate_]] + 1;
                }
                

            }
            
        }

        emit onExtendFunction(
            _customerAddress,
            _blockIDArray_,
            _blockColorArray_,
            _blockBuyPriceArray_,
            _blockAddressArray_
        );
    
    }
    

    
    /**
     * check maximum color and calculate winning profit 
     */
    function winnerColor(uint256 _distributionAmount) // 1 red, 2 yellow, 3 blue, 4 black, 5 green
        private

    {
        uint256 Maximum = totalColor_[1];
        
        // find the number of blocks of the maximum color
        for (uint i = 2; i < 6; i++) {
            
            if (Maximum < totalColor_[i]) {
                
                Maximum = totalColor_[i];
                
            }
            
        }
        
        if (Maximum != 0){

            uint256 totalMaxColor_ = 0;
            uint256[6] memory MaximumSign;
            // find how many colors are the winner
            for ( i = 1; i < 6; i++) {
              
                if (Maximum == totalColor_[i]) {
                    
                    MaximumSign[i] = 1;
                }else{
                  
                    MaximumSign[i] = 0;  
                }
                // calculate total color winners
                totalMaxColor_ += MaximumSign[i];
                
            } 
        
            
            // evenly distribute the profit for color winner to each winning color        
            if (totalMaxColor_ > 0){
                uint256 _distributionAmountEach = _distributionAmount/totalMaxColor_;
            }
        
            // calculate winning ETH per share of players in each color        
            for (i = 1; i < 6; i++) {
              
                if (totalGuess[i] > 0){
                
                    uint256 winningProfitPerShare_ = SafeMath.mul(_distributionAmountEach, Cons.magnitude) / totalGuess[i];
                    winningPerShareNew_[i] = SafeMath.mul(winningProfitPerShare_, MaximumSign[i]);
                    winningPerShare_[i] = SafeMath.add(winningPerShare_[i], winningPerShareNew_[i]);
              
                }
            }
        }
        
        emit onWinnerColor(
            
            totalColor_[1],
            totalColor_[2],
            totalColor_[3],
            totalColor_[4],
            totalColor_[5],
            winningPerShareNew_[1],
            winningPerShareNew_[2],
            winningPerShareNew_[3],
            winningPerShareNew_[4],
            winningPerShareNew_[5]
            
            );
        
    }   
    
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}