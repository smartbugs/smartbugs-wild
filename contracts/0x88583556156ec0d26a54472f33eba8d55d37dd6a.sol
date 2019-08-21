// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/generators/ColourGenerator.sol

pragma solidity ^0.5.0;


contract ColourGenerator is Ownable {

    uint256 internal randNonce = 0;

    event Colours(uint256 exteriorColorway, uint256 backgroundColorway);

    uint256 public exteriors = 20;
    uint256 public backgrounds = 8;

    function generate(address _sender)
    external
    returns (
        uint256 exteriorColorway,
        uint256 backgroundColorway
    ) {
        bytes32 hash = blockhash(block.number);

        uint256 exteriorColorwayRandom = generate(hash, _sender, exteriors);
        uint256 backgroundColorwayRandom = generate(hash, _sender, backgrounds);

        emit Colours(exteriorColorwayRandom, backgroundColorwayRandom);

        return (exteriorColorwayRandom, backgroundColorwayRandom);
    }

    function generate(bytes32 _hash, address _sender, uint256 _max) internal returns (uint256) {
        randNonce++;
        bytes memory packed = abi.encodePacked(_hash, _sender, randNonce);
        return uint256(keccak256(packed)) % _max;
    }

    function updateExteriors(uint256 _exteriors) public onlyOwner {
        exteriors = _exteriors;
    }

    function updateBackgrounds(uint256 _backgrounds) public onlyOwner {
        backgrounds = _backgrounds;
    }
}

// File: contracts/generators/LogicGenerator.sol

pragma solidity ^0.5.0;


contract LogicGenerator is Ownable {

    uint256 internal randNonce = 0;

    event Generated(
        uint256 city,
        uint256 building,
        uint256 base,
        uint256 body,
        uint256 roof,
        uint256 special
    );

    uint256[] public cityPercentages;

    mapping(uint256 => uint256[]) public cityMappings;

    mapping(uint256 => uint256[]) public buildingBaseMappings;
    mapping(uint256 => uint256[]) public buildingBodyMappings;
    mapping(uint256 => uint256[]) public buildingRoofMappings;

    uint256 public specialModulo = 7;
    uint256 public specialNo = 11;

    function generate(address _sender)
    external
    returns (uint256 city, uint256 building, uint256 base, uint256 body, uint256 roof, uint256 special) {
        bytes32 hash = blockhash(block.number);

        uint256 aCity = cityPercentages[generate(hash, _sender, cityPercentages.length)];

        uint256 aBuilding = cityMappings[aCity][generate(hash, _sender, cityMappings[aCity].length)];

        uint256 aBase = buildingBaseMappings[aBuilding][generate(hash, _sender, buildingBaseMappings[aBuilding].length)];
        uint256 aBody = buildingBodyMappings[aBuilding][generate(hash, _sender, buildingBodyMappings[aBuilding].length)];
        uint256 aRoof = buildingRoofMappings[aBuilding][generate(hash, _sender, buildingRoofMappings[aBuilding].length)];
        uint256 aSpecial = 0;

        // 1 in X roughly
        if (isSpecial(block.number)) {
            aSpecial = generate(hash, _sender, specialNo);
        }

        emit Generated(aCity, aBuilding, aBase, aBody, aRoof, aSpecial);

        return (aCity, aBuilding, aBase, aBody, aRoof, aSpecial);
    }

    function generate(bytes32 _hash, address _sender, uint256 _max) internal returns (uint256) {
        randNonce++;
        bytes memory packed = abi.encodePacked(_hash, _sender, randNonce);
        return uint256(keccak256(packed)) % _max;
    }

    function isSpecial(uint256 _blocknumber) public view returns (bool) {
        return (_blocknumber % specialModulo) == 0;
    }

    function updateBuildingBaseMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingBaseMappings[_building] = _params;
    }

    function updateBuildingBodyMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingBodyMappings[_building] = _params;
    }

    function updateBuildingRoofMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingRoofMappings[_building] = _params;
    }

    function updateSpecialModulo(uint256 _specialModulo) public onlyOwner {
        specialModulo = _specialModulo;
    }

    function updateSpecialNo(uint256 _specialNo) public onlyOwner {
        specialNo = _specialNo;
    }

    function updateCityPercentages(uint256[] memory _params) public onlyOwner {
        cityPercentages = _params;
    }

    function updateCityMappings(uint256 _cityIndex, uint256[] memory _params) public onlyOwner {
        cityMappings[_cityIndex] = _params;
    }

}

