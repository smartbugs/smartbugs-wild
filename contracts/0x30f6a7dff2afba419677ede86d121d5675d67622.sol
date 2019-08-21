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

/**
 * @title ERC20 interface
 */
contract ERC20 {
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}


contract Crowdsale is Ownable {
    using SafeMath for uint256;

    address public multisig;

    ERC20 public token;

    uint rate;
    uint priceETH;

    mapping (address => bool) whitelist;

    event Purchased(address indexed _addr, uint _amount);

    function getRateCentUsd() public view returns(uint) {
        if (block.timestamp >= 1539550800 && block.timestamp < 1541019600) {
            return(70);
        }
        if (block.timestamp >= 1541019600 && block.timestamp < 1545685200) {
            return(100);
        }
    }

    function setPriceETH(uint _newPriceETH) external onlyOwner {
        setRate(_newPriceETH);
    }

    function setRate(uint _priceETH) internal {
        require(_priceETH != 0);
        priceETH = _priceETH;
        rate = getRateCentUsd().mul(1 ether).div(100).div(_priceETH);
    }

    function addToWhitelist(address _newMember) external onlyOwner {
        require(_newMember != address(0));
        whitelist[_newMember] = true;
    }

    function removeFromWhitelist(address _member) external onlyOwner {
        require(_member != address(0));
        whitelist[_member] = false;
    }

    function addListToWhitelist(address[] _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }

    function removeListFromWhitelist(address[] _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = false;
        }
    }

    function getPriceETH() public view returns(uint) {
        return priceETH;
    }

    constructor(address _DNT, address _multisig, uint _priceETH) public {
        require(_DNT != 0 && _priceETH != 0);
        token = ERC20(_DNT);
        multisig = _multisig;
        setRate(_priceETH);
    }

    function() external payable {
        buyTokens();
    }

    function buyTokens() public payable {
        require(whitelist[msg.sender]);
        require(block.timestamp >= 1539550800 && block.timestamp < 1545685200);
        require(msg.value >= 1 ether * 100 / priceETH);

        uint256 amount = msg.value.div(rate);
        uint256 balance = token.balanceOf(this);

        if (amount > balance) {
            uint256 cash = balance.mul(rate);
            uint256 cashBack = msg.value.sub(cash);
            multisig.transfer(cash);
            msg.sender.transfer(cashBack);
            token.transfer(msg.sender, balance);
            emit Purchased(msg.sender, balance);
            return;
        }

        multisig.transfer(msg.value);
        token.transfer(msg.sender, amount);
        emit Purchased(msg.sender, amount);
    }

    function finalizeICO(address _owner) external onlyOwner {
        require(_owner != address(0));
        uint balance = token.balanceOf(this);
        token.transfer(_owner, balance);
    }

    function getMyBalanceDNT() external view returns(uint256) {
        return token.balanceOf(msg.sender);
    }
}