pragma solidity ^0.4.18;

library SafeMath {
    // ------------------------------------------------------------------------
    // Add a number to another number, checking for overflows
    // ------------------------------------------------------------------------
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    // ------------------------------------------------------------------------
    // Subtract a number from another number, checking for underflows
    // ------------------------------------------------------------------------
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
	
}

contract Owned {

    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

interface token {
    function transfer(address receiver, uint amount) public returns (bool success) ;
	function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract ALCCrowdsale2 is Owned{
    using SafeMath for uint256;
    using SafeMath for uint;
	
	struct ContributorData{
		bool isActive;
		bool isTokenDistributed;
		uint contributionAmount;	// ETH contribution
		uint tokensAmount;			// Exchanged ALC amount
	}
	
	mapping(address => ContributorData) public contributorList;
	mapping(uint => address) contributorIndexes;
	uint nextContributorIndex;
	uint contributorCount;
    
    address public beneficiary;
    uint public fundingLimit;
    uint public amountRaised;
	uint public remainAmount;
    uint public deadline;
    uint public exchangeTokenRate;
    token public tokenReward;
	uint256 public tokenBalance;
    bool public crowdsaleClosed = false;
    bool public isALCDistributed = false;
    

    // ------------------------------------------------------------------------
    // Tranche 1 crowdsale start date and end date
    // Start - 23h00
    // Tier1  - 23h05
    // Tier2  - 23h10
    // Tier3  - 23h15
    // End - 23h20
    // ------------------------------------------------------------------------
    uint public constant START_TIME = 1511614800;
    uint public constant SECOND_TIER_SALE_START_TIME = 1511615100;
    uint public constant THIRD_TIER_SALE_START_TIME = 1511615400;
    uint public constant FOURTH_TIER_SALE_START_TIME = 1511615700;
    uint public constant END_TIME = 1511616000;
	
	
    
    // ------------------------------------------------------------------------
    // crowdsale exchange rate
    // ------------------------------------------------------------------------
    uint public START_RATE = 15000;
    uint public SECOND_TIER_RATE = 14000;
    uint public THIRD_TIER_RATE = 12500;
    uint public FOURTH_RATE = 10000;
    

    // ------------------------------------------------------------------------
    // Funding Goal
    //    - HARD CAP : 33000 ETH
    // ------------------------------------------------------------------------
    uint public constant FUNDING_ETH_HARD_CAP = 150000000000000000; //0.15ETH
    
    // IQT token decimals
    uint8 public constant ALC_DECIMALS = 8;
    uint public constant ALC_DECIMALSFACTOR = 10**uint(ALC_DECIMALS);
    
    address public constant ALC_FOUNDATION_ADDRESS = 0x55BeA1A0335A8Ea56572b8E66f17196290Ca6467;
    address public constant ALC_CONTRACT_ADDRESS = 0xB15EF419bA0Dd1f5748c7c60e17Fe88e6e794950;

    event GoalReached(address raisingAddress, uint amountRaised);
	event LimitReached(address raisingAddress, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
	event WithdrawFailed(address raisingAddress, uint amount, bool isContribution);
	event FundReturn(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function ALCCrowdsale2(
    ) public {
        beneficiary = ALC_FOUNDATION_ADDRESS;
        fundingLimit = FUNDING_ETH_HARD_CAP;  // Funding limit 0.01ETH
	    deadline = END_TIME;  // 2017-11-25 12:00:00 UTC
        exchangeTokenRate = FOURTH_RATE * ALC_DECIMALSFACTOR;
        tokenReward = token(ALC_CONTRACT_ADDRESS);
		contributorCount = 0;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () public payable {
		
        require(!crowdsaleClosed);
        require(now >= START_TIME && now < END_TIME);
        
		processTransaction(msg.sender, msg.value);
    }
	
	/**
	 * Process transaction
	 */
	function processTransaction(address _contributor, uint _amount) internal{	
		uint contributionEthAmount = _amount;
			
        amountRaised += contributionEthAmount;                    // add newly received ETH
		remainAmount += contributionEthAmount;
        
		// calcualte exchanged token based on exchange rate
        if (now >= START_TIME && now < SECOND_TIER_SALE_START_TIME){
			exchangeTokenRate = START_RATE * ALC_DECIMALSFACTOR;
        }
        if (now >= SECOND_TIER_SALE_START_TIME && now < THIRD_TIER_SALE_START_TIME){
            exchangeTokenRate = SECOND_TIER_RATE * ALC_DECIMALSFACTOR;
        }
        if (now >= THIRD_TIER_SALE_START_TIME && now < FOURTH_TIER_SALE_START_TIME){
            exchangeTokenRate = THIRD_TIER_RATE * ALC_DECIMALSFACTOR;
        }
        if (now >= FOURTH_TIER_SALE_START_TIME && now < END_TIME){
            exchangeTokenRate = FOURTH_RATE * ALC_DECIMALSFACTOR;
        }
        uint amountIqtToken = _amount * exchangeTokenRate / 1 ether;
		
		if (contributorList[_contributor].isActive == false){                  // Check if contributor has already contributed
			contributorList[_contributor].isActive = true;                            // Set his activity to true
			contributorList[_contributor].contributionAmount = contributionEthAmount;    // Set his contribution
			contributorList[_contributor].tokensAmount = amountIqtToken;
			contributorList[_contributor].isTokenDistributed = false;
			contributorIndexes[nextContributorIndex] = _contributor;                  // Set contributors index
			nextContributorIndex++;
			contributorCount++;
		}
		else{
			contributorList[_contributor].contributionAmount += contributionEthAmount;   // Add contribution amount to existing contributor
			contributorList[_contributor].tokensAmount += amountIqtToken;             // log token amount`
		}
		
        FundTransfer(msg.sender, contributionEthAmount, true);
		
		if (amountRaised >= fundingLimit){
			// close crowdsale because the crowdsale limit is reached
			crowdsaleClosed = true;
		}		
		
	}

    modifier afterDeadline() { if (now >= deadline) _; }	
	modifier afterCrowdsaleClosed() { if (crowdsaleClosed == true || now >= deadline) _; }
	
	
	/**
     * close Crowdsale
     *
     */
	function closeCrowdSale() public {
		require(beneficiary == msg.sender);
		if ( beneficiary == msg.sender) {
			crowdsaleClosed = true;
		}
	}
	
    /**
     * Check token balance
     *
     */
	function checkTokenBalance() public {
		if ( beneficiary == msg.sender) {
			//check current token balance
			tokenBalance = tokenReward.balanceOf(address(this));
		}
	}
	
    /**
     * Withdraw the all funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. 
     */
    function safeWithdrawalAll() public {
        if ( beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
				remainAmount = remainAmount - amountRaised;
            } else {
				WithdrawFailed(beneficiary, amountRaised, false);
				//If we fail to send the funds to beneficiary
            }
        }
    }
	
	/**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. 
     */
    function safeWithdrawalAmount(uint256 withdrawAmount) public {
        if (beneficiary == msg.sender) {
            if (beneficiary.send(withdrawAmount)) {
                FundTransfer(beneficiary, withdrawAmount, false);
				remainAmount = remainAmount - withdrawAmount;
            } else {
				WithdrawFailed(beneficiary, withdrawAmount, false);
				//If we fail to send the funds to beneficiary
            }
        }
    }
	
	/**
	 * Withdraw ALC 
     * 
	 * If there are some remaining ALC in the contract 
	 * after all token are distributed the contributor,
	 * the beneficiary can withdraw the ALC in the contract
     *
     */
    function withdrawALC(uint256 tokenAmount) public afterCrowdsaleClosed {
		require(beneficiary == msg.sender);
        if (isALCDistributed && beneficiary == msg.sender) {
            tokenReward.transfer(beneficiary, tokenAmount);
			// update token balance
			tokenBalance = tokenReward.balanceOf(address(this));
        }
    }
	

	/**
     * Distribute token
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * distribute token to contributor. 
     */
	function distributeALCToken() public {
		if (beneficiary == msg.sender) {  // only ALC_FOUNDATION_ADDRESS can distribute the ALC
			address currentParticipantAddress;
			for (uint index = 0; index < contributorCount; index++){
				currentParticipantAddress = contributorIndexes[index]; 
				
				uint amountAlcToken = contributorList[currentParticipantAddress].tokensAmount;
				if (false == contributorList[currentParticipantAddress].isTokenDistributed){
					bool isSuccess = tokenReward.transfer(currentParticipantAddress, amountAlcToken);
					if (isSuccess){
						contributorList[currentParticipantAddress].isTokenDistributed = true;
					}
				}
			}
			
			// check if all ALC are distributed
			checkIfAllALCDistributed();
			// get latest token balance
			tokenBalance = tokenReward.balanceOf(address(this));
		}
	}
	
	/**
     * Distribute token by batch
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * distribute token to contributor. 
     */
	function distributeALCTokenBatch(uint batchUserCount) public {
		if (beneficiary == msg.sender) {  // only ALC_FOUNDATION_ADDRESS can distribute the ALC
			address currentParticipantAddress;
			uint transferedUserCount = 0;
			for (uint index = 0; index < contributorCount && transferedUserCount<batchUserCount; index++){
				currentParticipantAddress = contributorIndexes[index]; 
				
				uint amountAlcToken = contributorList[currentParticipantAddress].tokensAmount;
				if (false == contributorList[currentParticipantAddress].isTokenDistributed){
					bool isSuccess = tokenReward.transfer(currentParticipantAddress, amountAlcToken);
					transferedUserCount = transferedUserCount + 1;
					if (isSuccess){
						contributorList[currentParticipantAddress].isTokenDistributed = true;
					}
				}
			}
			
			// check if all ALC are distributed
			checkIfAllALCDistributed();
			// get latest token balance
			tokenBalance = tokenReward.balanceOf(address(this));
		}
	}
	
	/**
	 * Check if all contributor's token are successfully distributed
	 */
	function checkIfAllALCDistributed() public {
	    address currentParticipantAddress;
		isALCDistributed = true;
		for (uint index = 0; index < contributorCount; index++){
				currentParticipantAddress = contributorIndexes[index]; 
				
			if (false == contributorList[currentParticipantAddress].isTokenDistributed){
				isALCDistributed = false;
				break;
			}
		}
	}
	
}