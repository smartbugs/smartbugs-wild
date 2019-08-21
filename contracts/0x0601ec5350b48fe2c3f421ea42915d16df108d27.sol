pragma solidity 0.4.25;

library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint256 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not a contract owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _validateAddress(newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "contract is not paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract Controllable is Ownable {
    mapping(address => bool) controllers;

    modifier onlyController {
        require(_isController(msg.sender), "no controller rights");
        _;
    }

    function _isController(address _controller) internal view returns (bool) {
        return controllers[_controller];
    }

    function _setControllers(address[] _controllers) internal {
        for (uint256 i = 0; i < _controllers.length; i++) {
            _validateAddress(_controllers[i]);
            controllers[_controllers[i]] = true;
        }
    }
}

contract Upgradable is Controllable {
    address[] internalDependencies;
    address[] externalDependencies;

    function getInternalDependencies() public view returns(address[]) {
        return internalDependencies;
    }

    function getExternalDependencies() public view returns(address[]) {
        return externalDependencies;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        for (uint256 i = 0; i < _newDependencies.length; i++) {
            _validateAddress(_newDependencies[i]);
        }
        internalDependencies = _newDependencies;
    }

    function setExternalDependencies(address[] _newDependencies) public onlyOwner {
        externalDependencies = _newDependencies;
        _setControllers(_newDependencies);
    }
}

contract HumanOriented {
    modifier onlyHuman() {
        require(msg.sender == tx.origin, "not a human");
        _;
    }
}

contract Events {
    function emitEggCreated(address, uint256) external;
    function emitDragonOnSale(address, uint256) external;
    function emitDragonRemovedFromSale(address, uint256) external;
    function emitDragonRemovedFromBreeding(address, uint256) external;
    function emitDragonOnBreeding(address, uint256) external;
    function emitDragonBought(address, address, uint256, uint256) external;
    function emitDragonBreedingBought(address, address, uint256, uint256) external;
    function emitDistributionUpdated(uint256, uint256, uint256) external;
    function emitEggOnSale(address, uint256) external;
    function emitEggRemovedFromSale(address, uint256) external;
    function emitEggBought(address, address, uint256, uint256) external;
    function emitGoldSellOrderCreated(address, uint256, uint256) external;
    function emitGoldSellOrderCancelled(address) external;
    function emitGoldSold(address, address, uint256, uint256) external;
    function emitGoldBuyOrderCreated(address, uint256, uint256) external;
    function emitGoldBuyOrderCancelled(address) external;
    function emitGoldBought(address, address, uint256, uint256) external;
    function emitSkillOnSale(address, uint256) external;
    function emitSkillRemovedFromSale(address, uint256) external;
    function emitSkillBought(address, address, uint256, uint256, uint256) external;
}


contract MarketplaceController {
    function buyEgg(address, uint256, uint256, uint256, bool) external returns (address, uint256, bool);
    function sellEgg(address, uint256, uint256, uint256, uint16, bool) external;
    function removeEggFromSale(address, uint256) external;
    function buyDragon(address, uint256, uint256, uint256, bool) external returns (address, uint256, bool);
    function sellDragon(address, uint256, uint256, uint256, uint16, bool) external;
    function removeDragonFromSale(address, uint256) external;
    function buyBreeding(address, uint256, uint256, uint256, uint256, bool) external returns (uint256, address, uint256, bool);
    function sellBreeding(address, uint256, uint256, uint256, uint16, bool) external;
    function removeBreedingFromSale(address, uint256) external;
    function buySkill(address, uint256, uint256, uint256, uint32) external returns (address, uint256, bool);
    function sellSkill(address, uint256, uint256) external;
    function removeSkillFromSale(address, uint256) external;
}

contract GoldMarketplace {
    function createSellOrder(address, uint256, uint256) external;
    function cancelSellOrder(address) external;
    function fillSellOrder(address, uint256, address, uint256, uint256) external returns (uint256);
    function createBuyOrder(address, uint256, uint256, uint256) external;
    function cancelBuyOrder(address) external;
    function fillBuyOrder(address, address, uint256, uint256) external returns (uint256);
}




//////////////CONTRACT//////////////




