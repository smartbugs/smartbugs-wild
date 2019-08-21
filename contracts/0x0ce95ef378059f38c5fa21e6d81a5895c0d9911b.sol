pragma solidity ^0.4.13;

contract AbstractDatabase
{
    function() public payable;
    function ChangeOwner(address new_owner) public;
    function ChangeOwner2(address new_owner) public;
    function Store(address user, uint256 category, uint256 slot, bytes32 data) public;
    function Load(address user, uint256 category, uint256 index) public view returns (bytes32);
    function TransferFunds(address target, uint256 transfer_amount) public;
}

contract AbstractGameHidden
{
    function CalculateFinalDistance(bytes32 raw0, bytes32 raw1, bytes32 raw2, bytes32 raw3) pure public returns (int64, int64, uint64);
}

library CompetitionScoreTypes
{
    using Serializer for Serializer.DataComponent;

    struct CompetitionScore
    {
        address m_Owner; // 0
        uint64 m_Distance; // 20
        uint32 m_RocketId; // 28
    }

    function SerializeCompetitionScore(CompetitionScore score) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteAddress(0, score.m_Owner);
        data.WriteUint64(20, score.m_Distance);
        data.WriteUint32(28, score.m_RocketId);
        return data.m_Raw;
    }

    function DeserializeCompetitionScore(bytes32 raw) internal pure returns (CompetitionScore)
    {
        CompetitionScore memory score;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        score.m_Owner = data.ReadAddress(0);
        score.m_Distance = data.ReadUint64(20);
        score.m_RocketId = data.ReadUint32(28);

        return score;
    }
}

