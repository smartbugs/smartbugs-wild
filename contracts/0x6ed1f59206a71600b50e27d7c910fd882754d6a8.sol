pragma solidity ^0.5.0;

interface IMultiSigManager {
	function provideAddress(address origin, uint poolIndex) external returns (address payable);
	function passedContract(address) external returns (bool);
	function moderator() external returns(address);
}

interface ICustodianToken {
	function emitTransfer(address from, address to, uint value) external returns (bool success);
}

interface IWETH {
	function balanceOf(address) external returns (uint);
	function transfer(address to, uint value) external returns (bool success);
	function transferFrom(address from, address to, uint value) external returns (bool success);
	function approve(address spender, uint value) external returns (bool success);
	function allowance(address owner, address spender) external returns (uint);
	function withdraw(uint value) external;
	function deposit() external;
}

interface IOracle {
	function getLastPrice() external returns(uint, uint);
	function started() external returns(bool);
}

library SafeMath {
	function mul(uint a, uint b) internal pure returns (uint) {
		uint c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
		assert(b <= a);
		return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		assert(c >= a);
		return c;
	}

	function diff(uint a, uint b) internal pure returns (uint) {
		return a > b ? sub(a, b) : sub(b, a);
	}

	function gt(uint a, uint b) internal pure returns(bytes1) {
		bytes1 c;
		c = 0x00;
		if (a > b) {
			c = 0x01;
		}
		return c;
	}
}

contract Managed {
	IMultiSigManager roleManager;
	address public roleManagerAddress;
	address public operator;
	uint public lastOperationTime;
	uint public operationCoolDown;
	uint constant BP_DENOMINATOR = 10000;

	event UpdateRoleManager(address newManagerAddress);
	event UpdateOperator(address updater, address newOperator);

	modifier only(address addr) {
		require(msg.sender == addr);
		_;
	}

	modifier inUpdateWindow() {
		uint currentTime = getNowTimestamp();
		require(currentTime - lastOperationTime >= operationCoolDown);
		_;
		lastOperationTime = currentTime;
	}

	constructor(
		address roleManagerAddr,
		address opt, 
		uint optCoolDown
	) public {
		roleManagerAddress = roleManagerAddr;
		roleManager = IMultiSigManager(roleManagerAddr);
		operator = opt;
		operationCoolDown = optCoolDown;
	}

	function updateRoleManager(address newManagerAddr) 
		inUpdateWindow() 
		public 
	returns (bool) {
		require(roleManager.passedContract(newManagerAddr));
		roleManagerAddress = newManagerAddr;
		roleManager = IMultiSigManager(roleManagerAddress);
		require(roleManager.moderator() != address(0));
		emit UpdateRoleManager(newManagerAddr);
		return true;
	}

	function updateOperator() public inUpdateWindow() returns (bool) {	
		address updater = msg.sender;	
		operator = roleManager.provideAddress(updater, 0);
		emit UpdateOperator(updater, operator);	
		return true;
	}

	function getNowTimestamp() internal view returns (uint) {
		return now;
	}
}

