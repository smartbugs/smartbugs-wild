pragma solidity ^0.4.23;

/// @title BlockchainCuties: Collectible and breedable cuties on the Ethereum blockchain.
/// @author https://BlockChainArchitect.io
/// @dev This is the BlockchainCuties configuration. It can be changed redeploying another version.
interface ConfigInterface
{
    function isConfig() external pure returns (bool);

    function getCooldownIndexFromGeneration(uint16 _generation, uint40 _cutieId) external view returns (uint16);
    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex, uint40 _cutieId) external view returns (uint40);
    function getCooldownIndexFromGeneration(uint16 _generation) external view returns (uint16);
    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) external view returns (uint40);

    function getCooldownIndexCount() external view returns (uint256);

    function getBabyGenFromId(uint40 _momId, uint40 _dadId) external view returns (uint16);
    function getBabyGen(uint16 _momGen, uint16 _dadGen) external pure returns (uint16);

    function getTutorialBabyGen(uint16 _dadGen) external pure returns (uint16);

    function getBreedingFee(uint40 _momId, uint40 _dadId) external view returns (uint256);
}


contract CutieCoreInterface
{
    function isCutieCore() pure public returns (bool);

    ConfigInterface public config;

    function transferFrom(address _from, address _to, uint256 _cutieId) external;
    function transfer(address _to, uint256 _cutieId) external;

    function ownerOf(uint256 _cutieId)
        external
        view
        returns (address owner);

    function getCutie(uint40 _id)
        external
        view
        returns (
        uint256 genes,
        uint40 birthTime,
        uint40 cooldownEndTime,
        uint40 momId,
        uint40 dadId,
        uint16 cooldownIndex,
        uint16 generation
    );

    function getGenes(uint40 _id)
        public
        view
        returns (
        uint256 genes
    );


    function getCooldownEndTime(uint40 _id)
        public
        view
        returns (
        uint40 cooldownEndTime
    );

    function getCooldownIndex(uint40 _id)
        public
        view
        returns (
        uint16 cooldownIndex
    );


    function getGeneration(uint40 _id)
        public
        view
        returns (
        uint16 generation
    );

    function getOptional(uint40 _id)
        public
        view
        returns (
        uint64 optional
    );


    function changeGenes(
        uint40 _cutieId,
        uint256 _genes)
        public;

    function changeCooldownEndTime(
        uint40 _cutieId,
        uint40 _cooldownEndTime)
        public;

    function changeCooldownIndex(
        uint40 _cutieId,
        uint16 _cooldownIndex)
        public;

    function changeOptional(
        uint40 _cutieId,
        uint64 _optional)
        public;

    function changeGeneration(
        uint40 _cutieId,
        uint16 _generation)
        public;

    function createSaleAuction(
        uint40 _cutieId,
        uint128 _startPrice,
        uint128 _endPrice,
        uint40 _duration
    )
    public;

    function getApproved(uint256 _tokenId) external returns (address);
    function totalSupply() view external returns (uint256);
    function createPromoCutie(uint256 _genes, address _owner) external;
    function checkOwnerAndApprove(address _claimant, uint40 _cutieId, address _pluginsContract) external view;
    function breedWith(uint40 _momId, uint40 _dadId) public payable returns (uint40);
    function getBreedingFee(uint40 _momId, uint40 _dadId) public view returns (uint256);
}

pragma solidity ^0.4.23;


pragma solidity ^0.4.23;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

pragma solidity ^0.4.23;

/// @title Auction Market for Blockchain Cuties.
/// @author https://BlockChainArchitect.io
contract MarketInterface 
{
    function withdrawEthFromBalance() external;

    function createAuction(uint40 _cutieId, uint128 _startPrice, uint128 _endPrice, uint40 _duration, address _seller) public payable;
    function createAuctionWithTokens(uint40 _cutieId, uint128 _startPrice, uint128 _endPrice, uint40 _duration, address _seller, address[] allowedTokens) public payable;

    function bid(uint40 _cutieId) public payable;

    function cancelActiveAuctionWhenPaused(uint40 _cutieId) public;

	function getAuctionInfo(uint40 _cutieId)
        public
        view
        returns
    (
        address seller,
        uint128 startPrice,
        uint128 endPrice,
        uint40 duration,
        uint40 startedAt,
        uint128 featuringFee,
        address[] allowedTokens
    );
}

