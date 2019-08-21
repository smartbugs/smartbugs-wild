pragma solidity ^0.4.24;

contract UtilFairWin  {
   
    /* fairwin.me */
    
    function getRecommendBiliBylevelandDai(uint level,uint dai) public view returns(uint);
    function compareStr (string _str,string str) public view returns(bool);
    function getLineLevel(uint value) public view returns(uint);
    function getBiliBylevel(uint level) public view returns(uint);
    function getFireBiliBylevel(uint level) public view returns(uint);
    function getlevel(uint value) public view returns(uint);
}
contract FairWin {
    
     /* fairwin.me */
     
    uint ethWei = 1 ether;
    uint allCount = 0;
    uint oneDayCount = 0;
    uint leijiMoney = 0;
    uint leijiCount = 0;
	uint  beginTime = 1;
    uint lineCountTimes = 1;
    uint daySendMoney = 0;
	uint currentIndex = 0;
	bool isCountOver = false;
	bool isRecommendOver = false;
	uint countTimes = 0;
	uint recommendTimes = 0;
	uint sendTimes = 0;
	address private owner;
	
	constructor () public {
        owner = msg.sender;
    }
	struct User{

        address userAddress;
        uint freeAmount;
        uint freezeAmount;
        uint rechargeAmount;
        uint withdrawlsAmount;
        uint inviteAmonut;
        uint bonusAmount;
        uint dayInviteAmonut;
        uint dayBonusAmount;
        uint level;
        uint resTime;
        uint lineAmount;
        uint lineLevel;
        string inviteCode;
        string beInvitedCode;
		
		uint isline;
		uint status; 
		bool isVaild;
    }
    
    struct Invest{

        address userAddress;
        uint inputAmount;
        uint resTime;
        string inviteCode;
        string beInvitedCode;
		
		uint isline;
		
		uint status; 
    }
    
    mapping (address => User) userMapping;
    mapping (string => address) addressMapping;
    mapping (uint => address) indexMapping;
    
    Invest[] invests;
    UtilFairWin  util = UtilFairWin(0x90468D04ba71A1a2F5187d7B2Ef0cb5c3a355660);
    
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
    
     function invest(address userAddress ,uint inputAmount,string  inviteCode,string  beInvitedCode) public payable{
        
        userAddress = msg.sender;
  		inputAmount = msg.value;
        uint lineAmount = inputAmount;
        if(inputAmount < 1* ethWei || inputAmount > 15* ethWei || util.compareStr(inviteCode,"") ||  util.compareStr(beInvitedCode,"")){
             userAddress.transfer(msg.value);
                require(inputAmount >= 1* ethWei && inputAmount <= 15* ethWei && !util.compareStr(inviteCode,"") && !util.compareStr(beInvitedCode,""), "inputAmount must between 1 and 15");
        }
        User storage userTest = userMapping[userAddress];
        if(userTest.isVaild && userTest.status != 2){
            if((userTest.lineAmount + userTest.freezeAmount + lineAmount)> (15 * ethWei)){
                userAddress.transfer(msg.value);
                require((userTest.lineAmount + userTest.freezeAmount + lineAmount) <= 15 * ethWei,"freeze and line can not beyond 15 eth");
                return;
            }
        }
       leijiMoney = leijiMoney + inputAmount;
        leijiCount = leijiCount + 1;
        bool isLine = false;
        
        uint level =util.getlevel(inputAmount);
        uint lineLevel = util.getLineLevel(lineAmount);
        if(beginTime==1){
            lineAmount = 0;
            oneDayCount = oneDayCount + inputAmount;
            Invest memory invest = Invest(userAddress,inputAmount,now, inviteCode, beInvitedCode ,1,1);
            invests.push(invest);
            sendFeetoAdmin(inputAmount);
        }else{
            allCount = allCount + inputAmount;
            isLine = true;
            invest = Invest(userAddress,inputAmount,now, inviteCode, beInvitedCode ,0,1);
            inputAmount = 0;
            invests.push(invest);
        }
          User memory user = userMapping[userAddress];
            if(user.isVaild && user.status == 1){
                user.freezeAmount = user.freezeAmount + inputAmount;
                user.rechargeAmount = user.rechargeAmount + inputAmount;
                user.lineAmount = user.lineAmount + lineAmount;
                level =util.getlevel(user.freezeAmount);
                lineLevel = util.getLineLevel(user.freezeAmount + user.freeAmount +user.lineAmount);
                user.level = level;
                user.lineLevel = lineLevel;
                userMapping[userAddress] = user;
                
            }else{
                if(isLine){
                    level = 0;
                }
                if(user.isVaild){
                   inviteCode = user.inviteCode;
                   beInvitedCode = user.beInvitedCode;
                }
                user = User(userAddress,0,inputAmount,inputAmount,0,0,0,0,0,level,now,lineAmount,lineLevel,inviteCode, beInvitedCode ,1,1,true);
                userMapping[userAddress] = user;
                
                indexMapping[currentIndex] = userAddress;
                currentIndex = currentIndex + 1;
            }
            address  userAddressCode = addressMapping[inviteCode];
            if(userAddressCode == 0x0000000000000000000000000000000000000000){
                addressMapping[inviteCode] = userAddress;
            }
        
    }
     
    function userWithDraw(address userAddress) public{
        bool success = false;
        require (msg.sender == userAddress, "acoount diffrent");
        
        uint lineMoney = 0;
        uint sendMoney = 0; 
         User memory user = userMapping[userAddress];
         sendMoney = lineMoney + user.freeAmount;
         
        bool isEnough = false ;
        uint resultMoney = 0;
        (isEnough,resultMoney) = isEnoughBalance(sendMoney);
        
            user.withdrawlsAmount =user.withdrawlsAmount + resultMoney;
            user.freeAmount = lineMoney + user.freeAmount - resultMoney;
           //user.freeAmount = sendMoney;
            user.level = util.getlevel(user.freezeAmount);
            user.lineAmount = 0;
            user.lineLevel = util.getLineLevel(user.freezeAmount + user.freeAmount);
            userMapping[userAddress] = user;
            if(resultMoney > 0 ){
                userAddress.transfer(resultMoney);
            }
    }

    //
    function countShareAndRecommendedAward(uint startLength ,uint endLength,uint times) external onlyOwner {
         require (msg.sender == owner, "OnlyOwner methods called by non-owner.");

        for(uint i = startLength; i < endLength; i++) {
            Invest memory invest = invests[i];
             address  userAddressCode = addressMapping[invest.inviteCode];
            User memory user = userMapping[userAddressCode];
            if(invest.isline==1 && invest.status == 1 && now < (invest.resTime + 5 days)){

               uint bili = util.getBiliBylevel(user.level);
                user.dayBonusAmount =user.dayBonusAmount + bili*invest.inputAmount/1000;
                user.bonusAmount = user.bonusAmount + bili*invest.inputAmount/1000;
                userMapping[userAddressCode] = user;
               
            }
            if(invest.isline==1 && invest.status == 1 && now >= (invest.resTime + 5 days)){
                invests[i].status = 2;
                user.freezeAmount = user.freezeAmount - invest.inputAmount;
                user.freeAmount = user.freeAmount + invest.inputAmount;
                user.level = util.getlevel(user.freezeAmount);
                userMapping[userAddressCode] = user;
            }
        }
        countTimes = countTimes +1;
        if(times <= countTimes){ 
            isCountOver = true;
        }
    }
    
    function countRecommend(uint startLength ,uint endLength,uint times)  external onlyOwner {
        
         require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
         for(uint i = startLength; i <= endLength; i++) {
             
            address userAddress = indexMapping[i];
            if(userAddress != 0x0000000000000000000000000000000000000000){
                
                User memory user =  userMapping[userAddress];
                if(user.status == 1 && user.freezeAmount >= 1 * ethWei){
                    uint bili = util.getBiliBylevel(user.level);
                    execute(user.beInvitedCode,1,user.freezeAmount,bili);
                }
            }
        }
        recommendTimes = recommendTimes +1;
        if(times <= recommendTimes){ 
            isRecommendOver = true;
        }
    }
    
    
    function execute(string inviteCode,uint runtimes,uint money,uint shareBi) public  returns(string,uint,uint,uint) {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        string memory codeOne = "null";
        
        address  userAddressCode = addressMapping[inviteCode];
        User memory user = userMapping[userAddressCode];
        if (user.isVaild){
            codeOne = user.beInvitedCode;
              if(user.status == 1){
                  
                  uint fireBi = util.getFireBiliBylevel(user.lineLevel);
                  uint recommendBi = util.getRecommendBiliBylevelandDai(user.lineLevel,runtimes);
                  uint moneyResult = 0;
                  
                  if(money <= (user.freezeAmount+user.lineAmount+user.freeAmount)){
                      moneyResult = money;
                  }else{
                      moneyResult = user.freezeAmount+user.lineAmount+user.freeAmount;
                  }
                  
                  if(recommendBi != 0){
                      user.dayInviteAmonut =user.dayInviteAmonut + (moneyResult*shareBi*fireBi*recommendBi/1000/10/100);
                      user.inviteAmonut = user.inviteAmonut + (moneyResult*shareBi*fireBi*recommendBi/1000/10/100);
                      userMapping[userAddressCode] = user;
                  }
              }
              return execute(codeOne,runtimes+1,money,shareBi);
        }
        return (codeOne,0,0,0);

    }
    
    function sendMoneyToUser(address userAddress, uint money) private {
        address send_to_address = userAddress;
        uint256 _eth = money;
        send_to_address.transfer(_eth);
        
    }

    function sendAward(uint startLength ,uint endLength,uint times) public {
        
         daySendMoney = 0;
         require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
         
         for(uint i = startLength; i <= endLength; i++) {
             
            address userAddress = indexMapping[i];
            if(userAddress != 0x0000000000000000000000000000000000000000){
                
                User memory user =  userMapping[userAddress];
                if(user.status == 1){
                    uint sendMoney =user.dayInviteAmonut + user.dayBonusAmount;
                    
                    if(sendMoney >= (ethWei/10)){
                         sendMoney = sendMoney - (ethWei/1000);  
                        bool isEnough = false ;
                        uint resultMoney = 0;
                        (isEnough,resultMoney) = isEnoughBalance(sendMoney);
                        if(isEnough){
                             daySendMoney =daySendMoney + resultMoney;
                            sendMoneyToUser(user.userAddress,resultMoney);
                            //
                            user.dayInviteAmonut = 0;
                            user.dayBonusAmount = 0;
                            userMapping[userAddress] = user;
                        }else{
                            userMapping[userAddress] = user;
                            if(sendMoney > 0 ){
                                daySendMoney =daySendMoney + resultMoney;
                                sendMoneyToUser(user.userAddress,resultMoney);
                                user.dayInviteAmonut = 0;
                                user.dayBonusAmount = 0;
                                userMapping[userAddress] = user;
                            }
                        }
                    }
                }
            }
        }
        sendTimes = sendTimes + 1;
        if(sendTimes >= times){ 
            isRecommendOver = false;
            isCountOver = false;
            countTimes = 0;
        	recommendTimes = 0;
        	sendTimes = 0;
        }
    }

    function isEnoughBalance(uint sendMoney) public view returns (bool,uint){
        
        if(this.balance > 0 ){
             if(sendMoney >= this.balance){
                if((this.balance ) > 0){
                    return (false,this.balance); 
                }else{
                    return (false,0);
                }
            }else{
                 return (true,sendMoney);
            }
        }else{
             return (false,0);
        }
    }
    
    function getUserByAddress(address userAddress) public view returns(uint,uint,uint,uint,uint,uint,uint,uint,uint,string,string,uint){

            User memory user = userMapping[userAddress];
            return (user.lineAmount,user.freeAmount,user.freezeAmount,user.inviteAmonut,
            user.bonusAmount,user.lineLevel,user.status,user.dayInviteAmonut,user.dayBonusAmount,user.inviteCode,user.beInvitedCode,user.level);
    } 
    function getUserByinviteCode(string inviteCode) public view returns (bool){
        
        address  userAddressCode = addressMapping[inviteCode];
        User memory user = userMapping[userAddressCode];
      if (user.isVaild){
            return true;
      }
        return false;
    }
    function getPingtaiInfo() public view returns(uint,uint,uint){
        return(leijiMoney,leijiCount,beginTime);
    }
    function getStatus() public view returns(uint,uint,uint){
        return(countTimes,recommendTimes,sendTimes);
    }
   
    function test() public view returns(bool,bool,uint,uint){
        return (isRecommendOver,isCountOver,invests.length,currentIndex);
    }
     function sendFeetoAdmin(uint amount){
        address adminAddress = 0x854D359A586244c9E02B57a3770a4dC21Ffcaa8d;
        adminAddress.transfer(amount/25);
    }
}