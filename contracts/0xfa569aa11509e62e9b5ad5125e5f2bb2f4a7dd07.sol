pragma solidity ^0.4.24;

contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens, weiAmount);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount,
    uint256 _weiAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

contract QuinadsCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint8;
    using SafeERC20 for ERC20;

    uint256 public TokenSaleSupply = 12000000000000000000000000000;
    uint256 public tokensSold;
    
    // contribution(min) per stage
    uint256 public preContrib    = 20000000000000000000;
    uint256 public icoContrib    = 10000000000000000;
    // bonus pre n ico
    uint256 public minGetBonus    = 20000000000000000000;
    // bonus per stage
    uint8 public prePercentBonus = 10;
    uint8 public icoPercentBonus  = 5;
    // supply per stage (without bonus allocation)
    uint256 public preSupply  = 2400000000000000000000000000;
    uint256 public icoSupply  = 9600000000000000000000000000;
    // stage status
    bool public preOpen = false;
    bool public icoOpen = false;

    bool public icoClosed = false;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public presaleTotalBuy;
    mapping(address => uint256) public icoTotalBuy;
    mapping(address => uint256) public presaleBonus;
    mapping(address => uint256) public icoBonus;
    mapping(uint8 => uint256) public soldPerStage;
    mapping(uint8 => uint256) public availablePerStage;
    mapping(address => bool) public allowPre;

    // STAGE SETUP
    enum CrowdsaleStage { preSale, ICO }
    CrowdsaleStage public stage = CrowdsaleStage.preSale;
    uint256 public minContribution = preContrib;
    uint256 public stageAllocation = preSupply;

    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token
    )
    Crowdsale(_rate, _wallet, _token)
    public {
        availablePerStage[0] = stageAllocation;
    }

    /** add some function */
    function openPresale(bool status) public onlyOwner {
        preOpen = status;
    }
    function openICOSale(bool status) public onlyOwner {
        icoOpen = status;
    }
    function closeICO(bool status) public onlyOwner {
        icoClosed = status;
    }
    function setCrowdsaleStage(uint8 _stage) public onlyOwner {
        _setCrowdsaleStage(_stage);
    }

    function _setCrowdsaleStage(uint8 _stage) internal {
        // can not back to prev stage
        require(_stage > uint8(stage) && _stage < 2);

        if(uint8(CrowdsaleStage.preSale) == _stage) {
            stage = CrowdsaleStage.preSale;
            minContribution = preContrib;
            stageAllocation = preSupply;
        } else {
            stage = CrowdsaleStage.ICO;
            minContribution = icoContrib;
            stageAllocation = icoSupply;
        }

        availablePerStage[_stage] = stageAllocation;
    }

    function whitelistPresale(address _beneficiary, bool status) public onlyOwner {
        allowPre[_beneficiary] = status;
    }

    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        // checking
        require(!icoClosed);
        require(_beneficiary != address(0));
        if(stage == CrowdsaleStage.preSale) {
            require(preOpen);
            require(allowPre[_beneficiary]);
            allowPre[_beneficiary] = false;
            require(_weiAmount == minContribution);
        } else {
            require(icoOpen);
            require(_weiAmount >= minContribution);
        }
    }

    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount,
        uint256 _weiAmount
    )
        internal
    {
        uint8 getBonusStage;
        uint256 bonusStage_;
        uint256 additionalBonus = 0;
        if(stage == CrowdsaleStage.preSale) {
            getBonusStage = prePercentBonus;
        } else {
            if(_weiAmount>=minGetBonus){
                getBonusStage = icoPercentBonus;
            } else {
                getBonusStage = 0;
            }
        }
        bonusStage_ = _tokenAmount.mul(getBonusStage).div(100);
        require(availablePerStage[uint8(stage)] >= _tokenAmount);
        tokensSold = tokensSold.add(_tokenAmount);

        soldPerStage[uint8(stage)] = soldPerStage[uint8(stage)].add(_tokenAmount);
        availablePerStage[uint8(stage)] = availablePerStage[uint8(stage)].sub(_tokenAmount);
        // next stage or close ICO
        if(availablePerStage[uint8(stage)]<=0){
            // now stage false
            if(stage == CrowdsaleStage.preSale) {
                preOpen = false;
                stage = CrowdsaleStage.ICO;
                _setCrowdsaleStage(1);
            } else if(stage == CrowdsaleStage.ICO) {
                icoOpen = false;
                icoClosed = true;
            }
        }
        // contribution / stage and all bonuses
        if(stage == CrowdsaleStage.preSale) {
            presaleTotalBuy[_beneficiary] = presaleTotalBuy[_beneficiary] + _tokenAmount;
            presaleBonus[_beneficiary] = presaleBonus[_beneficiary].add(bonusStage_);
        } else {
            icoTotalBuy[_beneficiary] = icoTotalBuy[_beneficiary] + _tokenAmount;
            icoBonus[_beneficiary] = icoBonus[_beneficiary].add(bonusStage_);
        }
        _deliverTokens(_beneficiary, _tokenAmount.add(bonusStage_).add(additionalBonus));
    }

    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        // contribution
        uint256 _existingContribution = contributions[_beneficiary];
        uint256 _newContribution = _existingContribution.add(_weiAmount);
        contributions[_beneficiary] = _newContribution;
    }

    function getuserContributions(address _beneficiary) public view returns (uint256) {
        return contributions[_beneficiary];
    }
    function getuserPresaleTotalBuy(address _beneficiary) public view returns (uint256) {
        return presaleTotalBuy[_beneficiary];
    }
    function getuserICOTotalBuy(address _beneficiary) public view returns (uint256) {
        return icoTotalBuy[_beneficiary];
    }
    function getuserPresaleBonus(address _beneficiary) public view returns (uint256) {
        return presaleBonus[_beneficiary];
    }
    function getuserICOBonus(address _beneficiary) public view returns (uint256) {
        return icoBonus[_beneficiary];
    }
    function getAvailableBuyETH(uint8 _stage) public view returns (uint256) {
        return availablePerStage[_stage].div(rate);
    }

    // send back the rest of token to airdrop program
    function sendToOwner(uint256 _amount) public onlyOwner {
        require(icoClosed);
        _deliverTokens(owner, _amount);
    }

}