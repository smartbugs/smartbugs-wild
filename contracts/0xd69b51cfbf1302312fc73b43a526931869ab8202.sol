pragma solidity 0.4.24;

/**
 * @title LinkedListLib
 * @author Darryl Morris (o0ragman0o) and Modular.network
 *
 * This utility library was forked from https://github.com/o0ragman0o/LibCLL
 * into the Modular-Network ethereum-libraries repo at https://github.com/Modular-Network/ethereum-libraries
 * It has been updated to add additional functionality and be more compatible with solidity 0.4.18
 * coding patterns.
 *
 * version 1.1.1
 * Copyright (c) 2017 Modular Inc.
 * The MIT License (MIT)
 * https://github.com/Modular-network/ethereum-libraries/blob/master/LICENSE
 *
 * The LinkedListLib provides functionality for implementing data indexing using
 * a circlular linked list
 *
 * Modular provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: modular.network
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

    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    bool constant PREV = false;
    bool constant NEXT = true;

    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) list;
    }

    /// @dev returns true if the list exists
    /// @param self stored linked list from contract
    function listExists(LinkedList storage self)
        public
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
        public
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
    function sizeOf(LinkedList storage self) public view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists,i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists,i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

    /// @dev Returns the links of a node as a tuple
    /// @param self stored linked list from contract
    /// @param _node id of the node to get
    function getNode(LinkedList storage self, uint256 _node)
        public view returns (bool,uint256,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0,0);
        } else {
            return (true,self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

    /// @dev Returns the link of a node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node id of the node to step from
    /// @param _direction direction to step in
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        public view returns (bool,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0);
        } else {
            return (true,self.list[_node][_direction]);
        }
    }

    /// @dev Can be used before `insert` to build an ordered list
    /// @param self stored linked list from contract
    /// @param _node an existing node to search from, e.g. HEAD.
    /// @param _value value to seek
    /// @param _direction direction to seek in
    //  @return next first node beyond '_node' in direction `_direction`
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        public view returns (uint256)
    {
        if (sizeOf(self) == 0) { return 0; }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((next != 0) && (_value != next) && ((_value < next) != _direction)) next = self.list[next][_direction];
        return next;
    }

    /// @dev Creates a bidirectional link between two nodes on direction `_direction`
    /// @param self stored linked list from contract
    /// @param _node first node for linking
    /// @param _link  node to link to in the _direction
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction) private  {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
    /// @param self stored linked list from contract
    /// @param _node existing node
    /// @param _new  new node to insert
    /// @param _direction direction to insert node in
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if(!nodeExists(self,_new) && nodeExists(self,_node)) {
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
        if ((_node == NULL) || (!nodeExists(self,_node))) { return 0; }
        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];
        return _node;
    }

    /// @dev pushes an enrty to the head of the linked list
    /// @param self stored linked list from contract
    /// @param _node new entry to push to the head
    /// @param _direction push to the head (NEXT) or tail (PREV)
    function push(LinkedList storage self, uint256 _node, bool _direction) internal  {
        insert(self, HEAD, _node, _direction);
    }

    /// @dev pops the first entry from the linked list
    /// @param self stored linked list from contract
    /// @param _direction pop from the head (NEXT) or the tail (PREV)
    function pop(LinkedList storage self, bool _direction) internal returns (uint256) {
        bool exists;
        uint256 adj;

        (exists,adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}
// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20


contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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


library AttributeStore {
    struct Data {
        mapping(bytes32 => uint) store;
    }

    function getAttribute(Data storage self, bytes32 _UUID, string _attrName)
    public view returns (uint) {
        bytes32 key = keccak256(_UUID, _attrName);
        return self.store[key];
    }

    function setAttribute(Data storage self, bytes32 _UUID, string _attrName, uint _attrVal)
    public {
        bytes32 key = keccak256(_UUID, _attrName);
        self.store[key] = _attrVal;
    }
}


library DLL {

  uint constant NULL_NODE_ID = 0;

  struct Node {
    uint next;
    uint prev;
  }

  struct Data {
    mapping(uint => Node) dll;
  }

  function isEmpty(Data storage self) public view returns (bool) {
    return getStart(self) == NULL_NODE_ID;
  }

  function contains(Data storage self, uint _curr) public view returns (bool) {
    if (isEmpty(self) || _curr == NULL_NODE_ID) {
      return false;
    } 

    bool isSingleNode = (getStart(self) == _curr) && (getEnd(self) == _curr);
    bool isNullNode = (getNext(self, _curr) == NULL_NODE_ID) && (getPrev(self, _curr) == NULL_NODE_ID);
    return isSingleNode || !isNullNode;
  }

  function getNext(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].next;
  }

  function getPrev(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].prev;
  }

  function getStart(Data storage self) public view returns (uint) {
    return getNext(self, NULL_NODE_ID);
  }

  function getEnd(Data storage self) public view returns (uint) {
    return getPrev(self, NULL_NODE_ID);
  }

  /**
  @dev Inserts a new node between _prev and _next. When inserting a node already existing in 
  the list it will be automatically removed from the old position.
  @param _prev the node which _new will be inserted after
  @param _curr the id of the new node being inserted
  @param _next the node which _new will be inserted before
  */
  function insert(Data storage self, uint _prev, uint _curr, uint _next) public {
    require(_curr != NULL_NODE_ID);

    remove(self, _curr);

    require(_prev == NULL_NODE_ID || contains(self, _prev));
    require(_next == NULL_NODE_ID || contains(self, _next));

    require(getNext(self, _prev) == _next);
    require(getPrev(self, _next) == _prev);

    self.dll[_curr].prev = _prev;
    self.dll[_curr].next = _next;

    self.dll[_prev].next = _curr;
    self.dll[_next].prev = _curr;
  }

  function remove(Data storage self, uint _curr) public {
    if (!contains(self, _curr)) {
      return;
    }

    uint next = getNext(self, _curr);
    uint prev = getPrev(self, _curr);

    self.dll[next].prev = prev;
    self.dll[prev].next = next;

    delete self.dll[_curr];
  }
}



/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}





/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * @dev Supports unlimited numbers of roles and addresses.
 * @dev See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
/***************************************************************************************************
*                                                                                                  *
* (c) 2019 Quantstamp, Inc. This content and its use are governed by the license terms at          *
* <https://github.com/quantstamp/qsp-protocol-node/blob/develop/LICENSE>                           *
*                                                                                                  *
***************************************************************************************************/












