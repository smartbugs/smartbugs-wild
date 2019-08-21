pragma solidity 0.4.15;


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

/**
 * @title LimitedTransferToken
 * @dev LimitedTransferToken defines the generic interface and the implementation to limit token
 * transferability for different events. It is intended to be used as a base class for other token
 * contracts.
 * LimitedTransferToken has been designed to allow for different limiting factors,
 * this can be achieved by recursively calling super.transferableTokens() until the base class is
 * hit. For example:
 *     function transferableTokens(address holder, uint64 time) constant public returns (uint256) {
 *       return min256(unlockedTokens, super.transferableTokens(holder, time));
 *     }
 * A working example is VestedToken.sol:
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/VestedToken.sol
 */

contract LimitedTransferToken is ERC20 {

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer(address _sender, uint256 _value) {
   require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will receive the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will receive the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Default transferable tokens function returns all tokens for a holder (no limit).
   * @dev Overwriting transferableTokens(address holder, uint64 time) is the way to provide the
   * specific logic for limiting token transferability for a holder over time.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    return balanceOf(holder);
  }
}


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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

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

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
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

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}



contract Tiers {
  using SafeMath for uint256;

  uint256 public cpCap = 45000 ether;
  uint256 public presaleWeiSold = 18000 ether;

  uint256[6] public tierAmountCaps =  [ presaleWeiSold
                                      , presaleWeiSold + 5000 ether
                                      , presaleWeiSold + 10000 ether
                                      , presaleWeiSold + 15000 ether
                                      , presaleWeiSold + 21000 ether
                                      , cpCap
                                      ];
  uint256[6] public tierRates = [ 2000 // tierRates[0] should never be used, but it is accurate
                                , 1500 // Tokens are purchased at a rate of 105-150
                                , 1350 // per deciEth, depending on purchase tier.
                                , 1250 // tierRates[i] is the purchase rate of tier_i
                                , 1150
                                , 1050
                                ];

    function tierIndexByWeiAmount(uint256 weiLevel) public constant returns (uint256) {
        require(weiLevel <= cpCap);
        for (uint256 i = 0; i < tierAmountCaps.length; i++) {
            if (weiLevel <= tierAmountCaps[i]) {
                return i;
            }
        }
    }

    /**
     * @dev Calculates how many tokens a given amount of wei can buy at
     * a particular level of weiRaised. Takes into account tiers of purchase
     * bonus
     */
    function calculateTokens(uint256 _amountWei, uint256 _weiRaised) public constant returns (uint256) {
        uint256 currentTier = tierIndexByWeiAmount(_weiRaised);
        uint256 startWeiLevel = _weiRaised;
        uint256 endWeiLevel = _amountWei.add(_weiRaised);
        uint256 tokens = 0;
        for (uint256 i = currentTier; i < tierAmountCaps.length; i++) {
            if (endWeiLevel <= tierAmountCaps[i]) {
                tokens = tokens.add((endWeiLevel.sub(startWeiLevel)).mul(tierRates[i]));
                break;
            } else {
                tokens = tokens.add((tierAmountCaps[i].sub(startWeiLevel)).mul(tierRates[i]));
                startWeiLevel = tierAmountCaps[i];
            }
        }
        return tokens;
    }

}

contract CPToken is MintableToken, LimitedTransferToken {
    string public name = "BLOCKMASON CREDIT PROTOCOL TOKEN";
    string public symbol = "BCPT";
    uint256 public decimals = 18;

    bool public saleOver = false;

    function CPToken() {
    }

    function endSale() public onlyOwner {
        require (!saleOver);
        saleOver = true;
    }

    /**
     * @dev returns all user's tokens if time >= releaseTime
     */
    function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
        if (saleOver)
            return balanceOf(holder);
        else
            return 0;
    }

}



contract DPIcoWhitelist {
    address public admin;
    bool public isOn;
    mapping (address => bool) public whitelist;
    address[] public users;

    modifier signUpOpen() {
        if (!isOn) revert();
        _;
    }

    modifier isAdmin() {
        if (msg.sender != admin) revert();
        _;
    }

    modifier newAddr() {
        if (whitelist[msg.sender]) revert();
        _;
    }

    function DPIcoWhitelist() {
        admin = msg.sender;
        isOn = false;
    }

    function () {
        signUp();
    }

    // Public functions

    function setSignUpOnOff(bool state) public isAdmin {
        isOn = state;
    }

    function signUp() public signUpOpen newAddr {
        whitelist[msg.sender] = true;
        users.push(msg.sender);
    }

    function getAdmin() public constant returns (address) {
        return admin;
    }

    function signUpOn() public constant returns (bool) {
        return isOn;
    }

    function isSignedUp(address addr) public constant returns (bool) {
        return whitelist[addr];
    }

    function getUsers() public constant returns (address[]) {
        return users;
    }

    function numUsers() public constant returns (uint) {
        return users.length;
    }

    function userAtIndex(uint idx) public constant returns (address) {
        return users[idx];
    }
}