pragma solidity ^0.4.23;

interface Gen0CallbackInterface
{
    function onGen0Created(uint40 _cutieId) external;
}

pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken

interface TokenRecipientInterface
{
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

pragma solidity ^0.4.23;

// https://github.com/ethereum/EIPs/issues/223
interface TokenFallback
{
    function tokenFallback(address _from, uint _value, bytes _data) external;
}

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
contract ERC20 {

    // ERC Token Standard #223 Interface
    // https://github.com/ethereum/EIPs/issues/223

    string public symbol;
    string public  name;
    uint8 public decimals;

    function transfer(address _to, uint _value, bytes _data) external returns (bool success);

    // approveAndCall
    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool success);

    // ERC Token Standard #20 Interface
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md


    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    // bulk operations
    function transferBulk(address[] to, uint[] tokens) public;
    function approveBulk(address[] spender, uint[] tokens) public;
}


interface TokenRegistryInterface
{
    function getPriceInToken(ERC20 tokenContract, uint128 priceWei) external view returns (uint128);
    function areAllTokensAllowed(address[] tokens) external view returns (bool);
    function isTokenInList(address[] allowedTokens, address currentToken) external pure returns (bool);
    function getDefaultTokens() external view returns (address[]);
    function getDefaultCreatorTokens() external view returns (address[]);
    function onTokensReceived(ERC20 tokenContract, uint tokenCount) external;
    function withdrawEthFromBalance() external;
    function canConvertToEth(ERC20 tokenContract) external view returns (bool);
    function convertTokensToEth(ERC20 tokenContract, address seller, uint sellerValue, uint fee) external;
}


