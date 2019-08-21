pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/BasicToken.sol

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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

// File: contracts/Token.sol

contract Token is StandardToken, Pausable {
    string constant public name = "Bace Token";
    string constant public symbol = "BACE";
    uint8 constant public decimals =  18;

    uint256 constant public INITIAL_TOTAL_SUPPLY = 100 * 1E6 * (uint256(10) ** (decimals));

    address private addressIco;

    modifier onlyIco() {
        require(msg.sender == addressIco);
        _;
    }

    /**
    * @dev Create BACE Token contract and set pause
    * @param _ico The address of ICO contract.
    */
    function Token(address _ico) public {
        require(_ico != address(0));
        addressIco = _ico;

        totalSupply = totalSupply.add(INITIAL_TOTAL_SUPPLY);
        balances[_ico] = balances[_ico].add(INITIAL_TOTAL_SUPPLY);
        Transfer(address(0), _ico, INITIAL_TOTAL_SUPPLY);

        pause();
    }

    /**
    * @dev Transfer token for a specified address with pause feature for owner.
    * @dev Only applies when the transfer is allowed by the owner.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
        super.transfer(_to, _value);
    }

    /**
    * @dev Transfer tokens from one address to another with pause feature for owner.
    * @dev Only applies when the transfer is allowed by the owner.
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
        super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Transfer tokens from ICO address to another address.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transferFromIco(address _to, uint256 _value) onlyIco public returns (bool) {
        super.transfer(_to, _value);
    }

    /**
    * @dev Burn remaining tokens from the ICO balance.
    */
    function burnFromIco() onlyIco public {
        uint256 remainingTokens = balanceOf(addressIco);
        balances[addressIco] = balances[addressIco].sub(remainingTokens);
        totalSupply = totalSupply.sub(remainingTokens);
        Transfer(addressIco, address(0), remainingTokens);
    }

    /**
    * @dev Refund tokens from the investor balance.
    * @dev Function is needed for Refund investors ETH, if pre-ICO has failed.
    */
    function refund(address _to, uint256 _value) onlyIco public {
        require(_value <= balances[_to]);

        address addr = _to;
        balances[addr] = balances[addr].sub(_value);
        balances[addressIco] = balances[addressIco].add(_value);
        Transfer(_to, addressIco, _value);
    }
}

// File: contracts/Whitelist.sol

/**
 * @title Whitelist contract
 * @dev Whitelist for wallets.
*/
contract Whitelist is Ownable {
    mapping(address => bool) whitelist;

    uint256 public whitelistLength = 0;
	
	address private addressApi;
	
	modifier onlyPrivilegeAddresses {
        require(msg.sender == addressApi || msg.sender == owner);
        _;
    }

    /**
    * @dev Set backend Api address.
    * @dev Accept request from owner only.
    * @param _api The address of backend API.
    */
    function setApiAddress(address _api) onlyOwner public {
        require(_api != address(0));

        addressApi = _api;
    }


    /**
    * @dev Add wallet to whitelist.
    * @dev Accept request from the owner only.
    * @param _wallet The address of wallet to add.
    */  
    function addWallet(address _wallet) onlyPrivilegeAddresses public {
        require(_wallet != address(0));
        require(!isWhitelisted(_wallet));
        whitelist[_wallet] = true;
        whitelistLength++;
    }

    /**
    * @dev Remove wallet from whitelist.
    * @dev Accept request from the owner only.
    * @param _wallet The address of whitelisted wallet to remove.
    */  
    function removeWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        whitelist[_wallet] = false;
        whitelistLength--;
    }

    /**
    * @dev Check the specified wallet whether it is in the whitelist.
    * @param _wallet The address of wallet to check.
    */ 
    function isWhitelisted(address _wallet) view public returns (bool) {
        return whitelist[_wallet];
    }

}

// File: contracts/Whitelistable.sol

/**
 * @title Whitelistable contract.
 * @dev Contract that can be embedded in another contract, to add functionality "whitelist".
 */


contract Whitelistable {
    Whitelist public whitelist;

    modifier whenWhitelisted(address _wallet) {
        require(whitelist.isWhitelisted(_wallet));
        _;
    }

    /**
    * @dev Constructor for Whitelistable contract.
    */
    function Whitelistable() public {
        whitelist = new Whitelist();
    }
}

