pragma solidity >=0.4.0 <0.6.0;

contract Coin {
    function getOwner(uint index) public view returns (address, uint256);
    function getOwnerCount() public view returns (uint);
}

contract Caller {
    event console(address addr, uint256 amount);
    function f() public {
        Coin c = Coin(0x003FfEFeFBC4a6F34a62A3cA7b7937a880065BCB);
        for (uint256 i = 0; i < c.getOwnerCount(); i++) {
            address addr;
            uint256 amount;
                (addr, amount)  = c.getOwner(i);
                 emit console(addr, amount);
        }
    }
}