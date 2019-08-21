pragma solidity ^0.4.15;

/**
 * @title Safe math operations that throw error on overflow.
 *
 * Credit: Taking ideas from FirstBlood token
 */
library SafeMath {

    /** 
     * @dev Safely add two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x+y.
     */
    function add(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    /** 
     * @dev Safely substract two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x-y.
     */
    function sub(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    /** 
     * @dev Safely multiply two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x*y.
     */
    function mul(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z/x == y));
        return z;
    }

    /**
    * @dev Parse a floating point number from String to uint, e.g. "250.56" to "25056"
     */
    function parse(string s) 
    internal constant 
    returns (uint256) 
    {
    bytes memory b = bytes(s);
    uint result = 0;
    for (uint i = 0; i < b.length; i++) {
        if (b[i] >= 48 && b[i] <= 57) {
            result = result * 10 + (uint(b[i]) - 48); 
        }
    }
    return result; 
}
}

/**
 * @title The abstract ERC-20 Token Standard definition.
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract Token {
    /// @dev Returns the total token supply.
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /// @dev MUST trigger when tokens are transferred, including zero value transfers.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @dev MUST trigger on any successful call to approve(address _spender, uint256 _value).
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Default implementation of the ERC-20 Token Standard.
 */
contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

    /**
     * @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. 
     * @dev The function SHOULD throw if the _from account balance does not have enough tokens to spend.
     *
     * @dev A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transfer(address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
            balances[_to] = SafeMath.add(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     *
     * @dev The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
     * @dev This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in 
     * @dev sub-currencies. The function SHOULD throw unless the _from account has deliberately authorized the sender of 
     * @dev the message via some mechanism.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _from The sender of the tokens.
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[_to] = SafeMath.add(balances[_to], _value);
            balances[_from] = SafeMath.sub(balances[_from], _value);
            allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns the account balance of another account with address _owner.
     *
     * @param _owner The address of the account to check.
     * @return The account balance.
     */
    function balanceOf(address _owner)
    public constant
    returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount. 
     * @dev If this function is called again it overwrites the current allowance with _value.
     *
     * @dev NOTE: To prevent attack vectors like the one described in [1] and discussed in [2], clients 
     * @dev SHOULD make sure to create user interfaces in such a way that they set the allowance first 
     * @dev to 0 before setting it to another value for the same spender. THOUGH The contract itself 
     * @dev shouldn't enforce it, to allow backwards compatilibilty with contracts deployed before.
     * @dev [1] https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
     * @dev [2] https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     * @return True on success, false otherwise.
     */
    function approve(address _spender, uint256 _value)
    public
    onlyPayloadSize(2)
    returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Returns the amount which _spender is still allowed to withdraw from _owner.
     *
     * @param _owner The address of the sender.
     * @param _spender The address of the receiver.
     * @return The allowed withdrawal amount.
     */
    function allowance(address _owner, address _spender)
    public constant
    onlyPayloadSize(2)
    returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}


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

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
    function randomDS_getSessionPubKeyHash() returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
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
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork(networkID_auto);
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
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

    function __callback(bytes32 myid, string result) {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) {
    }
    
    function oraclize_useCoupon(string code) oraclizeAPI internal {
        oraclize.useCoupon(code);
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
    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {
        return oraclize.setConfig(config);
    }
    
    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal returns (address){
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

    function strCompare(string _a, string _b) internal returns (int) {
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

    function indexOf(string _haystack, string _needle) internal returns (int) {
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

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string) {
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

    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
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

    function uint2str(uint i) internal returns (string){
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
    
    function stra2cbor(string[] arr) internal returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
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

    function ba2cbor(bytes[] arr) internal returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
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
    
    function oraclize_getNetworkName() internal returns (string) {
        return oraclize_network_name;
    }
    
    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        if ((_nbytes == 0)||(_nbytes > 32)) throw;
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
        oraclize_randomDS_setCommitment(queryId, sha3(bytes8(_delay), args[1], sha256(args[0]), args[2]));
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
        if (address(sha3(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(sha3(pubkey)) == signer);
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
        tosign2[0] = 1; //role
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
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;
        
        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) throw;
        
        _;
    }
    
    function matchBytes32Prefix(bytes32 content, bytes prefix) internal returns (bool){
        bool match_ = true;
        
        for (var i=0; i<prefix.length; i++){
            if (content[i] != prefix[i]) match_ = false;
        }
        
        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){
        bool checkok;
        
        
        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        checkok = (sha3(keyhash) == sha3(sha256(context_name, queryId)));
        if (checkok == false) return false;
        
        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);
        
        
        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        checkok = matchBytes32Prefix(sha256(sig1), result);
        if (checkok == false) return false;
        
        
        // Step 4: commitment match verification, sha3(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);
        
        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);
        
        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == sha3(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;
        
        
        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        checkok = verifySig(sha256(tosign1), sig1, sessionPubkey);
        if (checkok == false) return false;
        
        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }
        
        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    
    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal returns (bytes) {
        uint minLength = length + toOffset;

        if (to.length < minLength) {
            // Buffer too small
            throw; // Should be a better way?
        }

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
        
}
// </ORACLIZE_API>


/**
 * @title The EVNToken Token contract.
 *
 * Credit: Taking ideas from BAT token and NET token
 */
 /*is StandardToken */
contract EVNToken is StandardToken, usingOraclize {

    // Token metadata
    string public constant name = "Envion";
    string public constant symbol = "EVN";
    uint256 public constant decimals = 18;
    string public constant version = "0.9";

    // Fundraising goals: minimums and maximums
    uint256 public constant TOKEN_CREATION_CAP = 130 * (10**6) * 10**decimals; // 130 million EVNs
    uint256 public constant TOKEN_CREATED_MIN = 1 * (10**6) * 10**decimals;    // 1 million EVNs
    uint256 public constant ETH_RECEIVED_CAP = 5333 * (10**2) * 10**decimals;  // 533 300 ETH
    uint256 public constant ETH_RECEIVED_MIN = 1 * (10**3) * 10**decimals;     // 1 000 ETH
    uint256 public constant TOKEN_MIN = 1 * 10**decimals;                      // 1 EVN

    // Discount multipliers
    uint256 public constant TOKEN_FIRST_DISCOUNT_MULTIPLIER  = 142857; // later divided by 10^5 to give users 1,42857 times more tokens per ETH == 30% discount
    uint256 public constant TOKEN_SECOND_DISCOUNT_MULTIPLIER = 125000; // later divided by 10^5 to give users 1,25 more tokens per ETH == 20% discount
    uint256 public constant TOKEN_THIRD_DISCOUNT_MULTIPLIER  = 111111; // later divided by 10^5 to give users 1,11111 more tokens per ETH == 10% discount

    // Fundraising parameters provided when creating the contract
    uint256 public fundingStartBlock; // These two blocks need to be chosen to comply with the
    uint256 public fundingEndBlock;   // start date and 31 day duration requirements
    uint256 public roundTwoBlock;     // block number that triggers the second exchange rate change
    uint256 public roundThreeBlock;   // block number that triggers the third exchange rate change
    uint256 public roundFourBlock;    // block number that triggers the fourth exchange rate change
    uint256 public ccReleaseBlock;    // block number that triggers purchases made by CC be transferable

    address public admin1;      // First administrator for multi-sig mechanism
    address public admin2;      // Second administrator for multi-sig mechanism
    address public tokenVendor; // Account delivering Tokens purchased with credit card

    // Contracts current state (Fundraising, Finalized, Paused) and the saved state (if currently paused)
    ContractState public state;       // Current state of the contract
    ContractState private savedState; // State of the contract before pause

    //@dev Usecase related: Purchasing Tokens with Credit card  
    //@dev Usecase related: Canceling purchases done with credit card
    mapping (string => Purchase) purchases;                 // in case CC payments get charged back, admins shall only be allowed to kill the exact amount of tokens associated with this payment
    mapping (address => uint256) public ccLockedUpBalances; // tracking the total amount of tokens users have bought via CC - locked up until ccReleaseBlock
    string[] public purchaseArray;                          // holding the IDs of all CC purchases

    // Keep track of holders and icoBuyers
    mapping (address => bool) public isHolder; // track if a user is a known token holder to the smart contract - important for payouts later
    address[] public holders;                  // array of all known holders - important for payouts later
    mapping (address => bool) isIcoBuyer;      // for tracking if user has to be kyc verified before being able to transfer tokens

    // ETH balance per user
    // Since we have different exchange rates at different stages, we need to keep track
    // of how much ether each contributed in case that we need to issue a refund
    mapping (address => uint256) private ethBalances;
    mapping (address => uint256) private noKycEthBalances;

    // Total received ETH balances
    // We need to keep track of how much ether have been contributed, since we have a cap for ETH too
    uint256 public allReceivedEth;
    uint256 public allUnKycedEth; // total amount of ETH we have no KYC for yet

    // store the hashes of admins' msg.data
    mapping (address => bytes32) private multiSigHashes;

    // KYC
    mapping (address => bool) public isKycTeam;   // to determine, if a user belongs to the KYC team or not
    mapping (address => bool) public kycVerified; // to check if user has already undergone KYC or not, to lock up his tokens until then

    // to track if team members already got their tokens
    bool public teamTokensDelivered;

    // Current ETH/USD exchange rate
    uint256 public ETH_USD_EXCHANGE_RATE_IN_CENTS; // set by oraclize

    // Everything oraclize related
    event updatedPrice(string price);
    event newOraclizeQuery(string description);
    uint public oraclizeQueryCost;

    // Events used for logging
    event LogRefund(address indexed _to, uint256 _value);
    event LogCreateEVN(address indexed _to, uint256 _value);
    event LogDeliverEVN(address indexed _to, uint256 _value);
    event LogCancelDelivery(address indexed _to, string _id);
    event LogKycRefused(address indexed _user, uint256 _value);
    event LogTeamTokensDelivered(address indexed distributor, uint256 _value);

    // Additional helper structs
    enum ContractState { Fundraising, Finalized, Paused }

    // Credit Card Purchase Parameters
    //@dev Usecase related: Purchase Tokens with Credit card
    //@dev Usecase related: Cancel purchase done with credit card
    struct Purchase {
        address buyer;
        uint256 tokenAmount;
        bool active;
    }

    // Modifiers
    modifier isFinalized() {
        require(state == ContractState.Finalized);
        _;
    }

    modifier isFundraising() {
        require(state == ContractState.Fundraising);
        _;
    }

    modifier isPaused() {
        require(state == ContractState.Paused);
        _;
    }

    modifier notPaused() {
        require(state != ContractState.Paused);
        _;
    }

    modifier isFundraisingIgnorePaused() {
        require(state == ContractState.Fundraising || (state == ContractState.Paused && savedState == ContractState.Fundraising));
        _;
    }

    modifier onlyKycTeam(){
        require(isKycTeam[msg.sender] == true);
        _;
    }

    modifier onlyOwner() {
        // check if transaction sender is admin.
        require (msg.sender == admin1 || msg.sender == admin2);
        // if yes, store his msg.data. 
        multiSigHashes[msg.sender] = keccak256(msg.data);
        // check if his stored msg.data hash equals to the one of the other admin
        if ((multiSigHashes[admin1]) == (multiSigHashes[admin2])) {
            // if yes, both admins agreed - continue.
            _;

            // Reset hashes after successful execution
            multiSigHashes[admin1] = 0x0;
            multiSigHashes[admin2] = 0x0;
        } else {
            // if not (yet), return.
            return;
        }
    }

    modifier onlyVendor() {
        require(msg.sender == tokenVendor);
        _;
    }

    modifier minimumReached() {
        require(allReceivedEth >= ETH_RECEIVED_MIN);
        require(totalSupply >= TOKEN_CREATED_MIN);
        _;
    }

    modifier isKycVerified(address _user) {
        // if token transferring user acquired the tokens through the ICO...
        if (isIcoBuyer[_user] == true) {
            // ...check if user is already unlocked
            require (kycVerified[_user] == true);
        }
        _;
    }

    modifier hasEnoughUnlockedTokens(address _user, uint256 _value) {
        // check if the user was a CC buyer and if the lockup period is not over,
        if (ccLockedUpBalances[_user] > 0 && block.number < ccReleaseBlock) {
            // allow to only transfer the not-locked up tokens
            require ((SafeMath.sub(balances[_user], _value)) >= ccLockedUpBalances[_user]);
        }
        _;
    }

    /**
     * @dev Create a new EVNToken contract.
     *
     *  _fundingStartBlock The starting block of the fundraiser (has to be in the future).
     *  _fundingEndBlock The end block of the fundraiser (has to be after _fundingStartBlock).
     *  _roundTwoBlock The block that changes the discount rate to 20% (has to be between _fundingStartBlock and _roundThreeBlock).
     *  _roundThreeBlock The block that changes the discount rate to 10% (has to be between _roundTwoBlock and _roundFourBlock).
     *  _roundFourBlock The block that changes the discount rate to 0% (has to be between _roundThreeBlock and _fundingEndBlock).
     *  _admin1 The first admin account that owns this contract.
     *  _admin2 The second admin account that owns this contract.
     *  _tokenVendor The account that creates tokens for credit card / fiat contributers.
     */
    function EVNToken(
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock,
        uint256 _roundTwoBlock, // block number that triggers the first exchange rate change
        uint256 _roundThreeBlock, // block number that triggers the second exchange rate change
        uint256 _roundFourBlock,
        address _admin1,
        address _admin2,
        address _tokenVendor,
        uint256 _ccReleaseBlock)
    payable
    {
        // Check that the parameters make sense

        // The start of the fundraising should happen in the future
        require (block.number <= _fundingStartBlock);

        // The discount rate changes and ending should follow in their subsequent order
        require (_fundingStartBlock < _roundTwoBlock);
        require (_roundTwoBlock < _roundThreeBlock);
        require (_roundThreeBlock < _roundFourBlock);
        require (_roundFourBlock < _fundingEndBlock);

        // block when tokens bought with CC will be released must be in the future
        require (_fundingEndBlock < _ccReleaseBlock);

        // admin1 and admin2 address must be set and must be different
        require (_admin1 != 0x0);
        require (_admin2 != 0x0);
        require (_admin1 != _admin2);

        // tokenVendor must be set and be different from admin1 and admin2
        require (_tokenVendor != 0x0);
        require (_tokenVendor != _admin1);
        require (_tokenVendor != _admin2);

        // provide some ETH for oraclize price feed
        require (msg.value > 0);

        // Init contract state
        state = ContractState.Fundraising;
        savedState = ContractState.Fundraising;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        roundTwoBlock = _roundTwoBlock;
        roundThreeBlock = _roundThreeBlock;
        roundFourBlock = _roundFourBlock;
        ccReleaseBlock = _ccReleaseBlock;

        totalSupply = 0;

        admin1 = _admin1;
        admin2 = _admin2;
        tokenVendor = _tokenVendor;

        //oraclize 
        oraclize_setCustomGasPrice(100000000000 wei); // set the gas price a little bit higher, so the pricefeed definitely works
        updatePrice();
        oraclizeQueryCost = oraclize_getPrice("URL");
    }

    //// oraclize START

    // @dev oraclize is called recursively here - once a callback fetches the newest ETH price, the next callback is scheduled for the next hour again
    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress());

        // setting the token price here
        ETH_USD_EXCHANGE_RATE_IN_CENTS = SafeMath.parse(result);
        updatedPrice(result);

        // fetch the next price
        updatePrice();
    }

    function updatePrice() payable {    // can be left public as a way for replenishing contract's ETH balance, just in case
        if (msg.sender != oraclize_cbAddress()) {
            require(msg.value >= 200 finney);
        }
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize sent, wait..");
            // Schedule query in 1 hour. Set the gas amount to 220000, as parsing in __callback takes around 70000 - we play it safe.
            oraclize_query(3600, "URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD", 220000);
        }
    }
    //// oraclize END

    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transfer(address _to, uint256 _value)
    public
    isFinalized // Only allow token transfer after the fundraising has ended
    isKycVerified(msg.sender)
    hasEnoughUnlockedTokens(msg.sender, _value)
    onlyPayloadSize(2)
    returns (bool success)
    {
        bool result = super.transfer(_to, _value);
        if (result) {
            trackHolder(_to); // track the owner for later payouts
        }
        return result;
    }

    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transferFrom(address _from, address _to, uint256 _value)
    public
    isFinalized // Only allow token transfer after the fundraising has ended
    isKycVerified(msg.sender)
    hasEnoughUnlockedTokens(msg.sender, _value)
    onlyPayloadSize(3)
    returns (bool success)
    {
        bool result = super.transferFrom(_from, _to, _value);
        if (result) {
            trackHolder(_to); // track the owner for later payouts
        }
        return result;
    }

    // Allow for easier balance checking
    function getBalanceOf(address _owner)
    constant
    returns (uint256 _balance)
    {
        return balances[_owner];
    }

     // getting purchase details by ID - workaround, mappings with dynamically sized keys can't be made public yet.
    function getPurchaseById(string _id)
    constant
    returns (address _buyer, uint256 _tokenAmount, bool _active){
        _buyer = purchases[_id].buyer;
        _tokenAmount = purchases[_id].tokenAmount;
        _active = purchases[_id].active;
    }

    // Allows to figure out the amount of known token holders
    function getHolderCount()
    public
    constant
    returns (uint256 _holderCount)
    {
        return holders.length;
    }

    // Allows to figure out the amount of purchases
    function getPurchaseCount()
    public
    constant
    returns (uint256 _purchaseCount)
    {
        return purchaseArray.length;
    }

    // Allows for easier retrieval of holder by array index
    function getHolder(uint256 _index)
    public
    constant
    returns (address _holder)
    {
        return holders[_index];
    }

    function trackHolder(address _to)
    private
    returns (bool success)
    {
        // Check if the recipient is a known token holder
        if (isHolder[_to] == false) {
            // if not, add him to the holders array and mark him as a known holder
            holders.push(_to);
            isHolder[_to] = true;
        }
        return true;
    }


    /// @dev Accepts ether and creates new EVN tokens
    function createTokens()
    payable
    external
    isFundraising
    {
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock);
        require(msg.value > 0);

        // First we check the ETH cap: would adding this amount to the total unKYCed eth and the already KYCed eth exceed the eth cap?
        // return the contribution if the cap has been reached already
        uint256 totalKycedAndUnKycEdEth = SafeMath.add(allUnKycedEth, allReceivedEth);
        uint256 checkedReceivedEth = SafeMath.add(totalKycedAndUnKycEdEth, msg.value);
        require(checkedReceivedEth <= ETH_RECEIVED_CAP);

        // If all is fine with the ETH cap, we continue to check the
        // minimum amount of tokens and the cap for how many tokens
        // have been generated so far

        // calculate the token amount
        uint256 tokens = SafeMath.mul(msg.value, ETH_USD_EXCHANGE_RATE_IN_CENTS);

        // divide by 100 to turn ETH_USD_EXCHANGE_RATE_IN_CENTS into full USD
        tokens = tokens / 100;

        // apply discount multiplier
        tokens = safeMulPercentage(tokens, getCurrentDiscountRate());

        require(tokens >= TOKEN_MIN);
        uint256 checkedSupply = SafeMath.add(totalSupply, tokens);
        require(checkedSupply <= TOKEN_CREATION_CAP);

        // Only when all the checks have passed, then we check if the address is already KYCEd and then 
        // update the state (noKycEthBalances, allReceivedEth, totalSupply, and balances) of the contract

        if (kycVerified[msg.sender] == false) {
            // @dev The unKYCed eth balances are moved to ethBalances in unlockKyc()

            noKycEthBalances[msg.sender] = SafeMath.add(noKycEthBalances[msg.sender], msg.value);

            // add the contributed eth to the total unKYCed eth amount
            allUnKycedEth = SafeMath.add(allUnKycedEth, msg.value);
        } else {
            // if buyer is already KYC unlocked...
            ethBalances[msg.sender] = SafeMath.add(ethBalances[msg.sender], msg.value);
            allReceivedEth = SafeMath.add(allReceivedEth, msg.value);
        }

        totalSupply = checkedSupply;
        balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here

        trackHolder(msg.sender);

        // to force the check for KYC Status upon the user when he tries transferring tokens
        // and exclude every later token owner
        isIcoBuyer[msg.sender] = true;

        // Log the creation of these tokens
        LogCreateEVN(msg.sender, tokens);
    }

    //add a user to the KYC team
    function addToKycTeam(address _teamMember)
    onlyOwner
    onlyPayloadSize(1){
        isKycTeam[_teamMember] = true;
    }

    //remove a user from the KYC team
    function removeFromKycTeam(address _teamMember)
    onlyOwner
    onlyPayloadSize(1){
        isKycTeam[_teamMember] = false;
    }

    //called by KYC team 
    function unlockKyc(address _owner)
    external
    onlyKycTeam {
        require(kycVerified[_owner] == false);

        //unlock the owner to allow transfer of tokens
        kycVerified[_owner] = true;

        // we leave the ccLockedUpBalances[_owner] as is, because also KYCed users could cancel their CC payments

        if (noKycEthBalances[_owner] > 0) { // check if the user was an ETH buyer

            // now move the unKYCed eth balance to the regular ethBalance. 
            ethBalances[_owner] = noKycEthBalances[_owner];

            // add the now KYCed eth to the total received eth
            allReceivedEth = SafeMath.add(allReceivedEth, noKycEthBalances[_owner]);

            // subtract the now KYCed eth from total amount of unKYCed eth
            allUnKycedEth = SafeMath.sub(allUnKycedEth, noKycEthBalances[_owner]);

            // and set the user's unKYCed eth balance to 0
            noKycEthBalances[_owner] = 0; // preventing replay attacks
        }
    }

    // Refusing KYC of a user, who only contributed in ETH.
    // We must pay close attention here for the case that a user contributes in ETH AND(!) CC !
    // in this case, he must only kill the tokens he received through ETH, the ones bought in fiat will be
    // killed by canceling his payments and subsequently calling cancelDelivery() with the according payment id.
    function refuseKyc(address _user)
    external
    onlyKycTeam
    {
        // once a user is verified, you can't kick him out.
        require (kycVerified[_user] == false);

        // immediately stop, if a user has none or only CC contributions.
        // we're managing kyc refusing of CC contributors off-chain
        require(noKycEthBalances[_user]>0);

        uint256 EVNVal = balances[_user];
        require(EVNVal > 0);

        uint256 ethVal = noKycEthBalances[_user]; // refund un-KYCd eth
        require(ethVal > 0);

        // Update the state only after all the checks have passed
        allUnKycedEth = SafeMath.sub(allUnKycedEth, noKycEthBalances[_user]); // or if there was any unKYCed Eth, subtract it from the total unKYCed eth balance.
        balances[_user] = ccLockedUpBalances[_user]; // assign user only the token amount he has bought through CC, if there are any.
        noKycEthBalances[_user] = 0;
        totalSupply = SafeMath.sub(totalSupply, EVNVal); // Extra safe

        // Log this refund
        LogKycRefused(_user, ethVal);

        // Send the contributions only after we have updated all the balances
        // If you're using a contract, make sure it works with .transfer() gas limits
        _user.transfer(ethVal);
    }

    // Called in case a buyer cancels his CC payment.
    // @param The payment ID from payment provider
    function cancelDelivery(string _purchaseID)
    external
    onlyKycTeam{
        
        // CC payments are only cancelable until ccReleaseBlock
        require (block.number < ccReleaseBlock);

        // check if the purchase to cancel is still active
        require (purchases[_purchaseID].active == true);

        // now withdraw the canceled purchase's token amount from the user's balance
        balances[purchases[_purchaseID].buyer] = SafeMath.sub(balances[purchases[_purchaseID].buyer], purchases[_purchaseID].tokenAmount);

        // and withdraw the canceled purchase's token amount from the lockedUp token balance
        ccLockedUpBalances[purchases[_purchaseID].buyer] = SafeMath.sub(ccLockedUpBalances[purchases[_purchaseID].buyer], purchases[_purchaseID].tokenAmount);

        // set the purchase's status to inactive
        purchases[_purchaseID].active = false;

        //correct th amount of tokens generated
        totalSupply = SafeMath.sub(totalSupply, purchases[_purchaseID].tokenAmount);

        LogCancelDelivery(purchases[_purchaseID].buyer, _purchaseID);
    }

    // @dev Deliver tokens sold for CC/fiat and BTC
    // @dev param _tokens in Cents, e.g. 1 Token == 1$, passed as 100 cents
    // @dev param _btcBuyer Boolean to determine if the delivered tokens need to be locked (not the case for BTC buyers, their payment is final)
    // @dev discount multipliers are applied off-contract in this case
    function deliverTokens(address _to, uint256 _tokens, string _purchaseId, bool _btcBuyer)
    external
    isFundraising
    onlyVendor
    {
        require(_to != 0x0);
        require(_tokens > 0);
        require(bytes(_purchaseId).length>0);
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock + 168000); // allow delivery of tokens sold for fiat for 28 days after end of ICO for safety reasons

        // calculate the total amount of tokens and cut out the extra two decimal units,
        // because _tokens was in cents.
        uint256 tokens = SafeMath.mul(_tokens, (10**(decimals) / 10**2));

        // continue to check for how many tokens
        // have been generated so far
        uint256 checkedSupply = SafeMath.add(totalSupply, tokens);
        require(checkedSupply <= TOKEN_CREATION_CAP);

        // Only when all the checks have passed, then we update the state (totalSupply, and balances) of the contract
        totalSupply = checkedSupply;

        // prevent from adding a delivery multiple times
        require(purchases[_purchaseId].buyer==0x0);

        // Log this information in order to be able to cancel token deliveries (on CC refund) by the payment ID
        purchases[_purchaseId] = Purchase({
            buyer: _to,
            tokenAmount: tokens,
            active: true
        });
        purchaseArray.push(_purchaseId);

        // if tokens were not paid with BTC (but credit card), they need to be locked up 
        if (_btcBuyer == false) {
        ccLockedUpBalances[_to] = SafeMath.add(ccLockedUpBalances[_to], tokens); // update user's locked up token balance
        }

        balances[_to] = SafeMath.add(balances[_to], tokens);                     // safeAdd not needed; bad semantics to use here
        trackHolder(_to);                                                        // log holder's address

        // to force the check for KYC Status upon the user when he tries transferring tokens
        // and exclude every later token owner
        isIcoBuyer[_to] = true;

        // Log the creation of these tokens
        LogDeliverEVN(_to, tokens);
   }

    /// @dev Returns the current token price
    function getCurrentDiscountRate()
    private
    constant
    returns (uint256 currentDiscountRate)
    {
        // determine which discount to apply
        if (block.number < roundTwoBlock) {
            // first round
            return TOKEN_FIRST_DISCOUNT_MULTIPLIER;
        } else if (block.number < roundThreeBlock){
            // second round
            return TOKEN_SECOND_DISCOUNT_MULTIPLIER;
        } else if (block.number < roundFourBlock) {
            // third round
            return TOKEN_THIRD_DISCOUNT_MULTIPLIER;
        } else {
            // fourth round, no discount
            return 100000;
        }
    }

    /// @dev Allows to transfer ether from the contract as soon as the minimum is reached
    function retrieveEth(uint256 _value, address _safe)
    external
    minimumReached
    onlyOwner
    {
        require(SafeMath.sub(this.balance, _value) >= allUnKycedEth); // make sure unKYCed eth cannot be withdrawn
        // make sure a recipient was defined !
        require (_safe != 0x0);

        // send the eth to where admins agree upon
        _safe.transfer(_value);
    }


    /// @dev Ends the fundraising period and sends the ETH to wherever the admins agree upon
    function finalize(address _safe)
    external
    isFundraising
    minimumReached
    onlyOwner  // Only the admins calling this method exactly the same way can finalize the sale.
    {
        // Only allow to finalize the contract before the ending block if we already reached any of the two caps
        require(block.number > fundingEndBlock || totalSupply >= TOKEN_CREATED_MIN || allReceivedEth >= ETH_RECEIVED_MIN);
        // make sure a recipient was defined !
        require (_safe != 0x0);

        // Move the contract to Finalized state
        state = ContractState.Finalized;
        savedState = ContractState.Finalized;

        // Send the KYCed ETH to where admins agree upon.
        _safe.transfer(allReceivedEth);
    }


    /// @dev Pauses the contract
    function pause()
    external
    notPaused   // Prevent the contract getting stuck in the Paused state
    onlyOwner   // Only both admins calling this method can pause the contract
    {
        // Move the contract to Paused state
        savedState = state;
        state = ContractState.Paused;
    }


    /// @dev Proceeds with the contract
    function proceed()
    external
    isPaused
    onlyOwner   // Only both admins calling this method can proceed with the contract
    {
        // Move the contract to the previous state
        state = savedState;
    }

    /// @dev Allows contributors to recover their ether in case the minimum funding goal is not reached
    function refund()
    external
    {
        // Allow refunds only a week after end of funding to give KYC-team time to verify contributors
        // and thereby move un-KYC-ed ETH over into allReceivedEth as well as deliver the tokens paid with CC
        require(block.number > (fundingEndBlock + 42000));

        // No refunds if the minimum has been reached or minimum of 1 Million Tokens have been generated
        require(allReceivedEth < ETH_RECEIVED_MIN || totalSupply < TOKEN_CREATED_MIN);

        // to prevent CC buyers from accidentally calling refund and burning their tokens
        require (ethBalances[msg.sender] > 0 || noKycEthBalances[msg.sender] > 0);

        // Only refund if there are EVN tokens
        uint256 EVNVal = balances[msg.sender];
        require(EVNVal > 0);

        // refunds either KYCed eth or un-KYCd eth
        uint256 ethVal = SafeMath.add(ethBalances[msg.sender], noKycEthBalances[msg.sender]);
        require(ethVal > 0);

        allReceivedEth = SafeMath.sub(allReceivedEth, ethBalances[msg.sender]);    // subtract only the KYCed ETH from allReceivedEth, because the latter is what admins will only be able to withdraw
        allUnKycedEth = SafeMath.sub(allUnKycedEth, noKycEthBalances[msg.sender]); // or if there was any unKYCed Eth, subtract it from the total unKYCed eth balance.

        // Update the state only after all the checks have passed.
        // reset everything to zero, no replay attacks.
        balances[msg.sender] = 0;
        ethBalances[msg.sender] = 0;
        noKycEthBalances[msg.sender] = 0;
        totalSupply = SafeMath.sub(totalSupply, EVNVal); // Extra safe

        // Log this refund
        LogRefund(msg.sender, ethVal);

        // Send the contributions only after we have updated all the balances
        // If you're using a contract, make sure it works with .transfer() gas limits
        msg.sender.transfer(ethVal);
    }

    // @dev Deliver tokens to be distributed to team members
    function deliverTeamTokens(address _to)
    external
    isFinalized
    onlyOwner
    {
        require(teamTokensDelivered == false);
        require(_to != 0x0);

        // allow delivery of tokens for the company and supporters without vesting, team tokens will be supplied like a CC purchase.
        
        // company and supporters gets 7% of a whole final pie, meaning we have to add ~7,5% to the
        // current totalSupply now, basically stretching it and taking 7% from the result, so the 93% that remain equals the amount of tokens created right now.
        // e.g. (93 * x = 100, where x amounts to roughly about 1.07526 and 7 would be the team's part)
        uint256 newTotalSupply = safeMulPercentage(totalSupply, 107526);

        // give company and supporters their 7% 
        uint256 tokens = SafeMath.sub(newTotalSupply, totalSupply);
        balances[_to] = tokens;

        //update state
        teamTokensDelivered = true;
        totalSupply = newTotalSupply;
        trackHolder(_to);

        // Log the creation of these tokens
        LogTeamTokensDelivered(_to, tokens);
    }

    function safeMulPercentage(uint256 value, uint256 percentage)
    internal
    constant
    returns (uint256 resultValue)
    {
        require(percentage >= 100000);
        require(percentage < 200000);

        // Multiply with percentage
        uint256 newValue = SafeMath.mul(value, percentage);
        // Remove the 5 extra decimals
        newValue = newValue / 10**5;
        return newValue;
    }

    // customizing the gas price for oraclize calls during "ICO Rush hours"
    function setOraclizeGas(uint256 _option)
    external
    onlyOwner
    {
        if (_option <= 30) {
            oraclize_setCustomGasPrice(30000000000 wei);
        } else if (_option <= 50) {
            oraclize_setCustomGasPrice(50000000000 wei);
        } else if (_option <= 70) {
            oraclize_setCustomGasPrice(70000000000 wei);
        } else if (_option <= 100) {
            oraclize_setCustomGasPrice(100000000000 wei);
        }
    }
}