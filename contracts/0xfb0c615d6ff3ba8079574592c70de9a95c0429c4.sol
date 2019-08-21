pragma solidity 0.4.25;

// * Samurai Quest - Levelling game that pay ether. Version 1.
// 
// * Developer     - Studio California
//                   "You can check out any time you like, but you can never leave"
//
// * Uses Linked List to store player level
//
// * Refer to https://samurai-quest.hostedwiki.co/ for detailed description.

contract SamuraiQuest {

    using SafeMath for uint256;
    using LinkedListLib for LinkedListLib.LinkedList;

    // ***Event Section
    event NewSamuraiIncoming(uint256 id, bytes32 name);
    event TheLastSamuraiBorn(uint256 id, bytes32 name, uint256 winning);
    event Retreat(uint256 id, bytes32 name, uint256 balance);

    address public owner;

    uint256 public currentSamuraiId;
    uint256 public totalProcessingFee;
    uint256 public theLastSamuraiPot;
    uint256 public theLastSamuraiEndTime;

    // ***Constant Section
    uint256 private constant MAX_LEVEL = 8;
    uint256 private constant JOINING_FEE = 0.03 ether;
    uint256 private constant PROCESSING_FEE = 0.001 ether;
    uint256 private constant REFERRAL_FEE = 0.002 ether;
    uint256 private constant THE_LAST_SAMURAI_FEE = 0.002 ether;
    uint256 private constant THE_LAST_SAMURAI_COOLDOWN = 1 days;

    struct Samurai {
        uint256 level;
        uint256 supporterWallet;
        uint256 referralWallet;
        uint256 theLastSamuraiWallet;
        bytes32 name;
        address addr;
        bool isRetreat;
        bool autoLevelUp;
    }

    mapping (address => uint256) public addressToId;
    mapping (uint256 => Samurai) public idToSamurai;
    mapping (uint256 => uint256) public idToSamuraiHeadId;
    mapping (uint256 => uint256) public idToAffiliateId;
    mapping (uint256 => uint256) public supporterCount;
    mapping (uint256 => uint256) public referralCount;
    
    mapping (uint256 => LinkedListLib.LinkedList) private levelChain; // level up chain
    uint256[9] public levelUpFee; // level up fees

    // Constructor. Deliberately does not take any parameters.
    constructor() public {
        // Set the contract owner
        owner = msg.sender;

        totalProcessingFee = 0;
        theLastSamuraiPot = 0;
        currentSamuraiId = 1;
        
        // Level up fee
        levelUpFee[1] = 0.02 ether; // 0 > 1
        levelUpFee[2] = 0.04 ether; // 1 > 2
        levelUpFee[3] = 0.08 ether; // 2 > 3
        levelUpFee[4] = 0.16 ether; // 3 > 4
        levelUpFee[5] = 0.32 ether; // 4 > 5
        levelUpFee[6] = 0.64 ether; // 5 > 6
        levelUpFee[7] = 1.28 ether; // 6 > 7
        levelUpFee[8] = 2.56 ether; // 7 > 8
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "OnlyOwner method called by non owner");
        _;
    }

    // Fund withdrawal to cover costs of operation
    function withdrawProcessingFee() public onlyOwner {
        require(totalProcessingFee <= address(this).balance, "not enough fund");
    
        uint256 amount = totalProcessingFee;

        totalProcessingFee = 0;

        owner.transfer(amount);
    }

    // Fallback function deliberately left empty.
    function () public payable { }

    /// *** join Logic

    // Set the samurai info and level to 0, then level up it
    // _name        - Name of the samurai
    // _affiliateId - Affiliate Id, affiliate will get 0.002ETH of each action
    //                performed by it's referral
    // _autoLevelUp - Let player control the level up type
    function join(bytes32 _name, uint256 _affiliateId, bool _autoLevelUp) public payable {
        require(msg.value == JOINING_FEE, "you have no enough courage");
        require(addressToId[msg.sender] == 0, "you're already in");
        require(_affiliateId >= 0 && _affiliateId < currentSamuraiId, "invalid affiliate");

        Samurai storage samurai = idToSamurai[currentSamuraiId];
        
        samurai.level = 0;
        samurai.addr = msg.sender;
        samurai.referralWallet = 0;
        samurai.theLastSamuraiWallet = 0;
        samurai.name = _name;
        samurai.isRetreat = false;
        samurai.autoLevelUp = _autoLevelUp;
        samurai.supporterWallet = JOINING_FEE;

        addressToId[msg.sender] = currentSamuraiId;

        if (_affiliateId > 0) {
            idToAffiliateId[currentSamuraiId] = _affiliateId;
            referralCount[_affiliateId] = referralCount[_affiliateId].add(1);
        }

        levelUp(currentSamuraiId);

        emit NewSamuraiIncoming(currentSamuraiId, samurai.name);

        // Increase the count for next samurai
        currentSamuraiId = currentSamuraiId.add(1);
        theLastSamuraiEndTime = now.add(THE_LAST_SAMURAI_COOLDOWN);
    }

    /// *** levelUp Logic

    // Level up the samurai, push it to the next level chain
    // Help checking the last samurai pot
    // Distribute the fund to corresponding accounts
    // Help levelling up the head of samurai 
    // _samuraiId - Id of the samurai to be levelled up
    function levelUp(uint256 _samuraiId) public {
        bool exist;
        uint256 samuraiHeadId;
        Samurai storage samurai = idToSamurai[_samuraiId];
        
        require(canLevelUp(_samuraiId), "cannot level up");

        uint256 balance = samurai.supporterWallet.add(samurai.referralWallet).add(samurai.theLastSamuraiWallet);

        require(
            balance >= levelUpFee[samurai.level.add(1)].add(PROCESSING_FEE).add(THE_LAST_SAMURAI_FEE).add(REFERRAL_FEE),
            "not enough fund to level up"
        );

        // level up
        samurai.level = samurai.level.add(1);

        // help checking the last samurai pot
        distributeTheLastSamuraiPot();

        // push the samurai Id to the corresponding level chain
        push(levelChain[samurai.level], _samuraiId);
        supporterCount[_samuraiId] = 0;

        // Check if head exist, and get it's Id
        (exist, samuraiHeadId) = levelChain[samurai.level].getAdjacent(0, true);
        
        // Distribute 0.001 ETH to poor developer
        samurai.supporterWallet = samurai.supporterWallet.sub(PROCESSING_FEE);
        totalProcessingFee = totalProcessingFee.add(PROCESSING_FEE);

        // Distribute 0.002 ETH to the last samurai pot
        samurai.supporterWallet = samurai.supporterWallet.sub(THE_LAST_SAMURAI_FEE);
        theLastSamuraiPot = theLastSamuraiPot.add(THE_LAST_SAMURAI_FEE);
        
        // Distribute 0.002 ETH to affiliate/the last samurai pot
        uint256 affiliateId = idToAffiliateId[_samuraiId];

        samurai.supporterWallet = samurai.supporterWallet.sub(REFERRAL_FEE);
        if (affiliateId == 0) {
            theLastSamuraiPot = theLastSamuraiPot.add(REFERRAL_FEE);
        } else {
            Samurai storage affiliate = idToSamurai[affiliateId];
            affiliate.referralWallet = affiliate.referralWallet.add(REFERRAL_FEE);
        }

        // check if samuraiHead exist and it should not be Samurai itself
        if (exist && samuraiHeadId != _samuraiId) {
            Samurai storage samuraiHead = idToSamurai[samuraiHeadId];

            // Distribute the level up fee to samuraiHead
            samurai.supporterWallet = samurai.supporterWallet.sub(levelUpFee[samurai.level]);
            samuraiHead.supporterWallet = samuraiHead.supporterWallet.add(levelUpFee[samurai.level]);

            // Map the samuraiId to samuraiHead struct
            idToSamuraiHeadId[_samuraiId] = samuraiHeadId;

            // Add up the supporter count of samuraiHead
            supporterCount[samuraiHeadId] = supporterCount[samuraiHeadId].add(1);

            // nested loop to level up samuraiHead
            if(canLevelUp(samuraiHeadId)) {
                // pop the samurai headoff the leve chain
                pop(levelChain[samuraiHead.level]);
                
                if(samuraiHead.autoLevelUp) {
                    levelUp(samuraiHeadId);
                } else {
                    return;
                }
            } else {
                return;
            }
        }
    }
    
    /// *** retreat Logic
    
    // Retreat the samurai, pop it off the level chain
    // Help checking the last samurai pot
    // Distribute the fund to corresponding accounts
    // _samuraiId - Id of the samurai to be retreat
    function retreat(uint256 _samuraiId) public {
        Samurai storage samurai = idToSamurai[_samuraiId];

        require(!samurai.isRetreat, "you've already quit!");
        require(samurai.addr == msg.sender, "you must be a yokai spy!");

        uint256 balance = samurai.supporterWallet.add(samurai.referralWallet).add(samurai.theLastSamuraiWallet);

        require(balance >= 0.005 ether, "fee is required, even when retreating");

        // Clear the balance, prevent re-entrancy
        samurai.supporterWallet = 0;
        samurai.theLastSamuraiWallet = 0;
        samurai.referralWallet = 0;

        // pop the player off the level chain and mark the retreat flag
        remove(levelChain[samurai.level], _samuraiId);
        samurai.isRetreat = true;
        
        // Transfer the processing fee to poor developer
        balance = balance.sub(PROCESSING_FEE);
        totalProcessingFee = totalProcessingFee.add(PROCESSING_FEE);

        balance = balance.sub(THE_LAST_SAMURAI_FEE);
        theLastSamuraiPot = theLastSamuraiPot.add(THE_LAST_SAMURAI_FEE);

        balance = balance.sub(REFERRAL_FEE);

        uint256 affiliateId = idToAffiliateId[_samuraiId];

        // No affiliate, distribute the referral fee to the last samurai pot
        if (affiliateId == 0) {
            theLastSamuraiPot = theLastSamuraiPot.add(REFERRAL_FEE);
        } else {
            Samurai storage affiliate = idToSamurai[affiliateId];
            affiliate.referralWallet = affiliate.referralWallet.add(REFERRAL_FEE);
        }

        // transfer balance to account holder
        samurai.addr.transfer(balance);

        // help checking the last samurai pot
        distributeTheLastSamuraiPot();

        emit Retreat(_samuraiId, samurai.name, balance);
    }

    /// *** withdraw Logic
    
    // Withdraw the left over fund in wallet after retreat
    // _samuraiId - Id of the samurai
    function withdraw(uint256 _samuraiId) public {
        Samurai storage samurai = idToSamurai[_samuraiId];

        require(samurai.addr == msg.sender, "you must be a yokai spy!");

        uint256 balance = samurai.supporterWallet.add(samurai.referralWallet).add(samurai.theLastSamuraiWallet);

        require(balance <= address(this).balance, "not enough fund");

        // Prevent re-entrancy
        samurai.supporterWallet = 0;
        samurai.theLastSamuraiWallet = 0;
        samurai.referralWallet = 0;

        // transfer balance to account holder
        samurai.addr.transfer(balance);
    }

    /// *** distributeTheLastSamuraiPot Logic
    
    // Distribute the last samurai pot to winner when no joining after 24 hours
    // Distribute the fund to corresponding accounts
    // _samuraiId - Id of the samurai to be retreat
    function distributeTheLastSamuraiPot() public {
        require(theLastSamuraiPot <= address(this).balance, "not enough fund");

        // When the remaining time is over
        if (theLastSamuraiEndTime <= now) {
            uint256 samuraiId = currentSamuraiId.sub(1);
            Samurai storage samurai = idToSamurai[samuraiId];

            uint256 total = theLastSamuraiPot;
            
            // again, prevent re-entrancy
            theLastSamuraiPot = 0;
            samurai.theLastSamuraiWallet = samurai.theLastSamuraiWallet.add(total);

            emit TheLastSamuraiBorn(samuraiId, samurai.name, total);
        }
    }

    /// *** toggleAutoLevelUp Logic
    
    // Toggle auto level up, for those who don't intend to play longer,
    // can set the auto level up to false
    // _samuraiId - Id of the samurai
    function toggleAutoLevelUp(uint256 _samuraiId) public {
        Samurai storage samurai = idToSamurai[_samuraiId];

        require(!samurai.isRetreat, "you've already quit!");
        require(msg.sender == samurai.addr, "you must be a yokai spy");

        samurai.autoLevelUp = !samurai.autoLevelUp;
    }

    //*** For UI

    // Returns - Id
    function getSamuraiId() public view returns(uint256) {
        return addressToId[msg.sender];
    }

    // Returns - 0: id, 1: level, 2: name, 3: isRetreat, 4: autoLevelUp, 5: isHead
    function getSamuraiInfo(uint256 _samuraiId) public view
        returns(uint256, uint256, bytes32, bool, bool, bool)
    {
        Samurai memory samurai = idToSamurai[_samuraiId];
        bool isHead = isHeadOfSamurai(_samuraiId);
        
        return (_samuraiId, samurai.level, samurai.name, samurai.isRetreat, samurai.autoLevelUp, isHead);
    }

    // Returns - 0: supperterWallet, 1: theLastSamuraiWallet, 2: referralWallet
    function getSamuraiWallet(uint256 _samuraiId) public view
        returns(uint256, uint256, uint256)
    {
        Samurai memory samurai = idToSamurai[_samuraiId];

        return (samurai.supporterWallet, samurai.theLastSamuraiWallet, samurai.referralWallet);
    }
    
    // Returns - 0: affiliateId, 1: affiliateName
    function getAffiliateInfo(uint256 _samuraiId) public view returns(uint256, bytes32) {
        uint256 affiliateId = idToAffiliateId[_samuraiId];
        Samurai memory affiliate = idToSamurai[affiliateId];

        return (affiliateId, affiliate.name);
    }

    // Returns - 0: samuraiHeadId, 1: samuraiHeadName
    function contributeTo(uint256 _samuraiId) public view returns(uint256, bytes32) {
        uint256 samuraiHeadId = idToSamuraiHeadId[_samuraiId];
        Samurai memory samuraiHead = idToSamurai[samuraiHeadId];

        return (samuraiHeadId, samuraiHead.name);
    }

    // Returns - 0: theLastSamuraiEndTime, 1: theLastSamuraiPot, 2: lastSamuraiId, 3: lastSamuraiName
    function getTheLastSamuraiInfo() public view returns(uint256, uint256, uint256, bytes32) {
        uint256 lastSamuraiId = currentSamuraiId.sub(1);

        return (theLastSamuraiEndTime, theLastSamuraiPot, lastSamuraiId, idToSamurai[lastSamuraiId].name);
    }
    
    // Returns - canLevelUp
    function canLevelUp(uint256 _id) public view returns(bool) {
        Samurai memory samurai = idToSamurai[_id];
        
        return !samurai.isRetreat && (samurai.level == 0 || (supporterCount[_id] == 2 ** samurai.level && samurai.level <= MAX_LEVEL));
    }

    // Returns - canRetreat
    function canRetreat(uint256 _id) public view returns(bool) {
        Samurai memory samurai = idToSamurai[_id];
        uint256 balance = samurai.supporterWallet.add(samurai.referralWallet).add(samurai.theLastSamuraiWallet);

        return !samurai.isRetreat && (balance >= 0.005 ether);
    }

    // Returns - canWithdraw
    function canWithdraw(uint256 _id) public view returns(bool) {
        Samurai memory samurai = idToSamurai[_id];
        uint256 balance = samurai.supporterWallet.add(samurai.referralWallet).add(samurai.theLastSamuraiWallet);

        return samurai.isRetreat && (balance > 0);
    }

    // Returns - isHeadOfSamurai
    function isHeadOfSamurai(uint256 _id) public view returns(bool) {
        Samurai memory samurai = idToSamurai[_id];
        bool exist;
        uint256 samuraiHeadId;

        (exist, samuraiHeadId) = levelChain[samurai.level].getAdjacent(0, true);

        return (exist && samuraiHeadId == _id);
    }
    
    // For linked list manipulation
    function push(LinkedListLib.LinkedList storage _levelChain, uint256 _samuraiId) private {
        _levelChain.push(_samuraiId, false);
    }
    
    function pop(LinkedListLib.LinkedList storage _levelChain) private {
        _levelChain.pop(true);
    }
    
    function remove(LinkedListLib.LinkedList storage _levelChain, uint256 _samuraiId) private {
        _levelChain.remove(_samuraiId);
    }
}

