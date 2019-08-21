// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: node_modules\openzeppelin-solidity\contracts\introspection\IERC165.sol

pragma solidity ^0.5.0;

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721.sol

pragma solidity ^0.5.0;


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Enumerable.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Metadata.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Full.sol

pragma solidity ^0.5.0;




/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {
    // solhint-disable-previous-line no-empty-blocks
}

// File: contracts\IMarketplace.sol

pragma solidity 0.5.0;


contract IMarketplace {
    function createAuction(
        uint256 _tokenId,
        uint128 startPrice,
        uint128 endPrice,
        uint128 duration
    )
        external;
}

// File: contracts\AnimalMarketplace.sol

pragma solidity 0.5.0;






contract AnimalMarketplace is Ownable, IMarketplace {
    using SafeMath for uint256;
    uint8 internal percentFee = 5;

    IERC721Full private erc721Contract;

    struct Auction {
        address payable tokenOwner;
        uint256 startTime;
        uint128 startPrice;
        uint128 endPrice;
        uint128 duration;
    }

    struct AuctionEntry {
        uint256 keyIndex;
        Auction value;
    }

    struct TokenIdAuctionMap {
        mapping(uint256 => AuctionEntry) data;
        uint256[] keys;
    }

    TokenIdAuctionMap private auctions;

    event AuctionBoughtEvent(
        uint256 tokenId,
        address previousOwner,
        address newOwner,
        uint256 pricePaid
    );

    event AuctionCreatedEvent(
        uint256 tokenId,
        uint128 startPrice,
        uint128 endPrice,
        uint128 duration
    );

    event AuctionCanceledEvent(uint256 tokenId);

    constructor(IERC721Full _erc721Contract) public {
        erc721Contract = _erc721Contract;
    }

    // "approve" in game contract will revert if sender is not token owner
    function createAuction(
        uint256 _tokenId,
        uint128 _startPrice,
        uint128 _endPrice,
        uint128 _duration
    )
        external
    {
        // this can be only called from game contract
        require(msg.sender == address(erc721Contract));

        AuctionEntry storage entry = auctions.data[_tokenId];
        require(entry.keyIndex == 0);

        address payable tokenOwner = address(uint160(erc721Contract.ownerOf(_tokenId)));
        erc721Contract.transferFrom(tokenOwner, address(this), _tokenId);

        entry.value = Auction({
            tokenOwner: tokenOwner,
            startTime: block.timestamp,
            startPrice: _startPrice,
            endPrice: _endPrice,
            duration: _duration
        });

        entry.keyIndex = ++auctions.keys.length;
        auctions.keys[entry.keyIndex - 1] = _tokenId;

        emit AuctionCreatedEvent(_tokenId, _startPrice, _endPrice, _duration);
    }

    function cancelAuction(uint256 _tokenId) external {
        AuctionEntry storage entry = auctions.data[_tokenId];
        Auction storage auction = entry.value;
        address sender = msg.sender;
        require(sender == auction.tokenOwner);
        erc721Contract.transferFrom(address(this), sender, _tokenId);
        deleteAuction(_tokenId, entry);
        emit AuctionCanceledEvent(_tokenId);
    }

    function buyAuction(uint256 _tokenId)
        external
        payable
    {
        AuctionEntry storage entry = auctions.data[_tokenId];
        require(entry.keyIndex > 0);
        Auction storage auction = entry.value;
        address payable sender = msg.sender;
        address payable tokenOwner = auction.tokenOwner;
        uint256 auctionPrice = calculateCurrentPrice(auction);
        uint256 pricePaid = msg.value;

        require(pricePaid >= auctionPrice);
        deleteAuction(_tokenId, entry);

        refundSender(sender, pricePaid, auctionPrice);
        payTokenOwner(tokenOwner, auctionPrice);
        erc721Contract.transferFrom(address(this), sender, _tokenId);
        emit AuctionBoughtEvent(_tokenId, tokenOwner, sender, auctionPrice);
    }

    function getAuctionByTokenId(uint256 _tokenId)
        external
        view
        returns (
            uint256 tokenId,
            address tokenOwner,
            uint128 startPrice,
            uint128 endPrice,
            uint256 startTime,
            uint128 duration,
            uint256 currentPrice,
            bool exists
        )
    {
        AuctionEntry storage entry = auctions.data[_tokenId];
        Auction storage auction = entry.value;
        uint256 calculatedCurrentPrice = calculateCurrentPrice(auction);
        return (
            entry.keyIndex > 0 ? _tokenId : 0,
            auction.tokenOwner,
            auction.startPrice,
            auction.endPrice,
            auction.startTime,
            auction.duration,
            calculatedCurrentPrice,
            entry.keyIndex > 0
        );
    }

    function getAuctionByIndex(uint256 _auctionIndex)
        external
        view
        returns (
            uint256 tokenId,
            address tokenOwner,
            uint128 startPrice,
            uint128 endPrice,
            uint256 startTime,
            uint128 duration,
            uint256 currentPrice,
            bool exists
        )
    {
        // for consistency with getAuctionByTokenId when returning invalid auction - otherwise it would throw error
        if (_auctionIndex >= auctions.keys.length) {
            return (0, address(0), 0, 0, 0, 0, 0, false);
        }

        uint256 currentTokenId = auctions.keys[_auctionIndex];
        Auction storage auction = auctions.data[currentTokenId].value;
        uint256 calculatedCurrentPrice = calculateCurrentPrice(auction);
        return (
            currentTokenId,
            auction.tokenOwner,
            auction.startPrice,
            auction.endPrice,
            auction.startTime,
            auction.duration,
            calculatedCurrentPrice,
            true
        );
    }

    function getAuctionsCount() external view returns (uint256 auctionsCount) {
        return auctions.keys.length;
    }

    function isOnAuction(uint256 _tokenId) public view returns (bool onAuction) {
        return auctions.data[_tokenId].keyIndex > 0;
    }

    function withdrawContract() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function refundSender(address payable _sender, uint256 _pricePaid, uint256 _auctionPrice) private {
        uint256 etherToRefund = _pricePaid.sub(_auctionPrice);
        if (etherToRefund > 0) {
            _sender.transfer(etherToRefund);
        }
    }

    function payTokenOwner(address payable _tokenOwner, uint256 _auctionPrice) private {
        uint256 etherToPay = _auctionPrice.sub(_auctionPrice * percentFee / 100);
        if (etherToPay > 0) {
            _tokenOwner.transfer(etherToPay);
        }
    }

    function deleteAuction(uint256 _tokenId, AuctionEntry storage _entry) private {
        uint256 keysLength = auctions.keys.length;
        if (_entry.keyIndex <= keysLength) {
            // Move an existing element into the vacated key slot.
            auctions.data[auctions.keys[keysLength - 1]].keyIndex = _entry.keyIndex;
            auctions.keys[_entry.keyIndex - 1] = auctions.keys[keysLength - 1];
            auctions.keys.length = keysLength - 1;
            delete auctions.data[_tokenId];
        }
    }

    function calculateCurrentPrice(Auction storage _auction) private view returns (uint256) {
        uint256 secondsInProgress = block.timestamp - _auction.startTime;

        if (secondsInProgress >= _auction.duration) {
            return _auction.endPrice;
        }

        int256 totalPriceChange = int256(_auction.endPrice) - int256(_auction.startPrice);
        int256 currentPriceChange =
            totalPriceChange * int256(secondsInProgress) / int256(_auction.duration);

        int256 calculatedPrice = int256(_auction.startPrice) + int256(currentPriceChange);

        return uint256(calculatedPrice);
    }

}