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

contract ERC20 {
    function transfer(address, uint256) public returns (bool);
}

contract Gold is ERC20 {}


contract GoldMarketplaceStorage is Upgradable {
    using SafeMath256 for uint256;

    Gold goldTokens;

    struct Order {
        address user;
        uint256 price;
        uint256 amount;
    }

    mapping (address => uint256) public userToSellOrderIndex;
    mapping (address => uint256) public userToBuyOrderIndex;

    Order[] public sellOrders;
    Order[] public buyOrders;

    constructor() public {
        sellOrders.length = 1;
        buyOrders.length = 1;
    }

    function _ordersShouldExist(uint256 _amount) internal pure {
        require(_amount > 1, "no orders"); // take a look at the constructor
    }

    function _orderShouldNotExist(uint256 _index) internal pure {
        require(_index == 0, "order already exists");
    }

    function _orderShouldExist(uint256 _index) internal pure {
        require(_index != 0, "order does not exist");
    }

    function _sellOrderShouldExist(address _user) internal view {
        _orderShouldExist(userToSellOrderIndex[_user]);
    }

    function _buyOrderShouldExist(address _user) internal view {
        _orderShouldExist(userToBuyOrderIndex[_user]);
    }

    function transferGold(address _to, uint256 _value) external onlyController {
        goldTokens.transfer(_to, _value);
    }

    function transferEth(address _to, uint256 _value) external onlyController {
        _to.transfer(_value);
    }

    // SELL

    function createSellOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        _orderShouldNotExist(userToSellOrderIndex[_user]);

        Order memory _order = Order(_user, _price, _amount);
        userToSellOrderIndex[_user] = sellOrders.length;
        sellOrders.push(_order);
    }

    function cancelSellOrder(
        address _user
    ) external onlyController {
        _sellOrderShouldExist(_user);
        _ordersShouldExist(sellOrders.length);

        uint256 _orderIndex = userToSellOrderIndex[_user];

        uint256 _lastOrderIndex = sellOrders.length.sub(1);
        Order memory _lastOrder = sellOrders[_lastOrderIndex];

        userToSellOrderIndex[_lastOrder.user] = _orderIndex;
        sellOrders[_orderIndex] = _lastOrder;

        sellOrders.length--;
        delete userToSellOrderIndex[_user];
    }

    function updateSellOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        _sellOrderShouldExist(_user);
        uint256 _index = userToSellOrderIndex[_user];
        sellOrders[_index].price = _price;
        sellOrders[_index].amount = _amount;
    }

    // BUY

    function () external payable onlyController {}

    function createBuyOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        _orderShouldNotExist(userToBuyOrderIndex[_user]);

        Order memory _order = Order(_user, _price, _amount);
        userToBuyOrderIndex[_user] = buyOrders.length;
        buyOrders.push(_order);
    }

    function cancelBuyOrder(address _user) external onlyController {
        _buyOrderShouldExist(_user);
        _ordersShouldExist(buyOrders.length);

        uint256 _orderIndex = userToBuyOrderIndex[_user];

        uint256 _lastOrderIndex = buyOrders.length.sub(1);
        Order memory _lastOrder = buyOrders[_lastOrderIndex];

        userToBuyOrderIndex[_lastOrder.user] = _orderIndex;
        buyOrders[_orderIndex] = _lastOrder;

        buyOrders.length--;
        delete userToBuyOrderIndex[_user];
    }

    function updateBuyOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        _buyOrderShouldExist(_user);
        uint256 _index = userToBuyOrderIndex[_user];
        buyOrders[_index].price = _price;
        buyOrders[_index].amount = _amount;
    }

    // GETTERS

    function orderOfSeller(
        address _user
    ) external view returns (
        uint256 index,
        address user,
        uint256 price,
        uint256 amount
    ) {
        _sellOrderShouldExist(_user);
        index = userToSellOrderIndex[_user];
        Order memory order = sellOrders[index];
        return (
            index,
            order.user,
            order.price,
            order.amount
        );
    }

    function orderOfBuyer(
        address _user
    ) external view returns (
        uint256 index,
        address user,
        uint256 price,
        uint256 amount
    ) {
        _buyOrderShouldExist(_user);
        index = userToBuyOrderIndex[_user];
        Order memory order = buyOrders[index];
        return (
            index,
            order.user,
            order.price,
            order.amount
        );
    }

    function sellOrdersAmount() external view returns (uint256) {
        return sellOrders.length;
    }

    function buyOrdersAmount() external view returns (uint256) {
        return buyOrders.length;
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        goldTokens = Gold(_newDependencies[0]);
    }
}