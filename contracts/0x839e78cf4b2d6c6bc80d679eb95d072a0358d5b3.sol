pragma solidity ^0.4.18;

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

contract Token {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
    owner = newOwner;
  }

}

contract Pausable is Ownable {

  bool public endITO = false;

  uint public endDate = 1530360000;  // June 30 2018 Token transfer enable

  /**
   * @dev modifier to allow actions only when the contract IS not paused
   */
  modifier whenNotPaused() {
    require(now >= endDate || endITO);
    _;
  }

  function unPause() public onlyOwner returns (bool) {
      endITO = true;
      return endITO;
  }

}

contract StandardToken is Token, Pausable {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) internal allowed;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
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


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
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
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
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
  function increaseApproval (address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract KeeppetToken is BurnableToken {

    string public constant name = "KeepPet Token";
    string public constant symbol = "PET";
    uint8 public constant decimals = 0;

    uint256 public constant INITIAL_SUPPLY = 3500000;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function KeeppetToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[owner] = INITIAL_SUPPLY;
    }

    function sendTokens(address _to, uint _amount) external onlyOwner {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
    }
}

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

contract SalesManager is Ownable {
    using SafeMath for uint256;

    /**
     * Pre-ICO
     * Start date 31 December 2017 (12:00 GMT)
     * End date or Hard Cap,  15 January 2018 (12:00 GMT)
     * Token amount 3500000
     * min eth = 0,0002
     * token price = 1,5$
     * transfer to wallet = NEED wallet
     * */
    // TODO: set actual dates before deploy
    uint public constant etherCost = 750;
    uint public constant startDate = 1514721600;
    uint public constant endDate = 1516017600;
    uint256 public constant softCap = 250000 / etherCost * 1 ether;
    uint256 public constant hardCap = 1050000 / etherCost * 1 ether;

    struct Stat {
        uint256 currentFundraiser;
        uint256 additionalEthAmount;
        uint256 ethAmount;
        uint txCounter;
    }

    Stat public stat;

    // ETH 750$ 13.12.2017 token price 1.5$
    // TODO: set actual price before deploy
    uint256 public constant tokenPrice = uint256(15 * 1 ether).div(etherCost * 10);
    RefundVault public refundVault;
    KeeppetToken public keeppetToken;

    /**
     * @dev modifier to allow actions only when Pre-ICO end date is now
     */
    modifier isFinished() {
        require(now >= endDate);
        _;
    }

    function SalesManager(address wallet) public {
        require(wallet != address(0));
        keeppetToken = new KeeppetToken();
        refundVault = new RefundVault(wallet);
    }

    function () payable public {
       require(msg.value >= 2 * 10**15  && now >= startDate && now < endDate);
       require(stat.ethAmount + stat.additionalEthAmount < hardCap);
       buyTokens();
    }

    uint bonusX2Stage1 = softCap;
    uint bonusX2Stage2 = 525000 / etherCost * 1 ether;
    uint bonusX2Stage3 = 787500 / etherCost * 1 ether;
    uint bonusX2Stage4 = hardCap;

    function checkBonus(uint256 amount) public constant returns(bool) {
        uint256 current = stat.ethAmount + stat.additionalEthAmount;
        uint256 withAmount = current.add(amount);

        return ((current < bonusX2Stage1 && bonusX2Stage1 <= withAmount)
        || (current < bonusX2Stage2 && bonusX2Stage2 <= withAmount)
        || (current < bonusX2Stage3 && bonusX2Stage3 <= withAmount)
        || (current < bonusX2Stage4 && bonusX2Stage4 <= withAmount));
    }

    uint private bonusPeriod = 1 days;

    function countMultiplyBonus(uint256 amount) internal returns (uint) {
        if (now >= startDate && now <= startDate + bonusPeriod) { // From 31 december 2017 to 1 january 2018 (12:00 GMT) — x5
            return 5;
        }
        if (now > startDate + bonusPeriod && now <= startDate + 2 * bonusPeriod) { // From 1 january 2017 to 2 january 2018 (12:00 GMT) — x4
            return 4;
        }
        if (now > startDate + 2 * bonusPeriod && now <= startDate + 3 * bonusPeriod) { // From 2 january 2017 to 3 january 2018 (12:00 GMT) — x3
            return 3;
        }
        if (now > startDate + 3 * bonusPeriod && now <= startDate + 4 * bonusPeriod) { // From 3 january 2017 to 4 january 2018 (12:00 GMT) — x2
            return 2;
        }
        if (checkBonus(amount)) {
            return 2;
        }
        return 1;
    }

    function buyTokens() internal {
        uint256 tokens = msg.value.div(tokenPrice);
        uint256 balance = keeppetToken.balanceOf(this);
        tokens = tokens.mul(countMultiplyBonus(msg.value));

        if (balance < tokens) {
            uint256 tempTokenPrice = msg.value.div(tokens); // Temp token price for tokens which were bought.
            uint256 toReturn = tempTokenPrice.mul(tokens.sub(balance)); // Amount for returing.
            sendTokens(balance, msg.value - toReturn);
            msg.sender.transfer(toReturn);
            return;
        }
        sendTokens(tokens, msg.value);
    }

    function sendTokens(uint256 _amount, uint256 _ethers) internal {
        keeppetToken.sendTokens(msg.sender, _amount);
        RefundVault refundVaultContract = RefundVault(refundVault);
        stat.currentFundraiser += _amount;
        stat.ethAmount += _ethers;
        stat.txCounter += 1;
        refundVaultContract.deposit.value(_ethers)(msg.sender);
    }

    function sendTokensManually(address _to, uint256 ethAmount, uint multiplier) public onlyOwner {
        require(multiplier < 6); // can be multiplier more then in five times.
        require(_to != address(0) && now <= endDate + 3 days); // available to send 72 hours after endDate
        uint256 tokens = ethAmount.div(tokenPrice).mul(multiplier);
        keeppetToken.sendTokens(_to, tokens);
        stat.currentFundraiser += tokens;
        stat.additionalEthAmount += ethAmount;
        stat.txCounter += 1;
    }

    function checkFunds() public isFinished onlyOwner {
        RefundVault refundVaultContract = RefundVault(refundVault);
        uint256 leftValue = keeppetToken.balanceOf(this);
        keeppetToken.burn(leftValue);
        uint256 fullAmount = stat.additionalEthAmount.add(stat.ethAmount);
        if (fullAmount < softCap) {
            // If soft cap is not reached enable refunds
            refundVaultContract.enableRefunds();
        } else {
            // Send eth to multisig
            refundVaultContract.close();
        }
    }

    function unPauseToken() public onlyOwner {
        require(keeppetToken.unPause());
    }
}