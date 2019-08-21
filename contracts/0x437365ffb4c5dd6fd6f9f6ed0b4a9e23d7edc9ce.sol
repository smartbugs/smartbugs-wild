pragma solidity 0.4.25;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
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

contract AdminRole {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _admins;

    constructor () internal {
        _addAdmin(msg.sender);
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title TokenVault
 * @dev TokenVault is a token holder contract that will allow a
 * beneficiary to spend the tokens from some function of a specified ERC20 token
 */
contract TokenVault {
    // ERC20 token contract being held
    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    /**
     * @notice increase the allowance of the token contract
     * to the full amount of tokens held in this vault
     */
    function fillUpAllowance() public {
        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.approve(token, amount);
    }

    /**
     * @notice change the allowance for a specific spender
     */
    function approve(address _spender, uint256 _tokensAmount) public {
        require(msg.sender == address(token));

        token.approve(_spender, _tokensAmount);
    }
}

contract FaireumToken is ERC20, ERC20Detailed, AdminRole {
    using SafeMath for uint256;

    uint8 public constant DECIMALS = 18;

    /// Maximum tokens to be allocated (1.2 billion FAIRC)
    uint256 public constant INITIAL_SUPPLY = 1200000000 * 10**uint256(DECIMALS);

    /// This vault is used to keep the Faireum team, developers and advisors tokens
    TokenVault public teamAdvisorsTokensVault;

    /// This vault is used to keep the reward pool tokens
    TokenVault public rewardPoolTokensVault;

    /// This vault is used to keep the founders tokens
    TokenVault public foundersTokensVault;

    /// This vault is used to keep the tokens for marketing/partnership/airdrop
    TokenVault public marketingAirdropTokensVault;

    /// This vault is used to keep the tokens for sale
    TokenVault public saleTokensVault;

    /// The reference time point at which all token locks start
    //  Mon Mar 11 2019 00:00:00 GMT+0000   The begining of Pre ICO
    uint256 public locksStartDate = 1552262400;

    mapping(address => uint256) public lockedHalfYearBalances;
    mapping(address => uint256) public lockedFullYearBalances;

    modifier timeLock(address from, uint256 value) {
        if (lockedHalfYearBalances[from] > 0 && now >= locksStartDate + 182 days) lockedHalfYearBalances[from] = 0;
        if (now < locksStartDate + 365 days) {
            uint256 unlocks = balanceOf(from).sub(lockedHalfYearBalances[from]).sub(lockedFullYearBalances[from]);
            require(value <= unlocks);
        } else if (lockedFullYearBalances[from] > 0) lockedFullYearBalances[from] = 0;
        _;
    }

    constructor () public ERC20Detailed("Faireum Token", "FAIRC", DECIMALS) {
    }

    /// @dev function to lock reward pool tokens
    function lockRewardPoolTokens(address _beneficiary, uint256 _tokensAmount) public onlyAdmin {
        _lockTokens(address(rewardPoolTokensVault), false, _beneficiary, _tokensAmount);
    }

    /// @dev function to lock founders tokens
    function lockFoundersTokens(address _beneficiary, uint256 _tokensAmount) public onlyAdmin {
        _lockTokens(address(foundersTokensVault), false, _beneficiary, _tokensAmount);
    }

    /// @dev function to lock team/devs/advisors tokens
    function lockTeamTokens(address _beneficiary, uint256 _tokensAmount) public onlyAdmin {
        require(_tokensAmount.mod(2) == 0);
        uint256 _half = _tokensAmount.div(2);
        _lockTokens(address(teamAdvisorsTokensVault), false, _beneficiary, _half);
        _lockTokens(address(teamAdvisorsTokensVault), true, _beneficiary, _half);
    }

    /// @dev check the locked balance for an address
    function lockedBalanceOf(address _owner) public view returns (uint256) {
        return lockedFullYearBalances[_owner].add(lockedHalfYearBalances[_owner]);
    }

    /// @dev change the allowance for an ICO sale service provider
    function approveSaleSpender(address _spender, uint256 _tokensAmount) public onlyAdmin {
        saleTokensVault.approve(_spender, _tokensAmount);
    }

    /// @dev change the allowance for an ICO marketing service provider
    function approveMarketingSpender(address _spender, uint256 _tokensAmount) public onlyAdmin {
        marketingAirdropTokensVault.approve(_spender, _tokensAmount);
    }

    function transferFrom(address from, address to, uint256 value) public timeLock(from, value) returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) public timeLock(msg.sender, value) returns (bool) {
        return super.transfer(to, value);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function createTokensVaults() external onlyAdmin {
        require(teamAdvisorsTokensVault == address(0));
        require(rewardPoolTokensVault == address(0));
        require(foundersTokensVault == address(0));
        require(marketingAirdropTokensVault == address(0));
        require(saleTokensVault == address(0));

        // Team, devs and advisors tokens - 120M FAIRC (10%)
        teamAdvisorsTokensVault = createTokenVault(120000000 * (10 ** uint256(DECIMALS)));
        // Reward funding pool tokens - 240M FAIRC (20%)
        rewardPoolTokensVault = createTokenVault(240000000 * (10 ** uint256(DECIMALS)));
        // Founders tokens - 60M FAIRC (5%)
        foundersTokensVault = createTokenVault(60000000 * (10 ** uint256(DECIMALS)));
        // Marketing/partnership/airdrop tokens - 120M FAIRC (10%)
        marketingAirdropTokensVault = createTokenVault(120000000 * (10 ** uint256(DECIMALS)));
        // Sale tokens - 660M FAIRC (55%)
        saleTokensVault = createTokenVault(660000000 * (10 ** uint256(DECIMALS)));

        require(totalSupply() == INITIAL_SUPPLY);
    }

    /// @dev Admin-only function to recover any tokens mistakenly sent to this contract
    function recoverERC20Tokens(address _contractAddress) external onlyAdmin  {
        IERC20 erc20Token = IERC20(_contractAddress);
        if (erc20Token.balanceOf(address(this)) > 0) {
            require(erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this))));
        }
    }

    /// @dev Create a TokenVault, fill with newly minted tokens and
    /// allow them to be spent only from the token contract
    function createTokenVault(uint256 tokens) internal returns (TokenVault) {
        TokenVault tokenVault = new TokenVault(ERC20(this));
        _mint(address(tokenVault), tokens);
        tokenVault.fillUpAllowance();
        return tokenVault;
    }

    /// @dev generic function to lock tokens from a vault
    function _lockTokens(address _fromVault, bool _halfYear, address _beneficiary, uint256 _tokensAmount) internal {
        require(_beneficiary != address(0));

        if (_halfYear) {
            lockedHalfYearBalances[_beneficiary] = lockedHalfYearBalances[_beneficiary].add(_tokensAmount);
        } else {
            lockedFullYearBalances[_beneficiary] = lockedFullYearBalances[_beneficiary].add(_tokensAmount);
        }

        require(this.transferFrom(_fromVault, _beneficiary, _tokensAmount));
    }
}