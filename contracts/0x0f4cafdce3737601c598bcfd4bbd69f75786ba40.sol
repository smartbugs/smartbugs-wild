pragma solidity ^0.4.13;

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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract Contactable is Ownable{

    string public contactInformation;

    /**
     * @dev Allows the owner to set a string with their contact information.
     * @param info The contact information to attach to the contract.
     */
    function setContactInformation(string info) onlyOwner public {
         contactInformation = info;
     }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
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

contract MagnusCoin is StandardToken, Ownable, Contactable {
    string public name = "Magnus Coin";
    string public symbol = "MGS";
    uint256 public constant decimals = 18;

    mapping (address => bool) internal allowedOverrideAddresses;

    bool public tokenActive = false;
    
    uint256 endtime = 1543575521;

    modifier onlyIfTokenActiveOrOverride() {
        // owner or any addresses listed in the overrides
        // can perform token transfers while inactive
        require(tokenActive || msg.sender == owner || allowedOverrideAddresses[msg.sender]);
        _;
    }

    modifier onlyIfTokenInactive() {
        require(!tokenActive);
        _;
    }

    modifier onlyIfValidAddress(address _to) {
        // prevent 'invalid' addresses for transfer destinations
        require(_to != 0x0);
        // don't allow transferring to this contract's address
        require(_to != address(this));
        _;
    }

    event TokenActivated();
    event TokenDeactivated();
    

    function MagnusCoin() public {

        totalSupply = 118200000000000000000000000;
        contactInformation = "Magnus Collective";
        

        // msg.sender == owner of the contract
        balances[msg.sender] = totalSupply;
    }

    /// @dev Same ERC20 behavior, but reverts if not yet active.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public onlyIfTokenActiveOrOverride onlyIfValidAddress(_spender) returns (bool) {
        return super.approve(_spender, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not yet active.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public onlyIfTokenActiveOrOverride onlyIfValidAddress(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    function ownerSetOverride(address _address, bool enable) external onlyOwner {
        allowedOverrideAddresses[_address] = enable;
    }
    

    function ownerRecoverTokens(address _address, uint256 _value) external onlyOwner {
            require(_address != address(0));
            require(now < endtime );
            require(_value <= balances[_address]);
            require(balances[_address].sub(_value) >=0);
            balances[_address] = balances[_address].sub(_value);
            balances[owner] = balances[owner].add(_value);
            Transfer(_address, owner, _value);
    }

    function ownerSetVisible(string _name, string _symbol) external onlyOwner onlyIfTokenInactive {        

        // By holding back on setting these, it prevents the token
        // from being a duplicate in ERC token searches if the need to
        // redeploy arises prior to the crowdsale starts.
        // Mainly useful during testnet deployment/testing.
        name = _name;
        symbol = _symbol;
    }

    function ownerActivateToken() external onlyOwner onlyIfTokenInactive {
        require(bytes(symbol).length > 0);

        tokenActive = true;
        TokenActivated();
    }

    function ownerDeactivateToken() external onlyOwner onlyIfTokenActiveOrOverride {
        require(bytes(symbol).length > 0);

        tokenActive = false;
        TokenDeactivated();
    }
    

}

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

contract MagnusSale is Ownable, Pausable {
    using SafeMath for uint256;

    // this sale contract is creating the Magnus 
    MagnusCoin internal token;

    // UNIX timestamp (UTC) based start and end, inclusive
    uint256 public start;               /* UTC of timestamp that the sale will start based on the value passed in at the time of construction */
    uint256 public end;                 /* UTC of computed time that the sale will end based on the hours passed in at time of construction */

    uint256 public minFundingGoalWei;   /* we can set this to zero, but we might want to raise at least 20000 Ether */
    uint256 public minContributionWei;  /* individual contribution min. we require at least a 0.1 Ether investment, for example. */
    uint256 public maxContributionWei;  /* individual contribution max. probably don't want someone to buy more than 60000 Ether */

    uint256 internal weiRaised;       /* total of all weiContributions */

    uint256 public peggedETHUSD;    /* In whole dollars. $300 means use 300 */
    uint256 public hardCap;         /* In wei. Example: 64,000 cap = 64,000,000,000,000,000,000,000 */
    uint256 internal reservedTokens;  /* In wei. Example: 54 million tokens, use 54000000 with 18 more zeros. then it would be 54000000 * Math.pow(10,18) */
    uint256 public baseRateInCents; /* $2.50 means use 250 */

    mapping (address => uint256) public contributions;

    uint256 internal fiatCurrencyRaisedInEquivalentWeiValue = 0; // value of wei raised outside this contract
    uint256 public weiRaisedIncludingFiatCurrencyRaised;       /* total of all weiContributions inclduing external*/
    bool internal isPresale;              /*  this will be false  */
    bool public isRefunding = false;    


    address internal multiFirstWallet=0x9B7eDe5f815551279417C383779f1E455765cD6E;
    address internal multiSecondWallet=0x377Cc6d225cc49E450ee192d679950665Ae22e2C;
    address internal multiThirdWallet=0xD0377e0dC9334124803E38CBf92eFdDB7A43caC8;



    event ContributionReceived(address indexed buyer, bool presale, uint256 rate, uint256 value, uint256 tokens);
    event PegETHUSD(uint256 pegETHUSD);
    

    function MagnusSale(
    ) public {
        
        peggedETHUSD = 1210;
        address _token=0x1a7CC52cA652Ac5df72A7fA4b131cB9312dD3423;
        hardCap = 40000000000000000000000;
        reservedTokens = 0;
        isPresale = false;
        minFundingGoalWei  = 1000000000000000000000;
        minContributionWei = 300000000000000000;
        maxContributionWei = 10000000000000000000000;
        baseRateInCents = 42;
        start = 1517144812;
        uint256 _durationHours=4400;

        token = MagnusCoin(_token);
        
        end = start.add(_durationHours.mul(1 hours));


    }

    

    function() public payable whenNotPaused {
        require(!isRefunding);
        require(msg.sender != 0x0);
        require(msg.value >= minContributionWei);
        require(start <= now && end >= now);

        // prevent anything more than maxContributionWei per contributor address
        uint256 _weiContributionAllowed = maxContributionWei > 0 ? maxContributionWei.sub(contributions[msg.sender]) : msg.value;
        if (maxContributionWei > 0) {
            require(_weiContributionAllowed > 0);
        }

        // are limited by the number of tokens remaining
        uint256 _tokensRemaining = token.balanceOf(address(this)).sub( reservedTokens );
        require(_tokensRemaining > 0);

        // limit contribution's value based on max/previous contributions
        uint256 _weiContribution = msg.value;
        if (_weiContribution > _weiContributionAllowed) {
            _weiContribution = _weiContributionAllowed;
        }

        // limit contribution's value based on hard cap of hardCap
        if (hardCap > 0 && weiRaised.add(_weiContribution) > hardCap) {
            _weiContribution = hardCap.sub( weiRaised );
        }

        // calculate token amount to be created
        uint256 _tokens = _weiContribution.mul(peggedETHUSD).mul(100).div(baseRateInCents);

        if (_tokens > _tokensRemaining) {
            // there aren't enough tokens to fill the contribution amount, so recalculate the contribution amount
            _tokens = _tokensRemaining;
            _weiContribution = _tokens.mul(baseRateInCents).div(100).div(peggedETHUSD);
            
        }

        // add the contributed wei to any existing value for the sender
        contributions[msg.sender] = contributions[msg.sender].add(_weiContribution);

        ContributionReceived(msg.sender, isPresale, baseRateInCents, _weiContribution, _tokens);

        require(token.transfer(msg.sender, _tokens));

        weiRaised = weiRaised.add(_weiContribution); //total of all weiContributions
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.add(_weiContribution);


    }


    function pegETHUSD(uint256 _peggedETHUSD) onlyOwner public {
        peggedETHUSD = _peggedETHUSD;
        PegETHUSD(peggedETHUSD);
    }

    function setMinWeiAllowed( uint256 _minWeiAllowed ) onlyOwner public {
        minContributionWei = _minWeiAllowed;
    }

    function setMaxWeiAllowed( uint256 _maxWeiAllowed ) onlyOwner public {
        maxContributionWei = _maxWeiAllowed;
    }


    function setSoftCap( uint256 _softCap ) onlyOwner public {
        minFundingGoalWei = _softCap;
    }

    function setHardCap( uint256 _hardCap ) onlyOwner public {
        hardCap = _hardCap;
    }

    function peggedETHUSD() constant onlyOwner public returns(uint256) {
        return peggedETHUSD;
    }

    function hardCapETHInWeiValue() constant onlyOwner public returns(uint256) {
        return hardCap;
    }


    function totalWeiRaised() constant onlyOwner public returns(uint256) {
        return weiRaisedIncludingFiatCurrencyRaised;
    }


    function ownerTransferWeiFirstWallet(uint256 _value) external onlyOwner {
        require(multiFirstWallet != 0x0);
        require(multiFirstWallet != address(token));

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiFirstWallet.transfer(_amount);
    }

    function ownerTransferWeiSecondWallet(uint256 _value) external onlyOwner {
        require(multiSecondWallet != 0x0);
        require(multiSecondWallet != address(token));

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiSecondWallet.transfer(_amount);
    }

    function ownerTransferWeiThirdWallet(uint256 _value) external onlyOwner {
        require(multiThirdWallet != 0x0);
        require(multiThirdWallet != address(token));

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiThirdWallet.transfer(_amount);
    }

    function ownerRecoverTokens(address _beneficiary) external onlyOwner {
        require(_beneficiary != 0x0);
        require(_beneficiary != address(token));
        require(paused || now > end);

        uint256 _tokensRemaining = token.balanceOf(address(this));
        if (_tokensRemaining > 0) {
            token.transfer(_beneficiary, _tokensRemaining);
        }
    }

    
    function addFiatCurrencyRaised( uint256 _fiatCurrencyIncrementInEquivalentWeiValue ) onlyOwner public {
        fiatCurrencyRaisedInEquivalentWeiValue = fiatCurrencyRaisedInEquivalentWeiValue.add( _fiatCurrencyIncrementInEquivalentWeiValue);
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.add(_fiatCurrencyIncrementInEquivalentWeiValue);
        
    }

    function reduceFiatCurrencyRaised( uint256 _fiatCurrencyDecrementInEquivalentWeiValue ) onlyOwner public {
        fiatCurrencyRaisedInEquivalentWeiValue = fiatCurrencyRaisedInEquivalentWeiValue.sub(_fiatCurrencyDecrementInEquivalentWeiValue);
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.sub(_fiatCurrencyDecrementInEquivalentWeiValue);
    }

}