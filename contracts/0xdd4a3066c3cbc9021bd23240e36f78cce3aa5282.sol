pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
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
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol

/**
 * @title Standard Burnable Token
 * @dev Adds burnFrom method to ERC20 implementations
 */
contract StandardBurnableToken is BurnableToken, StandardToken {

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: @pigzbe/erc20-contract/contracts/WLO.sol

contract WLO is StandardBurnableToken, Ownable {

  string public name = "Wollo";
  string public symbol = "WLO";

  uint8 public decimals = 18;
  uint public INITIAL_SUPPLY = 25000000 * uint(10**uint(decimals));

  constructor () public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

// File: contracts/ICOEngineInterface.sol

contract ICOEngineInterface {

  // false if the ico is not started, true if the ico is started and running, true if the ico is completed
  function started() public view returns(bool);

  // false if the ico is not started, false if the ico is started and running, true if the ico is completed
  function ended() public view returns(bool);

  // time stamp of the starting time of the ico, must return 0 if it depends on the block number
  function startTime() public view returns(uint);

  // time stamp of the ending time of the ico, must retrun 0 if it depends on the block number
  function endTime() public view returns(uint);

  // Optional function, can be implemented in place of startTime
  // Returns the starting block number of the ico, must return 0 if it depends on the time stamp
  // function startBlock() public view returns(uint);

  // Optional function, can be implemented in place of endTime
  // Returns theending block number of the ico, must retrun 0 if it depends on the time stamp
  // function endBlock() public view returns(uint);

  // returns the total number of the tokens available for the sale, must not change when the ico is started
  function totalTokens() public view returns(uint);

  // returns the number of the tokens available for the ico. At the moment that the ico starts it must be equal to totalTokens(),
  // then it will decrease. It is used to calculate the percentage of sold tokens as remainingTokens() / totalTokens()
  function remainingTokens() public view returns(uint);

  // return the price as number of tokens released for each ether
  function price() public view returns(uint);
}

// File: contracts/KYCBase.sol

// Abstract base contract
contract KYCBase {
  using SafeMath for uint256;

  mapping (address => bool) public isKycSigner;
  mapping (uint64 => uint256) public alreadyPayed;

  event KycVerified(address indexed signer, address buyerAddress, uint64 buyerId, uint maxAmount);

  constructor(address[] kycSigners) internal {
    for (uint i = 0; i < kycSigners.length; i++) {
      isKycSigner[kycSigners[i]] = true;
    }
  }

  // Must be implemented in descending contract to assign tokens to the buyers. Called after the KYC verification is passed
  function releaseTokensTo(address buyer) internal returns(bool);

  // This method can be overridden to enable some sender to buy token for a different address
  function senderAllowedFor(address buyer) internal view returns(bool) {
    return buyer == msg.sender;
  }

  function buyTokensFor(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s) public payable returns (bool) {
    require(senderAllowedFor(buyerAddress));
    return buyImplementation(buyerAddress, buyerId, maxAmount, v, r, s);
  }

  function buyTokens(uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s) public payable returns (bool) {
    return buyImplementation(msg.sender, buyerId, maxAmount, v, r, s);
  }

  function buyImplementation(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s) private returns (bool) {
    // check the signature
    bytes32 hash = sha256(abi.encodePacked("Eidoo icoengine authorization", this, buyerAddress, buyerId, maxAmount));
    address signer = ecrecover(hash, v, r, s);
    if (!isKycSigner[signer]) {
      revert();
    } else {
      uint256 totalPayed = alreadyPayed[buyerId].add(msg.value);
      require(totalPayed <= maxAmount);
      alreadyPayed[buyerId] = totalPayed;
      emit KycVerified(signer, buyerAddress, buyerId, maxAmount);
      return releaseTokensTo(buyerAddress);
    }
  }

  // No payable fallback function, the tokens must be buyed using the functions buyTokens and buyTokensFor
  function () public {
    revert();
  }
}

// File: contracts/WolloCrowdsale.sol

/* solium-disable security/no-block-members */
pragma solidity ^0.4.24;





contract WolloCrowdsale is ICOEngineInterface, KYCBase {
  using SafeMath for uint;

  WLO public token;
  address public wallet;
  uint public price;
  uint public startTime;
  uint public endTime;
  uint public cap;
  uint public remainingTokens;
  uint public totalTokens;

  /**
  * event for token purchase logging
  * @param purchaser who paid for the tokens
  * @param beneficiary who got the tokens
  * @param value weis paid for purchase
  * @param amount amount of tokens purchased
  */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
  * event for when weis are sent back to buyer
  * @param purchaser who paid for the tokens and is getting back some ether
  * @param amount of weis sent back
  */
  event SentBack(address indexed purchaser, uint256 amount);

  // LOGS
  event Log(string name, uint number);
  event LogBool(string name, bool log);
  event LogS(string name, string log);
  event LogA(string name, address log);

  /**
  *  Constructor
  */
  constructor (
    address[] kycSigner,
    address _token,
    address _wallet,
    uint _startTime,
    uint _endTime,
    uint _price,
    uint _cap
  ) public KYCBase(kycSigner) {

    require(_token != address(0));
    require(_wallet != address(0));
    /* require(_startTime >= now); */
    require(_endTime > _startTime);
    require(_price > 0);
    require(_cap > 0);

    token = WLO(_token);

    wallet = _wallet;
    startTime = _startTime;
    endTime = _endTime;
    price = _price;
    cap = _cap;

    totalTokens = cap;
    remainingTokens = cap;
  }

  // function that is called from KYCBase
  function releaseTokensTo(address buyer) internal returns(bool) {

    emit LogBool("started", started());
    emit LogBool("ended", ended());

    require(started() && !ended());

    emit Log("wei", msg.value);
    emit LogA("buyer", buyer);

    uint weiAmount = msg.value;
    uint weiBack = 0;
    uint tokens = weiAmount.mul(price);
    uint tokenRaised = totalTokens - remainingTokens;

    if (tokenRaised.add(tokens) > cap) {
      tokens = cap.sub(tokenRaised);
      weiAmount = tokens.div(price);
      weiBack = msg.value - weiAmount;
    }

    emit Log("tokens", tokens);

    remainingTokens = remainingTokens.sub(tokens);

    require(token.transferFrom(wallet, buyer, tokens));
    wallet.transfer(weiAmount);

    if (weiBack > 0) {
      msg.sender.transfer(weiBack);
      emit SentBack(msg.sender, weiBack);
    }

    emit TokenPurchase(msg.sender, buyer, weiAmount, tokens);
    return true;
  }

  function started() public view returns(bool) {
    return now >= startTime;
  }

  function ended() public view returns(bool) {
    return now >= endTime || remainingTokens == 0;
  }

  function startTime() public view returns(uint) {
    return(startTime);
  }

  function endTime() public view returns(uint){
    return(endTime);
  }

  function totalTokens() public view returns(uint){
    return(totalTokens);
  }

  function remainingTokens() public view returns(uint){
    return(remainingTokens);
  }

  function price() public view returns(uint){
    return price;
  }
}