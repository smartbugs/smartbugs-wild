pragma solidity ^0.4.25;


contract ERC20Basic {
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}



contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}



contract Ownable {
    
    address public owner;

    /**
     * The address whcih deploys this contrcat is automatically assgined ownership.
     * */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * Functions with this modifier can only be executed by the owner of the contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed from, address indexed to);

    /**
    * Transfers ownership to new Ethereum address. This function can only be called by the 
    * owner.
    * @param _newOwner the address to be granted ownership.
    **/
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



contract Memberships is Ownable {
    
    using SafeMath for uint256;
    
    
    uint256 private numOfMembers;
    uint256 private maxGramsPerMonth;
    uint256 private monthNo;
    ERC20 public ELYC;
    
    
    constructor() public {
        maxGramsPerMonth = 60;
        ELYC = ERC20(0xFD96F865707ec6e6C0d6AfCe1f6945162d510351); 
    }
    
    
    /**
     * MAPPINGS
     * */
    mapping (address => uint256) private memberIdByAddr;
    mapping (uint256 => address) private memberAddrById;
    mapping (address => bool) private addrIsMember;
    mapping (address => mapping (uint256 => uint256)) private memberPurchases;
    mapping (address => bool) private blacklist;
    
    
    /**
     * EVENTS
     * */
    event MaxGramsPerMonthChanged(uint256 from, uint256 to);
    event MemberBlacklisted(address indexed addr, uint256 indexed id, uint256 block);
    event MemberRemovedFromBlacklist(address indexed addr, uint256 indexed id, uint256 block);
    event NewMemberAdded(address indexed addr, uint256 indexed id, uint256 block);
    event CannabisPurchaseMade(address indexed by, uint256 milligrams, uint256 price, address indexed vendor, uint256 block);
    event PurchaseMade(address indexed by, uint256 _price, address indexed _vendor, uint256 block);
    event MonthNumberIncremented(uint256 block);
    
    
    /**
     * MODIFIERS
     * */
     modifier onlyMembers {
         require(
             addressHasMembership(msg.sender)
             && !memberIsBlacklisted(msg.sender)
             );
         _;
     }

    
    
    /**
     * GETTERS
     * */
     
    /**
     * @return The current number of months the contract has been running for
     * */
     function getMonthNo() public view returns(uint256) {
         return monthNo;
     }
     
    /**
     * @return The total amount of members 
     * */
    function getNumOfMembers() public view returns(uint256) {
        return numOfMembers;
    }
    
    
    /**
     * @return The maximum grams of cannabis each member can buy per month
     * */
    function getMaxGramsPerMonth() public view returns(uint256) {
        return maxGramsPerMonth;
    }
    
    
    /**
     * @param _addr The address which is being queried for membership
     * @return true if the address is a member, false otherwise
     * */
    function addressHasMembership(address _addr) public view returns(bool) {
        return addrIsMember[_addr];
    }
    
    
    /**
     * @param _addr The address associated with a member ID (if any).
     * @return The member ID if it exists, 0 otherwise
     * */
    function getMemberIdByAddr(address _addr) public view returns(uint256) {
        return memberIdByAddr[_addr];
    }
    
    
    /**
     * @param _id The ID associated with a member address (if any).
     * @return The member address if it exists, 0x00...00 otherwise.
     * */
    function getMemberAddrById(uint256 _id) public view returns(address) {
        return memberAddrById[_id];
    }
    
    
    /**
     * @param _addr The address which is being checked if it is on the blacklist
     * @return true if the address is on the blacklist, false otherwise
     * */
    function memberIsBlacklisted(address _addr) public view returns(bool) {
        return blacklist[_addr];
    }
    
    
    /**
     * @param _addr The address for which is being checked how many milligrams the address owner
     * (i.e. the registered member) can buy.
     * @return The total amount of milligrams the address owner can buy.
     * */
    function getMilligramsMemberCanBuy(address _addr) public view returns(uint256) {
        uint256 milligrams = memberPurchases[_addr][monthNo];
        if(milligrams >= maxGramsPerMonth.mul(1000)) {
            return 0;
        } else {
            return (maxGramsPerMonth.mul(1000)).sub(milligrams);
        }
    }
    
    

    /**
     * @param _id The member ID for which is being checked how many milligrams the ID owner
     * (i.e. the registered member) can buy.
     * @return The total amount of milligrams the ID owner can buy.
     * */
    function getMilligramsMemberCanBuy(uint256 _id) public view returns(uint256) {
        uint256 milligrams = memberPurchases[getMemberAddrById(_id)][monthNo];
        if(milligrams >= maxGramsPerMonth.mul(1000)) {
            return 0;
        } else {
            return (maxGramsPerMonth.mul(1000)).sub(milligrams);
        }
    }


    
    /**
     * ONLY MEMBER FUNCTIONS
     * */
     
     /**
      * Allows members to buy cannabis.
      * @param _price The total amount of ELYC tokens that should be paid.
      * @param _milligrams The total amount of milligrams which is being purchased 
      * @param _vendor The vendors address 
      * @return true if the function executes successfully, false otherwise
      * */
    function buyCannabis(uint256 _price, uint256 _milligrams, address _vendor) public onlyMembers returns(bool) {
        require(_milligrams > 0 && _price > 0 && _vendor != address(0));
        require(_milligrams <= getMilligramsMemberCanBuy(msg.sender));
        ELYC.transferFrom(msg.sender, _vendor, _price);
        memberPurchases[msg.sender][monthNo] = memberPurchases[msg.sender][monthNo].add(_milligrams);
        emit CannabisPurchaseMade(msg.sender, _milligrams, _price, _vendor, block.number);
        return true;
    }
    
    
    
    /**
     * ONLY OWNER FUNCTIONS
     * */
     
    /**
     * Allows the owner of this contract to add new members.
     * @param _addr The address of the new member. 
     * @return true if the function executes successfully, false otherwise.
     * */
    function addMember(address _addr) public onlyOwner returns(bool) {
        require(!addrIsMember[_addr]);
        addrIsMember[_addr] = true;
        numOfMembers += 1;
        memberIdByAddr[_addr] = numOfMembers;
        memberAddrById[numOfMembers] = _addr;
        emit NewMemberAdded(_addr, numOfMembers, block.number);
        //assignment of owner variable made to overcome bug found in EVM which 
        //caused the owner address to overflow to 0x00...01
        owner = msg.sender;
        return true;
    }
    
    
    /**
     * Allows the owner to change the maximum amount of grams which members can buy 
     * each month. 
     * @param _newMax The new maximum amount of grams 
     * @return true if the function executes successfully, false otherwise.
     * */
    function setMaxGramsPerMonth(uint256 _newMax) public onlyOwner returns(bool) {
        require(_newMax != maxGramsPerMonth && _newMax > 0);
        emit MaxGramsPerMonthChanged(maxGramsPerMonth, _newMax);
        maxGramsPerMonth = _newMax;
        return true;
    }
    
    
    /**
     * Allows the owner to add members to the blacklist using the member's address
     * @param _addr The address of the member who is to be blacklisted
     * @return true if the function executes successfully, false otherwise.
     * */
    function addMemberToBlacklist(address _addr) public onlyOwner returns(bool) {
        emit MemberBlacklisted(_addr, getMemberIdByAddr(_addr), block.number);
        blacklist[_addr] = true;
        return true;
    }
    
    
    /**
     * Allows the owner to add members to the blacklist using the member's ID
     * @param _id The ID of the member who is to be blacklisted.
     * @return true if the function executes successfully, false otherwise.
     * */
    function addMemberToBlacklist(uint256 _id) public onlyOwner returns(bool) {
        emit MemberBlacklisted(getMemberAddrById(_id), _id, block.number);
        blacklist[getMemberAddrById(_id)] = true;
        return true;
    }
    
    
    /**
     * Allows the owner to remove members from the blacklist using the member's address. 
     * @param _addr The address of the member who is to be removed from the blacklist. 
     * @return true if the function executes successfully, false otherwise.
     * */
    function removeMemberFromBlacklist(address _addr) public onlyOwner returns(bool) {
        emit MemberRemovedFromBlacklist(_addr, getMemberIdByAddr(_addr), block.number);
        blacklist[_addr] = false;
        return true;
    }
    
    
    /**
     * Allows the owner to remove members from the blacklist using the member's ID.
     * @param _id The ID of the member who is to be removed from the blacklist.
     * @return true if the function executes successfully, false otherwise.
     * */
    function removeMemberFromBlacklist(uint256 _id) public onlyOwner returns(bool) {
        emit MemberRemovedFromBlacklist(getMemberAddrById(_id), _id, block.number);
        blacklist[getMemberAddrById(_id)] = false;
        return true;
    }
    
    
    /**
     * Allows the owner to withdraw any ERC20 token which may have been sent to this 
     * contract address by mistake. 
     * @param _addressOfToken The contract address of the ERC20 token
     * @param _recipient The receiver of the token. 
     * */
    function withdrawAnyERC20(address _addressOfToken, address _recipient) public onlyOwner {
        ERC20 token = ERC20(_addressOfToken);
        token.transfer(_recipient, token.balanceOf(address(this)));
    }
    
    
    /**
     * Allows the owner to update the monnth on the contract
     * */
    function incrementMonthNo() public onlyOwner {
        emit MonthNumberIncremented(now);
        monthNo = monthNo.add(1);
    }
}