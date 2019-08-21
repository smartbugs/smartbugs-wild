pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Ownable {
  address private _owner;

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
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

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

contract GamePool is Ownable, usingOraclize {
    using SafeMath for uint256;
    
    enum RecordType { StartExRate, EndExRate, RandY }
    
    struct QueryRecord {
        RecordType recordType;
        uint256 gameId;
        uint256 arg;
    }
    
    mapping (bytes32 => QueryRecord) public queryRecords;
    
    GameLogic.Instance[] public games;
    GameLogic.GameBets[] gameBets;
    
    address public txFeeReceiver;
    uint256 public oraclizeFee;
    
    uint256 public MIN_BET = 100 finney; // 0.1 ether.
    uint256 public HIDDEN_TIME_BEFORE_CLOSE = 5 minutes;
    uint256 public ORICALIZE_GAS_LIMIT = 120000;
    uint256 public CLAIM_AWARD_TIME_AFTER_CLOSE = 30 days;
    uint256 public CLAIM_REFUND_TIME_AFTER_CLOSE = 6 hours;
    uint256 public MAX_FETCHING_TIME_FOR_END_EXRATE = 3 hours;
    
    event StartExRateUpdated(uint256 indexed gameId, uint256 coinId, int32 rate, uint256 timeStamp);
    event EndExRateUpdated(uint256 indexed gameId, uint256 coinId, int32 rate, uint256 timeStamp);
    event GameYChoosed(uint256 indexed gameId, uint8 Y);
    
    event Log(string message);
    event LogAddr(address addr);
    event CoinBet(uint256 indexed gameId, uint256 coinId, address player, uint256 amount);
    event CoinLargestBetChanged(uint256 indexed gameId, uint256 coinId, uint256 amount);
    event SendAwards(uint256 indexed gameId, address player, uint256 awards);
    event RefundClaimed(uint256 indexed gameId, address player, uint256 amount);
    event OraclizeFeeReceived(uint256 received);
    event OraclizeFeeUsed(uint256 used);
    event SentOraclizeQuery(bytes32 queryId);
    event SendTxFee(address receiver, uint256 feeAmount);
    event GetUnclaimedAwards(uint256 indexed gameId, address receiver, uint256 feeAmount);
    event GetUnclaimedRefunds(uint256 indexed gameId, address receiver, uint256 feeAmount);
    
    event GameCreated(uint256 gameId);
    
    event GameClosed(uint256 indexed gameId);
    event GameExtended(uint256 indexed gameId, uint256 closeTime);
    event GameWaitToClose(uint256 indexed gameId);
    event GameReady(uint256 indexed gameId);
    event GameOpened(uint256 indexed gameId);
    
    modifier hasGameId(uint256 _gameId) {
         require(_gameId < games.length && games.length == gameBets.length);
         _;
    }
    
    modifier hasCoinId(uint256 _coinId) {
         require(_coinId < 5);
         _;
    }
    
    constructor(address _txFeeReceiver) public {
        require(address(0) != _txFeeReceiver);
        txFeeReceiver = _txFeeReceiver;
        
        //OAR = OraclizeAddrResolverI(0x0BffB729b30063E53A341ba6a05dfE8f817E7a53);
        //emit LogAddr(oraclize_cbAddress());
    }
    
    function packedCommonData() 
        public 
        view 
        returns (address _txFeeReceiver
            , uint256 _minimumBets
            , uint256 _hiddenTimeLengthBeforeClose
            , uint256 _claimAwardTimeAfterClose
            , uint256 _claimRefundTimeAfterColose
            , uint256 _maximumFetchingTimeForEndExRate
            , uint256 _numberOfGames)
    {
        _txFeeReceiver = txFeeReceiver;
        _minimumBets = MIN_BET;
        _hiddenTimeLengthBeforeClose = HIDDEN_TIME_BEFORE_CLOSE;
        _claimAwardTimeAfterClose = CLAIM_AWARD_TIME_AFTER_CLOSE;
        _claimRefundTimeAfterColose = CLAIM_REFUND_TIME_AFTER_CLOSE;
        _maximumFetchingTimeForEndExRate = MAX_FETCHING_TIME_FOR_END_EXRATE;
        _numberOfGames = games.length;
    }
    
    function createNewGame(uint256 _openTime
        , uint256 _duration
        , string _coinName0
        , string _coinName1
        , string _coinName2
        , string _coinName3
        , string _coinName4
        , uint8[50] _YDistribution
        , uint8 _A
        , uint8 _B
        , uint16 _txFee
        , uint256 _minDiffBets) onlyOwner public
    {
        // Check inputs.
        require(_A <= 100 && _B <= 100 && _A + _B <= 100);
        
        require(_YDistribution[0] <= 100);
        require(_YDistribution[1] <= 100);
        require(_YDistribution[2] <= 100);
        require(_YDistribution[3] <= 100);
        require(_YDistribution[4] <= 100);
        require(_YDistribution[5] <= 100);
        require(_YDistribution[6] <= 100);
        require(_YDistribution[7] <= 100);
        require(_YDistribution[8] <= 100);
        require(_YDistribution[9] <= 100);
        require(_YDistribution[10] <= 100);
        require(_YDistribution[11] <= 100);
        require(_YDistribution[12] <= 100);
        require(_YDistribution[13] <= 100);
        require(_YDistribution[14] <= 100);
        require(_YDistribution[15] <= 100);
        require(_YDistribution[16] <= 100);
        require(_YDistribution[17] <= 100);
        require(_YDistribution[18] <= 100);
        require(_YDistribution[19] <= 100);
        require(_YDistribution[20] <= 100);
        require(_YDistribution[21] <= 100);
        require(_YDistribution[22] <= 100);
        require(_YDistribution[23] <= 100);
        require(_YDistribution[24] <= 100);
        require(_YDistribution[25] <= 100);
        require(_YDistribution[26] <= 100);
        require(_YDistribution[27] <= 100);
        require(_YDistribution[28] <= 100);
        require(_YDistribution[29] <= 100);
        require(_YDistribution[30] <= 100);
        require(_YDistribution[31] <= 100);
        require(_YDistribution[32] <= 100);
        require(_YDistribution[33] <= 100);
        require(_YDistribution[34] <= 100);
        require(_YDistribution[35] <= 100);
        require(_YDistribution[36] <= 100);
        require(_YDistribution[37] <= 100);
        require(_YDistribution[38] <= 100);
        require(_YDistribution[39] <= 100);
        require(_YDistribution[40] <= 100);
        require(_YDistribution[41] <= 100);
        require(_YDistribution[42] <= 100);
        require(_YDistribution[43] <= 100);
        require(_YDistribution[44] <= 100);
        require(_YDistribution[45] <= 100);
        require(_YDistribution[46] <= 100);
        require(_YDistribution[47] <= 100);
        require(_YDistribution[48] <= 100);
        require(_YDistribution[49] <= 100);
        
        require(_openTime >= now);
        require(_duration > 0);
        
        require(_txFee <= 1000); // < 100%
        
        if (0 != games.length) {
            GameLogic.State state = GameLogic.state(games[games.length - 1]
                , gameBets[games.length - 1]);
            require(GameLogic.State.Closed == state || GameLogic.State.Error == state);
        }
        
        // Create new game data.
        games.length++;
        gameBets.length++;
        
        GameLogic.Instance storage game = games[games.length - 1];
        
        game.id = games.length - 1;
        game.openTime = _openTime;
        game.closeTime = _openTime + _duration - 1;
        game.duration = _duration;
        game.hiddenTimeBeforeClose = HIDDEN_TIME_BEFORE_CLOSE;
        game.claimTimeAfterClose = CLAIM_AWARD_TIME_AFTER_CLOSE
            | (CLAIM_REFUND_TIME_AFTER_CLOSE << 128);
        game.maximumFetchingTimeForEndExRate = MAX_FETCHING_TIME_FOR_END_EXRATE;
        
        game.coins[0].name = _coinName0;
        game.coins[1].name = _coinName1;
        game.coins[2].name = _coinName2;
        game.coins[3].name = _coinName3;
        game.coins[4].name = _coinName4;
        
        game.YDistribution = _YDistribution;
        game.A = _A;
        game.B = _B;
        game.txFee = _txFee;
        game.minDiffBets = _minDiffBets;
        game.isFinished = false;
        game.isYChoosed = false;
        
        emit GameCreated(game.id);
    }
    
    function gamePackedCommonData(uint256 _gameId)
        hasGameId(_gameId)
        public
        view
        returns (uint256 openTime
            , uint256 closeTime
            , uint256 duration
            , uint8[50] YDistribution
            , uint8 Y
            , uint8 A
            , uint8 B
            , uint8 state
            , uint8 winnerMasks
            , uint16 txFee
            , uint256 minDiffBets)
    {
        GameLogic.Instance storage game = games[_gameId];
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        openTime = game.openTime;
        closeTime = game.closeTime;
        duration = game.duration;
        YDistribution = game.YDistribution;
        Y = game.Y;
        A = game.A;
        B = game.B;
        state = uint8(GameLogic.state(game, bets));
        txFee = game.txFee;
        minDiffBets = game.minDiffBets;
        
        winnerMasks = gameWinnerMask(_gameId);
    }
    
    function gameWinnerMask(uint256 _gameId)
        hasGameId(_gameId)
        public
        view
        returns (uint8 winnerMasks)
    {
        GameLogic.Instance storage game = games[_gameId];
        
        winnerMasks = 0;
        for (_gameId = 0; _gameId < game.winnerCoinIds.length; ++_gameId) {
            winnerMasks |= uint8(1 << game.winnerCoinIds[_gameId]);
        }
    }
    
    
    function gameCoinData(uint256 _gameId, uint256 _coinId)
        hasGameId(_gameId)
        hasCoinId(_coinId)
        public 
        view 
        returns (string name, int32 startExRate, uint256 timeStampOfStartExRate
                 , int32 endExRate, uint256 timeStampOfEndExRate)
    {
        GameLogic.Instance storage game = games[_gameId];
        
        name = game.coins[_coinId].name;
        startExRate = int32(game.coins[_coinId].startExRate);
        timeStampOfStartExRate = game.coins[_coinId].timeStampOfStartExRate;
        endExRate = int32(game.coins[_coinId].endExRate);
        timeStampOfEndExRate = game.coins[_coinId].timeStampOfEndExRate;
    }
    
    function gamePackedCoinData(uint256 _gameId)
        hasGameId(_gameId)
        public 
        view 
        returns (bytes32[5] encodedName
            , uint256[5] timeStampOfStartExRate
            , uint256[5] timeStampOfEndExRate
            , int32[5] startExRate
            , int32[5] endExRate)
    {
        GameLogic.Instance storage game = games[_gameId];
        
        for (uint256 i = 0 ; i < 5; ++i) {
            encodedName[i] = GameLogic.encodeCoinName(game.coins[i].name);
            startExRate[i] = int32(game.coins[i].startExRate);
            timeStampOfStartExRate[i] = game.coins[i].timeStampOfStartExRate;
            endExRate[i] = int32(game.coins[i].endExRate);
            timeStampOfEndExRate[i] = game.coins[i].timeStampOfEndExRate;
        }
    }
    
    function gameBetData(uint256 _gameId, uint256 _coinId)
        hasGameId(_gameId)
        hasCoinId(_coinId)
        public 
        view 
        returns (uint256 totalBets, uint256 largestBets, uint256 numberOfBets)
    {
        GameLogic.Instance storage game = games[_gameId];
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        if (!GameLogic.isBetInformationHidden(game)) {
            GameLogic.CoinBets storage c = bets.coinbets[_coinId];
            totalBets = c.totalBetAmount;
            numberOfBets = c.bets.length;
            largestBets = c.largestBetAmount;
        }
    }
    
    function gamePackedBetData(uint256 _gameId)
        hasGameId(_gameId)
        public 
        view 
        returns (uint256[5] totalBets
            , uint256[5] largestBets
            , uint256[5] numberOfBets)
    {
        GameLogic.Instance storage game = games[_gameId];
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        for (uint256 i = 0; i < 5; ++i) {
            if (GameLogic.isBetInformationHidden(game)) {
                totalBets[i] = largestBets[i] = numberOfBets[i] = 0;
            } else {
                GameLogic.CoinBets storage c = bets.coinbets[i];
                
                totalBets[i] = c.totalBetAmount;
                largestBets[i] = c.largestBetAmount;
                numberOfBets[i] = c.bets.length;
            }
        }
    }
    
    function numberOfGames() public view returns (uint256) {
        return games.length;
    }
    
    function gameNumberOfWinnerCoinIds(uint256 _gameId) 
        hasGameId(_gameId)
        public 
        view 
        returns (uint256)
    {
        return games[_gameId].winnerCoinIds.length;
    }
    
    function gameWinnerCoinIds(uint256 _gameId, uint256 _winnerId) 
        hasGameId(_gameId)
        public
        view
        returns (uint256)
    {
        GameLogic.Instance storage game = games[_gameId];
        require(_winnerId < game.winnerCoinIds.length);
        
        return game.winnerCoinIds[_winnerId];
    }
    
    function gameState(uint256 _gameId) public view returns (GameLogic.State) {
        if (_gameId < games.length) {
            return GameLogic.state(games[_gameId], gameBets[_gameId]);
        } else {
            return GameLogic.State.NotExists;
        }
    }
    
    function isBetInformationHidden(uint256 _gameId) 
        hasGameId(_gameId)
        public
        view
        returns (bool)
    {
        return GameLogic.isBetInformationHidden(games[_gameId]);
    }
    
    function bet(uint256 _gameId, uint256 _coinId) 
        hasGameId(_gameId)
        hasCoinId(_coinId)
        public 
        payable
    {
        require(msg.value >= MIN_BET);
        
        GameLogic.Instance storage game = games[_gameId];
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        GameLogic.bet(game, bets, _coinId, txFeeReceiver);
    }
    
    function fetchStartExRate(uint256 _gameId) 
        hasGameId(_gameId)
        onlyOwner
        public
    {
        // Check the game state.
        GameLogic.Instance storage game = games[_gameId];
        require(GameLogic.state(game, gameBets[_gameId]) == GameLogic.State.Created);
        
        // Check the tx fee amount.
        require(address(this).balance >= oraclizeFee);
        
        // Query all start exchange rate.
        string memory url;
        bytes32 queryId;
        
        for (uint256 i = 0; i < 5; ++i) {
            url = strConcat("json(https://api.binance.com/api/v3/ticker/price?symbol=", game.coins[i].name, "USDT).price");
            queryId = _doOraclizeQuery(url);
            queryRecords[queryId] = QueryRecord(RecordType.StartExRate, game.id, i);
        }
    }    
    
    function fetchEndExRate(uint256 _gameId) 
        hasGameId(_gameId)
        onlyOwner
        public 
    {
        // Check the game state.
        GameLogic.Instance storage game = games[_gameId];
        require(GameLogic.state(game, gameBets[_gameId]) == GameLogic.State.Stop);
        
        // Check the tx fee amount.
        require(address(this).balance >= oraclizeFee);
        
        // Query all end exchange rate.
        string memory url;
        bytes32 queryId;
        
        for (uint256 i = 0; i < 5; ++i) {
            url = strConcat("json(https://api.binance.com/api/v3/ticker/price?symbol=", game.coins[i].name, "USDT).price");
            queryId = _doOraclizeQuery(url);
            queryRecords[queryId] = QueryRecord(RecordType.EndExRate, game.id, i);
        }
        
        // Query rand y.
        queryId = _doOraclizeQuery("https://www.random.org/integers/?num=1&min=0&max=49&col=1&base=10&format=plain&rnd=new");
        queryRecords[queryId] = QueryRecord(RecordType.RandY, game.id, 0);
    }
    
    function close(uint256 _gameId) 
        hasGameId(_gameId)
        onlyOwner 
        public
        returns (bool)
    {
        GameLogic.Instance storage game = games[_gameId];
        GameLogic.GameBets storage bets = gameBets[_gameId];
            
        require(GameLogic.state(game, bets) == GameLogic.State.WaitToClose);
        
        if (0 != bets.totalAwards) {
            GameLogic.tryClose(game, bets);
        }

        if (game.isFinished) {
            GameLogic.calculateAwardForCoin(game, bets, bets.totalAwards);
            emit GameClosed(_gameId);
        } else {
            game.Y = 0;
            game.isYChoosed = false;
            game.coins[0].endExRate = 0;
            game.coins[1].endExRate = 0;
            game.coins[2].endExRate = 0;
            game.coins[3].endExRate = 0;
            game.coins[4].endExRate = 0;
            game.coins[0].timeStampOfEndExRate = 0;
            game.coins[1].timeStampOfEndExRate = 0;
            game.coins[2].timeStampOfEndExRate = 0;
            game.coins[3].timeStampOfEndExRate = 0;
            game.coins[4].timeStampOfEndExRate = 0;
            
            // ((now - open) / duration + 1) * duration + open - 1;
            game.closeTime = now.sub(game.openTime).div(game.duration).add(1).mul(game.duration).add(game.openTime).sub(1);
            emit GameExtended(_gameId, game.closeTime);
        }
        
        return game.isFinished;
    }
    
    function calculateAwardAmount(uint256 _gameId) 
        hasGameId(_gameId)
        public
        view
        returns (uint256)
    {
        GameLogic.State queryGameState = gameState(_gameId);
        if (GameLogic.State.Closed == queryGameState) {
            GameLogic.Instance storage game = games[_gameId];
            GameLogic.GameBets storage bets = gameBets[_gameId];
        
            return GameLogic.calculateAwardAmount(game, bets);
        } else {
            return 0;
        }
    }
    
    function calculateRefund(uint256 _gameId) 
        hasGameId(_gameId)
        public
        view
        returns (uint256)
    {
        GameLogic.State queryGameState = gameState(_gameId);
        if (GameLogic.State.Error == queryGameState) {
            GameLogic.Instance storage game = games[_gameId];
            GameLogic.GameBets storage bets = gameBets[_gameId];
        
            return GameLogic.calculateRefundAmount(game, bets);
        } else {
            return 0;
        }
    }
    
    function getAwards(uint256 _gameId) hasGameId(_gameId) public {
        uint256 amount = calculateAwardAmount(_gameId);
        if (0 < amount) {
            GameLogic.GameBets storage bets = gameBets[_gameId];
            require(bets.totalAwards.sub(bets.claimedAwards) >= amount);
            
            bets.isAwardTransfered[msg.sender] = true;
            bets.claimedAwards = bets.claimedAwards.add(amount);
            
            msg.sender.transfer(amount);
            emit SendAwards(_gameId, msg.sender, amount);
        }
    }
    
    function claimRefunds(uint256 _gameId) hasGameId(_gameId) public {
        uint256 amount = calculateRefund(_gameId);
        if (0 < amount) {
            GameLogic.GameBets storage bets = gameBets[_gameId];
            
            bets.isRefunded[msg.sender] = true;
            bets.claimedRefunds = bets.claimedRefunds.add(amount);
            
            msg.sender.transfer(amount);
            emit RefundClaimed(_gameId, msg.sender, amount);
        }
    }
    
    function withdrawOraclizeFee() public onlyOwner {
        require(address(this).balance >= oraclizeFee);
        uint256 amount = oraclizeFee;
        oraclizeFee = 0;
        owner().transfer(amount);
    }
    
    function getUnclaimedAward(uint256 _gameId) 
        hasGameId(_gameId) 
        onlyOwner 
        public
    {
        GameLogic.Instance storage game = games[_gameId];
        require(GameLogic.endTimeOfAwardsClaiming(game) < now);
        
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        uint256 amount = bets.totalAwards.sub(bets.claimedAwards);
        bets.claimedAwards = bets.totalAwards;
        
        owner().transfer(amount);
        emit GetUnclaimedAwards(_gameId, owner(), amount);
    }
    
    function getUnclaimedRefunds(uint256 _gameId) 
        hasGameId(_gameId) 
        onlyOwner 
        public
    {
        GameLogic.Instance storage game = games[_gameId];
        require(GameLogic.endTimeOfRefundsClaiming(game) < now);
        
        GameLogic.GameBets storage bets = gameBets[_gameId];
        
        uint256 amount = bets.totalAwards.sub(bets.claimedRefunds);
        bets.claimedRefunds = bets.totalAwards;
        
        owner().transfer(amount);
        emit GetUnclaimedRefunds(_gameId, owner(), amount);
    }
    
    function sendOraclizeFee() public payable {
        oraclizeFee = oraclizeFee.add(msg.value);
        emit OraclizeFeeReceived(msg.value);
    }
    
    function () public payable {
        sendOraclizeFee();
    }
    
    // Callback for oraclize query.
    function __callback(bytes32 _id, string _result) public {
        assert(msg.sender == oraclize_cbAddress());
        
        uint256 gameId = queryRecords[_id].gameId;
        GameLogic.Instance storage game = games[gameId];
        GameLogic.GameBets storage gameBet = gameBets[gameId];
        
        if (RecordType.RandY == queryRecords[_id].recordType) {
            if (now <= game.closeTime.add(game.maximumFetchingTimeForEndExRate)) {
                game.Y = game.YDistribution[parseInt(_result)];
                game.isYChoosed = true;
                delete queryRecords[_id];
                emit GameYChoosed(gameId, game.Y);
            
                if (GameLogic.state(game, gameBet) == GameLogic.State.WaitToClose) {
                    emit GameWaitToClose(gameId);
                }   
            } else {
                delete queryRecords[_id];
            }
            
        } else {
            uint256 coinId = queryRecords[_id].arg;
            if (RecordType.StartExRate == queryRecords[_id].recordType) {
                if (now <= game.closeTime) {
                    game.coins[coinId].startExRate = int256(parseInt(_result, 5));
                    game.coins[coinId].timeStampOfStartExRate = now;
                    
                    delete queryRecords[_id];
                    emit StartExRateUpdated(gameId, coinId, int32(game.coins[coinId].startExRate), now);
                
                    if (GameLogic.state(game, gameBet) == GameLogic.State.Ready) {
                        emit GameReady(gameId);
                    } else if (GameLogic.state(game, gameBet) == GameLogic.State.Open) {
                        emit GameOpened(gameId);
                    }
                } else {
                    delete queryRecords[_id];
                }
            } else if (RecordType.EndExRate == queryRecords[_id].recordType) {
                if (now <= game.closeTime.add(game.maximumFetchingTimeForEndExRate)) {
                    game.coins[coinId].endExRate = int256(parseInt(_result, 5));
                    game.coins[coinId].timeStampOfEndExRate = now;
                    delete queryRecords[_id];
                    emit EndExRateUpdated(gameId, coinId, int32(game.coins[coinId].endExRate), now);
                
                    if (GameLogic.state(game, gameBet) == GameLogic.State.WaitToClose) {
                        emit GameWaitToClose(gameId);
                    }
                } else {
                    delete queryRecords[_id];
                }
            } else {
                revert();
            }
        }
    }
    
    function _doOraclizeQuery(string url) private returns (bytes32) {
        uint256 fee = oraclize_getPrice("URL", ORICALIZE_GAS_LIMIT);
        require(fee <= oraclizeFee);
        oraclizeFee = oraclizeFee.sub(fee);
        
        bytes32 queryId = oraclize_query("URL", url, ORICALIZE_GAS_LIMIT);
        
        emit OraclizeFeeUsed(fee);
        emit SentOraclizeQuery(queryId);
        
        return queryId;
    }
}
library GameLogic {
    using SafeMath for uint256;

    enum State { NotExists, Created, Ready, Open, Stop, WaitToClose, Closed, Error }
    enum CompareResult { Equal, Less, Greater }

    struct Bets {
        uint256 betAmount;
        uint256 totalBetAmountByFar;
    }

    struct Coin {
        string name;
        int256 startExRate;
        uint256 timeStampOfStartExRate;
        int256 endExRate;
        uint256 timeStampOfEndExRate;
    }

    struct CoinBets {
        uint256 largestBetAmount;
        uint256 numberOfLargestBetTx;
        uint256 totalBetAmount;
        Bets[] bets;
        mapping (address => uint256[]) playerBetMap;
        uint256 yThreshold;
        uint256 awardAmountBeforeY;
        uint256 awardAmountAfterY;
        uint256 awardAmountForLargestBetPlayers;
        uint256 totalBetAmountBeforeY;
        uint256 totalBetAmountAfterY;
    }

    struct Instance {
        uint256 id;
        
        uint256 openTime;
        uint256 closeTime;
        uint256 duration;
        uint256 hiddenTimeBeforeClose;
        uint256 claimTimeAfterClose;    // [0~127] award, [128~255]refunds
        uint256 maximumFetchingTimeForEndExRate;
        
        uint8[50] YDistribution;
        uint8 Y;
        uint8 A;
        uint8 B;
        uint16 txFee;
        bool isFinished;
        bool isYChoosed;
        uint256 minDiffBets;
        
        uint256[] winnerCoinIds;
        
        Coin[5] coins;
    }

    struct GameBets {
        CoinBets[5] coinbets;
        mapping (address => bool) isAwardTransfered;
        mapping (address => bool) isRefunded;
        uint256 totalAwards;
        uint256 claimedAwards;
        uint256 claimedRefunds;
    }
    
    event CoinBet(uint256 indexed gameId, uint256 coinId, address player, uint256 amount);
    event CoinLargestBetChanged(uint256 indexed gameId, uint256 coinId, uint256 amount);
    event SendTxFee(address receiver, uint256 feeAmount);

    function isEndExRateAndYFetched(Instance storage game) 
        public
        view
        returns (bool)
    {
        return (0 != game.coins[0].endExRate && 
                0 != game.coins[1].endExRate &&
                0 != game.coins[2].endExRate &&
                0 != game.coins[3].endExRate &&
                0 != game.coins[4].endExRate &&
                game.isYChoosed);
    }

    function isStartExRateFetched(Instance storage game) 
        public
        view
        returns (bool)
    {
        return (0 != game.coins[0].startExRate && 
                0 != game.coins[1].startExRate &&
                0 != game.coins[2].startExRate &&
                0 != game.coins[3].startExRate &&
                0 != game.coins[4].startExRate);
    }

    function state(Instance storage game, GameBets storage bets) 
        public 
        view 
        returns (State)
    {
        if (game.isFinished) {
            return State.Closed;
        } else if (now > game.closeTime.add(game.maximumFetchingTimeForEndExRate)) {
            if (!isEndExRateAndYFetched(game)) {
                return State.Error;
            } else {
                return State.WaitToClose;
            }
        } else if (now > game.closeTime) {
            if (!isStartExRateFetched(game)) {
                return State.Error;
            } else if (isEndExRateAndYFetched(game) || 0 == bets.totalAwards) {
                return State.WaitToClose;
            } else {
                return State.Stop;
            }
        } else {
            if (isStartExRateFetched(game)) {
                if (now >= game.openTime) {
                    return State.Open;
                } else {
                    return State.Ready;
                }
            } else {
                return State.Created;
            }
        }
    }

    function tryClose(Instance storage game, GameBets storage bets)
        public 
        returns (bool) 
    {
        require(state(game, bets) == State.WaitToClose);
        
        uint256 largestIds = 0;
        uint256 smallestIds = 0;
        uint256 otherIds = 0;
        
        uint256 i = 0;
        CompareResult result;
        for (; i < 5; ++i) {
            // Remove the orphan coins which no one has bet.
            if (bets.coinbets[i].totalBetAmount == 0) {
                continue;
            }
            
            // Compare with the largest coin id.
            if (0 == (largestIds & 0x7)) {
                largestIds = i + 1;
                continue;
            } else {
                result = compare(game.coins[(largestIds & 0x7) - 1], game.coins[i]);
                if (CompareResult.Equal == result) {
                    largestIds = pushToLargestOrSmallestIds(bets, largestIds, i);
                    continue;
                } else if (CompareResult.Less == result) {
                    if (0 == (smallestIds & 0x7)) {
                        smallestIds = largestIds;
                    } else {
                        otherIds = pushToOtherIds(bets, otherIds, largestIds);
                    }
                    
                    largestIds = i + 1;
                    continue;
                }
            }
            
            // Compare with the smallest coin id.
            if (0 == (smallestIds & 0x7)) {
                smallestIds = i + 1;
                continue;
            } else {
                result = compare(game.coins[(smallestIds & 0x7) - 1], game.coins[i]);
                if (CompareResult.Equal == result) {
                    smallestIds = pushToLargestOrSmallestIds(bets, smallestIds, i);
                    continue;
                } else if (CompareResult.Greater == result) {
                    if (0 == (largestIds & 0x7)) {
                        largestIds = smallestIds;
                    } else {
                        otherIds = pushToOtherIds(bets, otherIds, smallestIds);
                    }
                        
                    smallestIds = i + 1;
                    continue;
                }
            }
            
            // Assign to 'other' group.
            otherIds = pushToOtherIds(bets, otherIds, i + 1);
        }
        
        // Choose winners.
        require(otherIds < 512);
        
        if (smallestIds == 0) {
            if (largestIds != 0) {
                game.isFinished = true;
                convertTempIdsToWinnerIds(game, largestIds);
                return true;
            } else {
                return false;
            }
        }
        
        i = bets.coinbets[(largestIds & 0x7) - 1].largestBetAmount;
        uint256 j = bets.coinbets[(smallestIds & 0x7) - 1].largestBetAmount;
        
        // Compare largest and smallest group.
        if (i > j.add(game.minDiffBets)) {
            game.isFinished = true;
            convertTempIdsToWinnerIds(game, largestIds);
        } else if (j > i.add(game.minDiffBets)) {
            game.isFinished = true;
            convertTempIdsToWinnerIds(game, smallestIds);
        } else {
            // Compare other group.
            if (otherIds < 8 && otherIds != 0) {
                // sole winner.
                game.isFinished = true;
                convertTempIdsToWinnerIds(game, otherIds);
            } else if (otherIds >= 8) {
				// compare.
				i = bets.coinbets[(otherIds & 0x7) - 1].totalBetAmount;
				j = bets.coinbets[((otherIds >> 3) & 0x7) - 1].totalBetAmount;

				if (i > j + game.minDiffBets) {
					game.isFinished = true;
					convertTempIdsToWinnerIds(game, otherIds & 0x7);
				} 
			}
        }
        
        return game.isFinished;
    }

    function bet(Instance storage game, GameBets storage gameBets, uint256 coinId, address txFeeReceiver)
        public 
    {
        require(coinId < 5);
        require(state(game, gameBets) == State.Open);
        require(address(0) != txFeeReceiver && address(this) != txFeeReceiver);
        
        uint256 txFeeAmount = msg.value.mul(game.txFee).div(1000);
        if (0 < txFeeAmount) {
            txFeeReceiver.transfer(txFeeAmount);
            emit SendTxFee(txFeeReceiver, txFeeAmount);
        }
        
        CoinBets storage c = gameBets.coinbets[coinId];
        
        c.bets.length++;
        Bets storage b = c.bets[c.bets.length - 1];
        b.betAmount = msg.value.sub(txFeeAmount);
        
        c.totalBetAmount = b.betAmount.add(c.totalBetAmount);
        b.totalBetAmountByFar = c.totalBetAmount;
        gameBets.totalAwards =  gameBets.totalAwards.add(b.betAmount);
        
        c.playerBetMap[msg.sender].push(c.bets.length - 1);
        
        if (b.betAmount > c.largestBetAmount) {
            c.largestBetAmount = b.betAmount;
            c.numberOfLargestBetTx = 1;
            
            emit CoinLargestBetChanged(game.id, coinId, b.betAmount);
            
        } else if (b.betAmount == c.largestBetAmount) {
            ++c.numberOfLargestBetTx;
        }
        
        emit CoinBet(game.id, coinId, msg.sender, b.betAmount);
    }

    function isBetInformationHidden(Instance storage game) 
        public 
        view 
        returns (bool)
    {
        return now <= game.closeTime 
            && now.add(game.hiddenTimeBeforeClose) > game.closeTime;
    }

    function calculateAwardForCoin(Instance storage game
        , GameBets storage bets
        , uint256 awardAmount
    ) 
        public
    {
        require(state(game, bets) == State.Closed);
        awardAmount = awardAmount.div(game.winnerCoinIds.length);
        
        for (uint256 i = 0; i < game.winnerCoinIds.length; ++i) {
            CoinBets storage c = bets.coinbets[game.winnerCoinIds[i]];
            require(c.bets.length > 0);
            
            c.yThreshold = c.bets.length.mul(uint256(game.Y)).div(100);
            if (c.yThreshold.mul(100) < c.bets.length.mul(uint256(game.Y))) {
                ++c.yThreshold;
            }
            
            c.awardAmountAfterY = awardAmount.mul(game.B).div(100);
           
            if (c.yThreshold == 0) {
                c.awardAmountBeforeY = 0;
                c.totalBetAmountBeforeY = 0;
            } else if (c.bets.length == 1) {
                c.awardAmountBeforeY = awardAmount;
                c.awardAmountAfterY = 0;
                c.totalBetAmountBeforeY = c.totalBetAmount;
            } else {
                c.awardAmountBeforeY = awardAmount.mul(game.A).div(100);
                c.totalBetAmountBeforeY = c.bets[c.yThreshold - 1].totalBetAmountByFar;
            }
            
            c.awardAmountForLargestBetPlayers = awardAmount
                .sub(c.awardAmountBeforeY)
                .sub(c.awardAmountAfterY)
                .div(c.numberOfLargestBetTx);
            
            c.totalBetAmountAfterY = c.totalBetAmount.sub(c.totalBetAmountBeforeY);
        }
    }

    function calculateAwardAmount(Instance storage game, GameBets storage bets)
        public 
        view 
        returns (uint256 amount)
    {
        require(state(game, bets) == State.Closed);
        require(0 < game.winnerCoinIds.length);
        
        if (bets.isAwardTransfered[msg.sender]) {
            return 0;
        } else if (endTimeOfAwardsClaiming(game) < now) {
            return 0;
        }
    
        amount = 0;
        
        for (uint256 i = 0; i < game.winnerCoinIds.length; ++i) {
            CoinBets storage c = bets.coinbets[game.winnerCoinIds[i]];
            uint256[] storage betIdList = c.playerBetMap[msg.sender];
            
            for (uint256 j = 0; j < betIdList.length; ++j) {
                Bets storage b = c.bets[betIdList[j]];
                if (betIdList[j] < c.yThreshold) {
                    amount = amount.add(
                        c.awardAmountBeforeY.mul(b.betAmount).div(c.totalBetAmountBeforeY));
                } else {
                    amount = amount.add(
                        c.awardAmountAfterY.mul(b.betAmount).div(c.totalBetAmountAfterY));
                }
                
                if (b.betAmount == c.largestBetAmount) {
                    amount = amount.add(c.awardAmountForLargestBetPlayers);
                }
            }
        }
    }

    function calculateRefundAmount(Instance storage game, GameBets storage bets)
        public 
        view 
        returns (uint256 amount)
    {
        require(state(game, bets) == State.Error);
        amount = 0;
        
        if (bets.isRefunded[msg.sender]) {
            return 0;
        } else if (endTimeOfRefundsClaiming(game) < now) {
            return 0;
        }
        
        for (uint256 i = 0; i < 5; ++i) {
            CoinBets storage c = bets.coinbets[i];
            uint256[] storage betIdList = c.playerBetMap[msg.sender];
            
            for (uint256 j = 0; j < betIdList.length; ++j) {
                Bets storage b = c.bets[betIdList[j]];
                amount = amount.add(b.betAmount);
            }
        }
    }

    function compare(Coin storage coin0, Coin storage coin1) 
        public
        view
        returns (CompareResult)
    {
        int256 value0 = (coin0.endExRate - coin0.startExRate) * coin1.startExRate;
        int256 value1 = (coin1.endExRate - coin1.startExRate) * coin0.startExRate;
        
        if (value0 == value1) {
            return CompareResult.Equal;
        } else if (value0 < value1) {
            return CompareResult.Less;
        } else {
            return CompareResult.Greater;
        }
    }

    function pushToLargestOrSmallestIds(GameBets storage bets
        , uint256 currentIds
        , uint256 newId
    )
        public
        view
        returns (uint256)
    {
        require(currentIds < 2048); // maximum capacity is 5.
    
        if (currentIds == 0) {
            return newId + 1;
        } else {
            uint256 id = (currentIds & 0x7) - 1;
            if (bets.coinbets[newId].largestBetAmount >= bets.coinbets[id].largestBetAmount) {
                return (currentIds << 3) | (newId + 1);
            } else {
                return (id + 1) | (pushToLargestOrSmallestIds(bets, currentIds >> 3, newId) << 3);
            }
        }
    }

    function pushToOtherIds(GameBets storage bets, uint256 currentIds, uint256 newIds)
        public
        view
        returns (uint256)
    {
        require(currentIds < 2048);
        require(newIds < 2048 && newIds > 0);
    
        if (newIds >= 8) {
            return pushToOtherIds(bets
                , pushToOtherIds(bets, currentIds, newIds >> 3)
                , newIds & 0x7);
        } else {
            if (currentIds == 0) {
                return newIds;
            } else {
                uint256 id = (currentIds & 0x7) - 1;
                if (bets.coinbets[newIds - 1].totalBetAmount >= bets.coinbets[id].totalBetAmount) {
                    return (currentIds << 3) | newIds;
                } else {
                    return (id + 1) | (pushToOtherIds(bets, currentIds >> 3, newIds) << 3);
                }
            }
        }
    }

    function convertTempIdsToWinnerIds(Instance storage game, uint256 ids) public
    {
        if (ids > 0) {
            game.winnerCoinIds.push((ids & 0x7) - 1);
            convertTempIdsToWinnerIds(game, ids >> 3);
        }
    }

    function utf8ToUint(byte char) public pure returns (uint256) {
        uint256 utf8Num = uint256(char);
        if (utf8Num > 47 && utf8Num < 58) {
            return utf8Num;
        } else if (utf8Num > 64 && utf8Num < 91) {
            return utf8Num;
        } else {
            revert();
        }
    }

    function encodeCoinName(string str) pure public returns (bytes32) {
        bytes memory bString = bytes(str);
        require(bString.length <= 32);
        
        uint256 retVal = 0;
        uint256 offset = 248;
        for (uint256 i = 0; i < bString.length; ++i) {
            retVal |= utf8ToUint(bString[i]) << offset;
            offset -= 8;
        }
        return bytes32(retVal);
    }
    
    function endTimeOfAwardsClaiming(Instance storage game) 
        view 
        public 
        returns (uint256)
    {
        return game.closeTime.add(game.claimTimeAfterClose & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }
    
    function endTimeOfRefundsClaiming(Instance storage game) 
        view 
        public 
        returns (uint256)
    {
        return  game.closeTime.add(game.claimTimeAfterClose >> 128);
    }
}