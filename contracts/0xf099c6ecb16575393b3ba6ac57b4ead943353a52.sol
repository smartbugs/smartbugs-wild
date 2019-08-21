pragma solidity ^0.4.22;

contract BuddhaTower {
    event onBuy
    (
        address indexed buyerAddress,
        uint256 amount,
        uint256 currentHeight
    );

    event onSplit(
    	uint round,
    	uint luckyNumber,
    	address luckyPlayer
    );

    event onTimeup(
    	uint round,
    	address lastBuyer
    );

    event onQualifySuccess(
    	address applier
    );


//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================

	struct RoundData {
        uint256 maxHeight;
        uint256 lotteryPool;
        uint256 peakPool;
        uint256 tokenPot;
        uint[][] buyinfo;
    	address[] buyAddress;
    	uint256 startTime;
    	uint256 endTime;
    	address[] lotteryWinners;
    	address finalWinner;
    }

	mapping (address => uint256) public balanceOf;
	address[] public holders;
    uint256 public totalToken = 0;
    // bool public active = false;
    address private owner;
    mapping (address => uint256) public ethOf;
    mapping (address => address) public inviterOf;
    mapping (address => bool) public qualified;
    uint public price;
    bool public emergencySwitch = false;
    uint public height;
    uint256 public lotteryPool;
    uint256 public peakPool;
    uint[7] public inviteCut = [10,8,6,2,2,1,1];
    mapping(uint256 => RoundData) public roundData_;
    mapping(address => uint256) public inviteIncome;
    mapping(address => uint256) public lotteryIncome;
    mapping(address => uint256) public finalIncome;
    mapping(address => uint256) public tokenIncome;
    uint256 public step = 100000000000;
    
    uint public _rId;
    address private lastBuyer;
    mapping (address => bool) public banAddress;
    mapping (address => uint[4]) public leefs;
    uint public devCut = 0;
    address public addr1 = 0x0b8E19f4A333f58f824e59eBeD301190939c63B5;//3.5%
    address public addr2 = 0x289809c3Aa4D52e2cb424719F82014a1Ff7F2266;//2%
    address public addr3 = 0xf3140b8c2e3dac1253f2041e4f4549ddb1aebd35;//2%
    address public addr4 = 0x245aDe5562bdA54AE913FF1f74b8329Ab011D7e0;//dev cut

    // uint public rand = 0;
//==============================================================================
//     _ _  _  _|. |`. _  _ _  .
//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)
//==============================================================================
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier isEmergency() {
        require(emergencySwitch);
        _;
    }

    modifier isBaned(address addr) {
        require(!banAddress[addr]);
        _;
    }

    modifier isActive(){
    	require(
            roundData_[_rId].startTime != 0,
            "not Started"
        );
        _;
    }

    modifier onlyOwner(){
    	require(
            msg.sender == owner,
            "only owner can do this"
        );
        _;
    }

    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "too low");
        require(_eth <= 100000000000000000000000, "too much");
        _;    
    }    
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)
//==============================================================================
    constructor () public{
    	owner = msg.sender;
    	balanceOf[owner] = 1000000000000000000;//decimal 18
    	totalToken = 1000000000000000000;
    	leefs[owner] = [9,9,9,9];
    	holders.push(owner);
    	qualified[owner] = true;
    	_rId = 0;
    	price = 100000000000000000;
    	activate();
    }

//==============================================================================
//     _    |_ |. _   |`    _  __|_. _  _  _  .
//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)
//====|=========================================================================
    function deposit(address _inviter, uint256 _amount)
        isActive()
        isHuman()
        isWithinLimits(msg.value)
        isBaned(msg.sender)
        public
        payable
    {
    	require(_amount > 0 && _amount <= 1000);
    	require (msg.value >= (height * step + price + (height + _amount-1)*step + price)*_amount/2,"value not enough");
    	if(inviterOf[msg.sender]==0x0 && qualified[_inviter] && _inviter != msg.sender)
    	{
    		inviterOf[msg.sender] = _inviter;
    	}
        buy(_amount);
    }

	function withdrawEth(uint _amount) 
	isBaned(msg.sender)
	isHuman()
	public
    {
        require(ethOf[msg.sender] >= _amount);
        msg.sender.transfer(_amount);
        ethOf[msg.sender] -= _amount;
    }    

    function getLotteryWinner(uint _round, uint index) public
    returns (address)
    {
    	require(_round>=0 && index >= 0);
    	return roundData_[_round].lotteryWinners[index];
    }

    function getLotteryWinnerLength(uint _round) public
    returns (uint)
    {
    	return roundData_[_round].lotteryWinners.length;
    }

    function getQualified() public{
    	require(balanceOf[msg.sender] >= 1000000000000000000);
    	qualified[msg.sender] = true;
    	emit onQualifySuccess(msg.sender);
    }

    function getBuyInfoLength(uint256 rId) public 
    returns(uint)
    {
    	return roundData_[rId].buyinfo.length;
    }

    function getBuyInfo(uint256 rId,uint256 index) public 
    returns(uint, uint)
    {
    	require(index >= 0 && index < roundData_[rId].buyinfo.length);
    	return (roundData_[rId].buyinfo[index][0],roundData_[rId].buyinfo[index][1]);
    }

    function getBuyAddress(uint256 rId,uint256 index) public 
    returns (address)
    {
    	require(index >= 0 && index < roundData_[rId].buyAddress.length);
    	return roundData_[rId].buyAddress[index];
    }
