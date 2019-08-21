pragma solidity ^0.4.21;

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
     constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "You are not the owner of this contract.");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/lifecycle/Destructible.sol

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  constructor() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
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
    require(!paused, "this contract is paused");
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
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
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
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: contracts/marketplace/Marketplace.sol

/**
 * @title Interface for contracts conforming to ERC-20
 */
contract ERC20Interface {
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

/**
 * @title Interface for contracts conforming to ERC-721
 */
contract ERC721Interface {
    function ownerOf(uint256 assetId) public view returns (address);
    function safeTransferFrom(address from, address to, uint256 assetId) public;
    function isAuthorized(address operator, uint256 assetId) public view returns (bool);
    function exists(uint256 assetId) public view returns (bool);
}

contract DCLEscrow is Ownable, Pausable, Destructible {
    using SafeMath for uint256;

    ERC20Interface public acceptedToken;
    ERC721Interface public nonFungibleRegistry;

    struct Escrow {
        bytes32 id;
        address seller;
        address buyer;
        uint256 price;
        uint256 offer;
        bool acceptsOffers;
        bool publicE;
        uint256 escrowByOwnerIdPos;
        uint256 parcelCount;
        address highestBidder;
        uint256 lastOfferPrice;
    }
    
    struct Offer {
        address highestOffer;
        uint256 highestOfferPrice;
        address previousOffer;
    }
    

    mapping (uint256 => Escrow) public escrowByAssetId;
    mapping (bytes32 => Escrow) public escrowByEscrowId;
    mapping (bytes32 => Offer) public offersByEscrowId;
    
    mapping (address => Escrow[]) public escrowByOwnerId;
    
    mapping(address => uint256) public openedEscrowsByOwnerId;
    mapping(address => uint256) public ownerEscrowsCounter;
    
    mapping(address => uint256[]) public allOwnerParcelsOnEscrow;
    mapping(bytes32 => uint256[]) public assetIdByEscrowId;
    mapping(address => bool) public whitelistAddresses;

    uint256 public whitelistCounter;
    uint256 public publicationFeeInWei;
    //15000000000000000000
    
    uint256 private publicationFeeTotal;
    bytes32[] public allEscrowIds;
    //address[] public whitelistAddressGetter;

    /* EVENTS */
    event EscrowCreated(
        bytes32 id,
        address indexed seller, 
        address indexed buyer,
        uint256 priceInWei,
        bool acceptsOffers,
        bool publicE,
        uint256 parcels
    );
    

    event EscrowSuccessful(
        bytes32 id,
        address indexed seller, 
        uint256 totalPrice, 
        address indexed winner
    );
    
    event EscrowCancelled(
        bytes32 id,
        address indexed seller
    );
    
    function addAddressWhitelist(address toWhitelist) public onlyOwner
    {
        require(toWhitelist != address(0), "Address cannot be empty.");
        whitelistAddresses[toWhitelist] = true;
    }
    
    /*
    function getwhitelistCounter() public onlyOwner view returns(uint256)
    {
        return whitelistCounter;
    }
    
    function getwhitelistAddress(uint256 index) public onlyOwner view returns(address)
    {
        return whitelistAddressGetter[index];
    }
    
    
    function deleteWhitelistAddress(address toDelete, uint256 index) public onlyOwner
    {
        require(toDelete != address(0), "Address cannot be blank.");
        require(index > 0, "index needs to be greater than zero.");
       delete whitelistAddresses[toDelete];
       delete whitelistAddressGetter[index];
    }
    */
    
    function updateEscrow(address _acceptedToken, address _nonFungibleRegistry) public onlyOwner {
        acceptedToken = ERC20Interface(_acceptedToken);
        nonFungibleRegistry = ERC721Interface(_nonFungibleRegistry);
    }
    
    constructor (address _acceptedToken, address _nonFungibleRegistry) public {
        
        acceptedToken = ERC20Interface(_acceptedToken);
        nonFungibleRegistry = ERC721Interface(_nonFungibleRegistry);
    }

    function setPublicationFee(uint256 publicationFee) onlyOwner public {
        publicationFeeInWei = publicationFee;
    }
    
    function getPublicationFeeTotal() public onlyOwner view returns(uint256)
    {
        return publicationFeeTotal;
    }
    
    function getTotalEscrowCount() public view returns(uint256)
    {
        return allEscrowIds.length;
    }
    
    function getSingleEscrowAdmin(bytes32 index) public view returns (bytes32, address, address,uint256, uint256, bool, bool, uint256, uint256, address, uint256) {
    Escrow storage tempEscrow = escrowByEscrowId[index];

    return (
    tempEscrow.id,
    tempEscrow.seller, 
    tempEscrow.buyer, 
    tempEscrow.price, 
    tempEscrow.offer, 
    tempEscrow.publicE,
    tempEscrow.acceptsOffers,
    tempEscrow.escrowByOwnerIdPos,
    tempEscrow.parcelCount,
    tempEscrow.highestBidder,
    tempEscrow.lastOfferPrice);
}
    
    function getAssetByEscrowIdLength(bytes32 escrowId) public view returns (uint256) {
    return assetIdByEscrowId[escrowId].length;
    }
    
    function getSingleAssetByEscrowIdLength(bytes32 escrowId, uint index) public view returns (uint256) {
    return assetIdByEscrowId[escrowId][index];
    }
    
    function getEscrowCountByAssetIdArray(address ownerAddress) public view returns (uint256) {
    return ownerEscrowsCounter[ownerAddress];
    }
    
    function getAllOwnedParcelsOnEscrow(address ownerAddress) public view returns (uint256) {
    return allOwnerParcelsOnEscrow[ownerAddress].length;
    }
    
    function getParcelAssetIdOnEscrow(address ownerAddress,uint index) public view returns (uint256) {
    return allOwnerParcelsOnEscrow[ownerAddress][index];
    }
    
    function getEscrowCountById(address ownerAddress) public view returns (uint) {
    return escrowByOwnerId[ownerAddress].length;
    }
    
    function getEscrowInfo(address ownerAddress, uint index) public view returns (bytes32, address, address,uint256, uint256, bool, bool, uint256, uint256, address, uint256) {
    Escrow storage tempEscrow = escrowByOwnerId[ownerAddress][index];

    return (
    tempEscrow.id,
    tempEscrow.seller, 
    tempEscrow.buyer, 
    tempEscrow.price, 
    tempEscrow.offer, 
    tempEscrow.publicE,
    tempEscrow.acceptsOffers,
    tempEscrow.escrowByOwnerIdPos,
    tempEscrow.parcelCount,
    tempEscrow.highestBidder,
    tempEscrow.lastOfferPrice);
}

   
    function placeOffer(bytes32 escrowId, uint256 offerPrice) public whenNotPaused
    {
        address seller = escrowByEscrowId[escrowId].seller;
        require(seller != msg.sender, "You are the owner of this escrow.");
        require(seller != address(0));
        require(offerPrice > 0, "Offer Price needs to be greater than zero");
        require(escrowByEscrowId[escrowId].id != '0x0', "That escrow ID is no longer valid.");

        
        bool acceptsOffers = escrowByEscrowId[escrowId].acceptsOffers;
        require(acceptsOffers, "This escrow does not accept offers.");

        //address buyer = escrowByEscrowId[escrowId].buyer;
        bool isPublic = escrowByEscrowId[escrowId].publicE;
        if(!isPublic)
        {
            require(msg.sender == escrowByEscrowId[escrowId].buyer, "You are not authorized for this escrow.");
        }
        
        Escrow memory tempEscrow = escrowByEscrowId[escrowId];
        tempEscrow.lastOfferPrice = tempEscrow.offer;
        tempEscrow.offer = offerPrice;
        tempEscrow.highestBidder = msg.sender;
        escrowByEscrowId[escrowId] = tempEscrow;
        
  
    }
    
    function createNewEscrow(uint256[] memory assedIds, uint256 escrowPrice, bool doesAcceptOffers, bool isPublic, address buyer) public whenNotPaused{
        //address tempAssetOwner = msg.sender;
        uint256 tempParcelCount = assedIds.length;
        
        for(uint i = 0; i < tempParcelCount; i++)
        {
            address assetOwner = nonFungibleRegistry.ownerOf(assedIds[i]);
            require(msg.sender == assetOwner, "You are not the owner of this parcel.");
            require(nonFungibleRegistry.exists(assedIds[i]), "This parcel does not exist.");
            require(nonFungibleRegistry.isAuthorized(address(this), assedIds[i]), "You have not authorized DCL Escrow to manage your LAND tokens.");
            allOwnerParcelsOnEscrow[assetOwner].push(assedIds[i]);
        }
        
        require(escrowPrice > 0, "Please pass a price greater than zero.");
        
        bytes32 escrowId = keccak256(abi.encodePacked(
            block.timestamp, 
            msg.sender,
            assedIds[0], 
            escrowPrice
        ));
        
         assetIdByEscrowId[escrowId] = assedIds;
        
        //uint256 memEscrowByOwnerIdPos = openedEscrowsByOwnerId[assetOwner];
        
        Escrow memory memEscrow = Escrow({
            id: escrowId,
            seller: msg.sender,
            buyer: buyer,
            price: escrowPrice,
            offer:0,
            publicE:isPublic,
            acceptsOffers: doesAcceptOffers,
            escrowByOwnerIdPos: 0,
            parcelCount: tempParcelCount,
            highestBidder: address(0),
            lastOfferPrice: 0
            });
            
        escrowByEscrowId[escrowId] = memEscrow;
        escrowByOwnerId[msg.sender].push(memEscrow);
        //ownerEscrowsCounter[msg.sender] = getEscrowCountByAssetIdArray(msg.sender) + 1;
        
        
           allEscrowIds.push(escrowId);
        
        
            emit EscrowCreated(
            escrowId,
            msg.sender,
            buyer,
            escrowPrice,
            doesAcceptOffers,
            isPublic,
            tempParcelCount
        );
        
    }
    
    function cancelAllEscrows() public onlyOwner
        {
            
        //need to delete each escrow by escrow id
        pause();
         for(uint e = 0; e < getTotalEscrowCount(); e++)
        {
             adminRemoveEscrow(allEscrowIds[e]);
        }
        delete allEscrowIds;
       unpause();
    }
    
    function adminRemoveEscrow(bytes32 escrowId) public onlyOwner
    {
        address seller = escrowByEscrowId[escrowId].seller;
        //require(seller == msg.sender || msg.sender == owner);
    
        //uint256 escrowOwnerPos = escrowByEscrowId[escrowId].escrowByOwnerIdPos;
        
        delete escrowByEscrowId[escrowId];

        for(uint t = 0; t < escrowByOwnerId[seller].length; t++)
        {
            if(escrowByOwnerId[seller][t].id == escrowId)
            {
                delete escrowByOwnerId[seller][t];
            }
        }
        
        //escrowByOwnerId[seller].splice
        //ownerEscrowsCounter[seller] = getEscrowCountByAssetIdArray(seller) - 1;
        
        uint256[] memory assetIds = assetIdByEscrowId[escrowId];
        
        for(uint i = 0; i < assetIds.length; i++)
        {
            for(uint j = 0; j < allOwnerParcelsOnEscrow[seller].length; j++)
            {
                if(assetIds[i] == allOwnerParcelsOnEscrow[seller][j])
                {
                    delete allOwnerParcelsOnEscrow[seller][j];
                }
            }
        }
        
        emit EscrowCancelled(escrowId, seller);
    }
    
    function removeEscrow(bytes32 escrowId) public whenNotPaused
    {
        address seller = escrowByEscrowId[escrowId].seller;
        require(seller == msg.sender || msg.sender == owner);
    
        //uint256 escrowOwnerPos = escrowByEscrowId[escrowId].escrowByOwnerIdPos;
        
        delete escrowByEscrowId[escrowId];

        for(uint t = 0; t < escrowByOwnerId[seller].length; t++)
        {
            if(escrowByOwnerId[seller][t].id == escrowId)
            {
                delete escrowByOwnerId[seller][t];
            }
        }
        
        //escrowByOwnerId[seller].splice
        //ownerEscrowsCounter[seller] = getEscrowCountByAssetIdArray(seller) - 1;
        
        uint256[] memory assetIds = assetIdByEscrowId[escrowId];
        
        for(uint i = 0; i < assetIds.length; i++)
        {
            for(uint j = 0; j < allOwnerParcelsOnEscrow[seller].length; j++)
            {
                if(assetIds[i] == allOwnerParcelsOnEscrow[seller][j])
                {
                    delete allOwnerParcelsOnEscrow[seller][j];
                }
            }
        }
        
        delete allEscrowIds;

        
        emit EscrowCancelled(escrowId, seller);
    }
 
 
    function acceptEscrow(bytes32 escrowId) public whenNotPaused {
        address seller = escrowByEscrowId[escrowId].seller;
        require(seller != msg.sender);
        require(seller != address(0));

        address buyer = escrowByEscrowId[escrowId].buyer;
        bool isPublic = escrowByEscrowId[escrowId].publicE;
        if(!isPublic)
        {
            require(msg.sender == escrowByEscrowId[escrowId].buyer, "You are not authorized for this escrow.");
        }

        //need to add check that offer price is accepted


        uint256[] memory assetIds = assetIdByEscrowId[escrowId];
        
        for(uint a = 0; a < assetIds.length; a++)
        {
            require(seller == nonFungibleRegistry.ownerOf(assetIds[a]));
        }
        
        uint escrowPrice = escrowByEscrowId[escrowId].price;
        
        if (publicationFeeInWei > 0) {
            if(!whitelistAddresses[msg.sender])
            {
                acceptedToken.transferFrom(
                msg.sender,
                owner,
                publicationFeeInWei
            );
            }
            
            if(!whitelistAddresses[seller])
            {
                acceptedToken.transferFrom(
                seller,
                owner,
                publicationFeeInWei
            );
            }
            
        }
        
        // Transfer sale amount to seller
        acceptedToken.transferFrom(
            msg.sender,
            seller,
            escrowPrice
        );
        
        for(uint counter = 0; counter < assetIds.length; counter++)
        {
            uint256 tempId = assetIds[counter];
            nonFungibleRegistry.safeTransferFrom(
            seller,
            msg.sender,
            tempId
            ); 
            
        }

        
        for(uint t = 0; t < escrowByOwnerId[seller].length; t++)
        {
            if(escrowByOwnerId[seller][t].id == escrowId)
            {
                delete escrowByOwnerId[seller][t];
            }
        }
        
        
        for(uint i = 0; i < assetIds.length; i++)
        {
            for(uint j = 0; j < allOwnerParcelsOnEscrow[seller].length; j++)
            {
                if(assetIds[i] == allOwnerParcelsOnEscrow[seller][j])
                {
                    delete allOwnerParcelsOnEscrow[seller][j];
                }
            }
        }


        delete escrowByEscrowId[escrowId]; 
        delete assetIdByEscrowId[escrowId];

            emit EscrowSuccessful(
            escrowId,
            seller,
            escrowPrice,
            buyer
        );

    }
 }