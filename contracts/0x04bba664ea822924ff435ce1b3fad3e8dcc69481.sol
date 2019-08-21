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

// File: contracts/KingOfEthAuctionsAbstractInterface.sol

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

/// @title King of Eth: Auctions Abstract Interface
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Abstract interface contract for auctions of houses
contract KingOfEthAuctionsAbstractInterface {
    /// @dev Determines if there is an auction at a particular location
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    /// @return true if there is an existing auction
    function existingAuction(uint _x, uint _y) public view returns(bool);
}

// File: contracts/KingOfEthBlindAuctionsReferencer.sol

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


/// @title King of Eth: Blind Auctions Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev This contract provides a reference to the blind auctions contract
contract KingOfEthBlindAuctionsReferencer is GodMode {
    /// @dev The address of the blind auctions contract
    address public blindAuctionsContract;

    /// @dev Only the blind auctions contract can run this
    modifier onlyBlindAuctionsContract()
    {
        require(blindAuctionsContract == msg.sender);
        _;
    }

    /// @dev God can set a new blind auctions contract
    /// @param _blindAuctionsContract the address of the blind auctions
    ///  contract
    function godSetBlindAuctionsContract(address _blindAuctionsContract)
        public
        onlyGod
    {
        blindAuctionsContract = _blindAuctionsContract;
    }
}

// File: contracts/KingOfEthOpenAuctionsReferencer.sol

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


/// @title King of Eth: Open Auctions Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev This contract provides a reference to the open auctions contract
contract KingOfEthOpenAuctionsReferencer is GodMode {
    /// @dev The address of the auctions contract
    address public openAuctionsContract;

    /// @dev Only the open auctions contract can run this
    modifier onlyOpenAuctionsContract()
    {
        require(openAuctionsContract == msg.sender);
        _;
    }

    /// @dev God can set a new auctions contract
    function godSetOpenAuctionsContract(address _openAuctionsContract)
        public
        onlyGod
    {
        openAuctionsContract = _openAuctionsContract;
    }
}

// File: contracts/KingOfEthAuctionsReferencer.sol

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



