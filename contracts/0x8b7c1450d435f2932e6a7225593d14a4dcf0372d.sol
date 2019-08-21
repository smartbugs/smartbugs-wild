pragma solidity ^0.4.25;

interface HourglassInterface {
    function() payable external;
    function buy(address _investorAddress) payable external returns(uint256);
    function reinvest() external;
    function exit() payable external;
    function withdraw() payable external;
    function sell(uint256 _amountOfTokens) external;
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function totalEthereumBalance() external;
    function totalSupply() external;
    function myTokens() external returns(uint256);
    function myDividends(bool _includeReferralBonus) external returns (uint256);
    function balanceOf(address _investorAddress) external returns (uint256);
    function dividendsOf(address _investorAddress) external returns (uint256);
    function sellPrice() payable external returns (uint256);
    function buyPrice() external;
    function calculateTokensReceived(uint256 _ethereumToSpend) external;
    function calculateEthereumReceived(uint256 _tokensToSell) external returns(uint256);
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) external;
}

contract MinerTokenDaily {
    using SafeMath
    for uint;
    
      /* Marketing private wallet*/
    address constant _parojectMarketing = 0x3d3B4a38caD44c2B77DAAC1D746124D2e2b8a27C;
    address constant _cmtfContractAddress = 0x0a97094c19295E320D5121d72139A150021a2702;
    /* Interface to main CMT contract */    
    HourglassInterface constant CMTContract = HourglassInterface(_cmtfContractAddress);
    
    /* % Fee that will be deducted from initial transfer and sent to CMT contract */
    uint constant _masterTaxOnInvestment = 8;
    
    uint constant basePercent = 36;
    uint constant lowPercent = 40;
    uint constant averagePercent = 45;
    uint constant highPercent = 50;
    /* Balance switches for % */
    uint constant phasePreperation = 1000 ether;
    uint constant phaseEngineStart = 2000 ether;
    uint constant phaseLiftoff = 5000 ether;
    uint constant depositLimit = 50.01 ether;
    uint constant payOutInterval = 1 minutes;
    uint _bonuss = 0;
    
    mapping (address => uint256) public invested;
    mapping (address => uint256) public withdraws;
    mapping (address => uint256) public atBlock;
    mapping (address => uint256) public refearned;

    function () external payable {
        require(msg.value < depositLimit);
        address referrer = bytesToAddress(msg.data);
        
        if (referrer > 0x0 && referrer != msg.sender) {
            if(balanceOf(referrer) > 0.1 ether){
            _bonuss = msg.value.mul(10).div(100);
			rewardReferral(referrer);
			refearned[referrer] += _bonuss;
            }
		}
		
        if (msg.value == 0) {
            withdraw();
            atBlock[msg.sender] = now;
        } else {
            startDivDistribution();
            atBlock[msg.sender] = now;
            invested[msg.sender]+=msg.value;
        }
    }
    
    function withdraw() internal {
        uint payout = availablePayOut();
        withdraws[msg.sender] += payout;
        msg.sender.transfer(payout);
    }
    
    function rewardReferral(address referrer) internal {
        referrer.transfer(_bonuss);
    }
    
    function availablePayOut() public view returns(uint){
            uint percentRate = resolvePercentRate();
            uint balanceTimer = now.sub(atBlock[msg.sender]).div(payOutInterval);
            if(balanceTimer > 1440){
               return invested[msg.sender].mul(percentRate).div(1000);
            }
            else{
               return invested[msg.sender].mul(percentRate).div(1000).div(1440).mul(balanceTimer);
            }
    }
    
    function outStandingPayoutFor(address wallet) public view returns(uint){
            uint percentRate = resolvePercentRate();
            uint balanceTimer = now.sub(atBlock[wallet]).div(payOutInterval);
            if(balanceTimer > 1440){
               return invested[wallet].mul(percentRate).div(1000);
            }
            else{
               return invested[wallet].mul(percentRate).div(1000).div(1440).mul(balanceTimer);
            }
    }
    
    function exit() payable public {
        uint percentRate = resolvePercentRate();
        uint payout = invested[msg.sender];
		if(now.sub(atBlock[msg.sender]).mul(percentRate).div(1000) < invested[msg.sender]/2){
		    atBlock[msg.sender] = 0;
            invested[msg.sender] = 0;
            uint payoutTotal = payout.div(2).sub(withdraws[msg.sender]);
            withdraws[msg.sender] = 0;
		 msg.sender.transfer(payoutTotal);
		}
		else{
		 msg.sender.transfer(payout);
		}
      
    }
    
        /* Internal function to distribute masterx tax fee into dividends to all CMT holders */
    function startDivDistribution() internal{
            /*#######################################  !  IMPORTANT  !  ##############################################
            ## Here we buy CMT tokens with 8% from deposit and we intentionally use marketing wallet as masternode  ##
            ## that results into 33% from 8% goes to marketing & server running  purposes by our team but the rest  ##
            ## of 8% is distributet to all holder with selling CMT tokens & then reinvesting again (LOGIC FROM CMT) ##
            ## This kindof functionality allows us to decrease the % tax on deposit since 1% from deposit is much   ##
            ## more than 33% from 8%.                                                                               ##
            ########################################################################################################*/
            CMTContract.buy.value(msg.value.mul(_masterTaxOnInvestment).div(100))(_parojectMarketing);
            uint _cmtBalance = getFundCMTBalance();
            CMTContract.sell(_cmtBalance);
            CMTContract.reinvest();
    }
      
    
    function resolvePercentRate() public view returns(uint) {
        uint balance = address(this).balance;
        if (balance < phasePreperation) {
            return (basePercent);
        }
        if (balance >= phasePreperation && balance < phaseEngineStart) {
            return (lowPercent);
        }
        if (balance >= phaseEngineStart && balance < phaseLiftoff) {
            return (averagePercent);
        }
        if (balance >= phaseLiftoff) {
            return (highPercent);
        }
    }
    
        /* Returns contracts balance on CMT contract */
    function getFundCMTBalance() internal returns (uint256){
        return CMTContract.myTokens();
    }
    
    function bytesToAddress(bytes bys) private pure returns (address addr) {
		assembly {
			addr := mload(add(bys, 20))
		}
	}
	
	function balanceOf(address _customerAddress) public view returns (uint256) {
	    return invested[_customerAddress];
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}