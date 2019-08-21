pragma solidity ^0.4.24;
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);
        return c;
    }
    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return c;
    }
    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;
        return c;
    }
    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);
        return c;
    }
    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
}
    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender)
    public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value)
    public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);
    function lock(address _victim, uint256 _value, uint256 _periodSec) public;
    function unlock(address _luckier) external;
    function transferOwnership(address _newOwner) public;
}
contract Crowdsale is Ownable {
    using SafeMath for uint256;
    address public multisig;
    address public tokenHolder;
    ERC20 public token;
    uint256 rate;
    uint256 rateInUsd;
    uint256 priceETH;
    uint256 startIco;
    uint256 periodIco;
    uint256 periodPreIco;
    uint256 indCap;
    mapping (address => uint256) tokens;
    address[] addresses;
    uint256 index;
    event Purchased(address _buyer, uint256 _amount);
    constructor(address _AS, address _multisig, address _tokenHolder, uint256 _priceETH, uint256 _startIcoUNIX, uint256 _periodPreIcoSEC, uint256 _periodIcoSEC) public {
        require(_AS != 0 && _priceETH != 0);
        token = ERC20(_AS);
        multisig = _multisig;
        tokenHolder = _tokenHolder;
        startIco = _startIcoUNIX;
        periodPreIco = _periodPreIcoSEC;
        periodIco = _periodIcoSEC;
        rateInUsd = 10;
        setRate(_priceETH);
    }
    function setIndCap(uint256 _indCapETH) public onlyOwner {
        indCap = _indCapETH;
    }
    function setPriceETH(uint256 _newPriceETH) external onlyOwner {
        setRate(_newPriceETH);
    }
    function setRate(uint256 _priceETH) internal {
        require(_priceETH != 0);
        priceETH = _priceETH;
        rate = rateInUsd.mul(1 ether).div(100).div(_priceETH);
    }
    function transferTokenOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        token.transferOwnership(_newOwner);
    }
    function _lock(address _address, uint256 _value, uint256 _period) internal {
        token.lock(_address, _value, _period);
    }
    function lock(address _address, uint256 _value, uint256 _period) external onlyOwner {
        _lock(_address, _value, _period);
    }
    function unlock(address _address) external onlyOwner {
        token.unlock(_address);
    }
    function unlockList() external onlyOwner {
        for (uint256 i = index; i < addresses.length; i++) {
            token.unlock(addresses[i]);
            if (gasleft() < 70000) {
                index = i + 1;
                return;
            }
        }
        index = 0;
    }
    function extendPeriodPreICO(uint256 _days) external onlyOwner {
        periodIco = periodPreIco.add(_days.mul(1 days));
    }
    function extendPeriodICO(uint256 _days) external onlyOwner {
        periodIco = periodIco.add(_days.mul(1 days));
    }
    function() external payable {
        buyTokens();
    }
    function buyTokens() public payable {
        require(block.timestamp > startIco && block.timestamp < startIco.add(periodIco));
        if (indCap > 0) {
            require(msg.value <= indCap.mul(1 ether));
        }
        uint256 totalAmount = msg.value.mul(10**8).div(rate).add(msg.value.mul(10**8).mul(getBonuses()).div(100).div(rate));
        uint256 balance = token.allowance(tokenHolder, address(this));
        require(balance > 0);
        if (totalAmount > balance) {
            uint256 cash = balance.mul(rate).mul(100).div(100 + getBonuses()).div(10**8);
            uint256 cashBack = msg.value.sub(cash);
            totalAmount = balance;
            msg.sender.transfer(cashBack);
        }
        multisig.transfer(msg.value + cash);
        token.transferFrom(tokenHolder, msg.sender, totalAmount);
        if (tokens[msg.sender] == 0) {
            addresses.push(msg.sender);
        }
        tokens[msg.sender] = tokens[msg.sender].add(totalAmount);
        _lock(msg.sender, tokens[msg.sender], startIco.add(periodIco).sub(block.timestamp));
        emit Purchased(msg.sender, totalAmount);
    }
    function getBonuses() internal view returns(uint256) {
        if (block.timestamp < startIco.add(periodPreIco)) {
            return 20;
        } else {
            return 0;
        }
    }
    function getIndCapInETH() public view returns(uint) {
        return indCap;
    }
    function getPriceETH() public view returns(uint) {
        return priceETH;
    }
    function tokenBalanceOf(address _address) external view returns(uint256) {
        return token.balanceOf(_address);
    }
}