contract Big{
    function Big(){
        Creator=msg.sender;
    }

    uint8 CategoriesLength=0;
    mapping(uint8=>Category) Categories;//array representation
    struct Category{
        bytes4 Id;
        uint Sum;//moneys sum for category

        address Owner;
        uint8 ProjectsFee;
        uint8 OwnerFee;

        uint24 VotesCount;
        mapping(address=>uint24) Ranks;//small contract addr->rank
        mapping(uint24=>Vote) Votes;//array representation
    }
    struct Vote{
        address From;
        address To;
		uint8 TransactionId;
    }
    uint24 SmallContractsLength=0; 
    mapping(uint24=>address) SmallContracts;//array of small contracts
    
    address private Creator;//addres of god
    uint16 constant defaultRank=1000;
    uint8 constant koef=2/1;
	uint constant ThanksCost = 10 finney;

    function GetCategoryNumber(bytes4 categoryId) returns(uint8) {
        for (uint8 i=0;i<CategoriesLength;i++){
            if(Categories[i].Id==categoryId)
                return i;
        }
        return 255;
    }
    function GetCategoryValue(uint8 categoryNumber) returns (uint){ 
        return Categories[categoryNumber].Sum;
    }
	function CheckUserVote(uint8 categoryNumber,uint8 transactionId) returns (bool){
		for (uint24 i = Categories[categoryNumber].VotesCount-1;i >0;i--){
            if(Categories[categoryNumber].Votes[i].TransactionId==transactionId) 
                return true;     
        }
		if(Categories[categoryNumber].Votes[0].TransactionId==transactionId){
                return true;  
        }
		return false;
	}
    function GetUserRank(uint8 categoryNumber,address user) returns (uint24){ 
        return Categories[categoryNumber].Ranks[user];
    }
    function GetSmallCotractIndex(address small) returns (uint24){
        for (uint24 i=0;i<SmallContractsLength;i++){
            if(SmallContracts[i]==small)
                return i;
        }
        return 16777215;
    }
    
    function AddNewSmallContract(address small){
        if(msg.sender == Creator && GetSmallCotractIndex(small)==16777215){
                SmallContracts[SmallContractsLength]=small;
                SmallContractsLength++;
        }
    }
    function AddNewCategory(bytes4 categoryId,uint8 projectsFee,uint8 ownerFee, address owner){
        if(msg.sender == Creator && GetCategoryNumber(categoryId)==255){
            Categories[CategoriesLength].Id= categoryId;
            Categories[CategoriesLength].ProjectsFee= projectsFee;
            Categories[CategoriesLength].OwnerFee= ownerFee;
            Categories[CategoriesLength].Owner= owner;
            Categories[CategoriesLength].Sum = 0;
            CategoriesLength++;
        }
    }

    
	struct Calculation{
		uint16 totalVotes;
		uint24 rank;
	}
    function CalcAll(){
        if(msg.sender==Creator){//only god can call this method
            uint24 i;//iterator variable
			
            for(uint8 prC=0; prC<CategoriesLength; prC++){
                Category category = Categories[prC];
                
                uint16 smallsCount = 0;//count of small contracts that got some rank
                mapping(address=>Calculation) temporary;//who->votesCount  (tootal voes from address)
                //calc users total votes          
				
				for (i = 0;i < category.VotesCount;i++){
                    temporary[category.Votes[i].From].totalVotes = 0; 
                }	
				
                for (i = 0;i < category.VotesCount;i++){
					if(temporary[category.Votes[i].From].totalVotes == 0) {
						temporary[category.Votes[i].From].rank = category.Ranks[category.Votes[i].From];
					}
                    temporary[category.Votes[i].From].totalVotes++; 
					
                }			
				
                // calculate new additional ranks
                for (i = 0;i < category.VotesCount;i++){ //iterate for each vote in category
                    Vote vote=category.Votes[i];
                    category.Ranks[vote.To] += temporary[vote.From].rank / (temporary[vote.From].totalVotes * koef);//add this vote weight
								// weight of vote measures in the (voters rank/( count of voters total thanks * 2)
                }                          
            }
        }
    }
    
    function NormalizeMoney(){
        if(msg.sender==Creator){
            uint sumDifference=this.balance;
            uint transactionCost = 5 finney;
			uint8 luckyCategoryIndex = 255;
			
        	for (uint8 prC = 0;prC < CategoriesLength;prC++) {
        	    sumDifference -= Categories[prC].Sum;
        	    
        	    uint ownerFee = (Categories[prC].Sum * Categories[prC].OwnerFee) / 100;
        	    if (ownerFee >0) Categories[prC].Owner.send(ownerFee);
        	    Categories[prC].Sum -= ownerFee;
        	    
            	if (luckyCategoryIndex == 255 && Categories[prC].Sum > transactionCost){
            	    luckyCategoryIndex = prC;
            	}
        	}
        	
        	if (sumDifference > transactionCost){
        	    Creator.send(sumDifference - transactionCost);
        	}
        	else{
        	    if (luckyCategoryIndex != 255){
        	        Categories[luckyCategoryIndex].Sum -= (transactionCost - sumDifference);
        	    }
        	}
        }
    }
    
	function NormalizeRanks(){
		if(msg.sender==Creator){
			uint32 accuracyKoef = 100000; //magic number 100000 is for accuracy
		
			uint24 i=0;
			for(uint8 prC=0; prC<CategoriesLength; prC++){
                Category category = Categories[prC];
				uint additionalRanksSum = 0; //sum of all computed additional ranks (rank - default rank) in category
				uint16 activeSmallContractsInCategoryCount = 0;

				for(i = 0;i<SmallContractsLength;i++){
					if (category.Ranks[SmallContracts[i]] != 0){
						additionalRanksSum += category.Ranks[SmallContracts[i]] - defaultRank;
						activeSmallContractsInCategoryCount++;
					}			
				}

				if (additionalRanksSum > activeSmallContractsInCategoryCount * defaultRank)//normalize ranks if addition of ranks is more than all users can have
                {
					uint24 normKoef = uint24(additionalRanksSum / activeSmallContractsInCategoryCount);
					for (i = 0;i < SmallContractsLength;i++){
						if (category.Ranks[SmallContracts[i]] > defaultRank){
							category.Ranks[SmallContracts[i]] = defaultRank + uint24(((uint)(category.Ranks[SmallContracts[i]] - defaultRank) * defaultRank)/ normKoef);
						}
					}
					additionalRanksSum = activeSmallContractsInCategoryCount * defaultRank;
                }
				if (category.Sum > 0)
				{
					for (i = 0;i < SmallContractsLength;i++)
					{
						if (category.Ranks[SmallContracts[i]] > defaultRank)
						{
							//just split sum in deendence of what rank users have							
							smallContractsIncoming[i] += accuracyKoef*(category.Sum / (accuracyKoef*additionalRanksSum / (category.Ranks[SmallContracts[i]] - defaultRank)));
						}
					}
				}
			}	
		}
	}
    mapping(uint24=> uint) smallContractsIncoming;//stores ether count per small contract
    function SendAllMoney(){
        if(msg.sender==Creator) { 
            for (uint24 i = 0;i < SmallContractsLength;i++){
                if(smallContractsIncoming[i] > 0 ){//if more than 0.005 ether
                    SmallContracts[i].send(smallContractsIncoming[i]);//send ether to wallet
                    smallContractsIncoming[i]=0;
                }
            }
        }
    }
    function Reset(){
        if(msg.sender==Creator) { 
            for(uint8 prC=0; prC<CategoriesLength; prC++){//in each contract
              Categories[prC].VotesCount=0; //reset votes
              Categories[prC].Sum=0; //reset ether sum 
            }
        }
    }

    function GetMoney(uint weiAmount,address to){
        if(msg.sender==Creator) { 
            to.send(weiAmount);
        }
    }
    function SetRank(uint8 categoryNumber,address small,uint16 rank){
        if(msg.sender == Creator){
            Category category=Categories[categoryNumber];
            category.Ranks[small]=rank;
        }
    }
	
	function SetNewBigContract(address newBigContractAddress){
		if(msg.sender == Creator){
			for(uint24 i = 0;i<SmallContractsLength;i++){
				Small s= Small(SmallContracts[i]);	
				s.SetBigContract(newBigContractAddress);
			}
		}
	}
    
	function ThanksInternal (address from,address to, uint8 categoryNumber,uint8 transactionId) private {
        if(categoryNumber==255||GetSmallCotractIndex(from)==16777215||GetSmallCotractIndex(to)==16777215) return;
        
        Category category=Categories[categoryNumber];
		
		Small s= Small(from);
        s.GetMoney(ThanksCost,this);	
        category.Sum+=ThanksCost;
        
        if(category.Ranks[from]==0){
            category.Ranks[from]=defaultRank;
        }      
        if(category.Ranks[to]==0){
            category.Ranks[to]=defaultRank;
        }

		category.Votes[category.VotesCount].From=from;
        category.Votes[category.VotesCount].To=to;
		category.Votes[category.VotesCount].TransactionId=transactionId;
        category.VotesCount++;
    }	
	function Thanks (address from,address to,uint8 categoryNumber,uint8 transactionId){
		if(msg.sender != Creator) return;	
		ThanksInternal(from,to,categoryNumber,transactionId);
	}
	
    function UniversalFunction(uint8 functionNumber,bytes32 p1,bytes32 p2,bytes32 p3,bytes32 p4,bytes32 p5){
        if(GetSmallCotractIndex(msg.sender)==16777215) return;
        
        if(functionNumber == 1){
            ThanksInternal(msg.sender,address(p1),uint8(p2),0);
        }
        if(functionNumber == 2){
            Small s= Small(msg.sender);
            s.GetMoney(uint(p1),address(p2));
        }
    }
}


contract Small {
    Big b;
  
    address private owner;

    function Small(address bigAddress){
        b=Big(bigAddress);
        owner = msg.sender;
    }
    function GetOwner() returns (address){
        return owner;
    }
    function SetOwner(address newOwner){
        if(msg.sender == owner) {
            owner = newOwner;
        }
    }

    function SetBigContract(address newAddress){
        if(msg.sender==address(b)) { 
            b=Big(newAddress);
        }
    }
    function GetMoney(uint weiAmount,address toAddress){
        if(msg.sender==address(b)) { 
            toAddress.send(weiAmount);
        }
    }
    function UniversalFunctionSecure(uint8 functionNumber,bytes32 p1,bytes32 p2,bytes32 p3,bytes32 p4,bytes32 p5){
        if(msg.sender == owner) {
            b.UniversalFunction(functionNumber,p1,p2,p3,p4,p5);
        }
    }
}