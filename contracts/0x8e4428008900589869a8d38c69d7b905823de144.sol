pragma solidity ^0.4.25;

// just ownable contract
contract Ownable {
    address public owner;

    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// Pausable contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    // Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    // Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }


    // Сalled by the owner to pause, triggers stopped state
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    // Сalled by the owner to unpause, returns to normal state
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

// Interface for pet contract
contract ParentInterface {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function getPet(uint256 _id) external view returns (uint64 birthTime, uint256 genes,uint64 breedTimeout,uint16 quality,address owner);
    function totalSupply() public view returns (uint);
}

// Simple utils, which calculate circle seats and grade by quality
contract Utils {
    
    function getGradeByQuailty(uint16 quality) public pure returns (uint8 grade) {
        
        require(quality <= uint16(0xF000));
        require(quality >= uint16(0x1000));
        
        if(quality == uint16(0xF000))
            return 7;
        
        quality+= uint16(0x1000);
        
        return uint8 ( quality / uint16(0x2000) );
    }
    
    function seatsByGrade(uint8 grade) public pure returns(uint8 seats) {
	    if(grade > 4)
	        return 1;
	
		seats = 8 - grade - 2;

		return seats;
	}
}

// Main contract, which calculating queue
contract ReferralQueue {
    
    // ID in circle
    uint64 currentReceiverId = 1;

    // Circle length
    uint64 public circleLength;
    
    // Store queue of referral circle
    struct ReferralSeat {
        uint64 petId;
        uint64 givenPetId;
    }
    
    mapping (uint64 => ReferralSeat) public referralCircle;
    
    // Store simple information about each pet: parent parrot and current referral reward
    struct PetInfo {
        uint64 parentId;
        uint256 amount;
    }
    
    mapping (uint64 => PetInfo) public petsInfo;

    
    function addPetIntoCircle(uint64 _id, uint8 _seats) internal {
        
        // Adding seats into queue
        for(uint8 i=0; i < _seats; i++)
		{
		    ReferralSeat memory _seat = ReferralSeat({
                petId: _id,
                givenPetId: 0
            });

            // Increasing circle length and save current seat in circle            
            circleLength++;
            referralCircle[circleLength] = _seat;
		}
		
		// Attach the parrot to the current receiver in the circle 
		// First 3 parrots adding without attaching
		if(_id>103) {
		    
		    referralCircle[currentReceiverId].givenPetId = _id;
		    
		    // adding new pet into information list
		    PetInfo memory petInfo = PetInfo({
		        parentId: referralCircle[currentReceiverId].petId,
		        amount: 0
		    });
		    
		    petsInfo[_id] = petInfo;
		    
		    // Increace circle receiver ID
            currentReceiverId++;
        }
    }
    
    // Current pet ID in circle for automatical attach
    function getCurrentReceiverId() view public returns(uint64 receiverId) {
        
        return referralCircle[currentReceiverId].petId;
    }
}

contract Reward is ReferralQueue {
    
    // Getting egg price by id and quality
    function getEggPrice(uint64 _petId, uint16 _quality) pure public returns(uint256 price) {
        		
        uint64[6] memory egg_prices = [0, 150 finney, 600 finney, 3 ether, 12 ether, 600 finney];
        
		uint8 egg = 2;
	
		if(_quality > 55000)
		    egg = 1;
			
		if(_quality > 26000 && _quality < 26500)
			egg = 3;
			
		if(_quality > 39100 && _quality < 39550)
			egg = 3;
			
		if(_quality > 31000 && _quality < 31250)
			egg = 4;
			
		if(_quality > 34500 && _quality < 35500)
			egg = 5;
			
		price = egg_prices[egg];
		
		uint8 discount = 10;
		
		if(_petId<= 600)
			discount = 20;
		if(_petId<= 400)
			discount = 30;
		if(_petId<= 200)
			discount = 50;
		if(_petId<= 120)
			discount = 80;
		
		price = price - (price*discount / 100);
    }
    
    // Save rewards for all referral levels
    function applyReward(uint64 _petId, uint16 _quality) internal {
        
        uint8[6] memory rewardByLevel = [0,250,120,60,30,15];
        
        uint256 eggPrice = getEggPrice(_petId, _quality);
        
        uint64 _currentPetId = _petId;
        
        // make rewards for 5 levels
        for(uint8 level=1; level<=5; level++) {
            uint64 _parentId = petsInfo[_currentPetId].parentId;
            // if no parent referral - break
            if(_parentId == 0)
                break;
            
            // increase pet balance
            petsInfo[_parentId].amount+= eggPrice * rewardByLevel[level] / 1000;
            
            // get parent id from parent id to move to the next level
            _currentPetId = _parentId;
        }
        
    }
    
    // Save rewards for all referral levels
    function applyRewardByAmount(uint64 _petId, uint256 _price) internal {
        
        uint8[6] memory rewardByLevel = [0,250,120,60,30,15];
        
        uint64 _currentPetId = _petId;
        
        // Make rewards for 5 levels
        for(uint8 i=1; i<=5; i++) {
            uint64 _parentId = petsInfo[_currentPetId].parentId;
            // if no parent referral - break
            if(_parentId == 0)
                break;
            
            // Increase pet balance
            petsInfo[_parentId].amount+= _price * rewardByLevel[i] / 1000;
            
            // Get parent id from parent id to move to the next level
            _currentPetId = _parentId;
        }
        
    }
}

// Launch it
contract ReferralCircle is Reward, Utils, Pausable {
    
    // Interface link
    ParentInterface public parentInterface;
    
    // Limit of manual synchronization repeats
    uint8 public syncLimit = 5;
    
    // Pet counter
    uint64 public lastPetId = 100;
    
    // Manual sync enabled
    bool public petSyncEnabled = true;
    
    // Setting default parent interface    
    constructor() public {
        parentInterface = ParentInterface(0x115f56742474f108AD3470DDD857C31a3f626c3C);
    }

    // Disable manual synchronization
    function disablePetSync() external onlyOwner {
        petSyncEnabled = false;
    }

    // Enable manual synchronization
    function enablePetSync() external onlyOwner {
        petSyncEnabled = true;
    }
    
    // Make synchronization, available for any sender
    function sync() external whenNotPaused {
        
        // Checking synchronization status
        require(petSyncEnabled);
        
        // Get supply of pets from parent contract
        uint64 petSupply = uint64(parentInterface.totalSupply());
        require(petSupply > lastPetId);

        // Synchronize pets        
        for(uint8 i=0; i < syncLimit; i++)
        {
            lastPetId++;
            
            if(lastPetId > petSupply)
            {
                lastPetId = petSupply;
                break;
            }
            
            addPet(lastPetId);
        }
    }
    
    // Change synchronization limit by owner
    function setSyncLimit(uint8 _limit) external onlyOwner {
        syncLimit = _limit;
    }

    // Function of manual add pet    
    function addPet(uint64 _id) internal {
        (uint64 birthTime, uint256 genes, uint64 breedTimeout, uint16 quality, address owner) = parentInterface.getPet(_id);
        
        uint16 gradeQuality = quality;

        // For first pets - bonus quality in grade calculating
        if(_id < 244)
			gradeQuality = quality - 13777;
			
		// Calculating seats in circle
        uint8 petGrade = getGradeByQuailty(gradeQuality);
        uint8 petSeats = seatsByGrade(petGrade);
        
        // Adding pet into circle
        addPetIntoCircle(_id, petSeats);
        
        // Save reward for each referral level
        applyReward(_id, quality);
    }
    
    // Function for automatic add pet
    function automaticPetAdd(uint256 _price, uint16 _quality, uint64 _id) external {
        require(!petSyncEnabled);
        require(msg.sender == address(parentInterface));
        
        lastPetId = _id;
        
        // Calculating seats in circle
        uint8 petGrade = getGradeByQuailty(_quality);
        uint8 petSeats = seatsByGrade(petGrade);
        
        // Adding pet into circle
        addPetIntoCircle(_id, petSeats);
        
        // Save reward for each referral level
        applyRewardByAmount(_id, _price);
    }
    
    // Function for withdraw reward by pet owner
    function withdrawReward(uint64 _petId) external whenNotPaused {
        
        // Get pet information
        PetInfo memory petInfo = petsInfo[_petId];
        
        // Get owner of pet from pet contract and check it
         (uint64 birthTime, uint256 genes, uint64 breedTimeout, uint16 quality, address petOwner) = parentInterface.getPet(_petId);
        require(petOwner == msg.sender);

        // Transfer reward
        msg.sender.transfer(petInfo.amount);
        
        // Change reward amount in pet information
        petInfo.amount = 0;
        petsInfo[_petId] = petInfo;
    }
    
    // Emergency reward sending by admin
    function sendRewardByAdmin(uint64 _petId) external onlyOwner whenNotPaused {
        
        // Get pet information
        PetInfo memory petInfo = petsInfo[_petId];
        
        // Get owner of pet from pet contract and check it
        (uint64 birthTime, uint256 genes, uint64 breedTimeout, uint16 quality, address petOwner) = parentInterface.getPet(_petId);

        // Transfer reward
        petOwner.transfer(petInfo.amount);
        
        // Change reward amount in pet information
        petInfo.amount = 0;
        petsInfo[_petId] = petInfo;
    }
        
    // Change parent contract
    function setParentAddress(address _address) public whenPaused onlyOwner
    {
        parentInterface = ParentInterface(_address);
    }

    // Just refill    
    function () public payable {}
    
    // Withdraw balance by owner
    function withdrawBalance(uint256 summ) external onlyOwner {
        owner.transfer(summ);
    }
}