// File: contracts/FundsSplitter.sol

pragma solidity ^0.5.0;



contract FundsSplitter is Ownable {
    using SafeMath for uint256;

    address payable public blockcities;
    address payable public partner;

    uint256 public partnerRate = 15;

    constructor (address payable _blockcities, address payable _partner) public {
        blockcities = _blockcities;
        partner = _partner;
    }

    function splitFunds(uint256 _totalPrice) internal {
        if (msg.value > 0) {
            uint256 refund = msg.value.sub(_totalPrice);

            // overpaid...
            if (refund > 0) {
                msg.sender.transfer(refund);
            }

            // work out the amount to split and send it
            uint256 partnerAmount = _totalPrice.div(100).mul(partnerRate);
            partner.transfer(partnerAmount);

            // send remaining amount to blockCities wallet
            uint256 remaining = _totalPrice.sub(partnerAmount);
            blockcities.transfer(remaining);
        }
    }

    function updatePartnerAddress(address payable _partner) onlyOwner public {
        partner = _partner;
    }

    function updatePartnerRate(uint256 _techPartnerRate) onlyOwner public {
        partnerRate = _techPartnerRate;
    }

    function updateBlockcitiesAddress(address payable _blockcities) onlyOwner public {
        blockcities = _blockcities;
    }
}

// File: contracts/libs/Strings.sol

pragma solidity ^0.5.0;

