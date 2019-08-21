pragma solidity ^0.4.15;

contract CryptoElections {

    /* Define variable owner of the type address */
    address creator;

    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    modifier onlyCountryOwner(uint256 countryId) {
        require(countries[countryId].president==msg.sender);
        _;
    }
    modifier onlyCityOwner(uint cityId) {
        require(cities[cityId].mayor==msg.sender);
        _;
    }

    struct Country {
        address president;
        string slogan;
        string flagUrl;
    }
    struct City {
        address mayor;
        string slogan;
        string picture;
        uint purchases;
    }
    bool maintenance=false;
    event withdrawalEvent(address user,uint value);
    event pendingWithdrawalEvent(address user,uint value);
    event assignCountryEvent(address user,uint countryId);
    event buyCityEvent(address user,uint cityId);
    mapping(uint => Country) public countries ;
    mapping(uint =>  uint[]) public countriesCities ;
    mapping(uint =>  uint) public citiesCountries ;

    mapping(uint =>  uint) public cityPopulation ;
    mapping(uint => City) public cities;
    mapping(address => uint[]) public userCities;
    mapping(address => uint) public userPendingWithdrawals;
    mapping(address => string) public userNicknames;

    function CryptoElections() public {
        creator = msg.sender;
    }

    function () public payable {
        revert();
    }

    /* This function is executed at initialization and sets the owner of the contract */
    /* Function to recover the funds on the contract */
    function kill() public
    onlyCreator()
    {
        selfdestruct(creator);
    }

    function transfer(address newCreator) public
    onlyCreator()
    {
        creator=newCreator;
    }



    // Contract initialisation
    function addCountryCities(uint countryId,uint[] _cities)  public
    onlyCreator()
    {
        countriesCities[countryId] = _cities;
        for (uint i = 0;i<_cities.length;i++) {
            citiesCountries[_cities[i]] = countryId;

        }
    }
    function setMaintenanceMode(bool _maintenance) public
    onlyCreator()
    {
        maintenance=_maintenance;
    }


    // Contract initialisation
    function addCitiesPopulation(uint[] _cities,uint[]_populations)  public
    onlyCreator()
    {

        for (uint i = 0;i<_cities.length;i++) {

            cityPopulation[_cities[i]] = _populations[i];
        }
    }

    function setCountrySlogan(uint countryId,string slogan) public
    onlyCountryOwner(countryId)
    {
        countries[countryId].slogan = slogan;
    }

    function setCountryPicture(uint countryId,string _flagUrl) public
    onlyCountryOwner(countryId)
    {
        countries[countryId].flagUrl = _flagUrl;
    }

    function setCitySlogan(uint256 cityId,string _slogan) public
    onlyCityOwner(cityId)
    {
        cities[cityId].slogan = _slogan;
    }

    function setCityPicture(uint256 cityId,string _picture) public
    onlyCityOwner(cityId)
    {
        cities[cityId].picture = _picture;
    }


    function withdraw() public {
        if (maintenance) revert();
        uint amount = userPendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks

        userPendingWithdrawals[msg.sender] = 0;
        withdrawalEvent(msg.sender,amount);
        msg.sender.transfer(amount);
    }

    function getPrices(uint purchases) public pure returns (uint[4]) {
        uint price = 20000000000000000; // 16x0
        uint pricePrev = 20000000000000000;
        uint systemCommission = 19000000000000000;
        uint presidentCommission = 1000000000000000;
        uint ownerCommission;

        for (uint i = 1;i<=purchases;i++) {
            if (i<=7)
                price = price*2;
            else
                price = (price*12)/10;

            presidentCommission = price/100;
            systemCommission = (price-pricePrev)*2/10;
            ownerCommission = price-presidentCommission-systemCommission;

            pricePrev = price;
        }
        return [price,systemCommission,presidentCommission,ownerCommission];
    }

    function setNickname(string nickname) public {
        if (maintenance) revert();
        userNicknames[msg.sender] = nickname;
    }

    function _assignCountry(uint countryId)    private returns (bool) {
        uint  totalPopulation;
        uint  controlledPopulation;

        uint  population;
        for (uint i = 0;i<countriesCities[countryId].length;i++) {
            population = cityPopulation[countriesCities[countryId][i]];
            if (cities[countriesCities[countryId][i]].mayor==msg.sender) {
                controlledPopulation += population;
            }
            totalPopulation += population;
        }
        if (controlledPopulation*2>(totalPopulation)) {
            countries[countryId].president = msg.sender;
            assignCountryEvent(msg.sender,countryId);
            return true;
        } else {
            return false;
        }
    }

    function buyCity(uint cityId) payable  public  {
        if (maintenance) revert();
        uint[4] memory prices = getPrices(cities[cityId].purchases);

        if (cities[cityId].mayor==msg.sender) {
            revert();
        }
        if (cityPopulation[cityId]==0) {
            revert();
        }

        if ( msg.value+userPendingWithdrawals[msg.sender]>=prices[0]) {
            // use user limit
            userPendingWithdrawals[msg.sender] = userPendingWithdrawals[msg.sender]+msg.value-prices[0];
            pendingWithdrawalEvent(msg.sender,userPendingWithdrawals[msg.sender]+msg.value-prices[0]);

            cities[cityId].purchases = cities[cityId].purchases+1;

            userPendingWithdrawals[cities[cityId].mayor] += prices[3];
            pendingWithdrawalEvent(cities[cityId].mayor,prices[3]);

            if (countries[citiesCountries[cityId]].president==0) {
                userPendingWithdrawals[creator] += prices[2];
                pendingWithdrawalEvent(creator,prices[2]);

            } else {
                userPendingWithdrawals[countries[citiesCountries[cityId]].president] += prices[2];
                pendingWithdrawalEvent(countries[citiesCountries[cityId]].president,prices[2]);
            }
            // change mayor
            if (cities[cityId].mayor>0) {
                _removeUserCity(cities[cityId].mayor,cityId);
            }



            cities[cityId].mayor = msg.sender;
            _addUserCity(msg.sender,cityId);

            _assignCountry(citiesCountries[cityId]);

            //send money to creator
            creator.transfer(prices[1]);
            buyCityEvent(msg.sender,cityId);

        } else {
            revert();
        }
    }
    function getUserCities(address user) public view returns (uint[]) {
        return userCities[user];
    }

    function _addUserCity(address user,uint cityId) private {
        bool added = false;
        for (uint i = 0; i<userCities[user].length; i++) {
            if (userCities[user][i]==0) {
                userCities[user][i] = cityId;
                added = true;
                break;
            }
        }
        if (!added)
            userCities[user].push(cityId);
    }

    function _removeUserCity(address user,uint cityId) private {
        for (uint i = 0; i<userCities[user].length; i++) {
            if (userCities[user][i]==cityId) {
                delete userCities[user][i];
            }
        }
    }

}