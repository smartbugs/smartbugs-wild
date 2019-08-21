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

// File: contracts/KingOfEthAbstractInterface.sol

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

/// @title King of Eth Abstract Interface
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Abstract interface contract for titles and taxes
contract KingOfEthAbstractInterface {
    /// @dev The address of the current King
    address public king;

    /// @dev The address of the current Wayfarer
    address public wayfarer;

    /// @dev Anyone can pay taxes
    function payTaxes() public payable;
}

// File: contracts/KingOfEthReferencer.sol

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


/// @title King of Eth Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Functionality to allow contracts to reference the king contract
contract KingOfEthReferencer is GodMode {
    /// @dev The address of the king contract
    address public kingOfEthContract;

    /// @dev Only the king contract can run this
    modifier onlyKingOfEthContract()
    {
        require(kingOfEthContract == msg.sender);
        _;
    }

    /// @dev God can change the king contract
    /// @param _kingOfEthContract The new address
    function godSetKingOfEthContract(address _kingOfEthContract)
        public
        onlyGod
    {
        kingOfEthContract = _kingOfEthContract;
    }
}

// File: contracts/KingOfEthRoadsAbstractInterface.sol

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

/// @title King of Eth: Roads Abstract Interface
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Abstract interface contract for roads
contract KingOfEthRoadsAbstractInterface {
    /// @dev Get the owner of the road at some location
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road (either
    ///  0 for right or 1 for down)
    /// @return The address of the owner
    function ownerOf(uint _x, uint _y, uint8 _direction) public view returns(address);

    /// @dev The road realty contract can transfer road ownership
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    /// @param _from The previous owner of road
    /// @param _to The new owner of road
    function roadRealtyTransferOwnership(
          uint _x
        , uint _y
        , uint8 _direction
        , address _from
        , address _to
    ) public;
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

// File: contracts/KingOfEthRoadRealty.sol

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






/// @title King of Eth: Road Realty
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for controlling sales of roads
contract KingOfEthRoadRealty is
      GodMode
    , KingOfEthReferencer
    , KingOfEthRoadsReferencer
{
    /// @dev The number that divides the amount payed for any sale to produce
    ///  the amount payed in taxes
    uint public constant taxDivisor = 25;

    /// @dev Mapping from the x, y coordinates and the direction (0 for right and
    ///  1 for down) of a road to the  current sale price (0 if there is no sale)
    mapping (uint => mapping (uint => uint[2])) roadPrices;

    /// @dev Fired when there is a new road for sale
    event RoadForSale(
          uint x
        , uint y
        , uint8 direction
        , address owner
        , uint amount
    );

    /// @dev Fired when the owner changes the price of a road
    event RoadPriceChanged(
          uint x
        , uint y
        , uint8 direction
        , uint amount
    );

    /// @dev Fired when a road is sold
    event RoadSold(
          uint x
        , uint y
        , uint8 direction
        , address from
        , address to
        , uint amount
    );

    /// @dev Fired when the sale for a road is cancelled by the owner
    event RoadSaleCancelled(
          uint x
        , uint y
        , uint8 direction
        , address owner
    );

    /// @dev Only the owner of the road at a location can run this
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    modifier onlyRoadOwner(uint _x, uint _y, uint8 _direction)
    {
        require(KingOfEthRoadsAbstractInterface(roadsContract).ownerOf(_x, _y, _direction) == msg.sender);
        _;
    }

    /// @dev This can only be run if there is *not* an existing sale for a road
    ///  at a location
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    modifier noExistingRoadSale(uint _x, uint _y, uint8 _direction)
    {
        require(0 == roadPrices[_x][_y][_direction]);
        _;
    }

    /// @dev This can only be run if there is an existing sale for a house
    ///  at a location
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    modifier existingRoadSale(uint _x, uint _y, uint8 _direction)
    {
        require(0 != roadPrices[_x][_y][_direction]);
        _;
    }

    /// @param _kingOfEthContract The address of the king contract
    constructor(address _kingOfEthContract) public
    {
        kingOfEthContract = _kingOfEthContract;
    }

    /// @dev The roads contract can cancel a sale when a road is transfered
    ///  to another player
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    function roadsCancelRoadSale(uint _x, uint _y, uint8 _direction)
        public
        onlyRoadsContract
    {
        // If there is indeed a sale
        if(0 != roadPrices[_x][_y][_direction])
        {
            // Cancel the sale
            roadPrices[_x][_y][_direction] = 0;

            emit RoadSaleCancelled(_x, _y, _direction, msg.sender);
        }
    }

    /// @dev The owner of a road can start a sale
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    /// @param _askingPrice The price that must be payed by another player
    ///  to purchase the road
    function startRoadSale(
          uint _x
        , uint _y
        , uint8 _direction
        , uint _askingPrice
    )
        public
        notPaused
        onlyRoadOwner(_x, _y, _direction)
        noExistingRoadSale(_x, _y, _direction)
    {
        // Require that the price is at least 0
        require(0 != _askingPrice);

        // Record the price
        roadPrices[_x][_y][_direction] = _askingPrice;

        emit RoadForSale(_x, _y, _direction, msg.sender, _askingPrice);
    }

    /// @dev The owner of a road can change the price of a sale
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    /// @param _askingPrice The new price that must be payed by another
    ///  player to purchase the road
    function changeRoadPrice(
          uint _x
        , uint _y
        , uint8 _direction
        , uint _askingPrice
    )
        public
        notPaused
        onlyRoadOwner(_x, _y, _direction)
        existingRoadSale(_x, _y, _direction)
    {
        // Require that the price is at least 0
        require(0 != _askingPrice);

        // Record the price
        roadPrices[_x][_y][_direction] = _askingPrice;

        emit RoadPriceChanged(_x, _y, _direction, _askingPrice);
    }

    /// @dev Anyone can purchase a road as long as the sale exists
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    function purchaseRoad(uint _x, uint _y, uint8 _direction)
        public
        payable
        notPaused
        existingRoadSale(_x, _y, _direction)
    {
        // Require that the exact price was paid
        require(roadPrices[_x][_y][_direction] == msg.value);

        // End the sale
        roadPrices[_x][_y][_direction] = 0;

        // Calculate the taxes to be paid
        uint taxCut = msg.value / taxDivisor;

        // Pay the taxes
        KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(taxCut)();

        KingOfEthRoadsAbstractInterface _roadsContract = KingOfEthRoadsAbstractInterface(roadsContract);

        // Determine the previous owner
        address _oldOwner = _roadsContract.ownerOf(_x, _y, _direction);

        // Send the buyer the house
        _roadsContract.roadRealtyTransferOwnership(
              _x
            , _y
            , _direction
            , _oldOwner
            , msg.sender
        );

        // Send the previous owner his share
        _oldOwner.transfer(msg.value - taxCut);

        emit RoadSold(
              _x
            , _y
            , _direction
            , _oldOwner
            , msg.sender
            , msg.value
        );
    }

    /// @dev The owner of a road can cancel a sale
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    function cancelRoadSale(uint _x, uint _y, uint8 _direction)
        public
        notPaused
        onlyRoadOwner(_x, _y, _direction)
        existingRoadSale(_x, _y, _direction)
    {
        // Cancel the sale
        roadPrices[_x][_y][_direction] = 0;

        emit RoadSaleCancelled(_x, _y, _direction, msg.sender);
    }
}