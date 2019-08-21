pragma solidity >=0.4.22 <0.6.0;
contract EventThrower {
    event SomethingHappened (
       string nonIndexedString,
       string indexed indexedString,
       uint nonIndexedInt,
       uint indexed indexedInt,
       bool nonIndexedBool,
       address nonIndexedAddress,
       address indexed indexedAddress
    );
    
     function throwEvent(string memory _nonIndexedString, string memory _indexedString, uint _nonIndexedInt, uint _indexedInt, bool _nonIndexedBool, address _nonIndexedAddress, address _indexedAddress) public {
       emit SomethingHappened(_nonIndexedString, _indexedString, _nonIndexedInt, _indexedInt, _nonIndexedBool, _nonIndexedAddress, _indexedAddress);
    }
}