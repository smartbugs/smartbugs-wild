pragma solidity ^0.4.24;

/*

    ____  _______   ________   __________  _   ____________  ____  __ 
   / __ \/ ____/ | / /_  __/  / ____/ __ \/ | / /_  __/ __ \/ __ \/ / 
  / /_/ / __/ /  |/ / / /    / /   / / / /  |/ / / / / /_/ / / / / /  
 / _, _/ /___/ /|  / / /    / /___/ /_/ / /|  / / / / _, _/ /_/ / /___
/_/ |_/_____/_/ |_/ /_/     \____/\____/_/ |_/ /_/ /_/ |_|\____/_____/
                                                                      
website:    https://rentcontrol.tk

discord:    https://discord.gg/X78kgWp

Buy Property.   Collect Rent.

Rent Control is a strategy game where you buy property levels and collect rent from other owners.

Game begins with 20 property levels.    Level 1 is the best and most valuable.    When you own a property level, you collect rent from the purchases of every other level.
Different levels have different rates of rent.    Level 1 collects 10% of all rent distributions from each purchase.
Once you buy a property level it is then available for purchase at a price 10% higher than what you paid.    So you will earn rent while you won the property AND you will have a capital gain
when someone buys the level from you.

Property owner receives 50% of the gain from a sale.

30% of gains are distributed to other property owners based on their rates of rent.

20% of gains are distributed to dev.

Masternodes recieve 5% of any distributions from buyers using the link.

*/

