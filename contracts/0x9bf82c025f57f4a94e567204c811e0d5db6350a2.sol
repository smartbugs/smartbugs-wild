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
pragma solidity ^0.4.18;

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
    function randomDS_getSessionPubKeyHash() external constant returns (bytes32);
}

contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}

contract usingOraclize {
    uint constant day = 60 * 60 * 24;
    uint constant week = 60 * 60 * 24 * 7;
    uint constant month = 60 * 60 * 24 * 30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
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
        if ((address(OAR) == 0) || (getCodeSize(address(OAR)) == 0))
            oraclize_setNetwork(networkID_auto);

        if (address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns (bool){
        return oraclize_setNetwork();
        networkID;
        // silence the warning and remain backwards compatible
    }

    function oraclize_setNetwork() internal returns (bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) {//mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) {//ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) {//kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) {//rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) {//ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) {//ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) {//browser-solidity
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
        myid;
        result;
        proof;
        // Silence compiler warnings
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
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
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice * 200000) return 0;
        // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice * gaslimit) return 0;
        // unexpectedly high price
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

    function getCodeSize(address _addr) constant internal returns (uint _size) {
        assembly {
            _size := extcodesize(_addr)
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
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10 ** _b;
        return mint;
    }

    function stra2cbor(string[] arr) internal pure returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1) / 23 + 3;
            //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
    }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1) / 23 + 3;
            //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
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
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes[3] memory args = [unonce, nbytes, sessionKeyHash];
        bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);
        oraclize_randomDS_setCommitment(queryId, keccak256(bytes8(_delay), args[1], sha256(args[0]), args[2]));
        return queryId;
    }

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32 => bytes32) oraclize_randomDS_args;
    mapping(bytes32 => bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4 + (uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset + (uint(dersig[offset - 1]) - 0x20), 32, sigs_, 0);

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
        bytes memory sig2 = new bytes(uint(proof[sig2offset + 1]) + 2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3 + 1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1 + 65 + 32);
        tosign2[0] = byte(1);
        //role
        copyBytes(proof, sig2offset - 65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1 + 65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1 + 65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3 + 65 + 1]) + 2);
        copyBytes(proof, 3 + 65, sig3.length, sig3, 0);

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
        if ((_proof[0] != "L") || (_proof[1] != "P") || (_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix) internal pure returns (bool){
        bool match_ = true;

        for (uint256 i = 0; i < prefix.length; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){
        bool checkok;


        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3 + 65 + (uint(proof[3 + 65 + 1]) + 2) + 32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        checkok = (keccak256(keyhash) == keccak256(sha256(context_name, queryId)));
        if (checkok == false) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength + (32 + 8 + 1 + 32) + 1]) + 2);
        copyBytes(proof, ledgerProofLength + (32 + 8 + 1 + 32), sig1.length, sig1, 0);


        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        checkok = matchBytes32Prefix(sha256(sig1), result);
        if (checkok == false) return false;


        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8 + 1 + 32);
        copyBytes(proof, ledgerProofLength + 32, 8 + 1 + 32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength + 32 + (8 + 1 + 32) + sig1.length + 65;
        copyBytes(proof, sig2offset - 64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)) {//unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);
        copyBytes(proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);
        checkok = verifySig(sha256(tosign1), sig1, sessionPubkey);
        if (checkok == false) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false) {
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }


    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {
        uint minLength = length + toOffset;

        // Buffer too small
        require(to.length >= minLength);
        // Should be a better way?

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

}
// </ORACLIZE_API>


/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <arachnid@notdot.net>
 */

