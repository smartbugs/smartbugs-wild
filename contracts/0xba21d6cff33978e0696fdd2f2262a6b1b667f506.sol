pragma solidity ^0.4.24;

// 😀😀😀😀😀😀😀😀😀😀😀😀😀😀
// 😀                            😀
// 😀 https://emojisan.github.io 😀
// 😀                            😀
// 😀😀😀😀😀😀😀😀😀😀😀😀😀😀

// part of NFT token interface used in this contract
// https://etherscan.io/address/0xE3f2F807ba194ea0221B9109fb14Da600C9e1eb6
interface Emojisan {

    function ownerOf(uint tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint tokenId) external;
    function mint(uint tokenId) external;
    function setMinter(address newMinter) external;
}

contract EmojisanAuctionHouse {

    event Bid(uint indexed tokenId);

    struct Auction {
        address owner;
        uint128 currentPrice;
    }

    struct User {
        uint128 balance;
        uint32 bidBlock;
    }

    // NFT token address
    // https://etherscan.io/address/0xE3f2F807ba194ea0221B9109fb14Da600C9e1eb6
    Emojisan public constant emojisan = Emojisan(0xE3f2F807ba194ea0221B9109fb14Da600C9e1eb6);

    uint[] public tokenByIndex;
    mapping (uint => Auction) public auction;
    mapping (address => User) public user;
    uint32 private constant auctionTime = 20000;

    address public whaleAddress;
    uint32 public whaleStartTime;
    uint128 public whaleBalance;
    uint32 private constant whaleWithdrawDelay = 80000;

    uint128 public ownerBalance;
    uint private constant ownerTokenId = 128512;

    function tokens() external view returns (uint[]) {
        return tokenByIndex;
    }

    function tokensCount() external view returns (uint) {
        return tokenByIndex.length;
    }

    function wantItForFree(uint tokenId) external {
        // user 👤 can bid only on one 1️⃣ token at a time ⏱️
        require(block.number >= user[msg.sender].bidBlock + auctionTime);
        // check auction has not started 🚫🎬
        require(auction[tokenId].owner == address(this));
        auction[tokenId].owner = msg.sender;
        user[msg.sender].bidBlock = uint32(block.number);
        emojisan.mint(tokenId);
        emit Bid(tokenId);
    }

    function wantItMoreThanYou(uint tokenId) external payable {
        // user 👤 can bid only on one 1️⃣ token at a time ⏱️
        require(block.number >= user[msg.sender].bidBlock + auctionTime);
        // check auction has not finished 🚫🏁
        address previousOwner = auction[tokenId].owner;
        require(block.number < user[previousOwner].bidBlock + auctionTime);
        // fancy 🧐 price 💰 calculation 📈
        // 0 ➡️ 0.002 ➡️ 0.004 ➡️ 0.008 ➡️ 0.016 ➡️ 0.032 ➡️ 0.064 ➡️ 0.128
        // ➡️ 0.256 ➡️ 0.512 ➡️ 1 ➡️ 1.5 ➡️ 2 ➡️ 2.5 ➡️ 3 ➡️ 3.5 ➡️ 4 ➡️ ...
        uint128 previousPrice = auction[tokenId].currentPrice;
        uint128 price;
        if (previousPrice == 0) {
            price = 2 finney;
        } else if (previousPrice < 500 finney) {
            price = 2 * previousPrice;
        } else {
            price = (previousPrice + 500 finney) / 500 finney * 500 finney;
        }
        require(msg.value >= price);
        uint128 priceDiff = price - previousPrice;
        // previous 👤 gets what she 🙆 paid ➕ 2️⃣5️⃣%
        user[previousOwner] = User({
            balance: previousPrice + priceDiff / 4,
            bidBlock: 0
        });
        // whale 🐋 gets 5️⃣0️⃣%
        whaleBalance += priceDiff / 2;
        // owner 👩 of token 128512 😀 gets 2️⃣5️⃣%
        ownerBalance += priceDiff / 4;
        auction[tokenId] = Auction({
            owner: msg.sender,
            currentPrice: price
        });
        user[msg.sender].bidBlock = uint32(block.number);
        if (msg.value > price) {
            // send back eth if someone sent too much 💸💸💸
            msg.sender.transfer(msg.value - price);
        }
        emit Bid(tokenId);
    }

    function wantMyToken(uint tokenId) external {
        Auction memory a = auction[tokenId];
        // check auction has finished 🏁
        require(block.number >= user[a.owner].bidBlock + auctionTime);
        emojisan.transferFrom(this, a.owner, tokenId);
    }

    function wantMyEther() external {
        uint amount = user[msg.sender].balance;
        user[msg.sender].balance = 0;
        msg.sender.transfer(amount);
    }

    function wantToBeWhale() external {
        // need to have more tokens 💰 than current 🐋
        require(emojisan.balanceOf(msg.sender) > emojisan.balanceOf(whaleAddress));
        whaleAddress = msg.sender;
        // whale 🐳 needs to wait some time ⏱️ before snatching that sweet 🍬 eth 🤑
        whaleStartTime = uint32(block.number);
    }

    function whaleWantMyEther() external {
        require(msg.sender == whaleAddress);
        // check enough time ⏱️ passed for whale 🐳 to grab 💵💷💶💴
        require(block.number >= whaleStartTime + whaleWithdrawDelay);
        // whale 🐳 needs to wait some time ⏱️ before snatching that sweet 🍭 eth 🤑 again
        whaleStartTime = uint32(block.number);
        uint amount = whaleBalance;
        whaleBalance = 0;
        whaleAddress.transfer(amount);
    }

    function ownerWantMyEther() external {
        uint amount = ownerBalance;
        ownerBalance = 0;
        emojisan.ownerOf(ownerTokenId).transfer(amount);
    }

    function wantNewTokens(uint[] tokenIds) external {
        // only owner 👩 of token 128512 😀
        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        for (uint i = 0; i < tokenIds.length; i++) {
            auction[tokenIds[i]].owner = this;
            tokenByIndex.push(tokenIds[i]);
        }
    }

    function wantNewMinter(address minter) external {
        // only owner 👩 of token 128512 😀
        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        emojisan.setMinter(minter);
    }
}