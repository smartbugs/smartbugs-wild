pragma solidity ^0.4.8;


/**
* @title RLPReader
*
* RLPReader is used to read and parse RLP encoded data in memory.
*
* @author Andreas Olofsson (androlo1980@gmail.com)
*/
library RLP {

 uint constant DATA_SHORT_START = 0x80;
 uint constant DATA_LONG_START = 0xB8;
 uint constant LIST_SHORT_START = 0xC0;
 uint constant LIST_LONG_START = 0xF8;

 uint constant DATA_LONG_OFFSET = 0xB7;
 uint constant LIST_LONG_OFFSET = 0xF7;


 struct RLPItem {
     uint _unsafe_memPtr;    // Pointer to the RLP-encoded bytes.
     uint _unsafe_length;    // Number of bytes. This is the full length of the string.
 }

 struct Iterator {
     RLPItem _unsafe_item;   // Item that's being iterated over.
     uint _unsafe_nextPtr;   // Position of the next item in the list.
 }

 /* Iterator */

 function next(Iterator memory self) internal constant returns (RLPItem memory subItem) {
     if(hasNext(self)) {
         var ptr = self._unsafe_nextPtr;
         var itemLength = _itemLength(ptr);
         subItem._unsafe_memPtr = ptr;
         subItem._unsafe_length = itemLength;
         self._unsafe_nextPtr = ptr + itemLength;
     }
     else
         throw;
 }

 function next(Iterator memory self, bool strict) internal constant returns (RLPItem memory subItem) {
     subItem = next(self);
     if(strict && !_validate(subItem))
         throw;
     return;
 }

 function hasNext(Iterator memory self) internal constant returns (bool) {
     var item = self._unsafe_item;
     return self._unsafe_nextPtr < item._unsafe_memPtr + item._unsafe_length;
 }

 /* RLPItem */

 /// @dev Creates an RLPItem from an array of RLP encoded bytes.
 /// @param self The RLP encoded bytes.
 /// @return An RLPItem
 function toRLPItem(bytes memory self) internal constant returns (RLPItem memory) {
     uint len = self.length;
     if (len == 0) {
         return RLPItem(0, 0);
     }
     uint memPtr;
     assembly {
         memPtr := add(self, 0x20)
     }
     return RLPItem(memPtr, len);
 }

 /// @dev Creates an RLPItem from an array of RLP encoded bytes.
 /// @param self The RLP encoded bytes.
 /// @param strict Will throw if the data is not RLP encoded.
 /// @return An RLPItem
 function toRLPItem(bytes memory self, bool strict) internal constant returns (RLPItem memory) {
     var item = toRLPItem(self);
     if(strict) {
         uint len = self.length;
         if(_payloadOffset(item) > len)
             throw;
         if(_itemLength(item._unsafe_memPtr) != len)
             throw;
         if(!_validate(item))
             throw;
     }
     return item;
 }

 /// @dev Check if the RLP item is null.
 /// @param self The RLP item.
 /// @return 'true' if the item is null.
 function isNull(RLPItem memory self) internal constant returns (bool ret) {
     return self._unsafe_length == 0;
 }

 /// @dev Check if the RLP item is a list.
 /// @param self The RLP item.
 /// @return 'true' if the item is a list.
 function isList(RLPItem memory self) internal constant returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))
     }
 }

 /// @dev Check if the RLP item is data.
 /// @param self The RLP item.
 /// @return 'true' if the item is data.
 function isData(RLPItem memory self) internal constant returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := lt(byte(0, mload(memPtr)), 0xC0)
     }
 }

 /// @dev Check if the RLP item is empty (string or list).
 /// @param self The RLP item.
 /// @return 'true' if the item is null.
 function isEmpty(RLPItem memory self) internal constant returns (bool ret) {
     if(isNull(self))
         return false;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     return (b0 == DATA_SHORT_START || b0 == LIST_SHORT_START);
 }

 /// @dev Get the number of items in an RLP encoded list.
 /// @param self The RLP item.
 /// @return The number of items.
 function items(RLPItem memory self) internal constant returns (uint) {
     if (!isList(self))
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     uint pos = memPtr + _payloadOffset(self);
     uint last = memPtr + self._unsafe_length - 1;
     uint itms;
     while(pos <= last) {
         pos += _itemLength(pos);
         itms++;
     }
     return itms;
 }

 /// @dev Create an iterator.
 /// @param self The RLP item.
 /// @return An 'Iterator' over the item.
 function iterator(RLPItem memory self) internal constant returns (Iterator memory it) {
     if (!isList(self))
         throw;
     uint ptr = self._unsafe_memPtr + _payloadOffset(self);
     it._unsafe_item = self;
     it._unsafe_nextPtr = ptr;
 }

 /// @dev Return the RLP encoded bytes.
 /// @param self The RLPItem.
 /// @return The bytes.
 function toBytes(RLPItem memory self) internal constant returns (bytes memory bts) {
     var len = self._unsafe_length;
     if (len == 0)
         return;
     bts = new bytes(len);
     _copyToBytes(self._unsafe_memPtr, bts, len);
 }

 /// @dev Decode an RLPItem into bytes. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toData(RLPItem memory self) internal constant returns (bytes memory bts) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
 }

 /// @dev Get the list of sub-items from an RLP encoded list.
 /// Warning: This is inefficient, as it requires that the list is read twice.
 /// @param self The RLP item.
 /// @return Array of RLPItems.
 function toList(RLPItem memory self) internal constant returns (RLPItem[] memory list) {
     if(!isList(self))
         throw;
     var numItems = items(self);
     list = new RLPItem[](numItems);
     var it = iterator(self);
     uint idx;
     while(hasNext(it)) {
         list[idx] = next(it);
         idx++;
     }
 }

 /// @dev Decode an RLPItem into an ascii string. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toAscii(RLPItem memory self) internal constant returns (string memory str) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     bytes memory bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
     str = string(bts);
 }

 /// @dev Decode an RLPItem into a uint. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toUint(RLPItem memory self) internal constant returns (uint data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len > 32 || len == 0)
         throw;
     assembly {
         data := div(mload(rStartPos), exp(256, sub(32, len)))
     }
 }

 /// @dev Decode an RLPItem into a boolean. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toBool(RLPItem memory self) internal constant returns (bool data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         throw;
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     if (temp > 1)
         throw;
     return temp == 1 ? true : false;
 }

 /// @dev Decode an RLPItem into a byte. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toByte(RLPItem memory self) internal constant returns (byte data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         throw;
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     return byte(temp);
 }

 /// @dev Decode an RLPItem into an int. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toInt(RLPItem memory self) internal constant returns (int data) {
     return int(toUint(self));
 }

 /// @dev Decode an RLPItem into a bytes32. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toBytes32(RLPItem memory self) internal constant returns (bytes32 data) {
     return bytes32(toUint(self));
 }

 /// @dev Decode an RLPItem into an address. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toAddress(RLPItem memory self) internal constant returns (address data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 20)
         throw;
     assembly {
         data := div(mload(rStartPos), exp(256, 12))
     }
 }

 // Get the payload offset.
 function _payloadOffset(RLPItem memory self) private constant returns (uint) {
     if(self._unsafe_length == 0)
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if(b0 < DATA_SHORT_START)
         return 0;
     if(b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START))
         return 1;
     if(b0 < LIST_SHORT_START)
         return b0 - DATA_LONG_OFFSET + 1;
     return b0 - LIST_LONG_OFFSET + 1;
 }

 // Get the full length of an RLP item.
 function _itemLength(uint memPtr) private constant returns (uint len) {
     uint b0;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if (b0 < DATA_SHORT_START)
         len = 1;
     else if (b0 < DATA_LONG_START)
         len = b0 - DATA_SHORT_START + 1;
     else if (b0 < LIST_SHORT_START) {
         assembly {
             let bLen := sub(b0, 0xB7) // bytes length (DATA_LONG_OFFSET)
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
             len := add(1, add(bLen, dLen)) // total length
         }
     }
     else if (b0 < LIST_LONG_START)
         len = b0 - LIST_SHORT_START + 1;
     else {
         assembly {
             let bLen := sub(b0, 0xF7) // bytes length (LIST_LONG_OFFSET)
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
             len := add(1, add(bLen, dLen)) // total length
         }
     }
 }

 // Get start position and length of the data.
 function _decode(RLPItem memory self) private constant returns (uint memPtr, uint len) {
     if(!isData(self))
         throw;
     uint b0;
     uint start = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(start))
     }
     if (b0 < DATA_SHORT_START) {
         memPtr = start;
         len = 1;
         return;
     }
     if (b0 < DATA_LONG_START) {
         len = self._unsafe_length - 1;
         memPtr = start + 1;
     } else {
         uint bLen;
         assembly {
             bLen := sub(b0, 0xB7) // DATA_LONG_OFFSET
         }
         len = self._unsafe_length - 1 - bLen;
         memPtr = start + bLen + 1;
     }
     return;
 }

 // Assumes that enough memory has been allocated to store in target.
 function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen) private constant {
     // Exploiting the fact that 'tgt' was the last thing to be allocated,
     // we can write entire words, and just overwrite any excess.
     assembly {
         {
                 let i := 0 // Start at arr + 0x20
                 let words := div(add(btsLen, 31), 32)
                 let rOffset := btsPtr
                 let wOffset := add(tgt, 0x20)
             tag_loop:
                 jumpi(end, eq(i, words))
                 {
                     let offset := mul(i, 0x20)
                     mstore(add(wOffset, offset), mload(add(rOffset, offset)))
                     i := add(i, 1)
                 }
                 jump(tag_loop)
             end:
                 mstore(add(tgt, add(0x20, mload(tgt))), 0)
         }
     }
 }

     // Check that an RLP item is valid.
     function _validate(RLPItem memory self) private constant returns (bool ret) {
         // Check that RLP is well-formed.
         uint b0;
         uint b1;
         uint memPtr = self._unsafe_memPtr;
         assembly {
             b0 := byte(0, mload(memPtr))
             b1 := byte(1, mload(memPtr))
         }
         if(b0 == DATA_SHORT_START + 1 && b1 < DATA_SHORT_START)
             return false;
         return true;
     }
}


