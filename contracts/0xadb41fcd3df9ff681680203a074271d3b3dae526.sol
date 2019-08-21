pragma solidity ^0.4.11;

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

}
//TODO: Change the name of the token
contract XrpcToken is BasicToken,Ownable {

   using SafeMath for uint256;
   
   //TODO: Change the name and the symbol
   string public constant name = "XRPConnect";
   string public constant symbol = "XRPC";
   uint256 public constant decimals = 18;

   uint256 public constant INITIAL_SUPPLY = 10000000;
   event Debug(string message, address addr, uint256 number);
  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
   //TODO: Change the name of the constructor
    function XrpcToken(address wallet) public {
        owner = msg.sender;
        totalSupply = INITIAL_SUPPLY;
        tokenBalances[wallet] = INITIAL_SUPPLY * 10 ** 18;   //Since we divided the token into 10^18 parts
    }

    function mint(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[wallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer's balance
      tokenBalances[wallet] = tokenBalances[wallet].sub(tokenAmount);                        // subtracts amount from seller's balance
      Transfer(wallet, buyer, tokenAmount); 
    }
  function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
    }
}
contract Crowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  XrpcToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;


  // rates corresponding to each week in WEI not ETH (conversion is 1 ETH == 10^18 WEI)

  uint256 public week1Price = 2117;   
  uint256 public week2Price = 1466;
  uint256 public week3Price = 1121;
  uint256 public week4Price = 907;
  
  bool ownerAmountPaid = false; 

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, address _wallet) public {
    //TODO: Uncomment these before final deployment
    require(_startTime >= now);
    startTime = _startTime;
    
    //TODO: Comment this "startTime = now" before deployment -- this was for testing purposes only
    //startTime = now;   
    endTime = startTime + 30 days;
    
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
    
  }

    function sendOwnerShares(address wal) public
    {
        require(msg.sender == wallet);
        require(ownerAmountPaid == false);
        uint256 ownerAmount = 350000*10**18;
        token.mint(wallet, wal,ownerAmount);
        ownerAmountPaid = true;
    }
  // creates the token to be sold.
  // TODO: Change the name of the token
  function createTokenContract(address wall) internal returns (XrpcToken) {
    return new XrpcToken(wall);
  }


  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

  //determine the rate of the token w.r.t. time elapsed
  function determineRate() internal view returns (uint256 weekRate) {
    uint256 timeElapsed = now - startTime;
    uint256 timeElapsedInWeeks = timeElapsed.div(7 days);

    if (timeElapsedInWeeks == 0)
      weekRate = week1Price;        //e.g. 3 days/7 days will be 0.4-- after truncation will be 0

    else if (timeElapsedInWeeks == 1)
      weekRate = week2Price;        //e.g. 10 days/7 days will be 1.3 -- after truncation will be 1

    else if (timeElapsedInWeeks == 2)
      weekRate = week3Price;        //e.g. 20 days/7 days will be 2.4 -- after truncation will be 2

    else if (timeElapsedInWeeks == 3)
      weekRate = week4Price;        //e.g. 24 days/7 days will be 3.4 -- after truncation will be 3

    else
    {
        weekRate = 0;   //No tokens to be transferred - ICO time is over
    }
  }

  // low level token purchase function
  // Minimum purchase can be of 1 ETH
  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    //uint256 ethAmount = weiAmount.div(10 ** 18);

    // calculate token amount to be created
    rate = determineRate();
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(wallet, beneficiary, tokens); 
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
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
    
}