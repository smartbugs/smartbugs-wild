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

contract ALT1Token is Ownable, ERC20Basic {
  using SafeMath for uint256;

  string public constant name     = "Altair VR presale token";
  string public constant symbol   = "ALT1";
  uint8  public constant decimals = 18;

  bool public mintingFinished = false;

  mapping(address => uint256) public balances;
  address[] public holders;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  /**
  * @dev Function to mint tokens
  * @param _to The address that will receive the minted tokens.
  * @param _amount The amount of tokens to mint.
  * @return A boolean that indicates if the operation was successful.
  */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    if (balances[_to] == 0) { 
      holders.push(_to);
    }
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

  /**
  * @dev Current token is not transferred.
  * After start official token sale ALT, you can exchange your ALT1 to ALT
  */
  function transfer(address, uint256) public returns (bool) {
    revert();
    return false;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}

/**
 * @title Crowdsale ALT1 presale token
 */

contract Crowdsale is Ownable {
  using SafeMath for uint256;

  uint256   public constant rate = 10000;                  // How many token units a buyer gets per wei
  uint256   public constant cap = 80000000 ether;          // Maximum amount of funds

  bool      public isFinalized = false;

  uint256   public endTime = 1522540800;                  // End timestamps where investments are allowed
                                                          // 01-Apr-18 00:00:00 UTC
  uint256 public bonusDecreaseDay = 1517529600;           // First day with lower bonus 02-Feb-18 00:00:00 UTC

  ALT1Token     public token;                                 // ALT1 token itself
  ALT1Token     public oldToken;                              // Old ALT1 token for balance converting
  address       public wallet;                                // Wallet of funds
  uint256       public weiRaised;                             // Amount of raised money in wei

  mapping(address => uint) public oldHolders;

  uint256 public constant bonusByAmount = 70;
  uint256 public constant amountForBonus = 50 ether;

  mapping(uint => uint) public bonusesByDates;
  uint[] public bonusesDates;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Finalized();

  function Crowdsale (ALT1Token _ALT1, ALT1Token _OldALT1, address _wallet) public {
    assert(address(_ALT1) != address(0));
    assert(address(_OldALT1) != address(0));
    assert(_wallet != address(0));
    assert(endTime > now);
    assert(rate > 0);
    assert(cap > 0);

    token = _ALT1;
    oldToken = _OldALT1;

    bonusesDates = [
      bonusDecreaseDay,   // 02-Feb-18 00:00:00 UTC
      1517788800,         // 05-Feb-18 00:00:00 UTC
      1518048000,         // 08-Feb-18 00:00:00 UTC
      1518307200,         // 11-Feb-18 00:00:00 UTC
      1518566400,         // 14-Feb-18 00:00:00 UTC
      1518825600,         // 17-Feb-18 00:00:00 UTC
      1519084800,         // 20-Feb-18 00:00:00 UTC
      1519344000,         // 23-Feb-18 00:00:00 UTC
      1519603200          // 26-Feb-18 00:00:00 UTC
    ];

    bonusesByDates[bonusesDates[0]] = 70;
    bonusesByDates[bonusesDates[1]] = 65;
    bonusesByDates[bonusesDates[2]] = 60;
    bonusesByDates[bonusesDates[3]] = 55;
    bonusesByDates[bonusesDates[4]] = 50;
    bonusesByDates[bonusesDates[5]] = 45;
    bonusesByDates[bonusesDates[6]] = 40;
    bonusesByDates[bonusesDates[7]] = 35;
    bonusesByDates[bonusesDates[8]] = 30;

  
    wallet = _wallet;
  }

  function () public payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = tokensForWei(weiAmount);
    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function getBonus(uint256 _tokens) public view returns (uint256) {
    if (_tokens.div(rate) >= amountForBonus && now <= bonusesDates[8]) return _tokens.mul(70).div(100);
    if (now < bonusesDates[0]) return getBonusByDate(0, _tokens);
    if (now < bonusesDates[1]) return getBonusByDate(1, _tokens);
    if (now < bonusesDates[2]) return getBonusByDate(2, _tokens);
    if (now < bonusesDates[3]) return getBonusByDate(3, _tokens);
    if (now < bonusesDates[4]) return getBonusByDate(4, _tokens);
    if (now < bonusesDates[5]) return getBonusByDate(5, _tokens);
    if (now < bonusesDates[6]) return getBonusByDate(6, _tokens);
    if (now < bonusesDates[7]) return getBonusByDate(7, _tokens);
    if (now < bonusesDates[8]) return getBonusByDate(8, _tokens);
    return _tokens.mul(25).div(100);
  }

   function getBonusByDate(uint256 _number, uint256 _tokens) public view returns (uint256 bonus) {
    bonus = _tokens.mul(bonusesByDates[bonusesDates[_number]]).div(100);
   }

  function convertOldToken(address beneficiary) public oldTokenHolders(beneficiary) oldTokenFinalized {
    uint amount = oldToken.balanceOf(beneficiary);
    oldHolders[beneficiary] = amount;
    weiRaised = weiRaised.add(amount.div(17000));
    token.mint(beneficiary, amount);
  }

  function convertAllOldTokens(uint256 length, uint256 start) public oldTokenFinalized {
    for (uint i = start; i < length; i++) {
      if (oldHolders[oldToken.holders(i)] == 0) {
        convertOldToken(oldToken.holders(i));
      }
    }
  }

  /**
   * @dev Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);

    finalization();
    Finalized();

    isFinalized = true;
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool tokenMintingFinished = token.mintingFinished();
    bool withinCap = token.totalSupply().add(tokensForWei(msg.value)) <= cap;
    bool withinPeriod = now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    bool moreThanMinimumPayment = msg.value >= 0.05 ether;

    return !tokenMintingFinished && withinCap && withinPeriod && nonZeroPurchase && moreThanMinimumPayment;
  }

  function tokensForWei(uint weiAmount) public view returns (uint tokens) {
    tokens = weiAmount.mul(rate);
    tokens = tokens.add(getBonus(tokens));
  }

  function finalization() internal {
    token.finishMinting();
    endTime = now;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


  /**
   * Throws if called by not an ALT0 holder or second time call for same ALT0 holder
   */
  modifier oldTokenHolders(address beneficiary) {
    require(oldToken.balanceOf(beneficiary) > 0);
    require(oldHolders[beneficiary] == 0);
    _;
  }

  modifier oldTokenFinalized() {
    require(oldToken.mintingFinished());
    _;
  }

}