contract Game
{
    using GlobalTypes for GlobalTypes.Global;
    using MarketTypes for MarketTypes.MarketListing;
    using MissionParametersTypes for MissionParametersTypes.MissionParameters;
    using GameCommon for GameCommon.LaunchRocketStackFrame;

    address public m_Owner;
    AbstractDatabase public m_Database;
    AbstractGameHidden public m_GameHidden;
    bool public m_Paused;

    uint256 constant GlobalCategory = 0;
    uint256 constant RocketCategory = 1;
    uint256 constant OwnershipCategory = 2;
    uint256 constant InventoryCategory = 3;
    uint256 constant MarketCategory = 4;
    uint256 constant ProfitFundsCategory = 5;
    uint256 constant CompetitionFundsCategory = 6;
    uint256 constant MissionParametersCategory = 7;
    uint256 constant CompetitionScoresCategory = 8;
    uint256 constant WithdrawalFundsCategory = 9;
    uint256 constant ReferralCategory = 10;
    uint256 constant RocketStockCategory = 11;
    uint256 constant RocketStockInitializedCategory = 12;

    address constant NullAddress = 0;
    uint256 constant MaxCompetitionScores = 10;

    mapping(uint32 => RocketTypes.StockRocket) m_InitialRockets;

    modifier OnlyOwner()
    {
        require(msg.sender == m_Owner);

        _;
    }

    modifier NotWhilePaused()
    {
        require(m_Paused == false);

        _;
    }

    function Game() public
    {
        m_Owner = msg.sender;
        m_Paused = true;
    }

    event BuyStockRocketEvent(address indexed buyer, uint32 stock_id, uint32 rocket_id, address referrer);
    event PlaceRocketForSaleEvent(address indexed seller, uint32 rocket_id, uint80 price);
    event RemoveRocketForSaleEvent(address indexed seller, uint32 rocket_id);
    event BuyRocketForSaleEvent(address indexed buyer, address indexed seller, uint32 rocket_id);
    event LaunchRocketEvent(address indexed launcher, uint32 competition_id, int64 leo_displacement, int64 planet_displacement);
    event StartCompetitionEvent(uint32 competition_id);
    event FinishCompetitionEvent(uint32 competition_id);

    function ChangeOwner(address new_owner) public OnlyOwner()
    {
        m_Owner = new_owner;
    }

    function ChangeDatabase(address db) public OnlyOwner()
    {
        m_Database = AbstractDatabase(db);
    }

    function ChangeGameHidden(address hidden) public OnlyOwner()
    {
        m_GameHidden = AbstractGameHidden(hidden);
    }

    function Unpause() public OnlyOwner()
    {
        m_Paused = false;
    }

    function Pause() public OnlyOwner()
    {
        require(m_Paused == false);

        m_Paused = true;
    }

    function IsPaused() public view returns (bool)
    {
        return m_Paused;
    }

    // 1 write
    function WithdrawProfitFunds(uint256 withdraw_amount, address beneficiary) public NotWhilePaused() OnlyOwner()
    {
        uint256 profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));

        require(withdraw_amount > 0);
        require(withdraw_amount <= profit_funds);
        require(beneficiary != address(0));
        require(beneficiary != address(this));
        require(beneficiary != address(m_Database));

        profit_funds -= withdraw_amount;

        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds));

        m_Database.TransferFunds(beneficiary, withdraw_amount);
    }

    // 1 write
    function WithdrawWinnings(uint256 withdraw_amount) public NotWhilePaused()
    {
        require(withdraw_amount > 0);

        uint256 withdrawal_funds = uint256(m_Database.Load(msg.sender, WithdrawalFundsCategory, 0));
        require(withdraw_amount <= withdrawal_funds);

        withdrawal_funds -= withdraw_amount;

        m_Database.Store(msg.sender, WithdrawalFundsCategory, 0, bytes32(withdrawal_funds));

        m_Database.TransferFunds(msg.sender, withdraw_amount);
    }

    function GetRocket(uint32 rocket_id) view public returns (bool is_valid, uint32 top_speed, uint32 thrust, uint32 weight, uint32 fuel_capacity, uint16 stock_id, uint64 max_distance, bool is_for_sale, address owner)
    {
        RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));

        is_valid = rocket.m_Version >= 1;
        is_for_sale = rocket.m_IsForSale == 1;
        top_speed = rocket.m_TopSpeed;
        thrust = rocket.m_Thrust;
        weight = rocket.m_Weight;
        fuel_capacity = rocket.m_FuelCapacity;
        stock_id = rocket.m_StockId;
        max_distance = rocket.m_MaxDistance;

        owner = GetRocketOwner(rocket_id);
    }

    function GetWithdrawalFunds(address target) view public NotWhilePaused() returns (uint256 funds)
    {
        funds = uint256(m_Database.Load(target, WithdrawalFundsCategory, 0));
    }

    function GetProfitFunds() view public OnlyOwner() returns (uint256 funds)
    {
        uint256 profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));
        return profit_funds;
    }

    function GetCompetitionFunds(uint32 competition_id) view public returns (uint256 funds)
    {
        return uint256(m_Database.Load(NullAddress, CompetitionFundsCategory, competition_id));
    }

    function GetRocketOwner(uint32 rocket_id) view internal returns (address owner)
    {
        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));
        owner = ownership.m_Owner;
    }

    function GetAuction(uint32 rocket_id) view public returns (bool is_for_sale, address owner, uint80 price)
    {
        RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));
        is_for_sale = rocket.m_IsForSale == 1;

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));
        owner = ownership.m_Owner;

        MarketTypes.MarketListing memory listing = MarketTypes.DeserializeMarketListing(m_Database.Load(NullAddress, MarketCategory, rocket_id));
        price = listing.m_Price;
    }

    function GetInventoryCount(address target) view public returns (uint256)
    {
        require(target != address(0));

        uint256 inventory_count = uint256(m_Database.Load(target, InventoryCategory, 0));

        return inventory_count;
    }

    function GetInventory(address target, uint256 start_index) view public returns (uint32[8] rocket_ids)
    {
        require(target != address(0));

        uint256 inventory_count = GetInventoryCount(target);

        uint256 end = start_index + 8;
        if (end > inventory_count)
            end = inventory_count;

        for (uint256 i = start_index; i < end; i++)
        {
            rocket_ids[i - start_index] = uint32(uint256(m_Database.Load(target, InventoryCategory, i + 1)));
        }
    }

    // 1 write
    function AddRocket(uint32 stock_id, uint64 cost, uint32 min_top_speed, uint32 max_top_speed, uint32 min_thrust, uint32 max_thrust, uint32 min_weight, uint32 max_weight, uint32 min_fuel_capacity, uint32 max_fuel_capacity, uint64 distance, uint32 max_stock) OnlyOwner() public
    {
        m_InitialRockets[stock_id] = RocketTypes.StockRocket({
            m_IsValid: true,
            m_Cost: cost,
            m_MinTopSpeed: min_top_speed,
            m_MaxTopSpeed: max_top_speed,
            m_MinThrust: min_thrust,
            m_MaxThrust: max_thrust,
            m_MinWeight: min_weight,
            m_MaxWeight: max_weight,
            m_MinFuelCapacity: min_fuel_capacity,
            m_MaxFuelCapacity: max_fuel_capacity,
            m_Distance: distance
        });

        min_top_speed = uint32(m_Database.Load(NullAddress, RocketStockInitializedCategory, stock_id));

        if (min_top_speed == 0)
        {
            m_Database.Store(NullAddress, RocketStockCategory, stock_id, bytes32(max_stock));
            m_Database.Store(NullAddress, RocketStockInitializedCategory, stock_id, bytes32(1));
        }
    }

    function GetRocketStock(uint16 stock_id) public view returns (uint32)
    {
        return uint32(m_Database.Load(NullAddress, RocketStockCategory, stock_id));
    }

    // 6 writes
    function BuyStockRocket(uint16 stock_id, address referrer) payable NotWhilePaused() public
    {
        //require(referrer != msg.sender);
        uint32 stock = GetRocketStock(stock_id);

        require(stock > 0);

        GiveRocketInternal(stock_id, msg.sender, true, referrer);

        stock--;

        m_Database.Store(NullAddress, RocketStockCategory, stock_id, bytes32(stock));
    }

    function GiveReferralRocket(uint16 stock_id, address target) public NotWhilePaused() OnlyOwner()
    {
        uint256 already_received = uint256(m_Database.Load(target, ReferralCategory, 0));
        require(already_received == 0);

        already_received = 1;
        m_Database.Store(target, ReferralCategory, 0, bytes32(already_received));

        GiveRocketInternal(stock_id, target, false, address(0));
    }

    function GiveRocketInternal(uint16 stock_id, address target, bool buying, address referrer) internal
    {
        RocketTypes.StockRocket storage stock_rocket = m_InitialRockets[stock_id];

        require(stock_rocket.m_IsValid);
        if (buying)
        {
            require(msg.value == stock_rocket.m_Cost);
        }

        GlobalTypes.Global memory global = GlobalTypes.DeserializeGlobal(m_Database.Load(NullAddress, GlobalCategory, 0));

        uint256 profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));

        global.m_LastRocketId++;
        uint32 next_rocket_id = global.m_LastRocketId;

        uint256 inventory_count = GetInventoryCount(target);
        inventory_count++;

        RocketTypes.Rocket memory rocket;
        rocket.m_Version = 1;
        rocket.m_StockId = stock_id;
        rocket.m_IsForSale = 0;

        bytes32 rand = sha256(block.timestamp, block.coinbase, global.m_LastRocketId);

        // Fix LerpExtra calls in FinishCompetition if anything is added here
        rocket.m_TopSpeed = uint32(Lerp(stock_rocket.m_MinTopSpeed, stock_rocket.m_MaxTopSpeed, rand[0]));
        rocket.m_Thrust = uint32(Lerp(stock_rocket.m_MinThrust, stock_rocket.m_MaxThrust, rand[1]));
        rocket.m_Weight = uint32(Lerp(stock_rocket.m_MinWeight, stock_rocket.m_MaxWeight, rand[2]));
        rocket.m_FuelCapacity = uint32(Lerp(stock_rocket.m_MinFuelCapacity, stock_rocket.m_MaxFuelCapacity, rand[3]));
        rocket.m_MaxDistance = uint64(stock_rocket.m_Distance);
        //

        OwnershipTypes.Ownership memory ownership;
        ownership.m_Owner = target;
        ownership.m_OwnerInventoryIndex = uint32(inventory_count) - 1;

        profit_funds += msg.value;

        m_Database.Store(target, InventoryCategory, inventory_count, bytes32(next_rocket_id));
        m_Database.Store(target, InventoryCategory, 0, bytes32(inventory_count));
        m_Database.Store(NullAddress, RocketCategory, next_rocket_id, RocketTypes.SerializeRocket(rocket));
        m_Database.Store(NullAddress, OwnershipCategory, next_rocket_id, OwnershipTypes.SerializeOwnership(ownership));
        m_Database.Store(NullAddress, GlobalCategory, 0, GlobalTypes.SerializeGlobal(global));
        if (buying)
        {
            m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds));

            m_Database.transfer(msg.value);
        }
        BuyStockRocketEvent(target, stock_id, next_rocket_id, referrer);
    }

    // 2 writes
    function PlaceRocketForSale(uint32 rocket_id, uint80 price) NotWhilePaused() public
    {
        RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));
        require(rocket.m_Version > 0);

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));
        require(ownership.m_Owner == msg.sender);

        require(rocket.m_IsForSale == 0);

        MarketTypes.MarketListing memory listing;
        listing.m_Price = price;

        rocket.m_IsForSale = 1;

        m_Database.Store(NullAddress, RocketCategory, rocket_id, RocketTypes.SerializeRocket(rocket));
        m_Database.Store(NullAddress, MarketCategory, rocket_id, MarketTypes.SerializeMarketListing(listing));

        PlaceRocketForSaleEvent(msg.sender, rocket_id, price);
    }

    // 1 write
    function RemoveRocketForSale(uint32 rocket_id) NotWhilePaused() public
    {
        RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));
        require(rocket.m_Version > 0);
        require(rocket.m_IsForSale == 1);

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));
        require(ownership.m_Owner == msg.sender);

        rocket.m_IsForSale = 0;

        m_Database.Store(NullAddress, RocketCategory, rocket_id, RocketTypes.SerializeRocket(rocket));

        RemoveRocketForSaleEvent(msg.sender, rocket_id);
    }

    // 9-11 writes
    function BuyRocketForSale(uint32 rocket_id) payable NotWhilePaused() public
    {
        RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));
        require(rocket.m_Version > 0);

        require(rocket.m_IsForSale == 1);

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));
        require(ownership.m_Owner != msg.sender);

        MarketTypes.MarketListing memory listing = MarketTypes.DeserializeMarketListing(m_Database.Load(NullAddress, MarketCategory, rocket_id));
        require(msg.value == listing.m_Price);

        uint256 seller_inventory_count = uint256(m_Database.Load(ownership.m_Owner, InventoryCategory, 0));
        uint256 buyer_inventory_count = uint256(m_Database.Load(msg.sender, InventoryCategory, 0));

        uint256 profit_funds_or_last_rocket_id;
        uint256 wei_for_profit_funds;
        uint256 buyer_price_or_wei_for_seller = uint256(listing.m_Price);

        address beneficiary = ownership.m_Owner;
        ownership.m_Owner = msg.sender;
        rocket.m_IsForSale = 0;

        listing.m_Price = 0;

        buyer_inventory_count++;
        profit_funds_or_last_rocket_id = uint256(m_Database.Load(beneficiary, InventoryCategory, seller_inventory_count));

        m_Database.Store(beneficiary, InventoryCategory, seller_inventory_count, bytes32(0));

        if (ownership.m_OwnerInventoryIndex + 1 != seller_inventory_count)
        {
            m_Database.Store(beneficiary, InventoryCategory, ownership.m_OwnerInventoryIndex + 1, bytes32(profit_funds_or_last_rocket_id));

            OwnershipTypes.Ownership memory last_rocket_ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, profit_funds_or_last_rocket_id));
            last_rocket_ownership.m_OwnerInventoryIndex = uint32(ownership.m_OwnerInventoryIndex);

            m_Database.Store(NullAddress, OwnershipCategory, profit_funds_or_last_rocket_id, OwnershipTypes.SerializeOwnership(last_rocket_ownership));
        }

        ownership.m_OwnerInventoryIndex = uint32(buyer_inventory_count);
        m_Database.Store(msg.sender, InventoryCategory, buyer_inventory_count, bytes32(rocket_id));

        wei_for_profit_funds = buyer_price_or_wei_for_seller / 20;
        buyer_price_or_wei_for_seller = buyer_price_or_wei_for_seller - wei_for_profit_funds;

        profit_funds_or_last_rocket_id = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));
        profit_funds_or_last_rocket_id += wei_for_profit_funds;

        seller_inventory_count--;
        m_Database.Store(msg.sender, InventoryCategory, 0, bytes32(buyer_inventory_count));
        m_Database.Store(beneficiary, InventoryCategory, 0, bytes32(seller_inventory_count));

        m_Database.Store(NullAddress, OwnershipCategory, rocket_id, OwnershipTypes.SerializeOwnership(ownership));
        m_Database.Store(NullAddress, RocketCategory, rocket_id, RocketTypes.SerializeRocket(rocket));
        m_Database.Store(NullAddress, MarketCategory, rocket_id, MarketTypes.SerializeMarketListing(listing));
        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds_or_last_rocket_id));

        buyer_price_or_wei_for_seller += uint256(m_Database.Load(beneficiary, WithdrawalFundsCategory, 0)); // Reuse variable
        m_Database.Store(beneficiary, WithdrawalFundsCategory, 0, bytes32(buyer_price_or_wei_for_seller));

        m_Database.transfer(msg.value);
        BuyRocketForSaleEvent(msg.sender, beneficiary, rocket_id);
    }

    // 3 writes + 1-12 writes = 4-15 writes
    function LaunchRocket(uint32 competition_id, uint32 rocket_id, uint32 launch_thrust, uint32 fuel_to_use, uint32 fuel_allocation_for_launch, uint32 stabilizer_setting) payable NotWhilePaused() public
    {
        GameCommon.LaunchRocketStackFrame memory stack;
        stack.m_Rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, rocket_id));
        stack.m_Mission =  MissionParametersTypes.DeserializeMissionParameters(m_Database.Load(NullAddress, MissionParametersCategory, competition_id));
        stack.m_Ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipCategory, rocket_id));

        require(stack.m_Mission.m_IsStarted == 1);
        require(stack.m_Rocket.m_Version > 0);
        require(stack.m_Rocket.m_IsForSale == 0);
        require(msg.value == uint256(stack.m_Mission.m_LaunchCost));
        require(stack.m_Ownership.m_Owner == msg.sender);
        require(launch_thrust <= stack.m_Rocket.m_Thrust);

        stack.m_MissionWindSpeed = stack.m_Mission.m_WindSpeed;
        stack.m_MissionLaunchLocation = stack.m_Mission.m_LaunchLocation;
        stack.m_MissionWeatherType = stack.m_Mission.m_WeatherType;
        stack.m_MissionWeatherCoverage = stack.m_Mission.m_WeatherCoverage;
        stack.m_MissionTargetDistance = stack.m_Mission.m_TargetDistance;
        stack.m_DebugExtraDistance = stack.m_Mission.m_DebugExtraDistance;

        stack.m_RocketTopSpeed = stack.m_Rocket.m_TopSpeed;
        stack.m_RocketThrust = stack.m_Rocket.m_Thrust;
        stack.m_RocketMass = stack.m_Rocket.m_Weight;
        stack.m_RocketFuelCapacity = stack.m_Rocket.m_FuelCapacity;
        stack.m_RocketMaxDistance = int64(stack.m_Rocket.m_MaxDistance);

        stack.m_CompetitionId = competition_id;
        stack.m_RocketId = rocket_id;
        stack.m_LaunchThrust = launch_thrust * 100 / stack.m_Rocket.m_Thrust;
        stack.m_FuelToUse = fuel_to_use;
        stack.m_FuelAllocationForLaunch = fuel_allocation_for_launch;
        stack.m_StabilizerSetting = stabilizer_setting;
        stack.m_Launcher = msg.sender;

        LaunchRocketInternal(stack);
    }

    // 3 writes
    function LaunchRocketInternal(GameCommon.LaunchRocketStackFrame memory stack) internal
    {
        stack.SerializeLaunchRocketStackFrame();

        (stack.m_DisplacementFromLowEarthOrbit, stack.m_DisplacementFromPlanet, stack.m_FinalDistance) = m_GameHidden.CalculateFinalDistance(
            stack.m_Raw0,
            stack.m_Raw1,
            stack.m_Raw2,
            stack.m_Raw3
        );

        AddScore(stack);

        stack.m_ProfitFunds = msg.value / 10;
        stack.m_CompetitionFunds = msg.value - stack.m_ProfitFunds;

        stack.m_ProfitFunds += uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));
        stack.m_CompetitionFunds += uint256(m_Database.Load(NullAddress, CompetitionFundsCategory, stack.m_CompetitionId));

        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(stack.m_ProfitFunds));
        m_Database.Store(NullAddress, CompetitionFundsCategory, stack.m_CompetitionId, bytes32(stack.m_CompetitionFunds));
        m_Database.Store(NullAddress, MissionParametersCategory, stack.m_CompetitionId, stack.m_Mission.SerializeMissionParameters());

        m_Database.transfer(msg.value);
        LaunchRocketEvent(msg.sender, stack.m_CompetitionId, stack.m_DisplacementFromLowEarthOrbit, stack.m_DisplacementFromPlanet);
    }

    // 0-1 writes
    function AddScore(GameCommon.LaunchRocketStackFrame memory stack) internal
    {
        CompetitionScoreTypes.CompetitionScore memory new_score;
        new_score.m_Owner = stack.m_Launcher;
        new_score.m_Distance = stack.m_FinalDistance;
        new_score.m_RocketId = stack.m_RocketId;

        CompetitionScoreTypes.CompetitionScore memory score;

        for (uint32 i = 0; i < stack.m_Mission.m_ValidCompetitionScores; i++)
        {
            // Check if the new score is better than the score that this user already has (if they are in the top x)
            score = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(stack.m_CompetitionId, CompetitionScoresCategory, i));

            if (score.m_Owner == stack.m_Launcher)
            {
                if (stack.m_FinalDistance < score.m_Distance)
                {
                    m_Database.Store(stack.m_CompetitionId, CompetitionScoresCategory, i, CompetitionScoreTypes.SerializeCompetitionScore(new_score));
                }
                return;
            }
        }

        if (stack.m_Mission.m_ValidCompetitionScores < MaxCompetitionScores)
        {
            // Not enough scores, so this one is automatically one of the best
            m_Database.Store(stack.m_CompetitionId, CompetitionScoresCategory, stack.m_Mission.m_ValidCompetitionScores, CompetitionScoreTypes.SerializeCompetitionScore(new_score));

            stack.m_Mission.m_ValidCompetitionScores++;
            return;
        }

        uint64 highest_distance = 0;
        uint32 highest_index = 0xFFFFFFFF;
        for (i = 0; i < stack.m_Mission.m_ValidCompetitionScores; i++)
        {
            score = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(stack.m_CompetitionId, CompetitionScoresCategory, i));

            if (score.m_Distance > highest_distance)
            {
                highest_distance = score.m_Distance;
                highest_index = i;
            }
        }

        if (highest_index != 0xFFFFFFFF)
        {
            score = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(stack.m_CompetitionId, CompetitionScoresCategory, highest_index));

            // Check if the new score is better than the highest score
            if (stack.m_FinalDistance < score.m_Distance)
            {
                m_Database.Store(stack.m_CompetitionId, CompetitionScoresCategory, highest_index, CompetitionScoreTypes.SerializeCompetitionScore(new_score));
                return;
            }
        }
    }

    function GetCompetitionInfo(uint32 competition_id) view NotWhilePaused() public returns (bool in_progress, uint8 wind_speed, uint8 launch_location, uint8 weather_type, uint8 weather_coverage, uint80 launch_cost, uint32 target_distance)
    {
        MissionParametersTypes.MissionParameters memory parameters = MissionParametersTypes.DeserializeMissionParameters(m_Database.Load(NullAddress, MissionParametersCategory, competition_id));

        in_progress = parameters.m_IsStarted == 1;
        wind_speed = parameters.m_WindSpeed;
        launch_location = parameters.m_LaunchLocation;
        weather_type = parameters.m_WeatherType;
        weather_coverage = parameters.m_WeatherCoverage;
        launch_cost = parameters.m_LaunchCost;
        target_distance = parameters.m_TargetDistance;
    }

    function SetDebugExtra(uint32 competition_id, uint8 extra) public OnlyOwner()
    {
        MissionParametersTypes.MissionParameters memory parameters = MissionParametersTypes.DeserializeMissionParameters(m_Database.Load(NullAddress, MissionParametersCategory, competition_id));

        parameters.m_DebugExtraDistance = extra;

        m_Database.Store(NullAddress, MissionParametersCategory, competition_id, parameters.SerializeMissionParameters());
    }

    // 2 writes
    function StartCompetition(uint8 wind_speed, uint8 launch_location, uint8 weather_type, uint8 weather_coverage, uint80 launch_cost, uint32 target_distance) public NotWhilePaused() OnlyOwner()
    {
        GlobalTypes.Global memory global = GlobalTypes.DeserializeGlobal(m_Database.Load(NullAddress, GlobalCategory, 0));

        MissionParametersTypes.MissionParameters memory parameters;
        parameters.m_WindSpeed = wind_speed;
        parameters.m_LaunchLocation = launch_location;
        parameters.m_WeatherType = weather_type;
        parameters.m_WeatherCoverage = weather_coverage;
        parameters.m_LaunchCost = launch_cost;
        parameters.m_TargetDistance = target_distance;
        parameters.m_IsStarted = 1;

        global.m_CompetitionNumber++;

        uint32 competition_id = global.m_CompetitionNumber;

        m_Database.Store(NullAddress, MissionParametersCategory, competition_id, parameters.SerializeMissionParameters());
        m_Database.Store(NullAddress, GlobalCategory, 0, GlobalTypes.SerializeGlobal(global));

        StartCompetitionEvent(competition_id);
    }

    function GetCompetitionResults(uint32 competition_id, bool first_half) public view returns (address[], uint64[])
    {
        CompetitionScoreTypes.CompetitionScore memory score;

        uint256 offset = (first_half == true ? 0 : 5);
        address[] memory winners = new address[](5);
        uint64[] memory distances = new uint64[](5);

        for (uint32 i = 0; i < 5; i++)
        {
            score = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(competition_id, CompetitionScoresCategory, offset + i));
            winners[i] = score.m_Owner;
            distances[i] = score.m_Distance;
        }

        return (winners, distances);
    }

    function SortCompetitionScores(uint32 competition_id) public NotWhilePaused() OnlyOwner()
    {
        CompetitionScoreTypes.CompetitionScore[] memory scores;
        MissionParametersTypes.MissionParameters memory parameters;

        (scores, parameters) = MakeAndSortCompetitionScores(competition_id);

        for (uint256 i = 0; i < parameters.m_ValidCompetitionScores; i++)
        {
            m_Database.Store(competition_id, CompetitionScoresCategory, i, CompetitionScoreTypes.SerializeCompetitionScore(scores[i]));
        }
    }

    function MakeAndSortCompetitionScores(uint32 competition_id) internal view returns (CompetitionScoreTypes.CompetitionScore[] memory scores, MissionParametersTypes.MissionParameters memory parameters)
    {
        parameters = MissionParametersTypes.DeserializeMissionParameters(m_Database.Load(NullAddress, MissionParametersCategory, competition_id));
        scores = new CompetitionScoreTypes.CompetitionScore[](MaxCompetitionScores + 1);

        for (uint256 i = 0; i < parameters.m_ValidCompetitionScores; i++)
        {
            scores[i] = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(competition_id, CompetitionScoresCategory, i));
        }

        BubbleSort(scores, parameters.m_ValidCompetitionScores);
    }

    // 22 writes (full competition)
    function FinishCompetition(uint32 competition_id) public NotWhilePaused() OnlyOwner()
    {
        CompetitionScoreTypes.CompetitionScore[] memory scores;
        MissionParametersTypes.MissionParameters memory parameters;

        (scores, parameters) = MakeAndSortCompetitionScores(competition_id);

        require(parameters.m_IsStarted == 1);

        parameters.m_IsStarted = 0;

        uint256 original_competition_funds = uint256(m_Database.Load(NullAddress, CompetitionFundsCategory, competition_id));
        uint256 competition_funds_remaining = original_competition_funds;

        for (uint256 i = 0; i < parameters.m_ValidCompetitionScores; i++)
        {
            RocketTypes.Rocket memory rocket = RocketTypes.DeserializeRocket(m_Database.Load(NullAddress, RocketCategory, scores[i].m_RocketId));
            RocketTypes.StockRocket storage stock_rocket = m_InitialRockets[rocket.m_StockId];

            // Fix Lerps in BuyStockRocket if anything is added here
            // This will increase even if they change owners, which is fine
            rocket.m_TopSpeed = uint32(LerpExtra(stock_rocket.m_MinTopSpeed, stock_rocket.m_MaxTopSpeed, rocket.m_TopSpeed, bytes1(10 - i)));
            rocket.m_Thrust = uint32(LerpExtra(stock_rocket.m_MinThrust, stock_rocket.m_MaxThrust, rocket.m_Thrust, bytes1(10 - i)));
            rocket.m_Weight = uint32(LerpLess(stock_rocket.m_MinWeight, stock_rocket.m_MaxWeight, rocket.m_Weight, bytes1(10 - i)));
            rocket.m_FuelCapacity = uint32(LerpExtra(stock_rocket.m_MinFuelCapacity, stock_rocket.m_MaxFuelCapacity, rocket.m_FuelCapacity, bytes1(10 - i)));
            //

            m_Database.Store(NullAddress, RocketCategory, scores[i].m_RocketId, RocketTypes.SerializeRocket(rocket));

            uint256 existing_funds = uint256(m_Database.Load(scores[i].m_Owner, WithdrawalFundsCategory, 0));

            uint256 funds_won = original_competition_funds / (2 ** (i + 1));

            if (funds_won > competition_funds_remaining)
                funds_won = competition_funds_remaining;

            existing_funds += funds_won;
            competition_funds_remaining -= funds_won;

            m_Database.Store(scores[i].m_Owner, WithdrawalFundsCategory, 0, bytes32(existing_funds));
        }

        if (competition_funds_remaining > 0)
        {
            scores[MaxCompetitionScores] = CompetitionScoreTypes.DeserializeCompetitionScore(m_Database.Load(competition_id, CompetitionScoresCategory, 0));
            existing_funds = uint256(m_Database.Load(scores[MaxCompetitionScores].m_Owner, WithdrawalFundsCategory, 0));
            existing_funds += competition_funds_remaining;
            m_Database.Store(scores[MaxCompetitionScores].m_Owner, WithdrawalFundsCategory, 0, bytes32(existing_funds));
        }

        m_Database.Store(NullAddress, MissionParametersCategory, competition_id, parameters.SerializeMissionParameters());

        FinishCompetitionEvent(competition_id);
    }

    function Lerp(uint256 min, uint256 max, bytes1 percent) internal pure returns(uint256)
    {
        uint256 real_percent = (uint256(percent) % 100);
        return uint256(min + (real_percent * (max - min)) / 100);
    }

    function LerpExtra(uint256 min, uint256 max, uint256 current, bytes1 total_extra_percent) internal pure returns (uint256)
    {
        current += Lerp(min, max, total_extra_percent) - min;
        if (current < min || current > max)
            current = max;
        return current;
    }

    function LerpLess(uint256 min, uint256 max, uint256 current, bytes1 total_less_percent) internal pure returns (uint256)
    {
        current -= Lerp(min, max, total_less_percent) - min;
        if (current < min || current > max)
            current = min;
        return current;
    }

    function BubbleSort(CompetitionScoreTypes.CompetitionScore[] memory scores, uint32 length) internal pure
    {
        uint32 n = length;
        while (true)
        {
            bool swapped = false;
            for (uint32 i = 1; i < n; i++)
            {
                if (scores[i - 1].m_Distance > scores[i].m_Distance)
                {
                    scores[MaxCompetitionScores] = scores[i - 1];
                    scores[i - 1] = scores[i];
                    scores[i] = scores[MaxCompetitionScores];
                    swapped = true;
                }
            }
            n--;
            if (!swapped)
                break;
        }
    }
}

