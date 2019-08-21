pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https://ethergoo.io
 * 
 */

contract Salvaging {
    
    Inventory constant inventory = Inventory(0xb545507080b0f63df02ff9bd9302c2bb2447b826);
    Crafting constant crafting = Crafting(0x29789c9abebc185f1876af10c38ee47ee0c6ed48);
    ClothMaterial constant clothMaterial = ClothMaterial(0x8a6014227138556a259e7b2bf1dce668f9bdfd06);
    WoodMaterial constant woodMaterial = WoodMaterial(0x6804bbb708b8af0851e2980c8a5e9abb42adb179);
    MetalMaterial constant metalMaterial = MetalMaterial(0xb334f68bf47c1f1c1556e7034954d389d7fbbf07);
    
    address owner;
    mapping(uint256 => Recipe) public recipeList;
    
    struct Recipe {
        uint256 itemRarity; // Serves as id [0,1,2,3]
        uint256 clothRecieved;
        uint256 woodRecieved;
        uint256 metalRecieved;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function salvageItem(uint256 tokenId) external {
        require(inventory.tokenOwner(tokenId) == msg.sender);

        uint256 itemId = inventory.tokenItems(tokenId);
        uint256 rarity = inventory.getItemRarity(itemId);
        Recipe memory recipe = recipeList[rarity];
        
        uint256 clothRecieved = recipe.clothRecieved;
        uint256 woodRecieved = recipe.woodRecieved;
        uint256 metalRecieved = recipe.metalRecieved;
        
        // Common items return 50% crafting
        if (rarity == 0) {
            (uint256 id,,uint256 clothCost, uint256 woodCost, uint256 metalCost) = crafting.recipeList(itemId);
            require(id > 0);
            clothRecieved = clothCost / 2;
            woodRecieved = woodCost / 2;
            metalRecieved = metalCost / 2;
        }
        
        // Grant materials
        if (clothRecieved > 0) {
            clothMaterial.mintCloth(clothRecieved, msg.sender);
        }
        
        if (woodRecieved > 0) {
            woodMaterial.mintWood(woodRecieved, msg.sender);
        }
        
        if (metalRecieved > 0) {
            metalMaterial.mintMetal(metalRecieved, msg.sender);
        }
        
        // Finally burn item
        inventory.burn(tokenId);
    }
    
    function addRecipe(uint256 itemRarity, uint256 cloth, uint256 wood, uint256 metal) external {
        require(msg.sender == owner);
        recipeList[itemRarity] = Recipe(itemRarity, cloth, wood, metal);
    }
    
}


contract Inventory {
    mapping(uint256 => Item) public itemList;
    mapping(uint256 => uint256) public tokenItems;
    mapping(uint256 => address) public tokenOwner;
    function getItemRarity(uint256 itemId) external view returns (uint256);
    function burn(uint256 tokenId) external;
    
    struct Item {
        uint256 itemId;
        uint256 unitId;
        uint256 rarity;
        uint32[8] upgradeGains;
    }
}

contract ClothMaterial {
    function mintCloth(uint256 amount, address player) external;
}

contract WoodMaterial {
    function mintWood(uint256 amount, address player) external;
}

contract MetalMaterial {
    function mintMetal(uint256 amount, address player) external;
}

contract Crafting {
    mapping(uint256 => Recipe) public recipeList;

    struct Recipe {
        uint256 id;
        uint256 itemId;

        uint256 clothRequired;
        uint256 woodRequired;
        uint256 metalRequired;
    }
    
}