/// @title Custodian - every derivative contract should has basic custodian properties
/// @author duo.network
contract Custodian is Managed {
	using SafeMath for uint;

	/*
     * Constants
     */
	uint constant decimals = 18;
	uint constant WEI_DENOMINATOR = 1000000000000000000;
	enum State {
		Inception,
		Trading,
		PreReset,
		Reset,
		Matured
	}

	/*
     * Storage
     */
	IOracle oracle;
	ICustodianToken aToken;
	ICustodianToken bToken;
	string public contractCode;
	address payable feeCollector;
	address oracleAddress;
	address aTokenAddress;
	address bTokenAddress;
	mapping(address => uint)[2] public balanceOf;
	mapping (address => mapping (address => uint))[2] public allowance;
	address[] public users;
	mapping (address => uint) public existingUsers;
	State state;
	uint minBalance = 10000000000000000; // set at constructor
	uint public totalSupplyA;
	uint public totalSupplyB;
	uint ethCollateralInWei;
	uint navAInWei;
	uint navBInWei;
	uint lastPriceInWei;
	uint lastPriceTimeInSecond;
	uint resetPriceInWei;
	uint resetPriceTimeInSecond;
	uint createCommInBP;
	uint redeemCommInBP;
	uint period;
	uint maturityInSecond; // set to 0 for perpetuals
	uint preResetWaitingBlocks;
	uint priceFetchCoolDown;
	
	// cycle state variables
	uint lastPreResetBlockNo = 0;
	uint nextResetAddrIndex;

	/*
     *  Modifiers
     */
	modifier inState(State _state) {
		require(state == _state);
		_;
	}

	/*
     *  Events
     */
	event StartTrading(uint navAInWei, uint navBInWei);
	event StartPreReset();
	event StartReset(uint nextIndex, uint total);
	event Matured(uint navAInWei, uint navBInWei);
	event AcceptPrice(uint indexed priceInWei, uint indexed timeInSecond, uint navAInWei, uint navBInWei);
	event Create(address indexed sender, uint ethAmtInWei, uint tokenAInWei, uint tokenBInWei, uint feeInWei);
	event Redeem(address indexed sender, uint ethAmtInWei, uint tokenAInWei, uint tokenBInWei, uint feeInWei);
	event TotalSupply(uint totalSupplyAInWei, uint totalSupplyBInWei);
	// token events
	event Transfer(address indexed from, address indexed to, uint value, uint index);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens, uint index);
	// operation events
	event CollectFee(address addr, uint feeInWei, uint feeBalanceInWei);
	event UpdateOracle(address newOracleAddress);
	event UpdateFeeCollector(address updater, address newFeeCollector);

	/*
     *  Constructor
     */
	/// @dev Contract constructor sets operation cool down and set address pool status.
	///	@param code contract name
	///	@param maturity marutiry time in second
	///	@param roleManagerAddr roleManagerContract Address
	///	@param fc feeCollector address
	///	@param comm commission rate
	///	@param pd period
	///	@param preResetWaitBlk pre reset waiting block numbers
	///	@param pxFetchCoolDown price fetching cool down
	///	@param opt operator
	///	@param optCoolDown operation cooldown
	///	@param minimumBalance niminum balance required
	constructor(
		string memory code,
		uint maturity,
		address roleManagerAddr,
		address payable fc,
		uint comm,
		uint pd,
		uint preResetWaitBlk, 
		uint pxFetchCoolDown,
		address opt,
		uint optCoolDown,
		uint minimumBalance
		) 
		public
		Managed(roleManagerAddr, opt, optCoolDown) 
	{
		contractCode = code;
		maturityInSecond = maturity;
		state = State.Inception;
		feeCollector = fc;
		createCommInBP = comm;
		redeemCommInBP = comm;
		period = pd;
		preResetWaitingBlocks = preResetWaitBlk;
		priceFetchCoolDown = pxFetchCoolDown;
		navAInWei = WEI_DENOMINATOR;
		navBInWei = WEI_DENOMINATOR;
		minBalance = minimumBalance;
	}

	/*
     * Public functions
     */

	/// @dev return totalUsers in the system.
	function totalUsers() public view returns (uint) {
		return users.length;
	}

	function feeBalanceInWei() public view returns(uint) {
		return address(this).balance.sub(ethCollateralInWei);
	}

	/*
     * ERC token functions
     */
	/// @dev transferInternal function.
	/// @param index 0 is classA , 1 is class B
	/// @param from  from address
	/// @param to   to address
	/// @param tokens num of tokens transferred
	function transferInternal(uint index, address from, address to, uint tokens) 
		internal 
		inState(State.Trading)
		returns (bool success) 
	{
		// Prevent transfer to 0x0 address. Use burn() instead
		require(to != address(0));
		// Check if the sender has enough
		require(balanceOf[index][from] >= tokens);

		// Save this for an assertion in the future
		uint previousBalances = balanceOf[index][from].add(balanceOf[index][to]);
		// Subtract from the sender
		balanceOf[index][from] = balanceOf[index][from].sub(tokens);
		// Add the same to the recipient
		balanceOf[index][to] = balanceOf[index][to].add(tokens);
	
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[index][from].add(balanceOf[index][to]) == previousBalances);
		emit Transfer(from, to, tokens, index);
		checkUser(from, balanceOf[index][from], balanceOf[1 - index][from]);
		checkUser(to, balanceOf[index][to], balanceOf[1 - index][to]);
		return true;
	}

	function determineAddress(uint index, address from) internal view returns (address) {
		return index == 0 && msg.sender == aTokenAddress || 
			index == 1 && msg.sender == bTokenAddress 
			? from : msg.sender;
	}

	function transfer(uint index, address from, address to, uint tokens)
		public
		inState(State.Trading)
		returns (bool success) 
	{
		require(index == 0 || index == 1);
		return transferInternal(index, determineAddress(index, from), to, tokens);
	}

	function transferFrom(uint index, address spender, address from, address to, uint tokens) 
		public 
		inState(State.Trading)
		returns (bool success) 
	{
		require(index == 0 || index == 1);
		address spenderToUse = determineAddress(index, spender);
		require(tokens <= allowance[index][from][spenderToUse]);	 // Check allowance
		allowance[index][from][spenderToUse] = allowance[index][from][spenderToUse].sub(tokens);
		return transferInternal(index, from, to, tokens);
	}

	function approve(uint index, address sender, address spender, uint tokens) 
		public 
		returns (bool success) 
	{
		require(index == 0 || index == 1);
		address senderToUse = determineAddress(index, sender);
		allowance[index][senderToUse][spender] = tokens;
		emit Approval(senderToUse, spender, tokens, index);
		return true;
	}
	// end of token functions

	/*
     * Internal Functions
     */
	// start of internal utility functions
	function checkUser(address user, uint256 balanceA, uint256 balanceB) internal {
		uint userIdx = existingUsers[user];
		if ( userIdx > 0) {
			if (balanceA < minBalance && balanceB < minBalance) {
				uint lastIdx = users.length;
				address lastUser = users[lastIdx - 1];
				if (userIdx < lastIdx) {
					users[userIdx - 1] = lastUser;
					existingUsers[lastUser] = userIdx;
				}
				delete users[lastIdx - 1];
				existingUsers[user] = 0;
				users.length--;					
			}
		} else if (balanceA >= minBalance || balanceB >= minBalance) {
			users.push(user);
			existingUsers[user] = users.length;
		}
	}
	// end of internal utility functions

	/*
     * Operation Functions
     */
	function collectFee(uint amountInWei) 
		public 
		only(feeCollector) 
		inState(State.Trading) 
		returns (bool success) 
	{
		uint feeBalance = feeBalanceInWei().sub(amountInWei);
		feeCollector.transfer(amountInWei);
		emit CollectFee(feeCollector, amountInWei, feeBalance);
		return true;
	}

	function updateOracle(address newOracleAddr) 
		only(roleManager.moderator())
		inUpdateWindow() 
		public 
	returns (bool) {
		require(roleManager.passedContract(newOracleAddr));
		oracleAddress = newOracleAddr;
		oracle = IOracle(oracleAddress);
		(uint lastPrice, uint lastPriceTime) = oracle.getLastPrice();
		require(lastPrice > 0 && lastPriceTime > 0);
		emit UpdateOracle(newOracleAddr);
		return true;
	}

	function updateFeeCollector() 
		public 
		inUpdateWindow() 
	returns (bool) {
		address updater = msg.sender;
		feeCollector = roleManager.provideAddress(updater, 0);
		emit UpdateFeeCollector(updater, feeCollector);
		return true;
	}
}

