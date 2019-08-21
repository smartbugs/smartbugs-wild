pragma solidity^0.4.24;

/**
                        MOBIUS 2D
                        V2.0
                     https://m2d.win 
                                       
    This game was inspired by FOMO3D. Our code is much cleaner and more efficient (built from scratch).
    Some useless "features" like the teams were not implemented.
 */

interface MobiusToken {
    function disburseDividends() external payable;
}

interface LastVersion {
    function withdrawReturns() external;
    function roundInfo(uint roundID) external view 
    returns(
        address leader, 
        uint price,
        uint jackpot, 
        uint airdrop, 
        uint shares, 
        uint totalInvested,
        uint distributedReturns,
        uint _hardDeadline,
        uint _softDeadline,
        bool finalized
        );
    function totalsInfo() external view 
    returns(
        uint totalReturns,
        uint totalShares,
        uint totalDividends,
        uint totalJackpots
    );
    function latestRoundID() external returns(uint);
}

/**
    The Mobius2D game consists of rounds with guaranteed winners!
    You buy "shares" (instad of keys) for a given round, and you get returns from investors after you.
    The sare price is constant until the hard deadline, after which it increases exponentially. 
    If a round is inactive for a day it can end earlier than the hard deadline.
    If a round runs longer, it is guaranteed to finish not much after the hard deadline (and the last investor gets the big jackpot).
    Additionally, if you invest more than 0.1 ETH you get a chance to win an airdrop and you get bonus shares
    Part of all funds also go to a big final jackpot - the last investor (before a round runs out) wins.
    Payouts work in REAL TIME - you can withdraw your returns at any time!
    Additionally, the first round is an ICO, so you'll also get our tokens by participating!
    !!!!!!!!!!!!!!
    Token holders will receive part of current and future revenue of this and any other game we develop!
    !!!!!!!!!!!!!!
    
    .................................. LAUGHING MAN sssyyhddmN..........................................
    ..........................Nmdyyso+/:--.``` :`  `-`:--:/+ossyhdmN....................................
    ......................Ndhyso/:.`   --.     o.  /+`o::` `` `-:+osyh..................................
    ..................MNdyso/-` /-`/:+./:/..`  +.  //.o +.+::+ -`  `-/sshdN.............................
    ................Ndyso:` ` --:+`o//.-:-```  ...  ``` - /::::/ +..-` ./osh............................
    ..............Nhso/. .-.:/`o--:``   `..-:::oss+::--.``    .:/::/`+-`/../sydN........................
    ............mhso-``-:+./:-:.   .-/+osssssssssssssssssso+:-`  -//o::+:/` .:oyhN......................
    ..........Nhso:`  .+-./ `  .:+sssssso+//:-------:://+ossssso/---.`-`/:-o/ `:syd.....................
    ........Mdyo- +/../`-`  ./osssso/-.`                 ``.:+ossss+:`  `-+`  ` `/sy....................
    ......MNys/` -:-/:    -+ssss+-`                           `.:+ssss/.  `  -+-. .osh..................
    ......mys-  :-/+-`  :osss+-`                                  .:osss+.  `//o:- `/syN................
    ....Mdso. --:-/-  -osss+.                                       `-osss+`  :--://`-sy................
    ....dso-. ++:+  `/sss+.                                           `:osss:  `:.-+  -sy...............
    ..Mdso``+///.` .osss:                                               `/sss+`  :/-.. -syN.............
    ..mss` `+::/  .ssso.                                                  :sss+` `+:/+  -syN............
    ..ys-   ```  .ssso`                                                    -sss+` `:::+:`/sh............
    Mds+ `:/..  `osso`                                                      -sss+  -:`.` `ssN...........
    Mys. `/+::  +sss/........................................................+sss:.....-::+sy..NN.......
    ds+  :-/-  .ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssyyhdN...
    hs: `/+::   :/+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ossssyhNM
    ss. `:::`                    ````                        ```                               ``-+sssyN
    ss` /:-+` `o++:           .:+oooo+/.                 `-/ooooo+-`                               -sssy
    ss  `:/:  `sss/          :ooo++/++os/`              .oso++/++oso.                               osss
    ss``/:--  `sss/         ./.`      `.::              /-.`     ``-/`                             -sssy
    ss.:::-:.  ssso         `            `                                                    ``.-+sssyN
    hs:`:/:/.  /sss.   .++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++oossssyhNM
    ds+ ``     .sss/   -ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssyyyyhmN...
    Nss.:::::.  +sss.   +sss/........................................osss:...+sss:......../shmNNN.......
    Mds+..-:::` `osso`  `+sss:                                     `+sss:   -sss+  .:-.` `ssN...........
    ..ys- .+.::  .ssso`  `/sss+.                                  -osss:   -sss+` `:++-` /sh............
    ..mss` .-.    .ssso.   :osss/`                              .+ssso.   :sss+` `.:+:` -syN............
    ..Mdso`  `--:` .osss:   `/ssss/.`                        `-+ssso:`  `/sss+` `++.-. -syN.............
    ....dso` -//+-` `/sss+.   ./ossso/-``                `.:+sssso:`  `:osss:  .::+/. -sy...............
    ....Mdso. `-//-`  -osss+.   `-+ssssso+/:-.`````..-:/+osssso/.   `-osss+.` -///-  -sy................
    ......mys- `/://.`  :osss+-`   `-/+osssssssssssssssssso+:.    .:osss+.  .:`..-``/syN................
    ......MNys/` ..+-/:   -+ssss+-`    `.-://++oooo++/:-.`    `.:+ssss/.  .`      .osh..................
    ........Mdyo- `::/.  `  ./osssso/-.`                 ``.:+ossss+:` `  .//`  `/sy....................
    ..........Nhso-     :+:.`  .:+sssssso+//:--------://+ossssso/:.  `::/: --/.:syd.....................
    ............mhso-` ./+--+-:    .-/+osssssssssssssssssso+/-.  .+` `//-/ `::oyhN......................
    ..............Nhso/`   +/:--+.-`    `..-:::////::--.``    .`:/-o`  ./`./sydN........................
    ................Ndys+:` ``--+++-  .:  `.``      `` -.`/:/`.o./::.  ./osh............................
    ..................MNdyso/-` ` :`  +-  :+.o`s ::-/++`s`+/o.-:`  `-/sshdN.............................
    ......................Ndhyso/:.` .+   +/:/ +:/-./:-`+: `` `.:+osyh..................................
    ..........................Nmdyyso+/:--/.``      ``..-:/+ossyhdmN....................................
    ..............................MN..dhhyyssssssssssssyyhddmN..........................................
 */
 
 contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract DSA {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetOrcl (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSA  public  a;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setOrcl(DSA a_)
        public
        auth
    {
        a = a_;
        emit LogSetOrcl(a);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (a == DSA(0)) {
            return false;
        } else {
            return a.canCall(src, this, sig);
        }
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

contract usingOraclize is DSAuth {
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
        
        return false;
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
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

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
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

    using CBOR for Buffer.buffer;

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

contract UsingOraclizeRandom is usingOraclize {
    uint public oraclizeCallbackGas = 200000;
    uint public oraclizeGasPrice = 20000000000; //20 gwei
    uint public totalPaidOraclize;
    uint internal oraclizeLastRequestTime;
    bool internal oraclizePending;

    mapping(bytes32=>bool) internal validQueryIDs;

    constructor() public {
        a = DSA(0xdbf98a75f521Cb1BD421c03F2b6A6a617f4240F1);
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public {
        oraclizePending = false;
        require(validQueryIDs[_queryId], "Invalid request ID!");
        require(msg.sender == oraclize_cbAddress(), "You can't do that!");
        
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            _onRandomFailed(_queryId);
        } else {
            uint randomNumber = uint(keccak256(abi.encode(_result)));
            _onRandom(randomNumber, _queryId);
        }
        delete validQueryIDs[_queryId];
    }

    function _requestRandom(uint delay) internal returns(bytes32 qID) {
        qID = oraclize_newRandomDSQuery(delay, 32, oraclizeCallbackGas);
        validQueryIDs[qID] = true;
    }

    function _onRandom(uint _rand, bytes32 _queryId) internal;

    function _onRandomFailed(bytes32 _queryId) internal;

    function setOraclizeGasLimit(uint _newLimit) public auth {
        oraclizeCallbackGas = _newLimit;
    }

    function setOraclizeGasPrice(uint _newGasPrice) public auth {
        oraclizeGasPrice = _newGasPrice;
        oraclize_setCustomGasPrice(_newGasPrice);
    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        oraclizePending = true; // overriding the dafault function to add this line
        oraclizeLastRequestTime = now; // overriding the dafault function to add this line
        uint price = oraclize.getPrice(datasource, gaslimit);
        totalPaidOraclize += price; // overriding the dafault function to add this line
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }

}
// </ORACLIZE_API>

 
contract Mobius2Dv2 is UsingOraclizeRandom, DSMath {
    // IPFS hash of the website - can be accessed even if our domain goes down.
    // Just go to any public IPFS gateway and use this hash - e.g. ipfs.infura.io/ipfs/<ipfsHash>
    string public ipfsHash;
    string public ipfsHashType = "ipfs"; // can either be ipfs, or ipns

    MobiusToken public constant token = MobiusToken(0x54cdC9D889c28f55F59f6b136822868c7d4726fC);

    // In case of an upgrade, these variables will be set. An upgrade does not affect a currently running round,
    // nor does it do anything with investors' vaults.
    bool public upgraded;
    bool public initialized;
    address public nextVersion;
    LastVersion public constant lastVersion = LastVersion(0xA74642Aeae3e2Fd79150c910eB5368B64f864B1e);
    uint public previousRounds;// how many rounds the last version had

    // Total stats
    uint public totalRevenue;
    uint public totalSharesSold;
    uint public totalEarningsGenerated;
    uint public totalDividendsPaid;
    uint public totalJackpotsWon;

    // Fractions for where revenue goes
    uint public constant DEV_DIVISOR = 20;                      // 5% 

    uint public constant RETURNS_FRACTION = 60 * 10**16;        // 60% goes to share holders
    // this value will be taken from the above fraction (e.g. if 3% is for refferals, then 57% goes to returns) 
    uint public constant REFERRAL_FRACTION = 3 * 10**16;        //3% for referrals

    uint public constant JACKPOT_SEED_FRACTION = WAD / 20;      // 5% goes to the next round's jackpot
    uint public constant JACKPOT_FRACTION = 15 * 10**16;        // 15% goes to the final jackpot
    uint public constant DAILY_JACKPOT_FRACTION = 6 * 10**16;    // 6% goes to daily jackpots
    uint public constant DIVIDENDS_FRACTION = 9 * 10**16;       // 9% goes to token holders!

    // NOTE: These parameters can be changed. If they are changed, the new values only affect the next round (not a currently running one)
    uint public startingSharePrice = 1 finney;   // a 1000th of an ETH
    uint public _priceIncreasePeriod = 1 hours;  // how often the price increases
    uint public _priceMultiplier = 101 * 10**16; // 101% - increase by 1% each increase period

    uint public _secondaryPrice = 100 finney;    // The minimum value to enter the daily jackpot draw
    uint public maxDailyJackpot = 5 ether; // Limit the max daily jackpot, so that it doesn't deplete quickly after a period of rapid growth

    uint public constant SOFT_DEADLINE_DURATION = 1 days; // max soft deadline
    uint public constant DAILY_JACKPOT_PERIOD = 1 days;
    uint public constant TIME_PER_SHARE = 5 minutes; // how much time is added to the soft deadline per share purchased

    uint public nextRoundTime; // this can be set as a delay before the next round can be started
    uint public jackpotSeed;// Jackpot from previous rounds
    uint public devBalance; // outstanding balance for devs

    // Helpers to calculate returns - no funds are ever held on lockdown
    uint public unclaimedReturns;
    uint public constant MULTIPLIER = RAY;

    // To keep track of players latest daily jackpot entry
    mapping (address => uint) public lastDailyEntry;

    // This represents an investor. No need to player IDs - they are useless (everyone already has a unique address).
    // Just use native mappings (duh!)
    struct Investor {
        uint lastCumulativeReturnsPoints;
        uint shares;
    }

    // This represents a round
    struct MobiusRound {
        uint totalInvested;        
        uint jackpot;
        uint dailyJackpot;
        uint totalShares;
        uint cumulativeReturnsPoints; // this is to help calculate returns when the total number of shares changes
        uint softDeadline;
        uint price;
        uint secondaryPrice;
        uint priceMultiplier;
        uint priceIncreasePeriod;
        uint lastPriceIncreaseTime;
        uint lastDailyJackpot;
        address lastInvestor;
        bool finalized;
        mapping (address => Investor) investors;
    }

    struct DailyJackpotRound {
        address[] entrants;
        address winner;
        bool finalized;
    }

    struct Vault {
        uint totalReturns; // Total balance = returns + referral returns + jackpots/airdrops 
        uint refReturns; // how much of the total is from referrals
    }

    mapping (address => Vault) vaults;

    uint public latestRoundID;// the first round has an ID of 0
    uint public latestDailyID;// daily round ID
    MobiusRound[] rounds;
    DailyJackpotRound[] dailyRounds;

    event SharesIssued(address indexed to, uint shares);
    event ReturnsWithdrawn(address indexed by, uint amount);
    event JackpotWon(address by, uint amount);
    event DailyJackpotWon(address indexed by, uint amount);
    event RoundStarted(uint ID, uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod);
    event IPFSHashSet(string _type, string _hash);

    constructor() public {
    }

    function initOraclize() public auth {
        oraclizeCallbackGas = 250000;
        if(oraclize_setNetwork()){
            oraclize_setProof(proofType_Ledger);
        }
    }

    // The return values will include all vault balance, but you must specify a roundID because
    // Returns are not actually calculated in storage until you invest in the round or withdraw them
    function estimateReturns(address investor, uint roundID) public view 
    returns (uint totalReturns, uint refReturns) 
    {
        MobiusRound storage rnd = rounds[roundID];
        uint outstanding;
        if(rounds.length > 1) {
            if(hasReturns(investor, roundID - 1)) {
                MobiusRound storage prevRnd = rounds[roundID - 1];
                outstanding = _outstandingReturns(investor, prevRnd);
            }
        }

        outstanding += _outstandingReturns(investor, rnd);
        
        totalReturns = vaults[investor].totalReturns + outstanding;
        refReturns = vaults[investor].refReturns;
    }

    function hasReturns(address investor, uint roundID) public view returns (bool) {
        MobiusRound storage rnd = rounds[roundID];
        return rnd.cumulativeReturnsPoints > rnd.investors[investor].lastCumulativeReturnsPoints;
    }

    function investorInfo(address investor, uint roundID) external view
    returns(uint shares, uint totalReturns, uint referralReturns, bool inNextDailyDraw) 
    {
        MobiusRound storage rnd = rounds[roundID];
        shares = rnd.investors[investor].shares;
        (totalReturns, referralReturns) = estimateReturns(investor, roundID);
        inNextDailyDraw = lastDailyEntry[investor] > rnd.lastDailyJackpot;
    }

    function roundInfo(uint roundID) external view 
    returns(
        address leader, 
        uint price,
        uint secondaryPrice,
        uint priceMultiplier,
        uint priceIncreasePeriod,
        uint jackpot, 
        uint dailyJackpot, 
        uint lastDailyJackpot,
        uint shares, 
        uint totalInvested,
        uint distributedReturns,
        uint _softDeadline,
        bool finalized
        )
    {
        MobiusRound storage rnd = rounds[roundID];
        leader = rnd.lastInvestor;
        price = rnd.price;
        secondaryPrice = _secondaryPrice;
        priceMultiplier = rnd.priceMultiplier;
        priceIncreasePeriod = rnd.priceIncreasePeriod;
        jackpot = rnd.jackpot;
        dailyJackpot = min(maxDailyJackpot, rnd.dailyJackpot/2);
        lastDailyJackpot = rnd.lastDailyJackpot;
        shares = rnd.totalShares;
        totalInvested = rnd.totalInvested;
        distributedReturns = wmul(rnd.totalInvested, RETURNS_FRACTION);
        _softDeadline = rnd.softDeadline;
        finalized = rnd.finalized;
    }

    function totalsInfo() external view 
    returns(
        uint totalReturns,
        uint totalShares,
        uint totalDividends,
        uint totalJackpots,
        uint totalInvested,
        uint totalRounds
    ) {
        MobiusRound storage rnd = rounds[latestRoundID];
        if(rnd.softDeadline > now) {
            totalShares = totalSharesSold + rnd.totalShares;
            totalReturns = totalEarningsGenerated + wmul(rnd.totalInvested, RETURNS_FRACTION);
            totalDividends = totalDividendsPaid + wmul(rnd.totalInvested, DIVIDENDS_FRACTION);
            totalInvested = totalRevenue + rnd.totalInvested;
        } else {
            totalShares = totalSharesSold;
            totalReturns = totalEarningsGenerated;
            totalDividends = totalDividendsPaid;
            totalInvested = totalRevenue;
        }
        totalJackpots = totalJackpotsWon;
        totalRounds = previousRounds + rounds.length;
    }

    function () public payable {
        if(!initialized){
            jackpotSeed += msg.value;
        } else {
            buyShares(address(0x0));
        }
    }

    /// Function to buy shares in the latest round. Purchase logic is abstracted
    function buyShares(address ref) public payable {        
        if(rounds.length > 0) {
            MobiusRound storage rnd = rounds[latestRoundID];                  
            _purchase(rnd, msg.value, ref);            
        } else {
            revert("Not yet started");
        }
    }

    /// Function to purchase with what you have in your vault as returns
    function reinvestReturns(uint value) public {        
        reinvestReturns(value, address(0x0));
    }

    function reinvestReturns(uint value, address ref) public {        
        MobiusRound storage rnd = rounds[latestRoundID];
        _updateReturns(msg.sender, rnd);        
        require(vaults[msg.sender].totalReturns >= value, "Can't spend what you don't have");        
        vaults[msg.sender].totalReturns = sub(vaults[msg.sender].totalReturns, value);
        vaults[msg.sender].refReturns = min(vaults[msg.sender].refReturns, vaults[msg.sender].totalReturns);
        unclaimedReturns = sub(unclaimedReturns, value);
        _purchase(rnd, value, ref);
    }

    function withdrawReturns() public {
        MobiusRound storage rnd = rounds[latestRoundID];

        if(rounds.length > 1) {// check if they also have returns from before
            if(hasReturns(msg.sender, latestRoundID - 1)) {
                MobiusRound storage prevRnd = rounds[latestRoundID - 1];
                _updateReturns(msg.sender, prevRnd);
            }
        }
        _updateReturns(msg.sender, rnd);
        uint amount = vaults[msg.sender].totalReturns;
        require(amount > 0, "Nothing to withdraw!");
        unclaimedReturns = sub(unclaimedReturns, amount);
        vaults[msg.sender].totalReturns = 0;
        vaults[msg.sender].refReturns = 0;
        
        rnd.investors[msg.sender].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
        msg.sender.transfer(amount);

        emit ReturnsWithdrawn(msg.sender, amount);
    }

    // Manually update your returns for a given round in case you were inactive since before it ended
    function updateMyReturns(uint roundID) public {
        MobiusRound storage rnd = rounds[roundID];
        _updateReturns(msg.sender, rnd);
    }

    function finalizeAndRestart() public payable {
        finalizeLastRound();
        startNewRound();
    }

    /// Anyone can start a new round
    function startNewRound() public payable {
        require(!upgraded && initialized, "This contract has been upgraded, or is not yet initialized!");
        require(now >= nextRoundTime, "Too early!");
        if(rounds.length > 0) {
            require(rounds[latestRoundID].finalized, "Previous round not finalized");
            require(rounds[latestRoundID].softDeadline < now, "Previous round still running");
        }
        uint _rID = rounds.length++;
        MobiusRound storage rnd = rounds[_rID];
        latestRoundID = _rID;

        rnd.lastInvestor = msg.sender;
        rnd.price = startingSharePrice;
        rnd.secondaryPrice = _secondaryPrice;
        rnd.priceMultiplier = _priceMultiplier;
        rnd.priceIncreasePeriod = _priceIncreasePeriod;
        rnd.lastPriceIncreaseTime = now;
        rnd.lastDailyJackpot = now;
        rnd.softDeadline = now + SOFT_DEADLINE_DURATION;
        rnd.jackpot = jackpotSeed;
        jackpotSeed = 0; 
        _startNewDailyRound();
        _purchase(rnd, msg.value, address(0x0));
        emit RoundStarted(_rID, startingSharePrice, _priceMultiplier, _priceIncreasePeriod);
    }

    /// Anyone can finalize a finished round
    function finalizeLastRound() public {
        MobiusRound storage rnd = rounds[latestRoundID];
        _finalizeRound(rnd);
    }

    function setRoundParams(uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod) public auth {
        startingSharePrice = startingPrice;
        _priceMultiplier = priceMultiplier;
        _priceIncreasePeriod = priceIncreasePeriod;
    }

    function setSecondaryPrice(uint newPrice) public auth {
        _secondaryPrice = newPrice;
    }

    function setMaxDailyJackpot(uint newLimit) public auth {
        maxDailyJackpot = newLimit;
    }

    // This is if we want to delay the start of the next round
    function setNextRoundTimestamp(uint timestamp) public auth {
        require(now > nextRoundTime);
        require(timestamp <= now + 2 days);// Can't set longer than 2 days delay
        nextRoundTime = timestamp;
    }

    function setNextRoundDelay(uint delayInSeconds) public auth {
        require(now > nextRoundTime);
        require(now + delayInSeconds <= now + 2 days);// Can't set longer than 2 days delay
        nextRoundTime = now + delayInSeconds;
    }
    
    /// This is how devs pay the bills
    function withdrawDevShare() public auth {
        uint value = sub(devBalance, totalPaidOraclize); // Pay for oraclize from dev share
        devBalance = 0;
        totalPaidOraclize = 0;
        msg.sender.transfer(value);
    }

    function setIPFSHash(string _type, string _hash) public auth {
        ipfsHashType = _type;
        ipfsHash = _hash;
        emit IPFSHashSet(_type, _hash);
    }

    function upgrade(address _nextVersion) public auth {
        require(_nextVersion != address(0x0), "Invalid Address!");
        require(!upgraded, "Already upgraded!");
        upgraded = true;
        nextVersion = _nextVersion;
    }

    //this is a fix for the previous bug that didn't let us transfer directly to the next version
    function getSeed() public {
        require(upgraded, "Not upgraded!");
        require(msg.sender == nextVersion, "You can't do that!");
        MobiusRound storage rnd = rounds[latestRoundID];
        require(rnd.finalized, "Still running!");
        
        require(nextVersion.call.value(jackpotSeed)(), "Transfer failed!");
    }

    // Function to initialise an updated version of the contract
    // Grab totals info and transfer the jackpot seed
    function init() public auth {
        
        require(!initialized, "Already initialized!");
        uint _rID = lastVersion.latestRoundID();
        previousRounds = 1 + _rID;
        uint _shares;
        uint _invested;// last version doesn't have a total invested counter, so this is assuming only a single round has run
        uint _returns;
        uint _dividends;
        uint _jackpots;
        bool finalized;
        ( , , , , , _invested, , , , finalized) = lastVersion.roundInfo(_rID);
        require(finalized, "Last round is still not finalized!");
        (_returns, _shares, _dividends, _jackpots) = lastVersion.totalsInfo();

        totalSharesSold = _shares;
        totalRevenue = _invested;
        totalEarningsGenerated = _returns;
        totalDividendsPaid = _dividends;
        totalJackpotsWon = _jackpots;
        // To be used in the next version - this one will be manually seeded
        // lastVersion.getSeed();
        
        initialized = true;
    }

    function _startNewDailyRound() internal {
        if(dailyRounds.length > 0) {
            require(dailyRounds[latestDailyID].finalized, "Previous round not finalized");
        }
        uint _rID = dailyRounds.length++;
        latestDailyID = _rID;
    }

    /// Purchase logic
    function _purchase(MobiusRound storage rnd, uint value, address ref) internal {
        require(rnd.softDeadline >= now, "After deadline!");
        require(value >= 100 szabo, "Not enough Ether!");
        rnd.totalInvested = add(rnd.totalInvested, value);

        // Set the last investor (to win the jackpot after the deadline)
        if(value >= rnd.price) {
            rnd.lastInvestor = msg.sender;
        }
        // Process daily jackpot 
        _dailyJackpot(rnd, value);
        // Process revenue in different "buckets"
        _splitRevenue(rnd, value, ref);
        // Update returns before issuing shares
        _updateReturns(msg.sender, rnd);
        //issue shares for the current round. 1 share = 1 time increase for the deadline
        uint newShares = _issueShares(rnd, msg.sender, value);

        uint timeIncreases = newShares/WAD;// since 1 share is represented by 1 * 10^18, divide by 10^18
        // adjust soft deadline to new soft deadline
        uint newDeadline = add(rnd.softDeadline, mul(timeIncreases, TIME_PER_SHARE));
        rnd.softDeadline = min(newDeadline, now + SOFT_DEADLINE_DURATION);
        
        // If it's time to increase the price - do it
        if(now > rnd.lastPriceIncreaseTime + rnd.priceIncreasePeriod) {
            rnd.price = wmul(rnd.price, rnd.priceMultiplier);
            rnd.lastPriceIncreaseTime = now;
        }
        
    }

    function _finalizeRound(MobiusRound storage rnd) internal {
        require(!rnd.finalized, "Already finalized!");
        require(rnd.softDeadline < now, "Round still running!");

        // Transfer jackpot to winner's vault
        vaults[rnd.lastInvestor].totalReturns = add(vaults[rnd.lastInvestor].totalReturns, rnd.jackpot);
        unclaimedReturns = add(unclaimedReturns, rnd.jackpot);
        
        emit JackpotWon(rnd.lastInvestor, rnd.jackpot);
        totalJackpotsWon += rnd.jackpot;
        // transfer the leftover to the next round's jackpot
        jackpotSeed = add(jackpotSeed, wmul(rnd.totalInvested, JACKPOT_SEED_FRACTION));
        //Empty the AD pot if it has a balance.
        jackpotSeed = add(jackpotSeed, rnd.dailyJackpot);
               
        //Send out dividends to token holders
        uint _div = wmul(rnd.totalInvested, DIVIDENDS_FRACTION);            
        
        token.disburseDividends.value(_div)();
        totalDividendsPaid += _div;
        totalSharesSold += rnd.totalShares;
        totalEarningsGenerated += wmul(rnd.totalInvested, RETURNS_FRACTION);
        totalRevenue += rnd.totalInvested;
        dailyRounds[latestDailyID].finalized = true;
        rnd.finalized = true;
    }

    /** 
        This is where the magic happens: every investor gets an exact share of all returns proportional to their shares
        If you're early, you'll have a larger share for longer, so obviously you earn more.
    */
    function _updateReturns(address _investor, MobiusRound storage rnd) internal {
        if(rnd.investors[_investor].shares == 0) {
            return;
        }
        
        uint outstanding = _outstandingReturns(_investor, rnd);

        // if there are any returns, transfer them to the investor's vaults
        if (outstanding > 0) {
            vaults[_investor].totalReturns = add(vaults[_investor].totalReturns, outstanding);
        }

        rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
    }

    function _outstandingReturns(address _investor, MobiusRound storage rnd) internal view returns(uint) {
        if(rnd.investors[_investor].shares == 0) {
            return 0;
        }
        // check if there've been new returns
        uint newReturns = sub(
            rnd.cumulativeReturnsPoints, 
            rnd.investors[_investor].lastCumulativeReturnsPoints
            );

        uint outstanding = 0;
        if(newReturns != 0) { 
            // outstanding returns = (total new returns points * ivestor shares) / MULTIPLIER
            // The MULTIPLIER is used also at the point of returns disbursment
            outstanding = mul(newReturns, rnd.investors[_investor].shares) / MULTIPLIER;
        }

        return outstanding;
    }

    /// Process revenue according to fractions
    function _splitRevenue(MobiusRound storage rnd, uint value, address ref) internal {
        uint roundReturns;
        
        if(ref != address(0x0) && ref != msg.sender) {
            // if there was a referral
            roundReturns = wmul(value, RETURNS_FRACTION - REFERRAL_FRACTION);
            uint _ref = wmul(value, REFERRAL_FRACTION);
            vaults[ref].totalReturns = add(vaults[ref].totalReturns, _ref);            
            vaults[ref].refReturns = add(vaults[ref].refReturns, _ref);
            unclaimedReturns = add(unclaimedReturns, _ref);
        } else {
            roundReturns = wmul(value, RETURNS_FRACTION);
        }
        
        uint dailyJackpot = wmul(value, DAILY_JACKPOT_FRACTION);
        uint jackpot = wmul(value, JACKPOT_FRACTION);
        
        uint dev;
        
        dev = value / DEV_DIVISOR;
        
        // if this is the first purchase, send to jackpot (no one can claim these returns otherwise)
        if(rnd.totalShares == 0) {
            rnd.jackpot = add(rnd.jackpot, roundReturns);
        } else {
            _disburseReturns(rnd, roundReturns);
        }
        
        rnd.dailyJackpot = add(rnd.dailyJackpot, dailyJackpot);
        rnd.jackpot = add(rnd.jackpot, jackpot);
        devBalance = add(devBalance, dev);
    }

    function _disburseReturns(MobiusRound storage rnd, uint value) internal {
        unclaimedReturns = add(unclaimedReturns, value);// keep track of unclaimed returns
        // The returns points represent returns*MULTIPLIER/totalShares (at the point of purchase)
        // This allows us to keep outstanding balances of shareholders when the total supply changes in real time
        if(rnd.totalShares == 0) {
            rnd.cumulativeReturnsPoints = mul(value, MULTIPLIER) / wdiv(value, rnd.price);
        } else {
            rnd.cumulativeReturnsPoints = add(
                rnd.cumulativeReturnsPoints, 
                mul(value, MULTIPLIER) / rnd.totalShares
            );
        }
    }

    function _issueShares(MobiusRound storage rnd, address _investor, uint value) internal returns(uint) {    
        if(rnd.investors[_investor].lastCumulativeReturnsPoints == 0) {
            rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
        }    
        
        uint newShares = wdiv(value, rnd.price);
        
        //bonuses:
        if(value >= 100 ether) {
            newShares = mul(newShares, 2);//get double shares if you paid more than 100 ether
        } else if(value >= 10 ether) {
            newShares = add(newShares, newShares/2);//50% bonus
        } else if(value >= 1 ether) {
            newShares = add(newShares, newShares/3);//33% bonus
        } else if(value >= 100 finney) {
            newShares = add(newShares, newShares/10);//10% bonus
        }

        rnd.investors[_investor].shares = add(rnd.investors[_investor].shares, newShares);
        rnd.totalShares = add(rnd.totalShares, newShares);
        emit SharesIssued(_investor, newShares);
        return newShares;
    }    

    function _dailyJackpot(MobiusRound storage rnd, uint value) internal {
        
        if(value >= rnd.secondaryPrice) {
            dailyRounds[latestDailyID].entrants.push(msg.sender);
            lastDailyEntry[msg.sender] = now; // in order to tell who's eligible for the next draw
        }
        // If it's time to draw
        if(now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
            //if the jackpot is smaller than 2*secondaryPrice, then skip
            if(rnd.dailyJackpot < rnd.secondaryPrice * 4) {// multiply by 4 bexause only half is won
                return;
            }
            if(!oraclizePending) {                
                _requestRandom(0);
            } else {
                if(now > oraclizeLastRequestTime + 10 minutes){
                    // Increase gas price if callback times out
                    // Increase to double last price, max 150 gwei.
                    oraclizeGasPrice = min(150000000000, oraclizeGasPrice * 2); 
                    oraclize_setCustomGasPrice(oraclizeGasPrice);
                }
            }
        }
    }

    // What happens when we get the random number from Oraclize
    function _onRandom(uint _rand, bytes32 _queryId) internal {
        MobiusRound storage rnd = rounds[latestRoundID];
        // only if the latest round is still running and it's time to draw the daily jackpot
        if(rnd.softDeadline >= now && now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
            _drawDailyJackpot(dailyRounds[latestDailyID], rnd, _rand);
        }
    }

    event FailedRNGVerification(bytes32 qID);

    function _onRandomFailed(bytes32 _queryId) internal {
        emit FailedRNGVerification(_queryId);
    }

    // We can manually send an Oraclize request - it doesn't affect the time of drawing the daily jackpot
    function _triggerOraclize() public auth {
        _requestRandom(0);
    }

    function _drawDailyJackpot(DailyJackpotRound storage dRnd, MobiusRound storage rnd, uint _rand) internal {
        if(dRnd.entrants.length != 0){
            uint winner = _rand % dRnd.entrants.length;
            uint prize = min(maxDailyJackpot, rnd.dailyJackpot / 2);// win half of the pot, with a max limit
            rnd.dailyJackpot = sub(rnd.dailyJackpot, prize);
            vaults[dRnd.entrants[winner]].totalReturns = add(vaults[dRnd.entrants[winner]].totalReturns, prize);
            emit DailyJackpotWon(dRnd.entrants[winner], prize);
            dRnd.finalized = true;       
            unclaimedReturns = add(unclaimedReturns, prize);
            totalJackpotsWon += prize;

            _startNewDailyRound();
        }        
        rnd.lastDailyJackpot = now; 
    }

}