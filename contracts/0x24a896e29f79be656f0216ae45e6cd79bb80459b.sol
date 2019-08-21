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

// File: contracts/generators/IColourGenerator.sol

pragma solidity ^0.5.0;

interface IColourGenerator {
    function generate(address _sender)
    external
    returns (uint256 exteriorColorway, uint256 backgroundColorway);
}

// File: contracts/generators/ILogicGenerator.sol

pragma solidity ^0.5.0;

interface ILogicGenerator {
    function generate(address _sender)
    external
    returns (uint256 city, uint256 building, uint256 base, uint256 body, uint256 roof, uint256 special);
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.5.0;


/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol

pragma solidity ^0.5.0;



/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

// File: contracts/FundsSplitterV2.sol

pragma solidity ^0.5.0;



contract FundsSplitterV2 is WhitelistedRole {
    using SafeMath for uint256;

    address payable public platform;
    address payable public partner;

    uint256 public partnerRate = 15;

    constructor (address payable _platform, address payable _partner) public {
        platform = _platform;
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
            platform.transfer(remaining);
        }
    }

    function updatePartnerAddress(address payable _partner) onlyWhitelisted public {
        partner = _partner;
    }

    function updatePartnerRate(uint256 _techPartnerRate) onlyWhitelisted public {
        partnerRate = _techPartnerRate;
    }