/**
@title Partial-Lock-Commit-Reveal Voting scheme with ERC20 tokens
@author Team: Aspyn Palatnick, Cem Ozer, Yorke Rhodes
*/
contract PLCRVoting {

    // ============
    // EVENTS:
    // ============

    event _VoteCommitted(uint indexed pollID, uint numTokens, address indexed voter);
    event _VoteRevealed(uint indexed pollID, uint numTokens, uint votesFor, uint votesAgainst, uint indexed choice, address indexed voter, uint salt);
    event _PollCreated(uint voteQuorum, uint commitEndDate, uint revealEndDate, uint indexed pollID, address indexed creator);
    event _VotingRightsGranted(uint numTokens, address indexed voter);
    event _VotingRightsWithdrawn(uint numTokens, address indexed voter);
    event _TokensRescued(uint indexed pollID, address indexed voter);

    // ============
    // DATA STRUCTURES:
    // ============

    using AttributeStore for AttributeStore.Data;
    using DLL for DLL.Data;
    using SafeMath for uint;

    struct Poll {
        uint commitEndDate;     /// expiration date of commit period for poll
        uint revealEndDate;     /// expiration date of reveal period for poll
        uint voteQuorum;	    /// number of votes required for a proposal to pass
        uint votesFor;		    /// tally of votes supporting proposal
        uint votesAgainst;      /// tally of votes countering proposal
        mapping(address => bool) didCommit;   /// indicates whether an address committed a vote for this poll
        mapping(address => bool) didReveal;   /// indicates whether an address revealed a vote for this poll
        mapping(address => uint) voteOptions; /// stores the voteOption of an address that revealed
    }

    // ============
    // STATE VARIABLES:
    // ============

    uint constant public INITIAL_POLL_NONCE = 0;
    uint public pollNonce;

    mapping(uint => Poll) public pollMap; // maps pollID to Poll struct
    mapping(address => uint) public voteTokenBalance; // maps user's address to voteToken balance

    mapping(address => DLL.Data) dllMap;
    AttributeStore.Data store;

    EIP20Interface public token;

    /**
    @dev Initializer. Can only be called once.
    @param _token The address where the ERC20 token contract is deployed
    */
    function init(address _token) public {
        require(_token != address(0) && address(token) == address(0));

        token = EIP20Interface(_token);
        pollNonce = INITIAL_POLL_NONCE;
    }

    // ================
    // TOKEN INTERFACE:
    // ================

    /**
    @notice Loads _numTokens ERC20 tokens into the voting contract for one-to-one voting rights
    @dev Assumes that msg.sender has approved voting contract to spend on their behalf
    @param _numTokens The number of votingTokens desired in exchange for ERC20 tokens
    */
    function requestVotingRights(uint _numTokens) public {
        require(token.balanceOf(msg.sender) >= _numTokens);
        voteTokenBalance[msg.sender] += _numTokens;
        require(token.transferFrom(msg.sender, this, _numTokens));
        emit _VotingRightsGranted(_numTokens, msg.sender);
    }

    /**
    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights
    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights
    */
    function withdrawVotingRights(uint _numTokens) external {
        uint availableTokens = voteTokenBalance[msg.sender].sub(getLockedTokens(msg.sender));
        require(availableTokens >= _numTokens);
        voteTokenBalance[msg.sender] -= _numTokens;
        require(token.transfer(msg.sender, _numTokens));
        emit _VotingRightsWithdrawn(_numTokens, msg.sender);
    }

    /**
    @dev Unlocks tokens locked in unrevealed vote where poll has ended
    @param _pollID Integer identifier associated with the target poll
    */
    function rescueTokens(uint _pollID) public {
        require(isExpired(pollMap[_pollID].revealEndDate));
        require(dllMap[msg.sender].contains(_pollID));

        dllMap[msg.sender].remove(_pollID);
        emit _TokensRescued(_pollID, msg.sender);
    }

    /**
    @dev Unlocks tokens locked in unrevealed votes where polls have ended
    @param _pollIDs Array of integer identifiers associated with the target polls
    */
    function rescueTokensInMultiplePolls(uint[] _pollIDs) public {
        // loop through arrays, rescuing tokens from all
        for (uint i = 0; i < _pollIDs.length; i++) {
            rescueTokens(_pollIDs[i]);
        }
    }

    // =================
    // VOTING INTERFACE:
    // =================

    /**
    @notice Commits vote using hash of choice and secret salt to conceal vote until reveal
    @param _pollID Integer identifier associated with target poll
    @param _secretHash Commit keccak256 hash of voter's choice and salt (tightly packed in this order)
    @param _numTokens The number of tokens to be committed towards the target poll
    @param _prevPollID The ID of the poll that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVote(uint _pollID, bytes32 _secretHash, uint _numTokens, uint _prevPollID) public {
        require(commitPeriodActive(_pollID));

        // if msg.sender doesn't have enough voting rights,
        // request for enough voting rights
        if (voteTokenBalance[msg.sender] < _numTokens) {
            uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);
            requestVotingRights(remainder);
        }

        // make sure msg.sender has enough voting rights
        require(voteTokenBalance[msg.sender] >= _numTokens);
        // prevent user from committing to zero node placeholder
        require(_pollID != 0);
        // prevent user from committing a secretHash of 0
        require(_secretHash != 0);

        // Check if _prevPollID exists in the user's DLL or if _prevPollID is 0
        require(_prevPollID == 0 || dllMap[msg.sender].contains(_prevPollID));

        uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);

        // edge case: in-place update
        if (nextPollID == _pollID) {
            nextPollID = dllMap[msg.sender].getNext(_pollID);
        }

        require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));
        dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);

        bytes32 UUID = attrUUID(msg.sender, _pollID);

        store.setAttribute(UUID, "numTokens", _numTokens);
        store.setAttribute(UUID, "commitHash", uint(_secretHash));

        pollMap[_pollID].didCommit[msg.sender] = true;
        emit _VoteCommitted(_pollID, _numTokens, msg.sender);
    }

    /**
    @notice                 Commits votes using hashes of choices and secret salts to conceal votes until reveal
    @param _pollIDs         Array of integer identifiers associated with target polls
    @param _secretHashes    Array of commit keccak256 hashes of voter's choices and salts (tightly packed in this order)
    @param _numsTokens      Array of numbers of tokens to be committed towards the target polls
    @param _prevPollIDs     Array of IDs of the polls that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVotes(uint[] _pollIDs, bytes32[] _secretHashes, uint[] _numsTokens, uint[] _prevPollIDs) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _secretHashes.length);
        require(_pollIDs.length == _numsTokens.length);
        require(_pollIDs.length == _prevPollIDs.length);

        // loop through arrays, committing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            commitVote(_pollIDs[i], _secretHashes[i], _numsTokens[i], _prevPollIDs[i]);
        }
    }

    /**
    @dev Compares previous and next poll's committed tokens for sorting purposes
    @param _prevID Integer identifier associated with previous poll in sorted order
    @param _nextID Integer identifier associated with next poll in sorted order
    @param _voter Address of user to check DLL position for
    @param _numTokens The number of tokens to be committed towards the poll (used for sorting)
    @return valid Boolean indication of if the specified position maintains the sort
    */
    function validPosition(uint _prevID, uint _nextID, address _voter, uint _numTokens) public constant returns (bool valid) {
        bool prevValid = (_numTokens >= getNumTokens(_voter, _prevID));
        // if next is zero node, _numTokens does not need to be greater
        bool nextValid = (_numTokens <= getNumTokens(_voter, _nextID) || _nextID == 0);
        return prevValid && nextValid;
    }

    /**
    @notice Reveals vote with choice and secret salt used in generating commitHash to attribute committed tokens
    @param _pollID Integer identifier associated with target poll
    @param _voteOption Vote choice used to generate commitHash for associated poll
    @param _salt Secret number used to generate commitHash for associated poll
    */
    function revealVote(uint _pollID, uint _voteOption, uint _salt) public {
        // Make sure the reveal period is active
        require(revealPeriodActive(_pollID));
        require(pollMap[_pollID].didCommit[msg.sender]);                         // make sure user has committed a vote for this poll
        require(!pollMap[_pollID].didReveal[msg.sender]);                        // prevent user from revealing multiple times
        require(keccak256(abi.encodePacked(_voteOption, _salt)) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash

        uint numTokens = getNumTokens(msg.sender, _pollID);

        if (_voteOption == 1) {// apply numTokens to appropriate poll choice
            pollMap[_pollID].votesFor += numTokens;
        } else {
            pollMap[_pollID].votesAgainst += numTokens;
        }

        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal
        pollMap[_pollID].didReveal[msg.sender] = true;
        pollMap[_pollID].voteOptions[msg.sender] = _voteOption;

        emit _VoteRevealed(_pollID, numTokens, pollMap[_pollID].votesFor, pollMap[_pollID].votesAgainst, _voteOption, msg.sender, _salt);
    }

    /**
    @notice             Reveals multiple votes with choices and secret salts used in generating commitHashes to attribute committed tokens
    @param _pollIDs     Array of integer identifiers associated with target polls
    @param _voteOptions Array of vote choices used to generate commitHashes for associated polls
    @param _salts       Array of secret numbers used to generate commitHashes for associated polls
    */
    function revealVotes(uint[] _pollIDs, uint[] _voteOptions, uint[] _salts) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _voteOptions.length);
        require(_pollIDs.length == _salts.length);

        // loop through arrays, revealing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            revealVote(_pollIDs[i], _voteOptions[i], _salts[i]);
        }
    }

    /**
    @param _voter           Address of voter who voted in the majority bloc
    @param _pollID          Integer identifier associated with target poll
    @return correctVotes    Number of tokens voted for winning option
    */
    function getNumPassingTokens(address _voter, uint _pollID) public constant returns (uint correctVotes) {
        require(pollEnded(_pollID));
        require(pollMap[_pollID].didReveal[_voter]);

        uint winningChoice = isPassed(_pollID) ? 1 : 0;
        uint voterVoteOption = pollMap[_pollID].voteOptions[_voter];

        require(voterVoteOption == winningChoice, "Voter revealed, but not in the majority");

        return getNumTokens(_voter, _pollID);
    }

    // ==================
    // POLLING INTERFACE:
    // ==================

    /**
    @dev Initiates a poll with canonical configured parameters at pollID emitted by PollCreated event
    @param _voteQuorum Type of majority (out of 100) that is necessary for poll to be successful
    @param _commitDuration Length of desired commit period in seconds
    @param _revealDuration Length of desired reveal period in seconds
    */
    function startPoll(uint _voteQuorum, uint _commitDuration, uint _revealDuration) public returns (uint pollID) {
        pollNonce = pollNonce + 1;

        uint commitEndDate = block.timestamp.add(_commitDuration);
        uint revealEndDate = commitEndDate.add(_revealDuration);

        pollMap[pollNonce] = Poll({
            voteQuorum: _voteQuorum,
            commitEndDate: commitEndDate,
            revealEndDate: revealEndDate,
            votesFor: 0,
            votesAgainst: 0
        });

        emit _PollCreated(_voteQuorum, commitEndDate, revealEndDate, pollNonce, msg.sender);
        return pollNonce;
    }

    /**
    @notice Determines if proposal has passed
    @dev Check if votesFor out of totalVotes exceeds votesQuorum (requires pollEnded)
    @param _pollID Integer identifier associated with target poll
    */
    function isPassed(uint _pollID) constant public returns (bool passed) {
        require(pollEnded(_pollID));

        Poll memory poll = pollMap[_pollID];
        return (100 * poll.votesFor) > (poll.voteQuorum * (poll.votesFor + poll.votesAgainst));
    }

    // ----------------
    // POLLING HELPERS:
    // ----------------

    /**
    @dev Gets the total winning votes for reward distribution purposes
    @param _pollID Integer identifier associated with target poll
    @return Total number of votes committed to the winning option for specified poll
    */
    function getTotalNumberOfTokensForWinningOption(uint _pollID) constant public returns (uint numTokens) {
        require(pollEnded(_pollID));

        if (isPassed(_pollID))
            return pollMap[_pollID].votesFor;
        else
            return pollMap[_pollID].votesAgainst;
    }

    /**
    @notice Determines if poll is over
    @dev Checks isExpired for specified poll's revealEndDate
    @return Boolean indication of whether polling period is over
    */
    function pollEnded(uint _pollID) constant public returns (bool ended) {
        require(pollExists(_pollID));

        return isExpired(pollMap[_pollID].revealEndDate);
    }

    /**
    @notice Checks if the commit period is still active for the specified poll
    @dev Checks isExpired for the specified poll's commitEndDate
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of isCommitPeriodActive for target poll
    */
    function commitPeriodActive(uint _pollID) constant public returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].commitEndDate);
    }

    /**
    @notice Checks if the reveal period is still active for the specified poll
    @dev Checks isExpired for the specified poll's revealEndDate
    @param _pollID Integer identifier associated with target poll
    */
    function revealPeriodActive(uint _pollID) constant public returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].revealEndDate) && !commitPeriodActive(_pollID);
    }

    /**
    @dev Checks if user has committed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of whether user has committed
    */
    function didCommit(address _voter, uint _pollID) constant public returns (bool committed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didCommit[_voter];
    }

    /**
    @dev Checks if user has revealed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of whether user has revealed
    */
    function didReveal(address _voter, uint _pollID) constant public returns (bool revealed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didReveal[_voter];
    }

    /**
    @dev Checks if a poll exists
    @param _pollID The pollID whose existance is to be evaluated.
    @return Boolean Indicates whether a poll exists for the provided pollID
    */
    function pollExists(uint _pollID) constant public returns (bool exists) {
        return (_pollID != 0 && _pollID <= pollNonce);
    }

    // ---------------------------
    // DOUBLE-LINKED-LIST HELPERS:
    // ---------------------------

    /**
    @dev Gets the bytes32 commitHash property of target poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Bytes32 hash property attached to target poll
    */
    function getCommitHash(address _voter, uint _pollID) constant public returns (bytes32 commitHash) {
        return bytes32(store.getAttribute(attrUUID(_voter, _pollID), "commitHash"));
    }

    /**
    @dev Wrapper for getAttribute with attrName="numTokens"
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Number of tokens committed to poll in sorted poll-linked-list
    */
    function getNumTokens(address _voter, uint _pollID) constant public returns (uint numTokens) {
        return store.getAttribute(attrUUID(_voter, _pollID), "numTokens");
    }

    /**
    @dev Gets top element of sorted poll-linked-list
    @param _voter Address of user to check against
    @return Integer identifier to poll with maximum number of tokens committed to it
    */
    function getLastNode(address _voter) constant public returns (uint pollID) {
        return dllMap[_voter].getPrev(0);
    }

    /**
    @dev Gets the numTokens property of getLastNode
    @param _voter Address of user to check against
    @return Maximum number of tokens committed in poll specified
    */
    function getLockedTokens(address _voter) constant public returns (uint numTokens) {
        return getNumTokens(_voter, getLastNode(_voter));
    }

    /*
    @dev Takes the last node in the user's DLL and iterates backwards through the list searching
    for a node with a value less than or equal to the provided _numTokens value. When such a node
    is found, if the provided _pollID matches the found nodeID, this operation is an in-place
    update. In that case, return the previous node of the node being updated. Otherwise return the
    first node that was found with a value less than or equal to the provided _numTokens.
    @param _voter The voter whose DLL will be searched
    @param _numTokens The value for the numTokens attribute in the node to be inserted
    @return the node which the propoded node should be inserted after
    */
    function getInsertPointForNumTokens(address _voter, uint _numTokens, uint _pollID)
    constant public returns (uint prevNode) {
        // Get the last node in the list and the number of tokens in that node
        uint nodeID = getLastNode(_voter);
        uint tokensInNode = getNumTokens(_voter, nodeID);

        // Iterate backwards through the list until reaching the root node
        while(nodeID != 0) {
            // Get the number of tokens in the current node
            tokensInNode = getNumTokens(_voter, nodeID);
            if(tokensInNode <= _numTokens) { // We found the insert point!
                if(nodeID == _pollID) {
                    // This is an in-place update. Return the prev node of the node being updated
                    nodeID = dllMap[_voter].getPrev(nodeID);
                }
                // Return the insert point
                return nodeID;
            }
            // We did not find the insert point. Continue iterating backwards through the list
            nodeID = dllMap[_voter].getPrev(nodeID);
        }

        // The list is empty, or a smaller value than anything else in the list is being inserted
        return nodeID;
    }

    // ----------------
    // GENERAL HELPERS:
    // ----------------

    /**
    @dev Checks if an expiration date has been reached
    @param _terminationDate Integer timestamp of date to compare current timestamp with
    @return expired Boolean indication of whether the terminationDate has passed
    */
    function isExpired(uint _terminationDate) constant public returns (bool expired) {
        return (block.timestamp > _terminationDate);
    }

    /**
    @dev Generates an identifier which associates a user and a poll together
    @param _pollID Integer identifier associated with target poll
    @return UUID Hash which is deterministic from _user and _pollID
    */
    function attrUUID(address _user, uint _pollID) public pure returns (bytes32 UUID) {
        return keccak256(abi.encodePacked(_user, _pollID));
    }
}



