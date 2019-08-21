pragma solidity ^0.4.18;

contract Admin {
  address public owner;
  mapping(address => bool) public isAdmin;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyAdmin() {
    require(isAdmin[msg.sender]);
    _;
  }

  function Admin() public {
    owner = msg.sender;
    addAdmin(owner);
  }

  function addAdmin(address _admin) public onlyOwner {
    isAdmin[_admin] = true;
  }

  function removeAdmin(address _admin) public onlyOwner {
    isAdmin[_admin] = false;
  }
}

// To add a tree do the following:
// - Create a new Tree with the ID, owner, treeValue and power to generate fruits
// - Update the treeBalances and treeOwner mappings
contract Trees is Admin {
  event LogWaterTree(uint256 indexed treeId, address indexed owner, uint256 date);
  event LogRewardPicked(uint256 indexed treeId, address indexed owner, uint256 date, uint256 amount);

  // Get the tree information given the id
  mapping(uint256 => Tree) public treeDetails;
  // A mapping with all the tree IDs of that owner
  mapping(address => uint256[]) public ownerTreesIds;
  // Tree id and the days the tree has been watered
  // Tree id => day number => isWatered
  mapping(uint256 => mapping(uint256 => bool)) public treeWater;

  struct Tree {
    uint256 ID;
    address owner;
    uint256 purchaseDate;
    uint256 treePower; // How much ether that tree is generating from 0 to 100 where 100 is the total power combined of all the trees
    uint256 salePrice;
    uint256 timesExchanged;
    uint256[] waterTreeDates;
    bool onSale;
    uint256 lastRewardPickedDate; // When did you take the last reward
  }

  uint256[] public trees;
  uint256[] public treesOnSale;
  uint256 public lastTreeId;
  address public defaultTreesOwner = msg.sender;
  uint256 public defaultTreesPower = 1; // 10% of the total power
  uint256 public defaultSalePrice = 1 ether;
  uint256 public totalTreePower;
  uint256 public timeBetweenRewards = 1 days;

  // This will be called automatically by the server
  // The contract itself will hold the initial trees
  function generateTrees(uint256 _amountToGenerate) public onlyAdmin {
    for(uint256 i = 0; i < _amountToGenerate; i++) {
        uint256 newTreeId = lastTreeId + 1;
        lastTreeId += 1;
        uint256[] memory emptyArray;
        Tree memory newTree = Tree(newTreeId, defaultTreesOwner, now, defaultTreesPower, defaultSalePrice, 0, emptyArray, true, 0);

        // Update the treeBalances and treeOwner mappings
        // We add the tree to the same array position to find it easier
        ownerTreesIds[defaultTreesOwner].push(newTreeId);
        treeDetails[newTreeId] = newTree;
        treesOnSale.push(newTreeId);
        totalTreePower += defaultTreesPower;
    }
  }

  // This is payable, the user will send the payment here
  // We delete the tree from the owner first and we add that to the receiver
  // When you sell you're actually putting the tree on the market, not losing it yet
  function putTreeOnSale(uint256 _treeNumber, uint256 _salePrice) public {
    require(msg.sender == treeDetails[_treeNumber].owner);
    require(!treeDetails[_treeNumber].onSale);
    require(_salePrice > 0);

    treesOnSale.push(_treeNumber);
    treeDetails[_treeNumber].salePrice = _salePrice;
    treeDetails[_treeNumber].onSale = true;
  }

  // To buy a tree paying ether
  function buyTree(uint256 _treeNumber, address _originalOwner) public payable {
    require(msg.sender != treeDetails[_treeNumber].owner);
    require(treeDetails[_treeNumber].onSale);
    require(msg.value >= treeDetails[_treeNumber].salePrice);
    address newOwner = msg.sender;
    // Move id from old to new owner
    // Find the tree of that user and delete it
    for(uint256 i = 0; i < ownerTreesIds[_originalOwner].length; i++) {
        if(ownerTreesIds[_originalOwner][i] == _treeNumber) delete ownerTreesIds[_originalOwner][i];
    }
    // Remove the tree from the array of trees on sale
    for(uint256 a = 0; a < treesOnSale.length; a++) {
        if(treesOnSale[a] == _treeNumber) {
            delete treesOnSale[a];
            break;
        }
    }
    ownerTreesIds[newOwner].push(_treeNumber);
    treeDetails[_treeNumber].onSale = false;
    if(treeDetails[_treeNumber].timesExchanged == 0) {
        // Reward the owner for the initial trees as a way of monetization. Keep half for the treasury
        owner.transfer(msg.value / 2);
    } else {
        treeDetails[_treeNumber].owner.transfer(msg.value * 90 / 100); // Keep 0.1% in the treasury
    }
    treeDetails[_treeNumber].owner = newOwner;
    treeDetails[_treeNumber].timesExchanged += 1;
  }

  // To take a tree out of the market without selling it
  function cancelTreeSell(uint256 _treeId) public {
    require(msg.sender == treeDetails[_treeId].owner);
    require(treeDetails[_treeId].onSale);
    // Remove the tree from the array of trees on sale
    for(uint256 a = 0; a < treesOnSale.length; a++) {
        if(treesOnSale[a] == _treeId) {
            delete treesOnSale[a];
            break;
        }
    }
    treeDetails[_treeId].onSale = false;
  }

  // Improves the treePower
  function waterTree(uint256 _treeId) public {
    require(_treeId > 0);
    require(msg.sender == treeDetails[_treeId].owner);
    uint256[] memory waterDates = treeDetails[_treeId].waterTreeDates;
    uint256 timeSinceLastWater;
    // We want to store at what day the tree was watered
    uint256 day;
    if(waterDates.length > 0) {
        timeSinceLastWater = now - waterDates[waterDates.length - 1];
        day = waterDates[waterDates.length - 1] / 1 days;
    }else {
        timeSinceLastWater = timeBetweenRewards;
        day = 1;
    }
    require(timeSinceLastWater >= timeBetweenRewards);
    treeWater[_treeId][day] = true;
    treeDetails[_treeId].waterTreeDates.push(now);
    treeDetails[_treeId].treePower += 1;
    totalTreePower += 1;
    LogWaterTree(_treeId, msg.sender, now);
  }

  // To get the ether from the rewards
  function pickReward(uint256 _treeId) public {
    require(msg.sender == treeDetails[_treeId].owner);
    require(now - treeDetails[_treeId].lastRewardPickedDate > timeBetweenRewards);

    uint256[] memory formatedId = new uint256[](1);
    formatedId[0] = _treeId;
    uint256[] memory rewards = checkRewards(formatedId);
    treeDetails[_treeId].lastRewardPickedDate = now;
    msg.sender.transfer(rewards[0]);
    LogRewardPicked(_treeId, msg.sender, now, rewards[0]);
  }

  // To see if a tree is already watered or not
  function checkTreesWatered(uint256[] _treeIds) public constant returns(bool[]) {
    bool[] memory results = new bool[](_treeIds.length);
    uint256 timeSinceLastWater;
    for(uint256 i = 0; i < _treeIds.length; i++) {
        uint256[] memory waterDates = treeDetails[_treeIds[i]].waterTreeDates;
        if(waterDates.length > 0) {
            timeSinceLastWater = now - waterDates[waterDates.length - 1];
            results[i] = timeSinceLastWater < timeBetweenRewards;
        } else {
            results[i] = false;
        }
    }
    return results;
  }

  // Returns an array of how much ether all those trees have generated today
  // All the tree power combiined for instance 10293
  // The tree power for this tree for instance 298
  // What percentage do you get: 2%
  // Total money in the treasury: 102 ETH
  // A 10% of the total is distributed daily across all the users
  // For instance 10.2 ETH today
  // So if you pick your rewards right now, you'll get a 2% of 10.2 ETH which is 0.204 ETH
  function checkRewards(uint256[] _treeIds) public constant returns(uint256[]) {
    uint256 amountInTreasuryToDistribute = this.balance / 10;
    uint256[] memory results = new uint256[](_treeIds.length);
    for(uint256 i = 0; i < _treeIds.length; i++) {
        // Important to multiply by 100 to
        uint256 yourPercentage = treeDetails[_treeIds[i]].treePower * 1 ether / totalTreePower;
        uint256 amountYouGet = yourPercentage * amountInTreasuryToDistribute / 1 ether;
        results[i] = amountYouGet;
    }
    return results;
  }

  // To get all the tree IDs of one user
  function getTreeIds(address _account) public constant returns(uint256[]) {
    if(_account != address(0)) return ownerTreesIds[_account];
    else return ownerTreesIds[msg.sender];
  }

  // To get all the trees on sale
  function getTreesOnSale() public constant returns(uint256[]) {
      return treesOnSale;
  }

  // To extract the ether in an emergency
  function emergencyExtract() public onlyOwner {
    owner.transfer(this.balance);
  }
}