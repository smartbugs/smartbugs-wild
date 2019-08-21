pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https://ethergoo.io
 * 
 */

interface ERC721 {
    function totalSupply() external view returns (uint256 tokens);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function exists(uint256 tokenId) external view returns (bool tokenExists);
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address approvee);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function tokensOf(address owner) external view returns (uint256[] tokens);
    //function tokenByIndex(uint256 index) external view returns (uint256 token);

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
}

interface ERC20 {
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
    function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns(bytes4);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}

contract Bankroll {
     function depositEth(uint256 gooAllocation, uint256 tokenAllocation) payable external;
}

contract Inventory {
    mapping(uint256 => uint256) public tokenItems; // tokenId -> itemId
}

contract Marketplace is ERC721TokenReceiver, ApproveAndCallFallBack {
    
    mapping(address => bool) whitelistedMaterials; // ERC20 addresses allowed to list
    mapping(address => bool) whitelistedItems; // ERC721 addresses allowed to list
    mapping(address => uint256) listingFees; // Just incase want different fee per type
    Bankroll constant bankroll = Bankroll(0x66a9f1e53173de33bec727ef76afa84956ae1b25);
 
    uint256 private constant removalDuration = 14 days; // Listings can be pruned from market after 14 days
    
    bool public paused = false;
    address owner;

    mapping(uint256 => Listing) public listings;
    uint256[] public listingsIds;
    
    uint256 listingId = 1; // Start at one
    
    constructor() public {
        owner = msg.sender;
    }

    struct Listing {
        address tokenAddress; // Listing type (either item, premium unit, materials)
        address player;
        
        uint128 listingPointer; // Index in the market's listings
        uint128 tokenId; // Or amount listed (if it's erc20)
        uint128 listTime;
        uint128 price;
    }
    
    function getMarketSize() external constant returns(uint) {
        return listingsIds.length;
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns(bytes4) {
        require(whitelistedItems[msg.sender]); // Can only list items + premium units
        require(canListItems(from)); // Token owner cannot be a contract (to prevent reverting payments)
        require(!paused);
        
        uint256 price = extractUInt256(data);
        require(price > 99 szabo && price <= 100 ether);
        
        listings[listingId] = Listing(msg.sender, from, uint128(listingsIds.push(listingId) - 1), uint128(tokenId), uint128(now), uint128(price));
        listingId++;
        
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
    
    function receiveApproval(address from, uint256 amount, address token, bytes data) external {
        require(whitelistedMaterials[msg.sender]);
        require(canListItems(from)); // Token owner cannot be a contract (to prevent reverting payments)
        require(amount > 0);
        require(!paused);
        
        uint256 price = extractUInt256(data);
        require(price > 9 szabo && price <= 100 ether);
        
        listings[listingId] = Listing(msg.sender, from, uint128(listingsIds.push(listingId) - 1), uint128(amount), uint128(now), uint128(price));
        listingId++;
        
        ERC20(token).transferFrom(from, this, amount);
    }
    
    function purchaseListing(uint256 auctionId) payable external {
        Listing memory listing = listings[auctionId];
        require(listing.tokenId > 0);
        require(listing.player != msg.sender);
        require(!paused);
        
        uint128 price = listing.price;
        require(msg.value >= price);
        
        if (whitelistedMaterials[listing.tokenAddress]) {
            uint128 matsBought = uint128(msg.value) / price;
            if (matsBought >= listing.tokenId) {
                matsBought = listing.tokenId; // Max mats for sale
                removeListingInternal(auctionId); // Listing sold out so remove
            } else {
                listings[auctionId].tokenId = listings[auctionId].tokenId - matsBought;
            }
            price *= matsBought;
            ERC20(listing.tokenAddress).transfer(msg.sender, matsBought);
        } else if (whitelistedItems[listing.tokenAddress]) {
            removeListingInternal(auctionId);
            ERC721(listing.tokenAddress).transferFrom(this, msg.sender, listing.tokenId);
        }
        
        uint256 saleFee = (price * listingFees[listing.tokenAddress]) / 100;
        listing.player.transfer(price - saleFee); // Pay seller
        bankroll.depositEth.value(saleFee)(50, 50);
        
        uint256 bidExcess = msg.value - price;
        if (bidExcess > 0) {
            msg.sender.transfer(bidExcess);
        }
    }
    
    function removeListing(uint256 auctionId) external {
        Listing memory listing = listings[auctionId];
        require(listing.tokenId > 0);
        require(listing.player == msg.sender || (now - listing.listTime) > removalDuration);
        
        // Transfer back
        if (whitelistedMaterials[listing.tokenAddress]) {
            ERC20(listing.tokenAddress).transfer(listing.player, listing.tokenId);
        } else if (whitelistedItems[listing.tokenAddress]) {
            ERC721(listing.tokenAddress).transferFrom(this, listing.player, listing.tokenId);
        }
        
        removeListingInternal(auctionId);
    }
    
    function removeListingInternal(uint256 auctionId) internal {
        if (listingsIds.length > 1) {
            uint128 rowToDelete = listings[auctionId].listingPointer;
            uint256 keyToMove = listingsIds[listingsIds.length - 1];
            
            listingsIds[rowToDelete] = keyToMove;
            listings[keyToMove].listingPointer = rowToDelete;
        }
        
        listingsIds.length--;
        delete listings[auctionId];
    }
    
    
    function getListings(uint256 startIndex, uint256 endIndex) external constant returns (uint256[], address[], uint256[], uint256[], uint256[], address[]) {
        uint256 numListings = (endIndex - startIndex) + 1;
        if (startIndex == 0 && endIndex == 0) {
            numListings = listingsIds.length;
        }
        uint256[] memory itemIds = new uint256[](numListings);
        address[] memory listingOwners = new address[](numListings);
        uint256[] memory listTimes = new uint256[](numListings);
        uint256[] memory prices = new uint256[](numListings);
        address[] memory listingType = new address[](numListings);
        
        for (uint256 i = startIndex; i < numListings; i++) {
            Listing memory listing = listings[listingsIds[i]];
            listingOwners[i] = listing.player;
            
            if (whitelistedItems[listing.tokenAddress]) {
                itemIds[i] = Inventory(listing.tokenAddress).tokenItems(listing.tokenId); // tokenId -> itemId
            } else {
                itemIds[i] = listing.tokenId; // Amount of tokens listed
            }
            
            listTimes[i] = listing.listTime;
            prices[i] = listing.price;
            listingType[i] = listing.tokenAddress;
        }
        return (listingsIds, listingOwners, itemIds, listTimes, prices, listingType);
    }
    
    function getListingAtPosition(uint256 i) external constant returns (address, uint256, uint256, uint256) {
        Listing memory listing = listings[listingsIds[i]];
        return (listing.player, listing.tokenId, listing.listTime, listing.price);
    }
    
    function getListing(uint64 tokenId) external constant returns (address, uint256, uint256, uint256) {
        Listing memory listing = listings[tokenId];
        return (listing.player, listing.tokenId, listing.listTime, listing.price);
    }
    
    // Contracts can't list items (avoids unbuyable listings)
    function canListItems(address seller) internal constant returns (bool) {
        uint size;
        assembly { size := extcodesize(seller) }
        return size == 0 && tx.origin == seller;
    }
    
    function extractUInt256(bytes bs) internal pure returns (uint256 payload) {
        uint256 payloadSize;
        assembly {
            payloadSize := mload(bs)
            payload := mload(add(bs, 0x20))
        }
        payload = payload >> 8*(32 - payloadSize);
        
    }

    function setPaused(bool shouldPause) external {
        require(msg.sender == owner);
        paused = shouldPause;
    }
    
    function updateERC20Settings(address token, bool allowed, uint256 newFee) external {
        require(msg.sender == owner);
        require(newFee <= 10); // Let's not get crazy
        whitelistedMaterials[token] = allowed;
        listingFees[token] = newFee;
    }
    
    function updateERC721Settings(address token, bool allowed, uint256 newFee) external {
        require(msg.sender == owner);
        require(newFee <= 10); // Let's not get crazy
        whitelistedItems[token] = allowed;
        listingFees[token] = newFee;
    }

}