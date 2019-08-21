library OwnershipTypes{
    using Serializer for Serializer.DataComponent;

    struct Ownership
    {
        address m_Owner; // 0
        uint32 m_OwnerInventoryIndex; // 20
    }

    function SerializeOwnership(Ownership ownership) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteAddress(0, ownership.m_Owner);
        data.WriteUint32(20, ownership.m_OwnerInventoryIndex);

        return data.m_Raw;
    }

    function DeserializeOwnership(bytes32 raw) internal pure returns (Ownership)
    {
        Ownership memory ownership;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        ownership.m_Owner = data.ReadAddress(0);
        ownership.m_OwnerInventoryIndex = data.ReadUint32(20);

        return ownership;
    }
}
library LibStructs{
    using Serializer for Serializer.DataComponent;
    // HEROES

    struct Hero {
        uint16 stockID;
        uint8 rarity;
        uint16 hp;
        uint16 atk;
        uint16 def;
        uint16 agi;
        uint16 intel;
        uint16 cHp;
        //uint8 cenas;
        // uint8 critic;
        // uint8 healbonus;
        // uint8 atackbonus;
        // uint8 defensebonus;

        uint8 isForSale;
        uint8 lvl;
        uint16 xp;
    }
    struct StockHero {uint16 price;uint8 stars;uint8 mainOnePosition;uint8 mainTwoPosition;uint16 stock;uint8 class;}

    function SerializeHero(Hero hero) internal pure returns (bytes32){
        Serializer.DataComponent memory data;
        data.WriteUint16(0, hero.stockID);
        data.WriteUint8(2, hero.rarity);
        //data.WriteUint8(2, hero.m_IsForSale);
        //data.WriteUint8(3, rocket.m_Unused3);
        data.WriteUint16(4, hero.hp);
        data.WriteUint16(6, hero.atk);
        data.WriteUint16(8, hero.def);
        data.WriteUint16(10, hero.agi);
        data.WriteUint16(12, hero.intel);
        data.WriteUint16(14, hero.cHp);

        // data.WriteUint8(16, hero.class);
        // data.WriteUint8(17, hero.healbonus);
        // data.WriteUint8(18, hero.atackbonus);
        // data.WriteUint8(19, hero.defensebonus);

        data.WriteUint8(20, hero.isForSale);
        data.WriteUint8(21, hero.lvl);
        data.WriteUint16(23, hero.xp);

        return data.m_Raw;
    }
    function DeserializeHero(bytes32 raw) internal pure returns (Hero){
        Hero memory hero;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        hero.stockID = data.ReadUint16(0);
        //hero.rarity = data.ReadUint8(1);
        hero.rarity = data.ReadUint8(2);
        //rocket.m_Unused3 = data.ReadUint8(3);
        hero.hp = data.ReadUint16(4);
        hero.atk = data.ReadUint16(6);
        hero.def = data.ReadUint16(8);
        hero.agi = data.ReadUint16(10);
        hero.intel = data.ReadUint16(12);
        hero.cHp = data.ReadUint16(14);

        // hero.class = data.ReadUint8(16);
        // hero.healbonus = data.ReadUint8(17);
        // hero.atackbonus = data.ReadUint8(18);
        // hero.defensebonus = data.ReadUint8(19);

        hero.isForSale = data.ReadUint8(20);
        hero.lvl = data.ReadUint8(21);
        hero.xp = data.ReadUint16(23);

        return hero;
    }
    function SerializeStockHero(StockHero stockhero) internal pure returns (bytes32){
        // string name;uint64 price;uint8 stars;uint8 mainOnePosition;uint8 mainTwoPosition;

        Serializer.DataComponent memory data;
        data.WriteUint16(0, stockhero.price);
        data.WriteUint8(2, stockhero.stars);
        data.WriteUint8(3, stockhero.mainOnePosition);
        data.WriteUint8(4, stockhero.mainTwoPosition);
        data.WriteUint16(5, stockhero.stock);
        data.WriteUint8(7, stockhero.class);


        return data.m_Raw;
    }
    function DeserializeStockHero(bytes32 raw) internal pure returns (StockHero){
        StockHero memory stockhero;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        stockhero.price = data.ReadUint16(0);
        stockhero.stars = data.ReadUint8(2);
        stockhero.mainOnePosition = data.ReadUint8(3);
        stockhero.mainTwoPosition = data.ReadUint8(4);
        stockhero.stock = data.ReadUint16(5);
        stockhero.class = data.ReadUint8(7);

        return stockhero;
    }
    // ITEMS
    struct Item {
        uint16 stockID;
        uint8 lvl;
        uint8 rarity;
        uint16 hp;
        uint16 atk;
        uint16 def;
        uint16 agi;
        uint16 intel;

        uint8 critic;
        uint8 healbonus;
        uint8 atackbonus;
        uint8 defensebonus;

        uint8 isForSale;
        uint8 grade;
    }
    struct StockItem {uint16 price;uint8 stars;uint8 lvl;uint8 mainOnePosition;uint8 mainTwoPosition;uint16[5] stats;uint8[4] secstats;uint8 cat;uint8 subcat;} // 1 finney = 0.0001 ether

    function SerializeItem(Item item) internal pure returns (bytes32){
        Serializer.DataComponent memory data;

        data.WriteUint16(0, item.stockID);
        data.WriteUint8(4, item.lvl);
        data.WriteUint8(5, item.rarity);
        data.WriteUint16(6, item.hp);
        data.WriteUint16(8, item.atk);
        data.WriteUint16(10, item.def);
        data.WriteUint16(12, item.agi);
        data.WriteUint16(14, item.intel);
        // data.WriteUint32(14, item.cHp);

        data.WriteUint8(16, item.critic);
        data.WriteUint8(17, item.healbonus);
        data.WriteUint8(18, item.atackbonus);
        data.WriteUint8(19, item.defensebonus);

        data.WriteUint8(20, item.isForSale);
        data.WriteUint8(21, item.grade);


        return data.m_Raw;

    }
    function DeserializeItem(bytes32 raw) internal pure returns (Item){
        Item memory item;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        item.stockID = data.ReadUint16(0);

        item.lvl = data.ReadUint8(4);
        item.rarity = data.ReadUint8(5);
        item.hp = data.ReadUint16(6);
        item.atk = data.ReadUint16(8);
        item.def = data.ReadUint16(10);
        item.agi = data.ReadUint16(12);
        item.intel = data.ReadUint16(14);

        item.critic = data.ReadUint8(16);
        item.healbonus = data.ReadUint8(17);
        item.atackbonus = data.ReadUint8(18);
        item.defensebonus = data.ReadUint8(19);

        item.isForSale = data.ReadUint8(20);
        item.grade = data.ReadUint8(21);


        return item;
    }
    function SerializeStockItem(StockItem stockitem) internal pure returns (bytes32){
        // string name;uint64 price;uint8 stars;uint8 mainOnePosition;uint8 mainTwoPosition;uint8 mainThreePosition;
        // uint16[] stats;uint8[] secstats;

        Serializer.DataComponent memory data;
        data.WriteUint16(0, stockitem.price);
        data.WriteUint8(2, stockitem.stars);
        data.WriteUint8(3, stockitem.lvl);
        data.WriteUint8(4, stockitem.mainOnePosition);
        data.WriteUint8(5, stockitem.mainTwoPosition);
        //data.WriteUint8(12, stockitem.mainThreePosition);
        //stats
        data.WriteUint16(6, stockitem.stats[0]);
        data.WriteUint16(8, stockitem.stats[1]);
        data.WriteUint16(10, stockitem.stats[2]);
        data.WriteUint16(12, stockitem.stats[3]);
        data.WriteUint16(14, stockitem.stats[4]);
        //secstats
        data.WriteUint8(16, stockitem.secstats[0]);
        data.WriteUint8(17, stockitem.secstats[1]);
        data.WriteUint8(18, stockitem.secstats[2]);
        data.WriteUint8(19, stockitem.secstats[3]);

        data.WriteUint8(20, stockitem.cat);
        data.WriteUint8(21, stockitem.subcat);


        return data.m_Raw;
    }
    function DeserializeStockItem(bytes32 raw) internal pure returns (StockItem){
        StockItem memory stockitem;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        stockitem.price = data.ReadUint16(0);
        stockitem.stars = data.ReadUint8(2);
        stockitem.lvl = data.ReadUint8(3);
        stockitem.mainOnePosition = data.ReadUint8(4);
        stockitem.mainTwoPosition = data.ReadUint8(5);
        //stockitem.mainThreePosition = data.ReadUint8(12);

        stockitem.stats[0] = data.ReadUint16(6);
        stockitem.stats[1] = data.ReadUint16(8);
        stockitem.stats[2] = data.ReadUint16(10);
        stockitem.stats[3] = data.ReadUint16(12);
        stockitem.stats[4] = data.ReadUint16(14);

        stockitem.secstats[0] = data.ReadUint8(16);
        stockitem.secstats[1] = data.ReadUint8(17);
        stockitem.secstats[2] = data.ReadUint8(18);
        stockitem.secstats[3] = data.ReadUint8(19);

        stockitem.cat = data.ReadUint8(20);
        stockitem.subcat = data.ReadUint8(21);

        return stockitem;
    }

    struct Action {uint16 actionID;uint8 actionType;uint16 finneyCost;uint32 cooldown;uint8 lvl;uint8 looted;uint8 isDaily;}
    function SerializeAction(Action action) internal pure returns (bytes32){
        Serializer.DataComponent memory data;
        data.WriteUint16(0, action.actionID);
        data.WriteUint8(2, action.actionType);
        data.WriteUint16(3, action.finneyCost);
        data.WriteUint32(5, action.cooldown);
        data.WriteUint8(9, action.lvl);
        data.WriteUint8(10, action.looted);
        data.WriteUint8(11, action.isDaily);

        return data.m_Raw;
    }
    function DeserializeAction(bytes32 raw) internal pure returns (Action){
        Action memory action;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        action.actionID = data.ReadUint16(0);
        action.actionType = data.ReadUint8(2);
        action.finneyCost = data.ReadUint16(3);
        action.cooldown = data.ReadUint32(5);
        action.lvl = data.ReadUint8(9);
        action.looted = data.ReadUint8(10);
        action.isDaily = data.ReadUint8(11);

        return action;
    }

    struct Mission {uint8 dificulty;uint16[4] stockitemId_drops;uint16[5] statsrequired;uint16 count;}
    function SerializeMission(Mission mission) internal pure returns (bytes32){
        Serializer.DataComponent memory data;
        data.WriteUint8(0, mission.dificulty);
        data.WriteUint16(1, mission.stockitemId_drops[0]);
        data.WriteUint16(5, mission.stockitemId_drops[1]);
        data.WriteUint16(9, mission.stockitemId_drops[2]);
        data.WriteUint16(13, mission.stockitemId_drops[3]);

        data.WriteUint16(15, mission.statsrequired[0]);
        data.WriteUint16(17, mission.statsrequired[1]);
        data.WriteUint16(19, mission.statsrequired[2]);
        data.WriteUint16(21, mission.statsrequired[3]);
        data.WriteUint16(23, mission.statsrequired[4]);

        data.WriteUint16(25, mission.count);

        return data.m_Raw;
    }
    function DeserializeMission(bytes32 raw) internal pure returns (Mission){
        Mission memory mission;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        mission.dificulty = data.ReadUint8(0);
        mission.stockitemId_drops[0] = data.ReadUint16(1);
        mission.stockitemId_drops[1] = data.ReadUint16(5);
        mission.stockitemId_drops[2] = data.ReadUint16(9);
        mission.stockitemId_drops[3] = data.ReadUint16(13);

        mission.statsrequired[0] = data.ReadUint16(15);
        mission.statsrequired[1] = data.ReadUint16(17);
        mission.statsrequired[2] = data.ReadUint16(19);
        mission.statsrequired[3] = data.ReadUint16(21);
        mission.statsrequired[4] = data.ReadUint16(23);

        mission.count = data.ReadUint16(25);

        return mission;
    }

    function toWei(uint80 price) public returns(uint256 value){
        value = price;
        value = value * 1 finney;

    }

}
library GlobalTypes{
    using Serializer for Serializer.DataComponent;

    struct Global
    {
        uint32 m_LastHeroId; // 0
        uint32 m_LastItem; // 4
        uint8 m_Unused8; // 8
        uint8 m_Unused9; // 9
        uint8 m_Unused10; // 10
        uint8 m_Unused11; // 11
    }

    function SerializeGlobal(Global global) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteUint32(0, global.m_LastHeroId);
        data.WriteUint32(4, global.m_LastItem);
        data.WriteUint8(8, global.m_Unused8);
        data.WriteUint8(9, global.m_Unused9);
        data.WriteUint8(10, global.m_Unused10);
        data.WriteUint8(11, global.m_Unused11);

        return data.m_Raw;
    }

    function DeserializeGlobal(bytes32 raw) internal pure returns (Global)
    {
        Global memory global;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        global.m_LastHeroId = data.ReadUint32(0);
        global.m_LastItem = data.ReadUint32(4);
        global.m_Unused8 = data.ReadUint8(8);
        global.m_Unused9 = data.ReadUint8(9);
        global.m_Unused10 = data.ReadUint8(10);
        global.m_Unused11 = data.ReadUint8(11);

        return global;
    }


}
library MarketTypes{
    using Serializer for Serializer.DataComponent;

    struct MarketListing
    {
        uint128 m_Price; // 0
    }

    function SerializeMarketListing(MarketListing listing) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteUint128(0, listing.m_Price);

        return data.m_Raw;
    }

    function DeserializeMarketListing(bytes32 raw) internal pure returns (MarketListing)
    {
        MarketListing memory listing;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        listing.m_Price = data.ReadUint128(0);

        return listing;
    }
}
library Serializer{
    struct DataComponent
    {
        bytes32 m_Raw;
    }

    function ReadUint8(DataComponent memory self, uint32 offset) internal pure returns (uint8)
    {
        return uint8((self.m_Raw >> (offset * 8)) & 0xFF);
    }

    function WriteUint8(DataComponent memory self, uint32 offset, uint8 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadUint16(DataComponent memory self, uint32 offset) internal pure returns (uint16)
    {
        return uint16((self.m_Raw >> (offset * 8)) & 0xFFFF);
    }

    function WriteUint16(DataComponent memory self, uint32 offset, uint16 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadUint32(DataComponent memory self, uint32 offset) internal pure returns (uint32)
    {
        return uint32((self.m_Raw >> (offset * 8)) & 0xFFFFFFFF);
    }

    function WriteUint32(DataComponent memory self, uint32 offset, uint32 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadUint64(DataComponent memory self, uint32 offset) internal pure returns (uint64)
    {
        return uint64((self.m_Raw >> (offset * 8)) & 0xFFFFFFFFFFFFFFFF);
    }

    function WriteUint64(DataComponent memory self, uint32 offset, uint64 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadUint80(DataComponent memory self, uint32 offset) internal pure returns (uint80)
    {
        return uint80((self.m_Raw >> (offset * 8)) & 0xFFFFFFFFFFFFFFFFFFFF);
    }

    function WriteUint80(DataComponent memory self, uint32 offset, uint80 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadUint128(DataComponent memory self, uint128 offset) internal pure returns (uint128)
    {
        return uint128((self.m_Raw >> (offset * 8)) & 0xFFFFFFFFFFFFFFFFFFFF);
    }

    function WriteUint128(DataComponent memory self, uint32 offset, uint128 value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }

    function ReadAddress(DataComponent memory self, uint32 offset) internal pure returns (address)
    {
        return address((self.m_Raw >> (offset * 8)) & (
        (0xFFFFFFFF << 0)  |
        (0xFFFFFFFF << 32) |
        (0xFFFFFFFF << 64) |
        (0xFFFFFFFF << 96) |
        (0xFFFFFFFF << 128)
        ));
    }

    function WriteAddress(DataComponent memory self, uint32 offset, address value) internal pure
    {
        self.m_Raw |= (bytes32(value) << (offset * 8));
    }
}
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
library SafeMath32 {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint32 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath16 {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint16 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath8 {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint8 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract HeroHelper
{
    address public m_Owner;
    address public m_Owner2;

    bool public m_Paused;
    AbstractDatabase m_Database= AbstractDatabase(0x095cbb73c75d4e1c62c94e0b1d4d88f8194b1941);
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;

    modifier OnlyOwner(){
        require(msg.sender == m_Owner || msg.sender == m_Owner2);
        _;
    }

    modifier onlyOwnerOf(uint _hero_id) {
        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, _hero_id));
        require(ownership.m_Owner == msg.sender);
        _;
    }

    address constant NullAddress = 0;

    uint256 constant GlobalCategory = 0;

    //Hero
    uint256 constant HeroCategory = 1;
    uint256 constant HeroStockCategory = 2;
    uint256 constant InventoryHeroCategory = 3;

    uint256 constant OwnershipHeroCategory = 10;
    uint256 constant OwnershipItemCategory = 11;
    uint256 constant OwnershipAbilitiesCategory = 12;

    //Market
    uint256 constant ProfitFundsCategory = 14;
    uint256 constant WithdrawalFundsCategory = 15;
    uint256 constant HeroMarketCategory = 16;

    //Action
    uint256 constant ActionCategory = 20;
    uint256 constant MissionCategory = 17;
    uint256 constant ActionHeroCategory = 18;

    //ReferalCategory
    uint256 constant ReferalCategory = 237;

    using Serializer for Serializer.DataComponent;

    function ChangeOwner(address new_owner) public OnlyOwner(){
        m_Owner = new_owner;
    }

    function ChangeOwner2(address new_owner) public OnlyOwner(){
        m_Owner2 = new_owner;
    }

    function ChangeDatabase(address db) public OnlyOwner(){
        m_Database = AbstractDatabase(db);
    }

    function HeroHelper() public{
        m_Owner = msg.sender;
        m_Paused = true;
    }

    function addHeroToCatalog(uint32 stock_id,uint16 _finneyCost,uint8 _stars,uint8 _mainOnePosition,uint8 _mainTwoPosition,uint16 _stock,uint8 _class) OnlyOwner() public {

        LibStructs.StockHero memory stockhero = LibStructs.StockHero( _finneyCost, _stars, _mainOnePosition, _mainTwoPosition,_stock,_class);
        m_Database.Store(NullAddress, HeroStockCategory, stock_id, LibStructs.SerializeStockHero(stockhero));

    }

    function GetHeroStockStats(uint16 stockhero_id) public view returns (uint64 price,uint8 stars,uint8 mainOnePosition,uint8 mainTwoPosition,uint16 stock,uint8 class){
        LibStructs.StockHero memory stockhero = GetHeroStock(stockhero_id);
        price = stockhero.price;
        stars = stockhero.stars;
        mainOnePosition = stockhero.mainOnePosition;
        mainTwoPosition = stockhero.mainTwoPosition;
        stock = stockhero.stock;
        class = stockhero.class;

    }
    function GetHeroStock(uint16 stockhero_id)  private view returns (LibStructs.StockHero){
        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));
        return stockhero;
    }

    function GetHeroStockPrice(uint16 stockhero_id)  public view returns (uint weiPrice){
        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));
        return stockhero.price;
    }

    function GetHeroCount(address _owner) public view returns (uint32){
        return uint32(m_Database.Load(_owner, HeroCategory, 0));
    }
    function GetHero(uint32 hero_id) public view returns(uint16[14] values){

        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));
        bytes32 base = m_Database.Load(NullAddress, ActionHeroCategory, hero_id);
        LibStructs.Action memory action = LibStructs.DeserializeAction( base );

        uint8 actStat = 0;
        uint16 minLeft = 0;
        if(uint32(base) != 0){
            if(action.cooldown > now){
                actStat = 1;
                minLeft = uint16( (action.cooldown - now).div(60 seconds));
            }
        }
        values = [hero.stockID,uint16(hero.rarity),hero.hp,hero.atk,hero.def,hero.agi,hero.intel,hero.lvl,hero.isForSale,hero.cHp,hero.xp,action.actionID,uint16(actStat),minLeft];

    }


    function GetInventoryHeroCount(address target) view public returns (uint256){
        require(target != address(0));

        uint256 inventory_count = uint256(m_Database.Load(target, InventoryHeroCategory, 0));

        return inventory_count;
    }
    function GetInventoryHero(address target, uint256 start_index) view public returns (uint32[8] hero_ids){
        require(target != address(0));

        uint256 inventory_count = GetInventoryHeroCount(target);

        uint256 end = start_index.add(8);
        if (end > inventory_count)
            end = inventory_count;

        for (uint256 i = start_index; i < end; i++)
        {
            hero_ids[i - start_index] = uint32(uint256(m_Database.Load(target, InventoryHeroCategory, i.add(1) )));
        }
    }


    function GetAuction(uint32 hero_id) view public returns (bool is_for_sale, address owner, uint128 price,uint16[14] herostats) {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));
        is_for_sale = hero.isForSale == 1;

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, hero_id));
        owner = ownership.m_Owner;

        MarketTypes.MarketListing memory listing = MarketTypes.DeserializeMarketListing(m_Database.Load(NullAddress, HeroMarketCategory, hero_id));
        price = listing.m_Price;

        herostats = GetHero(hero_id);
    }

}

