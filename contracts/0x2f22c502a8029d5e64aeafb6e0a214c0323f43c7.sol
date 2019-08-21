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



/*
 * @title This is proxy for analytics. Target contract can be found at field m_analytics (see "read contract").
 * @author Eenae

 * FIXME after fix of truffle issue #560: refactor to a separate contract file which uses InvestmentAnalytics interface
 */
contract AnalyticProxy {

    function AnalyticProxy() {
        m_analytics = InvestmentAnalytics(msg.sender);
    }

    /// @notice forward payment to analytics-capable contract
    function() payable {
        m_analytics.iaInvestedBy.value(msg.value)(msg.sender);
    }

    InvestmentAnalytics public m_analytics;
}


/*
 * @title Mixin contract which supports different payment channels and provides analytical per-channel data.
 * @author Eenae
 */
contract InvestmentAnalytics {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    /// @dev creates more payment channels, up to the limit but not exceeding gas stipend
    function createMorePaymentChannelsInternal(uint limit) internal returns (uint) {
        uint paymentChannelsCreated;
        for (uint i = 0; i < limit; i++) {
            uint startingGas = msg.gas;
            /*
             * ~170k of gas per paymentChannel,
             * using gas price = 4Gwei 2k paymentChannels will cost ~1.4 ETH.
             */

            address paymentChannel = new AnalyticProxy();
            m_validPaymentChannels[paymentChannel] = true;
            m_paymentChannels.push(paymentChannel);
            paymentChannelsCreated++;

            // cost of creating one channel
            uint gasPerChannel = startingGas.sub(msg.gas);
            if (gasPerChannel.add(50000) > msg.gas)
                break;  // enough proxies for this call
        }
        return paymentChannelsCreated;
    }


    /// @dev process payments - record analytics and pass control to iaOnInvested callback
    function iaInvestedBy(address investor) external payable {
        address paymentChannel = msg.sender;
        if (m_validPaymentChannels[paymentChannel]) {
            // payment received by one of our channels
            uint value = msg.value;
            m_investmentsByPaymentChannel[paymentChannel] = m_investmentsByPaymentChannel[paymentChannel].add(value);
            // We know for sure that investment came from specified investor (see AnalyticProxy).
            iaOnInvested(investor, value, true);
        } else {
            // Looks like some user has paid to this method, this payment is not included in the analytics,
            // but, of course, processed.
            iaOnInvested(msg.sender, msg.value, false);
        }
    }

    /// @dev callback
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel) internal {
    }


    function paymentChannelsCount() external constant returns (uint) {
        return m_paymentChannels.length;
    }

    function readAnalyticsMap() external constant returns (address[], uint[]) {
        address[] memory keys = new address[](m_paymentChannels.length);
        uint[] memory values = new uint[](m_paymentChannels.length);

        for (uint i = 0; i < m_paymentChannels.length; i++) {
            address key = m_paymentChannels[i];
            keys[i] = key;
            values[i] = m_investmentsByPaymentChannel[key];
        }

        return (keys, values);
    }

    function readPaymentChannels() external constant returns (address[]) {
        return m_paymentChannels;
    }


    mapping(address => uint256) public m_investmentsByPaymentChannel;
    mapping(address => bool) m_validPaymentChannels;

    address[] public m_paymentChannels;
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


contract STQToken {
    function mint(address _to, uint256 _amount) external;
}

/// @title Storiqa pre-ICO contract
contract STQPreICO is Ownable, ReentrancyGuard, InvestmentAnalytics {
    using SafeMath for uint256;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function STQPreICO(address token, address funds) {
        require(address(0) != address(token) && address(0) != address(funds));

        m_token = STQToken(token);
        m_funds = funds;
    }


    // PUBLIC interface: payments

    // fallback function as a shortcut
    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice ICO participation
    function buy() public payable {     // dont mark as external!
        iaOnInvested(msg.sender, msg.value, false);
    }


    // PUBLIC interface: maintenance

    function createMorePaymentChannels(uint limit) external onlyOwner returns (uint) {
        return createMorePaymentChannelsInternal(limit);
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyOwner returns (bool) {
        return true;
    }


    // INTERNAL

    /// @dev payment callback
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel)
        internal
        nonReentrant
    {
        require(payment >= c_MinInvestment);
        require(getCurrentTime() >= c_startTime && getCurrentTime() < c_endTime || msg.sender == owner);

        uint startingInvariant = this.balance.add(m_funds.balance);

        // return or update payment if needed
        uint paymentAllowed = getMaximumFunds().sub(m_totalInvested);
        if (0 == paymentAllowed) {
            investor.transfer(payment);
            return;
        }
        uint change;
        if (paymentAllowed < payment) {
            change = payment.sub(paymentAllowed);
            payment = paymentAllowed;
        }

        // calculate rate
        uint bonusPercent = c_preICOBonusPercent;
        bonusPercent += getLargePaymentBonus(payment);
        if (usingPaymentChannel)
            bonusPercent += c_paymentChannelBonusPercent;

        uint rate = c_STQperETH.mul(100 + bonusPercent).div(100);

        // issue tokens
        uint stq = payment.mul(rate);
        m_token.mint(investor, stq);

        // record payment
        m_funds.transfer(payment);
        m_totalInvested = m_totalInvested.add(payment);
        assert(m_totalInvested <= getMaximumFunds());
        FundTransfer(investor, payment, true);

        if (change > 0)
            investor.transfer(change);

        assert(startingInvariant == this.balance.add(m_funds.balance).add(change));
    }

    function getLargePaymentBonus(uint payment) private constant returns (uint) {
        if (payment > 1000 ether) return 10;
        if (payment > 800 ether) return 8;
        if (payment > 500 ether) return 5;
        if (payment > 200 ether) return 2;
        return 0;
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal constant returns (uint) {
        return now;
    }

    /// @dev to be overridden in tests
    function getMaximumFunds() internal constant returns (uint) {
        return c_MaximumFunds;
    }


    // FIELDS

    /// @notice start time of the pre-ICO
    uint public constant c_startTime = 1507766400;

    /// @notice end time of the pre-ICO
    uint public constant c_endTime = c_startTime + (1 days);

    /// @notice minimum investment
    uint public constant c_MinInvestment = 10 finney;

    /// @notice maximum investments to be accepted during pre-ICO
    uint public constant c_MaximumFunds = 8000 ether;


    /// @notice starting exchange rate of STQ
    uint public constant c_STQperETH = 100000;

    /// @notice pre-ICO bonus
    uint public constant c_preICOBonusPercent = 40;

    /// @notice authorised payment bonus
    uint public constant c_paymentChannelBonusPercent = 2;


    /// @dev total investments amount
    uint public m_totalInvested;

    /// @dev contract responsible for token accounting
    STQToken public m_token;

    /// @dev address responsible for investments accounting
    address public m_funds;
}