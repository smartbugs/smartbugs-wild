pragma solidity ^0.4.16;

contract TokenBurner {
    address private _burner;

    function TokenBurner() public {
        _burner = msg.sender;
    }

    function () payable public {
    }

    function BurnMe () public {
        // Only let ourselves be able to burn
        if (msg.sender == _burner) {
            // Selfdestruct and send tokens to self, to burn them 
            selfdestruct(address(this));
        }
        
    }
}