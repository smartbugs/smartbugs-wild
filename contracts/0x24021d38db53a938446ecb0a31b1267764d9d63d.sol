pragma solidity ^0.4.19;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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


contract HODLIT is StandardToken, Ownable {
  using SafeMath for uint256;
  string public name = "HODL INCENTIVE TOKEN";
  string public symbol = "HIT";
  uint256 public decimals = 18;
  uint256 public multiplicator = 10 ** decimals;
  uint256 public totalSupply;
  uint256 public ICDSupply;

  uint256 public registeredUsers;
  uint256 public claimedUsers;
  uint256 public maxReferrals = 20;

  uint256 public hardCap = SafeMath.mul(100000000, multiplicator);
  uint256 public ICDCap = SafeMath.mul(20000000, multiplicator);

  mapping (address => uint256) public etherBalances;
  mapping (address => bool) public ICDClaims;
  mapping (address => uint256) public referrals;
  mapping (address => bool) public bonusReceived;


  uint256 public regStartTime = 1519848000; // 28 feb 2018 20:00 GMT
  uint256 public regStopTime = regStartTime + 7 days;
  uint256 public POHStartTime = regStopTime;
  uint256 public POHStopTime = POHStartTime + 7 days;
  uint256 public ICDStartTime = POHStopTime;
  uint256 public ICDStopTime = ICDStartTime + 7 days;
  uint256 public PCDStartTime = ICDStopTime + 14 days;

  address public ERC721Address;

  modifier forRegistration {
    require(block.timestamp >= regStartTime && block.timestamp < regStopTime);
    _;
  }

  modifier forICD {
    require(block.timestamp >= ICDStartTime && block.timestamp < ICDStopTime);
    _;
  }

  modifier forERC721 {
    require(msg.sender == ERC721Address && block.timestamp >= PCDStartTime);
    _;
  }

  function HODLIT() public {
    uint256 reserve = SafeMath.mul(30000000, multiplicator);
    owner = msg.sender;
    totalSupply = totalSupply.add(reserve);
    balances[owner] = balances[owner].add(reserve);
    Transfer(address(0), owner, reserve);
  }

  function() external payable {
    revert();
  }

  function setERC721Address(address _ERC721Address) external onlyOwner {
    ERC721Address = _ERC721Address;
  }

  function setMaxReferrals(uint256 _maxReferrals) external onlyOwner {
    maxReferrals = _maxReferrals;
  }

  function registerEtherBalance(address _referral) external forRegistration {
    require(
      msg.sender.balance > 0.2 ether &&
      etherBalances[msg.sender] == 0 &&
      _referral != msg.sender
    );
    if (_referral != address(0) && referrals[_referral] < maxReferrals) {
      referrals[_referral]++;
    }
    registeredUsers++;
    etherBalances[msg.sender] = msg.sender.balance;
  }

  function claimTokens() external forICD {
    require(ICDClaims[msg.sender] == false);
    require(etherBalances[msg.sender] > 0);
    require(etherBalances[msg.sender] <= msg.sender.balance + 50 finney);
    ICDClaims[msg.sender] = true;
    claimedUsers++;
    require(mintICD(msg.sender, computeReward(etherBalances[msg.sender])));
  }

  function declareCheater(address _cheater) external onlyOwner {
    require(_cheater != address(0));
    ICDClaims[_cheater] = false;
    etherBalances[_cheater] = 0;
  }

  function declareCheaters(address[] _cheaters) external onlyOwner {
    for (uint256 i = 0; i < _cheaters.length; i++) {
      require(_cheaters[i] != address(0));
      ICDClaims[_cheaters[i]] = false;
      etherBalances[_cheaters[i]] = 0;
    }
  }

  function mintPCD(address _to, uint256 _amount) external forERC721 returns(bool) {
    require(_to != address(0));
    require(_amount + totalSupply <= hardCap);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    etherBalances[_to] = _to.balance;
    Transfer(address(0), _to, _amount);
    return true;
  }

  function claimTwitterBonus() external forICD {
    require(balances[msg.sender] > 0 && !bonusReceived[msg.sender]);
    bonusReceived[msg.sender] = true;
    mintICD(msg.sender, multiplicator.mul(20));
  }

  function claimReferralBonus() external forICD {
    require(referrals[msg.sender] > 0 && balances[msg.sender] > 0);
    uint256 cache = referrals[msg.sender];
    referrals[msg.sender] = 0;
    mintICD(msg.sender, SafeMath.mul(cache * 20, multiplicator));
  }

  function computeReward(uint256 _amount) internal view returns(uint256) {
    if (_amount < 1 ether) return SafeMath.mul(20, multiplicator);
    if (_amount < 2 ether) return SafeMath.mul(100, multiplicator);
    if (_amount < 3 ether) return SafeMath.mul(240, multiplicator);
    if (_amount < 4 ether) return SafeMath.mul(430, multiplicator);
    if (_amount < 5 ether) return SafeMath.mul(680, multiplicator);
    if (_amount < 6 ether) return SafeMath.mul(950, multiplicator);
    if (_amount < 7 ether) return SafeMath.mul(1260, multiplicator);
    if (_amount < 8 ether) return SafeMath.mul(1580, multiplicator);
    if (_amount < 9 ether) return SafeMath.mul(1900, multiplicator);
    if (_amount < 10 ether) return SafeMath.mul(2240, multiplicator);
    if (_amount < 11 ether) return SafeMath.mul(2560, multiplicator);
    if (_amount < 12 ether) return SafeMath.mul(2890, multiplicator);
    if (_amount < 13 ether) return SafeMath.mul(3210, multiplicator);
    if (_amount < 14 ether) return SafeMath.mul(3520, multiplicator);
    if (_amount < 15 ether) return SafeMath.mul(3830, multiplicator);
    if (_amount < 16 ether) return SafeMath.mul(4120, multiplicator);
    if (_amount < 17 ether) return SafeMath.mul(4410, multiplicator);
    if (_amount < 18 ether) return SafeMath.mul(4680, multiplicator);
    if (_amount < 19 ether) return SafeMath.mul(4950, multiplicator);
    if (_amount < 20 ether) return SafeMath.mul(5210, multiplicator);
    if (_amount < 21 ether) return SafeMath.mul(5460, multiplicator);
    if (_amount < 22 ether) return SafeMath.mul(5700, multiplicator);
    if (_amount < 23 ether) return SafeMath.mul(5930, multiplicator);
    if (_amount < 24 ether) return SafeMath.mul(6150, multiplicator);
    if (_amount < 25 ether) return SafeMath.mul(6360, multiplicator);
    if (_amount < 26 ether) return SafeMath.mul(6570, multiplicator);
    if (_amount < 27 ether) return SafeMath.mul(6770, multiplicator);
    if (_amount < 28 ether) return SafeMath.mul(6960, multiplicator);
    if (_amount < 29 ether) return SafeMath.mul(7140, multiplicator);
    if (_amount < 30 ether) return SafeMath.mul(7320, multiplicator);
    if (_amount < 31 ether) return SafeMath.mul(7500, multiplicator);
    if (_amount < 32 ether) return SafeMath.mul(7660, multiplicator);
    if (_amount < 33 ether) return SafeMath.mul(7820, multiplicator);
    if (_amount < 34 ether) return SafeMath.mul(7980, multiplicator);
    if (_amount < 35 ether) return SafeMath.mul(8130, multiplicator);
    if (_amount < 36 ether) return SafeMath.mul(8270, multiplicator);
    if (_amount < 37 ether) return SafeMath.mul(8410, multiplicator);
    if (_amount < 38 ether) return SafeMath.mul(8550, multiplicator);
    if (_amount < 39 ether) return SafeMath.mul(8680, multiplicator);
    if (_amount < 40 ether) return SafeMath.mul(8810, multiplicator);
    if (_amount < 41 ether) return SafeMath.mul(8930, multiplicator);
    if (_amount < 42 ether) return SafeMath.mul(9050, multiplicator);
    if (_amount < 43 ether) return SafeMath.mul(9170, multiplicator);
    if (_amount < 44 ether) return SafeMath.mul(9280, multiplicator);
    if (_amount < 45 ether) return SafeMath.mul(9390, multiplicator);
    if (_amount < 46 ether) return SafeMath.mul(9500, multiplicator);
    if (_amount < 47 ether) return SafeMath.mul(9600, multiplicator);
    if (_amount < 48 ether) return SafeMath.mul(9700, multiplicator);
    if (_amount < 49 ether) return SafeMath.mul(9800, multiplicator);
    if (_amount < 50 ether) return SafeMath.mul(9890, multiplicator);
    return SafeMath.mul(10000, multiplicator);
  }

  function mintICD(address _to, uint256 _amount) internal returns(bool) {
    require(_to != address(0));
    require(_amount + ICDSupply <= ICDCap);
    totalSupply = totalSupply.add(_amount);
    ICDSupply = ICDSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    etherBalances[_to] = _to.balance;
    Transfer(address(0), _to, _amount);
    return true;
  }
}