contract RENTCONTROL {
    /*=================================
    =        MODIFIERS        =
    =================================*/
   


    modifier onlyOwner(){
        
        require(msg.sender == dev);
        _;
    }
    

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onLevelPurchase(
        address customerAddress,
        uint256 incomingEthereum,
        uint256 level,
        uint256 newPrice
    );
    
    event onWithdraw(
        address customerAddress,
        uint256 ethereumWithdrawn
    );
    
    // ERC20
    event Transfer(
        address from,
        address to,
        uint256 level
    );

    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "RENT CONTROL";
    string public symbol = "LEVEL";

    uint8 constant public devDivRate = 20;
    uint8 constant public ownerDivRate = 50;
    uint8 constant public distDivRate = 30;

    uint8 constant public referralRate = 5; 

    uint8 constant public decimals = 18;
  
    uint public totalLevelValue = 2465e16;

    
   /*================================
    =            DATASETS            =
    ================================*/
    
    mapping(uint => address) internal levelOwner;
    mapping(uint => uint) public levelPrice;
    mapping(uint => uint) internal levelPreviousPrice;
    mapping(address => uint) internal ownerAccounts;
    mapping(uint => uint) internal totalLevelDivs;
    mapping(uint => string) internal levelName;

    uint levelPriceIncrement = 110;
    uint totalDivsProduced = 0;

    uint public maxLevels = 200;
    
    uint public initialPrice = 5e16;   //0.05 ETH

    uint public nextAvailableLevel;

    bool allowReferral = false;

    bool allowAutoNewLevel = false;
   
    address dev;

    
    


    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    function RENTCONTROL()
        public
    {
        dev = msg.sender;
        nextAvailableLevel = 21;

        levelOwner[1] = dev;
        levelPrice[1] = 5e18;
        levelPreviousPrice[1] = levelPrice[1];

        levelOwner[2] = dev;
        levelPrice[2] = 4e18;
        levelPreviousPrice[2] = levelPrice[2];

        levelOwner[3] = dev;
        levelPrice[3] = 3e18;
        levelPreviousPrice[3] = levelPrice[3];

        levelOwner[4] = dev;
        levelPrice[4] = 25e17;
        levelPreviousPrice[4] = levelPrice[4];

        levelOwner[5] = dev;
        levelPrice[5] = 20e17;
        levelPreviousPrice[5] = levelPrice[5];

        levelOwner[6] = dev;
        levelPrice[6] = 15e17;
        levelPreviousPrice[6] = levelPrice[6];

        levelOwner[7] = dev;
        levelPrice[7] = 125e16;
        levelPreviousPrice[7] = levelPrice[7];

        levelOwner[8] = dev;
        levelPrice[8] = 100e16;
        levelPreviousPrice[8] = levelPrice[8];

        levelOwner[9] = dev;
        levelPrice[9] = 80e16;
        levelPreviousPrice[9] = levelPrice[9];

        levelOwner[10] = dev;
        levelPrice[10] = 70e16;
        levelPreviousPrice[10] = levelPrice[10];

        levelOwner[11] = dev;
        levelPrice[11] = 60e16;
        levelPreviousPrice[11] = levelPrice[11];

        levelOwner[12] = dev;
        levelPrice[12] = 50e16;
        levelPreviousPrice[12] = levelPrice[12];

        levelOwner[13] = dev;
        levelPrice[13] = 40e16;
        levelPreviousPrice[13] = levelPrice[13];

        levelOwner[14] = dev;
        levelPrice[14] = 35e16;
        levelPreviousPrice[14] = levelPrice[14];

        levelOwner[15] = dev;
        levelPrice[15] = 30e16;
        levelPreviousPrice[15] = levelPrice[15];

        levelOwner[16] = dev;
        levelPrice[16] = 25e16;
        levelPreviousPrice[16] = levelPrice[16];

        levelOwner[17] = dev;
        levelPrice[17] = 20e16;
        levelPreviousPrice[17] = levelPrice[17];

        levelOwner[18] = dev;
        levelPrice[18] = 15e16;
        levelPreviousPrice[18] = levelPrice[18];

        levelOwner[19] = dev;
        levelPrice[19] = 10e16;
        levelPreviousPrice[19] = levelPrice[19];

        levelOwner[20] = dev;
        levelPrice[20] = 5e16;
        levelPreviousPrice[20] = levelPrice[20];


    }

    function addTotalLevelValue(uint _new, uint _old)
    internal
    {
        uint newPrice = SafeMath.div(SafeMath.mul(_new,levelPriceIncrement),100);
        totalLevelValue = SafeMath.add(totalLevelValue, SafeMath.sub(newPrice,_old));
    }
    
    function buy(uint _level, address _referrer)
        public
        payable

    {
        require(_level <= nextAvailableLevel);
        require(msg.value >= levelPrice[_level]);
        addTotalLevelValue(msg.value, levelPreviousPrice[_level]);

        if (levelOwner[_level] == dev){   

            require(msg.value >= levelPrice[_level]);
           // uint _price = msg.value;

            if ((allowAutoNewLevel) && (_level == nextAvailableLevel - 1) && nextAvailableLevel < maxLevels) {
                levelOwner[nextAvailableLevel] = dev;
                levelPrice[nextAvailableLevel] = initialPrice;
                nextAvailableLevel = nextAvailableLevel + 1;
                
            }

            

            ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev],msg.value);

            levelOwner[_level] = msg.sender;

            //Increment the Level Price
            levelPreviousPrice[_level] = msg.value;
            levelPrice[_level] = SafeMath.div(SafeMath.mul(msg.value,levelPriceIncrement),100);
            //levelName[_level] = _name;     //Give your level an optional name


        } else {      

            require(msg.sender != levelOwner[_level]);

           // uint _price = msg.value;

            uint _newPrice = SafeMath.div(SafeMath.mul(msg.value,levelPriceIncrement),100);

             //Determine the total dividends
            uint _baseDividends = msg.value - levelPreviousPrice[_level];
            totalDivsProduced = SafeMath.add(totalDivsProduced, _baseDividends);

            uint _devDividends = SafeMath.div(SafeMath.mul(_baseDividends,devDivRate),100);
            uint _ownerDividends = SafeMath.div(SafeMath.mul(_baseDividends,ownerDivRate),100);

            totalLevelDivs[_level] = SafeMath.add(totalLevelDivs[_level],_ownerDividends);
            _ownerDividends = SafeMath.add(_ownerDividends,levelPreviousPrice[_level]);
            
            uint _distDividends = SafeMath.div(SafeMath.mul(_baseDividends,distDivRate),100);

            if (allowReferral && (_referrer != msg.sender) && (_referrer != 0x0000000000000000000000000000000000000000)) {
                
                uint _referralDividends = SafeMath.div(SafeMath.mul(_baseDividends,referralRate),100);
                _distDividends = SafeMath.sub(_distDividends,_referralDividends);
                ownerAccounts[_referrer] = SafeMath.add(ownerAccounts[_referrer],_referralDividends);
            }
            


            //distribute dividends to accounts
            address _previousOwner = levelOwner[_level];
            address _newOwner = msg.sender;

            ownerAccounts[_previousOwner] = SafeMath.add(ownerAccounts[_previousOwner],_ownerDividends);
            ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev],_devDividends);

            distributeRent(nextAvailableLevel, _distDividends);

            //Increment the Level Price
            levelPreviousPrice[_level] = msg.value;
            levelPrice[_level] = _newPrice;
            levelOwner[_level] = _newOwner;
            //levelName[_level] = _name;   //Give your level an optional name

        }

        emit onLevelPurchase(msg.sender, msg.value, _level, SafeMath.div(SafeMath.mul(msg.value,levelPriceIncrement),100));
     
    }

    function distributeRent(uint _levels, uint _distDividends) {

        uint _distFactor = 10;
        uint counter = 1;

        ownerAccounts[dev] = SafeMath.add(ownerAccounts[dev], _distDividends);

        while (counter < nextAvailableLevel) { 
                
            uint _distAmountLocal = SafeMath.div(_distDividends,_distFactor);
            ownerAccounts[levelOwner[counter]] = SafeMath.add(ownerAccounts[levelOwner[counter]],_distAmountLocal);
            totalLevelDivs[counter] = SafeMath.add(totalLevelDivs[counter],_distAmountLocal);
            counter = counter + 1;
            ownerAccounts[dev] = SafeMath.sub(ownerAccounts[dev], _distAmountLocal);
            _distFactor = SafeMath.div(SafeMath.mul(_distFactor, 112),100);
        } 

    }


    function withdraw()
    
        public
    {
        address _customerAddress = msg.sender;
        require(ownerAccounts[_customerAddress] > 0);
        uint _dividends = ownerAccounts[_customerAddress];
        ownerAccounts[_customerAddress] = 0;
        _customerAddress.transfer(_dividends);
        // fire event
        onWithdraw(_customerAddress, _dividends);
    }

    function withdrawPart(uint _amount)
    
        public
        onlyOwner()
    {
        address _customerAddress = msg.sender;
        require(ownerAccounts[_customerAddress] > 0);
        require(_amount <= ownerAccounts[_customerAddress]);
        ownerAccounts[_customerAddress] = SafeMath.sub(ownerAccounts[_customerAddress],_amount);
        _customerAddress.transfer(_amount);
        // fire event
        onWithdraw(_customerAddress, _amount);
    }


    

     // Fallback function: just send funds back

    function()
        payable
        public
    {
        revert();
    }
    
    /**
     * Transfer Level to another address
     */
    function transfer(address _to, uint _level )
       
        public
    {
        require(levelOwner[nextAvailableLevel] == msg.sender);

        levelOwner[nextAvailableLevel] = _to;

        emit Transfer(msg.sender, _to, _level);

    }
    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**

    /**
     * If we want to rebrand, we can.
     */
    function setName(string _name)
        onlyOwner()
        public
    {
        name = _name;
    }
    
    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string _symbol)
        onlyOwner()
        public
    {
        symbol = _symbol;
    }

    function setInitialPrice(uint _price)
        onlyOwner()
        public
    {
        initialPrice = _price;
    }

    function setMaxLevels(uint _level)  
        onlyOwner()
        public
    {
        maxLevels = _level;
    }

    function setLevelPrice(uint _level, uint _price)   //Allow the changing of a level price owner if the dev owns it
        onlyOwner()
        public
    {
        require(levelOwner[_level] == dev);
        levelPrice[_level] = _price;
    }
    
    function addNewLevel(uint _price) 
        onlyOwner()
        public
    {
        require(nextAvailableLevel < maxLevels);
        levelPrice[nextAvailableLevel] = _price;
        levelOwner[nextAvailableLevel] = dev;
        totalLevelDivs[nextAvailableLevel] = 0;
        nextAvailableLevel = nextAvailableLevel + 1;
    }

    function setAllowReferral(bool _allowReferral)   
        onlyOwner()
        public
    {
        allowReferral = _allowReferral;
    }

    function setAutoNewlevel(bool _autoNewLevel)   
        onlyOwner()
        public
    {
        allowAutoNewLevel = _autoNewLevel;
    }

    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */


    function getMyBalance()
        public
        view
        returns(uint)
    {
        return ownerAccounts[msg.sender];
    }

    function getOwnerBalance(address _levelOwner)
        public
        view
        returns(uint)
    {
        require(msg.sender == dev);
        return ownerAccounts[_levelOwner];
    }
    
    function getlevelPrice(uint _level)
        public
        view
        returns(uint)
    {
        require(_level <= nextAvailableLevel);
        return levelPrice[_level];
    }

    function getlevelOwner(uint _level)
        public
        view
        returns(address)
    {
        require(_level <= nextAvailableLevel);
        return levelOwner[_level];
    }

    function gettotalLevelDivs(uint _level)
        public
        view
        returns(uint)
    {
        require(_level <= nextAvailableLevel);
        return totalLevelDivs[_level];
    }

    function getTotalDivsProduced()
        public
        view
        returns(uint)
    {
     
        return totalDivsProduced;
    }

    function getTotalLevelValue()
        public
        view
        returns(uint)
    {
      
        return totalLevelValue;
    }

    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address (this).balance;
    }

    function getNextAvailableLevel()
        public
        view
        returns(uint)
    {
        return nextAvailableLevel;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
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
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}