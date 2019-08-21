pragma solidity ^0.4.17;

contract WayneAndMichelle {
    string constant public congratulationFromNoel = "祝 Wayne 跟 Michelle 幸福健康快樂";
    
    function WayneAndMichelle () payable public {}
    
    function OpenRedEnvelope (string input) public {
        require(keccak256(input) == 0x5fd066216edd28dc49b0ee93e344e346a36b44b00bdf44713b98b566758f9758);
        msg.sender.transfer(this.balance);
    }
    
    function hashTest(string input) pure returns (bytes32) {
        return keccak256(input);
    }
}