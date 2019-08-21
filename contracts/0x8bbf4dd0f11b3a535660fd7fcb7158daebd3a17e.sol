/**
 * @First Smart Airdrop eGAS
 * @http://ethgas.stream
 * @egas@ethgas.stream
 */

pragma solidity ^0.4.16;


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

contract Owned {
    // The address of the account of the current owner
    address public owner;

    // The publiser is the inital owner
    function Owned() public {
        owner = msg.sender;
    }

    /**
     * Access is restricted to the current owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract EGAS is Owned {
    using SafeMath for uint256;
    string public symbol = "EGAS";
    string public name = "ETHGAS";
    uint8 public constant decimals = 8;
    uint256 _initialSupply = 100000000000000;
    uint256 _totalSupply = 0;
	uint256 _maxTotalSupply = 1279200000000000;
	uint256 _dropReward = 26000000000; //260 eGAS - per entry with 30% bonus to start
	uint256 _maxDropReward = 1300000000000; //13000 eGAS - per block 10min with 30% bonus to start - 50 entry max
	uint256 _rewardBonusTimePeriod = 86400; //1 day each bonus stage
	uint256 _nextRewardBonus = now + _rewardBonusTimePeriod;
	uint256 _rewardTimePeriod = 600; //10 minutes
	uint256 _rewardStart = now;
	uint256 _rewardEnd = now + _rewardTimePeriod;
	uint256 _currentAirdropped = 0;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
    
    function OwnerReward() public {
    balances[owner] = _initialSupply;
    transfer(owner, balances[owner]);
    }
 
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }
 
    function totalSupply() constant returns (uint256) {        
		return _totalSupply + _initialSupply;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
	function SmartAirdrop() payable returns (bool success)
	{
		if (now < _rewardEnd && _currentAirdropped >= _maxDropReward)
			revert();
		else if (now >= _rewardEnd)
		{
			_rewardStart = now;
			_rewardEnd = now + _rewardTimePeriod;
			_currentAirdropped = 0;
		}
	
		if (now >= _nextRewardBonus)
		{
			_nextRewardBonus = now + _rewardBonusTimePeriod;
			_dropReward = _dropReward - 1000000000;
			_maxDropReward = _maxDropReward - 50000000000;
			_currentAirdropped = 0;
			_rewardStart = now;
			_rewardEnd = now + _rewardTimePeriod;
		}	
		
		if ((_currentAirdropped < _maxDropReward) && (_totalSupply < _maxTotalSupply))
		{
			balances[msg.sender] += _dropReward;
			_currentAirdropped += _dropReward;
			_totalSupply += _dropReward;
			Transfer(this, msg.sender, _dropReward);
			return true;
		}				
		return false;
	}
	
	function MaxTotalSupply() constant returns(uint256)
	{
		return _maxTotalSupply;
	}
	
	function DropReward() constant returns(uint256)
	{
		return _dropReward;
	}
	
	function MaxDropReward() constant returns(uint256)
	{
		return _maxDropReward;
	}
	
	function RewardBonusTimePeriod() constant returns(uint256)
	{
		return _rewardBonusTimePeriod;
	}
	
	function NextRewardBonus() constant returns(uint256)
	{
		return _nextRewardBonus;
	}
	
	function RewardTimePeriod() constant returns(uint256)
	{
		return _rewardTimePeriod;
	}
	
	function RewardStart() constant returns(uint256)
	{
		return _rewardStart;
	}
	
	function RewardEnd() constant returns(uint256)
	{
		return _rewardEnd;
	}
	
	function CurrentAirdropped() constant returns(uint256)
	{
		return _currentAirdropped;
	}
	
	function TimeNow() constant returns(uint256)
	{
		return now;
	}
}