//==============================================================================
//     _ _  _ _   | _  _ . _  .
//    (_(_)| (/_  |(_)(_||(_  . (this + tools + calcs + modules = our softwares engine)
//=====================_|=======================================================
	function buy(uint256 amount) private{
		if(now >= roundData_[_rId].endTime)
		{
			endTime();
		}
		require(amount > 0);
		uint256 cost = (price + height*step + price + (height+amount-1)*step)*amount/2;
		ethOf[msg.sender] += msg.value - cost;
		
		roundData_[_rId].peakPool += cost*3/10;
		roundData_[_rId].lotteryPool += cost/10;
		roundData_[_rId].tokenPot += cost*17/100;
		devCut += cost*55/1000;

        ethOf[addr1] += cost*35/1000;
        ethOf[addr2] += cost*20/1000;
        ethOf[addr3] += cost*20/1000;


		roundData_[_rId].buyinfo.push([height+1,height+amount]);
		roundData_[_rId].buyAddress.push(msg.sender);

		roundData_[_rId].endTime += amount * 60;//*60;

        if (amount >= 10 && balanceOf[msg.sender] == 0)
        	holders.push(msg.sender);
        uint256 tokenGet = amount/1000 * 11000000000000000000 + amount / 100 * 1000000000000000000 + amount/10*1000000000000000000;
        address affect = 0x0;
        if (balanceOf[msg.sender] < 1000000000000000000 && tokenGet > 1000000000000000000)
        {
        	leefs[inviterOf[msg.sender]][0]+=1;
        	if(leefs[inviterOf[msg.sender]][0] == 3 && balanceOf[inviterOf[msg.sender]] >= 7000000000000000000 )
        	{
        		affect = inviterOf[inviterOf[msg.sender]];
        		leefs[affect][1]+=1;
        		if(leefs[affect][1] == 3 && balanceOf[affect] >= 20000000000000000000)
        		{
        			affect = inviterOf[affect];
        			leefs[affect][2]+=1;
        		}
        	}
        }
        if ((balanceOf[msg.sender] < 7000000000000000000 || leefs[msg.sender][0] < 3) && balanceOf[msg.sender] + tokenGet >= 7000000000000000000 && leefs[msg.sender][0] >= 3)
        {
        	leefs[inviterOf[msg.sender]][1]+=1;
        	if(leefs[inviterOf[msg.sender]][1] == 3 && balanceOf[inviterOf[msg.sender]] >= 20000000000000000000 )
        	{
        		affect = inviterOf[inviterOf[msg.sender]];
        		leefs[affect][2]+=1;
        	}
        }
        		
        if ((balanceOf[msg.sender] < 20000000000000000000 || leefs[msg.sender][1] < 3)&& balanceOf[msg.sender] + tokenGet >= 20000000000000000000 && leefs[msg.sender][1] >= 3)
        	leefs[inviterOf[msg.sender]][2]+=1;
        balanceOf[msg.sender] += tokenGet;
        totalToken+=tokenGet;
        address inviter = inviterOf[msg.sender];
        address inviter2 = inviterOf[inviter];
        address inviter3 = inviterOf[inviter2];
        address inviter4 = inviterOf[inviter3];
        address inviter5 = inviterOf[inviter4];
        address inviter6 = inviterOf[inviter5];
        address inviter7 = inviterOf[inviter6];

        if(inviter != 0x0){
            ethOf[inviter] += cost * inviteCut[0]/100;
            inviteIncome[inviter] += cost * inviteCut[0]/100;
        }

        if(inviter2 != 0x0 && balanceOf[inviter2] >= 7000000000000000000 && leefs[inviter2][0] >= 3){
            ethOf[inviter2] += cost * inviteCut[1]/100;
            inviteIncome[inviter2] += cost * inviteCut[1]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[1]/100;
        }

        if(inviter3 != 0x0 && balanceOf[inviter3] >= 7000000000000000000 && leefs[inviter3][0] >= 3){
            ethOf[inviter3] += cost * inviteCut[2]/100;
            inviteIncome[inviter3] += cost * inviteCut[2]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[2]/100;
        }

        if(inviter4 != 0x0 && balanceOf[inviter4] >= 20000000000000000000 && leefs[inviter4][1] >= 3){
            ethOf[inviter4] += cost * inviteCut[3]/100;
            inviteIncome[inviter4] += cost * inviteCut[3]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[3]/100;
        }

        if(inviter5 != 0x0 && balanceOf[inviter5] >= 20000000000000000000 && leefs[inviter5][1] >= 3){
            ethOf[inviter5] += cost * inviteCut[4]/100;
            inviteIncome[inviter5] += cost * inviteCut[4]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[4]/100;
        }

        if(inviter6 != 0x0 && balanceOf[inviter6] >= 100000000000000000000 && leefs[inviter6][2] >= 3){
            ethOf[inviter6] += cost * inviteCut[5]/100;
            inviteIncome[inviter6] += cost * inviteCut[5]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[5]/100;
        }

        if(inviter7 != 0x0 && balanceOf[inviter7] >= 100000000000000000000 && leefs[inviter7][2] >= 3){
            ethOf[inviter7] += cost * inviteCut[6]/100;
            inviteIncome[inviter7] += cost * inviteCut[6]/100;
        }else{
            roundData_[_rId].lotteryPool += cost * inviteCut[6]/100;
        }


        if(roundData_[_rId].endTime - now > 86400)
        {
            roundData_[_rId].endTime = now + 86400;
        }

		if(height+amount >= (height/1000+1)*1000 )
		{
			lastBuyer = msg.sender;
			splitLottery();
		}

		height += amount;
		emit onBuy(msg.sender, amount, height);
	}

	// function getRand() public{
	// 	rand = uint(keccak256(now, msg.sender)) % 1000 + 1 + _rId*1000;
	// }

	function splitLottery() private{
        //随机一个赢家
        uint random = uint(keccak256(now, msg.sender)) % 1000 + 1 + roundData_[_rId].lotteryWinners.length*1000;//瞎比写的
        // rand = random;
        //随机完毕
        // uint startHeight = ((height/1000)-1)*1000;
        uint i = 0;
        uint start = 0;
        uint end = roundData_[_rId].buyinfo.length-1;
        uint mid = (start+end)/2;
        while(end >= start)
        {
        	if(roundData_[_rId].buyinfo[mid][0] > random)
        	{
        		end = mid-1;
        		mid = start+(end-start)/2;
        		continue;
        	}
        	if(roundData_[_rId].buyinfo[mid][1] < random)
        	{
        		start = mid+1;
        		mid = start+(end-start)/2;
        		continue;
        	}
        	break;
        }
        address lotteryWinner = roundData_[_rId].buyAddress[mid];
        ethOf[lotteryWinner] += roundData_[_rId].lotteryPool*80/100;
        lotteryIncome[lotteryWinner] += roundData_[_rId].lotteryPool*80/100;
        roundData_[_rId].lotteryWinners.push(lotteryWinner);

        for (i = 0; i < holders.length; i++)
        {
        	ethOf[holders[i]] += roundData_[_rId].tokenPot* balanceOf[holders[i]]/totalToken;
        	tokenIncome[holders[i]] += roundData_[_rId].tokenPot* balanceOf[holders[i]]/totalToken;
        }
        step += 100000000000;
        roundData_[_rId].lotteryPool = roundData_[_rId].lotteryPool*2/10;
        emit onSplit(height/1000+1,random, lotteryWinner);
	}

	function endTime() private{
		address finalWinner = owner;
		if(roundData_[_rId].buyAddress.length > 0)
			finalWinner = roundData_[_rId].buyAddress[roundData_[_rId].buyAddress.length-1];
        //防止溢出
        require(ethOf[finalWinner]+roundData_[_rId].peakPool*8/10 >= ethOf[finalWinner]);
        ethOf[finalWinner] += roundData_[_rId].peakPool*8/10;
        finalIncome[finalWinner] += roundData_[_rId].peakPool*8/10;
        roundData_[_rId].finalWinner = finalWinner;
        roundData_[_rId].maxHeight = height;
        height = 0;
        step = 100000000000;
        _rId++;
        roundData_[_rId].peakPool = roundData_[_rId-1].peakPool*2/10;
        ethOf[owner] += roundData_[_rId-1].lotteryPool;
        roundData_[_rId].lotteryPool = 0; 

        roundData_[_rId].startTime = now;
        roundData_[_rId].endTime = now+86400;
        emit onTimeup(_rId-1,finalWinner);
	}


//==============================================================================
//    (~ _  _    _._|_    .
//    _)(/_(_|_|| | | \/  .
//====================/=========================================================
    function activate() public onlyOwner(){
    	height = 0;
    	_rId = 0;
    	roundData_[_rId].startTime = now;
    	roundData_[_rId].endTime = now + 86400;
    }

    function takeDevCut() public onlyOwner() {
        addr4.transfer(devCut);
        devCut = 0;
    }    

    function wipeAll() public onlyOwner() {
        selfdestruct(owner);
    }

    function emergencyStart() public onlyOwner() {
        emergencySwitch = true;
    }

    function emergencyClose() public onlyOwner() {
        emergencySwitch = false;
    }

    function addToBanlist(address addr) public onlyOwner() {
    	banAddress[addr] = true;
    }

    function moveFromBanlist(address addr) public onlyOwner() {
    	banAddress[addr] = false;
    }

//==============================================================================
//    _|_ _  _ | _  .
//     | (_)(_)|_\  .
//==============================================================================

}