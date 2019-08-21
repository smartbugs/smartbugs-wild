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