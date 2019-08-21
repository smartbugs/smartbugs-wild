pragma solidity ^ 0.4.24;

// ----------------------------------------------------------------------------
// 安全的加减乘除
// ----------------------------------------------------------------------------
library SafeMath {
	function add(uint a, uint b) internal pure returns(uint c) {
		c = a + b;
		require(c >= a);
	}

	function sub(uint a, uint b) internal pure returns(uint c) {
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns(uint c) {
		require(b > 0);
		c = a / b;
	}
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
	function totalSupply() public constant returns(uint);

	function balanceOf(address tokenOwner) public constant returns(uint balance);

	function allowance(address tokenOwner, address spender) public constant returns(uint remaining);

	function transfer(address to, uint tokens) public returns(bool success);

	function approve(address spender, uint tokens) public returns(bool success);

	function transferFrom(address from, address to, uint tokens) public returns(bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// 核心类
// ----------------------------------------------------------------------------
contract MT is ERC20Interface{
	using SafeMath for uint;
	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;//总发行
	uint public sysusermoney;//流通 
	uint public sysoutmoney;//矿池 

	uint public sellPrice; //出售价格 1枚代币换多少以太 /1000
	uint public buyPrice; //购买价格 多少以太可购买1枚代币 /1000
	uint public sysPer; //挖矿的增量百分比 /2%
	uint public sysPrice1; //挖矿的衡量值10000
	uint public sysPrice2; //挖矿的衡量值100000
	uint public sysPrice3; //挖矿的衡量值300000
	uint public sysPrice4; //挖矿的衡量值500000
	uint public sysPer1; //挖矿的增量百分比 /3%
	uint public sysPer2; //挖矿的增量百分比 /4%
	uint public sysPer3; //挖矿的增量百分比 /5%
	uint public sysPer4; //挖矿的增量百分比 /6%
	uint public systime1;//120
	uint public systime2;//240
	uint public systime3;//360
	uint public systime4;//720
	
	uint public outper1;//退出锁仓20
	uint public outper2;//退出锁仓30
	uint public outper3;//退出锁仓40
	uint public outper4;//退出锁仓50
	
	uint public transper; //转账手续费 /3%
	
	bool public actived;
	uint public onceAddTime; //挖矿的时间 10 days
	uint public upper1;//团队奖% 
	uint public upper2;//团队奖% 
	uint public upper3;//团队奖%
	uint public upper4;//团队奖%
	uint public upper5;//团队奖%
	uint public upper6;//团队奖%
	uint public teamper1;//团队奖% 
	uint public teamper2;//团队奖% 
	
	uint public sellper;//15
    uint public sysminteth;
    uint public hasoutmony;
    uint public hasbuymoney;
    uint public hassellmoney;
    uint public hasbuyeth;
    uint public hasselleth;
	mapping(address => uint) balances;//总计
	mapping(address => uint) myeth;//本金
	mapping(address => uint) froeth;//冻结
	//mapping(address => uint) used;
	mapping(address => mapping(address => uint)) allowed;

	/* 冻结账户 */
	mapping(address => bool) public frozenAccount;

	//上家地址
	mapping(address => address) public fromaddr;
	//管理员帐号
	mapping(address => bool) public admins;
	// 记录各个账户的增量时间
	mapping(address => uint) public crontime;
	// 挖矿次数
	mapping(address => uint) public mintnum;
	uint[] public permans;
	mapping(address => uint) public teamget;
	struct sunsdata{
	    uint n1;
	    uint n2;
	    uint n3;
	    uint n4;
	    uint n5;
	    uint n6;
	    uint getmoney;
	}
    mapping(address => sunsdata) public suns;
    address public intertoken;
    modifier onlyInterface {
        require(intertoken != address(0));
		require(msg.sender == intertoken);
		_;
	}
	/* 通知 */
	event FrozenFunds(address target, bool frozen);
	address public owner;
	address public financer;
    modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	modifier  onlyFinancer {
		require(msg.sender == financer);
		_;
	}
	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	constructor() public {

		symbol = "MToken";
		name = "MToken";
		decimals = 18;
		_totalSupply = 5000000000 ether;//总发行
		sysusermoney = 2500000000 ether;//流通
		sysoutmoney  = 2500000000 ether;//矿池

		sellPrice = 7251 ether; //出售价格 1mt can buy how much eth
		buyPrice = 7251 ether; //购买价格 1eth can buy how much mt
		
		//sysPrice1 = 3 ether;//test
		sysPer  = 2; //挖矿的增量百分比 /100
		sysPer1 = 3; //挖矿的增量百分比 /100
		sysPer2 = 4; //挖矿的增量百分比 /100
		sysPer3 = 5; //挖矿的增量百分比 /100
		sysPer4 = 6; //挖矿的增量百分比 /100
		
		sysPrice1 = 10000 ether; //挖矿的衡量值
		sysPrice2 = 100000 ether; //挖矿的衡量值
		sysPrice3 = 300000 ether; //挖矿的衡量值
		sysPrice4 = 500000 ether; //挖矿的衡量值
		
		transper = 3;//转账手续费 /100
		upper1 = 10;//第1代挖矿分润
		upper2 = 7;//第2代挖矿分润
		upper3 = 6;//第2代挖矿分润
		upper4 = 5;//第2代挖矿分润
		upper5 = 4;//第2代挖矿分润
		upper6 = 3;//第2代挖矿分润
		teamper1 = 10;//团队奖% /100
		teamper2 = 20;//团队奖% /100
		outper1 = 80;//退出锁仓 /100
		outper2 = 70;//退出锁仓 /100
		outper3 = 60;//退出锁仓 /100
		outper4 = 60;//退出锁仓 /100
		sellper = 85;// /100
		actived = true;
		onceAddTime = 10 days; //挖矿的时间 正式
		//onceAddTime = 60 seconds;//test
        systime1 = 13;
        systime2 = 25;
        systime3 = 37;
        systime4 = 73;
        permans = [40,20,12,6];
        //permans = [3,3,2,2];//test
		balances[this] = _totalSupply;
		owner = msg.sender;
		financer = msg.sender;
		emit Transfer(address(0), owner, _totalSupply);

	}

	/* 获取用户金额 */
	function balanceOf(address user) public view returns(uint balance) {
		return balances[user];
	}
	function ethbalance(address user) public view returns(uint balance) {
		return user.balance;
	}
    function addcrontime(address addr) private{
        if(crontime[addr] < now) {
            crontime[addr] = now + onceAddTime;
        }
        
    }
    function addusertime(address addr) private{
        if(balances[addr] < 2) {
            addcrontime(addr);
        }
    }
	/*
	 * 获取用户的挖矿时间
	 * @param {Object} address
	 */
	function getaddtime(address _addr) public view returns(uint) {
		if(crontime[_addr] < 2) {
			return(0);
		}else{
		    return(crontime[_addr]);
		}
		
	}
	function getmy(address user) public view returns(
	    uint myblance,
	    uint meth,
	    uint myeths,
	    uint mypro,
	    uint mytime,
	    uint bprice,
	    uint tmoney,
	    uint myall
	){
	    myblance = balances[user];//0
	    meth = address(user).balance;//2
	    myeths = myeth[user];//3
	    mypro = froeth[user];//4
	    mytime = crontime[user];//5
	    bprice = buyPrice;//6
	    tmoney = balances[this];//9
	    myall = myblance.add(mypro);//10
	}
	function geteam(address user) public view returns(
	    uint nn1,//0
	    uint nn2,//1
	    uint nn3,//2
	    uint nn4,//3
	    uint nn5,//4
	    uint nn6,//5
	    uint ms,//6
	    uint tm,//7
	    uint mintmoneys,//8
	    uint usermoneys,//9
	    uint fromoneys,//10
	    uint lid//11
	){
	    nn1 = suns[user].n1;
	    nn2 = suns[user].n2;
	    nn3 = suns[user].n3;
	    nn4 = suns[user].n4;
	    nn5 = suns[user].n5;
	    nn6 = suns[user].n6;
	    ms = teamget[user];
	    tm = getaddtime(user);
	    mintmoneys = sysoutmoney;
	    usermoneys = sysusermoney;
	    fromoneys = sysminteth;
	    if(suns[user].n2 >= permans[2] && suns[user].n1 >= permans[3]){
	        lid = 1;
	    }
	    if(suns[user].n2 >= permans[0] && suns[user].n1 >= permans[1]){
	        lid = 2;
	    }
	}
	function getsys() public view returns(
	    uint tmoney,//0
	    uint outm,//1
	    uint um,//2
	    uint from,//3
	    uint hasout,//4
	    uint hasbuy,//5
	    uint hassell,//6
	    uint hasbuyeths,//9
	    uint hasselleths//10
	){
	    tmoney = _totalSupply.sub(balances[this]);
	    outm = sysoutmoney;
	    um = sysusermoney;
	    from = sysminteth;
	    hasout = hasoutmony;
	    hasbuy = hasbuymoney;
	    hassell = hassellmoney;
	    hasbuyeths = hasbuyeth;
	    hasselleths = hasselleth;
	}
    function _transfer(address from, address to, uint tokens) private returns(bool success) {
        require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(actived == true);
		uint addper = tokens*transper/100;
		uint allmoney = tokens + addper;
		require(balances[from] >= allmoney);
		require(tokens > 1 && tokens < _totalSupply);
		// 防止转移到0x0， 用burn代替这个功能
        require(to != 0x0);
		require(from != to);
		// 将此保存为将来的断言， 函数最后会有一个检验103 - 3 + 10
        uint previousBalances = balances[from] - addper + balances[to];
		//如果用户没有上家
		if(fromaddr[to] == address(0) && fromaddr[from] != to) {
			//指定上家地址
			fromaddr[to] = from;
			suns[from].n1++;
			address top = fromaddr[from];
			if(top != address(0)) {
			    suns[top].n2++;
			    top = fromaddr[top];
			    if(top != address(0)) {
    			    suns[top].n3++;
    			    top = fromaddr[top];
    			    if(top != address(0)) {
        			    suns[top].n4++;
        			    top = fromaddr[top];
        			    if(top != address(0)) {
            			    suns[top].n5++;
            			    top = fromaddr[top];
            			    if(top != address(0)) {
                			    suns[top].n6++;
                			}
            			}
        			}
    			}
			}
		} 
		
		balances[from] = balances[from].sub(allmoney);
		if(balances[from] < myeth[from]) {
		    myeth[from] = balances[from];
		}
		balances[this] = balances[this].add(addper);
		balances[to] = balances[to].add(tokens);
		myeth[to] = myeth[to].add(tokens);
		addcrontime(to);
		emit Transfer(from, this, addper);
		emit Transfer(from, to, tokens);
		// 断言检测， 不应该为错
        assert(balances[from] + balances[to] == previousBalances);//90 10
		return true;
    }
	/*
	 * 用户转账
	 * @param {Object} address
	 */
	function transfer(address to, uint tokens) public returns(bool success) {
		_transfer(msg.sender, to, tokens);
		success = true;
	}
    function intertransfer(address from, address to, uint tokens) public onlyInterface returns(bool success) {
		_transfer(from, to, tokens);
		success = true;
	}
	/*
	 * 获取上家地址
	 * @param {Object} address
	 */
	function getfrom(address _addr) public view returns(address) {
		return(fromaddr[_addr]);
	}

	function approve(address spender, uint tokens) public returns(bool success) {
	    require(tokens > 1 && tokens < _totalSupply);
	    require(balances[msg.sender] >= tokens);
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	/*
	 * 授权转账
	 * @param {Object} address
	 */
	function transferFrom(address from, address to, uint tokens) public returns(bool success) {
		require(actived == true);
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(tokens > 1 && tokens < _totalSupply);
		require(balances[from] >= tokens);
		balances[from] = balances[from].sub(tokens);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);
		emit Transfer(from, to, tokens);
		return true;
	}

	/*
	 * 获取授权信息
	 * @param {Object} address
	 */
	function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
		return allowed[tokenOwner][spender];
	}



	/// 冻结 or 解冻账户
	function freezeAccount(address target, bool freeze) public onlyOwner{
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	
	/*
	 * 系统设置
	 * @param {Object} uint
	 	
	 */
	function setconf(
    	uint systyPrice1, 
    	uint systyPrice2, 
    	uint systyPrice3, 
    	uint systyPrice4, 
    	uint sysPermit1,
    	uint sysPermit2,
    	uint sysPermit3,
    	uint sysPermit4,
    	uint systime1s,
    	uint systime2s,
    	uint systime3s,
    	uint systime4s
    ) public onlyOwner{
		sysPrice1 = systyPrice1;
		sysPrice2 = systyPrice2;
		sysPrice3 = systyPrice3;
		sysPrice4 = systyPrice4;
		sysPer1 = sysPermit1;
		sysPer2 = sysPermit2;
		sysPer3 = sysPermit3;
		sysPer4 = sysPermit4;
		systime1 = systime1s + 1;
		systime2 = systime2s + 1;
		systime3 = systime3s + 1;
		systime4 = systime4s + 1;
		
	}
	/*
	 * 获取系统设置
	 */
	function getconf() public view returns(
	    uint systyPrice1, 
    	uint systyPrice2, 
    	uint systyPrice3, 
    	uint systyPrice4, 
    	uint sysPermit1,
    	uint sysPermit2,
    	uint sysPermit3,
    	uint sysPermit4,
    	uint systime1s,
    	uint systime2s,
    	uint systime3s,
    	uint systime4s
	) {
		
		systyPrice1 = sysPrice1;//0
		systyPrice2 = sysPrice2;//1
		systyPrice3 = sysPrice3;//2
		systyPrice4 = sysPrice4;//3
		sysPermit1 = sysPer1;//4
		sysPermit2 = sysPer2;//5
		sysPermit3 = sysPer3;//6
		sysPermit4 = sysPer4;//7
		systime1s = systime1 - 1;//8
		systime2s = systime2 - 1;//9
		systime3s = systime3 - 1;//10
		systime4s = systime4 - 1;//11
		
	}
	
	function setother(
	    uint newonceaddtime, 
    	uint newBuyPrice, 
    	uint newSellPrice, 
    	uint sysPermit,
    	uint transpers,
    	uint sellpers,
	    uint upper1s,
    	uint upper2s,
    	uint upper3s,
    	uint upper4s,
    	uint upper5s,
    	uint upper6s
	) public onlyOwner{
	    onceAddTime = newonceaddtime;
		buyPrice = newBuyPrice;
		sellPrice = newSellPrice;
		sysPer = sysPermit;
		transper = transpers;
		sellper = sellpers;
	    upper1 = upper1s;
		upper2 = upper2s;
		upper3 = upper3s;
		upper4 = upper4s;
		upper5 = upper5s;
		upper6 = upper6s;	
	}
	
	function getother() public view returns(
	    uint newonceaddtime, 
    	uint newBuyPrice, 
    	uint newSellPrice, 
    	uint sysPermit,
    	uint transpers,
    	uint sellpers,
	    uint upper1s,
    	uint upper2s,
    	uint upper3s,
    	uint upper4s,
    	uint upper5s,
    	uint upper6s
	){
	    newonceaddtime = onceAddTime;//0
		newBuyPrice = buyPrice;//1
	    newSellPrice = 	sellPrice;//2
		sysPermit = sysPer;//3
		transpers = transper;//4
		sellpers = sellper;//5
	    upper1s = upper1;//6
		upper2s = upper2;//7
		upper3s = upper3;//8
		upper4s = upper4;//9
		upper5s = upper5;//10
		upper6s = upper6;//11
	}
	function setsysteam(
    	uint outper1s,
    	uint outper2s,
    	uint outper3s,
    	uint outper4s,
    	uint teamper1s,
    	uint teamper2s,
    	uint t1,
    	uint t2,
    	uint t3,
    	uint t4
	) public onlyOwner{
	    outper1 = outper1s;
		outper2 = outper2s;
		outper3 = outper3s;
		outper4 = outper4s;
	    teamper1 = teamper1s;
		teamper2 = teamper2s;
		permans = [t1,t2,t3,t4];
	}
	function getsysteam() public view returns(
	    uint outper1s,
    	uint outper2s,
    	uint outper3s,
    	uint outper4s,
    	uint teamper1s,
    	uint teamper2s,
    	uint t1,
    	uint t2,
    	uint t3,
    	uint t4
	){
	    outper1s = outper1;//0
		outper2s = outper2;//1
		outper3s = outper3;//2
		outper4s = outper4;//3
		teamper1s = teamper1;//4
		teamper2s = teamper2;//5
		t1 = permans[0];//6
		t2 = permans[1];//7
		t3 = permans[2];//8
		t4 = permans[3];//9
	}
	/*
	 * 设置是否开启
	 * @param {Object} bool
	 */
	function setactive(bool tags) public onlyOwner {
		actived = tags;
	}
	function settoken(address tokensaddr) onlyOwner public {
		intertoken = tokensaddr;
	}
	function setadmin(address adminaddr) onlyOwner public {
		owner = adminaddr;
	}
	function setfinancer(address financeraddr) onlyOwner public {
		financer = financeraddr;
	}
	/*
	 * 获取总发行
	 */
	function totalSupply() public view returns(uint) {
		return _totalSupply;
	}
	function addusermoney(address target, uint256 mintedAmount) private{
	    require(!frozenAccount[target]);
		require(actived == true);
        require(balances[this] > mintedAmount);
		balances[target] = balances[target].add(mintedAmount);
		myeth[target] = myeth[target].add(mintedAmount);
		balances[this] = balances[this].sub(mintedAmount);
		sysusermoney = sysusermoney.sub(mintedAmount);
		hasoutmony = hasoutmony.add(mintedAmount);
		addcrontime(target);
		emit Transfer(this, target, mintedAmount);
	}
	function subusermoney(address target, uint256 mintedAmount) private{
	    require(!frozenAccount[target]);
		require(actived == true);
        require(balances[target] > mintedAmount);
		balances[target] = balances[target].sub(mintedAmount);
		if(balances[target] < myeth[target]) {
		    myeth[target] = balances[target];
		}
		balances[this] = balances[this].add(mintedAmount);
		sysusermoney = sysusermoney.add(mintedAmount);
		emit Transfer( target,this, mintedAmount);
	}
	/*
	 * 向指定账户拨发资金
	 * @param {Object} address
	 */
	function adduser(address target, uint256 mintedAmount) public onlyFinancer{
		addusermoney(target, mintedAmount);
	}
	function subuser(address target, uint256 mintedAmount) public onlyFinancer{
		subusermoney(target, mintedAmount);
	}
	function interadduser(address target, uint256 mintedAmount) public onlyInterface{
		addusermoney(target, mintedAmount);
	}
	function intersubuser(address target, uint256 mintedAmount) public onlyInterface{
		subusermoney(target, mintedAmount);
	}
	function mintadd() public{
	    address user = msg.sender;
		require(!frozenAccount[user]);
		require(actived == true);
		require(balances[user] >= sysPrice1);
		froeth[user] = froeth[user].add(balances[user]);
		sysminteth = sysminteth.add(balances[user]);
		emit Transfer(user, this, balances[user]);
		balances[user] = 1;
		myeth[user] = 1;
		if(froeth[user] >= sysPrice4) {
		    mintnum[user] = systime4;
		}
		else if(froeth[user] >= sysPrice3) {
		    mintnum[user] = systime3;
		}
		else if(froeth[user] >= sysPrice2) {
		    mintnum[user] = systime2;
		}else{
		    mintnum[user] = systime1;
		}
		crontime[user] = now + onceAddTime;
		
	}
	function mintsub() public{
	    address user = msg.sender;
		require(!frozenAccount[user]);
		require(actived == true);
		require(mintnum[user] > 1);
		require(froeth[user] >= sysPrice1);
		uint getamount = froeth[user]*outper1/100;
		if(froeth[user] >= sysPrice4) {
		    getamount = froeth[user]*outper4/100;
		}
		else if(froeth[user] >= sysPrice3) {
		    getamount = froeth[user]*outper3/100;
		}
		else if(froeth[user] >= sysPrice2) {
		    getamount = froeth[user]*outper2/100;
		}
		uint addthis = froeth[user].sub(getamount);
		balances[this] = balances[this].add(addthis);
		emit Transfer(user, this, addthis);
		sysminteth = sysminteth.add(uint(1)).sub(froeth[user]);
		froeth[user] = 1;
		mintnum[user] = 1;
		balances[user] = balances[user].add(getamount);
		myeth[user] = myeth[user].add(getamount);
		emit Transfer(this, user, getamount);
		
	}
	function setteam(address user, uint amount) private returns(bool) {
	    if(suns[user].n2 >= permans[2] && suns[user].n1 >= permans[3]){
	        teamget[user] = teamget[user].add(amount);
	        uint chkmoney = sysPrice2;
	        uint sendmoney = teamget[user]*teamper1/100;
	        if(suns[user].n2 >= permans[0] && suns[user].n1 >= permans[1]){
	            chkmoney = sysPrice4;
	            sendmoney = teamget[user]*teamper2/100;
	        }
	        if(teamget[user] >= chkmoney) {
	            require(balances[this] > sendmoney);
	            require(sysoutmoney > sendmoney);
	            suns[user].getmoney = suns[user].getmoney.add(sendmoney);
	            balances[user] = balances[user].add(sendmoney);
	            teamget[user] = 1;
	            balances[this] = balances[this].sub(sendmoney);
		        sysoutmoney = sysoutmoney.sub(sendmoney);
		        sysusermoney = sysusermoney.add(sendmoney);
		        emit Transfer(this, user, sendmoney);
	        }
	        return(true);
	    }
	}
	function settop(address top, uint upmoney) private{
	    require(balances[this] > upmoney);
	    require(sysoutmoney > upmoney);
	    balances[top] = balances[top].add(upmoney);
        balances[this] = balances[this].sub(upmoney);
        sysoutmoney = sysoutmoney.sub(upmoney);
        sysusermoney = sysusermoney.add(upmoney);
        emit Transfer(this, top, upmoney);
        setteam(top, upmoney);
	}
	/*
	 * 用户每隔10天挖矿一次
	 */
	function mint() public {
	    address user = msg.sender;
		require(!frozenAccount[user]);
		require(actived == true);
		require(crontime[user] > 1);
		require(now > crontime[user]);
		uint amount;
		uint usmoney;
		uint mintmoney;
		if(myeth[user] > 1) {
		    usmoney = myeth[user] * sysPer / 100;
		}
		if(froeth[user] >= sysPrice1 && mintnum[user] > 1) {
		    mintmoney = froeth[user] * sysPer1 / 100;
		    if(froeth[user] >= sysPrice4) {
    		    mintmoney = froeth[user] * sysPer4 / 100;
    		}
    		else if(froeth[user] >= sysPrice3) {
    		    mintmoney = froeth[user] * sysPer3 / 100;
    		}
    		else if(froeth[user] >= sysPrice2) {
    		    mintmoney = froeth[user] * sysPer2 / 100;
    		}
		}
		amount = usmoney.add(mintmoney);
		require(balances[this] > amount);
		require(sysoutmoney > amount);
		balances[user] = balances[user].add(amount);
		balances[this] = balances[this].sub(amount);
		sysoutmoney = sysoutmoney.sub(amount);
		sysusermoney = sysusermoney.add(amount);
		crontime[user] = now + onceAddTime;
		
		if(usmoney > 0) {
		    emit Transfer(this, user, usmoney);
		}
		if(mintmoney > 0) {
		    emit Transfer(this, user, mintmoney);
		    mintnum[user]--;
		    if(mintnum[user] < 2) {
		        balances[user] = balances[user].add(froeth[user]);
		        myeth[user] = myeth[user].add(froeth[user]);
		        sysminteth = sysminteth.sub(froeth[user]);
		        emit Transfer(this, user, froeth[user]);
		        froeth[user] = 1; 
		    }
		}
		address top = fromaddr[user];
		
		if(top != address(0) && top != user) { 
		    uint upmoney = amount*upper1/100;
		    settop(top, upmoney);
		    top = fromaddr[top];
		    if(top != address(0) && top != user) {
    		    upmoney = amount*upper2/100;
    		    settop(top, upmoney);
    		    top = fromaddr[top];
    		    if(top != address(0) && top != user) {
        		    upmoney = amount*upper3/100;
        		    settop(top, upmoney);
        		    top = fromaddr[top];
        		    if(top != address(0) && top != user) {
            		    upmoney = amount*upper4/100;
            		    settop(top, upmoney);
            		    top = fromaddr[top];
            		    if(top != address(0) && top != user) {
                		    upmoney = amount*upper5/100;
                		    settop(top, upmoney);
                		    top = fromaddr[top];
                		    if(top != address(0) && top != user) {
                    		    upmoney = amount*upper6/100;
                    		    settop(top, upmoney);
                    		}
                		}
            		}
        		}
        		
    		}
		}
		//emit Transfer(this, user, amount);
		

	}
	/*
	 * 获取总账目
	 */
	function getall() public view returns(uint256 money) {
		money = address(this).balance;
	}
	/*
	 * 购买
	 */
	function buy() public payable returns(uint) {
		require(actived == true);
		address user = msg.sender;
		require(!frozenAccount[user]);
		require(msg.value > 0);
		uint amount = (msg.value * buyPrice)/1 ether;
		require(balances[this] > amount);
		require(amount > 1 && amount < _totalSupply);
		balances[user] = balances[user].add(amount);
		myeth[user] = myeth[user].add(amount);
		balances[this] = balances[this].sub(amount);
		sysusermoney = sysusermoney.sub(amount);
		hasbuymoney = hasbuymoney.add(amount);
		hasbuyeth = hasbuyeth.add(msg.value);
		addcrontime(user);
		owner.transfer(msg.value);
		emit Transfer(this, user, amount);
		return(amount);
	}
	
	/*
	 * 系统充值
	 */
	function charge() public payable returns(bool) {
		return(true);
	}
	
	function() payable public {
		buy();
	}
	/*
	 * 系统提现
	 * @param {Object} address
	 */
	function withdraw(address _to, uint money) public onlyOwner {
		require(actived == true);
		require(!frozenAccount[_to]);
		require(address(this).balance > money);
		require(money > 0);
		_to.transfer(money);
	}
	/*
	 * 出售
	 * @param {Object} uint256
	 */
	function sell(uint256 amount) public returns(bool success) {
		require(actived == true);
		address user = msg.sender;
		require(!frozenAccount[user]);
		require(amount < _totalSupply);
		require(amount > 1);
		require(balances[user] >= amount);
		uint moneys = (amount * sellper * 10 finney)/sellPrice;
		require(address(this).balance > moneys);
		user.transfer(moneys);
		uint previousBalances = balances[user] + balances[this];
		balances[user] = balances[user].sub(amount);
		if(balances[user] < myeth[user]) {
		    myeth[user] = balances[user];
		}
		balances[this] = balances[this].add(amount);
        sysusermoney = sysusermoney.add(amount);
        hassellmoney = hassellmoney.add(amount);
        hasselleth = hasselleth.add(moneys);
		emit Transfer(user, this, amount);
		// 断言检测， 不应该为错
        assert(balances[user] + balances[this] == previousBalances);
		return(true);
	}
	
		/*
	 * 批量发币
	 * @param {Object} address
	 */
	function addBalances(address[] recipients, uint256[] moenys) public onlyOwner{
		uint256 sum = 0;
		for(uint256 i = 0; i < recipients.length; i++) {
			balances[recipients[i]] = balances[recipients[i]].add(moenys[i]);
			sum = sum.add(moenys[i]);
			addusertime(recipients[i]);
			emit Transfer(this, recipients[i], moenys[i]);
		}
		balances[this] = balances[this].sub(sum);
		sysusermoney = sysusermoney.sub(sum);
	}
	/*
	 * 批量减币
	 * @param {Object} address
	 */
	function subBalances(address[] recipients, uint256[] moenys) public onlyOwner{
		uint256 sum = 0;
		for(uint256 i = 0; i < recipients.length; i++) {
			balances[recipients[i]] = balances[recipients[i]].sub(moenys[i]);
			sum = sum.add(moenys[i]);
			emit Transfer(recipients[i], this, moenys[i]);
		}
		balances[this] = balances[this].add(sum);
		sysusermoney = sysusermoney.add(sum);
	}

}