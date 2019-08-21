contract check {
    function add(address _add, uint _req) {
        _add.callcode(bytes4(keccak256("changeRequirement(uint256)")), _req);
    }
}