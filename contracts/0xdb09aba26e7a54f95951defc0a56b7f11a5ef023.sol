pragma solidity ^0.4.11;


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

contract Haltable is Ownable {
  bool public halted = false;

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier stopNonOwnersInEmergency {
    require((msg.sender==owner) || !halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}

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


contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TakeProfitToken is Token, Haltable {
    using SafeMath for uint256;


    string constant public name = "TakeProfit";
    uint8 constant public decimals = 8;
    string constant public symbol = "XTP";       
    string constant public version = "1.1";


    uint256 constant public UNIT = uint256(10)**decimals;
    uint256 public totalSupply = 10**8 * UNIT;

    uint256 constant MAX_UINT256 = 2**256 - 1; // Used for allowance: this value mean infinite allowance

    function TakeProfitToken() public {
        balances[owner] = totalSupply;
    }


    function transfer(address _to, uint256 _value) public stopInEmergency returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public stopInEmergency returns (bool success) {
        require(_to != address(0));
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] = allowance.sub(_value);
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public stopInEmergency returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}


/**
 * @title Presale
 * @dev Presale is a base contract for managing a token Presale.
 * Presales have a start and end timestamps, where investors can make
 * token purchases and the Presale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Presale is Haltable {
  using SafeMath for uint256;

  // The token being sold
  Token public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 constant public startTime = 1511892000; // 28 Nov 2017 @ 18:00   (UTC)
  uint256 constant public endTime =   1513641600; // 19 Dec 2017 @ 12:00am (UTC)

  uint256 constant public tokenCap = uint256(8*1e6*1e8);

  // address where funds will be transfered
  address public withdrawAddress;

  // how many weis buyer need to pay for one token unit
  uint256 public default_rate = 2500000;

  // amount of raised money in wei
  uint256 public weiRaised;

  // amount of already sold tokens
  uint256 public tokenSold;

  bool public initiated = false;
  bool public finalized = false;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  // we always refund to address from which we get money, while tokens can be bought for another address
  mapping (address => uint256) purchasedTokens;
  mapping (address => uint256) receivedFunds;

  enum State{Unknown, Prepairing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  function Presale(address token_address, address _withdrawAddress) public {
    require(startTime >= now);
    require(endTime >= startTime);
    require(default_rate > 0);
    require(withdrawAddress == address(0));
    require(_withdrawAddress != address(0));
    require(tokenCap>0);
    token = Token(token_address);
    require(token.totalSupply()==100*uint256(10)**(6+8));
    withdrawAddress = _withdrawAddress;
  }

  function initiate() public onlyOwner {
    require(token.balanceOf(this) >= tokenCap);
    initiated = true;
    if(token.balanceOf(this)>tokenCap)
      require(token.transfer(withdrawAddress, token.balanceOf(this).sub(tokenCap)));
  }

  // fallback function can be used to buy tokens
  function () public stopInEmergency payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public stopInEmergency inState(State.Funding) payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 weiAmountConsumed = 0;
    uint256 weiExcess = 0;

    // calculate token amount to be bought
    uint256 tokens = weiAmount.div(rate());
    if(tokenSold.add(tokens)>tokenCap) {
      tokens = tokenCap.sub(tokenSold);
    }

    weiAmountConsumed = tokens.mul(rate());
    weiExcess = weiAmount.sub(weiAmountConsumed);


    // update state
    weiRaised = weiRaised.add(weiAmountConsumed);
    tokenSold = tokenSold.add(tokens);

    purchasedTokens[beneficiary] += tokens;
    receivedFunds[msg.sender] += weiAmountConsumed;
    if(weiExcess>0) {
      msg.sender.transfer(weiExcess);
    }
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool valuablePurchase = (msg.value >= 0.1 ether);
    return valuablePurchase;
  }

  function getPurchasedTokens(address beneficiary) public constant returns (uint256) {
    return purchasedTokens[beneficiary];
  }

  function getReceivedFunds(address buyer) public constant returns (uint256) {
    return receivedFunds[buyer];
  }

  function claim() public stopInEmergency inState(State.Finalized) {
    claimTokens(msg.sender);
  }


  function claimTokens(address beneficiary) public stopInEmergency inState(State.Finalized) {
    require(purchasedTokens[beneficiary]>0);
    uint256 value = purchasedTokens[beneficiary];
    purchasedTokens[beneficiary] -= value;
    require(token.transfer(beneficiary, value));
  }

  function refund() public stopInEmergency inState(State.Refunding) {
    delegatedRefund(msg.sender);
  }

  function delegatedRefund(address beneficiary) public stopInEmergency inState(State.Refunding) {
    require(receivedFunds[beneficiary]>0);
    uint256 value = receivedFunds[beneficiary];
    receivedFunds[beneficiary] = 0;
    beneficiary.transfer(value);
  }

  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(!finalized);
    require(this.balance==0);
    finalized = true;
  }

  function withdraw() public  inState(State.Success) onlyOwner stopInEmergency {
    withdrawAddress.transfer(weiRaised);
  }

  function manualWithdrawal(uint256 _amount) public  inState(State.Success) onlyOwner stopInEmergency {
    withdrawAddress.transfer(_amount);
  }

  function emergencyWithdrawal(uint256 _amount) public onlyOwner onlyInEmergency {
    withdrawAddress.transfer(_amount);
  }

  function emergencyTokenWithdrawal(uint256 _amount) public onlyOwner onlyInEmergency {
    require(token.transfer(withdrawAddress, _amount));
  }

  function rate() public constant returns (uint256) {
    if (block.timestamp < startTime) return 0;
    else if (block.timestamp >= startTime && block.timestamp < (startTime + 1 weeks)) return uint256(default_rate/2);
    else if (block.timestamp >= (startTime+1 weeks) && block.timestamp < (startTime + 2 weeks)) return uint256(10*default_rate/19);
    else if (block.timestamp >= (startTime+2 weeks) && block.timestamp < (startTime + 3 weeks)) return uint256(10*default_rate/18);
    return 0;
  }

  //It is function and not variable, thus it can't be stale
  function getState() public constant returns (State) {
    if(finalized) return State.Finalized;
    if(!initiated) return State.Prepairing;
    else if (block.timestamp < startTime) return State.PreFunding;
    else if (block.timestamp <= endTime && tokenSold<tokenCap) return State.Funding;
    else if (tokenSold>=tokenCap) return State.Success;
    else if (weiRaised > 0 && block.timestamp >= endTime && tokenSold<tokenCap) return State.Refunding;
    else return State.Failure;
  }

  modifier inState(State state) {
    require(getState() == state);
    _;
  }
}