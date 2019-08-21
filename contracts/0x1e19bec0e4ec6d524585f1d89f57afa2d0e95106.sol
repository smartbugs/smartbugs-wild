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

// File: contracts/KingOfEthBlindAuctions.sol

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










/// @title King of Eth: Blind Auctions
/// @author Anthony Burzillo <burz@burznest.com>
/// @dev This contracts provides the functionality for blind
///  for houses auctions
contract KingOfEthBlindAuctions is
      GodMode
    , KingOfEthReferencer
    , KingOfEthBoardReferencer
    , KingOfEthHousesReferencer
    , KingOfEthOpenAuctionsReferencer
{
    /// @dev A blinded bid
    struct Bid {
        /// @dev The hash value of the blinded bid
        bytes32 blindedBid;

        /// @dev The deposit that was made with the bid
        uint deposit;
    }

    /// @dev Information about a particular auction
    struct AuctionInfo {
        /// @dev The auction's x coordinate
        uint x;

        /// @dev The auction's y coordinate
        uint y;

        /// @dev The auctions's starting time
        uint startTime;

        /// @dev The blinded bids that each address made on the auction
        mapping (address => Bid[]) bids;

        /// @dev The total amount of unrevealed deposits for the auction
        uint unrevealedAmount;

        /// @dev The address of placer of the top revealed bid
        address topBidder;

        /// @dev The value of the top revealed bid
        uint topBid;

        /// @dev Has the auction been closed?
        bool closed;
    }

    /// @dev The span of time that players may bid on an auction
    uint public constant bidSpan = 10 minutes;

    /// @dev The span of time that players may reveal bids (after
    ///  the bid span)
    uint public constant revealSpan = 10 minutes;

    /// @dev The id that will be used for the next auction.
    ///  Note this is set to one so that checking a house without
    ///  an auction id does not resolve to an auction.
    ///  The contract will have to be replaced if all the ids are
    ///  used.
    uint public nextAuctionId = 1;

    /// @dev A mapping from an x, y coordinate to the id of a corresponding auction
    mapping (uint => mapping (uint => uint)) auctionIds;

    /// @dev A mapping from the id of an auction to the info about the auction
    mapping (uint => AuctionInfo) auctionInfo;

    /// @param _kingOfEthContract The address for the king contract
    /// @param _boardContract The address for the board contract
    constructor(
          address _kingOfEthContract
        , address _boardContract
    )
        public
    {
        kingOfEthContract = _kingOfEthContract;
        boardContract     = _boardContract;

        // Auctions are not allowed before God has begun the game
        isPaused = true;
    }

    /// @dev Fired when a new auction is started
    event BlindAuctionStarted(
          uint id
        , uint x
        , uint y
        , address starter
        , uint startTime
    );

    /// @dev Fired when a player places a new bid
    event BlindBidPlaced(
          uint id
        , address bidder
        , uint maxAmount
    );

    /// @dev Fired when a player reveals some bids
    event BlindBidsRevealed(
          uint id
        , address revealer
        , uint topBid
    );

    /// @dev Fired when a player closes an auction
    event BlindAuctionClosed(
          uint id
        , uint x
        , uint y
        , address newOwner
        , uint amount
    );

    /// @dev Create the hash of a blinded bid using keccak256
    /// @param _bid The true bid amount
    /// @param _isFake Is the bid fake?
    /// @param _secret The secret seed
    function blindedBid(uint _bid, bool _isFake, bytes32 _secret)
        public
        pure
        returns(bytes32)
    {
        return keccak256(abi.encodePacked(_bid, _isFake, _secret));
    }

    /// @dev Determines if there is an auction at a particular location
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    /// @return true if there is an existing auction
    function existingAuction(uint _x, uint _y) public view returns(bool)
    {
        return 0 != auctionInfo[auctionIds[_x][_y]].startTime;
    }

    /// @dev Create an auction at a particular location
    /// @param _x The x coordinate of the auction
    /// @param _y The y coordinate of the auction
    function createAuction(uint _x, uint _y) public notPaused
    {
        // Require that there is not already a started auction
        // at that location
        require(0 == auctionInfo[auctionIds[_x][_y]].startTime);

        // Require that there is not currently an open auction at
        // the location
        require(!KingOfEthAuctionsAbstractInterface(openAuctionsContract).existingAuction(_x, _y));

        KingOfEthBoard _board = KingOfEthBoard(boardContract);

        // Require that there is at least one available auction remaining
        require(0 < _board.auctionsRemaining());

        // Require that the auction is within the current bounds of the board
        require(_board.boundX1() < _x);
        require(_board.boundY1() < _y);
        require(_board.boundX2() > _x);
        require(_board.boundY2() > _y);

        // Require that nobody current owns the house
        require(0x0 == KingOfEthHousesAbstractInterface(housesContract).ownerOf(_x, _y));

        // Use up an available auction
        _board.auctionsDecrementAuctionsRemaining();

        // Claim the next auction id
        uint _id = nextAuctionId++;

        // Record the id of the auction
        auctionIds[_x][_y] = _id;

        AuctionInfo storage _auctionInfo = auctionInfo[_id];

        // Setup the starting data for the auction
        _auctionInfo.x         = _x;
        _auctionInfo.y         = _y;
        _auctionInfo.startTime = now;

        emit BlindAuctionStarted(
              _id
            , _x
            , _y
            , msg.sender
            , now
        );
    }

    /// @dev Place a bid on an auction. This function accepts the
    ///  deposit as msg.value
    /// @param _id The id of the auction to bid on
    /// @param _blindedBid The hash of the blinded bid
    function placeBid(uint _id, bytes32 _blindedBid)
        public
        payable
        notPaused
    {
        // Retrieve the info about the auction
        AuctionInfo storage _auctionInfo = auctionInfo[_id];

        // Require that an auction exists
        require(0 != _auctionInfo.startTime);

        // Require that it is still during the bid span
        require(_auctionInfo.startTime + bidSpan > now);

        // Add the amount deposited to the unrevealed amount
        // for the auction
        _auctionInfo.unrevealedAmount += msg.value;

        // Add the bid to the auctions bids for that player
        _auctionInfo.bids[msg.sender].push(Bid(
              _blindedBid
            , msg.value
        ));

        emit BlindBidPlaced(_id, msg.sender, msg.value);
    }

    /// @dev Reveal all of a player's bids
    /// @param _id The id of the auction that the bids were placed on
    /// @param _values The true values of the bids of each blinded bid
    /// @param _isFakes Whether each individual blinded bid was fake
    /// @param _secrets The secret seeds of each blinded bid
    function revealBids(
          uint _id
        , uint[] _values
        , bool[] _isFakes
        , bytes32[] _secrets
    )
        public
        notPaused
    {
        // Lookup the information about the auction
        AuctionInfo storage _auctionInfo = auctionInfo[_id];

        uint _biddersBidCount = _auctionInfo.bids[msg.sender].length;

        // Require that the user has submitted reveals for all of his bids
        require(_biddersBidCount == _values.length);
        require(_biddersBidCount == _isFakes.length);
        require(_biddersBidCount == _secrets.length);

        // Require that it's after the bid span
        require(_auctionInfo.startTime + bidSpan < now);

        // Require it's before the end of the reveal span
        require(_auctionInfo.startTime + bidSpan + revealSpan > now);

        // The refund the player will receive
        uint _refund;

        // The maximum bid made by the player
        uint _maxBid;

        // For each of the user's bids...
        for(uint _i = 0; _i < _biddersBidCount; ++_i)
        {
            Bid storage _bid = _auctionInfo.bids[msg.sender][_i];
            uint _value      = _values[_i];

            // If the blinded bid's hash does not equal the one the user
            // submitted then the revealed values are incorrect incorrect
            // and skipped. Note that the  user will not receive a refund
            // for this individual reveal in this case
            if(_bid.blindedBid != keccak256(abi.encodePacked(_value, _isFakes[_i], _secrets[_i])))
            {
                continue;
            }

            // Add the successfully revealed bid deposit to the refund
            _refund += _bid.deposit;

            // If the bid was not fake, and it is greater than the current
            // maximum bid, then it is the player's new maximum bid
            if(!_isFakes[_i] && _bid.deposit >= _value && _maxBid < _value)
            {
                _maxBid = _value;
            }

            // Ensure that the succesfully revealed bid cannot be re-revealed
            _bid.blindedBid = bytes32(0);
        }

        // Reduce the unrevealed amount for the auction by the refund amount
        _auctionInfo.unrevealedAmount -= _refund;

        // If the maximum bid is not 0
        if(0 != _maxBid)
        {
            // If the top bid is currently 0, i.e. this is the first
            // player to reveal non-zero bids
            if(0 == _auctionInfo.topBid)
            {
                // Don't refund the player their max bid yet
                _refund -= _maxBid;

                // The player is the current winner
                _auctionInfo.topBidder = msg.sender;
                _auctionInfo.topBid    = _maxBid;
            }
            // If the user has made a higher bid than the current winner
            else if(_auctionInfo.topBid < _maxBid)
            {
                // Refund the previous winner their bid
                _auctionInfo.topBidder.transfer(_auctionInfo.topBid);

                // Don't refund the player their max bid yet
                _refund -= _maxBid;

                // The player is the current winner
                _auctionInfo.topBidder = msg.sender;
                _auctionInfo.topBid    = _maxBid;
            }
        }

        // Send the player his refund
        msg.sender.transfer(_refund);

        emit BlindBidsRevealed(_id, msg.sender, _maxBid);
    }

    /// @dev Close the auction and claim its unrevealed
    ///  amount as taxes
    /// @param _id The id of the auction to be closed
    function closeAuction(uint _id) public notPaused
    {
        // Lookup the auction's info
        AuctionInfo storage _auctionInfo = auctionInfo[_id];

        // Require that an auction exists
        require(0 != _auctionInfo.startTime);

        // Require that the auction hasn't already been closed
        require(!_auctionInfo.closed);

        // Require that it is after the reveal span
        require(_auctionInfo.startTime + bidSpan + revealSpan < now);

        // Set the auction to closed
        _auctionInfo.closed = true;

        // If nobody won the auction
        if(0x0 == _auctionInfo.topBidder)
        {
            // Mark that there is no current auction for this location
            _auctionInfo.startTime = 0;

            // Allow another auction to be created
            KingOfEthBoard(boardContract).auctionsIncrementAuctionsRemaining();

            // Pay the unrevelealed amount as taxes
            KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(_auctionInfo.unrevealedAmount)();
        }
        // If a player won the auction
        else
        {
            // Set the auction's winner as the owner of the house
            KingOfEthHousesAbstractInterface(housesContract).auctionsSetOwner(
                  _auctionInfo.x
                , _auctionInfo.y
                , _auctionInfo.topBidder
            );

            // The amount payed in taxes is the unrevealed amount plus
            // the winning bid
            uint _amount = _auctionInfo.unrevealedAmount + _auctionInfo.topBid;

            // Pay the taxes
            KingOfEthAbstractInterface(kingOfEthContract).payTaxes.value(_amount)();
        }

        emit BlindAuctionClosed(
              _id
            , _auctionInfo.x
            , _auctionInfo.y
            , _auctionInfo.topBidder
            , _auctionInfo.topBid
        );
    }
}