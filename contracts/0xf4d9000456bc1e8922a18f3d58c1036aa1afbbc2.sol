pragma solidity ^0.4.24;

/**
 * Utility library of inline functions on addresses
 */
library Address {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x80ac58cd;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
    mapping(bytes4 => bool) private _supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
    constructor() public
    {
        _registerInterface(_InterfaceId_ERC165);
    }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
    function supportsInterface(bytes4 interfaceId) external view
    returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

  /**
   * @dev internal method for registering an interface
   */
    function _registerInterface(bytes4 interfaceId) internal
    {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safeTransfer`. This function MUST return the function selector,
   * otherwise the caller will revert the transaction. The selector to be
   * returned can be obtained as `this.onERC721Received.selector`. This
   * function MAY throw to revert and reject the transfer.
   * Note: the ERC721 contract address is always the message sender.
   * @param operator The address which called `safeTransferFrom` function
   * @param from The address which previously owned the token
   * @param tokenId The NFT identifier which is being transferred
   * @param data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    )
    public
        returns(bytes4);
}

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function approve(address to, uint256 tokenId) external payable;
    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes data
        ) external payable;
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    /*
    * 0x80ac58cd ===
    *   bytes4(keccak256('balanceOf(address)')) ^
    *   bytes4(keccak256('ownerOf(uint256)')) ^
    *   bytes4(keccak256('approve(address,uint256)')) ^
    *   bytes4(keccak256('getApproved(uint256)')) ^
    *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
    *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
    *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
    *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
    */

    constructor() public
    {
    // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_InterfaceId_ERC721);
    }

    /**
    * @dev Gets the balance of the specified address
    * @param owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

  /**
   * @dev Gets the owner of the specified token ID
   * @param tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
    function ownerOf(uint256 tokenId) external view returns (address) {
        _ownerOf(tokenId);
    }
  
    function _ownerOf(uint256 tokenId) internal view returns (address owner) {
        owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
    * @dev Approves another address to transfer the given token ID
    * The zero address indicates there is no approved address.
    * There can only be one approved address per token at a given time.
    * Can only be called by the token owner or an approved operator.
    * @param to address to be approved for the given token ID
    * @param tokenId uint256 ID of the token to be approved
    */
    function approve(address to, uint256 tokenId) external payable {
        address owner = _tokenOwner[tokenId];
        require(to != owner);
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender]);

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
    * @dev Gets the approved address for a token ID, or zero if no address set
    * Reverts if the token ID does not exist.
    * @param tokenId uint256 ID of the token to query the approval of
    * @return address currently approved for the given token ID
    */
    function getApproved(uint256 tokenId) external view returns (address) {
        _getApproved(tokenId);
    }
  
    function _getApproved(uint256 tokenId) internal view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }
    /**
    * @dev Sets or unsets the approval of a given operator
    * An operator is allowed to transfer all tokens of the sender on their behalf
    * @param to operator address to set the approval
    * @param approved representing the status of the approval to be set
    */
    function setApprovalForAll(address to, bool approved) external {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
    * @dev Tells whether an operator is approved by a given owner
    * @param owner owner address which you want to query the approval of
    * @param operator operator address which you want to query the approval of
    * @return bool whether the given operator is approved by the given owner
    */
    function isApprovedForAll(
        address owner,
        address operator
    )
        external
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
    * @dev Transfers the ownership of a given token ID to another address
    * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
    * Requires the msg sender to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        external payable
    {
        _transferFrom(from, to, tokenId);
    }
    
    function _transferFrom(
        address from, 
        address to,
        uint256 tokenId) internal {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));
        
        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        
        emit Transfer(from, to, tokenId);
    }

    /**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    *
    * Requires the msg sender to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        external payable
    {
        // solium-disable-next-line arg-overflow
        _safeTransferFrom(from, to, tokenId, "");
    }

    /**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * Requires the msg sender to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes data to send along with a safe transfer check
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes _data
    )
        external payable
    {
        _safeTransferFrom(from, to, tokenId, _data);
    }
    
    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes _data)
        internal
    {
        _transferFrom(from, to, tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(from, to, tokenId, _data));
    }

    /**
    * @dev Returns whether the specified token exists
    * @param tokenId uint256 ID of the token to query the existence of
    * @return whether the token exists
    */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
    * @dev Returns whether the given spender can transfer a given token ID
    * @param spender address of the spender to query
    * @param tokenId uint256 ID of the token to be transferred
    * @return bool whether the msg.sender is approved for the given token ID,
    *  is an operator of the owner, or is the owner of the token
    */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    )
        internal
        view
        returns (bool)
    {
        address owner = _tokenOwner[tokenId];
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
        spender == owner ||
        _getApproved(tokenId) == spender ||
        _operatorApprovals[owner][spender]
        );
    }

    /**
    * @dev Internal function to mint a new token
    * Reverts if the given token ID already exists
    * @param to The address that will own the minted token
    * @param tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    /**
    * @dev Internal function to burn a specific token
    * Reverts if the token does not exist
    * @param tokenId uint256 ID of the token being burned by the msg.sender
    */
    function _burn(address owner, uint256 tokenId) internal {
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    /**
    * @dev Internal function to clear current approval of a given token ID
    * Reverts if the given address is not indeed the owner of the token
    * @param owner owner of the token
    * @param tokenId uint256 ID of the token to be transferred
    */
    function _clearApproval(address owner, uint256 tokenId) internal {
        require(_ownerOf(tokenId) == owner);
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    /**
    * @dev Internal function to add a token ID to the list of a given address
    * @param to address representing the new owner of the given token ID
    * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
    function _addTokenTo(address to, uint256 tokenId) internal {
        require(_tokenOwner[tokenId] == address(0));
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
    }

    /**
    * @dev Internal function to remove a token ID from the list of a given address
    * @param from address representing the previous owner of the given token ID
    * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(_ownerOf(tokenId) == from);
        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _tokenOwner[tokenId] = address(0);
    }

    /**
    * @dev Internal function to invoke `onERC721Received` on a target address
    * The call is not executed if the target address is not a contract
    * @param from address representing the previous owner of the given token ID
    * @param to target address that will receive the tokens
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes optional data to send along with the call
    * @return whether the call correctly returned the expected magic value
    */
    function _checkAndCallSafeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes _data
    )
        internal
        returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(
        msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
}

contract Bloccelerator is ERC721 {
    
    mapping (uint256 => string) public Courses;
    
      // The data structure of the example deed
    struct Certificate {
        string name;
        uint256 courseID;
        uint256 date;
        bytes32 registrationCode;
    }

  /* Events */

    // When a certificate is created by an admin.
    event Creation(uint256 indexed c_id, string indexed c_name, string indexed c_course);
    
    // Mapping from participants to certificates
    mapping (uint256 => Certificate) private participants;
    mapping (bytes32 => uint256[]) private studentDetail;

    // Needed to make all deeds discoverable. The length of this array also serves as our deed ID.
    uint256[] private certificates;
    uint256[] private courseIDs;
    address private owner;
    string public constant name = "Bloccelerator";
    string public constant symbol = "BLOC";
  
    constructor()
    public
    {
        owner = msg.sender;
    }
  
    modifier onlyContractOwner {
        require(msg.sender == owner);
        _;
    }
    
    // The contract owner creates deeds. Newly created deeds are initialised with a name and a beneficiary.
    function create(address _to, string _name, uint256 _course, uint256 _date, bytes32 _userCode) 
    public
    onlyContractOwner
    returns (uint256 certificateID)  {
        certificateID = certificates.length;
        certificates.push(certificateID);
        super._mint(_to, certificateID);
        participants[certificateID] = Certificate({
            name: _name,
            courseID: _course,
            date: _date,
            registrationCode: _userCode
        });
        studentDetail[_userCode].push(certificateID);
        
        emit Creation(certificateID, _name, Courses[_course]);
    }
  
    function addCourse(string _name) public onlyContractOwner returns (uint256 courseID) {
        require(verifyCourseExists(_name) != true);
        uint _courseCount = courseIDs.length;
        courseIDs.push(_courseCount);
        Courses[_courseCount] = _name;
        return _courseCount;
    }
  
    function verifyCourseExists(string _name) internal view returns (bool exists) {
        uint numberofCourses = courseIDs.length;
        for (uint i=0; i<numberofCourses; i++) {
            if (keccak256(abi.encodePacked(Courses[i])) == keccak256(abi.encodePacked(_name)))
            {
                return true;
            }
        }
        return false;
    }
  
    function getMyCertIDs(string IDNumber) public view returns (string _name, uint[] _certIDs) {
        bytes32 hashedID = keccak256(abi.encodePacked(IDNumber));
        uint[] storage ownedCerts = studentDetail[hashedID];
        require(verifyOwner(ownedCerts));
        
        _certIDs = studentDetail[hashedID];      
        _name = participants[_certIDs[0]].name;
    }
  
    function getCertInfo(uint256 certificateNumber) public view returns (string _name, string _courseName, uint256 _issueDate) {
        _name = participants[certificateNumber].name;
        _courseName = Courses[participants[certificateNumber].courseID];
        _issueDate = participants[certificateNumber].date;
    }
  
    function verifyOwner(uint[] _certIDs) internal view returns (bool isOwner) {
        uint _numberOfCerts = _certIDs.length;
        bool allCorrect = false;
        for (uint i=0; i<_numberOfCerts; i++) {
            allCorrect = (true && (_ownerOf(_certIDs[i]) == msg.sender));
        }
        return allCorrect;
    }
}