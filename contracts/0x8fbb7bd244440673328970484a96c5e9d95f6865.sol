pragma solidity ^0.4.18;


/**
Mockup object 
*/
contract ElementhToken {
    
  bool public mintingFinished = false;
    function mint(address _to, uint256 _amount) public returns (bool) {
    if(_to != address(0)) mintingFinished = false;
    if(_amount != 0) mintingFinished = false;
    return true;
    }

    function burn(address _to, uint256 _amount) public returns (bool) {
    if(_to != address(0)) mintingFinished = false;
    if(_amount != 0) mintingFinished = false;
    return true;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
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
    mapping(address => bool)  internal owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public{
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address newAllowed) onlyOwner public {
        owners[newAllowed] = true;
    }

    function removeOwner(address toRemove) onlyOwner public {
        owners[toRemove] = false;
    }

    function isOwner() public view returns(bool){
        return owners[msg.sender] == true;
    }

}



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive. The contract requires a MintableToken that will be
 * minted as contributions arrive, note that the crowdsale contract
 * must be owner of the token in order to be able to mint it.
 */
contract PreFund is Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public deposited;
  mapping (address => uint256) public claimed;

  // The token being sold
  ElementhToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;


  // how many token units a buyer gets per wei
  uint256 public rate;

  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event AddDeposit(address indexed beneficiary, uint256 value);
  event LogClaim(address indexed holder, uint256 amount);

  function setStartTime(uint256 _startTime) public onlyOwner{
    startTime = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner{
    endTime = _endTime;
  }

  function setWallet(address _wallet) public onlyOwner{
    wallet = _wallet;
  }

  function setRate(uint256 _rate) public onlyOwner{
    rate = _rate;
  }


  function PreFund(uint256 _startTime, uint256 _endTime, address _wallet, ElementhToken _token) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != address(0));
    require(_token != address(0));

    token = _token;
    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
  }

  function () external payable {
    deposit(msg.sender);
  }

  // low level token purchase function
  function deposit(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    deposited[beneficiary] = deposited[beneficiary].add(msg.value);

    uint256 weiAmount = msg.value;
    AddDeposit(beneficiary, weiAmount);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }


  // send ether to the fund collection wallet
  function forwardFunds() onlyOwner public {
    require(now >= endTime);
    wallet.transfer(this.balance);
  }

  function claimToken () public {
    require (msg.sender != address(0));
    require (now >= endTime);
    require (deposited[msg.sender] != 0);
    
    uint tokens = deposited[msg.sender] * rate;

    token.mint(msg.sender, tokens);
    deposited[msg.sender] = 0;
    claimed[msg.sender] = tokens;

    LogClaim(msg.sender, tokens);
  }
  

  function refundWallet(address _wallet) onlyOwner public {
    refundFunds(_wallet);
  }

  function claimRefund() public {
  	require(now <= endTime);
    refundFunds(msg.sender);
  }

  function refundFunds(address _wallet) internal {
    require(_wallet != address(0));
    require(deposited[_wallet] != 0);
    uint256 depositedValue = deposited[_wallet];
    deposited[_wallet] = 0;
    _wallet.transfer(depositedValue);
    if(claimed[_wallet] != 0){
    	token.burn(_wallet, claimed[_wallet]);
    	claimed[_wallet] = 0;
    }
    Refunded(_wallet, depositedValue);
  }

}