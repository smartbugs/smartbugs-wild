pragma solidity ^0.4.11;

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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments. Inherit from this
 * contract and use asyncSend instead of send.
 */
contract PullPayment {
  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  /**
  * @dev Called by the payer to store the sent amount as credit to be pulled.
  * @param dest The destination address of the funds.
  * @param amount The amount to transfer.
  */
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }

  /**
  * @dev withdraw accumulated balance, called by payee.
  */
  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(this.balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    assert(payee.send(payment));
  }
}

contract EvaCoin is MintableToken, PullPayment {
    string public constant name = "EvaCoin";
    string public constant symbol = "EVA";
    uint8 public constant decimals = 18;
    bool public transferAllowed = false;

    // keeper has special limited rights for the coin:
    // pay dividends
    address public keeper;

    // raisings in USD
    uint256 public raisedPreSaleUSD;
    uint256 public raisedSale1USD;
    uint256 public raisedSale2USD;
    uint256 public payedDividendsUSD;

    // coin issues
    uint256 public totalSupplyPreSale = 0;
    uint256 public totalSupplySale1 = 0;
    uint256 public totalSupplySale2 = 0;

    enum SaleStages { PreSale, Sale1, Sale2, SaleOff }
    SaleStages public stage = SaleStages.PreSale;

    function EvaCoin() public {
        keeper = msg.sender; 
    }   

    modifier onlyKeeper() {
        require(msg.sender == keeper);
        _;
    }

    function sale1Started() onlyOwner public {
        totalSupplyPreSale = totalSupply;
        stage = SaleStages.Sale1;
    }
    function sale2Started() onlyOwner public {
        totalSupplySale1 = totalSupply;
        stage = SaleStages.Sale2;
    }
    function sale2Stopped() onlyOwner public {
        totalSupplySale2 = totalSupply;
        stage = SaleStages.SaleOff;
    }

    // ---------------------------- dividends related definitions --------------------
    uint constant MULTIPLIER = 10e18;

    mapping(address=>uint256) lastDividends;
    uint public totalDividendsPerCoin;
    uint public etherBalance;

    modifier activateDividends(address account) {
        if (totalDividendsPerCoin != 0) { // only after first dividends payed
            var actual = totalDividendsPerCoin - lastDividends[account];
            var dividends = (balances[account] * actual) / MULTIPLIER;

            if (dividends > 0 && etherBalance >= dividends) {
                etherBalance -= dividends;
                lastDividends[account] = totalDividendsPerCoin;
                asyncSend(account, dividends);
            }
            //This needed for accounts with zero balance at the moment
            lastDividends[account] = totalDividendsPerCoin;
        }

        _;
    }
    function activateDividendsFunc(address account) private activateDividends(account) {}
    // -------------------------------------------------------------------------------


    // ---------------------------- sale 2 bonus definitions --------------------
    // coins investor has before sale2 started
    mapping(address=>uint256) sale1Coins;

    // investors who has been payed sale2 bonus
    mapping(address=>bool) sale2Payed;

    modifier activateBonus(address account) {
        if (stage == SaleStages.SaleOff && !sale2Payed[account]) {
            uint256 coins = sale1Coins[account];
            if (coins == 0) {
                coins = balances[account];
            }
            balances[account] += balances[account] * coins / (totalSupplyPreSale + totalSupplySale1);
            sale2Payed[account] = true;
        } else if (stage != SaleStages.SaleOff) {
            // remember account balace before SaleOff
            sale1Coins[account] = balances[account];
        }
        _;
    }
    function activateBonusFunc(address account) private activateBonus(account) {}

    // ----------------------------------------------------------------------

    event TransferAllowed(bool);

    modifier canTransfer() {
        require(transferAllowed);
        _;
    }

    // Override StandardToken#transferFrom
    function transferFrom(address from, address to, uint256 value) canTransfer
    // stack too deep to call modifiers
    // activateDividends(from) activateDividends(to) activateBonus(from) activateBonus(to)
    public returns (bool) {
        activateDividendsFunc(from);
        activateDividendsFunc(to);
        activateBonusFunc(from);
        activateBonusFunc(to);
        return super.transferFrom(from, to, value); 
    }   
    
    // Override BasicToken#transfer
    function transfer(address to, uint256 value) 
    canTransfer activateDividends(to) activateBonus(to)
    public returns (bool) {
        return super.transfer(to, value); 
    }

    function allowTransfer() onlyOwner public {
        transferAllowed = true; 
        TransferAllowed(true);
    }

    function raisedUSD(uint256 amount) onlyOwner public {
        if (stage == SaleStages.PreSale) {
            raisedPreSaleUSD += amount;
        } else if (stage == SaleStages.Sale1) {
            raisedSale1USD += amount;
        } else if (stage == SaleStages.Sale2) {
            raisedSale2USD += amount;
        } 
    }

    function canStartSale2() public constant returns (bool) {
        return payedDividendsUSD >= raisedPreSaleUSD + raisedSale1USD;
    }

    // Dividents can be payed any time - even after PreSale and before Sale1
    // ethrate - actual ETH/USD rate
    function sendDividends(uint256 ethrate) public payable onlyKeeper {
        require(totalSupply > 0); // some coins must be issued
        totalDividendsPerCoin += (msg.value * MULTIPLIER / totalSupply);
        etherBalance += msg.value;
        payedDividendsUSD += msg.value * ethrate / 1 ether;
    }

    // Override MintableToken#mint
    function mint(address _to, uint256 _amount) 
        onlyOwner canMint activateDividends(_to) activateBonus(_to) 
        public returns (bool) {
        super.mint(_to, _amount);

        if (stage == SaleStages.PreSale) {
            totalSupplyPreSale += _amount;
        } else if (stage == SaleStages.Sale1) {
            totalSupplySale1 += _amount;
        } else if (stage == SaleStages.Sale2) {
            totalSupplySale2 += _amount;
        } 
    }

    // Override PullPayment#withdrawPayments
    function withdrawPayments()
        activateDividends(msg.sender) activateBonus(msg.sender)
        public {
        super.withdrawPayments();
    }

    function checkPayments()
        activateDividends(msg.sender) activateBonus(msg.sender)
        public returns (uint256) {
        return payments[msg.sender];
    }
    function paymentsOf() constant public returns (uint256) {
        return payments[msg.sender];
    }

    function checkBalance()
        activateDividends(msg.sender) activateBonus(msg.sender)
        public returns (uint256) {
        return balanceOf(msg.sender);
    }

    // withdraw ethers if contract has more ethers
    // than for dividends for some reason
    function withdraw() onlyOwner public {
        if (this.balance > etherBalance) {
            owner.transfer(this.balance - etherBalance);
        }
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

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract EvaCoinPreSale is CappedCrowdsale, Ownable {
    // Sale1 and Sale2 EVC/ETH sale rate (without bonus)
    uint256 public constant SALE_RATE = 2100;

    // PreSale EVA/ETH sale rate
    uint256 public constant PRESALE_RATE = 2*SALE_RATE;

    // ETH/USD exchange rate - set to actual before this contract deploy
    uint256 constant ETH_RATE = 700;  

    // How much want to raise in USD
    uint256 constant RAISE_USD = 25000;

    // USD amount invested by early founders before the coin issued in USD
    uint256 public constant EARLY_FOUNDERS_USD = 135 * 1000;

    // hard cap in wei
    uint256 public constant HARD_CAP = RAISE_USD * 1 ether / ETH_RATE;

    // early founders investments in ethers
    uint256 public constant EARLY_FOUNDERS_CAP = EARLY_FOUNDERS_USD * 1 ether / ETH_RATE;

    bool public isFinalized = false;

    EvaCoin public coin;

    function EvaCoinPreSale(address evacoin, uint256 _startTime, uint256 _endTime) public
        CappedCrowdsale(HARD_CAP)
        Crowdsale(_startTime, _endTime, PRESALE_RATE, msg.sender)
    {
        coin = EvaCoin(evacoin);

        // Need to call this, because wrong token assigned in Crowdsale constructor
        Crowdsale.token = coin;
    }

    function createTokenContract() internal returns (MintableToken) {
        // it doesn't really matter what coin to return
        // because setCoin call goes after
        return coin;
    }

    // Override Crowdsale#buyTokens
    function buyTokens(address beneficiary) public payable {
        require(!isFinalized);
        require(msg.value >= 500 finney);
        super.buyTokens(beneficiary);
        coin.raisedUSD(ETH_RATE.mul(msg.value).div(1 ether));
    }

    function finalize() onlyOwner public {
        require(!isFinalized);

        // coins for early founders
        uint256 founderCoins = EARLY_FOUNDERS_CAP.mul(SALE_RATE);
        coin.mint(owner, founderCoins);

        // contract owner need to transfer coin to Sale1 contract
        coin.transferOwnership(coin.keeper());

        isFinalized = true;
    }
}