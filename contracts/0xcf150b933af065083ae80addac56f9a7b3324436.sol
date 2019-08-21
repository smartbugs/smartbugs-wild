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
        
        leastExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  
        mostExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission5percent * 3); // => 85%
        
        // This cryptoGamer is still owned by the contract, we transfer the commission to the ownerAddress
        if(cryptoGamers[_cryptoGamerId].ownerAddress == address(this)) {
            contractOwnerAddress.transfer(commissionOwner);

        } else {
            // This cryptogamer is owned by a user, we transfer the commission to this player
            cryptoGamers[_cryptoGamerId].ownerAddress.transfer(commissionOwner);
        }
        

        // Transfer the 5% commission to the developer
        contractOwnerAddress.transfer(commission5percent); // => 5%                   

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
        uint256 curPrice
    ) {
        CryptoGamer storage _cryptoGamer = cryptoGamers[_cryptoGamerId];

        name = _cryptoGamer.name;
        ownerAddress = _cryptoGamer.ownerAddress;
        curPrice = _cryptoGamer.curPrice;
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
    The owner can use this function to create new cryptoGamers.
    The price is set in WEI
    Important: If you purchased the contract and are the owner of this game, create the CryptoGamers from your admin section in the game instead calling this function from another place.
    */
    function createCryptoGamer(string _cryptoGamerName, uint256 _cryptoGamerPrice) public onlyOwner {
        cryptoGamers.push(CryptoGamer(_cryptoGamerName, address(this), _cryptoGamerPrice));
    }
    
    // Initiate functions that will create the cryptoGamers
    function InitiateCryptoGamers() public onlyOwner {
        require(cryptoGamersAreInitiated == false);
        createCryptoGamer("Phil", 450000000000000000); 
        createCryptoGamer("Carlini8", 310000000000000000); 
        createCryptoGamer("Ferocious", 250000000000000000); 
        createCryptoGamer("Pranked", 224000000000000000); 
        createCryptoGamer("SwagDaPanda", 181000000000000000); 
        createCryptoGamer("Slush", 141000000000000000); 
        createCryptoGamer("Acapuck", 107000000000000000); 
        createCryptoGamer("Arwynian", 131000000000000000); 
        createCryptoGamer("Bohl", 106000000000000000);
        createCryptoGamer("Corgi", 91500000000000000);
        createCryptoGamer("Enderhero", 104000000000000000);
        createCryptoGamer("Hecatonquiro", 105000000000000000);
        createCryptoGamer("herb", 101500000000000000);
        createCryptoGamer("Kail", 103000000000000000);
        createCryptoGamer("karupin the cat", 108100000000000000);
        createCryptoGamer("LiveFree", 90100000000000000);
        createCryptoGamer("Prokiller", 100200000000000000);
        createCryptoGamer("Sanko", 101000000000000000);
        createCryptoGamer("TheHermitMonk", 100000000000000000);
        createCryptoGamer("TomiSharked", 89000000000000000);
        createCryptoGamer("Zalman", 92000000000000000);
        createCryptoGamer("xxFyMxx", 110000000000000000);
        createCryptoGamer("UncleTom", 90000000000000000);
        createCryptoGamer("legal", 115000000000000000);
        createCryptoGamer("Terpsicores", 102000000000000000);
        createCryptoGamer("triceratops", 109000000000000000);
        createCryptoGamer("souto", 85000000000000000);
    }
}