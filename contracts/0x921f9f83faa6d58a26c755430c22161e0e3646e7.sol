pragma solidity ^0.4.24;

// File: contracts/deps/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
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
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

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

// File: contracts/deps/IERC20.sol

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);
    
    function _mint(address account, uint256 amount) external;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/deps/SafeERC20.sol

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
    internal
    {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
    internal
    {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal
    {
        require(token.approve(spender, value));
    }
}

// File: contracts/deps/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

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
        _owner = msg.sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns(address) {
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
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
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

// File: contracts/IPCToken.sol

contract IPCToken is IERC20, Ownable {

    string public name = "Iranian Phoenix Coin";
    uint8 public decimals = 18;


    string public symbol = "IPC";

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;


    constructor() public {}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }


    function allowance(
        address owner,
        address spender
    )
    public
    view
    returns (uint256)
    {
        return _allowed[owner][spender];
    }


    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }


    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    public onlyOwner
    returns (bool)
    {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }


    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }



    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }


    function _mint(address account, uint256 amount) external onlyOwner {
        require(account != 0);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != 0);
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);

        emit Transfer(account, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner {
        require(amount <= _allowed[account][msg.sender]);

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            amount);
        _burn(account, amount);
    }
}

// File: contracts/IPCCrowdsale.sol

contract IPCCrowdsale is Ownable {

    using SafeMath for uint;
    using SafeERC20 for IPCToken;


    IPCToken private _token = new IPCToken();

    uint currentPhase = 0;

    uint256  _weiRaised;

    uint8[] phase_bonuses =  [50, 0];

    uint256[] phase_supply_limits = [ 150000 ether, 400000 ether];

    address private _wallet = 0x67E6Efc62635353aE31d16AD844Cc4BDBCaCe53D;

    uint private usd_per_barrel_rate = 55;
    uint private eth_per_usd_rate = 21800 ;


    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );


    constructor() public {
        transferOwnership(_wallet);
        _token._mint(_wallet, 50000 ether);
    
    }


    function startMainSale() public onlyOwner {
        require(currentPhase == 0);
        currentPhase = 1;
    }


    function() external payable {
        buyTokens(msg.sender);
    }


    function token() public view returns (IERC20) {
        return _token;
    }


    function wallet() public view returns (address) {
        return _wallet;
    }


    function rate() public view returns (uint256) {
        return eth_per_usd_rate.div(usd_per_barrel_rate);
    }

    function setBarrelPrice(uint _price){
        usd_per_barrel_rate =_price;
    }


    function setEtherPrice(uint _price){
        eth_per_usd_rate = _price;
    }


    /**
     * @return the mount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }


    function get_max_supply() public view returns (uint256) {
        return phase_supply_limits[currentPhase];
    }


    function buyTokens(address beneficiary) public payable {

        uint256 weiAmount = msg.value;

        uint256 tokens = _getTokenAmount(weiAmount);
        uint256 bonus = tokens.mul(phase_bonuses[currentPhase]).div(100);
        _weiRaised = _weiRaised.add(weiAmount);
        

        _processPurchase(beneficiary, tokens + bonus);

        require(token().totalSupply() < get_max_supply());

        // emit TokensPurchased(
        //     msg.sender,
        //     beneficiary,
        //     weiAmount,
        //     tokens
        // );


        _forwardFunds();
    }




    function _deliverTokens(
        address beneficiary,
        uint256 tokenAmount
    )
    internal
    {
        _token._mint(beneficiary, tokenAmount);
    }


    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
    internal
    {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
    {
        return weiAmount.mul(rate()).div(100);
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}