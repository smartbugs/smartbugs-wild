/**
 * 
 *	@title 	FlightDelay contract
 *	@author	Christoph Mussenbrock, Stephan Karpischek
 *	
 *  @brief 	This is a smart contract modelling the financial compensation of 
 *			delayed flights. People can apply for a policy and get automatically 
 *			paid in case a plane is late. Probabilities are calculated based on
 *			public accessible information from http://www.flightstats.com. 
 *			Real time flight status information is also pulled from the 
 *			same source.
 *			A frontend for the contract is running on http://fdi.etherisc.com.
 *	
 *	@copyright (c) 2016 by the authors.
 *
 *	@remark To view the contract code, you have to scroll down past
 *  		the imported interfaces. 
 * 
 */

/**************************************************************************
 *
 *	Oraclize API
 *
 **************************************************************************/
 
// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani



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
    function query(uint _timestamp, string _datasource, string _arg) returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setCustomGasPrice(uint _gasPrice);
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
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;
    
    OraclizeI oraclize;
    modifier oraclizeAPI {
        address oraclizeAddr = OAR.getAddress();
        if (oraclizeAddr == 0){
            oraclize_setNetwork(networkID_auto);
            oraclizeAddr = OAR.getAddress();
        }
        oraclize = OraclizeI(oraclizeAddr);
        _
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)>0){
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0x9efbea6358bed926b293d2ce63a730d6d98d43dd)>0){
            OAR = OraclizeAddrResolverI(0x9efbea6358bed926b293d2ce63a730d6d98d43dd);
            return true;
        }
        if (getCodeSize(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf)>0){
            OAR = OraclizeAddrResolverI(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf);
            return true;
        }
        return false;
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
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
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
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
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

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
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

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
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
    

}
// </ORACLIZE_API>


