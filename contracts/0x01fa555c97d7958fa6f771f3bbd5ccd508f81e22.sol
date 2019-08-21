// File: contracts/zeppelin-solidity/ownership/Ownable.sol

pragma solidity ^0.4.24;


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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: contracts/token/Managed.sol

pragma solidity ^0.4.24;


contract Managed is Ownable {
  mapping (address => bool) public managers;

  modifier onlyManager () {
    require(isManager(), "Only managers may perform this action");
    _;
  }

  modifier onlyManagerOrOwner () {
    require(
      checkManagerStatus(msg.sender) || msg.sender == owner,
      "Only managers or owners may perform this action"
    );
    _;
  }

  function checkManagerStatus (address managerAddress) public view returns (bool) {
    return managers[managerAddress];
  }

  function isManager () public view returns (bool) {
    return checkManagerStatus(msg.sender);
  }

  function addManager (address managerAddress) public onlyOwner {
    managers[managerAddress] = true;
  }

  function removeManager (address managerAddress) public onlyOwner {
    managers[managerAddress] = false;
  }
}

// File: contracts/token/ManagedWhitelist.sol

pragma solidity ^0.4.24;


contract ManagedWhitelist is Managed {
  // CORE - addresses that are controller by Civil Foundation, Civil Media, or Civil Newsrooms
  mapping (address => bool) public coreList;
  // CIVILIAN - addresses that have completed the tutorial
  mapping (address => bool) public civilianList;
  // UNLOCKED - addresses that have completed "proof of use" requirements
  mapping (address => bool) public unlockedList;
  // VERIFIED - addresses that have completed KYC verification
  mapping (address => bool) public verifiedList;
  // STOREFRONT - addresses that will sell tokens on behalf of the Civil Foundation. these addresses can only transfer to VERIFIED users
  mapping (address => bool) public storefrontList;
  // NEWSROOM - multisig addresses created by the NewsroomFactory
  mapping (address => bool) public newsroomMultisigList;

  // addToCore allows a manager to add an address to the CORE list
  function addToCore (address operator) public onlyManagerOrOwner {
    coreList[operator] = true;
  }

  // removeFromCore allows a manager to remove an address frin the CORE list
  function removeFromCore (address operator) public onlyManagerOrOwner {
    coreList[operator] = false;
  }

  // addToCivilians allows a manager to add an address to the CORE list
  function addToCivilians (address operator) public onlyManagerOrOwner {
    civilianList[operator] = true;
  }

  // removeFromCivilians allows a manager to remove an address from the CORE list
  function removeFromCivilians (address operator) public onlyManagerOrOwner {
    civilianList[operator] = false;
  }
  // addToUnlocked allows a manager to add an address to the UNLOCKED list
  function addToUnlocked (address operator) public onlyManagerOrOwner {
    unlockedList[operator] = true;
  }

  // removeFromUnlocked allows a manager to remove an address from the UNLOCKED list
  function removeFromUnlocked (address operator) public onlyManagerOrOwner {
    unlockedList[operator] = false;
  }

  // addToVerified allows a manager to add an address to the VERIFIED list
  function addToVerified (address operator) public onlyManagerOrOwner {
    verifiedList[operator] = true;
  }
  // removeFromVerified allows a manager to remove an address from the VERIFIED list
  function removeFromVerified (address operator) public onlyManagerOrOwner {
    verifiedList[operator] = false;
  }

  // addToStorefront allows a manager to add an address to the STOREFRONT list
  function addToStorefront (address operator) public onlyManagerOrOwner {
    storefrontList[operator] = true;
  }
  // removeFromStorefront allows a manager to remove an address from the STOREFRONT list
  function removeFromStorefront (address operator) public onlyManagerOrOwner {
    storefrontList[operator] = false;
  }

  // addToNewsroomMultisigs allows a manager to remove an address from the STOREFRONT list
  function addToNewsroomMultisigs (address operator) public onlyManagerOrOwner {
    newsroomMultisigList[operator] = true;
  }
  // removeFromNewsroomMultisigs allows a manager to remove an address from the STOREFRONT list
  function removeFromNewsroomMultisigs (address operator) public onlyManagerOrOwner {
    newsroomMultisigList[operator] = false;
  }

  function checkProofOfUse (address operator) public {

  }

}

