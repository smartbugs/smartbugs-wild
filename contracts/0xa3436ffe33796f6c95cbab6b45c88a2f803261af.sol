pragma solidity ^0.4.18;

contract corrently_iot {
    
	  mapping (address => uint256) public value;
      event Value(address indexed thing, uint256 value);
      
      function setValue(uint256 _value) public {
          value[msg.sender] = _value;
          emit Value(msg.sender,_value);
      }
}