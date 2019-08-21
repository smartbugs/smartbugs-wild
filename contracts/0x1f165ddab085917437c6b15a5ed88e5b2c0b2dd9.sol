pragma solidity ^0.4.24;


contract Ceil {
    
    
    function ceil(uint a, uint m) constant returns (uint ) {
        return ((a + m - 1) / m) * m;
    }
    
    
}


contract QuickSort {
    
    
    function sort(uint[] data) public constant returns(uint[]) {
       quickSort(data, int(0), int(data.length - 1));
       return data;
    }
    
    
    function quickSort(uint[] memory arr, int left, int right) internal{
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }
    
    
}


contract Abssub{
    
    
    function AbsSub(uint x,uint y) constant returns(uint ){
        if (x>=y){
            return(x-y);
        }else{
            return(y-x);
        }
    }
    
    
}


contract Rounding{
    
    
    function rounding(uint x) constant returns(uint ){
        if (x-(x/10)*10>=5){
            return(x/10+1);
        }else{
            return(x/10);
        }
    }
    
    
}


contract FiveElementsAdministration is QuickSort,Ceil,Abssub,Rounding{
    
    
    address[] Users;
    uint[5][] Guesses;
    uint[] EntryPaid;
    uint[5] Weights;
    uint[5] Ans;
    uint[5] AvgGuesses;
    uint[] ERaw;
    // Raw Error Datas
    uint[] Error;
    uint[] EST;
    // Error Datas Sorted and Trimmed
    address[] Winners;
    uint[] WinEntryPaid;
    uint MinEntryPrice;
    uint FeePM;
    // Fee Per Million
    uint ExpirationTime;
    uint Period;
    uint Round;
    uint WOCC;
    bool Frozen;
    address constant private Admin=0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    address constant private Adam=0x9640a35e5345CB0639C4DD0593567F9334FfeB8a;
    address constant private Tummy=0x820090F4D39a9585a327cc39ba483f8fE7a9DA84;
    address constant private Willy=0xA4757a60d41Ff94652104e4BCdB2936591c74d1D;
    address constant private Nicky=0x89473CD97F49E6d991B68e880f4162e2CBaC3561;
    address constant private Artem=0xA7e8AFa092FAa27F06942480D28edE6fE73E5F88;
    address FiveElementsContractAddress;
    
    
    //event ResultsAndPayouts(uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE,uint TotalWinners,uint TotalParticipants,uint PayoutsPerEtherEntry,uint TotalPrizePool,uint AverageEntryPaid);
    
    
    event ResultsAudit(uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE);
    
    
    event PayoutInfo(uint TotalWinners,uint TotalParticipants,uint PayoutsPerEtherEntry,uint TotalPrizePool,uint AverageEntryPaid);
    
    
    event NoPlayers();
    
    
    event Extension(uint extension,uint newExpirationTime);
    
    
    event Initialisation(uint EntryPrice,uint FeePerMillion,uint submissionPeriod,uint expirationTime,uint WA,uint WB,uint WC,uint WD,uint WE);
    
    
    event UserBetAmount(address indexed User,uint Amount);
    
    
    event RoundNumber(uint round);
    
    
    event FiveElementsAddressSet(address indexed FiveElementsAddress);
    
    
    event UserJoined(address indexed User,address indexed AddedBy,uint Value,uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE);
    
    
    event BetAmountUpdated(address indexed User,address indexed UpdatedBy,uint BetMoreAmount,uint TotalBetAmount);
    
    
    event LiveRanking(address indexed User,uint Rank,uint TotalPlayers,uint TotalEntryPaid);
    
    
    event MinEntryInWei(uint MinEntryValue);
    
    
    event WeightsSet(uint WA,uint WB,uint WC,uint WD,uint WE);
    
    
    event ContractFrozen(string Status);
    
    
    event ContractDefrosted(string Status);
    
    
    event FundsEjected(uint TotalEjected);
    
    
    event UserQuitGame(address indexed User,address indexed FunctionActivatedBy,uint TotalRefundAmount);
    
    
    event UserRefundAmount(address indexed User,address indexed FunctionActivatedBy,uint RefundAmount,uint NewEntryBalance);
    
    
    event Volume(uint PrizePool,uint TotalPlayers);
    
    
    event CurrentFeePerMillion(uint FeePerMillion);
    
    
    event AvgOfAllGuesses(uint AvgGuessA,uint AvgGuessB,uint AvgGuessC,uint AvgGuessD,uint AvgGuessE,uint ActivationCount);
    
    
    event ReceivedFunds(address indexed Sender,uint Value);
    
    
    function Results(uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE,bool Freeze){
        require(msg.sender==Admin || msg.sender==Adam);
        uint Bal=address(this).balance;
        Ans[0]=RealPriceA;
        Ans[1]=RealPriceB;
        Ans[2]=RealPriceC;
        Ans[3]=RealPriceD;
        Ans[4]=RealPriceE;
        require(Ans[0]>0 && Ans[1]>0 && Ans[2]>0 && Ans[3]>0 && Ans[4]>0);
        uint L=Users.length;
        if (L>0){
            for (uint k=0;k<L;k++){
                uint E=0;
                for (uint j=0;j<5;j++){
                    E=E+1000000*Weights[j]*AbsSub(Guesses[k][j],Ans[j])/Ans[j];
                }
                ERaw.push(E);
            }
            Error=sort(ERaw);
            uint store=Error[L-1]+1;
        for (k=0;k<L;k++){
            if (store!=Error[k]){
                EST.push(Error[k]);
                store=Error[k];
            }
        }
        uint M=EST[ceil(5*(EST.length),10)/10-1];
        uint Sum=0;
        for (k=0;k<L;k++){
            if (ERaw[k]<=M){
                Winners.push(Users[k]);
                WinEntryPaid.push(EntryPaid[k]);
                Sum=Sum+EntryPaid[k];
            }
        }
        uint WL=Winners.length;
        for (k=0;k<WL;k++){
            uint I=0;
            while (I<L&&Winners[k]!=Users[I]){
                I=I+1;
            }
            Users[I].transfer(EntryPaid[I]*Bal*(1000000-FeePM)/(1000000*Sum));
        }
        for (k=0;k<L;k++){
            for (j=0;j<5;j++){
                AvgGuesses[j]=AvgGuesses[j]+Guesses[k][j];
            }
        }
        for (j=0;j<5;j++){
            AvgGuesses[j]=rounding(10*AvgGuesses[j]/L);
        }
        emit AvgOfAllGuesses(AvgGuesses[0],AvgGuesses[1],AvgGuesses[2],AvgGuesses[3],AvgGuesses[4],WOCC);
        //emit ResultsAndPayouts(uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE,Winners.length,L,Bal/Sum,Bal,Bal/L);
        emit ResultsAudit(Ans[0],Ans[1],Ans[2],Ans[3],Ans[4]);
        emit PayoutInfo(Winners.length,L,Bal/Sum,Bal,Bal/L);
        }else{
        emit NoPlayers();
        emit ResultsAudit(Ans[0],Ans[1],Ans[2],Ans[3],Ans[4]);
        }
        Frozen=Freeze;
        Round=Round+1;
        ExpirationTime=now+Period;
        Adam.transfer(address(this).balance/2);
        Admin.transfer(address(this).balance);
        delete Users;
        delete Guesses;
        delete EntryPaid;
        delete AvgGuesses;
        delete ERaw;
        delete Error;
        delete EST;
        delete Winners;
        delete WinEntryPaid;
        delete WOCC;
    }
    
    
    function SetExtension(uint extension){
        require(msg.sender==Admin || msg.sender==Adam);
        ExpirationTime=ExpirationTime+extension;
        emit Extension(extension,ExpirationTime);
    }
    
    
    function Initialise(uint EntryPrice,uint FeePerMillion,uint SetSubmissionPeriod,uint WA,uint WB,uint WC,uint WD,uint WE,bool FirstRound){
        require(msg.sender==Admin || msg.sender==Adam);
        MinEntryPrice=EntryPrice;
        FeePM=FeePerMillion;
        Period=SetSubmissionPeriod;
        ExpirationTime=now+Period;
        Weights[0]=WA;
        Weights[1]=WB;
        Weights[2]=WC;
        Weights[3]=WD;
        Weights[4]=WE;
        if (FirstRound==true){
            Round=1;
        }
        Frozen=false;
        emit Initialisation(EntryPrice,FeePerMillion,SetSubmissionPeriod,ExpirationTime,WA,WB,WC,WD,WE);
        emit RoundNumber(Round);
    }
    
    
    function GetBetAmount(address User)public returns(uint Amount){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        if (k<L){
            Amount=EntryPaid[k];
        }else{
            Amount=0;
        }
        emit UserBetAmount(User,Amount);
    }
    
    
    function GetRoundNumber()public returns(uint round){
        round=Round;
        emit RoundNumber(round);
    }
    
    
    function SetFiveElementsAddress(address ContractAddress){
        require(msg.sender==Admin || msg.sender==Adam);
        FiveElementsContractAddress=ContractAddress;
        emit FiveElementsAddressSet(ContractAddress);
    }
    
    
    function UserJoin(address User,uint Value,uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        require(Frozen==false);
        require(Value>0);
        require(now<=ExpirationTime || msg.sender==Admin || msg.sender==Adam);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k>=L);
        Users.push(User);
        EntryPaid.push(Value);
        Guesses.push([GuessA,GuessB,GuessC,GuessD,GuessE]);
        emit UserJoined(User,msg.sender,Value,GuessA,GuessB,GuessC,GuessD,GuessE);
    }
    
    
    function UpdateBetAmount(address User,uint Value){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        require(Frozen==false);
        require(Value>0);
        require(now<=ExpirationTime+14400 || msg.sender==Admin || msg.sender==Adam);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k<L);
        EntryPaid[k]=EntryPaid[k]+Value;
        emit BetAmountUpdated(User,msg.sender,Value,EntryPaid[k]);
    }
    
    
    function GetCurrentRank(address User,uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE)public returns(uint Rank,uint TotalPlayers){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        Ans[0]=RealPriceA;
        Ans[1]=RealPriceB;
        Ans[2]=RealPriceC;
        Ans[3]=RealPriceD;
        Ans[4]=RealPriceE;
        require(Ans[0]>0 && Ans[1]>0 && Ans[2]>0 && Ans[3]>0 && Ans[4]>0);
        uint L=Users.length;
        require(L>0);
        for (uint k=0;k<L;k++){
                uint E=0;
                for (uint j=0;j<5;j++){
                    E=E+1000000*Weights[j]*AbsSub(Guesses[k][j],Ans[j])/Ans[j];
                }
                ERaw.push(E);
            }
            Error=sort(ERaw);
            uint store=Error[L-1]+1;
        for (k=0;k<L;k++){
            if (store!=Error[k]){
                EST.push(Error[k]);
                store=Error[k];
            }
        }
        k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k<L);
        uint TP=EST.length;
        j=0;
        while (ERaw[k]>=EST[j]){
            j=j+1;
        }
        TotalPlayers=TP;
        Rank=j;
        delete ERaw;
        delete Error;
        delete EST;
        emit LiveRanking(User,Rank,TotalPlayers,EntryPaid[k]);
    }
    
    
    function GetMinEntry()public returns(uint MinEntry){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        MinEntry=MinEntryPrice;
        emit MinEntryInWei(MinEntry);
    }
    
    
    function SetWeights(uint WA,uint WB,uint WC,uint WD,uint WE){
        require(msg.sender==Admin || msg.sender==Adam);
        Weights[0]=WA;
        Weights[1]=WB;
        Weights[2]=WC;
        Weights[3]=WD;
        Weights[4]=WE;
        emit WeightsSet(WA,WB,WC,WD,WE);
    }
    
    
    function FreezeContract(){
        require(msg.sender==Admin || msg.sender==Adam);
        require(Frozen==false);
        Frozen=true;
        emit ContractFrozen("Frozen");
    }
    
    
    function UnfreezeContract(){
        require(msg.sender==Admin || msg.sender==Adam);
        require(Frozen==true);
        Frozen=false;
        emit ContractDefrosted("Defrosted");
    }
    
    
    function FreezeContractAndEjectFunds(){
        require(msg.sender==Admin || msg.sender==Adam);
        Frozen=true;
        uint Bal=address(this).balance;
        uint L=Users.length;
        for (uint k=0;k<L;k++){
            Users[k].transfer(EntryPaid[k]);
        }
        emit ContractFrozen("Frozen");
        emit FundsEjected(Bal);
        delete Users;
        delete Guesses;
        delete EntryPaid;
    }
    
    
    function QuitAndRefund(address User){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        require(now<=ExpirationTime || msg.sender==Admin || msg.sender==Adam);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k<L);
        if (User==Admin || User==Adam){
            User.transfer(EntryPaid[k]);
        }else{
        User.transfer(EntryPaid[k]*(1000000-FeePM)/1000000);
        Admin.transfer(EntryPaid[k]*FeePM/2000000);
        Adam.transfer(EntryPaid[k]*FeePM/2000000);
        }
        emit UserQuitGame(User,msg.sender,EntryPaid[k]);
        delete Users[k];
        delete Guesses[k];
        delete EntryPaid[k];
    }
    
    
    function RefundAmount(address User,uint Amount){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        require(now<=ExpirationTime || msg.sender==Admin || msg.sender==Adam);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k<L);
        require(EntryPaid[k]>Amount && ((EntryPaid[k]-Amount)>=MinEntryPrice || User==Admin || User==Adam || User==Tummy || User==Willy || User==Nicky || User==Artem));
        if (User==Admin || User==Adam){
            User.transfer(Amount);
        }else{
        User.transfer(Amount*(1000000-FeePM)/1000000);
        Admin.transfer(Amount*FeePM/2000000);
        Adam.transfer(Amount*FeePM/2000000);
        }
        EntryPaid[k]=EntryPaid[k]-Amount;
        emit UserRefundAmount(User,msg.sender,Amount,EntryPaid[k]);
    }
    
    
    function GetBetVolume(){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        uint L=Users.length;
        uint Bal=address(this).balance;
        emit Volume(Bal,L);
    }
    
    
    function GetFeePerMillion()public returns(uint FeePerMillion){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        FeePerMillion=FeePM;
        emit CurrentFeePerMillion(FeePerMillion);
    }
    
    
    function AverageOfAllGuesses()public returns(uint[5] ){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        uint L=Users.length;
        require(L>0 || msg.sender==Admin || msg.sender==Adam);
        if (L>0){
        require((now<=ExpirationTime && now+7200>=ExpirationTime) || msg.sender==Admin || msg.sender==Adam);
        require(WOCC<=5 || msg.sender==Admin || msg.sender==Adam);
        for (uint k=0;k<L;k++){
            for (uint j=0;j<5;j++){
                AvgGuesses[j]=AvgGuesses[j]+Guesses[k][j];
            }
        }
        for (j=0;j<5;j++){
            AvgGuesses[j]=rounding(10*AvgGuesses[j]/L);
        }
        if (msg.sender==Admin || msg.sender==Adam){
        }else{
        WOCC=WOCC+1;
        }
        return AvgGuesses;
        emit AvgOfAllGuesses(AvgGuesses[0],AvgGuesses[1],AvgGuesses[2],AvgGuesses[3],AvgGuesses[4],WOCC);
        delete AvgGuesses;
        }else{
        emit NoPlayers();
        }
    }
    
    
    function GetWisdomOfCrowdsActivationCount()public returns(uint ){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        return(WOCC);
    }
    
    
    function () public payable{
        emit ReceivedFunds(msg.sender,msg.value);
    }
    
    
}