// File: contracts/token/ERC1404/ERC1404.sol

pragma solidity ^0.4.24;

contract ERC1404 {
  /// @notice Detects if a transfer will be reverted and if so returns an appropriate reference code
  /// @param from Sending address
  /// @param to Receiving address
  /// @param value Amount of tokens being transferred
  /// @return Code by which to reference message for rejection reasoning
  /// @dev Overwrite with your custom transfer restriction logic
  function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);

  /// @notice Returns a human-readable message for a given restriction code
  /// @param restrictionCode Identifier for looking up a message
  /// @return Text showing the restriction's reasoning
  /// @dev Overwrite with your custom message and restrictionCode handling
  function messageForTransferRestriction (uint8 restrictionCode) public view returns (string);
}

// File: contracts/token/ERC1404/MessagesAndCodes.sol

pragma solidity ^0.4.24;

library MessagesAndCodes {
  string public constant EMPTY_MESSAGE_ERROR = "Message cannot be empty string";
  string public constant CODE_RESERVED_ERROR = "Given code is already pointing to a message";
  string public constant CODE_UNASSIGNED_ERROR = "Given code does not point to a message";

  struct Data {
    mapping (uint8 => string) messages;
    uint8[] codes;
  }

  function messageIsEmpty (string _message)
      internal
      pure
      returns (bool isEmpty)
  {
    isEmpty = bytes(_message).length == 0;
  }

  function messageExists (Data storage self, uint8 _code)
      internal
      view
      returns (bool exists)
  {
    exists = bytes(self.messages[_code]).length > 0;
  }

  function addMessage (Data storage self, uint8 _code, string _message)
      public
      returns (uint8 code)
  {
    require(!messageIsEmpty(_message), EMPTY_MESSAGE_ERROR);
    require(!messageExists(self, _code), CODE_RESERVED_ERROR);

    // enter message at code and push code onto storage
    self.messages[_code] = _message;
    self.codes.push(_code);
    code = _code;
  }

  function autoAddMessage (Data storage self, string _message)
      public
      returns (uint8 code)
  {
    require(!messageIsEmpty(_message), EMPTY_MESSAGE_ERROR);

    // find next available code to store the message at
    code = 0;
    while (messageExists(self, code)) {
      code++;
    }

    // add message at the auto-generated code
    addMessage(self, code, _message);
  }

  function removeMessage (Data storage self, uint8 _code)
      public
      returns (uint8 code)
  {
    require(messageExists(self, _code), CODE_UNASSIGNED_ERROR);

    // find index of code
    uint8 indexOfCode = 0;
    while (self.codes[indexOfCode] != _code) {
      indexOfCode++;
    }

    // remove code from storage by shifting codes in array
    for (uint8 i = indexOfCode; i < self.codes.length - 1; i++) {
      self.codes[i] = self.codes[i + 1];
    }
    self.codes.length--;

    // remove message from storage
    self.messages[_code] = "";
    code = _code;
  }

  function updateMessage (Data storage self, uint8 _code, string _message)
      public
      returns (uint8 code)
  {
    require(!messageIsEmpty(_message), EMPTY_MESSAGE_ERROR);
    require(messageExists(self, _code), CODE_UNASSIGNED_ERROR);

    // update message at code
    self.messages[_code] = _message;
    code = _code;
  }
}

// File: contracts/multisig/Factory.sol

pragma solidity ^0.4.19;

