//File: node_modules/zeppelin-solidity/contracts/token/ERC20Basic.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/token/BasicToken.sol
pragma solidity ^0.4.18;






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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20.sol
pragma solidity ^0.4.18;





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

//File: node_modules/zeppelin-solidity/contracts/token/StandardToken.sol
pragma solidity ^0.4.18;






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

//File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol
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

//File: node_modules/zeppelin-solidity/contracts/token/MintableToken.sol
pragma solidity ^0.4.18;







/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

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
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

//File: node_modules/zeppelin-solidity/contracts/crowdsale/Crowdsale.sol
pragma solidity ^0.4.18;




/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

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
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
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
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}

//File: node_modules/zeppelin-solidity/contracts/token/SafeERC20.sol
pragma solidity ^0.4.18;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

//File: node_modules/zeppelin-solidity/contracts/token/TokenVesting.sol
pragma solidity ^0.4.18;






/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}

//File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol
pragma solidity ^0.4.18;





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

//File: node_modules/zeppelin-solidity/contracts/token/PausableToken.sol
pragma solidity ^0.4.18;




/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

//File: src/contracts/ico/MtnToken.sol
/**
 * @title MTN token
 *
 * @version 1.0
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity ^0.4.18;




contract MtnToken is MintableToken, PausableToken {
    string public constant name = "MedToken";
    string public constant symbol = "MTN";
    uint8 public constant decimals = 18;

    /**
     * @dev Constructor of MtnToken that instantiates a new Mintable Pauseable Token
     */
    function MtnToken() public {
        // token should not be transferrable until after all tokens have been issued
        paused = true;
    }
}

