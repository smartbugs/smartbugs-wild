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

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

interface EtheremonAdventureItem {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getItemInfo(uint _tokenId) constant external returns(uint classId, uint value);
    function spawnItem(uint _classId, uint _value, address _owner) external returns(uint);
}

contract EtheremonAdventureData {
    
    function addLandRevenue(uint _siteId, uint _emontAmount, uint _etherAmount) external;
    function addTokenClaim(uint _tokenId, uint _emontAmount, uint _etherAmount) external;
    
    // public function
    function getLandRevenue(uint _classId) constant public returns(uint _emontAmount, uint _etherAmount);
    function getTokenClaim(uint _tokenId) constant public returns(uint _emontAmount, uint _etherAmount);
}

contract EtheremonAdventureRevenue is BasicAccessControl {
    using SafeMath for uint;
    
    struct PairData {
        uint d1;
        uint d2;
    }
    
    address public tokenContract;
    address public adventureDataContract;
    address public adventureItemContract;

    modifier requireTokenContract {
        require(tokenContract != address(0));
        _;
    }
    
    modifier requireAdventureDataContract {
        require(adventureDataContract != address(0));
        _;
    }

    modifier requireAdventureItemContract {
        require(adventureItemContract != address(0));
        _;
    }
    
    
    function setConfig(address _tokenContract, address _adventureDataContract, address _adventureItemContract) onlyModerators public {
        tokenContract = _tokenContract;
        adventureDataContract = _adventureDataContract;
        adventureItemContract = _adventureItemContract;
    }
    
    function withdrawEther(address _sendTo, uint _amount) onlyOwner public {
        // it is used in case we need to upgrade the smartcontract
        if (_amount > address(this).balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
    
    function withdrawToken(address _sendTo, uint _amount) onlyOwner requireTokenContract external {
        ERC20Interface token = ERC20Interface(tokenContract);
        if (_amount > token.balanceOf(address(this))) {
            revert();
        }
        token.transfer(_sendTo, _amount);
    }
    // public
    
    function () payable public {
    }
    

    function getEarning(uint _tokenId) constant public returns(uint _emontAmount, uint _ethAmount) {
        PairData memory tokenInfo;
        PairData memory currentRevenue;
        PairData memory claimedRevenue;
        (tokenInfo.d1, tokenInfo.d2) = EtheremonAdventureItem(adventureItemContract).getItemInfo(_tokenId);
        EtheremonAdventureData data = EtheremonAdventureData(adventureDataContract);
        (currentRevenue.d1, currentRevenue.d2) = data.getLandRevenue(tokenInfo.d1);
        (claimedRevenue.d1, claimedRevenue.d2) = data.getTokenClaim(_tokenId);
        
        _emontAmount = ((currentRevenue.d1.mul(9)).div(100)).sub(claimedRevenue.d1);
        _ethAmount = ((currentRevenue.d2.mul(9)).div(100)).sub(claimedRevenue.d2);
    }
    
    function claimEarning(uint _tokenId) isActive requireTokenContract requireAdventureDataContract requireAdventureItemContract public {
        EtheremonAdventureItem item = EtheremonAdventureItem(adventureItemContract);
        EtheremonAdventureData data = EtheremonAdventureData(adventureDataContract);
        if (item.ownerOf(_tokenId) != msg.sender) revert();
        PairData memory tokenInfo;
        PairData memory currentRevenue;
        PairData memory claimedRevenue;
        PairData memory pendingRevenue;
        (tokenInfo.d1, tokenInfo.d2) = item.getItemInfo(_tokenId);
        (currentRevenue.d1, currentRevenue.d2) = data.getLandRevenue(tokenInfo.d1);
        (claimedRevenue.d1, claimedRevenue.d2) = data.getTokenClaim(_tokenId);
        
        pendingRevenue.d1 = ((currentRevenue.d1.mul(9)).div(100)).sub(claimedRevenue.d1);
        pendingRevenue.d2 = ((currentRevenue.d2.mul(9)).div(100)).sub(claimedRevenue.d2);
        
        if (pendingRevenue.d1 == 0 && pendingRevenue.d2 == 0) revert();
        data.addTokenClaim(_tokenId, pendingRevenue.d1, pendingRevenue.d2);
        
        if (pendingRevenue.d1 > 0) {
            ERC20Interface(tokenContract).transfer(msg.sender, pendingRevenue.d1);
        }
        
        if (pendingRevenue.d2 > 0) {
            msg.sender.transfer(pendingRevenue.d2);
        }
        
    }
}