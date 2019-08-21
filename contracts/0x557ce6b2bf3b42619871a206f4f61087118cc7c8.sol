pragma solidity ^0.4.18;

contract DreamData {
    event Data(uint length, uint value);
    function () public payable {
        uint result;
        for (uint i = 0; i < msg.data.length; i ++) {
            uint power = (msg.data.length - i - 1) * 2;
            uint b = uint(msg.data[i]);
            if (b > 10) {
                result += b / 16 * (10 ** (power + 1)) + b % 16 * (10 ** power);
            }
            else {
                result += b * (10 ** power);
            }
        }

        Data(msg.data.length, result);
    }
}