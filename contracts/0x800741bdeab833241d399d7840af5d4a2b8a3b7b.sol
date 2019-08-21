pragma solidity ^0.4.13;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

// Token standard API
// https://github.com/ethereum/EIPs/issues/20

contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

contract TokenTransferGuard {
    function onTokenTransfer(address _from, address _to, uint _amount) public returns (bool);
}

contract RewardSharedPool is DSStop {
    using SafeMath for uint256;

    uint public maxReward      = 1000000 ether;

    uint public consumed   = 0;

    mapping(address => bool) public consumers;

    modifier onlyConsumer {
        require(msg.sender == owner || consumers[msg.sender]);
        _;
    }

    function RewardSharedPool()
    {
    }

    function consume(uint amount) onlyConsumer public returns (bool)
    {
        require(available(amount));

        consumed = consumed.add(amount);

        Consume(msg.sender, amount);

        return true;
    }

    function available(uint amount) constant public returns (bool)
    {
        return consumed.add(amount) <= maxReward;
    }

    function changeMaxReward(uint _maxReward) auth public
    {
        maxReward = _maxReward;
    }

    function addConsumer(address consumer) public auth
    {
        consumers[consumer] = true;

        ConsumerAddition(consumer);
    }

    function removeConsumer(address consumer) public auth
    {
        consumers[consumer] = false;

        ConsumerRemoval(consumer);
    }

    event Consume(address indexed _sender, uint _value);
    event ConsumerAddition(address indexed _consumer);
    event ConsumerRemoval(address indexed _consumer);
}

contract ATNLongTermHolding is DSStop, TokenTransferGuard {
    using SafeMath for uint256;

    uint public constant DEPOSIT_WINDOW                 = 60 days;

    // There are three kinds of options: 1. {105, 120 days}, 2. {110, 240 days}, 3. {115, 360 days}
    uint public rate = 105;
    uint public withdrawal_delay    = 120 days;

    uint public agtAtnReceived      = 0;
    uint public atnSent             = 0;

    uint public depositStartTime    = 0;
    uint public depositStopTime     = 0;

    RewardSharedPool public pool;

    struct Record {
        uint agtAtnAmount;
        uint timestamp;
    }

    mapping (address => Record) public records;

    ERC20 public AGT;
    ERC20 public ATN;

    uint public gasRequired;

    function ATNLongTermHolding(address _agt, address _atn, address _poolAddress, uint _rate, uint _delayDays)
    {
        AGT = ERC20(_agt);
        ATN = ERC20(_atn);

        pool = RewardSharedPool(_poolAddress);

        require(_rate > 100);

        rate = _rate;
        withdrawal_delay = _delayDays * 1 days;
    }

    function start() public auth {
        require(depositStartTime == 0);

        depositStartTime = now;
        depositStopTime  = now + DEPOSIT_WINDOW;

        Started(depositStartTime);
    }

    function changeDepositStopTimeFromNow(uint _daysFromNow) public auth {
        depositStopTime = now + _daysFromNow * 1 days;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        tokenFallback(_from, _value);
    }

    // TODO: To test the stoppable can work or not
    function tokenFallback(address _from, uint256 _value) public stoppable
    {
        if (msg.sender == address(AGT) || msg.sender == address(ATN))
        {
            // the owner is not count in the statistics
            // Only owner can use to deposit the ATN reward things.
            if (_from == owner)
            {
                return;
            }

            require(now <= depositStopTime);

            var record = records[_from];

            record.agtAtnAmount += _value;
            record.timestamp = now;
            records[_from] = record;

            agtAtnReceived += _value;

            pool.consume( _value.mul(rate - 100 ).div(100) );

            Deposit(depositId++, _from, _value);
        }
    }

    function onTokenTransfer(address _from, address _to, uint _amount) public returns (bool)
    {
        if (_to == address(this) && _from != owner)
        {
            if (msg.gas < gasRequired) return false;
            
            if (stopped) return false;
            if (now > depositStopTime) return false;

            // each address can only deposit once.
            if (records[_from].timestamp > 0 ) return false;

            // can not over the limit of maximum reward amount
            if ( !pool.available( _amount.mul(rate - 100 ).div(100) ) ) return false;
        }

        return true;
    }

    function withdrawATN() public stoppable {
        require(msg.sender != owner);

        Record record = records[msg.sender];

        require(record.timestamp > 0);

        require(now >= record.timestamp + withdrawal_delay);

        withdrawFor(msg.sender);
    }

    function withdrawATN(address _addr) public stoppable {
        require(_addr != owner);

        Record record = records[_addr];

        require(record.timestamp > 0);

        require(now >= record.timestamp + withdrawal_delay);

        withdrawFor(_addr);
    }

    function withdrawFor(address _addr) internal {
        Record record = records[_addr];
        
        uint atnAmount = record.agtAtnAmount.mul(rate).div(100);

        require(ATN.transfer(_addr, atnAmount));

        atnSent += atnAmount;

        delete records[_addr];

        Withdrawal(
                   withdrawId++,
                   _addr,
                   atnAmount
                   );
    }

    function batchWithdraw(address[] _addrList) public stoppable {
        for (uint i = 0; i < _addrList.length; i++) {
            if (records[_addrList[i]].timestamp > 0 && now >= records[_addrList[i]].timestamp + withdrawal_delay)
            {
                withdrawFor(_addrList[i]);
            }
        }
    }

    function changeGasRequired(uint _gasRequired) public auth {
        gasRequired = _gasRequired;
        ChangeGasRequired(_gasRequired);
    }

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public auth {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        
        ERC20 token = ERC20(_token);
        
        uint256 balance = token.balanceOf(this);
        
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);

    /*
     * EVENTS
     */
    /// Emitted when program starts.
    event Started(uint _time);

    /// Emitted for each sucuessful deposit.
    uint public depositId = 0;
    event Deposit(uint _depositId, address indexed _addr, uint agtAtnAmount);

    /// Emitted for each sucuessful withdrawal.
    uint public withdrawId = 0;
    event Withdrawal(uint _withdrawId, address indexed _addr, uint _atnAmount);

    event ChangeGasRequired(uint _gasRequired);
}