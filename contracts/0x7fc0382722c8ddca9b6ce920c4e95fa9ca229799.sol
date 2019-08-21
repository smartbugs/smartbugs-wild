pragma solidity ^0.4.18;

// ----------------- 
//begin Ownable.sol

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

//end Ownable.sol
// ----------------- 
//begin SafeMath.sol

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

//end SafeMath.sol
// ----------------- 
//begin ERC20Basic.sol

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

//end ERC20Basic.sol
// ----------------- 
//begin Pausable.sol



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

//end Pausable.sol
// ----------------- 
//begin BasicToken.sol



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

//end BasicToken.sol
// ----------------- 
//begin ERC20.sol



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

//end ERC20.sol
// ----------------- 
//begin StandardToken.sol



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

//end StandardToken.sol
// ----------------- 
//begin MintableToken.sol




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

//end MintableToken.sol
// ----------------- 
//begin PausableToken.sol

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

//end PausableToken.sol
// ----------------- 
//begin RestartEnergyToken.sol

contract RestartEnergyToken is MintableToken, PausableToken {
    string public name = "RED MegaWatt Token";
    string public symbol = "MWAT";
    uint256 public decimals = 18;
}

//end RestartEnergyToken.sol
// ----------------- 
//begin Crowdsale.sol

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

//end Crowdsale.sol
// ----------------- 
//begin TimedCrowdsale.sol



contract TimedCrowdsale is Crowdsale, Ownable {

    uint256 public presaleStartTime;

    uint256 public presaleEndTime;

    event EndTimeChanged(uint newEndTime);

    event StartTimeChanged(uint newStartTime);

    event PresaleStartTimeChanged(uint newPresaleStartTime);

    event PresaleEndTimeChanged(uint newPresaleEndTime);

    function setEndTime(uint time) public onlyOwner {
        require(now < time);
        require(time > startTime);

        endTime = time;
        EndTimeChanged(endTime);
    }

    function setStartTime(uint time) public onlyOwner {
        require(now < time);
        require(time > presaleEndTime);

        startTime = time;
        StartTimeChanged(startTime);
    }

    function setPresaleStartTime(uint time) public onlyOwner {
        require(now < time);
        require(time < presaleEndTime);

        presaleStartTime = time;
        PresaleStartTimeChanged(presaleEndTime);
    }

    function setPresaleEndTime(uint time) public onlyOwner {
        require(now < time);
        require(time > presaleStartTime);

        presaleEndTime = time;
        PresaleEndTimeChanged(presaleEndTime);
    }


}

//end TimedCrowdsale.sol
// ----------------- 
//begin FinalizableCrowdsale.sol

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

//end FinalizableCrowdsale.sol
// ----------------- 
//begin TokenCappedCrowdsale.sol



contract TokenCappedCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

    uint256 public hardCap;
    uint256 public totalTokens;

    function TokenCappedCrowdsale() internal {

        hardCap = 400000000 * 1 ether;
        totalTokens = 500000000 * 1 ether;
    }

    function notExceedingSaleLimit(uint256 amount) internal constant returns (bool) {
        return hardCap >= amount.add(token.totalSupply());
    }

    /**
    * Finalization logic. We take the expected sale cap
    * ether and find the difference from the actual minted tokens.
    * The remaining balance and the reserved amount for the team are minted
    * to the team wallet.
    */
    function finalization() internal {
        super.finalization();
    }
}

//end TokenCappedCrowdsale.sol
// ----------------- 
//begin RestartEnergyCrowdsale.sol




