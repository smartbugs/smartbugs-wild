pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https://ethergoo.io
 * 
 */

contract Forging {
    
    Clans constant clans = Clans(0xe97b5fd7056d38c85c5f6924461f7055588a53d9);
    Inventory constant inventory = Inventory(0xb545507080b0f63df02ff9bd9302c2bb2447b826);
    Material constant clothMaterial = Material(0x8a6014227138556a259e7b2bf1dce668f9bdfd06);
    Material constant woodMaterial = Material(0x6804bbb708b8af0851e2980c8a5e9abb42adb179);
    Material constant metalMaterial = Material(0xb334f68bf47c1f1c1556e7034954d389d7fbbf07);
    
    address owner;
    mapping(uint256 => Recipe) public randomRecipeList;
    mapping(uint256 => Recipe) public upgradeRecipeList;
    
    struct Recipe {
        uint256 rarityRequired; // Serves as id [0,1,2]
        uint256 clothRequired;
        uint256 woodRequired;
        uint256 metalRequired;
        
        uint256 rarityItemIdStart; // First item id for produced rarity
        uint256 rarityItemIdEnd; // Last item id for produced rarity
    }
 
    constructor() public {
        owner = msg.sender;
    }
    
    function addRandomRecipe(uint256 recipeRarity, uint256 cloth, uint256 wood, uint256 metal, uint256 producedItemIdStart, uint256 producedItemIdEnd) external {
        require(msg.sender == owner);
        randomRecipeList[recipeRarity] = Recipe(recipeRarity, cloth, wood, metal, producedItemIdStart, producedItemIdEnd);
    }
    
    function addUpgradeRecipe(uint256 recipeRarity, uint256 cloth, uint256 wood, uint256 metal) external {
        require(msg.sender == owner);
        upgradeRecipeList[recipeRarity] = Recipe(recipeRarity, cloth, wood, metal, 0, 0);
    }
    
    function forgeRandomItem(uint256 tokenIdOne, uint256 tokenIdTwo, uint256 tokenIdThree) external {
        require(inventory.tokenOwner(tokenIdOne) == msg.sender);
        require(inventory.tokenOwner(tokenIdTwo) == msg.sender);
        require(inventory.tokenOwner(tokenIdThree) == msg.sender);
        
        require(tokenIdOne != tokenIdTwo);
        require(tokenIdOne != tokenIdThree);
        
        uint256 itemId1 = inventory.tokenItems(tokenIdOne);
        uint256 itemId2 = inventory.tokenItems(tokenIdTwo);
        uint256 itemId3 = inventory.tokenItems(tokenIdThree);
        Recipe memory recipe;
        if (itemId1 == itemId2) {
            recipe = upgradeRecipeList[inventory.getItemRarity(itemId1)];
            // Check third item rarity matches
            require(inventory.getItemRarity(itemId3) == recipe.rarityRequired);
            
            // Upgrade itemId1
            inventory.mintItem(itemId1 + 200, msg.sender);
        } else if (itemId1 == itemId3) {
            recipe = upgradeRecipeList[inventory.getItemRarity(itemId1)];
            // Check third item rarity matches
            require(inventory.getItemRarity(itemId2) == recipe.rarityRequired);
            
            // Upgrade itemId1
            inventory.mintItem(itemId1 + 200, msg.sender);
        } else if (itemId2 == itemId3) {
            recipe = upgradeRecipeList[inventory.getItemRarity(itemId2)];
            // Check third item rarity matches
            require(inventory.getItemRarity(itemId1) == recipe.rarityRequired);
            
             // Upgrade itemId2
             inventory.mintItem(itemId2 + 200, msg.sender);
        } else {
            // Random forge so check three item's rarity matches
            recipe = randomRecipeList[inventory.getItemRarity(itemId1)];
            require(inventory.getItemRarity(itemId2) == recipe.rarityRequired);
            require(inventory.getItemRarity(itemId3) == recipe.rarityRequired);
            
            // Mint random item
            uint256 rng = pseudoRandom(block.timestamp + block.difficulty, block.coinbase);
            uint256 numItemsLength = (recipe.rarityItemIdEnd - recipe.rarityItemIdStart) + 1;
  
            inventory.mintItem(recipe.rarityItemIdStart + (rng % numItemsLength), msg.sender);
        }
        
        // Clan discount
        uint224 upgradeDiscount = clans.getPlayersClanUpgrade(msg.sender, 2); // class 2 = crafting discount

        // Burn materials
        if (recipe.clothRequired > 0) {
            clothMaterial.burn(recipe.clothRequired - ((recipe.clothRequired * upgradeDiscount) / 100), msg.sender);
        }
        if (recipe.woodRequired > 0) {
            woodMaterial.burn(recipe.woodRequired - ((recipe.woodRequired * upgradeDiscount) / 100), msg.sender);
        }
        if (recipe.metalRequired > 0) {
            metalMaterial.burn(recipe.metalRequired - ((recipe.metalRequired * upgradeDiscount) / 100), msg.sender);
        }
        
        // Burn items
        inventory.burn(tokenIdOne);
        inventory.burn(tokenIdTwo);
        inventory.burn(tokenIdThree);
    }
    
    function pseudoRandom(uint256 seed, address nonce) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed,  block.coinbase, nonce)));
    }
    
}

contract Clans {
    function getPlayersClanUpgrade(address player, uint256 upgradeClass) external view returns (uint224 upgradeGain);
}

contract Inventory {
    mapping(uint256 => Item) public itemList;
    mapping(uint256 => uint256) public tokenItems;
    mapping(uint256 => address) public tokenOwner;
    function totalSupply() external view returns (uint256 tokens);
    function mintItem(uint256 itemId, address player) external;
    function burn(uint256 tokenId) external;
    function getItemRarity(uint256 itemId) external view returns (uint256);
    
    struct Item {
        string name;
        uint256 itemId;
        uint256 unitId;
        uint256 rarity;
        uint256 upgradeGains;
    }
}

contract Material {
    function burn(uint256 amount, address player) public;
}