/// @title DualClassCustodian - dual class token contract
/// @author duo.network
contract DualClassCustodian is Custodian {
	/*
     * Storage
     */

	uint alphaInBP;
	uint betaInWei;
	uint limitUpperInWei; 
	uint limitLowerInWei;
	uint iterationGasThreshold;
	uint periodCouponInWei; 
	uint limitPeriodicInWei; 

	// reset intermediate values
	uint newAFromAPerA;
	uint newAFromBPerB;
	uint newBFromAPerA;
	uint newBFromBPerB;

	enum ResetState {
		UpwardReset,
		DownwardReset,
		PeriodicReset
	}

	ResetState resetState;

	/*
     * Events
     */
	event SetValue(uint index, uint oldValue, uint newValue);

	function() external payable {}
	
	/*
     * Constructor
     */
	constructor(
		string memory code,
		uint maturity,
		address roleManagerAddr,
		address payable fc,
		uint alpha,
		uint r,
		uint hp,
		uint hu,
		uint hd,
		uint comm,
		uint pd,
		uint optCoolDown,
		uint pxFetchCoolDown,
		uint iteGasTh,
		uint preResetWaitBlk,
		uint minimumBalance
		) 
		public 
		Custodian ( 
		code,
		maturity,
		roleManagerAddr,
		fc,
		comm,
		pd,
		preResetWaitBlk, 
		pxFetchCoolDown,
		msg.sender,
		optCoolDown,
		minimumBalance
		)
	{
		alphaInBP = alpha;
		betaInWei = WEI_DENOMINATOR;
		periodCouponInWei = r;
		limitPeriodicInWei = hp;
		limitUpperInWei = hu; 
		limitLowerInWei = hd;
		iterationGasThreshold = iteGasTh; // 65000;
	}


	/*
     * Public Functions
     */
	/// @dev startCustodian
	///	@param aAddr contract address of Class A
	///	@param bAddr contract address of Class B
	///	@param oracleAddr contract address of Oracle
	function startCustodian(
		address aAddr,
		address bAddr,
		address oracleAddr
		) 
		public 
		inState(State.Inception) 
		only(operator)
		returns (bool success) 
	{	
		aTokenAddress = aAddr;
		aToken = ICustodianToken(aTokenAddress);
		bTokenAddress = bAddr;
		bToken = ICustodianToken(bTokenAddress);
		oracleAddress = oracleAddr;
		oracle = IOracle(oracleAddress);
		(uint priceInWei, uint timeInSecond) = oracle.getLastPrice();
		require(priceInWei > 0 && timeInSecond > 0);
		lastPriceInWei = priceInWei;
		lastPriceTimeInSecond = timeInSecond;
		resetPriceInWei = priceInWei;
		resetPriceTimeInSecond = timeInSecond;
		roleManager = IMultiSigManager(roleManagerAddress);
		state = State.Trading;
		emit AcceptPrice(priceInWei, timeInSecond, WEI_DENOMINATOR, WEI_DENOMINATOR);
		emit StartTrading(navAInWei, navBInWei);
		return true;
	}

	/// @dev create with ETH
	function create() 
		public 
		payable 
		inState(State.Trading) 
		returns (bool) 
	{	
		return createInternal(msg.sender, msg.value);
	}

	/// @dev create with ETH
	///	@param amount amount of WETH to create
	///	@param wethAddr wrapEth contract address
	function createWithWETH(uint amount, address wethAddr)
		public 
		inState(State.Trading) 
		returns (bool success) 
	{
		require(amount > 0 && wethAddr != address(0));
		IWETH wethToken = IWETH(wethAddr);
		wethToken.transferFrom(msg.sender, address(this), amount);
		uint wethBalance = wethToken.balanceOf(address(this));
		require(wethBalance >= amount);
		uint beforeEthBalance = address(this).balance;
        wethToken.withdraw(wethBalance);
		uint ethIncrement = address(this).balance.sub(beforeEthBalance);
		require(ethIncrement >= wethBalance);
		return createInternal(msg.sender, amount);
	}

	function createInternal(address sender, uint ethAmtInWei) 
		internal 
		returns(bool)
	{
		require(ethAmtInWei > 0);
		uint feeInWei;
		(ethAmtInWei, feeInWei) = deductFee(ethAmtInWei, createCommInBP);
		ethCollateralInWei = ethCollateralInWei.add(ethAmtInWei);
		uint numeritor = ethAmtInWei
						.mul(resetPriceInWei)
						.mul(betaInWei)
						.mul(BP_DENOMINATOR
		);
		uint denominator = WEI_DENOMINATOR
						.mul(WEI_DENOMINATOR)
						.mul(alphaInBP
							.add(BP_DENOMINATOR)
		);
		uint tokenValueB = numeritor.div(denominator);
		uint tokenValueA = tokenValueB.mul(alphaInBP).div(BP_DENOMINATOR);
		balanceOf[0][sender] = balanceOf[0][sender].add(tokenValueA);
		balanceOf[1][sender] = balanceOf[1][sender].add(tokenValueB);
		checkUser(sender, balanceOf[0][sender], balanceOf[1][sender]);
		totalSupplyA = totalSupplyA.add(tokenValueA);
		totalSupplyB = totalSupplyB.add(tokenValueB);

		emit Create(
			sender, 
			ethAmtInWei, 
			tokenValueA, 
			tokenValueB, 
			feeInWei
			);
		emit TotalSupply(totalSupplyA, totalSupplyB);
		aToken.emitTransfer(address(0), sender, tokenValueA);
		bToken.emitTransfer(address(0), sender, tokenValueB);
		return true;

	}

	function redeem(uint amtInWeiA, uint amtInWeiB) 
		public 
		inState(State.Trading) 
		returns (bool success) 
	{
		uint adjAmtInWeiA = amtInWeiA.mul(BP_DENOMINATOR).div(alphaInBP);
		uint deductAmtInWeiB = adjAmtInWeiA < amtInWeiB ? adjAmtInWeiA : amtInWeiB;
		uint deductAmtInWeiA = deductAmtInWeiB.mul(alphaInBP).div(BP_DENOMINATOR);
		address payable sender = msg.sender;
		require(balanceOf[0][sender] >= deductAmtInWeiA && balanceOf[1][sender] >= deductAmtInWeiB);
		uint ethAmtInWei = deductAmtInWeiA
			.add(deductAmtInWeiB)
			.mul(WEI_DENOMINATOR)
			.mul(WEI_DENOMINATOR)
			.div(resetPriceInWei)
			.div(betaInWei);
		return redeemInternal(sender, ethAmtInWei, deductAmtInWeiA, deductAmtInWeiB);
	}

	function redeemAll() public inState(State.Matured) returns (bool success) {
		address payable sender = msg.sender;
		uint balanceAInWei = balanceOf[0][sender];
		uint balanceBInWei = balanceOf[1][sender];
		require(balanceAInWei > 0 || balanceBInWei > 0);
		uint ethAmtInWei = balanceAInWei
			.mul(navAInWei)
			.add(balanceBInWei
				.mul(navBInWei))
			.div(lastPriceInWei);
		return redeemInternal(sender, ethAmtInWei, balanceAInWei, balanceBInWei);
	}

	function redeemInternal(
		address payable sender, 
		uint ethAmtInWei, 
		uint deductAmtInWeiA, 
		uint deductAmtInWeiB) 
		internal 
		returns(bool) 
	{
		require(ethAmtInWei > 0);
		ethCollateralInWei = ethCollateralInWei.sub(ethAmtInWei);
		uint feeInWei;
		(ethAmtInWei,  feeInWei) = deductFee(ethAmtInWei, redeemCommInBP);

		balanceOf[0][sender] = balanceOf[0][sender].sub(deductAmtInWeiA);
		balanceOf[1][sender] = balanceOf[1][sender].sub(deductAmtInWeiB);
		checkUser(sender, balanceOf[0][sender], balanceOf[1][sender]);
		totalSupplyA = totalSupplyA.sub(deductAmtInWeiA);
		totalSupplyB = totalSupplyB.sub(deductAmtInWeiB);
		sender.transfer(ethAmtInWei);
		emit Redeem(
			sender, 
			ethAmtInWei, 
			deductAmtInWeiA, 
			deductAmtInWeiB, 
			feeInWei
		);
		emit TotalSupply(totalSupplyA, totalSupplyB);
		aToken.emitTransfer(sender, address(0), deductAmtInWeiA);
		bToken.emitTransfer(sender, address(0), deductAmtInWeiB);
		return true;
	}

	function deductFee(
		uint ethAmtInWei, 
		uint commInBP
	) 
		internal pure
		returns (
			uint ethAmtAfterFeeInWei, 
			uint feeInWei) 
	{
		require(ethAmtInWei > 0);
		feeInWei = ethAmtInWei.mul(commInBP).div(BP_DENOMINATOR);
		ethAmtAfterFeeInWei = ethAmtInWei.sub(feeInWei);
	}
	// end of conversion


	// start of operator functions
	function setValue(uint idx, uint newValue) public only(operator) inState(State.Trading) inUpdateWindow() returns (bool success) {
		uint oldValue;
		if (idx == 0) {
			require(newValue <= BP_DENOMINATOR);
			oldValue = createCommInBP;
			createCommInBP = newValue;
		} else if (idx == 1) {
			require(newValue <= BP_DENOMINATOR);
			oldValue = redeemCommInBP;
			redeemCommInBP = newValue;
		} else if (idx == 2) {
			oldValue = iterationGasThreshold;
			iterationGasThreshold = newValue;
		} else if (idx == 3) {
			oldValue = preResetWaitingBlocks;
			preResetWaitingBlocks = newValue;
		} else {
			revert();
		}

		emit SetValue(idx, oldValue, newValue);
		return true;
	}
	// end of operator functions

	function getStates() public view returns (uint[30] memory) {
		return [
			// managed
			lastOperationTime,
			operationCoolDown,
			// custodian
			uint(state),
			minBalance,
			totalSupplyA,
			totalSupplyB,
			ethCollateralInWei,
			navAInWei,
			navBInWei,
			lastPriceInWei,
			lastPriceTimeInSecond,
			resetPriceInWei,
			resetPriceTimeInSecond,
			createCommInBP,
			redeemCommInBP,
			period,
			maturityInSecond,
			preResetWaitingBlocks,
			priceFetchCoolDown,
			nextResetAddrIndex,
			totalUsers(),
			feeBalanceInWei(),
			// dual class custodian
			uint(resetState),
			alphaInBP,
			betaInWei,
			periodCouponInWei, 
			limitPeriodicInWei, 
			limitUpperInWei, 
			limitLowerInWei,
			iterationGasThreshold
		];
	}

	function getAddresses() public view returns (address[6] memory) {
		return [
			roleManagerAddress,
			operator,
			feeCollector,
			oracleAddress,
			aTokenAddress,
			bTokenAddress
		];
	}
}