contract MainMarket is Pausable, Upgradable, HumanOriented {
    using SafeMath256 for uint256;

    MarketplaceController public marketplaceController;
    GoldMarketplace goldMarketplace;
    Events events;

    // MARKETPLACE

    function _transferEth(
        address _from,
        address _to,
        uint256 _available,
        uint256 _required_,
        bool _isGold
    ) internal {
        uint256 _required = _required_;
        if (_isGold) {
            _required = 0;
        }

        _to.transfer(_required);
        if (_available > _required) {
            _from.transfer(_available.sub(_required));
        }
    }

    // EGG

    function buyEgg(
        uint256 _id,
        uint256 _expectedPrice,
        bool _isGold
    ) external onlyHuman whenNotPaused payable {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceController.buyEgg(
            msg.sender,
            msg.value,
            _id,
            _expectedPrice,
            _isGold
        );
        if (_success) {
            _transferEth(msg.sender, _seller, msg.value, _price, _isGold);
            events.emitEggBought(msg.sender, _seller, _id, _price);
        } else {
            msg.sender.transfer(msg.value);
            events.emitEggRemovedFromSale(_seller, _id);
        }
    }

    function sellEgg(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isGold
    ) external onlyHuman whenNotPaused {
        marketplaceController.sellEgg(msg.sender, _id, _maxPrice, _minPrice, _period, _isGold);
        events.emitEggOnSale(msg.sender, _id);
    }

    function removeEggFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceController.removeEggFromSale(msg.sender, _id);
        events.emitEggRemovedFromSale(msg.sender, _id);
    }

    // DRAGON

    function buyDragon(
        uint256 _id,
        uint256 _expectedPrice,
        bool _isGold
    ) external onlyHuman whenNotPaused payable {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceController.buyDragon(
            msg.sender,
            msg.value,
            _id,
            _expectedPrice,
            _isGold
        );
        if (_success) {
            _transferEth(msg.sender, _seller, msg.value, _price, _isGold);
            events.emitDragonBought(msg.sender, _seller, _id, _price);
        } else {
            msg.sender.transfer(msg.value);
            events.emitDragonRemovedFromSale(_seller, _id);
        }
    }

    function sellDragon(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isGold
    ) external onlyHuman whenNotPaused {
        marketplaceController.sellDragon(msg.sender, _id, _maxPrice, _minPrice, _period, _isGold);
        events.emitDragonOnSale(msg.sender, _id);
    }

    function removeDragonFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceController.removeDragonFromSale(msg.sender, _id);
        events.emitDragonRemovedFromSale(msg.sender, _id);
    }

    // BREEDING

    function buyBreeding(
        uint256 _momId,
        uint256 _dadId,
        uint256 _expectedPrice,
        bool _isGold
    ) external onlyHuman whenNotPaused payable {
        (
            uint256 _eggId,
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceController.buyBreeding(
            msg.sender,
            msg.value,
            _momId,
            _dadId,
            _expectedPrice,
            _isGold
        );
        if (_success) {
            events.emitEggCreated(msg.sender, _eggId);
            _transferEth(msg.sender, _seller, msg.value, _price, _isGold);
            events.emitDragonBreedingBought(msg.sender, _seller, _dadId, _price);
        } else {
            msg.sender.transfer(msg.value);
            events.emitDragonRemovedFromBreeding(_seller, _dadId);
        }
    }

    function sellBreeding(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isGold
    ) external onlyHuman whenNotPaused {
        marketplaceController.sellBreeding(msg.sender, _id, _maxPrice, _minPrice, _period, _isGold);
        events.emitDragonOnBreeding(msg.sender, _id);
    }

    function removeBreedingFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceController.removeBreedingFromSale(msg.sender, _id);
        events.emitDragonRemovedFromBreeding(msg.sender, _id);
    }

    // GOLD

    // SELL

    function fillGoldSellOrder(
        address _seller,
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused payable {
        address(goldMarketplace).transfer(msg.value);
        uint256 _priceForOne = goldMarketplace.fillSellOrder(msg.sender, msg.value, _seller, _price, _amount);
        events.emitGoldSold(msg.sender, _seller, _amount, _priceForOne);
    }

    function createGoldSellOrder(
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused {
        goldMarketplace.createSellOrder(msg.sender, _price, _amount);
        events.emitGoldSellOrderCreated(msg.sender, _price, _amount);
    }

    function cancelGoldSellOrder() external onlyHuman whenNotPaused {
        goldMarketplace.cancelSellOrder(msg.sender);
        events.emitGoldSellOrderCancelled(msg.sender);
    }

    // BUY

    function fillGoldBuyOrder(
        address _buyer,
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused {
        uint256 _priceForOne = goldMarketplace.fillBuyOrder(msg.sender, _buyer, _price, _amount);
        events.emitGoldBought(msg.sender, _buyer, _amount, _priceForOne);
    }

    function createGoldBuyOrder(
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused payable {
        address(goldMarketplace).transfer(msg.value);
        goldMarketplace.createBuyOrder(msg.sender, msg.value, _price, _amount);
        events.emitGoldBuyOrderCreated(msg.sender, _price, _amount);
    }

    function cancelGoldBuyOrder() external onlyHuman whenNotPaused {
        goldMarketplace.cancelBuyOrder(msg.sender);
        events.emitGoldBuyOrderCancelled(msg.sender);
    }

    // SKILL

    function buySkill(
        uint256 _id,
        uint256 _target,
        uint256 _expectedPrice,
        uint32 _expectedEffect
    ) external onlyHuman whenNotPaused {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceController.buySkill(
            msg.sender,
            _id,
            _target,
            _expectedPrice,
            _expectedEffect
        );

        if (_success) {
            events.emitSkillBought(msg.sender, _seller, _id, _target, _price);
        } else {
            events.emitSkillRemovedFromSale(_seller, _id);
        }
    }

    function sellSkill(
        uint256 _id,
        uint256 _price
    ) external onlyHuman whenNotPaused {
        marketplaceController.sellSkill(msg.sender, _id, _price);
        events.emitSkillOnSale(msg.sender, _id);
    }

    function removeSkillFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceController.removeSkillFromSale(msg.sender, _id);
        events.emitSkillRemovedFromSale(msg.sender, _id);
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        marketplaceController = MarketplaceController(_newDependencies[0]);
        goldMarketplace = GoldMarketplace(_newDependencies[1]);
        events = Events(_newDependencies[2]);
    }
}