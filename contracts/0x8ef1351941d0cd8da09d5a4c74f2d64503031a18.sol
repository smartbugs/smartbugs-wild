pragma solidity ^0.4.18;

// File: contracts/libraries/PermissionsLib.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;


/**
 *  Note(kayvon): these events are emitted by our PermissionsLib, but all contracts that
 *  depend on the library must also define the events in order for web3 clients to pick them up.
 *  This topic is discussed in greater detail here (under the section "Events and Libraries"):
 *  https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736
 */
contract PermissionEvents {
    event Authorized(address indexed agent, string callingContext);
    event AuthorizationRevoked(address indexed agent, string callingContext);
}


library PermissionsLib {

    // TODO(kayvon): remove these events and inherit from PermissionEvents when libraries are
    // capable of inheritance.
    // See relevant github issue here: https://github.com/ethereum/solidity/issues/891
    event Authorized(address indexed agent, string callingContext);
    event AuthorizationRevoked(address indexed agent, string callingContext);

    struct Permissions {
        mapping (address => bool) authorized;
        mapping (address => uint) agentToIndex; // ensures O(1) look-up
        address[] authorizedAgents;
    }

    function authorize(
        Permissions storage self,
        address agent,
        string callingContext
    )
        internal
    {
        require(isNotAuthorized(self, agent));

        self.authorized[agent] = true;
        self.authorizedAgents.push(agent);
        self.agentToIndex[agent] = self.authorizedAgents.length - 1;
        Authorized(agent, callingContext);
    }

    function revokeAuthorization(
        Permissions storage self,
        address agent,
        string callingContext
    )
        internal
    {
        /* We only want to do work in the case where the agent whose
        authorization is being revoked had authorization permissions in the
        first place. */
        require(isAuthorized(self, agent));

        uint indexOfAgentToRevoke = self.agentToIndex[agent];
        uint indexOfAgentToMove = self.authorizedAgents.length - 1;
        address agentToMove = self.authorizedAgents[indexOfAgentToMove];

        // Revoke the agent's authorization.
        delete self.authorized[agent];

        // Remove the agent from our collection of authorized agents.
        self.authorizedAgents[indexOfAgentToRevoke] = agentToMove;

        // Update our indices to reflect the above changes.
        self.agentToIndex[agentToMove] = indexOfAgentToRevoke;
        delete self.agentToIndex[agent];

        // Clean up memory that's no longer being used.
        delete self.authorizedAgents[indexOfAgentToMove];
        self.authorizedAgents.length -= 1;

        AuthorizationRevoked(agent, callingContext);
    }

    function isAuthorized(Permissions storage self, address agent)
        internal
        view
        returns (bool)
    {
        return self.authorized[agent];
    }

    function isNotAuthorized(Permissions storage self, address agent)
        internal
        view
        returns (bool)
    {
        return !isAuthorized(self, agent);
    }

    function getAuthorizedAgents(Permissions storage self)
        internal
        view
        returns (address[])
    {
        return self.authorizedAgents;
    }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/DebtRegistry.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;





/**
 * The DebtRegistry stores the parameters and beneficiaries of all debt agreements in
 * Dharma protocol.  It authorizes a limited number of agents to
 * perform mutations on it -- those agents can be changed at any
 * time by the contract's owner.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtRegistry is Pausable, PermissionEvents {
    using SafeMath for uint;
    using PermissionsLib for PermissionsLib.Permissions;

    struct Entry {
        address version;
        address beneficiary;
        address underwriter;
        uint underwriterRiskRating;
        address termsContract;
        bytes32 termsContractParameters;
        uint issuanceBlockTimestamp;
    }

    // Primary registry mapping agreement IDs to their corresponding entries
    mapping (bytes32 => Entry) internal registry;

    // Maps debtor addresses to a list of their debts' agreement IDs
    mapping (address => bytes32[]) internal debtorToDebts;

    PermissionsLib.Permissions internal entryInsertPermissions;
    PermissionsLib.Permissions internal entryEditPermissions;

    string public constant INSERT_CONTEXT = "debt-registry-insert";
    string public constant EDIT_CONTEXT = "debt-registry-edit";

    event LogInsertEntry(
        bytes32 indexed agreementId,
        address indexed beneficiary,
        address indexed underwriter,
        uint underwriterRiskRating,
        address termsContract,
        bytes32 termsContractParameters
    );

    event LogModifyEntryBeneficiary(
        bytes32 indexed agreementId,
        address indexed previousBeneficiary,
        address indexed newBeneficiary
    );

    modifier onlyAuthorizedToInsert() {
        require(entryInsertPermissions.isAuthorized(msg.sender));
        _;
    }

    modifier onlyAuthorizedToEdit() {
        require(entryEditPermissions.isAuthorized(msg.sender));
        _;
    }

    modifier onlyExtantEntry(bytes32 agreementId) {
        require(doesEntryExist(agreementId));
        _;
    }

    modifier nonNullBeneficiary(address beneficiary) {
        require(beneficiary != address(0));
        _;
    }

    /* Ensures an entry with the specified agreement ID exists within the debt registry. */
    function doesEntryExist(bytes32 agreementId)
        public
        view
        returns (bool exists)
    {
        return registry[agreementId].beneficiary != address(0);
    }

    /**
     * Inserts a new entry into the registry, if the entry is valid and sender is
     * authorized to make 'insert' mutations to the registry.
     */
    function insert(
        address _version,
        address _beneficiary,
        address _debtor,
        address _underwriter,
        uint _underwriterRiskRating,
        address _termsContract,
        bytes32 _termsContractParameters,
        uint _salt
    )
        public
        onlyAuthorizedToInsert
        whenNotPaused
        nonNullBeneficiary(_beneficiary)
        returns (bytes32 _agreementId)
    {
        Entry memory entry = Entry(
            _version,
            _beneficiary,
            _underwriter,
            _underwriterRiskRating,
            _termsContract,
            _termsContractParameters,
            block.timestamp
        );

        bytes32 agreementId = _getAgreementId(entry, _debtor, _salt);

        require(registry[agreementId].beneficiary == address(0));

        registry[agreementId] = entry;
        debtorToDebts[_debtor].push(agreementId);

        LogInsertEntry(
            agreementId,
            entry.beneficiary,
            entry.underwriter,
            entry.underwriterRiskRating,
            entry.termsContract,
            entry.termsContractParameters
        );

        return agreementId;
    }

    /**
     * Modifies the beneficiary of a debt issuance, if the sender
     * is authorized to make 'modifyBeneficiary' mutations to
     * the registry.
     */
    function modifyBeneficiary(bytes32 agreementId, address newBeneficiary)
        public
        onlyAuthorizedToEdit
        whenNotPaused
        onlyExtantEntry(agreementId)
        nonNullBeneficiary(newBeneficiary)
    {
        address previousBeneficiary = registry[agreementId].beneficiary;

        registry[agreementId].beneficiary = newBeneficiary;

        LogModifyEntryBeneficiary(
            agreementId,
            previousBeneficiary,
            newBeneficiary
        );
    }

    /**
     * Adds an address to the list of agents authorized
     * to make 'insert' mutations to the registry.
     */
    function addAuthorizedInsertAgent(address agent)
        public
        onlyOwner
    {
        entryInsertPermissions.authorize(agent, INSERT_CONTEXT);
    }

    /**
     * Adds an address to the list of agents authorized
     * to make 'modifyBeneficiary' mutations to the registry.
     */
    function addAuthorizedEditAgent(address agent)
        public
        onlyOwner
    {
        entryEditPermissions.authorize(agent, EDIT_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized
     * to make 'insert' mutations to the registry.
     */
    function revokeInsertAgentAuthorization(address agent)
        public
        onlyOwner
    {
        entryInsertPermissions.revokeAuthorization(agent, INSERT_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized
     * to make 'modifyBeneficiary' mutations to the registry.
     */
    function revokeEditAgentAuthorization(address agent)
        public
        onlyOwner
    {
        entryEditPermissions.revokeAuthorization(agent, EDIT_CONTEXT);
    }

    /**
     * Returns the parameters of a debt issuance in the registry.
     *
     * TODO(kayvon): protect this function with our `onlyExtantEntry` modifier once the restriction
     * on the size of the call stack has been addressed.
     */
    function get(bytes32 agreementId)
        public
        view
        returns(address, address, address, uint, address, bytes32, uint)
    {
        return (
            registry[agreementId].version,
            registry[agreementId].beneficiary,
            registry[agreementId].underwriter,
            registry[agreementId].underwriterRiskRating,
            registry[agreementId].termsContract,
            registry[agreementId].termsContractParameters,
            registry[agreementId].issuanceBlockTimestamp
        );
    }

    /**
     * Returns the beneficiary of a given issuance
     */
    function getBeneficiary(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns(address)
    {
        return registry[agreementId].beneficiary;
    }

    /**
     * Returns the terms contract address of a given issuance
     */
    function getTermsContract(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (address)
    {
        return registry[agreementId].termsContract;
    }

    /**
     * Returns the terms contract parameters of a given issuance
     */
    function getTermsContractParameters(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (bytes32)
    {
        return registry[agreementId].termsContractParameters;
    }

    /**
     * Returns a tuple of the terms contract and its associated parameters
     * for a given issuance
     */
    function getTerms(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns(address, bytes32)
    {
        return (
            registry[agreementId].termsContract,
            registry[agreementId].termsContractParameters
        );
    }

    /**
     * Returns the timestamp of the block at which a debt agreement was issued.
     */
    function getIssuanceBlockTimestamp(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (uint timestamp)
    {
        return registry[agreementId].issuanceBlockTimestamp;
    }

    /**
     * Returns the list of agents authorized to make 'insert' mutations
     */
    function getAuthorizedInsertAgents()
        public
        view
        returns(address[])
    {
        return entryInsertPermissions.getAuthorizedAgents();
    }

    /**
     * Returns the list of agents authorized to make 'modifyBeneficiary' mutations
     */
    function getAuthorizedEditAgents()
        public
        view
        returns(address[])
    {
        return entryEditPermissions.getAuthorizedAgents();
    }

    /**
     * Returns the list of debt agreements a debtor is party to,
     * with each debt agreement listed by agreement ID.
     */
    function getDebtorsDebts(address debtor)
        public
        view
        returns(bytes32[])
    {
        return debtorToDebts[debtor];
    }

    /**
     * Helper function for computing the hash of a given issuance,
     * and, in turn, its agreementId
     */
    function _getAgreementId(Entry _entry, address _debtor, uint _salt)
        internal
        pure
        returns(bytes32)
    {
        return keccak256(
            _entry.version,
            _debtor,
            _entry.underwriter,
            _entry.underwriterRiskRating,
            _entry.termsContract,
            _entry.termsContractParameters,
            _salt
        );
    }
}

// File: contracts/ERC165.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;


/**
 * ERC165 interface required by ERC721 non-fungible token.
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);  

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);
  
  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);
  
  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;  
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: zeppelin-solidity/contracts/token/ERC721/DeprecatedERC721.sol

/**
 * @title ERC-721 methods shipped in OpenZeppelin v1.7.0, removed in the latest version of the standard
 * @dev Only use this interface for compatibility with previously deployed contracts
 * @dev Use ERC721 for interacting with new contracts which are standard-compliant
 */
contract DeprecatedERC721 is ERC721 {
  function takeOwnership(uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;
  function tokensOf(address _owner) public view returns (uint256[]);
}

// File: zeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether there is code in the target address
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address address to check
   * @return whether there is code in the target address
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   *  after a `safetransfer`. This function MAY throw to revert and reject the
   *  transfer. This function MUST use 50,000 gas or less. Return of other
   *  than the magic value MUST result in the transaction being reverted.
   *  Note: the contract address is always the message sender.
   * @param _from The sending address 
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;
  
  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
  * @dev Guarantees msg.sender is owner of the given token
  * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
  */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
  * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
  * @param _tokenId uint256 ID of the token to validate
  */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  /**
  * @dev Gets the balance of the specified address
  * @param _owner address to query the balance of
  * @return uint256 representing the amount owned by the passed address
  */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
  * @dev Gets the owner of the specified token ID
  * @param _tokenId uint256 ID of the token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
  * @dev Returns whether the specified token exists
  * @param _tokenId uint256 ID of the token to query the existance of
  * @return whether the token exists
  */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
  * @dev Approves another address to transfer the given token ID
  * @dev The zero address indicates there is no approved address.
  * @dev There can only be one approved address per token at a given time.
  * @dev Can only be called by the token owner or an approved operator.
  * @param _to address to be approved for the given token ID
  * @param _tokenId uint256 ID of the token to be approved
  */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      Approval(owner, _to, _tokenId);
    }
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }


  /**
  * @dev Sets or unsets the approval of a given operator
  * @dev An operator is allowed to transfer all tokens of the sender on their behalf
  * @param _to operator address to set the approval
  * @param _approved representing the status of the approval to be set
  */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  /**
  * @dev Transfers the ownership of a given token ID to another address
  * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);
    
    Transfer(_from, _to, _tokenId);
  }

  /**
  * @dev Safely transfers the ownership of a given token ID to another address
  * @dev If the target address is a contract, it must implement `onERC721Received`,
  *  which is called upon a safe transfer, and return the magic value
  *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
  *  the transfer is reverted.
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
  * @dev Safely transfers the ownership of a given token ID to another address
  * @dev If the target address is a contract, it must implement `onERC721Received`,
  *  which is called upon a safe transfer, and return the magic value
  *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
  *  the transfer is reverted.
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  * @param _data bytes data to send along with a safe transfer check
  */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  /**
  * @dev Internal function to mint a new token
  * @dev Reverts if the given token ID already exists
  * @param _to The address that will own the minted token
  * @param _tokenId uint256 ID of the token to be minted by the msg.sender
  */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    Transfer(address(0), _to, _tokenId);
  }

  /**
  * @dev Internal function to burn a specific token
  * @dev Reverts if the token does not exist
  * @param _tokenId uint256 ID of the token being burned by the msg.sender
  */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    Transfer(_owner, address(0), _tokenId);
  }

  /**
  * @dev Internal function to clear current approval of a given token ID
  * @dev Reverts if the given address is not indeed the owner of the token
  * @param _owner owner of the token
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      Approval(_owner, address(0), _tokenId);
    }
  }

  /**
  * @dev Internal function to add a token ID to the list of a given address
  * @param _to address representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
  */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
  * @dev Internal function to remove a token ID from the list of a given address
  * @param _from address representing the previous owner of the given token ID
  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
  */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
  * @dev Internal function to invoke `onERC721Received` on a target address
  * @dev The call is not executed if the target address is not a contract
  * @param _from address representing the previous owner of the given token ID
  * @param _to target address that will receive the tokens
  * @param _tokenId uint256 ID of the token to be transferred
  * @param _data bytes optional data to send along with the call
  * @return whether the call correctly returned the expected magic value
  */
  function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721, ERC721BasicToken {
  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping (address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs 
  mapping(uint256 => string) internal tokenURIs;

  /**
  * @dev Constructor function
  */
  function ERC721Token(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;
  }

  /**
  * @dev Gets the token name
  * @return string representing the token name
  */
  function name() public view returns (string) {
    return name_;
  }

  /**
  * @dev Gets the token symbol
  * @return string representing the token symbol
  */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
  * @dev Returns an URI for a given token ID
  * @dev Throws if the token ID does not exist. May return an empty string.
  * @param _tokenId uint256 ID of the token to query
  */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
  * @dev Internal function to set the token URI for a given token
  * @dev Reverts if the token ID does not exist
  * @param _tokenId uint256 ID of the token to set its URI
  * @param _uri string URI to assign
  */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
  * @dev Gets the token ID at a given index of the tokens list of the requested owner
  * @param _owner address owning the tokens list to be accessed
  * @param _index uint256 representing the index to be accessed of the requested tokens list
  * @return uint256 token ID at the given index of the tokens list owned by the requested address
  */
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
  * @dev Gets the total amount of tokens stored by the contract
  * @return uint256 representing the total amount of tokens
  */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
  * @dev Gets the token ID at a given index of all the tokens in this contract
  * @dev Reverts if the index is greater or equal to the total number of tokens
  * @param _index uint256 representing the index to be accessed of the tokens list
  * @return uint256 token ID at the given index of the tokens list
  */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
  * @dev Internal function to add a token ID to the list of a given address
  * @param _to address representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
  */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
  * @dev Internal function to remove a token ID from the list of a given address
  * @param _from address representing the previous owner of the given token ID
  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
  */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
  * @dev Internal function to mint a new token
  * @dev Reverts if the given token ID already exists
  * @param _to address the beneficiary that will own the minted token
  * @param _tokenId uint256 ID of the token to be minted by the msg.sender
  */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);
    
    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
  * @dev Internal function to burn a specific token
  * @dev Reverts if the token does not exist
  * @param _owner owner of the token to burn
  * @param _tokenId uint256 ID of the token being burned by the msg.sender
  */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}

// File: contracts/DebtToken.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;

// Internal dependencies.




// External dependencies.





/**
 * The DebtToken contract governs all business logic for making a debt agreement
 * transferable as an ERC721 non-fungible token.  Additionally, the contract
 * allows authorized contracts to trigger the minting of a debt agreement token
 * and, in turn, the insertion of a debt issuance into the DebtRegsitry.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtToken is ERC721Token, ERC165, Pausable, PermissionEvents {
    using PermissionsLib for PermissionsLib.Permissions;

    DebtRegistry public registry;

    PermissionsLib.Permissions internal tokenCreationPermissions;
    PermissionsLib.Permissions internal tokenURIPermissions;

    string public constant CREATION_CONTEXT = "debt-token-creation";
    string public constant URI_CONTEXT = "debt-token-uri";

    /**
     * Constructor that sets the address of the debt registry.
     */
    function DebtToken(address _registry)
        public
        ERC721Token("DebtToken", "DDT")
    {
        registry = DebtRegistry(_registry);
    }

    /**
     * ERC165 interface.
     * Returns true for ERC721, false otherwise
     */
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool _isSupported)
    {
        return interfaceID == 0x80ac58cd; // ERC721
    }

    /**
     * Mints a unique debt token and inserts the associated issuance into
     * the debt registry, if the calling address is authorized to do so.
     */
    function create(
        address _version,
        address _beneficiary,
        address _debtor,
        address _underwriter,
        uint _underwriterRiskRating,
        address _termsContract,
        bytes32 _termsContractParameters,
        uint _salt
    )
        public
        whenNotPaused
        returns (uint _tokenId)
    {
        require(tokenCreationPermissions.isAuthorized(msg.sender));

        bytes32 entryHash = registry.insert(
            _version,
            _beneficiary,
            _debtor,
            _underwriter,
            _underwriterRiskRating,
            _termsContract,
            _termsContractParameters,
            _salt
        );

        super._mint(_beneficiary, uint(entryHash));

        return uint(entryHash);
    }

    /**
     * Adds an address to the list of agents authorized to mint debt tokens.
     */
    function addAuthorizedMintAgent(address _agent)
        public
        onlyOwner
    {
        tokenCreationPermissions.authorize(_agent, CREATION_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized to mint debt tokens
     */
    function revokeMintAgentAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenCreationPermissions.revokeAuthorization(_agent, CREATION_CONTEXT);
    }

    /**
     * Returns the list of agents authorized to mint debt tokens
     */
    function getAuthorizedMintAgents()
        public
        view
        returns (address[] _agents)
    {
        return tokenCreationPermissions.getAuthorizedAgents();
    }

    /**
     * Adds an address to the list of agents authorized to set token URIs.
     */
    function addAuthorizedTokenURIAgent(address _agent)
        public
        onlyOwner
    {
        tokenURIPermissions.authorize(_agent, URI_CONTEXT);
    }

    /**
     * Returns the list of agents authorized to set token URIs.
     */
    function getAuthorizedTokenURIAgents()
        public
        view
        returns (address[] _agents)
    {
        return tokenURIPermissions.getAuthorizedAgents();
    }

    /**
     * Removes an address from the list of agents authorized to set token URIs.
     */
    function revokeTokenURIAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenURIPermissions.revokeAuthorization(_agent, URI_CONTEXT);
    }

    /**
     * We override approval method of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function approve(address _to, uint _tokenId)
        public
        whenNotPaused
    {
        super.approve(_to, _tokenId);
    }

    /**
     * We override setApprovalForAll method of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function setApprovalForAll(address _to, bool _approved)
        public
        whenNotPaused
    {
        super.setApprovalForAll(_to, _approved);
    }

    /**
     * Support deprecated ERC721 method
     */
    function transfer(address _to, uint _tokenId)
        public
    {
        safeTransferFrom(msg.sender, _to, _tokenId);
    }

    /**
     * We override transferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function transferFrom(address _from, address _to, uint _tokenId)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.transferFrom(_from, _to, _tokenId);
    }

    /**
     * We override safeTransferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function safeTransferFrom(address _from, address _to, uint _tokenId)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    /**
     * We override safeTransferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes _data)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.safeTransferFrom(_from, _to, _tokenId, _data);
    }

    /**
     * Allows senders with special permissions to set the token URI for a given debt token.
     */
    function setTokenURI(uint256 _tokenId, string _uri)
        public
        whenNotPaused
    {
        require(tokenURIPermissions.isAuthorized(msg.sender));
        super._setTokenURI(_tokenId, _uri);
    }

    /**
     * _modifyBeneficiary mutates the debt registry. This function should be
     * called every time a token is transferred or minted
     */
    function _modifyBeneficiary(uint _tokenId, address _to)
        internal
    {
        if (registry.getBeneficiary(bytes32(_tokenId)) != _to) {
            registry.modifyBeneficiary(bytes32(_tokenId), _to);
        }
    }
}

// File: contracts/TermsContract.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;


interface TermsContract {
     /// When called, the registerTermStart function registers the fact that
     ///    the debt agreement has begun.  This method is called as a hook by the
     ///    DebtKernel when a debt order associated with `agreementId` is filled.
     ///    Method is not required to make any sort of internal state change
     ///    upon the debt agreement's start, but MUST return `true` in order to
     ///    acknowledge receipt of the transaction.  If, for any reason, the
     ///    debt agreement stored at `agreementId` is incompatible with this contract,
     ///    MUST return `false`, which will cause the pertinent order fill to fail.
     ///    If this method is called for a debt agreement whose term has already begun,
     ///    must THROW.  Similarly, if this method is called by any contract other
     ///    than the current DebtKernel, must THROW.
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  debtor address. The debtor in this particular issuance.
     /// @return _success bool. Acknowledgment of whether
    function registerTermStart(
        bytes32 agreementId,
        address debtor
    ) public returns (bool _success);

     /// When called, the registerRepayment function records the debtor's
     ///  repayment, as well as any auxiliary metadata needed by the contract
     ///  to determine ex post facto the value repaid (e.g. current USD
     ///  exchange rate)
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  payer address. The address of the payer.
     /// @param  beneficiary address. The address of the payment's beneficiary.
     /// @param  unitsOfRepayment uint. The units-of-value repaid in the transaction.
     /// @param  tokenAddress address. The address of the token with which the repayment transaction was executed.
    function registerRepayment(
        bytes32 agreementId,
        address payer,
        address beneficiary,
        uint256 unitsOfRepayment,
        address tokenAddress
    ) public returns (bool _success);

     /// Returns the cumulative units-of-value expected to be repaid by a given block timestamp.
     ///  Note this is not a constant function -- this value can vary on basis of any number of
     ///  conditions (e.g. interest rates can be renegotiated if repayments are delinquent).
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  timestamp uint. The timestamp of the block for which repayment expectation is being queried.
     /// @return uint256 The cumulative units-of-value expected to be repaid by the time the given timestamp lapses.
    function getExpectedRepaymentValue(
        bytes32 agreementId,
        uint256 timestamp
    ) public view returns (uint256);

     /// Returns the cumulative units-of-value repaid by the point at which this method is called.
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @return uint256 The cumulative units-of-value repaid up until now.
    function getValueRepaidToDate(
        bytes32 agreementId
    ) public view returns (uint256);

    /**
     * A method that returns a Unix timestamp representing the end of the debt agreement's term.
     * contract.
     */
    function getTermEndTimestamp(
        bytes32 _agreementId
    ) public view returns (uint);
}

// File: contracts/TokenTransferProxy.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;






/**
 * The TokenTransferProxy is a proxy contract for transfering principal
 * and fee payments and repayments between agents and keepers in the Dharma
 * ecosystem.  It is decoupled from the DebtKernel in order to make upgrades to the
 * protocol contracts smoother -- if the DebtKernel or RepyamentRouter is upgraded to a new contract,
 * creditors will not have to grant new transfer approvals to a new contract's address.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract TokenTransferProxy is Pausable, PermissionEvents {
    using PermissionsLib for PermissionsLib.Permissions;

    PermissionsLib.Permissions internal tokenTransferPermissions;

    string public constant CONTEXT = "token-transfer-proxy";

    /**
     * Add address to list of agents authorized to initiate `transferFrom` calls
     */
    function addAuthorizedTransferAgent(address _agent)
        public
        onlyOwner
    {
        tokenTransferPermissions.authorize(_agent, CONTEXT);
    }

    /**
     * Remove address from list of agents authorized to initiate `transferFrom` calls
     */
    function revokeTransferAgentAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenTransferPermissions.revokeAuthorization(_agent, CONTEXT);
    }

    /**
     * Return list of agents authorized to initiate `transferFrom` calls
     */
    function getAuthorizedTransferAgents()
        public
        view
        returns (address[] authorizedAgents)
    {
        return tokenTransferPermissions.getAuthorizedAgents();
    }

    /**
     * Transfer specified token amount from _from address to _to address on give token
     */
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint _amount
    )
        public
        returns (bool _success)
    {
        require(tokenTransferPermissions.isAuthorized(msg.sender));

        return ERC20(_token).transferFrom(_from, _to, _amount);
    }
}

// File: contracts/DebtKernel.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;








/**
 * The DebtKernel is the hub of all business logic governing how and when
 * debt orders can be filled and cancelled.  All logic that determines
 * whether a debt order is valid & consensual is contained herein,
 * as well as the mechanisms that transfer fees to keepers and
 * principal payments to debtors.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtKernel is Pausable {
    using SafeMath for uint;

    enum Errors {
        // Debt has been already been issued
        DEBT_ISSUED,
        // Order has already expired
        ORDER_EXPIRED,
        // Debt issuance associated with order has been cancelled
        ISSUANCE_CANCELLED,
        // Order has been cancelled
        ORDER_CANCELLED,
        // Order parameters specify amount of creditor / debtor fees
        // that is not equivalent to the amount of underwriter / relayer fees
        ORDER_INVALID_INSUFFICIENT_OR_EXCESSIVE_FEES,
        // Order parameters specify insufficient principal amount for
        // debtor to at least be able to meet his fees
        ORDER_INVALID_INSUFFICIENT_PRINCIPAL,
        // Order parameters specify non zero fee for an unspecified recipient
        ORDER_INVALID_UNSPECIFIED_FEE_RECIPIENT,
        // Order signatures are mismatched / malformed
        ORDER_INVALID_NON_CONSENSUAL,
        // Insufficient balance or allowance for principal token transfer
        CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT
    }

    DebtToken public debtToken;

    // solhint-disable-next-line var-name-mixedcase
    address public TOKEN_TRANSFER_PROXY;
    bytes32 constant public NULL_ISSUANCE_HASH = bytes32(0);

    /* NOTE(kayvon): Currently, the `view` keyword does not actually enforce the
    static nature of the method; this will change in the future, but for now, in
    order to prevent reentrancy we'll need to arbitrarily set an upper bound on
    the gas limit allotted for certain method calls. */
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 8000;

    mapping (bytes32 => bool) public issuanceCancelled;
    mapping (bytes32 => bool) public debtOrderCancelled;

    event LogDebtOrderFilled(
        bytes32 indexed _agreementId,
        uint _principal,
        address _principalToken,
        address indexed _underwriter,
        uint _underwriterFee,
        address indexed _relayer,
        uint _relayerFee
    );

    event LogIssuanceCancelled(
        bytes32 indexed _agreementId,
        address indexed _cancelledBy
    );

    event LogDebtOrderCancelled(
        bytes32 indexed _debtOrderHash,
        address indexed _cancelledBy
    );

    event LogError(
        uint8 indexed _errorId,
        bytes32 indexed _orderHash
    );

    struct Issuance {
        address version;
        address debtor;
        address underwriter;
        uint underwriterRiskRating;
        address termsContract;
        bytes32 termsContractParameters;
        uint salt;
        bytes32 agreementId;
    }

    struct DebtOrder {
        Issuance issuance;
        uint underwriterFee;
        uint relayerFee;
        uint principalAmount;
        address principalToken;
        uint creditorFee;
        uint debtorFee;
        address relayer;
        uint expirationTimestampInSec;
        bytes32 debtOrderHash;
    }

    function DebtKernel(address tokenTransferProxyAddress)
        public
    {
        TOKEN_TRANSFER_PROXY = tokenTransferProxyAddress;
    }

    ////////////////////////
    // EXTERNAL FUNCTIONS //
    ////////////////////////

    /**
     * Allows contract owner to set the currently used debt token contract.
     * Function exists to maximize upgradeability of individual modules
     * in the entire system.
     */
    function setDebtToken(address debtTokenAddress)
        public
        onlyOwner
    {
        debtToken = DebtToken(debtTokenAddress);
    }

    /**
     * Fills a given debt order if it is valid and consensual.
     */
    function fillDebtOrder(
        address creditor,
        address[6] orderAddresses,
        uint[8] orderValues,
        bytes32[1] orderBytes32,
        uint8[3] signaturesV,
        bytes32[3] signaturesR,
        bytes32[3] signaturesS
    )
        public
        whenNotPaused
        returns (bytes32 _agreementId)
    {
        DebtOrder memory debtOrder = getDebtOrder(orderAddresses, orderValues, orderBytes32);

        // Assert order's validity & consensuality
        if (!assertDebtOrderValidityInvariants(debtOrder) ||
            !assertDebtOrderConsensualityInvariants(
                debtOrder,
                creditor,
                signaturesV,
                signaturesR,
                signaturesS) ||
            !assertExternalBalanceAndAllowanceInvariants(creditor, debtOrder)) {
            return NULL_ISSUANCE_HASH;
        }

        // Mint debt token and finalize debt agreement
        issueDebtAgreement(creditor, debtOrder.issuance);

        // Register debt agreement's start with terms contract
        // We permit terms contracts to be undefined (for debt agreements which
        // may not have terms contracts associated with them), and only
        // register a term's start if the terms contract address is defined.
        if (debtOrder.issuance.termsContract != address(0)) {
            require(
                TermsContract(debtOrder.issuance.termsContract)
                    .registerTermStart(
                        debtOrder.issuance.agreementId,
                        debtOrder.issuance.debtor
                    )
            );
        }

        // Transfer principal to debtor
        if (debtOrder.principalAmount > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.issuance.debtor,
                debtOrder.principalAmount.sub(debtOrder.debtorFee)
            ));
        }

        // Transfer underwriter fee to underwriter
        if (debtOrder.underwriterFee > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.issuance.underwriter,
                debtOrder.underwriterFee
            ));
        }

        // Transfer relayer fee to relayer
        if (debtOrder.relayerFee > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.relayer,
                debtOrder.relayerFee
            ));
        }

        LogDebtOrderFilled(
            debtOrder.issuance.agreementId,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.issuance.underwriter,
            debtOrder.underwriterFee,
            debtOrder.relayer,
            debtOrder.relayerFee
        );

        return debtOrder.issuance.agreementId;
    }

    /**
     * Allows both underwriters and debtors to prevent a debt
     * issuance in which they're involved from being used in
     * a future debt order.
     */
    function cancelIssuance(
        address version,
        address debtor,
        address termsContract,
        bytes32 termsContractParameters,
        address underwriter,
        uint underwriterRiskRating,
        uint salt
    )
        public
        whenNotPaused
    {
        require(msg.sender == debtor || msg.sender == underwriter);

        Issuance memory issuance = getIssuance(
            version,
            debtor,
            underwriter,
            termsContract,
            underwriterRiskRating,
            salt,
            termsContractParameters
        );

        issuanceCancelled[issuance.agreementId] = true;

        LogIssuanceCancelled(issuance.agreementId, msg.sender);
    }

    /**
     * Allows a debtor to cancel a debt order before it's been filled
     * -- preventing any counterparty from filling it in the future.
     */
    function cancelDebtOrder(
        address[6] orderAddresses,
        uint[8] orderValues,
        bytes32[1] orderBytes32
    )
        public
        whenNotPaused
    {
        DebtOrder memory debtOrder = getDebtOrder(orderAddresses, orderValues, orderBytes32);

        require(msg.sender == debtOrder.issuance.debtor);

        debtOrderCancelled[debtOrder.debtOrderHash] = true;

        LogDebtOrderCancelled(debtOrder.debtOrderHash, msg.sender);
    }

    ////////////////////////
    // INTERNAL FUNCTIONS //
    ////////////////////////

    /**
     * Helper function that mints debt token associated with the
     * given issuance and grants it to the beneficiary.
     */
    function issueDebtAgreement(address beneficiary, Issuance issuance)
        internal
        returns (bytes32 _agreementId)
    {
        // Mint debt token and finalize debt agreement
        uint tokenId = debtToken.create(
            issuance.version,
            beneficiary,
            issuance.debtor,
            issuance.underwriter,
            issuance.underwriterRiskRating,
            issuance.termsContract,
            issuance.termsContractParameters,
            issuance.salt
        );

        assert(tokenId == uint(issuance.agreementId));

        return issuance.agreementId;
    }

    /**
     * Asserts that a debt order meets all consensuality requirements
     * described in the DebtKernel specification document.
     */
    function assertDebtOrderConsensualityInvariants(
        DebtOrder debtOrder,
        address creditor,
        uint8[3] signaturesV,
        bytes32[3] signaturesR,
        bytes32[3] signaturesS
    )
        internal
        returns (bool _orderIsConsensual)
    {
        // Invariant: debtor's signature must be valid, unless debtor is submitting order
        if (msg.sender != debtOrder.issuance.debtor) {
            if (!isValidSignature(
                debtOrder.issuance.debtor,
                debtOrder.debtOrderHash,
                signaturesV[0],
                signaturesR[0],
                signaturesS[0]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }

        // Invariant: creditor's signature must be valid, unless creditor is submitting order
        if (msg.sender != creditor) {
            if (!isValidSignature(
                creditor,
                debtOrder.debtOrderHash,
                signaturesV[1],
                signaturesR[1],
                signaturesS[1]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }


        // Invariant: underwriter's signature must be valid (if present)
        if (debtOrder.issuance.underwriter != address(0) &&
            msg.sender != debtOrder.issuance.underwriter) {
            if (!isValidSignature(
                debtOrder.issuance.underwriter,
                getUnderwriterMessageHash(debtOrder),
                signaturesV[2],
                signaturesR[2],
                signaturesS[2]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }

        return true;
    }

    /**
     * Asserts that debt order meets all validity requirements described in
     * the DebtKernel specification document.
     */
    function assertDebtOrderValidityInvariants(DebtOrder debtOrder)
        internal
        returns (bool _orderIsValid)
    {
        uint totalFees = debtOrder.creditorFee.add(debtOrder.debtorFee);

        // Invariant: the total value of fees contributed by debtors and creditors
        //  must be equivalent to that paid out to underwriters and relayers.
        if (totalFees != debtOrder.relayerFee.add(debtOrder.underwriterFee)) {
            LogError(uint8(Errors.ORDER_INVALID_INSUFFICIENT_OR_EXCESSIVE_FEES), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debtor is given enough principal to cover at least debtorFees
        if (debtOrder.principalAmount < debtOrder.debtorFee) {
            LogError(uint8(Errors.ORDER_INVALID_INSUFFICIENT_PRINCIPAL), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: if no underwriter is specified, underwriter fees must be 0
        // Invariant: if no relayer is specified, relayer fees must be 0.
        //      Given that relayer fees = total fees - underwriter fees,
        //      we assert that total fees = underwriter fees.
        if ((debtOrder.issuance.underwriter == address(0) && debtOrder.underwriterFee > 0) ||
            (debtOrder.relayer == address(0) && totalFees != debtOrder.underwriterFee)) {
            LogError(uint8(Errors.ORDER_INVALID_UNSPECIFIED_FEE_RECIPIENT), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order must not be expired
        // solhint-disable-next-line not-rely-on-time
        if (debtOrder.expirationTimestampInSec < block.timestamp) {
            LogError(uint8(Errors.ORDER_EXPIRED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order's issuance must not already be minted as debt token
        if (debtToken.exists(uint(debtOrder.issuance.agreementId))) {
            LogError(uint8(Errors.DEBT_ISSUED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order's issuance must not have been cancelled
        if (issuanceCancelled[debtOrder.issuance.agreementId]) {
            LogError(uint8(Errors.ISSUANCE_CANCELLED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order itself must not have been cancelled
        if (debtOrderCancelled[debtOrder.debtOrderHash]) {
            LogError(uint8(Errors.ORDER_CANCELLED), debtOrder.debtOrderHash);
            return false;
        }

        return true;
    }

    /**
     * Assert that the creditor has a sufficient token balance and has
     * granted the token transfer proxy contract sufficient allowance to suffice for the principal
     * and creditor fee.
     */
    function assertExternalBalanceAndAllowanceInvariants(
        address creditor,
        DebtOrder debtOrder
    )
        internal
        returns (bool _isBalanceAndAllowanceSufficient)
    {
        uint totalCreditorPayment = debtOrder.principalAmount.add(debtOrder.creditorFee);

        if (getBalance(debtOrder.principalToken, creditor) < totalCreditorPayment ||
            getAllowance(debtOrder.principalToken, creditor) < totalCreditorPayment) {
            LogError(uint8(Errors.CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT), debtOrder.debtOrderHash);
            return false;
        }

        return true;
    }

    /**
     * Helper function transfers a specified amount of tokens between two parties
     * using the token transfer proxy contract.
     */
    function transferTokensFrom(
        address token,
        address from,
        address to,
        uint amount
    )
        internal
        returns (bool success)
    {
        return TokenTransferProxy(TOKEN_TRANSFER_PROXY).transferFrom(
            token,
            from,
            to,
            amount
        );
    }

    /**
     * Helper function that constructs a hashed issuance structs from the given
     * parameters.
     */
    function getIssuance(
        address version,
        address debtor,
        address underwriter,
        address termsContract,
        uint underwriterRiskRating,
        uint salt,
        bytes32 termsContractParameters
    )
        internal
        pure
        returns (Issuance _issuance)
    {
        Issuance memory issuance = Issuance({
            version: version,
            debtor: debtor,
            underwriter: underwriter,
            termsContract: termsContract,
            underwriterRiskRating: underwriterRiskRating,
            salt: salt,
            termsContractParameters: termsContractParameters,
            agreementId: getAgreementId(
                version,
                debtor,
                underwriter,
                termsContract,
                underwriterRiskRating,
                salt,
                termsContractParameters
            )
        });

        return issuance;
    }

    /**
     * Helper function that constructs a hashed debt order struct given the raw parameters
     * of a debt order.
     */
    function getDebtOrder(address[6] orderAddresses, uint[8] orderValues, bytes32[1] orderBytes32)
        internal
        view
        returns (DebtOrder _debtOrder)
    {
        DebtOrder memory debtOrder = DebtOrder({
            issuance: getIssuance(
                orderAddresses[0],
                orderAddresses[1],
                orderAddresses[2],
                orderAddresses[3],
                orderValues[0],
                orderValues[1],
                orderBytes32[0]
            ),
            principalToken: orderAddresses[4],
            relayer: orderAddresses[5],
            principalAmount: orderValues[2],
            underwriterFee: orderValues[3],
            relayerFee: orderValues[4],
            creditorFee: orderValues[5],
            debtorFee: orderValues[6],
            expirationTimestampInSec: orderValues[7],
            debtOrderHash: bytes32(0)
        });

        debtOrder.debtOrderHash = getDebtOrderHash(debtOrder);

        return debtOrder;
    }

    /**
     * Helper function that returns an issuance's hash
     */
    function getAgreementId(
        address version,
        address debtor,
        address underwriter,
        address termsContract,
        uint underwriterRiskRating,
        uint salt,
        bytes32 termsContractParameters
    )
        internal
        pure
        returns (bytes32 _agreementId)
    {
        return keccak256(
            version,
            debtor,
            underwriter,
            underwriterRiskRating,
            termsContract,
            termsContractParameters,
            salt
        );
    }

    /**
     * Returns the hash of the parameters which an underwriter is supposed to sign
     */
    function getUnderwriterMessageHash(DebtOrder debtOrder)
        internal
        view
        returns (bytes32 _underwriterMessageHash)
    {
        return keccak256(
            address(this),
            debtOrder.issuance.agreementId,
            debtOrder.underwriterFee,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.expirationTimestampInSec
        );
    }

    /**
     * Returns the hash of the debt order.
     */
    function getDebtOrderHash(DebtOrder debtOrder)
        internal
        view
        returns (bytes32 _debtorMessageHash)
    {
        return keccak256(
            address(this),
            debtOrder.issuance.agreementId,
            debtOrder.underwriterFee,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.debtorFee,
            debtOrder.creditorFee,
            debtOrder.relayer,
            debtOrder.relayerFee,
            debtOrder.expirationTimestampInSec
        );
    }

    /**
     * Given a hashed message, a signer's address, and a signature, returns
     * whether the signature is valid.
     */
    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
        pure
        returns (bool _valid)
    {
        return signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

    /**
     * Helper function for querying an address' balance on a given token.
     */
    function getBalance(
        address token,
        address owner
    )
        internal
        view
        returns (uint _balance)
    {
        // Limit gas to prevent reentrancy.
        return ERC20(token).balanceOf.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner);
    }

    /**
     * Helper function for querying an address' allowance to the 0x transfer proxy.
     */
    function getAllowance(
        address token,
        address owner
    )
        internal
        view
        returns (uint _allowance)
    {
        // Limit gas to prevent reentrancy.
        return ERC20(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner, TOKEN_TRANSFER_PROXY);
    }
}