contract CPCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable {
    using SafeMath for uint256;

    DPIcoWhitelist private aw;
    Tiers private at;
    mapping (address => bool) private hasPurchased; // has whitelist address purchased already
    uint256 public whitelistEndTime;
    uint256 public maxWhitelistPurchaseWei;
    uint256 public openWhitelistEndTime;

    function CPCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _whitelistEndTime, uint256 _openWhitelistEndTime, address _wallet, address _tiersContract, address _whitelistContract, address _airdropWallet, address _advisorWallet, address _stakingWallet, address _privateSaleWallet)
        CappedCrowdsale(45000 ether) // crowdsale capped at 45000 ether
        FinalizableCrowdsale()
        Crowdsale(_startTime, _endTime, 1, _wallet)  // rate = 1 is a dummy value; we use tiers instead
    {
        token.mint(_wallet, 23226934 * (10 ** 18));
        token.mint(_airdropWallet, 5807933 * (10 ** 18));
        token.mint(_advisorWallet, 5807933 * (10 ** 18));
        token.mint(_stakingWallet, 11615867 * (10 ** 18));
        token.mint(_privateSaleWallet, 36000000 * (10 ** 18));

        aw = DPIcoWhitelist(_whitelistContract);
        require (aw.numUsers() > 0);
        at = Tiers(_tiersContract);
        whitelistEndTime = _whitelistEndTime;
        openWhitelistEndTime = _openWhitelistEndTime;
        weiRaised = 18000 ether; // 18K ether was sold during presale
        maxWhitelistPurchaseWei = (cap.sub(weiRaised)).div(aw.numUsers());
    }

    // Public functions
    function buyTokens(address beneficiary) public payable whenNotPaused {
        uint256 weiAmount = msg.value;

        require(beneficiary != 0x0);
        require(validPurchase());
        require(!isWhitelistPeriod()
             || whitelistValidPurchase(msg.sender, beneficiary, weiAmount));
        require(!isOpenWhitelistPeriod()
             || openWhitelistValidPurchase(msg.sender, beneficiary));

        hasPurchased[beneficiary] = true;

        uint256 tokens = at.calculateTokens(weiAmount, weiRaised);
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }

    // Internal functions

    function createTokenContract() internal returns (MintableToken) {
        return new CPToken();
    }

    /**
     * @dev Overriden to add finalization logic.
     * Mints remaining tokens to dev wallet
     */
    function finalization() internal {
        uint256 remainingWei = cap.sub(weiRaised);
        if (remainingWei > 0) {
            uint256 remainingDevTokens = at.calculateTokens(remainingWei, weiRaised);
            token.mint(wallet, remainingDevTokens);
        }
        CPToken(token).endSale();
        token.finishMinting();
        super.finalization();
    }

    // Private functions

    // can't override `validPurchase` because need to pass additional values
    function whitelistValidPurchase(address buyer, address beneficiary, uint256 amountWei) private constant returns (bool) {
        bool beneficiaryPurchasedPreviously = hasPurchased[beneficiary];
        bool belowMaxWhitelistPurchase = amountWei <= maxWhitelistPurchaseWei;
        return (openWhitelistValidPurchase(buyer, beneficiary)
                && !beneficiaryPurchasedPreviously
                && belowMaxWhitelistPurchase);
    }

    // @return true if `now` is within the bounds of the whitelist period
    function isWhitelistPeriod() private constant returns (bool) {
        return (now <= whitelistEndTime && now >= startTime);
    }

    // can't override `validPurchase` because need to pass additional values
    function openWhitelistValidPurchase(address buyer, address beneficiary) private constant returns (bool) {
        bool buyerIsBeneficiary = buyer == beneficiary;
        bool signedup = aw.isSignedUp(beneficiary);
        return (buyerIsBeneficiary && signedup);
    }

    // @return true if `now` is within the bounds of the open whitelist period
    function isOpenWhitelistPeriod() private constant returns (bool) {
        bool cappedWhitelistOver = now > whitelistEndTime;
        bool openWhitelistPeriod = now <= openWhitelistEndTime;
        return cappedWhitelistOver && openWhitelistPeriod;
    }

}