contract Factory {

  /*
    *  Events
    */
  event ContractInstantiation(address sender, address instantiation);

  /*
    *  Storage
    */
  mapping(address => bool) public isInstantiation;
  mapping(address => address[]) public instantiations;

  /*
    * Public functions
    */
  /// @dev Returns number of instantiations by creator.
  /// @param creator Contract creator.
  /// @return Returns number of instantiations by creator.
  function getInstantiationCount(address creator)
    public
    view
    returns (uint)
  {
    return instantiations[creator].length;
  }

  /*
    * Internal functions
    */
  /// @dev Registers contract in factory registry.
  /// @param instantiation Address of contract instantiation.
  function register(address instantiation)
      internal
  {
    isInstantiation[instantiation] = true;
    instantiations[msg.sender].push(instantiation);
    emit ContractInstantiation(msg.sender, instantiation);
  }
}

// File: contracts/interfaces/IMultiSigWalletFactory.sol

pragma solidity ^0.4.19;

interface IMultiSigWalletFactory {
  function create(address[] _owners, uint _required) public returns (address wallet);
}

// File: contracts/newsroom/ACL.sol

pragma solidity ^0.4.19;


/**
@title String-based Access Control List
@author The Civil Media Company
@dev The owner of this smart-contract overrides any role requirement in the requireRole modifier,
and so it is important to use the modifier instead of checking hasRole when creating actual requirements.
The internal functions are not secured in any way and should be extended in the deriving contracts to define
requirements that suit that specific domain.
*/
contract ACL is Ownable {
  event RoleAdded(address indexed granter, address indexed grantee, string role);
  event RoleRemoved(address indexed granter, address indexed grantee, string role);

  mapping(string => RoleData) private roles;

  modifier requireRole(string role) {
    require(isOwner(msg.sender) || hasRole(msg.sender, role));
    _;
  }

  function ACL() Ownable() public {
  }

  /**
  @notice Returns whether a specific addres has a role. Keep in mind that the owner can override role checks
  @param user The address for which role check is done
  @param role A constant name of the role being checked
  */
  function hasRole(address user, string role) public view returns (bool) {
    return roles[role].actors[user];
  }

  /**
  @notice Returns if the specified address is owner of this smart-contract and thus can override any role checks
  @param user The checked address
  */
  function isOwner(address user) public view returns (bool) {
    return user == owner;
  }

  function _addRole(address grantee, string role) internal {
    roles[role].actors[grantee] = true;
    emit RoleAdded(msg.sender, grantee, role);
  }

  function _removeRole(address grantee, string role) internal {
    delete roles[role].actors[grantee];
    emit RoleRemoved(msg.sender, grantee, role);
  }

  struct RoleData {
    mapping(address => bool) actors;
  }
}

// File: contracts/zeppelin-solidity/ECRecovery.sol

pragma solidity ^0.4.24;


/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 _hash, bytes _sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(_hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 _hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
    );
  }
}

// File: contracts/newsroom/Newsroom.sol

pragma solidity ^0.4.19;



