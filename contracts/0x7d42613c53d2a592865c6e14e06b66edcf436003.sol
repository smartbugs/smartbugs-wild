pragma solidity ^0.4.18;

/**
 * @title NeuralTrade Network Tokensale Contract
 * @dev Symbol: Network
 * @dev Name: NeuralTrade Token
 * @dev Total Supply: 10000000
 * @dev Decimals: 2
 * @dev (c) by NeuralTrade Network
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    uint256 c = a + b; assert(c >= a);
    return c;
  }

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

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
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param _owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 */
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
    emit Transfer(_from, _to, _value);
    return true;
  }

 /**
  * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

 /**
  * approve should be called when allowed[_spender] == 0. To increment
  * allowed value is better to use this function to avoid 2 calls (and wait until
  * the first transaction is mined)
  */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function () public payable {
    revert();
  }

}

/**
 * @title Owned
 */
contract Owned {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */

contract BurnableToken is StandardToken, Owned {

  /**
  * @dev Burns a specific amount of tokens.
  * @param _value The amount of token to be burned.
  */

  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(burner, _value);
  }

  event Burn(address indexed burner, uint indexed value);

}

contract NeuralTradeToken is BurnableToken {

    string public constant name = "Neural Trade Token";

    string public constant symbol = "NET";

    uint32 public constant decimals = 2;

    uint256 public INITIAL_SUPPLY = 10000000 * 1 ether;

    constructor() public {
      totalSupply = INITIAL_SUPPLY;
      balances[msg.sender] = INITIAL_SUPPLY;
    }

}

contract NETCrowdsale is Owned {
   using SafeMath for uint;

    address vaulted;

    uint restrictedPercent;

    address restricted;

    NeuralTradeToken public token = new NeuralTradeToken();

    uint start;

    uint period = 140;

    uint hardcap;

    uint rate;

    uint minPurchase;

    uint earlyBirdBonus;

    constructor() public payable {
        owner = msg.sender;
        vaulted = 0xD1eA8ACE84C56BF21a1b481Ca492b6aA65D95830;
        restricted = 0xBbC18b0824709Fd3E0fA3aF49b812E5B6efAC3c1;
        restrictedPercent = 50;
        rate = 100000000000000000000;
        start = 1549843200;
        period = 140;
        minPurchase = 0.1 ether;
        earlyBirdBonus = 1 ether;
    }

    modifier saleIsOn() {
    	require(now > start && now < start + period * 1 days);
    	_;
    }

    modifier purchaseAllowed() {
        require(msg.value >= minPurchase);
        _;
    }

    function createTokens() saleIsOn purchaseAllowed public payable {
        vaulted.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(now < start + (period * 1 days).div(10) && msg.value >= earlyBirdBonus) {
          bonusTokens = tokens.div(1);
        } else if(now < start + (period * 1 days).div(10).mul(2)) {
          bonusTokens = tokens.div(2);
        } else if(now >= start + (period * 1 days).div(10).mul(2) && now < start + (period * 1 days).div(10).mul(4)) {
          bonusTokens = tokens.div(4);
        } else if(now >= start + (period * 1 days).div(10).mul(4) && now < start + (period * 1 days).div(10).mul(8)) {
          bonusTokens = tokens.div(5);
        }
        uint tokensWithBonus = tokens.add(bonusTokens);
        token.transfer(msg.sender, tokensWithBonus);

        uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
        token.transfer(restricted, restrictedTokens);

        if(msg.data.length == 20) {
          address referer = bytesToAddress(bytes(msg.data));
          require(referer != msg.sender);
          uint refererTokens = tokens.mul(10).div(100);
          token.transfer(referer, refererTokens);
        }
    }

    function bytesToAddress(bytes source) internal pure returns(address) {
        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
          result += uint8(source[i-1])*mul;
          mul = mul*256;
        }
        return address(result);
    }

    function() external payable {
        createTokens();
    }

}