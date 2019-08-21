pragma solidity 0.4.24;
contract CoinbaseTest {
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function () public payable {
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
    }

}