/// @title King of Eth: Auctions Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev This contract provides a reference to the auctions contracts
contract KingOfEthAuctionsReferencer is
      KingOfEthBlindAuctionsReferencer
    , KingOfEthOpenAuctionsReferencer
{
    /// @dev Only an auctions contract can run this
    modifier onlyAuctionsContract()
    {
        require(blindAuctionsContract == msg.sender
             || openAuctionsContract == msg.sender);
        _;
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

// File: contracts/KingOfEthBoard.sol

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





/// @title King of Eth: Board
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for board
contract KingOfEthBoard is
      GodMode
    , KingOfEthAuctionsReferencer
    , KingOfEthReferencer
{
    /// @dev x coordinate of the top left corner of the boundary
    uint public boundX1 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef;

    /// @dev y coordinate of the top left corner of the boundary
    uint public boundY1 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef;

    /// @dev x coordinate of the bottom right corner of the boundary
    uint public boundX2 = 0x800000000000000000000000000000000000000000000000000000000000000f;

    /// @dev y coordinate of the bottom right corner of the boundary
    uint public boundY2 = 0x800000000000000000000000000000000000000000000000000000000000000f;

    /// @dev Number used to divide the total number of house locations
    /// after any expansion to yield the number of auctions that  will be
    /// available to start for the expansion's duration
    uint public constant auctionsAvailableDivisor = 10;

    /// @dev Amount of time the King must wait between increasing the board
    uint public constant kingTimeBetweenIncrease = 2 weeks;

    /// @dev Amount of time the Wayfarer must wait between increasing the board
    uint public constant wayfarerTimeBetweenIncrease = 3 weeks;

    /// @dev Amount of time that anyone but the King or Wayfarer must wait
    ///  before increasing the board
    uint public constant plebTimeBetweenIncrease = 4 weeks;

    /// @dev The last time the board was increased in size
    uint public lastIncreaseTime;

    /// @dev The direction of the next increase
    uint8 public nextIncreaseDirection;

    /// @dev The number of auctions that players may choose to start
    ///  for this expansion
    uint public auctionsRemaining;

    constructor() public
    {
        // Game is paused as God must start it
        isPaused = true;

        // Set the auctions remaining
        setAuctionsAvailableForBounds();
    }

    /// @dev Fired when the board is increased in size
    event BoardSizeIncreased(
          address initiator
        , uint newBoundX1
        , uint newBoundY1
        , uint newBoundX2
        , uint newBoundY2
        , uint lastIncreaseTime
        , uint nextIncreaseDirection
        , uint auctionsRemaining
    );

    /// @dev Only the King can run this
    modifier onlyKing()
    {
        require(KingOfEthAbstractInterface(kingOfEthContract).king() == msg.sender);
        _;
    }

    /// @dev Only the Wayfarer can run this
    modifier onlyWayfarer()
    {
        require(KingOfEthAbstractInterface(kingOfEthContract).wayfarer() == msg.sender);
        _;
    }

    /// @dev Set the total auctions available
    function setAuctionsAvailableForBounds() private
    {
        uint boundDiffX = boundX2 - boundX1;
        uint boundDiffY = boundY2 - boundY1;

        auctionsRemaining = boundDiffX * boundDiffY / 2 / auctionsAvailableDivisor;
    }

    /// @dev Increase the board's size making sure to keep steady at
    ///  the maximum outer bounds
    function increaseBoard() private
    {
        // The length of increase
        uint _increaseLength;

        // If this increase direction is right
        if(0 == nextIncreaseDirection)
        {
            _increaseLength = boundX2 - boundX1;
            uint _updatedX2 = boundX2 + _increaseLength;

            // Stay within bounds
            if(_updatedX2 <= boundX2 || _updatedX2 <= _increaseLength)
            {
                boundX2 = ~uint(0);
            }
            else
            {
                boundX2 = _updatedX2;
            }
        }
        // If this increase direction is down
        else if(1 == nextIncreaseDirection)
        {
            _increaseLength = boundY2 - boundY1;
            uint _updatedY2 = boundY2 + _increaseLength;

            // Stay within bounds
            if(_updatedY2 <= boundY2 || _updatedY2 <= _increaseLength)
            {
                boundY2 = ~uint(0);
            }
            else
            {
                boundY2 = _updatedY2;
            }
        }
        // If this increase direction is left
        else if(2 == nextIncreaseDirection)
        {
            _increaseLength = boundX2 - boundX1;

            // Stay within bounds
            if(boundX1 <= _increaseLength)
            {
                boundX1 = 0;
            }
            else
            {
                boundX1 -= _increaseLength;
            }
        }
        // If this increase direction is up
        else if(3 == nextIncreaseDirection)
        {
            _increaseLength = boundY2 - boundY1;

            // Stay within bounds
            if(boundY1 <= _increaseLength)
            {
                boundY1 = 0;
            }
            else
            {
                boundY1 -= _increaseLength;
            }
        }

        // The last increase time is now
        lastIncreaseTime = now;

        // Set the next increase direction
        nextIncreaseDirection = (nextIncreaseDirection + 1) % 4;

        // Reset the auctions available
        setAuctionsAvailableForBounds();

        emit BoardSizeIncreased(
              msg.sender
            , boundX1
            , boundY1
            , boundX2
            , boundY2
            , now
            , nextIncreaseDirection
            , auctionsRemaining
        );
    }

    /// @dev God can start the game
    function godStartGame() public onlyGod
    {
        // Reset increase times
        lastIncreaseTime = now;

        // Unpause the game
        godUnpause();
    }

    /// @dev The auctions contracts can decrement the number
    ///  of auctions that are available to be started
    function auctionsDecrementAuctionsRemaining()
        public
        onlyAuctionsContract
    {
        auctionsRemaining -= 1;
    }

    /// @dev The auctions contracts can increment the number
    ///  of auctions that are available to be started when
    ///  an auction ends wihout a winner
    function auctionsIncrementAuctionsRemaining()
        public
        onlyAuctionsContract
    {
        auctionsRemaining += 1;
    }

    /// @dev The King can increase the board much faster than the plebs
    function kingIncreaseBoard()
        public
        onlyKing
    {
        // Require enough time has passed since the last increase
        require(lastIncreaseTime + kingTimeBetweenIncrease < now);

        increaseBoard();
    }

    /// @dev The Wayfarer can increase the board faster than the plebs
    function wayfarerIncreaseBoard()
        public
        onlyWayfarer
    {
        // Require enough time has passed since the last increase
        require(lastIncreaseTime + wayfarerTimeBetweenIncrease < now);

        increaseBoard();
    }

    /// @dev Any old pleb can increase the board
    function plebIncreaseBoard() public
    {
        // Require enough time has passed since the last increase
        require(lastIncreaseTime + plebTimeBetweenIncrease < now);

        increaseBoard();
    }
}

// File: contracts/KingOfEthBoardReferencer.sol

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


/// @title King of Eth: Board Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Functionality to allow contracts to reference the board contract
contract KingOfEthBoardReferencer is GodMode {
    /// @dev The address of the board contract
    address public boardContract;

    /// @dev Only the board contract can run this
    modifier onlyBoardContract()
    {
        require(boardContract == msg.sender);
        _;
    }

    /// @dev God can change the board contract
    /// @param _boardContract The new address
    function godSetBoardContract(address _boardContract)
        public
        onlyGod
    {
        boardContract = _boardContract;
    }
}

// File: contracts/KingOfEthHousesAbstractInterface.sol

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

/// @title King of Eth: Houses Abstract Interface
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Abstract interface contract for houses
contract KingOfEthHousesAbstractInterface {
    /// @dev Get the owner of the house at some location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @return The address of the owner
    function ownerOf(uint _x, uint _y) public view returns(address);

    /// @dev Get the level of the house at some location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @return The level of the house
    function level(uint _x, uint _y) public view returns(uint8);

    /// @dev The auctions contracts can set the owner of a house after an auction
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _owner The new owner of the house
    function auctionsSetOwner(uint _x, uint _y, address _owner) public;

    /// @dev The house realty contract can transfer house ownership
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _from The previous owner of house
    /// @param _to The new owner of house
    function houseRealtyTransferOwnership(
          uint _x
        , uint _y
        , address _from
        , address _to
    ) public;
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

// File: contracts/KingOfEthHouseRealty.sol

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






/// @title King of Eth: House Realty
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for controlling sales of houses
contract KingOfEthHouseRealty is
      GodMode
    , KingOfEthHousesReferencer
    , KingOfEthReferencer
{
    /// @dev The number that divides the amount payed for any sale to produce
    ///  the amount payed in taxes
    uint public constant taxDivisor = 25;

    /// @dev Mapping from the x, y coordinates of a house to the current sale
    ///  price (0 if there is no sale)
    mapping (uint => mapping (uint => uint)) housePrices;

    /// @dev Fired when there is a new house for sale
    event HouseForSale(
          uint x
        , uint y
        , address owner
        , uint amount
    );

    /// @dev Fired when the owner changes the price of a house
    event HousePriceChanged(uint x, uint y, uint amount);

    /// @dev Fired when a house is sold
    event HouseSold(
          uint x
        , uint y
        , address from
        , address to
        , uint amount
        , uint8 level
    );

    /// @dev Fired when the sale for a house is cancelled by the owner
    event HouseSaleCancelled(
          uint x
        , uint y
        , address owner
    );

    /// @dev Only the owner of the house at a location can run this
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    modifier onlyHouseOwner(uint _x, uint _y)
    {
        require(KingOfEthHousesAbstractInterface(housesContract).ownerOf(_x, _y) == msg.sender);
        _;
    }

    /// @dev This can only be run if there is *not* an existing sale for a house
    ///  at a location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    modifier noExistingHouseSale(uint _x, uint _y)
    {
        require(0 == housePrices[_x][_y]);
        _;
    }

    /// @dev This can only be run if there is an existing sale for a house
    ///  at a location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    modifier existingHouseSale(uint _x, uint _y)
    {
        require(0 != housePrices[_x][_y]);
        _;
    }

    /// @param _kingOfEthContract The address of the king contract
    constructor(address _kingOfEthContract) public
    {
        kingOfEthContract = _kingOfEthContract;
    }

    /// @dev The houses contract can cancel a sale when a house is transfered
    ///  to another player
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    function housesCancelHouseSale(uint _x, uint _y)
        public
        onlyHousesContract
    {
        // If there is indeed a sale
        if(0 != housePrices[_x][_y])
        {
            // Cancel the sale
            housePrices[_x][_y] = 0;

            emit HouseSaleCancelled(_x, _y, msg.sender);
        }
    }

    /// @dev The owner of a house can start a sale
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _askingPrice The price that must be payed by another player
    ///  to purchase the house
    function startHouseSale(uint _x, uint _y, uint _askingPrice)
        public
        notPaused
        onlyHouseOwner(_x, _y)
        noExistingHouseSale(_x, _y)
    {
        // Require that the price is at least 0
        require(0 != _askingPrice);

        // Record the price
        housePrices[_x][_y] = _askingPrice;

        emit HouseForSale(_x, _y, msg.sender, _askingPrice);
    }

    /// @dev The owner of a house can change the price of a sale
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _askingPrice The new price that must be payed by another
    ///  player to purchase the house
    function changeHousePrice(uint _x, uint _y, uint _askingPrice)
        public
        notPaused
        onlyHouseOwner(_x, _y)
        existingHouseSale(_x, _y)
    {
        // Require that the price is at least 0
        require(0 != _askingPrice);

        // Record the price
        housePrices[_x][_y] = _askingPrice;

        emit HousePriceChanged(_x, _y, _askingPrice);
    }

    /// @dev Anyone can purchase a house as long as the sale exists
    /// @param _x The y coordinate of the house
    /// @param _y The y coordinate of the house
    function purchaseHouse(uint _x, uint _y)
        public
        payable
        notPaused
        existingHouseSale(_x, _y)
    {
        // Require that the exact price was paid
        require(housePrices[_x][_y] == msg.value);

        // End the sale
        housePrices[_x][_y] = 0;

        // Calculate the taxes to be paid
        uint taxCut = msg.value / taxDivisor;

        // Pay the taxes
        KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(taxCut)();

        KingOfEthHousesAbstractInterface _housesContract = KingOfEthHousesAbstractInterface(housesContract);

        // Determine the previous owner
        address _oldOwner = _housesContract.ownerOf(_x, _y);

        // Send the buyer the house
        _housesContract.houseRealtyTransferOwnership(
              _x
            , _y
            , _oldOwner
            , msg.sender
        );

        // Send the previous owner his share
        _oldOwner.transfer(msg.value - taxCut);

        emit HouseSold(
              _x
            , _y
            , _oldOwner
            , msg.sender
            , msg.value
            , _housesContract.level(_x, _y)
        );
    }

    /// @dev The owner of a house can cancel a sale
    /// @param _x The y coordinate of the house
    /// @param _y The y coordinate of the house
    function cancelHouseSale(uint _x, uint _y)
        public
        notPaused
        onlyHouseOwner(_x, _y)
        existingHouseSale(_x, _y)
    {
        // Cancel the sale
        housePrices[_x][_y] = 0;

        emit HouseSaleCancelled(_x, _y, msg.sender);
    }
}

// File: contracts/KingOfEthHouseRealtyReferencer.sol

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


/// @title King of Eth: House Realty Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to reference the house realty contract
contract KingOfEthHouseRealtyReferencer is GodMode {
    /// @dev The realty contract's address
    address public houseRealtyContract;

    /// @dev Only the house realty contract can run this function
    modifier onlyHouseRealtyContract()
    {
        require(houseRealtyContract == msg.sender);
        _;
    }

    /// @dev God can set the house realty contract
    /// @param _houseRealtyContract The new address
    function godSetHouseRealtyContract(address _houseRealtyContract)
        public
        onlyGod
    {
        houseRealtyContract = _houseRealtyContract;
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

// File: contracts/KingOfEthHouses.sol

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














/// @title King of Eth: Houses
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for houses
contract KingOfEthHouses is
      GodMode
    , KingOfEthAuctionsReferencer
    , KingOfEthBoardReferencer
    , KingOfEthHouseRealtyReferencer
    , KingOfEthHousesAbstractInterface
    , KingOfEthReferencer
    , KingOfEthRoadsReferencer
    , KingOfEthResourcesInterfaceReferencer
{
    /// @dev ETH cost to build or upgrade a house
    uint public houseCost = 0.001 ether;

    /// @dev Struct to hold info about a house location on the board
    struct LocationInfo {
        /// @dev The owner of the house at this location
        address owner;

        /// @dev The level of the house at this location
        uint8 level;
    }

    /// @dev Mapping from the (x, y) coordinate of the location to its info
    mapping (uint => mapping (uint => LocationInfo)) locationInfo;

    /// @dev Mapping from a player's address to his points
    mapping (address => uint) pointCounts;

    /// @param _blindAuctionsContract The address of the blind auctions contract
    /// @param _boardContract The address of the board contract
    /// @param _kingOfEthContract The address of the king contract
    /// @param _houseRealtyContract The address of the house realty contract
    /// @param _openAuctionsContract The address of the open auctions contract
    /// @param _roadsContract The address of the roads contract
    /// @param _interfaceContract The address of the resources
    ///  interface contract
    constructor(
          address _blindAuctionsContract
        , address _boardContract
        , address _kingOfEthContract
        , address _houseRealtyContract
        , address _openAuctionsContract
        , address _roadsContract
        , address _interfaceContract
    )
        public
    {
        blindAuctionsContract = _blindAuctionsContract;
        boardContract         = _boardContract;
        kingOfEthContract     = _kingOfEthContract;
        houseRealtyContract   = _houseRealtyContract;
        openAuctionsContract  = _openAuctionsContract;
        roadsContract         = _roadsContract;
        interfaceContract     = _interfaceContract;
    }

    /// @dev Fired when new houses are built
    event NewHouses(address owner, uint[] locations);

    /// @dev Fired when a house is sent from one player to another
    event SentHouse(uint x, uint y, address from, address to, uint8 level);

    /// @dev Fired when a house is upgraded
    event UpgradedHouse(uint x, uint y, address owner, uint8 newLevel);

    /// @dev Get the owner of the house at some location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @return The address of the owner
    function ownerOf(uint _x, uint _y) public view returns(address)
    {
        return locationInfo[_x][_y].owner;
    }

    /// @dev Get the level of the house at some location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @return The level of the house
    function level(uint _x, uint _y) public view returns(uint8)
    {
        return locationInfo[_x][_y].level;
    }

    /// @dev Get the number of points held by a player
    /// @param _player The player's address
    /// @return The number of points
    function numberOfPoints(address _player) public view returns(uint)
    {
        return pointCounts[_player];
    }

    /// @dev Helper function to build a house at a location
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    function buildHouseInner(uint _x, uint _y) private
    {
        // Lookup the info about the house
        LocationInfo storage _locationInfo = locationInfo[_x][_y];

        KingOfEthBoard _boardContract = KingOfEthBoard(boardContract);

        // Require the house to be within the current bounds of the game
        require(_boardContract.boundX1() <= _x);
        require(_boardContract.boundY1() <= _y);
        require(_boardContract.boundX2() > _x);
        require(_boardContract.boundY2() > _y);

        // Require the spot to be empty
        require(0x0 == _locationInfo.owner);

        KingOfEthRoadsAbstractInterface _roadsContract = KingOfEthRoadsAbstractInterface(roadsContract);

        // Require either either the right, bottom, left or top road
        // to be owned by the player
        require(
                _roadsContract.ownerOf(_x, _y, 0) == msg.sender
             || _roadsContract.ownerOf(_x, _y, 1) == msg.sender
             || _roadsContract.ownerOf(_x - 1, _y, 0) == msg.sender
             || _roadsContract.ownerOf(_x, _y - 1, 1) == msg.sender
        );

        // Require that there is no existing blind auction at the location
        require(!KingOfEthAuctionsAbstractInterface(blindAuctionsContract).existingAuction(_x, _y));

        // Require that there is no existing open auction at the location
        require(!KingOfEthAuctionsAbstractInterface(openAuctionsContract).existingAuction(_x, _y));

        // Set new owner
        _locationInfo.owner = msg.sender;

        // Update player's points
        ++pointCounts[msg.sender];

        // Distribute resources to the player
        KingOfEthResourcesInterface(interfaceContract).distributeResources(
              msg.sender
            , _x
            , _y
            , 0 // Level 0
        );
    }

    /// @dev God can change the house cost
    /// @param _newHouseCost The new cost of a house
    function godChangeHouseCost(uint _newHouseCost)
        public
        onlyGod
    {
        houseCost = _newHouseCost;
    }

    /// @dev The auctions contracts can set the owner of a house after an auction
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _owner The new owner of the house
    function auctionsSetOwner(uint _x, uint _y, address _owner)
        public
        onlyAuctionsContract
    {
        // Lookup the info about the house
        LocationInfo storage _locationInfo = locationInfo[_x][_y];

        // Require that nobody already owns the house.
        // Note that this would be an assert if only the blind auctions
        // contract used this code, but the open auctions contract
        // depends on this require to save space.
        require(0x0 == _locationInfo.owner);

        // Set the house's new owner
        _locationInfo.owner = _owner;

        // Give the player a point for the house
        ++pointCounts[_owner];

        // Distribute the resources for the house
        KingOfEthResourcesInterface(interfaceContract).distributeResources(
              _owner
            , _x
            , _y
            , 0 // Level 0
        );

        // Set up the locations for the event
        uint[] memory _locations = new uint[](2);
        _locations[0] = _x;
        _locations[1] = _y;

        emit NewHouses(_owner, _locations);
    }

    /// @dev The house realty contract can transfer house ownership
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _from The previous owner of house
    /// @param _to The new owner of house
    function houseRealtyTransferOwnership(
          uint _x
        , uint _y
        , address _from
        , address _to
    )
        public
        onlyHouseRealtyContract
    {
        // Lookup the info about the house
        LocationInfo storage _locationInfo = locationInfo[_x][_y];

        // Assert that the previous owner still has the house
        assert(_locationInfo.owner == _from);

        // Set the new owner
        _locationInfo.owner = _to;

        // Calculate the total points of the house
        uint _points = _locationInfo.level + 1;

        // Update the point counts
        pointCounts[_from] -= _points;
        pointCounts[_to]   += _points;
    }

    /// @dev Build multiple houses at once
    /// @param _locations An array of coordinates for the houses. These
    ///  are specified sequentially like [x1, y1, x2, y2] representing
    ///  location (x1, y1) and location (x2, y2).
    function buildHouses(uint[] _locations)
        public
        payable
    {
        // Require that there are an even number of locations
        require(0 == _locations.length % 2);

        uint _count = _locations.length / 2;

        // Require the house cost
        require(houseCost * _count == msg.value);

        // Pay taxes
        KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(msg.value)();

        // Burn the required resource costs for the houses
        KingOfEthResourcesInterface(interfaceContract).burnHouseCosts(
              _count
            , msg.sender
        );

        // Build a house at each one of the locations
        for(uint i = 0; i < _locations.length; i += 2)
        {
            buildHouseInner(_locations[i], _locations[i + 1]);
        }

        emit NewHouses(msg.sender, _locations);
    }

    /// @dev Send a house to another player
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    /// @param _to The recipient of the house
    function sendHouse(uint _x, uint _y, address _to) public
    {
        // Lookup the info about the house
        LocationInfo storage _locationInfo = locationInfo[_x][_y];

        // Require that the sender is the owner
        require(_locationInfo.owner == msg.sender);

        // Set the new owner
        _locationInfo.owner = _to;

        // Calculate the points of the house
        uint _points = _locationInfo.level + 1;

        // Update point counts
        pointCounts[msg.sender] -= _points;
        pointCounts[_to]        += _points;

        // Cancel any sales that exist
        KingOfEthHouseRealty(houseRealtyContract).housesCancelHouseSale(_x, _y);

        emit SentHouse(_x, _y, msg.sender, _to, _locationInfo.level);
    }

    /// @dev Upgrade a house
    /// @param _x The x coordinate of the house
    /// @param _y The y coordinate of the house
    function upgradeHouse(uint _x, uint _y) public payable
    {
        // Lookup the info about the house
        LocationInfo storage _locationInfo = locationInfo[_x][_y];

        // Require that the sender is the owner
        require(_locationInfo.owner == msg.sender);

        // Require the house cost be payed
        require(houseCost == msg.value);

        // Pay the taxes
        KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(msg.value)();

        // Burn the resource costs of the upgrade
        KingOfEthResourcesInterface(interfaceContract).burnUpgradeCosts(
              _locationInfo.level
            , msg.sender
        );

        // Update the house's level
        ++locationInfo[_x][_y].level;

        // Update the owner's points
        ++pointCounts[msg.sender];

        // Distribute the resources for the house
        KingOfEthResourcesInterface(interfaceContract).distributeResources(
              msg.sender
            , _x
            , _y
            , _locationInfo.level
        );

        emit UpgradedHouse(_x, _y, msg.sender, _locationInfo.level);
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

// File: contracts/KingOfEthRoadRealtyReferencer.sol

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


/// @title King of Eth: Road Realty Referencer
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Provides functionality to reference the road realty contract
contract KingOfEthRoadRealtyReferencer is GodMode {
    /// @dev The realty contract's address
    address public roadRealtyContract;

    /// @dev Only the road realty contract can run this function
    modifier onlyRoadRealtyContract()
    {
        require(roadRealtyContract == msg.sender);
        _;
    }

    /// @dev God can set the road realty contract
    /// @param _roadRealtyContract The new address
    function godSetRoadRealtyContract(address _roadRealtyContract)
        public
        onlyGod
    {
        roadRealtyContract = _roadRealtyContract;
    }
}

// File: contracts/KingOfEthRoads.sol

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













/// @title King of Eth: Roads
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for roads
contract KingOfEthRoads is
      GodMode
    , KingOfEthBoardReferencer
    , KingOfEthHousesReferencer
    , KingOfEthReferencer
    , KingOfEthResourcesInterfaceReferencer
    , KingOfEthRoadRealtyReferencer
    , KingOfEthRoadsAbstractInterface
{
    /// @dev ETH cost to build a road
    uint public roadCost = 0.0002 ether;

    /// @dev Mapping from the x, y, direction coordinate of the location to its owner
    mapping (uint => mapping (uint => address[2])) owners;

    /// @dev Mapping from a players address to his road counts
    mapping (address => uint) roadCounts;

    /// @param _boardContract The address of the board contract
    /// @param _roadRealtyContract The address of the road realty contract
    /// @param _kingOfEthContract The address of the king contract
    /// @param _interfaceContract The address of the resources
    ///  interface contract
    constructor(
          address _boardContract
        , address _roadRealtyContract
        , address _kingOfEthContract
        , address _interfaceContract
    )
        public
    {
        boardContract      = _boardContract;
        roadRealtyContract = _roadRealtyContract;
        kingOfEthContract  = _kingOfEthContract;
        interfaceContract  = _interfaceContract;
    }

    /// @dev Fired when new roads are built
    event NewRoads(
          address owner
        , uint x
        , uint y
        , uint8 direction
        , uint length
    );

    /// @dev Fired when a road is sent from one player to another
    event SentRoad(
          uint x
        , uint y
        , uint direction
        , address from
        , address to
    );

    /// @dev Get the owner of the road at some location
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road (either
    ///  0 for right or 1 for down)
    /// @return The address of the owner
    function ownerOf(uint _x, uint _y, uint8 _direction)
        public
        view
        returns(address)
    {
        // Only 0 or 1 is a valid direction
        require(2 > _direction);

        return owners[_x][_y][_direction];
    }

    /// @dev Get the number of roads owned by a player
    /// @param _player The player's address
    /// @return The number of roads
    function numberOfRoads(address _player) public view returns(uint)
    {
        return roadCounts[_player];
    }

    /// @dev Only the owner of a road can run this
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    modifier onlyRoadOwner(uint _x, uint _y, uint8 _direction)
    {
        require(owners[_x][_y][_direction] == msg.sender);
        _;
    }

    /// @dev Build houses to the right
    /// @param _x The x coordinate of the starting point of the first road
    /// @param _y The y coordinate of the starting point of the first road
    /// @param _length The length to build
    function buildRight(uint _x, uint _y, uint _length) private
    {
        // Require that nobody currently owns the road
        require(0x0 == owners[_x][_y][0]);

        KingOfEthHousesAbstractInterface _housesContract = KingOfEthHousesAbstractInterface(housesContract);

        // Require that either the player owns the house at the
        // starting location, the road below it, the road to the
        // left of it, or the road above it
        address _houseOwner = _housesContract.ownerOf(_x, _y);
        require(_houseOwner == msg.sender || (0x0 == _houseOwner && (
               owners[_x][_y][1] == msg.sender
            || owners[_x - 1][_y][0] == msg.sender
            || owners[_x][_y - 1][1] == msg.sender
        )));

        // Set the new owner
        owners[_x][_y][0] = msg.sender;

        for(uint _i = 1; _i < _length; ++_i)
        {
            // Require that nobody currently owns the road
            require(0x0 == owners[_x + _i][_y][0]);

            // Require that either the house location is empty or
            // that it is owned by the player
            require(
                   _housesContract.ownerOf(_x + _i, _y) == 0x0
                || _housesContract.ownerOf(_x + _i, _y) == msg.sender
            );

            // Set the new owner
            owners[_x + _i][_y][0] = msg.sender;
        }
    }

    /// @dev Build houses downwards
    /// @param _x The x coordinate of the starting point of the first road
    /// @param _y The y coordinate of the starting point of the first road
    /// @param _length The length to build
    function buildDown(uint _x, uint _y, uint _length) private
    {
        // Require that nobody currently owns the road
        require(0x0 == owners[_x][_y][1]);

        KingOfEthHousesAbstractInterface _housesContract = KingOfEthHousesAbstractInterface(housesContract);

        // Require that either the player owns the house at the
        // starting location, the road to the right of it, the road to
        // the left of it, or the road above it
        address _houseOwner = _housesContract.ownerOf(_x, _y);
        require(_houseOwner == msg.sender || (0x0 == _houseOwner && (
               owners[_x][_y][0] == msg.sender
            || owners[_x - 1][_y][0] == msg.sender
            || owners[_x][_y - 1][1] == msg.sender
        )));

        // Set the new owner
        owners[_x][_y][1] = msg.sender;

        for(uint _i = 1; _i < _length; ++_i)
        {
            // Require that nobody currently owns the road
            require(0x0 == owners[_x][_y + _i][1]);

            // Require that either the house location is empty or
            // that it is owned by the player
            require(
                   _housesContract.ownerOf(_x, _y + _i) == 0x0
                || _housesContract.ownerOf(_x, _y + _i) == msg.sender
            );

            // Set the new owner
            owners[_x][_y + _i][1] = msg.sender;
        }
    }

    /// @dev Build houses to the left
    /// @param _x The x coordinate of the starting point of the first road
    /// @param _y The y coordinate of the starting point of the first road
    /// @param _length The length to build
    function buildLeft(uint _x, uint _y, uint _length) private
    {
        // Require that nobody currently owns the road
        require(0x0 == owners[_x - 1][_y][0]);

        KingOfEthHousesAbstractInterface _housesContract = KingOfEthHousesAbstractInterface(housesContract);

        // Require that either the player owns the house at the
        // starting location, the road to the right of it, the road
        // below it, or the road above it
        address _houseOwner = _housesContract.ownerOf(_x, _y);
        require(_houseOwner == msg.sender || (0x0 == _houseOwner && (
               owners[_x][_y][0] == msg.sender
            || owners[_x][_y][1] == msg.sender
            || owners[_x][_y - 1][1] == msg.sender
        )));

        // Set the new owner
        owners[_x - 1][_y][0] = msg.sender;

        for(uint _i = 1; _i < _length; ++_i)
        {
            // Require that nobody currently owns the road
            require(0x0 == owners[_x - _i - 1][_y][0]);

            // Require that either the house location is empty or
            // that it is owned by the player
            require(
                   _housesContract.ownerOf(_x - _i, _y) == 0x0
                || _housesContract.ownerOf(_x - _i, _y) == msg.sender
            );

            // Set the new owner
            owners[_x - _i - 1][_y][0] = msg.sender;
        }
    }

    /// @dev Build houses upwards
    /// @param _x The x coordinate of the starting point of the first road
    /// @param _y The y coordinate of the starting point of the first road
    /// @param _length The length to build
    function buildUp(uint _x, uint _y, uint _length) private
    {
        // Require that nobody currently owns the road
        require(0x0 == owners[_x][_y - 1][1]);

        KingOfEthHousesAbstractInterface _housesContract = KingOfEthHousesAbstractInterface(housesContract);

        // Require that either the player owns the house at the
        // starting location, the road to the right of it, the road
        // below it, or the road to the left of it
        address _houseOwner = _housesContract.ownerOf(_x, _y);
        require(_houseOwner == msg.sender || (0x0 == _houseOwner && (
               owners[_x][_y][0] == msg.sender
            || owners[_x][_y][1] == msg.sender
            || owners[_x - 1][_y][0] == msg.sender
        )));

        // Set the new owner
        owners[_x][_y - 1][1] = msg.sender;

        for(uint _i = 1; _i < _length; ++_i)
        {
            // Require that nobody currently owns the road
            require(0x0 == owners[_x][_y - _i - 1][1]);

            // Require that either the house location is empty or
            // that it is owned by the player
            require(
                   _housesContract.ownerOf(_x, _y - _i) == 0x0
                || _housesContract.ownerOf(_x, _y - _i) == msg.sender
            );

            // Set the new owner
            owners[_x][_y - _i - 1][1] = msg.sender;
        }
    }

    /// @dev God can change the road cost
    /// @param _newRoadCost The new cost of a road
    function godChangeRoadCost(uint _newRoadCost)
        public
        onlyGod
    {
        roadCost = _newRoadCost;
    }

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
    )
        public
        onlyRoadRealtyContract
    {
        // Assert that the previous owner still has the road
        assert(owners[_x][_y][_direction] == _from);

        // Set the new owner
        owners[_x][_y][_direction] = _to;

        // Update the road counts
        --roadCounts[_from];
        ++roadCounts[_to];
    }

    /// @dev Build a road in a direction from a location
    /// @param _x The x coordinate of the starting location
    /// @param _y The y coordinate of the starting location
    /// @param _direction The direction to build (right is 0, down is 1,
    ///  2 is left, and 3 is up)
    /// @param _length The number of roads to build
    function buildRoads(
          uint _x
        , uint _y
        , uint8 _direction
        , uint _length
    )
        public
        payable
    {
        // Require at least one road to be built
        require(0 < _length);

        // Require that the cost for each road was payed
        require(roadCost * _length == msg.value);

        KingOfEthBoard _boardContract = KingOfEthBoard(boardContract);

        // Require that the start is within bounds
        require(_boardContract.boundX1() <= _x);
        require(_boardContract.boundY1() <= _y);
        require(_boardContract.boundX2() > _x);
        require(_boardContract.boundY2() > _y);

        // Burn the resource costs for each road
        KingOfEthResourcesInterface(interfaceContract).burnRoadCosts(
              _length
            , msg.sender
        );

        // If the direction is right
        if(0 == _direction)
        {
            // Require that the roads will be in bounds
            require(_boardContract.boundX2() > _x + _length);

            buildRight(_x, _y, _length);
        }
        // If the direction is down
        else if(1 == _direction)
        {
            // Require that the roads will be in bounds
            require(_boardContract.boundY2() > _y + _length);

            buildDown(_x, _y, _length);
        }
        // If the direction is left
        else if(2 == _direction)
        {
            // Require that the roads will be in bounds
            require(_boardContract.boundX1() < _x - _length - 1);

            buildLeft(_x, _y, _length);
        }
        // If the direction is up
        else if(3 == _direction)
        {
            // Require that the roads will be in bounds
            require(_boardContract.boundY1() < _y - _length - 1);

            buildUp(_x, _y, _length);
        }
        else
        {
            // Revert if the direction is invalid
            revert();
        }

        // Update the number of roads of the player
        roadCounts[msg.sender] += _length;

        // Pay taxes
        KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(msg.value)();

        emit NewRoads(msg.sender, _x, _y, _direction, _length);
    }

    /// @dev Send a road to another player
    /// @param _x The x coordinate of the road
    /// @param _y The y coordinate of the road
    /// @param _direction The direction of the road
    /// @param _to The recipient of the road
    function sendRoad(uint _x, uint _y, uint8 _direction, address _to)
        public
        onlyRoadOwner(_x, _y, _direction)
    {
        // Set the new owner
        owners[_x][_y][_direction] = _to;

        // Update road counts
        --roadCounts[msg.sender];
        ++roadCounts[_to];

        // Cancel any sales that exist
        KingOfEthRoadRealty(roadRealtyContract).roadsCancelRoadSale(
              _x
            , _y
            , _direction
        );

        emit SentRoad(_x, _y, _direction, msg.sender, _to);
    }
}

// File: contracts/KingOfEth.sol

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








/// @title King of Eth
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for titles, and taxes
contract KingOfEth is
      GodMode
    , KingOfEthHousesReferencer
    , KingOfEthRoadsReferencer
    , KingOfEthResourcesInterfaceReferencer
{
    /// @dev Number used to divide the taxes to yield the King's share
    uint public constant kingsTaxDivisor = 5;

    /// @dev Number used to divide the taxes to yield the Wayfarer's share
    uint public constant wayfarersTaxDivisor = 20;

    /// @dev Number used to divide the taxes to yield Parliament's share
    uint public constant parliamentsTaxDivisor = 4;

    /// @dev Amount of time the King, Wayfarer, and Paliament must wait
    ///  between claiming/distributing their taxes
    uint public constant timeBetweenClaims = 2 weeks;

    /// @dev Amount of time the King or Parliement has to claim/distribute
    ///  their taxes before the other side is able to overthrow them
    uint public constant gracePeriod = 1 days;

    /// @dev The address of the current King
    address public king;

    /// @dev The amount of taxes currently reserved for the King
    uint public kingsTaxes;

    /// @dev The last time that the King claimed his taxes
    uint public kingsTaxesLastClaimed;

    /// @dev The address of the current Wayfarer
    address public wayfarer;

    /// @dev The amount of taxes currently reserved for the Wayfarer
    uint public wayfarersTaxes;

    /// @dev The last time that the Wayfarer claimed his taxes
    uint public wayfarersTaxesLastClaimed;

    /// @dev Relevant data for each seat of Parliament
    struct ParliamentSeatData {
        /// @dev The number of resource points the seat holds
        uint points;

        /// @dev The amount of unclaimed taxes the seat has
        ///  and can claim at any time
        uint unclaimedTaxes;
    }

    /// @dev The 10 seats of Parliament
    address[10] public parliamentSeats;

    /// @dev Mapping from an arbitrary address to data about a seat
    ///  of Parliament (this data exists only for the current seats)
    mapping (address => ParliamentSeatData) parliamentSeatData;

    /// @dev The number of taxes currently reserved for Parliament
    uint public parliamentsTaxes;

    /// @dev The last time that Parliament's taxes were distributed
    uint public parliamentsTaxesLastDistributed;

    /// @param _interfaceContract The address for the resources
    ///  interface contract
    constructor(address _interfaceContract) public
    {
        interfaceContract = _interfaceContract;

        // Game is paused as God must start it
        isPaused = true;
    }

    /// @dev Fired when the King's taxes are claimed
    event KingsTaxesClaimed(address king, uint claimedTime);

    /// @dev Fired when the Wayfarer's taxes are claimed
    event WayfarersTaxesClaimed(address wayfarer, uint claimedTime);

    /// @dev Fired when a seat in Parliament claims their
    ///  unclaimed taxes
    event ParliamentTaxesClaimed(address seat);

    /// @dev Fired when a new King claims the throne
    event NewKing(address king);

    /// @dev Fired when a new Wayfarer claims the title
    event NewWayfarer(address wayfarer);

    /// @dev Fired when a player claims a seat in Parliament
    event ParliamentSeatClaimed(address seat, uint points);

    /// @dev Fired when a successful inquest is made against a
    ///  seat of Parliament
    event ParliamentInquest(address seat, uint points);

    /// @dev Fired when Parliament's taxes are distributed
    event ParliamentsTaxesDistributed(
          address distributor
        , uint share
        , uint distributedTime
    );

    /// @dev Fired when Parliament is overthrown by the king
    event ParliamentOverthrown(uint overthrownTime);

    /// @dev Fired when the King is overthrown by Parliament
    event KingOverthrown(uint overthrownTime);

    /// @dev Only the King can run this
    modifier onlyKing()
    {
        require(king == msg.sender);
        _;
    }

    /// @dev Only the Wayfarer can run this
    modifier onlyWayfarer()
    {
        require(wayfarer == msg.sender);
        _;
    }

    /// @dev Only a Parliament seat can run this
    modifier onlyParliamentSeat()
    {
        require(0 != parliamentSeatData[msg.sender].points);
        _;
    }

    /// @dev God can withdraw his taxes
    function godWithdrawTaxes()
        public
        onlyGod
    {
        // Add up each Parliament seat's unclaimed taxes
        uint _parliamentsUnclaimed = 0;
        for(uint8 _i = 0; _i < 10; ++_i)
        {
            _parliamentsUnclaimed += parliamentSeatData[parliamentSeats[_i]].unclaimedTaxes;
        }

        // God's share is the balance minus the king's, the wayfarer's,
        //  Parliament's, as well as any of Parliament's seat's unclaimed taxes
        uint taxes = address(this).balance - kingsTaxes - wayfarersTaxes
                   - parliamentsTaxes - _parliamentsUnclaimed;

        god.transfer(taxes);
    }

    /// @dev God can start the game
    function godStartGame() public onlyGod
    {
        // Reset time title taxes were last claimed
        kingsTaxesLastClaimed           = now;
        wayfarersTaxesLastClaimed       = now;
        parliamentsTaxesLastDistributed = now;

        // Unpause the game
        isPaused = false;
    }

    /// @dev The King can claim his taxes
    function kingWithdrawTaxes()
        public
        onlyKing
    {
        // Require that enought time has passed since the King's last claim
        require(kingsTaxesLastClaimed + timeBetweenClaims < now);

        // The last claim time is now
        kingsTaxesLastClaimed = now;

        // Temporarily save the King's taxes
        uint _taxes = kingsTaxes;

        // Reset the King's taxes
        kingsTaxes = 0;

        king.transfer(_taxes);

        emit KingsTaxesClaimed(msg.sender, now);
    }

    /// @dev The Wayfarer can claim his taxes
    function wayfarerWithdrawTaxes()
        public
        onlyWayfarer
    {
        // Require that enough time has passed since the Wayfarer's last claim
        require(wayfarersTaxesLastClaimed + timeBetweenClaims < now);

        // The last claim time is now
        wayfarersTaxesLastClaimed = now;

        // Temporarily save the Wayfarer's taxes
        uint _taxes = wayfarersTaxes;

        // Reset the Wayfarer's taxes
        wayfarersTaxes = 0;

        wayfarer.transfer(_taxes);

        emit WayfarersTaxesClaimed(msg.sender, now);
    }

    /// @dev A seat of Parliament can withdraw any unclaimed taxes
    function parliamentWithdrawTaxes()
        public
    {
        // Lookup the data on the sender
        ParliamentSeatData storage _senderData = parliamentSeatData[msg.sender];

        // If the sender does indeed have unclaimed taxes
        if(0 != _senderData.unclaimedTaxes)
        {
            // Temporarily save the taxes
            uint _taxes = _senderData.unclaimedTaxes;

            // Mark the taxes as claimed
            _senderData.unclaimedTaxes = 0;

            // Send the sender the unclaimed taxes
            msg.sender.transfer(_taxes);
        }

        emit ParliamentTaxesClaimed(msg.sender);
    }

    /// @dev Claim the King's throne
    function claimThrone() public
    {
        KingOfEthHouses _housesContract = KingOfEthHouses(housesContract);

        // Require the claimant to have more points than the King
        require(_housesContract.numberOfPoints(king) < _housesContract.numberOfPoints(msg.sender));

        // Save the new King
        king = msg.sender;

        emit NewKing(msg.sender);
    }

    /// @dev Claim the Wayfarer's title
    function claimWayfarerTitle() public
    {
        KingOfEthRoads _roadsContract = KingOfEthRoads(roadsContract);

        // Require the claimant to have more roads than the wayfarer
        require(_roadsContract.numberOfRoads(wayfarer) < _roadsContract.numberOfRoads(msg.sender));

        // Save the new Wayfarer
        wayfarer = msg.sender;

        emit NewWayfarer(msg.sender);
    }

    /// @dev Claim a seat in Parliament
    function claimParliamentSeat() public
    {
        // Lookup the sender's data
        ParliamentSeatData storage _senderData = parliamentSeatData[msg.sender];

        // If the sender is not already in Parliament
        if(0 == _senderData.points)
        {
            // Determine the points of the sender
            uint _points
                = KingOfEthResourcesInterface(interfaceContract).lookupResourcePoints(msg.sender);

            // Lookup the lowest seat in parliament (the last seat)
            ParliamentSeatData storage _lastSeat = parliamentSeatData[parliamentSeats[9]];

            // If the lowest ranking seat has fewer points than the sender
            if(_lastSeat.points < _points)
            {
                // If the lowest ranking seat has unclaimed taxes
                if(0 != _lastSeat.unclaimedTaxes)
                {
                    // Put them back into Parliament's pool
                    parliamentsTaxes += _lastSeat.unclaimedTaxes;
                }

                // Delete the lowest seat's data
                delete parliamentSeatData[parliamentSeats[9]];

                // Record the sender's points
                _senderData.points = _points;

                // Record the new seat's temporary standing
                parliamentSeats[_i] = msg.sender;

                uint8 _i;

                // Move the new seat up until they are in the correct position
                for(_i = 8; _i >= 0; --_i)
                {
                    // If the seat above has fewer points than the new seat
                    if(parliamentSeatData[parliamentSeats[_i]].points < _points)
                    {
                        // Move the seat above down
                        parliamentSeats[_i + 1] = parliamentSeats[_i];
                    }
                    else
                    {
                        // We have found the new seat's position
                        parliamentSeats[_i] = msg.sender;

                        break;
                    }
                }

                emit ParliamentSeatClaimed(msg.sender, _points);
            }
        }
    }

    /// @dev Question the standing of a current seat in Parliament
    /// @param _seat The seat to run the inquest on
    function parliamentInquest(address _seat) public
    {
        // Grab the seat's data
        ParliamentSeatData storage _seatData = parliamentSeatData[_seat];

        // Ensure that the account in question is actually in Parliament
        if(0 != _seatData.points)
        {
            // Determine the current points held by the seat
            uint _newPoints
                = KingOfEthResourcesInterface(interfaceContract).lookupResourcePoints(_seat);

            uint _i;

            // If the seat has more points than before
            if(_seatData.points < _newPoints)
            {
                // Find the seat's current location
                _i = 9;
                while(_seat != parliamentSeats[_i])
                {
                    --_i;
                }

                // For each seat higher than the seat in question
                for(; _i > 0; --_i)
                {
                    // If the higher seat has fewer points than the seat in question
                    if(parliamentSeatData[parliamentSeats[_i - 1]].points < _newPoints)
                    {
                        // Move the seat back
                        parliamentSeats[_i] = parliamentSeats[_i - 1];
                    }
                    else
                    {
                        // Record the seat's (new) position
                        parliamentSeats[_i] = _seat;

                        break;
                    }
                }
            }
            // If the seat has the same number of points
            else if(_seatData.points == _newPoints)
            {
                revert();
            }
            // If the seat has fewer points than before
            else
            {
                // Find the seat's current position
                _i = 0;
                while(_seat != parliamentSeats[_i])
                {
                    ++_i;
                }

                // For each seat lower than the seat in question
                for(; _i < 10; ++_i)
                {
                    // If the lower seat has more points than the seat in question
                    if(parliamentSeatData[parliamentSeats[_i + 1]].points > _newPoints)
                    {
                        // Move the lower seat up
                        parliamentSeats[_i] = parliamentSeats[_i + 1];
                    }
                    else
                    {
                        // Record the seat's (new) position
                        parliamentSeats[_i] = _seat;

                        break;
                    }
                }
            }

            // Save the seat in question's points
            _seatData.points = _newPoints;

            emit ParliamentInquest(_seat, _newPoints);
        }
    }

    /// @dev Distribute the taxes set aside for Parliament to
    ///  the seats of Parliament
    function distributeParliamentTaxes()
        public
        onlyParliamentSeat
    {
        // Require enough time has passed since Parliament's last taxes
        // were distributed
        require(parliamentsTaxesLastDistributed + timeBetweenClaims < now);

        // Determine the share for each seat of Parliament (plus an additional
        // share for the distributor)
        uint _share = parliamentsTaxes / 11;

        // Calculate the distributor's share
        uint _distributorsShare = parliamentsTaxes - _share * 9;

        // Reset Parliament's claimable taxes
        parliamentsTaxes = 0;

        // For each seat of Parliament
        for(uint8 _i = 0; _i < 10; ++_i)
        {
            // If the distributor is not the seat in question
            if(msg.sender != parliamentSeats[_i])
            {
                // Add the share to the seat's unclaimedTaxes
                parliamentSeatData[parliamentSeats[_i]].unclaimedTaxes += _share;
            }
        }

        // Set the last time the taxes were distributed to now
        parliamentsTaxesLastDistributed = now;

        // Send the distributor their double share
        msg.sender.transfer(_distributorsShare);

        emit ParliamentsTaxesDistributed(msg.sender, _share, now);
    }

    /// @dev If the grace period has elapsed, the king can overthrow
    ///  Parliament and claim their taxes
    function overthrowParliament()
        public
        onlyKing
    {
        // Require that the time between claims plus
        //  the grace period has elapsed
        require(parliamentsTaxesLastDistributed + timeBetweenClaims + gracePeriod < now);

        // The king can now claim Parliament's taxes as well
        kingsTaxes += parliamentsTaxes;

        // Parliament has lost their taxes
        parliamentsTaxes = 0;

        // Parliament must wait before distributing their taxes again
        parliamentsTaxesLastDistributed = now;

        emit ParliamentOverthrown(now);
    }

    /// @dev If the grace period has elapsed, Parliament can overthrow
    ///  the king and claim his taxes
    function overthrowKing()
        public
        onlyParliamentSeat
    {
        // Require the time between claims plus
        // the grace period has elapsed
        require(kingsTaxesLastClaimed + timeBetweenClaims + gracePeriod < now);

        // Parliament can now claim the King's taxes as well
        parliamentsTaxes += kingsTaxes;

        // The King has lost his taxes
        kingsTaxes = 0;

        // The King must wait before claiming his taxes again
        kingsTaxesLastClaimed = now;

        emit KingOverthrown(now);
    }

    /// @dev Anyone can pay taxes
    function payTaxes() public payable
    {
        // Add the King's share
        kingsTaxes += msg.value / kingsTaxDivisor;

        // Add the Wayfarer's share
        wayfarersTaxes += msg.value / wayfarersTaxDivisor;

        // Add Parliament's share
        parliamentsTaxes += msg.value / parliamentsTaxDivisor;
    }
}