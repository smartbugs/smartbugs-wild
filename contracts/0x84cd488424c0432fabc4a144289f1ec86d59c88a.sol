pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

library Shared {
    struct Spinner {
        string name;
        uint256 class;
        uint8 speed;
        uint8 momentum;
        uint8 inertia;
        uint256 _id;
        address spinnerOwner;
        uint256 created;
        uint256 purchasePrice;
        uint256 purchaseIndex;    
    }

    struct SpinnerMint {
        bool purchasable;
        uint startPrice;
        uint currentPrice;
        uint returnPrice;
    }
}


contract SpinnerDatabase is Ownable {
    
    uint256 public totalSpinners;
    uint256 public availableThemedSpinners;
    uint256 public maxSpinners; //prevent hoarding
    uint256 public currentUniqueSpinnerPrice;
    uint256 spinnerModulus = 16777216; //16,777,216 or 256^3 possible unique spinners
    uint256 public uniqueSpinners;

    address[] public uniqueSpinnerOwners;
    
    address public owner;
    address public processorAddress;
    address public factoryAddress;
    address public marketAddress;

    function setProcessorAddress(address processAddress) public onlyOwner {
        processorAddress = processAddress;
    }

    function setFactoryAddress(address factorAddress) public onlyOwner {
        factoryAddress = factorAddress;
    }

    function setMarketAddress(address market) public onlyOwner {
        marketAddress = market;
    }

    mapping (uint => uint) public spinnerCounts;
    mapping (address => uint) public balances;
    mapping (address => uint) public earn;
    mapping (uint => Shared.SpinnerMint) public themedSpinners;
    mapping (address => Shared.Spinner[]) public SpinnersByAddress;
    mapping (uint => address[]) public OwnersBySpinner;
    mapping (address => uint) public SpinnerCountsByAddress;
    mapping (uint => uint) public originalPricesBySpinner;
    mapping (uint => uint) public spinnerCountsByType;

    function SpinnerDatabase() public {
        totalSpinners = 0;
        maxSpinners = 512;
        availableThemedSpinners = 0;
        uniqueSpinners = 0;
        currentUniqueSpinnerPrice = 1 ether;
        owner = msg.sender;
        
    }

    function addSpinner(string _name, uint _type, address creator, uint value, uint8 speed, uint8 momentum, uint8 inertia) external {
        require(msg.sender == factoryAddress);
        uint256 _id = uint(uint(keccak256(_type)) + uint(keccak256(block.timestamp + uint(keccak256(msg.sender)))));
        uint256 purchaseIndex = spinnerCountsByType[_type];
        SpinnersByAddress[creator].push(Shared.Spinner(_name, _type, speed, momentum, inertia, _id, creator, block.timestamp, value, purchaseIndex));
        incrementBalances(_type); //payout owners
        OwnersBySpinner[_type].push(creator); //Add new owner of Spinner
        incrementThemedSpinnerPrice(_type); //increase price
        spinnerCounts[_type]++; //Total Purchased of Spinner
        totalSpinners++; //Total Purchased overall
        SpinnerCountsByAddress[creator]++; //Total Owned
        spinnerCountsByType[_type]++; //increment count of type    
    }

    function addUniqueSpinner(string _name, uint _type, address creator, uint value, uint8 speed, uint8 momentum, uint8 inertia) external {
        require(msg.sender == factoryAddress); 
        uint256 _id = uint(uint(keccak256(_type)) + uint(keccak256(block.timestamp + uint(keccak256(msg.sender)))));
        uint256 purchaseIndex = uniqueSpinners;
        SpinnersByAddress[creator].push(Shared.Spinner(_name, _type, speed, momentum, inertia, _id, creator, block.timestamp, value, purchaseIndex));
        uniqueSpinnerOwners.push(creator); //Add new owner of Spinner
        uniqueSpinners++; //Total Purchased of Spinner
        totalSpinners++; //Total Purchased overall
        SpinnerCountsByAddress[creator]++; //Total Owned
    }

    function changeOwnership(string _name, uint _id, uint _type, address originalOwner, address newOwner) external {
        require(msg.sender == marketAddress);
        uint256 totalSpinnersOwned = SpinnerCountsByAddress[originalOwner];
        for (uint256 i = 0; i < totalSpinnersOwned; i++) {
            uint mySpinnerId = getSpinnerData(originalOwner, i)._id;
            if (mySpinnerId == _id) {
                executeOwnershipChange(i, _id, _type, originalOwner, newOwner, _name);
                break;
            }
        }
        changeOwnershipStepTwo(_type, originalOwner, newOwner);
    }

    function changeOwnershipStepTwo(uint _type, address originalOwner, address newOwner) private {
        uint totalSpinnersOfType = spinnerCountsByType[_type];
        address[] storage owners = OwnersBySpinner[_type];
        for (uint j = 0; j < totalSpinnersOfType; j++) {
            if (owners[j] == originalOwner) {
                owners[j] = newOwner;
                break;
            }
        }
        OwnersBySpinner[_type] = owners;    
    }

    function changeUniqueOwnership(string _name, uint _id, address originalOwner, address newOwner) external {
        require(msg.sender == marketAddress);
        uint256 totalSpinnersOwned = SpinnerCountsByAddress[originalOwner];
        for (uint256 i = 0; i < totalSpinnersOwned; i++) {
            uint mySpinnerId = getSpinnerData(originalOwner, i)._id;
            if (mySpinnerId == _id) {
                uint spinnerType = getSpinnerData(originalOwner, i).class;
                executeOwnershipChange(i, _id, spinnerType, originalOwner, newOwner, _name);
                break;
            }
        }
        changeUniqueOwnershipStepTwo(originalOwner, newOwner);
    }
    
    function changeUniqueOwnershipStepTwo(address originalOwner, address newOwner) private {
        uint totalUniqueSpinners = uniqueSpinners;
        for (uint j = 0; j < totalUniqueSpinners; j++) {
            if (uniqueSpinnerOwners[j] == originalOwner) {
                uniqueSpinnerOwners[j] = newOwner;
                break;
            }
        }  
    }

    function executeOwnershipChange(uint i, uint _id, uint _type, address originalOwner, address newOwner, string _name) private {
        uint8 spinnerSpeed = getSpinnerData(originalOwner, i).speed;
        uint8 spinnerMomentum = getSpinnerData(originalOwner, i).momentum;
        uint8 spinnerInertia = getSpinnerData(originalOwner, i).inertia;
        uint spinnerTimestamp = getSpinnerData(originalOwner, i).created;
        uint spinnerPurchasePrice = getSpinnerData(originalOwner, i).purchasePrice;
        uint spinnerPurchaseIndex  = getSpinnerData(originalOwner, i).purchaseIndex;
        SpinnerCountsByAddress[originalOwner]--;
        delete SpinnersByAddress[originalOwner][i];
        SpinnersByAddress[newOwner].push(Shared.Spinner(_name, _type, spinnerSpeed, spinnerMomentum, spinnerInertia, _id, newOwner, spinnerTimestamp, spinnerPurchasePrice, spinnerPurchaseIndex));
        SpinnerCountsByAddress[newOwner]++;  
    }


    function generateThemedSpinners(uint seed, uint price, uint returnPrice) external {
        require(msg.sender == factoryAddress);
        themedSpinners[seed] = Shared.SpinnerMint(true, price, price, returnPrice);
        originalPricesBySpinner[seed] = price;
        availableThemedSpinners++;
    }

    function incrementThemedSpinnerPrice(uint seed) private {
        themedSpinners[seed].currentPrice = themedSpinners[seed].currentPrice + themedSpinners[seed].returnPrice;
    }

    function getSpinnerPrice(uint seed) public view returns (uint) {
        return themedSpinners[seed].currentPrice;
    }

    function getUniqueSpinnerPrice() public view returns (uint) {
        return currentUniqueSpinnerPrice;
    }

    function setUniqueSpinnerPrice(uint cost) public onlyOwner {
        currentUniqueSpinnerPrice = cost;
    }

    function getBalance(address walletAddress) public view returns (uint) {
        return balances[walletAddress];
    }

    function getSpinnerData(address walletAddress, uint index) public view returns (Shared.Spinner) {
        return SpinnersByAddress[walletAddress][index];
    } 

    function getOriginalSpinnerPrice(uint256 _id) public view returns (uint) {
        return originalPricesBySpinner[_id];
    }

    function doesAddressOwnSpinner(address walletAddress, uint _id) public view returns (bool) {
        uint count = spinnerCountsByType[_id + spinnerModulus];
        for (uint i=0; i<count; i++) {
            if (keccak256(SpinnersByAddress[walletAddress][i].spinnerOwner) == keccak256(walletAddress)) {
                return true;
            }
        }
        return false;
    }

    function incrementBalances(uint _type) private {
        uint totalPurchased = spinnerCounts[_type];
        address[] storage owners = OwnersBySpinner[_type];
        uint payout = themedSpinners[_type].returnPrice;
        for (uint i = 0; i < totalPurchased; i++) {
            balances[owners[i]] = balances[owners[i]] + payout;
            earn[owners[i]] = earn[owners[i]] + payout;
        }
    }

    function decrementBalance(address walletAddress, uint amount) external {
        require(msg.sender == processorAddress);
        require(amount <= balances[walletAddress]);
        balances[walletAddress] = balances[walletAddress] - amount;
    }
}

