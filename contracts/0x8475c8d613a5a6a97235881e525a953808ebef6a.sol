pragma solidity ^0.4.24;
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
  constructor() internal {
    _addPauser(msg.sender);
  }
  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }
  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }
  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }
  function renouncePauser() public {
    _removePauser(msg.sender);
  }
  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }
  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}
contract CapperRole {
  using Roles for Roles.Role;
  event CapperAdded(address indexed account);
  event CapperRemoved(address indexed account);
  Roles.Role private cappers;
  constructor() internal {
    _addCapper(msg.sender);
  }
  modifier onlyCapper() {
    require(isCapper(msg.sender));
    _;
  }
  function isCapper(address account) public view returns (bool) {
    return cappers.has(account);
  }
  function addCapper(address account) public onlyCapper {
    _addCapper(account);
  }
  function renounceCapper() public {
    _removeCapper(msg.sender);
  }
  function _addCapper(address account) internal {
    cappers.add(account);
    emit CapperAdded(account);
  }
  function _removeCapper(address account) internal {
    cappers.remove(account);
    emit CapperRemoved(account);
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
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
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
contract ERC20 is IERC20, MinterRole {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping(address => bool) mastercardUsers;
  mapping(address => bool) SGCUsers;
  bool public walletLock;
  bool public publicLock;
  uint256 private _totalSupply;
  /**
  * @dev Total number of coins in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  /**
  * @dev Total number of coins in existence
  */
  function walletLock() public view returns (bool) {
    return walletLock;
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
   * @dev Function to check the amount of coins that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of coins still available for the spender.
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
  * @dev Transfer coin for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }
  /**
   * @dev Approve the passed address to spend the specified amount of coins on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of coins to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    value = SafeMath.mul(value,1 ether);
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  /**
   * @dev Transfer coins from one address to another
   * @param from address The address which you want to send coins from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of coins to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    value = SafeMath.mul(value, 1 ether);
    
    require(value <= _allowed[from][msg.sender]);
    require(value <= _balances[from]);
    require(to != address(0));
    require(value > 0);
    require(!mastercardUsers[from]);
    require(!walletLock);
    
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    if(publicLock){
        require(
            SGCUsers[from]
            && SGCUsers[to]
        );
        _balances[from] = _balances[from].sub(value); 
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    else{
        _balances[from] = _balances[from].sub(value); 
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    return true;
  }
  /**
   * @dev Increase the amount of coins that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO coin.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of coins to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));
    addedValue = SafeMath.mul(addedValue, 1 ether);
    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  /**
   * @dev Decrease the amount of coins that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO coin.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of coins to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));
    subtractedValue = SafeMath.mul(subtractedValue, 1 ether);
    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  /**
  * @dev Transfer coin for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));
    require(value > 0);
    require(!mastercardUsers[from]);
    if(publicLock && !walletLock){
        require(
           SGCUsers[from]
            && SGCUsers[to]
        );
    }
    if(isMinter(from)){
          _addSGCUsers(to);
          _balances[from] = _balances[from].sub(value); 
          _balances[to] = _balances[to].add(value);
          emit Transfer(from, to, value);
    }
    else{
      require(!walletLock);
      _balances[from] = _balances[from].sub(value); 
      _balances[to] = _balances[to].add(value);
      emit Transfer(from, to, value);
    }
  }
  /**
   * @dev Internal function that mints an amount of the coin and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created coins.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }
  /**
   * @dev Internal function that burns an amount of the coin of a given
   * account.
   * @param account The account whose coins will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    value = SafeMath.mul(value,1 ether);
    require(account != 0);
    require(value <= _balances[account]);
    
    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }
  /**
   * @dev Internal function that burns an amount of the coin of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose coins will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    value = SafeMath.mul(value,1 ether);
    require(value <= _allowed[account][msg.sender]);
    require(account != 0);
    require(value <= _balances[account]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
       
    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }
  function _addSGCUsers(address newAddress) onlyMinter public {
      if(!SGCUsers[newAddress]){
        SGCUsers[newAddress] = true;
      }
  }
  function getSGCUsers(address userAddress) public view returns (bool) {
    return SGCUsers[userAddress];
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
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);
  bool private _paused;
  constructor() internal {
    _paused = false;
  }
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
 * @title Burnable coin
 * @dev Coin that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20, Pausable {
  /**
   * @dev Burns a specific amount of coins.
   * @param value The amount of coin to be burned.
   */
  function burn(uint256 value) public whenNotPaused{
    _burn(msg.sender, value);
  }
  /**
   * @dev Burns a specific amount of coins from the target address and decrements allowance
   * @param from address The address which you want to send coins from
   * @param value uint256 The amount of coin to be burned
   */
  function burnFrom(address from, uint256 value) public whenNotPaused {
    _burnFrom(from, value);
  }
}
/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20 {
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
    function addMastercardUser(
    address user
  ) 
    public 
    onlyMinter 
  {
    mastercardUsers[user] = true;
  }
  function removeMastercardUser(
    address user
  ) 
    public 
    onlyMinter  
  {
    mastercardUsers[user] = false;
  }
  function updateWalletLock(
  ) 
    public 
    onlyMinter  
  {
    if(walletLock){
      walletLock = false;
    }
    else{
      walletLock = true;
    }
  }
    function updatePublicCheck(
  ) 
    public 
    onlyMinter  
  {
    if(publicLock){
      publicLock = false;
    }
    else{
      publicLock = true;
    }
  }
}
/**
 * @title Capped Coin
 * @dev Mintable Coin with a coin cap.
 */
contract ERC20Capped is ERC20Mintable, CapperRole {
  uint256 internal _latestCap;
  constructor(uint256 cap)
    public
  {
    require(cap > 0);
    _latestCap = cap;
  }
  /**
   * @return the cap for the coin minting.
   */
  function cap() public view returns(uint256) {
    return _latestCap;
  }
  function _updateCap (uint256 addCap) public onlyCapper {
    addCap = SafeMath.mul(addCap, 1 ether);   
    _latestCap = addCap; 
  }
  function _mint(address account, uint256 value) internal {
    value = SafeMath.mul(value, 1 ether);
    require(totalSupply().add(value) <= _latestCap);
    super._mint(account, value);
  }
}
/**
 * @title Pausable coin
 * @dev ERC20 modified with pausable transfers.
 **/
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
/**
 * @title SecuredGoldCoin
 * @dev 
 * -> SGC Coin is 60% Gold backed and 40% is utility coin
 * -> SGC per coin gold weight is 21.2784 Milligrams with certification of LBMA
 *    (London Bullion Market Association)
 * -> SGC Coin - Gold Description - 24 Caret - .9999 Purity - LMBA Certification
 * -> The price will be locked till 14 April 2019 - 2 Euro per coin
 * -> The merchants can start trading with all SGC users from 15 June 2019
 * -> The coin will be available for sale from 15 April 2019 on the basis of live price
 * -> Coins price can be live on the SGC users wallet from the day of activation
 *    of the wallet.
 * -> During private sale coins can be bought from VIVA Gold Packages
 * -> Coins will be available for public offer from November 2019
 * -> The coin will be listed on exchange by November 2019.
 * @author Junaid Mushtaq | Talha Yusuf
 */
contract SecuredGoldCoin is ERC20, ERC20Mintable, ERC20Detailed, ERC20Burnable, ERC20Pausable, ERC20Capped {
    string public name =  "Secured Gold Coin";
    string public symbol = "SGC";
    uint8 public decimals = 18;
    uint public intialCap = 1000000000 * 1 ether;
    constructor () public 
        ERC20Detailed(name, symbol, decimals)
        ERC20Mintable()
        ERC20Burnable()
        ERC20Pausable()
        ERC20Capped(intialCap)
        ERC20()
    {}
}