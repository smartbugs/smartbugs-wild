pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract FundCruToken is MintableToken {
  // token identity
  string public constant name = "FundCru";
  string public constant symbol = "FUND";
  uint256 public constant decimals = 18;
  bytes4 public constant magic = 0x46554E44;    // "FUND"

  // whether token transfering will be blocked during crowdsale timeframe
  bool public blockTransfering;

  function FundCruToken(bool _blockTransfering) public {
    blockTransfering = _blockTransfering;
  }

  function blockTransfer() onlyOwner public {
    require(!blockTransfering);
    blockTransfering = true;
  }

  function unblockTransfer() onlyOwner public {
    require(blockTransfering);
    blockTransfering = false;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(!blockTransfering);
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(!blockTransfering);
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(!blockTransfering);
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
    require(!blockTransfering);
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
    require(!blockTransfering);
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract FundCruCrowdsale is Ownable {
  using SafeMath for uint256;

  // the token being sold
  FundCruToken public fundcruToken;

  // address where funds/ethers are collected
  address public crowdsaleOwner;

  // lock-up time of FUND tokens that belongs to Fundcru
  uint256 public fundcruVaultLockTime;

  // better trust our data, block timestamp can be malicious
  bool public crowdsaleActive = false;

  // duration of the crowdsale, in seconds
  uint256 public duration;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // minimum accepted transaction
  uint256 public minimumPurchaseInWei;

  // crowdsale configs
  uint256[] public goalOfState;
  uint256[] public durationOfState;
  uint256[] public conversionRateOfState;

  // keep track of the current state
  uint256 public currentState;
  uint256 public currentStateStartTime;

  // and the last state where we have countdown reset mechanism
  uint256 public lastState;
  uint256 public softCapCountDownTimer;

  event StateTransition(uint256 from_state, uint256 to_state, uint256 timestamp);

  event TokenPurchase(uint256 current_state,
                      uint256 timestamp,
                      address indexed purchaser,
                      address indexed beneficiary,
                      uint256 transaction_amount_in_wei,
                      uint256 num_tokens);

  // transaction sanity test
  modifier validPurchase() {
    require(crowdsaleActive);
    require(now >= startTime && now <= endTime);    // buy within valid timeframe
    require(msg.value >= minimumPurchaseInWei);     // buy at least minimumPurchaseInWei
    _;
  }

  // state transition
  modifier stateTransition() {
    require(currentState >= 0 && currentState <= lastState);
    require(now >= currentStateStartTime);

    if (currentState == lastState) {
      // If we achieve the soft cap goal, make sure the timeframe is valid
      uint256 totalSupply = fundcruToken.totalSupply();
      if (totalSupply >= goalOfState[lastState - 1]) {
        assert(now < currentStateStartTime + softCapCountDownTimer);
      }
    } else {
      // how long since current state start time
      uint256 timePassed = now - currentStateStartTime;

      // what state we suppose to be in
      uint256 newState;
      uint256 sumTime = 0;
      for (uint256 i=currentState; i<lastState; i++) {
        sumTime = sumTime.add(durationOfState[i]);
        if (sumTime >= timePassed) {
          newState = i;
          break;
        }
      }

      if (i == lastState) {
        newState = lastState;
      }

      // do we need to switch to new state
      if (newState != currentState) {
        StateTransition(currentState, newState, now);
        currentState = newState;
        currentStateStartTime = now;
      }
    }

    _;
  }

  function FundCruCrowdsale(uint256   _duration,                // in seconds, convenience for testing
                            uint256   _minimumPurchaseInWei,    // minimum accepted transaction
                            uint256[] _goalOfState,             // goal of each state in FUND
                            uint256[] _durationOfState,         // how long each funding state lasts, in seconds
                            uint256[] _conversionRateOfState,   // ETH -> FUND conversion rate
                            uint256   _softCapCountDownTimer,   // count down timer (in seconds) after soft cap goal reached
                            uint256   _fundcruVaultLockTime,
                            address   _crowdsaleOwner) public {
    require(_duration > 0);
    require(_minimumPurchaseInWei > 0);
    require(_goalOfState.length > 0);
    require(_crowdsaleOwner != 0x0);

    duration = _duration;
    minimumPurchaseInWei = _minimumPurchaseInWei;

    lastState = _goalOfState.length - 1;
    require(_durationOfState.length == (lastState + 1) &&
            _conversionRateOfState.length == (lastState + 1));

    // funding goal configs
    for (uint256 i=0; i<=lastState; i++) {
      goalOfState.push(_goalOfState[i].mul(1 ether)); // 10^18, like our token's decimal
      durationOfState.push(_durationOfState[i]);
      conversionRateOfState.push(_conversionRateOfState[i]);
    }

    // last state countdown parameters
    softCapCountDownTimer = _softCapCountDownTimer;

    fundcruToken = createTokenContract();
    assert(fundcruToken.magic() == 0x46554E44);
    assert(fundcruToken.blockTransfering() == true);

    // locked vault
    fundcruVaultLockTime = _fundcruVaultLockTime;

    // crowdsale owner
    crowdsaleOwner = _crowdsaleOwner;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (FundCruToken) {
    // don't allow FUND tokens being traded during crowdsale period
    return new FundCruToken(/*_blockTransfering = */true);
  }

  // fallback function can be used to buy tokens
  function () payable public {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable stateTransition validPurchase {
    require(beneficiary != 0x0);

    // calculate token amount to be created
    uint256 weiAmount = msg.value;
    uint256 numTokens = weiAmount.mul(conversionRateOfState[currentState]);

    fundcruToken.mint(beneficiary, numTokens);
    TokenPurchase(currentState, now, msg.sender, beneficiary, weiAmount, numTokens);

    // get total supply to see if we need to change state
    uint256 totalSupply = fundcruToken.totalSupply();

    // check if we need to go to new state
    if (currentState < lastState) {
      // what state we suppose to be in after this transaction
      uint256 newState = currentState;
      for (uint256 i=currentState; i<lastState; i++) {
        if (goalOfState[i] > totalSupply) {
          newState = i;
          break;
        }
      }

      if (i == lastState) {
        newState = lastState;
      }

      // do we need to switch to new state
      if (newState != currentState) {
        StateTransition(currentState, newState, now);
        currentState = newState;
        currentStateStartTime = now;
      }
    }

    forwardFunds();
  }

  function startCrowdsale() public onlyOwner {
    require(!crowdsaleActive);
    crowdsaleActive = true;

    // start now
    startTime = now;
    endTime = startTime.add(duration);

    // start from state 0
    currentState = 0;
    currentStateStartTime = startTime;
  }

  function endCrowdsale() public onlyOwner {
    require(crowdsaleActive);
    crowdsaleActive = false;

    uint256 totalSupply = fundcruToken.totalSupply();

    // fundcru only offers 50% of tokens, keeps 50% for the company
    // 90% of company tokens will be locked
    uint256 unlocked_tokens = totalSupply.div(10);
    fundcruToken.mint(crowdsaleOwner, unlocked_tokens);
    fundcruToken.mint(this, totalSupply.sub(unlocked_tokens));

    // stop minting new coins
    fundcruToken.finishMinting();

    // allow token being traded
    fundcruToken.unblockTransfer();

    // lock company tokens
    fundcruVaultLockTime = fundcruVaultLockTime.add(now);
  }

  function withdrawTokens() public onlyOwner {
    // must wait until lock-up time expires
    require(!crowdsaleActive);
    require(now > fundcruVaultLockTime);

    // withdraw all FUND tokens to company wallet
    fundcruToken.transfer(crowdsaleOwner, fundcruToken.balanceOf(this));

    // transfer ownership to crowdsale's organizer
    fundcruToken.transferOwnership(crowdsaleOwner);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    crowdsaleOwner.transfer(msg.value);
  }
}