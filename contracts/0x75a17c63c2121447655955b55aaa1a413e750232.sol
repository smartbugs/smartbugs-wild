pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to
  * @param _value The amount to be transferred
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address
  * @param _owner The address to query the the balance of
  * @return An uint256 representing the amount owned by the passed address
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 The amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
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
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title Cryder token contract
 * @dev The minting functionality is reimplemented, as opposed to inherited
 * from MintableToken, to allow for giving right to mint to arbitery account.
 */
contract CryderToken is StandardToken, Ownable, Pausable {
  // Disable transfer unless explicitly enabled
  function CryderToken() public { paused = true; }

  // The address of the contract or user that is allowed to mint tokens.
  address public minter;
  
  /**
   * @dev Variables
   *
   * @public FREEZE_TIME uint the time when team tokens can be transfered
   * @public bounty the address of bounty manager 
  */
  uint public FREEZE_TIME = 1550682000;
  address public bounty = 0xa258Eb1817aA122acBa4Af66A7A064AE6E10552A;

  /**
   * @dev Set the address of the minter
   * @param _minter address to be set as minter.
   *
   * Note: We also need to implement "mint" method.
   */
  function setMinter(address _minter) public onlyOwner {
      minter = _minter;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public returns (bool) {
    require(msg.sender == minter);

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev account for paused/unpaused-state.
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    // Check for paused with an exception of bounty manager and freeze team tokens for 1 year
    require(msg.sender == bounty || (!paused && msg.sender != owner) || (!paused && msg.sender == owner && now > FREEZE_TIME));
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    // Check for paused with an exception of bounty manager and freeze team tokens for 1 year with an additional _from check
    require((msg.sender == bounty && _from == bounty) || (!paused && msg.sender != owner && _from != owner) || (!paused && msg.sender == owner && now > FREEZE_TIME));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Token meta-information
   * @param name of the token as it's shown to user
   * @param symbol of the token
   * @param decimals number
   * Number of indivisible tokens that make up 1 CRYDER = 10^{decimals}
   */
  string public constant name = "Cryder Token";
  string public constant symbol = "CRYDER";
  uint8  public constant decimals = 18;
}

/**
 * @title Cryder crowdsale contract
 * @dev Govern the sale:
 *   1) Taking place in a specific limited period of time.
 *   2) Having HARDCAP value set --- a number of sold tokens to end the sale
 *
 * Owner can change time parameters at any time --- just in case of emergency
 * Owner can change minter at any time --- just in case of emergency
 *
 * !!! There is no way to change the address of the wallet or bounty manager !!!
 */
contract CryderCrowdsale is Ownable {
    // Use SafeMath library to provide methods for uint256-type vars.
    using SafeMath for uint256;

    // The hardcoded address of wallet
    address public wallet;

    // The address of presale token
    CryderToken public presaleToken;
    
    // The address of sale token
    CryderToken public token;
    
    // Bounty must be allocated only once
    bool public isBountyAllocated = false;
    
    // Requested tokens array
    mapping(address => bool) tokenRequests;

    /**
     * @dev Variables
     *
     * @public START_TIME uint the time of the start of the sale
     * @public CLOSE_TIME uint the time of the end of the sale
     * @public HARDCAP uint256 if @HARDCAP is reached, sale stops
     * @public exchangeRate the amount of indivisible quantities (=10^18 CRYDER) given for 1 wei
     * @public bounty the address of bounty manager 
     */
    uint public START_TIME = 1516467600;
    uint public CLOSE_TIME = 1519146000;
    uint256 public HARDCAP = 400000000000000000000000000;
    uint256 public exchangeRate = 3000;
    address public bounty = 0xa258Eb1817aA122acBa4Af66A7A064AE6E10552A;

    /**
     * Fallback function
     * @dev The contracts are prevented from using fallback function.
     * That prevents loosing control of tokens that will eventually get attributed to the contract, not the user.
     * To buy tokens from the wallet (that is a contract) user has to specify beneficiary of tokens using buyTokens method.
     */
    function () payable public {
      require(msg.sender == tx.origin);
      buyTokens(msg.sender);
    }

    /**
     * @dev A function to withdraw all funds.
     * Normally, contract should not have ether at all.
     */
    function withdraw() onlyOwner public {
      wallet.transfer(this.balance);
    }

    /**
     * @dev The constructor sets the tokens address
     * @param _token address
     */
    function CryderCrowdsale(address _presaleToken, address _token, address _wallet) public {
      presaleToken = CryderToken(_presaleToken);
      token  = CryderToken(_token);
      wallet = _wallet;
    }

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
      address indexed purchaser,
      address indexed beneficiary,
      uint256 value,
      uint256 amount
    );

    /**
     * @dev Sets the start and end of the sale.
     * @param _start uint256 start of the sale.
     * @param _close uint256 end of the sale.
     */
    function setTime(uint _start, uint _close) public onlyOwner {
      require( _start < _close );
      START_TIME = _start;
      CLOSE_TIME = _close;
    }

    /**
     * @dev Sets exhange rate, ie amount of tokens (10^18 CRYDER) for 1 wei.
     * @param _exchangeRate uint256 new exhange rate.
     */
    function setExchangeRate(uint256 _exchangeRate) public onlyOwner  {
      require(now < START_TIME);
      exchangeRate = _exchangeRate;
    }

    /**
     * @dev Buy tokens for all sent ether. Tokens will be added to beneficiary's account
     * @param beneficiary address the owner of bought tokens.
     */
    function buyTokens(address beneficiary) payable public {
      uint256 total = token.totalSupply();
      uint256 amount = msg.value;
      require(amount > 0);

      // Check that hardcap not reached, and sale-time.
      require(total < HARDCAP);
      require(now >= START_TIME);
      require(now < CLOSE_TIME);

      // Override exchange rate for daily bonuses
      if (now < START_TIME + 3600 * 24 * 1) {
          exchangeRate = 3900;
      } else if (now < START_TIME + 3600 * 24 * 3) {
          exchangeRate = 3750;
      } else if (now < START_TIME + 3600 * 24 * 5) {
          exchangeRate = 3600;
      } else {
          exchangeRate = 3000;
      }

      // Mint tokens bought for all sent ether to beneficiary
      uint256 tokens = amount.mul(exchangeRate);

      token.mint(beneficiary, tokens);
      TokenPurchase(msg.sender, beneficiary, amount, tokens);

      // Mint 8% tokens to wallet as a team part
      uint256 teamTokens = tokens / 100 * 8;
      token.mint(wallet, teamTokens);

      // Finally, sent all the money to wallet
      wallet.transfer(amount);
    }
    
    /**
     * @dev One time command to allocate 5kk bounty tokens
     */
     
     function allocateBounty() public returns (bool) {
         // Check for bounty manager and allocation state
         require(msg.sender == bounty && isBountyAllocated == false);
         // Mint bounty tokens to bounty managers address
         token.mint(bounty, 5000000000000000000000000);
         isBountyAllocated = true;
         return true;
     }
     
     function requestTokens() public returns (bool) {
         require(presaleToken.balanceOf(msg.sender) > 0 && tokenRequests[msg.sender] == false);
         token.mint(msg.sender, presaleToken.balanceOf(msg.sender));
         tokenRequests[msg.sender] = true;
         return true;
     }
}