/**
 * @title LinkedListLib
 * @author Darryl Morris (o0ragman0o) and Modular.network
 * 
 * This utility library was forked from https://github.com/o0ragman0o/LibCLL
 * into the Modular-Network ethereum-libraries repo at https://github.com/Modular-Network/ethereum-libraries
 * It has been updated to add additional functionality and be more compatible with solidity 0.4.18
 * coding patterns.
 *
 * version 1.0.0
 * Copyright (c) 2017 Modular Inc.
 * The MIT License (MIT)
 * https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE
 * 
 * The LinkedListLib provides functionality for implementing data indexing using
 * a circlular linked list.
 *
 * Modular provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: modular.network.
 *
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

library LinkedListLib {


    uint256 private constant NULL = 0;
    uint256 private constant HEAD = 0;
    bool private constant PREV = false;
    bool private constant NEXT = true;
    
    struct LinkedList {
        mapping (uint256 => mapping (bool => uint256)) list;
    }

  /// @dev returns true if the list exists
  /// @param self stored linked list from contract
    function listExists(LinkedList storage self)
        internal
        view returns (bool)
    {
        // if the head nodes previous or next pointers both point to itself, then there are no items in the list
        if (self.list[HEAD][PREV] != HEAD || self.list[HEAD][NEXT] != HEAD) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev returns true if the node exists
    /// @param self stored linked list from contract
    /// @param _node a node to search for
    function nodeExists(LinkedList storage self, uint256 _node) 
        internal
        view returns (bool)
    {
        if (self.list[_node][PREV] == HEAD && self.list[_node][NEXT] == HEAD) {
            if (self.list[HEAD][NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
  
    /// @dev Returns the number of elements in the list
    /// @param self stored linked list from contract
    function sizeOf(LinkedList storage self) internal view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists, i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists, i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

    /// @dev Returns the links of a node as a tuple
    /// @param self stored linked list from contract
    /// @param _node id of the node to get
    function getNode(LinkedList storage self, uint256 _node)
        internal view returns (bool, uint256, uint256)
    {
        if (!nodeExists(self, _node)) {
            return (false, 0, 0);
        } else {
            return (true, self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

    /// @dev Returns the link of a node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node id of the node to step from
    /// @param _direction direction to step in
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        internal view returns (bool, uint256)
    {
        if (!nodeExists(self, _node)) {
            return (false, 0);
        } else {
            return (true, self.list[_node][_direction]);
        }
    }
  
    /// @dev Can be used before `insert` to build an ordered list
    /// @param self stored linked list from contract
    /// @param _node an existing node to search from, e.g. HEAD.
    /// @param _value value to seek
    /// @param _direction direction to seek in
    //  @return next first node beyond '_node' in direction `_direction`
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        internal view returns (uint256)
    {
        if (sizeOf(self) == 0) {
            return 0;
        }

        require((_node == 0) || nodeExists(self, _node));

        bool exists;
        uint256 next;

        (exists, next) = getAdjacent(self, _node, _direction);

        while ((next != 0) && (_value != next) && ((_value < next) != _direction)) {
            next = self.list[next][_direction];
        }

        return next;
    }

    /// @dev Creates a bidirectional link between two nodes on direction `_direction`
    /// @param self stored linked list from contract
    /// @param _node first node for linking
    /// @param _link  node to link to in the _direction
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction)
        internal
    {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node existing node
    /// @param _new  new node to insert
    /// @param _direction direction to insert node in
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if (!nodeExists(self, _new) && nodeExists(self, _node)) {
            uint256 c = self.list[_node][_direction];
            createLink(self, _node, _new, _direction);
            createLink(self, _new, c, _direction);

            return true;
        } else {
            return false;
        }
    }
    
    /// @dev removes an entry from the linked list
    /// @param self stored linked list from contract
    /// @param _node node to remove from the list
    function remove(LinkedList storage self, uint256 _node) internal returns (uint256) {
        if ((_node == NULL) || (!nodeExists(self, _node))) {
            return 0;
        }

        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];

        return _node;
    }

    /// @dev pushes an entry to the head of the linked list
    /// @param self stored linked list from contract
    /// @param _node new entry to push to the head
    /// @param _direction push to the head (NEXT) or tail (PREV)
    function push(LinkedList storage self, uint256 _node, bool _direction)    
        internal returns (bool)
    {
        return insert(self, HEAD, _node, _direction);
    }
    
    /// @dev pops the first entry from the linked list
    /// @param self stored linked list from contract
    /// @param _direction pop from the head (NEXT) or the tail (PREV)
    function pop(LinkedList storage self, bool _direction) 
        internal returns (uint256)
    {
        bool exists;
        uint256 adj;

        (exists, adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        
        return a % b;
    }
}