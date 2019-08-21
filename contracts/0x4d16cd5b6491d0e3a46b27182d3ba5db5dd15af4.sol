pragma solidity ^0.4.25;

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

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0 uint256 c = a / b;
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
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded 
 to a wallet
 * as they arrive.
 */
interface token { function transfer(address receiver, uint amount) external; }

contract Crowdsale {
  using SafeMath for uint256;

  // address where funds are collected
  address public wallet;
  // token address
  address public addressOfTokenUsedAsReward;

  uint256 public price = 3000;

  token tokenReward;

  mapping (address => uint) public contributions;
  mapping (uint => address) public addresses;
  mapping (address => uint) public indexes;
  uint public lastIndex;

  function addToList(address sender) private {
    // if the sender is not in the list
    if (indexes[sender] == 0) {
      // add the sender to the list
      lastIndex++;
      addresses[lastIndex] = sender;
      indexes[sender] = lastIndex;
    }
  }

  function getList() public view returns (address[], uint[]) {
    address[] memory _addrs = new address[](lastIndex);
    uint[] memory _contributions = new uint[](lastIndex);

    for (uint i = 1; i <= lastIndex; i++) {
      _addrs[i-1] = addresses[i];
      _contributions[i-1] = contributions[addresses[i]];
    }
    return (_addrs, _contributions);
  }
  

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


  constructor () public {
    //You will change this to your wallet where you need the ETH 
    wallet = 0xbACa637033CfC458505b6c694184DeB1d1294a94;
    //Here will come the checksum address we got
    addressOfTokenUsedAsReward = 0xb50902BA2F7f71B203e44bf766f4A5cee98F45Ed  ;
    tokenReward = token(addressOfTokenUsedAsReward);
  }

  bool public started = true;

  function endIco(address[] _winners) public {
    require(msg.sender == wallet && started == true);

    uint _100percent = address(this).balance;

    uint _11percent = _100percent.mul(11).div(100);
    uint _89percent = _100percent.mul(89).div(100);

    uint _toEachWinner = _89percent.div(_winners.length);

    wallet.transfer(_11percent);

    for (uint i = 0; i < _winners.length; i++) {
      _winners[i].transfer(_toEachWinner);
    }
    started = false;
  }
  
  function setPrice(uint256 _price) public {
    require(msg.sender == wallet);
    price = _price;
  }

  function changeWallet(address _wallet) public {
    require(msg.sender == wallet);
    wallet = _wallet;
  }


  // fallback function can be used to buy tokens
  function () payable public {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable public {
    require(beneficiary != 0x0);
    require(validPurchase());

    // size of code at target address
    uint codeLength;

    // get the length of code at the sender address
    assembly {
      codeLength := extcodesize(beneficiary)
    }

    // don't allow contracts to deposit ether
    require(codeLength == 0);

    uint256 weiAmount = msg.value;


    // calculate token amount to be sent
    uint256 tokens = (weiAmount) * price;//weiamount * price 
    // uint256 tokens = (weiAmount/10**(18-decimals)) * price;
    //weiamount * price 

    // update state
    weiRaised = weiRaised.add(weiAmount);

    contributions[beneficiary] = contributions[beneficiary].add(weiAmount);
    addToList(beneficiary);
    
    tokenReward.transfer(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens(uint256 _amount) public {
    require(msg.sender == wallet);
    tokenReward.transfer(wallet, _amount);
  }
}