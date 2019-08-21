pragma solidity ^0.4.25;

interface ReportEmitter {
    event Report(address indexed sender,
                 uint256 indexed tag,
                 uint256 indexed target,
                 uint256 value);
}

contract Crier is ReportEmitter {
    function report(uint256 o, bytes32 t) public payable {emit Report(msg.sender,uint256(t),o,msg.value);}
    function report(uint256 o, bytes t) public payable {report(o,keccak256(abi.encodePacked(t)));}
    function report(uint256 o, string t) public payable {report(o,keccak256(abi.encodePacked(t)));}
    
    function report(address o, bytes32 t) public payable {report(uint256(o),t);}
    function report(address o, bytes t) public payable {report(o,keccak256(abi.encodePacked(t)));}
    function report(address o, string t) public payable {report(o,keccak256(abi.encodePacked(t)));}

    function report(bytes o, bytes32 t) public payable {report(uint256(keccak256(abi.encodePacked(o))),t);}
    function report(bytes o, bytes t) public payable {report(uint256(keccak256(abi.encodePacked(o))),t);}
    function report(bytes o, string t) public payable {report(uint256(keccak256(abi.encodePacked(o))),t);}
}