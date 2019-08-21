pragma solidity ^0.4.18;

contract PixelStorageWithFee {
    event PixelUpdate(uint32 indexed index, uint8 color);
    byte[500000] public packedBytes;
    uint256 feeWei;
    address masterAddress;

    function PixelStorageWithFee(uint256 startingFeeWei) public {
        masterAddress = msg.sender;
        feeWei = startingFeeWei;
    }

    // Pixels are represented using 4-bits.  We pack 2 pixels into one byte like so:
    // [left_pixel|right_pixel]
    // To set these bytes, we use bitwise operations to change either the upper or
    // lower half of a packed byte.
    // [index] is the index of the pixel; not the byte
    // [color] is a 4-bit integer; the upper 4 bits of the uint8 are discarded.

    function set(uint32 index, uint8 color) public payable {
        require(index < 1000000);
        require(msg.value >= feeWei);

        uint32 packedByteIndex = index / 2;
        byte currentByte = packedBytes[packedByteIndex];
        bool left = index % 2 == 0;

        byte newByte;
        if (left) {
            // clear upper 4 bits of existing byte
            // OR with new byte shifted left 4 bits
            newByte = (currentByte & hex'0f') | bytes1(color * 2 ** 4);
        } else {
            // clear lower 4 bits of existing byte
            // OR with with new color, with upper 4 bits cleared
            newByte = (currentByte & hex'f0') | (bytes1(color) & hex'0f');
        }

        packedBytes[packedByteIndex] = newByte;
        PixelUpdate(index, color);
    }

    function getAll() public constant returns (byte[500000]) {
        return packedBytes;
    }

    modifier masterOnly() {
        require(msg.sender == masterAddress);
        _;
    }

    function setFee(uint256 fee) public masterOnly {
        feeWei = fee;
    }

    function withdraw() public masterOnly {
        masterAddress.transfer(this.balance);
    }

    function() public payable { }
}