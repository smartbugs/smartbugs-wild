interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed holder, address indexed spender, uint256 value);
}

contract ReserveDollar is IERC20 {
    using SafeMath for uint256;


    // DATA


    // Non-constant-sized data
    ReserveDollarEternalStorage internal data;

    // Basic token data
    string public name = "Reserve Dollar";
    string public symbol = "RSVD";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // Paused data
    bool public paused;

    // Auth roles
    address public owner;
    address public minter;
    address public pauser;
    address public freezer;
    address public nominatedOwner;


    // EVENTS


    // Auth role change events
    event OwnerChanged(address indexed newOwner);
    event MinterChanged(address indexed newMinter);
    event PauserChanged(address indexed newPauser);
    event FreezerChanged(address indexed newFreezer);

    // Pause events
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    // Name change event
    event NameChanged(string newName, string newSymbol);

    // Law enforcement events
    event Frozen(address indexed freezer, address indexed account);
    event Unfrozen(address indexed freezer, address indexed account);
    event Wiped(address indexed freezer, address indexed wiped);


    // FUNCTIONALITY


    /// Initialize critical fields.
    constructor() public {
        data = new ReserveDollarEternalStorage(msg.sender);
        owner = msg.sender;
        pauser = msg.sender;
        // Other roles deliberately default to the zero address.
    }

    /// Accessor for eternal storage contract address.
    function getEternalStorageAddress() external view returns(address) {
        return address(data);
    }


    // ==== Admin functions ====


    /// Modifies a function to only run if sent by `role`.
    modifier only(address role) {
        require(msg.sender == role, "unauthorized: not role holder");
        _;
    }

    /// Modifies a function to only run if sent by `role` or the contract's `owner`.
    modifier onlyOwnerOr(address role) {
        require(msg.sender == owner || msg.sender == role, "unauthorized: not role holder and not owner");
        _;
    }

    /// Change who holds the `minter` role.
    function changeMinter(address newMinter) external onlyOwnerOr(minter) {
        minter = newMinter;
        emit MinterChanged(newMinter);
    }

    /// Change who holds the `pauser` role.
    function changePauser(address newPauser) external onlyOwnerOr(pauser) {
        pauser = newPauser;
        emit PauserChanged(newPauser);
    }

    /// Change who holds the `freezer` role.
    function changeFreezer(address newFreezer) external onlyOwnerOr(freezer) {
        freezer = newFreezer;
        emit FreezerChanged(newFreezer);
    }

    /// Nominate a new `owner`.  We want to ensure that `owner` is always valid, so we don't
    /// actually change `owner` to `nominatedOwner` until `nominatedOwner` calls `acceptOwnership`.
    function nominateNewOwner(address nominee) external only(owner) {
        nominatedOwner = nominee;
    }

    /// Accept nomination for ownership.
    /// This completes the `nominateNewOwner` handshake.
    function acceptOwnership() external onlyOwnerOr(nominatedOwner) {
        if (msg.sender != owner) {
            emit OwnerChanged(msg.sender);
        }
        owner = msg.sender;
        nominatedOwner = address(0);
    }

    /// Set `owner` to 0.
    /// Only do this to deliberately lock in the current permissions.
    function renounceOwnership() external only(owner) {
        owner = address(0);
        emit OwnerChanged(owner);
    }

    /// Make a different address own the EternalStorage contract.
    /// This will break this contract, so only do it if you're
    /// abandoning this contract, e.g., for an upgrade.
    function transferEternalStorage(address newOwner) external only(owner) {
        data.transferOwnership(newOwner);
    }

    /// Change the name and ticker symbol of this token.
    function changeName(string calldata newName, string calldata newSymbol) external only(owner) {
        name = newName;
        symbol = newSymbol;
        emit NameChanged(newName, newSymbol);
    }

    /// Pause the contract.
    function pause() external only(pauser) {
        paused = true;
        emit Paused(pauser);
    }

    /// Unpause the contract.
    function unpause() external only(pauser) {
        paused = false;
        emit Unpaused(pauser);
    }

    /// Modifies a function to run only when the contract is not paused.
    modifier notPaused() {
        require(!paused, "contract is paused");
        _;
    }

    /// Freeze token transactions for a particular address.
    function freeze(address account) external only(freezer) {
        require(data.frozenTime(account) == 0, "account already frozen");

        // In `wipe` we use block.timestamp (aka `now`) to check that enough time has passed since
        // this freeze happened. That required time delay -- 4 weeks -- is a long time relative to
        // the maximum drift of block.timestamp, so it is fine to trust the miner here.
        // solium-disable-next-line security/no-block-members
        data.setFrozenTime(account, now);

        emit Frozen(freezer, account);
    }

    /// Unfreeze token transactions for a particular address.
    function unfreeze(address account) external only(freezer) {
        require(data.frozenTime(account) > 0, "account not frozen");
        data.setFrozenTime(account, 0);
        emit Unfrozen(freezer, account);
    }

    /// Modifies a function to run only when the `account` is not frozen.
    modifier notFrozen(address account) {
        require(data.frozenTime(account) == 0, "account frozen");
        _;
    }

    /// Burn the balance of an account that has been frozen for at least 4 weeks.
    function wipe(address account) external only(freezer) {
        require(data.frozenTime(account) > 0, "cannot wipe unfrozen account");
        // See commentary above about using block.timestamp.
        // solium-disable-next-line security/no-block-members
        require(data.frozenTime(account) + 4 weeks < now, "cannot wipe frozen account before 4 weeks");
        _burn(account, data.balance(account));
        emit Wiped(freezer, account);
    }


    // ==== Token transfers, allowances, minting, and burning ====


    /// @return how many attotokens are held by `holder`.
    function balanceOf(address holder) external view returns (uint256) {
        return data.balance(holder);
    }

    /// @return how many attotokens `holder` has allowed `spender` to control.
    function allowance(address holder, address spender) external view returns (uint256) {
        return data.allowed(holder, spender);
    }

    /// Transfer `value` attotokens from `msg.sender` to `to`.
    function transfer(address to, uint256 value)
        external
        notPaused
        notFrozen(msg.sender)
        notFrozen(to)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * Approve `spender` to spend `value` attotokens on behalf of `msg.sender`.
     *
     * Beware that changing a nonzero allowance with this method brings the risk that
     * someone may use both the old and the new allowance by unfortunate transaction ordering. One
     * way to mitigate this risk is to first reduce the spender's allowance
     * to 0, and then set the desired value afterwards, per
     * [this ERC-20 issue](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729).
     *
     * A simpler workaround is to use `increaseAllowance` or `decreaseAllowance`, below.
     *
     * @param spender address The address which will spend the funds.
     * @param value uint256 How many attotokens to allow `spender` to spend.
     */
    function approve(address spender, uint256 value)
        external
        notPaused
        notFrozen(msg.sender)
        notFrozen(spender)
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /// Transfer approved tokens from one address to another.
    /// @param from address The address to send tokens from.
    /// @param to address The address to send tokens to.
    /// @param value uint256 The number of attotokens to send.
    function transferFrom(address from, address to, uint256 value)
        external
        notPaused
        notFrozen(msg.sender)
        notFrozen(from)
        notFrozen(to)
        returns (bool)
    {
        _transfer(from, to, value);
        _approve(from, msg.sender, data.allowed(from, msg.sender).sub(value));
        return true;
    }

    /// Increase `spender`'s allowance of the sender's tokens.
    /// @dev From MonolithDAO Token.sol
    /// @param spender The address which will spend the funds.
    /// @param addedValue How many attotokens to increase the allowance by.
    function increaseAllowance(address spender, uint256 addedValue)
        external
        notPaused
        notFrozen(msg.sender)
        notFrozen(spender)
        returns (bool)
    {
        _approve(msg.sender, spender, data.allowed(msg.sender, spender).add(addedValue));
        return true;
    }

    /// Decrease `spender`'s allowance of the sender's tokens.
    /// @dev From MonolithDAO Token.sol
    /// @param spender The address which will spend the funds.
    /// @param subtractedValue How many attotokens to decrease the allowance by.
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        notPaused
        notFrozen(msg.sender)
        // This is the one case in which changing the allowance of a frozen spender is allowed.
        // notFrozen(spender)
        returns (bool)
    {
        _approve(msg.sender, spender, data.allowed(msg.sender, spender).sub(subtractedValue));
        return true;
    }

    /// Mint `value` new attotokens to `account`.
    function mint(address account, uint256 value)
        external
        notPaused
        notFrozen(account)
        only(minter)
    {
        require(account != address(0), "can't mint to address zero");

        totalSupply = totalSupply.add(value);
        data.addBalance(account, value);
        emit Transfer(address(0), account, value);
    }

    /// Burn `value` attotokens from `account`, if sender has that much allowance from `account`.
    function burnFrom(address account, uint256 value)
        external
        notPaused
        notFrozen(account)
        only(minter)
    {
        _burn(account, value);
        _approve(account, msg.sender, data.allowed(account, msg.sender).sub(value));
    }

    /// @dev Transfer of `value` attotokens from `from` to `to`.
    /// Internal; doesn't check permissions.
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "can't transfer to address zero");

        data.subBalance(from, value);
        data.addBalance(to, value);
        emit Transfer(from, to, value);
    }

    /// @dev Burn `value` attotokens from `account`.
    /// Internal; doesn't check permissions.
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "can't burn from address zero");

        totalSupply = totalSupply.sub(value);
        data.subBalance(account, value);
        emit Transfer(account, address(0), value);
    }

    /// @dev Set `spender`'s allowance on `holder`'s tokens to `value` attotokens.
    /// Internal; doesn't check permissions.
    function _approve(address holder, address spender, uint256 value) internal {
        require(spender != address(0), "spender cannot be address zero");
        require(holder != address(0), "holder cannot be address zero");

        data.setAllowed(holder, spender, value);
        emit Approval(holder, spender, value);
    }
}