/// @title Auction Market for Blockchain Cuties.
/// @author https://BlockChainArchitect.io
contract Market is MarketInterface, Pausable, TokenRecipientInterface, TokenFallback
{
    // Shows the auction on an Cutie Token
    struct Auction {
        // Price (in wei or tokens) at the beginning of auction
        uint128 startPrice;
        // Price (in wei or tokens) at the end of auction
        uint128 endPrice;
        // Current owner of Token
        address seller;
        // Auction duration in seconds
        uint40 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint40 startedAt;
        // Featuring fee (in wei, optional)
        uint128 featuringFee;
        // list of erc20 tokens addresses, that is allowed to bid with
        address[] allowedTokens;
    }

    // Reference to contract that tracks ownership
    CutieCoreInterface public coreContract;
    Gen0CallbackInterface public gen0Callback;

    // Cut owner takes on each auction, in basis points - 1/100 of a per cent.
    // Values 0-10,000 map to 0%-100%
    uint16 public ownerFee;

    // Map from token ID to their corresponding auction.
    mapping (uint40 => Auction) public cutieIdToAuction;
    TokenRegistryInterface public tokenRegistry;


    address operatorAddress;

    event AuctionCreatedWithTokens(uint40 indexed cutieId, uint128 startPrice, uint128 endPrice, uint40 duration, uint128 fee, address[] allowedTokens);
    event AuctionSuccessful(uint40 indexed cutieId, uint128 totalPriceWei, address indexed winner);
    event AuctionSuccessfulForToken(uint40 indexed cutieId, uint128 totalPriceWei, address indexed winner, uint128 priceInTokens, address indexed token);
    event AuctionCancelled(uint40 indexed cutieId);

    modifier onlyOperator() {
        require(msg.sender == operatorAddress || msg.sender == owner);
        _;
    }

    function setOperator(address _newOperator) public onlyOwner {
        require(_newOperator != address(0));

        operatorAddress = _newOperator;
    }

    /// @dev enable sending fund to this contract
    function() external payable {}

    modifier canBeStoredIn128Bits(uint256 _value)
    {
        require(_value <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        _;
    }

    // @dev Adds to the list of open auctions and fires the
    //  AuctionCreated event.
    // @param _cutieId The token ID is to be put on auction.
    // @param _auction To add an auction.
    // @param _fee Amount of money to feature auction
    function _addAuction(uint40 _cutieId, Auction _auction) internal
    {
        if (_auction.seller == address(coreContract))
        {
            if (address(gen0Callback) != 0x0)
            {
                gen0Callback.onGen0Created(_cutieId);
            }
            if (_auction.duration == 0)
            {
                _transfer(operatorAddress, _cutieId);
                return;
            }
        }
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        cutieIdToAuction[_cutieId] = _auction;
        
        emit AuctionCreatedWithTokens(
            _cutieId,
            _auction.startPrice,
            _auction.endPrice,
            _auction.duration,
            _auction.featuringFee,
            _auction.allowedTokens
        );
    }

    // @dev Returns true if the token is claimed by the claimant.
    // @param _claimant - Address claiming to own the token.
    function _isOwner(address _claimant, uint256 _cutieId) internal view returns (bool)
    {
        return (coreContract.ownerOf(_cutieId) == _claimant);
    }

    // @dev Transfers the token owned by this contract to another address.
    // Returns true when the transfer succeeds.
    // @param _receiver - Address to transfer token to.
    // @param _cutieId - Token ID to transfer.
    function _transfer(address _receiver, uint40 _cutieId) internal
    {
        // it will throw if transfer fails
        coreContract.transfer(_receiver, _cutieId);
    }

    // @dev Escrows the token and assigns ownership to this contract.
    // Throws if the escrow fails.
    // @param _owner - Current owner address of token to escrow.
    // @param _cutieId - Token ID the approval of which is to be verified.
    function _escrow(address _owner, uint40 _cutieId) internal
    {
        // it will throw if transfer fails
        coreContract.transferFrom(_owner, this, _cutieId);
    }

    // @dev just cancel auction.
    function _cancelActiveAuction(uint40 _cutieId, address _seller) internal
    {
        _removeAuction(_cutieId);
        _transfer(_seller, _cutieId);
        emit AuctionCancelled(_cutieId);
    }

    // @dev Calculates the price and transfers winnings.
    // Does not transfer token ownership.
    function _bid(uint40 _cutieId, uint128 _bidAmount)
        internal
        returns (uint128)
    {
        // Get a reference to the auction struct
        Auction storage auction = cutieIdToAuction[_cutieId];

        require(_isOnAuction(auction));

        // Check that bid > current price
        uint128 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Provide a reference to the seller before the auction struct is deleted.
        address seller = auction.seller;

        _removeAuction(_cutieId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0 && seller != address(coreContract)) {
            uint128 fee = _computeFee(price);
            uint128 sellerValue = price - fee;

            seller.transfer(sellerValue);
        }

        emit AuctionSuccessful(_cutieId, price, msg.sender);

        return price;
    }

    // @dev Removes from the list of open auctions.
    // @param _cutieId - ID of token on auction.
    function _removeAuction(uint40 _cutieId) internal
    {
        delete cutieIdToAuction[_cutieId];
    }

    // @dev Returns true if the token is on auction.
    // @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool)
    {
        return (_auction.startedAt > 0);
    }

    // @dev calculate current price of auction. 
    //  When testing, make this function public and turn on
    //  `Current price calculation` test suite.
    function _computeCurrentPrice(
        uint128 _startPrice,
        uint128 _endPrice,
        uint40 _duration,
        uint40 _secondsPassed
    )
        internal
        pure
        returns (uint128)
    {
        if (_secondsPassed >= _duration) {
            return _endPrice;
        } else {
            int256 totalPriceChange = int256(_endPrice) - int256(_startPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            uint128 currentPrice = _startPrice + uint128(currentPriceChange);
            
            return currentPrice;
        }
    }
    // @dev return current price of token.
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint128)
    {
        uint40 secondsPassed = 0;

        uint40 timeNow = uint40(now);
        if (timeNow > _auction.startedAt) {
            secondsPassed = timeNow - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startPrice,
            _auction.endPrice,
            _auction.duration,
            secondsPassed
        );
    }

    // @dev Calculates owner's cut of a sale.
    // @param _price - Sale price of cutie.
    function _computeFee(uint128 _price) internal view returns (uint128)
    {
        return _price * ownerFee / 10000;
    }

    // @dev Remove all Ether from the contract with the owner's cuts. Also, remove any Ether sent directly to the contract address.
    //  Transfers to the token contract, but can be called by
    //  the owner or the token contract.
    function withdrawEthFromBalance() external
    {
        address coreAddress = address(coreContract);

        require(
            msg.sender == owner ||
            msg.sender == coreAddress
        );

        tokenRegistry.withdrawEthFromBalance();
        coreAddress.transfer(address(this).balance);
    }

    // @dev create and start a new auction
    // @param _cutieId - ID of cutie to auction, sender must be owner.
    // @param _startPrice - Price of item (in wei) at the beginning of auction.
    // @param _endPrice - Price of item (in wei) at the end of auction.
    // @param _duration - Length of auction (in seconds). Most significant bit od duration is to allow sell for all tokens.
    // @param _seller - Seller
    function createAuction(uint40 _cutieId, uint128 _startPrice, uint128 _endPrice, uint40 _duration, address _seller)
        public whenNotPaused payable
    {
        require(_isOwner(_seller, _cutieId));
        _escrow(_seller, _cutieId);

        bool allowTokens = _duration < 0x8000000000; // first bit of duration is boolean flag (1 to disable tokens)
        _duration = _duration % 0x8000000000; // clear flag from duration

        Auction memory auction = Auction(
            _startPrice,
            _endPrice,
            _seller,
            _duration,
            uint40(now),
            uint128(msg.value),
            allowTokens ?
                (_seller == address(coreContract) ? tokenRegistry.getDefaultCreatorTokens() : tokenRegistry.getDefaultTokens())
                : new address[](0)
        );
        _addAuction(_cutieId, auction);
    }

    // @dev create and start a new auction
    // @param _cutieId - ID of cutie to auction, sender must be owner.
    // @param _startPrice - Price of item (in wei) at the beginning of auction.
    // @param _endPrice - Price of item (in wei) at the end of auction.
    // @param _duration - Length of auction (in seconds).
    // @param _seller - Seller
    // @param _allowedTokens - list of tokens addresses, that can be used as currency to buy cutie.
    function createAuctionWithTokens(
        uint40 _cutieId,
        uint128 _startPrice,
        uint128 _endPrice,
        uint40 _duration,
        address _seller,
        address[] _allowedTokens) public payable
    {
        require(tokenRegistry.areAllTokensAllowed(_allowedTokens));
        require(_isOwner(_seller, _cutieId));
        _escrow(_seller, _cutieId);

        Auction memory auction = Auction(
            _startPrice,
            _endPrice,
            _seller,
            _duration,
            uint40(now),
            uint128(msg.value),
            _allowedTokens
        );
        _addAuction(_cutieId, auction);
    }

    // @dev Set the reference to cutie ownership contract. Verify the owner's fee.
    //  @param fee should be between 0-10,000.
    function setup(address _coreContractAddress, TokenRegistryInterface _tokenRegistry, uint16 _fee) public onlyOwner
    {
        require(_fee <= 10000);

        ownerFee = _fee;

        CutieCoreInterface candidateContract = CutieCoreInterface(_coreContractAddress);
        require(candidateContract.isCutieCore());
        coreContract = candidateContract;
        tokenRegistry = _tokenRegistry;
    }

    function setGen0Callback(Gen0CallbackInterface _gen0Callback) public onlyOwner
    {
        gen0Callback = _gen0Callback;
    }

    // @dev Set the owner's fee.
    //  @param fee should be between 0-10,000.
    function setFee(uint16 _fee) public onlyOwner
    {
        require(_fee <= 10000);

        ownerFee = _fee;
    }

    // @dev bid on auction. Complete it and transfer ownership of cutie if enough ether was given.
    function bid(uint40 _cutieId) public payable whenNotPaused canBeStoredIn128Bits(msg.value)
    {
        // _bid throws if something failed.
        _bid(_cutieId, uint128(msg.value));
        _transfer(msg.sender, _cutieId);
    }

    function getCutieId(bytes _extraData) pure internal returns (uint40)
    {
        require(_extraData.length == 5); // 40 bits

        return
            uint40(_extraData[0]) +
            uint40(_extraData[1]) * 0x100 +
            uint40(_extraData[2]) * 0x10000 +
            uint40(_extraData[3]) * 0x100000 +
            uint40(_extraData[4]) * 0x10000000;
    }

    function bidWithToken(address _tokenContract, uint40 _cutieId) external whenNotPaused
    {
        _bidWithToken(_tokenContract, _cutieId, msg.sender);
    }

    function tokenFallback(address _sender, uint _value, bytes _extraData) external whenNotPaused
    {
        uint40 cutieId = getCutieId(_extraData);
        address tokenContractAddress = msg.sender;
        ERC20 tokenContract = ERC20(tokenContractAddress);

        // Get a reference to the auction struct
        Auction storage auction = cutieIdToAuction[cutieId];

        require(tokenRegistry.isTokenInList(auction.allowedTokens, tokenContractAddress)); // buy for token is allowed

        require(_isOnAuction(auction));

        uint128 priceWei = _currentPrice(auction);

        uint128 priceInTokens = tokenRegistry.getPriceInToken(tokenContract, priceWei);

        // Check that bid > current price (this tokens are already sent to currect contract)
        require(_value >= priceInTokens);

        // Provide a reference to the seller before the auction struct is deleted.
        address seller = auction.seller;

        _removeAuction(cutieId);

        // send tokens to seller
        if (seller != address(coreContract))
        {
            uint128 fee = _computeFee(priceInTokens);
            uint128 sellerValue = priceInTokens - fee;

            tokenContract.transfer(seller, sellerValue);
        }

        emit AuctionSuccessfulForToken(cutieId, priceWei, _sender, priceInTokens, tokenContractAddress);
        _transfer(_sender, cutieId);
    }

    // https://github.com/BitGuildPlatform/Documentation/blob/master/README.md#2-required-game-smart-contract-changes
    // Function that is called when trying to use PLAT for payments from approveAndCall
    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes _extraData)
        external
        canBeStoredIn128Bits(_value)
        whenNotPaused
    {
        uint40 cutieId = getCutieId(_extraData);
        _bidWithToken(_tokenContract, cutieId, _sender);
    }

    function _bidWithToken(address _tokenContract, uint40 _cutieId, address _sender) internal
    {
        ERC20 tokenContract = ERC20(_tokenContract);

        // Get a reference to the auction struct
        Auction storage auction = cutieIdToAuction[_cutieId];

        bool allowTokens = tokenRegistry.isTokenInList(auction.allowedTokens, _tokenContract); // buy for token is allowed
        bool allowConvertToEth = tokenRegistry.canConvertToEth(tokenContract);

        require(allowTokens || allowConvertToEth);

        require(_isOnAuction(auction));

        uint128 priceWei = _currentPrice(auction);

        uint128 priceInTokens = tokenRegistry.getPriceInToken(tokenContract, priceWei);

        // Provide a reference to the seller before the auction struct is deleted.
        address seller = auction.seller;

        _removeAuction(_cutieId);

        if (seller != address(coreContract))
        {
            uint128 fee = _computeFee(priceInTokens);
            uint128 sellerValueTokens = priceInTokens - fee;

            if (allowTokens)
            {
                // seller income - tokens
                require(tokenContract.transferFrom(_sender, seller, sellerValueTokens));

                // market fee - convert tokens to eth
                require(tokenContract.transferFrom(_sender, address(tokenRegistry), fee));
                tokenRegistry.onTokensReceived(tokenContract, fee);
            }
            else
            {
                // seller income
                require(tokenContract.transferFrom(_sender, address(tokenRegistry), priceInTokens)); // sellerValueTokens + fee
                tokenRegistry.convertTokensToEth(tokenContract, seller, priceInTokens, ownerFee); // sellerValueTokens = priceInTokens * (100% - fee)
            }
        }
        else
        {
            require(tokenContract.transferFrom(_sender, address(tokenRegistry), priceInTokens));
            tokenRegistry.onTokensReceived(tokenContract, priceInTokens);
        }
        emit AuctionSuccessfulForToken(_cutieId, priceWei, _sender, priceInTokens, _tokenContract);
        _transfer(_sender, _cutieId);
    }

    // @dev Returns auction info for a token on auction.
    // @param _cutieId - ID of token on auction.
    function getAuctionInfo(uint40 _cutieId)
        public
        view
        returns
    (
        address seller,
        uint128 startPrice,
        uint128 endPrice,
        uint40 duration,
        uint40 startedAt,
        uint128 featuringFee,
        address[] allowedTokens
    ) {
        Auction storage auction = cutieIdToAuction[_cutieId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startPrice,
            auction.endPrice,
            auction.duration,
            auction.startedAt,
            auction.featuringFee,
            auction.allowedTokens
        );
    }

    // @dev Returns auction info for a token on auction.
    // @param _cutieId - ID of token on auction.
    function isOnAuction(uint40 _cutieId)
        public
        view
        returns (bool) 
    {
        return cutieIdToAuction[_cutieId].startedAt > 0;
    }

/*
    /// @dev Import cuties from previous version of Core contract.
    /// @param _oldAddress Old core contract address
    /// @param _fromIndex (inclusive)
    /// @param _toIndex (inclusive)
    function migrate(address _oldAddress, uint40 _fromIndex, uint40 _toIndex) public onlyOwner whenPaused
    {
        Market old = Market(_oldAddress);

        for (uint40 i = _fromIndex; i <= _toIndex; i++)
        {
            if (coreContract.ownerOf(i) == _oldAddress)
            {
                address seller;
                uint128 startPrice;
                uint128 endPrice;
                uint40 duration;
                uint40 startedAt;
                uint128 featuringFee;   
                (seller, startPrice, endPrice, duration, startedAt, featuringFee) = old.getAuctionInfo(i);

                Auction memory auction = Auction({
                    seller: seller, 
                    startPrice: startPrice, 
                    endPrice: endPrice, 
                    duration: duration, 
                    startedAt: startedAt, 
                    featuringFee: featuringFee
                });
                _addAuction(i, auction);
            }
        }
    }*/

    // @dev Returns the current price of an auction.
    function getCurrentPrice(uint40 _cutieId)
        public
        view
        returns (uint128)
    {
        Auction storage auction = cutieIdToAuction[_cutieId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

    // @dev Cancels unfinished auction and returns token to owner. 
    // Can be called when contract is paused.
    function cancelActiveAuction(uint40 _cutieId) public
    {
        Auction storage auction = cutieIdToAuction[_cutieId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelActiveAuction(_cutieId, seller);
    }

    // @dev Cancels auction when contract is on pause. Option is available only to owners in urgent situations. Tokens returned to seller.
    //  Used on Core contract upgrade.
    function cancelActiveAuctionWhenPaused(uint40 _cutieId) whenPaused onlyOwner public
    {
        Auction storage auction = cutieIdToAuction[_cutieId];
        require(_isOnAuction(auction));
        _cancelActiveAuction(_cutieId, auction.seller);
    }

    // @dev Cancels unfinished auction and returns token to owner.
    // Can be called when contract is paused.
    function cancelCreatorAuction(uint40 _cutieId) public onlyOperator
    {
        Auction storage auction = cutieIdToAuction[_cutieId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(seller == address(coreContract));
        _cancelActiveAuction(_cutieId, msg.sender);
    }

    // @dev Transfers to _withdrawToAddress all tokens controlled by
    // contract _tokenContract.
    function withdrawTokenFromBalance(ERC20 _tokenContract, address _withdrawToAddress) external
    {
        address coreAddress = address(coreContract);

        require(
            msg.sender == owner ||
            msg.sender == operatorAddress ||
            msg.sender == coreAddress
        );
        uint256 balance = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(_withdrawToAddress, balance);
    }

    function isPluginInterface() public pure returns (bool)
    {
        return true;
    }

    function onRemove() public {}

    function run(
        uint40 /*_cutieId*/,
        uint256 /*_parameter*/,
        address /*_seller*/
    )
    public
    payable
    {
        revert();
    }

    function runSigned(
        uint40 /*_cutieId*/,
        uint256 /*_parameter*/,
        address /*_owner*/
    )
        external
        payable
    {
        revert();
    }

    function withdraw() public
    {
        require(
            msg.sender == owner ||
            msg.sender == address(coreContract)
        );
        if (address(this).balance > 0)
        {
            address(coreContract).transfer(address(this).balance);
        }
    }
}


/// @title Auction market for cuties sale 
/// @author https://BlockChainArchitect.io
contract SaleMarket is Market
{
    // @dev Sanity check reveals that the
    //  auction in our setSaleAuctionAddress() call is right.
    bool public isSaleMarket = true;

    // @dev LastSalePrice is updated if seller is the token contract.
    // Otherwise, default bid method is used.
    function bid(uint40 _cutieId)
        public
        payable
        canBeStoredIn128Bits(msg.value)
    {
        // _bid verifies token ID size
        _bid(_cutieId, uint128(msg.value));
        _transfer(msg.sender, _cutieId);
    }
}