contract Parameterizer {

    // ------
    // EVENTS
    // ------

    event _ReparameterizationProposal(string name, uint value, bytes32 propID, uint deposit, uint appEndDate, address indexed proposer);
    event _NewChallenge(bytes32 indexed propID, uint challengeID, uint commitEndDate, uint revealEndDate, address indexed challenger);
    event _ProposalAccepted(bytes32 indexed propID, string name, uint value);
    event _ProposalExpired(bytes32 indexed propID);
    event _ChallengeSucceeded(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _ChallengeFailed(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);


    // ------
    // DATA STRUCTURES
    // ------

    using SafeMath for uint;

    struct ParamProposal {
        uint appExpiry;
        uint challengeID;
        uint deposit;
        string name;
        address owner;
        uint processBy;
        uint value;
    }

    struct Challenge {
        uint rewardPool;        // (remaining) pool of tokens distributed amongst winning voters
        address challenger;     // owner of Challenge
        bool resolved;          // indication of if challenge is resolved
        uint stake;             // number of tokens at risk for either party during challenge
        uint winningTokens;     // (remaining) amount of tokens used for voting by the winning side
        mapping(address => bool) tokenClaims;
    }

    // ------
    // STATE
    // ------

    mapping(bytes32 => uint) public params;

    // maps challengeIDs to associated challenge data
    mapping(uint => Challenge) public challenges;

    // maps pollIDs to intended data change if poll passes
    mapping(bytes32 => ParamProposal) public proposals;

    // Global Variables
    EIP20Interface public token;
    PLCRVoting public voting;
    uint public PROCESSBY = 604800; // 7 days

    /**
    @dev Initializer        Can only be called once
    @param _token           The address where the ERC20 token contract is deployed
    @param _plcr            address of a PLCR voting contract for the provided token
    @notice _parameters     array of canonical parameters
    */
    function init(
        address _token,
        address _plcr,
        uint[] _parameters
    ) public {
        require(_token != 0 && address(token) == 0);
        require(_plcr != 0 && address(voting) == 0);

        token = EIP20Interface(_token);
        voting = PLCRVoting(_plcr);

        // minimum deposit for listing to be whitelisted
        set("minDeposit", _parameters[0]);

        // minimum deposit to propose a reparameterization
        set("pMinDeposit", _parameters[1]);

        // period over which applicants wait to be whitelisted
        set("applyStageLen", _parameters[2]);

        // period over which reparmeterization proposals wait to be processed
        set("pApplyStageLen", _parameters[3]);

        // length of commit period for voting
        set("commitStageLen", _parameters[4]);

        // length of commit period for voting in parameterizer
        set("pCommitStageLen", _parameters[5]);

        // length of reveal period for voting
        set("revealStageLen", _parameters[6]);

        // length of reveal period for voting in parameterizer
        set("pRevealStageLen", _parameters[7]);

        // percentage of losing party's deposit distributed to winning party
        set("dispensationPct", _parameters[8]);

        // percentage of losing party's deposit distributed to winning party in parameterizer
        set("pDispensationPct", _parameters[9]);

        // type of majority out of 100 necessary for candidate success
        set("voteQuorum", _parameters[10]);

        // type of majority out of 100 necessary for proposal success in parameterizer
        set("pVoteQuorum", _parameters[11]);

        // minimum length of time user has to wait to exit the registry
        set("exitTimeDelay", _parameters[12]);

        // maximum length of time user can wait to exit the registry
        set("exitPeriodLen", _parameters[13]);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE
    // -----------------------

    /**
    @notice propose a reparamaterization of the key _name's value to _value.
    @param _name the name of the proposed param to be set
    @param _value the proposed value to set the param to be set
    */
    function proposeReparameterization(string _name, uint _value) public returns (bytes32) {
        uint deposit = get("pMinDeposit");
        bytes32 propID = keccak256(abi.encodePacked(_name, _value));

        if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("dispensationPct")) ||
            keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("pDispensationPct"))) {
            require(_value <= 100);
        }

        require(!propExists(propID)); // Forbid duplicate proposals
        require(get(_name) != _value); // Forbid NOOP reparameterizations

        // attach name and value to pollID
        proposals[propID] = ParamProposal({
            appExpiry: now.add(get("pApplyStageLen")),
            challengeID: 0,
            deposit: deposit,
            name: _name,
            owner: msg.sender,
            processBy: now.add(get("pApplyStageLen"))
                .add(get("pCommitStageLen"))
                .add(get("pRevealStageLen"))
                .add(PROCESSBY),
            value: _value
        });

        require(token.transferFrom(msg.sender, this, deposit)); // escrow tokens (deposit amt)

        emit _ReparameterizationProposal(_name, _value, propID, deposit, proposals[propID].appExpiry, msg.sender);
        return propID;
    }

    /**
    @notice challenge the provided proposal ID, and put tokens at stake to do so.
    @param _propID the proposal ID to challenge
    */
    function challengeReparameterization(bytes32 _propID) public returns (uint challengeID) {
        ParamProposal memory prop = proposals[_propID];
        uint deposit = prop.deposit;

        require(propExists(_propID) && prop.challengeID == 0);

        //start poll
        uint pollID = voting.startPoll(
            get("pVoteQuorum"),
            get("pCommitStageLen"),
            get("pRevealStageLen")
        );

        challenges[pollID] = Challenge({
            challenger: msg.sender,
            rewardPool: SafeMath.sub(100, get("pDispensationPct")).mul(deposit).div(100),
            stake: deposit,
            resolved: false,
            winningTokens: 0
        });

        proposals[_propID].challengeID = pollID;       // update listing to store most recent challenge

        //take tokens from challenger
        require(token.transferFrom(msg.sender, this, deposit));

        (uint commitEndDate, uint revealEndDate,,,) = voting.pollMap(pollID);

        emit _NewChallenge(_propID, pollID, commitEndDate, revealEndDate, msg.sender);
        return pollID;
    }

    /**
    @notice             for the provided proposal ID, set it, resolve its challenge, or delete it depending on whether it can be set, has a challenge which can be resolved, or if its "process by" date has passed
    @param _propID      the proposal ID to make a determination and state transition for
    */
    function processProposal(bytes32 _propID) public {
        ParamProposal storage prop = proposals[_propID];
        address propOwner = prop.owner;
        uint propDeposit = prop.deposit;


        // Before any token transfers, deleting the proposal will ensure that if reentrancy occurs the
        // prop.owner and prop.deposit will be 0, thereby preventing theft
        if (canBeSet(_propID)) {
            // There is no challenge against the proposal. The processBy date for the proposal has not
            // passed, but the proposal's appExpirty date has passed.
            set(prop.name, prop.value);
            emit _ProposalAccepted(_propID, prop.name, prop.value);
            delete proposals[_propID];
            require(token.transfer(propOwner, propDeposit));
        } else if (challengeCanBeResolved(_propID)) {
            // There is a challenge against the proposal.
            resolveChallenge(_propID);
        } else if (now > prop.processBy) {
            // There is no challenge against the proposal, but the processBy date has passed.
            emit _ProposalExpired(_propID);
            delete proposals[_propID];
            require(token.transfer(propOwner, propDeposit));
        } else {
            // There is no challenge against the proposal, and neither the appExpiry date nor the
            // processBy date has passed.
            revert();
        }

        assert(get("dispensationPct") <= 100);
        assert(get("pDispensationPct") <= 100);

        // verify that future proposal appExpiry and processBy times will not overflow
        now.add(get("pApplyStageLen"))
            .add(get("pCommitStageLen"))
            .add(get("pRevealStageLen"))
            .add(PROCESSBY);

        delete proposals[_propID];
    }

    /**
    @notice                 Claim the tokens owed for the msg.sender in the provided challenge
    @param _challengeID     the challenge ID to claim tokens for
    */
    function claimReward(uint _challengeID) public {
        Challenge storage challenge = challenges[_challengeID];
        // ensure voter has not already claimed tokens and challenge results have been processed
        require(challenge.tokenClaims[msg.sender] == false);
        require(challenge.resolved == true);

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID);
        uint reward = voterReward(msg.sender, _challengeID);

        // subtract voter's information to preserve the participation ratios of other voters
        // compared to the remaining pool of rewards
        challenge.winningTokens -= voterTokens;
        challenge.rewardPool -= reward;

        // ensures a voter cannot claim tokens again
        challenge.tokenClaims[msg.sender] = true;

        emit _RewardClaimed(_challengeID, reward, msg.sender);
        require(token.transfer(msg.sender, reward));
    }

    /**
    @dev                    Called by a voter to claim their rewards for each completed vote.
                            Someone must call updateStatus() before this can be called.
    @param _challengeIDs    The PLCR pollIDs of the challenges rewards are being claimed for
    */
    function claimRewards(uint[] _challengeIDs) public {
        // loop through arrays, claiming each individual vote reward
        for (uint i = 0; i < _challengeIDs.length; i++) {
            claimReward(_challengeIDs[i]);
        }
    }

    // --------
    // GETTERS
    // --------

    /**
    @dev                Calculates the provided voter's token reward for the given poll.
    @param _voter       The address of the voter whose reward balance is to be returned
    @param _challengeID The ID of the challenge the voter's reward is being calculated for
    @return             The uint indicating the voter's reward
    */
    function voterReward(address _voter, uint _challengeID)
    public view returns (uint) {
        uint winningTokens = challenges[_challengeID].winningTokens;
        uint rewardPool = challenges[_challengeID].rewardPool;
        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID);
        return (voterTokens * rewardPool) / winningTokens;
    }

    /**
    @notice Determines whether a proposal passed its application stage without a challenge
    @param _propID The proposal ID for which to determine whether its application stage passed without a challenge
    */
    function canBeSet(bytes32 _propID) view public returns (bool) {
        ParamProposal memory prop = proposals[_propID];

        return (now > prop.appExpiry && now < prop.processBy && prop.challengeID == 0);
    }

    /**
    @notice Determines whether a proposal exists for the provided proposal ID
    @param _propID The proposal ID whose existance is to be determined
    */
    function propExists(bytes32 _propID) view public returns (bool) {
        return proposals[_propID].processBy > 0;
    }

    /**
    @notice Determines whether the provided proposal ID has a challenge which can be resolved
    @param _propID The proposal ID whose challenge to inspect
    */
    function challengeCanBeResolved(bytes32 _propID) view public returns (bool) {
        ParamProposal memory prop = proposals[_propID];
        Challenge memory challenge = challenges[prop.challengeID];

        return (prop.challengeID > 0 && challenge.resolved == false && voting.pollEnded(prop.challengeID));
    }

    /**
    @notice Determines the number of tokens to awarded to the winning party in a challenge
    @param _challengeID The challengeID to determine a reward for
    */
    function challengeWinnerReward(uint _challengeID) public view returns (uint) {
        if(voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
            // Edge case, nobody voted, give all tokens to the challenger.
            return 2 * challenges[_challengeID].stake;
        }

        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;
    }

    /**
    @notice gets the parameter keyed by the provided name value from the params mapping
    @param _name the key whose value is to be determined
    */
    function get(string _name) public view returns (uint value) {
        return params[keccak256(abi.encodePacked(_name))];
    }

    /**
    @dev                Getter for Challenge tokenClaims mappings
    @param _challengeID The challengeID to query
    @param _voter       The voter whose claim status to query for the provided challengeID
    */
    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {
        return challenges[_challengeID].tokenClaims[_voter];
    }

    // ----------------
    // PRIVATE FUNCTIONS
    // ----------------

    /**
    @dev resolves a challenge for the provided _propID. It must be checked in advance whether the _propID has a challenge on it
    @param _propID the proposal ID whose challenge is to be resolved.
    */
    function resolveChallenge(bytes32 _propID) private {
        ParamProposal memory prop = proposals[_propID];
        Challenge storage challenge = challenges[prop.challengeID];

        // winner gets back their full staked deposit, and dispensationPct*loser's stake
        uint reward = challengeWinnerReward(prop.challengeID);

        challenge.winningTokens = voting.getTotalNumberOfTokensForWinningOption(prop.challengeID);
        challenge.resolved = true;

        if (voting.isPassed(prop.challengeID)) { // The challenge failed
            if(prop.processBy > now) {
                set(prop.name, prop.value);
            }
            emit _ChallengeFailed(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);
            require(token.transfer(prop.owner, reward));
        }
        else { // The challenge succeeded or nobody voted
            emit _ChallengeSucceeded(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);
            require(token.transfer(challenges[prop.challengeID].challenger, reward));
        }
    }

    /**
    @dev sets the param keted by the provided name to the provided value
    @param _name the name of the param to be set
    @param _value the value to set the param to be set
    */
    function set(string _name, uint _value) private {
        params[keccak256(abi.encodePacked(_name))] = _value;
    }
}
 // Imports PLCRVoting and SafeMath









