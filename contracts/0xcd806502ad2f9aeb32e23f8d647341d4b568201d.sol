pragma solidity ^0.4.18;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract THTokenSale is Pausable {
    using SafeMath for uint256;

    // Sale Token
    THToken public token;

    // Total wei raised
    uint256 public fundsRaised = 0;

    // Minimal possible cap in ethers
    // @dev NEEDS to be the same as Stage 1 cap now.
    uint256 public constant SOFT_CAP = 3000 ether;

    // Maximum possible cap in ethers
    uint256 public constant HARD_CAP = 12000 ether;

    bool public softCapReached = false;
    bool public hardCapReached = false;
    bool public saleSuccessfullyFinished = false;

    /**
     * Stage 1: 3000 ether worth of THT available at 40% bonus
     * Stage 2: 1800 ether worth of THT available at 20% bonus
     * Stage 3: 2250 ether worth of THT available at 10% bonus
     * Stage 4: 2250 ether worth of THT available at 5% bonus
     * Stage 5: 2700 ether worth of THT available with no bonus
     */
    uint256[5] public stageCaps = [
        3000 ether,
        4800 ether,
        7050 ether,
        9300 ether,
        12000 ether
    ];
    uint256[5] public stageTokenMul = [
        5040,
        4320,
        3960,
        3780,
        3600
    ];
    uint256 public activeStage = 0;

    // Minimum investment during first 48 hours
    uint256 public constant MIN_INVESTMENT_PHASE1 = 5 ether;
    // Minimum investment
    uint256 public constant MIN_INVESTMENT = 0.1 ether;

    // refundAllowed can be set to true if SOFT_CAP is not reached
    bool public refundAllowed = false;
    // Token Allocation for Bounty(5%), Advisors (5%), Platform (10%)
    uint256[3] public varTokenAllocation = [5, 5, 10];
    // 20% vested over 4 segments for Core Team
    uint256[4] public teamTokenAllocation = [5, 5, 5, 5];
    // 60% crowdsale
    uint256 public constant CROWDSALE_ALLOCATION = 60;

    // Vested amounts of tokens, filled with proper values when finalizing
    uint256[4] public vestedTeam = [0, 0, 0, 0];
    uint256 public vestedAdvisors = 0;

    // Withdraw
    address public wallet;
    // CoreTeam Vested
    address public walletCoreTeam;
    // Platform THT
    address public walletPlatform;
    // Bounty and Advisors THT
    address public walletBountyAndAdvisors;

    // start and end timestamp when investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // Whitelisted addresses and their allocations of wei available to invest
    mapping(address => uint256) public whitelist;

    // Wei received from token buyers
    mapping(address => uint256) public weiBalances;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Whitelisted(address indexed beneficiary, uint256 value);
    event SoftCapReached();
    event HardCapReached();
    event Finalized(bool successfullyFinished);
    event StageOpened(uint stage);
    event StageClosed(uint stage);

    /**
    * @dev Modifier to make a function callable only during the sale
    */
    modifier beforeSaleEnds() {
        // Not calling hasEnded due to lower gas usage
        require(now < endTime && fundsRaised < HARD_CAP);
        _;
    }

    function THTokenSale(
        uint256 _startTime,
        address _wallet,
        address _walletCoreTeam,
        address _walletPlatform,
        address _walletBountyAndAdvisors
    ) public {
        require(_startTime >= now);
        require(_wallet != 0x0);
        require(_walletCoreTeam != 0x0);
        require(_walletPlatform != 0x0);
        require(_walletBountyAndAdvisors != 0x0);
        require(vestedTeam.length == teamTokenAllocation.length);   // sanity checks
        require(stageCaps.length == stageTokenMul.length);   // sanity checks

        token = new THToken();
        wallet = _wallet;
        walletCoreTeam = _walletCoreTeam;
        walletPlatform = _walletPlatform;
        walletBountyAndAdvisors = _walletBountyAndAdvisors;
        startTime = _startTime;
        // Sale lasts up to 4 weeks and 4 days
        endTime = _startTime + 32 * 86400;
    }

    /*
     * @dev fallback for processing ether
     */
    function() public payable {
        buyTokens(msg.sender);
    }

    /*
     * @dev Sale is executed in stages/tranches. Each stage except the first is activated manually by the owner.
     * Only allow next stage when current stage/tranche is filled to cap.
     */
    function activateNextStage() onlyOwner public {
        uint256 stageIndex = activeStage;
        require(fundsRaised >= stageCaps[stageIndex]);
        require(stageIndex + 1 < stageCaps.length);

        activeStage = stageIndex + 1;
        StageOpened(activeStage + 1);
    }

    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    function buyTokens(address contributor) whenNotPaused beforeSaleEnds public payable {
        uint256 _stageIndex = activeStage;
        uint256 refund = 0;
        uint256 weiAmount = msg.value;
        uint256 _activeStageCap = stageCaps[_stageIndex];

        require(fundsRaised < _activeStageCap);
        require(validPurchase());
        require(canContribute(contributor, weiAmount));

        uint256 capDelta = _activeStageCap.sub(fundsRaised);

        if (capDelta < weiAmount) {
            // Not enough tokens available for full contribution, we will do a partial.
            weiAmount = capDelta;
            // Calculate refund for contributor.
            refund = msg.value.sub(weiAmount);
        }

        uint256 tokensToMint = weiAmount.mul(stageTokenMul[_stageIndex]);

        whitelist[contributor] = whitelist[contributor].sub(weiAmount);
        weiBalances[contributor] = weiBalances[contributor].add(weiAmount);

        fundsRaised = fundsRaised.add(weiAmount);
        token.mint(contributor, tokensToMint);

        // Refund after state changes for re-entrancy safety
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
        TokenPurchase(0x0, contributor, weiAmount, tokensToMint);

        if (fundsRaised >= _activeStageCap) {
            finalizeCurrentStage();
        }
    }

    function canContribute(address contributor, uint256 weiAmount) public view returns (bool) {
        require(contributor != 0x0);
        require(weiAmount > 0);
        return (whitelist[contributor] >= weiAmount);
    }

    function addWhitelist(address contributor, uint256 weiAmount) onlyOwner public returns (bool) {
        require(contributor != 0x0);
        require(weiAmount > 0);
        // Only ever set the new amount, even if user is already whitelisted with a previous value set
        whitelist[contributor] = weiAmount;
        Whitelisted(contributor, weiAmount);
        return true;
    }

    /*
     * @dev Add participants to whitelist in bulk
     */
    function addWhitelistBulk(address[] contributors, uint256[] amounts) onlyOwner beforeSaleEnds public returns (bool) {
        address contributor;
        uint256 amount;
        require(contributors.length == amounts.length);

        for (uint i = 0; i < contributors.length; i++) {
            contributor = contributors[i];
            amount = amounts[i];
            require(addWhitelist(contributor, amount));
        }
        return true;
    }

    function withdraw() onlyOwner public {
        require(softCapReached);
        require(this.balance > 0);

        wallet.transfer(this.balance);
    }

    function withdrawCoreTeamTokens() onlyOwner public {
        require(saleSuccessfullyFinished);

        if (now > startTime + 720 days && vestedTeam[3] > 0) {
            token.transfer(walletCoreTeam, vestedTeam[3]);
            vestedTeam[3] = 0;
        }
        if (now > startTime + 600 days && vestedTeam[2] > 0) {
            token.transfer(walletCoreTeam, vestedTeam[2]);
            vestedTeam[2] = 0;
        }
        if (now > startTime + 480 days && vestedTeam[1] > 0) {
            token.transfer(walletCoreTeam, vestedTeam[1]);
            vestedTeam[1] = 0;
        }
        if (now > startTime + 360 days && vestedTeam[0] > 0) {
            token.transfer(walletCoreTeam, vestedTeam[0]);
            vestedTeam[0] = 0;
        }
    }

    function withdrawAdvisorTokens() onlyOwner public {
        require(saleSuccessfullyFinished);

        if (now > startTime + 180 days && vestedAdvisors > 0) {
            token.transfer(walletBountyAndAdvisors, vestedAdvisors);
            vestedAdvisors = 0;
        }
    }

    /*
     * @dev Leave token balance as is.
     * The tokens are unusable if a refund call could be successful due to transferAllowed = false upon failing to reach SOFT_CAP.
     */
    function refund() public {
        require(refundAllowed);
        require(!softCapReached);
        require(weiBalances[msg.sender] > 0);

        uint256 currentBalance = weiBalances[msg.sender];
        weiBalances[msg.sender] = 0;
        msg.sender.transfer(currentBalance);
    }

    /*
     * @dev When finishing the crowdsale we mint non-crowdsale tokens based on total tokens minted during crowdsale
     */
    function finishCrowdsale() onlyOwner public returns (bool) {
        require(now >= endTime || fundsRaised >= HARD_CAP);
        require(!saleSuccessfullyFinished && !refundAllowed);

        // Crowdsale successful
        if (softCapReached) {
            uint256 _crowdsaleAllocation = CROWDSALE_ALLOCATION; // 60% crowdsale
            uint256 crowdsaleTokens = token.totalSupply();

            uint256 tokensBounty = crowdsaleTokens.mul(varTokenAllocation[0]).div(_crowdsaleAllocation); // 5% Bounty
            uint256 tokensAdvisors = crowdsaleTokens.mul(varTokenAllocation[1]).div(_crowdsaleAllocation); // 5% Advisors
            uint256 tokensPlatform = crowdsaleTokens.mul(varTokenAllocation[2]).div(_crowdsaleAllocation); // 10% Platform

            vestedAdvisors = tokensAdvisors;

            // 20% Team
            uint256 tokensTeam = 0;
            uint len = teamTokenAllocation.length;
            uint amount = 0;
            for (uint i = 0; i < len; i++) {
                amount = crowdsaleTokens.mul(teamTokenAllocation[i]).div(_crowdsaleAllocation);
                vestedTeam[i] = amount;
                tokensTeam = tokensTeam.add(amount);
            }

            token.mint(walletBountyAndAdvisors, tokensBounty);
            token.mint(walletPlatform, tokensPlatform);

            token.mint(this, tokensAdvisors);
            token.mint(this, tokensTeam);

            token.endMinting(true);
            saleSuccessfullyFinished = true;
            Finalized(true);
            return true;
        } else {
            refundAllowed = true;
            // Token contract gets destroyed
            token.endMinting(false);
            Finalized(false);
            return false;
        }
    }

    // @return user balance
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return token.balanceOf(_owner);
    }

    function hasStarted() public view returns (bool) {
        return now >= startTime;
    }

    function hasEnded() public view returns (bool) {
        return now >= endTime || fundsRaised >= HARD_CAP;
    }

    function validPurchase() internal view returns (bool) {
        // Extended from 2 * 86400 to 200.000 seconds, since there's a 48 hour pause scheduled after phase 1
        if(now <= (startTime + 200000) && msg.value < MIN_INVESTMENT_PHASE1) {
            return false;
        }
        bool withinPeriod = now >= startTime && now <= endTime;
        bool withinPurchaseLimits = msg.value >= MIN_INVESTMENT;
        return withinPeriod && withinPurchaseLimits;
    }

    function finalizeCurrentStage() internal {
        uint256 _stageIndex = activeStage;

        if (_stageIndex == 0) {
            softCapReached = true;
            SoftCapReached();
        } else if (_stageIndex == stageCaps.length - 1) {
            hardCapReached = true;
            HardCapReached();
        }

        StageClosed(_stageIndex + 1);
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
    totalSupply_ = totalSupply_.add(_amount);
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

contract THToken is MintableToken {

    string public constant name = "Tradershub Token";
    string public constant symbol = "THT";
    uint8 public constant decimals = 18;

    bool public transferAllowed = false;

    event TransferAllowed(bool transferIsAllowed);

    modifier canTransfer() {
        require(mintingFinished && transferAllowed);
        _;
    }

    function transferFrom(address from, address to, uint256 value) canTransfer public returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) canTransfer public returns (bool) {
        return super.transfer(to, value);
    }

    function endMinting(bool _transferAllowed) onlyOwner canMint public returns (bool) {
        if (!_transferAllowed) {
            // Only ever called if the sale failed to reach soft cap
            selfdestruct(msg.sender);
            return true;
        }
        transferAllowed = _transferAllowed;
        TransferAllowed(_transferAllowed);
        return super.finishMinting();
    }
}