/**
@title Newsroom - Smart-contract allowing for Newsroom-like goverance and content publishing

@dev The content number 0 is created automatically and it's use is reserved for the Newsroom charter / about page

Roles that are currently supported are:
- "editor" -> which can publish content, update revisions and add/remove more editors

To post cryptographicaly pre-approved content on the Newsroom, the author's signature must be included and
"Signed"-suffix functions used. Here are the steps to generate authors signature:
1. Take the address of this newsroom and the contentHash as bytes32 and tightly pack them
2. Calculate the keccak256 of tightly packed of above
3. Take the keccak and prepend it with the standard "Ethereum signed message" preffix (see ECRecovery and Ethereum's JSON PRC).
  a. Note - if you're using Ethereum's node instead of manual private key signing, that message shall be prepended by the Node itself
4. Take a keccak256 of that signed messaged
5. Verification can be done by using EC recovery algorithm using the authors signature
The verification can be seen in the internal `verifyRevisionsSignature` function.
The signing can be seen in (at)joincivil/utils package, function prepareNewsroomMessage function (and web3.eth.sign() it afterwards)
*/
contract Newsroom is ACL {
  using ECRecovery for bytes32;

  event ContentPublished(address indexed editor, uint indexed contentId, string uri);
  event RevisionSigned(uint indexed contentId, uint indexed revisionId, address indexed author);
  event RevisionUpdated(address indexed editor, uint indexed contentId, uint indexed revisionId, string uri);
  event NameChanged(string newName);

  string private constant ROLE_EDITOR = "editor";

  mapping(uint => Content) private contents;
  /*
  Maps the revision hash to original contentId where it was first used.
  This is used to prevent replay attacks in which a bad actor reuses an already used signature to sign a new revision of new content.
  New revisions with the same contentID can reuse signatures by design -> this is to allow the Editors to change the canonical URL (eg, website change).
  The end-client of those smart-contracts MUST (RFC-Like) verify the content to it's hash and the the hash to the signature.
  */
  mapping(bytes32 => UsedSignature) private usedSignatures;

  /**
  @notice The number of different contents in this Newsroom, indexed in <0, contentCount) (exclusive) range
  */
  uint public contentCount;
  /**
  @notice User readable name of this Newsroom
  */
  string public name;

  function Newsroom(string newsroomName, string charterUri, bytes32 charterHash) ACL() public {
    setName(newsroomName);
    publishContent(charterUri, charterHash, address(0), "");
  }

  /**
  @notice Gets the latest revision of the content at id contentId
  */
  function getContent(uint contentId) external view returns (bytes32 contentHash, string uri, uint timestamp, address author, bytes signature) {
    return getRevision(contentId, contents[contentId].revisions.length - 1);
  }

  /**
  @notice Gets a specific revision of the content. Each revision increases the ID from the previous one
  @param contentId Which content to get
  @param revisionId Which revision in that get content to get
  */
  function getRevision(
    uint contentId,
    uint revisionId
  ) public view returns (bytes32 contentHash, string uri, uint timestamp, address author, bytes signature)
  {
    Content storage content = contents[contentId];
    require(content.revisions.length > revisionId);

    Revision storage revision = content.revisions[revisionId];

    return (revision.contentHash, revision.uri, revision.timestamp, content.author, revision.signature);
  }

  /**
  @return Number of revisions for a this content, 0 if never published
  */
  function revisionCount(uint contentId) external view returns (uint) {
    return contents[contentId].revisions.length;
  }

  /**
  @notice Returns if the latest revision of the content at ID has the author's signature associated with it
  */
  function isContentSigned(uint contentId) public view returns (bool) {
    return isRevisionSigned(contentId, contents[contentId].revisions.length - 1);
  }

  /**
  @notice Returns if that specific revision of the content has the author's signature
  */
  function isRevisionSigned(uint contentId, uint revisionId) public view returns (bool) {
    Revision[] storage revisions = contents[contentId].revisions;
    require(revisions.length > revisionId);
    return revisions[revisionId].signature.length != 0;
  }

  /**
  @notice Changes the user-readable name of this contract.
  This function can be only called by the owner of the Newsroom
  */
  function setName(string newName) public onlyOwner() {
    require(bytes(newName).length > 0);
    name = newName;

    emit NameChanged(name);
  }

  /**
  @notice Adds a string-based role to the specific address, requires ROLE_EDITOR to use
  */
  function addRole(address who, string role) external requireRole(ROLE_EDITOR) {
    _addRole(who, role);
  }

  function addEditor(address who) external requireRole(ROLE_EDITOR) {
    _addRole(who, ROLE_EDITOR);
  }

  /**
  @notice Removes a string-based role from the specific address, requires ROLE_EDITOR to use
  */
  function removeRole(address who, string role) external requireRole(ROLE_EDITOR) {
    _removeRole(who, role);
  }

  /**
  @notice Saves the content's URI and it's hash into this Newsroom, this creates a new Content and Revision number 0.
  This function requires ROLE_EDITOR or owner to use.
  The content can be cryptographicaly secured / approved by author as per signing procedure
  @param contentUri Canonical URI to access the content. The client should then verify that the content has the same hash
  @param contentHash Keccak256 hash of the content that is linked
  @param author Author that cryptographically signs the content. Null if not signed
  @param signature Cryptographic signature of the author. Empty if not signed
  @return Content ID of the newly published content

  @dev Emits `ContentPublished`, `RevisionUpdated` and optionaly `ContentSigned` events
  */
  function publishContent(
    string contentUri,
    bytes32 contentHash,
    address author,
    bytes signature
  ) public requireRole(ROLE_EDITOR) returns (uint)
  {
    uint contentId = contentCount;
    contentCount++;

    require((author == address(0) && signature.length == 0) || (author != address(0) && signature.length != 0));
    contents[contentId].author = author;
    pushRevision(contentId, contentUri, contentHash, signature);

    emit ContentPublished(msg.sender, contentId, contentUri);
    return contentId;
  }

  /**
  @notice Updates the existing content with a new revision, the content id stays the same while revision id increases afterwards
  Requires that the content was first published
  This function can be only called by ROLE_EDITOR or the owner.
  The new revision can be left unsigned, even if the previous revisions were signed.
  If the new revision is also signed, it has to be approved by the same author that has signed the first revision.
  No signing can be done for articles that were published without any cryptographic author in the first place
  @param signature Signature that cryptographically approves this revision. Empty if not approved
  @return Newest revision id

  @dev Emits `RevisionUpdated`  event
  */
  function updateRevision(uint contentId, string contentUri, bytes32 contentHash, bytes signature) external requireRole(ROLE_EDITOR) {
    pushRevision(contentId, contentUri, contentHash, signature);
  }

  /**
  @notice Allows to backsign a revision by the author. This is indented when an author didn't have time to access
  to their private key but after time they do.
  The author must be the same as the one during publishing.
  If there was no author during publishing this functions allows to update the null author to a real one.
  Once done, the author can't be changed afterwards

  @dev Emits `RevisionSigned` event
  */
  function signRevision(uint contentId, uint revisionId, address author, bytes signature) external requireRole(ROLE_EDITOR) {
    require(contentId < contentCount);

    Content storage content = contents[contentId];

    require(content.author == address(0) || content.author == author);
    require(content.revisions.length > revisionId);

    if (contentId == 0) {
      require(isOwner(msg.sender));
    }

    content.author = author;

    Revision storage revision = content.revisions[revisionId];
    revision.signature = signature;

    require(verifyRevisionSignature(author, contentId, revision));

    emit RevisionSigned(contentId, revisionId, author);
  }

  function verifyRevisionSignature(address author, uint contentId, Revision storage revision) internal returns (bool isSigned) {
    if (author == address(0) || revision.signature.length == 0) {
      require(revision.signature.length == 0);
      return false;
    } else {
      // The url is is not used in the cryptography by design,
      // the rationale is that the Author can approve the content and the Editor might need to set the url
      // after the fact, or things like DNS change, meaning there would be a question of canonical url for that article
      //
      // The end-client of this smart-contract MUST (RFC-like) compare the authenticity of the content behind the URL with the hash of the revision
      bytes32 hashedMessage = keccak256(
        address(this),
        revision.contentHash
      ).toEthSignedMessageHash();

      require(hashedMessage.recover(revision.signature) == author);

      // Prevent replay attacks
      UsedSignature storage lastUsed = usedSignatures[hashedMessage];
      require(lastUsed.wasUsed == false || lastUsed.contentId == contentId);

      lastUsed.wasUsed = true;
      lastUsed.contentId = contentId;

      return true;
    }
  }

  function pushRevision(uint contentId, string contentUri, bytes32 contentHash, bytes signature) internal returns (uint) {
    require(contentId < contentCount);

    if (contentId == 0) {
      require(isOwner(msg.sender));
    }

    Content storage content = contents[contentId];

    uint revisionId = content.revisions.length;

    content.revisions.push(Revision(
      contentHash,
      contentUri,
      now,
      signature
    ));

    if (verifyRevisionSignature(content.author, contentId, content.revisions[revisionId])) {
      emit RevisionSigned(contentId, revisionId, content.author);
    }

    emit RevisionUpdated(msg.sender, contentId, revisionId, contentUri);
  }

  struct Content {
    Revision[] revisions;
    address author;
  }

  struct Revision {
    bytes32 contentHash;
    string uri;
    uint timestamp;
    bytes signature;
  }

  // Since all uints are 0x0 by default, we require additional bool to confirm that the contentID is not equal to content with actualy ID 0x0
  struct UsedSignature {
    bool wasUsed;
    uint contentId;
  }
}

