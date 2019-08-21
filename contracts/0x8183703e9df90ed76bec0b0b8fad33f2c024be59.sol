// File: contracts/GodMode.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;

/// @title God Mode
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev This contract provides a basic interface for God
///  in a contract as well as the ability for God to pause
///  the contract
contract GodMode {
    /// @dev Is the contract paused?
    bool public isPaused;

    /// @dev God's address
    address public god;

    /// @dev Only God can run this function
    modifier onlyGod()
    {
        require(god == msg.sender);
        _;
    }

    /// @dev This function can only be run while the contract
    ///  is not paused
    modifier notPaused()
    {
        require(!isPaused);
        _;
    }

    /// @dev This event is fired when the contract is paused
    event GodPaused();

    /// @dev This event is fired when the contract is unpaused
    event GodUnpaused();

    constructor() public
    {
        // Make the creator of the contract God
        god = msg.sender;
    }

    /// @dev God can change the address of God
    /// @param _newGod The new address for God
    function godChangeGod(address _newGod) public onlyGod
    {
        god = _newGod;
    }

    /// @dev God can pause the game
    function godPause() public onlyGod
    {
        isPaused = true;

        emit GodPaused();
    }

    /// @dev God can unpause the game
    function godUnpause() public onlyGod
    {
        isPaused = false;

        emit GodUnpaused();
    }
}

// File: contracts/KingOfEthEthExchangeReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;


/// @title King of Eth: Resource-to-ETH Exchange Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to interface with the
///  ETH exchange contract
contract KingOfEthEthExchangeReferencer is GodMode {
    /// @dev Address of the ETH exchange contract
    address public ethExchangeContract;

    /// @dev Only the ETH exchange contract may run this function
    modifier onlyEthExchangeContract()
    {
        require(ethExchangeContract == msg.sender);
        _;
    }

    /// @dev God may set the ETH exchange contract's address
    /// @dev _ethExchangeContract The new address
    function godSetEthExchangeContract(address _ethExchangeContract)
        public
        onlyGod
    {
        ethExchangeContract = _ethExchangeContract;
    }
}

// File: contracts/KingOfEthResourceExchangeReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;


/// @title King of Eth: Resource-to-Resource Exchange Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to interface with the
///  resource-to-resource contract
contract KingOfEthResourceExchangeReferencer is GodMode {
    /// @dev Address of the resource-to-resource contract
    address public resourceExchangeContract;

    /// @dev Only the resource-to-resource contract may run this function
    modifier onlyResourceExchangeContract()
    {
        require(resourceExchangeContract == msg.sender);
        _;
    }

    /// @dev God may set the resource-to-resource contract's address
    /// @dev _resourceExchangeContract The new address
    function godSetResourceExchangeContract(address _resourceExchangeContract)
        public
        onlyGod
    {
        resourceExchangeContract = _resourceExchangeContract;
    }
}

// File: contracts/KingOfEthExchangeReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;




/// @title King of Eth: Exchange Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to interface with the exchange contract
contract KingOfEthExchangeReferencer is
      GodMode
    , KingOfEthEthExchangeReferencer
    , KingOfEthResourceExchangeReferencer
{
    /// @dev Only one of the exchange contracts may
    ///  run this function
    modifier onlyExchangeContract()
    {
        require(
               ethExchangeContract == msg.sender
            || resourceExchangeContract == msg.sender
        );
        _;
    }
}

// File: contracts/KingOfEthHousesReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;


/// @title King of Eth: Houses Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to reference the houses contract
contract KingOfEthHousesReferencer is GodMode {
    /// @dev The houses contract's address
    address public housesContract;

    /// @dev Only the houses contract can run this function
    modifier onlyHousesContract()
    {
        require(housesContract == msg.sender);
        _;
    }

    /// @dev God can set the realty contract
    /// @param _housesContract The new address
    function godSetHousesContract(address _housesContract)
        public
        onlyGod
    {
        housesContract = _housesContract;
    }
}

// File: contracts/KingOfEthResourcesInterfaceReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;


/// @title King of Eth: Resources Interface Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to reference the resource interface contract
contract KingOfEthResourcesInterfaceReferencer is GodMode {
    /// @dev The interface contract's address
    address public interfaceContract;

    /// @dev Only the interface contract can run this function
    modifier onlyInterfaceContract()
    {
        require(interfaceContract == msg.sender);
        _;
    }

    /// @dev God can set the realty contract
    /// @param _interfaceContract The new address
    function godSetInterfaceContract(address _interfaceContract)
        public
        onlyGod
    {
        interfaceContract = _interfaceContract;
    }
}

