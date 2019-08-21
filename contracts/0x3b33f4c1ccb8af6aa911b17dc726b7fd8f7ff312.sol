pragma solidity 0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract StrikersBaseInterface {

  struct Card {
    uint32 mintTime;
    uint8 checklistId;
    uint16 serialNumber;
  }

  Card[] public cards;
}

contract StrikersMetadataIPFS is Ownable {

  string public ipfsGateway;
  StrikersBaseInterface public strikersBaseContract;

  mapping(uint256 => string) internal starredCardURIs;
  mapping(uint8 => string) internal checklistIdURIs;

  constructor(string _ipfsGateway, address _strikersBaseAddress) public {
    ipfsGateway = _ipfsGateway;
    strikersBaseContract = StrikersBaseInterface(_strikersBaseAddress);
    setupStarredCardURIs();
  }

  function setupStarredCardURIs() internal {
    // ONE STAR HAZARD
    starredCardURIs[1778] = "Qmd5DBGsaeScxxqrB7Xmi3abK24zqx4DnwY6CQRGBZSdqb";
    starredCardURIs[8151] = "Qmd5DBGsaeScxxqrB7Xmi3abK24zqx4DnwY6CQRGBZSdqb";

    // ONE STAR MBAPPE
    starredCardURIs[882] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[2552] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[3043] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[4019] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[4460] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[5303] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[7109] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";
    starredCardURIs[8494] = "QmPzwhKZyhdie48xT6nFcW8CMkD9kz56NxbVM7RZsoMJEc";

    // ONE STAR GRIEZMANN
    starredCardURIs[3448] = "Qmafj7ShBgibLoS8yrYBBD7KphwPZPCRq5jRtr6opz8NvV";
    starredCardURIs[4455] = "Qmafj7ShBgibLoS8yrYBBD7KphwPZPCRq5jRtr6opz8NvV";
    starredCardURIs[7366] = "Qmafj7ShBgibLoS8yrYBBD7KphwPZPCRq5jRtr6opz8NvV";
    starredCardURIs[7619] = "Qmafj7ShBgibLoS8yrYBBD7KphwPZPCRq5jRtr6opz8NvV";

    // ONE STAR POGBA
    starredCardURIs[5233] = "QmUXetpbGfBy2JuLowT9dtrcdQJ9GgcixgyddXWXo9EjD5";
    starredCardURIs[8089] = "QmUXetpbGfBy2JuLowT9dtrcdQJ9GgcixgyddXWXo9EjD5";

    // ONE STAR COURTOIS
    starredCardURIs[3224] = "QmfADUDxupVBQPbNR5yo5cRFKBHGQmSpMXnxtYTkTTZFfw";

    // ONE STAR LLORIS
    starredCardURIs[7357] = "QmQvjcGXq2Kb2q2quXgrk6y7zr68cXQwre54vfiTNRM5xu";
    starredCardURIs[7407] = "QmQvjcGXq2Kb2q2quXgrk6y7zr68cXQwre54vfiTNRM5xu";
    starredCardURIs[7697] = "QmQvjcGXq2Kb2q2quXgrk6y7zr68cXQwre54vfiTNRM5xu";

    // ONE STAR ALLI
    starredCardURIs[736] = "QmawJzdsP9EaxVxcQMkaHhKNPgesigiLdFvokUzh9ZzqF7";
    starredCardURIs[5487] = "QmawJzdsP9EaxVxcQMkaHhKNPgesigiLdFvokUzh9ZzqF7";
    starredCardURIs[7421] = "QmawJzdsP9EaxVxcQMkaHhKNPgesigiLdFvokUzh9ZzqF7";

    // ONE STAR VARANE
    starredCardURIs[2867] = "QmdFxtcfi8qwww4NniFbMJuU7tTR4EDj79uLseVSZpSohJ";
    starredCardURIs[6252] = "QmdFxtcfi8qwww4NniFbMJuU7tTR4EDj79uLseVSZpSohJ";

    // ONE STAR MANDZUKIC
    starredCardURIs[6250] = "QmTYT3im5aVjCX8jVBDer8YJedD4Z5KEnJtbVPr32eEN3e";

    // TWO STAR MANDZUKIC
    starredCardURIs[7794] = "Qmb89ETw9b1MRqRySxU8DxuQFBptiF1uN7wgkesWMwxAgF";
  }

  function updateIpfsGateway(string _ipfsGateway) external onlyOwner {
    ipfsGateway = _ipfsGateway;
  }

  function updateStarredCardURI(uint256 _tokenId, string _uri) external onlyOwner {
    starredCardURIs[_tokenId] = _uri;
  }

  function checklistIdURI(uint8 _checklistId, string _uri) external onlyOwner {
    checklistIdURIs[_checklistId] = _uri;
  }

  function tokenURI(uint256 _tokenId) external view returns (string) {
    string memory starredCardURI = starredCardURIs[_tokenId];
    if (bytes(starredCardURI).length > 0) {
      return strConcat(ipfsGateway, starredCardURI);
    }

    uint8 checklistId;
    (,checklistId,) = strikersBaseContract.cards(_tokenId);
    return strConcat(ipfsGateway, checklistIdURIs[checklistId]);
  }

  function strConcat(string _a, string _b) internal pure returns (string) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ab = new string(_ba.length + _bb.length);
    bytes memory bab = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
  }
}