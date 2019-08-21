pragma solidity ^0.5.1;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
}

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }
}  

/// @title Synpatreg smart conract for synpat service
/// @author Telegram: @msmobile, IBerGroup
/// @notice This smart contract write events  with steem post hash
///in particular ProofOfConnect.

contract Synpatreg is Claimable {
    string public version = '1.1.0';
    mapping(bytes32 => bool) public permlinkSaved;
    
    event SynpatRecord(string indexed permlinkSaved_permlink, bytes32 _hashSha);
    
    function() external { } 
 
    ///@notice Make event record in Ethereumblockchain
    /// @dev Implied that _hashSha is hash of steemet post title+body
    /// @param _permlink  string, _permlink of steem post.
    /// @param _hashSha   - result of Keccak SHA256 function.
    /// @return true if ok, false otherwise 
    function writeSha3(string calldata _permlink, bytes32 _hashSha) external  returns (bool){
        bytes32 hash = calculateSha3(_permlink);
        require(!permlinkSaved[hash],"Permalink already exist!");
        permlinkSaved[hash]=true;
        emit SynpatRecord(_permlink, _hashSha);
        return true;
    }
    
    ///@notice Calculate hash
    /// @dev There is web3py analog exists: Web3.soliditySha3(['string'], ['_hashinput'])
    /// @param _hashinput   - string .
    /// @return byte32, result of keccak256 (sha3 in old style) 
    function calculateSha3(string memory _hashinput) public pure returns (bytes32){
        return keccak256(bytes(_hashinput)); 
    }
   
    
    ///@dev use in case of depricate this contract
    function kill() external onlyOwner {
        selfdestruct(msg.sender);
    }
}