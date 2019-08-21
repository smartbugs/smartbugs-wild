pragma solidity ^0.4.18;

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


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
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

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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

contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;
    address public publisher;


    function MultiOwners() {
        owners[msg.sender] = true;
        publisher = msg.sender;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(_owner != publisher);
        require(msg.sender != _owner);

        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract Haltable is MultiOwners {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
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

contract FixedRate {
    uint256 public rateETHUSD = 470e2;
}

contract Stage is FixedRate, MultiOwners {
    using SafeMath for uint256;

    // Global
    string _stageName = "Pre-ICO";

    // Maximum possible cap in USD
    uint256 public mainCapInUSD = 1000000e2;

    // Maximum possible cap in USD
    uint256 public hardCapInUSD = mainCapInUSD;

    //  period in days
    uint256 public period = 30 days;

    // Token Price in USD
    uint256 public tokenPriceUSD = 50;

    // WEI per token
    uint256 public weiPerToken;
    
    // start and end timestamp where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // total wei received during phase one
    uint256 public totalWei;

    // Maximum possible cap in wei for phase one
    uint256 public mainCapInWei;
    // Maximum possible cap in wei
    uint256 public hardCapInWei;

    function Stage (uint256 _startTime) {
        startTime = _startTime;
        endTime = startTime.add(period);
        weiPerToken = tokenPriceUSD.mul(1 ether).div(rateETHUSD);
        mainCapInWei = mainCapInUSD.mul(1 ether).div(rateETHUSD);
        hardCapInWei = mainCapInWei;

    }

    /*
     * @dev amount calculation, depends of current period
     * @param _value ETH in wei
     * @param _at time
     */
    function calcAmountAt(uint256 _value, uint256 _at) constant returns (uint256, uint256) {
        uint256 estimate;
        uint256 odd;

        if(_value.add(totalWei) > hardCapInWei) {
            odd = _value.add(totalWei).sub(hardCapInWei);
            _value = hardCapInWei.sub(totalWei);
        } 
        estimate = _value.mul(1 ether).div(weiPerToken);
        require(_value + totalWei <= hardCapInWei);
        return (estimate, odd);
    }
}

contract TripleAlphaCrowdsalePreICO is MultiOwners, Haltable, Stage {
    using SafeMath for uint256;

    // minimal token selled per time
    uint256 public minimalTokens = 1e18;

    // Sale token
    TripleAlphaTokenPreICO public token;

    // Withdraw wallet
    address public wallet;

    // Events
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event OddMoney(address indexed beneficiary, uint256 value);

    modifier validPurchase() {
        bool nonZeroPurchase = msg.value != 0;

        require(withinPeriod() && nonZeroPurchase);

        _;        
    }

    modifier isExpired() {
        require(now > endTime);

        _;        
    }

    /**
     * @return true if in period or false if not
     */
    function withinPeriod() constant returns(bool res) {
        return (now >= startTime && now <= endTime);
    }

    /**
     * @param _startTime Pre-ITO start time
     * @param _wallet destination fund address (i hope it will be multi-sig)
     */
    function TripleAlphaCrowdsalePreICO(uint256 _startTime, address _wallet) Stage(_startTime)

    {
        require(_startTime >= now);
        require(_wallet != 0x0);

        token = new TripleAlphaTokenPreICO();
        wallet = _wallet;
    }

    /**
     * @dev Human readable period Name 
     * @return current stage name
     */
    function stageName() constant public returns (string) {
        bool before = (now < startTime);
        bool within = (now >= startTime && now <= endTime);

        if(before) {
            return 'Not started';
        }

        if(within) {
            return _stageName;
        } 

        return 'Finished';
    }

    
    function totalEther() public constant returns(uint256) {
        return totalWei.div(1e18);
    }

    /*
     * @dev fallback for processing ether
     */
    function() payable {
        return buyTokens(msg.sender);
    }

    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    function buyTokens(address contributor) payable stopInEmergency validPurchase public {
        uint256 amount;
        uint256 odd_ethers;
        
        (amount, odd_ethers) = calcAmountAt(msg.value, now);
  
        require(contributor != 0x0) ;
        require(minimalTokens <= amount);

        token.mint(contributor, amount);
        TokenPurchase(contributor, msg.value, amount);

        totalWei = totalWei.add(msg.value);

        if(odd_ethers > 0) {
            require(odd_ethers < msg.value);
            OddMoney(contributor, odd_ethers);
            contributor.transfer(odd_ethers);
        }

        wallet.transfer(this.balance);
    }

    /*
     * @dev finish crowdsale
     */
    function finishCrowdsale() onlyOwner public {
        require(now > endTime || totalWei == hardCapInWei);
        require(!token.mintingFinished());
        token.finishMinting();
    }

    // @return true if crowdsale event has ended
    function running() constant public returns (bool) {
        return withinPeriod() && !token.mintingFinished();
    }
}

contract TripleAlphaTokenPreICO is MintableToken {

    string public constant name = 'Triple Alpha Token Pre-ICO';
    string public constant symbol = 'pTRIA';
    uint8 public constant decimals = 18;

    function transferFrom(address from, address to, uint256 value) returns (bool) {
        revert();
    }

    function transfer(address to, uint256 value) returns (bool) {
        revert();
    }
}