library Strings {

    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

// File: contracts/IBlockCitiesCreator.sol

pragma solidity ^0.5.0;

interface IBlockCitiesCreator {
    function createBuilding(
        uint256 _exteriorColorway,
        uint256 _backgroundColorway,
        uint256 _city,
        uint256 _building,
        uint256 _base,
        uint256 _body,
        uint256 _roof,
        uint256 _special,
        address _architect
    ) external returns (uint256 _tokenId);
}

// File: contracts/BlockCitiesVendingMachine.sol

pragma solidity ^0.5.0;








contract BlockCitiesVendingMachine is Ownable, FundsSplitter {
    using SafeMath for uint256;

    event VendingMachineTriggered(
        uint256 indexed _tokenId,
        address indexed _architect
    );

    event CreditAdded(address indexed _to, uint256 _amount);

    event PriceDiscountBandsChanged(uint256[2] _priceDiscountBands);

    event PriceStepInWeiChanged(
        uint256 _oldPriceStepInWei,
        uint256 _newPriceStepInWei
    );

    event PricePerBuildingInWeiChanged(
        uint256 _oldPricePerBuildingInWei,
        uint256 _newPricePerBuildingInWei
    );

    event FloorPricePerBuildingInWeiChanged(
        uint256 _oldFloorPricePerBuildingInWei,
        uint256 _newFloorPricePerBuildingInWei
    );

    event CeilingPricePerBuildingInWeiChanged(
        uint256 _oldCeilingPricePerBuildingInWei,
        uint256 _newCeilingPricePerBuildingInWei
    );

    event BlockStepChanged(
        uint256 _oldBlockStep,
        uint256 _newBlockStep
    );

    event LastSaleBlockChanged(
        uint256 _oldLastSaleBlock,
        uint256 _newLastSaleBlock
    );

    struct Colour {
        uint256 exteriorColorway;
        uint256 backgroundColorway;
    }

    struct Building {
        uint256 city;
        uint256 building;
        uint256 base;
        uint256 body;
        uint256 roof;
        uint256 special;
    }

    LogicGenerator public logicGenerator;

    ColourGenerator public colourGenerator;

    IBlockCitiesCreator public blockCities;

    mapping(address => uint256) public credits;

    uint256 public totalPurchasesInWei = 0;
    uint256[2] public priceDiscountBands = [80, 70];

    uint256 public floorPricePerBuildingInWei = 0.05 ether;

    uint256 public ceilingPricePerBuildingInWei = 0.15 ether;

    // use totalPrice() to calculate current weighted price
    uint256 pricePerBuildingInWei = 0.075 ether;

    uint256 public priceStepInWei = 0.0003 ether;

    // 120 is approx 30 mins
    uint256 public blockStep = 120;

    uint256 public lastSaleBlock = 0;
    uint256 public lastSalePrice = 0;

    constructor (
        LogicGenerator _logicGenerator,
        ColourGenerator _colourGenerator,
        IBlockCitiesCreator _blockCities,
        address payable _blockCitiesAddress,
        address payable _partnerAddress
    ) public FundsSplitter(_blockCitiesAddress, _partnerAddress) {
        logicGenerator = _logicGenerator;
        colourGenerator = _colourGenerator;
        blockCities = _blockCities;
    }

    function mintBuilding() public payable returns (uint256 _tokenId) {
        uint256 currentPrice = totalPrice(1);
        require(
            credits[msg.sender] > 0 || msg.value >= currentPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );

        _adjustCredits(currentPrice, 1);

        uint256 tokenId = _generate(msg.sender);

        _stepIncrease();

        return tokenId;
    }

    function mintBuildingTo(address _to) public payable returns (uint256 _tokenId) {
        uint256 currentPrice = totalPrice(1);
        require(
            credits[msg.sender] > 0 || msg.value >= currentPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );

        _adjustCredits(currentPrice, 1);

        uint256 tokenId = _generate(_to);

        _stepIncrease();

        return tokenId;
    }

    function mintBatch(uint256 _numberOfBuildings) public payable returns (uint256[] memory _tokenIds) {
        uint256 currentPrice = totalPrice(_numberOfBuildings);
        require(
            credits[msg.sender] >= _numberOfBuildings || msg.value >= currentPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );

        _adjustCredits(currentPrice, _numberOfBuildings);

        uint256[] memory generatedTokenIds = new uint256[](_numberOfBuildings);

        for (uint i = 0; i < _numberOfBuildings; i++) {
            generatedTokenIds[i] = _generate(msg.sender);
        }

        _stepIncrease();

        return generatedTokenIds;
    }

    function mintBatchTo(address _to, uint256 _numberOfBuildings) public payable returns (uint256[] memory _tokenIds) {
        uint256 currentPrice = totalPrice(_numberOfBuildings);
        require(
            credits[msg.sender] >= _numberOfBuildings || msg.value >= currentPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );

        _adjustCredits(currentPrice, _numberOfBuildings);

        uint256[] memory generatedTokenIds = new uint256[](_numberOfBuildings);

        for (uint i = 0; i < _numberOfBuildings; i++) {
            generatedTokenIds[i] = _generate(_to);
        }

        _stepIncrease();

        return generatedTokenIds;
    }

    function _generate(address _to) internal returns (uint256 _tokenId) {
        Building memory building = _generateBuilding();
        Colour memory colour = _generateColours();

        uint256 tokenId = blockCities.createBuilding(
            colour.exteriorColorway,
            colour.backgroundColorway,
            building.city,
            building.building,
            building.base,
            building.body,
            building.roof,
            building.special,
            _to
        );

        emit VendingMachineTriggered(tokenId, _to);

        return tokenId;
    }

    function _generateColours() internal returns (Colour memory){
        (uint256 _exteriorColorway, uint256 _backgroundColorway) = colourGenerator.generate(msg.sender);

        return Colour({
            exteriorColorway : _exteriorColorway,
            backgroundColorway : _backgroundColorway
            });
    }

    function _generateBuilding() internal returns (Building memory){
        (uint256 _city, uint256 _building, uint256 _base, uint256 _body, uint256 _roof, uint256 _special) = logicGenerator.generate(msg.sender);

        return Building({
            city : _city,
            building : _building,
            base : _base,
            body : _body,
            roof : _roof,
            special : _special
            });
    }

    function _adjustCredits(uint256 _currentPrice, uint256 _numberOfBuildings) internal {
        // use credits first
        if (credits[msg.sender] >= _numberOfBuildings) {
            credits[msg.sender] = credits[msg.sender].sub(_numberOfBuildings);

            // refund msg.value when using up credits
            if (msg.value > 0) {
                msg.sender.transfer(msg.value);
            }
        } else {
            splitFunds(_currentPrice);
            totalPurchasesInWei = totalPurchasesInWei.add(_currentPrice);
        }
    }

    function _stepIncrease() internal {
        lastSalePrice = pricePerBuildingInWei;
        lastSaleBlock = block.number;

        pricePerBuildingInWei = pricePerBuildingInWei.add(priceStepInWei);

        if (pricePerBuildingInWei >= ceilingPricePerBuildingInWei) {
            pricePerBuildingInWei = ceilingPricePerBuildingInWei;
        }
    }

    function totalPrice(uint256 _numberOfBuildings) public view returns (uint256) {

        uint256 calculatedPrice = pricePerBuildingInWei;

        uint256 blocksPassed = block.number - lastSaleBlock;
        uint256 reduce = blocksPassed.div(blockStep).mul(priceStepInWei);

        if (reduce > calculatedPrice) {
            calculatedPrice = floorPricePerBuildingInWei;
        }
        else {
            calculatedPrice = calculatedPrice.sub(reduce);
        }

        if (calculatedPrice < floorPricePerBuildingInWei) {
            calculatedPrice = floorPricePerBuildingInWei;
        }

        if (_numberOfBuildings < 5) {
            return _numberOfBuildings.mul(calculatedPrice);
        }
        else if (_numberOfBuildings < 10) {
            return _numberOfBuildings.mul(calculatedPrice).div(100).mul(priceDiscountBands[0]);
        }

        return _numberOfBuildings.mul(calculatedPrice).div(100).mul(priceDiscountBands[1]);
    }

    function setPricePerBuildingInWei(uint256 _pricePerBuildingInWei) public onlyOwner returns (bool) {
        emit PricePerBuildingInWeiChanged(pricePerBuildingInWei, _pricePerBuildingInWei);
        pricePerBuildingInWei = _pricePerBuildingInWei;
        return true;
    }

    function setPriceStepInWei(uint256 _priceStepInWei) public onlyOwner returns (bool) {
        emit PriceStepInWeiChanged(priceStepInWei, _priceStepInWei);
        priceStepInWei = _priceStepInWei;
        return true;
    }

    function setPriceDiscountBands(uint256[2] memory _newPriceDiscountBands) public onlyOwner returns (bool) {
        priceDiscountBands = _newPriceDiscountBands;

        emit PriceDiscountBandsChanged(_newPriceDiscountBands);

        return true;
    }

    function addCredit(address _to) public onlyOwner returns (bool) {
        credits[_to] = credits[_to].add(1);

        emit CreditAdded(_to, 1);

        return true;
    }

    function addCreditAmount(address _to, uint256 _amount) public onlyOwner returns (bool) {
        credits[_to] = credits[_to].add(_amount);

        emit CreditAdded(_to, _amount);

        return true;
    }

    function addCreditBatch(address[] memory _addresses, uint256 _amount) public onlyOwner returns (bool) {
        for (uint i = 0; i < _addresses.length; i++) {
            addCreditAmount(_addresses[i], _amount);
        }

        return true;
    }

    function setFloorPricePerBuildingInWei(uint256 _floorPricePerBuildingInWei) public onlyOwner returns (bool) {
        emit FloorPricePerBuildingInWeiChanged(floorPricePerBuildingInWei, _floorPricePerBuildingInWei);
        floorPricePerBuildingInWei = _floorPricePerBuildingInWei;
        return true;
    }

    function setCeilingPricePerBuildingInWei(uint256 _ceilingPricePerBuildingInWei) public onlyOwner returns (bool) {
        emit CeilingPricePerBuildingInWeiChanged(ceilingPricePerBuildingInWei, _ceilingPricePerBuildingInWei);
        ceilingPricePerBuildingInWei = _ceilingPricePerBuildingInWei;
        return true;
    }

    function setBlockStep(uint256 _blockStep) public onlyOwner returns (bool) {
        emit BlockStepChanged(blockStep, _blockStep);
        blockStep = _blockStep;
        return true;
    }

    function setLastSaleBlock(uint256 _lastSaleBlock) public onlyOwner returns (bool) {
        emit LastSaleBlockChanged(lastSaleBlock, _lastSaleBlock);
        lastSaleBlock = _lastSaleBlock;
        return true;
    }

    function setLogicGenerator(LogicGenerator _logicGenerator) public onlyOwner returns (bool) {
        logicGenerator = _logicGenerator;
        return true;
    }

    function setColourGenerator(ColourGenerator _colourGenerator) public onlyOwner returns (bool) {
        colourGenerator = _colourGenerator;
        return true;
    }
}