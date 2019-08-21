contract SafeMath {
    
    uint256 constant MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        require(x <= MAX_UINT256 - y);
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        require(x >= y);
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) {
            return 0;
        }
        require(x <= (MAX_UINT256 / y));
        return x * y;
    }
}

contract ReentrancyHandlingContract{

    bool locked;

    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
}
contract Owned {
    address public owner;
    address public newOwner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

contract Lockable is Owned {

    uint256 public lockedUntilBlock;

    event ContractLocked(uint256 _untilBlock, string _reason);

    modifier lockAffected {
        require(block.number > lockedUntilBlock);
        _;
    }

    function lockFromSelf(uint256 _untilBlock, string _reason) internal {
        lockedUntilBlock = _untilBlock;
        ContractLocked(_untilBlock, _reason);
    }


    function lockUntil(uint256 _untilBlock, string _reason) onlyOwner public {
        lockedUntilBlock = _untilBlock;
        ContractLocked(_untilBlock, _reason);
    }
}

contract LinkedList {

	struct Element {
    	uint previous;
    	uint next;

    	address data;
  	}

  	uint public size;
  	uint public tail;
  	uint public head;
  	mapping(uint => Element) elements;
  	mapping(address => uint) elementLocation;

	function addItem(address _newItem) returns (bool) {
		Element memory elem = Element(0, 0, _newItem);

		if (size == 0) {
        	head = 1;
      	} else {
        	elements[tail].next = tail + 1;
        	elem.previous = tail;
      	}

      	elementLocation[_newItem] = tail + 1;
      	elements[tail + 1] = elem;
      	size++;
      	tail++;
      	return true;
	}

    function removeItem(address _item) returns (bool) {
        uint key;
        if (elementLocation[_item] == 0) {
            return false;
        }else {
            key = elementLocation[_item];
        }

        if (size == 1) {
            tail = 0;
            head = 0;
        }else if (key == head) {
            head = elements[head].next;
        }else if (key == tail) {
            tail = elements[tail].previous;
            elements[tail].next = 0;
        }else {
            elements[key - 1].next = elements[key].next;
            elements[key + 1].previous = elements[key].previous;
        }

        size--;
        delete elements[key];
        elementLocation[_item] = 0;
        return true;
    }

    function getAllElements() constant returns(address[]) {
        address[] memory tempElementArray = new address[](size);
        uint cnt = 0;
        uint currentElemId = head;
        while (cnt < size) {
            tempElementArray[cnt] = elements[currentElemId].data;
            currentElemId = elements[currentElemId].next;
            cnt += 1;
        }
        return tempElementArray;
    }

    function getElementAt(uint _index) constant returns (address) {
        return elements[_index].data;
    }

    function getElementLocation(address _element) constant returns (uint) {
        return elementLocation[_element];
    }

    function getNextElement(uint _currElementId) constant returns (uint) {
        return elements[_currElementId].next;
    }
}

contract RootDonationsContract is Owned {

    LinkedList donationsList = new LinkedList();

    function addNewDonation(address _donationAddress) public onlyOwner {
        require(donationsList.getElementLocation(_donationAddress) != 0);
        donationsList.addItem(_donationAddress);
    }

    function removeDonation(address _donationAddress) public onlyOwner {
        require(donationsList.getElementLocation(_donationAddress) == 0);
        donationsList.removeItem(_donationAddress);
    }

    function getDonations() constant public returns (address[]) {
        address[] memory tempElementArray = new address[](donationsList.size());
        uint cnt = 0;
        uint tempArrayCnt = 0;
        uint currentElemId = donationsList.head();
        while (cnt < donationsList.size()) {
            tempElementArray[tempArrayCnt] = donationsList.getElementAt(currentElemId);
            
            currentElemId = donationsList.getNextElement(currentElemId);
            cnt++;
            return tempElementArray;
        }
        
    }
}

contract DonationContract is Owned {

    struct ContributorData {
        bool active;
        uint contributionAmount;
        bool hasVotedForDisable;
    }
    mapping(address => ContributorData) public contributorList;
    uint public nextContributorIndex;
    mapping(uint => address) public contributorIndexes;
    uint public nextContributorToReturn;

    enum phase { pendingStart, started, EndedFail, EndedSucess, disabled, finished}
    phase public donationPhase;

    uint public maxCap;
    uint public minCap;

    uint public donationsStartTime;
    uint public donationsEndedTime;

    address tokenAddress;
    uint public tokensDonated;

    event MinCapReached(uint blockNumber);
    event MaxCapReached(uint blockNumber);
    event FundsClaimed(address athlete, uint _value, uint blockNumber);

    uint public athleteCanClaimPercent;
    uint public tick;
    uint public lastClaimed;
    uint public athleteAlreadyClaimed;
    address public athlete;
    uint public contractFee;
    address public feeWallet;

    uint public tokensVotedForDisable;










    function DonationContract(  address _tokenAddress,
                                uint _minCap,
                                uint _maxCap,
                                uint _donationsStartTime,
                                uint _donationsEndedTime,
                                uint _athleteCanClaimPercent,
                                uint _tick,
                                address _athlete,
                                uint _contractFee,
                                address _feeWallet) {
        tokenAddress = _tokenAddress;
        minCap = _minCap;
        maxCap = _maxCap;
        donationsStartTime = _donationsStartTime;
        donationsEndedTime = _donationsEndedTime;
        donationPhase = phase.pendingStart;
        require(_athleteCanClaimPercent <= 100);
        athleteCanClaimPercent = _athleteCanClaimPercent;
        tick = _tick;
        athlete = _athlete;
        require(_athleteCanClaimPercent <= 100);
        contractFee = _contractFee;
        feeWallet = _feeWallet;
    }

    function receiveApproval(address _from, uint256 _value, address _to, bytes _extraData) public {
        require(_to == tokenAddress);
        require(_value != 0);

        if (donationPhase == phase.pendingStart) {
            if (now >= donationsStartTime) {
                donationPhase = phase.started;
            } else {
                revert();
            }
        }

        if(donationPhase == phase.started) {
            if (now > donationsEndedTime){
                if(tokensDonated >= minCap){
                    donationPhase = phase.EndedSucess;
                }else{
                    donationPhase = phase.EndedFail;
                }
            }else{
                uint tokensToTake = processTransaction(_from, _value);
                ERC20TokenInterface(tokenAddress).transferFrom(_from, address(this), tokensToTake);
            }
        }else{
            revert();
        }
    }

    function processTransaction(address _from, uint _value) internal returns (uint) {
        uint valueToProcess = 0;
        if (tokensDonated + _value >= maxCap) {
            valueToProcess = maxCap - tokensDonated;
            donationPhase = phase.EndedSucess;
            MaxCapReached(block.number);
        } else {
            valueToProcess = _value;
            if (tokensDonated < minCap && tokensDonated + valueToProcess >= minCap) {
                MinCapReached(block.number);
            }
        }
        if (!contributorList[_from].active) {
            contributorList[_from].active = true;
            contributorList[_from].contributionAmount = valueToProcess;
            contributorIndexes[nextContributorIndex] = _from;
            nextContributorIndex++;
        }else{
            contributorList[_from].contributionAmount += valueToProcess;
        }
        tokensDonated += valueToProcess;
        return valueToProcess;
    }

    function manuallyProcessTransaction(address _from, uint _value) onlyOwner public {
        require(_value != 0);
        require(ERC20TokenInterface(tokenAddress).balanceOf(address(this)) >= _value + tokensDonated);

        if (donationPhase == phase.pendingStart) {
            if (now >= donationsStartTime) {
                donationPhase = phase.started;
            } else {
                ERC20TokenInterface(tokenAddress).transfer(_from, _value);
            }
        }

        if(donationPhase == phase.started) {
            uint tokensToTake = processTransaction(_from, _value);
            ERC20TokenInterface(tokenAddress).transfer(_from, _value - tokensToTake);
        }else{
            ERC20TokenInterface(tokenAddress).transfer(_from, _value);
        }
    }

    function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner public {
        require(_tokenAddress != tokenAddress);
        ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
    }

    function claimFunds() public {
        require(donationPhase == phase.EndedSucess);
        require(athleteAlreadyClaimed < tokensDonated);
        require(athlete == msg.sender);
        if (lastClaimed == 0) {
            lastClaimed = now;
        } else {
            require(lastClaimed + tick <= now);
        }
        uint claimAmount = (athleteCanClaimPercent * tokensDonated) / 100;
        if (athleteAlreadyClaimed + claimAmount >= tokensDonated) {
            claimAmount = tokensDonated - athleteAlreadyClaimed;
            donationPhase = phase.finished;
        }
        athleteAlreadyClaimed += claimAmount;
        lastClaimed += tick;
        uint fee = (claimAmount * contractFee) / 100;
        ERC20TokenInterface(tokenAddress).transfer(athlete, claimAmount - fee);
        ERC20TokenInterface(tokenAddress).transfer(feeWallet, fee);
        FundsClaimed(athlete, claimAmount, block.number);
    }

    function disableDonationContract() public {
        require(msg.sender == athlete);
        require(donationPhase == phase.EndedSucess);

        donationPhase = phase.disabled;
    }

    function voteForDisable() public {
        require(donationPhase == phase.EndedSucess);
        require(contributorList[msg.sender].active);
        require(!contributorList[msg.sender].hasVotedForDisable);

        tokensVotedForDisable += contributorList[msg.sender].contributionAmount;
        contributorList[msg.sender].hasVotedForDisable = true;

        if (tokensVotedForDisable >= tokensDonated/2) {
            donationPhase = phase.disabled;
        }
    }

    function batchReturnTokensIfFailed(uint _numberOfReturns) public {
        require(donationPhase == phase.EndedFail);
        address currentParticipantAddress;
        uint contribution;
        for (uint cnt = 0; cnt < _numberOfReturns; cnt++) {
            currentParticipantAddress = contributorIndexes[nextContributorToReturn];
            if (currentParticipantAddress == 0x0) {
                donationPhase = phase.finished;
                return;
            }
            contribution = contributorList[currentParticipantAddress].contributionAmount;
            ERC20TokenInterface(tokenAddress).transfer(currentParticipantAddress, contribution);
            nextContributorToReturn += 1;
        }
    }

    function batchReturnTokensIfDisabled(uint _numberOfReturns) public {
        require(donationPhase == phase.disabled);
        address currentParticipantAddress;
        uint contribution;
        for (uint cnt = 0; cnt < _numberOfReturns; cnt++) {
            currentParticipantAddress = contributorIndexes[nextContributorToReturn];
            if (currentParticipantAddress == 0x0) {
                donationPhase = phase.finished;
                return;
            }
            contribution = (contributorList[currentParticipantAddress].contributionAmount * (tokensDonated - athleteAlreadyClaimed)) / tokensDonated;
            ERC20TokenInterface(tokenAddress).transfer(currentParticipantAddress, contribution);
            nextContributorToReturn += 1;
        }
    }

    function getSaleFinancialData() public constant returns(uint,uint){
        return (tokensDonated, maxCap);
    }

    function getClaimedFinancialData() public constant returns(uint,uint){
        return (athleteAlreadyClaimed, tokensDonated);
    }
}


contract ERC20TokenInterface {
  function totalSupply() public constant returns (uint256 _totalSupply);
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract tokenRecipientInterface {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}
contract SportifyTokenInterface {
    function mint(address _to, uint256 _amount) public;
}