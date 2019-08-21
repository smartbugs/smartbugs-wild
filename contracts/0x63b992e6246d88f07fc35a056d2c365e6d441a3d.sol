pragma solidity ^0.4.13;

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

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}

contract SomaIco is PausableToken {
    using SafeMath for uint256;

    string public name = "Soma Community Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    address public liquidityReserveWallet; // address where liquidity reserve tokens will be delivered
    address public wallet; // address where funds are collected
    address public marketingWallet; // address which controls marketing token pool

    uint256 public icoStartTimestamp; // ICO start timestamp
    uint256 public icoEndTimestamp; // ICO end timestamp

    uint256 public totalRaised = 0; // total amount of money raised in wei
    uint256 public totalSupply; // total token supply with decimals precisoin
    uint256 public marketingPool; // marketing pool with decimals precisoin
    uint256 public tokensSold = 0; // total number of tokens sold

    bool public halted = false; //the owner address can set this to true to halt the crowdsale due to emergency

    uint256 public icoEtherMinCap; // should be specified as: 8000 * 1 ether
    uint256 public icoEtherMaxCap; // should be specified as: 120000 * 1 ether
    uint256 public rate = 450; // standard SCT/ETH rate

    event Burn(address indexed burner, uint256 value);

    function SomaIco(
        address newWallet,
        address newMarketingWallet,
        address newLiquidityReserveWallet,
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap,
        uint256 totalPresaleRaised
    ) {
        require(newWallet != 0x0);
        require(newMarketingWallet != 0x0);
        require(newLiquidityReserveWallet != 0x0);
        require(newIcoEtherMinCap <= newIcoEtherMaxCap);
        require(newIcoEtherMinCap > 0);
        require(newIcoEtherMaxCap > 0);

        pause();

        icoEtherMinCap = newIcoEtherMinCap;
        icoEtherMaxCap = newIcoEtherMaxCap;
        wallet = newWallet;
        marketingWallet = newMarketingWallet;
        liquidityReserveWallet = newLiquidityReserveWallet;

        // calculate marketingPool and totalSupply based on the max cap:
        // totalSupply = rate * icoEtherMaxCap + marketingPool
        // marketingPool = 10% * totalSupply
        // hence:
        // totalSupply = 10/9 * rate * icoEtherMaxCap
        totalSupply = icoEtherMaxCap.mul(rate).mul(10).div(9);
        marketingPool = totalSupply.div(10);

        // account for the funds raised during the presale
        totalRaised = totalRaised.add(totalPresaleRaised);

        // assign marketing pool to marketing wallet
        assignTokens(marketingWallet, marketingPool);
    }

    /// fallback function to buy tokens
    function () nonHalted nonZeroPurchase acceptsFunds payable {
        address recipient = msg.sender;
        uint256 weiAmount = msg.value;

        uint256 amount = weiAmount.mul(rate);

        assignTokens(recipient, amount);
        totalRaised = totalRaised.add(weiAmount);

        forwardFundsToWallet();
    }

    modifier acceptsFunds() {
        bool hasStarted = icoStartTimestamp != 0 && now >= icoStartTimestamp;
        require(hasStarted);

        // ICO is continued over the end date until the min cap is reached
        bool isIcoInProgress = now <= icoEndTimestamp
                || (icoEndTimestamp == 0) // before dates are set
                || totalRaised < icoEtherMinCap;
        require(isIcoInProgress);

        bool isBelowMaxCap = totalRaised < icoEtherMaxCap;
        require(isBelowMaxCap);

        _;
    }

    modifier nonHalted() {
        require(!halted);
        _;
    }

    modifier nonZeroPurchase() {
        require(msg.value > 0);
        _;
    }

    function forwardFundsToWallet() internal {
        wallet.transfer(msg.value); // immediately send Ether to wallet address, propagates exception if execution fails
    }

    function assignTokens(address recipient, uint256 amount) internal {
        balances[recipient] = balances[recipient].add(amount);
        tokensSold = tokensSold.add(amount);

        // sanity safeguard
        if (tokensSold > totalSupply) {
            // there is a chance that tokens are sold over the supply:
            // a) when: total presale bonuses > (maxCap - totalRaised) * rate
            // b) when: last payment goes over the maxCap
            totalSupply = tokensSold;
        }

        Transfer(0x0, recipient, amount);
    }

    function setIcoDates(uint256 newIcoStartTimestamp, uint256 newIcoEndTimestamp) public onlyOwner {
        require(newIcoStartTimestamp < newIcoEndTimestamp);
        require(!isIcoFinished());
        icoStartTimestamp = newIcoStartTimestamp;
        icoEndTimestamp = newIcoEndTimestamp;
    }

    function setRate(uint256 _rate) public onlyOwner {
        require(!isIcoFinished());
        rate = _rate;
    }

    function haltFundraising() public onlyOwner {
        halted = true;
    }

    function unhaltFundraising() public onlyOwner {
        halted = false;
    }

    function isIcoFinished() public constant returns (bool icoFinished) {
        return (totalRaised >= icoEtherMinCap && icoEndTimestamp != 0 && now > icoEndTimestamp) ||
               (totalRaised >= icoEtherMaxCap);
    }

    function prepareLiquidityReserve() public onlyOwner {
        require(isIcoFinished());
        
        uint256 unsoldTokens = totalSupply.sub(tokensSold);
        // make sure there are any unsold tokens to be assigned
        require(unsoldTokens > 0);

        // try to allocate up to 10% of total sold tokens to Liquidity Reserve fund:
        uint256 liquidityReserveTokens = tokensSold.div(10);
        if (liquidityReserveTokens > unsoldTokens) {
            liquidityReserveTokens = unsoldTokens;
        }
        assignTokens(liquidityReserveWallet, liquidityReserveTokens);
        unsoldTokens = unsoldTokens.sub(liquidityReserveTokens);

        // if there are still unsold tokens:
        if (unsoldTokens > 0) {
            // decrease  (burn) total supply by the number of unsold tokens:
            totalSupply = totalSupply.sub(unsoldTokens);
        }

        // make sure there are no tokens left
        assert(tokensSold == totalSupply);
    }

    function manuallyAssignTokens(address recipient, uint256 amount) public onlyOwner {
        require(tokensSold < totalSupply);
        assignTokens(recipient, amount);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public whenNotPaused {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

}