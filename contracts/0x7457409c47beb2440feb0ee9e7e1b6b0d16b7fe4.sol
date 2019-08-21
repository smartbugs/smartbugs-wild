pragma solidity 0.4.19;

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

    function decreaseApproval (address _spender, uint _subtractedValue) public
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

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
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

contract Tigereum is MintableToken, BurnableToken {
    string public webAddress = "www.tigereum.io";
    string public name = "Tigereum";
    string public symbol = "TIG";
    uint8 public decimals = 18;
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
    var curtime = now;
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

contract TigereumCrowdsale is Ownable, Crowdsale {

    using SafeMath for uint256;
  
    //operational
    bool public LockupTokensWithdrawn = false;
    bool public isFinalized = false;
    uint256 public constant toDec = 10**18;
    uint256 public tokensLeft = 32800000*toDec;
    uint256 public constant cap = 32800000*toDec;
    uint256 public constant startRate = 1333;
    uint256 private accumulated = 0;

    enum State { BeforeSale, Bonus, NormalSale, ShouldFinalize, Lockup, SaleOver }
    State public state = State.BeforeSale;

    /* --- Ether wallets --- */

    address public admin;// = 0x021e366d41cd25209a9f1197f238f10854a0c662; // 0 - get 99% of ether
    address public ICOadvisor1;// = 0xBD1b96D30E1a202a601Fa8823Fc83Da94D71E3cc; // 1 - get 1% of ether
    uint256 private constant ICOadvisor1Sum = 400000*toDec; // also gets tokens - 0.8% - 400,000

    // Pre ICO wallets

    address public hundredKInvestor;// = 0x93da612b3DA1eF05c5D80c9B906bf9e7aAdc4a23;
    uint256 private constant hundredKInvestorSum = 3200000*toDec; // 2 - 6.4% - 3,200,000

    address public additionalPresaleInvestors;// = 0x095e80F85f3D260bF959Aa524F2f3918f56a2493;
    uint256 private constant additionalPresaleInvestorsSum = 1000000*toDec; // 3 - 2% - 1,000,000

    address public preSaleBotReserve;// = 0x095e80F85f3D260bF959Aa524F2f3918f56a2493; // same as additionalPresaleInvestors
    uint256 private constant preSaleBotReserveSum = 2500000*toDec; // 4 - 5% - 2,500,000

    address public ICOadvisor2;// = 0xe05416EAD6d997C8bC88A7AE55eC695c06693C58;
    uint256 private constant ICOadvisor2Sum = 100000*toDec; // 5 - 0.2% - 100,000

    address public team;// = 0xA919B56D099C12cC8921DF605Df2D696b30526B0;
    uint256 private constant teamSum = 1820000*toDec; // 6 - 3.64% - 1,820,000
 
    address public bounty;// = 0x20065A723d43c753AD83689C5f9F4786a73Be6e6;
    uint256 private constant bountySum = 1000000*toDec; // 7 - 2% - 1,000,000

    
    // Lockup wallets
    address public founders;// = 0x49ddcD8b4B1F54f3E5c4fEf705025C1DaDC753f6;
    uint256 private constant foundersSum = 7180000*toDec; // 8 - 14.36% - 7,180,000


    /* --- Time periods --- */


    uint256 public constant startTimeNumber = 1512723600 + 1; // 8/12/17-9:00:00 - 1512723600
    uint256 public constant endTimeNumber = 1513641540; // 18/12/17-23:59:00 - 1513641540

    uint256 public constant lockupPeriod = 90 * 1 days; // 90 days - 7776000
    uint256 public constant bonusPeriod = 12 * 1 hours; // 12 hours - 43,200

    uint256 public constant bonusEndTime = bonusPeriod + startTimeNumber;



    event LockedUpTokensWithdrawn();
    event Finalized();

    modifier canWithdrawLockup() {
        require(state == State.Lockup);
        require(endTime.add(lockupPeriod) < block.timestamp);
        _;
    }

    function TigereumCrowdsale(
        address _admin,
        address _ICOadvisor1,
        address _hundredKInvestor,
        address _additionalPresaleInvestors,
        address _preSaleBotReserve,
        address _ICOadvisor2,
        address _team,
        address _bounty,
        address _founders)
    Crowdsale(
        startTimeNumber /* start date - 8/12/17-9:00:00 */, 
        endTimeNumber /* end date - 18/12/17-23:59:00 */, 
        startRate /* start rate - 1333 */, 
        _admin
    )  
    public 
    {      
        admin = _admin;
        ICOadvisor1 = _ICOadvisor1;
        hundredKInvestor = _hundredKInvestor;
        additionalPresaleInvestors = _additionalPresaleInvestors;
        preSaleBotReserve = _preSaleBotReserve;
        ICOadvisor2 = _ICOadvisor2;
        team = _team;
        bounty = _bounty;
        founders = _founders;
        owner = admin;
    }

    function isContract(address addr) private returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific MintableToken token.
    function createTokenContract() internal returns (MintableToken) {
        return new Tigereum();
    }

    function forwardFunds() internal {
        forwardFundsAmount(msg.value);
    }

    function forwardFundsAmount(uint256 amount) internal {
        var onePercent = amount / 100;
        var adminAmount = onePercent.mul(99);
        admin.transfer(adminAmount);
        ICOadvisor1.transfer(onePercent);
        var left = amount.sub(adminAmount).sub(onePercent);
        accumulated = accumulated.add(left);
    }

    function refundAmount(uint256 amount) internal {
        msg.sender.transfer(amount);
    }

    function fixAddress(address newAddress, uint256 walletIndex) onlyOwner public {
        require(state != State.ShouldFinalize && state != State.Lockup && state != State.SaleOver);
        if (walletIndex == 0 && !isContract(newAddress)) {
            admin = newAddress;
        }
        if (walletIndex == 1 && !isContract(newAddress)) {
            ICOadvisor1 = newAddress;
        }
        if (walletIndex == 2) {
            hundredKInvestor = newAddress;
        }
        if (walletIndex == 3) {
            additionalPresaleInvestors = newAddress;
        }
        if (walletIndex == 4) {
            preSaleBotReserve = newAddress;
        }
        if (walletIndex == 5) {
            ICOadvisor2 = newAddress;
        }
        if (walletIndex == 6) {
            team = newAddress;
        }
        if (walletIndex == 7) {
            bounty = newAddress;
        }
        if (walletIndex == 8) {
            founders = newAddress;
        }
    }

    function calculateCurrentRate() internal {
        if (state == State.NormalSale) {
            rate = 1000;
        }
    }

    function buyTokensUpdateState() internal {
        if(state == State.BeforeSale && now >= startTimeNumber) { state = State.Bonus; }
        if(state == State.Bonus && now >= bonusEndTime) { state = State.NormalSale; }
        calculateCurrentRate();
        require(state != State.ShouldFinalize && state != State.Lockup && state != State.SaleOver);
        if(msg.value.mul(rate) >= tokensLeft) { state = State.ShouldFinalize; }
    }

    function buyTokens(address beneficiary) public payable {
        buyTokensUpdateState();
        var numTokens = msg.value.mul(rate);
        if(state == State.ShouldFinalize) {
            lastTokens(beneficiary);
            finalize();
        }
        else {
            tokensLeft = tokensLeft.sub(numTokens); // if negative, should finalize
            super.buyTokens(beneficiary);
        }
    }

    function lastTokens(address beneficiary) internal {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokensForFullBuy = weiAmount.mul(rate);// must be bigger or equal to tokensLeft to get here
        uint256 tokensToRefundFor = tokensForFullBuy.sub(tokensLeft);
        uint256 tokensRemaining = tokensForFullBuy.sub(tokensToRefundFor);
        uint256 weiAmountToRefund = tokensToRefundFor.div(rate);
        uint256 weiRemaining = weiAmount.sub(weiAmountToRefund);
        
        // update state
        weiRaised = weiRaised.add(weiRemaining);

        token.mint(beneficiary, tokensRemaining);
        TokenPurchase(msg.sender, beneficiary, weiRemaining, tokensRemaining);

        forwardFundsAmount(weiRemaining);
        refundAmount(weiAmountToRefund);
    }

    function withdrawLockupTokens() canWithdrawLockup public {
        rate = 1000;
        token.mint(founders, foundersSum);
        token.finishMinting();
        LockupTokensWithdrawn = true;
        LockedUpTokensWithdrawn();
        state = State.SaleOver;
    }

    function finalizeUpdateState() internal {
        if(now > endTimeNumber) { state = State.ShouldFinalize; }
        if(tokensLeft == 0) { state = State.ShouldFinalize; }
    }

    function finalize() public {
        finalizeUpdateState();
        require (!isFinalized);
        require (state == State.ShouldFinalize);

        finalization();
        Finalized();

        isFinalized = true;
    }

    function finalization() internal {
        endTime = block.timestamp;
        /* - preICO investors - */
        token.mint(ICOadvisor1, ICOadvisor1Sum);
        token.mint(hundredKInvestor, hundredKInvestorSum);
        token.mint(additionalPresaleInvestors, additionalPresaleInvestorsSum);
        token.mint(preSaleBotReserve, preSaleBotReserveSum);
        token.mint(ICOadvisor2, ICOadvisor2Sum);
        token.mint(team, teamSum);
        token.mint(bounty, bountySum);
        forwardFundsAmount(accumulated);
        tokensLeft = 0;
        state = State.Lockup;
    }
}