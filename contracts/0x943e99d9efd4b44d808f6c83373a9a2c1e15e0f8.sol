pragma solidity 0.4.15;

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

contract IDealToken {
    function spend(address _from, uint256 _value) returns (bool success);
}

contract DealToken is MintableToken, IDealToken {
    string public constant name = "Deal Token";
    string public constant symbol = "DEAL";
    uint8 public constant decimals = 0;

    uint256 public totalTokensBurnt = 0;

    event TokensSpent(address indexed _from, uint256 _value);

    /**
     * @dev - Empty constructor
     */
    function DealToken() public { }

    /**
     * @dev - Function that allows foreground contract to spend (burn) the tokens.
     * @param _from - Account to withdraw from.
     * @param _value - Number of tokens to withdraw.
     * @return - A boolean that indicates if the operation was successful.
     */
    function spend(address _from, uint256 _value) public returns (bool) {
        require(_value > 0);

        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        totalTokensBurnt = totalTokensBurnt.add(_value);
        totalSupply = totalSupply.sub(_value);
        TokensSpent(_from, _value);
        return true;
    }

    /**
     * @dev - Allow another contract to spend some tokens on your behalf
     * @param _spender - Contract that will spend the tokens
     * @param _value - Amount of tokens to spend
     * @param _extraData - Additional data to pass to the receiveApproval
     * @return -  A boolean that indicates if the operation was successful.
     */
    function approveAndCall(ITokenRecipient _spender, uint256 _value, bytes _extraData) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        _spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }
}

contract IForeground {
    function payConversionFromTransaction(uint256 _promotionID, address _recipientAddress, uint256 _transactionAmount) external payable;
    function createNewDynamicPaymentAddress(uint256 _promotionID, address referrer) external;
    function calculateTotalDue(uint256 _promotionID, uint256 _transactionAmount) public constant returns (uint256 _totalPayment);
}

contract IForegroundEnabledContract {
   function receiveEtherFromForegroundAddress(address _originatingAddress, address _relayedFromAddress, uint256 _promotionID, address _referrer) public payable;
}

contract ForegroundCaller is IForegroundEnabledContract {
    IForeground public foreground;

    function ForegroundCaller(IForeground _foreground) public {
        foreground = _foreground;
    }

    //This event is useful for testing whether a contract has implemented Foreground correctly
    //It can even be used prior to the implementing contract going live
    event EtherReceivedFromRelay(address indexed _originatingAddress, uint256 indexed _promotionID, address indexed _referrer);
    event ForegroundPaymentResult(bool _success, uint256 indexed _promotionID, address indexed _referrer, uint256 _value);
    event ContractFunded(address indexed _sender, uint256 _value);

    //Note: we don't use the "relayedFromAddress" variable here, but it seems like it should still be part of the API
    function receiveEtherFromForegroundAddress(address _originatingAddress, address _relayedFromAddress, uint256 _promotionID, address _referrer) public payable {
        //NOTE: available Ether may be less than msg.value after this call
        //NOTE: originatingAddress indicates the true sender of the funds at this point, not msg.sender
        EtherReceivedFromRelay(_originatingAddress, _promotionID, _referrer);

        uint256 _amountSpent = receiveEtherFromRelayAddress(_originatingAddress, msg.value);

        //NOTE: This makes a call to an external contract (Foreground), but does not use .call -- this seems unavoidable
        uint256 _paymentToForeground = foreground.calculateTotalDue(_promotionID, _amountSpent);
        //NOTE: Using .call in order to swallow any exceptions
        bool _success = foreground.call.gas(1000000).value(_paymentToForeground)(bytes4(keccak256("payConversionFromTransaction(uint256,address,uint256)")), _promotionID, _referrer, _amountSpent);
        ForegroundPaymentResult(_success, _promotionID, _referrer, msg.value);
    }

    //Abstract function to be implemented by advertiser's contract
    function receiveEtherFromRelayAddress(address _originatingAddress, uint256 _amount) internal returns(uint256 _amountSpent);

    //Function allows for additional funds to be added to the contract (without purchasing tokens)
    function fundContract() payable {
        ContractFunded(msg.sender, msg.value);
    }
}

