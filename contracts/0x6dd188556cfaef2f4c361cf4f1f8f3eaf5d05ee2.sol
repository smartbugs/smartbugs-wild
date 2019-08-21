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
    function myDividends(bool _includeReferralBonus) external;
    function balanceOf(address _investorAddress) external pure returns(uint256);
    function dividendsOf(address _investorAddress) external;
    function sellPrice() payable external returns (uint256);
    function buyPrice() external;
    function calculateTokensReceived(uint256 _ethereumToSpend) external;
    function calculateEthereumReceived(uint256 _tokensToSell) external returns(uint256);
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) external;
}

contract CryptoMinerFund {
    using ItsJustBasicMathBro
    for uint;
    
    /* Marketing private wallet*/
    address constant _parojectMarketing = 0x3d3B4a38caD44c2B77DAAC1D746124D2e2b8a27C;
    /* Interface to main CMT contract */    
    HourglassInterface constant CMTContract = HourglassInterface(0x0a97094c19295E320D5121d72139A150021a2702);
    /* Hashtables for functionality */
    mapping(address => uint) public walletDeposits;
    mapping(address => uint) public walletTimer;
    mapping(address => uint) public withdrawedAmounts;
    
    /* % Fee that will be deducted from initial transfer and sent to CMT contract */
    uint constant _masterTaxOnInvestment = 8;
    /* Time modifier for return value incremental increase */
    uint constant payOutInterval = 1 hours;
    /* Percent rates */
    uint constant basePercent = 270;
    uint constant lowPercent = 320;
    uint constant averagePercent = 375;
    uint constant highPercent = 400;
    /* Balance switches for % */
    uint constant phasePreperation = 500 ether;
    uint constant phaseEngineStart = 1500 ether;
    uint constant phaseLiftoff = 4000 ether;

    /* Fallback that allows to call early exit or with any other value to make a deposit after 1 hour */
    function() external payable {
        if (msg.value > 0) {
            if (now > walletTimer[msg.sender].add(payOutInterval)) {
                makeDeposit();
            }
        } else {
            requestPayDay();
        }
    }

    /* Internal function that makes record into walletDeposits for incomming deposit */
    function makeDeposit() internal{
        if (msg.value > 0) {
            if (now > walletTimer[msg.sender].add(payOutInterval)) {
               walletDeposits[msg.sender] = walletDeposits[msg.sender].add(msg.value);
               walletTimer[msg.sender] = now;
               startDivDistribution();
            }
        }
    }

    /* Calculates if balance > 92% of investment and returns user he's 92% on early exit or all balance if > */
    function requestPayDay() internal{
        uint payDay = 0;
        if(walletDeposits[msg.sender].mul(92).div(100) > getAvailablePayout()){
            payDay = walletDeposits[msg.sender].mul(92).div(100);
            withdrawedAmounts[msg.sender] = 0;
            walletDeposits[msg.sender] = 0;
            walletTimer[msg.sender] = 0;
            msg.sender.transfer(payDay);
        } else{
            payDay = getAvailablePayout();
            withdrawedAmounts[msg.sender] += payDay;
            walletDeposits[msg.sender] = 0;
            walletTimer[msg.sender] = 0;
            msg.sender.transfer(payDay);
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
            CMTContract.sell(totalEthereumBalance());
            CMTContract.reinvest();
    }
      
    /* Calculates actual value of % earned */
    function getAvailablePayout() public view returns(uint) {
        uint percent = resolvePercentRate();
        uint interestRate = now.sub(walletTimer[msg.sender]).div(payOutInterval);
        uint baseRate = walletDeposits[msg.sender].mul(percent).div(100000);
        uint withdrawAmount = baseRate.mul(interestRate);
        if(withdrawAmount > walletDeposits[msg.sender].mul(2)){
            return walletDeposits[msg.sender].mul(2);
        }
        return (withdrawAmount);
    }

    /* Resolve percent rate for deposit */
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

    /* Returns total balance of contract wallet */
    function totalEthereumBalance() public view returns (uint) {
        return address(this).balance;
    }

}

library ItsJustBasicMathBro {

    function mul(uint a, uint b) internal pure returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns(uint) {
        uint c = a / b;
        return c;
    }

    function sub(uint a, uint b) internal pure returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

}