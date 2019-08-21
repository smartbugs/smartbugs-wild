pragma solidity 0.4.24;

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
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

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
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
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
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

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
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

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
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

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
  * @title Escrow (based on openzeppelin version with one function to withdraw funds to the wallet)
  * @dev Base escrow contract, holds funds destinated to a payee until they
  * withdraw them. The contract that uses the escrow as its payment method
  * should be its owner, and provide public methods redirecting to the escrow's
  * deposit and withdraw.
  */
contract Escrow is Ownable {
    using SafeMath for uint256;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private deposits;

    /**
      * @dev Stores the sent amount as credit to be withdrawn.
      * @param _payee The destination address of the funds.
      */
    function deposit(address _payee) public onlyOwner payable {
        uint256 amount = msg.value;
        deposits[_payee] = deposits[_payee].add(amount);

        emit Deposited(_payee, amount);
    }

    /**
      * @dev Withdraw accumulated balance for a payee.
      * @param _payee The address whose funds will be withdrawn and transferred to.
      * @return Amount withdrawn
      */
    function withdraw(address _payee) public onlyOwner returns(uint256) {
        uint256 payment = deposits[_payee];

        assert(address(this).balance >= payment);

        deposits[_payee] = 0;

        _payee.transfer(payment);

        emit Withdrawn(_payee, payment);
        return payment;
    }

    /**
      * @dev Withdraws the wallet's funds.
      * @param _wallet address the funds will be transferred to.
      */
    function beneficiaryWithdraw(address _wallet) public onlyOwner {
        uint256 _amount = address(this).balance;
        
        _wallet.transfer(_amount);

        emit Withdrawn(_wallet, _amount);
    }

    /**
      * @dev Returns the deposited amount of the given address.
      * @param _payee address of the payee of which to return the deposted amount.
      * @return Deposited amount by the address given as argument.
      */
    function depositsOf(address _payee) public view returns(uint256) {
        return deposits[_payee];
    }
}

/**
  * @title PullPayment (based on openzeppelin version with one function to withdraw funds to the wallet)
  * @dev Base contract supporting async send for pull payments. Inherit from this
  * contract and use asyncTransfer instead of send or transfer.
  */
contract PullPayment {
    Escrow private escrow;

    constructor() public {
        escrow = new Escrow();
    }

    /**
      * @dev Returns the credit owed to an address.
      * @param _dest The creditor's address.
      * @return Deposited amount by the address given as argument.
      */
    function payments(address _dest) public view returns(uint256) {
        return escrow.depositsOf(_dest);
    }

    /**
      * @dev Withdraw accumulated balance, called by payee.
      * @param _payee The address whose funds will be withdrawn and transferred to.
      * @return Amount withdrawn
      */
    function _withdrawPayments(address _payee) internal returns(uint256) {
        uint256 payment = escrow.withdraw(_payee);

        return payment;
    }

    /**
      * @dev Called by the payer to store the sent amount as credit to be pulled.
      * @param _dest The destination address of the funds.
      * @param _amount The amount to transfer.
      */
    function _asyncTransfer(address _dest, uint256 _amount) internal {
        escrow.deposit.value(_amount)(_dest);
    }

    /**
      * @dev Withdraws the wallet's funds.
      * @param _wallet address the funds will be transferred to.
      */
    function _withdrawFunds(address _wallet) internal {
        escrow.beneficiaryWithdraw(_wallet);
    }
}

/** @title VestedCrowdsale
  * @dev Extension of Crowdsale to allow a vested distribution of tokens
  * Users have to individually claim their tokens
  */
