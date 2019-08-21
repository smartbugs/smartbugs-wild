pragma solidity ^0.4.24;

/*
* ETHERLIFE INTERNATIONAL ETH CRYPTOCURRENCY DISTRIBUTION PROJECT
* Web:               https://etherlife.io
* Telegram_channel:  https://t.me/etherlife
* EN  Telegram_chat: https://t.me/etherlife_eng
* RU  Telegram_chat: https://t.me/EtherLife_rus
* Email:             support@etherlife.io
* 
* 
*  - GAIN 4% - 0,5% per 24 HOURS
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution 0.1 eth
*  - Currency and payment - ETH only
*  - Contribution allocation schemes:
*       - 89% payments;
*       - 4% marketing;
*       - 7% technical support & dev.
*
* HOW TO USE:
*  1. Send from ETH wallet to the smart contract address 0x29BeF3878B85522Ef2AFA541dD7477c9e0a2c122 any amount from 0.1 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
*     of your wallet.
*  3a. Claim your profit by sending 0 ether transaction.
*  OR
*  3b. For reinvest, you need to deposit the amount that you want to reinvest and the 
*      accrued interest automatically summed to your new contribution.
*
* RECOMMEND
* GAS LIMIT: 200000
* GAS PRICE: https://ethgasstation.info/
* 
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet. 
*
* AFFILIATE PROGRAM:
* 1 LEVEL - 2 %
* 2 LEVEL - 1 %
* 3 LEVEL - 0.5 %
* 4 LEVEL - 0.25 %
* 5 LEVEL - 0.25 %
*
* ATTENTION!
* It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 
* have private keys.
*
* Contracts reviewed and approved by octopus.
*/


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EtherLife
{   
    using SafeMath for uint;
    address public owner;
    
    struct deposit {
        uint time;
        uint value;
        uint timeOfLastWithdraw;
    }
    
    mapping(address => deposit) public deposits;
    mapping(address => address) public parents;
    address[] public investors;
    
    uint public constant minDepositSum = 100 finney; // 0.1 ether;
    
    event Deposit(address indexed from, uint256 value, uint256 startTime);
    event Withdraw(address indexed from, uint256 value);
    event ReferrerBonus(address indexed from, address indexed to, uint8 level, uint256 value);
    
    constructor () public 
    {
        owner = msg.sender;
    }
    
    modifier checkSender() 
    {
        require(msg.sender != address(0));
        _;
    }
    
    function bytesToAddress(bytes source) internal pure returns(address parsedAddress) 
    {
        assembly {
            parsedAddress := mload(add(source,0x14))
        }
        return parsedAddress;
    }

    function () checkSender public payable 
    {
        if(msg.value == 0)
        {
            withdraw();
            return;
        }
        
        require(msg.value >= minDepositSum);
        
        uint bonus = checkReferrer(msg.sender, msg.value);
        
        payFee(msg.value);
        addDeposit(msg.sender, msg.value, bonus);
        
        payRewards(msg.sender, msg.value);
    }
    
    function getInvestorsLength() public view returns (uint)
    {
        return investors.length;
    }
    
    function getParents(address investorAddress) public view returns (address[])
    {
        address[] memory refLevels = new address[](5);
        address current = investorAddress;
        
        for(uint8 i = 0; i < 5; i++)
        {
             current = parents[current];
             if(current == address(0)) break;
             refLevels[i] = current;
        }
        
        return refLevels;
    }
    
    function calculateRewardForLevel(uint8 level, uint value) public pure returns (uint)
    {
        if(level == 1) return value.div(50);           // 2%
        if(level == 2) return value.div(100);          // 1%
        if(level == 3) return value.div(200);          // 0.5%
        if(level == 4) return value.div(400);          // 0.25%
        if(level == 5) return value.div(400);          // 0.25%
        
        return 0;
    }
    
    function calculateWithdrawalSumForPeriod(uint period, uint depositValue, uint duration) public pure returns (uint)
    {
        if(period == 1) return depositValue * 4 / 100 * duration / 1 days;          // 4%
        else if(period == 2) return depositValue * 3 / 100 * duration / 1 days;     // 3%
        else if(period == 3) return depositValue * 2 / 100 * duration / 1 days;     // 2%
        else if(period == 4) return depositValue / 100 * duration / 1 days;         // 1%
        else if(period == 5) return depositValue / 200 * duration / 1 days;         // 0.5%
        return 0;
    }
    
    function calculateWithdrawalSum(uint currentTime, uint depositTime, uint depositValue, uint timeOfLastWithdraw) public pure returns (uint)
    {
        uint startTime = 0;
        uint endTime = 0;
        uint sum = 0;
        int duration = 0;
        
        uint timeEndOfPeriod = 0;
        uint timeEndOfPrevPeriod = 0;
        
        for(uint i = 1; i <= 5; i++)
        {
            timeEndOfPeriod = depositTime.add(i.mul(30 days));
            
            if(i == 1)
            {
                startTime = timeOfLastWithdraw;
                endTime = currentTime > timeEndOfPeriod ? timeEndOfPeriod : currentTime;
            }
            else if(i == 5) 
            {
                timeEndOfPrevPeriod = timeEndOfPeriod.sub(30 days);
                startTime = timeOfLastWithdraw > timeEndOfPrevPeriod ? timeOfLastWithdraw : timeEndOfPrevPeriod;
                endTime = currentTime;
            }
            else
            {
                timeEndOfPrevPeriod = timeEndOfPeriod.sub(30 days);
                startTime = timeOfLastWithdraw > timeEndOfPrevPeriod ? timeOfLastWithdraw : timeEndOfPrevPeriod;
                endTime = currentTime > timeEndOfPeriod ? timeEndOfPeriod : currentTime;    
            }
            
            duration = int(endTime - startTime);
            if(duration >= 0)
            {
                sum = sum.add(calculateWithdrawalSumForPeriod(i, depositValue, uint(duration)));
                timeOfLastWithdraw = endTime;
            }
        }
        
        return sum;
    }
    
    function checkReferrer(address investorAddress, uint weiAmount) internal returns (uint)
    {
        if(deposits[investorAddress].value == 0 && msg.data.length == 20)
        {
            address referrerAddress = bytesToAddress(bytes(msg.data));
            require(referrerAddress != investorAddress);     
            require(deposits[referrerAddress].value > 0);        
            
            parents[investorAddress] = referrerAddress;
            return weiAmount / 100; // 1%
        }
        
        return 0;
    }
    
    function payRewards(address investorAddress, uint depositValue) internal
    {   
        address[] memory parentAddresses = getParents(investorAddress);
        for(uint8 i = 0; i < parentAddresses.length; i++)
        {
            address parent = parentAddresses[i];
            if(parent == address(0)) break;
            
            uint rewardValue = calculateRewardForLevel(i + 1, depositValue);
            parent.transfer(rewardValue);
            
            emit ReferrerBonus(investorAddress, parent, i + 1, rewardValue);
        }
    }
    
    function addDeposit(address investorAddress, uint weiAmount, uint bonus) internal
    {   
        if(deposits[investorAddress].value == 0)
        {
            deposits[investorAddress].time = now;
            deposits[investorAddress].timeOfLastWithdraw = deposits[investorAddress].time;
            deposits[investorAddress].value = weiAmount.add(bonus);
            investors.push(investorAddress);
        }
        else
        {
            payWithdraw(investorAddress);
            deposits[investorAddress].value = deposits[investorAddress].value.add(weiAmount);
        }
        
        emit Deposit(msg.sender, msg.value, deposits[investorAddress].timeOfLastWithdraw);
    }
    
    function payFee(uint weiAmount) internal
    {
        uint fee = weiAmount.mul(11).div(100); // 11%
        owner.transfer(fee);
    }
    
    function calculateNewTime(uint startTime, uint endTime) public pure returns (uint) 
    {
        uint daysCount = endTime.sub(startTime).div(1 days);
        return startTime.add(daysCount.mul(1 days));
    }
    
    function payWithdraw(address to) internal
    {
        require(deposits[to].value > 0);
        require(now - deposits[to].timeOfLastWithdraw >= 1 days);
        
        uint sum = calculateWithdrawalSum(now, deposits[to].time, deposits[to].value, deposits[to].timeOfLastWithdraw);
        require(sum > 0);
        
        deposits[to].timeOfLastWithdraw = now;
        
        to.transfer(sum);
        emit Withdraw(to, sum);
    }
    
    function withdraw() checkSender public
    {
        payWithdraw(msg.sender);
    }
}