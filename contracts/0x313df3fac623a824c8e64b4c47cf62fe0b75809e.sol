pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: zeppelin-solidity/contracts/examples/SimpleToken.sol

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract SimpleToken is StandardToken {

  string public constant name = "SimpleToken"; // solium-disable-line uppercase
  string public constant symbol = "SIM"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function SimpleToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

}

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

// File: contracts/LockedOutTokens.sol

// for unit test purposes only



contract LockedOutTokens is Ownable {

    address public wallet;
    uint8 public tranchesCount;
    uint256 public trancheSize;
    uint256 public period;

    uint256 public startTimestamp;
    uint8 public tranchesPayedOut = 0;

    ERC20Basic internal token;
    
    function LockedOutTokens(
        address _wallet,
        address _tokenAddress,
        uint256 _startTimestamp,
        uint8 _tranchesCount,
        uint256 _trancheSize,
        uint256 _periodSeconds
    ) {
        require(_wallet != address(0));
        require(_tokenAddress != address(0));
        require(_startTimestamp > 0);
        require(_tranchesCount > 0);
        require(_trancheSize > 0);
        require(_periodSeconds > 0);

        wallet = _wallet;
        tranchesCount = _tranchesCount;
        startTimestamp = _startTimestamp;
        trancheSize = _trancheSize;
        period = _periodSeconds;

        token = ERC20Basic(_tokenAddress);
    }

    function grant()
        public
    {
        require(wallet == msg.sender);
        require(tranchesPayedOut < tranchesCount);
        require(startTimestamp > 0);
        require(now >= startTimestamp + (period * (tranchesPayedOut + 1)));

        tranchesPayedOut = tranchesPayedOut + 1;
        token.transfer(wallet, trancheSize);
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

// File: contracts/TiqpitToken.sol

contract TiqpitToken is StandardToken, Pausable {
    using SafeMath for uint256;

    string constant public name = "Tiqpit Token";
    string constant public symbol = "PIT";
    uint8 constant public decimals = 18;

    string constant public smallestUnitName = "TIQ";

    uint256 constant public INITIAL_TOTAL_SUPPLY = 500e6 * (uint256(10) ** decimals);

    address private addressIco;

    modifier onlyIco() {
        require(msg.sender == addressIco);
        _;
    }
    
    /**
    * @dev Create TiqpitToken contract and set pause
    * @param _ico The address of ICO contract.
    */
    function TiqpitToken (address _ico) public {
        require(_ico != address(0));

        addressIco = _ico;

        totalSupply_ = totalSupply_.add(INITIAL_TOTAL_SUPPLY);
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
    * @dev Burn a specific amount of tokens of other token holders if refund process enable.
    * @param _from The address of token holder whose tokens to be burned.
    */
    function burnFromAddress(address _from) onlyIco public {
        uint256 amount = balances[_from];

        require(_from != address(0));
        require(amount > 0);
        require(amount <= balances[_from]);

        balances[_from] = balances[_from].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
        Transfer(_from, address(0), amount);
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

    address public backendAddress;

    /**
    * @dev Add wallet to whitelist.
    * @dev Accept request from the owner only.
    * @param _wallet The address of wallet to add.
    */  
    function addWallet(address _wallet) public onlyPrivilegedAddresses {
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
    function removeWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        require(isWhitelisted(_wallet));
        whitelist[_wallet] = false;
        whitelistLength--;
    }

    /**
    * @dev Check the specified wallet whether it is in the whitelist.
    * @param _wallet The address of wallet to check.
    */ 
    function isWhitelisted(address _wallet) constant public returns (bool) {
        return whitelist[_wallet];
    }

    /**
    * @dev Sets the backend address for automated operations.
    * @param _backendAddress The backend address to allow.
    */
    function setBackendAddress(address _backendAddress) public onlyOwner {
        require(_backendAddress != address(0));
        backendAddress = _backendAddress;
    }

    /**
    * @dev Allows the function to be called only by the owner and backend.
    */
    modifier onlyPrivilegedAddresses() {
        require(msg.sender == owner || msg.sender == backendAddress);
        _;
    }
}

// File: contracts/Whitelistable.sol

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

// File: contracts/TiqpitCrowdsale.sol

contract TiqpitCrowdsale is Pausable, Whitelistable {
    using SafeMath for uint256;

    uint256 constant private DECIMALS = 18;
    
    uint256 constant public RESERVED_TOKENS_BOUNTY = 10e6 * (10 ** DECIMALS);
    uint256 constant public RESERVED_TOKENS_FOUNDERS = 25e6 * (10 ** DECIMALS);
    uint256 constant public RESERVED_TOKENS_ADVISORS = 25e5 * (10 ** DECIMALS);
    uint256 constant public RESERVED_TOKENS_TIQPIT_SOLUTIONS = 625e5 * (10 ** DECIMALS);

    uint256 constant public MIN_INVESTMENT = 200 * (10 ** DECIMALS);
    
    uint256 constant public MINCAP_TOKENS_PRE_ICO = 1e6 * (10 ** DECIMALS);
    uint256 constant public MAXCAP_TOKENS_PRE_ICO = 75e5 * (10 ** DECIMALS);
    
    uint256 constant public MINCAP_TOKENS_ICO = 5e6 * (10 ** DECIMALS);    
    uint256 constant public MAXCAP_TOKENS_ICO = 3925e5 * (10 ** DECIMALS);

    uint256 public tokensRemainingIco = MAXCAP_TOKENS_ICO;
    uint256 public tokensRemainingPreIco = MAXCAP_TOKENS_PRE_ICO;

    uint256 public soldTokensPreIco = 0;
    uint256 public soldTokensIco = 0;
    uint256 public soldTokensTotal = 0;

    uint256 public preIcoRate = 2857;        // 1 PIT = 0.00035 ETH //Base rate for  Pre-ICO stage.

    // ICO rates
    uint256 public firstRate = 2500;         // 1 PIT = 0.0004 ETH
    uint256 public secondRate = 2222;        // 1 PIT = 0.00045 ETH
    uint256 public thirdRate = 2000;         // 1 PIT = 0.0005 ETH

    uint256 public startTimePreIco = 0;
    uint256 public endTimePreIco = 0;

    uint256 public startTimeIco = 0;
    uint256 public endTimeIco = 0;

    uint256 public weiRaisedPreIco = 0;
    uint256 public weiRaisedIco = 0;
    uint256 public weiRaisedTotal = 0;

    TiqpitToken public token = new TiqpitToken(this);

    // Key - address of wallet, Value - address of  contract.
    mapping (address => address) private lockedList;

    address private tiqpitSolutionsWallet;
    address private foundersWallet;
    address private advisorsWallet;
    address private bountyWallet;

    address public backendAddress;

    bool private hasPreIcoFailed = false;
    bool private hasIcoFailed = false;

    bool private isInitialDistributionDone = false;

    struct Purchase {
        uint256 refundableWei;
        uint256 burnableTiqs;
    }

    mapping(address => Purchase) private preIcoPurchases;
    mapping(address => Purchase) private icoPurchases;

    /**
    * @dev Constructor for TiqpitCrowdsale contract.
    * @dev Set the owner who can manage whitelist and token.
    * @param _startTimePreIco The pre-ICO start time.
    * @param _endTimePreIco The pre-ICO end time.
    * @param _foundersWallet The address to which reserved tokens for founders will be transferred.
    * @param _advisorsWallet The address to which reserved tokens for advisors.
    * @param _tiqpitSolutionsWallet The address to which reserved tokens for Tiqpit Solutions.
    */
    function TiqpitCrowdsale(
        uint256 _startTimePreIco,
        uint256 _endTimePreIco,
        uint256 _startTimeIco,
        uint256 _endTimeIco,
        address _foundersWallet,
        address _advisorsWallet,
        address _tiqpitSolutionsWallet,
        address _bountyWallet
    ) Whitelistable() public
    {
        require(_bountyWallet != address(0) && _foundersWallet != address(0) && _tiqpitSolutionsWallet != address(0) && _advisorsWallet != address(0));
        
        require(_startTimePreIco >= now && _endTimePreIco > _startTimePreIco);
        require(_startTimeIco >= _endTimePreIco && _endTimeIco > _startTimeIco);

        startTimePreIco = _startTimePreIco;
        endTimePreIco = _endTimePreIco;

        startTimeIco = _startTimeIco;
        endTimeIco = _endTimeIco;

        tiqpitSolutionsWallet = _tiqpitSolutionsWallet;
        advisorsWallet = _advisorsWallet;
        foundersWallet = _foundersWallet;
        bountyWallet = _bountyWallet;

        whitelist.transferOwnership(msg.sender);
        token.transferOwnership(msg.sender);
    }

    /**
    * @dev Fallback function can be used to buy tokens.
    */
    function() public payable {
        sellTokens();
    }

    /**
    * @dev Check whether the pre-ICO is active at the moment.
    */
    function isPreIco() public view returns (bool) {
        return now >= startTimePreIco && now <= endTimePreIco;
    }

    /**
    * @dev Check whether the ICO is active at the moment.
    */
    function isIco() public view returns (bool) {
        return now >= startTimeIco && now <= endTimeIco;
    }

    /**
    * @dev Burn Remaining Tokens.
    */
    function burnRemainingTokens() onlyOwner public {
        require(tokensRemainingIco > 0);
        require(now > endTimeIco);

        token.burnFromAddress(this);

        tokensRemainingIco = 0;
    }

    /**
    * @dev Send tokens to Advisors & Tiqpit Solutions Wallets.
    * @dev Locked  tokens for Founders wallet.
    */
    function initialDistribution() onlyOwner public {
        require(!isInitialDistributionDone);

        token.transferFromIco(bountyWallet, RESERVED_TOKENS_BOUNTY);

        token.transferFromIco(advisorsWallet, RESERVED_TOKENS_ADVISORS);
        token.transferFromIco(tiqpitSolutionsWallet, RESERVED_TOKENS_TIQPIT_SOLUTIONS);
        
        lockTokens(foundersWallet, RESERVED_TOKENS_FOUNDERS, 1 years);

        isInitialDistributionDone = true;
    }

    /**
    * @dev Get Purchase by investor's address.
    * @param _address The address of a ICO investor.
    */
    function getIcoPurchase(address _address) view public returns(uint256 weis, uint256 tokens) {
        return (icoPurchases[_address].refundableWei, icoPurchases[_address].burnableTiqs);
    }

    /**
    * @dev Get Purchase by investor's address.
    * @param _address The address of a Pre-ICO investor.
    */
    function getPreIcoPurchase(address _address) view public returns(uint256 weis, uint256 tokens) {
        return (preIcoPurchases[_address].refundableWei, preIcoPurchases[_address].burnableTiqs);
    }

    /**
    * @dev Refund Ether invested in pre-ICO to the sender if pre-ICO failed.
    */
    function refundPreIco() public {
        require(hasPreIcoFailed);

        require(preIcoPurchases[msg.sender].burnableTiqs > 0 && preIcoPurchases[msg.sender].refundableWei > 0);
        
        uint256 amountWei = preIcoPurchases[msg.sender].refundableWei;
        msg.sender.transfer(amountWei);

        preIcoPurchases[msg.sender].refundableWei = 0;
        preIcoPurchases[msg.sender].burnableTiqs = 0;

        token.burnFromAddress(msg.sender);
    }

    /**
    * @dev Refund Ether invested in ICO to the sender if ICO failed.
    */
    function refundIco() public {
        require(hasIcoFailed);

        require(icoPurchases[msg.sender].burnableTiqs > 0 && icoPurchases[msg.sender].refundableWei > 0);
        
        uint256 amountWei = icoPurchases[msg.sender].refundableWei;
        msg.sender.transfer(amountWei);

        icoPurchases[msg.sender].refundableWei = 0;
        icoPurchases[msg.sender].burnableTiqs = 0;

        token.burnFromAddress(msg.sender);
    }

    /**
    * @dev Manual burn tokens from specified address.
    * @param _address The address of a investor.
    */
    function burnTokens(address _address) onlyOwner public {
        require(hasIcoFailed);

        require(icoPurchases[_address].burnableTiqs > 0 || preIcoPurchases[_address].burnableTiqs > 0);

        icoPurchases[_address].burnableTiqs = 0;
        preIcoPurchases[_address].burnableTiqs = 0;

        token.burnFromAddress(_address);
    }

    /**
    * @dev Manual send tokens  for  specified address.
    * @param _address The address of a investor.
    * @param _tokensAmount Amount of tokens.
    */
    function manualSendTokens(address _address, uint256 _tokensAmount) whenWhitelisted(_address) public onlyPrivilegedAddresses {
        require(_tokensAmount > 0);
        
        if (isPreIco() && _tokensAmount <= tokensRemainingPreIco) {
            token.transferFromIco(_address, _tokensAmount);

            addPreIcoPurchaseInfo(_address, 0, _tokensAmount);
        } else if (isIco() && _tokensAmount <= tokensRemainingIco && soldTokensPreIco >= MINCAP_TOKENS_PRE_ICO) {
            token.transferFromIco(_address, _tokensAmount);

            addIcoPurchaseInfo(_address, 0, _tokensAmount);
        } else {
            revert();
        }
    }

    /**
    * @dev Get Locked Contract Address.
    */
    function getLockedContractAddress(address wallet) public view returns(address) {
        return lockedList[wallet];
    }

    /**
    * @dev Enable refund process.
    */
    function triggerFailFlags() onlyOwner public {
        if (!hasPreIcoFailed && now > endTimePreIco && soldTokensPreIco < MINCAP_TOKENS_PRE_ICO) {
            hasPreIcoFailed = true;
        }

        if (!hasIcoFailed && now > endTimeIco && soldTokensIco < MINCAP_TOKENS_ICO) {
            hasIcoFailed = true;
        }
    }

    /**
    * @dev Calculate rate for ICO phase.
    */
    function currentIcoRate() public view returns(uint256) {     
        if (now > startTimeIco && now <= startTimeIco + 5 days) {
            return firstRate;
        }

        if (now > startTimeIco + 5 days && now <= startTimeIco + 10 days) {
            return secondRate;
        }

        if (now > startTimeIco + 10 days) {
            return thirdRate;
        }
    }

    /**
    * @dev Sell tokens during Pre-ICO && ICO stages.
    * @dev Sell tokens only for whitelisted wallets.
    */
    function sellTokens() whenWhitelisted(msg.sender) whenNotPaused public payable {
        require(msg.value > 0);
        
        bool preIco = isPreIco();
        bool ico = isIco();

        if (ico) {require(soldTokensPreIco >= MINCAP_TOKENS_PRE_ICO);}
        
        require((preIco && tokensRemainingPreIco > 0) || (ico && tokensRemainingIco > 0));
        
        uint256 currentRate = preIco ? preIcoRate : currentIcoRate();
        
        uint256 weiAmount = msg.value;
        uint256 tokensAmount = weiAmount.mul(currentRate);

        require(tokensAmount >= MIN_INVESTMENT);

        if (ico) {
            // Move unsold Pre-Ico tokens for current phase.
            if (tokensRemainingPreIco > 0) {
                tokensRemainingIco = tokensRemainingIco.add(tokensRemainingPreIco);
                tokensRemainingPreIco = 0;
            }
        }
       
        uint256 tokensRemaining = preIco ? tokensRemainingPreIco : tokensRemainingIco;
        if (tokensAmount > tokensRemaining) {
            uint256 tokensRemainder = tokensAmount.sub(tokensRemaining);
            tokensAmount = tokensAmount.sub(tokensRemainder);
            
            uint256 overpaidWei = tokensRemainder.div(currentRate);
            msg.sender.transfer(overpaidWei);

            weiAmount = msg.value.sub(overpaidWei);
        }

        token.transferFromIco(msg.sender, tokensAmount);

        if (preIco) {
            addPreIcoPurchaseInfo(msg.sender, weiAmount, tokensAmount);

            if (soldTokensPreIco >= MINCAP_TOKENS_PRE_ICO) {
                owner.transfer(this.balance);
            }
        }

        if (ico) {
            addIcoPurchaseInfo(msg.sender, weiAmount, tokensAmount);

            if (soldTokensIco >= MINCAP_TOKENS_ICO) {
                owner.transfer(this.balance);
            }
        }
    }

    /**
    * @dev Add new investment to the Pre-ICO investments storage.
    * @param _address The address of a Pre-ICO investor.
    * @param _amountWei The investment received from a Pre-ICO investor.
    * @param _amountTokens The tokens that will be sent to Pre-ICO investor.
    */
    function addPreIcoPurchaseInfo(address _address, uint256 _amountWei, uint256 _amountTokens) internal {
        preIcoPurchases[_address].refundableWei = preIcoPurchases[_address].refundableWei.add(_amountWei);
        preIcoPurchases[_address].burnableTiqs = preIcoPurchases[_address].burnableTiqs.add(_amountTokens);

        soldTokensPreIco = soldTokensPreIco.add(_amountTokens);
        tokensRemainingPreIco = tokensRemainingPreIco.sub(_amountTokens);

        weiRaisedPreIco = weiRaisedPreIco.add(_amountWei);

        soldTokensTotal = soldTokensTotal.add(_amountTokens);
        weiRaisedTotal = weiRaisedTotal.add(_amountWei);
    }

    /**
    * @dev Add new investment to the ICO investments storage.
    * @param _address The address of a ICO investor.
    * @param _amountWei The investment received from a ICO investor.
    * @param _amountTokens The tokens that will be sent to ICO investor.
    */
    function addIcoPurchaseInfo(address _address, uint256 _amountWei, uint256 _amountTokens) internal {
        icoPurchases[_address].refundableWei = icoPurchases[_address].refundableWei.add(_amountWei);
        icoPurchases[_address].burnableTiqs = icoPurchases[_address].burnableTiqs.add(_amountTokens);

        soldTokensIco = soldTokensIco.add(_amountTokens);
        tokensRemainingIco = tokensRemainingIco.sub(_amountTokens);

        weiRaisedIco = weiRaisedIco.add(_amountWei);

        soldTokensTotal = soldTokensTotal.add(_amountTokens);
        weiRaisedTotal = weiRaisedTotal.add(_amountWei);
    }

    /**
    * @dev Locked specified amount  of  tokens for  specified wallet.
    * @param _wallet The address of wallet.
    * @param _amount The tokens  for locked.
    * @param _time The time for locked period.
    */
    function lockTokens(address _wallet, uint256 _amount, uint256 _time) internal {
        LockedOutTokens locked = new LockedOutTokens(_wallet, token, endTimePreIco, 1, _amount, _time);
        lockedList[_wallet] = locked;
        token.transferFromIco(locked, _amount);
    }

    /**
    * @dev Sets the backend address for automated operations.
    * @param _backendAddress The backend address to allow.
    */
    function setBackendAddress(address _backendAddress) public onlyOwner {
        require(_backendAddress != address(0));
        backendAddress = _backendAddress;
    }

    /**
    * @dev Allows the function to be called only by the owner and backend.
    */
    modifier onlyPrivilegedAddresses() {
        require(msg.sender == owner || msg.sender == backendAddress);
        _;
    }
}