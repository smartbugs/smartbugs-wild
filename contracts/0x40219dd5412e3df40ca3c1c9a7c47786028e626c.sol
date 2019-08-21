contract ICreditBIT {
    function totalSupply() constant returns (uint256 supply) {}
    function mintMigrationTokens(address _reciever, uint _amount) returns (uint error) {}
    function getAccountData(address _owner) constant returns (uint avaliableBalance, uint lockedBalance, uint bondMultiplier, uint lockedUntilBlock, uint lastBlockClaimed) {}
}

contract ICreditIDENTITY {
    function getAddressDescription(address _queryAddress) constant returns (string){}
}

contract ICreditDAOfund {
    function withdrawReward(address _destination) {}
    function setCreditBondContract(address _creditBondAddress) {}
    function setCreditBitContract(address _creditBitAddress) {}
    function setFundsCreditDaoAddress(address _creditDaoAddress) {}
    function claimBondReward() {}
    function setCreditDaoAddress(address _creditDaoAddress) {}
    function lockTokens(uint _multiplier) {}

}

contract CreditDAO {
    struct Election {
        uint startBlock;
        uint endBlock;
        uint totalCrbSupply;
        bool electionsFinished;

        uint nextCandidateIndex;
        mapping(uint => address) candidateIndex;
        mapping(address => uint) candidateAddyToIndexMap;
        mapping(uint => uint) candidateVotes;
        mapping(address => bool) candidates;

        mapping(address => bool) userHasVoted;

        address maxVotes;
        uint numOfMaxVotes;
        uint idProcessed;
    }

    uint public nextElectionIndex;
    mapping(uint => Election) public elections;

    address public creditCEO;
    uint public mandateInBlocks = 927530;
    uint public blocksPerMonth = 76235;

    ICreditBIT creditBitContract = ICreditBIT(0xAef38fBFBF932D1AeF3B808Bc8fBd8Cd8E1f8BC5);
    ICreditDAOfund creditDAOFund;

    modifier onlyCEO {
        require(msg.sender == creditCEO);
        _;
    }
    
    function CreditDAO() {
        elections[nextElectionIndex].startBlock = block.number;
        elections[nextElectionIndex].endBlock = block.number + blocksPerMonth;
        elections[nextElectionIndex].totalCrbSupply = creditBitContract.totalSupply();
        nextElectionIndex++;
    }

    // Election part
    function createNewElections() {
        require(elections[nextElectionIndex - 1].endBlock + mandateInBlocks < block.number);

        elections[nextElectionIndex].startBlock = block.number;
        elections[nextElectionIndex].endBlock = block.number + blocksPerMonth;
        elections[nextElectionIndex].totalCrbSupply = creditBitContract.totalSupply();
        nextElectionIndex++;

        creditCEO = 0x0;
    }

    function sumbitForElection() {
        require(elections[nextElectionIndex - 1].endBlock > block.number);
        require(!elections[nextElectionIndex - 1].candidates[msg.sender]);

        uint nextCandidateId = elections[nextElectionIndex].nextCandidateIndex;
        elections[nextElectionIndex - 1].candidateIndex[nextCandidateId] = msg.sender;
        elections[nextElectionIndex - 1].candidateAddyToIndexMap[msg.sender] = nextCandidateId;
        elections[nextElectionIndex - 1].nextCandidateIndex++;
        elections[nextElectionIndex - 1].candidates[msg.sender] = true;
        
    }

    function vote(address _participant) {
        require(elections[nextElectionIndex - 1].endBlock > block.number);
        
        uint avaliableBalance;
        uint lockedBalance;
        uint bondMultiplier; 
        uint lockedUntilBlock; 
        uint lastBlockClaimed; 
        (avaliableBalance, lockedBalance, bondMultiplier, lockedUntilBlock, lastBlockClaimed) = creditBitContract.getAccountData(msg.sender);
        require(lockedUntilBlock >= elections[nextElectionIndex - 1].endBlock);
        require(!elections[nextElectionIndex - 1].userHasVoted[msg.sender]);
        uint candidateId = elections[nextElectionIndex - 1].candidateAddyToIndexMap[_participant];
        elections[nextElectionIndex - 1].candidateVotes[candidateId] += lockedBalance;
        elections[nextElectionIndex - 1].userHasVoted[msg.sender] = true;
    }

    function finishElections(uint _iterations) {
        require(elections[nextElectionIndex - 1].endBlock < block.number);
        require(!elections[nextElectionIndex - 1].electionsFinished);

        uint curentVotes;
        uint nextCandidateId = elections[nextElectionIndex - 1].idProcessed;
        for (uint cnt = 0; cnt < _iterations; cnt++) {
            curentVotes = elections[nextElectionIndex - 1].candidateVotes[nextCandidateId];
            if (curentVotes > elections[nextElectionIndex - 1].numOfMaxVotes) {
                elections[nextElectionIndex - 1].maxVotes = elections[nextElectionIndex - 1].candidateIndex[nextCandidateId];
                elections[nextElectionIndex - 1].numOfMaxVotes = curentVotes;
            }
            nextCandidateId++;
        }
        elections[nextElectionIndex - 1].idProcessed = nextCandidateId;
        if (elections[nextElectionIndex - 1].candidateIndex[nextCandidateId] == 0x0) {
            creditCEO = elections[nextElectionIndex - 1].maxVotes;
            elections[nextElectionIndex - 1].electionsFinished = true;

            if (elections[nextElectionIndex - 1].numOfMaxVotes == 0) {
                elections[nextElectionIndex].startBlock = block.number;
                elections[nextElectionIndex].endBlock = block.number + blocksPerMonth;
                elections[nextElectionIndex].totalCrbSupply = creditBitContract.totalSupply();
                nextElectionIndex++;
            }
        }
    }

    // CEO part
    function claimBondReward() onlyCEO {
		creditDAOFund.claimBondReward();
	}

    function withdrawBondReward(address _addy) onlyCEO {
        creditDAOFund.withdrawReward(_addy);
    }

    function lockTokens(uint _multiplier) onlyCEO {
        creditDAOFund.lockTokens(_multiplier);
    }

    function setCreditBitContract(address _newCreditBitAddress) onlyCEO {
        creditBitContract = ICreditBIT(_newCreditBitAddress);
    }

    function setMandateInBlocks(uint _newMandateInBlocks) onlyCEO {
        mandateInBlocks = _newMandateInBlocks;
    }

    function setblocksPerMonth(uint _newblocksPerMonth) onlyCEO {
        blocksPerMonth = _newblocksPerMonth;
    }

    
    function setCreditDaoFund(address _newCreditDaoFundAddress) onlyCEO {
        creditDAOFund = ICreditDAOfund(_newCreditDaoFundAddress);
    }

    // Fund methods
    function setFundsCreditDaoAddress(address _creditDaoAddress) onlyCEO {
	    creditDAOFund.setCreditDaoAddress(_creditDaoAddress);
	}
	
	function setFundsCreditBitContract(address _creditBitAddress) onlyCEO {
        creditDAOFund.setCreditBitContract(_creditBitAddress);
	}
	
	function setFundsCreditBondContract(address _creditBondAddress) onlyCEO {
        creditDAOFund.setCreditBondContract(_creditBondAddress);
	}

    function getCreditFundAddress() constant returns (address) {
        return address(creditDAOFund);
    }

    function getCreditBitAddress() constant returns (address) {
        return address(creditBitContract);
    }
}