pragma solidity ^0.4.18;

// File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: node_modules/zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: node_modules/zeppelin-solidity/contracts/token/BasicToken.sol

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

// File: node_modules/zeppelin-solidity/contracts/token/ERC20.sol

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

// File: node_modules/zeppelin-solidity/contracts/token/StandardToken.sol

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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

// File: node_modules/zeppelin-solidity/contracts/token/MintableToken.sol

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

// File: node_modules/zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}

// File: node_modules/zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}

// File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: contracts/KeyrptoToken.sol

contract KeyrptoToken is MintableToken, Pausable {
  string public constant name = "Keyrpto Token";
  string public constant symbol = "KYT";
  uint8 public constant decimals = 18;
  uint256 internal constant MILLION_TOKENS = 1e6 * 1e18;

  address public teamWallet;
  bool public teamTokensMinted = false;
  uint256 public circulationStartTime;

  event Burn(address indexed burnedFrom, uint256 value);

  function KeyrptoToken() public {
    paused = true;
  }

  function setTeamWallet(address _teamWallet) public onlyOwner canMint {
    require(teamWallet == address(0));
    require(_teamWallet != address(0));

    teamWallet = _teamWallet;
  }

  function mintTeamTokens(uint256 _extraTokensMintedDuringPresale) public onlyOwner canMint {
    require(!teamTokensMinted);

    teamTokensMinted = true;
    mint(teamWallet, (490 * MILLION_TOKENS).sub(_extraTokensMintedDuringPresale));
  }

  /*
   * @overrides Pausable#unpause
   * Change: store the time when it was first unpaused
   */
  function unpause() onlyOwner whenPaused public {
    if (circulationStartTime == 0) {
      circulationStartTime = now;
    }

    super.unpause();
  }

  /*
   * @overrides BasicToken#transfer
   * Changes:
   * - added whenNotPaused modifier
   * - added validation that teamWallet balance must not fall below amount of locked tokens
   */
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(validTransfer(msg.sender, _value));
    return super.transfer(_to, _value);
  }

  /*
   * @overrides StandardToken#transferFrom
   * Changes:
   * - added whenNotPaused modifier
   * - added validation that teamWallet balance must not fall below amount of locked tokens
   */
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(validTransfer(_from, _value));
    return super.transferFrom(_from, _to, _value);
  }

  function validTransfer(address _from, uint256 _amount) internal view returns (bool) {
    if (_from != teamWallet) {
      return true;
    }

    uint256 balanceAfterTransfer = balanceOf(_from).sub(_amount);
    return balanceAfterTransfer >= minimumTeamWalletBalance();
  }

  /*
   * 100M tokens in teamWallet are locked for 6 months
   * 200M tokens in teamWallet are locked for 12 months
   */
  function minimumTeamWalletBalance() internal view returns (uint256) {
    if (now < circulationStartTime + 26 weeks) {
      return 300 * MILLION_TOKENS;
    } else if (now < circulationStartTime + 1 years) {
      return 200 * MILLION_TOKENS;
    } else {
      return 0;
    }
  }

  /*
   * Copy of BurnableToken#burn
   * Changes:
   * - only allow owner to burn tokens and burn from given address, not msg.sender
   */
  function burn(address _from, uint256 _value) external onlyOwner {
    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_from, _value);
  }
}

// File: contracts/KeyrptoCrowdsale.sol