/**************************************************************************
 *
 *	Arachnid Strings utils.
 *
 **************************************************************************/

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <arachnid@notdot.net>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */
library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private {
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
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string self) internal returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-termintaed utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal returns (slice ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice self) internal returns (slice) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice self) internal returns (string) {
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice self) internal returns (uint) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        var ptr = self._ptr - 31;
        var end = ptr + self._len;
        for (uint len = 0; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice self) internal returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice self, slice other) internal returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        var selfptr = self._ptr;
        var otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                var diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice self, slice other) internal returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice self, slice rune) internal returns (slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint len;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            len = 1;
        } else if(b < 0xE0) {
            len = 2;
        } else if(b < 0xF0) {
            len = 3;
        } else {
            len = 4;
        }

        // Check for truncated codepoints
        if (len > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += len;
        self._len -= len;
        rune._len = len;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice self) internal returns (slice ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice self) internal returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint len;
        uint div = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        var b = word / div;
        if (b < 0x80) {
            ret = b;
            len = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            len = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            len = 3;
        } else {
            ret = b & 0x07;
            len = 4;
        }

        // Check for truncated codepoints
        if (len > self._len) {
            return 0;
        }

        for (uint i = 1; i < len; i++) {
            div = div / 256;
            b = (word / div) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice self) internal returns (bytes32 ret) {
        assembly {
            ret := sha3(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice self, slice needle) internal returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let len := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(sha3(selfptr, len), sha3(needleptr, len))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let len := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, len), sha3(needleptr, len))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice self, slice needle) internal returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        var selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let len := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(sha3(selfptr, len), sha3(needleptr, len))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        var selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let len := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, len), sha3(needleptr, len))
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
                    loop:
                    jumpi(exit, eq(and(mload(ptr), mask), needledata))
                    ptr := add(ptr, 1)
                    jumpi(loop, lt(sub(ptr, 1), end))
                    ptr := add(selfptr, selflen)
                    exit:
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr;
                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                // Optimized assembly for 69 gas per byte on short strings
                assembly {
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata := and(mload(needleptr), mask)
                    ptr := add(selfptr, sub(selflen, needlelen))
                    loop:
                    jumpi(ret, eq(and(mload(ptr), mask), needledata))
                    ptr := sub(ptr, 1)
                    jumpi(loop, gt(add(ptr, 1), selfptr))
                    ptr := selfptr
                    jump(exit)
                    ret:
                    ptr := add(ptr, needlelen)
                    exit:
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice self, slice needle) internal returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice self, slice needle) internal returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
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

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice self, slice needle) internal returns (slice token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice self, slice needle, slice token) internal returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice self, slice needle) internal returns (slice token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice self, slice needle) internal returns (uint count) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            count++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice self, slice needle) internal returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice self, slice other) internal returns (string) {
        var ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice self, slice[] parts) internal returns (string) {
        if (parts.length == 0)
            return "";

        uint len = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            len += parts[i]._len;

        var ret = new string(len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}


/**************************************************************************
 * 
 *	Contract code starts here. 
 * 
 **************************************************************************/

/*

	FlightDelay with Oraclized Underwriting and Payout
	All times are UTC.
	Copyright (C) Christoph Mussenbrock, Stephan Karpischek
	
*/

contract FlightDelay is usingOraclize {

	using strings for *;

	modifier noEther { if (msg.value > 0) throw; _ }
	modifier onlyOwner { if (msg.sender != owner) throw; _ }
	modifier onlyOraclize {	if (msg.sender != oraclize_cbAddress()) throw; _ }

	modifier onlyInState (uint _policyId, policyState _state) {

		policy p = policies[_policyId];
		if (p.state != _state) throw;
		_

	}

	modifier onlyCustomer(uint _policyId) {

		policy p = policies[_policyId];
		if (p.customer != msg.sender) throw;
		_

	}

	modifier notInMaintenance {
		healthCheck();
		if (maintenance_mode >= maintenance_Emergency) throw;
		_
	}

	// the following modifier is always checked at last, so previous modifiers
	// may throw without affecting reentrantGuard
	modifier noReentrant {
		if (reentrantGuard) throw;
		reentrantGuard = true;
		_
		reentrantGuard = false;
	}

	// policy Status Codes and meaning:
	//
	// 00 = Applied:	the customer has payed a premium, but the oracle has
	//					not yet checked and confirmed.
	//					The customer can still revoke the policy.
	// 01 = Accepted:	the oracle has checked and confirmed.
	//					The customer can still revoke the policy.
	// 02 = Revoked:	The customer has revoked the policy.
	//					The premium minus cancellation fee is payed back to the
	//					customer by the oracle.
	// 03 = PaidOut:	The flight has ended with delay.
	//					The oracle has checked and payed out.
	// 04 = Expired:	The flight has endet with <15min. delay.
	//					No payout.
	// 05 = Declined:	The application was invalid.
	//					The premium minus cancellation fee is payed back to the
	//					customer by the oracle.
	// 06 = SendFailed:	During Revoke, Decline or Payout, sending ether failed
	//					for unknown reasons.
	//					The funds remain in the contracts RiskFund.


	//                  00       01        02       03
	enum policyState {Applied, Accepted, Revoked, PaidOut,
	//					04      05           06
					  Expired, Declined, SendFailed}

	// oraclize callback types:
	enum oraclizeState { ForUnderwriting, ForPayout }

	event LOG_PolicyApplied(
		uint policyId,
		address customer,
		string carrierFlightNumber,
		uint premium
	);
	event LOG_PolicyAccepted(
		uint policyId,
		uint statistics0,
		uint statistics1,
		uint statistics2,
		uint statistics3,
		uint statistics4,
		uint statistics5
	);
	event LOG_PolicyRevoked(
		uint policyId
	);
	event LOG_PolicyPaidOut(
		uint policyId,
		uint amount
	);
	event LOG_PolicyExpired(
		uint policyId
	);
	event LOG_PolicyDeclined(
		uint policyId,
		bytes32 reason
	);
	event LOG_PolicyManualPayout(
		uint policyId,
		bytes32 reason
	);
	event LOG_SendFail(
		uint policyId,
		bytes32 reason
	);
	event LOG_OraclizeCall(
		uint policyId,
		bytes32 queryId,
		string oraclize_url
	);
	event LOG_OraclizeCallback(
		uint policyId,
		bytes32 queryId,
		string result,
		bytes proof
	);
	event LOG_HealthCheck(
		bytes32 message, 
		int diff,
		uint balance,
		int ledgerBalance 
	);

	// some general constants for the system:
	// minimum observations for valid prediction
	uint constant minObservations 			= 10;
	// minimum premium to cover costs
	uint constant minPremium 				= 500 finney;
	// maximum premium
	uint constant maxPremium 				= 5 ether;
	// maximum payout
	uint constant maxPayout 				= 150 ether;
	// maximum cumulated weighted premium per risk
	uint maxCumulatedWeightedPremium		= 300 ether; 
	// 1 percent for DAO, 1 percent for maintainer
	uint8 constant rewardPercent 			= 2;
	// reserve for tail risks
	uint8 constant reservePercent 			= 1;
	// the weight pattern; in future versions this may become part of the policy struct.
	// currently can't be constant because of compiler restrictions
	// weightPattern[0] is not used, just to be consistent
    uint8[6] weightPattern 					= [0, 10,20,30,50,50];
	// Deadline for acceptance of policies: Mon, 26 Sep 2016 12:00:00 GMT
	uint contractDeadline 					= 1474891200; 

	// account numbers for the internal ledger:
	// sum of all Premiums of all currently active policies
	uint8 constant acc_Premium 				= 0;
	// Risk fund; serves as reserve for tail risks
	uint8 constant acc_RiskFund 			= 1;
	// sum of all payed out policies
	uint8 constant acc_Payout 				= 2;
	// the balance of the contract (negative!!)
	uint8 constant acc_Balance 				= 3;
	// the reward account for DAO and maintainer
	uint8 constant acc_Reward 				= 4;
	// oraclize costs
	uint8 constant acc_OraclizeCosts 		= 5;
	// when adding more accounts, remember to increase ledger array length

	// Maintenance modes 
	uint8 constant maintenance_None      	= 0;
	uint8 constant maintenance_BalTooHigh 	= 1;
	uint8 constant maintenance_Emergency 	= 255;
	
	
	// gas Constants for oraclize
	uint constant oraclizeGas 				= 500000;

	// URLs and query strings for oraclize

	string constant oraclize_RatingsBaseUrl =
		"[URL] json(https://api.flightstats.com/flex/ratings/rest/v1/json/flight/";
	string constant oraclizeRatingsQuery =
		"?${[decrypt] BN0pJDw6e65XSHqRe1zGji/QU9y5NgK9eTda3VmITxeRgncyGQewbTE+46EFY/waH5KXoHWSb0d/Wpwm1rE5SVeA5SvXrSZCKHw13krbK8D/F/RqL9/VoAx8fGJnYsWQ1q2G5lZbiY9sd6sKhozb/epq4GpcHpdjNf111/pJTwHttxsrUno/}).ratings[0]['observations','late15','late30','late45','cancelled','diverted']";

	// [URL] json(https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/LH/410/dep/2016/09/01?appId={appId}&appKey={appKey})
	string constant oraclize_StatusBaseUrl =
	  "[URL] json(https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/";
	string constant oraclizeStatusQuery =
		"?${[decrypt] BN0pJDw6e65XSHqRe1zGji/QU9y5NgK9eTda3VmITxeRgncyGQewbTE+46EFY/waH5KXoHWSb0d/Wpwm1rE5SVeA5SvXrSZCKHw13krbK8D/F/RqL9/VoAx8fGJnYsWQ1q2G5lZbiY9sd6sKhozb/epq4GpcHpdjNf111/pJTwHttxsrUno/}&utc=true).flightStatuses[0]['status','delays','operationalTimes']";


	// the policy structure: this structure keeps track of the individual parameters of a policy.
	// typically customer address, premium and some status information.

	struct policy {

		// 0 - the customer
		address customer;
		// 1 - premium
		uint premium;

		// risk specific parameters:
		// 2 - pointer to the risk in the risks mapping
		bytes32 riskId;
		// custom payout pattern
		// in future versions, customer will be able to tamper with this array.
		// to keep things simple, we have decided to hard-code the array for all policies.
		// uint8[5] pattern;
		// 3 - probability weight. this is the central parameter
		uint weight;
		// 4 - calculated Payout
		uint calculatedPayout;
		// 5 - actual Payout
		uint actualPayout;

		// status fields:
		// 6 - the state of the policy
		policyState state;
		// 7 - time of last state change
		uint stateTime;
		// 8 - state change message/reason
		bytes32 stateMessage;
		// 9 - TLSNotary Proof
		bytes proof;
	}

	// the risk structure; this structure keeps track of the risk-
	// specific parameters.
	// several policies can share the same risk structure (typically 
	// some people flying with the same plane)

	struct risk {

		// 0 - Airline Code + FlightNumber
		string carrierFlightNumber;
		// 1 - scheduled departure and arrival time in the format /dep/YYYY/MM/DD
		string departureYearMonthDay;
		// 2 - the inital arrival time
		uint arrivalTime;
		// 3 - the final delay in minutes
		uint delayInMinutes;
		// 4 - the determined delay category (0-5)
		uint8 delay;
		// 5 - we limit the cumulated weighted premium to avoid cluster risks
		uint cumulatedWeightedPremium;
		// 6 - max cumulated Payout for this risk
		uint premiumMultiplier;
	}

	// the oraclize callback structure: we use several oraclize calls.
	// all oraclize calls will result in a common callback to __callback(...).
	// to keep track of the different querys we have to introduce this struct.

	struct oraclizeCallback {

		// for which policy have we called?
		uint policyId;
		// for which purpose did we call? {ForUnderwrite | ForPayout}
		oraclizeState oState;
		uint oraclizeTime;

	}

	address public owner;

	// Table of policies
	policy[] public policies;
	// Lookup policyIds from customer addresses
	mapping (address => uint[]) public customerPolicies;
	// Lookup policy Ids from queryIds
	mapping (bytes32 => oraclizeCallback) public oraclizeCallbacks;
	mapping (bytes32 => risk) public risks;
	// Internal ledger
	int[6] public ledger;

	// invariant: acc_Premium + acc_RiskFund + acc_Payout
	//						+ acc_Balance + acc_Reward == 0

	// Mutex
	bool public reentrantGuard;
	uint8 public maintenance_mode;

	function healthCheck() internal {
		int diff = int(this.balance-msg.value) + ledger[acc_Balance];
		if (diff == 0) {
			return; // everything ok.
		}
		if (diff > 0) {
			LOG_HealthCheck('Balance too high', diff, this.balance, ledger[acc_Balance]);
			maintenance_mode = maintenance_BalTooHigh;
		} else {
			LOG_HealthCheck('Balance too low', diff, this.balance, ledger[acc_Balance]);
			maintenance_mode = maintenance_Emergency;
		}
	}

	// manually perform healthcheck.
	// @param _maintenance_mode: 
	// 		0 = reset maintenance_mode, even in emergency
	// 		1 = perform health check
	//    255 = set maintenance_mode to maintenance_emergency (no newPolicy anymore)
	function performHealthCheck(uint8 _maintenance_mode) onlyOwner {
		maintenance_mode = _maintenance_mode;
		if (maintenance_mode > 0 && maintenance_mode < maintenance_Emergency) {
			healthCheck();
		}
	}

	function payReward() onlyOwner {

		if (!owner.send(this.balance)) throw;
		maintenance_mode = maintenance_Emergency; // don't accept any policies

	}

	function bookkeeping(uint8 _from, uint8 _to, uint _amount) internal {

		ledger[_from] -= int(_amount);
		ledger[_to] += int(_amount);

	}

	// if ledger gets corrupt for unknown reasons, have a way to correct it:
	function audit(uint8 _from, uint8 _to, uint _amount) onlyOwner {

		bookkeeping (_from, _to, _amount);

	}

	function getPolicyCount(address _customer)
		constant returns (uint _count) {
		return policies.length;
	}

	function getCustomerPolicyCount(address _customer)
		constant returns (uint _count) {
		return customerPolicies[_customer].length;
	}

	function bookAndCalcRemainingPremium() internal returns (uint) {

		uint v = msg.value;
		uint reserve = v * reservePercent / 100;
		uint remain = v - reserve;
		uint reward = remain * rewardPercent / 100;

		bookkeeping(acc_Balance, acc_Premium, v);
		bookkeeping(acc_Premium, acc_RiskFund, reserve);
		bookkeeping(acc_Premium, acc_Reward, reward);

		return (uint(remain - reward));

	}

	// constructor
	function FlightDelay (address _owner) {

		owner = _owner;
		reentrantGuard = false;
		maintenance_mode = maintenance_None;

		// initially put all funds in risk fund.
		bookkeeping(acc_Balance, acc_RiskFund, msg.value);
		oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);

	}

	// fix issue with _departureYMD
    function toYMD (uint departure) returns (string) {
        uint diff = (departure - 1472601600) / 86400;
        uint8 d1 = uint8(diff / 10);
        uint8 d2 = uint8(diff - 10*d1);
        string memory str = '/dep/2016/09/xx';
        bytes memory strb = bytes(str);
        strb[13] = bytes1(d1+48);
        strb[14] = bytes1(d2+48);
		return(string(strb));
    }


	// create new policy
	function newPolicy(
		string _carrierFlightNumber, 
		string _departureYearMonthDay, 
		uint _departureTime, 
		uint _arrivalTime
		) 
		notInMaintenance {

		_departureYearMonthDay = toYMD(_departureTime);
		// sanity checks:

		// don't accept too low or too high policies

		if (msg.value < minPremium || msg.value > maxPremium) {
			LOG_PolicyDeclined(0, 'Invalid premium value');
			if (!msg.sender.send(msg.value)) {
				LOG_SendFail(0, 'newPolicy sendback failed (1)');
			}
			return;
		}

        // don't accept flights with departure time earlier than in 24 hours, 
		// or arrivalTime before departureTime, 
		// or departureTime after Mon, 26 Sep 2016 12:00:00 GMT
        if (
			_arrivalTime < _departureTime ||
			_arrivalTime > _departureTime + 2 days ||
			_departureTime < now + 24 hours ||
			_departureTime > contractDeadline) {
			LOG_PolicyDeclined(0, 'Invalid arrival/departure time');
			if (!msg.sender.send(msg.value)) {
				LOG_SendFail(0, 'newPolicy sendback failed (2)');
			}
			return;
        }
		
		// accept only a number of maxIdenticalRisks identical risks:
		
		bytes32 riskId = sha3(
			_carrierFlightNumber, 
			_departureYearMonthDay, 
			_arrivalTime
		);
		risk r = risks[riskId];
	
		// roughly check, whether maxCumulatedWeightedPremium will be exceeded
		// (we accept the inaccuracy that the real remaining premium is 3% lower), 
		// but we are conservative;
		// if this is the first policy, the left side will be 0
		if (msg.value * r.premiumMultiplier + r.cumulatedWeightedPremium >= 
			maxCumulatedWeightedPremium) {
			LOG_PolicyDeclined(0, 'Cluster risk');
			if (!msg.sender.send(msg.value)) {
				LOG_SendFail(0, 'newPolicy sendback failed (3)');
			}
			return;
		} else if (r.cumulatedWeightedPremium == 0) {
			// at the first police, we set r.cumulatedWeightedPremium to the max.
			// this prevents further polices to be accepted, until the correct
			// value is calculated after the first callback from the oracle.
			r.cumulatedWeightedPremium = maxCumulatedWeightedPremium;
		}

		// store or update policy
		uint policyId = policies.length++;
		customerPolicies[msg.sender].push(policyId);
		policy p = policies[policyId];

		p.customer = msg.sender;
		// the remaining premium after deducting reserve and reward
		p.premium = bookAndCalcRemainingPremium();
		p.riskId = riskId;

		// store risk parameters
		// Airline Code
		if (r.premiumMultiplier == 0) { // then it is the first call.
			// we have a new struct
			r.carrierFlightNumber = _carrierFlightNumber;
			r.departureYearMonthDay = _departureYearMonthDay;
			r.arrivalTime = _arrivalTime;
		} else { // we cumulate the risk
			r.cumulatedWeightedPremium += p.premium * r.premiumMultiplier;
		}

		// now we have successfully applied
		p.state = policyState.Applied;
		p.stateMessage = 'Policy applied by customer';
		p.stateTime = now;
		LOG_PolicyApplied(policyId, msg.sender, _carrierFlightNumber, p.premium);

		// call oraclize to get Flight Stats; this will also call underwrite()
		getFlightStats(policyId, _carrierFlightNumber);
	}
	
	function underwrite(uint _policyId, uint[6] _statistics, bytes _proof) internal {

		policy p = policies[_policyId]; // throws if _policyId invalid
		uint weight;
		for (uint8 i = 1; i <= 5; i++ ) {
			weight += weightPattern[i] * _statistics[i];
			// 1% = 100 / 100% = 10,000
		}
		// to avoid div0 in the payout section, 
		// we have to make a minimal assumption on p.weight.
		if (weight == 0) { weight = 100000 / _statistics[0]; }

		risk r = risks[p.riskId];
		// we calculate the factors to limit cluster risks.
		if (r.premiumMultiplier == 0) { 
			// it's the first call, we accept any premium
			r.premiumMultiplier = 100000 / weight;
			r.cumulatedWeightedPremium = p.premium * 100000 / weight;
		}
		
		p.proof = _proof;
		p.weight = weight;

		// schedule payout Oracle
		schedulePayoutOraclizeCall(
			_policyId, 
			r.carrierFlightNumber, 
			r.departureYearMonthDay, 
			r.arrivalTime + 15 minutes
		);

		p.state = policyState.Accepted;
		p.stateMessage = 'Policy underwritten by oracle';
		p.stateTime = now;

		LOG_PolicyAccepted(
			_policyId, 
			_statistics[0], 
			_statistics[1], 
			_statistics[2], 
			_statistics[3], 
			_statistics[4],
			_statistics[5]
		);

	}
	
	function decline(uint _policyId, bytes32 _reason, bytes _proof)	internal {

		policy p = policies[_policyId];

		p.state = policyState.Declined;
		p.stateMessage = _reason;
		p.stateTime = now; // won't be reverted in case of errors
		p.proof = _proof;
		bookkeeping(acc_Premium, acc_Balance, p.premium);

		if (!p.customer.send(p.premium))  {
			bookkeeping(acc_Balance, acc_RiskFund, p.premium);
			p.state = policyState.SendFailed;
			p.stateMessage = 'decline: Send failed.';
			LOG_SendFail(_policyId, 'decline sendfail');
		}
		else {
			LOG_PolicyDeclined(_policyId, _reason);
		}


	}
	
	function schedulePayoutOraclizeCall(
		uint _policyId, 
		string _carrierFlightNumber, 
		string _departureYearMonthDay, 
		uint _oraclizeTime) 
		internal {

		string memory oraclize_url = strConcat(
			oraclize_StatusBaseUrl,
			_carrierFlightNumber,
			_departureYearMonthDay,
			oraclizeStatusQuery
			);

		bytes32 queryId = oraclize_query(_oraclizeTime, 'nested', oraclize_url, oraclizeGas);
		bookkeeping(acc_OraclizeCosts, acc_Balance, uint((-ledger[acc_Balance]) - int(this.balance)));
		oraclizeCallbacks[queryId] = oraclizeCallback(_policyId, oraclizeState.ForPayout, _oraclizeTime);

		LOG_OraclizeCall(_policyId, queryId, oraclize_url);
	}

	function payOut(uint _policyId, uint8 _delay, uint _delayInMinutes)
		notInMaintenance
		onlyOraclize
		onlyInState(_policyId, policyState.Accepted)
		internal {

		policy p = policies[_policyId];
		risk r = risks[p.riskId];
		r.delay = _delay;
		r.delayInMinutes = _delayInMinutes;
		
		if (_delay == 0) {
			p.state = policyState.Expired;
			p.stateMessage = 'Expired - no delay!';
			p.stateTime = now;
			LOG_PolicyExpired(_policyId);
		} else {

			uint payout = p.premium * weightPattern[_delay] * 10000 / p.weight;
			p.calculatedPayout = payout;

			if (payout > maxPayout) {
				payout = maxPayout;
			}

			if (payout > uint(-ledger[acc_Balance])) { // don't go for chapter 11
				payout = uint(-ledger[acc_Balance]);
			}

			p.actualPayout = payout;
			bookkeeping(acc_Payout, acc_Balance, payout);      // cash out payout


			if (!p.customer.send(payout))  {
				bookkeeping(acc_Balance, acc_Payout, payout);
				p.state = policyState.SendFailed;
				p.stateMessage = 'Payout, send failed!';
				p.actualPayout = 0;
				LOG_SendFail(_policyId, 'payout sendfail');
			}
			else {
				p.state = policyState.PaidOut;
				p.stateMessage = 'Payout successful!';
				p.stateTime = now; // won't be reverted in case of errors
				LOG_PolicyPaidOut(_policyId, payout);
			}
		}

	}

	// fallback function: don't accept ether, except from owner
	function () onlyOwner {

		// put additional funds in risk fund.
		bookkeeping(acc_Balance, acc_RiskFund, msg.value);

	}

	// internal, so no reentrant guard neccessary
	function getFlightStats(
		uint _policyId,
		string _carrierFlightNumber)
		internal {

		// call oraclize and retrieve the number of observations from flightstats API
		// format https://api.flightstats.com/flex/ratings/rest/v1/json/flight/OS/75?appId=**&appKey=**

		// using nested data sources (query type nested) and partial
		// encrypted queries in the next release of oraclize
		// note that the first call maps the encrypted string to the
		// sending contract address, this string can't be used from any other sender
		string memory oraclize_url = strConcat(
			oraclize_RatingsBaseUrl,
			_carrierFlightNumber,
			oraclizeRatingsQuery
			);

		bytes32 queryId = oraclize_query("nested", oraclize_url, oraclizeGas);
		// calculate the spent gas
		bookkeeping(acc_OraclizeCosts, acc_Balance, uint((-ledger[acc_Balance]) - int(this.balance)));
		oraclizeCallbacks[queryId] = oraclizeCallback(_policyId, oraclizeState.ForUnderwriting, 0);

		LOG_OraclizeCall(_policyId, queryId, oraclize_url);

	}

	// this is a dispatcher, but must be called __callback
	function __callback(bytes32 _queryId, string _result, bytes _proof) 
		onlyOraclize 
		noReentrant {

		oraclizeCallback o = oraclizeCallbacks[_queryId];
		LOG_OraclizeCallback(o.policyId, _queryId, _result, _proof);
		
		if (o.oState == oraclizeState.ForUnderwriting) {
            callback_ForUnderwriting(o.policyId, _result, _proof);
		}
        else {
            callback_ForPayout(_queryId, _result, _proof);
        }
	}

	function callback_ForUnderwriting(uint _policyId, string _result, bytes _proof) 
		onlyInState(_policyId, policyState.Applied)
		internal {

		var sl_result = _result.toSlice(); 		
		risk r = risks[policies[_policyId].riskId];

		// we expect result to contain 6 values, something like
		// "[61, 10, 4, 3, 0, 0]" ->
		// ['observations','late15','late30','late45','cancelled','diverted']

		if (bytes(_result).length == 0) {
			decline(_policyId, 'Declined (empty result)', _proof);
		} else {

			// now slice the string using
			// https://github.com/Arachnid/solidity-stringutils

			if (sl_result.count(', '.toSlice()) != 5) { 
				// check if result contains 6 values
				decline(_policyId, 'Declined (invalid result)', _proof);
			} else {
				sl_result.beyond("[".toSlice()).until("]".toSlice());

				uint observations = parseInt(
					sl_result.split(', '.toSlice()).toString());

				// decline on < minObservations observations,
				// can't calculate reasonable probabibilities
				if (observations <= minObservations) {
					decline(_policyId, 'Declined (too few observations)', _proof);
				} else {
					uint[6] memory statistics;
					// calculate statistics (scaled by 10000; 1% => 100)
					statistics[0] = observations;
					for(uint i = 1; i <= 5; i++) {
						statistics[i] =
							parseInt(
								sl_result.split(', '.toSlice()).toString()) 
								* 10000/observations;
					}

					// underwrite policy
					underwrite(_policyId, statistics, _proof);
				}
			}
		}
	} 

	function callback_ForPayout(bytes32 _queryId, string _result, bytes _proof) internal {

		oraclizeCallback o = oraclizeCallbacks[_queryId];
		uint policyId = o.policyId;
		var sl_result = _result.toSlice(); 		
		risk r = risks[policies[policyId].riskId];

		if (bytes(_result).length == 0) {
			if (o.oraclizeTime > r.arrivalTime + 180 minutes) {
				LOG_PolicyManualPayout(policyId, 'No Callback at +120 min');
				return;
			} else {
				schedulePayoutOraclizeCall(
					policyId, 
					r.carrierFlightNumber, 
					r.departureYearMonthDay, 
					o.oraclizeTime + 45 minutes
				);
			}
		} else {
						
			// first check status

			// extract the status field:
			sl_result.find('"'.toSlice()).beyond('"'.toSlice());
			sl_result.until(sl_result.copy().find('"'.toSlice()));
			bytes1 status = bytes(sl_result.toString())[0];	// s = L
			
			if (status == 'C') {
				// flight cancelled --> payout
				payOut(policyId, 4, 0);
				return;
			} else if (status == 'D') {
				// flight diverted --> payout					
				payOut(policyId, 5, 0);
				return;
			} else if (status != 'L' && status != 'A' && status != 'C' && status != 'D') {
				LOG_PolicyManualPayout(policyId, 'Unprocessable status');
				return;
			}
			
			// process the rest of the response:
			sl_result = _result.toSlice();
			bool arrived = sl_result.contains('actualGateArrival'.toSlice());

			if (status == 'A' || (status == 'L' && !arrived)) {
				// flight still active or not at gate --> reschedule
				if (o.oraclizeTime > r.arrivalTime + 180 minutes) {
					LOG_PolicyManualPayout(policyId, 'No arrival at +120 min');
				} else {
					schedulePayoutOraclizeCall(
						policyId, 
						r.carrierFlightNumber, 
						r.departureYearMonthDay, 
						o.oraclizeTime + 45 minutes
					);
				}
			} else if (status == 'L' && arrived) {
				var aG = '"arrivalGateDelayMinutes": '.toSlice();
				if (sl_result.contains(aG)) {
					sl_result.find(aG).beyond(aG);
					sl_result.until(sl_result.copy().find('"'.toSlice())
						.beyond('"'.toSlice()));
					sl_result.until(sl_result.copy().find('}'.toSlice()));
					sl_result.until(sl_result.copy().find(','.toSlice()));
					uint delayInMinutes = parseInt(sl_result.toString());
				} else {
					delayInMinutes = 0;
				}
				
				if (delayInMinutes < 15) {
					payOut(policyId, 0, 0);
				} else if (delayInMinutes < 30) {
					payOut(policyId, 1, delayInMinutes);
				} else if (delayInMinutes < 45) {
					payOut(policyId, 2, delayInMinutes);
				} else {
					payOut(policyId, 3, delayInMinutes);
				}
			} else { // no delay info
				payOut(policyId, 0, 0);
			}
		} 
	}
}




/* EOF */