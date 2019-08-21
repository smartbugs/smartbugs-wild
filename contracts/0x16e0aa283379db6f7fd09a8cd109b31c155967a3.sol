pragma solidity ^0.4.25;

/*

    Lambo Lotto Win | Dapps game for real crypto human
    site: https://llotto.win/
    telegram: https://t.me/Lambollotto/
    discord: https://discord.gg/VWV5jeW/
    
    Rules of the game:
    - Jackpot from 0.1 Ether;    
    - Jackpot is currently 1.5% of the turnover for the jackpot period;    
    - 2.5% of the bet goes to the next jackpot;   
    - jackpot win number 888 (may vary during games);      
    - in case of a jackpot from 0 to 15, the player wins a small jackpot which is equal to 0.5 of the turnover during the jackpot period;
    - when the jackpot is between 500 and 515, the player wins the small jackpot which is equal to 0.3 of the turnover during the jackpot period;
    - the minimum win is 15% of the bet amount, the maximum win is 150% (may be changed by the administration during the game but does not affect the existing bets);
    - administration commission of 2.5% + 2.5% for the development and maintenance of the project;
    - the administration also reserves the right to dispose of the entire bank including jackpots in the event of termination of interest in the game from the users ( 
what happened in Las Vegas stays in Las Vegas:) );
    - there is an opportunity to add marketing wallets if you are interested in advertising our project;

*/