/// @title Mozart - short & long token contract
/// @author duo.network
contract Mozart is DualClassCustodian {
	/*
     * Constructor
     */
	constructor(
		string memory code,
		uint maturity,
		address roleManagerAddr,
		address payable fc,
		uint alpha,
		uint hu,
		uint hd,
		uint comm,
		uint pd,
		uint optCoolDown,
		uint pxFetchCoolDown,
		uint iteGasTh,
		uint preResetWaitBlk,
		uint minimumBalance
		) 
		public 
		DualClassCustodian ( 
			code,
			maturity,
			roleManagerAddr,
			fc,
			alpha,
			0,
			0,
			hu,
			hd,
			comm,
			pd,
			optCoolDown,
			pxFetchCoolDown,
			iteGasTh,
			preResetWaitBlk,
			minimumBalance
		)
	{
	}

	// start of priceFetch funciton
	function fetchPrice() public inState(State.Trading) returns (bool) {
		uint currentTime = getNowTimestamp();
		require(currentTime > lastPriceTimeInSecond.add(priceFetchCoolDown));
		(uint priceInWei, uint timeInSecond) = oracle.getLastPrice();
		require(timeInSecond > lastPriceTimeInSecond && timeInSecond <= currentTime && priceInWei > 0);
		lastPriceInWei = priceInWei;
		lastPriceTimeInSecond = timeInSecond;
		(navAInWei, navBInWei) = calculateNav(
			priceInWei, 
			resetPriceInWei 
			);
		if (maturityInSecond > 0 && timeInSecond > maturityInSecond) {
			state = State.Matured;
			emit Matured(navAInWei, navBInWei);
		} else if (navBInWei >= limitUpperInWei || navBInWei <= limitLowerInWei) {
			state = State.PreReset;
			lastPreResetBlockNo = block.number;
			emit StartPreReset();
		} 
		emit AcceptPrice(priceInWei, timeInSecond, navAInWei, navBInWei);
		return true;
	}
	
	function calculateNav(
		uint priceInWei, 
		uint rstPriceInWei
		) 
		internal 
		view 
		returns (uint, uint) 
	{
		uint navEthInWei = priceInWei.mul(WEI_DENOMINATOR).div(rstPriceInWei);
		
		uint navParentInWei = navEthInWei
			.mul(alphaInBP
				.add(BP_DENOMINATOR))
			.div(BP_DENOMINATOR);
		
		if(navEthInWei >= WEI_DENOMINATOR.mul(2)) {
			return (0, navParentInWei);
		}

		if(navEthInWei <= WEI_DENOMINATOR
			.mul(2)
			.mul(alphaInBP)
			.div(alphaInBP
				.mul(2)
				.add(BP_DENOMINATOR)
			)
		) {
			return (navParentInWei.mul(BP_DENOMINATOR).div(alphaInBP), 0);
		}
		uint navA = WEI_DENOMINATOR.mul(2).sub(navEthInWei);
		uint navB = navEthInWei
			.mul(alphaInBP
				.mul(2)
				.add(BP_DENOMINATOR))
			.sub(WEI_DENOMINATOR
				.mul(alphaInBP)
				.mul(2))
			.div(BP_DENOMINATOR);
		return (navA, navB);
	}
	// end of priceFetch function

	// start of reset function
	function startPreReset() public inState(State.PreReset) returns (bool success) {
		if (block.number - lastPreResetBlockNo >= preResetWaitingBlocks) {
			state = State.Reset;
			if (navBInWei >= limitUpperInWei) {
				resetState = ResetState.UpwardReset;
				newAFromAPerA = 0;
				newBFromAPerA = 0;
				uint excessBInWei = navBInWei.sub(navAInWei);
				newBFromBPerB = excessBInWei.mul(BP_DENOMINATOR).div(BP_DENOMINATOR.add(alphaInBP));
				newAFromBPerB = newBFromBPerB.mul(alphaInBP).div(BP_DENOMINATOR);
				// adjust total supply
				totalSupplyA = totalSupplyA.mul(navAInWei).div(WEI_DENOMINATOR).add(totalSupplyB.mul(newAFromBPerB).div(WEI_DENOMINATOR));
				totalSupplyB = totalSupplyB.mul(navAInWei).div(WEI_DENOMINATOR).add(totalSupplyB.mul(newBFromBPerB).div(WEI_DENOMINATOR));
			} else {
				resetState = ResetState.DownwardReset;
				newAFromBPerB = 0;
				newBFromBPerB = 0;
				uint excessAInWei = navAInWei.sub(navBInWei);
				newBFromAPerA = excessAInWei.mul(BP_DENOMINATOR).div(BP_DENOMINATOR.add(alphaInBP));
				newAFromAPerA = newBFromAPerA.mul(alphaInBP).div(BP_DENOMINATOR);
				totalSupplyB = totalSupplyB.mul(navBInWei).div(WEI_DENOMINATOR).add(totalSupplyA.mul(newBFromAPerA).div(WEI_DENOMINATOR));
				totalSupplyA = totalSupplyA.mul(navBInWei).div(WEI_DENOMINATOR).add(totalSupplyA.mul(newAFromAPerA).div(WEI_DENOMINATOR));
			} 

			emit TotalSupply(totalSupplyA, totalSupplyB);
			emit StartReset(nextResetAddrIndex, users.length);
		} else 
			emit StartPreReset();

		return true;
	}

	function startReset() public inState(State.Reset) returns (bool success) {
		uint currentBalanceA;
		uint currentBalanceB;
		uint newBalanceA;
		uint newBalanceB;
		uint newAFromA;
		uint newBFromA;
		uint newBFromB;
		uint newAFromB;
		address currentAddress;
		uint localResetAddrIndex = nextResetAddrIndex;
		while (localResetAddrIndex < users.length && gasleft() > iterationGasThreshold) {
			currentAddress = users[localResetAddrIndex];
			currentBalanceA = balanceOf[0][currentAddress];
			currentBalanceB = balanceOf[1][currentAddress];
			if (resetState == ResetState.DownwardReset) {
				newBFromA = currentBalanceA.mul(newBFromAPerA).div(WEI_DENOMINATOR);
				newAFromA = newBFromA.mul(alphaInBP).div(BP_DENOMINATOR);
				newBalanceA = currentBalanceA.mul(navBInWei).div(WEI_DENOMINATOR).add(newAFromA);
				newBalanceB = currentBalanceB.mul(navBInWei).div(WEI_DENOMINATOR).add(newBFromA);
			} else {
				newBFromB = currentBalanceB.mul(newBFromBPerB).div(WEI_DENOMINATOR);
				newAFromB = newBFromB.mul(alphaInBP).div(BP_DENOMINATOR);
				newBalanceA = currentBalanceA.mul(navAInWei).div(WEI_DENOMINATOR).add(newAFromB);
				newBalanceB = currentBalanceB.mul(navAInWei).div(WEI_DENOMINATOR).add(newBFromB);
			}

			balanceOf[0][currentAddress] = newBalanceA;
			balanceOf[1][currentAddress] = newBalanceB;
			localResetAddrIndex++;
		}

		if (localResetAddrIndex >= users.length) {
			
			resetPriceInWei = lastPriceInWei;
			resetPriceTimeInSecond = lastPriceTimeInSecond;
			navAInWei = WEI_DENOMINATOR;
			navBInWei = WEI_DENOMINATOR;
			nextResetAddrIndex = 0;

			state = State.Trading;
			emit StartTrading(navAInWei, navBInWei);
			return true;
		} else {
			nextResetAddrIndex = localResetAddrIndex;
			emit StartReset(localResetAddrIndex, users.length);
			return false;
		}
	}
	// end of reset function
}