contract SpinnerFactory is Ownable {

    function SpinnerFactory(address _spinnerDatabaseAddress) public {
        databaseAddress = _spinnerDatabaseAddress;
    }

    address public databaseAddress;
    address public processorAddress;
    uint256 public spinnerModulus = 16777216; //16,777,216 or 256^3 possible unique spinners

    address public owner;

    mapping (uint => bool) public initialSpinners; //mapping of initial spinners

    function setProcessorAddress(address processAddress) public onlyOwner {
        processorAddress = processAddress;
    }

    function _generateRandomSeed() internal view returns (uint) {
        uint rand = uint(keccak256(uint(block.blockhash(block.number-1)) + uint(keccak256(msg.sender))));
        return rand % spinnerModulus;
    }

    function createUniqueSpinner(string _name, address creator, uint value) external {
        require(msg.sender == processorAddress);
        uint _seed = _generateRandomSeed();
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        database.addUniqueSpinner(_name, _seed, creator, value, uint8(keccak256(_seed + 1)) % 64 + 64, uint8(keccak256(_seed + 2)) % 64 + 64, uint8(keccak256(_seed + 3)) % 64 + 64);
    }

   function createThemedSpinner(string _name, uint _type, address creator, uint value) external {
        require(msg.sender == processorAddress);
        require(initialSpinners[_type] == true);
        uint _seed = _generateRandomSeed();
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        database.addSpinner(_name, _type, creator, value, uint8(keccak256(_seed + 1)) % 64 + 64, uint8(keccak256(_seed + 2)) % 64 + 64, uint8(keccak256(_seed + 3)) % 64 + 64);
    }

    function addNewSpinner(uint _type) public onlyOwner {
        initialSpinners[_type] = true;
    }

    function blockNewSpinnerPurchase(uint _type) public onlyOwner {
        initialSpinners[_type] = false;
    }

    function mintGen0Spinners() public onlyOwner {
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        addNewSpinner(1 + spinnerModulus);
        database.generateThemedSpinners(1 + spinnerModulus, 1 ether, .01 ether);
        addNewSpinner(2 + spinnerModulus);
        database.generateThemedSpinners(2 + spinnerModulus, 1 ether, .01 ether);
        addNewSpinner(3 + spinnerModulus);
        database.generateThemedSpinners(3 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(4 + spinnerModulus);
        database.generateThemedSpinners(4 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(5 + spinnerModulus);
        database.generateThemedSpinners(5 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(6 + spinnerModulus);
        database.generateThemedSpinners(6 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(7 + spinnerModulus);
        database.generateThemedSpinners(7 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(8 + spinnerModulus);
        database.generateThemedSpinners(8 + spinnerModulus, .75 ether, .0075 ether);
        addNewSpinner(9 + spinnerModulus);
        database.generateThemedSpinners(9 + spinnerModulus, .5 ether, .005 ether);
        addNewSpinner(10 + spinnerModulus);
        database.generateThemedSpinners(10 + spinnerModulus, .5 ether, .005 ether);
        addNewSpinner(11 + spinnerModulus);
        database.generateThemedSpinners(11 + spinnerModulus, .5 ether, .005 ether);
        addNewSpinner(12 + spinnerModulus);
        database.generateThemedSpinners(12 + spinnerModulus, .5 ether, .005 ether);
        addNewSpinner(13 + spinnerModulus);
        database.generateThemedSpinners(13 + spinnerModulus, .2 ether, .002 ether);
        addNewSpinner(14 + spinnerModulus);
        database.generateThemedSpinners(14 + spinnerModulus, .2 ether, .002 ether);
        addNewSpinner(15 + spinnerModulus);
        database.generateThemedSpinners(15 + spinnerModulus, .3 ether, .003 ether);
        addNewSpinner(16 + spinnerModulus);
        database.generateThemedSpinners(16 + spinnerModulus, .3 ether, .003 ether);
        addNewSpinner(17 + spinnerModulus);
        database.generateThemedSpinners(17 + spinnerModulus, .05 ether, .0005 ether);
        addNewSpinner(18 + spinnerModulus);
        database.generateThemedSpinners(18 + spinnerModulus, .05 ether, .0005 ether);
        addNewSpinner(19 + spinnerModulus);
        database.generateThemedSpinners(19 + spinnerModulus, .008 ether, .00008 ether);
        addNewSpinner(20 + spinnerModulus);
        database.generateThemedSpinners(20 + spinnerModulus, .001 ether, .00001 ether);
    }

    function mintNewSpinner(uint _id, uint price, uint returnPrice) public onlyOwner {
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        addNewSpinner(_id + spinnerModulus);
        database.generateThemedSpinners(_id + spinnerModulus, price, returnPrice);
    }
}
    
contract SpinnerProcessor is Ownable {

    uint256 spinnerModulus = 16777216; //16,777,216 or 256^3 possible unique spinners

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier uniqueSpinnersActivated() {
        require(uniqueSpinnersActive);
        _;
    }

    address public owner;

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function activateUniqueSpinners() public onlyOwner {
        uniqueSpinnersActive = true;
    }   
    
    bool public paused;
    bool public uniqueSpinnersActive;

    address factoryAddress;
    address databaseAddress;
    address ownerAddress;

    uint256 ownerEarn;
    uint256 ownerBalance;

    function viewBalance() view public returns (uint256) {
        return this.balance;
    }

    function SpinnerProcessor(address _spinnerFactoryAddress, address _spinnerDatabaseAddress, address _ownerAddress) public {
        factoryAddress = _spinnerFactoryAddress;
        databaseAddress = _spinnerDatabaseAddress;
        ownerAddress = _ownerAddress;
        paused = true;
        uniqueSpinnersActive = false;
    }

    function purchaseThemedSpinner(string _name, uint _id) public payable whenNotPaused {
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        uint currentPrice = database.getSpinnerPrice(_id + spinnerModulus);
        require(msg.value == currentPrice);
        uint ownerPayout = database.getOriginalSpinnerPrice(_id + spinnerModulus);
        ownerEarn = ownerEarn + ownerPayout;
        ownerBalance = ownerBalance + ownerPayout;    
        SpinnerFactory factory = SpinnerFactory(factoryAddress);
        factory.createThemedSpinner(_name, _id + spinnerModulus, msg.sender, msg.value);
    }

    function purchaseUniqueSpinner(string _name) public payable whenNotPaused uniqueSpinnersActivated {
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        uint currentPrice = database.getUniqueSpinnerPrice();
        require(msg.value == currentPrice);
        SpinnerFactory factory = SpinnerFactory(factoryAddress);
        factory.createUniqueSpinner(_name, msg.sender, msg.value);
    }

    function cashOut() public whenNotPaused {
        SpinnerDatabase database = SpinnerDatabase(databaseAddress);
        uint balance = database.getBalance(msg.sender);
        uint contractBalance = this.balance;
        require(balance <= contractBalance);
        database.decrementBalance(msg.sender, balance);
        msg.sender.transfer(balance);
    }

    function OwnerCashout() public onlyOwner {
        require(ownerBalance <= this.balance);
        msg.sender.transfer(ownerBalance);
        ownerBalance = 0;
    }

    function transferBalance(address newProcessor) public onlyOwner {
        newProcessor.transfer(this.balance);
    }

    function () payable public {}

}