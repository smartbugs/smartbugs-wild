pragma solidity ^0.4.13;
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract WTE is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="WITEE";
	string public constant symbol="WTE";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;



	uint256 public constant MAX_PRIVATE_FUNDING_SUPPLY=648000000*10**decimals;


	uint256 public constant COOPERATE_REWARD=270000000*10**decimals;


	uint256 public constant ADVISOR_REWARD=90000000*10**decimals;


	uint256 public constant COMMON_WITHDRAW_SUPPLY=MAX_PRIVATE_FUNDING_SUPPLY+COOPERATE_REWARD+ADVISOR_REWARD;


	uint256 public constant PARTNER_SUPPLY=270000000*10**decimals;


	
	uint256 public constant MAX_PUBLIC_FUNDING_SUPPLY=180000000*10**decimals;

	
	uint256 public constant TEAM_KEEPING=342000000*10**decimals;

	
	uint256 public constant MAX_SUPPLY=COMMON_WITHDRAW_SUPPLY+PARTNER_SUPPLY+MAX_PUBLIC_FUNDING_SUPPLY+TEAM_KEEPING;


	uint256 public rate;


	mapping(address=>uint256) public publicFundingWhiteList;

	mapping(address=>uint256) public  userPublicFundingEthCountMap;

	uint256 public publicFundingPersonalEthLimit;


	uint256 public totalCommonWithdrawSupply;

	uint256 public totalPartnerWithdrawSupply;


	uint256 public totalPublicFundingSupply;

	bool public hasTeamKeepingWithdraw;


	uint256 public startTime;
	uint256 public endTime;
	

    struct epoch  {
        uint256 lockEndTime;
        uint256 lockAmount;
    }

    mapping(address=>epoch[]) public lockEpochsMap;
	 

    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function WTE(){
		totalSupply = 0 ;
		totalCommonWithdrawSupply=0;
		totalPartnerWithdrawSupply=0;
		totalPublicFundingSupply = 0;
		hasTeamKeepingWithdraw=false;


		startTime = 1525104000;
		endTime = 1525104000;
		rate=18300;
		publicFundingPersonalEthLimit = 10000000000000000000;
	}

	event CreateWTE(address indexed _to, uint256 _value);


	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachPublicFundingSupply(uint256 _value,uint256 _rate){
		assert(MAX_PUBLIC_FUNDING_SUPPLY>=totalPublicFundingSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachCommonWithdrawSupply(uint256 _value,uint256 _rate){
		assert(COMMON_WITHDRAW_SUPPLY>=totalCommonWithdrawSupply.add(_value.mul(_rate)));
		_;
	}


	modifier notReachPartnerWithdrawSupply(uint256 _value,uint256 _rate){
		assert(PARTNER_SUPPLY>=totalPartnerWithdrawSupply.add(_value.mul(_rate)));
		_;
	}


	modifier assertFalse(bool withdrawStatus){
		assert(!withdrawStatus);
		_;
	}

	modifier notBeforeTime(uint256 targetTime){
		assert(now>targetTime);
		_;
	}

	modifier notAfterTime(uint256 targetTime){
		assert(now<=targetTime);
		_;
	}

	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}



	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateWTE(receiver,amount);
		Transfer(0x0, receiver, amount);
	}



	function commonWithdraw(uint256 _value) external
		onlyOwner
		notReachCommonWithdrawSupply(_value,1)

	{
		processFunding(msg.sender,_value,1);

		totalCommonWithdrawSupply=totalCommonWithdrawSupply.add(_value);
	}



	function withdrawToTeam() external
		onlyOwner
		assertFalse(hasTeamKeepingWithdraw)
		notBeforeTime(1545753600)
	{
		processFunding(msg.sender,TEAM_KEEPING,1);
		hasTeamKeepingWithdraw = true;
	}


	function withdrawToPartner(address _to,uint256 _value) external
		onlyOwner
		notReachPartnerWithdrawSupply(_value,1)
	{
		processFunding(_to,_value,1);
		totalPartnerWithdrawSupply=totalPartnerWithdrawSupply.add(_value);
		lockBalance(_to,_value,1528473600);
	}


	function () payable external
		notBeforeTime(startTime)
		notAfterTime(endTime)
		notReachPublicFundingSupply(msg.value,rate)
	{
		require(publicFundingWhiteList[msg.sender]==1);
		require(userPublicFundingEthCountMap[msg.sender].add(msg.value)<=publicFundingPersonalEthLimit);

		processFunding(msg.sender,msg.value,rate);

		uint256 amount=msg.value.mul(rate);
		totalPublicFundingSupply = totalPublicFundingSupply.add(amount);

		userPublicFundingEthCountMap[msg.sender] = userPublicFundingEthCountMap[msg.sender].add(msg.value);
	}



  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));

		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance=needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[msg.sender].sub(_value)>=needLockBalance);

		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public constant returns (uint256 balance) 
  	{
		return balances[_owner];
  	}


  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));

		epoch[] epochs = lockEpochsMap[_from];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance = needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[_from].sub(_value)>=needLockBalance);

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}



	function lockBalance(address user, uint256 lockAmount,uint256 lockEndTime) internal
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.push(epoch(lockEndTime,lockAmount));
	}

    function addPublicFundingWhiteList(address[] _list) external
    	onlyOwner
    {
        uint256 count = _list.length;
        for (uint256 i = 0; i < count; i++) {
        	publicFundingWhiteList[_list [i]] = 1;
        }    	
    }

	function refreshRate(uint256 _rate) external
		onlyOwner
	{
		rate=_rate;
	}
	
    function refreshPublicFundingTime(uint256 _startTime,uint256 _endTime) external
        onlyOwner
    {
		startTime=_startTime;
		endTime=_endTime;
    }

    function refreshPublicFundingPersonalEthLimit (uint256 _publicFundingPersonalEthLimit)  external
    	onlyOwner
    {
    	publicFundingPersonalEthLimit=_publicFundingPersonalEthLimit;
    }

	  
}