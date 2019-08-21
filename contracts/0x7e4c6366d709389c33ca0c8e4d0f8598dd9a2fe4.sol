pragma solidity ^0.4.24;


contract FiveElements{
    
    
    uint[5] AvgGuesses;
    address constant private Admin=0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    address constant private Adam=0x9640a35e5345CB0639C4DD0593567F9334FfeB8a;
    address constant private Tummy=0x820090F4D39a9585a327cc39ba483f8fE7a9DA84;
    address constant private Willy=0xA4757a60d41Ff94652104e4BCdB2936591c74d1D;
    address constant private Nicky=0x89473CD97F49E6d991B68e880f4162e2CBaC3561;
    address constant private Artem=0xA7e8AFa092FAa27F06942480D28edE6fE73E5F88;
    address constant private FiveElementsAdministrationAddress=0x1f165ddAb085917437C6B15A5ed88E5B2c0B2dd9;
    
    
    //event LiveRankAndPrizePool();
    
    
    event ProofOfEntry(address indexed User,uint EntryPaid,uint GuessBTC,uint GuessETH,uint GuessLTC,uint GuessBCH,uint GuessXMR);
    
    
    event WisdomOfCrowdsEntry(address indexed User,uint EntryPaid,uint AvgGuessBTC,uint AvgGuessETH,uint AvgGuessLTC,uint AvgGuessBCH,uint AvgGuessXMR,uint ActivationCount);
    
    
    event ProofOfBettingMore(address indexed User,uint EtherPaid,uint NewEntryBalance);
    
    
    event ProofOfQuitting(address indexed User,uint EtherRefund,uint TotalPaid);
    
    
    event ReceivedFunds(address indexed Sender,uint Value);
    
    
    function Join(uint GuessBTC,uint GuessETH,uint GuessLTC,uint GuessBCH,uint GuessXMR) public payable{
        require(msg.value>0);
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        uint Min=FEA.GetMinEntry();
        if (msg.sender==Admin || msg.sender==Adam || msg.sender==Tummy || msg.sender==Willy || msg.sender==Nicky || msg.sender==Artem){
        }else{
            require(msg.value>=Min);
        }
        FiveElementsAdministrationAddress.transfer(msg.value);
        FEA.UserJoin(msg.sender,msg.value,GuessBTC,GuessETH,GuessLTC,GuessBCH,GuessXMR);
        emit ProofOfEntry(msg.sender,msg.value,GuessBTC,GuessETH,GuessLTC,GuessBCH,GuessXMR);
    }
    
    
    function BetMore() public payable{
        require(msg.value>0);
        FiveElementsAdministrationAddress.transfer(msg.value);
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        FEA.UpdateBetAmount(msg.sender,msg.value);
        emit ProofOfBettingMore(msg.sender,msg.value,FEA.GetBetAmount(msg.sender));
    }
    
    
    function WisdomOfTheCrowd() public payable{
        require(msg.value>0);
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        uint Min=FEA.GetMinEntry();
        if (msg.sender==Admin || msg.sender==Adam || msg.sender==Tummy || msg.sender==Willy || msg.sender==Nicky || msg.sender==Artem){
        }else{
            require(msg.value>=Min);
        }
        AvgGuesses=FEA.AverageOfAllGuesses();
        FiveElementsAdministrationAddress.transfer(msg.value);
        FEA.UserJoin(msg.sender,msg.value,AvgGuesses[0],AvgGuesses[1],AvgGuesses[2],AvgGuesses[3],AvgGuesses[4]);
        emit WisdomOfCrowdsEntry(msg.sender,msg.value,AvgGuesses[0],AvgGuesses[1],AvgGuesses[2],AvgGuesses[3],AvgGuesses[4],FEA.GetWisdomOfCrowdsActivationCount());
        delete AvgGuesses;
    }
    
    
    function QuitGameAndRefund(){
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        FEA.QuitAndRefund(msg.sender);
        uint Amount=FEA.GetBetAmount(msg.sender);
        uint FeePM=FEA.GetFeePerMillion();
        emit ProofOfQuitting(msg.sender,Amount*(1000000-FeePM)/1000000,Amount);
    }
    
    
    function () payable{
        FiveElementsAdministrationAddress.transfer(msg.value);
        emit ReceivedFunds(msg.sender,msg.value);
    }
    
    
}


contract FiveElementsAdministration{
    
    
    function GetBetAmount(address User)public returns(uint Amount);
    function UserJoin(address User,uint Value,uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE);
    function UpdateBetAmount(address User,uint Value);
    function GetMinEntry()public returns(uint MinEntry);
    function QuitAndRefund(address User);
    function GetFeePerMillion()public returns(uint FeePerMillion);
    function AverageOfAllGuesses()public returns(uint[5] AvgGuesses);
    function GetWisdomOfCrowdsActivationCount()public returns(uint );
    
    
}