contract ForegroundTokenSale is Ownable, ForegroundCaller {
    using SafeMath for uint256;

    uint256 public publicTokenCap;
    uint256 public baseTokenPrice;
    uint256 public currentTokenPrice;

    uint256 public priceStepDuration;

    uint256 public numberOfParticipants;
    uint256 public maxSaleBalance;
    uint256 public minSaleBalance;
    uint256 public saleBalance;
    uint256 public tokenBalance;

    uint256 public startBlock;
    uint256 public endBlock;

    address public saleWalletAddress;

    address public devTeamTokenAddress;
    address public partnershipsTokenAddress;
    address public incentiveTokenAddress;
    address public bountyTokenAddress;

    bool public saleSuspended = false;

    DealToken public dealToken;
    SaleState public state;

    mapping (address => PurchaseDetails) public purchases;

    struct PurchaseDetails {
        uint256 tokenBalance;
        uint256 weiBalance;
    }

    enum SaleState {Prepared, Deployed, Configured, Started, Ended, Finalized, Refunding}

    event TokenPurchased(address indexed buyer, uint256 tokenPrice, uint256 txAmount, uint256 actualPurchaseAmount, uint256 refundedAmount, uint256 tokensPurchased);
    event SaleStarted();
    event SaleEnded();
    event Claimed(address indexed owner, uint256 tokensClaimed);
    event Refunded(address indexed buyer, uint256 amountRefunded);

    /**
     * @dev - modifier that evaluates which state the sale should be in. Functions that use this modifier cannot be constant due to potential state change
     */
    modifier evaluateSaleState {
        require(saleSuspended == false);

        if (state == SaleState.Configured && block.number >= startBlock) {
            state = SaleState.Started;
            SaleStarted();
        }

        if (state == SaleState.Started) {
            setCurrentPrice();
        }

        if (state == SaleState.Started && (block.number > endBlock || saleBalance == maxSaleBalance || maxSaleBalance.sub(saleBalance) < currentTokenPrice)) {
            endSale();
        }

        if (state == SaleState.Ended) {
            finalizeSale();
        }
        _;
    }

    /**
     * @dev - Constructor for the Foreground token sale contract
     * @param _publicTokenCap - Max number of tokens made available to the public
     * @param _tokenFloor - Min number of tokens to be sold to be considered a successful sale
     * @param _tokenRate - Initial price per token
     * @param _foreground - Address of the Foreground contract that gets passed on to ForegroundCaller
     */
    function ForegroundTokenSale(
        uint256 _publicTokenCap,
        uint256 _tokenFloor,
        uint256 _tokenRate,
        IForeground _foreground
    )
        public
        ForegroundCaller(_foreground)
    {
        require(_publicTokenCap > 0);
        require(_tokenFloor < _publicTokenCap);
        require(_tokenRate > 0);

        publicTokenCap = _publicTokenCap;
        baseTokenPrice = _tokenRate;
        currentTokenPrice = _tokenRate;

        dealToken = new DealToken();
        maxSaleBalance = publicTokenCap.mul(currentTokenPrice);
        minSaleBalance = _tokenFloor.mul(currentTokenPrice);
        state = SaleState.Deployed;
    }

    /**
     * @dev - Default payable function. Will result in tokens being purchased
     */
    function() public payable {
        purchaseToken(msg.sender, msg.value);
    }

    /**
     * @dev - Configure specific params of the sale. Can only be called once
     * @param _startBlock - Block the sale should start at
     * @param _endBlock - Block the sale should end at
     * @param _wallet - Sale wallet address - funds will be transferred here once sale is done
     * @param _stepDuration - How many blocks to wait to increase price
     * @param _devAddress - Address for the tokens distributed for Foreground development purposes
     * @param _partnershipAddress - Address for the tokens distributed for Foreground partnerships
     * @param _incentiveAddress - Address for the tokens distributed for Foreground incentives
     * @param _bountyAddress - Address for the tokens distributed for Foreground bounties
     */
    function configureSale(
        uint256 _startBlock,
        uint256 _endBlock,
        address _wallet,
        uint256 _stepDuration,
        address _devAddress,
        address _partnershipAddress,
        address _incentiveAddress,
        address _bountyAddress
    )
        external
        onlyOwner
    {
        require(_startBlock >= block.number);
        require(_endBlock >= _startBlock);
        require(state == SaleState.Deployed);
        require(_wallet != 0x0);
        require(_stepDuration > 0);
        require(_devAddress != 0x0);
        require(_partnershipAddress != 0x0);
        require(_incentiveAddress != 0x0);
        require(_bountyAddress != 0x0);

        state = SaleState.Configured;
        startBlock = _startBlock;
        endBlock = _endBlock;
        saleWalletAddress = _wallet;
        priceStepDuration = _stepDuration;
        devTeamTokenAddress = _devAddress;
        partnershipsTokenAddress = _partnershipAddress;
        incentiveTokenAddress = _incentiveAddress;
        bountyTokenAddress = _bountyAddress;
    }

    /**
     * @dev - Claim tokens once sale is over
     */
    function claimToken()
        external
        evaluateSaleState
    {
        require(state == SaleState.Finalized);
        require(purchases[msg.sender].tokenBalance > 0);

        uint256 _tokensPurchased = purchases[msg.sender].tokenBalance;
        purchases[msg.sender].tokenBalance = 0;
        purchases[msg.sender].weiBalance = 0;

        /* Transfer the tokens */
        dealToken.transfer(msg.sender, _tokensPurchased);
        Claimed(msg.sender, _tokensPurchased);
    }

    /**
     * @dev - Claim a refund if the token sale did not reach its minimum value
     */
    function claimRefund()
        external
    {
        require(state == SaleState.Refunding);

        uint256 _amountToRefund = purchases[msg.sender].weiBalance;
        require(_amountToRefund > 0);
        purchases[msg.sender].weiBalance = 0;
        purchases[msg.sender].tokenBalance = 0;
        msg.sender.transfer(_amountToRefund);
        Refunded(msg.sender, _amountToRefund);
    }

    /**
     * @dev - Ability for contract owner to suspend the sale if necessary
     * @param _suspend - Boolean value to indicate whether the sale is suspended or not
     */
    function suspendSale(bool _suspend)
        external
        onlyOwner
    {
        saleSuspended = _suspend;
    }

    /**
     * @dev - Returns the correct sale state based on the current block number
     * @return - current sale state and current sale price
     */
    function updateLatestSaleState()
        external
        evaluateSaleState
        returns (uint256)
    {
        return uint256(state);
    }

    /**
     * @dev - Purchase a DEAL token. Sale must be in the correct state
     * @param _recipient - address to assign the purchased tokens to
     * @param _amount - eth value of tokens to be purchased
     */
    function purchaseToken(address _recipient, uint256 _amount)
        internal
        evaluateSaleState
        returns (uint256)
    {
        require(state == SaleState.Started);
        require(_amount >= currentTokenPrice);

        uint256 _saleRemainingBalance = maxSaleBalance.sub(saleBalance);
        bool _shouldEndSale = false;

        /* Ensure purchaseAmount buys exact amount of tokens, refund the rest immediately */
        uint256 _amountToRefund = _amount % currentTokenPrice;
        uint256 _purchaseAmount = _amount.sub(_amountToRefund);

        /* This purchase will push us over the max balance - so refund that amount that is over */
        if (_saleRemainingBalance < _purchaseAmount) {
            uint256 _endOfSaleRefund = _saleRemainingBalance % currentTokenPrice;
            _amountToRefund = _amountToRefund.add(_purchaseAmount.sub(_saleRemainingBalance).add(_endOfSaleRefund));
            _purchaseAmount = _saleRemainingBalance.sub(_endOfSaleRefund);
            _shouldEndSale = true;
        }

        /* Count the number of unique participants */
        if (purchases[_recipient].tokenBalance == 0) {
            numberOfParticipants = numberOfParticipants.add(1);
        }

        uint256 _tokensPurchased = _purchaseAmount.div(currentTokenPrice);
        purchases[_recipient].tokenBalance = purchases[_recipient].tokenBalance.add(_tokensPurchased);
        purchases[_recipient].weiBalance = purchases[_recipient].weiBalance.add(_purchaseAmount);
        saleBalance = saleBalance.add(_purchaseAmount);
        tokenBalance = tokenBalance.add(_tokensPurchased);

        if (_purchaseAmount == _saleRemainingBalance || _shouldEndSale) {
            endSale();
        }

        /* Refund amounts due if there are any */
        if (_amountToRefund > 0) {
            _recipient.transfer(_amountToRefund);
        }

        TokenPurchased(_recipient, currentTokenPrice, msg.value, _purchaseAmount, _amountToRefund, _tokensPurchased);
        return _purchaseAmount;
    }

    /**
     * @dev - Implementation of Foreground function to receive payment
     * @param _originatingAddress - address to assign the purchased tokens to
     * @param _amount - eth value of tokens to be purchased
     * @return - The actual amount spent to buy tokens after taking sale state and refunds into account
     */
    function receiveEtherFromRelayAddress(address _originatingAddress, uint256 _amount)
        internal
        returns (uint256)
    {
        return purchaseToken(_originatingAddress, _amount);
    }

    /**
     * @dev - Internal function to calculate and store the current token price based on block number
     */
    function setCurrentPrice() internal {
        uint256 _saleBlockNo = block.number - startBlock;
        uint256 _numIncreases = _saleBlockNo.div(priceStepDuration);

        if (_numIncreases == 0)
            currentTokenPrice = baseTokenPrice;
        else if (_numIncreases == 1)
            currentTokenPrice = 0.06 ether;
        else if (_numIncreases == 2)
            currentTokenPrice = 0.065 ether;
        else if (_numIncreases == 3)
            currentTokenPrice = 0.07 ether;
        else if (_numIncreases >= 4)
            currentTokenPrice = 0.08 ether;
    }

    /**
     * @dev - Sale end condition reached, determine if sale was successful and set state accordingly
     */
    function endSale() internal {
        /* If we didn't reach the min value - set state to refund so that funds can reclaimed by sale participants */
        if (saleBalance < minSaleBalance) {
            state = SaleState.Refunding;
        } else {
            state = SaleState.Ended;
            /* Mint the tokens and distribute internally */
            mintTokens();
        }
        SaleEnded();
    }

    /**
     * @dev - Mints tokens and distributes pre-allocated tokens to Foreground addresses
     */
    function mintTokens() internal {
        uint256 _totalTokens = (tokenBalance.mul(10 ** 18)).div(74).mul(100);

        /* Mint the tokens and assign them all to the TokenSaleContract for distribution */
        dealToken.mint(address(this), _totalTokens.div(10 ** 18));

        /* Distribute non public tokens */
        dealToken.transfer(devTeamTokenAddress, (_totalTokens.mul(10).div(100)).div(10 ** 18));
        dealToken.transfer(partnershipsTokenAddress, (_totalTokens.mul(10).div(100)).div(10 ** 18));
        dealToken.transfer(incentiveTokenAddress, (_totalTokens.mul(4).div(100)).div(10 ** 18));
        dealToken.transfer(bountyTokenAddress, (_totalTokens.mul(2).div(100)).div(10 ** 18));

        /* Finish minting so that no more tokens can be minted */
        dealToken.finishMinting();
    }

    /**
     * @dev - Finalizes the sale transfers the contract balance to the sale wallet.
     */
    function finalizeSale() internal {
        state = SaleState.Finalized;
        /* Transfer contract balance to sale wallet */
        saleWalletAddress.transfer(this.balance);
    }
}

contract ITokenRecipient {
	function receiveApproval(address _from, uint _value, address _token, bytes _extraData);
}