library GameCommon
{
    using Serializer for Serializer.DataComponent;

    struct LaunchRocketStackFrame
    {
        int64 m_RocketTopSpeed; // 0
        int64 m_RocketThrust; // 8
        int64 m_RocketMass; // 16
        int64 m_RocketFuelCapacity; // 24

        int64 m_RocketMaxDistance; // 0
        int64 m_MissionWindSpeed; // 8
        int64 m_MissionLaunchLocation; // 16
        int64 m_MissionWeatherType; // 24

        int64 m_MissionWeatherCoverage; // 0
        int64 m_MissionTargetDistance; // 8
        int64 m_FuelToUse; // 16
        int64 m_FuelAllocationForLaunch; // 24

        int64 m_StabilizerSetting; // 0
        int64 m_DebugExtraDistance; // 8
        int64 m_LaunchThrust; // 16

        RocketTypes.Rocket m_Rocket;
        OwnershipTypes.Ownership m_Ownership;
        MissionParametersTypes.MissionParameters m_Mission;

        bytes32 m_Raw0;
        bytes32 m_Raw1;
        bytes32 m_Raw2;
        bytes32 m_Raw3;

        uint32 m_CompetitionId;
        uint32 m_RocketId;
        int64 m_LowEarthOrbitPosition;
        int64 m_DisplacementFromLowEarthOrbit;
        int64 m_DisplacementFromPlanet;
        address m_Launcher;
        uint256 m_ProfitFunds;
        uint256 m_CompetitionFunds;
        uint64 m_FinalDistance;
    }

    function SerializeLaunchRocketStackFrame(LaunchRocketStackFrame memory stack) internal pure
    {
        SerializeRaw0(stack);
        SerializeRaw1(stack);
        SerializeRaw2(stack);
        SerializeRaw3(stack);
    }

    function DeserializeLaunchRocketStackFrame(LaunchRocketStackFrame memory stack) internal pure
    {
        DeserializeRaw0(stack);
        DeserializeRaw1(stack);
        DeserializeRaw2(stack);
        DeserializeRaw3(stack);
    }

    function SerializeRaw0(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;

        data.WriteUint64(0, uint64(stack.m_RocketTopSpeed));
        data.WriteUint64(8, uint64(stack.m_RocketThrust));
        data.WriteUint64(16, uint64(stack.m_RocketMass));
        data.WriteUint64(24, uint64(stack.m_RocketFuelCapacity));

        stack.m_Raw0 = data.m_Raw;
    }

    function DeserializeRaw0(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;
        data.m_Raw = stack.m_Raw0;

        stack.m_RocketTopSpeed = int64(data.ReadUint64(0));
        stack.m_RocketThrust = int64(data.ReadUint64(8));
        stack.m_RocketMass = int64(data.ReadUint64(16));
        stack.m_RocketFuelCapacity = int64(data.ReadUint64(24));
    }

    function SerializeRaw1(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;

        data.WriteUint64(0, uint64(stack.m_RocketMaxDistance));
        data.WriteUint64(8, uint64(stack.m_MissionWindSpeed));
        data.WriteUint64(16, uint64(stack.m_MissionLaunchLocation));
        data.WriteUint64(24, uint64(stack.m_MissionWeatherType));

        stack.m_Raw1 = data.m_Raw;
    }

    function DeserializeRaw1(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;
        data.m_Raw = stack.m_Raw1;

        stack.m_RocketMaxDistance = int64(data.ReadUint64(0));
        stack.m_MissionWindSpeed = int64(data.ReadUint64(8));
        stack.m_MissionLaunchLocation = int64(data.ReadUint64(16));
        stack.m_MissionWeatherType = int64(data.ReadUint64(24));
    }

    function SerializeRaw2(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;

        data.WriteUint64(0, uint64(stack.m_MissionWeatherCoverage));
        data.WriteUint64(8, uint64(stack.m_MissionTargetDistance));
        data.WriteUint64(16, uint64(stack.m_FuelToUse));
        data.WriteUint64(24, uint64(stack.m_FuelAllocationForLaunch));

        stack.m_Raw2 = data.m_Raw;
    }

    function DeserializeRaw2(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;
        data.m_Raw = stack.m_Raw2;

        stack.m_MissionWeatherCoverage = int64(data.ReadUint64(0));
        stack.m_MissionTargetDistance = int64(data.ReadUint64(8));
        stack.m_FuelToUse = int64(data.ReadUint64(16));
        stack.m_FuelAllocationForLaunch = int64(data.ReadUint64(24));
    }

    function SerializeRaw3(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;

        data.WriteUint64(0, uint64(stack.m_StabilizerSetting));
        data.WriteUint64(8, uint64(stack.m_DebugExtraDistance));
        data.WriteUint64(16, uint64(stack.m_LaunchThrust));

        stack.m_Raw3 = data.m_Raw;
    }

    function DeserializeRaw3(LaunchRocketStackFrame memory stack) internal pure
    {
        Serializer.DataComponent memory data;
        data.m_Raw = stack.m_Raw3;

        stack.m_StabilizerSetting = int64(data.ReadUint64(0));
        stack.m_DebugExtraDistance = int64(data.ReadUint64(8));
        stack.m_LaunchThrust = int64(data.ReadUint64(16));
    }
}

