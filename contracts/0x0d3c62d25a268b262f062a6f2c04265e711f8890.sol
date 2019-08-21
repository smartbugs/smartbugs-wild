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

/// @dev We need to be able to check a card's checklist ID, so use this interface instead of importing everything.
contract StrikersBaseInterface {

  struct Card {
    uint32 mintTime;
    uint8 checklistId;
    uint16 serialNumber;
  }

  Card[] public cards;
}

/// @title An optional contract that allows us to associate metadata to our cards.
/// @author The CryptoStrikers Team
contract StrikersMetadataIPFS is Ownable {

  /// @dev The base url for an IPFS gateway
  ///   ex: https://ipfs.infura.io/ipfs/
  string public ipfsGateway;

  /// @dev A reference to the main CryptoStrikers contract
  StrikersBaseInterface public strikersBaseContract;

  /// @dev Cards with stars have special metadata, which we access here using the relevant token id.
  mapping(uint256 => string) internal starredCardURIs;

  /// @dev For the rest of the cards, we get their checklist id and access this mapping.
  mapping(uint8 => string) internal checklistIdURIs;

  constructor(string _ipfsGateway, address _strikersBaseAddress) public {
    ipfsGateway = _ipfsGateway;
    strikersBaseContract = StrikersBaseInterface(_strikersBaseAddress);
    setupURIs();
  }

  /// @dev This isn't super expensive so just do it in the constructor.
  function setupURIs() internal {
    // ONE STAR HAZARD
    starredCardURIs[1778] = "QmYr929yRFHUWqadAW6djKXaXjv9hzjxJyhgfNiTyQWw3a";
    starredCardURIs[8151] = "QmYr929yRFHUWqadAW6djKXaXjv9hzjxJyhgfNiTyQWw3a";

    // ONE STAR MBAPPE
    starredCardURIs[882] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[2552] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[3043] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[4019] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[4460] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[5303] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[7109] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";
    starredCardURIs[8494] = "QmPvDZykYBw9iMBfHcSdLMruWirKUfcwsXfZ5mZwEFnG7X";

    // ONE STAR GRIEZMANN
    starredCardURIs[3448] = "QmXZmq6xs5MaoSZ6UPJ5MLKDeLK5rTWuwhjYvaeZJdMS77";
    starredCardURIs[4455] = "QmXZmq6xs5MaoSZ6UPJ5MLKDeLK5rTWuwhjYvaeZJdMS77";
    starredCardURIs[7366] = "QmXZmq6xs5MaoSZ6UPJ5MLKDeLK5rTWuwhjYvaeZJdMS77";
    starredCardURIs[7619] = "QmXZmq6xs5MaoSZ6UPJ5MLKDeLK5rTWuwhjYvaeZJdMS77";

    // ONE STAR POGBA
    starredCardURIs[5233] = "QmVDfxWGjLSomrcQz7JB2iZmsfNFpyVPQzJvkCbJc19iWu";
    starredCardURIs[8089] = "QmVDfxWGjLSomrcQz7JB2iZmsfNFpyVPQzJvkCbJc19iWu";

    // ONE STAR COURTOIS
    starredCardURIs[3224] = "QmXCJ53VF2nZdj1xpYaBo8BJyjdoo1ggVmCjt1cAWhd4ou";

    // ONE STAR LLORIS
    starredCardURIs[7357] = "QmP5wADxxZJVrzkKj5e8S7HAtAGg6L1DHMAUp7tGCgiGxE";
    starredCardURIs[7407] = "QmP5wADxxZJVrzkKj5e8S7HAtAGg6L1DHMAUp7tGCgiGxE";
    starredCardURIs[7697] = "QmP5wADxxZJVrzkKj5e8S7HAtAGg6L1DHMAUp7tGCgiGxE";

    // ONE STAR ALLI
    starredCardURIs[736] = "Qmc7w3D5C9xEp3LPTwGxwC3xUnAsQH22KDSdhLi5Bj7nYr";
    starredCardURIs[5487] = "Qmc7w3D5C9xEp3LPTwGxwC3xUnAsQH22KDSdhLi5Bj7nYr";
    starredCardURIs[7421] = "Qmc7w3D5C9xEp3LPTwGxwC3xUnAsQH22KDSdhLi5Bj7nYr";

    // ONE STAR VARANE
    starredCardURIs[2867] = "QmecZq2xjqRPQfUQbGs2N4dp7NX1ftutVcp6vRK9FUMV4C";
    starredCardURIs[6252] = "QmecZq2xjqRPQfUQbGs2N4dp7NX1ftutVcp6vRK9FUMV4C";

    // ONE STAR MANDZUKIC
    starredCardURIs[6250] = "QmTyyYRJQhqVHAVCgvpMJgp5d67QDuLnkDZ24EnZBD2heF";

    // TWO STAR MANDZUKIC
    starredCardURIs[7794] = "QmZFHQhcWenea4GwHsK2chF5x1rxyFDvnz3QhyPqLSRKc4";
  }

  function updateIpfsGateway(string _ipfsGateway) external onlyOwner {
    ipfsGateway = _ipfsGateway;
  }

  function updateStarredCardURI(uint256 _tokenId, string _uri) external onlyOwner {
    starredCardURIs[_tokenId] = _uri;
  }

  function updateChecklistIdURI(uint8 _checklistId, string _uri) external onlyOwner {
    checklistIdURIs[_checklistId] = _uri;
  }

  /// @dev Returns the IPFS URL for a given token Id.
  ///   ex: https://ipfs.infura.io/ipfs/QmP5wADxxZJVrzkKj5e8S7HAtAGg6L1DHMAUp7tGCgiGxE
  ///   That URI points to a JSON blob conforming to OpenSea's spec.
  ///   see: https://docs.opensea.io/docs/2-adding-metadata
  function tokenURI(uint256 _tokenId) external view returns (string) {
    string memory starredCardURI = starredCardURIs[_tokenId];
    if (bytes(starredCardURI).length > 0) {
      return strConcat(ipfsGateway, starredCardURI);
    }

    uint8 checklistId;
    (,checklistId,) = strikersBaseContract.cards(_tokenId);
    return strConcat(ipfsGateway, checklistIdURIs[checklistId]);
  }

  // String helper below was taken from Oraclize.
  // https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.4.sol

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