pragma solidity ^0.4.18;

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
    assert(b > 0); // Solidity automatically throws when dividing by 0
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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}
/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
contract ERC20Basic  {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Pausable {
  using SafeMath for uint256;
  uint256 public etherRaised;
  mapping(address => uint256) balances;
  address companyReserve;
  uint256 deployTime;
  modifier isUserAbleToTransferCheck(uint256 _value) {
  if(msg.sender == companyReserve){
          uint256 balanceRemaining = balanceOf(companyReserve);
          uint256 timeDiff = now - deployTime;
          uint256 totalMonths = timeDiff / 30 days;
          if(totalMonths == 0){
              totalMonths  = 1;
          }
          uint256 percentToWitdraw = totalMonths * 5;
          uint256 tokensToWithdraw = ((25000000 * (10**18)) * percentToWitdraw)/100;
          uint256 spentTokens = (25000000 * (10**18)) - balanceRemaining;
          if(spentTokens + _value <= tokensToWithdraw){
              _;
          }
          else{
              revert();
          }
        }else{
           _;
        }
    }
    
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public  isUserAbleToTransferCheck(_value) returns (bool) {
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
contract BurnableToken is BasicToken {
    using SafeMath for uint256;
  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply= totalSupply.sub(_value);
    Burn(burner, _value);
  }
}
contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public isUserAbleToTransferCheck(_value) returns (bool) {
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


contract POTENTIAM is StandardToken, Destructible {
    string public constant name = "POTENTIAM";
    using SafeMath for uint256;
    uint public constant decimals = 18;
    string public constant symbol = "PTM";
    uint public priceOfToken=250000000000000;//1 eth = 4000 PTM
    address[] allParticipants;
   
    uint tokenSales=0;
    uint256 public firstWeekPreICOBonusEstimate;
    uint256  public secondWeekPreICOBonusEstimate;
    uint256  public firstWeekMainICOBonusEstimate;
    uint256 public secondWeekMainICOBonusEstimate;
    uint256 public thirdWeekMainICOBonusEstimate;
    uint256 public forthWeekMainICOBonusEstimate;
    uint256 public firstWeekPreICOBonusRate;
    uint256 secondWeekPreICOBonusRate;
    uint256 firstWeekMainICOBonusRate;
    uint256 secondWeekMainICOBonusRate;
    uint256 thirdWeekMainICOBonusRate;
    uint256 forthWeekMainICOBonusRate;
    uint256 totalWeiRaised = 0;
    function POTENTIAM()  public {
       totalSupply = 100000000 * (10**decimals);  // 
       owner = msg.sender;
       companyReserve =   0xd311cB7D961B46428d766df0eaE7FE83Fc8B7B5c;
       balances[msg.sender] += 75000000 * (10 **decimals);
       balances[companyReserve]  += 25000000 * (10**decimals);
       firstWeekPreICOBonusEstimate = now + 7 days;
       deployTime = now;
       secondWeekPreICOBonusEstimate = firstWeekPreICOBonusEstimate + 7 days;
       firstWeekMainICOBonusEstimate = firstWeekPreICOBonusEstimate + 14 days;
       secondWeekMainICOBonusEstimate = firstWeekPreICOBonusEstimate + 21 days;
       thirdWeekMainICOBonusEstimate = firstWeekPreICOBonusEstimate + 28 days;
       forthWeekMainICOBonusEstimate = firstWeekPreICOBonusEstimate + 35 days;
       firstWeekPreICOBonusRate = 20;
       secondWeekPreICOBonusRate = 18;
       firstWeekMainICOBonusRate = 12;
       secondWeekMainICOBonusRate = 8;
       thirdWeekMainICOBonusRate = 4;
       forthWeekMainICOBonusRate = 0;
    }

    function()  public whenNotPaused payable {
        require(msg.value>0);
        require(now<=forthWeekMainICOBonusEstimate);
        require(tokenSales < (60000000 * (10 **decimals)));
        uint256 bonus = 0;
        if(now<=firstWeekPreICOBonusEstimate && totalWeiRaised < 3000 ether){
            bonus = firstWeekPreICOBonusRate;
        }else if(now <=secondWeekPreICOBonusEstimate && totalWeiRaised < 5000 ether){
            bonus = secondWeekPreICOBonusRate;
        }else if(now<=firstWeekMainICOBonusEstimate && totalWeiRaised < 9000 ether){
            bonus = firstWeekMainICOBonusRate;
        }else if(now<=secondWeekMainICOBonusEstimate && totalWeiRaised < 12000 ether){
            bonus = secondWeekMainICOBonusRate;
        }
        else if(now<=thirdWeekMainICOBonusEstimate && totalWeiRaised <14000 ether){
            bonus = thirdWeekMainICOBonusRate;
        }
        uint256 tokens = (msg.value * (10 ** decimals)) / priceOfToken;
        uint256 bonusTokens = ((tokens * bonus) /100); 
        tokens +=bonusTokens;
          if(balances[owner] <tokens) //check etiher owner can have token otherwise reject transaction and ether
        {
           revert();
        }
        allowed[owner][msg.sender] += tokens;
        bool transferRes=transferFrom(owner, msg.sender, tokens);
        if (!transferRes) {
            revert();
        }
        else{
            tokenSales += tokens;
            etherRaised += msg.value;
            totalWeiRaised +=msg.value;
        }
    }//end of fallback
    /**
    * Transfer entire balance to any account (by owner and admin only)
    **/
    function transferFundToAccount(address _accountByOwner) public onlyOwner {
        require(etherRaised > 0);
        _accountByOwner.transfer(etherRaised);
        etherRaised = 0;
    }

    function resetTokenOfAddress(address _userAddr, uint256 _tokens) public onlyOwner returns (uint256){
       require(_userAddr !=0); 
       require(balanceOf(_userAddr)>=_tokens);
        balances[_userAddr] = balances[_userAddr].sub(_tokens);
        balances[owner] = balances[owner].add(_tokens);
        return balances[_userAddr];
    }
   
    /**
    * Transfer part of balance to any account (by owner and admin only)
    **/
    function transferLimitedFundToAccount(address _accountByOwner, uint256 balanceToTransfer) public onlyOwner   {
        require(etherRaised > balanceToTransfer);
        _accountByOwner.transfer(balanceToTransfer);
        etherRaised -= balanceToTransfer;
    }
  
}