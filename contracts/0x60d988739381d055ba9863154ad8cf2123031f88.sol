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

contract EttToken{
    function tokenAdd(address user,uint tokens) public returns(bool success);
    function tokenSub(address user,uint tokens) public returns(bool success);
    function balanceOf(address tokenOwner) public constant returns(uint balance);
}

// ----------------------------------------------------------------------------
// 核心类
// ----------------------------------------------------------------------------

contract USDT is ERC20Interface{
	using SafeMath for uint;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;//总发行


//	uint public sellPrice; //出售价格 1枚代币换多少以太 /1000
	uint public buyPrice; //购买价格 多少以太可购买1枚代币 /1000

	
	uint public transper; //转账手续费 /3%
	
	bool public actived;

	uint public teamper1;//团队奖% 
	uint public teamper2;//团队奖% 
	
	//uint public sellper;//15
    uint public sysinteth;

	mapping(address => uint) balances;//总计
	//mapping(address => uint) myeth;//本金
//	mapping(address => uint) froeth;//冻结
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
//	mapping(address => uint) public mintnum;
	uint[] public permans;
	mapping(address => uint) public teamget;

	struct sunsdata{
		mapping(uint => uint) n;	
		mapping(uint => uint) n_effective;
	}
	
    mapping(address => sunsdata)  suns;
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
	
	struct record{
			//当前可提现本金
			uint can_draw_capital;
			//当前已投资本金
			uint not_draw_capital;
			//总的应释放利润
			uint total_profit;
			//总的已释放利润
			uint  releasd_profit;
			//投资时间
			uint last_investdate;
			uint history_releasd_profit;
		}
		mapping(address=>record) public user_inverst_record;
		
		struct plan{
			uint account;
			uint times;
		}
		mapping(uint => plan) public plans;
		
		struct node_profit{
				uint menber_counts;
				uint percent;
		}
		mapping(uint => node_profit) public node_profits;
	//	uint public min_investment;
				

		uint  public per;
		uint public OnceWidrawTime;
		mapping(address => bool) _effective_son;
		struct quit_conf{
			uint  interval;
			uint rate1;
			uint rate2;
		}
		quit_conf public quit_config;
		uint teamPrice1;
		uint teamPrice2;
		
        mapping(address=>bool) public isleader;
        mapping(address =>uint) public leader_eth;
        
        mapping(address=>uint) public userineth;
		address [] public leaders;
		EttToken public ett;
		uint public ettRate;
		uint generation;
		uint generation_team;
		mapping(address=>address) public ethtop;
	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	constructor(EttToken _ettAddress,address [] _supernodes) public {

		symbol = "USDT";
		name = "USDT Coin";
		decimals = 18;
		_totalSupply = 1000000000 ether;
		buyPrice = 138 ether; //购买价格 1eth can buy how much mt
		

		transper = uint(0);//转账手续费 /100

		teamper1 = 10;//团队奖% /100
		teamper2 = 20;//团队奖% /100

		//sellper = 85;// /100
		actived = true;


        permans = [40,10,12,6];
        //permans = [3,3,2,2];//test
		balances[this] = _totalSupply;
		owner = msg.sender;
		financer = msg.sender;
		
        
		per = 1;
		plans[1].account = 7000 ether;
		plans[1].times = 2 ;
		plans[2].account = 35000 ether;
		plans[2].times = 3 ;
		plans[3].account = 70000 ether;
		plans[3].times = 4 ;
		plans[4].account = 210000 ether;
		plans[4].times = 5 ;
	
		for(uint i=1;i<=16;i++){
			node_profits[i].menber_counts = i;
			if(i==1){
				node_profits[i].percent = 100;
			}else if(i==2){
				node_profits[i].percent = 20;
			}else if(i==3){
				node_profits[i].percent = 15;
			}else if(i == 4){
				node_profits[i].percent = 10;
			}else{
				node_profits[i].percent = 5;
			}
		}
		
		OnceWidrawTime = 24 hours;
		//OnceWidrawTime = 10 seconds;
		//min_investment = plans[1].account ;
		//quit_config.interval = 30 days
		//quit_config.interval = 30 seconds;
		quit_config.interval = 30 days;
		quit_config.rate1 = 5;
		quit_config.rate2 = 1;
		teamPrice1 = 100000 ether;
		teamPrice2 = 500000 ether;
		ettRate = 70 ether;
		generation = 16;
		generation_team = 8;
		ett = _ettAddress;
		for(uint m;m<_supernodes.length;m++){
		    addLeader(_supernodes[m]);
		}
		
		emit Transfer(address(0), owner, _totalSupply);

	}

	/* 获取用户金额 */
	function balanceOf(address user) public view returns(uint balance) {
		return balances[user];
	}
	function ethbalance(address user) public view returns(uint _balance) {
	    
		_balance = address(user).balance;
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
	    uint mytime,
	    uint bprice,
	    uint tmoney,
	    uint myineth,
	    bool _isleader,
	    uint _leader_eth,
	    uint [10] _inverst
	    /*
	    uint _can_draw_capital,
	    uint _not_draw_capital,
	    uint _last_investdate,
	    uint _total_profit,
	    uint _releasd_profit,
	    uint _history_releasd_profit
	    */
	){
	    address _user = user;
	    myblance = balances[_user];//0
	    meth = ethbalance(_user);//2
	    mytime = crontime[_user];//5
	    bprice = buyPrice;//6
	    tmoney = balances[this];//9
	    myineth = userineth[_user];
	    _isleader = isleader[_user];
	    _leader_eth = leader_eth[_user];
	    
	    _inverst[0]=user_inverst_record[_user].can_draw_capital;
	    _inverst[1]=user_inverst_record[_user].last_investdate;
	    _inverst[2]=user_inverst_record[_user].not_draw_capital;
	    _inverst[3]=user_inverst_record[_user].total_profit;
	    _inverst[4]=user_inverst_record[_user].releasd_profit;
	    _inverst[5] = user_inverst_record[_user].history_releasd_profit;
	    _inverst[6] = ethbalance(_user);
	    _inverst[7] = getquitfee(_user);
	    _inverst[8] = ettRate;
	    _inverst[9] = getettbalance(_user);
	    /*
	    _can_draw_capital=user_inverst_record[_user].can_draw_capital;
	    _last_investdate=user_inverst_record[_user].last_investdate;
	    _not_draw_capital=user_inverst_record[_user].not_draw_capital;
	    _total_profit=user_inverst_record[_user].total_profit;
	    _releasd_profit=user_inverst_record[_user].releasd_profit;
	    _history_releasd_profit = user_inverst_record[_user].history_releasd_profit;
	    */
	}
	
	function setRwardGeneration(uint _generation,uint _generation_team) public onlyOwner returns(bool){
	    if(_generation_team>1&&_generation>1&&_generation<=16){
	        generation = _generation;
	        generation_team = _generation_team;
	        return true;
	    }else{
	        return false;
	    }
	}
	
	function getRwardGeneration() public view onlyOwner returns(uint _generation,uint _generation_team){
	    _generation = generation;
	    _generation_team = generation_team;
	}
	
	function geteam(address _user) public view returns(
	    
	    uint nn1,//0
	    uint nn2,//1
	    uint n_effective1,
	    uint n_effective2,
	    
	    uint [16]  n,
	    uint [16] n_effective,
	    uint ms,//6
	    uint tm,//7
	    uint lid//11
	){
	    
	    nn1 = suns[_user].n[1];
	    nn2 = suns[_user].n[2];
	    n_effective1 = suns[_user].n_effective[1];
	    n_effective2 = suns[_user].n_effective[2];
        
        for(uint i;i<16;i++){
            
            n[i] = suns[_user].n[i+1];
            n_effective[i] = suns[_user].n_effective[i+1];
        }
	    ms = teamget[_user];
	    tm = getaddtime(_user);


	    if(suns[_user].n_effective[2] >= permans[2] && suns[_user].n_effective[1] >= permans[3]){
	        lid = 1;
	    }
	    if(suns[_user].n_effective[2] >= permans[0] && suns[_user].n_effective[1] >= permans[1]){
	        lid = 2;
	    }
	}
	
	

	function getsys() public view returns(
	    uint tmoney,//0
	    uint _sysinteth
	   
	){
	    tmoney = _totalSupply.sub(balances[this]);
	    _sysinteth = sysinteth;
	    
	}
    function _transfer(address from, address to, uint tokens) private returns(bool success) {
        require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(actived == true);
		
		uint addper = tokens*transper/100;

		uint allmoney = tokens + addper;
		require(balances[from] >= allmoney);
		require(tokens > 0 && tokens < _totalSupply);
		// 防止转移到0x0， 用burn代替这个功能
        require(to != 0x0);
		require(from != to);
		// 将此保存为将来的断言， 函数最后会有一个检验103 - 3 + 10
        uint previousBalances = balances[from] - addper + balances[to];
		//如果用户没有上家
		if(fromaddr[to] == address(0) && fromaddr[from] != to) {
			//指定上家地址
			fromaddr[to] = from;
			address top = fromaddr[to];
			
			
			if(isleader[ethtop[top]]){
			    ethtop[to] = ethtop[top];
			}
			if(isleader[top] ){
			    ethtop[to] = top;
			}
			
			
			address _to = to;
			for(uint i = 1;i<=16;i++){
				if(top != address(0) && top !=_to){
					suns[top].n[i] += 1;
					_to = top;
					top = fromaddr[top];
					
					continue;
				}else{
				    break;    
				}
				
			}
			
		} 
		
		balances[from] = balances[from].sub(allmoney);
		balances[this] = balances[this].add(addper);
		balances[to] = balances[to].add(tokens);
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
    	uint _per,
    	uint _newOnceWidrawTime, 
    	uint _newBuyPrice,
    	uint _ettRate
    ) public onlyOwner{
        require(_per>0);
        require(ettRate>0);
		per = _per;
		OnceWidrawTime = _newOnceWidrawTime;
		buyPrice = _newBuyPrice;
		ettRate = _ettRate;
	}
	
	
	// * 获取系统设置
	 
	function getconf() public view returns(
	    uint _per,
	    uint _newOnceWidrawTime, 
    	uint _newBuyPrice,
    	uint _ettRate) 
    {
		 _per = per;
		 _newOnceWidrawTime = OnceWidrawTime;
		 _newBuyPrice = buyPrice;
		 _ettRate = ettRate;
	}
	
	function setother(
    	uint _transper,
    	uint _quit_interval,
    	uint _quit_rate1,
    	uint _quit_rate2
	) public onlyOwner{
	    transper = _transper;
		quit_config = quit_conf(_quit_interval,_quit_rate1,_quit_rate2);
	}
	
	function getquitfee(address _user) public view returns(uint ){
	    uint _fee;
	    //require(actived == true&&!frozenAccount[msg.sender]);
		if (user_inverst_record[_user].can_draw_capital > 0){
		    uint interval = now.sub(user_inverst_record[_user].last_investdate);
		    uint rate = quit_config.rate2;
		    if(interval<quit_config.interval){
			    rate = quit_config.rate1;
		    }
		    uint fee = user_inverst_record[_user].can_draw_capital*rate/100;
		}
		_fee = fee;
		return _fee;

	}
	
	function getother() public view returns(
	    uint _onceWidrawTime, 
    	uint newBuyPrice,
    	uint _transper,
    	uint _quit_interval,
    	uint _quit_rate1,
    	uint _quit_rate2
	){
	    _onceWidrawTime = OnceWidrawTime;//0
		newBuyPrice = buyPrice;//1
		_transper = transper;
		_quit_interval = quit_config.interval;
		_quit_rate1 = quit_config.rate1;
		_quit_rate2 = quit_config.rate2;
	}
	
	function setNodeProfit(uint _node,uint _members,uint _percert) public  onlyOwner returns(bool){
	    //require(_node<=16&&_node>=1);
	    require(_node>=1);
	    require(_members>0&&_percert>0&&_percert<=100);
	    node_profits[_node] = node_profit(_members,_percert);
	    return true;
	}
	function setPlan(uint _plan,uint _account,uint _times) public onlyOwner returns(bool){
	    require(_plan<=4&&_plan>=1);
	    require(_account>0&&_times>0);
	    plans[_plan] = plan(_account,_times);
	    
	    return true;
	}
	function getPlan(uint _plan) public view returns(uint _account,uint _times){
	    require(_plan>0 && _plan <=4);
	    _account=plans[_plan].account;
	    _times = plans[_plan].times;
	}
	function getNodeProfit(uint _node) public view returns(uint _members,uint _percert){
	    require(_node>0 && _node <=16);
	    _members = node_profits[_node].menber_counts;
	    _percert = node_profits[_node].percent;
	}
	
	function setsysteam(
        uint _newteamPrice1,
        uint _newteamPrice2,
    	uint teamper1s,
    	uint teamper2s,
    	uint t1,
    	uint t2,
    	uint t3,
    	uint t4
	) public onlyOwner{
        teamPrice1=_newteamPrice1;
        teamPrice2=_newteamPrice2;
	    teamper1 = teamper1s;
		teamper2 = teamper2s;
		permans = [t1,t2,t3,t4];
	}
	function getsysteam() public view returns(
        uint teamprice1,
        uint teamprice2,
    	uint teamper1s,
    	uint teamper2s,
    	uint t1,
    	uint t2,
    	uint t3,
    	uint t4
	){
        teamprice1 = teamPrice1;
        teamprice2 = teamPrice2;
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

	function setadmin(address adminaddr) onlyOwner public {
	    require(adminaddr != owner && adminaddr != address(0));
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
		balances[this] = balances[this].sub(mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}
	function subusermoney(address target, uint256 mintedAmount) private{
	    require(!frozenAccount[target]);
		require(actived == true);
        require(balances[target] > mintedAmount);
		balances[target] = balances[target].sub(mintedAmount);
		balances[this] = balances[this].add(mintedAmount);
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
	/*
	function interadduser(address target, uint256 mintedAmount) public onlyInterface{
		addusermoney(target, mintedAmount);
	}
	function intersubuser(address target, uint256 mintedAmount) public onlyInterface{
		subusermoney(target, mintedAmount);
	}
	*/
	
	function setteam(address user, uint amount) private returns(bool) {
		require(amount >0);
		teamget[user] += amount;
	    if(suns[user].n_effective[2] >= permans[2] && suns[user].n_effective[1] >= permans[3]){
	        //teamget[user] += amount;
	        uint chkmoney = teamPrice1;
	        uint sendmoney = teamget[user]*teamper1/100;
	        if(suns[user].n_effective[2] >= permans[0] && suns[user].n_effective[1] >= permans[1]){
	            chkmoney = teamPrice2;
	            sendmoney = teamget[user]*teamper2/100;
	        }
	        if(teamget[user] >= chkmoney) {
	        	_update_user_inverst(user,sendmoney);
	        	teamget[user] = uint(0);
	        	
	        }
	    }
	    return(true);
	}	
	


	function _reset_user_inverst(address user) private returns(bool){
			user_inverst_record[user].can_draw_capital = uint(0);
			user_inverst_record[user].not_draw_capital = uint(0);
			user_inverst_record[user].releasd_profit = uint(0);
			//user_inverst_record[user].last_investdate = uint(0);
			user_inverst_record[user].total_profit = uint(0);
			crontime[user]=uint(0);
			return(true);
	}
	function _update_user_inverst(address user,uint rewards) private returns(uint){
	    
		require(rewards >0);
		uint _mint_account;
		if(user_inverst_record[user].not_draw_capital==uint(0)){
		    return _mint_account;
		}
		/*剩余可释放*/
		uint releasable = user_inverst_record[user].total_profit.sub(user_inverst_record[user].releasd_profit);
		if(releasable<=rewards){
			_reset_user_inverst(user);
			_mint_account = releasable;
		}
		else{
			/*
				修改可提现本金
			*/
			_mint_account = rewards;
			if(user_inverst_record[user].can_draw_capital>0){
				if(user_inverst_record[user].can_draw_capital>rewards){
					user_inverst_record[user].can_draw_capital=user_inverst_record[user].can_draw_capital.sub(rewards);
				}
				else{
					user_inverst_record[user].can_draw_capital = uint(0);
				}
			}
			/*
				修改已释放利润
			*/
			user_inverst_record[user].releasd_profit += _mint_account;
		}
		require(balances[this]>= _mint_account);
		user_inverst_record[user].history_releasd_profit += _mint_account;
		balances[user] += _mint_account;
		balances[this] -= _mint_account;
		emit Transfer(this, user, _mint_account);
		return _mint_account;
	}
	
	function hasReward(address _user)public view returns(bool){
	    if(crontime[_user] <= now - OnceWidrawTime && crontime[_user]!=0){
	        return true;
	    }
	    else{
	        return false;
	    }
	}
	
	function reward() public returns(bool){
	    require(actived == true&&!frozenAccount[msg.sender]);
		address user = msg.sender;
		require(crontime[user] <= now - OnceWidrawTime && crontime[user]!=0);
		/*
		静态
		*/
		uint rewards = user_inverst_record[user].not_draw_capital*per/1000;		
		/*挖矿数量*/
		uint _mint_account = _update_user_inverst(user,rewards);

		
		/*
			动态
		*/
		address  top = fromaddr[user];
		address _user = user;
	 	for(uint i=1;i<=generation;i++){
	 			if(top != address(0) && top != _user){
	 				if(suns[top].n_effective[1]>=node_profits[i].menber_counts){
	 					uint upmoney = _mint_account*node_profits[i].percent/100;
	 					//settop(top, upmoney);
	 					
	 					_update_user_inverst(top,upmoney);
	 					//setteam(top,_mint_account);
	 				}
	 				_user = top;
	 				top = fromaddr[top];
	 				
	 				continue;
                }
                 break;
	 	}
	 	//团队业绩统计
	 	_user = user;
	 	top = fromaddr[user];
	 	for(uint n=1;n<=generation_team;n++){
	 		if(top != address(0) && top != _user){
	 			setteam(top,_mint_account);
	 			_user = top;
	 			top = fromaddr[top];
	 			continue;
	 		}
	 		break;
	 	}
	 	
	 			/*修改下次提现时间*/

		if(crontime[user]>uint(0)){
		    crontime[user] = now + OnceWidrawTime;
		}
		return true;
	}
	
	/*
	 * 用户参与挖矿
	 */

	 function mint(uint _tokens) public {
	 		require(actived == true&&!frozenAccount[msg.sender]);
	 		address user = msg.sender;
  	 		require(_tokens>=plans[1].account && balances[user]>=_tokens);
	 		require(!frozenAccount[user]);
			
			/*16代以内有效用户设置，可以改成N代*/
			address top = fromaddr[user];
			address _user = user;
			for(uint n=1;n<=16;n++){	
				if(top != address(0) && top !=_user){
					if(!_effective_son[user] && n==1){
						++suns[top].n_effective[n];
						_effective_son[user] = true;
						top = fromaddr[top];
						continue;		
					}
					else if(n >=2){
						++suns[top].n_effective[n];
						_user = top;
						top = fromaddr[top];
						continue;
					}else{
						break;
					}
				}
				break;
			}

	 		/*
	 		修改投资信息
	 		*/
	 		user_inverst_record[user].can_draw_capital += _tokens;
	 		user_inverst_record[user].not_draw_capital += _tokens;
	 		user_inverst_record[user].last_investdate = now;

			/*
			增加总投资利润
			*/
			uint _profits;
	 		for(uint i=4;i>=1;i--){
	 				if(_tokens >= plans[i].account){
	 						_profits = plans[i].times * _tokens;
	 						break;
	 				}
	 		}
	 		
	 		user_inverst_record[user].total_profit += _profits;


	 		
	 		balances[user] -= _tokens;
	 		balances[this] += _tokens;
	 		crontime[user] = now + OnceWidrawTime;
	 	}


	function quitMint() public returns(bool){
		require(actived == true&&!frozenAccount[msg.sender]);
		require(user_inverst_record[msg.sender].can_draw_capital > 0);
		uint interval = now.sub(user_inverst_record[msg.sender].last_investdate);
		uint rate = quit_config.rate2;
		if(interval<quit_config.interval){
			rate = quit_config.rate1;
		}
		uint fee = user_inverst_record[msg.sender].can_draw_capital*rate/100;
		uint refund = user_inverst_record[msg.sender].can_draw_capital.sub(fee);
		_reset_user_inverst(msg.sender);
		require(balances[this]>=refund);
		balances[msg.sender] += refund;
		balances[this] -= refund;
		
		emit Transfer(this, msg.sender,refund);
		return(true);	
	}
	 
	function addleadereth(address _user,uint _ethvalue) private returns(bool){
	    address _ethtop = ethtop[_user];
	    if(_ethtop!=address(0) ){
	        leader_eth[_ethtop] += _ethvalue;
	    }
	    /*
	    if(isleader[_user]){
	        leader_eth[_user] += _ethvalue;
	    }
	    */
	    /*
	    address user = _user;
	    address top = fromaddr[_user];
	    for(uint i=1;;i++){
	       if(top!=address(0)&&top!= user){
	           if(isleader[top]){
    	           leader_eth[top] += _ethvalue;
    	           break;
	           }
	           (user,top)=(top,fromaddr[top]);
	           continue;
	       }
	       break;
	   }
	   */
	    return(true);
	}
	function addLeader(address _leader) public onlyOwner returns(bool){
	    require(_leader!=address(0) && !isleader[_leader]);
	    isleader[_leader] = true;
	    leaders.push(_leader);
	    return(true);
	}
	function subLeader(address _leader)public onlyOwner returns(bool){
	    require(_leader!=address(0) && isleader[_leader]);
	   isleader[_leader] = false;
	    return(true);
	}
	/*
	*
	*/
	function getleaders()public view  returns(address [] memory _leaders,uint [] memory _eths){
        uint l;
        for(uint i;i<leaders.length;i++){
            if(isleader[leaders[i]]){
                l++;
            }
        }
        address [] memory  _leaders1 = new address[](l);
        uint [] memory _eths1 = new uint[](l);
        for(uint n;n<leaders.length;n++){
            if(isleader[leaders[n]]){
                l--;
                
                _leaders1[l] = leaders[n];
                _eths1[l] = leader_eth[leaders[n]];
            }
        }
        _eths = _eths1;
        _leaders = _leaders1;
	}
	function setEttTokenAddress(address _ett) public onlyOwner returns(bool){
	    require(_ett!=address(0) && _ett != address(this));
	    ett = EttToken(_ett);
	    return true;
	}
	/*
	function setEttRate(uint _rate) public onlyOwner returns(bool){
	    require(_rate>0);
	    ettRate = _rate;
	    return true;
	}
	*/
	/*
	* sell usdt
	*/
	
	function  usdt2ett(uint _tokens) public returns(bool){
	    require(actived);
	    require(_tokens>0 && balances[msg.sender] >= _tokens);
	    require(ett!=address(0));
	    uint _ettAmount = _tokens * ettRate / 1 ether;
	    ett.tokenAdd(msg.sender,_ettAmount);
	    balances[msg.sender] -= _tokens;
	    emit Transfer(msg.sender,this,_tokens);
	    return true;
	}
	
	/*
	* sell ett
	*/
	function ett2usdt(uint _tokens) public returns(bool){
	    require(actived);
	    require(_tokens>0);
	    require(ett!=address(0));
	    if(getettbalance(msg.sender)>= _tokens){
	        uint _usdts = _tokens*1 ether/ettRate;    
	        ett.tokenSub(msg.sender,_tokens);
	        require(balances[this]> _usdts);
	        balances[msg.sender] += _usdts;
	        balances[this] -= _usdts;
	        emit Transfer(this,msg.sender,_tokens);
	    }else{
	        return false;
	    }
	    return true;
	}
	
	function getettbalance(address _user) public view returns(uint256 _balance){
	    require(ett!=address(0));
	    _balance = ett.balanceOf(_user);
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
		require(msg.value > 0 && actived);
		address user = msg.sender;
		require(!frozenAccount[user]);
		uint amount = msg.value * buyPrice/1 ether;
		require(balances[this] >= amount && amount < _totalSupply);
		
		balances[user] = balances[user].add(amount);
		
		sysinteth += msg.value;
		userineth[user] += msg.value;

		balances[this] = balances[this].sub(amount);
        
		addleadereth(user,msg.value);
		
		owner.transfer(msg.value);
		
		emit Transfer(this, user, amount);
		return(amount);
	}
	
	

	function() payable public {
		buy();
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
			emit Transfer(this, recipients[i], moenys[i]);
		}
		balances[this] = balances[this].sub(sum);

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

	}

}