// File: contracts/KingOfEthResource.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;



/// @title ERC20Interface
/// @dev ERC20 token interface contract
contract ERC20Interface {
    function totalSupply() public constant returns(uint);
    function balanceOf(address _tokenOwner) public constant returns(uint balance);
    function allowance(address _tokenOwner, address _spender) public constant returns(uint remaining);
    function transfer(address _to, uint _tokens) public returns(bool success);
    function approve(address _spender, uint _tokens) public returns(bool success);
    function transferFrom(address _from, address _to, uint _tokens) public returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/// @title King of Eth: Resource
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Common contract implementation for resources
contract KingOfEthResource is
      ERC20Interface
    , GodMode
    , KingOfEthResourcesInterfaceReferencer
{
    /// @dev Current resource supply
    uint public resourceSupply;

    /// @dev ERC20 token's decimals
    uint8 public constant decimals = 0;

    /// @dev mapping of addresses to holdings
    mapping (address => uint) holdings;

    /// @dev mapping of addresses to amount of tokens frozen
    mapping (address => uint) frozenHoldings;

    /// @dev mapping of addresses to mapping of allowances for an address
    mapping (address => mapping (address => uint)) allowances;

    /// @dev ERC20 total supply
    /// @return The current total supply of the resource
    function totalSupply()
        public
        constant
        returns(uint)
    {
        return resourceSupply;
    }

    /// @dev ERC20 balance of address
    /// @param _tokenOwner The address to look up
    /// @return The balance of the address
    function balanceOf(address _tokenOwner)
        public
        constant
        returns(uint balance)
    {
        return holdings[_tokenOwner];
    }

    /// @dev Total resources frozen for an address
    /// @param _tokenOwner The address to look up
    /// @return The frozen balance of the address
    function frozenTokens(address _tokenOwner)
        public
        constant
        returns(uint balance)
    {
        return frozenHoldings[_tokenOwner];
    }

    /// @dev The allowance for a spender on an account
    /// @param _tokenOwner The account that allows withdrawels
    /// @param _spender The account that is allowed to withdraw
    /// @return The amount remaining in the allowance
    function allowance(address _tokenOwner, address _spender)
        public
        constant
        returns(uint remaining)
    {
        return allowances[_tokenOwner][_spender];
    }

    /// @dev Only run if player has at least some amount of tokens
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens required
    modifier hasAvailableTokens(address _owner, uint _tokens)
    {
        require(holdings[_owner] - frozenHoldings[_owner] >= _tokens);
        _;
    }

    /// @dev Only run if player has at least some amount of tokens frozen
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of frozen tokens required
    modifier hasFrozenTokens(address _owner, uint _tokens)
    {
        require(frozenHoldings[_owner] >= _tokens);
        _;
    }

    /// @dev Set up the exact same state in each resource
    constructor() public
    {
        // God gets 200 to put on exchange
        holdings[msg.sender] = 200;

        resourceSupply = 200;
    }

    /// @dev The resources interface can burn tokens for building
    ///  roads or houses
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to burn
    function interfaceBurnTokens(address _owner, uint _tokens)
        public
        onlyInterfaceContract
        hasAvailableTokens(_owner, _tokens)
    {
        holdings[_owner] -= _tokens;

        resourceSupply -= _tokens;

        // Pretend the tokens were sent to 0x0
        emit Transfer(_owner, 0x0, _tokens);
    }

    /// @dev The resources interface contract can mint tokens for houses
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to burn
    function interfaceMintTokens(address _owner, uint _tokens)
        public
        onlyInterfaceContract
    {
        holdings[_owner] += _tokens;

        resourceSupply += _tokens;

        // Pretend the tokens were sent from the interface contract
        emit Transfer(interfaceContract, _owner, _tokens);
    }

    /// @dev The interface can freeze tokens
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to freeze
    function interfaceFreezeTokens(address _owner, uint _tokens)
        public
        onlyInterfaceContract
        hasAvailableTokens(_owner, _tokens)
    {
        frozenHoldings[_owner] += _tokens;
    }

    /// @dev The interface can thaw tokens
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to thaw
    function interfaceThawTokens(address _owner, uint _tokens)
        public
        onlyInterfaceContract
        hasFrozenTokens(_owner, _tokens)
    {
        frozenHoldings[_owner] -= _tokens;
    }

    /// @dev The interface can transfer tokens
    /// @param _from The owner of the tokens
    /// @param _to The new owner of the tokens
    /// @param _tokens The amount of tokens to transfer
    function interfaceTransfer(address _from, address _to, uint _tokens)
        public
        onlyInterfaceContract
    {
        assert(holdings[_from] >= _tokens);

        holdings[_from] -= _tokens;
        holdings[_to]   += _tokens;

        emit Transfer(_from, _to, _tokens);
    }

    /// @dev The interface can transfer frozend tokens
    /// @param _from The owner of the tokens
    /// @param _to The new owner of the tokens
    /// @param _tokens The amount of frozen tokens to transfer
    function interfaceFrozenTransfer(address _from, address _to, uint _tokens)
        public
        onlyInterfaceContract
        hasFrozenTokens(_from, _tokens)
    {
        // Make sure to deduct the tokens from both the total and frozen amounts
        holdings[_from]       -= _tokens;
        frozenHoldings[_from] -= _tokens;
        holdings[_to]         += _tokens;

        emit Transfer(_from, _to, _tokens);
    }

    /// @dev ERC20 transfer
    /// @param _to The address to transfer to
    /// @param _tokens The amount of tokens to transfer
    function transfer(address _to, uint _tokens)
        public
        hasAvailableTokens(msg.sender, _tokens)
        returns(bool success)
    {
        holdings[_to]        += _tokens;
        holdings[msg.sender] -= _tokens;

        emit Transfer(msg.sender, _to, _tokens);

        return true;
    }

    /// @dev ERC20 approve
    /// @param _spender The address to approve
    /// @param _tokens The amount of tokens to approve
    function approve(address _spender, uint _tokens)
        public
        returns(bool success)
    {
        allowances[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);

        return true;
    }

    /// @dev ERC20 transfer from
    /// @param _from The address providing the allowance
    /// @param _to The address using the allowance
    /// @param _tokens The amount of tokens to transfer
    function transferFrom(address _from, address _to, uint _tokens)
        public
        hasAvailableTokens(_from, _tokens)
        returns(bool success)
    {
        require(allowances[_from][_to] >= _tokens);

        holdings[_to]          += _tokens;
        holdings[_from]        -= _tokens;
        allowances[_from][_to] -= _tokens;

        emit Transfer(_from, _to, _tokens);

        return true;
    }
}

// File: contracts/KingOfEthResourceType.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;

/// @title King of Eth: Resource Type
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides enum to choose resource types
contract KingOfEthResourceType {
    /// @dev Enum describing a choice of a resource
    enum ResourceType {
          ETH
        , BRONZE
        , CORN
        , GOLD
        , OIL
        , ORE
        , STEEL
        , URANIUM
        , WOOD
    }
}

// File: contracts/KingOfEthRoadsReferencer.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;


/// @title King of Eth: Roads Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to reference the roads contract
contract KingOfEthRoadsReferencer is GodMode {
    /// @dev The roads contract's address
    address public roadsContract;

    /// @dev Only the roads contract can run this function
    modifier onlyRoadsContract()
    {
        require(roadsContract == msg.sender);
        _;
    }

    /// @dev God can set the realty contract
    /// @param _roadsContract The new address
    function godSetRoadsContract(address _roadsContract)
        public
        onlyGod
    {
        roadsContract = _roadsContract;
    }
}

// File: contracts/KingOfEthResourcesInterface.sol

/****************************************************
 *
 * Copyright 2018 BurzNest LLC. All rights reserved.
 *
 * The contents of this file are provided for review
 * and educational purposes ONLY. You MAY NOT use,
 * copy, distribute, or modify this software without
 * explicit written permission from BurzNest LLC.
 *
 ****************************************************/

pragma solidity ^0.4.24;







/// @title King of Eth: Resources Interface
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for interacting with resources
contract KingOfEthResourcesInterface is
      GodMode
    , KingOfEthExchangeReferencer
    , KingOfEthHousesReferencer
    , KingOfEthResourceType
    , KingOfEthRoadsReferencer
{
    /// @dev Amount of resources a user gets for building a house
    uint public constant resourcesPerHouse = 3;

    /// @dev Address for the bronze contract
    address public bronzeContract;

    /// @dev Address for the corn contract
    address public cornContract;

    /// @dev Address for the gold contract
    address public goldContract;

    /// @dev Address for the oil contract
    address public oilContract;

    /// @dev Address for the ore contract
    address public oreContract;

    /// @dev Address for the steel contract
    address public steelContract;

    /// @dev Address for the uranium contract
    address public uraniumContract;

    /// @dev Address for the wood contract
    address public woodContract;

    /// @param _bronzeContract The address of the bronze contract
    /// @param _cornContract The address of the corn contract
    /// @param _goldContract The address of the gold contract
    /// @param _oilContract The address of the oil contract
    /// @param _oreContract The address of the ore contract
    /// @param _steelContract The address of the steel contract
    /// @param _uraniumContract The address of the uranium contract
    /// @param _woodContract The address of the wood contract
    constructor(
          address _bronzeContract
        , address _cornContract
        , address _goldContract
        , address _oilContract
        , address _oreContract
        , address _steelContract
        , address _uraniumContract
        , address _woodContract
    )
        public
    {
        bronzeContract  = _bronzeContract;
        cornContract    = _cornContract;
        goldContract    = _goldContract;
        oilContract     = _oilContract;
        oreContract     = _oreContract;
        steelContract   = _steelContract;
        uraniumContract = _uraniumContract;
        woodContract    = _woodContract;
    }

    /// @dev Return the particular address for a certain resource type
    /// @param _type The resource type
    /// @return The address for that resource
    function contractFor(ResourceType _type)
        public
        view
        returns(address)
    {
        // ETH does not have a contract
        require(ResourceType.ETH != _type);

        if(ResourceType.BRONZE == _type)
        {
            return bronzeContract;
        }
        else if(ResourceType.CORN == _type)
        {
            return cornContract;
        }
        else if(ResourceType.GOLD == _type)
        {
            return goldContract;
        }
        else if(ResourceType.OIL == _type)
        {
            return oilContract;
        }
        else if(ResourceType.ORE == _type)
        {
            return oreContract;
        }
        else if(ResourceType.STEEL == _type)
        {
            return steelContract;
        }
        else if(ResourceType.URANIUM == _type)
        {
            return uraniumContract;
        }
        else if(ResourceType.WOOD == _type)
        {
            return woodContract;
        }
    }

    /// @dev Determine the resource type of a tile
    /// @param _x The x coordinate of the top left corner of the tile
    /// @param _y The y coordinate of the top left corner of the tile
    function resourceType(uint _x, uint _y)
        public
        pure
        returns(ResourceType resource)
    {
        uint _seed = (_x + 7777777) ^  _y;

        if(0 == _seed % 97)
        {
          return ResourceType.URANIUM;
        }
        else if(0 == _seed % 29)
        {
          return ResourceType.OIL;
        }
        else if(0 == _seed % 23)
        {
          return ResourceType.STEEL;
        }
        else if(0 == _seed % 17)
        {
          return ResourceType.GOLD;
        }
        else if(0 == _seed % 11)
        {
          return ResourceType.BRONZE;
        }
        else if(0 == _seed % 5)
        {
          return ResourceType.WOOD;
        }
        else if(0 == _seed % 2)
        {
          return ResourceType.CORN;
        }
        else
        {
          return ResourceType.ORE;
        }
    }

    /// @dev Lookup the number of resource points for a certain
    ///  player
    /// @param _player The player in question
    function lookupResourcePoints(address _player)
        public
        view
        returns(uint)
    {
        uint result = 0;

        result += KingOfEthResource(bronzeContract).balanceOf(_player);
        result += KingOfEthResource(goldContract).balanceOf(_player)    * 3;
        result += KingOfEthResource(steelContract).balanceOf(_player)   * 6;
        result += KingOfEthResource(oilContract).balanceOf(_player)     * 10;
        result += KingOfEthResource(uraniumContract).balanceOf(_player) * 44;

        return result;
    }

    /// @dev Burn the resources necessary to build a house
    /// @param _count the number of houses being built
    /// @param _player The player who is building the house
    function burnHouseCosts(uint _count, address _player)
        public
        onlyHousesContract
    {
        // Costs 2 corn per house
        KingOfEthResource(contractFor(ResourceType.CORN)).interfaceBurnTokens(
              _player
            , 2 * _count
        );

        // Costs 2 ore per house
        KingOfEthResource(contractFor(ResourceType.ORE)).interfaceBurnTokens(
              _player
            , 2 * _count
        );

        // Costs 1 wood per house
        KingOfEthResource(contractFor(ResourceType.WOOD)).interfaceBurnTokens(
              _player
            , _count
        );
    }

    /// @dev Burn the costs of upgrading a house
    /// @param _currentLevel The level of the house before the upgrade
    /// @param _player The player who is upgrading the house
    function burnUpgradeCosts(uint8 _currentLevel, address _player)
        public
        onlyHousesContract
    {
        // Do not allow upgrades after level 4
        require(5 > _currentLevel);

        // Burn the base house cost
        burnHouseCosts(1, _player);

        if(0 == _currentLevel)
        {
            // Level 1 costs bronze
            KingOfEthResource(contractFor(ResourceType.BRONZE)).interfaceBurnTokens(
                  _player
                , 1
            );
        }
        else if(1 == _currentLevel)
        {
            // Level 2 costs gold
            KingOfEthResource(contractFor(ResourceType.GOLD)).interfaceBurnTokens(
                  _player
                , 1
            );
        }
        else if(2 == _currentLevel)
        {
            // Level 3 costs steel
            KingOfEthResource(contractFor(ResourceType.STEEL)).interfaceBurnTokens(
                  _player
                , 1
            );
        }
        else if(3 == _currentLevel)
        {
            // Level 4 costs oil
            KingOfEthResource(contractFor(ResourceType.OIL)).interfaceBurnTokens(
                  _player
                , 1
            );
        }
        else if(4 == _currentLevel)
        {
            // Level 5 costs uranium
            KingOfEthResource(contractFor(ResourceType.URANIUM)).interfaceBurnTokens(
                  _player
                , 1
            );
        }
    }

    /// @dev Mint resources for a house and distribute all to its owner
    /// @param _owner The owner of the house
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _level The new level of the house
    function distributeResources(address _owner, uint _x, uint _y, uint8 _level)
        public
        onlyHousesContract
    {
        // Calculate the count of resources for this level
        uint _count = resourcesPerHouse * uint(_level + 1);

        // Distribute the top left resource
        KingOfEthResource(contractFor(resourceType(_x - 1, _y - 1))).interfaceMintTokens(
            _owner
          , _count
        );

        // Distribute the top right resource
        KingOfEthResource(contractFor(resourceType(_x, _y - 1))).interfaceMintTokens(
            _owner
          , _count
        );

        // Distribute the bottom right resource
        KingOfEthResource(contractFor(resourceType(_x, _y))).interfaceMintTokens(
            _owner
          , _count
        );

        // Distribute the bottom left resource
        KingOfEthResource(contractFor(resourceType(_x - 1, _y))).interfaceMintTokens(
            _owner
          , _count
        );
    }

    /// @dev Burn the costs necessary to build a road
    /// @param _length The length of the road
    /// @param _player The player who is building the house
    function burnRoadCosts(uint _length, address _player)
        public
        onlyRoadsContract
    {
        // Burn corn
        KingOfEthResource(cornContract).interfaceBurnTokens(
              _player
            , _length
        );

        // Burn ore
        KingOfEthResource(oreContract).interfaceBurnTokens(
              _player
            , _length
        );
    }

    /// @dev The exchange can freeze tokens
    /// @param _type The type of resource
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to freeze
    function exchangeFreezeTokens(ResourceType _type, address _owner, uint _tokens)
        public
        onlyExchangeContract
    {
        KingOfEthResource(contractFor(_type)).interfaceFreezeTokens(_owner, _tokens);
    }

    /// @dev The exchange can thaw tokens
    /// @param _type The type of resource
    /// @param _owner The owner of the tokens
    /// @param _tokens The amount of tokens to thaw
    function exchangeThawTokens(ResourceType _type, address _owner, uint _tokens)
        public
        onlyExchangeContract
    {
        KingOfEthResource(contractFor(_type)).interfaceThawTokens(_owner, _tokens);
    }

    /// @dev The exchange can transfer tokens
    /// @param _type The type of resource
    /// @param _from The owner of the tokens
    /// @param _to The new owner of the tokens
    /// @param _tokens The amount of tokens to transfer
    function exchangeTransfer(ResourceType _type, address _from, address _to, uint _tokens)
        public
        onlyExchangeContract
    {
        KingOfEthResource(contractFor(_type)).interfaceTransfer(_from, _to, _tokens);
    }

    /// @dev The exchange can transfer frozend tokens
    /// @param _type The type of resource
    /// @param _from The owner of the tokens
    /// @param _to The new owner of the tokens
    /// @param _tokens The amount of frozen tokens to transfer
    function exchangeFrozenTransfer(ResourceType _type, address _from, address _to, uint _tokens)
        public
        onlyExchangeContract
    {
        KingOfEthResource(contractFor(_type)).interfaceFrozenTransfer(_from, _to, _tokens);
    }
}