// File: contracts/newsroom/NewsroomFactory.sol

pragma solidity ^0.4.19;
// TODO(ritave): Think of a way to not require contracts out of package




/**
@title Newsroom with Board of Directors factory
@notice This smart-contract creates the full multi-smart-contract structure of a Newsroom in a single transaction
After creation the Newsroom is owned by the Board of Directors which is represented by a multisig-gnosis-based wallet
*/
contract NewsroomFactory is Factory {
  IMultiSigWalletFactory public multisigFactory;
  mapping (address => address) public multisigNewsrooms;

  function NewsroomFactory(address multisigFactoryAddr) public {
    multisigFactory = IMultiSigWalletFactory(multisigFactoryAddr);
  }

  /**
  @notice Creates a fully-set-up newsroom, a multisig wallet and transfers it's ownership straight to the wallet at hand
  */
  function create(string name, string charterUri, bytes32 charterHash, address[] initialOwners, uint initialRequired)
    public
    returns (Newsroom newsroom)
  {
    address wallet = multisigFactory.create(initialOwners, initialRequired);
    newsroom = new Newsroom(name, charterUri, charterHash);
    newsroom.addEditor(msg.sender);
    newsroom.transferOwnership(wallet);
    multisigNewsrooms[wallet] = newsroom;
    register(newsroom);
  }
}

