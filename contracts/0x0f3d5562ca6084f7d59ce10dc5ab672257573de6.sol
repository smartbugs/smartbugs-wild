pragma solidity 0.4.15;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/Authorizable.sol

contract Authorizable is Ownable {
    event LogAccess(address authAddress);
    event Grant(address authAddress, bool grant);

    mapping(address => bool) public auth;

    modifier authorized() {
        LogAccess(msg.sender);
        require(auth[msg.sender]);
        _;
    }

    function authorize(address _address) onlyOwner public {
        Grant(_address, true);
        auth[_address] = true;
    }

    function unauthorize(address _address) onlyOwner public {
        Grant(_address, false);
        auth[_address] = false;
    }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/BasicToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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

// File: zeppelin-solidity/contracts/token/MintableToken.sol

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

// File: contracts/TutellusToken.sol

/**
 * @title Tutellus Token
 * @author Javier Ortiz
 *
 * @dev ERC20 Tutellus Token (TUT)
 */
contract TutellusToken is MintableToken {
   string public name = "Tutellus";
   string public symbol = "TUT";
   uint8 public decimals = 18;
}

// File: contracts/TutellusLockerVault.sol

contract TutellusLockerVault is Authorizable {
    event Deposit(address indexed _address, uint256 _amount);
    event Verify(address indexed _address);
    event Release(address indexed _address);

    uint256 releaseTime;
    TutellusToken token;

    mapping(address => uint256) public amounts;
    mapping(address => bool) public verified;

    function TutellusLockerVault(
        uint256 _releaseTime, 
        address _token
    ) public 
    {
        require(_releaseTime > now);
        require(_token != address(0));
        
        releaseTime = _releaseTime;
        token = TutellusToken(_token);
    }

    function verify(address _address) authorized public {
        require(_address != address(0));
        
        verified[_address] = true;
        Verify(_address);
    }

    function deposit(address _address, uint256 _amount) authorized public {
        require(_address != address(0));
        require(_amount > 0);

        amounts[_address] += _amount;
        Deposit(_address, _amount);
    }

    function release() public returns(bool) {
        require(now >= releaseTime);
        require(verified[msg.sender]);

        uint256 amount = amounts[msg.sender];
        if (amount > 0) {
            amounts[msg.sender] = 0;
            if (!token.transfer(msg.sender, amount)) {
                amounts[msg.sender] = amount;
                return false;
            }
            Release(msg.sender);
        }
        return true;
    }
}

// File: contracts/TutellusVault.sol

contract TutellusVault is Authorizable {
    event VaultMint(address indexed authAddress);

    TutellusToken public token;

    function TutellusVault() public {
        token = new TutellusToken();
    }

    function mint(address _to, uint256 _amount) authorized public returns (bool) {
        require(_to != address(0));
        require(_amount >= 0);

        VaultMint(msg.sender);
        return token.mint(_to, _amount);
    }
}

// File: zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

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
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
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
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

// File: zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

// File: zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: contracts/TutellusCrowdsale.sol

/**
 * @title TutellusCrowdsale
 *
 * @dev Crowdsale for the Tutellus.io ICO.
 *
 * Upon finalization the pool and the team's wallet are mined. It must be
 * finalized once all the backers (including the vesting ones) have made
 * their contributions.
 */
contract TutellusCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable {
    event ConditionsAdded(address indexed beneficiary, uint256 rate);
    
    mapping(address => uint256) public conditions;

    uint256 salePercent = 60;   // Percent of TUTs for sale
    uint256 poolPercent = 30;   // Percent of TUTs for pool
    uint256 teamPercent = 10;   // Percent of TUTs for team

    uint256 vestingLimit; // 400 ether;
    uint256 specialLimit; // 200 ether;

    uint256 minPreICO; // 5 ether;
    uint256 minICO; // 0.05 ether;

    uint256 unitTimeSecs; //86400 secs;

    address teamTimelock; //Team TokenTimelock.

    TutellusVault vault;
    TutellusLockerVault locker;

    function TutellusCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _cap,
        address _wallet,
        address _teamTimelock,
        address _tutellusVault,
        address _lockerVault,
        uint256 _vestingLimit,
        uint256 _specialLimit,
        uint256 _minPreICO,
        uint256 _minICO,
        uint256 _unitTimeSecs
    )
        CappedCrowdsale(_cap)
        Crowdsale(_startTime, _endTime, 1000, _wallet)
    {
        require(_teamTimelock != address(0));
        require(_tutellusVault != address(0));
        require(_vestingLimit > _specialLimit);
        require(_minPreICO > _minICO);
        require(_unitTimeSecs > 0);

        teamTimelock = _teamTimelock;
        vault = TutellusVault(_tutellusVault);
        token = MintableToken(vault.token());

        locker = TutellusLockerVault(_lockerVault);

        vestingLimit = _vestingLimit;
        specialLimit = _specialLimit;
        minPreICO = _minPreICO;
        minICO = _minICO;
        unitTimeSecs = _unitTimeSecs;
    }

    function addSpecialRateConditions(address _address, uint256 _rate) public onlyOwner {
        require(_address != address(0));
        require(_rate > 0);

        conditions[_address] = _rate;
        ConditionsAdded(_address, _rate);
    }

    // Returns TUTs rate per 1 ETH depending on current time
    function getRateByTime() public constant returns (uint256) {
        uint256 timeNow = now;
        if (timeNow > (startTime + 94 * unitTimeSecs)) {
            return 1500;
        } else if (timeNow > (startTime + 87 * unitTimeSecs)) {
            return 1575; // + 5%
        } else if (timeNow > (startTime + 80 * unitTimeSecs)) {
            return 1650; // + 10%
        } else if (timeNow > (startTime + 73 * unitTimeSecs)) {
            return 1800; // + 20%
        } else if (timeNow > (startTime + 56 * unitTimeSecs)) {
            return 2025; // + 35%
        } else if (timeNow > (startTime + 42 * unitTimeSecs)) {
            return 2100; // + 40%
        } else if (timeNow > (startTime + 28 * unitTimeSecs)) {
            return 2175; // + 45%
        } else {
            return 2250; // + 50%
        }
    }

    function buyTokens(address beneficiary) whenNotPaused public payable {
        require(beneficiary != address(0));
        require(msg.value >= minICO && msg.value <= vestingLimit);
        require(validPurchase());

        uint256 senderRate;

        if (conditions[beneficiary] != 0) {
            require(msg.value >= specialLimit);
            senderRate = conditions[beneficiary];
        } else {
            senderRate = getRateByTime();
            if (senderRate > 1800) {
                require(msg.value >= minPreICO);
            }
        }

        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(senderRate);
        // update state
        weiRaised = weiRaised.add(weiAmount);

        locker.deposit(beneficiary, tokens);
        vault.mint(locker, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // Calculate the Tokens in percent over de tokens generated
    function poolTokensByPercent(uint256 _percent) internal returns(uint256) {
        return token.totalSupply().mul(_percent).div(salePercent);
    }

    // Method to mint the team and pool tokens
    function finalization() internal {
        uint256 tokensPool = poolTokensByPercent(poolPercent);
        uint256 tokensTeam = poolTokensByPercent(teamPercent);

        vault.mint(wallet, tokensPool);
        vault.mint(teamTimelock, tokensTeam);
    }

    function createTokenContract() internal returns (MintableToken) {}
}