contract RLPReaderTest {

    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;

    function RLPReaderTest() {}

    function testItemStrict(bytes rlp) constant returns (bool res) {
        res = true;
        rlp.toRLPItem(true);
    }

    function testFirst(bytes rlp) constant returns (uint memPtr, uint len, byte first) {
        var item = rlp.toRLPItem();
        memPtr = item._unsafe_memPtr;
        len = item._unsafe_length;
        uint b0;
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        first = byte(b0);
    }

    function testIsList(bytes rlp) constant returns (bool ret) {
        ret = rlp.toRLPItem().isList();
    }

    function testIsData(bytes rlp) constant returns (bool ret) {
        ret = rlp.toRLPItem().isData();
    }

    function testIsNull(bytes rlp) constant returns (bool ret) {
        ret = rlp.toRLPItem().isNull();
    }

    function testIsEmpty(bytes rlp) constant returns (bool ret) {
        ret = rlp.toRLPItem().isEmpty();
    }

    function testItems(bytes rlp) constant returns (uint) {
        return rlp.toRLPItem().items();
    }

    function testSubItem(bytes rlp, uint index) constant returns (uint memPtr, uint len, bool isList, uint[] list, uint listLen) {
        var it = rlp.toRLPItem().iterator();
        uint idx;
        while(it.hasNext() && idx < index) {
            it.next();
            idx++;
        }
       var si = it.next();
       return _testItem(si);
    }

    function testToData(bytes rlp) constant returns (bytes memory bts) {
        bts = rlp.toRLPItem().toData();
    }

    function testToUint(bytes rlp) constant returns (uint) {
        return rlp.toRLPItem().toUint();
    }

    function testToInt(bytes rlp) constant returns (int) {
        return rlp.toRLPItem().toInt();
    }

    function testToBytes32(bytes rlp) constant returns (bytes32) {
        return rlp.toRLPItem().toBytes32();
    }

    function testToAddress(bytes rlp) constant returns (address) {
        return rlp.toRLPItem().toAddress();
    }

    function testToByte(bytes rlp) constant returns (byte) {
        return rlp.toRLPItem().toByte();
    }

    function testToBool(bytes rlp) constant returns (bool) {
        return rlp.toRLPItem().toBool();
    }

    function _testItem(RLP.RLPItem item) internal constant returns (uint memPtr, uint len, bool isList, uint[] memory list, uint listLen) {
        memPtr = item._unsafe_memPtr;
        len = item._unsafe_length;
        isList = item.isList();

        if (isList) {
            uint i;
            listLen = item.items();
            list = new uint[](listLen);
            var it = item.iterator();
            while(it.hasNext() && i < listLen) {
                var si = it.next();
                uint ptr;
                assembly {
                    ptr := mload(si)
                }
                list[i] = ptr;
                i++;
            }
        }
    }
    
    function testItem(bytes rlp) constant returns (uint memPtr, uint len, bool isList, uint[] list, uint listLen) {
        var item = rlp.toRLPItem();
        return _testItem(item);
    }
    
    function getItem(bytes rlp, uint itemIndex) constant returns(uint) {
        var it = rlp.toRLPItem().iterator();        
        uint idx;
        while(it.hasNext() && idx < itemIndex) {
            it.next();                    
            idx++;
        }

        
        return it.next().toUint();
    }
    
}


    


