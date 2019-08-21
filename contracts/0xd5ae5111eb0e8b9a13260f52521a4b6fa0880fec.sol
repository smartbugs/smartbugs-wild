pragma solidity ^0.4.25;

/*
    Trust based betting system, affiliated with NeutrinoTokenStandard contract. Yearly version.
    Rules:
        Welcome Fee                      -  25%, including:
            Boss                         -  10%
            Yearly jackpot               -   2%
            Referral bonus               -   8%
            NTS funding                  -   5%
        Exit Fee                         - FREE
*/

contract NeutrinoTokenStandard {
    function fund() external payable;
}

contract ReferralPayStation {
    event OnGotRef (
        address indexed ref,
        uint256 value,
        uint256 timestamp,
        address indexed player
    );
    
    event OnWithdraw (
        address indexed ref,
        uint256 value,
        uint256 timestamp
    );
    
    event OnRob (
        address indexed ref,
        uint256 value,
        uint256 timestamp
    );
    
    event OnRobAll (
        uint256 value,
        uint256 timestamp  
    );
    
    address owner;
    mapping(address => uint256) public refBalance;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function put(address ref, address player) public payable {
        require(msg.value > 0);
        refBalance[ref] += msg.value;
        
        emit OnGotRef(ref, msg.value, now, player);
    }
    
    function withdraw() public {
        require(refBalance[msg.sender] > 0);
        uint256 value = refBalance[msg.sender];
        refBalance[msg.sender] = 0;
        msg.sender.transfer(value);
        emit OnWithdraw(msg.sender, value, now);
    }
    
    /* admin */
    function rob(address ref) onlyOwner public {
        require(refBalance[ref] > 0);
        uint256 value = refBalance[ref];
        refBalance[ref] = 0;
        owner.transfer(value);
        emit OnRob(ref, value, now);
    }
    
    function robAll() onlyOwner public {
        uint256 balance = address(this).balance;
        owner.transfer(balance);
        emit OnRobAll(balance, now);
    }
}

