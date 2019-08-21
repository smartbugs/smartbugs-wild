pragma solidity ^0.4.18;

contract CryptoVideoGames {

    address contractCreator = 0xC15d9f97aC926a6A29A681f5c19e2b56fd208f00;
    address devFeeAddress = 0xC15d9f97aC926a6A29A681f5c19e2b56fd208f00;

    struct VideoGame {
        string videoGameName;
        address ownerAddress;
        uint256 currentPrice;
    }
    VideoGame[] videoGames;

    modifier onlyContractCreator() {
        require (msg.sender == contractCreator);
        _;
    }

    bool isPaused;
    
    
    /*
    We use the following functions to pause and unpause the game.
    */
    function pauseGame() public onlyContractCreator {
        isPaused = true;
    }
    function unPauseGame() public onlyContractCreator {
        isPaused = false;
    }
    function GetGamestatus() public view returns(bool) {
       return(isPaused);
    }

    /*
    This function allows users to purchase Video Game. 
    The price is automatically multiplied by 2 after each purchase.
    Users can purchase multiple video games.
    */
    function purchaseVideoGame(uint _videoGameId) public payable {
        require(msg.value == videoGames[_videoGameId].currentPrice);
        require(isPaused == false);

        // Calculate the 10% value
        uint256 devFee = (msg.value / 10);

        // Calculate the video game owner commission on this sale & transfer the commission to the owner.     
        uint256 commissionOwner = msg.value - devFee; // => 90%
        videoGames[_videoGameId].ownerAddress.transfer(commissionOwner);

        // Transfer the 10% commission to the developer
        devFeeAddress.transfer(devFee); // => 10%                       

        // Update the video game owner and set the new price
        videoGames[_videoGameId].ownerAddress = msg.sender;
        videoGames[_videoGameId].currentPrice = mul(videoGames[_videoGameId].currentPrice, 2);
    }
    
    /*
    This function can be used by the owner of a video game to modify the price of its video game.
    He can make the price lesser than the current price only.
    */
    function modifyCurrentVideoGamePrice(uint _videoGameId, uint256 _newPrice) public {
        require(_newPrice > 0);
        require(videoGames[_videoGameId].ownerAddress == msg.sender);
        require(_newPrice < videoGames[_videoGameId].currentPrice);
        videoGames[_videoGameId].currentPrice = _newPrice;
    }
    
    // This function will return all of the details of the Video Games
    function getVideoGameDetails(uint _videoGameId) public view returns (
        string videoGameName,
        address ownerAddress,
        uint256 currentPrice
    ) {
        VideoGame memory _videoGame = videoGames[_videoGameId];

        videoGameName = _videoGame.videoGameName;
        ownerAddress = _videoGame.ownerAddress;
        currentPrice = _videoGame.currentPrice;
    }
    
    // This function will return only the price of a specific Video Game
    function getVideoGameCurrentPrice(uint _videoGameId) public view returns(uint256) {
        return(videoGames[_videoGameId].currentPrice);
    }
    
    // This function will return only the owner address of a specific Video Game
    function getVideoGameOwner(uint _videoGameId) public view returns(address) {
        return(videoGames[_videoGameId].ownerAddress);
    }
    
    
    /**
    @dev Multiplies two numbers, throws on overflow. => From the SafeMath library
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    @dev Integer division of two numbers, truncating the quotient. => From the SafeMath library
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    // This function will be used to add a new video game by the contract creator
    function addVideoGame(string videoGameName, address ownerAddress, uint256 currentPrice) public onlyContractCreator {
        videoGames.push(VideoGame(videoGameName,ownerAddress,currentPrice));
    }
    
}