pragma solidity 0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title BITTOStandard
 * @dev the interface of BITTOStandard
 */
 
contract BITTOStandard {
    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;
    function mint() public returns (bool);
    function coinAge() constant public returns (uint256);
    function annualInterest() constant public returns (uint256);
    event Mint(address indexed _address, uint _reward);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
address private _owner;


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
  _owner = msg.sender;
}

/**
  * @return the address of the owner.
  */
function owner() public view returns(address) {
  return _owner;
}

/**
  * @dev Throws if called by any account other than the owner.
  */
modifier onlyOwner() {
  require(isOwner());
  _;
}

/**
  * @return true if `msg.sender` is the owner of the contract.
  */
function isOwner() public view returns(bool) {
  return msg.sender == _owner;
}

/**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
function renounceOwnership() public onlyOwner {
  emit OwnershipRenounced(_owner);
  _owner = address(0);
}

/**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
function transferOwnership(address newOwner) public onlyOwner {
  _transferOwnership(newOwner);
}

/**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
function _transferOwnership(address newOwner) internal {
  require(newOwner != address(0));
  emit OwnershipTransferred(_owner, newOwner);
  _owner = newOwner;
}
}


contract BITTO is IERC20, BITTOStandard, Ownable {
    using SafeMath for uint256;

    string public name = "BITTO";
    string public symbol = "BITTO";
    uint public decimals = 18;

    uint public chainStartTime; //chain start time
    uint public chainStartBlockNumber; //chain start block number
    uint public stakeStartTime; //stake start time
    uint public stakeMinAge = 10 days; // minimum age for coin age: 10D
    uint public stakeMaxAge = 180 days; // stake age of full weight: 180D

    uint public totalSupply;
    uint public maxTotalSupply;
    uint public totalInitialSupply;

    uint constant MIN_STAKING = 5000;  // minium amount of token to stake
    uint constant STAKE_START_TIME = 1537228800;  // 2018.9.18
    uint constant STEP1_ENDTIME = 1552780800;  //  2019.3.17
    uint constant STEP2_ENDTIME = 1568332800;  // 2019.9.13
    uint constant STEP3_ENDTIME = 1583884800;  // 2020.3.11
    uint constant STEP4_ENDTIME = 1599436800; // 2020.9.7
    uint constant STEP5_ENDTIME = 1914969600; // 2030.9.7

    struct Period {
        uint start;
        uint end;
        uint interest;
    }

    mapping (uint => Period) periods;

    mapping(address => bool) public noPOSRewards;

    struct transferInStruct {
        uint128 amount;
        uint64 time;
    }

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => transferInStruct[]) transferIns;

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    modifier canPoSMint() {
        require(totalSupply < maxTotalSupply);
        _;
    }

    constructor() public {
        // 5 mil is reserved for POS rewards
        maxTotalSupply = 223 * 10**23; // 22.3 Mil.
        totalInitialSupply = 173 * 10**23; // 17.3 Mil. 10 mil = crowdsale, 7.3 team account

        chainStartTime = now;
        chainStartBlockNumber = block.number;

        balances[msg.sender] = totalInitialSupply;
        totalSupply = totalInitialSupply;

        // 4 periods for 2 years
        stakeStartTime = 1537228800;
        
        periods[0] = Period(STAKE_START_TIME, STEP1_ENDTIME, 65 * 10 ** 18);
        periods[1] = Period(STEP1_ENDTIME, STEP2_ENDTIME, 34 * 10 ** 18);
        periods[2] = Period(STEP2_ENDTIME, STEP3_ENDTIME, 20 * 10 ** 18);
        periods[3] = Period(STEP3_ENDTIME, STEP4_ENDTIME, 134 * 10 ** 16);
        periods[4] = Period(STEP4_ENDTIME, STEP5_ENDTIME, 134 * 10 ** 16);
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
        if (msg.sender == _to)
            return mint();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        if (transferIns[msg.sender].length > 0)
            delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        if (transferIns[_from].length > 0)
            delete transferIns[_from];
        uint64 _now = uint64(now);
        transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function mint() canPoSMint public returns (bool) {
        // minimum stake of 5000 x is required to earn staking.
        if (balances[msg.sender] < MIN_STAKING.mul(1 ether))
            return false;
        if (transferIns[msg.sender].length <= 0)
            return false;

        uint reward = getProofOfStakeReward(msg.sender);
        if (reward <= 0)
            return false;
       
        totalSupply = totalSupply.add(reward);
        balances[msg.sender] = balances[msg.sender].add(reward);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));

        emit Transfer(address(0), msg.sender, reward);
        emit Mint(msg.sender, reward);
        return true;
    }

    function getBlockNumber() view public returns (uint blockNumber) {
        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge() constant public returns (uint myCoinAge) {
        uint _now = now;
        myCoinAge = 0;
        for (uint i=0; i < getPeriodNumber(_now) + 1; i ++) {
            myCoinAge += getCoinAgeofPeriod(msg.sender, i, _now);
        }
    }

    function annualInterest() constant public returns (uint interest) {        
        uint _now = now;
        interest = periods[getPeriodNumber(_now)].interest;
    }

    function getProofOfStakeReward(address _address) public view returns (uint totalReward) {
        require((now >= stakeStartTime) && (stakeStartTime > 0));
        require(!noPOSRewards[_address]);

        uint _now = now;

        totalReward = 0;
        for (uint i=0; i < getPeriodNumber(_now) + 1; i ++) {
            totalReward += (getCoinAgeofPeriod(_address, i, _now)).mul(periods[i].interest).div(100).div(365);
        }
    }

    function getPeriodNumber(uint _now) public view returns (uint periodNumber) {
        for (uint i = 4; i >= 0; i --) {
            if( _now >= periods[i].start){
                return i;
            }
        }
    }

    function getCoinAgeofPeriod(address _address, uint _pid, uint _now) public view returns (uint _coinAge) {        
        if (transferIns[_address].length <= 0)
            return 0;

        if (_pid < 0 || _pid > 4)
            return 0;

        _coinAge = 0;
        uint nCoinSeconds;
        uint i;

        if (periods[_pid].start < _now && 
            periods[_pid].end >= _now) {
            // calculate the current period
            for (i = 0; i < transferIns[_address].length; i ++) {
                if (uint(periods[_pid].start) > uint(transferIns[_address][i].time) || 
                    uint(periods[_pid].end) <= uint(transferIns[_address][i].time))
                    continue;
                
                nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
                
                if (nCoinSeconds < stakeMinAge)
                    continue;

                if ( nCoinSeconds > stakeMaxAge )
                    nCoinSeconds = stakeMaxAge;    
                
                nCoinSeconds = nCoinSeconds.sub(stakeMinAge);
                _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
            }

        }else{
            // calculate for the ended preriods which user did not claimed
            for (i = 0; i < transferIns[_address].length; i++) {
                if (uint(periods[_pid].start) > uint(transferIns[_address][i].time) || 
                    uint(periods[_pid].end) <= uint(transferIns[_address][i].time))
                    continue;

                nCoinSeconds = (uint(periods[_pid].end)).sub(uint(transferIns[_address][i].time));
                
                if (nCoinSeconds < stakeMinAge)
                    continue;

                if ( nCoinSeconds > stakeMaxAge )
                    nCoinSeconds = stakeMaxAge;

                nCoinSeconds = nCoinSeconds.sub(stakeMinAge);
                _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
            }
        }

        _coinAge = _coinAge.div(1 ether);
    }

    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function ownerBurnToken(uint _value) public onlyOwner {
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));

        totalSupply = totalSupply.sub(_value);
        totalInitialSupply = totalInitialSupply.sub(_value);
        maxTotalSupply = maxTotalSupply.sub(_value*10);

        emit Burn(msg.sender, _value);
    }

    /* Batch token transfer. Used by contract creator to distribute initial tokens to holders */
    function batchTransfer(address[] _recipients, uint[] _values) onlyOwner public returns (bool) {
        require(_recipients.length > 0 && _recipients.length == _values.length);

        uint total = 0;
        for (uint i = 0; i < _values.length; i++) {
            total = total.add(_values[i]);
        }
        require(total <= balances[msg.sender]);

        uint64 _now = uint64(now);
        for (uint j = 0; j < _recipients.length; j++) {
            balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
            transferIns[_recipients[j]].push(transferInStruct(uint128(_values[j]),_now));
            emit Transfer(msg.sender, _recipients[j], _values[j]);
        }

        balances[msg.sender] = balances[msg.sender].sub(total);
        if (transferIns[msg.sender].length > 0)
            delete transferIns[msg.sender];
        if (balances[msg.sender] > 0)
            transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));

        return true;
    }

    function disablePOSReward(address _account, bool _enabled) onlyOwner public {
        noPOSRewards[_account] = _enabled;
    }
}