contract AbstractDatabase
{
    function() public payable;
    function ChangeOwner(address new_owner) public;
    function ChangeOwner2(address new_owner) public;
    function Store(address user, uint256 category, uint256 slot, bytes32 data) public;
    function Load(address user, uint256 category, uint256 index) public view returns (bytes32);
    function TransferFunds(address target, uint256 transfer_amount) public;
    function getRandom(uint256 upper, uint8 seed) public returns (uint256 number);
    function setHeroApproval(address _to, uint256 _tokenId);
    function getHeroApproval(uint256 _tokenId) public returns(address approved);
}

contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved); // NEW

  function name() public view returns (string name);
  function symbol() constant returns (string symbol);
  function totalSupply() constant returns (uint256 totalSupply);
  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public; // NEW
  function transferFrom(address _from, address _to, uint256 _tokenId) public; // NEW
  function setApprovalForAll(address _operator, bool _approved) public; // NEW
  function getApproved(uint256 _tokenId) public view returns (address); // NEW
  function isApprovedForAll(address _owner, address _operator) public view returns (bool); // NEW
  
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
  

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);
}

contract HeroSale is ERC721 {
    address public m_Owner;
    bool public m_Paused;
    using OwnershipTypes
    for OwnershipTypes.Ownership;
    using MarketTypes
    for MarketTypes.MarketListing;
    using Serializer
    for Serializer.DataComponent;
    AbstractDatabase m_Database = AbstractDatabase(0x095cbb73c75d4e1c62c94e0b1d4d88f8194b1941);
    address public bitGuildAddress = 0x89a196a34B7820bC985B98096ED5EFc7c4DC8363;
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;
    
    mapping(address => bool) public trustedContracts;

    using SafeMath
    for uint256;
    using SafeMath32
    for uint32;
    using SafeMath16
    for uint16;
    using SafeMath8
    for uint8;

    mapping(uint => address) heroApprovals;
    mapping(address => mapping(address => bool)) internal operatorApprovals;

    modifier OnlyOwner() {
        require(msg.sender == m_Owner || trustedContracts[msg.sender]);
        _;
    }

    modifier NotWhileInSale(uint _hero_id) {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, _hero_id));
        require(hero.isForSale == 0);
        _;
    }
    modifier isApprovedOrOwnerOf(uint _hero_id) {
        address owner = ownerOf(_hero_id);
        require(msg.sender == owner || getApproved(_hero_id) == msg.sender || isApprovedForAll(owner, msg.sender));
        _;
    }

    address constant NullAddress = 0;
    uint256 constant GlobalCategory = 0;

    //Hero
    uint256 constant HeroCategory = 1;
    uint256 constant HeroStockCategory = 2;
    uint256 constant InventoryHeroCategory = 3;


    uint256 constant OwnershipHeroCategory = 10;
    uint256 constant OwnershipItemCategory = 11;
    uint256 constant OwnershipAbilitiesCategory = 12;

    //Market
    uint256 constant ProfitFundsCategory = 14;
    uint256 constant WithdrawalFundsCategory = 15;
    uint256 constant HeroMarketCategory = 16;

    function HeroSale() public {
        m_Owner = msg.sender;
    }

    function ChangeAddressTrust(address contract_address, bool trust_flag) public OnlyOwner() {
        trustedContracts[contract_address] = trust_flag;
    }

    function name() public view returns(string name) {
        return "CryptoDungeonsHero";
    }

    function symbol() public view returns(string symbol) {
        return "CDH";
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string){
        return appendUintToString("https://cryptodungeons.io/api/hero/", _tokenId);
    }
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
       return uint256(m_Database.Load(_owner, InventoryHeroCategory, _index ));
    }

    function totalSupply() public view returns(uint) {
        GlobalTypes.Global memory global = GlobalTypes.DeserializeGlobal(m_Database.Load(NullAddress, 0, 0));

        return global.m_LastHeroId;
    }

    function balanceOf(address _owner) public view returns(uint256 _balance) {
        return GetHeroCount(_owner);
    }

    function ownerOf(uint256 _tokenId) public view returns(address _owner) {
        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, _tokenId));
        return ownership.m_Owner;
    }

    function approve(address _spender, uint256 _tokenId) public isApprovedOrOwnerOf(_tokenId) NotWhileInSale(_tokenId) {
        heroApprovals[_tokenId] = _spender;
        Approval(msg.sender, _spender, _tokenId);
    }

    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        ApprovalForAll(msg.sender, _to, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns(address) {
        return heroApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns(bool) {
        return operatorApprovals[_owner][_operator];
    }


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public isApprovedOrOwnerOf(_tokenId) {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));

    }

    function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns(bool) {
        if (!isContract(_to)) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

    function isContract(address addr) internal view returns(bool) {
        uint256 size;
        assembly {
            size: = extcodesize(addr)
        }
        return size > 0;
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) public isApprovedOrOwnerOf(_tokenId) {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, _tokenId));
        require(hero.isForSale == 0);
        require(_to != address(0));

        _transfer(_from, _to, _tokenId);
    }

    // function forceTransfer(address _from, address _to, uint256 _tokenId) public OnlyOwner() {
    //     _transfer(_from, _to, _tokenId);
    // }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, _tokenId));


        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, _tokenId));
        require(_from != _to);

        uint256 seller_inventory_count = uint256(m_Database.Load(_from, InventoryHeroCategory, 0));
        uint256 buyer_inventory_count = uint256(m_Database.Load(_to, InventoryHeroCategory, 0));

        uint256 profit_funds_or_last_rocket_id;
        uint256 wei_for_profit_funds;

        address seller = _from;
        ownership.m_Owner = _to;
        hero.isForSale = 0;


        buyer_inventory_count = buyer_inventory_count.add(1);
        profit_funds_or_last_rocket_id = uint256(m_Database.Load(seller, InventoryHeroCategory, seller_inventory_count));

        m_Database.Store(seller, InventoryHeroCategory, seller_inventory_count, bytes32(0)); // na posiçao zero colocamos o novo numero de items que o comprador tem

        if (ownership.m_OwnerInventoryIndex.add(1) != seller_inventory_count) //se for diferente do ultimo temos de ordenar
        {

            m_Database.Store(seller, InventoryHeroCategory, ownership.m_OwnerInventoryIndex.add(1), bytes32(profit_funds_or_last_rocket_id)); // coloca na posiçao do hero vendido o ultimo hero do array

            OwnershipTypes.Ownership memory last_item_ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, profit_funds_or_last_rocket_id));
            last_item_ownership.m_OwnerInventoryIndex = uint32(ownership.m_OwnerInventoryIndex);

            m_Database.Store(NullAddress, OwnershipHeroCategory, profit_funds_or_last_rocket_id, OwnershipTypes.SerializeOwnership(last_item_ownership)); // actualiza no ownership a posiçao nova em que ficou este hero
        }

        ownership.m_OwnerInventoryIndex = uint32(buyer_inventory_count).sub(1);
        m_Database.Store(_to, InventoryHeroCategory, buyer_inventory_count, bytes32(_tokenId));

        seller_inventory_count = seller_inventory_count.sub(1);
        m_Database.Store(_to, InventoryHeroCategory, 0, bytes32(buyer_inventory_count));
        m_Database.Store(seller, InventoryHeroCategory, 0, bytes32(seller_inventory_count));

        m_Database.Store(NullAddress, OwnershipHeroCategory, _tokenId, OwnershipTypes.SerializeOwnership(ownership));
        m_Database.Store(NullAddress, HeroCategory, _tokenId, LibStructs.SerializeHero(hero));

        Transfer(_from, _to, _tokenId);
    }



    function takeOwnership(uint256 _tokenId) public {
        require(heroApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    function GetHeroCount(address _owner) public view returns(uint32) {
        return uint32(m_Database.Load(_owner, InventoryHeroCategory, 0));
    }

    // SALES
    event PlaceHeroForSaleEvent(address indexed seller, uint32 hero_id, uint80 price);

    function PlaceHeroForSale(uint32 hero_id, uint80 price) public isApprovedOrOwnerOf(hero_id) {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        require(hero.isForSale == 0);

        MarketTypes.MarketListing memory listing;
        listing.m_Price = price;

        hero.isForSale = 1;

        m_Database.Store(NullAddress, HeroCategory, hero_id, LibStructs.SerializeHero(hero));
        m_Database.Store(NullAddress, HeroMarketCategory, hero_id, MarketTypes.SerializeMarketListing(listing));

        PlaceHeroForSaleEvent(msg.sender, hero_id, price);
    }

    event RemoveHeroForSaleEvent(address indexed seller, uint32 rocket_id);

    function RemoveHeroForSale(uint32 hero_id) public isApprovedOrOwnerOf(hero_id) {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));
        require(hero.isForSale == 1);

        hero.isForSale = 0;

        m_Database.Store(NullAddress, HeroCategory, hero_id, LibStructs.SerializeHero(hero));

        RemoveHeroForSaleEvent(msg.sender, hero_id);
    }

    event showValues(uint256 _value, uint256 _price, uint256 _stock, uint256 hero_id);
    event BuyHeroForSaleEvent(address indexed buyer, address indexed seller, uint32 hero_id);

    function BuyHeroForSale(uint32 hero_id) payable public {
        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));
        require(hero.isForSale == 1);

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, hero_id));
        require(ownership.m_Owner != msg.sender);

        MarketTypes.MarketListing memory listing = MarketTypes.DeserializeMarketListing(m_Database.Load(NullAddress, HeroMarketCategory, hero_id));

        require(msg.value == listing.m_Price);

        uint256 profit_funds_or_last_rocket_id;
        uint256 wei_for_profit_funds;
        uint256 buyer_price_or_wei_for_seller = msg.value;

        address beneficiary = ownership.m_Owner;
        ownership.m_Owner = msg.sender;
        hero.isForSale = 0;

        _transfer(beneficiary, msg.sender, hero_id);

        listing.m_Price = 0;

        wei_for_profit_funds = msg.value.div(20);//5%
        buyer_price_or_wei_for_seller = buyer_price_or_wei_for_seller.sub(wei_for_profit_funds);

        m_Database.Store(NullAddress, HeroCategory, hero_id, LibStructs.SerializeHero(hero));
        m_Database.Store(NullAddress, HeroMarketCategory, hero_id, MarketTypes.SerializeMarketListing(listing));

        buyer_price_or_wei_for_seller = buyer_price_or_wei_for_seller.add(uint256(m_Database.Load(beneficiary, WithdrawalFundsCategory, 0))); // Reuse variable
        m_Database.Store(beneficiary, WithdrawalFundsCategory, 0, bytes32(buyer_price_or_wei_for_seller));

        managePayment(wei_for_profit_funds);
        BuyHeroForSaleEvent(msg.sender, beneficiary, hero_id);
    }


    function managePayment(uint256 _value) internal {

        uint256 profit_funds = uint256(m_Database.Load(bitGuildAddress, WithdrawalFundsCategory, 0));
        profit_funds = profit_funds.add(_value.div(10).mul(3)); //30%
        m_Database.Store(bitGuildAddress, WithdrawalFundsCategory, 0, bytes32(profit_funds));

        profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));
        profit_funds = profit_funds.add(_value.div(10).mul(7)); //70%
        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds));
        m_Database.transfer(msg.value);

    }
    
    function appendUintToString(string inStr, uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }

}