contract ReserveDollarEternalStorage {

    using SafeMath for uint256;



    // ===== auth =====

    address public owner;
    address public escapeHatch;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event EscapeHatchTransferred(address indexed oldEscapeHatch, address indexed newEscapeHatch);

    /// On construction, set auth fields.
    constructor(address escapeHatchAddress) public {
        owner = msg.sender;
        escapeHatch = escapeHatchAddress;
    }

    /// Only run modified function if sent by `owner`.
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    /// Set `owner`.
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner || msg.sender == escapeHatch, "not authorized");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /// Set `escape hatch`.
    function transferEscapeHatch(address newEscapeHatch) external {
        require(msg.sender == escapeHatch, "not authorized");
        emit EscapeHatchTransferred(escapeHatch, newEscapeHatch);
        escapeHatch = newEscapeHatch;
    }

    // ===== balance =====

    mapping(address => uint256) public balance;

    /// Add `value` to `balance[key]`, unless this causes integer overflow.
    ///
    /// @dev This is a slight divergence from the strict Eternal Storage pattern, but it reduces the gas
    /// for the by-far most common token usage, it's a *very simple* divergence, and `setBalance` is
    /// available anyway.
    function addBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].add(value);
    }

    /// Subtract `value` from `balance[key]`, unless this causes integer underflow.
    function subBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].sub(value);
    }

    /// Set `balance[key]` to `value`.
    function setBalance(address key, uint256 value) external onlyOwner {
        balance[key] = value;
    }



    // ===== allowed =====

    mapping(address => mapping(address => uint256)) public allowed;

    /// Set `to`'s allowance of `from`'s tokens to `value`.
    function setAllowed(address from, address to, uint256 value) external onlyOwner {
        allowed[from][to] = value;
    }



    // ===== frozenTime =====

    /// @dev When `frozenTime[addr] == 0`, `addr` is not frozen. This is the normal state.
    /// When `frozenTime[addr] == t` and `t > 0`, `addr` was last frozen at timestamp `t`.
    /// So, to unfreeze an address `addr`, set `frozenTime[addr] = 0`.
    mapping(address => uint256) public frozenTime;

    /// Set `frozenTime[who]` to `time`.
    function setFrozenTime(address who, uint256 time) external onlyOwner {
        frozenTime[who] = time;
    }
}

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