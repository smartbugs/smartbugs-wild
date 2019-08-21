pragma solidity ^0.5.0;

/**
 * @title - SalePO8
 * ███████╗ █████╗ ██╗     ███████╗     ██████╗  ██████╗  █████╗
 * ██╔════╝██╔══██╗██║     ██╔════╝     ██╔══██╗██╔═══██╗██╔══██╗
 * ███████╗███████║██║     █████╗       ██████╔╝██║   ██║╚█████╔╝
 * ╚════██║██╔══██║██║     ██╔══╝       ██╔═══╝ ██║   ██║██╔══██╗
 * ███████║██║  ██║███████╗███████╗     ██║     ╚██████╔╝╚█████╔╝
 * ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝     ╚═╝      ╚═════╝  ╚════╝
 * ---
 *
 * POWERED BY
 *  __    ___   _     ___  _____  ___     _     ___
 * / /`  | |_) \ \_/ | |_)  | |  / / \   | |\ |  ) )
 * \_\_, |_| \  |_|  |_|    |_|  \_\_/   |_| \| _)_)
 *
 * Game at https://skullys.co/
 **/
 
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

contract Ownable {
    address payable public owner;
    address payable public updater;
    address payable public captain;

    event UpdaterTransferred(address indexed previousUpdater, address indexed newUpdater);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
     /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyUpdater() {
        require(msg.sender == updater);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newUpdater The address to transfer ownership to.
     */
    function transferUpdater(address payable newUpdater) public onlyOwner {
        require(newUpdater != address(0));
        emit UpdaterTransferred(updater, newUpdater);
        updater = newUpdater;
    }
    
    /// @dev Assigns a new address to act as the captain.
    /// @param _newCaptain The address of the new Captain
    function setCaptain(address payable _newCaptain) external onlyOwner {
        require(_newCaptain != address(0));

        captain = _newCaptain;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        _paused = true;
        emit Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        _paused = false;
        emit Unpause();
        return true;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public;
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract SalePO8 is Pausable {
    using SafeMath for uint256;
    ERC20 public po8Token;

    uint256 public exchangeRate; // 1 ether == 20000 PO8 for example
    uint256 public cut;
    
    event ExchangeRateUpdated(uint256 newExchangeRate);
    event PO8Bought(address indexed buyer, uint256 ethValue, uint256 po8Receive);
    
    // Delegate constructor
    constructor(uint256 _exchangeRate, uint256 _cut, address po8Address, address payable captainAddress) public {
        exchangeRate = _exchangeRate;
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
        cut = _cut;
        captain = captainAddress;
    }
    
    function setPO8TokenContractAdress(address po8Address) external onlyOwner returns (bool) {
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
        return true;
    }
    
    // @dev The Owner can set the new exchange rate between ETH and PO8 token.
    function setExchangeRate(uint256 _newExchangeRate) external onlyUpdater returns (uint256) {
        exchangeRate = _newExchangeRate;

        emit ExchangeRateUpdated(_newExchangeRate);

        return _newExchangeRate;
    }
    
    function buyPO8() external payable whenNotPaused {
        require(msg.value >= 1e4 wei);
        
        uint256 totalTokenTransfer = msg.value.mul(exchangeRate);
        
        po8Token.transferFrom(owner, msg.sender, totalTokenTransfer);
        captain.transfer(msg.value*cut/1e4); // cut by captain
        
        emit PO8Bought(msg.sender, msg.value, totalTokenTransfer);
    }
    
    // @dev Allows the owner to capture the balance available to the contract.
    function withdrawBalance() external onlyOwner {
        uint256 balance = address(this).balance;

        owner.transfer(balance);
    }
    
    //@dev contract prevent transfer accident ether from user.
    function () external {
        revert();
    }
    
    function getBackERC20Token(address tokenAddress) external onlyOwner {
        ERC20 token = ERC20(tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }
    
}