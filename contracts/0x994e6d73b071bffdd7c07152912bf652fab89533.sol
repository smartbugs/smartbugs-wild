pragma solidity ^0.4.15;



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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
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
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
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
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
 * @title PreSale ZNA token
 * @dev The minting functionality is reimplemented, as opposed to inherited
 *   from MintableToken, to allow for giving right to mint to arbitery account.
 */
contract PreSaleZNA is StandardToken, Ownable, Pausable {

  // Disable transfer unless explicitly enabled
  function PreSaleZNA(){ paused = true; }

  // The address of the contract or user that is allowed to mint tokens.
  address public minter;

  /**
   * @dev Set the address of the minter
   * @param _minter address to be set as minter.
   *
   * Note: We also need to implement "mint" method.
   */
  function setMinter(address _minter) onlyOwner {
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
  function transfer(address _to, uint256 _value)
  public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value)
  public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }


  /**
   * @dev Token meta-information
   * @param name of the token as it's shown to user
   * @param symbol of the token
   * @param decimals number
   * Number of indivisible tokens that make up 1 ZNA = 10^{decimals}
   */
  string public constant name = "Presale ZNA Token";
  string public constant symbol = "pZNA";
  uint8  public constant decimals = 18;
}


/**
 * @title Zenome Crowdsale contract
 * @dev Govern the presale:
 *   1) Taking place in a specific limited period of time.
 *   2) Having HARDCAP value set --- a number of sold tokens to end the pre-sale
 *
 * Owner can change time parameters at any time --- just in case of emergency
 * Owner can change minter at any time --- just in case of emergency
 *
 * !!! There is no way to change the address of the wallet !!!
 */
contract ZenomeCrowdSale is Ownable {

    // Use SafeMath library to provide methods for uint256-type vars.
    using SafeMath for uint256;

    // The hardcoded address of wallet
    address public wallet;

    // The address of presale token
    PreSaleZNA public token;// = new PreSaleZNA();

    // The accounting mapping to store information on the amount of
    // bonus tokens that should be given in case of successful presale.
    mapping(address => uint256) bonuses;

    /**
     * @dev Variables
     *
     * @public START_TIME uint the time of the start of the sale
     * @public CLOSE_TIME uint the time of the end of the sale
     * @public HARDCAP uint256 if @HARDCAP is reached, presale stops
     * @public the amount of indivisible quantities (=10^18 ZBA) given for 1 wie
     */
    uint public START_TIME = 1508256000;
    uint public CLOSE_TIME = 1508860800;
    uint256 public HARDCAP = 3200000000000000000000000;
    uint256 public exchangeRate = 966;


    /**
     * Fallback function
     * @dev The contracts are prevented from using fallback function.
     *   That prevents loosing control of tokens that will eventually get
     *      attributed to the contract, not the user
     *   To buy tokens from the wallet (that is a contract)
     *      user has to specify beneficiary of tokens using buyTokens method.
     */
    function () payable {
      require(msg.sender == tx.origin);
      buyTokens(msg.sender);
    }

    /**
     * @dev A function to withdraw all funds.
     *   Normally, contract should not have ether at all.
     */
    function withdraw() onlyOwner {
      wallet.transfer(this.balance);
    }

    /**
     * @dev The constructor sets the tokens address
     * @param _token address
     */
    function ZenomeCrowdSale(address _token, address _wallet) {
      token  = PreSaleZNA(_token);
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
     * event for bonus processing logging
     * @param beneficiary a user to get bonuses
     * @param amount bonus tokens given
     */
    event TokenBonusGiven(
      address indexed beneficiary,
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
     * @dev Sets exhange rate, ie amount of tokens (10^{-18}ZNA) for 1 wie.
     * @param _exchangeRate uint256 new exhange rate.
     */
    function setExchangeRate(uint256 _exchangeRate) public onlyOwner  {
      require(now < START_TIME);
      exchangeRate = _exchangeRate;
    }


    /**
     * @dev Buy tokens for all sent ether.
     *      Tokens will be added to beneficiary's account
     * @param beneficiary address the owner of bought tokens.
     */
    function buyTokens(address beneficiary) payable {

      uint256 total = token.totalSupply();
      uint256 amount = msg.value;
      require(amount > 0);

      // Check that hardcap not reached, and sale-time.
      require(total < HARDCAP);
      require(now >= START_TIME);
      require(now <  CLOSE_TIME);

      // Mint tokens bought for all sent ether to beneficiary
      uint256 tokens = amount.mul(exchangeRate);
      token.mint(beneficiary, tokens);
      TokenPurchase(msg.sender, beneficiary,amount, tokens);

      // Calcualate the corresponding bonus tokens,
      //  that can be given in case of successful pre-sale
      uint256 _bonus = tokens.div(4);
      bonuses[beneficiary] = bonuses[beneficiary].add(_bonus);

      // Finally, sent all the money to wallet
      wallet.transfer(amount);
    }


    /**
     * @dev Process bonus tokens for beneficiary in case of all tokens sold.
     * @param beneficiary address the user's address to process.
     *
     * Everyone can call this method for any beneficiary:
     *  1) Method (code) does not depend on msg.sender =>
     *         => side effects don't depend on the caller
     *  2) Calling method for beneficiary is either positive or neutral.
     */
    function transferBonuses(address beneficiary) {
      // Checks that sale has successfully ended by having all tokens sold.
      uint256 total = token.totalSupply();
      require( total >= HARDCAP );

      // Since the number of bonus tokens that are intended for beneficiary
      //    was pre-calculated beforehand, set variable "tokens" to this value.
      uint256 tokens = bonuses[beneficiary];
      // Chech if there are tokens to give as bonuses
      require( tokens > 0 );

      // If so, make changes the accounting mapping. Then mint bonus tokens
      bonuses[beneficiary] = 0;
      token.mint(beneficiary, tokens);

      // After all, log event.
      TokenBonusGiven(beneficiary, tokens);
    }
}