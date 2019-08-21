pragma solidity ^0.4.24;
//pragma experimental ABIEncoderV2;
/**
  * @title Luckybar
  * @author Joshua Choi
  * @dev
  *
  */

pragma solidity ^0.4.24;

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() public {
    pausers.add(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function renouncePauser() public {
    pausers.remove(msg.sender);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

contract Pausable is PauserRole {
  event Paused();
  event Unpaused();

  bool private _paused = false;


  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
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
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

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
  * @param owner The address to query the the balance of.
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

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
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
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(_balances[to].add(value) > _balances[to]);
    require(to != address(0));

    uint previousBalances = _balances[from].add(_balances[to]);
    assert(_balances[from].add(_balances[to]) == previousBalances);
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  /**
   * @dev Retrieve tokens from one address to owner
   * @param from address The address which you want to send tokens from
   * @param value uint256 the amount of tokens to be transferred
   */
  function retrieveFrom(
    address from,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _balances[from]);
    require(_balances[msg.sender].add(value) > _balances[msg.sender]);

    uint previousBalances = _balances[from].add(_balances[msg.sender]);
    assert(_balances[from].add(_balances[msg.sender]) == previousBalances);

    _balances[from] = _balances[from].sub(value);
    _balances[msg.sender] = _balances[msg.sender].add(value);
    emit Transfer(from, msg.sender, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
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

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
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

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
  
    /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    _allowed[msg.sender][_spender] = (
    _allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = _allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      _allowed[msg.sender][_spender] = 0;
    } else {
      _allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
    return true;
   }
}


contract ERC20Burnable is ERC20 {

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function sudoBurnFrom(address from, uint256 value) public {
    _burn(from, value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
  }

  /**
   * @dev Overrides ERC20._burn in order for burn and burnFrom to emit
   * an additional Burn event.
   */
  function _burn(address who, uint256 value) internal {
    super._burn(who, value);
  }
}


contract MinterRole {
  using Roles for Roles.Role;
  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);
  Roles.Role private minters;
  constructor() internal {
    _addMinter(msg.sender);
  }
  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }
  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }
  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }
  function renounceMinter() public {
    _removeMinter(msg.sender);
  }
  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }
  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

contract StandardTokenERC20Custom is ERC20Detailed, ERC20Burnable, ERC20Pausable, ERC20Mintable {

  using SafeERC20 for ERC20;

  //   string public name = "TOKA CHIP";
  //   string public symbol = "CHIP";
  //   uint8 public decimals = 18;
  //   uint256 private _totalSupply = 4600000000 * (10 ** uint256(decimals));
  //   4600000000000000000000000000

  constructor(string name, string symbol, uint8 decimals, uint256 _totalSupply)
    ERC20Pausable()
    ERC20Burnable()
    ERC20Detailed(name, symbol, decimals)
    ERC20()
    public
  {
    _mint(msg.sender, _totalSupply * (10 ** uint256(decimals)));
    addPauser(msg.sender);
    addMinter(msg.sender);
  }

  function approveAndPlayFunc(address _spender, uint _value, string _func) public returns(bool success){
    require(_spender != address(this));
    require(super.approve(_spender, _value));
    require(_spender.call(bytes4(keccak256(string(abi.encodePacked(_func, "(address,uint256)")))), msg.sender, _value));
    return true;
  }
}

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


/**
 * @title Ownership
 * @dev Ownership contract establishes ownership (via owner address) and provides basic authorization control
 * functions (transferring of ownership and ownership modifier).
 */
 
contract Ownership {
    address public owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev The establishOwnership constructor sets original `owner` of the contract to the sender
     * account.
     */
    function estalishOwnership() public {
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
     * @dev Allows current owner to transfer control/ownership of contract to a newOwner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


/**
 * @dev Termination contract for terminating the smart contract.
 * Terminate function can only be called by the current owner,
 * returns all funds in contract to owner and then terminates.
 */
contract Bank is Ownership {

    function terminate() public onlyOwner {
        selfdestruct(owner);
    }

    function withdraw(uint amount) payable public onlyOwner {
        if(!owner.send(amount)) revert();
    }

    function depositSpecificAmount(uint _deposit) payable public onlyOwner {
        require(msg.value == _deposit);
    }

    function deposit() payable public onlyOwner {
        require(msg.value > 0);
    }

 /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
}

/**
 * @dev contract that sets terms of the minBet, houseEdge,
 * & contains betting and fallback function.
 */
contract LuckyBar is Bank {

    struct record {
        uint[5] date;
        uint[5] amount;
        address[5] account;
    }
    
    struct pair {
        uint256 maxBet;
        uint256 minBet;
        uint256 houseEdge; // in %
        uint256 reward;
        bool bEnabled;
        record ranking;
        record latest;
    }

    pair public sE2E;
    pair public sE2C;
    pair public sC2E;
    pair public sC2C;

    uint256 public E2C_Ratio;
    uint256 private salt;
    IERC20 private token;
    StandardTokenERC20Custom private chip;
    address public manager;

    // Either True or False + amount
    //event Won(bool _status, string _rewardType, uint _amount, record[5], record[5]); // it does not work maybe because of its size is too big
    event Won(bool _status, string _rewardType, uint _amount);
    event Swapped(string _target, uint _amount);

    // sets the stakes of the bet
    constructor() payable public {
        estalishOwnership();
        setProperties("thisissaltIneedtomakearandomnumber", 100000);
        setToken(0x0bfd1945683489253e401485c6bbb2cfaedca313); // toka mainnet
        setChip(0x27a88bfb581d4c68b0fb830ee4a493da94dcc86c); // chip mainnet
        setGameMinBet(100e18, 0.1 ether, 100e18, 0.1 ether);
        setGameMaxBet(10000000e18, 1 ether, 100000e18, 1 ether);
        setGameFee(1,0,5,5);
        enableGame(true, true, false, true);
        setReward(0,5000,0,5000);
        manager = owner;
    }
    
    function getRecordsE2E() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sE2E.ranking.date,sE2E.ranking.amount,sE2E.ranking.account, sE2E.latest.date,sE2E.latest.amount,sE2E.latest.account);
    }
    function getRecordsE2C() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sE2C.ranking.date,sE2C.ranking.amount,sE2C.ranking.account, sE2C.latest.date,sE2C.latest.amount,sE2C.latest.account);
    }
    function getRecordsC2E() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sC2E.ranking.date,sC2E.ranking.amount,sC2E.ranking.account, sC2E.latest.date,sC2E.latest.amount,sC2E.latest.account);
    }
    function getRecordsC2C() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sC2C.ranking.date,sC2C.ranking.amount,sC2C.ranking.account, sC2C.latest.date,sC2C.latest.amount,sC2C
        .latest.account);
    }

    function emptyRecordsE2E() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sE2E.ranking.amount[i] = 0;
            sE2E.ranking.date[i] = 0;
            sE2E.ranking.account[i] = 0x0;
            sE2E.latest.amount[i] = 0;
            sE2E.latest.date[i] = 0;
            sE2E.latest.account[i] = 0x0;
        }
    }

    function emptyRecordsE2C() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sE2C.ranking.amount[i] = 0;
            sE2C.ranking.date[i] = 0;
            sE2C.ranking.account[i] = 0x0;
            sE2C.latest.amount[i] = 0;
            sE2C.latest.date[i] = 0;
            sE2C.latest.account[i] = 0x0;
        }
    }

    function emptyRecordsC2E() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sC2E.ranking.amount[i] = 0;
            sC2E.ranking.date[i] = 0;
            sC2E.ranking.account[i] = 0x0;
            sC2E.latest.amount[i] = 0;
            sC2E.latest.date[i] = 0;
            sC2E.latest.account[i] = 0x0;     
        }
    }

    function emptyRecordsC2C() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sC2C.ranking.amount[i] = 0;
            sC2C.ranking.date[i] = 0;
            sC2C.ranking.account[i] = 0x0;
            sC2C.latest.amount[i] = 0;
            sC2C.latest.date[i] = 0;
            sC2C.latest.account[i] = 0x0;
        }
    }


    function setReward(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.reward = C2C;
        sE2C.reward = E2C;
        sC2E.reward = C2E;
        sE2E.reward = E2E;
    }
    
    function enableGame(bool C2C, bool E2C, bool C2E, bool E2E) public onlyOwner {
        sC2C.bEnabled = C2C;
        sE2C.bEnabled = E2C;
        sC2E.bEnabled = C2E;
        sE2E.bEnabled = E2E;
    }

    function setGameFee(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.houseEdge = C2C;
        sE2C.houseEdge = E2C;
        sC2E.houseEdge = C2E;
        sE2E.houseEdge = E2E;
    }
    
    function setGameMaxBet(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.maxBet = C2C;
        sE2C.maxBet = E2C;
        sC2E.maxBet = C2E;
        sE2E.maxBet = E2E;
    }

    function setGameMinBet(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.minBet = C2C;
        sE2C.minBet = E2C;
        sC2E.minBet = C2E;
        sE2E.minBet = E2E;
    }

    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function setChip(address _chip) public onlyOwner {
        chip = StandardTokenERC20Custom(_chip);
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function setProperties(string _salt, uint _E2C_Ratio) public onlyOwner {
        require(_E2C_Ratio > 0);
        salt = uint(keccak256(_salt));
        E2C_Ratio = _E2C_Ratio;
    }

    function() public { //fallback
        revert();
    }

    function swapC2T(address _from, uint256 _value) payable public {
        require(chip.transferFrom(_from, manager, _value));
        require(token.transferFrom(manager, _from, _value));

        emit Swapped("TOKA", _value);
    }

    function swapT2C(address _from, uint256 _value) payable public {
        require(token.transferFrom(_from, manager, _value));
        require(chip.transferFrom(manager, _from, _value));

        emit Swapped("CHIP", _value);
    }

    function playC2C(address _from, uint256 _value) payable public {
        require(sC2C.bEnabled);
        require(_value >= sC2C.minBet && _value <= sC2C.maxBet);
        require(chip.transferFrom(_from, manager, _value));

        uint256 amountWon = _value * (50 + uint256(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sC2C.houseEdge) / 100;
        require(chip.transferFrom(manager, _from, amountWon + _value * sC2C.reward)); // reward. but set to be zero.
        
        // ranking
        for(uint i=0;i<5;i++) {
            if(sC2C.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sC2C.ranking.amount[j] = sC2C.ranking.amount[j-1];
                    sC2C.ranking.date[j] = sC2C.ranking.date[j-1];
                    sC2C.ranking.account[j] = sC2C.ranking.account[j-1];
                }
                sC2C.ranking.amount[i] = amountWon;
                sC2C.ranking.date[i] = now;
                sC2C.ranking.account[i] = _from;
                break;
            }
        }
        // latest
        for(i=4;i>0;i--) {
            sC2C.latest.amount[i] = sC2C.latest.amount[i-1];
            sC2C.latest.date[i] = sC2C.latest.date[i-1];
            sC2C.latest.account[i] = sC2C.latest.account[i-1];
        }
        sC2C.latest.amount[0] = amountWon;
        sC2C.latest.date[0] = now;
        sC2C.latest.account[0] = _from;

        emit Won(amountWon > _value, "CHIP", amountWon);//, sC2C.ranking, sC2C.latest);
    }

    function playC2E(address _from, uint256 _value) payable public {
        require(sC2E.bEnabled);
        require(_value >= sC2E.minBet && _value <= sC2E.maxBet);
        require(chip.transferFrom(_from, manager, _value));

        uint256 amountWon = _value * (50 + uint256(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sC2E.houseEdge) / 100 / E2C_Ratio;
        require(_from.send(amountWon));
        
        // ranking
        for(uint i=0;i<5;i++) {
            if(sC2E.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sC2E.ranking.amount[j] = sC2E.ranking.amount[j-1];
                    sC2E.ranking.date[j] = sC2E.ranking.date[j-1];
                    sC2E.ranking.account[j] = sC2E.ranking.account[j-1];
                }
                sC2E.ranking.amount[i] = amountWon;
                sC2E.ranking.date[i] = now;
                sC2E.ranking.account[i] = _from;
                break;
            }
        }
        // latest
        for(i=4;i>0;i--) {
            sC2E.latest.amount[i] = sC2E.latest.amount[i-1];
            sC2E.latest.date[i] = sC2E.latest.date[i-1];
            sC2E.latest.account[i] = sC2E.latest.account[i-1];
        }
        sC2E.latest.amount[0] = amountWon;
        sC2E.latest.date[0] = now;
        sC2E.latest.account[0] = _from;

        emit Won(amountWon > (_value / E2C_Ratio), "ETH", amountWon);//, sC2E.ranking, sC2E.latest);
    }

    function playE2E() payable public {
        require(sE2E.bEnabled);
        require(msg.value >= sE2E.minBet && msg.value <= sE2E.maxBet);

        uint amountWon = msg.value * (50 + uint(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sE2E.houseEdge) / 100;
        require(msg.sender.send(amountWon));
        require(chip.transferFrom(manager, msg.sender, msg.value * sE2E.reward)); // reward!!

        // ranking
        for(uint i=0;i<5;i++) {
            if(sE2E.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sE2E.ranking.amount[j] = sE2E.ranking.amount[j-1];
                    sE2E.ranking.date[j] = sE2E.ranking.date[j-1];
                    sE2E.ranking.account[j] = sE2E.ranking.account[j-1];
                }
                sE2E.ranking.amount[i] = amountWon;
                sE2E.ranking.date[i] = now;
                sE2E.ranking.account[i] = msg.sender;
                break;
            }
        }
        // latest
        for(i=4;i>0;i--) {
            sE2E.latest.amount[i] = sE2E.latest.amount[i-1];
            sE2E.latest.date[i] = sE2E.latest.date[i-1];
            sE2E.latest.account[i] = sE2E.latest.account[i-1];
        }
        sE2E.latest.amount[0] = amountWon;
        sE2E.latest.date[0] = now;
        sE2E.latest.account[0] = msg.sender;

        emit Won(amountWon > msg.value, "ETH", amountWon);//, sE2E.ranking, sE2E.latest);
    }

    function playE2C() payable public {
        require(sE2C.bEnabled);
        require(msg.value >= sE2C.minBet && msg.value <= sE2C.maxBet);

        uint amountWon = msg.value * (50 + uint(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sE2C.houseEdge) / 100 * E2C_Ratio;
        require(chip.transferFrom(manager, msg.sender, amountWon));
        require(chip.transferFrom(manager, msg.sender, msg.value * sE2C.reward)); // reward!!
        
        // ranking
        for(uint i=0;i<5;i++) {
            if(sE2C.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sE2C.ranking.amount[j] = sE2C.ranking.amount[j-1];
                    sE2C.ranking.date[j] = sE2C.ranking.date[j-1];
                    sE2C.ranking.account[j] = sE2C.ranking.account[j-1];
                }
                sE2C.ranking.amount[i] = amountWon;
                sE2C.ranking.date[i] = now;
                sE2C.ranking.account[i] = msg.sender;
                break;
            }
        }
        // latest
        for(i=4;i>0;i--) {
            sE2C.latest.amount[i] = sE2C.latest.amount[i-1];
            sE2C.latest.date[i] = sE2C.latest.date[i-1];
            sE2C.latest.account[i] = sE2C.latest.account[i-1];
        }
        sE2C.latest.amount[0] = amountWon;
        sE2C.latest.date[0] = now;
        sE2C.latest.account[0] = msg.sender;

        emit Won(amountWon > (msg.value * E2C_Ratio), "CHIP", amountWon);//, sE2C.ranking, sE2C.latest);
    }

    // function for owner to check contract balance
    function checkContractBalance() onlyOwner public view returns(uint) {
        return address(this).balance;
    }
    function checkContractBalanceToka() onlyOwner public view returns(uint) {
        return token.balanceOf(manager);
    }
    function checkContractBalanceChip() onlyOwner public view returns(uint) {
        return chip.balanceOf(manager);
    }
}