pragma solidity ^0.4.15;

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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

// File: contracts/BurnableToken.sol

/**
* @title Customized Burnable Token
* @dev Token that can be irreversibly burned (destroyed).
*/
contract BurnableToken is StandardToken, Ownable {

    event Burn(address indexed burner, uint256 amount);

    /**
    * @dev Anybody can burn a specific amount of their tokens.
    * @param _amount The amount of token to be burned.
    */
    function burn(uint256 _amount) public {
        require(_amount > 0);
        require(_amount <= balances[msg.sender]);
        // no need to require _amount <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        Transfer(burner, address(0), _amount);
        Burn(burner, _amount);
    }

    /**
    * @dev Owner can burn a specific amount of tokens of other token holders.
    * @param _from The address of token holder whose tokens to be burned.
    * @param _amount The amount of token to be burned.
    */
    function burnFrom(address _from, uint256 _amount) onlyOwner public {
        require(_from != address(0));
        require(_amount > 0);
        require(_amount <= balances[_from]);
        // no need to require _amount <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        Transfer(_from, address(0), _amount);
        Burn(_from, _amount);
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

// File: contracts/GiftToken.sol

contract GiftToken is BurnableToken, Pausable {
    string constant public name = "Giftcoin";
    string constant public symbol = "GIFT";
    uint8 constant public decimals = 18;

    uint256 constant public INITIAL_TOTAL_SUPPLY = 2e7 * (uint256(10) ** decimals);

    address private addressIco;

    modifier onlyIco() {
        require(msg.sender == addressIco);
        _;
    }

    /**
    * @dev Create GiftToken contract and set pause
    * @param _ico The address of ICO contract.
    */
    function GiftToken (address _ico) {
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
}

// File: contracts/Whitelist.sol

/**
 * @title Whitelist contract
 * @dev Whitelist for wallets, with additional data for every wallet.
*/
contract Whitelist is Ownable {
    struct WalletInfo {
        string data;
        bool whitelisted;
    }

    address private addressApi;

    mapping(address => WalletInfo) public whitelist;

    uint256 public whitelistLength = 0;

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
    * @dev Accept request from privilege adresses only.
    * @param _wallet The address of wallet to add.
    * @param _data The checksum of additional wallet data.
    */  
    function addWallet(address _wallet, string _data) onlyPrivilegeAddresses public {
        require(_wallet != address(0));
        require(!isWhitelisted(_wallet));
        whitelist[_wallet].data = _data;
        whitelist[_wallet].whitelisted = true;
        whitelistLength++;
    }

    /**
    * @dev Update additional data for whitelisted wallet.
    * @dev Accept request from privilege adresses only.
    * @param _wallet The address of whitelisted wallet to update.
    * @param _data The checksum of new additional wallet data.
    */      
    function updateWallet(address _wallet, string _data) onlyPrivilegeAddresses public {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        whitelist[_wallet].data = _data;
    }

    /**
    * @dev Remove wallet from whitelist.
    * @dev Accept request from privilege adresses only.
    * @param _wallet The address of whitelisted wallet to remove.
    */  
    function removeWallet(address _wallet) onlyPrivilegeAddresses public {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        delete whitelist[_wallet];
        whitelistLength--;
    }

    /**
    * @dev Check the specified wallet whether it is in the whitelist.
    * @param _wallet The address of wallet to check.
    */ 
    function isWhitelisted(address _wallet) constant public returns (bool) {
        return whitelist[_wallet].whitelisted;
    }

    /**
    * @dev Get the checksum of additional data for the specified whitelisted wallet.
    * @param _wallet The address of wallet to get.
    */ 
    function walletData(address _wallet) constant public returns (string) {
        return whitelist[_wallet].data;
    }

}

// File: contracts/Whitelistable.sol

contract Whitelistable {
    Whitelist public whitelist;

    modifier whenWhitelisted(address _wallet) {
        require(whitelist.isWhitelisted(_wallet));
        _;
    }

    function Whitelistable () public {
        whitelist = new Whitelist();

        whitelist.transferOwnership(msg.sender);
    }
}

// File: contracts/GiftCrowdsale.sol

contract GiftCrowdsale is Pausable, Whitelistable {
    using SafeMath for uint256;

    uint256 public startTimestamp = 0;

    uint256 public endTimestamp = 0;

    uint256 public exchangeRate = 0;

    uint256 public tokensSold = 0;

    uint256 constant public minimumInvestment = 25e16; // 0.25 ETH

    uint256 public minCap = 0;

    uint256 public endFirstPeriodTimestamp = 0;

    uint256 public endSecondPeriodTimestamp = 0;

    uint256 public endThirdPeriodTimestamp = 0;

    GiftToken public token = new GiftToken(this);

    mapping(address => uint256) public investments;

    modifier whenSaleIsOpen () {
        require(now >= startTimestamp && now < endTimestamp);
        _;
    }

    modifier whenSaleHasEnded () {
        require(now >= endTimestamp);
        _;
    }

    /**
    * @dev Constructor for GiftCrowdsale contract.
    * @dev Set first owner who can manage whitelist.
    * @param _startTimestamp uint256 The start time ico.
    * @param _endTimestamp uint256 The end time ico.
    * @param _exchangeRate uint256 The price of the Gift token.
    * @param _minCap The minimum amount of tokens sold required for the ICO to be considered successful.
    */
    function GiftCrowdsale (
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _exchangeRate,
        uint256 _minCap
    ) public
    {
        require(_startTimestamp >= now && _endTimestamp > _startTimestamp);
        require(_exchangeRate > 0);

        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;

        exchangeRate = _exchangeRate;

        endFirstPeriodTimestamp = _startTimestamp.add(1 days);

        endSecondPeriodTimestamp = _startTimestamp.add(1 weeks);

        endThirdPeriodTimestamp = _startTimestamp.add(2 weeks);

        minCap = _minCap;
    }

    function discount() constant public returns (uint256) {
        if (now > endThirdPeriodTimestamp)
            return 0;
        if (now > endSecondPeriodTimestamp)
            return 15;
        if (now > endFirstPeriodTimestamp)
            return 25;
        return 35;
    }

    function bonus() constant public returns (uint256) {
        if (now > endSecondPeriodTimestamp)
            return 0;
        if (now > endFirstPeriodTimestamp)
            return 3;
        return 5;
    }

    /**
    * @dev Function for sell tokens.
    * @dev Sells tokens only for wallets from Whitelist while ICO lasts
    */
    function sellTokens () whenSaleIsOpen whenWhitelisted(msg.sender) whenNotPaused public payable {
        require(msg.value > minimumInvestment);
        uint256 _bonus = bonus();
        uint256 _discount = discount();
        uint256 tokensAmount = (msg.value).mul(exchangeRate).mul(_bonus.add(100)).div((100 - _discount));

        token.transferFromIco(msg.sender, tokensAmount);

        tokensSold = tokensSold.add(tokensAmount);

        addInvestment(msg.sender, msg.value);
    }

    /**
    * @dev Fallback function allowing the contract to receive funds
    */
    function () public payable {
        sellTokens();
    }

    /**
    * @dev Function for funds withdrawal
    * @dev transfers funds to specified wallet once ICO is ended
    * @param _wallet address wallet address, to  which funds  will be transferred
    */
    function withdrawal (address _wallet) onlyOwner whenSaleHasEnded external {
        require(_wallet != address(0));
        _wallet.transfer(this.balance);

        token.transferOwnership(msg.sender);
    }

    /**
    * @dev Function for manual token assignment (token transfer from ICO to requested wallet)
    * @param _to address The address which you want transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function assignTokens (address _to, uint256 _value) onlyOwner external {
        token.transferFromIco(_to, _value);
    }

    /**
    * @dev Add new investment to the ICO investments storage.
    * @param _from The address of a ICO investor.
    * @param _value The investment received from a ICO investor.
    */
    function addInvestment(address _from, uint256 _value) internal {
        investments[_from] = investments[_from].add(_value);
    }

    /**
    * @dev Function to return money to one customer, if mincap has not been reached
    */
    function refundPayment() whenWhitelisted(msg.sender) whenSaleHasEnded external {
        require(tokensSold < minCap);
        require(investments[msg.sender] > 0);

        token.burnFrom(msg.sender, token.balanceOf(msg.sender));

        uint256 investment = investments[msg.sender];
        investments[msg.sender] = 0;
        (msg.sender).transfer(investment);
    }

    /**
    * @dev Allows the current owner to transfer control of the token contract from ICO to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferTokenOwnership(address _newOwner) onlyOwner public {
        token.transferOwnership(_newOwner);
    }

    function updateIcoEnding(uint256 _endTimestamp) onlyOwner public {
        endTimestamp = _endTimestamp;
    }
}