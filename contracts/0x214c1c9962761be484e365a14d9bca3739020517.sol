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

// File: contracts/KingOfEthOpenAuctions.sol

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










/// @title King of Eth: Open Auctions
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev Contract for open auctions of houses
contract KingOfEthOpenAuctions is
      GodMode
    , KingOfEthAuctionsAbstractInterface
    , KingOfEthReferencer
    , KingOfEthBlindAuctionsReferencer
    , KingOfEthBoardReferencer
    , KingOfEthHousesReferencer
{
    /// @dev Data for an auction
    struct Auction {
        /// @dev The time the auction started
        uint startTime;

        /// @dev The (current) winning bid
        uint winningBid;

        /// @dev The address of the (current) winner
        address winner;
    }

    /// @dev Mapping from location (x, y) to the auction at that location
    mapping (uint => mapping (uint => Auction)) auctions;

    /// @dev The span of time that players may bid on an auction
    uint public constant bidSpan = 20 minutes;

    /// @param _kingOfEthContract The address for the king contract
    /// @param _blindAuctionsContract The address for the blind auctions contract
    /// @param _boardContract The address for the board contract
    constructor(
          address _kingOfEthContract
        , address _blindAuctionsContract
        , address _boardContract
    )
        public
    {
        kingOfEthContract     = _kingOfEthContract;
        blindAuctionsContract = _blindAuctionsContract;
        boardContract         = _boardContract;

        // Auctions are not allowed before God has begun the game
        isPaused = true;
    }

    /// @dev Fired when a new auction is started
    event OpenAuctionStarted(
          uint x
        , uint y
        , address starter
        , uint startTime
    );

    /// @dev Fired when a new bid is placed
    event OpenBidPlaced(uint x, uint y, address bidder, uint amount);

    /// @dev Fired when an auction is closed
    event OpenAuctionClosed(uint x, uint y, address newOwner, uint amount);

    /// @dev Determines if there is an auction at a particular location
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    /// @return true if there is an existing auction
    function existingAuction(uint _x, uint _y) public view returns(bool)
    {
        return 0 != auctions[_x][_y].startTime;
    }

    /// @dev Create an auction at a particular location
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    function createAuction(uint _x, uint _y) public notPaused
    {
        // Require that there is not an auction already started at
        // the location
        require(0 == auctions[_x][_y].startTime);

        // Require that there is no blind auction at that location
        require(!KingOfEthAuctionsAbstractInterface(blindAuctionsContract).existingAuction(_x, _y));

        KingOfEthBoard _board = KingOfEthBoard(boardContract);

        // Require that there is at least one available auction remaining
        require(0 < _board.auctionsRemaining());

        // Require that the auction is within the current bounds of the board
        require(_board.boundX1() < _x);
        require(_board.boundY1() < _y);
        require(_board.boundX2() > _x);
        require(_board.boundY2() > _y);

        // Require that nobody currently owns the house
        require(0x0 == KingOfEthHousesAbstractInterface(housesContract).ownerOf(_x, _y));

        // Use up an available auction
        _board.auctionsDecrementAuctionsRemaining();

        auctions[_x][_y].startTime = now;

        emit OpenAuctionStarted(_x, _y, msg.sender, now);
    }

    /// @dev Make a bid on an auction. The amount bid is the amount sent
    ///  with the transaction.
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    function placeBid(uint _x, uint _y) public payable notPaused
    {
        // Lookup the auction
        Auction storage _auction = auctions[_x][_y];

        // Require that the auction actually exists
        require(0 != _auction.startTime);

        // Require that it is still during the bid span
        require(_auction.startTime + bidSpan > now);

        // If the new bid is larger than the current winning bid
        if(_auction.winningBid < msg.value)
        {
            // Temporarily save the old winning values
            uint    _oldWinningBid = _auction.winningBid;
            address _oldWinner     = _auction.winner;

            // Store the new winner
            _auction.winningBid = msg.value;
            _auction.winner     = msg.sender;

            // Send the loser back their ETH
            if(0 < _oldWinningBid) {
                _oldWinner.transfer(_oldWinningBid);
            }
        }
        else
        {
            // Return the sender their ETH
            msg.sender.transfer(msg.value);
        }

        emit OpenBidPlaced(_x, _y, msg.sender, msg.value);
    }

    /// @dev Close an auction and distribute the bid amount as taxes
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    function closeAuction(uint _x, uint _y) public notPaused
    {
        // Lookup the auction
        Auction storage _auction = auctions[_x][_y];

        // Require that the auction actually exists
        require(0 != _auction.startTime);

        // If nobody won the auction
        if(0x0 == _auction.winner)
        {
            // Mark that there is no current auction for this location
            _auction.startTime = 0;

            // Allow another auction to be created
            KingOfEthBoard(boardContract).auctionsIncrementAuctionsRemaining();
        }
        // If a player won the auction
        else
        {
            // Set the auction's winner as the owner of the house.
            // Note that this will fail if there is already an owner so we
            // don't need to mark the auction as closed with some extra
            // variable.
            KingOfEthHousesAbstractInterface(housesContract).auctionsSetOwner(
                  _x
                , _y
                , _auction.winner
            );

            // Pay the taxes
            KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(_auction.winningBid)();
        }

        emit OpenAuctionClosed(_x, _y, _auction.winner, _auction.winningBid);
    }
}