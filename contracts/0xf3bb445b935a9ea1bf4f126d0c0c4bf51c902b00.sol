pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }
}

contract EtheremonAdventureData is BasicAccessControl {
    
    using SafeMath for uint;
    
    struct LandTokenClaim {
        uint emontAmount;
        uint etherAmount;
    }
    
    // total revenue 
    struct LandRevenue {
        uint emontAmount;
        uint etherAmount;
    }
    
    struct ExploreData {
        address sender;
        uint typeId;
        uint monsterId;
        uint siteId;
        uint itemSeed;
        uint startAt; // blocknumber
    }
    
    uint public exploreCount = 0;
    mapping(uint => ExploreData) public exploreData; // explore count => data
    mapping(address => uint) public explorePending; // address => explore id
    
    mapping(uint => LandTokenClaim) public claimData; // tokenid => claim info
    mapping(uint => LandRevenue) public siteData; // class id => amount 
    
    function addLandRevenue(uint _siteId, uint _emontAmount, uint _etherAmount) onlyModerators external {
        LandRevenue storage revenue = siteData[_siteId];
        revenue.emontAmount = revenue.emontAmount.add(_emontAmount);
        revenue.etherAmount = revenue.etherAmount.add(_etherAmount);
    }
    
    function addTokenClaim(uint _tokenId, uint _emontAmount, uint _etherAmount) onlyModerators external {
        LandTokenClaim storage claim = claimData[_tokenId];
        claim.emontAmount = claim.emontAmount.add(_emontAmount);
        claim.etherAmount = claim.etherAmount.add(_etherAmount);
    }
    
    function addExploreData(address _sender, uint _typeId, uint _monsterId, uint _siteId, uint _startAt, uint _emontAmount, uint _etherAmount) onlyModerators external returns(uint){
        if (explorePending[_sender] > 0) revert();
        exploreCount += 1;
        ExploreData storage data = exploreData[exploreCount];
        data.sender = _sender;
        data.typeId = _typeId;
        data.monsterId = _monsterId;
        data.siteId = _siteId;
        data.itemSeed = 0;
        data.startAt = _startAt;
        explorePending[_sender] = exploreCount;
        
        LandRevenue storage revenue = siteData[_siteId];
        revenue.emontAmount = revenue.emontAmount.add(_emontAmount);
        revenue.etherAmount = revenue.etherAmount.add(_etherAmount);
        return exploreCount;
    }
    
    function removePendingExplore(uint _exploreId, uint _itemSeed) onlyModerators external {
        ExploreData storage data = exploreData[_exploreId];
        if (explorePending[data.sender] != _exploreId)
            revert();
        explorePending[data.sender] = 0;
        data.itemSeed = _itemSeed;
    }
    
    // public function
    function getLandRevenue(uint _classId) constant public returns(uint _emontAmount, uint _etherAmount) {
        LandRevenue storage revenue = siteData[_classId];
        return (revenue.emontAmount, revenue.etherAmount);
    }
    
    function getTokenClaim(uint _tokenId) constant public returns(uint _emontAmount, uint _etherAmount) {
        LandTokenClaim storage claim = claimData[_tokenId];
        return (claim.emontAmount, claim.etherAmount);
    }
    
    function getExploreData(uint _exploreId) constant public returns(address _sender, uint _typeId, uint _monsterId, uint _siteId, uint _itemSeed, uint _startAt) {
        ExploreData storage data = exploreData[_exploreId];
        return (data.sender, data.typeId, data.monsterId, data.siteId, data.itemSeed, data.startAt);
    }
    
    function getPendingExplore(address _player) constant public returns(uint) {
        return explorePending[_player];
    }
    
    function getPendingExploreData(address _player) constant public returns(uint _exploreId, uint _typeId, uint _monsterId, uint _siteId, uint _itemSeed, uint _startAt) {
        _exploreId = explorePending[_player];
        if (_exploreId > 0) {
            ExploreData storage data = exploreData[_exploreId];
            return (_exploreId, data.typeId, data.monsterId, data.siteId, data.itemSeed, data.startAt);
        }
        
    }
}