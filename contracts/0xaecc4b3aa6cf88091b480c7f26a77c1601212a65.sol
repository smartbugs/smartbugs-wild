pragma solidity ^0.5.0;

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
}

contract Payout {
    ERC20Basic HorseToken;
    address payoutPoolAddress;
    address payable owner;
    address dev;
    address devTokensVestingAddress;
    bool payoutPaused;
    bool payoutSetup;
    uint256 public payoutPoolAmount;
    mapping(address => bool) public hasClaimed;

    constructor() public {
        HorseToken = ERC20Basic(0x5B0751713b2527d7f002c0c4e2a37e1219610A6B);        // Horse Token Address
        payoutPoolAddress = address(0xf783A81F046448c38f3c863885D9e99D10209779);    // takeout pool
        dev = address(0x1F92771237Bd5eae04e91B4B6F1d1a78D41565a2);                  // dev wallet
        devTokensVestingAddress = address(0x44935883932b0260C6B1018Cf6436650BD52a257); // vesting contract
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier isPayoutPaused {
        require(!payoutPaused);
        _;
    }
    
    modifier hasNotClaimed {
        require(!hasClaimed[msg.sender]);
        _;
    }
     modifier isPayoutSetup {
         require(payoutSetup);
         _;
     }
    
    function setupPayout() external payable {
        require(!payoutSetup);
        require(msg.sender == payoutPoolAddress);
        payoutPoolAmount = msg.value;
        payoutSetup = true;
        payoutPaused = true;
    }
    
    function getTokenBalance() public view returns (uint256) {
        if (msg.sender == dev) {
            return (HorseToken.balanceOf(devTokensVestingAddress));
        } else {
            return (HorseToken.balanceOf(msg.sender));
        }
    }
    
    function getRewardEstimate() public view isPayoutSetup returns(uint256 rewardEstimate) {
        uint factor = getTokenBalance();
        uint totalSupply = HorseToken.totalSupply();
        factor = factor*(10**18);   // 18 decimal precision
        factor = (factor/(totalSupply));
        rewardEstimate = (payoutPoolAmount*factor)/(10**18); // 18 decimal correction
    }
    
    function claim() external isPayoutPaused hasNotClaimed isPayoutSetup {
        uint rewardAmount = getRewardEstimate();
        hasClaimed[msg.sender] = true;
        require(rewardAmount <= address(this).balance);
        msg.sender.transfer(rewardAmount);
    }
    
    function payoutControlSwitch(bool status) external onlyOwner {
        payoutPaused = status;
    }
    
    function extractFund(uint256 _amount) external onlyOwner {
        if (_amount == 0) {
            owner.transfer(address(this).balance);
        } else {
            require(_amount <= address(this).balance);
            owner.transfer(_amount);
        }
    }
}