    function updatePlatformAddress(address payable _platform) onlyWhitelisted public {
        platform = _platform;
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

// File: contracts/BlockCitiesVendingMachineV2.sol

pragma solidity ^0.5.0;







contract BlockCitiesVendingMachineV2 is FundsSplitterV2 {
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

    event LastSalePriceChanged(
        uint256 _oldLastSalePrice,
        uint256 _newLastSalePrice
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

    ILogicGenerator public logicGenerator;

    IColourGenerator public colourGenerator;

    IBlockCitiesCreator public blockCities;

    mapping(address => uint256) public credits;

    uint256 public totalPurchasesInWei = 0;
    uint256[2] public priceDiscountBands = [80, 70];

    uint256 public floorPricePerBuildingInWei = 0.05 ether;

    uint256 public ceilingPricePerBuildingInWei = 0.15 ether;

    uint256 public priceStepInWei = 0.0003 ether;

    uint256 public blockStep = 10;

    uint256 public lastSaleBlock = 0;
    uint256 public lastSalePrice = 0.075 ether;

    constructor (
        ILogicGenerator _logicGenerator,
        IColourGenerator _colourGenerator,
        IBlockCitiesCreator _blockCities,
        address payable _platform,
        address payable _partnerAddress
    ) public FundsSplitterV2(_platform, _partnerAddress) {
        logicGenerator = _logicGenerator;
        colourGenerator = _colourGenerator;
        blockCities = _blockCities;

        lastSaleBlock = block.number;

        super.addWhitelisted(msg.sender);
    }

    function mintBuilding() public payable returns (uint256 _tokenId) {
        uint256 currentPrice = totalPrice(1);
        require(
            credits[msg.sender] > 0 || msg.value >= currentPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );

        _reconcileCreditsAndFunds(currentPrice, 1);

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

        _reconcileCreditsAndFunds(currentPrice, 1);

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

        _reconcileCreditsAndFunds(currentPrice, _numberOfBuildings);

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

        _reconcileCreditsAndFunds(currentPrice, _numberOfBuildings);

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

    function _reconcileCreditsAndFunds(uint256 _currentPrice, uint256 _numberOfBuildings) internal {
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

        lastSalePrice = totalPrice(1).add(priceStepInWei);
        lastSaleBlock = block.number;

        if (lastSalePrice >= ceilingPricePerBuildingInWei) {
            lastSalePrice = ceilingPricePerBuildingInWei;
        }
    }

    function totalPrice(uint256 _numberOfBuildings) public view returns (uint256) {

        uint256 calculatedPrice = lastSalePrice;

        uint256 blocksPassed = block.number - lastSaleBlock;
        uint256 reduce = blocksPassed.div(blockStep).mul(priceStepInWei);

        if (reduce > calculatedPrice) {
            calculatedPrice = floorPricePerBuildingInWei;
        }
        else {
            calculatedPrice = calculatedPrice.sub(reduce);

            if (calculatedPrice < floorPricePerBuildingInWei) {
                calculatedPrice = floorPricePerBuildingInWei;
            }
        }

        if (_numberOfBuildings < 5) {
            return _numberOfBuildings.mul(calculatedPrice);
        }
        else if (_numberOfBuildings < 10) {
            return _numberOfBuildings.mul(calculatedPrice).div(100).mul(priceDiscountBands[0]);
        }

        return _numberOfBuildings.mul(calculatedPrice).div(100).mul(priceDiscountBands[1]);
    }

    function setPriceStepInWei(uint256 _priceStepInWei) public onlyWhitelisted returns (bool) {
        emit PriceStepInWeiChanged(priceStepInWei, _priceStepInWei);
        priceStepInWei = _priceStepInWei;
        return true;
    }

    function setPriceDiscountBands(uint256[2] memory _newPriceDiscountBands) public onlyWhitelisted returns (bool) {
        priceDiscountBands = _newPriceDiscountBands;

        emit PriceDiscountBandsChanged(_newPriceDiscountBands);

        return true;
    }

    function addCredit(address _to) public onlyWhitelisted returns (bool) {
        credits[_to] = credits[_to].add(1);

        emit CreditAdded(_to, 1);

        return true;
    }

    function addCreditAmount(address _to, uint256 _amount) public onlyWhitelisted returns (bool) {
        credits[_to] = credits[_to].add(_amount);

        emit CreditAdded(_to, _amount);

        return true;
    }

    function addCreditBatch(address[] memory _addresses, uint256 _amount) public onlyWhitelisted returns (bool) {
        for (uint i = 0; i < _addresses.length; i++) {
            addCreditAmount(_addresses[i], _amount);
        }

        return true;
    }

    function setFloorPricePerBuildingInWei(uint256 _floorPricePerBuildingInWei) public onlyWhitelisted returns (bool) {
        emit FloorPricePerBuildingInWeiChanged(floorPricePerBuildingInWei, _floorPricePerBuildingInWei);
        floorPricePerBuildingInWei = _floorPricePerBuildingInWei;
        return true;
    }

    function setCeilingPricePerBuildingInWei(uint256 _ceilingPricePerBuildingInWei) public onlyWhitelisted returns (bool) {
        emit CeilingPricePerBuildingInWeiChanged(ceilingPricePerBuildingInWei, _ceilingPricePerBuildingInWei);
        ceilingPricePerBuildingInWei = _ceilingPricePerBuildingInWei;
        return true;
    }

    function setBlockStep(uint256 _blockStep) public onlyWhitelisted returns (bool) {
        emit BlockStepChanged(blockStep, _blockStep);
        blockStep = _blockStep;
        return true;
    }

    function setLastSaleBlock(uint256 _lastSaleBlock) public onlyWhitelisted returns (bool) {
        emit LastSaleBlockChanged(lastSaleBlock, _lastSaleBlock);
        lastSaleBlock = _lastSaleBlock;
        return true;
    }

    function setLastSalePrice(uint256 _lastSalePrice) public onlyWhitelisted returns (bool) {
        emit LastSalePriceChanged(lastSalePrice, _lastSalePrice);
        lastSalePrice = _lastSalePrice;
        return true;
    }

    function setLogicGenerator(ILogicGenerator _logicGenerator) public onlyWhitelisted returns (bool) {
        logicGenerator = _logicGenerator;
        return true;
    }

    function setColourGenerator(IColourGenerator _colourGenerator) public onlyWhitelisted returns (bool) {
        colourGenerator = _colourGenerator;
        return true;
    }
}