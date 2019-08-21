pragma solidity ^0.4.18;
// File: contracts/TulipsSaleInterface.sol

/** @title Crypto Tulips Initial Sale Interface
* @dev This interface sets the standard for initial sale
* contract. All future sale contracts should follow this.
*/
interface TulipsSaleInterface {
    function putOnInitialSale(uint256 tulipId) external;
    function createAuction(
        uint256 _tulipId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _transferFrom
    )external;
}

// File: contracts/ERC721.sol

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
}

// File: contracts/ERC721MetaData.sol

/// @title The external contract that is responsible for generatingmetadata for the tulips,
/// Taken from crypto kitties source. May change with our own implementation
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
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

// File: contracts/TulipsRoles.sol

/*
* @title Crypto Tulips SaleAuction
* @dev .
*/
contract TulipsRoles is Pausable {

    modifier onlyFinancial() {
        require(msg.sender == address(financialAccount));
        _;
    }

    modifier onlyOperations() {
        require(msg.sender == address(operationsAccount));
        _;
    }

    function TulipsRoles() Ownable() public {
        financialAccount = msg.sender;
        operationsAccount = msg.sender;
    }

    address public financialAccount;
    address public operationsAccount;

    function transferFinancial(address newFinancial) public onlyOwner {
        require(newFinancial != address(0));
        financialAccount = newFinancial;
    }

    function transferOperations(address newOperations) public onlyOwner {
        require(newOperations != address(0));
        operationsAccount = newOperations;
    }

}

// File: contracts/TulipsStorage.sol

contract TulipsStorage is TulipsRoles {

    //// DATA

    /*
    * Main tulip struct.
    * Visual Info is the dna used to create the tulip image
    * Visual Hash hash of the image file to confirm validity if needed.
    */
    struct Tulip {
        uint256 visualInfo;
        bytes32 visualHash;
    }

    //// STORAGE
    /*
    * @dev Array of all tulips created indexed with tulipID.
    */
    Tulip[] public tulips;

    /*
    * @dev Maps tulipId's to owner addreses
    */
    mapping (uint256 => address) public tulipIdToOwner;

    /*
    * @dev Maps owner adress to number of tulips owned.
    * Bookkeeping for compliance with ERC20 and ERC721. Doesn't mean much in terms of
    * value of individual unfungable assets.
    */
    mapping (address => uint256) tulipOwnershipCount;

    /// @dev Maps tulipId to approved reciever of a pending token transfer.
    mapping (uint256 => address) public tulipIdToApprovedTranserAddress;
}

// File: contracts/TulipsTokenInterface.sol