contract SHA3_512 {
    function SHA3_512() {}

    function keccak_f(uint[25] A) constant internal returns(uint[25]) {
        uint[5] memory C;
        uint[5] memory D;
        uint x;
        uint y;
        //uint D_0; uint D_1; uint D_2; uint D_3; uint D_4;
        uint[25] memory B;
        
        uint[24] memory RC= [
                   uint(0x0000000000000001),
                   0x0000000000008082,
                   0x800000000000808A,
                   0x8000000080008000,
                   0x000000000000808B,
                   0x0000000080000001,
                   0x8000000080008081,
                   0x8000000000008009,
                   0x000000000000008A,
                   0x0000000000000088,
                   0x0000000080008009,
                   0x000000008000000A,
                   0x000000008000808B,
                   0x800000000000008B,
                   0x8000000000008089,
                   0x8000000000008003,
                   0x8000000000008002,
                   0x8000000000000080,
                   0x000000000000800A,
                   0x800000008000000A,
                   0x8000000080008081,
                   0x8000000000008080,
                   0x0000000080000001,
                   0x8000000080008008 ];
        
        for( uint i = 0 ; i < 24 ; i++ ) {
            /*
            for( x = 0 ; x < 5 ; x++ ) {
                C[x] = A[5*x]^A[5*x+1]^A[5*x+2]^A[5*x+3]^A[5*x+4];                
            }*/
                       
            C[0]=A[0]^A[1]^A[2]^A[3]^A[4];
            C[1]=A[5]^A[6]^A[7]^A[8]^A[9];
            C[2]=A[10]^A[11]^A[12]^A[13]^A[14];
            C[3]=A[15]^A[16]^A[17]^A[18]^A[19];
            C[4]=A[20]^A[21]^A[22]^A[23]^A[24];

            /*
            for( x = 0 ; x < 5 ; x++ ) {
                D[x] = C[(x+4)%5]^((C[(x+1)%5] * 2)&0xffffffffffffffff | (C[(x+1)%5]/(2**63)));
            }*/
                        
            
            D[0]=C[4] ^ ((C[1] * 2)&0xffffffffffffffff | (C[1] / (2 ** 63)));
            D[1]=C[0] ^ ((C[2] * 2)&0xffffffffffffffff | (C[2] / (2 ** 63)));
            D[2]=C[1] ^ ((C[3] * 2)&0xffffffffffffffff | (C[3] / (2 ** 63)));
            D[3]=C[2] ^ ((C[4] * 2)&0xffffffffffffffff | (C[4] / (2 ** 63)));
            D[4]=C[3] ^ ((C[0] * 2)&0xffffffffffffffff | (C[0] / (2 ** 63)));

            /*
            for( x = 0 ; x < 5 ; x++ ) {
                for( y = 0 ; y < 5 ; y++ ) {
                    A[5*x+y] = A[5*x+y] ^ D[x];
                }            
            }*/
            

            
            A[0]=A[0] ^ D[0];
            A[1]=A[1] ^ D[0];
            A[2]=A[2] ^ D[0];
            A[3]=A[3] ^ D[0];
            A[4]=A[4] ^ D[0];
            A[5]=A[5] ^ D[1];
            A[6]=A[6] ^ D[1];
            A[7]=A[7] ^ D[1];
            A[8]=A[8] ^ D[1];
            A[9]=A[9] ^ D[1];
            A[10]=A[10] ^ D[2];
            A[11]=A[11] ^ D[2];
            A[12]=A[12] ^ D[2];
            A[13]=A[13] ^ D[2];
            A[14]=A[14] ^ D[2];
            A[15]=A[15] ^ D[3];
            A[16]=A[16] ^ D[3];
            A[17]=A[17] ^ D[3];
            A[18]=A[18] ^ D[3];
            A[19]=A[19] ^ D[3];
            A[20]=A[20] ^ D[4];
            A[21]=A[21] ^ D[4];
            A[22]=A[22] ^ D[4];
            A[23]=A[23] ^ D[4];
            A[24]=A[24] ^ D[4];

            /*Rho and pi steps*/            
            B[0]=A[0];
            B[8]=((A[1] * (2 ** 36))&0xffffffffffffffff | (A[1] / (2 ** 28)));
            B[11]=((A[2] * (2 ** 3))&0xffffffffffffffff | (A[2] / (2 ** 61)));
            B[19]=((A[3] * (2 ** 41))&0xffffffffffffffff | (A[3] / (2 ** 23)));
            B[22]=((A[4] * (2 ** 18))&0xffffffffffffffff | (A[4] / (2 ** 46)));
            B[2]=((A[5] * (2 ** 1))&0xffffffffffffffff | (A[5] / (2 ** 63)));
            B[5]=((A[6] * (2 ** 44))&0xffffffffffffffff | (A[6] / (2 ** 20)));
            B[13]=((A[7] * (2 ** 10))&0xffffffffffffffff | (A[7] / (2 ** 54)));
            B[16]=((A[8] * (2 ** 45))&0xffffffffffffffff | (A[8] / (2 ** 19)));
            B[24]=((A[9] * (2 ** 2))&0xffffffffffffffff | (A[9] / (2 ** 62)));
            B[4]=((A[10] * (2 ** 62))&0xffffffffffffffff | (A[10] / (2 ** 2)));
            B[7]=((A[11] * (2 ** 6))&0xffffffffffffffff | (A[11] / (2 ** 58)));
            B[10]=((A[12] * (2 ** 43))&0xffffffffffffffff | (A[12] / (2 ** 21)));
            B[18]=((A[13] * (2 ** 15))&0xffffffffffffffff | (A[13] / (2 ** 49)));
            B[21]=((A[14] * (2 ** 61))&0xffffffffffffffff | (A[14] / (2 ** 3)));
            B[1]=((A[15] * (2 ** 28))&0xffffffffffffffff | (A[15] / (2 ** 36)));
            B[9]=((A[16] * (2 ** 55))&0xffffffffffffffff | (A[16] / (2 ** 9)));
            B[12]=((A[17] * (2 ** 25))&0xffffffffffffffff | (A[17] / (2 ** 39)));
            B[15]=((A[18] * (2 ** 21))&0xffffffffffffffff | (A[18] / (2 ** 43)));
            B[23]=((A[19] * (2 ** 56))&0xffffffffffffffff | (A[19] / (2 ** 8)));
            B[3]=((A[20] * (2 ** 27))&0xffffffffffffffff | (A[20] / (2 ** 37)));
            B[6]=((A[21] * (2 ** 20))&0xffffffffffffffff | (A[21] / (2 ** 44)));
            B[14]=((A[22] * (2 ** 39))&0xffffffffffffffff | (A[22] / (2 ** 25)));
            B[17]=((A[23] * (2 ** 8))&0xffffffffffffffff | (A[23] / (2 ** 56)));
            B[20]=((A[24] * (2 ** 14))&0xffffffffffffffff | (A[24] / (2 ** 50)));

            /*Xi state*/
            /*
            for( x = 0 ; x < 5 ; x++ ) {
                for( y = 0 ; y < 5 ; y++ ) {
                    A[5*x+y] = B[5*x+y]^((~B[5*((x+1)%5)+y]) & B[5*((x+2)%5)+y]);
                }
            }*/
            
            
            A[0]=B[0]^((~B[5]) & B[10]);
            A[1]=B[1]^((~B[6]) & B[11]);
            A[2]=B[2]^((~B[7]) & B[12]);
            A[3]=B[3]^((~B[8]) & B[13]);
            A[4]=B[4]^((~B[9]) & B[14]);
            A[5]=B[5]^((~B[10]) & B[15]);
            A[6]=B[6]^((~B[11]) & B[16]);
            A[7]=B[7]^((~B[12]) & B[17]);
            A[8]=B[8]^((~B[13]) & B[18]);
            A[9]=B[9]^((~B[14]) & B[19]);
            A[10]=B[10]^((~B[15]) & B[20]);
            A[11]=B[11]^((~B[16]) & B[21]);
            A[12]=B[12]^((~B[17]) & B[22]);
            A[13]=B[13]^((~B[18]) & B[23]);
            A[14]=B[14]^((~B[19]) & B[24]);
            A[15]=B[15]^((~B[20]) & B[0]);
            A[16]=B[16]^((~B[21]) & B[1]);
            A[17]=B[17]^((~B[22]) & B[2]);
            A[18]=B[18]^((~B[23]) & B[3]);
            A[19]=B[19]^((~B[24]) & B[4]);
            A[20]=B[20]^((~B[0]) & B[5]);
            A[21]=B[21]^((~B[1]) & B[6]);
            A[22]=B[22]^((~B[2]) & B[7]);
            A[23]=B[23]^((~B[3]) & B[8]);
            A[24]=B[24]^((~B[4]) & B[9]);

            /*Last step*/
            A[0]=A[0]^RC[i];            
        }

        
        return A;
    }
 
    
    function sponge(uint[9] M) constant internal returns(uint[16]) {
        if( (M.length * 8) != 72 ) throw;
        M[5] = 0x01;
        M[8] = 0x8000000000000000;
        
        uint r = 72;
        uint w = 8;
        uint size = M.length * 8;
        
        uint[25] memory S;
        uint i; uint y; uint x;
        /*Absorbing Phase*/
        for( i = 0 ; i < size/r ; i++ ) {
            for( y = 0 ; y < 5 ; y++ ) {
                for( x = 0 ; x < 5 ; x++ ) {
                    if( (x+5*y) < (r/w) ) {
                        S[5*x+y] = S[5*x+y] ^ M[i*9 + x + 5*y];
                    }
                }
            }
            S = keccak_f(S);
        }

        /*Squeezing phase*/
        uint[16] memory result;
        uint b = 0;
        while( b < 16 ) {
            for( y = 0 ; y < 5 ; y++ ) {
                for( x = 0 ; x < 5 ; x++ ) {
                    if( (x+5*y)<(r/w) && (b<16) ) {
                        result[b] = S[5*x+y] & 0xFFFFFFFF; 
                        result[b+1] = S[5*x+y] / 0x100000000;
                        b+=2;
                    }
                }
            }
        }
         
        return result;
   }

}