contract VestedCrowdsale {
    using SafeMath for uint256;

    mapping (address => uint256) public withdrawn;
    mapping (address => uint256) public contributions;
    mapping (address => uint256) public contributionsRound;
    uint256 public vestedTokens;

    /**
      * @dev Gives how much a user is allowed to withdraw at the current moment
      * @param _beneficiary The address of the user asking how much he's allowed
      * to withdraw
      * @return Amount _beneficiary is allowed to withdraw
      */
    function getWithdrawableAmount(address _beneficiary) public view returns(uint256) {
        uint256 step = _getVestingStep(_beneficiary);
        uint256 valueByStep = _getValueByStep(_beneficiary);
        uint256 result = step.mul(valueByStep).sub(withdrawn[_beneficiary]);

        return result;
    }

    /**
      * @dev Gives the step of the vesting (starts from 0 to steps)
      * @param _beneficiary The address of the user asking how much he's allowed
      * to withdraw
      * @return The vesting step for _beneficiary
      */
    function _getVestingStep(address _beneficiary) internal view returns(uint8) {
        require(contributions[_beneficiary] != 0);
        require(contributionsRound[_beneficiary] > 0 && contributionsRound[_beneficiary] < 4);

        uint256 march31 = 1554019200;
        uint256 april30 = 1556611200;
        uint256 may31 = 1559289600;
        uint256 june30 = 1561881600;
        uint256 july31 = 1564560000;
        uint256 sept30 = 1569830400;
        uint256 contributionRound = contributionsRound[_beneficiary];

        // vesting for private sale contributors
        if (contributionRound == 1) {
            if (block.timestamp < march31) {
                return 0;
            }
            if (block.timestamp < june30) {
                return 1;
            }
            if (block.timestamp < sept30) {
                return 2;
            }

            return 3;
        }
        // vesting for pre ico contributors
        if (contributionRound == 2) {
            if (block.timestamp < april30) {
                return 0;
            }
            if (block.timestamp < july31) {
                return 1;
            }

            return 2;
        }
        // vesting for ico contributors
        if (contributionRound == 3) {
            if (block.timestamp < may31) {
                return 0;
            }

            return 1;
        }
    }

    /**
      * @dev Gives the amount a user is allowed to withdraw by step
      * @param _beneficiary The address of the user asking how much he's allowed
      * to withdraw
      * @return How much a user is allowed to withdraw by step
      */
    function _getValueByStep(address _beneficiary) internal view returns(uint256) {
        require(contributions[_beneficiary] != 0);
        require(contributionsRound[_beneficiary] > 0 && contributionsRound[_beneficiary] < 4);

        uint256 contributionRound = contributionsRound[_beneficiary];
        uint256 amount;
        uint256 rate;

        if (contributionRound == 1) {
            rate = 416700;
            amount = contributions[_beneficiary].mul(rate).mul(25).div(100);
            return amount;
        } else if (contributionRound == 2) {
            rate = 312500;
            amount = contributions[_beneficiary].mul(rate).mul(25).div(100);
            return amount;
        }

        rate = 250000;
        amount = contributions[_beneficiary].mul(rate).mul(25).div(100);
        return amount;
    }
}

/**
  * @title Whitelist
  * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
  * This simplifies the implementation of "user permissions".
  */
