pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
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
  function Ownable() public {
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
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;
    
  mapping (address => uint256) balances;
  uint256 totalSupply_;
  mapping (address => uint256) public threeMonVesting;
  mapping (address => uint256) public bonusVesting;
  uint256 public launchBlock = 999999999999999999999999999999;
  uint256 constant public monthSeconds = 2592000;
  uint256 constant public secsPerBlock = 15; // 1 block per 15 seconds
  bool public launch = false;
  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  modifier afterLaunch() {
    require(block.number >= launchBlock || msg.sender == owner);
    _;
  }
  
  function checkVesting(address sender) public view returns (uint256) {
      if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(6))) {
          return balances[sender];
      } else if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(3))) {
          return balances[sender].sub(bonusVesting[sender]);
      } else {
          return balances[sender].sub(threeMonVesting[sender]).sub(bonusVesting[sender]);
      }
  }
  
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) afterLaunch public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(_value <= checkVesting(msg.sender));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) afterLaunch public {
    require(_value <= balances[msg.sender]);
    require(_value <= checkVesting(msg.sender));
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) afterLaunch public returns (bool) {
    
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_value <= checkVesting(_from));

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
}

contract InstaToken is StandardToken {

  string constant public name = "INSTA";
  string constant public symbol = "INSTA";
  uint256 constant public decimals = 18;

  address constant public partnersWallet = 0x4092678e4E78230F46A1534C0fbc8fA39780892B; // change
  uint256 public partnersPart = uint256(200000000).mul(10 ** decimals); // 20
  
  address constant public foundersWallet = 0x6748F50f686bfbcA6Fe8ad62b22228b87F31ff2b; // change
  uint256 public foundersPart = uint256(200000000).mul(10 ** decimals); // 20
  
  address constant public treasuryWallet = 0xEa11755Ae41D889CeEc39A63E6FF75a02Bc1C00d; // change
  uint256 public treasuryPart = uint256(150000000).mul(10 ** decimals); // 15
  
  uint256 public salePart = uint256(400000000).mul(10 ** decimals); // 40
  
  address constant public devWallet = 0x39Bb259F66E1C59d5ABEF88375979b4D20D98022; // change
  uint256 public devPart = uint256(50000000).mul(10 ** decimals); // 5

  uint256 public INITIAL_SUPPLY = uint256(1000000000).mul(10 ** decimals); // 1 000 000 000 tokens
    
  uint256 public foundersWithdrawTokens = 0;
  uint256 public partnersWithdrawTokens = 0;
  
  bool public oneTry = true;

  function setup() external {
    require(address(msg.sender) == owner);
    require(oneTry);

    totalSupply_ = INITIAL_SUPPLY;

    balances[msg.sender] = salePart;
    emit Transfer(this, msg.sender, salePart);
    
    balances[devWallet] = devPart;
    emit Transfer(this, devWallet, devPart);
    
    balances[treasuryWallet] = treasuryPart;
    emit Transfer(this, treasuryWallet, treasuryPart);
    
    balances[address(this)] = INITIAL_SUPPLY.sub(treasuryPart.add(devPart).add(salePart));
    emit Transfer(this, treasuryWallet, treasuryPart);
    
    oneTry = false;
  }
  
  function setLaunchBlock() public onlyOwner {
    require(!launch);
    launchBlock = block.number.add(monthSeconds.div(secsPerBlock).div(2));
    launch = true;
  }
  
  modifier onlyFounders() {
    require(msg.sender == foundersWallet);
    _;
  }
  
  modifier onlyPartners() {
    require(msg.sender == partnersWallet);
    _;
  }
  
  function viewFoundersTokens() public view returns (uint256) {
    if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(9))) {
      return 200000000;
    } else if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(6))) {
      return 140000000;
    } else if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(3))) {
      return 80000000;
    } else if (block.number >= launchBlock) {
      return 20000000;
    }
  }
  
  function viewPartnersTokens() public view returns (uint256) {
    if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(9))) {
      return 200000000;
    } else if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(6))) {
      return 140000000;
    } else if (block.number >= launchBlock.add(monthSeconds.div(secsPerBlock).mul(3))) {
      return 80000000;
    } else if (block.number >= launchBlock) {
      return 20000000;
    }
  }
  
  function getFoundersTokens(uint256 _tokens) public onlyFounders {
    uint256 tokens = _tokens.mul(10 ** decimals);
    require(foundersWithdrawTokens.add(tokens) <= viewFoundersTokens().mul(10 ** decimals));
    transfer(foundersWallet, tokens);
    emit Transfer(this, foundersWallet, tokens);
    foundersWithdrawTokens = foundersWithdrawTokens.add(tokens);
  }
  
  function getPartnersTokens(uint256 _tokens) public onlyPartners {
    uint256 tokens = _tokens.mul(10 ** decimals);
    require(partnersWithdrawTokens.add(tokens) <= viewPartnersTokens().mul(10 ** decimals));
    transfer(partnersWallet, tokens);
    emit Transfer(this, partnersWallet, tokens);
    partnersWithdrawTokens = partnersWithdrawTokens.add(tokens);
  }

  function addBonusTokens(address sender, uint256 amount) external onlyOwner {
      bonusVesting[sender] = bonusVesting[sender].add(amount);
  }
  
  function freezeTokens(address sender, uint256 amount) external onlyOwner {
      threeMonVesting[sender] = threeMonVesting[sender].add(amount);
  }
}