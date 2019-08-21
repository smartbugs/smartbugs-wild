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
  address public owner;
  address public oldOwner;
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
  modifier onlyOldOwner() {
    require(msg.sender == oldOwner || msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    oldOwner = owner;
    owner = newOwner;
  }
  function backToOldOwner() onlyOldOwner public {
    require(oldOwner != address(0));
    owner = oldOwner;
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
    wallet = 0x00B95A5D838F02b12B75BE562aBF7Ee0100410922b;
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
  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }
}
contract HeartBoutPreICO is CappedCrowdsale, Ownable {
    using SafeMath for uint256;
    
    // The token address
    address public token;
    uint256 public minCount;
    // Bind User Account and Address Wallet
    mapping(string => address) bindAccountsAddress;
    mapping(address => string) bindAddressAccounts;
    string[] accounts;
    event GetBindTokensAccountEvent(address _address, string _account);
    function HeartBoutPreICO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap, uint256 _minCount) public
    CappedCrowdsale(_startTime, _endTime, _rate, _wallet, _cap)
    {
        token = 0x00305cB299cc82a8A74f8da00AFA6453741d9a15Ed;
        minCount = _minCount;
    }
    // fallback function can be used to buy tokens
    function () payable public {
    }
    // low level token purchase function
    function buyTokens(string _account) public payable {
        require(!stringEqual(_account, ""));
        require(validPurchase());
        require(msg.value >= minCount);
        // throw if address was bind with another account
        if(!stringEqual(bindAddressAccounts[msg.sender], "")) {
            require(stringEqual(bindAddressAccounts[msg.sender], _account));
        }
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        // Mint only message sender address
        require(token.call(bytes4(keccak256("mint(address,uint256)")), msg.sender, tokens));
        bindAccountsAddress[_account] = msg.sender;
        bindAddressAccounts[msg.sender] = _account;
        accounts.push(_account);
        // update state
        weiRaised = weiRaised.add(weiAmount);
        forwardFunds();
    }
    function getEachBindAddressAccount() onlyOwner public {
        // get transfered account and addresses
        for (uint i = 0; i < accounts.length; i++) {
            GetBindTokensAccountEvent(bindAccountsAddress[accounts[i]], accounts[i]);
        }
    }
    function getBindAccountAddress(string _account) public constant returns (address) {
        return bindAccountsAddress[_account];
    }
    function getBindAddressAccount(address _accountAddress) public constant returns (string) {
        return bindAddressAccounts[_accountAddress];
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