contract Whitelist is Ownable {
    // Whitelisted address
    mapping(address => bool) public whitelist;

    event AddedBeneficiary(address indexed _beneficiary);
    event RemovedBeneficiary(address indexed _beneficiary);

    /**
      * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
      * @param _beneficiaries Addresses to be added to the whitelist
      */
    function addAddressToWhitelist(address[] _beneficiaries) public onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;

            emit AddedBeneficiary(_beneficiaries[i]);
        }
    }

    /**
      * @dev Adds list of address to whitelist. Not overloaded due to limitations with truffle testing.
      * @param _beneficiary Address to be added to the whitelist
      */
    function addToWhitelist(address _beneficiary) public onlyOwner {
        whitelist[_beneficiary] = true;

        emit AddedBeneficiary(_beneficiary);
    }

    /**
      * @dev Removes single address from whitelist.
      * @param _beneficiary Address to be removed to the whitelist
      */
    function removeFromWhitelist(address _beneficiary) public onlyOwner {
        whitelist[_beneficiary] = false;

        emit RemovedBeneficiary(_beneficiary);
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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

/**
  * @title DSLACrowdsale
  * @dev Crowdsale is a base contract for managing a token crowdsale,
  * allowing investors to purchase tokens with ether
  */
contract DSLACrowdsale is VestedCrowdsale, Whitelist, Pausable, PullPayment {
    // struct to store ico rounds details
    struct IcoRound {
        uint256 rate;
        uint256 individualFloor;
        uint256 individualCap;
        uint256 softCap;
        uint256 hardCap;
    }

    // mapping ico rounds
    mapping (uint256 => IcoRound) public icoRounds;
    // The token being sold
    ERC20Burnable private _token;
    // Address where funds are collected
    address private _wallet;
    // Amount of wei raised
    uint256 private totalContributionAmount;
    // Tokens to sell = 5 Billions * 10^18 = 5 * 10^27 = 5000000000000000000000000000
    uint256 public constant TOKENSFORSALE = 5000000000000000000000000000;
    // Current ico round
    uint256 public currentIcoRound;
    // Distributed Tokens
    uint256 public distributedTokens;
    // Amount of wei raised from other currencies
    uint256 public weiRaisedFromOtherCurrencies;
    // Refund period on
    bool public isRefunding = false;
    // Finalized crowdsale off
    bool public isFinalized = false;
    // Refunding deadline
    uint256 public refundDeadline;

    /**
      * Event for token purchase logging
      * @param purchaser who paid for the tokens
      * @param beneficiary who got the tokens
      * @param value weis paid for purchase
      * @param amount amount of tokens purchased
      */
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
      * @param wallet Address where collected funds will be forwarded to
      * @param token Address of the token being sold
      */
    constructor(address wallet, ERC20Burnable token) public {
        require(wallet != address(0) && token != address(0));

        icoRounds[1] = IcoRound(
            416700,
            3 ether,
            600 ether,
            0,
            1200 ether
        );

        icoRounds[2] = IcoRound(
            312500,
            12 ether,
            5000 ether,
            0,
            6000 ether
        );

        icoRounds[3] = IcoRound(
            250000,
            3 ether,
            30 ether,
            7200 ether,
            17200 ether
        );

        _wallet = wallet;
        _token = token;
    }

    /**
      * @dev fallback function ***DO NOT OVERRIDE***
      */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
      * @dev low level token purchase ***DO NOT OVERRIDE***
      * @param _contributor Address performing the token purchase
      */
    function buyTokens(address _contributor) public payable {
        require(whitelist[_contributor]);

        uint256 contributionAmount = msg.value;

        _preValidatePurchase(_contributor, contributionAmount, currentIcoRound);

        totalContributionAmount = totalContributionAmount.add(contributionAmount);

        uint tokenAmount = _handlePurchase(contributionAmount, currentIcoRound, _contributor);

        emit TokensPurchased(msg.sender, _contributor, contributionAmount, tokenAmount);

        _forwardFunds();
    }

    /**
      * @dev Function to go to the next round
      * @return True bool when round is incremented
      */
    function goToNextRound() public onlyOwner returns(bool) {
        require(currentIcoRound >= 0 && currentIcoRound < 3);

        currentIcoRound = currentIcoRound + 1;

        return true;
    }

    /**
      * @dev Manually adds a contributor's contribution for private presale period
      * @param _contributor The address of the contributor
      * @param _contributionAmount Amount of wei contributed
      */
    function addPrivateSaleContributors(address _contributor, uint256 _contributionAmount)
    public onlyOwner
    {
        uint privateSaleRound = 1;
        _preValidatePurchase(_contributor, _contributionAmount, privateSaleRound);

        totalContributionAmount = totalContributionAmount.add(_contributionAmount);

        addToWhitelist(_contributor);

        _handlePurchase(_contributionAmount, privateSaleRound, _contributor);
    }

    /**
      * @dev Manually adds a contributor's contribution with other currencies
      * @param _contributor The address of the contributor
      * @param _contributionAmount Amount of wei contributed
      * @param _round contribution round
      */
    function addOtherCurrencyContributors(address _contributor, uint256 _contributionAmount, uint256 _round)
    public onlyOwner
    {
        _preValidatePurchase(_contributor, _contributionAmount, _round);

        weiRaisedFromOtherCurrencies = weiRaisedFromOtherCurrencies.add(_contributionAmount);

        addToWhitelist(_contributor);

        _handlePurchase(_contributionAmount, _round, _contributor);
    }

    /**
      * @dev Function to close refunding period
      * @return True bool
      */
    function closeRefunding() public returns(bool) {
        require(isRefunding);
        require(block.timestamp > refundDeadline);

        isRefunding = false;

        _withdrawFunds(wallet());

        return true;
    }

    /**
      * @dev Function to close the crowdsale
      * @return True bool
      */
    function closeCrowdsale() public onlyOwner returns(bool) {
        require(currentIcoRound > 0 && currentIcoRound < 4);

        currentIcoRound = 4;

        return true;
    }

    /**
      * @dev Function to finalize the crowdsale
      * @param _burn bool burn unsold tokens when true
      * @return True bool
      */
    function finalizeCrowdsale(bool _burn) public onlyOwner returns(bool) {
        require(currentIcoRound == 4 && !isRefunding);

        if (raisedFunds() < icoRounds[3].softCap) {
            isRefunding = true;
            refundDeadline = block.timestamp + 4 weeks;

            return true;
        }

        require(!isFinalized);

        _withdrawFunds(wallet());
        isFinalized = true;

        if (_burn) {
            _burnUnsoldTokens();
        } else {
            _withdrawUnsoldTokens();
        }

        return  true;
    }

    /**
      * @dev Investors can claim refunds here if crowdsale is unsuccessful
      */
    function claimRefund() public {
        require(isRefunding);
        require(block.timestamp <= refundDeadline);
        require(payments(msg.sender) > 0);

        uint256 payment = _withdrawPayments(msg.sender);

        totalContributionAmount = totalContributionAmount.sub(payment);
    }

    /**
      * @dev Allows the sender to claim the tokens he is allowed to withdraw
      */
    function claimTokens() public {
        require(getWithdrawableAmount(msg.sender) != 0);

        uint256 amount = getWithdrawableAmount(msg.sender);
        withdrawn[msg.sender] = withdrawn[msg.sender].add(amount);

        _deliverTokens(msg.sender, amount);
    }

    /**
      * @dev returns the token being sold
      * @return the token being sold
      */
    function token() public view returns(ERC20Burnable) {
        return _token;
    }

    /**
      * @dev returns the wallet address that collects the funds
      * @return the address where funds are collected
      */
    function wallet() public view returns(address) {
        return _wallet;
    }

    /**
      * @dev Returns the total of raised funds
      * @return total amount of raised funds
      */
    function raisedFunds() public view returns(uint256) {
        return totalContributionAmount.add(weiRaisedFromOtherCurrencies);
    }

    // -----------------------------------------
    // Internal interface
    // -----------------------------------------
    /**
      * @dev Source of tokens. Override this method to modify the way in which
      * the crowdsale ultimately gets and sends its tokens.
      * @param _beneficiary Address performing the token purchase
      * @param _tokenAmount Number of tokens to be emitted
      */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
    internal
    {
        _token.transfer(_beneficiary, _tokenAmount);
    }

    /**
      * @dev Determines how ETH is stored/forwarded on purchases.
      */
    function _forwardFunds()
    internal
    {
        if (currentIcoRound == 2 || currentIcoRound == 3) {
            _asyncTransfer(msg.sender, msg.value);
        } else {
            _wallet.transfer(msg.value);
        }
    }

    /**
      * @dev Gets tokens allowed to deliver in the given round
      * @param _tokenAmount total amount of tokens involved in the purchase
      * @param _round Round in which the purchase is happening
      * @return Returns the amount of tokens allowed to deliver
      */
    function _getTokensToDeliver(uint _tokenAmount, uint _round)
    internal pure returns(uint)
    {
        require(_round > 0 && _round < 4);
        uint deliverPercentage = _round.mul(25);

        return _tokenAmount.mul(deliverPercentage).div(100);
    }

    /**
      * @dev Handles token purchasing
      * @param _contributor Address performing the token purchase
      * @param _contributionAmount Value in wei involved in the purchase
      * @param _round Round in which the purchase is happening
      * @return Returns the amount of tokens purchased
      */
    function _handlePurchase(uint _contributionAmount, uint _round, address _contributor)
    internal returns(uint) {
        uint256 soldTokens = distributedTokens.add(vestedTokens);
        uint256 tokenAmount = _getTokenAmount(_contributionAmount, _round);

        require(tokenAmount.add(soldTokens) <= TOKENSFORSALE);

        contributions[_contributor] = contributions[_contributor].add(_contributionAmount);
        contributionsRound[_contributor] = _round;

        uint tokensToDeliver = _getTokensToDeliver(tokenAmount, _round);
        uint tokensToVest = tokenAmount.sub(tokensToDeliver);

        distributedTokens = distributedTokens.add(tokensToDeliver);
        vestedTokens = vestedTokens.add(tokensToVest);

        _deliverTokens(_contributor, tokensToDeliver);

        return tokenAmount;
    }

    /**
      * @dev Validation of an incoming purchase.
      * @param _contributor Address performing the token purchase
      * @param _contributionAmount Value in wei involved in the purchase
      * @param _round Round in which the purchase is happening
      */
    function _preValidatePurchase(address _contributor, uint256 _contributionAmount, uint _round)
    internal view
    {
        require(_contributor != address(0));
        require(currentIcoRound > 0 && currentIcoRound < 4);
        require(_round > 0 && _round < 4);
        require(contributions[_contributor] == 0);
        require(_contributionAmount >= icoRounds[_round].individualFloor);
        require(_contributionAmount < icoRounds[_round].individualCap);
        require(_doesNotExceedHardCap(_contributionAmount, _round));
    }

    /**
      * @dev define the way in which ether is converted to tokens.
      * @param _contributionAmount Value in wei to be converted into tokens
      * @return Number of tokens that can be purchased with the specified _contributionAmount
      */
    function _getTokenAmount(uint256 _contributionAmount, uint256 _round)
    internal view returns(uint256)
    {
        uint256 _rate = icoRounds[_round].rate;
        return _contributionAmount.mul(_rate);
    }

    /**
      * @dev Checks if current round hardcap will not be exceeded by a new contribution
      * @param _contributionAmount purchase amount in Wei
      * @param _round Round in which the purchase is happening
      * @return true when current hardcap is not exceeded, false if exceeded
      */
    function _doesNotExceedHardCap(uint _contributionAmount, uint _round)
    internal view returns(bool)
    {
        uint roundHardCap = icoRounds[_round].hardCap;
        return totalContributionAmount.add(_contributionAmount) <= roundHardCap;
    }

    /**
      * @dev Function to burn unsold tokens
      */
    function _burnUnsoldTokens()
    internal
    {
        uint256 tokensToBurn = TOKENSFORSALE.sub(vestedTokens).sub(distributedTokens);

        _token.burn(tokensToBurn);
    }

    /**
      * @dev Transfer the unsold tokens to the funds collecting address
      */
    function _withdrawUnsoldTokens()
    internal {
        uint256 tokensToWithdraw = TOKENSFORSALE.sub(vestedTokens).sub(distributedTokens);

        _token.transfer(_wallet, tokensToWithdraw);
    }
}