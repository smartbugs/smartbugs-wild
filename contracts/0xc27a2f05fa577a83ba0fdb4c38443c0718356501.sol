pragma solidity ^0.4.15;

contract Ownable {

    //Variables
    address public owner;

    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract LamdenTau is MintableToken {
    string public constant name = "Lamden Tau";
    string public constant symbol = "TAU";
    uint8 public constant decimals = 18;
}

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    //require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    //require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
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

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}
contract Presale is CappedCrowdsale, Ownable {
    using SafeMath for uint256;

    mapping (address => bool) public whitelist;

    bool public isFinalized = false;
    event Finalized();
    
    address public team = 0x9c38c7e22cb20b055e008775617224d0ec25c91f;
    uint256 public teamShare = 150000000 * (10 ** 18);
    
    address public seed = 0x3669ad54675E94e14196528786645c858b8391F1;
    uint256 public seedShare = 6807960 * (10 ** 18);

    bool public hasAllocated = false;

    address public mediator = 0x0;
    
    function Presale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet, address _tokenAddress) 
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
    {
        token = LamdenTau(_tokenAddress);
    }
    
    // Crowdsale overrides
    function createTokenContract() internal returns (MintableToken) {
        return LamdenTau(0x0);
    }

    function validPurchase() internal constant returns (bool) {
        bool withinCap = weiRaised.add(msg.value) <= cap;
        bool valid = super.validPurchase() && withinCap && whitelist[msg.sender];
        return valid;
    }
    // * * *
    
    // Finalizer functions. Redefined from FinalizableCrowdsale to prevent diamond inheritence complexities
    
    function finalize() onlyOwner public {
      require(mediator != 0x0);
      require(!isFinalized);
      require(hasEnded());
      
      finalization();
      Finalized();

      isFinalized = true;
    }
    
    function finalization() internal {
        // set the ownership to the mediator so it can pass it onto the sale contract
        // at the time that the sale contract is deployed
        token.transferOwnership(mediator);
        Mediator m = Mediator(mediator);
        m.acceptToken();
    }
    // * * * 

    // Contract Specific functions
    function assignMediator(address _m) public onlyOwner returns(bool) {
        mediator = _m;
        return true;
    }
    
    function whitelistUser(address _a) public onlyOwner returns(bool){
        whitelist[_a] = true;
        return whitelist[_a];
    }

    function whitelistUsers(address[] users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }

    function unWhitelistUser(address _a) public onlyOwner returns(bool){
        whitelist[_a] = false;
        return whitelist[_a];
    }

    function unWhitelistUsers(address[] users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = false;
        }
    }
    
    function allocateTokens() public onlyOwner returns(bool) {
        require(hasAllocated == false);
        token.mint(team, teamShare);
        token.mint(seed, seedShare);
        hasAllocated = true;
        return hasAllocated;
    }
    
    function acceptToken() public onlyOwner returns(bool) {
        token.acceptOwnership();
        return true;
    }

    function changeEndTime(uint256 _e) public onlyOwner returns(uint256) {
        require(_e > startTime);
        endTime = _e;
        return endTime;
    }

    function mintTokens(uint256 tokenAmount) public onlyOwner {
       require(!isFinalized);
       token.mint(wallet, tokenAmount);
    }
    
    // * * *
}

contract Mediator is Ownable {
    address public presale;
    LamdenTau public tau;
    address public sale;
    
    function setPresale(address p) public onlyOwner { presale = p; }
    function setTau(address t) public onlyOwner { tau = LamdenTau(t); }
    function setSale(address s) public onlyOwner { sale = s; }
    
    modifier onlyPresale {
        require(msg.sender == presale);
        _;
    }
    
    modifier onlySale {
        require(msg.sender == sale);
        _;
    }
    
    function acceptToken() public onlyPresale { tau.acceptOwnership(); }
    function passOff() public onlySale { tau.transferOwnership(sale); }
}

contract Sale is CappedCrowdsale, Ownable {
    using SafeMath for uint256;

    // Initialization Variables
    uint256 public amountPerDay; // 30 eth
    uint256 public constant UNIX_DAY = 86400;

    bool public isFinalized = false;
    event Finalized();

    mapping (address => bool) public whitelist;
    mapping (address => uint256) public amountContributedBy;
    // * * *

    // Constructor
    function Sale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet, uint256 _amountPerDay, address _tokenAddress)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
    {
        amountPerDay = _amountPerDay;
        token = LamdenTau(_tokenAddress);
    }
    // * * *
    
    // Crowdsale overrides
    function createTokenContract() internal returns (MintableToken) {
        return LamdenTau(0x0);
    }
    
    function validPurchase() internal constant returns (bool) {
        bool withinCap = weiRaised.add(msg.value) <= cap;
        bool withinContributionLimit = msg.value <= currentPersonalLimit(msg.sender);
        bool valid = super.validPurchase() && withinCap && whitelist[msg.sender] && withinContributionLimit;
        return valid;
    }

    function buyTokens(address beneficiary) public payable {
        super.buyTokens(beneficiary);
        amountContributedBy[msg.sender] = amountContributedBy[msg.sender].add(msg.value);
    }
    // * * *

    // Finalizer functions
    function finalize() onlyOwner public {
      require(!isFinalized);
      require(hasEnded());

      finalization();
      Finalized();

      isFinalized = true;
    }
    
    function finalization() internal {
        token.finishMinting();
    }
    // * * * 
    
    // Contract Specific functions
    function daysSinceLaunch() public constant returns(uint256) {
        return now.sub(startTime).div(UNIX_DAY);
    }
    
    function currentContributionLimit() public constant returns(uint256) {
        return amountPerDay.mul(2 ** daysSinceLaunch());
    }
    
    function currentPersonalLimit(address _a) public constant returns(uint256) {
        return currentContributionLimit().sub(amountContributedBy[_a]);
    }
    
    function claimToken(address _m) public onlyOwner returns(bool) {
        Mediator m = Mediator(_m);
        m.passOff();
        token.acceptOwnership();
        return true;
    }
    
    function whitelistUser(address _a) onlyOwner public returns(bool) {
        whitelist[_a] = true;
        return whitelist[_a];
    }
    
    function whitelistUsers(address[] users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }

    function unWhitelistUser(address _a) public onlyOwner returns(bool){
        whitelist[_a] = false;
        return whitelist[_a];
    }

    function unWhitelistUsers(address[] users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = false;
        }
    }

    function changeEndTime(uint256 _e) public onlyOwner returns(uint256) {
        require(_e > startTime);
        endTime = _e;
        return endTime;
    }

    function mintTokens(uint256 tokenAmount) public onlyOwner {
       require(!isFinalized);
       token.mint(wallet, tokenAmount);
    }
    // * * *
}