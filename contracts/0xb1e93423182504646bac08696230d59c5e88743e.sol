pragma solidity ^0.4.0;
contract Test {
    
    uint[] array = [1,5];
    address to = 0x1b60840cBaFBe74DB4B9C7Dd7F1d0822fA9b9591;

    function send() public{
        if (to.call(0xc66ddd68, array)) {
            return;
        } else {
            revert();
        }
    }
}