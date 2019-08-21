pragma solidity >=0.4.0 <0.6.0;

contract SeeYouAtEthcon2020 {
    address public winner;
    uint256 public timeLock;
    
    constructor() public {
        timeLock = uint256(0) - 1;
    }
    
    function () payable external {
        require(msg.value >= 0.1 ether);
        timeLock = now + 6 hours;
        winner = msg.sender;
    }
    
    function claim() public {
        require(msg.sender == winner);
        require(now >= timeLock);
        msg.sender.transfer(address(this).balance);
    }
}