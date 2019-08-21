pragma solidity ^0.4.18;

contract TokenRate {
    uint public USDValue;
    uint public EURValue;
    uint public GBPValue;
    uint public BTCValue;
    address public owner = msg.sender;

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    function setValues(uint USD, uint EUR, uint GBP, uint BTC) ownerOnly public {
        USDValue = USD;
        EURValue = EUR;
        GBPValue = GBP;
        BTCValue = BTC;
    }
}