library GlobalTypes
{
    using Serializer for Serializer.DataComponent;

    struct Global
    {
        uint32 m_LastRocketId; // 0
        uint32 m_CompetitionNumber; // 4
        uint8 m_Unused8; // 8
        uint8 m_Unused9; // 9
        uint8 m_Unused10; // 10
        uint8 m_Unused11; // 11
    }

    function SerializeGlobal(Global global) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteUint32(0, global.m_LastRocketId);
        data.WriteUint32(4, global.m_CompetitionNumber);
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

        global.m_LastRocketId = data.ReadUint32(0);
        global.m_CompetitionNumber = data.ReadUint32(4);
        global.m_Unused8 = data.ReadUint8(8);
        global.m_Unused9 = data.ReadUint8(9);
        global.m_Unused10 = data.ReadUint8(10);
        global.m_Unused11 = data.ReadUint8(11);

        return global;
    }
}

library MarketTypes
{
    using Serializer for Serializer.DataComponent;

    struct MarketListing
    {
        uint80 m_Price; // 0
    }

    function SerializeMarketListing(MarketListing listing) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteUint80(0, listing.m_Price);

        return data.m_Raw;
    }

    function DeserializeMarketListing(bytes32 raw) internal pure returns (MarketListing)
    {
        MarketListing memory listing;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        listing.m_Price = data.ReadUint80(0);

        return listing;
    }
}

