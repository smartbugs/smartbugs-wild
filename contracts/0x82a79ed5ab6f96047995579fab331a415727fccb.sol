pragma solidity ^0.4.18;

contract SubPrimeCrypto {
    struct Listing {
        uint startPrice;
        uint endPrice;
        uint startedAt;
        uint endsAt;
        bool isAvailable;
    }

    enum HouseClasses {
        Shack,
        Apartment,
        Bungalow,
        House,
        Mansion,
        Estate,
        Penthouse,
        Ashes
    }

    struct House {
        address owner;
        uint streetNumber;
        string streetName;
        string streetType;
        string colorCode;
        uint numBedrooms;
        uint numBathrooms;
        uint squareFootage;
        uint propertyValue;
        uint statusValue;
        HouseClasses class;
        uint classVariant;
    }

    struct Trait {
        string name;
        bool isNegative;
    }

    address public gameOwner;
    address public gameDeveloper;

    uint public presaleSales;
    uint public presaleLimit = 5000;
    bool public presaleOngoing = true;

    uint public buildPrice = 150 finney;
    uint public additionPrice = 100 finney;
    uint public saleFee = 2; // percent

    House[] public houses;
    Trait[] public traits;

    mapping (uint => uint[4]) public houseTraits;
    mapping (uint => Listing) public listings;

    mapping (address => uint) public houseCredits;
    mapping (address => uint) public ownedHouses;
    mapping (uint => uint) public classVariants;
    mapping (uint => address) approvedTransfers;

    string[] colors;
    string[] streetNames;
    string[] streetTypes;

    modifier onlyBy(address _authorized) {
        require(msg.sender == _authorized);
        _;
    }

    modifier onlyByOwnerOrDev {
        require(msg.sender == gameOwner || msg.sender == gameDeveloper);
        _;
    }

    modifier onlyByAssetOwner(uint _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    modifier onlyDuringPresale {
        require(presaleOngoing);
        _;
    }

    function SubPrimeCrypto() public {
        gameOwner = msg.sender;
        gameDeveloper = msg.sender;
    }

    /* ERC-20 Compatibility */
    function name() pure public returns (string) {
        return "SubPrimeCrypto";
    }

    function symbol() pure public returns (string) {
        return "HOUSE";
    }

    function totalSupply() view public returns (uint) {
        return houses.length;
    }

    function balanceOf(address _owner) constant public returns (uint) {
        return ownedHouses[_owner];
    }

    /* ERC-20 + ERC-721 Token Events */
    event Transfer(address indexed _from, address indexed _to, uint _numTokens);
    event Approval(address indexed _owner, address indexed _approved, uint _tokenId);

    /* ERC-721 Token Ownership */
    function ownerOf(uint _tokenId) constant public returns (address) {
        return houses[_tokenId].owner;
    }

    function approve(address _to, uint _tokenId) onlyByAssetOwner(_tokenId) public {
        require(msg.sender != _to);
        approvedTransfers[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }

    function approveAndTransfer(address _to, uint _tokenId) internal {
        House storage house = houses[_tokenId];

        address oldOwner = house.owner;
        address newOwner = _to;

        ownedHouses[oldOwner]--;
        ownedHouses[newOwner]++;
        house.owner = newOwner;

        Approval(oldOwner, newOwner, _tokenId);
        Transfer(oldOwner, newOwner, 1);
    }

    function takeOwnership(uint _tokenId) public {
        House storage house = houses[_tokenId];

        address oldOwner = house.owner;
        address newOwner = msg.sender;

        require(approvedTransfers[_tokenId] == newOwner);

        ownedHouses[oldOwner] -= 1;
        ownedHouses[newOwner] += 1;
        house.owner = newOwner;

        Transfer(oldOwner, newOwner, 1);
    }

    function transfer(address _to, uint _tokenId) public {
        House storage house = houses[_tokenId];

        address oldOwner = house.owner;
        address newOwner = _to;

        require(oldOwner != newOwner);
        require(
            (msg.sender == oldOwner) ||
            (approvedTransfers[_tokenId] == newOwner)
        );

        ownedHouses[oldOwner]--;
        ownedHouses[newOwner]++;
        house.owner = newOwner;

        Transfer(oldOwner, newOwner, 1);
    }

    /* Token-Specific Events */
    event Minted(uint _tokenId);
    event Upgraded(uint _tokenId);
    event Destroyed(uint _tokenId);

    /* Public Functionality */
    function buildHouse() payable public {
        if (houseCredits[msg.sender] > 0) {
            houseCredits[msg.sender]--;
        } else {
            require(msg.value >= buildPrice);
            if (presaleOngoing) presaleSales++;
        }

        generateHouse(msg.sender);
    }

    function buildAddition(uint _tokenId) onlyByAssetOwner(_tokenId) payable public {
        require(msg.value >= additionPrice);
        House storage house = houses[_tokenId];

        upgradeAsset(_tokenId, false);

        house.numBedrooms++;
        house.numBathrooms++;
        house.statusValue += house.statusValue / 10;

        Upgraded(_tokenId);
    }

    function burnForInsurance(uint _tokenId) onlyByAssetOwner(_tokenId) public {
        House storage house = houses[_tokenId];
        uint rand = notRandomWithSeed(1000, _tokenId);

        // 80% chance "claim" is investigated
        if (rand > 799) {
            upgradeAsset(_tokenId, true);
        } else {
            // investigations yield equal chance of upgrade or permanent loss
            if (rand > 499) {
                upgradeAsset(_tokenId, true);
            } else {
                house.class = HouseClasses.Ashes;
                house.statusValue = 0;
                house.numBedrooms = 0;
                house.numBathrooms = 0;
                house.propertyValue = 0;
                Destroyed(_tokenId);
            }
        }
    }

    function purchaseAsset(uint _tokenId) payable public {
        Listing storage listing = listings[_tokenId];

        uint currentPrice = calculateCurrentPrice(listing);
        require(currentPrice > 0 && msg.value >= currentPrice);
        require(listing.isAvailable && listing.endsAt > now);
        listing.isAvailable = false;

        if (houses[_tokenId].owner != address(this)) {
            uint fee = currentPrice / (100 / saleFee);
            houses[_tokenId].owner.transfer(currentPrice - fee);
        } else {
            if (++presaleSales >= presaleLimit) {
                presaleOngoing = false;
            }
        }

        approveAndTransfer(msg.sender, _tokenId);
    }

    function listAsset(uint _tokenId, uint _startPrice, uint _endPrice, uint _numHours) onlyByAssetOwner(_tokenId) public {
        createListing(_tokenId, _startPrice, _endPrice, _numHours);
    }

    function removeAssetListing(uint _tokenId) public onlyByAssetOwner(_tokenId) {
        listings[_tokenId].isAvailable = false;
    }

    function getHouseTraits(uint _tokenId) public view returns (uint[4]) {
        return houseTraits[_tokenId];
    }

    function getTraitCount() public view returns (uint) {
        return traits.length;
    }

    /* Admin Functionality */
    function addNewColor(string _colorCode) public onlyByOwnerOrDev {
        colors[colors.length++] = _colorCode;
    }

    function addNewTrait(string _name, bool _isNegative) public onlyByOwnerOrDev {
        uint traitId = traits.length++;
        traits[traitId].name = _name;
        traits[traitId].isNegative = _isNegative;
    }

    function add5NewTraits(string _one, string _two, string _three, string _four, string _five, bool _isNegative) public onlyByOwnerOrDev {
        addNewTrait(_one, _isNegative);
        addNewTrait(_two, _isNegative);
        addNewTrait(_three, _isNegative);
        addNewTrait(_four, _isNegative);
        addNewTrait(_five, _isNegative);
    }

    function addNewStreetName(string _name) public onlyByOwnerOrDev {
        streetNames[streetNames.length++] = _name;
    }

    function add5NewStreetNames(string _one, string _two, string _three, string _four, string _five) public onlyByOwnerOrDev {
        addNewStreetName(_one);
        addNewStreetName(_two);
        addNewStreetName(_three);
        addNewStreetName(_four);
        addNewStreetName(_five);
    }

    function addNewStreetType(string _type) public onlyByOwnerOrDev {
        streetTypes[streetTypes.length++] = _type;
    }

    function addHouseCredits(address _address, uint _numCredits) public onlyByOwnerOrDev {
        houseCredits[_address] += _numCredits;
    }

    function generatePresaleHouses() public onlyByOwnerOrDev onlyDuringPresale {
        uint initialGas = msg.gas;
        generateAndListPresaleHouse();

        while (msg.gas > (initialGas - msg.gas)) {
            generateAndListPresaleHouse();
        }
    }

    function setBuildPrice(uint _buildPrice) public onlyBy(gameOwner) {
        buildPrice = _buildPrice;
    }

    function setAdditionPrice(uint _additionPrice) public onlyBy(gameOwner) {
        additionPrice = _additionPrice;
    }

    function setSaleFee(uint _saleFee) public onlyBy(gameOwner) {
        saleFee = _saleFee;
    }

    function setVariantCount(uint _houseClass, uint _variantCount) public onlyByOwnerOrDev {
        classVariants[_houseClass] = _variantCount;
    }

    function withdrawFees() public onlyByOwnerOrDev {
        if (presaleOngoing) gameDeveloper.transfer(this.balance / 5);
        gameOwner.transfer(this.balance);
    }

    function transferGameOwnership(address _newOwner) public onlyBy(gameOwner) {
        gameOwner = _newOwner;
    }

    /* Internal Functionality */
    function generateHouse(address owner) internal returns (uint houseId) {
        houseId = houses.length++;

        HouseClasses houseClass = randomHouseClass();
        uint numBedrooms = randomBedrooms(houseClass);
        uint numBathrooms = randomBathrooms(numBedrooms);
        uint squareFootage = calculateSquareFootage(houseClass, numBedrooms, numBathrooms);
        uint propertyValue = calculatePropertyValue(houseClass, squareFootage, numBathrooms, numBedrooms);

        houses[houseId] = House({
            owner: owner,
            class: houseClass,
            streetNumber: notRandomWithSeed(9999, squareFootage + houseId),
            streetName: streetNames[notRandom(streetNames.length)],
            streetType: streetTypes[notRandom(streetTypes.length)],
            propertyValue: propertyValue,
            statusValue: propertyValue / 10000,
            colorCode: colors[notRandom(colors.length)],
            numBathrooms: numBathrooms,
            numBedrooms: numBedrooms,
            squareFootage: squareFootage,
            classVariant: randomClassVariant(houseClass)
        });

        houseTraits[houseId] = [
            notRandomWithSeed(traits.length, propertyValue + houseId * 5),
            notRandomWithSeed(traits.length, squareFootage + houseId * 4),
            notRandomWithSeed(traits.length, numBathrooms + houseId * 3),
            notRandomWithSeed(traits.length, numBedrooms + houseId * 2)
        ];

        ownedHouses[owner]++;
        Minted(houseId);
        Transfer(address(0), owner, 1);

        return houseId;
    }

    function generateAndListPresaleHouse() internal {
        uint houseId = generateHouse(this);
        uint sellPrice = (houses[houseId].propertyValue / 5000) * 1 finney;

        if (sellPrice > 250 finney) sellPrice = 250 finney;
        if (sellPrice < 50 finney) sellPrice = 50 finney;

        createListing(houseId, sellPrice, sellPrice, 365 * 24);
    }

    function createListing(uint tokenId, uint startPrice, uint endPrice, uint numHours) internal {
        listings[tokenId] = Listing({
            startPrice: startPrice,
            endPrice: endPrice,
            startedAt: now,
            endsAt: now + (numHours * 1 hours),
            isAvailable: true
        });
    }

    function calculateCurrentPrice(Listing listing) internal view returns (uint) {
        if (listing.endPrice == listing.startPrice || listing.endPrice == 0) {
            return listing.startPrice;
        } else {
            uint totalNumberOfSeconds = listing.endsAt - listing.startedAt;
            uint secondSinceStart = now - listing.startedAt;
            int priceChangePerSecond = int(listing.endPrice - listing.startPrice) / int(totalNumberOfSeconds);

            return uint(int(listing.startPrice) + int(priceChangePerSecond * int(secondSinceStart)));
        }
    }

    function calculatePropertyValue(HouseClasses houseClass, uint squareFootage, uint numBathrooms, uint numBedrooms) pure internal returns (uint) {
        uint propertyValue = (uint(houseClass) + 1) * 10;
        propertyValue += (numBathrooms + 1) * 10;
        propertyValue += (numBedrooms + 1) * 25;
        propertyValue += squareFootage * 25;
        propertyValue *= 5;

        return uint(houseClass) > 4 ? propertyValue * 5 : propertyValue;
    }

    function randomHouseClass() internal view returns (HouseClasses) {
        uint rand = notRandom(1000);

        if (rand < 200) {
            return HouseClasses.Shack;
        } else if (rand > 200 && rand < 400) {
            return HouseClasses.Apartment;
        } else if (rand > 400 && rand < 600) {
            return HouseClasses.Bungalow;
        } else if (rand > 600 && rand < 800) {
            return HouseClasses.House;
        } else {
            return HouseClasses.Mansion;
        }
    }

    function randomClassVariant(HouseClasses houseClass) internal view returns (uint) {
        uint possibleVariants = 10;
        if (classVariants[uint(houseClass)] != 0) possibleVariants = classVariants[uint(houseClass)];
        return notRandom(possibleVariants);
    }

    function randomBedrooms(HouseClasses houseClass) internal view returns (uint) {
        uint class = uint(houseClass);
        return class >= 1 ? class + notRandom(4) : 0;
    }

    function randomBathrooms(uint numBedrooms) internal view returns (uint) {
        return numBedrooms < 2 ? numBedrooms : numBedrooms - notRandom(3);
    }

    function calculateSquareFootage(HouseClasses houseClass, uint numBedrooms, uint numBathrooms) internal pure returns (uint) {
        uint baseSqft = uint(houseClass) >= 4 ? 50 : 25;
        uint multiplier = uint(houseClass) + 1;

        uint bedroomSqft = (numBedrooms + 1) * 10 * baseSqft;
        uint bathroomSqft = (numBathrooms + 1) * 5 * baseSqft;

        return (bedroomSqft + bathroomSqft) * multiplier;
    }

    function upgradeAsset(uint tokenId, bool allowClassUpgrade) internal {
        House storage house = houses[tokenId];

        house.numBedrooms++;
        house.numBathrooms++;

        if (allowClassUpgrade) {
            uint class = uint(house.class);
            if (class <= house.numBedrooms) {
                house.class = HouseClasses.Bungalow;
            } else if (class < 2 && house.numBedrooms > 5) {
                house.class = HouseClasses.Penthouse;
            } else if (class < 4 && house.numBedrooms > 10) {
                house.class = HouseClasses.Mansion;
            } else if (class < 6 && house.numBedrooms > 15) {
                house.class = HouseClasses.Estate;
            }
        }

        house.squareFootage = calculateSquareFootage(
            house.class, house.numBedrooms, house.numBathrooms
        );

        house.propertyValue = calculatePropertyValue(
            house.class, house.squareFootage, house.numBathrooms, house.numBedrooms
        );

        house.statusValue += house.statusValue / 10;
        Upgraded(tokenId);
    }

    function notRandom(uint lessThan) public view returns (uint) {
        return uint(keccak256(
            (houses.length + 1) + (tx.gasprice * lessThan) +
            (block.difficulty * block.number + now) * msg.gas
        )) % lessThan;
    }

    function notRandomWithSeed(uint lessThan, uint seed) public view returns (uint) {
        return uint(keccak256(
            seed + block.gaslimit + block.number
        )) % lessThan;
    }
}