contract BitcoinPriceBetY {
    event OnBet (
        address indexed player,
        address indexed ref,
        uint256 indexed timestamp,
        uint256 value,
        uint256 betPrice,
        uint256 extra,
        uint256 refBonus,
        uint256 amount
    );
    
    event OnWithdraw (
        address indexed referrer,
        uint256 value
    );
    
    event OnWithdrawWin (
        address indexed player,
        uint256 value
    );
    
    event OnPrizePayed (
        address indexed player,
        uint256 value,
        uint8 place,
        uint256 betPrice,
        uint256 amount,
        uint256 betValue
    );
    
    event OnNTSCharged (
        uint256 value
    );
    
    event OnYJPCharged (
        uint256 value  
    );
    
    event OnGotMoney (
        address indexed source,
        uint256 value
    );
    
    event OnCorrect (
        uint256 value
    );
    
    event OnPrizeFunded (
        uint256 value
    );
    
    event OnSendRef (
        address indexed ref,
        uint256 value,
        uint256 timestamp,
        address indexed player,
        address indexed payStation
    );
    
    event OnNewRefPayStation (
        address newAddress,
        uint256 timestamp
    );

    event OnBossPayed (
        address indexed boss,
        uint256 value,
        uint256 timestamp
    );
    
    string constant public name = "BitcoinPrice.Bet Yearly";
    string constant public symbol = "BPBY";
    address public owner;
    address constant internal boss1 = 0x42cF5e102dECCf8d89E525151c5D5bbEAc54200d;
    address constant internal boss2 = 0x8D86E611ef0c054FdF04E1c744A8cEFc37F00F81;
    NeutrinoTokenStandard constant internal neutrino = NeutrinoTokenStandard(0xad0a61589f3559026F00888027beAc31A5Ac4625); 
    ReferralPayStation public refPayStation = ReferralPayStation(0x4100dAdA0D80931008a5f7F5711FFEb60A8071BA);
    
    uint8 constant bossFee = 10;
    uint8 constant refFee = 8;
    uint8 constant ntsFee = 5;
    
    mapping(address => uint256) public winBalance;
    uint256 public winBalanceTotal = 0;
    uint256 public bossBalance = 0;
    uint256 public ntsBalance = 0;
    uint256 public prizeBalance = 0;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public payable {
        owner = msg.sender;
        prizeBalance = msg.value;
    }
    
    function() public payable {
        emit OnGotMoney(msg.sender, msg.value);
    }
    
    function betStep() public view returns (uint256) {
        if (now >= 1545581345 && now < 1548979200) return 0.1 ether; /* until Feb 1st */
        if (now >= 1548979200 && now < 1551398400) return 0.2 ether; /* until Mar 1st */
        if (now >= 1551398400 && now < 1554076800) return 0.3 ether; /* until Apr 1st */
        if (now >= 1554076800 && now < 1556668800) return 0.4 ether; /* until May 1st */
        if (now >= 1556668800 && now < 1559347200) return 0.5 ether; /* until Jun 1st */
        if (now >= 1559347200 && now < 1561939200) return 0.6 ether; /* until Jul 1st */
        if (now >= 1561939200 && now < 1564617600) return 0.7 ether; /* until Aug 1st */
        if (now >= 1564617600 && now < 1567296000) return 0.8 ether; /* until Sep 1st */
        return 0;
    }
    
    function canMakeBet() public view returns (bool) {
        return betStep() > 0;
    }
    
    function makeBet(uint256 betPrice, address ref) public payable {
        uint256 _betStep = betStep();
        require (_betStep > 0);
        
        uint256 value = (msg.value / _betStep) * _betStep;
        uint256 extra = msg.value - value;
        
        require(value > 0);
        prizeBalance += extra;
        
        uint8 welcomeFee = bossFee + ntsFee;
        uint256 refBonus = 0;
        if (ref != 0x0) {
            welcomeFee += refFee;
            refBonus = value * refFee / 100;

            refPayStation.put.value(refBonus)(ref, msg.sender);
            emit OnSendRef(ref, refBonus, now, msg.sender, address(refPayStation));
        }
        
        uint256 taxedValue = value - value * welcomeFee / 100;
        prizeBalance += taxedValue;
    
        bossBalance += value * bossFee / 100;
        ntsBalance += value * ntsFee / 100;
            
        emit OnBet(msg.sender, ref, block.timestamp, value, betPrice, extra, refBonus, value / _betStep);
    }
    
    function withdrawWin() public {
        require(winBalance[msg.sender] > 0);
        uint256 value = winBalance[msg.sender];
        winBalance[msg.sender] = 0;
        winBalanceTotal -= value;
        msg.sender.transfer(value);
        emit OnWithdrawWin(msg.sender, value);
    }
    
    /* Admin */
    function payPrize(address player, uint256 value, uint8 place, uint256 betPrice, uint256 amount, uint256 betValue) onlyOwner public {
        require(value <= prizeBalance);
        
        winBalance[player] += value;
        winBalanceTotal += value;
        prizeBalance -= value;
        emit OnPrizePayed(player, value, place, betPrice, amount, betValue);   
    }
    
    function payPostDrawRef(address ref, address player, uint256 value) onlyOwner public {
        require(value <= prizeBalance);
        
        prizeBalance -= value;
        
        refPayStation.put.value(value)(ref, player);
        emit OnSendRef(ref, value, now, player, address(refPayStation));
    }
    
    function payBoss(uint256 value) onlyOwner public {
        require(value <= bossBalance);
        if (value == 0) value = bossBalance;
        uint256 value1 = value * 90 / 100;
        uint256 value2 = value * 10 / 100;
        
        if (boss1.send(value1)) {
            bossBalance -= value1;
            emit OnBossPayed(boss1, value1, now);
        }
        
        if (boss2.send(value2)) {
            bossBalance -= value2;
            emit OnBossPayed(boss2, value2, now);
        }
    }
    
    function payNTS() onlyOwner public {
        require(ntsBalance > 0);
        uint256 _ntsBalance = ntsBalance;
        
        neutrino.fund.value(ntsBalance)();
        ntsBalance = 0;
        emit OnNTSCharged(_ntsBalance);
    }
    
    function correct() onlyOwner public {
        uint256 counted = winBalanceTotal + bossBalance + ntsBalance + prizeBalance;
        uint256 uncounted = address(this).balance - counted;
        
        require(uncounted > 0);
        
        bossBalance += uncounted;
        emit OnCorrect(uncounted);
    }
    
    function fundPrize() onlyOwner public {
        uint256 counted = winBalanceTotal + bossBalance + ntsBalance + prizeBalance;
        uint256 uncounted = address(this).balance - counted;
        
        require(uncounted > 0);
        
        prizeBalance += uncounted;
        emit OnPrizeFunded(uncounted);
    }
    
    function newRefPayStation(address newAddress) onlyOwner public {
        refPayStation = ReferralPayStation(newAddress);
        
        emit OnNewRefPayStation(newAddress, now);
    }
}