// File: contracts/proof-of-use/telemetry/TokenTelemetryI.sol

pragma solidity ^0.4.23;

interface TokenTelemetryI {
  function onRequestVotingRights(address user, uint tokenAmount) external;
}

// File: contracts/token/CivilTokenController.sol

pragma solidity ^0.4.24;






contract CivilTokenController is ManagedWhitelist, ERC1404, TokenTelemetryI {
  using MessagesAndCodes for MessagesAndCodes.Data;
  MessagesAndCodes.Data internal messagesAndCodes;

  uint8 public constant SUCCESS_CODE = 0;
  string public constant SUCCESS_MESSAGE = "SUCCESS";

  uint8 public constant MUST_BE_A_CIVILIAN_CODE = 1;
  string public constant MUST_BE_A_CIVILIAN_ERROR = "MUST_BE_A_CIVILIAN";

  uint8 public constant MUST_BE_UNLOCKED_CODE = 2;
  string public constant MUST_BE_UNLOCKED_ERROR = "MUST_BE_UNLOCKED";

  uint8 public constant MUST_BE_VERIFIED_CODE = 3;
  string public constant MUST_BE_VERIFIED_ERROR = "MUST_BE_VERIFIED";

  constructor () public {
    messagesAndCodes.addMessage(SUCCESS_CODE, SUCCESS_MESSAGE);
    messagesAndCodes.addMessage(MUST_BE_A_CIVILIAN_CODE, MUST_BE_A_CIVILIAN_ERROR);
    messagesAndCodes.addMessage(MUST_BE_UNLOCKED_CODE, MUST_BE_UNLOCKED_ERROR);
    messagesAndCodes.addMessage(MUST_BE_VERIFIED_CODE, MUST_BE_VERIFIED_ERROR);

  }

  function detectTransferRestriction (address from, address to, uint value)
      public
      view
      returns (uint8)
  {
    // FROM is core or users that have proved use
    if (coreList[from] || unlockedList[from]) {
      return SUCCESS_CODE;
    } else if (storefrontList[from]) { // FROM is a storefront wallet
      // allow if this is going to a verified user or a core address
      if (verifiedList[to] || coreList[to]) {
        return SUCCESS_CODE;
      } else {
        // Storefront cannot transfer to wallets that have not been KYCed
        return MUST_BE_VERIFIED_CODE;
      }
    } else if (newsroomMultisigList[from]) { // FROM is a newsroom multisig
      // TO is CORE or CIVILIAN
      if ( coreList[to] || civilianList[to]) {
        return SUCCESS_CODE;
      } else {
        return MUST_BE_UNLOCKED_CODE;
      }
    } else if (civilianList[from]) { // FROM is a civilian
      // FROM is sending TO a core address or a newsroom
      if (coreList[to] || newsroomMultisigList[to]) {
        return SUCCESS_CODE;
      } else {
        // otherwise fail
        return MUST_BE_UNLOCKED_CODE;
      }
    } else {
      // reject if FROM is not a civilian
      return MUST_BE_A_CIVILIAN_CODE;
    }
  }

  function messageForTransferRestriction (uint8 restrictionCode)
    public
    view
    returns (string message)
  {
    message = messagesAndCodes.messages[restrictionCode];
  }

  function onRequestVotingRights(address user, uint tokenAmount) external {
    addToUnlocked(user);
  }
}

