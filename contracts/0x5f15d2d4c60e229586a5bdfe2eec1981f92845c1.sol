pragma solidity ^0.4.25;  

contract GetsBurned {

    function () public payable {
    }

    function BurnMe () {
        selfdestruct(address(this));
    }
}