contract KeyrptoCrowdsale is FinalizableCrowdsale {
  uint256 internal constant ONE_TOKEN = 1e18;
  uint256 internal constant MILLION_TOKENS = 1e6 * ONE_TOKEN;
  uint256 internal constant PRESALE_TOKEN_CAP = 62500000 * ONE_TOKEN;
  uint256 internal constant MAIN_SALE_TOKEN_CAP = 510 * MILLION_TOKENS;
  uint256 internal constant MINIMUM_CONTRIBUTION_IN_WEI = 100 finney;

  mapping (address => bool) public whitelist;

  uint256 public mainStartTime;
  uint256 public extraTokensMintedDuringPresale;

  function KeyrptoCrowdsale(
                  uint256 _startTime,
                  uint256 _mainStartTime,
                  uint256 _endTime,
                  uint256 _rate,
                  address _wallet) public
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    require(_startTime < _mainStartTime && _mainStartTime < _endTime);

    mainStartTime = _mainStartTime;

    KeyrptoToken(token).setTeamWallet(_wallet);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new KeyrptoToken();
  }

  /*
   * Disable fallback function
   */
  function() external payable {
    revert();
  }

  function updateRate(uint256 _rate) external onlyOwner {
    require(_rate > 0);
    require(now < endTime);

    rate = _rate;
  }

  function whitelist(address _address) external onlyOwner {
    whitelist[_address] = true;
  }

  function blacklist(address _address) external onlyOwner {
    delete whitelist[_address];
  }

  /*
   * @overrides Crowdsale#buyTokens
   * Changes:
   * - Pass number of tokens to be created and beneficiary for purchase validation
   * - After presale has ended, record number of extra tokens minted during presale
   */
  function buyTokens(address _beneficiary) public payable {
    require(_beneficiary != address(0));

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(getRate());

    require(validPurchase(tokens, _beneficiary));

    if(!presale()) {
      setExtraTokensMintedDuringPresaleIfNotYetSet();
    }

    if (extraTokensMintedDuringPresale == 0 && !presale()) {
      extraTokensMintedDuringPresale = token.totalSupply() / 5;
    }

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  /*
   * @overrides Crowdsale#validPurchase
   * Changes:
   * - Added restriction to sell only to whitelisted addresses
   * - Added minimum purchase amount of 0.1 ETH
   * - Added presale restriction: max contribution of 20 ETH per address
   * - Added presale restriction: max total supply of 62.5M KYT
   */
  function validPurchase(uint256 _tokens, address _beneficiary) internal view returns (bool) {
    uint256 totalSupplyAfterTransaction = token.totalSupply() + _tokens;

    if (presale()) {
      bool withinPerAddressLimit = (token.balanceOf(_beneficiary) + _tokens) <= getRate().mul(20 ether);
      bool withinTotalSupplyLimit = totalSupplyAfterTransaction <= PRESALE_TOKEN_CAP;
      if (!withinPerAddressLimit || !withinTotalSupplyLimit) {
        return false;
      }
    }

    bool aboveMinContribution = msg.value >= MINIMUM_CONTRIBUTION_IN_WEI;
    bool whitelistedSender = whitelisted(msg.sender);
    bool withinCap = totalSupplyAfterTransaction <= tokenSupplyCap();
    return aboveMinContribution && whitelistedSender && withinCap && super.validPurchase();
  }

  function whitelisted(address _address) public view returns (bool) {
    return whitelist[_address];
  }

  function getRate() internal view returns (uint256) {
    return presale() ? rate.mul(5).div(4) : rate;
  }

  function presale() internal view returns (bool) {
    return now < mainStartTime;
  }

  /*
   * @overrides Crowdsale#hasEnded
   * Changes:
   * - Added token cap logic based on token supply
   */
  function hasEnded() public view returns (bool) {
    bool capReached = token.totalSupply() >= tokenSupplyCap();
    return capReached || super.hasEnded();
  }

  function tokenSupplyCap() public view returns (uint256) {
    return MAIN_SALE_TOKEN_CAP + extraTokensMintedDuringPresale;
  }

  function finalization() internal {
    setExtraTokensMintedDuringPresaleIfNotYetSet();

    KeyrptoToken(token).mintTeamTokens(extraTokensMintedDuringPresale);
    token.finishMinting();
    token.transferOwnership(wallet);
  }

  function setExtraTokensMintedDuringPresaleIfNotYetSet() internal {
    if (extraTokensMintedDuringPresale == 0) {
      extraTokensMintedDuringPresale = token.totalSupply() / 5;
    }
  }

  function hasPresaleEnded() external view returns (bool) {
    if (!presale()) {
      return true;
    }

    uint256 minPurchaseInTokens = MINIMUM_CONTRIBUTION_IN_WEI.mul(getRate());
    return token.totalSupply() + minPurchaseInTokens > PRESALE_TOKEN_CAP;
  }
}