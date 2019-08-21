pragma solidity >=0.4.22 <0.6.0;

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
    require(c / a == b); // will fail if overflow

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

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
    require(c >= a); // will fail if overflow because of wraparound

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
 * @dev The Ownable contract has an owner address, and provides basic
 * authorization control functions, this simplifies the implementation of
 * "user permissions".
 */
contract Ownable {
  using SafeMath for uint256;
  address public owner;
 
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));  // can't accidentally burn the entire contract
    owner = newOwner;
  }

  /**
   * @dev Allows the owner to withdraw the ether for conversion to USD to handle
   * tax credits properly.
   * Note: this function withdraws the entire balance of the contract!
   * @param destination The destination address to withdraw the funds to
   */
  function withdraw(address payable destination) public onlyOwner {
    require(destination != address(0));
    destination.transfer(address(this).balance);
  }

  /**
   * @dev Allows the owner to view the current balance of the contract to 6 decimal places
   */
  function getBalance() public view onlyOwner returns (uint256) {
    return address(this).balance.div(1 szabo);
  }

}

/**
 * @title Tokenization of tax credits
 *
 * @dev Implementation of a permissioned token.
 */
contract TaxCredit is Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;
  mapping (address => string) private emails;
  address[] addresses;
  uint256 public minimumPurchase = 1950 ether;  // minimum purchase is 300,000 credits (270,000 USD)
  uint256 private _totalSupply;
  uint256 private exchangeRate = (270000 ether / minimumPurchase) + 1;  // convert to credit tokens - account for integer division
  uint256 private discountRate = 1111111111111111111 wei;  // giving credits at 10% discount (90 * 1.11111 = 100)

  string public name = "Tax Credit Token";
  string public symbol = "TCT";
  uint public INITIAL_SUPPLY = 20000000;  // 20m credits reserved for use by Clean Energy Systems LLC

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Exchange(
    string indexed email,
    address indexed addr,
    uint256 value
  );

  constructor() public {
    mint(msg.sender, INITIAL_SUPPLY);
  }

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
    return balances[owner];
  }

  /**
   * @dev Transfer tokens from one address to another - since there are off-chain legal
   * transactions that must occur, this function can only be called by the owner; any
   * entity that wants to transfer tax credit tokens must go through the contract owner in order
   * to get legal documents dispersed first
   * @param from address The address to send tokens from
   * @param to address The address to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address from, address to, uint256 value) public onlyOwner {
    require(value <= balances[from]);

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Public function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted. Only the owner of the contract can mint tokens at will.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function mint(address account, uint256 value) public onlyOwner {
    _handleMint(account, value);
  }

  /**
   * @dev Internal function that handles and executes the minting of tokens. This
   * function exists because there are times when tokens may need to be minted,
   * but not by the owner of the contract (namely, when participants exchange their
   * ether for tokens).
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _handleMint(address account, uint256 value) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(value);
    balances[account] = balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function burn(address account, uint256 value) public onlyOwner {
    require(account != address(0));
    require(value <= balances[account]);

    _totalSupply = _totalSupply.sub(value);
    balances[account] = balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Allows entities to exchange their Ethereum for tokens representing
   * their tax credits. This function mints new tax credit tokens that are backed
   * by the ethereum sent to exchange for them.
   */
  function exchange(string memory email) public payable {
    require(msg.value > minimumPurchase);
    require(keccak256(bytes(email)) != keccak256(bytes("")));  // require email parameter

    addresses.push(msg.sender);
    emails[msg.sender] = email;
    uint256 tokens = msg.value.mul(exchangeRate);
    tokens = tokens.mul(discountRate);
    tokens = tokens.div(1 ether).div(1 ether);  // offset exchange rate & discount rate multiplications
    _handleMint(msg.sender, tokens);
    emit Exchange(email, msg.sender, tokens);
  }

  /**
   * @dev Allows owner to change minimum purchase in order to keep minimum
   * tax credit exchange around a certain USD threshold
   * @param newMinimum The new minimum amount of ether required to purchase tax credit tokens
   */
  function changeMinimumExchange(uint256 newMinimum) public onlyOwner {
    require(newMinimum > 0);  // if minimum is 0 then division errors will occur for exchange and discount rates
    minimumPurchase = newMinimum * 1 ether;
    exchangeRate = 270000 ether / minimumPurchase;
  }

  /**
   * @dev Return a list of all participants in the contract by address
   */
  function getAllAddresses() public view returns (address[] memory) {
    return addresses;
  }

  /**
   * @dev Return the email of a participant by Ethereum address
   * @param addr The address from which to retrieve the email
   */
  function getParticipantEmail(address addr) public view returns (string memory) {
    return emails[addr];
  }

  /*
   * @dev Return all addresses belonging to a certain email (it is possible that an
   * entity may purchase tax credit tokens multiple times with different Ethereum addresses).
   * 
   * NOTE: This transaction may incur a significant gas cost as more participants purchase credits.
   */
  function getAllAddresses(string memory email) public view onlyOwner returns (address[] memory) {
    address[] memory all = new address[](addresses.length);
    for (uint32 i = 0; i < addresses.length; i++) {
      if (keccak256(bytes(emails[addresses[i]])) == keccak256(bytes(email))) {
        all[i] = addresses[i];
      }
    }
    return all;
  }

}