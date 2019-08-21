pragma solidity ^0.4.9;

contract Originstamp {

    address public owner;

    event Submitted(bytes32 indexed pHash);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Originstamp() public {
	owner = msg.sender;
    }

    function submitHash(bytes32 pHash) public onlyOwner() {
        Submitted(pHash);
    }
}