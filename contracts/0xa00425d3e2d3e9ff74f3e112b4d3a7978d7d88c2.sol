pragma solidity ^0.4.18;

//
// imports from https://github.com/OpenZeppelin/zeppelin-solidity
//

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
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


//
//   GoPowerToken
//

contract GoPowerToken is StandardToken, Ownable {

  string public name = 'GoPower Token';
  string public symbol = 'GPT';
  uint public decimals = 18;


  //
  //   Distribution of tokens
  //

  uint constant TOKEN_TOTAL_SUPPLY_LIMIT = 700 * 1e6 * 1e18;
  uint constant TOKEN_SALE_LIMIT =         600 * 1e6 * 1e18;
  uint constant RESERVED_FOR_SETTLEMENTS =  50 * 1e6 * 1e18;
  uint constant RESERVED_FOR_TEAM =         30 * 1e6 * 1e18;
  uint constant RESERVED_FOR_BOUNTY =       20 * 1e6 * 1e18;

  address constant settlementsAddress = 0x9e6290C55faba3FFA269cCbF054f8D93586aaa6D;
  address constant teamAddress = 0xaA2E8DEbEAf429A21c59c3E697d9FC5bB86E126d;
  address constant bountyAddress = 0xdFa360FdF23DC9A7bdF1d968f453831d3351c33D;


  //
  //   Token rate calculation parameters
  //

  uint constant TOKEN_RATE_INITIAL =  0.000571428571428571 ether;           // 1/1750
  uint constant TOKEN_RATE_ICO_DAILY_INCREMENT = TOKEN_RATE_INITIAL / 200;  // 0.5%
  uint constant BONUS_PRESALE = 50;    // 50%
  uint constant BONUS_ICO_WEEK1 = 30;  // 30%
  uint constant BONUS_ICO_WEEK2 = 20;  // 20%
  uint constant BONUS_ICO_WEEK3 = 10;  // 10%
  uint constant BONUS_ICO_WEEK4 = 5;   // 5%
  uint constant MINIMUM_PAYABLE_AMOUNT = 0.0001 ether;
  uint constant TOKEN_BUY_PRECISION = 0.01e18;


  //
  //    State transitions
  //

  uint public presaleStartedAt;
  uint public presaleFinishedAt;
  uint public icoStartedAt;
  uint public icoFinishedAt;

  function presaleInProgress() private view returns (bool) {
    return ((presaleStartedAt > 0) && (presaleFinishedAt == 0));
  }

  function icoInProgress() private view returns (bool) {
    return ((icoStartedAt > 0) && (icoFinishedAt == 0));
  }

  modifier onlyDuringSale { require(presaleInProgress() || icoInProgress()); _; }
  modifier onlyAfterICO { require(icoFinishedAt > 0); _; }

  function startPresale() onlyOwner external returns(bool) {
    require(presaleStartedAt == 0);
    presaleStartedAt = now;
    return true;
  }

  function finishPresale() onlyOwner external returns(bool) {
    require(presaleInProgress());
    presaleFinishedAt = now;
    return true;
  }

  function startICO() onlyOwner external returns(bool) {
    require(presaleFinishedAt > 0);
    require(icoStartedAt == 0);
    icoStartedAt = now;
    return true;
  }

  function finishICO() onlyOwner external returns(bool) {
    require(icoInProgress());
    _mint_internal(settlementsAddress, RESERVED_FOR_SETTLEMENTS);
    _mint_internal(teamAddress, RESERVED_FOR_TEAM);
    _mint_internal(bountyAddress, RESERVED_FOR_BOUNTY);
    icoFinishedAt = now;
    tradeRobot = address(0);   // disable trade robot
    return true;
  }


  //
  //  Trade robot permissions
  //

  address public tradeRobot;
  modifier onlyTradeRobot { require(msg.sender == tradeRobot); _; }

  function setTradeRobot(address _robot) onlyOwner external returns(bool) {
    require(icoFinishedAt == 0); // the robot is disabled after the end of ICO
    tradeRobot = _robot;
    return true;
  }


  //
  //   Token sale logic
  //

  function _mint_internal(address _to, uint _amount) private {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(address(0), _to, _amount);
  }

  function mint(address _to, uint _amount) onlyDuringSale onlyTradeRobot external returns (bool) {
    _mint_internal(_to, _amount);
    return true;
  }

  function mintUpto(address _to, uint _newValue) onlyDuringSale onlyTradeRobot external returns (bool) {
    var oldValue = balances[_to];
    require(_newValue > oldValue);
    _mint_internal(_to, _newValue.sub(oldValue));
    return true;
  }

  function buy() onlyDuringSale public payable {
    assert(msg.value >= MINIMUM_PAYABLE_AMOUNT);
    var tokenRate = TOKEN_RATE_INITIAL;
    uint amount;

    if (icoInProgress()) { // main ICO

      var daysFromIcoStart = now.sub(icoStartedAt).div(1 days);
      tokenRate = tokenRate.add( TOKEN_RATE_ICO_DAILY_INCREMENT.mul(daysFromIcoStart) );
      amount = msg.value.mul(1e18).div(tokenRate);

      var weekNumber = 1 + daysFromIcoStart.div(7);
      if (weekNumber == 1) {
        amount = amount.add( amount.mul(BONUS_ICO_WEEK1).div(100) );
      } else if (weekNumber == 2) {
        amount = amount.add( amount.mul(BONUS_ICO_WEEK2).div(100) );
      } else if (weekNumber == 3) {
        amount = amount.add( amount.mul(BONUS_ICO_WEEK3).div(100) );
      } else if (weekNumber == 4) {
        amount = amount.add( amount.mul(BONUS_ICO_WEEK4).div(100) );
      }
    
    } else {  // presale

      amount = msg.value.mul(1e18).div(tokenRate);
      amount = amount.add( amount.mul(BONUS_PRESALE).div(100) );
    }

    amount = amount.add(TOKEN_BUY_PRECISION/2).div(TOKEN_BUY_PRECISION).mul(TOKEN_BUY_PRECISION);

    require(totalSupply.add(amount) <= TOKEN_SALE_LIMIT);
    _mint_internal(msg.sender, amount);
  }

  function () external payable {
    buy();
  }

  function collect() onlyOwner external {
    msg.sender.transfer(this.balance);
  }


  //
  //   Token transfer operations are locked until the end of ICO
  //

  // this one is much more gas-effective because of the 'external' visibility
  function transferExt(address _to, uint256 _value) onlyAfterICO external returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transfer(address _to, uint _value) onlyAfterICO public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) onlyAfterICO public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint _value) onlyAfterICO public returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) onlyAfterICO public returns (bool) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) onlyAfterICO public returns (bool) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

}