/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}








/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    checkRole(msg.sender, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr)
    onlyOwner
    public
  {
    addRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressAdded(addr);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address addr)
    public
    view
    returns (bool)
  {
    return hasRole(addr, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      addAddressToWhitelist(addrs[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr)
    onlyOwner
    public
  {
    removeRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressRemoved(addr);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      removeAddressFromWhitelist(addrs[i]);
    }
  }

}

/***************************************************************************************************
*                                                                                                  *
* (c) 2019 Quantstamp, Inc. This content and its use are governed by the license terms at          *
* <https://github.com/quantstamp/qsp-protocol-node/blob/develop/LICENSE>                           *
*                                                                                                  *
***************************************************************************************************/









contract Registry {

    // ------
    // EVENTS
    // ------

    event _Application(bytes32 indexed listingHash, uint deposit, uint appEndDate, string data, address indexed applicant);
    event _Challenge(bytes32 indexed listingHash, uint challengeID, string data, uint commitEndDate, uint revealEndDate, address indexed challenger);
    event _Deposit(bytes32 indexed listingHash, uint added, uint newTotal, address indexed owner);
    event _Withdrawal(bytes32 indexed listingHash, uint withdrew, uint newTotal, address indexed owner);
    event _ApplicationWhitelisted(bytes32 indexed listingHash);
    event _ApplicationRemoved(bytes32 indexed listingHash);
    event _ListingRemoved(bytes32 indexed listingHash);
    event _ListingWithdrawn(bytes32 indexed listingHash, address indexed owner);
    event _TouchAndRemoved(bytes32 indexed listingHash);
    event _ChallengeFailed(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _ChallengeSucceeded(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);
    event _ExitInitialized(bytes32 indexed listingHash, uint exitTime, uint exitDelayEndDate, address indexed owner);

    using SafeMath for uint;

    struct Listing {
        uint applicationExpiry; // Expiration date of apply stage
        bool whitelisted;       // Indicates registry status
        address owner;          // Owner of Listing
        uint unstakedDeposit;   // Number of tokens in the listing not locked in a challenge
        uint challengeID;       // Corresponds to a PollID in PLCRVoting
	uint exitTime;		// Time the listing may leave the registry
        uint exitTimeExpiry;    // Expiration date of exit period
    }

    struct Challenge {
        uint rewardPool;        // (remaining) Pool of tokens to be distributed to winning voters
        address challenger;     // Owner of Challenge
        bool resolved;          // Indication of if challenge is resolved
        uint stake;             // Number of tokens at stake for either party during challenge
        uint totalTokens;       // (remaining) Number of tokens used in voting by the winning side
        mapping(address => bool) tokenClaims; // Indicates whether a voter has claimed a reward yet
    }

    // Maps challengeIDs to associated challenge data
    mapping(uint => Challenge) public challenges;

    // Maps listingHashes to associated listingHash data
    mapping(bytes32 => Listing) public listings;

    // Global Variables
    EIP20Interface public token;
    PLCRVoting public voting;
    Parameterizer public parameterizer;
    string public name;

    /**
    @dev Initializer. Can only be called once.
    @param _token The address where the ERC20 token contract is deployed
    */
    function init(address _token, address _voting, address _parameterizer, string _name) public {
        require(_token != 0 && address(token) == 0);
        require(_voting != 0 && address(voting) == 0);
        require(_parameterizer != 0 && address(parameterizer) == 0);

        token = EIP20Interface(_token);
        voting = PLCRVoting(_voting);
        parameterizer = Parameterizer(_parameterizer);
        name = _name;
    }

    // --------------------
    // PUBLISHER INTERFACE:
    // --------------------

    /**
    @dev                Allows a user to start an application. Takes tokens from user and sets
                        apply stage end time.
    @param _listingHash The hash of a potential listing a user is applying to add to the registry
    @param _amount      The number of ERC20 tokens a user is willing to potentially stake
    @param _data        Extra data relevant to the application. Think IPFS hashes.
    */
    function apply(bytes32 _listingHash, uint _amount, string _data) external {
        require(!isWhitelisted(_listingHash));
        require(!appWasMade(_listingHash));
        require(_amount >= parameterizer.get("minDeposit"));

        // Sets owner
        Listing storage listing = listings[_listingHash];
        listing.owner = msg.sender;

        // Sets apply stage end time
        listing.applicationExpiry = block.timestamp.add(parameterizer.get("applyStageLen"));
        listing.unstakedDeposit = _amount;

        // Transfers tokens from user to Registry contract
        require(token.transferFrom(listing.owner, this, _amount));

        emit _Application(_listingHash, _amount, listing.applicationExpiry, _data, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to increase their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of
    @param _amount      The number of ERC20 tokens to increase a user's unstaked deposit
    */
    function deposit(bytes32 _listingHash, uint _amount) external {
        Listing storage listing = listings[_listingHash];

        require(listing.owner == msg.sender);

        listing.unstakedDeposit += _amount;
        require(token.transferFrom(msg.sender, this, _amount));

        emit _Deposit(_listingHash, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to decrease their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of.
    @param _amount      The number of ERC20 tokens to withdraw from the unstaked deposit.
    */
    function withdraw(bytes32 _listingHash, uint _amount) external {
        Listing storage listing = listings[_listingHash];

        require(listing.owner == msg.sender);
        require(_amount <= listing.unstakedDeposit);
        require(listing.unstakedDeposit - _amount >= parameterizer.get("minDeposit"));

        listing.unstakedDeposit -= _amount;
        require(token.transfer(msg.sender, _amount));

        emit _Withdrawal(_listingHash, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev		Initialize an exit timer for a listing to leave the whitelist
    @param _listingHash	A listing hash msg.sender is the owner of
    */
    function initExit(bytes32 _listingHash) external {
        Listing storage listing = listings[_listingHash];

        require(msg.sender == listing.owner);
        require(isWhitelisted(_listingHash));
        // Cannot exit during ongoing challenge
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved);

        // Ensure user never initializedExit or exitPeriodLen passed
        require(listing.exitTime == 0 || now > listing.exitTimeExpiry);

        // Set when the listing may be removed from the whitelist
        listing.exitTime = now.add(parameterizer.get("exitTimeDelay"));
	// Set exit period end time
	listing.exitTimeExpiry = listing.exitTime.add(parameterizer.get("exitPeriodLen"));
        emit _ExitInitialized(_listingHash, listing.exitTime,
            listing.exitTimeExpiry, msg.sender);
    }

    /**
    @dev		Allow a listing to leave the whitelist
    @param _listingHash A listing hash msg.sender is the owner of
    */
    function finalizeExit(bytes32 _listingHash) external {
        Listing storage listing = listings[_listingHash];

        require(msg.sender == listing.owner);
        require(isWhitelisted(_listingHash));
        // Cannot exit during ongoing challenge
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved);

        // Make sure the exit was initialized
        require(listing.exitTime > 0);
        // Time to exit has to be after exit delay but before the exitPeriodLen is over
	require(listing.exitTime < now && now < listing.exitTimeExpiry);

        resetListing(_listingHash);
        emit _ListingWithdrawn(_listingHash, msg.sender);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE:
    // -----------------------

    /**
    @dev                Starts a poll for a listingHash which is either in the apply stage or
                        already in the whitelist. Tokens are taken from the challenger and the
                        applicant's deposits are locked.
    @param _listingHash The listingHash being challenged, whether listed or in application
    @param _data        Extra data relevant to the challenge. Think IPFS hashes.
    */
    function challenge(bytes32 _listingHash, string _data) external returns (uint challengeID) {
        Listing storage listing = listings[_listingHash];
        uint minDeposit = parameterizer.get("minDeposit");

        // Listing must be in apply stage or already on the whitelist
        require(appWasMade(_listingHash) || listing.whitelisted);
        // Prevent multiple challenges
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved);

        if (listing.unstakedDeposit < minDeposit) {
            // Not enough tokens, listingHash auto-delisted
            resetListing(_listingHash);
            emit _TouchAndRemoved(_listingHash);
            return 0;
        }

        // Starts poll
        uint pollID = voting.startPoll(
            parameterizer.get("voteQuorum"),
            parameterizer.get("commitStageLen"),
            parameterizer.get("revealStageLen")
        );

        uint oneHundred = 100; // Kludge that we need to use SafeMath
        challenges[pollID] = Challenge({
            challenger: msg.sender,
            rewardPool: ((oneHundred.sub(parameterizer.get("dispensationPct"))).mul(minDeposit)).div(100),
            stake: minDeposit,
            resolved: false,
            totalTokens: 0
        });

        // Updates listingHash to store most recent challenge
        listing.challengeID = pollID;

        // Locks tokens for listingHash during challenge
        listing.unstakedDeposit -= minDeposit;

        // Takes tokens from challenger
        require(token.transferFrom(msg.sender, this, minDeposit));

        (uint commitEndDate, uint revealEndDate,,,) = voting.pollMap(pollID);

        emit _Challenge(_listingHash, pollID, _data, commitEndDate, revealEndDate, msg.sender);
        return pollID;
    }

    /**
    @dev                Updates a listingHash's status from 'application' to 'listing' or resolves
                        a challenge if one exists.
    @param _listingHash The listingHash whose status is being updated
    */
    function updateStatus(bytes32 _listingHash) public {
        if (canBeWhitelisted(_listingHash)) {
            whitelistApplication(_listingHash);
        } else if (challengeCanBeResolved(_listingHash)) {
            resolveChallenge(_listingHash);
        } else {
            revert();
        }
    }

    /**
    @dev                  Updates an array of listingHashes' status from 'application' to 'listing' or resolves
                          a challenge if one exists.
    @param _listingHashes The listingHashes whose status are being updated
    */
    function updateStatuses(bytes32[] _listingHashes) public {
        // loop through arrays, revealing each individual vote values
        for (uint i = 0; i < _listingHashes.length; i++) {
            updateStatus(_listingHashes[i]);
        }
    }

    // ----------------
    // TOKEN FUNCTIONS:
    // ----------------

    /**
    @dev                Called by a voter to claim their reward for each completed vote. Someone
                        must call updateStatus() before this can be called.
    @param _challengeID The PLCR pollID of the challenge a reward is being claimed for
    */
    function claimReward(uint _challengeID) public {
        Challenge storage challengeInstance = challenges[_challengeID];
        // Ensures the voter has not already claimed tokens and challengeInstance results have
        // been processed
        require(challengeInstance.tokenClaims[msg.sender] == false);
        require(challengeInstance.resolved == true);

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID);
        uint reward = voterTokens.mul(challengeInstance.rewardPool)
                      .div(challengeInstance.totalTokens);

        // Subtracts the voter's information to preserve the participation ratios
        // of other voters compared to the remaining pool of rewards
        challengeInstance.totalTokens -= voterTokens;
        challengeInstance.rewardPool -= reward;

        // Ensures a voter cannot claim tokens again
        challengeInstance.tokenClaims[msg.sender] = true;

        require(token.transfer(msg.sender, reward));

        emit _RewardClaimed(_challengeID, reward, msg.sender);
    }

    /**
    @dev                 Called by a voter to claim their rewards for each completed vote. Someone
                         must call updateStatus() before this can be called.
    @param _challengeIDs The PLCR pollIDs of the challenges rewards are being claimed for
    */
    function claimRewards(uint[] _challengeIDs) public {
        // loop through arrays, claiming each individual vote reward
        for (uint i = 0; i < _challengeIDs.length; i++) {
            claimReward(_challengeIDs[i]);
        }
    }

    // --------
    // GETTERS:
    // --------

    /**
    @dev                Calculates the provided voter's token reward for the given poll.
    @param _voter       The address of the voter whose reward balance is to be returned
    @param _challengeID The pollID of the challenge a reward balance is being queried for
    @return             The uint indicating the voter's reward
    */
    function voterReward(address _voter, uint _challengeID)
    public view returns (uint) {
        uint totalTokens = challenges[_challengeID].totalTokens;
        uint rewardPool = challenges[_challengeID].rewardPool;
        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID);
        return voterTokens.mul(rewardPool).div(totalTokens);
    }

    /**
    @dev                Determines whether the given listingHash be whitelisted.
    @param _listingHash The listingHash whose status is to be examined
    */
    function canBeWhitelisted(bytes32 _listingHash) view public returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        // Ensures that the application was made,
        // the application period has ended,
        // the listingHash can be whitelisted,
        // and either: the challengeID == 0, or the challenge has been resolved.
        if (
            appWasMade(_listingHash) &&
            listings[_listingHash].applicationExpiry < now &&
            !isWhitelisted(_listingHash) &&
            (challengeID == 0 || challenges[challengeID].resolved == true)
        ) { return true; }

        return false;
    }

    /**
    @dev                Returns true if the provided listingHash is whitelisted
    @param _listingHash The listingHash whose status is to be examined
    */
    function isWhitelisted(bytes32 _listingHash) view public returns (bool whitelisted) {
        return listings[_listingHash].whitelisted;
    }

    /**
    @dev                Returns true if apply was called for this listingHash
    @param _listingHash The listingHash whose status is to be examined
    */
    function appWasMade(bytes32 _listingHash) view public returns (bool exists) {
        return listings[_listingHash].applicationExpiry > 0;
    }

    /**
    @dev                Returns true if the application/listingHash has an unresolved challenge
    @param _listingHash The listingHash whose status is to be examined
    */
    function challengeExists(bytes32 _listingHash) view public returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        return (listings[_listingHash].challengeID > 0 && !challenges[challengeID].resolved);
    }

    /**
    @dev                Determines whether voting has concluded in a challenge for a given
                        listingHash. Throws if no challenge exists.
    @param _listingHash A listingHash with an unresolved challenge
    */
    function challengeCanBeResolved(bytes32 _listingHash) view public returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        require(challengeExists(_listingHash));

        return voting.pollEnded(challengeID);
    }

    /**
    @dev                Determines the number of tokens awarded to the winning party in a challenge.
    @param _challengeID The challengeID to determine a reward for
    */
    function determineReward(uint _challengeID) public view returns (uint) {
        require(!challenges[_challengeID].resolved && voting.pollEnded(_challengeID));

        // Edge case, nobody voted, give all tokens to the challenger.
        if (voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
            return 2 * challenges[_challengeID].stake;
        }

        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;
    }

    /**
    @dev                Getter for Challenge tokenClaims mappings
    @param _challengeID The challengeID to query
    @param _voter       The voter whose claim status to query for the provided challengeID
    */
    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {
        return challenges[_challengeID].tokenClaims[_voter];
    }

    // ----------------
    // PRIVATE FUNCTIONS:
    // ----------------

    /**
    @dev                Determines the winner in a challenge. Rewards the winner tokens and
                        either whitelists or de-whitelists the listingHash.
    @param _listingHash A listingHash with a challenge that is to be resolved
    */
    function resolveChallenge(bytes32 _listingHash) private {
        uint challengeID = listings[_listingHash].challengeID;

        // Calculates the winner's reward,
        // which is: (winner's full stake) + (dispensationPct * loser's stake)
        uint reward = determineReward(challengeID);

        // Sets flag on challenge being processed
        challenges[challengeID].resolved = true;

        // Stores the total tokens used for voting by the winning side for reward purposes
        challenges[challengeID].totalTokens =
            voting.getTotalNumberOfTokensForWinningOption(challengeID);

        // Case: challenge failed
        if (voting.isPassed(challengeID)) {
            whitelistApplication(_listingHash);
            // Unlock stake so that it can be retrieved by the applicant
            listings[_listingHash].unstakedDeposit += reward;

            emit _ChallengeFailed(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
        // Case: challenge succeeded or nobody voted
        else {
            resetListing(_listingHash);
            // Transfer the reward to the challenger
            require(token.transfer(challenges[challengeID].challenger, reward));

            emit _ChallengeSucceeded(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
    }

    /**
    @dev                Called by updateStatus() if the applicationExpiry date passed without a
                        challenge being made. Called by resolveChallenge() if an
                        application/listing beat a challenge.
    @param _listingHash The listingHash of an application/listingHash to be whitelisted
    */
    function whitelistApplication(bytes32 _listingHash) private {
        if (!listings[_listingHash].whitelisted) { emit _ApplicationWhitelisted(_listingHash); }
        listings[_listingHash].whitelisted = true;
    }

    /**
    @dev                Deletes a listingHash from the whitelist and transfers tokens back to owner
    @param _listingHash The listing hash to delete
    */
    function resetListing(bytes32 _listingHash) private {
        Listing storage listing = listings[_listingHash];

        // Emit events before deleting listing to check whether is whitelisted
        if (listing.whitelisted) {
            emit _ListingRemoved(_listingHash);
        } else {
            emit _ApplicationRemoved(_listingHash);
        }

        // Deleting listing to prevent reentry
        address owner = listing.owner;
        uint unstakedDeposit = listing.unstakedDeposit;
        delete listings[_listingHash];

        // Transfers any remaining balance back to the owner
        if (unstakedDeposit > 0){
            require(token.transfer(owner, unstakedDeposit));
        }
    }
}


/***************************************************************************************************
*                                                                                                  *
* (c) 2019 Quantstamp, Inc. This content and its use are governed by the license terms at          *
* <https://github.com/quantstamp/qsp-protocol-node/blob/develop/LICENSE>                           *
*                                                                                                  *
***************************************************************************************************/



 // Imports PLCRVoting and SafeMath


 //Imports SafeMath



contract QuantstampBountyData is Whitelist {

  using SafeMath for uint256;
  using LinkedListLib for LinkedListLib.LinkedList;

  // constants used by LinkedListLib
  uint256 constant internal NULL = 0;
  uint256 constant internal HEAD = 0;
  bool constant internal PREV = false;
  bool constant internal NEXT = true;


  uint256 constant internal NUMBER_OF_PHASES = 3;

  struct Bounty {
    address submitter;
    string contractAddress;
    uint256 size; // R1
    uint256 minVotes; // R3
    uint256 duration; // R2. Number of seconds
    uint256 judgeDeposit; // R5
    uint256 hunterDeposit; // R6
    uint256 initiationTimestamp; // Time in seconds that the bounty is created
    bool remainingFeesWithdrawn; // true if the remaining fees have been withdrawn by the submitter
    uint256 numApprovedBugs;
  }

  // holds information about a revealed bug
  struct Bug {
    address hunter; // address that submitted the hash
    uint256 bountyId; // the ID of the associated bounty
    string bugDescription; // the description of the bug
    uint256 numTokens; // the number of tokens staked on the commit
    uint256 pollId; // the poll that decided on the validity of the bug
  }

  // holds information relevant to a bug commit
  struct BugCommit {
    address hunter;  // address that submitted the hash
    uint256 bountyId;  // the ID of the associated bounty
    bytes32 bugDescriptionHash;  // keccak256 hash of the bug
    uint256 commitTimestamp;  // Time in seconds that the bug commit occurred
    uint256 revealStartTimestamp;  // Time in seconds when the the reveal phase starts
    uint256 revealEndTimestamp;  // Time in seconds when the the reveal phase ends
    uint256 numTokens;  // the number of tokens staked on the commit
  }

  mapping (uint256 => Bounty) public bounties;

  // maps pollIds back to bugIds
  mapping (uint256 => uint256) public pollIdToBugId;

  // For generating bountyIDs starting from 1
  uint256 private bountyCounter;

  // For generating bugIDs starting from 1
  uint256 private bugCounter;

  // token used to pay for participants in a bounty. This contract assumes that the owner of the contract
  // trusts token's code and that transfer function (such as transferFrom, transfer) do the right thing
  StandardToken public token;

  // The partial-locking commit-reveal voting interface used by the TCR to determine the validity of bugs
  RestrictedPLCRVoting public voting;

  // The underlying contract to hold PLCR voting parameters
  Parameterizer public parameterizer;

  // Recording reported bugs not yet awarded for each hunter
  mapping (address => LinkedListLib.LinkedList) private hunterReportedBugs;
  mapping (address => uint256) public hunterReportedBugsCount;

  /**
   * @dev The constructor creates a QuantstampBountyData contract.
   * @param tokenAddress The address of a StandardToken that will be used to pay auditor nodes.
   */
  constructor (address tokenAddress, address votingAddress, address parameterizerAddress) public {
    require(tokenAddress != address(0));
    require(votingAddress != address(0));
    require(parameterizerAddress != address(0));
    token = StandardToken(tokenAddress);
    voting = RestrictedPLCRVoting(votingAddress);
    parameterizer = Parameterizer(parameterizerAddress);
  }

  // maps bountyIDs to list of corresponding bugIDs
  // each list contains all revealed bugs for a given bounty, ordered by time
  // NOTE: this cannot be part of the Bounty struct due to solidity limitations
  mapping(uint256 => LinkedListLib.LinkedList) private bugLists;

  // maps bugIDs to BugCommits
  mapping(uint256 => BugCommit) public bugCommitMap;

  // maps bugIDs to revealed bugs; uses the same ID as the bug commit
  mapping(uint256 => Bug) public bugs;

  function addBugCommitment(address hunter,
                            uint256 bountyId,
                            bytes32 bugDescriptionHash,
                            uint256 hunterDeposit) public onlyWhitelisted returns (uint256) {
    bugCounter = bugCounter.add(1);
    bugCommitMap[bugCounter] = BugCommit({
      hunter: hunter,
      bountyId: bountyId,
      bugDescriptionHash: bugDescriptionHash,
      commitTimestamp: block.timestamp,
      revealStartTimestamp: getBountyRevealPhaseStartTimestamp(bountyId),
      revealEndTimestamp: getBountyRevealPhaseEndTimestamp(bountyId),
      numTokens: hunterDeposit
    });
    return bugCounter;
  }

  function addBug(uint256 bugId, string bugDescription, uint256 pollId) public onlyWhitelisted returns (bool) {
    // create a Bug
    bugs[bugId] = Bug({
      hunter: bugCommitMap[bugId].hunter,
      bountyId: bugCommitMap[bugId].bountyId,
      bugDescription: bugDescription,
      numTokens: bugCommitMap[bugId].numTokens,
      pollId: pollId
    });
    // add pointer to it in the corresponding bounty
    bugLists[bugCommitMap[bugId].bountyId].push(bugId, PREV);
    pollIdToBugId[pollId] = bugId;
    return true;
  }

  function addBounty (address submitter,
                      string contractAddress,
                      uint256 size,
                      uint256 minVotes,
                      uint256 duration,
                      uint256 judgeDeposit,
                      uint256 hunterDeposit) public onlyWhitelisted returns(uint256) {
    bounties[++bountyCounter] = Bounty(submitter,
                                        contractAddress,
                                        size,
                                        minVotes,
                                        duration,
                                        judgeDeposit,
                                        hunterDeposit,
                                        block.timestamp,
                                        false,
                                        0);
    return bountyCounter;
  }

  function removeBugCommitment(uint256 bugId) public onlyWhitelisted returns (bool) {
    delete bugCommitMap[bugId];
    return true;
  }

  /**
   * @dev Sets a new value for the number of approved bugs, if appropriate
   * @param pollId The ID of the poll being that a vote was received for
   * @param wasPassing true if and only if more affirmative votes prior to this vote
   * @param isPassing true if and only if more affirmative votes after this vote
   * @param wasEnoughVotes true if and only if quorum was reached prior to this vote
   */
  function updateNumApprovedBugs(uint256 pollId, bool wasPassing, bool isPassing, bool wasEnoughVotes) public {
    require(msg.sender == address(voting));
    uint256 bountyId = getBugBountyId(getBugIdFromPollId(pollId));

    if (wasEnoughVotes) {
      if (!wasPassing && isPassing) {
        bounties[bountyId].numApprovedBugs = bounties[bountyId].numApprovedBugs.add(1);
      } else if (wasPassing && !isPassing) {
        bounties[bountyId].numApprovedBugs = bounties[bountyId].numApprovedBugs.sub(1);
      }
    } else if (voting.isEnoughVotes(pollId) && isPassing) {
      bounties[bountyId].numApprovedBugs = bounties[bountyId].numApprovedBugs.add(1);
    }
  }

  /**
   * @dev Reports the number of approved bugs of a bounty
   * @param bountyId The ID of the bounty.
   */
  function getNumApprovedBugs(uint256 bountyId) public view returns (uint256) {
    return bounties[bountyId].numApprovedBugs;
  }

  /**
   * @dev Sets remainingFeesWithdrawn to true after the submitter withdraws.
   * @param bountyId The ID of the bounty.
   */
  function setBountyRemainingFeesWithdrawn (uint256 bountyId) public onlyWhitelisted {
    bounties[bountyId].remainingFeesWithdrawn = true;
  }

  function addBugToHunter (address hunter, uint256 bugId) public onlyWhitelisted {
    hunterReportedBugs[hunter].push(bugId, PREV);
    hunterReportedBugsCount[hunter] = hunterReportedBugsCount[hunter].add(1);
  }

  function removeBugFromHunter (address hunter, uint256 bugId) public onlyWhitelisted returns (bool) {
    if (hunterReportedBugs[hunter].remove(bugId) != 0) {
      hunterReportedBugsCount[hunter] = hunterReportedBugsCount[hunter].sub(1);
      bugs[bugId].hunter = 0x0;
      return true;
    }
    return false;
  }

  function getListHeadConstant () public pure returns(uint256 head) {
    return HEAD;
  }

  function getBountySubmitter (uint256 bountyId) public view returns(address) {
    return bounties[bountyId].submitter;
  }

  function getBountyContractAddress (uint256 bountyId) public view returns(string) {
    return bounties[bountyId].contractAddress;
  }

  function getBountySize (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].size;
  }

  function getBountyMinVotes (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].minVotes;
  }

  function getBountyDuration (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].duration;
  }

  function getBountyJudgeDeposit (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].judgeDeposit;
  }

  function getBountyHunterDeposit (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].hunterDeposit;
  }

  function getBountyInitiationTimestamp (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].initiationTimestamp;
  }

  function getBountyCommitPhaseEndTimestamp (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].initiationTimestamp.add(getBountyDuration(bountyId).div(NUMBER_OF_PHASES));
  }

  function getBountyRevealPhaseStartTimestamp (uint256 bountyId) public view returns(uint256) {
    return getBountyCommitPhaseEndTimestamp(bountyId).add(1);
  }

  function getBountyRevealPhaseEndTimestamp (uint256 bountyId) public view returns(uint256) {
    return getBountyCommitPhaseEndTimestamp(bountyId).add(getBountyDuration(bountyId).div(NUMBER_OF_PHASES));
  }

  function getBountyJudgePhaseStartTimestamp (uint256 bountyId) public view returns(uint256) {
    return getBountyRevealPhaseEndTimestamp(bountyId).add(1);
  }

  function getBountyJudgePhaseEndTimestamp (uint256 bountyId) public view returns(uint256) {
    return bounties[bountyId].initiationTimestamp.add(getBountyDuration(bountyId));
  }

  function getBountyJudgeCommitPhaseEndTimestamp (uint256 bountyId) public view returns(uint256) {
    uint256 judgePhaseDuration = getBountyDuration(bountyId).div(NUMBER_OF_PHASES);
    return getBountyJudgePhaseStartTimestamp(bountyId).add(judgePhaseDuration.div(2));
  }

  function getBountyJudgeRevealDuration (uint256 bountyId) public view returns(uint256) {
    return getBountyJudgePhaseEndTimestamp(bountyId).sub(getBountyJudgeCommitPhaseEndTimestamp(bountyId));
  }

  function isCommitPeriod (uint256 bountyId) public view returns(bool) {
    return block.timestamp >= bounties[bountyId].initiationTimestamp && block.timestamp <= getBountyCommitPhaseEndTimestamp(bountyId);
  }

  function isRevealPeriod (uint256 bountyId) public view returns(bool) {
    return block.timestamp >= getBountyRevealPhaseStartTimestamp(bountyId) && block.timestamp <= getBountyRevealPhaseEndTimestamp(bountyId);
  }

  function isJudgingPeriod (uint256 bountyId) public view returns(bool) {
    return block.timestamp >= getBountyJudgePhaseStartTimestamp(bountyId) && block.timestamp <= getBountyJudgePhaseEndTimestamp(bountyId);
  }

  function getBountyRemainingFeesWithdrawn (uint256 bountyId) public view returns(bool) {
    return bounties[bountyId].remainingFeesWithdrawn;
  }

  function getBugCommitCommitter(uint256 bugCommitId) public view returns (address) {
    return bugCommitMap[bugCommitId].hunter;
  }

  function getBugCommitBountyId(uint256 bugCommitId) public view returns (uint256) {
    return bugCommitMap[bugCommitId].bountyId;
  }

  function getBugCommitBugDescriptionHash(uint256 bugCommitId) public view returns (bytes32) {
    return bugCommitMap[bugCommitId].bugDescriptionHash;
  }

  function getBugCommitCommitTimestamp(uint256 bugCommitId) public view returns (uint256) {
    return bugCommitMap[bugCommitId].commitTimestamp;
  }

  function getBugCommitRevealStartTimestamp(uint256 bugCommitId) public view returns (uint256) {
    return bugCommitMap[bugCommitId].revealStartTimestamp;
  }

  function getBugCommitRevealEndTimestamp(uint256 bugCommitId) public view returns (uint256) {
    return bugCommitMap[bugCommitId].revealEndTimestamp;
  }

  function getBugCommitNumTokens(uint256 bugCommitId) public view returns (uint256) {
    return bugCommitMap[bugCommitId].numTokens;
  }

  function bugRevealPeriodActive(uint256 bugCommitId) public view returns (bool) {
    return bugCommitMap[bugCommitId].revealStartTimestamp <= block.timestamp && block.timestamp <= bugCommitMap[bugCommitId].revealEndTimestamp;
  }

  function bugRevealPeriodExpired(uint256 bugCommitId) public view returns (bool) {
    return block.timestamp > bugCommitMap[bugCommitId].revealEndTimestamp;
  }

  function bugRevealDelayPeriodActive(uint256 bugCommitId) public view returns (bool) {
    return block.timestamp < bugCommitMap[bugCommitId].revealStartTimestamp;
  }

  function bountyActive(uint256 bountyId) public view returns (bool) {
    return block.timestamp <= getBountyInitiationTimestamp(bountyId).add(getBountyDuration(bountyId));
  }

  function getHunterReportedBugsCount (address hunter) public view returns (uint256) {
    return hunterReportedBugsCount[hunter];
  }

  // Bug Functions
  function getBugBountyId(uint256 bugId) public view returns (uint256) {
    return bugs[bugId].bountyId;
  }

  function getBugHunter(uint256 bugId) public view returns (address) {
    return bugs[bugId].hunter;
  }

  function getBugDescription(uint256 bugId) public view returns (string) {
    return bugs[bugId].bugDescription;
  }

  function getBugNumTokens(uint256 bugId) public view returns (uint256) {
    return bugs[bugId].numTokens;
  }

  function getBugPollId(uint256 bugId) public view returns (uint256) {
    return bugs[bugId].pollId;
  }

  function getFirstRevealedBug(uint256 bountyId) public view returns (bool, uint256, string) {
    return getNextRevealedBug(bountyId, HEAD);
  }

  function getBugIdFromPollId(uint256 pollId) public view returns (uint256) {
    return pollIdToBugId[pollId];
  }

  /*
   * @dev Gets the bug description of a revealed bug associated with a bounty
   * @param bountyId The ID of the bounty
   * @param previousBugId The ID of the previous bug in the linked list (HEAD for the first bug)
   * @return a triple containing 1) whether the bug exists; 2) its bugId (0 if non-existent); 3) the description
   */
  function getNextRevealedBug(uint256 bountyId, uint256 previousBugId) public view returns (bool, uint256, string) {
    if (!bugLists[bountyId].listExists()) {
      return (false, 0, "");
    }
    uint256 bugId;
    bool exists;
    (exists, bugId) = bugLists[bountyId].getAdjacent(previousBugId, NEXT);
    if (!exists || bugId == 0) {
      return (false, 0, "");
    }
    string memory bugDescription = bugs[bugId].bugDescription;
    return (true, bugId, bugDescription);
  }

  /**
   * @dev Given a bugId, it retrieves the next bugId reported by a hunter. Such bugs have not been cashed yet.
   * @param hunter The address of a hunter
   * @param previousBugId The id of the previous reported bug. Passing 0, it returns the first reported bug.
   */
  function getNextBugFromHunter(address hunter, uint256 previousBugId) public view returns (bool, uint256) {
    if (!hunterReportedBugs[hunter].listExists()) {
      return (false, 0);
    }
    uint256 bugId;
    bool exists;
    (exists, bugId) = hunterReportedBugs[hunter].getAdjacent(previousBugId, NEXT);
    if (!exists || bugId == 0) {
      return (false, 0);
    }
    return (true, bugId);
  }

  /**
   * @dev Determines if the judge meets the requirements to claim an award for voting in a poll
   * @param bugId Id of a bug
   * Note: moved to this contract as the Bounty contract was getting too large to deploy
   */
  function canClaimJudgeAward(address judge, uint256 bugId) public view returns (bool) {
    // NOTE: these cannot be a require statement as this check occurs in a loop that should not fail
    // the poll has concluded
    uint256 pollId = getBugPollId(bugId);
    bool pollHasConcluded = voting.pollExists(pollId) && voting.pollEnded(pollId);
    // the judge voted in the majority
    // this is needed to avoid hitting a require statement when in the minority in PLCRVoting
    bool votedWithMajority = pollHasConcluded && voting.isEnoughVotes(pollId) &&
      (voting.isPassed(pollId) && voting.hasVotedAffirmatively(judge, pollId) ||
      !voting.isPassed(pollId) && !voting.hasVotedAffirmatively(judge, pollId));
    // the judge should not have already claimed an award for this poll
    bool alreadyClaimed = voting.hasVoterClaimedReward(judge, pollId);
    // the bounty should be over
    bool bountyStillActive = bountyActive(getBugBountyId(bugId));
    return votedWithMajority && !alreadyClaimed && !bountyStillActive;
  }
}




