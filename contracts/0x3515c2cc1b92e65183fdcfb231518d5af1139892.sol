pragma solidity ^0.4.24;

/***
 *     __   __   ___      ___    ___   
 *     \ \ / /  / _ \    | _ \  / _ \  
 *      \ V /  | (_) |   |  _/ | (_) | 
 *      _|_|_   \___/   _|_|_   \___/  
 *    _| """ |_|"""""|_| """ |_|"""""| 
 *    "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 
 *   
 *
 * https://easyinvest10.app
 * 
 * YOPO Lucky Investment Contract
 *  - GAIN 3.3%-10% PER 24 HOURS! LUCKY PEOPLE GAINS LUCKY RATE!
 *  - Different investors gain different division rates (see who the lucky guy is)
 *  - 10% chance to win extra 10% ETH while investing 0.5 ETH or higher
 *  - 1% chance to win double ETH while investing 0.1 ETH or higher
 *
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction  (1 time per hour)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *  3. If you earn more than 200%, you can withdraw only one finish time
 *
 * RECOMMENDED GAS LIMIT: 140000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */

contract YopoInvest {

    using SafeMath for uint;
    mapping(address => uint) public rates;
    mapping(address => uint) public balance;
    mapping(address => uint) public time;
    mapping(address => uint) public percentWithdraw;
    mapping(address => uint) public allPercentWithdraw;
    uint public stepTime = 1 hours;
    uint public countOfInvestors = 0;
    address public ownerAddress = 0xe79b84906aBb7ddE4CC81bD27BC89A7E97366C0C;
    
    uint public projectPercent = 10;
    uint public floatRate = 50;
    uint public startTime = now;
    uint public lastTime = now;

	struct Bet {
		address addr;
		uint256 eth;
		uint256 rate;
		uint256 date;
	}
	
	Bet[] private _bets;
	uint256 public numberOfBets = 0;
	uint256[] public topRates;
	address[] public bonusAcounts;
	uint256 public numberOfbonusAcounts = 0;
	bool public enabledBonus = true;
	
    address[] public promotors = new address[](8);
    uint256 public numberOfPromo = 0;
	
    event Invest(address investor, uint256 amount, uint256 rate);
    event Withdraw(address investor, uint256 amount);
    event OnBonus(address investor, uint256 amount, uint256 bonus);

    modifier userExist {
        require(balance[msg.sender] > 0, "Address not found");
        _;
    }

    modifier checkTime {
        require(now >= time[msg.sender].add(stepTime), "Too fast payout request");
        _;
    }

    modifier onlyOwner {
        require (msg.sender == ownerAddress, "OnlyOwner methods called by non-owner.");
        _;
    }

    constructor() public{
        addPromotor(0x56C4ECf7fBB1B828319d8ba6033f8F3836772FA9) ;
    }

    function() external payable {
        deposit();
    }
    
    function deposit() private {
        if (msg.value > 0) {
            lastTime = now;
            uint bal = balance[msg.sender];
            if (bal == 0) {
                countOfInvestors += 1;
            }
            if (bal > 0 && now > time[msg.sender].add(stepTime)) {
                collectDivision();
                percentWithdraw[msg.sender] = 0;
            }
             
            // update division rate in first investment or reinvesting higher than current balance
            if(msg.value>=bal){
                // update rates
                (uint _rate, uint _floatRate) = luckyrate();
                floatRate = _floatRate;
                rates[msg.sender] = _rate;
                _bets.push(Bet(msg.sender, msg.value, _rate, now)); 
                numberOfBets++;
                updateTopRates(numberOfBets-1);
            }else{
                _bets.push(Bet(msg.sender, msg.value, rates[msg.sender], now)); 
                numberOfBets++;
            }
            
            balance[msg.sender] = balance[msg.sender].add(msg.value);
            time[msg.sender] = now;
            
            luckybonus();
            shareProfit();
            emit Invest(msg.sender, msg.value, rates[msg.sender]);
        } else {
            collectDivision();
        }
    }
    
    function collectDivision() userExist checkTime internal {
        if ((balance[msg.sender].mul(2)) <= allPercentWithdraw[msg.sender]) {
            balance[msg.sender] = 0;
            time[msg.sender] = 0;
            percentWithdraw[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            percentWithdraw[msg.sender] = percentWithdraw[msg.sender].add(payout);
            allPercentWithdraw[msg.sender] = allPercentWithdraw[msg.sender].add(payout);
            msg.sender.transfer(payout);
            emit Withdraw(msg.sender, payout);
        }
    }

    function payoutAmount() public view returns(uint256) {
        uint256 percent = rates[msg.sender];
        uint256 different = now.sub(time[msg.sender]).div(stepTime);
        uint256 rate = balance[msg.sender].mul(percent).div(1000);
        uint256 withdrawalAmount = rate.mul(different).div(24).sub(percentWithdraw[msg.sender]);

        return withdrawalAmount;
    }

    function luckyrate() public view returns (uint256, uint256){
		uint256 _seed = rand();
       
        // longer gap time, higher bonus
        uint bonusRate = now.sub(lastTime).div(1 minutes);
        
        (uint minRate, uint maxRate) = rateRange();
        uint rate = (_seed % (floatRate.sub(minRate)+1)).add(minRate).add(bonusRate);
        if(rate> maxRate){
            rate = maxRate;
        }
        
        uint _floatRate = (maxRate.sub(rate).add(minRate));
        
        if(_floatRate > maxRate){
            _floatRate = maxRate;
        }
        if(_floatRate < minRate){
            _floatRate = minRate;
        }
        
        return (rate, _floatRate);
    }
    
    function luckybonus() private {        
        // check if you're a lucky guy
        if(enabledBonus && msg.value>= (0.1 ether)){
            uint256 _seed = rand();
            uint256 _bonus = 0;
            if(msg.value>= (0.5 ether) && (_seed % 10)==9){
                // Congratulation! you win extra 10% 
                _bonus = msg.value/10;
            }else if((_seed % 100)==99){
                // Congratulation! you win DOUBLE!
                _bonus = msg.value;
            } 
            
            if(_bonus>0){
                if(_bonus > 1 ether){ 
                    /*1 ether is the highest bonus*/
                    _bonus = 1 ether;
                }
                balance[msg.sender] = balance[msg.sender].add(_bonus);  
                bonusAcounts.push(msg.sender);
                numberOfbonusAcounts++;
                emit OnBonus(msg.sender, msg.value, _bonus);
            }
        } 
    }

    function shareProfit() private {
        uint256 projectShare = msg.value.mul(projectPercent).div(100);
        uint256 promoFee = msg.value.div(100);
        uint256 i = 0;
        while(i<numberOfPromo && i<8){
            address promo = promotors[i];
            balance[promo] = balance[promo].add(promoFee);
            projectShare = projectShare.sub(promoFee);
            i++;
        }
        ownerAddress.transfer(projectShare);
    }

    function rand() private view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(
                (block.timestamp) +
                (block.difficulty) +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                (block.gaslimit) +
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
                (block.number)
        ))); 
    }
    
    function rateRange() public view returns (uint256, uint256){
        uint contractBalance = address(this).balance;

        if (contractBalance < 100 ether) {
            return (33, 60);
        }
        else if (contractBalance < 500 ether) {
            return (40, 70);
        }
        else if (contractBalance < 1000 ether) {
            return (46, 78);
        }
        else if (contractBalance < 2000 ether) {
            return (51, 85);
        }
        else if (contractBalance < 2500 ether) {
            return (55, 90);
        }
        else if (contractBalance < 5000 ether) {
            return (59, 95);
        }
        else{
            return (62, 100);
        }
    }
    
    function getTopRatedBets() public view returns(
		address[],
		uint256[],
		uint256[],
		uint256[]){
	    
        uint256 i = 0;
        uint256 len = topRates.length;
		address[] memory _addrs = new address[](len);
		uint256[] memory _eths = new uint256[](len);  
		uint256[] memory _rates = new uint256[](len);
		uint256[] memory _dates = new uint256[](len);
		
		while (i< len) {
            Bet memory b = _bets[topRates[i]];
            _addrs[i] = b.addr;
            _eths[i] = b.eth;
            _rates[i] = b.rate;
            _dates[i] = b.date;
            i++;
        }
        
        return(_addrs, _eths,  _rates, _dates);
	}

    function getBets(uint256 _len) public view returns(
		address[],
		uint256[],
		uint256[],
		uint256[]){
	    
        uint256 i = 0;
        uint256 len = _len> _bets.length? _bets.length: _len;
		address[] memory _addrs = new address[](len);
		uint256[] memory _eths = new uint256[](len);  
		uint256[] memory _rates = new uint256[](len);
		uint256[] memory _dates = new uint256[](len);
		
		while (i< len) {
            Bet memory b = _bets[i];
            _addrs[i] = b.addr;
            _eths[i] = b.eth;
            _rates[i] = b.rate;
            _dates[i] = b.date;
            i++;
        }
        
        return(_addrs, _eths,  _rates, _dates);
	}
    
    /** sort rates */
    function updateTopRates(uint256 indexOfBet) private{
        if(indexOfBet<_bets.length){ 
            uint256 maxLen = 20; /* only sort top 20 rates */
            uint256 currentRate = _bets[indexOfBet].rate;
            uint256 len = topRates.length> maxLen ? maxLen: topRates.length;
            uint256 i = 0;
            while (i< len) {
                if(currentRate > _bets[topRates[i]].rate){
                    uint256 j = len.sub(1);
                    if(j<maxLen-1){
                        topRates.push(topRates[topRates.length-1]);
                    }
                    while(j>i){
                        topRates[j]= topRates[j-1];
                        j--;
                    }
                    break;
                }
                i++;
            }
            if(i<maxLen){
                if(i< topRates.length){
                    topRates[i] = indexOfBet;
                }else{
                    topRates.push(indexOfBet);
                }
            }
        }
    }
    
    function setEnabledBonus(bool _enabledBonus) public payable{
        require(msg.sender == ownerAddress, "auth fails");
        enabledBonus = _enabledBonus;
    }

    function getTopRates() public view returns (uint256[]){
        return topRates;
    }

    function getBonusAccounts() public view returns (address[]){
        return bonusAcounts;
    }
    
    function getPromotors() public view returns (address[]){
        address[] memory _promotors = new address[](numberOfPromo);
        uint i = 0;
        while(i<numberOfPromo){
            _promotors[i] = promotors[i];
            i++;
        }
        return _promotors;
    }

    function addPromotor(address addr) onlyOwner public payable { 
        require(numberOfPromo<8, "no more than 8 promotors");
        promotors[numberOfPromo++] = addr;
    }

    function removePromotor(address addr) onlyOwner public payable {  
        uint i = 0;
        bool found = false;
        while(i<numberOfPromo){
            if(promotors[i] == addr){
                found = true;
            }
            if(found){
               promotors[i] = (i<numberOfPromo-1 ? promotors[i+1]: 0x0) ;
            }
            i++;
        } 

        if(found){
            numberOfPromo--;
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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