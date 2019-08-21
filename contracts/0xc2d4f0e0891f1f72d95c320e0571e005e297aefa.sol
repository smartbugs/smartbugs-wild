pragma solidity ^0.5.0;

contract FloatingInSolidity {
    
    address payable public Owner;
    
    constructor() public {
        Owner = msg.sender;
    }
    
    modifier hasEth() {
        require(msg.value >= 0.1 ether);
        _;
    }

    function letsBet() public payable hasEth {
        uint one = 1;
        if((one / 2) > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }
    
    function letsBetAgain(uint dividend, uint divisor) public payable hasEth {
        require(dividend < divisor);
        if((dividend / divisor) > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }
    
   function withdraw() payable public {
        require(msg.sender == Owner);
        Owner.transfer(address(this).balance);
    }
    
    function amount() public view returns (uint) {
        return address(this).balance;
    }
    
    function() external payable {}

}