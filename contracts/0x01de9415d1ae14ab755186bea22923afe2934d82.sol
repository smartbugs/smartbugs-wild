pragma solidity ^0.4.24;

interface ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
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

/**
 * @title Operator
 * @dev Allow two roles: 'owner' or 'operator'
 *      - owner: admin/superuser (e.g. with financial rights)
 *      - operator: can update configurations
 */
contract Operator is Ownable {
    address[] public operators;

    uint public MAX_OPS = 20; // Default maximum number of operators allowed

    mapping(address => bool) public isOperator;

    event OperatorAdded(address operator);
    event OperatorRemoved(address operator);

    // @dev Throws if called by any non-operator account. Owner has all ops rights.
    modifier onlyOperator() {
        require(
            isOperator[msg.sender] || msg.sender == owner,
            "Permission denied. Must be an operator or the owner."
        );
        _;
    }

    /**
     * @dev Allows the current owner or operators to add operators
     * @param _newOperator New operator address
     */
    function addOperator(address _newOperator) public onlyOwner {
        require(
            _newOperator != address(0),
            "Invalid new operator address."
        );

        // Make sure no dups
        require(
            !isOperator[_newOperator],
            "New operator exists."
        );

        // Only allow so many ops
        require(
            operators.length < MAX_OPS,
            "Overflow."
        );

        operators.push(_newOperator);
        isOperator[_newOperator] = true;

        emit OperatorAdded(_newOperator);
    }

    /**
     * @dev Allows the current owner or operators to remove operator
     * @param _operator Address of the operator to be removed
     */
    function removeOperator(address _operator) public onlyOwner {
        // Make sure operators array is not empty
        require(
            operators.length > 0,
            "No operator."
        );

        // Make sure the operator exists
        require(
            isOperator[_operator],
            "Not an operator."
        );

        // Manual array manipulation:
        // - replace the _operator with last operator in array
        // - remove the last item from array
        address lastOperator = operators[operators.length - 1];
        for (uint i = 0; i < operators.length; i++) {
            if (operators[i] == _operator) {
                operators[i] = lastOperator;
            }
        }
        operators.length -= 1; // remove the last element

        isOperator[_operator] = false;
        emit OperatorRemoved(_operator);
    }

    // @dev Remove ALL operators
    function removeAllOps() public onlyOwner {
        for (uint i = 0; i < operators.length; i++) {
            isOperator[operators[i]] = false;
        }
        operators.length = 0;
    }
}

interface BitizenCarService {
  function isBurnedCar(uint256 _carId) external view returns (bool);
  function getOwnerCars(address _owner) external view returns(uint256[]);
  function getBurnedCarIdByIndex(uint256 _index) external view returns (uint256);
  function getCarInfo(uint256 _carId) external view returns(string, uint8, uint8);
  function createCar(address _owner, string _foundBy, uint8 _type, uint8 _ext) external returns(uint256);
  function updateCar(uint256 _carId, string _newFoundBy, uint8 _newType, uint8 _ext) external;
  function burnCar(address _owner, uint256 _carId) external;
}

contract BitizenCarOperator is Operator {

  event CreateCar(address indexed _owner, uint256 _carId);
  
  BitizenCarService internal carService;

  ERC721 internal ERC721Service;

  uint16 PER_USER_MAX_CAR_COUNT = 1;

  function injectCarService(BitizenCarService _service) public onlyOwner {
    carService = BitizenCarService(_service);
    ERC721Service = ERC721(_service);
  }

  function setMaxCount(uint16 _count) public onlyOwner {
    PER_USER_MAX_CAR_COUNT = _count;
  }

  function getOwnerCars() external view returns(uint256[]) {
    return carService.getOwnerCars(msg.sender);
  }

  function getCarInfo(uint256 _carId) external view returns(string, uint8, uint8){
    return carService.getCarInfo(_carId);
  }
  
  function createCar(string _foundBy) external returns(uint256) {
    require(ERC721Service.balanceOf(msg.sender) < PER_USER_MAX_CAR_COUNT,"user owned car count overflow");
    uint256 carId = carService.createCar(msg.sender, _foundBy, 1, 1);
    emit CreateCar(msg.sender, carId);
    return carId;
  }

  function createCarByOperator(address _owner, string _foundBy, uint8 _type, uint8 _ext) external onlyOperator returns (uint256) {
    uint256 carId = carService.createCar(_owner, _foundBy, _type, _ext);
    emit CreateCar(msg.sender, carId);
    return carId;
  }

}