library MissionParametersTypes
{
    using Serializer for Serializer.DataComponent;

    struct MissionParameters
    {
        uint8 m_WindSpeed; // 0
        uint8 m_LaunchLocation; // 1
        uint8 m_WeatherType; // 2
        uint8 m_WeatherCoverage; // 3
        uint80 m_LaunchCost; // 4
        uint8 m_IsStarted; // 14
        uint32 m_TargetDistance; // 15
        uint32 m_ValidCompetitionScores; // 19
        uint8 m_DebugExtraDistance; // 23
    }

    function SerializeMissionParameters(MissionParameters mission) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;

        data.WriteUint8(0, mission.m_WindSpeed);
        data.WriteUint8(1, mission.m_LaunchLocation);
        data.WriteUint8(2, mission.m_WeatherType);
        data.WriteUint8(3, mission.m_WeatherCoverage);
        data.WriteUint80(4, mission.m_LaunchCost);
        data.WriteUint8(14, mission.m_IsStarted);
        data.WriteUint32(15, mission.m_TargetDistance);
        data.WriteUint32(19, mission.m_ValidCompetitionScores);
        data.WriteUint8(23, mission.m_DebugExtraDistance);

        return data.m_Raw;
    }

    function DeserializeMissionParameters(bytes32 raw) internal pure returns (MissionParameters)
    {
        MissionParameters memory mission;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        mission.m_WindSpeed = data.ReadUint8(0);
        mission.m_LaunchLocation = data.ReadUint8(1);
        mission.m_WeatherType = data.ReadUint8(2);
        mission.m_WeatherCoverage = data.ReadUint8(3);
        mission.m_LaunchCost = data.ReadUint80(4);
        mission.m_IsStarted = data.ReadUint8(14);
        mission.m_TargetDistance = data.ReadUint32(15);
        mission.m_ValidCompetitionScores = data.ReadUint32(19);
        mission.m_DebugExtraDistance = data.ReadUint8(23);

        return mission;
    }
}