////////////////////////////////////////////////////////////////////////////////

contract Ethash is SHA3_512 {
    
    address public owner;    
    
    struct EthashCacheData {
        uint128 merkleRoot;
        uint64  fullSizeIn128Resultion;
        uint64  branchDepth;
    }
    
    mapping(uint=>EthashCacheData) epochData;    
    
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;
 
    struct BlockHeader {
        uint       prevBlockHash; // 0
        uint       coinbase;      // 1
        uint       blockNumber;   // 8
        uint       timestamp;     // 11
        bytes32    extraData;     // 12
    }
    
    function Ethash() {
        owner = msg.sender;
    }
           
    function setEpochData( uint128 merkleRoot, uint64 fullSizeIn128Resultion, uint64 branchDepth, uint epoch ) {
        EthashCacheData memory data;
        data.merkleRoot = merkleRoot;
        data.fullSizeIn128Resultion = fullSizeIn128Resultion;
        data.branchDepth = branchDepth;
        
        epochData[epoch] = data;        
    }    
      
    function parseBlockHeader( bytes rlpHeader ) constant internal returns(BlockHeader) {
        BlockHeader memory header;
        
        var it = rlpHeader.toRLPItem().iterator();        
        uint idx;
        while(it.hasNext()) {
            if( idx == 0 ) header.prevBlockHash = it.next().toUint();
            else if ( idx == 2 ) header.coinbase = it.next().toUint();
            else if ( idx == 8 ) header.blockNumber = it.next().toUint();
            else if ( idx == 11 ) header.timestamp = it.next().toUint();
            else if ( idx == 12 ) header.extraData = bytes32(it.next().toUint());
            else it.next();
            
            idx++;
        }
 
        return header;        
    }
        
     
    function fnv( uint v1, uint v2 ) constant internal returns(uint) {
        return ((v1*0x01000193) ^ v2) & 0xFFFFFFFF;
    }



    function computeCacheRoot( uint index,
                               uint indexInElementsArray,
                               uint[] elements,
                               uint[] witness,
                               uint branchSize ) constant private returns(uint) {
 
                       
        uint leaf = computeLeaf(elements, indexInElementsArray) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        uint left;
        uint right;
        uint node;
        bool oddBranchSize = (branchSize % 2) > 0;
         
        assembly {
            branchSize := div(branchSize,2)
            //branchSize /= 2;
        }
        uint witnessIndex = indexInElementsArray * branchSize;
        if( oddBranchSize ) witnessIndex += indexInElementsArray;  

        for( uint depth = 0 ; depth < branchSize ; depth++ ) {
            assembly {
                node := mload(add(add(witness,0x20),mul(add(depth,witnessIndex),0x20)))
            }
            //node  = witness[witnessIndex + depth] & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if( index & 0x1 == 0 ) {
                left = leaf;
                assembly{
                    //right = node & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;                
                    right := and(node,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                }
                
            }
            else {
                assembly{
                    //left = node & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    left := and(node,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                }
                right = leaf;
            }
            
            leaf = uint(sha3(left,right)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            assembly {
                index := div(index,2) 
            }
            //index = index / 2;

            //node  = witness[witnessIndex + depth] / (2**128);
            if( index & 0x1 == 0 ) {
                left = leaf;
                assembly{
                    right := div(node,0x100000000000000000000000000000000)
                    //right = node / 0x100000000000000000000000000000000;
                }
            }
            else {
                assembly {
                    //left = node / 0x100000000000000000000000000000000;
                    left := div(node,0x100000000000000000000000000000000)
                }
                right = leaf;
            }
            
            leaf = uint(sha3(left,right)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            assembly {
                index := div(index,2) 
            }
            //index = index / 2;
        }
        
        if( oddBranchSize ) {
            assembly {
                node := mload(add(add(witness,0x20),mul(add(depth,witnessIndex),0x20)))
            }
        
            //node  = witness[witnessIndex + depth] & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if( index & 0x1 == 0 ) {
                left = leaf;
                assembly{
                    //right = node & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;                
                    right := and(node,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                }                
            }
            else {
                assembly{
                    //left = node & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;                
                    left := and(node,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                }
            
                right = leaf;
            }
            
            leaf = uint(sha3(left,right)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;        
        }
        
        
        return leaf;
    }

    
    function toBE( uint x ) constant internal returns(uint) {
        uint y = 0;
        for( uint i = 0 ; i < 32 ; i++ ) {
            y = y * 256;
            y += (x & 0xFF);
            x = x / 256;            
        }
        
        return y;
        
    }
    
    function computeSha3( uint[16] s, uint[8] cmix ) constant internal returns(uint) {
        uint s0 = s[0] + s[1] * (2**32) + s[2] * (2**64) + s[3] * (2**96) +
                  (s[4] + s[5] * (2**32) + s[6] * (2**64) + s[7] * (2**96))*(2**128);

        uint s1 = s[8] + s[9] * (2**32) + s[10] * (2**64) + s[11] * (2**96) +
                  (s[12] + s[13] * (2**32) + s[14] * (2**64) + s[15] * (2**96))*(2**128);
                  
        uint c = cmix[0] + cmix[1] * (2**32) + cmix[2] * (2**64) + cmix[3] * (2**96) +
                  (cmix[4] + cmix[5] * (2**32) + cmix[6] * (2**64) + cmix[7] * (2**96))*(2**128);

        
        /* god knows why need to convert to big endian */
        return uint( sha3(toBE(s0),toBE(s1),toBE(c)) );
    }
 
 
    function computeLeaf( uint[] dataSetLookup, uint index ) constant internal returns(uint) {
        return uint( sha3(dataSetLookup[4*index],
                          dataSetLookup[4*index + 1],
                          dataSetLookup[4*index + 2],
                          dataSetLookup[4*index + 3]) );
                                    
    }
 
    function computeS( uint header, uint nonceLe ) constant internal returns(uint[16]) {
        uint[9]  memory M;
        
        header = reverseBytes(header);
        
        M[0] = uint(header) & 0xFFFFFFFFFFFFFFFF;
        header = header / 2**64;
        M[1] = uint(header) & 0xFFFFFFFFFFFFFFFF;
        header = header / 2**64;
        M[2] = uint(header) & 0xFFFFFFFFFFFFFFFF;
        header = header / 2**64;
        M[3] = uint(header) & 0xFFFFFFFFFFFFFFFF;

        // make little endian nonce
        M[4] = nonceLe;
        return sponge(M);
    }
    
    function reverseBytes( uint input ) constant internal returns(uint) {
        uint result = 0;
        for(uint i = 0 ; i < 32 ; i++ ) {
            result = result * 256;
            result += input & 0xff;
            
            input /= 256;
        }
        
        return result;
    }
    
    function hashimoto( bytes32 header,
                        bytes8 nonceLe,
                        uint fullSizeIn128Resultion,
                        uint[] dataSetLookup,
                        uint[] witnessForLookup,
                        uint   branchSize,
                        uint   root ) constant returns(uint) {
         
        uint[16] memory s;
        uint[32] memory mix;
        uint[8]  memory cmix;
                
        uint i;
        uint j;
        

        
        s = computeS(uint(header), uint(nonceLe));
        for( i = 0 ; i < 16 ; i++ ) {            
            assembly {
                let offset := mul(i,0x20)
                
                //mix[i] = s[i];
                mstore(add(mix,offset),mload(add(s,offset)))
                
                // mix[i+16] = s[i];
                mstore(add(mix,add(0x200,offset)),mload(add(s,offset)))    
            }
        }
        
        for( i = 0 ; i < 64 ; i++ ) {
            uint p = fnv( i ^ s[0], mix[i % 32]) % fullSizeIn128Resultion;
            if( computeCacheRoot( p, i, dataSetLookup,  witnessForLookup, branchSize )  != root ) {
                // PoW failed
                return 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            }        

            for( j = 0 ; j < 8 ; j++ ) {

                assembly{
                    //mix[j] = fnv(mix[j], dataSetLookup[4*i] & varFFFFFFFF );
                    let dataOffset := add(mul(0x80,i),add(dataSetLookup,0x20))
                    let dataValue   := and(mload(dataOffset),0xFFFFFFFF)
                    
                    let mixOffset := add(mix,mul(0x20,j))
                    let mixValue  := mload(mixOffset)
                    
                    // fnv = return ((v1*0x01000193) ^ v2) & 0xFFFFFFFF;
                    let fnvValue := and(xor(mul(mixValue,0x01000193),dataValue),0xFFFFFFFF)                    
                    mstore(mixOffset,fnvValue)
                    
                    //mix[j+8] = fnv(mix[j+8], dataSetLookup[4*i + 1] & 0xFFFFFFFF );
                    dataOffset := add(dataOffset,0x20)
                    dataValue   := and(mload(dataOffset),0xFFFFFFFF)
                    
                    mixOffset := add(mixOffset,0x100)
                    mixValue  := mload(mixOffset)
                    
                    // fnv = return ((v1*0x01000193) ^ v2) & 0xFFFFFFFF;
                    let fnvValue := and(xor(mul(mixValue,0x01000193),dataValue),0xFFFFFFFF)                    
                    mstore(mixOffset,fnvValue)

                    //mix[j+16] = fnv(mix[j+16], dataSetLookup[4*i + 2] & 0xFFFFFFFF );
                    dataOffset := add(dataOffset,0x20)
                    dataValue   := and(mload(dataOffset),0xFFFFFFFF)
                    
                    mixOffset := add(mixOffset,0x100)
                    mixValue  := mload(mixOffset)
                    
                    // fnv = return ((v1*0x01000193) ^ v2) & 0xFFFFFFFF;
                    let fnvValue := and(xor(mul(mixValue,0x01000193),dataValue),0xFFFFFFFF)                    
                    mstore(mixOffset,fnvValue)

                    //mix[j+24] = fnv(mix[j+24], dataSetLookup[4*i + 3] & 0xFFFFFFFF );
                    dataOffset := add(dataOffset,0x20)
                    dataValue   := and(mload(dataOffset),0xFFFFFFFF)
                    
                    mixOffset := add(mixOffset,0x100)
                    mixValue  := mload(mixOffset)
                    
                    // fnv = return ((v1*0x01000193) ^ v2) & 0xFFFFFFFF;
                    let fnvValue := and(xor(mul(mixValue,0x01000193),dataValue),0xFFFFFFFF)                    
                    mstore(mixOffset,fnvValue)                    
                                        
                }

                
                //mix[j] = fnv(mix[j], dataSetLookup[4*i] & 0xFFFFFFFF );
                //mix[j+8] = fnv(mix[j+8], dataSetLookup[4*i + 1] & 0xFFFFFFFF );
                //mix[j+16] = fnv(mix[j+16], dataSetLookup[4*i + 2] & 0xFFFFFFFF );                
                //mix[j+24] = fnv(mix[j+24], dataSetLookup[4*i + 3] & 0xFFFFFFFF );
                
                
                //dataSetLookup[4*i    ] = dataSetLookup[4*i    ]/(2**32);
                //dataSetLookup[4*i + 1] = dataSetLookup[4*i + 1]/(2**32);
                //dataSetLookup[4*i + 2] = dataSetLookup[4*i + 2]/(2**32);
                //dataSetLookup[4*i + 3] = dataSetLookup[4*i + 3]/(2**32);                
                
                assembly{
                    let offset := add(add(dataSetLookup,0x20),mul(i,0x80))
                    let value  := div(mload(offset),0x100000000)
                    mstore(offset,value)
                                       
                    offset := add(offset,0x20)
                    value  := div(mload(offset),0x100000000)
                    mstore(offset,value)
                    
                    offset := add(offset,0x20)
                    value  := div(mload(offset),0x100000000)
                    mstore(offset,value)                    
                    
                    offset := add(offset,0x20)
                    value  := div(mload(offset),0x100000000)
                    mstore(offset,value)                                                                                
                }                
            }
        }
        
        
        for( i = 0 ; i < 32 ; i += 4) {
            cmix[i/4] = (fnv(fnv(fnv(mix[i], mix[i+1]), mix[i+2]), mix[i+3]));
        }
        

        uint result = computeSha3(s,cmix); 
        return result;        
    }    

    event EthashValue( uint value );
        
    function verifyHash( bytes rlpHeader,
                          uint  nonce,
                          uint[] dataSetLookup,
                          uint[] witnessForLookup ) constant returns(uint) {
                          
        BlockHeader memory header = parseBlockHeader(rlpHeader);        
        
        uint leafHash = uint(sha3(rlpHeader));                          
        
        // get epoch data
        EthashCacheData memory eData = epochData[header.blockNumber / 30000];
        
        // verify ethash
        uint ethash = hashimoto( bytes32(leafHash),
                                 bytes8(nonce),
                                 eData.fullSizeIn128Resultion,
                                 dataSetLookup,
                                 witnessForLookup,                                 
                                 eData.branchDepth,
                                 eData.merkleRoot );
                                 
        EthashValue( ethash );
        
        return ethash;
    }             
}