pragma solidity ^0.4.14;


//SatanCoin token buying contract


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

//SatanCoin token buying contract

contract SatanCoin is StandardToken {
  
  using SafeMath for uint;

  string public constant name = "SatanCoin";
  string public constant symbol = "SATAN";
  uint public constant decimals = 0;

  address public owner = msg.sender;
  //.0666 ether = 1 SATAN
  uint public constant rate = .0666 ether;

  uint public roundNum = 0;
  uint public constant roundMax = 74;
  uint public roundDeadline;
  bool public roundActive = false;
  uint tokenAmount;
  uint roundBuyersNum;

  mapping(uint => address) buyers;

  event Raffled(uint roundNumber, address winner, uint amount);
  event RoundStart(uint roundNumber);
  event RoundEnd(uint roundNumber);

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function ()
    payable
  {
    createTokens(msg.sender);
  }

  function createTokens(address receiver)
    public
    payable
  {
    //Make sure there is an active buying round
    require(roundActive);
    //Make sure greater than 0 was sent
    require(msg.value > 0);
    //Make sure the amount is a multiple of .0666 ether
    require((msg.value % rate) == 0);

    tokenAmount = msg.value.div(rate);

    //Make sure no more than 74 Satancoins issued per round
    require(tokenAmount <= getRoundRemaining());
    //Make sure that no more than 666 SatanCoins can be issued.
    require((tokenAmount+totalSupply) <= 666);
    //Extra precaution to contract attack
    require(tokenAmount >= 1);

    //Issue Tokens
    totalSupply = totalSupply.add(tokenAmount);
    balances[receiver] = balances[receiver].add(tokenAmount);

    //Record buyer per token bought this round 
    for(uint i = 0; i < tokenAmount; i++)
    {
      buyers[i.add(getRoundIssued())] = receiver;
    }

    //Send Ether to owner
    owner.transfer(msg.value);
  }

  function startRound()
    public
    onlyOwner
    returns (bool)
  {
    require(!roundActive);//last round must have been ended
    require(roundNum<9); //only 9 rounds may occur
     
    roundActive = true;
    roundDeadline = now + 6 days;
    roundNum++;

    RoundStart(roundNum);
    return true;
  }

  function endRound()
    public
    onlyOwner
    returns (bool)
  {
     require(roundDeadline < now);
     //If no tokens sold, give full amount to owner
    if(getRoundRemaining() == 74)
    {
      totalSupply = totalSupply.add(74);
      balances[owner] = balances[owner].add(74);
    } //raffles off remaining tokens if any are left
    else if(getRoundRemaining() != 0) assert(raffle(getRoundRemaining()));

    roundActive = false;

    RoundEnd(roundNum);
    return true;
  }

  function raffle(uint raffleAmount)
    private
    returns (bool)
  {
    //Assign random number to a token bought this round and make the buyer the winner
    uint randomIndex = uint(block.blockhash(block.number))%(roundMax-raffleAmount)+1;
    address receiver = buyers[randomIndex];

    totalSupply = totalSupply.add(raffleAmount);
    balances[receiver] = balances[receiver].add(raffleAmount);

    Raffled(roundNum, receiver, raffleAmount);
    return true;
  }

  function getRoundRemaining()
    public
    constant
    returns (uint)
  {
    return roundNum.mul(roundMax).sub(totalSupply);
  }

   function getRoundIssued()
    public
    constant
    returns (uint)
  {
    return totalSupply.sub((roundNum-1).mul(roundMax));
  }
}