contract lambolotto {
    
    using SafeMath
    for uint;

    modifier onlyAdministrator(){    
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }
    
    modifier onlyActive(){    
        require(boolContractActive);
        _;
    }
    
	modifier onlyHumans() { 
	    require (msg.sender == tx.origin, "only approved contracts allowed"); 
	    _; 
	  }     

    constructor () public {
    
        administrators[msg.sender] = true;          
    }
    
    uint templeContractPercent = 0;
    
    address private adminGet;
	address private promoGet;
    
    uint public forAdminGift = 25;
    
    uint public jackPot_percent_now = 15;
    uint public jackPot_percent_next = 25;
    
    uint public jackPotWin = 888;
    uint public jackPotWinMinAmount = 0.1 ether;
    uint public maxBetsVolume = 10 ether;
    
    uint public jackPot_little_first = 5;
    uint public jackPot_little_first_min = 0;    
    uint public jackPot_little_first_max = 15;
    
    uint public jackPot_little_second = 3;
    uint public jackPot_little_second_min = 500;    
    uint public jackPot_little_second_max = 515;
    
    uint public addPercent = 15;
    
    uint public rand_pmin = 0;
    uint public rand_pmax = 1350; 
    
    uint public rand_jmin = 0;
    uint public rand_jmax = 1000;

    uint public currentReceiverIndex;
    uint public totalInvested;

    uint public betsNum;
    uint public jackPot_now;
    uint public jackPot_next;
    uint public jackPot_lf;
    uint public jackPot_ls;    
    
    uint public jackPotNum = 0;
    uint public jackPotLFNum = 0;
    uint public jackPotLSNum = 0;
    
    struct Deposit {
    
        address depositor;
        uint deposit;
        uint winAmount;
        uint depositJackPotValue;
        uint payout;
    }
    
    Deposit[] public queue;
    
    uint nonce;
    
    bool public boolContractActive = true;    
    mapping(address => bool) public administrators;   
    
    address mkt = 0x0;
    uint mktRate = 0;

    event bets(
        address indexed customerAddress,
        uint timestamp,
        uint amount,
        uint winAmount,
        uint jackPotValue,
        uint payout
    );

    event jackPot(
        uint indexed numIndex,
        address customerAddress,
        uint timestamp,
        uint jackAmount
    );

    event jackPotLittleFirst(
        uint indexed numIndex,
        address customerAddress,
        uint timestamp,
        uint jackAmount
    );

    event jackPotLitteleSecond(
        uint indexed numIndex,
        address customerAddress,
        uint timestamp,
        uint jackAmount
    );
    
    function ()
        onlyActive()
        onlyHumans()
        public payable{

        if(msg.value > 0){
        
            require(gasleft() >= 250000); 
            require(msg.value >= 0.001 ether && msg.value <= maxBetsVolume);
            
            uint winningNumber = rand(rand_pmin, rand_pmax);

            totalInvested += msg.value;
            jackPot_now += msg.value.mul(jackPot_percent_now).div(1000);
            jackPot_next += msg.value.mul(jackPot_percent_next).div(1000);
            
            jackPot_lf += msg.value.mul(jackPot_little_first).div(1000);
            jackPot_ls += msg.value.mul(jackPot_little_second).div(1000);
            
            betsNum++;
            
            uint depositJPV = 0;
            
            if( msg.value >= jackPotWinMinAmount)
            {                
                depositJPV = rand(rand_jmin, rand_jmax);
            
                if (depositJPV == jackPotWin){     

                        msg.sender.transfer(jackPot_now);                        
                        jackPotNum++;
                        
                        emit jackPot(jackPotNum,  msg.sender, now, jackPot_now );

                        jackPot_now = jackPot_next;  
                        jackPot_next = 0;
                }
                
                if ( depositJPV > jackPot_little_first_min && depositJPV <= jackPot_little_first_max){     

                        msg.sender.transfer(jackPot_lf);   
                        jackPotLFNum++;
                                        
                        emit jackPotLittleFirst(jackPotLFNum,  msg.sender, now, jackPot_lf );
                        
                        jackPot_lf = 0; 
                }
                
                if ( depositJPV >= jackPot_little_second_min && depositJPV <= jackPot_little_second_max){     

                        msg.sender.transfer(jackPot_ls);                        
                        jackPotLSNum++;                        
                        emit jackPotLitteleSecond(jackPotLSNum,  msg.sender, now, jackPot_ls );
                        
                        jackPot_ls = 0;
                }
                
                uint totalPayout = msg.value.mul(winningNumber.div(10).add(addPercent)).div(100);
                            
                emit bets(msg.sender, now, msg.value, winningNumber, depositJPV, totalPayout);
                
            }
            
            queue.push( Deposit(msg.sender, msg.value, winningNumber, depositJPV, 0) );
            
            uint adminGetValue = msg.value.mul(forAdminGift).div(1000); 
            adminGet.transfer(adminGetValue);
            
			uint promoGetValue = msg.value.mul(forAdminGift).div(1000);
            promoGet.transfer(promoGetValue);
            
            if (mkt != 0x0 && mktRate != 0){
                
                uint mktGetValue = msg.value.mul(mktRate).div(1000);
                mkt.transfer(mktGetValue);                
            }
            
            pay();
        }
    }

    function pay() internal {

        uint money = address(this).balance.sub(jackPot_now.add(jackPot_next).add(jackPot_lf).add(jackPot_ls));
        
        for (uint i = 0; i < queue.length; i++){   
        
            uint idx = currentReceiverIndex.add(i); 
                
                if(idx <= queue.length.sub(1)){
                
                    Deposit storage dep = queue[idx]; 
                    uint totalPayout = dep.deposit.mul(dep.winAmount.div(10).add(addPercent)).div(100);

                    if(totalPayout > dep.payout) { uint leftPayout = totalPayout.sub(dep.payout); }

                    if(money >= leftPayout){ 
                    
                        if (leftPayout > 0){                        
                            dep.depositor.transfer(leftPayout); 
                            dep.payout += leftPayout;                                                   
                            money -= leftPayout; 
                        }

                    }else{
                        dep.depositor.transfer(money); 
                        dep.payout += money;   
                        break; 
                    }

                    if(gasleft() <= 55000){ break; }   
                    
                }else{ break; }                
        }
        currentReceiverIndex += i; 
    }
    
    function rand(uint minValue, uint maxValue) internal returns (uint){
    
        nonce++;        
        uint nonce_ = block.difficulty.div(block.number).mul(now).mod(nonce);        
        uint mixUint = SafeMath.sub(SafeMath.mod(uint(keccak256(abi.encodePacked(nonce_))), SafeMath.add(minValue,maxValue)), minValue);
        nonce += mixUint; 
        return mixUint;        
    }
 
    function donate()
        public payable{        
    } 

    function setJackPotNowValue()
        onlyAdministrator()
        public payable{
      
        require(msg.value > jackPot_now);      
        jackPot_now = msg.value;     
    } 
    
    function setJackPotNextValue()
        onlyAdministrator()
        public payable{
      
        require(msg.value > jackPot_next);      
        jackPot_next = msg.value;     
    } 
    
    function setJackPotLFValue()
        onlyAdministrator()
        public payable{
      
        require(msg.value > jackPot_lf);      
        jackPot_lf = msg.value;     
    }  
    
    function setJackPotLSValue()
        onlyAdministrator()
        public payable{
      
        require(msg.value > jackPot_ls);      
        jackPot_ls =  msg.value;     
    }     

    function setjackPotLillteF(uint _newJPLF)
        onlyAdministrator()
        public{
      
        jackPot_little_first = _newJPLF;     
    }       
    
    function setjackPotLillteS(uint _newJPLS)
        onlyAdministrator()
        public{
      
        jackPot_little_second =  _newJPLS;     
    }    
    
    function setMarket(address _newMkt)
        onlyAdministrator()
        public{
      
        mkt =  _newMkt;     
    }
    
    function setMarketingRates(uint _newMktRate)
        onlyAdministrator()
        public{
       
        mktRate =  _newMktRate;
    }  

    function setAdminGet(address _newAdminGet)
        onlyAdministrator()
        public{
      
        adminGet =  _newAdminGet;     
    }     
    
    function setPromoGet(address _newPromoGet)
        onlyAdministrator()
        public{
      
        promoGet =  _newPromoGet;     
    }   

    function setForAdminGift(uint _newAdminGift)
        onlyAdministrator()
        public{
       
        forAdminGift =  _newAdminGift;
    }      
    
   function setJeckPotPercentNow(uint _newJeckPotPercentNow)
        onlyAdministrator()
        public{
       
        jackPot_percent_now =  _newJeckPotPercentNow;
    }  
 
   function setJeckPotPercentNext(uint _newJeckPotPercentNext)
        onlyAdministrator()
        public{
       
        jackPot_percent_next =  _newJeckPotPercentNext;
    }   
 
   function setJeckPotWin(uint _newJeckPotWin)
        onlyAdministrator()
        public{
       
        jackPotWin =  _newJeckPotWin;
    } 
    
   function setAddPercent(uint _newAddPercent)
        onlyAdministrator()
        public{
       
        addPercent =  _newAddPercent;
    } 

   function setRandPMax(uint _newRandPMax)
        onlyAdministrator()
        public{
       
        rand_pmax =  _newRandPMax;
    }

   function setRandJMax(uint _newRandJMax)
        onlyAdministrator()
        public{
       
        rand_jmax =  _newRandJMax;
    }
    
   function setNonce(uint _newNonce)
        onlyAdministrator()
        public{
       
        nonce =  _newNonce;
    }    
 
   function setNewMaxVolume(uint _newMaxVol)
        onlyAdministrator()
        public{
       
        maxBetsVolume =  _newMaxVol;
    }    
    
    function setContractActive(bool _status)
        onlyAdministrator()
        public{
        
        boolContractActive = _status;
        
    } 
    
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public{
        
        administrators[_identifier] = _status;
    } 
    
    function getAllDepoIfGameStop() 
        onlyAdministrator()
        public{        
        
        jackPot_now = 0;
        jackPot_next = 0;
        jackPot_lf = 0;
        jackPot_ls = 0;
        
        uint money = address(this).balance;
        adminGet.transfer(money);
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