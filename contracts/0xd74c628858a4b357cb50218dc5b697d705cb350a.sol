pragma solidity >= 0.5.0;

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

contract Constants {
    uint public constant UNLOCK_COUNT = 7;
}

contract CardioCoin is ERC20, Ownable, Constants {
    using SafeMath for uint256;

    uint public constant RESELLER_UNLOCK_TIME = 1559347200; 
    uint public constant UNLOCK_PERIOD = 30 days;

    string public name = "CardioCoin";
    string public symbol = "CRDC";

    uint8 public decimals = 18;
    uint256 internal totalSupply_ = 50000000000 * (10 ** uint256(decimals));

    mapping (address => uint256) internal reselling;
    uint256 internal resellingAmount = 0;

    struct locker {
        bool isLocker;
        string role;
        uint lockUpPeriod;
        uint unlockCount;
        bool isReseller;
    }

    mapping (address => locker) internal lockerList;

    event AddToLocker(address indexed owner, string role, uint lockUpPeriod, uint unlockCount);
    event AddToReseller(address indexed owner);

    event ResellingAdded(address indexed seller, uint256 amount);
    event ResellingSubtracted(address indexed seller, uint256 amount);
    event Reselled(address indexed seller, address indexed buyer, uint256 amount);

    event TokenLocked(address indexed owner, uint256 amount);
    event TokenUnlocked(address indexed owner, uint256 amount);

    constructor() public Ownable() {
        balance memory b;

        b.available = totalSupply_;
        balances[msg.sender] = b;
    }

    function addLockedUpTokens(address _owner, uint256 amount, uint lockUpPeriod, uint unlockCount)
    internal {
        balance storage b = balances[_owner];
        lockUp memory l;

        l.amount = amount;
        l.unlockTimestamp = now + lockUpPeriod;
        l.unlockCount = unlockCount;
        b.lockedUp += amount;
        b.lockUpData[b.lockUpCount] = l;
        b.lockUpCount += 1;
        emit TokenLocked(_owner, amount);
    }

    // Reselling

    function addAddressToResellerList(address _operator)
    public
    onlyOwner {
        locker storage existsLocker = lockerList[_operator];

        require(!existsLocker.isLocker);

        locker memory l;

        l.isLocker = true;
        l.role = "Reseller";
        l.lockUpPeriod = RESELLER_UNLOCK_TIME;
        l.unlockCount = UNLOCK_COUNT;
        l.isReseller = true;
        lockerList[_operator] = l;
        emit AddToReseller(_operator);
    }

    function addResellingAmount(address seller, uint256 amount)
    public
    onlyOwner
    {
        require(seller != address(0));
        require(amount > 0);
        require(balances[seller].available >= amount);

        reselling[seller] = reselling[seller].add(amount);
        balances[seller].available = balances[seller].available.sub(amount);
        resellingAmount = resellingAmount.add(amount);
        emit ResellingAdded(seller, amount);
    }

    function subtractResellingAmount(address seller, uint256 _amount)
    public
    onlyOwner
    {
        uint256 amount = reselling[seller];

        require(seller != address(0));
        require(_amount > 0);
        require(amount >= _amount);

        reselling[seller] = reselling[seller].sub(_amount);
        resellingAmount = resellingAmount.sub(_amount);
        balances[seller].available = balances[seller].available.add(_amount);
        emit ResellingSubtracted(seller, _amount);
    }

    function cancelReselling(address seller)
    public
    onlyOwner {
        uint256 amount = reselling[seller];

        require(seller != address(0));
        require(amount > 0);

        subtractResellingAmount(seller, amount);
    }

    function resell(address seller, address buyer, uint256 amount)
    public
    onlyOwner
    returns (bool)
    {
        require(seller != address(0));
        require(buyer != address(0));
        require(amount > 0);
        require(reselling[seller] >= amount);
        require(balances[owner()].available >= amount);

        reselling[seller] = reselling[seller].sub(amount);
        resellingAmount = resellingAmount.sub(amount);
        addLockedUpTokens(buyer, amount, RESELLER_UNLOCK_TIME - now, UNLOCK_COUNT);
        emit Reselled(seller, buyer, amount);

        return true;
    }

    // ERC20 Custom

    struct lockUp {
        uint256 amount;
        uint unlockTimestamp;
        uint unlockedCount;
        uint unlockCount;
    }

    struct balance {
        uint256 available;
        uint256 lockedUp;
        mapping (uint => lockUp) lockUpData;
        uint lockUpCount;
        uint unlockIndex;
    }

    mapping(address => balance) internal balances;

    function unlockBalance(address _owner) internal {
        balance storage b = balances[_owner];

        if (b.lockUpCount > 0 && b.unlockIndex < b.lockUpCount) {
            for (uint i = b.unlockIndex; i < b.lockUpCount; i++) {
                lockUp storage l = b.lockUpData[i];

                if (l.unlockTimestamp <= now) {
                    uint count = calculateUnlockCount(l.unlockTimestamp, l.unlockedCount, l.unlockCount);
                    uint256 unlockedAmount = l.amount.mul(count).div(l.unlockCount);

                    if (unlockedAmount > b.lockedUp) {
                        unlockedAmount = b.lockedUp;
                        l.unlockedCount = l.unlockCount;
                    } else {
                        b.available = b.available.add(unlockedAmount);
                        b.lockedUp = b.lockedUp.sub(unlockedAmount);
                        l.unlockedCount += count;
                    }
                    emit TokenUnlocked(_owner, unlockedAmount);
                    if (l.unlockedCount == l.unlockCount) {
                        lockUp memory tempA = b.lockUpData[i];
                        lockUp memory tempB = b.lockUpData[b.unlockIndex];

                        b.lockUpData[i] = tempB;
                        b.lockUpData[b.unlockIndex] = tempA;
                        b.unlockIndex += 1;
                    } else {
                        l.unlockTimestamp += UNLOCK_PERIOD * count;
                    }
                }
            }
        }
    }

    function calculateUnlockCount(uint timestamp, uint unlockedCount, uint unlockCount) view internal returns (uint) {
        uint count = 0;
        uint nowFixed = now;

        while (timestamp < nowFixed && unlockedCount + count < unlockCount) {
            count++;
            timestamp += UNLOCK_PERIOD;
        }

        return count;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function _transfer(address from, address to, uint256 value) internal {
        locker storage l = lockerList[from];

        if (l.isReseller && RESELLER_UNLOCK_TIME < now) {
            l.isLocker = false;
            l.isReseller = false;

            uint elapsedPeriod = (now - RESELLER_UNLOCK_TIME) / UNLOCK_PERIOD;

            if (elapsedPeriod < UNLOCK_COUNT) {
                balance storage b = balances[from];
                uint256 lockUpAmount = b.available * (UNLOCK_COUNT - elapsedPeriod) / UNLOCK_COUNT;

                b.available = b.available.sub(lockUpAmount);
                addLockedUpTokens(from, lockUpAmount, RESELLER_UNLOCK_TIME + UNLOCK_PERIOD * (elapsedPeriod + 1) - now, UNLOCK_COUNT - elapsedPeriod);
            }
        }
        unlockBalance(from);

        require(value <= balances[from].available);
        require(to != address(0));
        if (l.isLocker) {
            balances[from].available = balances[from].available.sub(value);
            if (l.isReseller) {
                addLockedUpTokens(to, value, RESELLER_UNLOCK_TIME - now, UNLOCK_COUNT);
            } else {
                addLockedUpTokens(to, value, l.lockUpPeriod, l.unlockCount);
            }
        } else {
            balances[from].available = balances[from].available.sub(value);
            balances[to].available = balances[to].available.add(value);
        }
        emit Transfer(from, to, value);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner].available.add(balances[_owner].lockedUp);
    }

    function lockedUpBalanceOf(address _owner) public view returns (uint256) {
        balance storage b = balances[_owner];
        uint256 lockedUpBalance = b.lockedUp;

        if (b.lockUpCount > 0 && b.unlockIndex < b.lockUpCount) {
            for (uint i = b.unlockIndex; i < b.lockUpCount; i++) {
                lockUp storage l = b.lockUpData[i];

                if (l.unlockTimestamp <= now) {
                    uint count = calculateUnlockCount(l.unlockTimestamp, l.unlockedCount, l.unlockCount);
                    uint256 unlockedAmount = l.amount.mul(count).div(l.unlockCount);

                    if (unlockedAmount > lockedUpBalance) {
                        lockedUpBalance = 0;
                        break;
                    } else {
                        lockedUpBalance = lockedUpBalance.sub(unlockedAmount);
                    }
                }
            }
        }

        return lockedUpBalance;
    }

    function resellingBalanceOf(address _owner) public view returns (uint256) {
        return reselling[_owner];
    }

    function transferWithLockUp(address _to, uint256 _value, uint lockUpPeriod, uint unlockCount)
    public
    onlyOwner
    returns (bool) {
        require(_value <= balances[owner()].available);
        require(_to != address(0));

        balances[owner()].available = balances[owner()].available.sub(_value);
        addLockedUpTokens(_to, _value, lockUpPeriod, unlockCount);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // Burnable

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who].available);

        balances[_who].available = balances[_who].available.sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    // Lockup

    function addAddressToLockerList(address _operator, string memory role, uint lockUpPeriod, uint unlockCount)
    public
    onlyOwner {
        locker storage existsLocker = lockerList[_operator];

        require(!existsLocker.isLocker);

        locker memory l;

        l.isLocker = true;
        l.role = role;
        l.lockUpPeriod = lockUpPeriod;
        l.unlockCount = unlockCount;
        l.isReseller = false;
        lockerList[_operator] = l;
        emit AddToLocker(_operator, role, lockUpPeriod, unlockCount);
    }

    function lockerInfo(address _operator) public view returns (string memory, uint, uint, bool) {
        locker memory l = lockerList[_operator];

        return (l.role, l.lockUpPeriod, l.unlockCount, l.isReseller);
    }

    // Refund

    event RefundRequested(address indexed reuqester, uint256 tokenAmount, uint256 paidAmount);
    event RefundCanceled(address indexed requester);
    event RefundAccepted(address indexed requester, address indexed tokenReceiver, uint256 tokenAmount, uint256 paidAmount);

    struct refundRequest {
        bool active;
        uint256 tokenAmount;
        uint256 paidAmount;
        address buyFrom;
    }

    mapping (address => refundRequest) internal refundRequests;

    function requestRefund(uint256 paidAmount, address buyFrom) public {
        require(!refundRequests[msg.sender].active);

        refundRequest memory r;

        r.active = true;
        r.tokenAmount = balanceOf(msg.sender);
        r.paidAmount = paidAmount;
        r.buyFrom = buyFrom;
        refundRequests[msg.sender] = r;

        emit RefundRequested(msg.sender, r.tokenAmount, r.paidAmount);
    }

    function cancelRefund() public {
        require(refundRequests[msg.sender].active);
        refundRequests[msg.sender].active = false;
        emit RefundCanceled(msg.sender);
    }

    function acceptRefundForOwner(address payable requester, address receiver) public payable onlyOwner {
        require(requester != address(0));
        require(receiver != address(0));

        refundRequest storage r = refundRequests[requester];

        require(r.active);
        require(balanceOf(requester) == r.tokenAmount);
        require(msg.value == r.paidAmount);
        require(r.buyFrom == owner());
        requester.transfer(msg.value);
        transferForRefund(requester, receiver, r.tokenAmount);
        r.active = false;
        emit RefundAccepted(requester, receiver, r.tokenAmount, msg.value);
    }

    function acceptRefundForReseller(address payable requester) public payable {
        require(requester != address(0));

        locker memory l = lockerList[msg.sender];

        require(l.isReseller);

        refundRequest storage r = refundRequests[requester];

        require(r.active);
        require(balanceOf(requester) == r.tokenAmount);
        require(msg.value == r.paidAmount);
        require(r.buyFrom == msg.sender);
        requester.transfer(msg.value);
        transferForRefund(requester, msg.sender, r.tokenAmount);
        r.active = false;
        emit RefundAccepted(requester, msg.sender, r.tokenAmount, msg.value);
    }

    function refundInfo(address requester) public view returns (bool, uint256, uint256) {
        refundRequest memory r = refundRequests[requester];

        return (r.active, r.tokenAmount, r.paidAmount);
    }

    function transferForRefund(address from, address to, uint256 amount) internal {
        require(balanceOf(from) == amount);

        unlockBalance(from);

        balance storage fromBalance = balances[from];
        balance storage toBalance = balances[to];

        fromBalance.available = 0;
        fromBalance.lockedUp = 0;
        fromBalance.unlockIndex = fromBalance.lockUpCount;
        toBalance.available = toBalance.available.add(amount);

        emit Transfer(from, to, amount);
    }
}