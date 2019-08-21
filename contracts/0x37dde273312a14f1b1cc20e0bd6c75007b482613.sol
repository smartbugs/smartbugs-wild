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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address previousOwner,
    address newOwner
  );

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == address(this));
    _;
  }

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
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

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause(bool isPause);

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
    emit Pause(paused);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Pause(paused);
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Pausable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  uint256 totalSupply_;
  address public altTokenFundAddress;
  address public setPriceAccount;
  address public setReferralAccount;
  uint256 public tokenPrice;
  uint256 public managersFee;
  uint256 public referralFee;
  uint256 public supportFee;
  uint256 public withdrawFee;

  address public ethAddress;
  address public supportWallet;
  address public fundManagers;
  bool public lock;
  event Deposit(address indexed buyer, uint256 weiAmount, uint256 tokensAmount, uint256 tokenPrice, uint256 commission);
  event Withdraw(address indexed buyer, uint256 weiAmount, uint256 tokensAmount, uint256 tokenPrice, uint256 commission);


  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    if (_to == altTokenFundAddress) {
      require(!lock);
      uint256 weiAmount = _value.mul(uint256(100).sub(withdrawFee)).div(100).mul(tokenPrice).div(uint256(1000000000000000000));
      uint256 feeAmount = _value.mul(withdrawFee).div(100);

      totalSupply_ = totalSupply_.sub(_value-feeAmount);
      balances[fundManagers] = balances[fundManagers].add(feeAmount);
      emit Transfer(address(this), fundManagers, feeAmount);
      emit Withdraw(msg.sender, weiAmount, _value, tokenPrice, feeAmount);
    } else {
      balances[_to] = balances[_to].add(_value);
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    uint256 availableTokens = balances[_owner];
    return availableTokens;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
    whenNotPaused
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    if (_to == altTokenFundAddress) {
      require(!lock);
      uint256 weiAmount = _value.mul(uint256(100).sub(withdrawFee)).div(100).mul(tokenPrice).div(uint256(1000000000000000000));
      uint256 feeAmount = _value.mul(withdrawFee).div(100);

      totalSupply_ = totalSupply_.sub(_value-feeAmount);
      balances[fundManagers] = balances[fundManagers].add(feeAmount);
      emit Transfer(address(this), fundManagers, feeAmount);
      emit Withdraw(msg.sender, weiAmount, _value, tokenPrice, withdrawFee);
    } else {
      balances[_to] = balances[_to].add(_value);
    }

    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
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
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract AltTokenTradeToken is StandardToken {

  string constant public name = "Alt Token Trade Token";
  uint256 constant public decimals = 18;
  string constant public symbol = "ATT";
  mapping (address => address) public referrals;

  event Lock(bool lockStatus);
  event NewTokenPrice(uint256 tokenPrice);
  event AddTokens(address indexed user, uint256 tokensAmount, uint256 _price);

  event SupportFee(uint256 supportFee);
  event ManagersFee(uint256 managersFee);
  event ReferralFee(uint256 referralFee);
  event WithdrawFee(uint256 withdrawFee);

  event NewEthAddress(address ethAddress);
  event NewFundManagers(address fundManagers);
  event NewSupportWallet (address supportWallet);
  event NewSetPriceAccount (address setPriceAccount);
  event NewSetRefferalAccount (address referral);

  constructor() public {
    altTokenFundAddress = address(this);
    tokenPrice = 5041877658000000;
    lockUp(false);
    newManagersFee(1);
    newSupportFee(1);
    newReferralFee(3);
    newWithdrawFee(5);
    newEthAddress(0xBDE0483B3b2Fb37506879676c9B04e05101bB420);
    newFundManagers(0xe37517a6cbE9567b34ca9D8c3e85c50616a9ceee);
    newSupportWallet(0x2f12ba5e592C31ECA4E91A9009c5B683901FB1cf);
    newPriceAccount(0x5e817D174b05D5eD04b758a5CD11e24E170112Ba);
    newReferralAccount(0x57503367f7e085992CDac21697d2760292C0Fe31);
    
  }

  //Modifiers
  modifier onlySetPriceAccount {
      if (msg.sender != setPriceAccount) revert();
      _;
  }

  modifier onlySetReferralAccount {
      if (msg.sender != setReferralAccount) revert();
      _;
  }

  function priceOf() external view returns(uint256) {
    return tokenPrice;
  }

  function () payable external whenNotPaused {
    uint depositFee = managersFee.add(referralFee).add(supportFee);
    uint256 tokens = msg.value.mul(uint256(1000000000000000000)).mul(100-depositFee).div(uint256(100)).div(tokenPrice);


    totalSupply_ = totalSupply_.add(tokens);
    balances[msg.sender] = balances[msg.sender].add(tokens);

    fundManagers.transfer(msg.value.mul(managersFee).div(100));
    supportWallet.transfer(msg.value.mul(supportFee).div(100));
    if (referrals[msg.sender]!=0){
        referrals[msg.sender].transfer(msg.value.mul(referralFee).div(100));
    }
    else {
        supportWallet.transfer(msg.value.mul(referralFee).div(100));
    }
    
    ethAddress.transfer(msg.value.mul(uint256(100).sub(depositFee)).div(100));
    emit Transfer(altTokenFundAddress, msg.sender, tokens);
    emit Deposit(msg.sender, msg.value, tokens, tokenPrice, depositFee);
  }


  function airdrop(address[] receiver, uint256[] amount) external onlyOwner {
    require(receiver.length > 0 && receiver.length == amount.length);

    for(uint256 i = 0; i < receiver.length; i++) {
      uint256 tokens = amount[i];
      totalSupply_ = totalSupply_.add(tokens);
      balances[receiver[i]] = balances[receiver[i]].add(tokens);
      emit Transfer(address(this), receiver[i], tokens);
      emit AddTokens(receiver[i], tokens, tokenPrice);
    }
  }

  function setTokenPrice(uint256 _tokenPrice) public onlySetPriceAccount {
    tokenPrice = _tokenPrice;
    emit NewTokenPrice(tokenPrice);
  }
  
  function setReferral(address client, address referral)
        public
        onlySetReferralAccount
    {
        referrals[client] = referral;
    }

  function getReferral(address client)
        public
        constant
        returns (address)
    {
        return referrals[client];
    }

    function estimateTokens(uint256 valueInWei)
        public
        constant
        returns (uint256)
    {
        uint256 depositFee = managersFee.add(referralFee).add(supportFee);
        return valueInWei.mul(uint256(1000000000000000000)).mul(100-depositFee).div(uint256(100)).div(tokenPrice);
    }
    
    function estimateEthers(uint256 tokenCount)
        public
        constant
        returns (uint256)
    {
        uint256 weiAmount = tokenCount.mul(uint256(100).sub(withdrawFee)).div(100).mul(tokenPrice).div(uint256(1000000000000000000));
        return weiAmount;
    }

  function newSupportFee(uint256 _supportFee) public onlyOwner {
    supportFee = _supportFee;
    emit SupportFee(supportFee);
  }

  function newManagersFee(uint256 _managersFee) public onlyOwner {
    managersFee = _managersFee;
    emit ManagersFee(managersFee);
  }

  function newReferralFee(uint256 _referralFee) public onlyOwner {
    referralFee = _referralFee;
    emit ReferralFee(referralFee);
  }

  function newWithdrawFee(uint256 _newWithdrawFee) public onlyOwner {
    withdrawFee = _newWithdrawFee;
    emit WithdrawFee(withdrawFee);
  }

  function newEthAddress(address _ethAddress) public onlyOwner {
    ethAddress = _ethAddress;
    emit NewEthAddress(ethAddress);
  }

  function newFundManagers(address _fundManagers) public onlyOwner {
    fundManagers = _fundManagers;
    emit NewFundManagers(fundManagers);
  }
  
  function newSupportWallet(address _supportWallet) public onlyOwner {
    supportWallet = _supportWallet;
    emit NewSupportWallet(supportWallet);
  }
  
  function newPriceAccount(address _setPriceAccount) public onlyOwner {
    setPriceAccount = _setPriceAccount;
    emit NewSetPriceAccount(setPriceAccount);
  }
  
  function newReferralAccount(address _setReferralAccount) public onlyOwner {
    setReferralAccount = _setReferralAccount;
    emit NewSetRefferalAccount(setReferralAccount);
  }

  function lockUp(bool _lock) public onlyOwner {
    lock = _lock;
    emit Lock(lock);
  }
}