pragma solidity ^0.4.18;

// File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20Basic.sol

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules/zeppelin-solidity/contracts/token/BasicToken.sol

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: node_modules/zeppelin-solidity/contracts/token/ERC20.sol

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: node_modules/zeppelin-solidity/contracts/token/StandardToken.sol

contract StandardToken is ERC20, BasicToken {
  event ChangeBalance (address from, uint256 fromBalance, address to, uint256 toBalance, uint256 seq);

  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 internal seq = 0;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    ChangeBalance (_from, balances[_from], _to, balances[_to], ++seq);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

// File: node_modules/zeppelin-solidity/contracts/token/MintableToken.sol

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);

  function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    ChangeBalance (address(0), 0, _to, balances[_to], ++seq);
    return true; 
  }
}

// File: node_modules/zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // ICO Phases
  uint256[] starts;
  uint256[] ends;
  uint256[] rates;

  // Purchase counter
  uint256 internal seq;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  uint256 public cap;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 seq);
  
  function Crowdsale(uint256[] _startTime, uint256[] _endTime, uint256[] _rates, address _wallet, uint256 _cap) public {
    // require(_startTime >= now);

    for (uint8 i = 0; i < starts.length; i ++) {
      require(_endTime[i] >= _startTime[i]);
      require(_rates[i] > 0);
      require(_wallet != address(0));
    }

    cap = _cap;
    starts = _startTime;
    ends = _endTime;
    rates = _rates;

    // token = createTokenContract();
    
    
    startTime = _startTime[0];
    endTime = _endTime[_endTime.length - 1];
    rate = _rates[0];
    wallet = _wallet;
  }

  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  function () external payable {
    //minimum is 1 Ether
    require (msg.value >= 1000000000000000000);
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 arrayLength = starts.length;


    // calculate token amount to be created
    for (uint8 i = 0; i < arrayLength; i ++) {
      if (now >= starts[i] && now <= ends[i]) {
        rate = rates[i];
        break;
      }
    }    
    uint256 tokens = weiAmount.mul(rate);
    require (checkCap(tokens));

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, ++seq);

    forwardFunds();
  }

  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    
    return withinPeriod && nonZeroPurchase;
  }

  function hasEnded() public view returns (bool) {
    uint256 tokenSupply = token.totalSupply();
    bool capReached = tokenSupply >= cap;
    bool overTime = now > endTime;
    return capReached && overTime; //now > endTime;
  }

  function checkCap(uint256 tokens) internal view returns (bool) {
    uint256 issuedTokens = token.totalSupply();
    return (issuedTokens.add(tokens) <= cap);
  }
}

// File: node_modules/zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    Finalized();

    isFinalized = true;
  }
}

// File: contracts/OMXToken.sol

contract OMXToken is MintableToken {
    string public constant name = "OMEX";
    string public constant symbol = "OMX";
    uint8 public constant decimals = 18;

    function OMXToken () public MintableToken () {
    }


}

// File: contracts/OMXCrowdsale.sol

contract OMXCrowdsale is FinalizableCrowdsale {
    uint256[] start = [1514646000, 1515942000, 1516806000];
    uint256[] end = [1515941999, 1516805999, 1517669999];
    uint256[] rate = [1400, 1200, 1000];
    address companyWallet;
    address tokenAddress;

    uint256 salesCap    = 300000000000000000000000000;
    uint256 cap         = 500000000000000000000000000;

  function OMXCrowdsale(address _wallet, address _token) public 
      FinalizableCrowdsale() Crowdsale(start, end, rate, _wallet, salesCap)
  {
      companyWallet = _wallet;
      tokenAddress = _token;
      token = createTokenContract();
  }

  function createTokenContract() internal returns (MintableToken) {
      OMXToken omxInstance;
      omxInstance = OMXToken (address(tokenAddress));
      return omxInstance;
  }

  function finalize() onlyOwner public {
      // mint company share of tokens
      token.mint(companyWallet, cap - token.totalSupply());
      super.finalize();
  }
}