pragma solidity ^0.4.13;

contract ArgumentsChecker {

    /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint size) {
       require(msg.data.length == size + 4 /* function selector */);
       _;
    }

    /// @dev check that address is valid
    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}

contract CrowdsaleBase is ArgumentsChecker, ReentrancyGuard {
    using SafeMath for uint256;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function CrowdsaleBase(address owner80, address owner20, string token_name, string token_symbol)
        public
    {
        m_funds = new LightFundsRegistry(owner80, owner20);
        m_token = new TokenBase(token_name, token_symbol);

        assert(! hasHardCap() || getMaximumFunds() >= getMinimumFunds());
    }


    // PUBLIC interface

    // fallback function as a shortcut
    function()
        public
        payable
    {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice crowdsale participation
    function buy()
        public  // dont mark as external!
        payable
    {
        buyInternal(msg.sender, msg.value);
    }


    /// @notice refund
    function withdrawPayments()
        external
    {
        m_funds.withdrawPayments(msg.sender);
    }


    // INTERNAL

    /// @dev payment processing
    function buyInternal(address investor, uint payment)
        internal
        nonReentrant
    {
        require(payment >= getMinInvestment());
        if (getCurrentTime() >= getEndTime())
            finish();

        if (m_finished) {
            // saving provided gas
            investor.transfer(payment);
            return;
        }

        uint startingWeiCollected = getWeiCollected();
        uint startingInvariant = this.balance.add(startingWeiCollected);

        uint change;
        if (hasHardCap()) {
            // return or update payment if needed
            uint paymentAllowed = getMaximumFunds().sub(getWeiCollected());
            assert(0 != paymentAllowed);

            if (paymentAllowed < payment) {
                change = payment.sub(paymentAllowed);
                payment = paymentAllowed;
            }
        }

        // issue tokens
        require(m_token.mint(investor, calculateTokens(payment)));

        // record payment
        m_funds.invested.value(payment)(investor);

        assert((!hasHardCap() || getWeiCollected() <= getMaximumFunds()) && getWeiCollected() > startingWeiCollected);
        FundTransfer(investor, payment, true);

        if (hasHardCap() && getWeiCollected() == getMaximumFunds())
            finish();

        if (change > 0)
            investor.transfer(change);

        assert(startingInvariant == this.balance.add(getWeiCollected()).add(change));
    }

    function finish() internal {
        if (m_finished)
            return;

        if (getWeiCollected() >= getMinimumFunds()) {
            // Success
            m_funds.changeState(LightFundsRegistry.State.SUCCEEDED);
            m_token.ICOSuccess();
        }
        else {
            // Failure
            m_funds.changeState(LightFundsRegistry.State.REFUNDING);
        }

        m_finished = true;
    }


    /// @notice whether to apply hard cap check logic via getMaximumFunds() method
    function hasHardCap() internal constant returns (bool) {
        return getMaximumFunds() != 0;
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal constant returns (uint) {
        return now;
    }

    /// @notice maximum investments to be accepted during the sale (in wei)
    function getMaximumFunds() internal constant returns (uint) {
        return euroCents2wei(getMaximumFundsInEuroCents());
    }

    /// @notice minimum amount of funding to consider the sale as successful (in wei)
    function getMinimumFunds() internal constant returns (uint) {
        return euroCents2wei(getMinimumFundsInEuroCents());
    }

    /// @notice end time of the sale
    function getEndTime() public pure returns (uint) {
        return 1521331200;
    }

    /// @notice minimal amount of one investment (in wei)
    function getMinInvestment() public pure returns (uint) {
        return 10 finney;
    }

    /// @dev smallest divisible token units (token wei) in one token
    function tokenWeiInToken() internal constant returns (uint) {
        return uint(10) ** uint(m_token.decimals());
    }

    /// @dev calculates token amount for given investment
    function calculateTokens(uint payment) internal constant returns (uint) {
        return wei2euroCents(payment).mul(tokenWeiInToken()).div(tokenPriceInEuroCents());
    }


    // conversions

    function wei2euroCents(uint wei_) public view returns (uint) {
        return wei_.mul(euroCentsInOneEther()).div(1 ether);
    }


    function euroCents2wei(uint euroCents) public view returns (uint) {
        return euroCents.mul(1 ether).div(euroCentsInOneEther());
    }


    // stat

    /// @notice amount of euro collected
    function getEuroCollected() public constant returns (uint) {
        return wei2euroCents(getWeiCollected()).div(100);
    }

    /// @notice amount of wei collected
    function getWeiCollected() public constant returns (uint) {
        return m_funds.totalInvested();
    }

    /// @notice amount of wei-tokens minted
    function getTokenMinted() public constant returns (uint) {
        return m_token.totalSupply();
    }


    // SETTINGS

    /// @notice maximum investments to be accepted during the sale (in euro-cents)
    function getMaximumFundsInEuroCents() public constant returns (uint);

    /// @notice minimum amount of funding to consider the sale as successful (in euro-cents)
    function getMinimumFundsInEuroCents() public constant returns (uint);

    /// @notice euro-cents per 1 ether
    function euroCentsInOneEther() public constant returns (uint);

    /// @notice price of one token (1e18 wei-tokens) in euro cents
    function tokenPriceInEuroCents() public constant returns (uint);


    // FIELDS

    /// @dev contract responsible for funds accounting
    LightFundsRegistry public m_funds;

    /// @dev contract responsible for token accounting
    TokenBase public m_token;

    bool m_finished = false;
}

contract LightFundsRegistry is ArgumentsChecker, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    enum State {
        // gathering funds
        GATHERING,
        // returning funds to investors
        REFUNDING,
        // funds sent to owners
        SUCCEEDED
    }

    event StateChanged(State _state);
    event Invested(address indexed investor, uint256 amount);
    event EtherSent(address indexed to, uint value);
    event RefundSent(address indexed to, uint value);


    modifier requiresState(State _state) {
        require(m_state == _state);
        _;
    }


    // PUBLIC interface

    function LightFundsRegistry(address owner80, address owner20)
        public
        validAddress(owner80)
        validAddress(owner20)
    {
        m_owner80 = owner80;
        m_owner20 = owner20;
    }

    /// @dev performs only allowed state transitions
    function changeState(State _newState)
        external
        onlyOwner
    {
        assert(m_state != _newState);

        if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);

        if (State.SUCCEEDED == _newState) {
            uint _80percent = this.balance.mul(80).div(100);
            m_owner80.transfer(_80percent);
            EtherSent(m_owner80, _80percent);

            uint _20percent = this.balance;
            m_owner20.transfer(_20percent);
            EtherSent(m_owner20, _20percent);
        }
    }

    /// @dev records an investment
    function invested(address _investor)
        external
        payable
        onlyOwner
        requiresState(State.GATHERING)
    {
        uint256 amount = msg.value;
        require(0 != amount);

        // register investor
        if (0 == m_weiBalances[_investor])
            m_investors.push(_investor);

        // register payment
        totalInvested = totalInvested.add(amount);
        m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);

        Invested(_investor, amount);
    }

    /// @notice withdraw accumulated balance, called by payee in case crowdsale has failed
    function withdrawPayments(address payee)
        external
        nonReentrant
        onlyOwner
        requiresState(State.REFUNDING)
    {
        uint256 payment = m_weiBalances[payee];

        require(payment != 0);
        require(this.balance >= payment);

        totalInvested = totalInvested.sub(payment);
        m_weiBalances[payee] = 0;

        payee.transfer(payment);
        RefundSent(payee, payment);
    }

    function getInvestorsCount() external view returns (uint) { return m_investors.length; }


    // FIELDS

    /// @notice total amount of investments in wei
    uint256 public totalInvested;

    /// @notice state of the registry
    State public m_state = State.GATHERING;

    /// @dev balances of investors in wei
    mapping(address => uint256) public m_weiBalances;

    /// @dev list of unique investors
    address[] public m_investors;

    address public m_owner80;
    address public m_owner20;
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