contract RestartEnergyCrowdsale is TimedCrowdsale, TokenCappedCrowdsale, Pausable {

    uint256 public presaleLimit = 10 * 1 ether;

    // how many token units a buyer gets per ether with basic presale discount
    uint16 public basicPresaleRate = 120;

    uint256 public soldTokens = 0;

    uint16 public etherRate = 100;

    // address where funds are collected
    address public tokensWallet;

    // How much ETH each address has invested to this crowdsale
    mapping(address => uint256) public purchasedAmountOf;

    // How many tokens this crowdsale has credited for each investor address
    mapping(address => uint256) public tokenAmountOf;


    function RestartEnergyCrowdsale(uint256 _presaleStartTime, uint256 _presaleEndTime,
        uint256 _startTime, uint256 _endTime, address _wallet, address _tokensWallet) public TokenCappedCrowdsale() Crowdsale(_startTime, _endTime, 100, _wallet) {
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        tokensWallet = _tokensWallet;
    }

    /**
    * Creates the token automatically (inherited from zeppelin Crowdsale)
    */
    function createTokenContract() internal returns (MintableToken) {
        return RestartEnergyToken(0x0);
    }

    /**
    * create the token manually to consume less gas per transaction when deploying
    */
    function buildTokenContract() public onlyOwner {
        require(token == address(0x0));
        RestartEnergyToken _token = new RestartEnergyToken();
        _token.pause();
        token = _token;
    }

    function buy() public whenNotPaused payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public whenNotPaused payable {
        require(!isFinalized);
        require(beneficiary != address(0));
        require(validPresalePurchase() || validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(getRate());

        require(validPurchase());
        require(notExceedingSaleLimit(tokens));

        // update state
        weiRaised = weiRaised.add(weiAmount);

        soldTokens = soldTokens.add(tokens);

        // mint the tokens
        token.mint(beneficiary, tokens);

        // update purchaser
        purchasedAmountOf[msg.sender] = purchasedAmountOf[msg.sender].add(msg.value);
        tokenAmountOf[msg.sender] = tokenAmountOf[msg.sender].add(tokens);

        //event
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        //forward funds to our wallet
        forwardFunds();
    }

    /**
    * Send tokens by the owner directly to an address.
    */
    function sendTokensToAddress(uint256 amount, address to) public onlyOwner {
        require(!isFinalized);
        require(notExceedingSaleLimit(amount));
        tokenAmountOf[to] = tokenAmountOf[to].add(amount);
        token.mint(to, amount);
    }

    function enableTokenTransfers() public onlyOwner {
        require(isFinalized);
        require(now > endTime + 15 days);
        require(RestartEnergyToken(token).paused());
        RestartEnergyToken(token).unpause();
    }

    // the team wallet is the 'wallet' field
    bool public firstPartOfTeamTokensClaimed = false;
    bool public secondPartOfTeamTokensClaimed = false;


    function claimTeamTokens() public onlyOwner {
        require(isFinalized);
        require(!secondPartOfTeamTokensClaimed);
        require(now > endTime + 182 days);

        uint256 tokensToMint = totalTokens.mul(3).div(100);
        if (!firstPartOfTeamTokensClaimed) {
            token.mint(wallet, tokensToMint);
            firstPartOfTeamTokensClaimed = true;
        }
        else {
            require(now > endTime + 365 days);
            token.mint(wallet, tokensToMint);
            secondPartOfTeamTokensClaimed = true;
            token.finishMinting();
        }
    }

    /**
    * the rate (how much tokens are given for 1 ether)
    * is calculated according to presale/sale period and the amount of ether
    */
    function getRate() internal view returns (uint256) {
        uint256 calcRate = rate;
        //check if this sale is in presale period
        if (validPresalePurchase()) {
            calcRate = basicPresaleRate;
        }
        else {
            //if not validPresalePurchase() and not validPurchase() this function is not called
            // so no need to check validPurchase() again here
            uint256 daysPassed = (now - startTime) / 1 days;
            if (daysPassed < 15) {
                calcRate = 100 + (15 - daysPassed);
            }
        }
        calcRate = calcRate.mul(etherRate);
        return calcRate;
    }


    function setEtherRate(uint16 _etherRate) public onlyOwner {
        etherRate = _etherRate;
    }

    // @return true if the transaction can buy tokens in presale
    function validPresalePurchase() internal constant returns (bool) {
        bool withinPeriod = now >= presaleStartTime && now <= presaleEndTime;
        bool nonZeroPurchase = msg.value != 0;
        bool validPresaleLimit = msg.value >= presaleLimit;
        return withinPeriod && nonZeroPurchase && validPresaleLimit;
    }

    function finalization() internal {
        super.finalization();

        uint256 toMintNow;

        // mint not sold tokens into team wallet
        toMintNow = hardCap.sub(token.totalSupply());
        token.mint(tokensWallet, toMintNow);


        // mint 14% of total Tokens (3% for bounty, 5% for advisors, 6% for team) into team wallet
        toMintNow = totalTokens.mul(14).div(100);
        token.mint(tokensWallet, toMintNow);
    }
}

//end RestartEnergyCrowdsale.sol