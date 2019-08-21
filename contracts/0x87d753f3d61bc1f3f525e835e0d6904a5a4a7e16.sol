pragma solidity ^0.4.16;

contract test
{
    event AAA(address indexed sender, uint x);
    
    function aaa(bytes data) public
    {
        uint x = _bytesToUint(data);
        AAA(msg.sender, x);
    }
    
    function _bytesToUint(bytes data) internal view returns (uint) {
        uint num = 0;
        for(uint i = 0; i < data.length; i++) {
            num += uint(data[i]);
            if(i != data.length - 1)
                num *= 256;
        }
        return num;
    }
}