contract CirculatingToken is StandardToken {

    event CirculationEnabled();

    modifier requiresCirculation {
        require(m_isCirculating);
        _;
    }


    // PUBLIC interface

    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {
        return super.approve(_spender, _value);
    }


    // INTERNAL functions

    function enableCirculation() internal returns (bool) {
        if (m_isCirculating)
            return false;

        m_isCirculating = true;
        CirculationEnabled();
        return true;
    }


    // FIELDS

    /// @notice are the circulation started?
    bool public m_isCirculating;
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

contract TokenBase is MintableToken, CirculatingToken {

    event Burn(address indexed from, uint256 amount);


    string m_name;
    string m_symbol;
    uint8 public constant decimals = 18;


    function TokenBase(string _name, string _symbol) public {
        require(bytes(_name).length > 0 && bytes(_name).length <= 32);
        require(bytes(_symbol).length > 0 && bytes(_symbol).length <= 32);

        m_name = _name;
        m_symbol = _symbol;
    }


    function burn(uint256 _amount) external returns (bool) {
        address _from = msg.sender;
        require(_amount>0);
        require(_amount<=balances[_from]);

        totalSupply = totalSupply.sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        Burn(_from, _amount);
        Transfer(_from, address(0), _amount);

        return true;
    }


    function name() public view returns (string) {
        return m_name;
    }

    function symbol() public view returns (string) {
        return m_symbol;
    }


    function ICOSuccess()
        external
        onlyOwner
    {
        assert(finishMinting());
        assert(enableCirculation());
    }
}


contract EESTSale6 is CrowdsaleBase {

    function EESTSale6() public
        CrowdsaleBase(
            /*owner80*/ address(0xade21bda21be237f8b13a494a46b122c5f1f26fb),
            /*owner20*/ address(0xa6809a7e050ca9ea9e4d2ccedc88f07d6ada09aa),
            "Electronic exchange sign-token 6", "EEST6")
    {
    }


    /// @notice maximum investments to be accepted during the sale (in euro-cents)
    function getMaximumFundsInEuroCents() public constant returns (uint) {
        return 6000000000;
    }

    /// @notice minimum amount of funding to consider the sale as successful (in euro-cents)
    function getMinimumFundsInEuroCents() public constant returns (uint) {
        return 6000000000;
    }

    /// @notice euro-cents per 1 ether
    function euroCentsInOneEther() public constant returns (uint) {
        return 58000;
    }

    /// @notice price of one token (1e18 wei-tokens) in euro cents
    function tokenPriceInEuroCents() public constant returns (uint) {
        return 1000;
    }
}