// File: contracts/Crowdsale.sol

contract Crowdsale is Pausable, Whitelistable {
    using SafeMath for uint256;

    /////////////////////////////
    //Constant block
    //
    // DECIMALS = 18
    uint256 constant private DECIMALS = 18;
    // rate 1 ETH = 180 BACE tokens
    uint256 constant public BACE_ETH = 1800;
    // Bonus: 20%
    uint256 constant public PREICO_BONUS = 20;
    // 20 000 000 * 10^18
    uint256 constant public RESERVED_TOKENS_BACE_TEAM = 20 * 1E6 * (10 ** DECIMALS);
    // 10 000 000 * 10^18
    uint256 constant public RESERVED_TOKENS_ANGLE = 10 * 1E6 * (10 ** DECIMALS);
    // 10 000 000 * 10^18
    uint256 constant public HARDCAP_TOKENS_PRE_ICO = 10 * 1E6 * (10 ** DECIMALS);
    // 70 000 000 * 10^18
    uint256 constant public HARDCAP_TOKENS_ICO = 70 * 1E6 * (10 ** DECIMALS);
    // 5 000 000 * 10^18
    uint256 constant public MINCAP_TOKENS = 5 * 1E6 * (10 ** DECIMALS);
    /////////////////////////////

    /////////////////////////////
    //Live cycle block
    //
    uint256 public maxInvestments;

    uint256 public minInvestments;

    /**
     * @dev test mode.
     * @dev if test mode is "true" allows to change caps in an deployed contract
     */
    bool private testMode;

    /**
     * @dev contract BACE token object.
     */
    Token public token;

    /**
     * @dev start time of PreIco stage.
     */
    uint256 public preIcoStartTime;

    /**
     * @dev finish time of PreIco stage.
     */
    uint256 public preIcoFinishTime;

    /**
     * @dev start time of Ico stage.
     */
    uint256 public icoStartTime;

    /**
     * @dev finish time of Ico stage.
     */
    uint256 public icoFinishTime;

    /**
     * @dev were the Ico dates set?
     */
    bool public icoInstalled;

    /**
     * @dev The address to backend program.
     */
    address private backendWallet;

    /**
     * @dev The address to which raised funds will be withdrawn.
     */
    address private withdrawalWallet;

    /**
     * @dev The guard interval.
     */
    uint256 public guardInterval;
    ////////////////////////////

    /////////////////////////////
    //ETH block
    //
    /**
     * @dev Map of investors. Key = address, Value = Total ETH at PreIco.
     */
    mapping(address => uint256) public preIcoInvestors;

    /**
     * @dev Array of addresses of investors at PreIco.
     */
    address[] public preIcoInvestorsAddresses;

    /**
     * @dev Map of investors. Key = address, Value = Total ETH at Ico.
     */
    mapping(address => uint256) public icoInvestors;

    /**
     * @dev Array of addresses of investors at Ico.
     */
    address[] public icoInvestorsAddresses;

    /**
     * @dev Amount of investment collected in PreIco stage. (without BTC investment)
     */
    uint256 public preIcoTotalCollected;

    /**
     * @dev Amount of investment collected in Ico stage. (without BTC investment)
     */
    uint256 public icoTotalCollected;
    ////////////////////////////

    ////////////////////////////
    //Tokens block
    //

    /**
     * @dev Map of investors. Key = address, Value = Total tokens at PreIco.
     */
    mapping(address => uint256) public preIcoTokenHolders;

    /**
     * @dev Array of addresses of investors.
     */
    address[] public preIcoTokenHoldersAddresses;

    /**
     * @dev Map of investors. Key = address, Value = Total tokens at PreIco.
     */
    mapping(address => uint256) public icoTokenHolders;

    /**
     * @dev Array of addresses of investors.
     */
    address[] public icoTokenHoldersAddresses;

    /**
     * @dev the minimum amount in tokens for the investment.
     */
    uint256 public minCap;

    /**
     * @dev the maximum amount in tokens for the investment in the PreIco stage.
     */
    uint256 public hardCapPreIco;

    /**
     * @dev the maximum amount in tokens for the investment in the Ico stage.
     */
    uint256 public hardCapIco;

    /**
     * @dev number of sold tokens issued in  PreIco stage.
     */
    uint256 public preIcoSoldTokens;

    /**
     * @dev number of sold tokens issued in Ico stage.
     */
    uint256 public icoSoldTokens;

    /**
     * @dev The BACE token exchange rate for PreIco stage.
     */
    uint256 public exchangeRatePreIco;

    /**
     * @dev The BACE token exchange rate for Ico stage.
     */
    uint256 public exchangeRateIco;

    /**
     * @dev unsold BACE tokens burned?.
     */
    bool burnt;
    ////////////////////////////

    /**
     * @dev Constructor for Crowdsale contract.
     * @dev Set the owner who can manage whitelist and token.
     * @param _startTimePreIco The PreIco start time.
     * @param _endTimePreIco The PreIco end time.
     * @param _angelInvestorsWallet The address to which reserved tokens angel investors will be transferred.
     * @param _foundersWallet The address to which reserved tokens for founders will be transferred.
     * @param _backendWallet The address to backend program.
     * @param _withdrawalWallet The address to which raised funds will be withdrawn.
     * @param _testMode test mode is on?
     */
    function Crowdsale (
        uint256 _startTimePreIco,
        uint256 _endTimePreIco,
        address _angelInvestorsWallet,
        address _foundersWallet,
        address _backendWallet,
        address _withdrawalWallet,
        uint256 _maxInvestments,
        uint256 _minInvestments,
        bool _testMode
    ) public Whitelistable()
    {
        require(_angelInvestorsWallet != address(0) && _foundersWallet != address(0) && _backendWallet != address(0) && _withdrawalWallet != address(0));
        require(_startTimePreIco >= now && _endTimePreIco > _startTimePreIco);
        require(_maxInvestments != 0 && _minInvestments != 0 && _maxInvestments > _minInvestments);

        ////////////////////////////
        //Live cycle block init
        //
        testMode = _testMode;
        token = new Token(this);
        maxInvestments = _maxInvestments;
        minInvestments = _minInvestments;
        preIcoStartTime = _startTimePreIco;
        preIcoFinishTime = _endTimePreIco;
        icoStartTime = 0;
        icoFinishTime = 0;
        icoInstalled = false;
        guardInterval = uint256(86400).mul(7); //guard interval - 1 week
        /////////////////////////////

        ////////////////////////////
        //ETH block init
        preIcoTotalCollected = 0;
        icoTotalCollected = 0;
        /////////////////////////////

        ////////////////////////////
        //Tokens block init
        //
        minCap = MINCAP_TOKENS;
        hardCapPreIco = HARDCAP_TOKENS_PRE_ICO;
        hardCapIco = HARDCAP_TOKENS_ICO;
        preIcoSoldTokens = 0;
        icoSoldTokens = 0;
        exchangeRateIco = BACE_ETH;
        exchangeRatePreIco = exchangeRateIco.mul(uint256(100).add(PREICO_BONUS)).div(100);
        burnt = false;
        ////////////////////////////

        backendWallet = _backendWallet;
        withdrawalWallet = _withdrawalWallet;

        whitelist.transferOwnership(msg.sender);

        token.transferFromIco(_angelInvestorsWallet, RESERVED_TOKENS_ANGLE);
        token.transferFromIco(_foundersWallet, RESERVED_TOKENS_BACE_TEAM);
        token.transferOwnership(msg.sender);
    }

    modifier isTestMode() {
        require(testMode);
        _;
    }

    /**
     * @dev check Ico Failed.
     * @return bool true if Ico Failed.
     */
    function isIcoFailed() public view returns (bool) {
        return isIcoFinish() && icoSoldTokens.add(preIcoSoldTokens) < minCap;
    }

    /**
     * @dev check Ico Success.
     * @return bool true if Ico Success.
     */
    function isIcoSuccess() public view returns (bool) {
        return isIcoFinish() && icoSoldTokens.add(preIcoSoldTokens) >= minCap;
    }

    /**
     * @dev check PreIco Stage.
     * @return bool true if PreIco Stage now.
     */
    function isPreIcoStage() public view returns (bool) {
        return now > preIcoStartTime && now < preIcoFinishTime;
    }

    /**
     * @dev check Ico Stage.
     * @return bool true if Ico Stage now.
     */
    function isIcoStage() public view returns (bool) {
        return icoInstalled && now > icoStartTime && now < icoFinishTime;
    }

    /**
     * @dev check PreIco Finish.
     * @return bool true if PreIco Finished.
     */
    function isPreIcoFinish() public view returns (bool) {
        return now > preIcoFinishTime;
    }

    /**
     * @dev check Ico Finish.
     * @return bool true if Ico Finished.
     */
    function isIcoFinish() public view returns (bool) {
        return icoInstalled && now > icoFinishTime;
    }

    /**
     * @dev guard interval finished?
     * @return bool true if guard Interval finished.
     */
    function guardIntervalFinished() public view returns (bool) {
        return now > icoFinishTime.add(guardInterval);
    }

    /**
     * @dev Set start time and end time for Ico.
     * @param _startTimeIco The Ico start time.
     * @param _endTimeIco The Ico end time.
     */
    function setStartTimeIco(uint256 _startTimeIco, uint256 _endTimeIco) onlyOwner public {
        require(_startTimeIco >= now && _endTimeIco > _startTimeIco && _startTimeIco > preIcoFinishTime);

        icoStartTime = _startTimeIco;
        icoFinishTime = _endTimeIco;
        icoInstalled = true;
    }

    /**
     * @dev Remaining amount of tokens for PreIco stage.
     */
    function tokensRemainingPreIco() public view returns(uint256) {
        if (isPreIcoFinish()) {
            return 0;
        }
        return hardCapPreIco.sub(preIcoSoldTokens);
    }

    /**
     * @dev Remaining amount of tokens for Ico stage.
     */
    function tokensRemainingIco() public view returns(uint256) {
        if (burnt) {
            return 0;
        }
        if (isPreIcoFinish()) {
            return hardCapIco.sub(icoSoldTokens).sub(preIcoSoldTokens);
        }
        return hardCapIco.sub(hardCapPreIco).sub(icoSoldTokens);
    }

    /**
     * @dev Add information about the investment at the PreIco stage.
     * @param _addr Investor's address.
     * @param _weis Amount of wei(1 ETH = 1 * 10 ** 18 wei) received.
     * @param _tokens Amount of Token for investor.
     */
    function addInvestInfoPreIco(address _addr,  uint256 _weis, uint256 _tokens) private {
        if (preIcoTokenHolders[_addr] == 0) {
            preIcoTokenHoldersAddresses.push(_addr);
        }
        preIcoTokenHolders[_addr] = preIcoTokenHolders[_addr].add(_tokens);
        preIcoSoldTokens = preIcoSoldTokens.add(_tokens);
        if (_weis > 0) {
            if (preIcoInvestors[_addr] == 0) {
                preIcoInvestorsAddresses.push(_addr);
            }
            preIcoInvestors[_addr] = preIcoInvestors[_addr].add(_weis);
            preIcoTotalCollected = preIcoTotalCollected.add(_weis);
        }
    }

    /**
     * @dev Add information about the investment at the Ico stage.
     * @param _addr Investor's address.
     * @param _weis Amount of wei(1 ETH = 1 * 10 ** 18 wei) received.
     * @param _tokens Amount of Token for investor.
     */
    function addInvestInfoIco(address _addr,  uint256 _weis, uint256 _tokens) private {
        if (icoTokenHolders[_addr] == 0) {
            icoTokenHoldersAddresses.push(_addr);
        }
        icoTokenHolders[_addr] = icoTokenHolders[_addr].add(_tokens);
        icoSoldTokens = icoSoldTokens.add(_tokens);
        if (_weis > 0) {
            if (icoInvestors[_addr] == 0) {
                icoInvestorsAddresses.push(_addr);
            }
            icoInvestors[_addr] = icoInvestors[_addr].add(_weis);
            icoTotalCollected = icoTotalCollected.add(_weis);
        }
    }

    /**
     * @dev Fallback function can be used to buy tokens.
     */
    function() public payable {
        acceptInvestments(msg.sender, msg.value);
    }

    /**
     * @dev function can be used to buy tokens by ETH investors.
     */
    function sellTokens() public payable {
        acceptInvestments(msg.sender, msg.value);
    }

    /**
     * @dev Function processing new investments.
     * @param _addr Investor's address.
     * @param _amount The amount of wei(1 ETH = 1 * 10 ** 18 wei) received.
     */
    function acceptInvestments(address _addr, uint256 _amount) private whenWhitelisted(msg.sender) whenNotPaused {
        require(_addr != address(0) && _amount >= minInvestments);

        bool preIco = isPreIcoStage();
        bool ico = isIcoStage();

        require(preIco || ico);
        require((preIco && tokensRemainingPreIco() > 0) || (ico && tokensRemainingIco() > 0));

        uint256 intermediateEthInvestment;
        uint256 ethSurrender = 0;
        uint256 currentEth = preIco ? preIcoInvestors[_addr] : icoInvestors[_addr];

        if (currentEth.add(_amount) > maxInvestments) {
            intermediateEthInvestment = maxInvestments.sub(currentEth);
            ethSurrender = ethSurrender.add(_amount.sub(intermediateEthInvestment));
        } else {
            intermediateEthInvestment = _amount;
        }

        uint256 currentRate = preIco ? exchangeRatePreIco : exchangeRateIco;
        uint256 intermediateTokenInvestment = intermediateEthInvestment.mul(currentRate);
        uint256 tokensRemaining = preIco ? tokensRemainingPreIco() : tokensRemainingIco();
        uint256 currentTokens = preIco ? preIcoTokenHolders[_addr] : icoTokenHolders[_addr];
        uint256 weiToAccept;
        uint256 tokensToSell;

        if (currentTokens.add(intermediateTokenInvestment) > tokensRemaining) {
            tokensToSell = tokensRemaining;
            weiToAccept = tokensToSell.div(currentRate);
            ethSurrender = ethSurrender.add(intermediateEthInvestment.sub(weiToAccept));
        } else {
            tokensToSell = intermediateTokenInvestment;
            weiToAccept = intermediateEthInvestment;
        }

        if (preIco) {
            addInvestInfoPreIco(_addr, weiToAccept, tokensToSell);
        } else {
            addInvestInfoIco(_addr, weiToAccept, tokensToSell);
        }

        token.transferFromIco(_addr, tokensToSell);

        if (ethSurrender > 0) {
            msg.sender.transfer(ethSurrender);
        }
    }

    /**
     * @dev Function can be used to buy tokens by third-party investors.
     * @dev Only the owner or the backend can call this function.
     * @param _addr Investor's address.
     * @param _value Amount of Token for investor.
     */
    function thirdPartyInvestments(address _addr, uint256 _value) public  whenWhitelisted(_addr) whenNotPaused {
        require(msg.sender == backendWallet || msg.sender == owner);
        require(_addr != address(0) && _value > 0);

        bool preIco = isPreIcoStage();
        bool ico = isIcoStage();

        require(preIco || ico);
        require((preIco && tokensRemainingPreIco() > 0) || (ico && tokensRemainingIco() > 0));

        uint256 currentRate = preIco ? exchangeRatePreIco : exchangeRateIco;
        uint256 currentTokens = preIco ? preIcoTokenHolders[_addr] : icoTokenHolders[_addr];

        require(maxInvestments.mul(currentRate) >= currentTokens.add(_value));
        require(minInvestments.mul(currentRate) <= _value);

        uint256 tokensRemaining = preIco ? tokensRemainingPreIco() : tokensRemainingIco();

        require(tokensRemaining >= _value);

        if (preIco) {
            addInvestInfoPreIco(_addr, 0, _value);
        } else {
            addInvestInfoIco(_addr, 0, _value);
        }

        token.transferFromIco(_addr, _value);
    }

    /**
     * @dev Send raised funds to the withdrawal wallet.
     * @param _weiAmount The amount of raised funds to withdraw.
     */
    function forwardFunds(uint256 _weiAmount) public onlyOwner {
        require(isIcoSuccess() || (isIcoFailed() && guardIntervalFinished()));
        withdrawalWallet.transfer(_weiAmount);
    }

    /**
     * @dev Function for refund eth if Ico failed and guard interval has not expired.
     * @dev Any wallet can call the function.
     * @dev Function returns ETH for sender if it is a member of Ico or(and) PreIco.
     */
    function refund() public {
        require(isIcoFailed() && !guardIntervalFinished());

        uint256 ethAmountPreIco = preIcoInvestors[msg.sender];
        uint256 ethAmountIco = icoInvestors[msg.sender];
        uint256 ethAmount = ethAmountIco.add(ethAmountPreIco);

        uint256 tokensAmountPreIco = preIcoTokenHolders[msg.sender];
        uint256 tokensAmountIco = icoTokenHolders[msg.sender];
        uint256 tokensAmount = tokensAmountPreIco.add(tokensAmountIco);

        require(ethAmount > 0 && tokensAmount > 0);

        preIcoInvestors[msg.sender] = 0;
        icoInvestors[msg.sender] = 0;
        preIcoTokenHolders[msg.sender] = 0;
        icoTokenHolders[msg.sender] = 0;

        msg.sender.transfer(ethAmount);
        token.refund(msg.sender, tokensAmount);
    }

    /**
     * @dev Set new withdrawal wallet address.
     * @param _addr new withdrawal Wallet address.
     */
    function setWithdrawalWallet(address _addr) public onlyOwner {
        require(_addr != address(0));

        withdrawalWallet = _addr;
    }

    /**
        * @dev Set new backend wallet address.
        * @param _addr new backend Wallet address.
        */
    function setBackendWallet(address _addr) public onlyOwner {
        require(_addr != address(0));

        backendWallet = _addr;
    }

    /**
    * @dev Burn unsold tokens from the Ico balance.
    * @dev Only applies when the Ico was ended.
    */
    function burnUnsoldTokens() onlyOwner public {
        require(isIcoFinish());
        token.burnFromIco();
        burnt = true;
    }

    /**
     * @dev Set new MinCap.
     * @param _newMinCap new MinCap,
     */
    function setMinCap(uint256 _newMinCap) public onlyOwner isTestMode {
        require(now < preIcoFinishTime);
        minCap = _newMinCap;
    }

    /**
     * @dev Set new PreIco HardCap.
     * @param _newPreIcoHardCap new PreIco HardCap,
     */
    function setPreIcoHardCap(uint256 _newPreIcoHardCap) public onlyOwner isTestMode {
        require(now < preIcoFinishTime);
        require(_newPreIcoHardCap <= hardCapIco);
        hardCapPreIco = _newPreIcoHardCap;
    }

    /**
     * @dev Set new Ico HardCap.
     * @param _newIcoHardCap new Ico HardCap,
     */
    function setIcoHardCap(uint256 _newIcoHardCap) public onlyOwner isTestMode {
        require(now < preIcoFinishTime);
        require(_newIcoHardCap > hardCapPreIco);
        hardCapIco = _newIcoHardCap;
    }

    /**
     * @dev Count the Ico investors total.
     */
    function getIcoTokenHoldersAddressesCount() public view returns(uint256) {
        return icoTokenHoldersAddresses.length;
    }

    /**
     * @dev Count the PreIco investors total.
     */
    function getPreIcoTokenHoldersAddressesCount() public view returns(uint256) {
        return preIcoTokenHoldersAddresses.length;
    }

    /**
     * @dev Count the Ico investors total (not including third-party investors).
     */
    function getIcoInvestorsAddressesCount() public view returns(uint256) {
        return icoInvestorsAddresses.length;
    }

    /**
     * @dev Count the PreIco investors total (not including third-party investors).
     */
    function getPreIcoInvestorsAddressesCount() public view returns(uint256) {
        return preIcoInvestorsAddresses.length;
    }

    /**
     * @dev Get backend wallet address.
     */
    function getBackendWallet() public view returns(address) {
        return backendWallet;
    }

    /**
     * @dev Get Withdrawal wallet address.
     */
    function getWithdrawalWallet() public view returns(address) {
        return withdrawalWallet;
    }
}

// File: contracts/CrowdsaleFactory.sol

contract Factory {
    Crowdsale public crowdsale;

    function createCrowdsale (
        uint256 _startTimePreIco,
        uint256 _endTimePreIco,
        address _angelInvestorsWallet,
        address _foundersWallet,
        address _backendWallet,
        address _withdrawalWallet,
        uint256 _maxInvestments,
        uint256 _minInvestments,
        bool _testMode
    ) public
    {
        crowdsale = new Crowdsale(
            _startTimePreIco,
            _endTimePreIco,
            _angelInvestorsWallet,
            _foundersWallet,
            _backendWallet,
            _withdrawalWallet,
            _maxInvestments,
            _minInvestments,
            _testMode
        );

        Whitelist whitelist = crowdsale.whitelist();
        whitelist.transferOwnership(msg.sender);

        Token token = crowdsale.token();
        token.transferOwnership(msg.sender);

        crowdsale.transferOwnership(msg.sender);
    }
}