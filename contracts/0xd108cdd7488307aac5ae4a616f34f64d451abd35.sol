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
contract CCMToken is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="Chain cell matrix";
	string public symbol;
	string public constant version = "1.0";
	uint256 public constant decimals = 18;

	//总发行30亿
	uint256 public constant MAX_SUPPLY=3000000000*10**decimals;

	//投资人持有1.2亿
	uint256 public constant PARTNER_SUPPLY=120000000*10**decimals;
	//已经分配给投资人的份额
	uint256 public totalPartnerSupply;

	//私募9亿
	uint256 public constant MAX_FUNDING_SUPPLY=900000000*10**decimals;
	//私募比例，按eth 3000来算，1:75000的兑换比例，私募价为0.04
	uint256 public rate;
	//已经私募量
	uint256 public totalFundingSupply;

	//团队奖励5.4亿
	uint256 public constant TEAM_KEEPING=540000000*10**decimals;
	bool public hasTeamKeepingWithdraw;

	//1年解禁
	uint256 public constant ONE_YEAR_KEEPING=432000000*10**decimals;
	bool public hasOneYearWithdraw;

	//2年解禁
	uint256 public constant TWO_YEAR_KEEPING=432000000*10**decimals;
	bool public hasTwoYearWithdraw;

	//3年解禁
	uint256 public constant THREE_YEAR_KEEPING=576000000*10**decimals;	
	bool public hasThreeYearWithdraw;

	//私募开始结束时间
	uint256 public startBlock;
	uint256 public endBlock;
	

	//各个用户的锁仓金额
	mapping(address=>uint256) public lockBalance;
	//锁仓百分比
	uint256 public lockRate;


	 
	//ERC20的余额
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function CCMToken(){
		totalSupply = 0 ;
		totalFundingSupply = 0;
		totalPartnerSupply= 0;

		hasTeamKeepingWithdraw=false;
		hasOneYearWithdraw=false;
		hasTwoYearWithdraw=false;
		hasThreeYearWithdraw=false;

		startBlock = 4000000;
		endBlock = 5000000;
		lockRate=100;
		rate=75000;
		symbol="CCM";
	}

	event CreateCCM(address indexed _to, uint256 _value);

	modifier beforeBlock(uint256 _blockNum){
		assert(getCurrentBlockNum()<_blockNum);
		_;
	}

	modifier afterBlock(uint256 _blockNum){
		assert(getCurrentBlockNum()>=_blockNum);
		_;
	}

	modifier notReachTotalSupply(uint256 _value,uint256 _rate){
		assert(MAX_SUPPLY>=totalSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachFundingSupply(uint256 _value,uint256 _rate){
		assert(MAX_FUNDING_SUPPLY>=totalFundingSupply.add(_value.mul(_rate)));
		_;
	}

	modifier notReachPartnerWithdrawSupply(uint256 _value,uint256 _rate){
		assert(PARTNER_SUPPLY>=totalPartnerSupply.add(_value.mul(_rate)));
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


	//owner有权限提取账户中的eth
	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}


	//代币分发函数，内部使用
	function processFunding(address receiver,uint256 _value,uint256 _rate) internal
		notReachTotalSupply(_value,_rate)
	{
		uint256 amount=_value.mul(_rate);
		totalSupply=totalSupply.add(amount);
		balances[receiver] +=amount;
		CreateCCM(receiver,amount);
		Transfer(0x0, receiver, amount);
	}



	//分配代币给股东
	function withdrawToPartner(address partnerAddress,uint256 _value) external
		onlyOwner
		notReachPartnerWithdrawSupply(_value,1)

	{
		processFunding(partnerAddress,_value,1);
		//增加股东已分配份额
		totalPartnerSupply=totalPartnerSupply.add(_value);

		//股东要锁仓，记录锁仓份额
		lockBalance[partnerAddress]=lockBalance[partnerAddress].add(_value);
	}

	//私募，不超过最大私募份额,要在私募时间内
	function () payable external
		afterBlock(startBlock)
		beforeBlock(endBlock)
		notReachFundingSupply(msg.value,rate)
	{
		processFunding(msg.sender,msg.value,rate);
		//增加已私募份额
		uint256 amount=msg.value.mul(rate);
		totalFundingSupply = totalFundingSupply.add(amount);

		//私募的用户，都要锁仓，记录锁仓份额
		lockBalance[msg.sender]=lockBalance[msg.sender].add(amount);
	}



	//团队提币，提到owner账户，只有未提过才能提
	function withdrawToTeam() external
		onlyOwner
		assertFalse(hasTeamKeepingWithdraw)
	{
		processFunding(msg.sender,TEAM_KEEPING,1);
		//标记团队已提现
		hasTeamKeepingWithdraw = true;
	}

	//一年解禁，提到owner账户，只有未提过才能提 ,
	function withdrawForOneYear() external
		onlyOwner
		assertFalse(hasOneYearWithdraw)
		notBeforeTime(1514736000)
	{
		processFunding(msg.sender,ONE_YEAR_KEEPING,1);
		//标记团队已提现
		hasOneYearWithdraw = true;
	}

	//两年解禁，提到owner账户，只有未提过才能提
	function withdrawForTwoYear() external
		onlyOwner
		assertFalse(hasTwoYearWithdraw)
		notBeforeTime(1546272000)
	{
		processFunding(msg.sender,TWO_YEAR_KEEPING,1);
		//标记团队已提现
		hasTwoYearWithdraw = true;
	}

	//三年解禁，提到owner账户，只有未提过才能提
	function withdrawForThreeYear() external
		onlyOwner
		assertFalse(hasThreeYearWithdraw)
		notBeforeTime(1577808000)
	{
		processFunding(msg.sender,THREE_YEAR_KEEPING,1);
		//标记团队已提现
		hasThreeYearWithdraw = true;
	}


  //转账前，先校验减去转出份额后，是否大于等于锁仓份额
  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));
		require(balances[msg.sender].sub(_value)>=lockBalance[msg.sender].mul(lockRate).div(100));
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


  //从委托人账上转出份额时，还要判断委托人的余额-转出份额是否大于等于锁仓份额
  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));
		require(balances[_from].sub(_value)>=lockBalance[_from].mul(lockRate).div(100));
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

	function getCurrentBlockNum() internal returns (uint256)
	{
		return block.number;
	}


	function setSymbol(string _symbol) external
		onlyOwner
	{
		symbol=_symbol;
	}


	function setRate(uint256 _rate) external
		onlyOwner
	{
		rate=_rate;
	}

	function setLockRate(uint256 _lockRate) external
		onlyOwner
	{
		lockRate=_lockRate;
	}
	
    function setupFundingInfo(uint256 _startBlock,uint256 _endBlock) external
        onlyOwner
    {
		startBlock=_startBlock;
		endBlock=_endBlock;
    }
	  
}