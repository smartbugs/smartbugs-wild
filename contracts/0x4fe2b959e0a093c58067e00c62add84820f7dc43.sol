/* MUSystem is a global Savings system 
based of the mathematical algorithm created 
by the Mavrodi brothers - Sergey and Vyacheslav. 
The solidity code was written by the enthusiast and devoted MMM participant.
According to these rules MMM worked in Russia in the nineties.

Today you help someone — Tomorrow you will be helped!

Mutual Uniting System (MUSystem):
email: mutualunitingsystem@gmail.com
https://mutualunitingsystem.online/

"MMM IS A FINANCIAL NUCLEAR WEAPON.
They say Baba Vanga predicted, “Pyramid from Russia will travel the world.”
When Sergey Mavrodi passed away, many people thought this prediction 
wasn't going to come true. What if it's just started to materialize?"

Financial apocalypse is inevitable! Together we can do a lot!
Thank you Sergey Mavrodi. You've opened my eyes. */

pragma solidity 0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c=a * b;
    require(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c=a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c=a - b;
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c=a + b;
    require(c >= a);
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract MUSystem{
    
    using SafeMath for uint;
    
    string public constant name="Mutual Uniting System";
    string public constant symbol="MUS";
    uint public constant decimals=15;
    uint public totalSupply;
    address private creatorOwner;
    mapping (address => uint) balances;
    
    struct User{
        uint UserBuyFirstDate;
        uint UserBuyFirstPack;
        uint UserCycle;
        uint UserBuyTokenPackNum;
        uint UserFirstAmt;
        uint UserBuyDate;
        uint UserSellDate;
        uint UserContinued;
        uint UserTotalAmtDepositCurrentPack;
        uint UserTotalAmtDeposit;
        uint UserAmtDepositCurrentPackTRUE;
        uint UserSellTokenPackNum;
        uint UserTotalAmtWithdrawal;
        uint UserTotalAmtWithdrawalCurrentPack;
        uint UserWithdrawalFromFirstRefunded;
        uint UserWithdrawalFromDisparity;
    }
    mapping (address => User) users;
    
    struct DepositTemp{
        address useraddress;
        uint p;
        uint bonus;
        uint userAmt;
        uint amtToSend;
        uint bonusAmount;
        uint userBuyDate;
        uint userSellDate;
        uint userFirstAmt;
        uint userContinued;
        uint userAmtToStore;
        uint availableTokens;
        uint feeCompensation;
        uint UserTokenObtain;
        uint userBuyFirstPack;
        uint userBuyFirstDate;
        uint currentPackNumber;
        uint amtForfirstRefund;
        uint UserBuyTokenPackNum;
        uint userTotalAmtDeposit;
        uint bonusAmountRefunded;
        uint currentPackStartDate;
        uint userAmtOverloadToSend;
        uint currentPackTokenPriceSellout;
        uint userAmtDepositCurrentPackTRUE;
        uint userTotalAmtDepositCurrentPack;
    }
    
    struct WithdrawTemp{
        address useraddress;
        uint userTotalAmtWithdrawalCurrentPack;
        uint UserTokensReturnAboveCurrentPack;
        uint userWithdrawalFromFirstRefunded;
        uint userTotalAmtDepositCurrentPack;
        uint userAmtDepositCurrentPackTRUE;
        uint UserTokensReturnToCurrentPack;
        uint currentPackTokenPriceSellout;
        uint currentPackTokenPriceBuyout;
        uint withdrawAmtAboveCurrentPack;
        uint userWithdrawalFromDisparity;
        uint bonusTokensReturnDecrease;
        bool returnTokenInCurrentPack;
        uint withdrawAmtToCurrentPack;
        uint remainsFromFirstRefunded;
        uint overallDisparityAmounts;
        uint userTotalAmtWithdrawal;
        uint useFromFirstRefunded;
        uint remainsFromDisparity;
        uint TokensReturnDecrease;
        uint currentPackStartDate;
        uint userAvailableAmount;
        uint currentPackDeposits;
        uint currentPackNumber;
        uint userBuyFirstPack;
        uint UserTokensReturn;
        uint useFromDisparity;
        uint overallRefunded;
        uint userSellDate;
        uint userFirstAmt;
        uint userBuyDate;
        uint bonusToSend;
        uint withdrawAmt;
        uint wAtoStore;
        uint thisBal;
        uint bonus;
        uint diff;
        uint dsp;
        bool ra;
    }

    uint private Cycle;
    uint private PrevPackCost;
    bool private feeTransfered;
    uint private NextPackDelta;
    uint private NextPackYield;
    uint private CurrentPackFee;
    uint private RestartModeDate;
    uint private CurrentPackCost;
    uint private OverallDeposits;
    uint private OverallRefunded;
    uint private PrevPackTotalAmt;
    uint private CurrentPackYield;
    uint private CurrentPackDelta;
    bool private RestartMode=false;
    uint private CurrentPackNumber;
    uint private OverallWithdrawals;
    uint private CurrentPackRestAmt;
    uint private CurrentPackTotalAmt;
    uint private CurrentPackDeposits;
    uint private CurrentPackStartDate; 
    uint private CurrentPackTotalToPay;
    uint private OverallDisparityAmounts;
    uint private PrevPackTokenPriceBuyout; 
    uint private NextPackTokenPriceBuyout;
    uint private PrevPackTokenPriceSellout;
    uint private CurrentPackTokenPriceBuyout;
    uint private CurrentPackDisparityAmounts;
    uint private CurrentPackTokenPriceSellout;
    uint private CurrentPackTotalToPayDisparity;
    uint private CurrentPackTokenAvailablePercent;

    constructor () public payable {
        creatorOwner=msg.sender;
        CurrentPackNumber=1;
        Cycle=0;
        mint(50000000000000000);
        packSettings(CurrentPackNumber);
    }

    function packSettings (uint _currentPackNumber) internal {
        CurrentPackNumber=_currentPackNumber;
        if(_currentPackNumber==1){
            CurrentPackTokenPriceSellout=10;
            CurrentPackTokenPriceBuyout=10;
            CurrentPackCost=500000000000000000;
            CurrentPackFee=0;
        }
        if(_currentPackNumber==2){
            PrevPackTotalAmt=CurrentPackCost;
            CurrentPackDelta=0;
            NextPackTokenPriceBuyout=CurrentPackTokenPriceSellout*110/100;
            NextPackYield=NextPackTokenPriceBuyout/CurrentPackTokenPriceSellout;
            NextPackDelta=NextPackYield;
            CurrentPackTokenPriceSellout=NextPackTokenPriceBuyout+NextPackDelta;
            CurrentPackTokenPriceBuyout=CurrentPackTokenPriceSellout;
            CurrentPackCost=50000000000000000*CurrentPackTokenPriceSellout;
            CurrentPackTotalAmt=CurrentPackCost+PrevPackTotalAmt;
            CurrentPackFee=0;
        }
        if(_currentPackNumber>2){
            PrevPackTokenPriceSellout=CurrentPackTokenPriceSellout;
            PrevPackTokenPriceBuyout=CurrentPackTokenPriceBuyout;
            PrevPackCost=CurrentPackCost;
            PrevPackTotalAmt=CurrentPackTotalAmt;
            CurrentPackDelta=NextPackDelta;
            CurrentPackTokenPriceBuyout=NextPackTokenPriceBuyout;
            NextPackTokenPriceBuyout=PrevPackTokenPriceSellout*110;
            if(NextPackTokenPriceBuyout<=100){  
                NextPackTokenPriceBuyout=PrevPackTokenPriceSellout*11/10;
            }
            if(NextPackTokenPriceBuyout>100){ 
                NextPackTokenPriceBuyout=NextPackTokenPriceBuyout*10**3;
                NextPackTokenPriceBuyout=((NextPackTokenPriceBuyout/10000)+5)/10;
            }
            NextPackYield=NextPackTokenPriceBuyout-PrevPackTokenPriceSellout;
            NextPackDelta=NextPackYield*101;
            if(NextPackDelta<=100){ 
                NextPackDelta=CurrentPackDelta+(NextPackYield*101/100);
            }
            if(NextPackDelta>100){
                NextPackDelta=NextPackDelta*10**3;
                NextPackDelta=((NextPackDelta/10000)+5)/10;
                NextPackDelta=CurrentPackDelta+NextPackDelta;
            }
            CurrentPackTokenPriceSellout=NextPackTokenPriceBuyout+NextPackDelta;
            CurrentPackCost=50000000000000000*CurrentPackTokenPriceSellout;
            CurrentPackTotalToPay=50000000000000000*CurrentPackTokenPriceBuyout;
            CurrentPackTotalAmt=CurrentPackCost+PrevPackTotalAmt-CurrentPackTotalToPay;
            CurrentPackFee=PrevPackTotalAmt-CurrentPackTotalToPay-(PrevPackCost*7/10);
        }
        CurrentPackDisparityAmounts=0;
        CurrentPackDeposits=0;
        CurrentPackTokenAvailablePercent=100;
        CurrentPackStartDate=now;
        emit NextPack(CurrentPackTokenPriceSellout, CurrentPackTokenPriceBuyout);
    }

    function aboutCurrentPack () public constant returns (uint num, uint bal, uint overallRefunded, uint dsp, uint availableTokens, uint availableTokensInPercentage, uint availableAmountToDepositInWei, uint tokenPriceSellout, uint tokenPriceBuyout, uint cycle, uint overallDeposits, uint overallWithdrawals, bool){
        if(CurrentPackDeposits+OverallDisparityAmounts > CurrentPackDisparityAmounts+OverallRefunded){
            dsp = CurrentPackDeposits+OverallDisparityAmounts-CurrentPackDisparityAmounts-OverallRefunded;
        }else{
            dsp=0;
        }
        return (CurrentPackNumber, address(this).balance, OverallRefunded, dsp, balances[address(this)], CurrentPackTokenAvailablePercent, balances[address(this)].mul(CurrentPackTokenPriceSellout), CurrentPackTokenPriceSellout, CurrentPackTokenPriceBuyout, Cycle, OverallDeposits, OverallWithdrawals, RestartMode);
    }

    function aboutUser () public constant returns (uint UserFirstAmt, uint remainsFromFirstRefunded, uint UserContinued, uint userTotalAmtDeposit, uint userTotalAmtWithdrawal, uint userAvailableAmount, uint userAvailableAmount1, uint remainsFromDisparity, uint depCP, uint witCP, uint userCycle, uint wAmtToCurrentPack, uint userBuyFirstDate){
        if(users[msg.sender].UserBuyDate>CurrentPackStartDate && users[msg.sender].UserBuyTokenPackNum==CurrentPackNumber){
            wAmtToCurrentPack=users[msg.sender].UserAmtDepositCurrentPackTRUE; 
        }else{
            wAmtToCurrentPack=0;
        }
        if(users[msg.sender].UserSellDate>CurrentPackStartDate && users[msg.sender].UserSellTokenPackNum==CurrentPackNumber){    
            witCP=users[msg.sender].UserTotalAmtWithdrawalCurrentPack;
        }else{
            witCP=0;
        }
        if(users[msg.sender].UserBuyDate>CurrentPackStartDate && users[msg.sender].UserBuyTokenPackNum==CurrentPackNumber){
            depCP=users[msg.sender].UserTotalAmtDepositCurrentPack;
        }else{
            depCP=0;
        }
        remainsFromFirstRefunded=(users[msg.sender].UserFirstAmt*6/10).sub(users[msg.sender].UserWithdrawalFromFirstRefunded);
        remainsFromDisparity=(users[msg.sender].UserFirstAmt*7/10).sub(users[msg.sender].UserWithdrawalFromDisparity);
        userAvailableAmount=(balances[msg.sender]-((wAmtToCurrentPack)/CurrentPackTokenPriceSellout))*CurrentPackTokenPriceBuyout+wAmtToCurrentPack;
        if(CurrentPackTokenAvailablePercent<10){userAvailableAmount+userAvailableAmount/100;}
        if(userAvailableAmount>remainsFromDisparity){
            userAvailableAmount=userAvailableAmount-remainsFromDisparity;
        }else{
            userAvailableAmount=0;
        }
        if (userAvailableAmount<10){
            userAvailableAmount=0;
        }
        uint dsp=0;
        if(CurrentPackDeposits+OverallDisparityAmounts>CurrentPackDisparityAmounts+OverallRefunded){
            dsp = CurrentPackDeposits+OverallDisparityAmounts-CurrentPackDisparityAmounts-OverallRefunded;
        }
        if(address(this).balance>dsp){
            userAvailableAmount1=address(this).balance-dsp;
        }else{
            userAvailableAmount1=0;
        }
        return (users[msg.sender].UserFirstAmt, remainsFromFirstRefunded, users[msg.sender].UserContinued, users[msg.sender].UserTotalAmtDeposit, users[msg.sender].UserTotalAmtWithdrawal, userAvailableAmount, userAvailableAmount1, remainsFromDisparity, depCP, witCP, userCycle, wAmtToCurrentPack, users[msg.sender].UserBuyFirstDate);
    }

    function nextPack (uint _currentPackNumber)internal{
        transferFee();
        feeTransfered=false;
        CurrentPackNumber=_currentPackNumber+1;
        if(_currentPackNumber>0){
            mint(50000000000000000);
        }
        packSettings(CurrentPackNumber);
    }

    function restart(bool _rm)internal{
        if(_rm==true){
            if(RestartMode==false){
                RestartMode=true;
                RestartModeDate=now;
            }else{
                if(now>RestartModeDate+14*1 days){
                    Cycle=Cycle+1;
                    nextPack(0);
                    RestartMode=false;
                }
            }
        }else{
            if(RestartMode==true){
                RestartMode=false;
                RestartModeDate=0;
            }
        }
    }
    
    function transferFee()internal{
        if(CurrentPackNumber>2 && feeTransfered==false && RestartMode==false){
            if(address(this).balance>=CurrentPackFee){
                feeTransfered=true;
                creatorOwner.transfer(CurrentPackFee);
            }
        }
    }

    function deposit() public payable{ 
        require(msg.sender!=0x0 && msg.sender!=0);
        DepositTemp memory d;
        d.userAmt=msg.value;
        d.useraddress=msg.sender;
        require(d.userAmt<250 * 1 ether);
        d.availableTokens=balances[address(this)];
        d.currentPackTokenPriceSellout=CurrentPackTokenPriceSellout;
        require(d.userAmt<=d.availableTokens.mul(d.currentPackTokenPriceSellout).add(d.availableTokens.mul(d.currentPackTokenPriceSellout).div(10)).add(10*1 finney)); 
        require(d.userAmt.div(d.currentPackTokenPriceSellout)>0);
        d.currentPackNumber=CurrentPackNumber;
        d.currentPackStartDate=CurrentPackStartDate;
        d.UserBuyTokenPackNum=users[d.useraddress].UserBuyTokenPackNum;
        d.userBuyFirstDate=users[d.useraddress].UserBuyFirstDate;
        d.userBuyDate=users[d.useraddress].UserBuyDate;
        d.userContinued=users[d.useraddress].UserContinued;
        d.userTotalAmtDepositCurrentPack=users[d.useraddress].UserTotalAmtDepositCurrentPack;
        d.userTotalAmtDeposit=users[d.useraddress].UserTotalAmtDeposit;
        if(d.UserBuyTokenPackNum==d.currentPackNumber && d.userBuyDate>=d.currentPackStartDate){
            require(d.userTotalAmtDepositCurrentPack.add(d.userAmt)<250*1 ether);
            d.userAmtDepositCurrentPackTRUE=users[d.useraddress].UserAmtDepositCurrentPackTRUE;
        }else{
            d.userTotalAmtDepositCurrentPack=0;
            d.userAmtDepositCurrentPackTRUE=0;
        }
        if(users[d.useraddress].UserSellTokenPackNum==d.currentPackNumber && users[d.useraddress].UserSellDate>=d.currentPackStartDate){
            d.p=users[d.useraddress].UserTotalAmtWithdrawalCurrentPack/20;
            require(d.userAmt>d.p);
            d.userAmt=d.userAmt.sub(d.p);
        }
        d.UserTokenObtain=d.userAmt/d.currentPackTokenPriceSellout;
        if(d.UserTokenObtain*d.currentPackTokenPriceSellout<d.userAmt){
            d.UserTokenObtain=d.UserTokenObtain+1;
        }
        if(d.UserTokenObtain>d.availableTokens){
            d.amtToSend=d.currentPackTokenPriceSellout*(d.UserTokenObtain-d.availableTokens);
            d.userAmt=d.userAmt.sub(d.amtToSend);
            d.UserTokenObtain=d.availableTokens;
        }
        if(d.userAmt>=100*1 finney){  
            if(now<=(d.currentPackStartDate+1*1 days)){
                d.bonus=d.UserTokenObtain*75/10000+1;
            }else{
                if(now<=(d.currentPackStartDate+2*1 days)){
                    d.bonus=d.UserTokenObtain*50/10000+1;
                }else{
                    if(now<=(d.currentPackStartDate+3*1 days)){
                        d.bonus=d.UserTokenObtain*25/10000+1;
                    }
                }
            }
        }
        if(d.userContinued>=4 && now>=(d.userBuyFirstDate+1*1 weeks)){
            d.bonus=d.bonus+d.UserTokenObtain/100+1;
        }
        if(d.bonus>0){
            d.UserTokenObtain=d.UserTokenObtain.add(d.bonus);
            if(d.UserTokenObtain>d.availableTokens){
                d.userAmtOverloadToSend=d.currentPackTokenPriceSellout*(d.UserTokenObtain-d.availableTokens);
                d.bonusAmountRefunded=d.userAmtOverloadToSend;
                d.UserTokenObtain=d.availableTokens;
                d.amtToSend=d.amtToSend.add(d.userAmtOverloadToSend);
                d.bonus=0;
            }else{
                d.bonusAmount=d.bonus*d.currentPackTokenPriceSellout;
            }
        }
        if(d.UserBuyTokenPackNum==0){
            d.userContinued=1;
            d.userBuyFirstDate=now;
            d.userFirstAmt=d.userAmt.add(d.bonusAmount);
            d.userBuyFirstPack=d.currentPackNumber;
            d.amtForfirstRefund=d.userFirstAmt*6/10;
            OverallDisparityAmounts=OverallDisparityAmounts+d.userFirstAmt*7/10;
            CurrentPackDisparityAmounts=CurrentPackDisparityAmounts+d.userFirstAmt*7/10;
            d.amtToSend=d.amtToSend.add(d.amtForfirstRefund);
            d.feeCompensation=d.feeCompensation+2500000000000000;
            OverallRefunded=OverallRefunded+d.amtForfirstRefund;
        }else{
            d.userFirstAmt=users[d.useraddress].UserFirstAmt;
            d.userBuyFirstPack=users[d.useraddress].UserBuyFirstPack;
            if(d.UserBuyTokenPackNum==d.currentPackNumber-1){
                d.userContinued=d.userContinued+1;
            }else{
                d.userContinued=1;
            }
        }
        d.userAmtToStore=d.userAmt.add(d.bonusAmount);
        d.userTotalAmtDepositCurrentPack=d.userTotalAmtDepositCurrentPack.add(d.userAmtToStore);
        d.userTotalAmtDeposit=d.userTotalAmtDeposit.add(d.userAmtToStore);
        d.userAmtDepositCurrentPackTRUE=d.userAmtDepositCurrentPackTRUE.add(d.userAmtToStore);
        CurrentPackDeposits=CurrentPackDeposits.add(d.userAmtToStore);
        OverallDeposits=OverallDeposits.add(d.userAmtToStore);
        transfer(address(this), d.useraddress, d.UserTokenObtain, false, 0, 0);
        User storage user=users[d.useraddress];
        user.UserBuyFirstDate=d.userBuyFirstDate;
        user.UserBuyFirstPack=d.userBuyFirstPack;
        user.UserBuyTokenPackNum=d.currentPackNumber;
        user.UserBuyDate=now;
        user.UserFirstAmt=d.userFirstAmt;
        user.UserContinued=d.userContinued;
        user.UserTotalAmtDepositCurrentPack=d.userTotalAmtDepositCurrentPack;
        user.UserTotalAmtDeposit=d.userTotalAmtDeposit;
        user.UserAmtDepositCurrentPackTRUE=d.userAmtDepositCurrentPackTRUE;
        restart(false);
        d.feeCompensation=d.feeCompensation+500000000000000;
        if(balances[address(this)]==0){
            nextPack(d.currentPackNumber);
            d.feeCompensation=d.feeCompensation+1000000000000000;
        }else{
            CurrentPackTokenAvailablePercent=balances[address(this)]/500000000000000;
        }
        if(d.feeCompensation>0 && d.userAmt>d.feeCompensation){
            d.amtToSend=d.amtToSend.add(d.feeCompensation);
        }
        emit Deposit(d.useraddress, d.userAmtToStore, d.amtForfirstRefund, d.bonusAmount, d.bonusAmountRefunded, d.feeCompensation, d.UserTokenObtain, d.bonus, d.currentPackNumber, d.amtToSend);
        if(d.amtToSend>0){ 
            d.useraddress.transfer(d.amtToSend);
        }
    }

    function withdraw(uint WithdrawAmount, uint WithdrawTokens, bool AllowToUseDisparity) public {
        require(msg.sender!=0x0 && msg.sender!=0);
        require(WithdrawTokens>0 || WithdrawAmount>0);
        require(WithdrawTokens<=balances[msg.sender]);
        WithdrawTemp memory w;
        w.useraddress=msg.sender;
        w.userFirstAmt=users[w.useraddress].UserFirstAmt;
        w.userBuyFirstPack=users[w.useraddress].UserBuyFirstPack;
        w.currentPackNumber=CurrentPackNumber;
        w.currentPackStartDate=CurrentPackStartDate;
        w.currentPackTokenPriceSellout=CurrentPackTokenPriceSellout;
        w.currentPackTokenPriceBuyout=CurrentPackTokenPriceBuyout;
        w.overallRefunded=OverallRefunded;
        w.overallDisparityAmounts=OverallDisparityAmounts;
        w.userTotalAmtWithdrawal=users[w.useraddress].UserTotalAmtWithdrawal;
        w.userWithdrawalFromFirstRefunded=users[w.useraddress].UserWithdrawalFromFirstRefunded;
        w.remainsFromFirstRefunded=(w.userFirstAmt*6/10).sub(w.userWithdrawalFromFirstRefunded);
        w.userWithdrawalFromDisparity=users[w.useraddress].UserWithdrawalFromDisparity;
        w.remainsFromDisparity=(w.userFirstAmt*7/10).sub(w.userWithdrawalFromDisparity);
        w.thisBal=address(this).balance;
        w.currentPackDeposits=CurrentPackDeposits;
        if(users[w.useraddress].UserBuyTokenPackNum==w.currentPackNumber && users[w.useraddress].UserBuyDate>=w.currentPackStartDate){
            w.userTotalAmtDepositCurrentPack=users[w.useraddress].UserTotalAmtDepositCurrentPack;
            w.userAmtDepositCurrentPackTRUE=users[w.useraddress].UserAmtDepositCurrentPackTRUE;
            w.withdrawAmtToCurrentPack=users[w.useraddress].UserAmtDepositCurrentPackTRUE;
            w.returnTokenInCurrentPack=true;
        }else{
            w.returnTokenInCurrentPack=false;
        }
        if(users[w.useraddress].UserSellTokenPackNum==w.currentPackNumber && users[w.useraddress].UserSellDate>=w.currentPackStartDate){
            w.userTotalAmtWithdrawalCurrentPack=users[w.useraddress].UserTotalAmtWithdrawalCurrentPack;
        }
        if(CurrentPackDeposits+OverallDisparityAmounts>CurrentPackDisparityAmounts+OverallRefunded){
            w.dsp=CurrentPackDeposits+OverallDisparityAmounts-CurrentPackDisparityAmounts-OverallRefunded;
        }else{
            w.dsp=0;
        }
        w.userAvailableAmount=(balances[w.useraddress]-(w.withdrawAmtToCurrentPack/w.currentPackTokenPriceSellout))*w.currentPackTokenPriceBuyout+w.withdrawAmtToCurrentPack;
        if(w.thisBal>=w.dsp){
            if(w.userAvailableAmount>w.thisBal-w.dsp){
                if(w.currentPackNumber==w.userBuyFirstPack){
                    if(w.userAvailableAmount>w.thisBal-w.dsp+w.userAmtDepositCurrentPackTRUE){
                        w.userAvailableAmount=w.thisBal-w.dsp+w.userAmtDepositCurrentPackTRUE;
                    }
                }else{
                    if(w.userAvailableAmount>w.thisBal-w.dsp+w.remainsFromDisparity+w.userAmtDepositCurrentPackTRUE){
                        w.userAvailableAmount=w.thisBal-w.dsp+w.remainsFromDisparity+w.userAmtDepositCurrentPackTRUE;
                    }
                }
            }
        }else{
            if(w.userAmtDepositCurrentPackTRUE>w.remainsFromDisparity){
                if(w.userAvailableAmount>w.userAmtDepositCurrentPackTRUE){
                    w.userAvailableAmount=w.userAmtDepositCurrentPackTRUE;
                }
            }else{
                if(w.userAvailableAmount>w.remainsFromDisparity){
                    w.userAvailableAmount=w.remainsFromDisparity;
                }
            }
            if(w.userAvailableAmount>w.thisBal+w.remainsFromFirstRefunded){
                w.userAvailableAmount=w.thisBal+w.remainsFromFirstRefunded;
            }
            if(w.currentPackNumber>2){
                w.ra=true;
            }
        }
        if(WithdrawTokens>0 && WithdrawAmount==0){
            w.UserTokensReturn=WithdrawTokens;
            if(w.returnTokenInCurrentPack==true){
                w.UserTokensReturnToCurrentPack=w.withdrawAmtToCurrentPack.div(w.currentPackTokenPriceSellout);
                if(w.UserTokensReturn>w.UserTokensReturnToCurrentPack){
                    w.UserTokensReturnAboveCurrentPack=w.UserTokensReturn.sub(w.UserTokensReturnToCurrentPack);
                    w.withdrawAmtAboveCurrentPack=w.UserTokensReturnAboveCurrentPack.mul(w.currentPackTokenPriceBuyout);
                }else{
                    w.withdrawAmtToCurrentPack=w.UserTokensReturn.mul(w.currentPackTokenPriceSellout);
                    w.UserTokensReturnToCurrentPack=w.UserTokensReturn;
                    w.withdrawAmtAboveCurrentPack=0;
                    w.UserTokensReturnAboveCurrentPack=0;
                }
            }else{
                w.withdrawAmtToCurrentPack=0;
                w.UserTokensReturnToCurrentPack=0;
                w.UserTokensReturnAboveCurrentPack=w.UserTokensReturn;
                w.withdrawAmtAboveCurrentPack=w.UserTokensReturnAboveCurrentPack.mul(w.currentPackTokenPriceBuyout);
            }
            w.withdrawAmt=w.withdrawAmtToCurrentPack.add(w.withdrawAmtAboveCurrentPack);
        }else{
            w.withdrawAmt=WithdrawAmount;
        }
        if(w.withdrawAmt>w.userAvailableAmount){
            w.withdrawAmt=w.userAvailableAmount;
        }
        if(w.remainsFromDisparity>0){
           if(w.userAvailableAmount>=w.remainsFromDisparity){
                w.userAvailableAmount=w.userAvailableAmount-w.remainsFromDisparity;
            }else{
                w.userAvailableAmount=0;
            }
        }
        if(w.userAvailableAmount<100){
            w.userAvailableAmount=0;
        }
        if(AllowToUseDisparity==false && w.remainsFromDisparity>0){
            if(w.withdrawAmt>w.userAvailableAmount){
                w.withdrawAmt=w.userAvailableAmount;
            }
        }
        if(w.returnTokenInCurrentPack==true){
            w.UserTokensReturnToCurrentPack=w.withdrawAmtToCurrentPack.div(w.currentPackTokenPriceSellout);
            if(w.withdrawAmt>w.withdrawAmtToCurrentPack){ 
                w.withdrawAmtAboveCurrentPack=w.withdrawAmt.sub(w.withdrawAmtToCurrentPack);
                w.UserTokensReturnAboveCurrentPack=w.withdrawAmtAboveCurrentPack.div(w.currentPackTokenPriceBuyout);
            }else{
                w.withdrawAmtToCurrentPack=w.withdrawAmt;
                w.UserTokensReturnToCurrentPack=w.withdrawAmtToCurrentPack.div(w.currentPackTokenPriceSellout);
                w.withdrawAmtAboveCurrentPack=0;
                w.UserTokensReturnAboveCurrentPack=0;
            }
        }else{
            w.withdrawAmtToCurrentPack=0;
            w.UserTokensReturnToCurrentPack=0;
            w.withdrawAmtAboveCurrentPack=w.withdrawAmt;
            w.UserTokensReturnAboveCurrentPack=w.withdrawAmtAboveCurrentPack.div(w.currentPackTokenPriceBuyout);
        }
        if(AllowToUseDisparity==true && w.remainsFromDisparity>0){
            if(w.withdrawAmt>w.userAvailableAmount){
                w.useFromDisparity=w.withdrawAmt-w.userAvailableAmount;
                if(w.remainsFromDisparity<w.useFromDisparity){
                    w.useFromDisparity=w.remainsFromDisparity;
                }
                w.userWithdrawalFromDisparity=w.userWithdrawalFromDisparity.add(w.useFromDisparity);
                if(w.remainsFromFirstRefunded>0){
                    if(w.useFromDisparity>w.remainsFromDisparity-w.remainsFromFirstRefunded){
                        w.useFromFirstRefunded=w.useFromDisparity+w.remainsFromFirstRefunded-w.remainsFromDisparity;
                        if (w.remainsFromFirstRefunded<w.useFromFirstRefunded){
                            w.useFromFirstRefunded=w.remainsFromFirstRefunded;
                        }
                        w.userWithdrawalFromFirstRefunded=w.userWithdrawalFromFirstRefunded+w.useFromFirstRefunded;
                        w.withdrawAmt=w.withdrawAmt.sub(w.useFromFirstRefunded);
                    }
                }
            }
        }
        if(CurrentPackTokenAvailablePercent<10){
            w.bonus=(w.withdrawAmt+w.useFromFirstRefunded)/100;
            w.bonusToSend=w.bonus;
        }
        if(w.thisBal>w.dsp && w.bonus>0){
            if(w.withdrawAmt+w.bonus>w.thisBal-w.dsp){
                w.bonusToSend=0;
                w.diff=w.bonus;
                if(w.UserTokensReturnAboveCurrentPack>0){
                    w.bonusTokensReturnDecrease=w.diff/w.currentPackTokenPriceBuyout;
                    if(w.UserTokensReturnAboveCurrentPack>=w.bonusTokensReturnDecrease){
                        w.UserTokensReturnAboveCurrentPack=w.UserTokensReturnAboveCurrentPack-w.bonusTokensReturnDecrease;
                        
                    }else{
                        w.diff=w.bonusTokensReturnDecrease-w.UserTokensReturnAboveCurrentPack;
                        w.UserTokensReturnAboveCurrentPack=0;
                        w.bonusTokensReturnDecrease=w.diff*w.currentPackTokenPriceBuyout/w.currentPackTokenPriceSellout;
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.bonusTokensReturnDecrease;
                    }
                }else{
                    w.bonusTokensReturnDecrease=w.diff/w.currentPackTokenPriceSellout;
                    if(w.UserTokensReturnToCurrentPack>=w.bonusTokensReturnDecrease){
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.bonusTokensReturnDecrease;
                    }
                }
            }
        }
        if(w.thisBal<=w.dsp){
            if(w.bonus>0){
                w.bonusToSend=0;
                w.diff=w.bonus;
                if(w.UserTokensReturnAboveCurrentPack>0){
                    w.bonusTokensReturnDecrease=w.diff/w.currentPackTokenPriceBuyout;
                    if(w.UserTokensReturnAboveCurrentPack>=w.bonusTokensReturnDecrease){
                        w.UserTokensReturnAboveCurrentPack=w.UserTokensReturnAboveCurrentPack-w.bonusTokensReturnDecrease;
                    }else{
                        w.diff=w.bonusTokensReturnDecrease-w.UserTokensReturnAboveCurrentPack;
                        w.UserTokensReturnAboveCurrentPack=0;
                        w.bonusTokensReturnDecrease=w.diff*w.currentPackTokenPriceBuyout/w.currentPackTokenPriceSellout;
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.bonusTokensReturnDecrease;
                    }
                }else{
                    w.bonusTokensReturnDecrease=w.diff/w.currentPackTokenPriceSellout;
                    if(w.UserTokensReturnToCurrentPack>=w.bonusTokensReturnDecrease){
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.bonusTokensReturnDecrease;
                    }
                }
            }
            if(w.withdrawAmt>w.thisBal){
                w.diff=w.withdrawAmt+100-w.thisBal;
                if(w.UserTokensReturnAboveCurrentPack>0){
                    w.TokensReturnDecrease=w.diff/w.currentPackTokenPriceBuyout;
                    if(w.UserTokensReturnAboveCurrentPack>=w.TokensReturnDecrease){
                        w.UserTokensReturnAboveCurrentPack=w.UserTokensReturnAboveCurrentPack-w.TokensReturnDecrease;
                        w.withdrawAmtAboveCurrentPack=w.UserTokensReturnAboveCurrentPack*w.currentPackTokenPriceBuyout;
                    }else{
                        w.diff=w.TokensReturnDecrease-w.UserTokensReturnAboveCurrentPack;
                        w.UserTokensReturnAboveCurrentPack=0;
                        w.TokensReturnDecrease=w.diff*w.currentPackTokenPriceBuyout/w.currentPackTokenPriceSellout;
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.TokensReturnDecrease;
                    }
                }else{
                    w.TokensReturnDecrease=w.diff/w.currentPackTokenPriceSellout;
                    if(w.UserTokensReturnToCurrentPack>=w.TokensReturnDecrease){
                        w.UserTokensReturnToCurrentPack=w.UserTokensReturnToCurrentPack-w.TokensReturnDecrease;
                        w.withdrawAmtToCurrentPack=w.UserTokensReturnToCurrentPack*w.currentPackTokenPriceSellout;
                    }
                }
                w.withdrawAmt=w.withdrawAmtToCurrentPack+w.withdrawAmtAboveCurrentPack;
                if(w.withdrawAmt>=w.useFromFirstRefunded){
                    w.withdrawAmt=w.withdrawAmt-w.useFromFirstRefunded;
                }else{
                    w.diff=w.useFromFirstRefunded-w.withdrawAmt;
                    w.withdrawAmt=0;
                    w.useFromFirstRefunded=w.useFromFirstRefunded-w.diff;
                }
                if(w.withdrawAmt>w.thisBal){
                    w.withdrawAmt=w.thisBal;
                }
            }
        }
        User storage user=users[w.useraddress];
        if(w.userAmtDepositCurrentPackTRUE>w.withdrawAmtToCurrentPack){
            user.UserAmtDepositCurrentPackTRUE=w.userAmtDepositCurrentPackTRUE-w.withdrawAmtToCurrentPack;
        }else{
            user.UserAmtDepositCurrentPackTRUE=0;
        }
        if(w.overallDisparityAmounts>w.useFromDisparity){
            OverallDisparityAmounts=w.overallDisparityAmounts-w.useFromDisparity;
        }else{
            OverallDisparityAmounts=0;
        }
        if(w.userBuyFirstPack==w.currentPackNumber && users[w.useraddress].UserBuyFirstDate>=w.currentPackStartDate){
            if(CurrentPackDisparityAmounts>w.useFromDisparity){
                CurrentPackDisparityAmounts=CurrentPackDisparityAmounts-w.useFromDisparity;
            }else{
                CurrentPackDisparityAmounts=0;
            }
        }
        if(w.overallRefunded>w.useFromFirstRefunded){
            OverallRefunded=w.overallRefunded-w.useFromFirstRefunded;
        }else{
            OverallRefunded=0;
        }
        if(w.currentPackDeposits>w.withdrawAmtToCurrentPack){
            CurrentPackDeposits=w.currentPackDeposits-w.withdrawAmtToCurrentPack;
        }else{
            CurrentPackDeposits=0;
        }
        w.UserTokensReturn=w.UserTokensReturnToCurrentPack+w.UserTokensReturnAboveCurrentPack;
        w.wAtoStore=w.withdrawAmt+w.useFromFirstRefunded+w.bonusToSend;
        w.userTotalAmtWithdrawal=w.userTotalAmtWithdrawal+w.wAtoStore;
        w.userTotalAmtWithdrawalCurrentPack=w.userTotalAmtWithdrawalCurrentPack+w.wAtoStore;
        OverallWithdrawals=OverallWithdrawals+w.wAtoStore;
        user.UserSellTokenPackNum=w.currentPackNumber;
        user.UserSellDate=now;
        user.UserTotalAmtWithdrawal=w.userTotalAmtWithdrawal;
        user.UserTotalAmtWithdrawalCurrentPack=w.userTotalAmtWithdrawalCurrentPack;
        user.UserWithdrawalFromFirstRefunded=w.userWithdrawalFromFirstRefunded;
        user.UserWithdrawalFromDisparity=w.userWithdrawalFromDisparity;
        emit Withdraw(w.useraddress, w.wAtoStore, w.useFromFirstRefunded, w.bonus, w.bonusToSend, w.currentPackNumber, w.UserTokensReturn, w.UserTokensReturnToCurrentPack, w.bonusTokensReturnDecrease, w.TokensReturnDecrease);
        if (w.UserTokensReturn==balances[w.useraddress]+1){
            w.UserTokensReturn=balances[w.useraddress];
            if (w.UserTokensReturnToCurrentPack==balances[w.useraddress]+1){
                w.UserTokensReturnToCurrentPack=balances[w.useraddress];
            }
            if (w.UserTokensReturnAboveCurrentPack==balances[w.useraddress]+1){
                w.UserTokensReturnAboveCurrentPack=balances[w.useraddress];
            }
        }
        transfer(w.useraddress, address(this), w.UserTokensReturn, w.returnTokenInCurrentPack, w.UserTokensReturnToCurrentPack, w.UserTokensReturnAboveCurrentPack);
        CurrentPackTokenAvailablePercent=balances[address(this)]/500000000000000;
        if(w.ra==true){
            restart(true);
        }
        if(w.withdrawAmt+w.bonus>0){
            w.useraddress.transfer(w.withdrawAmt+w.bonusToSend);
        }
    }

    function transfer(address _from, address _to, uint _value, bool _rttcp, uint _rtcp, uint _racp) internal returns (bool success) {
        balances[_from]=balances[_from].sub(_value); 
        if(_to==address(this)){ 
            if(_rttcp==true){
                balances[_to]=balances[_to].add(_rtcp);
            }else{
                balances[_to]=balances[_to];
            }
            totalSupply=totalSupply.sub(_racp);
        }else{
            balances[_to]=balances[_to].add(_value);
        }
        emit Transfer(_from, _to, _value); 
        return true;
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function mint(uint _value) internal returns (bool) {
        balances[address(this)]=balances[address(this)].add(_value);
        totalSupply=totalSupply.add(_value);
        return true;
    }
    
    event Deposit(address indexed addr, uint, uint, uint, uint, uint, uint, uint, uint, uint);
    event Withdraw(address indexed addr, uint, uint, uint, uint, uint, uint, uint, uint, uint);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event NextPack(uint indexed CurrentPackTokenPriceSellout, uint indexed CurrentPackTokenPriceBuyout);
}