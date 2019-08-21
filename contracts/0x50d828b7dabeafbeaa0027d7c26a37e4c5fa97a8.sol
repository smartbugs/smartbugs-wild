pragma solidity ^0.4.18;

/**
 * Math operations with safety checks
 */
contract SafeMath {

  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a && c >= b);
    return c;
  }

}

/**
 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 *
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is SafeMath {

  uint256 public totalSupply;

  /* Actual balances of token holders */
  mapping(address => uint) balances;

  /* approve() allowances */
  mapping (address => mapping (address => uint)) allowed;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  /**
   *
   * Fix for the ERC20 short address attack
   *
   * http://vessenes.com/the-erc20-short-address-attack-explained/
   */
  modifier onlyPayloadSize(uint256 size) {
     require(msg.data.length == size + 4);
     _;
  }

  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) {
    require(_to != 0);
    uint256 balanceFrom = balances[msg.sender];
    require(_value <= balanceFrom);

    // SafeMath safeSub will throw if there is not enough balance.
    balances[msg.sender] = safeSub(balanceFrom, _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != 0);
    uint256 allowToTrans = allowed[_from][msg.sender];
    uint256 balanceFrom = balances[_from];
    require(_value <= balanceFrom);
    require(_value <= allowToTrans);

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balanceFrom, _value);
    allowed[_from][msg.sender] = safeSub(allowToTrans, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
    // require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * Atomic increment of approved spending
   *
   * Works around https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   */
  function addApproval(address _spender, uint256 _addedValue)
  onlyPayloadSize(2 * 32)
  public returns (bool success) {
      uint256 oldValue = allowed[msg.sender][_spender];
      allowed[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  /**
   * Atomic decrement of approved spending.
   *
   * Works around https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function subApproval(address _spender, uint256 _subtractedValue)
  onlyPayloadSize(2 * 32)
  public returns (bool success) {

      uint256 oldVal = allowed[msg.sender][_spender];

      if (_subtractedValue > oldVal) {
          allowed[msg.sender][_spender] = 0;
      } else {
          allowed[msg.sender][_spender] = safeSub(oldVal, _subtractedValue);
      }
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract MigrationAgent {
  function migrateFrom(address _from, uint256 _value) public;
}

contract UpgradeableToken is Ownable, StandardToken {
  address public migrationAgent;

  /**
   * Somebody has upgraded some of his tokens.
   */
  event Upgrade(address indexed from, address indexed to, uint256 value);

  /**
   * New upgrade agent available.
   */
  event UpgradeAgentSet(address agent);

    // Migrate tokens to the new token contract
    function migrate() public {
        require(migrationAgent != 0);
        uint value = balances[msg.sender];
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Upgrade(msg.sender, migrationAgent, value);
    }

    function () public payable {
      require(migrationAgent != 0);
      require(balances[msg.sender] > 0);
      migrate();
      msg.sender.transfer(msg.value);
    }

    function setMigrationAgent(address _agent) onlyOwner external {
        migrationAgent = _agent;
        UpgradeAgentSet(_agent);
    }

}
contract SABToken is UpgradeableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();


  address public allTokenOwnerOnStart;
  string public constant name = "SABCoin";
  string public constant symbol = "SAB";
  uint256 public constant decimals = 6;
  

  function SABToken() public {
    allTokenOwnerOnStart = msg.sender;
    totalSupply = 100000000000000;
    balances[allTokenOwnerOnStart] = totalSupply;
    Mint(allTokenOwnerOnStart, totalSupply);
    Transfer(0x0, allTokenOwnerOnStart ,totalSupply);
    MintFinished();
  }
  
}

// ============================================================================

contract IcoSABToken is Ownable, SafeMath {
  address public wallet;
  address public allTokenAddress;
  bool public emergencyFlagAndHiddenCap = false;
  // UNIX format
  uint256 public startTime = 1515888000; // 14 Dec 2017 19:00:00 GMT
  uint256 public endTime =   1518998400; // 13 Jan 2018 19:00:00 GMT

  uint256 public USDto1ETH = 1300; // 1 ether = 1300$
  uint256 public price; 
  uint256 public totalTokensSold = 0;
  uint256 public constant maxTokensToSold = 60000000000000; // 60% * (100 000 000.000 000)
  SABToken public token;

  function IcoSABToken(address _wallet, SABToken _token) public {
    wallet = _wallet;
    token = _token;
    allTokenAddress = token.allTokenOwnerOnStart();
    price = 1 ether / USDto1ETH / 1000000;
  }

  function () public payable {
    require(now <= endTime && now >= startTime);
    require(!emergencyFlagAndHiddenCap);
    require(totalTokensSold < maxTokensToSold);
    uint256 value = msg.value;
    uint256 tokensToSend = safeDiv(value, price);
    require(tokensToSend >= 40000000 && tokensToSend <= 500000000000);
    uint256 valueToReturn = safeSub(value, tokensToSend * price);
    uint256 valueToWallet = safeSub(value, valueToReturn);

    wallet.transfer(valueToWallet);
    if (valueToReturn > 0) {
      msg.sender.transfer(valueToReturn);
   }
    token.transferFrom(allTokenAddress, msg.sender, tokensToSend);
    totalTokensSold += tokensToSend;
  }

    function ChangeUSDto1ETH(uint256 _USDto1ETH) onlyOwner public {
        USDto1ETH = _USDto1ETH;
        ChangePrice();
    }

  function ChangePrice() onlyOwner public {
    uint256 priceWeiToUSD = 1 ether / USDto1ETH;
    uint256 price1mToken = priceWeiToUSD / 1000000; // decimals = 6
    if ( now <= startTime + 15 days) {
      price = price1mToken * 1 / 4; // 1.000000Token = 0.25 $ first 5 days
    } 
    else {
      if ( now <= startTime + 25 days ) {
        price = price1mToken * 1 / 2; // 1.000000Token = 0.5 $ next
      } 
      else {
        price = price1mToken; // 1.000000Token = 1.0 $ to end
      }
    }

  }

    function ChangeStart(uint _startTime) onlyOwner public {
        startTime = _startTime;
    }

    function ChangeEnd(uint _endTime) onlyOwner public {
        endTime = _endTime;
    }


  function emergencyAndHiddenCapToggle() onlyOwner public {
    emergencyFlagAndHiddenCap = !emergencyFlagAndHiddenCap;
  }

}