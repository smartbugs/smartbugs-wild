pragma solidity 0.4.26;

contract Burner {
    function() external {}
    
    function selfDestruct() external {
        selfdestruct(address(this));
    }
}