//File: src/contracts/ico/MtnCrowdsale.sol
/**
 * @title MtnCrowdsale
 *
 * Simple time and TOKEN_CAPped based crowdsale.
 *
 * @version 1.0
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity ^0.4.18;






contract MtnCrowdsale is Ownable, Crowdsale {
    /*** CONSTANTS ***/
    uint256 public constant TOTAL_TOKEN_CAP = 500e6 * 1e18;   // 500 million * 1e18 - smallest unit of MTN token
    uint256 public constant CROWDSALE_TOKENS = 175e6 * 1e18;  // 175 million * 1e18 - presale and crowdsale tokens
    uint256 public constant TOTAL_TEAM_TOKENS = 170e6 * 1e18; // 170 million * 1e18 - team tokens
    uint256 public constant TEAM_TOKENS0 = 50e6 * 1e18;       // 50 million * 1e18 - team tokens, already vested
    uint256 public constant TEAM_TOKENS1 = 60e6 * 1e18;       // 60 million * 1e18 - team tokens, vesting over 2 years
    uint256 public constant TEAM_TOKENS2 = 60e6 * 1e18;       // 60 million * 1e18 - team tokens, vesting over 4 years
    uint256 public constant COMMUNITY_TOKENS = 155e6 * 1e18;  // 155 million * 1e18 - community tokens, vesting over 4 years

    uint256 public constant MAX_CONTRIBUTION_USD = 5000;      //  USD
    uint256 public constant USD_CENT_PER_TOKEN = 25;          // in cents - smallest unit of USD E.g. 100 = 1 USD

    uint256 public constant VESTING_DURATION_4Y = 4 years;
    uint256 public constant VESTING_DURATION_2Y = 2 years;

    // true if address is allowed to invest
    mapping(address => bool) public isWhitelisted;

    // allow managers to whitelist and confirm contributions by manager accounts
    // managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;

    uint256 public maxContributionInWei;
    uint256 public tokensMinted;                            // already minted tokens (maximally = TOKEN_CAP)
    bool public capReached;                                 // set to true when cap has been reached when minting tokens
    mapping(address => uint256) public totalInvestedPerAddress;

    address public beneficiaryWallet;

    // for convenience we store vesting wallets
    address public teamVesting2Years;
    address public teamVesting4Years;
    address public communityVesting4Years;

    /*** Tracking Crowdsale Stages ***/
    bool public isCrowdsaleOver;

    /*** EVENTS  ***/
    event ChangedManager(address manager, bool active);
    event PresaleMinted(address indexed beneficiary, uint256 tokenAmount);
    event ChangedInvestorWhitelisting(address indexed investor, bool whitelisted);

    /*** MODIFIERS ***/
    modifier onlyManager() {
        require(isManager[msg.sender]);
        _;
    }

    // trying to accompish using already existing variables to determine stage - prevents manual updating of the enum stage states
    modifier onlyPresalePhase() {
        require(now < startTime);
        _;
    }

    modifier onlyCrowdsalePhase() {
        require(now >= startTime && now < endTime && !isCrowdsaleOver);
        _;
    }

    modifier respectCrowdsaleCap(uint256 _amount) {
        require(tokensMinted.add(_amount) <= CROWDSALE_TOKENS);
        _;
    }

    modifier onlyCrowdSaleOver() {
        require(isCrowdsaleOver || now > endTime || capReached);
        _;
    }

    modifier onlyValidAddress(address _address) {
        require(_address != address(0));
        _;
    }

    /**
     * @dev Deploy MTN Token Crowdsale
     * @param _startTime uint256 Start time of the crowdsale
     * @param _endTime uint256 End time of the crowdsale
     * @param _usdPerEth uint256 issueing rate tokens per wei
     * @param _wallet address Wallet address of the crowdsale
     * @param _beneficiaryWallet address wallet holding team and community tokens
     */
    function MtnCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _usdPerEth,
        address _wallet,
        address _beneficiaryWallet
        )
        Crowdsale(_startTime, _endTime, (_usdPerEth.mul(1e2)).div(USD_CENT_PER_TOKEN), _wallet)
        public
        onlyValidAddress(_beneficiaryWallet)
    {
        require(TOTAL_TOKEN_CAP == CROWDSALE_TOKENS.add(TOTAL_TEAM_TOKENS).add(COMMUNITY_TOKENS));
        require(TOTAL_TEAM_TOKENS == TEAM_TOKENS0.add(TEAM_TOKENS1).add(TEAM_TOKENS2));
        setManager(msg.sender, true);

        beneficiaryWallet = _beneficiaryWallet;

        maxContributionInWei = (MAX_CONTRIBUTION_USD.mul(1e18)).div(_usdPerEth);

        mintTeamTokens();
        mintCommunityTokens();
    }

    /**
     * @dev Create new instance of mtn token contract
     */
    function createTokenContract() internal returns (MintableToken) {
        return new MtnToken();
    }

    /**
     * @dev Set / alter manager / whitelister "account". This can be done from owner only
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        ChangedManager(_manager, _active);
    }

    /**
     * @dev whitelist investors to allow the direct investment of this crowdsale
     * @param _investor address address of the investor to be whitelisted
     */
    function whiteListInvestor(address _investor) public onlyManager onlyValidAddress(_investor) {
        isWhitelisted[_investor] = true;
        ChangedInvestorWhitelisting(_investor, true);
    }

    /**
     * @dev whitelist several investors via a batch method
     * @param _investors address[] array of addresses of the beneficiaries to receive tokens after they have been confirmed
     */
    function batchWhiteListInvestors(address[] _investors) public onlyManager {
        for (uint256 c; c < _investors.length; c = c.add(1)) {
            whiteListInvestor(_investors[c]);
        }
    }

    /**
     * @dev unwhitelist investor from participating in the crowdsale
     * @param _investor address address of the investor to disallowed participation
     */
    function unWhiteListInvestor(address _investor) public onlyManager onlyValidAddress(_investor) {
        isWhitelisted[_investor] = false;
        ChangedInvestorWhitelisting(_investor, false);
    }

   /**
    * @dev onlyOwner allowed to mint tokens, respecting the cap, and only before the crowdsale starts
    * @param _beneficiary address
    * @param _amount uint256
    */
    function mintTokenPreSale(address _beneficiary, uint256 _amount) public onlyOwner onlyPresalePhase onlyValidAddress(_beneficiary) respectCrowdsaleCap(_amount) {
        require(_amount > 0);

        tokensMinted = tokensMinted.add(_amount);
        token.mint(_beneficiary, _amount);
        PresaleMinted(_beneficiary, _amount);
    }

   /**
    * @dev onlyOwner allowed to handle batch presale minting
    * @param _beneficiaries address[]
    * @param _amounts uint256[]
    */
    function batchMintTokenPresale(address[] _beneficiaries, uint256[] _amounts) public onlyOwner onlyPresalePhase {
        require(_beneficiaries.length == _amounts.length);

        for (uint256 i; i < _beneficiaries.length; i = i.add(1)) {
            mintTokenPreSale(_beneficiaries[i], _amounts[i]);
        }
    }

   /**
    * @dev override core functionality by whitelist check
    * @param _beneficiary address
    */
    function buyTokens(address _beneficiary) public payable onlyCrowdsalePhase onlyValidAddress(_beneficiary) {
        require(isWhitelisted[msg.sender]);
        require(validPurchase());

        uint256 overflowTokens;
        uint256 refundWeiAmount;
        bool overMaxInvestmentAllowed;

        uint256 investedWeiAmount = msg.value;

        // Is this specific investment over the MAX_CONTRIBUTION_USD limit?
        // if so, calcuate wei refunded and tokens to mint for the allowed investment amount
        uint256 totalInvestedWeiAmount = investedWeiAmount.add(totalInvestedPerAddress[msg.sender]);
        if (totalInvestedWeiAmount > maxContributionInWei) {
            overMaxInvestmentAllowed = true;
            refundWeiAmount = totalInvestedWeiAmount.sub(maxContributionInWei);
            investedWeiAmount = investedWeiAmount.sub(refundWeiAmount);
        }

        uint256 tokenAmount = investedWeiAmount.mul(rate);
        uint256 tempMintedTokens = tokensMinted.add(tokenAmount); // gas optimization, do not inline twice

        // check to see if this purchase sets it over the crowdsale token cap
        // if so, calculate tokens to mint, then refund the remaining ether investment
        if (tempMintedTokens >= CROWDSALE_TOKENS) {
            capReached = true;
            overflowTokens = tempMintedTokens.sub(CROWDSALE_TOKENS);
            tokenAmount = tokenAmount.sub(overflowTokens);
            refundWeiAmount = overflowTokens.div(rate);
            investedWeiAmount = investedWeiAmount.sub(refundWeiAmount);
        }

        weiRaised = weiRaised.add(investedWeiAmount);

        tokensMinted = tokensMinted.add(tokenAmount);
        TokenPurchase(msg.sender, _beneficiary, investedWeiAmount, tokenAmount);
        totalInvestedPerAddress[msg.sender] = totalInvestedPerAddress[msg.sender].add(investedWeiAmount);
        token.mint(_beneficiary, tokenAmount);

        // if investor breached cap and has remaining ether not invested
        // refund remaining ether to investor
        if (capReached || overMaxInvestmentAllowed) {
            msg.sender.transfer(refundWeiAmount);
            wallet.transfer(investedWeiAmount);
        } else {
            forwardFunds();
        }
    }

   /**
    * @dev onlyOwner to close Crowdsale manually if before endTime
    */
    function closeCrowdsale() public onlyOwner onlyCrowdsalePhase {
        isCrowdsaleOver = true;
    }

   /**
    * @dev onlyOwner allows tokens to be tradeable
    */
    function finalize() public onlyOwner onlyCrowdSaleOver {
        // do not allow new owner to mint further tokens & unpause token to allow trading
        MintableToken(token).finishMinting();
        PausableToken(token).unpause();
    }

    /*** INTERNAL/PRIVATE FUNCTIONS ***/

    /**
     * @dev allows contract owner to mint all team tokens per TEAM_TOKENS and have 50m immediately available, 60m 2 years vested, and 60m over 4 years vesting
     */
    function mintTeamTokens() private {
        token.mint(beneficiaryWallet, TEAM_TOKENS0);

        TokenVesting newVault1 = new TokenVesting(beneficiaryWallet, now, 0, VESTING_DURATION_2Y, false);
        teamVesting2Years = address(newVault1); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan
        token.mint(address(newVault1), TEAM_TOKENS1);

        TokenVesting newVault2 = new TokenVesting(beneficiaryWallet, now, 0, VESTING_DURATION_4Y, false);
        teamVesting4Years = address(newVault2); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan
        token.mint(address(newVault2), TEAM_TOKENS2);
    }

    /**
     * @dev allows contract owner to mint all community tokens per COMMUNITY_TOKENS and have the vested to the beneficiaryWallet
     */
    function mintCommunityTokens() private {
        TokenVesting newVault = new TokenVesting(beneficiaryWallet, now, 0, VESTING_DURATION_4Y, false);
        communityVesting4Years = address(newVault); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan
        token.mint(address(newVault), COMMUNITY_TOKENS);
    }

    /**
     * @dev extend base functionality with min investment amount
     */
    function validPurchase() internal view respectCrowdsaleCap(0) returns (bool) {
        require(!capReached);
        require(totalInvestedPerAddress[msg.sender] < maxContributionInWei);

        return super.validPurchase();
    }
}