/**
Extends PLCR Voting to have restricted polls that can only be voted on by the TCR.
*/
contract RestrictedPLCRVoting is PLCRVoting, Whitelist {

  using SafeMath for uint256;
  using LinkedListLib for LinkedListLib.LinkedList;

  // constants used by LinkedListLib
  uint256 constant internal NULL = 0;
  uint256 constant internal HEAD = 0;
  bool constant internal PREV = false;
  bool constant internal NEXT = true;

  // TCR used to list judge stakers.
  Registry public judgeRegistry;

  QuantstampBountyData public bountyData;

  // Map that contains IDs of restricted polls that can only be voted on by the TCR
  mapping(uint256 => bool) isRestrictedPoll;

  // Map from IDs of restricted polls to the minimum number of votes needed for a bug to pass
  mapping(uint256 => uint256) minimumVotes;

  // Map from IDs of restricted polls to the amount a judge must deposit to vote
  mapping(uint256 => uint256) judgeDeposit;

  // Map from (voter x pollId) -> bool to determine whether a voter has already claimed a reward of a given poll
  mapping(address => mapping(uint256 => bool)) private voterHasClaimedReward;

  // Map from (voter x pollId) -> bool indicating whether a voter voted yes (true) or no (false) for a poll.
  // Needed due to visibility issues with Poll structs in PLCRVoting
  mapping(address => mapping(uint256 => bool)) private votedAffirmatively;

  // Recording polls voted on but not yet awarded for each voter
  mapping (address => LinkedListLib.LinkedList) private voterPolls;
  mapping (address => uint256) public voterPollsCount;

  event LogPollRestricted(uint256 pollId);

  /**
   * @dev Initializer. Can only be called once.
   * @param _registry The address of the TCR registry
   * @param _token The address of the token
   */
  function initialize(address _token, address _registry, address _bountyData) public {
    require(_token != 0 && address(token) == 0);
    require(_registry != 0 && address(judgeRegistry) == 0);
    require(_bountyData != 0 && address(bountyData) == 0);
    bountyData = QuantstampBountyData(_bountyData);
    token = EIP20Interface(_token);
    judgeRegistry = Registry(_registry);
    pollNonce = INITIAL_POLL_NONCE;
  }

  /*
   * @dev addr is of type Address which is 20 Bytes, but the TCR expects all
   * entries to be of type Bytes32. addr is first cast to Uint256 so that it
   * becomes 32 bytes long, addr is then shifted 12 bytes (96 bits) to the
   * left so the 20 important bytes are in the correct spot.
   * @param addr The address of the person who may be an judge.
   * @return true If addr is on the TCR (is an judge)
   */
  function isJudge(address addr) public view returns(bool) {
    return judgeRegistry.isWhitelisted(bytes32(uint256(addr) << 96));
  }

  /**
   * @dev Set a poll to be restricted to TCR voting
   * @param _pollId The ID of the poll
   * @param _minimumVotes The minimum number of votes needed for the vote to go through. Each voter counts as 1 vote (not weighted).
   * @param _judgeDepositAmount The deposit of a judge to vote
   */
  function restrictPoll(uint256 _pollId, uint256 _minimumVotes, uint256 _judgeDepositAmount) public onlyWhitelisted {
    isRestrictedPoll[_pollId] = true;
    minimumVotes[_pollId] = _minimumVotes;
    judgeDeposit[_pollId] = _judgeDepositAmount;
    emit LogPollRestricted(_pollId);
  }

  /**
   * @dev Set that a voter has claimed a reward for voting with the majority
   * @param _voter The address of the voter
   * @param _pollID Integer identifier associated with target poll
   */
  function setVoterClaimedReward(address _voter, uint256 _pollID) public onlyWhitelisted {
    voterHasClaimedReward[_voter][_pollID] = true;
  }

  /**
   * @dev Determines whether a restricted poll has met the minimum vote requirements
   * @param _pollId The ID of the poll
   */
  function isEnoughVotes(uint256 _pollId) public view returns (bool) {
    return pollMap[_pollId].votesFor.add(pollMap[_pollId].votesAgainst) >= minimumVotes[_pollId].mul(judgeDeposit[_pollId]);
  }

  // Overridden methods from PLCRVoting. Needed for special requirements of the bounty protocol

  /**
  * @dev Overridden Initializer from PLCR Voting. Always reverts to ensure the registry is initialized in the above initialize function.
  * @param _token The address of the token
  */
  function init(address _token) public {
    require(false);
  }

  /**
   * @dev Overrides PLCRVoting to only allow TCR members to vote on restricted votes.
   *      Commits vote using hash of choice and secret salt to conceal vote until reveal.
   * @param _pollID Integer identifier associated with target poll
   * @param _secretHash Commit keccak256 hash of voter's choice and salt (tightly packed in this order)
   * @param _numTokens The number of tokens to be committed towards the target poll
   * @param _prevPollID The ID of the poll that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
   */
  function commitVote(uint256 _pollID, bytes32 _secretHash, uint256 _numTokens, uint256 _prevPollID) public {
    if (isRestrictedPoll[_pollID]) {
      require(isJudge(msg.sender));
      // Note: The PLCR weights votes by numTokens, so here we use strict equality rather than '>='
      // This must be accounted for when tallying votes.
      require(_numTokens == judgeDeposit[_pollID]);
      require(bountyData.isJudgingPeriod(bountyData.getBugBountyId(bountyData.getBugIdFromPollId(_pollID))));
    }
    super.commitVote(_pollID, _secretHash, _numTokens, _prevPollID);
  }

  /**
   * @dev Overrides PLCRVoting to track which polls are associated with a voter.
   * @notice Reveals vote with choice and secret salt used in generating commitHash to attribute committed tokens
   * @param _pollID Integer identifier associated with target poll
   * @param _voteOption Vote choice used to generate commitHash for associated poll
   * @param _salt Secret number used to generate commitHash for associated poll
   */
  function revealVote(uint256 _pollID, uint256 _voteOption, uint256 _salt) public {
    address voter = msg.sender;
    // record the vote
    if (_voteOption == 1) {
      votedAffirmatively[voter][_pollID] = true;
    }
    // do not allow multiple votes for the same poll
    require(!voterPolls[voter].nodeExists(_pollID));
    bool wasPassing = isPassing(_pollID);
    bool wasEnoughVotes = isEnoughVotes(_pollID);
    voterPolls[voter].push(_pollID, PREV);
    voterPollsCount[voter] = voterPollsCount[voter].add(1);
    super.revealVote(_pollID, _voteOption, _salt);
    bool voteIsPassing = isPassing(_pollID);
    bountyData.updateNumApprovedBugs(_pollID, wasPassing, voteIsPassing, wasEnoughVotes);
  }

  function removePollFromVoter (address _voter, uint256 _pollID) public onlyWhitelisted returns (bool) {
    if (voterPolls[_voter].remove(_pollID) != 0) {
      voterPollsCount[_voter] = voterPollsCount[_voter] - 1;
      return true;
    }
    return false;
  }

  /**
   * @dev Determines if proposal has more affirmative votes
   *      Check if votesFor out of totalVotes exceeds votesQuorum (does not require pollEnded)
   * @param _pollID Integer identifier associated with target poll
   */
  function isPassing(uint _pollID) public view returns (bool) {
    Poll memory poll = pollMap[_pollID];
    return (100 * poll.votesFor) > (poll.voteQuorum * (poll.votesFor + poll.votesAgainst));
  }

  /**
   * @dev Gets the total winning votes for reward distribution purposes.
   *      Returns 0 if there were not enough votes.
   * @param _pollID Integer identifier associated with target poll
   * @return Total number of votes committed to the winning option for specified poll
   */
  function getTotalNumberOfTokensForWinningOption(uint _pollID) constant public returns (uint256) {
    if (isRestrictedPoll[_pollID] && !isEnoughVotes(_pollID)) {
      return 0;
    }
    return super.getTotalNumberOfTokensForWinningOption(_pollID);
  }

  /**
   * @dev Gets the number of tokens allocated toward the winning vote for a particular voter.
   *      Zero if there were not enough votes for a restricted poll.
   * @param _voter Address of voter who voted in the majority bloc
   * @param _pollID Integer identifier associated with target poll
   * @return correctVotes Number of tokens voted for winning option
   */
  function getNumPassingTokens(address _voter, uint _pollID) public constant returns (uint256) {
    if (isRestrictedPoll[_pollID] && !isEnoughVotes(_pollID)) {
      return 0;
    }
    return super.getNumPassingTokens(_voter, _pollID);
  }

  /**
   * @dev Determines if proposal has passed
   *      Check if votesFor out of totalVotes exceeds votesQuorum (requires pollEnded)
   * @param _pollID Integer identifier associated with target poll
   */
  function isPassed(uint _pollID) constant public returns (bool) {
    if (isRestrictedPoll[_pollID] && !isEnoughVotes(_pollID)) {
      return false;
    }
    return super.isPassed(_pollID);
  }

  /**
   * @dev Determines if a voter has already claimed a reward for voting with the majority
   * @param _voter The address of the voter
   * @param _pollID Integer identifier associated with target poll
   */
  function hasVoterClaimedReward(address _voter, uint256 _pollID) public view returns (bool) {
    return voterHasClaimedReward[_voter][_pollID];
  }

  /**
   * @dev Determines if a voter voted yes or no for a poll
   * @param _voter The address of the voter
   * @param _pollID Integer identifier associated with target poll
   */
  function hasVotedAffirmatively(address _voter, uint256 _pollID) public view returns (bool) {
    return votedAffirmatively[_voter][_pollID];
  }

  /**
   * @dev Returns the number of unclaimed polls associated with the voter.
   * @param _voter The address of the voter
   */
  function getVoterPollsCount (address _voter) public view returns (uint256) {
    return voterPollsCount[_voter];
  }

  function getListHeadConstant () public pure returns(uint256 head) {
    return HEAD;
  }

  /**
   * @dev Given a pollID, it retrieves the next pollID voted on but unclaimed by the voter.
   * @param _voter The address of the voter
   * @param _prevPollID The id of the previous unclaimed poll. Passing 0, it returns the first poll.
   */
  function getNextPollFromVoter(address _voter, uint256 _prevPollID) public view returns (bool, uint256) {
    if (!voterPolls[_voter].listExists()) {
      return (false, 0);
    }
    uint256 pollID;
    bool exists;
    (exists, pollID) = voterPolls[_voter].getAdjacent(_prevPollID, NEXT);
    if (!exists || pollID == 0) {
      return (false, 0);
    }
    return (true, pollID);
  }
}
 //Imports SafeMath