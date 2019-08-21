pragma solidity ^0.4.18;

/*
Game Name: PlayCryptoGaming
Game Link: https://playcryptogaming.com/
*/

contract PlayCryptoGaming {

    address contractOwnerAddress = 0x46d9112533ef677059c430E515775e358888e38b;
    uint256 priceContract = 26000000000000000000;


    modifier onlyOwner() {
        require (msg.sender == contractOwnerAddress);
        _;
    }
    
    struct CryptoGamer {
        string name;
        address ownerAddress;
        uint256 curPrice;
        address CryptoGamerAddress;
    }
    CryptoGamer[] cryptoGamers;

    bool cryptoGamersAreInitiated;
    bool isPaused;
    
    /*
    We use the following functions to pause and unpause the game.
    */
    function pauseGame() public onlyOwner {
        isPaused = true;
    }
    function unPauseGame() public onlyOwner {
        isPaused = false;
    }
    function GetIsPaused() public view returns(bool) {
       return(isPaused);
    }

    /*
    This function allows players to purchase cryptogamers from other players. 
    The price is automatically multiplied by 1.5 after each purchase.
    */
    function purchaseCryptoGamer(uint _cryptoGamerId) public payable {
        require(msg.value == cryptoGamers[_cryptoGamerId].curPrice);
        require(isPaused == false);

        // Calculate the 5% value
        uint256 commission1percent = (msg.value / 100);
        
        // Transfer the 5% commission to the owner of the least expensive and most expensive cryptogame
        address leastExpensiveCryptoGamerOwner = cryptoGamers[getLeastExpensiveCryptoGamer()].ownerAddress;
        address mostExpensiveCryptoGamerOwner = cryptoGamers[getMostExpensiveCryptoGamer()].ownerAddress;
        
        // We check if the contract is still the owner of the most/least expensive cryptogamers 
        if(leastExpensiveCryptoGamerOwner == address(this)) { 
            leastExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        if(mostExpensiveCryptoGamerOwner == address(this)) { 
            mostExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        
        leastExpensiveCryptoGamerOwner.transfer(commission1percent * 5); // => 5%  
        mostExpensiveCryptoGamerOwner.transfer(commission1percent * 5); // => 5%  

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission1percent * 15); // => 85%
        
        // This cryptoGamer is still owned by the contract, we transfer the commission to the ownerAddress
        if(cryptoGamers[_cryptoGamerId].ownerAddress == address(this)) {
            contractOwnerAddress.transfer(commissionOwner);

        } else {
            // This cryptogamer is owned by a user, we transfer the commission to this player
            cryptoGamers[_cryptoGamerId].ownerAddress.transfer(commissionOwner);
        }
        

        // Transfer the 3% commission to the developer
        contractOwnerAddress.transfer(commission1percent * 3); // => 3%
        
        // Transfer the 2% commission to the actual cryptogamer
        if(cryptoGamers[_cryptoGamerId].CryptoGamerAddress != 0x0) {
            cryptoGamers[_cryptoGamerId].CryptoGamerAddress.transfer(commission1percent * 2); // => 2%
        } else {
            // We don't konw the address of the crypto gamer yet, we transfer the commission to the owner
            contractOwnerAddress.transfer(commission1percent * 2); // => 2%
        }
        

        // Update the company owner and set the new price
        cryptoGamers[_cryptoGamerId].ownerAddress = msg.sender;
        cryptoGamers[_cryptoGamerId].curPrice = cryptoGamers[_cryptoGamerId].curPrice + (cryptoGamers[_cryptoGamerId].curPrice / 2);
    }

    /*
    This is the function that will allow players to purchase the contract. 
    The initial price is set to 26ETH (26000000000000000000 WEI).
    The owner of the contract can create new players and will receive a 5% commission on every sales
    */
    function purchaseContract() public payable {
        require(msg.value == priceContract);
        
        // Calculate the 5% value
        uint256 commission5percent = ((msg.value / 10)/2);
        
        // Transfer the 5% commission to the owner of the least expensive and most expensive cryptogame
        address leastExpensiveCryptoGamerOwner = cryptoGamers[getLeastExpensiveCryptoGamer()].ownerAddress;
        address mostExpensiveCryptoGamerOwner = cryptoGamers[getMostExpensiveCryptoGamer()].ownerAddress;
        
        // We check if the contract is still the owner of the most/least expensive cryptogamers 
        if(leastExpensiveCryptoGamerOwner == address(this)) { 
            leastExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        if(mostExpensiveCryptoGamerOwner == address(this)) { 
            mostExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        
        // Transfer the commission
        leastExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  
        mostExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission5percent * 2); // => 85%
        
        contractOwnerAddress.transfer(commissionOwner);
        contractOwnerAddress = msg.sender;
    }

    function getPriceContract() public view returns(uint) {
        return(priceContract);
    }

    /*
    The owner of the contract can use this function to modify the price of the contract.
    The price is set in WEI
    */
    function updatePriceContract(uint256 _newPrice) public onlyOwner {
        priceContract = _newPrice;
    }

    // Simply returns the current owner address
    function getContractOwnerAddress() public view returns(address) {
        return(contractOwnerAddress);
    }

    /*
    The owner of a company can reduce the price of the company using this function.
    The price can be reduced but cannot be bigger.
    The price is set in WEI.
    */
    function updateCryptoGamerPrice(uint _cryptoGamerId, uint256 _newPrice) public {
        require(_newPrice > 0);
        require(cryptoGamers[_cryptoGamerId].ownerAddress == msg.sender);
        require(_newPrice < cryptoGamers[_cryptoGamerId].curPrice);
        cryptoGamers[_cryptoGamerId].curPrice = _newPrice;
    }
    
    // This function will return the details of a cryptogamer
    function getCryptoGamer(uint _cryptoGamerId) public view returns (
        string name,
        address ownerAddress,
        uint256 curPrice,
        address CryptoGamerAddress
    ) {
        CryptoGamer storage _cryptoGamer = cryptoGamers[_cryptoGamerId];

        name = _cryptoGamer.name;
        ownerAddress = _cryptoGamer.ownerAddress;
        curPrice = _cryptoGamer.curPrice;
        CryptoGamerAddress = _cryptoGamer.CryptoGamerAddress;
    }
    
    /*
    Get least expensive crypto gamers (to transfer the owner 5% of the transaction)
    If multiple cryptogamers have the same price, the selected one will be the cryptogamer with the smalled id 
    */
    function getLeastExpensiveCryptoGamer() public view returns(uint) {
        uint _leastExpensiveGamerId = 0;
        uint256 _leastExpensiveGamerPrice = 9999000000000000000000;

        // Loop through all the shares of this company
        for (uint8 i = 0; i < cryptoGamers.length; i++) {
            if(cryptoGamers[i].curPrice < _leastExpensiveGamerPrice) {
                _leastExpensiveGamerPrice = cryptoGamers[i].curPrice;
                _leastExpensiveGamerId = i;
            }
        }
        return(_leastExpensiveGamerId);
    }

    /* 
    Get most expensive crypto gamers (to transfer the owner 5% of the transaction)
     If multiple cryptogamers have the same price, the selected one will be the cryptogamer with the smalled id 
     */
    function getMostExpensiveCryptoGamer() public view returns(uint) {
        uint _mostExpensiveGamerId = 0;
        uint256 _mostExpensiveGamerPrice = 9999000000000000000000;

        // Loop through all the shares of this company
        for (uint8 i = 0; i < cryptoGamers.length; i++) {
            if(cryptoGamers[i].curPrice > _mostExpensiveGamerPrice) {
                _mostExpensiveGamerPrice = cryptoGamers[i].curPrice;
                _mostExpensiveGamerId = i;
            }
        }
        return(_mostExpensiveGamerId);
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
    /*
    The dev can update the verified address of the crypto gamer. Email me at contact@playcryptogaming.com to get your account verified and earn a commission.
    */
    function updateCryptoGamerVerifiedAddress(uint _cryptoGamerId, address _newAddress) public onlyOwner {
        cryptoGamers[_cryptoGamerId].CryptoGamerAddress = _newAddress;
    }
    
    /*
    The owner can use this function to create new cryptoGamers.
    The price is set in WEI
    Important: If you purchased the contract and are the owner of this game, create the CryptoGamers from your admin section in the game instead calling this function from another place.
    */
    function createCryptoGamer(string _cryptoGamerName, uint256 _cryptoGamerPrice, address _verifiedAddress) public onlyOwner {
        cryptoGamers.push(CryptoGamer(_cryptoGamerName, address(this), _cryptoGamerPrice, _verifiedAddress));
    }
    
    // Initiate functions that will create the cryptoGamers
    function InitiateCryptoGamers() public onlyOwner {
        require(cryptoGamersAreInitiated == false);
        cryptoGamers.push(CryptoGamer("Phil", 0x183febd8828a9ac6c70c0e27fbf441b93004fc05, 1012500000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Carlini8", address(this), 310000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Ferocious", 0x1A5fe261E8D9e8efC5064EEccC09B531E6E24BD3, 375000000000000000, 0x1A5fe261E8D9e8efC5064EEccC09B531E6E24BD3));
        cryptoGamers.push(CryptoGamer("Pranked", address(this), 224000000000000000, 0xD387A6E4e84a6C86bd90C158C6028A58CC8Ac459));
        cryptoGamers.push(CryptoGamer("SwagDaPanda", address(this), 181000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Slush", address(this), 141000000000000000, 0x70580eA14d98a53fd59376dC7e959F4a6129bB9b));
        cryptoGamers.push(CryptoGamer("Acapuck", address(this), 107000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Arwynian", address(this), 131000000000000000, 0xA3b61695E46432E5CCCd0427AD956fa146379D08));
        cryptoGamers.push(CryptoGamer("Bohl", address(this), 106000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Corgi", address(this), 91500000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Enderhero", address(this), 104000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Hecatonquiro", address(this), 105000000000000000, 0xB87e73ad25086C43a16fE5f9589Ff265F8A3A9Eb));
        cryptoGamers.push(CryptoGamer("herb", address(this), 101500000000000000, 0x466aCFE9f93D167EA8c8fa6B8515A65Aa47784dD));
        cryptoGamers.push(CryptoGamer("Kail", address(this), 103000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("karupin the cat", 0x5632ca98e5788eddb2397757aa82d1ed6171e5ad, 108100000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("LiveFree", 0x3177abbe93422c9525652b5d4e1101a248a99776, 90100000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Prokiller", address(this), 100200000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Sanko", address(this), 101000000000000000, 0x71f35825a3B1528859dFa1A64b24242BC0d12990));
        cryptoGamers.push(CryptoGamer("TheHermitMonk", address(this), 100000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("TomiSharked", 0x9afbaa3003d9e75c35fde2d1fd283b13d3335f00, 89000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Zalman", 0x9afbaa3003d9e75c35fde2d1fd283b13d3335f00, 92000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("xxFyMxx", address(this), 110000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("UncleTom", address(this), 90000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("legal", address(this), 115000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Terpsicores", address(this), 102000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("triceratops", 0x9afbaa3003d9e75c35fde2d1fd283b13d3335f00, 109000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("souto", address(this), 85000000000000000, 0x0));
        cryptoGamers.push(CryptoGamer("Danimal", 0xa586a3b8939e9c0dc72d88166f6f6bb7558eedce, 85000000000000000, 0x3177Abbe93422c9525652b5d4e1101a248A99776));

    }
}