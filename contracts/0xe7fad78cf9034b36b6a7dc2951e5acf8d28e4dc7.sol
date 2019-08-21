pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
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

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract CryptoAngelConstants {

  string constant TOKEN_NAME = "CryptoAngel";
  string constant TOKEN_SYMBOL = "ANGEL";
  uint constant TOKEN_DECIMALS = 18;
  uint8 constant TOKEN_DECIMALS_UINT8 = uint8(TOKEN_DECIMALS);
  uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

  uint constant TEAM_TOKENS =   18000000 * TOKEN_DECIMAL_MULTIPLIER;
  uint constant HARD_CAP_TOKENS =   88000000 * TOKEN_DECIMAL_MULTIPLIER;
  uint constant MINIMAL_PURCHASE = 0.05 ether;
  uint constant RATE = 1000; // 1ETH = 1000ANGEL

  address constant TEAM_ADDRESS = 0x6941A0FD30198c70b3872D4d1b808e4bFc5A07E1;
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
    require(_value > 0);
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
      require(_value > 0);
      require(_value <= balances[msg.sender]);
      // no need to require value <= totalSupply, since that would imply the
      // sender's balance is greater than the totalSupply, which *should* be an assertion failure

      address burner = msg.sender;
      balances[burner] = balances[burner].sub(_value);
      totalSupply = totalSupply.sub(_value);
      Burn(burner, _value);
  }

  /**
   * @dev Burn tokens from the specified address.
   * @param _from address The address which you want to burn tokens from.
   * @param _value uint The amount of tokens to be burned.
   */
  function burnFrom(address _from, uint256 _value) public returns (bool) {
      require(_value > 0);
      var allowance = allowed[_from][msg.sender];
      require(allowance >= _value);
      balances[_from] = balances[_from].sub(_value);
      totalSupply = totalSupply.sub(_value);
      allowed[_from][msg.sender] = allowance.sub(_value);
      Burn(_from, _value);
      return true;
  }
}


contract CryptoAngel is CryptoAngelConstants, MintableToken, BurnableToken {

  mapping (address => bool) public frozenAccount;

  event FrozenFunds(address target, bool frozen);

  /**
   * @param target Address to be frozen
   * @param freeze either to freeze it or not
   */
  function freezeAccount(address target, bool freeze) public onlyOwner {
      frozenAccount[target] = freeze;
      FrozenFunds(target, freeze);
  }
    
  /**
   * @dev Returns token's name.
   */
  function name() pure public returns (string _name) {
      return TOKEN_NAME;
  }

  /**
   * @dev Returns token's symbol.
   */
  function symbol() pure public returns (string _symbol) {
      return TOKEN_SYMBOL;
  }

  /**
   * @dev Returns number of decimals.
   */
  function decimals() pure public returns (uint8 _decimals) {
      return TOKEN_DECIMALS_UINT8;
  }

  /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
  */
    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(!frozenAccount[_to]);
        super.mint(_to, _amount);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[msg.sender]);
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        return super.transferFrom(_from, _to, _value);
    }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale is CryptoAngelConstants{
  using SafeMath for uint256;

  // The token being sold
  CryptoAngel public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  // maximum amount of tokens to mint.
  uint public hardCap;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    hardCap = HARD_CAP_TOKENS;
    wallet = _wallet;
    rate = RATE;
  }

  // creates the token to be sold.
  function createTokenContract() internal returns (CryptoAngel) {
    return new CryptoAngel();
  }

  // fallback function can be used to buy tokens
  function() public payable {
    buyTokens(msg.sender, msg.value);
  }

  // low level token purchase function
  function buyTokens(address beneficiary, uint256 weiAmount) internal {
    require(beneficiary != address(0));
    require(validPurchase(weiAmount, token.totalSupply()));

    // calculate token amount to be created
    uint256 tokens = calculateTokens(token.totalSupply(), weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds(weiAmount);
  }

  // @return number of tokens which should be created
  function calculateTokens(uint256 totalTokens, uint256 weiAmount) internal view returns (uint256) {

    uint256 numOfTokens = weiAmount.mul(RATE);

    if (totalTokens <= hardCap.mul(30).div(100)) { // first 30% of available tokens
        numOfTokens += numOfTokens.mul(30).div(100);
    }
    else if (totalTokens <= hardCap.mul(45).div(100)) { // 30-45% of available tokens
        numOfTokens += numOfTokens.mul(20).div(100);
    }
    else if (totalTokens <= hardCap.mul(60).div(100)) { // 45-60% of available tokens
        numOfTokens += numOfTokens.mul(10).div(100);
    }  
   return numOfTokens;
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds(uint amountWei) internal {
    wallet.transfer(amountWei);
  }

  // @return true if the transaction can buy tokens
  function validPurchase(uint _amountWei, uint _totalSupply) internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonMinimalPurchase = _amountWei >= MINIMAL_PURCHASE;
    bool hardCapNotReached = _totalSupply <= hardCap;
    return withinPeriod && nonMinimalPurchase && hardCapNotReached;
  }

  // @return true if crowdsale event has ended
  function hasEnded() internal view returns (bool) {
    return now > endTime;
  }
}


/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  function FinalizableCrowdsale(uint _startTime, uint _endTime, address _wallet) public
            Crowdsale(_startTime, _endTime, _wallet) {
    }

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());
    isFinalized = true;
    token.finishMinting();
    token.transferOwnership(owner);
    Finalized();
  }

  modifier notFinalized() {
    require(!isFinalized);
    _;
  }
}


contract CryptoAngelCrowdsale is CryptoAngelConstants, FinalizableCrowdsale {

    function CryptoAngelCrowdsale(
            uint _startTime,
            uint _endTime,
            address _wallet
    ) public
        FinalizableCrowdsale(_startTime, _endTime, _wallet) {
        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
    }

  /**
   * @dev Allows the current owner to set the new start time if crowdsale is not finalized.
   * @param _startTime new end time.
   */
    function setStartTime(uint256 _startTime) public onlyOwner notFinalized {
        require(_startTime < endTime);
        startTime = _startTime;
    }

  /**
   * @dev Allows the current owner to set the new end time if crowdsale is not finalized.
   * @param _endTime new end time.
   */
    function setEndTime(uint256 _endTime) public onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = _endTime;
    }

  /**
   * @dev Allows the current owner to change the hard cap if crowdsale is not finalized.
   * @param _hardCapTokens new hard cap.
   */
    function setHardCap(uint256 _hardCapTokens) public onlyOwner notFinalized {
        require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > hardCap);
        hardCap = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    }
}