/*
* @title Crypto Tulips Token Interface
* @dev This contract provides interface to ERC721 support.
*/
contract TulipsTokenInterface is TulipsStorage, ERC721 {

    //// TOKEN SPECS & META DATA

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "CryptoTulips";
    string public constant symbol = "CT";

    /*
    * @dev This external contract will return Tulip metadata. We are making this changable in case
    * we need to update our current uri scheme later on.
    */
    ERC721Metadata public erc721Metadata;

    /// @dev Set the address of the external contract that generates the metadata.
    function setMetadataAddress(address _contractAddress) public onlyOperations {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    //// EVENTS

    /*
    * @dev Transfer event as defined in ERC721.
    */
    event Transfer(address from, address to, uint256 tokenId);

    /*
    * @dev Approval event as defined in ERC721.
    */
    event Approval(address owner, address approved, uint256 tokenId);

    //// TRANSFER DATA

    /*
    * @dev Maps tulipId to approved transfer address
    */
    mapping (uint256 => address) public tulipIdToApproved;


    //// PUBLIC FACING FUNCTIONS
    /*
    * @notice Returns total number of Tulips created so far.
    */
    function totalSupply() public view returns (uint) {
        return tulips.length - 1;
    }

    /*
    * @notice Returns the number of Tulips owned by given address.
    * @param _owner The Tulip owner.
    */
    function balanceOf(address _owner) public view returns (uint256 count) {
        return tulipOwnershipCount[_owner];
    }

    /*
    * @notice Returns the owner of the given Tulip
    */
    function ownerOf(uint256 _tulipId)
        external
        view
        returns (address owner)
    {
        owner = tulipIdToOwner[_tulipId];

        // If owner adress is empty this is still a fresh Tulip waiting for its first owner.
        require(owner != address(0));
    }

    /*
    * @notice Unlocks the tulip for transfer. The reciever can calltransferFrom() to
    * get ownership of the tulip. This is a safer method since you can revoke the transfer
    * if you mistakenly send it to an invalid address.
    * @param _to The reciever address. Set to address(0) to revoke the approval.
    * @param _tulipId The tulip to be transfered
    */
    function approve(
        address _to,
        uint256 _tulipId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(tulipIdToOwner[_tulipId] == msg.sender);

        // Register the approval
        _approve(_tulipId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tulipId);
    }

    /*
    * @notice Transfers a tulip to another address without confirmation.
    * If the reciever's address is invalid tulip may be lost! Use approve() and transferFrom() instead.
    * @param _to The reciever address.
    * @param _tulipId The tulip to be transfered
    */
    function transfer(
        address _to,
        uint256 _tulipId
    )
        external
        whenNotPaused
    {
        // Safety checks for common mistakes.
        require(_to != address(0));
        require(_to != address(this));

        // You can only send tulips you own.
        require(tulipIdToOwner[_tulipId] == msg.sender);

        // Do the transfer
        _transfer(msg.sender, _to, _tulipId);
    }

    /*
    * @notice This method allows the caller to recieve a tulip if the caller is the approved address
    * caller can also give another address to recieve the tulip.
    * @param _from Current owner of the tulip.
    * @param _to New owner of the tulip
    * @param _tulipId The tulip to be transfered
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tulipId
    )
        external
        whenNotPaused
    {
        // Safety checks for common mistakes.
        require(_to != address(0));
        require(_to != address(this));

        // Check for approval and valid ownership
        require(tulipIdToApproved[_tulipId] == msg.sender);
        require(tulipIdToOwner[_tulipId] == _from);

        // Do the transfer
        _transfer(_from, _to, _tulipId);
    }

    /// @notice Returns metadata for the tulip.
    /// @param _tulipId The tulip to recieve information on
    function tokenMetadata(uint256 _tulipId, string _preferredTransport) external view returns (string infoUrl) {
        // We will set the meta data scheme in an external contract
        require(erc721Metadata != address(0));

        // Contracts cannot return string to each other so we do this
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tulipId, _preferredTransport);

        return _toString(buffer, count);
    }

    //// INTERNAL FUNCTIONS THAT ACTUALLY DO STUFF
    // These are called by public facing functions after sanity checks

    function _transfer(address _from, address _to, uint256 _tulipId) internal {
        // Increase total Tulips owned by _to address
        tulipOwnershipCount[_to]++;

        // Decrease total Tulips owned by _from address, if _from address is not empty
        if (_from != address(0)) {
            tulipOwnershipCount[_from]--;
        }

        // Update mapping of tulipID -> ownerAddress
        tulipIdToOwner[_tulipId] = _to;

        // Emit the transfer event.
        Transfer(_from, _to, _tulipId);
    }

    function _approve(uint256 _tulipId, address _approved) internal{
        tulipIdToApproved[_tulipId] = _approved;
        // Approve event is only sent on public facing function
    }

    //// UTILITY FUNCTIONS

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength)private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    function _memcpy(uint dest, uint src, uint len) private view {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

}

// File: contracts/TulipsCreation.sol

/*
* @title Crypto Tulips Creation Mechanisms & Core Contract
* @dev This contract provides methods in which we create new tulips.
*/
contract TulipsCreation is TulipsTokenInterface {

    //// STATS & LIMITS
    uint256 public constant TOTAL_TULIP_SUPPLY = 100000;
    uint256 public totalTulipCount;

    //// Sale contract
    TulipsSaleInterface public initialSaleContract;

    //// EVENTS

    /*
    * @dev Announces creation of a new tulip.
    */
    event TulipCreation(uint256 tulipId, uint256 visualInfo);

    /*
    * We have this in case we have to change the initial sale contract
    */
    function setSaleAuction(address _initialSaleContractAddress) external onlyOwner {
        initialSaleContract = TulipsSaleInterface(_initialSaleContractAddress);
    }

    function getSaleAuctionAddress() external view returns(address){
        return address(initialSaleContract);
    }

    //// CREATION INTERFACE
    /*
    * @dev This function mints a new Tulip .
    * @param _visualInfo Visual information used to generate tulip image.
    * @param _visualHash Keccak hash of generated image.
    */
    function createTulip( uint256 _visualInfo, bytes32 _visualHash )  external onlyOperations
        returns (uint)
    {
        require(totalTulipCount<TOTAL_TULIP_SUPPLY);

        Tulip memory tulip = Tulip({
            visualInfo: _visualInfo,
            visualHash: _visualHash
        });

        uint256 tulipId = tulips.push(tulip) - 1;

        // New created tulip is owned by initial sale auction at first
        tulipIdToOwner[tulipId] = address(initialSaleContract);
        initialSaleContract.putOnInitialSale(tulipId);

        totalTulipCount++;

        // Let the world know about this new tulip
        TulipCreation(
            tulipId, _visualInfo
        );

        return tulipId;
    }

    /*
    * @dev This method authorizes for transfer and puts tulip on auction on a single call.
    * This could be done in two seperate calls approve() and createAuction()
    * but this way we can offer a single operation version that canbe triggered from web ui.
    */
    function putOnAuction(
        uint256 _tulipId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {

        require(tulipIdToOwner[_tulipId] == msg.sender);

        tulipIdToApproved[_tulipId] = address(initialSaleContract);

        initialSaleContract.createAuction(
            _tulipId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }


}