pragma solidity ^0.4.18;

/**
 * Libraries
 */


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * Helper contracts
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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

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

contract BurnableToken is BasicToken {

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
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
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

/**
 * Proxy
 */

contract Proxy is Ownable, Destructible, Pausable {
    // crowdsale contract
    Crowdsale public crowdsale;

    function Proxy(Crowdsale _crowdsale) public {
        setCrowdsale(_crowdsale);
    }

    function setCrowdsale(address _crowdsale) onlyOwner public {
        require(_crowdsale != address(0));
        crowdsale = Crowdsale(_crowdsale);
    }

    function () external whenNotPaused payable {
        // buy tokens from crowdsale
        crowdsale.buyTokens.value(msg.value)(msg.sender);
    }
}

/**
 * Proxy
 */

contract Referral is Ownable, Destructible, Pausable {
    using SafeMath for uint256;

    Crowdsale public crowdsale;
    Token public token;

    address public beneficiary;

    function Referral(address _crowdsale, address _token, address _beneficiary) public {
        setCrowdsale(_crowdsale);
        setToken(_token);
        setBeneficiary(_beneficiary);
    }

    function setCrowdsale(address _crowdsale) onlyOwner public {
        require(_crowdsale != address(0));
        crowdsale = Crowdsale(_crowdsale);
    }

    function setToken(address _token) onlyOwner public {
        require(_token != address(0));
        token = Token(_token);
    }

    function setBeneficiary(address _beneficiary) onlyOwner public {
        require(_beneficiary != address(0));
        beneficiary = _beneficiary;
    }

    function () external whenNotPaused payable {
        uint256 tokens = crowdsale.buyTokens.value(msg.value)(this);

        uint256 baseAmount = crowdsale.getBaseAmount(msg.value);
        uint256 refTokens = baseAmount.div(10);

        // send 10% to referral
        token.transfer(beneficiary, refTokens);

        // remove 10%
        tokens = tokens.sub(refTokens);

        // send eth to buyer
        token.transfer(msg.sender, tokens);
    }
}

/**
 * CCOS Token
 */

contract Token is StandardToken, BurnableToken, DetailedERC20, Destructible {
    function Token(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply)
        DetailedERC20(_name, _symbol, _decimals) public
        {

        // covert to ether
        _totalSupply = _totalSupply;

        totalSupply_ = _totalSupply;

        // give moneyz to us
        balances[msg.sender] = totalSupply_;

        // first event
        Transfer(0x0, msg.sender, totalSupply_);
    }
}

/**
 * CCOS Crowdsale
 */

contract Crowdsale is Ownable, Pausable, Destructible {
    using SafeMath for uint256;

    struct Vault {
        uint256 tokenAmount;
        uint256 weiValue;
        address referralBeneficiary;
    }

    struct CustomContract {
        bool isReferral;
        bool isSpecial;
        address referralAddress;
    }

    // Manual kill switch
    bool crowdsaleConcluded = false;

    // The token being sold
    Token public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // minimum investment
    uint256 minimum_invest = 100000000000000;

    // regular bonus amounts
    uint256 week_1 = 20;
    uint256 week_2 = 15;
    uint256 week_3 = 10;
    uint256 week_4 = 0;

    // custom bonus amounts
    uint256 week_special_1 = 40;
    uint256 week_special_2 = 15;
    uint256 week_special_3 = 10;
    uint256 week_special_4 = 0;

    uint256 week_referral_1 = 25;
    uint256 week_referral_2 = 20;
    uint256 week_referral_3 = 15;
    uint256 week_referral_4 = 5;

    // bonus ducks
    mapping (address => CustomContract) public customBonuses;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised in wei
    uint256 public weiRaised;
    uint256 public tokensSold;

    // amount on hold for KYC
    uint256 public tokensOnHold;

    // high-ballers
    mapping(address => Vault) ballers;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) public {
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        token = Token(_token);
    }

    // fallback function can be used to buy tokens
    function () external whenNotPaused payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address _beneficiary) public whenNotPaused payable returns (uint256) {
        require(!hasEnded());

        // minimum investment
        require(minimum_invest <= msg.value);

        address beneficiary = _beneficiary;

        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be sent
        var tokens = getTokenAmount(weiAmount);

        // if we run out of tokens
        bool isLess = false;
        if (!hasEnoughTokensLeft(weiAmount)) {
            isLess = true;

            uint256 percentOfValue = tokensLeft().mul(100).div(tokens);
            require(percentOfValue <= 100);

            tokens = tokens.mul(percentOfValue).div(100);
            weiAmount = weiAmount.mul(percentOfValue).div(100);

            // send back unused ethers
            beneficiary.transfer(msg.value.sub(weiAmount));
        }

        // update raised ETH amount
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokens);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        // Require a KYC, but tokens on hold
        if ((11 ether) <= weiAmount) {
            // we have a KYC requirement
            // add tokens to his/her vault to release/refund manually afterawards

            tokensOnHold = tokensOnHold.add(tokens);

            ballers[beneficiary].tokenAmount += tokens;
            ballers[beneficiary].weiValue += weiAmount;
            ballers[beneficiary].referralBeneficiary = address(0);

            // set referral address if referral contract
            if (customBonuses[msg.sender].isReferral == true) {
              ballers[beneficiary].referralBeneficiary = customBonuses[msg.sender].referralAddress;
            }

            return (0);
        }

        token.transfer(beneficiary, tokens);

        forwardFunds(weiAmount);

        if (isLess == true) {
          return (tokens);
        }
        return (tokens);
    }

    /**
     * Release / Refund logics
     */

    function viewFunds(address _wallet) public view returns (uint256) {
        return ballers[_wallet].tokenAmount;
    }

    function releaseFunds(address _wallet) onlyOwner public {
        require(ballers[_wallet].tokenAmount > 0);
        require(ballers[_wallet].weiValue <= this.balance);

        // held tokens count for this buyer
        uint256 tokens = ballers[_wallet].tokenAmount;

        // remove from tokens on hold
        tokensOnHold = tokensOnHold.sub(tokens);

        // transfer ether to our wallet
        forwardFunds(ballers[_wallet].weiValue);

        // if it's a referral release give bonus tokens to referral
        if (ballers[_wallet].referralBeneficiary != address(0)) {
          uint256 refTokens = tokens.mul(10).div(100);
          token.transfer(ballers[_wallet].referralBeneficiary, refTokens);

          // subtract referral tokens from total
          tokens = tokens.sub(refTokens);
        }

        // send tokens to buyer
        token.transfer(_wallet, tokens);


        // reset vault
        ballers[_wallet].tokenAmount = 0;
        ballers[_wallet].weiValue = 0;
    }

    function refundFunds(address _wallet) onlyOwner public {
        require(ballers[_wallet].tokenAmount > 0);
        require(ballers[_wallet].weiValue <= this.balance);

        // remove from tokens on hold
        tokensOnHold = tokensOnHold.sub(ballers[_wallet].tokenAmount);

        _wallet.transfer(ballers[_wallet].weiValue);

        weiRaised = weiRaised.sub(ballers[_wallet].weiValue);
        tokensSold = tokensSold.sub(ballers[_wallet].tokenAmount);

        ballers[_wallet].tokenAmount = 0;
        ballers[_wallet].weiValue = 0;
    }

    /**
     * Editors
     */

    function addOldInvestment(address _beneficiary, uint256 _weiAmount, uint256 _tokensWithDecimals) onlyOwner public {
      require(_beneficiary != address(0));

      // update sold tokens amount
      weiRaised = weiRaised.add(_weiAmount);
      tokensSold = tokensSold.add(_tokensWithDecimals);

      token.transfer(_beneficiary, _tokensWithDecimals);

      TokenPurchase(msg.sender, _beneficiary, _weiAmount, _tokensWithDecimals);
    }

    function setCustomBonus(address _contract, bool _isReferral, bool _isSpecial, address _referralAddress) onlyOwner public {
      require(_contract != address(0));

      customBonuses[_contract] = CustomContract({
          isReferral: _isReferral,
          isSpecial: _isSpecial,
          referralAddress: _referralAddress
      });
    }

    function addOnHold(uint256 _amount) onlyOwner public {
      tokensOnHold = tokensOnHold.add(_amount);
    }

    function subOnHold(uint256 _amount) onlyOwner public {
      tokensOnHold = tokensOnHold.sub(_amount);
    }

    function setMinInvestment(uint256 _investment) onlyOwner public {
      require(_investment > 0);
      minimum_invest = _investment;
    }

    function changeEndTime(uint256 _endTime) onlyOwner public {
        require(_endTime > startTime);
        endTime = _endTime;
    }

    function changeStartTime(uint256 _startTime) onlyOwner public {
        require(endTime > _startTime);
        startTime = _startTime;
    }

    function setWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        wallet = _wallet;
    }

    function setToken(address _token) onlyOwner public {
        require(_token != address(0));
        token = Token(_token);
    }

    /**
     * End crowdsale manually
     */

    function endSale() onlyOwner public {
      // close crowdsale
      crowdsaleConcluded = true;

      // burn all tokens left
      token.burn(token.balanceOf(this));
    }

    /**
     * When at risk, evacuate tokens
     */

    function evacuateTokens(address _wallet) onlyOwner public {
      require(_wallet != address(0));
      token.transfer(_wallet, token.balanceOf(this));
    }

    /**
     * Calculations
     */

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime || token.balanceOf(this) == 0 || crowdsaleConcluded;
    }

    function getBaseAmount(uint256 _weiAmount) public view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    // Override this method to have a way to add business logic to your crowdsale when buying
    function getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokens = getBaseAmount(_weiAmount);
        uint256 percentage = 0;

         // Special bonuses
        if (customBonuses[msg.sender].isSpecial == true) {

          if ( startTime <= now && now < startTime + 7 days ) {
            percentage = week_special_1;
          } else if ( startTime + 7 days <= now && now < startTime + 14 days ) {
            percentage = week_special_2;
          } else if ( startTime + 14 days <= now && now < startTime + 21 days ) {
            percentage = week_special_3;
          } else if ( startTime + 21 days <= now && now <= endTime ) {
            percentage = week_special_4;
          }

        // Regular bonuses
        } else {

          if ( startTime <= now && now < startTime + 7 days ) {
            percentage = week_1;
          } else if ( startTime + 7 days <= now && now < startTime + 14 days ) {
            percentage = week_2;
          } else if ( startTime + 14 days <= now && now < startTime + 21 days ) {
            percentage = week_3;
          } else if ( startTime + 21 days <= now && now <= endTime ) {
            percentage = week_4;
          }

          // Referral bonuses
          if (customBonuses[msg.sender].isReferral == true) {
            percentage += 15; // 5 for buyer, 10 for referrer
          }

        }

        // Large contributors
        if (msg.value >= 50 ether) {
          percentage += 80;
        } else if (msg.value >= 30 ether) {
          percentage += 70;
        } else if (msg.value >= 10 ether) {
          percentage += 50;
        } else if (msg.value >= 5 ether) {
          percentage += 30;
        } else if (msg.value >= 3 ether) {
          percentage += 10;
        }

        tokens += tokens.mul(percentage).div(100);

        assert(tokens > 0);

        return (tokens);
    }

    // send ether to the fund collection wallet
    function forwardFunds(uint256 _amount) internal {
        wallet.transfer(_amount);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function tokensLeft() public view returns (uint256) {
        return token.balanceOf(this).sub(tokensOnHold);
    }

    function hasEnoughTokensLeft(uint256 _weiAmount) public payable returns (bool) {
        return tokensLeft().sub(_weiAmount) >= getBaseAmount(_weiAmount);
    }
}