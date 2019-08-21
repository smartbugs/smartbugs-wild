pragma solidity ^0.4.18;

contract Owned {
    address public owner;
    address receiver;

    function Owned() public {
      owner = msg.sender;
      receiver = owner;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
      require(newOwner != address(0));
      owner = newOwner;
    }

    function changeReceiver(address newReceiver) onlyOwner public {
      require(newReceiver != address(0));
      receiver =  newReceiver;
    }
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
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract AdminToken is Owned{
  
  bool onSale = true;

  uint stageNumber = 1;
  uint256 tokenPrice = 1000;

  
  //Enable token sale;
  function sell() public onlyOwner {
    require (!onSale && stageNumber < 5);                // cannot activated sale when ongoing/ stage already reach 5

    stageNumber += 1;                                    // move to next stage

    if (stageNumber != 5) {
      tokenPrice -= 100;                                 // stage 2-4 price will be 100 less then previous price
    }
    else{
      tokenPrice -= 200;                                 // stage 5 price will be 200 less then stage 4 price
    }
    onSale = true;
  }

  //disable token sale
  function _stopSale() internal {
    onSale = false;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken
 */
contract AdminBasicToken is ERC20Basic, AdminToken {

  using SafeMath for uint256;

  mapping (address => uint256) balances;

  /**
  * Internal transfer, only can be called by this contract
  */
  function _transfer(address _from, address _to, uint _value) internal {

    require (_to != 0x0 &&                                            // Prevent transfer to 0x0 address.
           balances[_from] >= _value &&                               // Check if the sender has enough
           balances[_to] + _value > balances[_to]);                   // Check for overflows
                                       
    balances[_from] = balances[_from].sub(_value);                    // Subtract from the sender
    balances[_to] = balances[_to].add(_value);                        // Add the same to the recipient
    Transfer(_from, _to, _value);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);
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

contract StandardToken is ERC20, AdminBasicToken {

  mapping (address => mapping (address => uint256)) allowed;
  
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= allowed[_from][msg.sender]);     // Check allowance
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {

    //  To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
  	require(_addedValue !=0 && allowed[msg.sender][_spender] > 0);
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
  	require(_subtractedValue !=0 && allowed[msg.sender][_spender] > 0);
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract SackWengerCoin is StandardToken {

  // Public variables of the token
  string public name =  "Sack Wenger Coin";
  string public symbol = "AXW";
  uint8 public decimals = 18;
  uint256 ETHreceived = 0;

  uint256 eachStageSupply = 20000000 * 10 ** uint256(decimals);   // Target of each stage is 20,000,000AXW

  uint256 stageTokenIssued = 0;


  /* Initializes contract */
  function SackWengerCoin() public {
    totalSupply = 0;                                    // Initial supply = 0; No coin pre-exist!
  }

  function getStats() public constant returns (uint, uint256, uint256, uint256, uint256, bool) {
    return (stageNumber, stageTokenIssued, tokenPrice, ETHreceived, totalSupply, onSale);
  }

  function _createTokenAndSend(uint256 price) internal {
    uint newTokenIssued = msg.value * price;            // calculates new token amount by stageOnePrice
    totalSupply += newTokenIssued;
    stageTokenIssued += newTokenIssued;
    balances[msg.sender] += newTokenIssued;            // makes the transfers

    if (stageTokenIssued >= eachStageSupply) {
      _stopSale();                                     // stop selling coins when stage target is met
      stageTokenIssued = 0;
    }
  }

  function () payable public {
    require (onSale && msg.value != 0);

    receiver.transfer(msg.value);

    ETHreceived += msg.value;
    _createTokenAndSend(tokenPrice);
  }
}