// File: contracts/zeppelin-solidity/token/ERC20/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/zeppelin-solidity/math/SafeMath.sol

pragma solidity ^0.4.24;


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

// File: contracts/zeppelin-solidity/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param addedValue The amount of tokens to increase the allowance by.
    */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param subtractedValue The amount of tokens to decrease the allowance by.
    */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param value The amount that will be created.
    */
  function _mint(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
  function _burn(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal burn function.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
  function _burnFrom(address account, uint256 value) internal {
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
    _burn(account, value);
  }
}

// File: contracts/zeppelin-solidity/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor (string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
    * @return the name of the token.
    */
  function name() public view returns (string) {
    return _name;
  }

  /**
    * @return the symbol of the token.
    */
  function symbol() public view returns (string) {
    return _symbol;
  }

  /**
    * @return the number of decimals of the token.
    */
  function decimals() public view returns (uint8) {
    return _decimals;
  }
}

// File: contracts/token/CVLToken.sol

pragma solidity ^0.4.24;






/// @title Extendable reference implementation for the ERC-1404 token
/// @dev Inherit from this contract to implement your own ERC-1404 token
contract CVLToken is ERC20, ERC20Detailed, Ownable, ERC1404 {

  ERC1404 public controller;

  constructor (uint256 _initialAmount,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    ERC1404 _controller
    ) public ERC20Detailed(_tokenName, _tokenSymbol, _decimalUnits) {
    require(address(_controller) != address(0), "controller not provided");
    controller = _controller;
    _mint(msg.sender, _initialAmount);              // Give the creator all initial tokens
  }

  modifier onlyOwner () {
    require(msg.sender == owner, "not owner");
    _;
  }

  function changeController(ERC1404 _controller) public onlyOwner {
    require(address(_controller) != address(0), "controller not provided");
    controller = _controller;
  }

  modifier notRestricted (address from, address to, uint256 value) {
    require(controller.detectTransferRestriction(from, to, value) == 0, "token transfer restricted");
    _;
  }

  function transfer (address to, uint256 value)
      public
      notRestricted(msg.sender, to, value)
      returns (bool success)
  {
    success = super.transfer(to, value);
  }

  function transferFrom (address from, address to, uint256 value)
      public
      notRestricted(from, to, value)
      returns (bool success)
  {
    success = super.transferFrom(from, to, value);
  }

  function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8) {
    return controller.detectTransferRestriction(from, to, value);
  }

  function messageForTransferRestriction (uint8 restrictionCode) public view returns (string) {
    return controller.messageForTransferRestriction(restrictionCode);
  }


}