pragma solidity ^0.4.14;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
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
    }

    function toSlice(string self) internal returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }
    
    function copy(slice self) internal returns (slice) {
        return slice(self._len, self._ptr);
    }

    function toString(slice self) internal returns (string) {
        var ret = new string(self._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }
    
    function beyond(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    function until(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        var selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
        uint ptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                // Optimized assembly for 68 gas per byte on short strings
                assembly {
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata := and(mload(needleptr), mask)
                    let end := add(selfptr, sub(selflen, needlelen))
                    ptr := selfptr
                    loop :
                    jumpi(exit, eq(and(mload(ptr), mask), needledata))
                    ptr := add(ptr, 1)
                    jumpi(loop, lt(sub(ptr, 1), end))
                    ptr := add(selfptr, selflen)
                    exit :
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {hash := sha3(needleptr, needlelen)}
                ptr = selfptr;
                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly {testHash := sha3(ptr, needlelen)}
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    function split(slice self, slice needle, slice token) internal returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }
    
    function split(slice self, slice needle) internal returns (slice token) {
        split(self, needle, token);
    }
}

contract CryptoLotto is usingOraclize {
    using strings for *;

    address Owner;

    uint public constant lottoPrice = 10 finney;
    uint public constant duration = 1 days;

    uint8 public constant lottoLength = 6;
    uint8 public constant lottoLowestNumber = 1;
    uint8 public constant lottoHighestNumber = 15;

    uint8 public constant sixMatchPayoutInPercent = 77;
    uint8 public constant bonusMatchPayoutInPercent = 11;
    uint8 public constant fiveMatchPayoutInPercent = 11;
    uint8 public constant ownerShareInPercent = 1;
    uint8 public constant numTurnsToRevolve = 10;

    string constant oraclizedQuery = "Sort[randomsample [range [1, 15], 7]], randomsample [range [0, 6], 1]";
    string constant oraclizedQuerySource = "WolframAlpha";

    bool public isLottoStarted = false;
    uint32 public turn = 0;
    uint32 public gasForOraclizedQuery = 600000;
    uint256 public raisedAmount = 0;

    uint8[] lottoNumbers = new uint8[](lottoLength);
    uint8 bonusNumber;
    enum lottoRank {NONCE, FIVE_MATCH, BONUS_MATCH, SIX_MATCH, DEFAULT}
    uint256 public finishWhen;
    uint256[] bettings;
    uint256[] accNumBettings;
    mapping(address => mapping(uint32 => uint64[])) tickets;

    uint256[] public raisedAmounts;
    uint256[] public untakenPrizeAmounts;
    uint32[] encodedLottoResults;
    uint32[] numFiveMatchWinners;
    uint32[] numBonusMatchWinners;
    uint32[] numSixMatchWinners;
    uint32[] nonces;

    uint64[] public timestamps;

    bytes32 oracleCallbackId;

    event LottoStart(uint32 turn);
    event FundRaised(address buyer, uint256 value, uint256 raisedAmount);
    event LottoNumbersAnnounced(uint8[] lottoNumbers, uint8 bonusNumber, uint256 raisedAmount, uint32 numFiveMatchWinners, uint32 numBonusMatchWinners, uint32 numSixMatchWinners);
    event SixMatchPrizeTaken(address winner, uint256 prizeAmount);
    event BonusMatchPrizeTaken(address winner, uint256 prizeAmount);
    event FiveMatchPrizeTaken(address winner, uint256 prizeAmount);

    modifier onlyOwner {
        require(msg.sender == Owner);
        _;
    }

    modifier onlyOracle {
        require(msg.sender == oraclize_cbAddress());
        _;
    }

    modifier onlyWhenLottoNotStarted {
        require(isLottoStarted == false);
        _;
    }

    modifier onlyWhenLottoStarted {
        require(isLottoStarted == true);
        _;
    }

    function CryptoLotto() {
        Owner = msg.sender;
    }

    function launchLotto() onlyOwner {
        oracleCallbackId = oraclize_query(oraclizedQuerySource, oraclizedQuery, gasForOraclizedQuery);
    }

    // Emergency function to call only when the turn missed oraclized_query becaused of gas management failure and no chance to resume by itself.
    function resumeLotto() onlyOwner {
        require(finishWhen < now);
        oracleCallbackId = oraclize_query(oraclizedQuerySource, oraclizedQuery, gasForOraclizedQuery);
    }

    function setGasForOraclizedQuery(uint32 _gasLimit) onlyOwner {
        gasForOraclizedQuery = _gasLimit;
    }

    function __callback(bytes32 myid, string result) onlyOracle {
        require(myid == oracleCallbackId);
        
        if (turn > 0)
            _finishLotto();
        _setLottoNumbers(result);
        _startLotto();
    }

    function _startLotto() onlyWhenLottoNotStarted internal {
        turn++;
        finishWhen = now + duration;
        oracleCallbackId = oraclize_query(duration, oraclizedQuerySource, oraclizedQuery, gasForOraclizedQuery);
        isLottoStarted = true;
        numFiveMatchWinners.push(0);
        numBonusMatchWinners.push(0);
        numSixMatchWinners.push(0);
        nonces.push(0);
        LottoStart(turn);
    }

    function _finishLotto() onlyWhenLottoStarted internal {
        isLottoStarted = false;
        _saveLottoResult();
        LottoNumbersAnnounced(lottoNumbers, bonusNumber, raisedAmounts[turn - 1], numFiveMatchWinners[turn - 1], numBonusMatchWinners[turn - 1], numSixMatchWinners[turn - 1]);
    }

    function _setLottoNumbers(string _strData) onlyWhenLottoNotStarted internal {
        uint8[] memory _lottoNumbers = new uint8[](lottoLength);
        uint8 _bonusNumber;
        var slicedString = _strData.toSlice();
        slicedString.beyond("{{".toSlice()).until("}".toSlice());
        var _strLottoNumbers = slicedString.split('}, {'.toSlice());

        var _bonusNumberIndex = uint8(parseInt(slicedString.toString()));
        uint8 _lottoLowestNumber = lottoLowestNumber;
        uint8 _lottoHighestNumber = lottoHighestNumber;
        uint8 _nonce = 0;

        for (uint8 _index = 0; _index < lottoLength + 1; _index++) {
            var splited = _strLottoNumbers.split(', '.toSlice());
            if (_index == _bonusNumberIndex) {
                bonusNumber = uint8(parseInt(splited.toString()));
                _nonce = 1;
                continue;
            }
            _lottoNumbers[_index - _nonce] = uint8(parseInt(splited.toString()));
            require(_lottoNumbers[_index - _nonce] >= _lottoLowestNumber && _lottoNumbers[_index - _nonce] <= _lottoHighestNumber);
            if (_index - _nonce > 0)
                require(_lottoNumbers[_index - _nonce - 1] < _lottoNumbers[_index - _nonce]);
            lottoNumbers[_index - _nonce] = _lottoNumbers[_index - _nonce];
        }
    }

    function _saveLottoResult() onlyWhenLottoNotStarted internal {
        uint32 _encodedLottoResult = 0;
        var _raisedAmount = raisedAmount;

        // lottoNumbers[6]          24 bits  [0..23]
        for (uint8 _index = 0; _index < lottoNumbers.length; _index++) {
            _encodedLottoResult |= uint32(lottoNumbers[_index]) << (_index * 4);
        }

        // bonusNumber               4 bits  [24..27]
        _encodedLottoResult |= uint32(bonusNumber) << (24);

        uint256 _totalPrizeAmount = 0;

        if (numFiveMatchWinners[turn - 1] > 0)
            _totalPrizeAmount += _raisedAmount * fiveMatchPayoutInPercent / 100;

        if (numBonusMatchWinners[turn - 1] > 0)
            _totalPrizeAmount += _raisedAmount * bonusMatchPayoutInPercent / 100;

        if (numSixMatchWinners[turn - 1] > 0)
            _totalPrizeAmount += _raisedAmount * sixMatchPayoutInPercent / 100;

        raisedAmounts.push(_raisedAmount);
        untakenPrizeAmounts.push(_totalPrizeAmount);
        encodedLottoResults.push(_encodedLottoResult);
        accNumBettings.push(bettings.length);
        timestamps.push(uint64(now));

        var _ownerShare = _raisedAmount * ownerShareInPercent / 100;
        Owner.transfer(_ownerShare);

        uint32 _numTurnsToRevolve = uint32(numTurnsToRevolve);
        uint256 _amountToCarryOver = 0;
        if (turn > _numTurnsToRevolve)
            _amountToCarryOver = untakenPrizeAmounts[turn - _numTurnsToRevolve - 1];
        raisedAmount = _raisedAmount - _totalPrizeAmount - _ownerShare + _amountToCarryOver;
    }

    function getLottoResult(uint256 _turn) constant returns (uint256, uint256, uint32, uint32, uint32) {
        require(_turn < turn && _turn > 0);
        return (raisedAmounts[_turn - 1], untakenPrizeAmounts[_turn - 1], numFiveMatchWinners[_turn - 1], numBonusMatchWinners[_turn - 1], numSixMatchWinners[_turn - 1]);
    }

    function getLottoNumbers(uint256 _turn) constant returns (uint8[], uint8) {
        require(_turn < turn && _turn > 0);
        var _encodedLottoResult = encodedLottoResults[_turn - 1];
        uint8[] memory _lottoNumbers = new uint8[](lottoLength);
        uint8 _bonusNumber;

        for (uint8 _index = 0; _index < _lottoNumbers.length; _index++) {
            _lottoNumbers[_index] = uint8((_encodedLottoResult >> (_index * 4)) & (2 ** 4 - 1));
        }
        _bonusNumber = uint8((_encodedLottoResult >> 24) & (2 ** 4 - 1));
        return (_lottoNumbers, _bonusNumber);
    }

    function buyTickets(uint _numTickets, uint8[] _betNumbersList, bool _isAutoGenerated) payable onlyWhenLottoStarted {
        require(finishWhen > now);
        var _lottoLength = lottoLength;
        require(_betNumbersList.length == _numTickets * _lottoLength);
        uint _totalPrice = _numTickets * lottoPrice;
        require(msg.value >= _totalPrice);

        for (uint j = 0; j < _numTickets; j++) {
            require(_betNumbersList[j * _lottoLength] >= lottoLowestNumber && _betNumbersList[(j + 1) * _lottoLength - 1] <= lottoHighestNumber);
            for (uint _index = 0; _index < _lottoLength - 1; _index++) {
                require(_betNumbersList[_index + j * _lottoLength] < _betNumbersList[_index + 1 + j * _lottoLength]);
            }
        }

        uint8[] memory _betNumbers = new uint8[](lottoLength);
        for (j = 0; j < _numTickets; j++) {
            for (_index = 0; _index < _lottoLength - 1; _index++) {
                _betNumbers[_index] = _betNumbersList[_index + j * _lottoLength];
            }
            _betNumbers[_index] = _betNumbersList[_index + j * _lottoLength];
            _saveBettingAndTicket(_betNumbers, _isAutoGenerated);
        }

        raisedAmount += _totalPrice;
        Owner.transfer(msg.value - _totalPrice);
        FundRaised(msg.sender, msg.value, raisedAmount);
    }

    function _getLottoRank(uint8[] _betNumbers) internal constant returns (lottoRank) {
        uint8 _lottoLength = lottoLength;
        uint8[] memory _lottoNumbers = new uint8[](_lottoLength);
        uint8 _indexLotto = 0;
        uint8 _indexBet = 0;
        uint8 _numMatch = 0;

        for (uint8 i = 0; i < _lottoLength; i++) {
            _lottoNumbers[i] = lottoNumbers[i];
        }

        while (_indexLotto < _lottoLength && _indexBet < _lottoLength) {
            if (_betNumbers[_indexBet] == _lottoNumbers[_indexLotto]) {
                _numMatch++;
                _indexBet++;
                _indexLotto++;
                if (_numMatch > 4)
                    for (uint8 _burner = 0; _burner < 6; _burner++) {}
                continue;
            }
            else if (_betNumbers[_indexBet] < _lottoNumbers[_indexLotto]) {
                _indexBet++;
                continue;
            }

            else {
                _indexLotto++;
                continue;
            }
        }

        if (_numMatch == _lottoLength - 1) {
            uint8 _bonusNumber = bonusNumber;
            for (uint8 _index = 0; _index < lottoLength; _index++) {
                if (_betNumbers[_index] == _bonusNumber) {
                    for (_burner = 0; _burner < 6; _burner++) {}
                    return lottoRank.BONUS_MATCH;
                }
            }
            return lottoRank.FIVE_MATCH;
        }
        else if (_numMatch == _lottoLength) {
            for (_burner = 0; _burner < 12; _burner++) {}
            return lottoRank.SIX_MATCH;
        }

        return lottoRank.DEFAULT;
    }

    function _saveBettingAndTicket(uint8[] _betNumbers, bool _isAutoGenerated) internal onlyWhenLottoStarted {
        require(_betNumbers.length == 6 && lottoHighestNumber <= 16);
        uint256 _encodedBetting = 0;
        uint64 _encodedTicket = 0;
        uint256 _nonce256 = 0;
        uint64 _nonce64 = 0;

        // isTaken                   1 bit      betting[0]                  ticket[0]
        // isAutoGenerated           1 bit      betting[1]                  ticket[1]
        // betNumbers[6]            24 bits     betting[2..25]              ticket[2..25]
        // lottoRank.FIVE_MATCH      1 bit      betting[26]                 ticket[26]
        // lottoRank.BONUS_MATCH     1 bit      betting[27]                 ticket[27]
        // lottoRank.SIX_MATCH       1 bit      betting[28]                 ticket[28]
        // sender address          160 bits     betting[29..188]
        // timestamp                36 bits     betting[189..224]           ticket[29..64]

        // isAutoGenerated
        if (_isAutoGenerated) {
            _encodedBetting |= uint256(1) << 1;
            _encodedTicket |= uint64(1) << 1;
        }

        // betNumbers[6]
        for (uint8 _index = 0; _index < _betNumbers.length; _index++) {
            uint256 _betNumber = uint256(_betNumbers[_index]) << (_index * 4 + 2);
            _encodedBetting |= _betNumber;
            _encodedTicket |= uint64(_betNumber);
        }

        // lottoRank.FIVE_MATCH, lottoRank.BONUS_MATCH, lottoRank.SIX_MATCH
        lottoRank _lottoRank = _getLottoRank(_betNumbers);
        if (_lottoRank == lottoRank.FIVE_MATCH) {
            numFiveMatchWinners[turn - 1]++;
            _encodedBetting |= uint256(1) << 26;
            _encodedTicket |= uint64(1) << 26;
        }
        else if (_lottoRank == lottoRank.BONUS_MATCH) {
            numBonusMatchWinners[turn - 1]++;
            _encodedBetting |= uint256(1) << 27;
            _encodedTicket |= uint64(1) << 27;
        }
        else if (_lottoRank == lottoRank.SIX_MATCH) {
            numSixMatchWinners[turn - 1]++;
            _encodedBetting |= uint256(1) << 28;
            _encodedTicket |= uint64(1) << 28;
        } else {
            nonces[turn - 1]++;
            _nonce256 |= uint256(1) << 29;
            _nonce64 |= uint64(1) << 29;
        }

        // sender address
        _encodedBetting |= uint256(msg.sender) << 29;

        // timestamp
        _encodedBetting |= now << 189;
        _encodedTicket |= uint64(now) << 29;

        // push ticket
        tickets[msg.sender][turn].push(_encodedTicket);
        // push betting
        bettings.push(_encodedBetting);
    }

    function getNumBettings() constant returns (uint256) {
        return bettings.length;
    }

    function getTurn(uint256 _bettingId) constant returns (uint32) {
        uint32 _turn = turn;
        require(_turn > 0);
        require(_bettingId < bettings.length);

        if (_turn == 1 || _bettingId < accNumBettings[0])
            return 1;
        if (_bettingId >= accNumBettings[_turn - 2])
            return _turn;

        uint32 i = 0;
        uint32 j = _turn - 1;
        uint32 mid = 0;

        while (i < j) {
            mid = (i + j) / 2;

            if (accNumBettings[mid] == _bettingId)
                return mid + 2;

            if (_bettingId < accNumBettings[mid]) {
                if (mid > 0 && _bettingId > accNumBettings[mid - 1])
                    return mid + 1;
                j = mid;
            }
            else {
                if (mid < _turn - 2 && _bettingId < accNumBettings[mid + 1])
                    return mid + 2;
                i = mid + 1;
            }
        }
        return mid + 2;
    }

    function getBetting(uint256 i) constant returns (bool, bool, uint8[], lottoRank, uint32){
        require(i < bettings.length);
        uint256 _betting = bettings[i];

        // isTaken                      1 bit      [0]
        bool _isTaken;
        if (_betting & 1 == 1)
            _isTaken = true;
        else
            _isAutoGenerated = false;

        // _isAutoGenerated             1 bit      [1]
        bool _isAutoGenerated;
        if ((_betting >> 1) & 1 == 1)
            _isAutoGenerated = true;
        else
            _isAutoGenerated = false;

        // 6 betNumbers                24 bits     [2..25]
        uint8[] memory _betNumbers = new uint8[](lottoLength);
        for (uint8 _index = 0; _index < lottoLength; _index++) {
            _betNumbers[_index] = uint8((_betting >> (_index * 4 + 2)) & (2 ** 4 - 1));
        }

        //  _timestamp                   bits     [189..255]
        uint128 _timestamp;
        _timestamp = uint128((_betting >> 189) & (2 ** 67 - 1));

        uint32 _turn = getTurn(i);
        if (_turn == turn && isLottoStarted)
            return (_isTaken, _isAutoGenerated, _betNumbers, lottoRank.NONCE, _turn);

        // return lottoRank only when the turn is finished
        // lottoRank                    3 bits     [26..28]
        lottoRank _lottoRank = lottoRank.DEFAULT;
        if ((_betting >> 26) & 1 == 1)
            _lottoRank = lottoRank.FIVE_MATCH;
        if ((_betting >> 27) & 1 == 1)
            _lottoRank = lottoRank.BONUS_MATCH;
        if ((_betting >> 28) & 1 == 1)
            _lottoRank = lottoRank.SIX_MATCH;

        return (_isTaken, _isAutoGenerated, _betNumbers, _lottoRank, _turn);
    }

    function getBettingExtra(uint256 i) constant returns (address, uint128){
        require(i < bettings.length);
        uint256 _betting = bettings[i];
        uint128 _timestamp = uint128((_betting >> 189) & (2 ** 67 - 1));
        address _beneficiary = address((_betting >> 29) & (2 ** 160 - 1));
        return (_beneficiary, _timestamp);
    }

    function getMyResult(uint32 _turn) constant returns (uint256, uint32, uint32, uint32, uint256) {
        require(_turn > 0);
        if (_turn == turn)
            require(!isLottoStarted);
        else
            require(_turn < turn);

        uint256 _numMyTickets = tickets[msg.sender][_turn].length;
        uint256 _totalPrizeAmount = 0;
        uint64 _ticket;
        uint32 _numSixMatchPrizes = 0;
        uint32 _numBonusMatchPrizes = 0;
        uint32 _numFiveMatchPrizes = 0;

        if (_numMyTickets == 0) {
            return (0, 0, 0, 0, 0);
        }

        for (uint256 _index = 0; _index < _numMyTickets; _index++) {
            _ticket = tickets[msg.sender][_turn][_index];
            if ((_ticket >> 26) & 1 == 1) {
                _numFiveMatchPrizes++;
                _totalPrizeAmount += _getFiveMatchPrizeAmount(_turn);
            }
            else if ((_ticket >> 27) & 1 == 1) {
                _numBonusMatchPrizes++;
                _totalPrizeAmount += _getBonusMatchPrizeAmount(_turn);
            }
            else if ((_ticket >> 28) & 1 == 1) {
                _numSixMatchPrizes++;
                _totalPrizeAmount += _getSixMatchPrizeAmount(_turn);
            }
        }
        return (_numMyTickets, _numSixMatchPrizes, _numBonusMatchPrizes, _numFiveMatchPrizes, _totalPrizeAmount);
    }

    function getNumMyTickets(uint32 _turn) constant returns (uint256) {
        require(_turn > 0 && _turn <= turn);
        return tickets[msg.sender][_turn].length;
    }

    function getMyTicket(uint32 _turn, uint256 i) constant returns (bool, bool, uint8[], lottoRank, uint64){
        require(_turn <= turn);
        require(i < tickets[msg.sender][_turn].length);
        uint64 _ticket = tickets[msg.sender][_turn][i];

        // isTaken                   1 bit      ticket[0]
        bool _isTaken = false;
        if ((_ticket & 1) == 1)
            _isTaken = true;

        // isAutoGenerated           1 bit      ticket[1]
        bool _isAutoGenerated = false;
        if ((_ticket >> 1) & 1 == 1)
            _isAutoGenerated = true;

        // betNumbers[6]            24 bits     ticket[2..25]
        uint8[] memory _betNumbers = new uint8[](lottoLength);
        for (uint8 _index = 0; _index < lottoLength; _index++) {
            _betNumbers[_index] = uint8((_ticket >> (_index * 4 + 2)) & (2 ** 4 - 1));
        }

        // timestamp                36 bits     ticket[29..64]
        uint64 _timestamp = uint64((_ticket >> 29) & (2 ** 36 - 1));

        if (_turn == turn)
            return (_isTaken, _isAutoGenerated, _betNumbers, lottoRank.NONCE, _timestamp);

        // return lottoRank only when the turn is finished

        // lottoRank.FIVE_MATCH      1 bit      ticket[26]
        // lottoRank.BONUS_MATCH     1 bit      ticket[27]
        // lottoRank.SIX_MATCH       1 bit      ticket[28]
        lottoRank _lottoRank = lottoRank.DEFAULT;
        if ((_ticket >> 26) & 1 == 1)
            _lottoRank = lottoRank.FIVE_MATCH;
        if ((_ticket >> 27) & 1 == 1)
            _lottoRank = lottoRank.BONUS_MATCH;
        if ((_ticket >> 28) & 1 == 1)
            _lottoRank = lottoRank.SIX_MATCH;

        return (_isTaken, _isAutoGenerated, _betNumbers, _lottoRank, _timestamp);
    }

    function getMyUntakenPrizes(uint32 _turn) constant returns (uint32[]) {
        require(_turn > 0 && _turn < turn);
        uint256 _numMyTickets = tickets[msg.sender][_turn].length;

        uint32[] memory _prizes = new uint32[](50);
        uint256 _indexPrizes = 0;

        for (uint16 _index; _index < _numMyTickets; _index++) {
            uint64 _ticket = tickets[msg.sender][_turn][_index];
            if (((_ticket >> 26) & 1 == 1) && (_ticket & 1 == 0))
                _prizes[_indexPrizes++] = _index;
            else if (((_ticket >> 27) & 1 == 1) && (_ticket & 1 == 0))
                _prizes[_indexPrizes++] = _index;
            else if (((_ticket >> 28) & 1 == 1) && (_ticket & 1 == 0))
                _prizes[_indexPrizes++] = _index;
            if (_indexPrizes >= 50) {
                break;
            }
        }
        uint32[] memory _retPrizes = new uint32[](_indexPrizes);

        for (_index = 0; _index < _indexPrizes; _index++) {
            _retPrizes[_index] = _prizes[_index];
        }
        return (_retPrizes);
    }

    function takePrize(uint32 _turn, uint256 i) {
        require(_turn > 0 && _turn < turn);
        if (turn > numTurnsToRevolve)
            require(_turn >= turn - numTurnsToRevolve);

        require(i < tickets[msg.sender][_turn].length);
        var _ticket = tickets[msg.sender][_turn][i];

        // isTaken must be false
        require((_ticket & 1) == 0);

        // lottoRank.FIVE_MATCH      1 bit   [26]
        // lottoRank.BONUS_MATCH     1 bit   [27]
        // lottoRank.SIX_MATCH       1 bit   [28]
        if ((_ticket >> 26) & 1 == 1) {
            uint256 _prizeAmount = _getFiveMatchPrizeAmount(_turn);
            require(_prizeAmount > 0);
            msg.sender.transfer(_prizeAmount);
            FiveMatchPrizeTaken(msg.sender, _prizeAmount);
            tickets[msg.sender][_turn][i] |= 1;
            untakenPrizeAmounts[_turn - 1] -= _prizeAmount;
        } else if ((_ticket >> 27) & 1 == 1) {
            _prizeAmount = _getBonusMatchPrizeAmount(_turn);
            require(_prizeAmount > 0);
            msg.sender.transfer(_prizeAmount);
            BonusMatchPrizeTaken(msg.sender, _prizeAmount);
            tickets[msg.sender][_turn][i] |= 1;
            untakenPrizeAmounts[_turn - 1] -= _prizeAmount;
        } else if ((_ticket >> 28) & 1 == 1) {
            _prizeAmount = _getSixMatchPrizeAmount(_turn);
            require(_prizeAmount > 0);
            msg.sender.transfer(_prizeAmount);
            SixMatchPrizeTaken(msg.sender, _prizeAmount);
            tickets[msg.sender][_turn][i] |= 1;
            untakenPrizeAmounts[_turn - 1] -= _prizeAmount;
        }
    }

    function _getFiveMatchPrizeAmount(uint256 _turn) internal constant returns (uint256) {
        require(_turn > 0 && _turn < turn);
        uint256 _numFiveMatchWinners = uint256(numFiveMatchWinners[_turn - 1]);
        if (_numFiveMatchWinners == 0)
            return 0;
        return raisedAmounts[_turn - 1] * fiveMatchPayoutInPercent / 100 / _numFiveMatchWinners;
    }

    function _getBonusMatchPrizeAmount(uint256 _turn) internal constant returns (uint256) {
        require(_turn > 0 && _turn < turn);
        uint256 _numBonusMatchWinners = uint256(numBonusMatchWinners[_turn - 1]);
        if (_numBonusMatchWinners == 0)
            return 0;
        return raisedAmounts[_turn - 1] * bonusMatchPayoutInPercent / 100 / _numBonusMatchWinners;
    }

    function _getSixMatchPrizeAmount(uint256 _turn) internal constant returns (uint256) {
        require(_turn > 0 && _turn < turn);
        uint256 _numSixMatchWinners = uint256(numSixMatchWinners[_turn - 1]);
        if (_numSixMatchWinners == 0)
            return 0;
        return raisedAmounts[_turn - 1] * sixMatchPayoutInPercent / 100 / _numSixMatchWinners;
    }

    function() payable {
    }
}