library OwnershipTypes
{
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

library RocketTypes
{
    using Serializer for Serializer.DataComponent;

    struct Rocket
    {
        uint8 m_Version; // 0
        uint8 m_Unused1; // 1
        uint8 m_IsForSale; // 2
        uint8 m_Unused3; // 3

        uint32 m_TopSpeed; // 4
        uint32 m_Thrust; // 8
        uint32 m_Weight; // 12
        uint32 m_FuelCapacity; // 16

        uint16 m_StockId; // 20
        uint16 m_Unused22; // 22
        uint64 m_MaxDistance; // 24
    }

    struct StockRocket
    {
        bool m_IsValid; // 0
        uint64 m_Cost; // 1

        uint32 m_MinTopSpeed; // 5
        uint32 m_MaxTopSpeed; // 9

        uint32 m_MinThrust; // 13
        uint32 m_MaxThrust; // 17

        uint32 m_MinWeight; // 21
        uint32 m_MaxWeight; // 25

        uint32 m_MinFuelCapacity; // 29
        uint32 m_MaxFuelCapacity; // 33

        uint64 m_Distance; // 37
    }

    function SerializeRocket(Rocket rocket) internal pure returns (bytes32)
    {
        Serializer.DataComponent memory data;
        data.WriteUint8(0, rocket.m_Version);
        //data.WriteUint8(1, rocket.m_Unused1);
        data.WriteUint8(2, rocket.m_IsForSale);
        //data.WriteUint8(3, rocket.m_Unused3);
        data.WriteUint32(4, rocket.m_TopSpeed);
        data.WriteUint32(8, rocket.m_Thrust);
        data.WriteUint32(12, rocket.m_Weight);
        data.WriteUint32(16, rocket.m_FuelCapacity);
        data.WriteUint16(20, rocket.m_StockId);
        //data.WriteUint16(22, rocket.m_Unused22);
        data.WriteUint64(24, rocket.m_MaxDistance);

        return data.m_Raw;
    }

    function DeserializeRocket(bytes32 raw) internal pure returns (Rocket)
    {
        Rocket memory rocket;

        Serializer.DataComponent memory data;
        data.m_Raw = raw;

        rocket.m_Version = data.ReadUint8(0);
        //rocket.m_Unused1 = data.ReadUint8(1);
        rocket.m_IsForSale = data.ReadUint8(2);
        //rocket.m_Unused3 = data.ReadUint8(3);
        rocket.m_TopSpeed = data.ReadUint32(4);
        rocket.m_Thrust = data.ReadUint32(8);
        rocket.m_Weight = data.ReadUint32(12);
        rocket.m_FuelCapacity = data.ReadUint32(16);
        rocket.m_StockId = data.ReadUint16(20);
        //rocket.m_Unused22 = data.ReadUint16(22);
        rocket.m_MaxDistance = data.ReadUint64(24);

        return rocket;
    }
}

library Serializer
{
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