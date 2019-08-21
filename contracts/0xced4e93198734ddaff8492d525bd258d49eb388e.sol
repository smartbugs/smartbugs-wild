pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

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

contract MintableInterface {
  function mint(address _to, uint256 _amount) returns (bool);
  function mintLocked(address _to, uint256 _amount) returns (bool);
}

/**
 * This is the Crowdsale contract from OpenZeppelin version 1.2.0
 * The only changes are:
 *   - the type of token field is changed from MintableToken to MintableInterface
 *   - the createTokenContract() method is removed, the token field must be initialized in the derived contracts constuctor
 **/






/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end block, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableInterface public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;

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


  function Crowdsale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) {
    require(_startBlock >= block.number);
    require(_endBlock >= _startBlock);
    require(_rate > 0);
    require(_wallet != 0x0);

    startBlock = _startBlock;
    endBlock = _endBlock;
    rate = _rate;
    wallet = _wallet;
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
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
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return block.number > endBlock;
  }


}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowsdale with a max amount of funds raised
 */
contract TokenCappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  // tokenCap should be initialized in derived contract
  uint256 public tokenCap;

  uint256 public soldTokens;

  // overriding Crowdsale#hasEnded to add tokenCap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = soldTokens >= tokenCap;
    return super.hasEnded() || capReached;
  }

  // overriding Crowdsale#buyTokens to add extra tokenCap logic
  function buyTokens(address beneficiary) payable {
    // calculate token amount to be created
    uint256 tokens = msg.value.mul(rate);
    uint256 newTotalSold = soldTokens.add(tokens);
    require(newTotalSold <= tokenCap);
    soldTokens = newTotalSold;
    super.buyTokens(beneficiary);
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * This is the TokenTimelock contract from OpenZeppelin version 1.2.0
 * The only changes are:
 *   - all contract fields are declared as public
 *   - removed deprecated claim() method
 **/





/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a 
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  
  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint _releaseTime) {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() {
    require(now >= releaseTime);

    uint amount = token.balanceOf(this);
    require(amount > 0);

    token.transfer(beneficiary, amount);
  }
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract EidooToken is MintableInterface, Ownable, StandardToken {
  using SafeMath for uint256;

  string public name = "Eidoo Token";
  string public symbol = "EDO";
  uint256 public decimals = 18;

  uint256 public transferableFromBlock;
  uint256 public lockEndBlock;
  mapping (address => uint256) public initiallyLockedAmount;

  function EidooToken(uint256 _transferableFromBlock, uint256 _lockEndBlock) {
    require(_lockEndBlock > _transferableFromBlock);
    transferableFromBlock = _transferableFromBlock;
    lockEndBlock = _lockEndBlock;
  }

  modifier canTransfer(address _from, uint _value) {
    if (block.number < lockEndBlock) {
      require(block.number >= transferableFromBlock);
      uint256 locked = lockedBalanceOf(_from);
      if (locked > 0) {
        uint256 newBalance = balanceOf(_from).sub(_value);
        require(newBalance >= locked);
      }
    }
   _;
  }

  function lockedBalanceOf(address _to) constant returns(uint256) {
    uint256 locked = initiallyLockedAmount[_to];
    if (block.number >= lockEndBlock ) return 0;
    else if (block.number <= transferableFromBlock) return locked;

    uint256 releaseForBlock = locked.div(lockEndBlock.sub(transferableFromBlock));
    uint256 released = block.number.sub(transferableFromBlock).mul(releaseForBlock);
    return locked.sub(released);
  }

  function transfer(address _to, uint _value) canTransfer(msg.sender, _value) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from, _value) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  // --------------- Minting methods

  modifier canMint() {
    require(!mintingFinished());
    _;
  }

  function mintingFinished() constant returns(bool) {
    return block.number >= transferableFromBlock;
  }

  /**
   * @dev Function to mint tokens, implements MintableInterface
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function mintLocked(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    initiallyLockedAmount[_to] = initiallyLockedAmount[_to].add(_amount);
    return mint(_to, _amount);
  }

  function burn(uint256 _amount) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    Transfer(msg.sender, address(0), _amount);
    return true;
  }
}

contract EidooTokenSale is Ownable, TokenCappedCrowdsale {
  using SafeMath for uint256;
  uint256 public MAXIMUM_SUPPLY = 100000000 * 10**18;
  uint256 [] public LOCKED = [     20000000 * 10**18,
                                   15000000 * 10**18,
                                    6000000 * 10**18,
                                    6000000 * 10**18 ];
  uint256 public POST_ICO =        21000000 * 10**18;
  uint256 [] public LOCK_END = [
    1570190400, // 4 October 2019 12:00:00 GMT
    1538654400, // 4 October 2018 12:00:00 GMT
    1522843200, // 4 April 2018 12:00:00 GMT
    1515067200  // 4 January 2018 12:00:00 GMT
  ];

  mapping (address => bool) public claimed;
  TokenTimelock [4] public timeLocks;

  event ClaimTokens(address indexed to, uint amount);

  modifier beforeStart() {
    require(block.number < startBlock);
    _;
  }

  function EidooTokenSale(
    uint256 _startBlock,
    uint256 _endBlock,
    uint256 _rate,
    uint _tokenStartBlock,
    uint _tokenLockEndBlock,
    address _wallet
  )
    Crowdsale(_startBlock, _endBlock, _rate, _wallet)
  {
    token = new EidooToken(_tokenStartBlock, _tokenLockEndBlock);

    // create timelocks for tokens
    timeLocks[0] = new TokenTimelock(EidooToken(token), _wallet, LOCK_END[0]);
    timeLocks[1] = new TokenTimelock(EidooToken(token), _wallet, LOCK_END[1]);
    timeLocks[2] = new TokenTimelock(EidooToken(token), _wallet, LOCK_END[2]);
    timeLocks[3] = new TokenTimelock(EidooToken(token), _wallet, LOCK_END[3]);
    token.mint(address(timeLocks[0]), LOCKED[0]);
    token.mint(address(timeLocks[1]), LOCKED[1]);
    token.mint(address(timeLocks[2]), LOCKED[2]);
    token.mint(address(timeLocks[3]), LOCKED[3]);

    token.mint(_wallet, POST_ICO);

    // initialize maximum number of tokens that can be sold
    tokenCap = MAXIMUM_SUPPLY.sub(EidooToken(token).totalSupply());
  }

  function claimTokens(address [] buyers, uint [] amounts) onlyOwner beforeStart public {
    require(buyers.length == amounts.length);
    uint len = buyers.length;
    for (uint i = 0; i < len; i++) {
      address to = buyers[i];
      uint256 amount = amounts[i];
      if (amount > 0 && !claimed[to]) {
        claimed[to] = true;
        if (to == 0x32Be343B94f860124dC4fEe278FDCBD38C102D88) {
          // replace Poloniex Wallet address
          to = 0x2274bebe2b47Ec99D50BB9b12005c921F28B83bB;
        }
        tokenCap = tokenCap.sub(amount);
        uint256 unlockedAmount = amount.div(10).mul(3);
        token.mint(to, unlockedAmount);
        token.mintLocked(to, amount.sub(unlockedAmount));
        ClaimTokens(to, amount);
      }
    }
  }

}