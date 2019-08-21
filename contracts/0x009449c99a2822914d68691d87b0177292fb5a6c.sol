pragma solidity ^0.4.18;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
  address public admin;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    admin = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == admin);
    _;
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
 contract Crowdsale {
  using SafeMath for uint256;
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;
  // address where funds are collected
  address public wallet;
  // how many token units a buyer gets per wei
  uint256 public rate;
  // amount of raised money in wei
  uint256 public weiRaised;
  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = 0x00b95a5d838f02b12b75be562abf7ee0100410922b;
  }
  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  // @return true if the transaction can mint tokens
  function validMintPurchase(uint256 _value) internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = _value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
}
/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
 contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;
  uint256 public cap;
  function CappedCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap) public
  Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    require(_cap > 0);
    cap = _cap;
  }
  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }
  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can mint at the moment
  function validMintPurchase(uint256 _value) internal constant returns (bool) {
    bool withinCap = weiRaised.add(_value) <= cap;
    return super.validMintPurchase(_value) && withinCap;
  }
  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }
}
contract HeartBoutToken {
   function mint(address _to, uint256 _amount, string _account) public returns (bool);
}
contract HeartBoutPreICO is CappedCrowdsale, Ownable {
    using SafeMath for uint256;
    
    // The token address
    address public token;
    uint256 public minCount;
    function HeartBoutPreICO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap, uint256 _minCount) public
    CappedCrowdsale(_startTime, _endTime, _rate, _wallet, _cap)
    {
        token = 0x00f5b36df8732fb5a045bd90ab40082ab37897b841;
        minCount = _minCount;
    }
    // fallback function can be used to buy tokens
    function () payable public {}
    // low level token purchase function
    function buyTokens(string _account) public payable {
        require(!stringEqual(_account, ""));
        require(validPurchase());
        require(msg.value >= minCount);
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        // Mint only message sender address
        HeartBoutToken token_contract = HeartBoutToken(token);
        token_contract.mint(msg.sender, tokens, _account);
        // update state
        weiRaised = weiRaised.add(weiAmount);
        forwardFunds();
    }
    // mintTokens function
    function mintTokens(address _to, uint256 _amount, string _account) onlyOwner public {
        require(!stringEqual(_account, ""));
        require(validMintPurchase(_amount));
        require(_amount >= minCount);
        uint256 weiAmount = _amount;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        // Mint only message sender address
        HeartBoutToken token_contract = HeartBoutToken(token);
        token_contract.mint(_to, tokens, _account);
        // update state
        weiRaised = weiRaised.add(weiAmount);
    }
    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    function stringEqual(string _a, string _b) internal pure returns (bool) {
        return keccak256(_a) == keccak256(_b);
    }
    // change wallet
    function changeWallet(address _wallet) onlyOwner public {
        wallet = _wallet;
    }
    // Remove contract
    function removeContract() onlyOwner public {
        selfdestruct(wallet);
    }
}