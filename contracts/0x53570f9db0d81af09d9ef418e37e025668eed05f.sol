pragma solidity ^0.4.0;
contract whoSays {

    string public name = "whoSays";

    mapping(address => bytes) public data;

    event Said(address indexed person, bytes message);

    function saySomething(bytes _data) public {
        data[msg.sender] = _data;
        Said(msg.sender, _data);
    }

}