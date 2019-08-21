pragma solidity ^0.4.18;

contract ERC20_Interface {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	uint public decimals;
	string public name;
}

contract nonNativeToken_Interface is ERC20_Interface {
	function makeDeposit(address deposit_to, uint256 amount) public returns (bool success);
	function makeWithdrawal(address withdraw_from, uint256 amount) public returns (bool success);
}

contract EthWrapper_Interface is nonNativeToken_Interface {
	function wrapperChanged() public payable;
}

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b > 0);
		uint256 c = a / b;
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

contract ERC20_Token is ERC20_Interface{
	using SafeMath for uint256;
	mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public totalSupply;
	uint256 public decimals;
	string public name;
	string public symbol;

	function ERC20_Token(string _name,string _symbol,uint256 _decimals) public{
		name=_name;
		symbol=_symbol;
		decimals=_decimals;
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {
		if (balances[msg.sender] >= _value) {
			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			return true;
		}else return false;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
			balances[_from] = balances[_from].sub(_value);
			balances[_to] = balances[_to].add(_value);
			allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
			Transfer(_from, _to, _value);
			return true;
		}else return false;
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
}

contract nonNativeToken is ERC20_Token, nonNativeToken_Interface{
	address public exchange;
	modifier onlyExchange{
		require(msg.sender==exchange);
		_;
	}

	function nonNativeToken(string _name, string _symbol, uint256 _decimals) ERC20_Token(_name, _symbol, _decimals) public{
		exchange=msg.sender;
	}

	function makeDeposit(address deposit_to, uint256 amount) public onlyExchange returns (bool success){
		balances[deposit_to] = balances[deposit_to].add(amount);
		totalSupply = totalSupply.add(amount);
		return true;
	}

	function makeWithdrawal(address withdraw_from, uint256 amount) public onlyExchange returns (bool success){
		if(balances[withdraw_from]>=amount) {
			balances[withdraw_from] = balances[withdraw_from].sub(amount);
			totalSupply = totalSupply.sub(amount);
			return true;
		}
		return false;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if(balances[_from] >= _value) {
			if(msg.sender == exchange) {
				balances[_from] = balances[_from].sub(_value);
				balances[_to] = balances[_to].add(_value);
				Transfer(_from, _to, _value);
				return true;
			}else if(allowed[_from][msg.sender] >= _value) {
				balances[_from] = balances[_from].sub(_value);
				balances[_to] = balances[_to].add(_value);
				allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
				Transfer(_from, _to, _value);
				return true;
			}
		}
		return false;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		if(_spender==exchange){
			return balances[_owner];
		}else{
			return allowed[_owner][_spender];
		}
	}
}

contract EthWrapper is nonNativeToken, EthWrapper_Interface{
	bool isWrapperChanged;

	function EthWrapper(string _name, string _symbol, uint256 _decimals) nonNativeToken(_name, _symbol, _decimals) public{
		isWrapperChanged=false;
	}

	modifier notWrapper(){
		require(isWrapperChanged);
		_;
	}

	function wrapperChanged() public payable onlyExchange{
		require(!isWrapperChanged);
		isWrapperChanged=true;
	}

	function withdrawEther(uint _amount) public notWrapper{
		require(balances[msg.sender]>=_amount);
		balances[msg.sender]=balances[msg.sender].sub(_amount);
		msg.sender.transfer(_amount);
	}
}

contract AdminAccess {
	mapping(address => uint8) public admins;
	event AdminAdded(address admin,uint8 access);
	event AdminAccessChanged(address admin, uint8 old_access, uint8 new_access);
	event AdminRemoved(address admin);
	modifier onlyAdmin(uint8 accessLevel){
		require(admins[msg.sender]>=accessLevel);
		_;
	}

	function AdminAccess() public{
		admins[msg.sender]=2;
	}

	function addAdmin(address _admin, uint8 _access) public onlyAdmin(2) {
		require(admins[_admin] == 0);
		require(_access > 0);
		AdminAdded(_admin,_access);
		admins[_admin]=_access;
	}

	function changeAccess(address _admin, uint8 _access) public onlyAdmin(2) {
		require(admins[_admin] > 0);
		require(_access > 0);
		AdminAccessChanged(_admin, admins[_admin], _access);
		admins[_admin]=_access;
	}

	function removeAdmin(address _admin) public onlyAdmin(2) {
		require(admins[_admin] > 0);
		AdminRemoved(_admin);
		admins[_admin]=0;
	}
}

contract Managable is AdminAccess {
	uint public feePercent;
	address public feeAddress;
	mapping (string => address) nTokens;

	event TradingFeeChanged(uint256 _from, uint256 _to);
	event FeeAddressChanged(address _from, address _to);
	event TokenDeployed(address _addr, string _name, string _symbol);
	event nonNativeDeposit(string _token,address _to,uint256 _amount);
	event nonNativeWithdrawal(string _token,address _from,uint256 _amount);

	function Managable() AdminAccess() public {
		feePercent=10;
		feeAddress=msg.sender;
	}

	function setFeeAddress(address _fee) public onlyAdmin(2) {
		FeeAddressChanged(feeAddress, _fee);
		feeAddress=_fee;
	}

	//1 fee unit equals 0.01% fee
	function setFee(uint _fee) public onlyAdmin(2) {
		require(_fee < 100);
		TradingFeeChanged(feePercent, _fee);
		feePercent=_fee;
	}

	function deployNonNativeToken(string _name,string _symbol,uint256 _decimals) public onlyAdmin(2) returns(address tokenAddress){
		address nToken = new nonNativeToken(_name, _symbol, _decimals);
		nTokens[_symbol]=nToken;
		TokenDeployed(nToken, _name, _symbol);
		return nToken;
	}

	function depositNonNative(string _symbol,address _to,uint256 _amount) public onlyAdmin(2){
		require(nTokens[_symbol] != address(0));
		nonNativeToken_Interface(nTokens[_symbol]).makeDeposit(_to, _amount);
		nonNativeDeposit(_symbol, _to, _amount);
	}

	function withdrawNonNative(string _symbol,address _from,uint256 _amount) public onlyAdmin(2){
		require(nTokens[_symbol] != address(0));
		nonNativeToken_Interface(nTokens[_symbol]).makeWithdrawal(_from, _amount);
		nonNativeWithdrawal(_symbol, _from, _amount);
	}

	function getTokenAddress(string _symbol) public constant returns(address tokenAddress){
		return nTokens[_symbol];
	}
}

contract EtherStore is Managable{
	bool public WrapperisEnabled;
	address public EtherWrapper;

	modifier WrapperEnabled{
		require(WrapperisEnabled);
		_;
	}
	modifier PreWrapper{
		require(!WrapperisEnabled);
		_;
		WrapperSetup(EtherWrapper);
		WrapperisEnabled=true;
	}

	event WrapperSetup(address _wrapper);
	event WrapperChanged(address _from, address _to);
	event EtherDeposit(address _to, uint256 _amount);
	event EtherWithdrawal(address _from, uint256 _amount);

	function EtherStore() Managable() public {
		WrapperisEnabled=false;
	}

	function setupWrapper(address _wrapper) public onlyAdmin(2) PreWrapper{
		EtherWrapper=_wrapper;
	}

	function deployWrapper() public onlyAdmin(2) PreWrapper{
		EtherWrapper = new EthWrapper('EtherWrapper', 'ETH', 18);
	}

	function changeWrapper(address _wrapper) public onlyAdmin(2) WrapperEnabled{
		EthWrapper_Interface(EtherWrapper).wrapperChanged.value(this.balance)();
		WrapperChanged(EtherWrapper, _wrapper);
		EtherWrapper = _wrapper;
	}

	function deposit() public payable WrapperEnabled{
		require(EthWrapper_Interface(EtherWrapper).makeDeposit(msg.sender, msg.value));
		EtherDeposit(msg.sender,msg.value);
	}

	function depositTo(address _to) public payable WrapperEnabled{
		require(EthWrapper_Interface(EtherWrapper).makeDeposit(_to, msg.value));
		EtherDeposit(_to,msg.value);
	}

	function () public payable {
		deposit();
	}

	function withdraw(uint _amount) public WrapperEnabled{
		require(EthWrapper_Interface(EtherWrapper).balanceOf(msg.sender) >= _amount);
		require(EthWrapper_Interface(EtherWrapper).makeWithdrawal(msg.sender, _amount));
		msg.sender.transfer(_amount);
		EtherWithdrawal(msg.sender, _amount);
	}

	function withdrawTo(address _to,uint256 _amount) public WrapperEnabled{
		require(EthWrapper_Interface(EtherWrapper).balanceOf(msg.sender) >= _amount);
		require(EthWrapper_Interface(EtherWrapper).makeWithdrawal(msg.sender, _amount));
		_to.transfer(_amount);
		EtherWithdrawal(_to, _amount);
	}
}

contract Mergex is EtherStore{
	using SafeMath for uint256;
	mapping(address => mapping(bytes32 => uint256)) public fills;
	event Trade(bytes32 hash, address tokenA, address tokenB, uint valueA, uint valueB);
	event Filled(bytes32 hash);
	event Cancel(bytes32 hash);
	function Mergex() EtherStore() public {
	}

	function checkAllowance(address token, address owner, uint256 amount) internal constant returns (bool allowed){
		return ERC20_Interface(token).allowance(owner,address(this)) >= amount;
	}

	function getFillValue(address owner, bytes32 hash) public view returns (uint filled){
		return fills[owner][hash];
	}

	function fillOrder(address owner, address tokenA, address tokenB, uint tradeAmount, uint valueA, uint valueB, uint expiration, uint nonce, uint8 v, bytes32 r, bytes32 s) public{
		bytes32 hash=sha256('mergex',owner,tokenA,tokenB,valueA,valueB,expiration,nonce);
		if(validateOrder(owner,hash,expiration,tradeAmount,valueA,v,r,s)){
			if(!tradeTokens(hash, msg.sender, owner, tokenA, tokenB, tradeAmount, valueA, valueB)){
				revert();
			}
			fills[owner][hash]=fills[owner][hash].add(tradeAmount);
			if(fills[owner][hash] == valueA){
				Filled(hash);
			}
		}
	}

	function validateOrder(address owner, bytes32 hash, uint expiration, uint tradeAmount, uint Value, uint8 v, bytes32 r, bytes32 s) internal constant returns(bool success){
		require(fills[owner][hash].add(tradeAmount) <= Value);
		require(block.number<=expiration);
		require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32",hash),v,r,s)==owner);
		return true;
	}

	function cancelOrder(address tokenA, address tokenB, uint valueA, uint valueB, uint expiration, uint nonce, uint8 v, bytes32 r, bytes32 s) public{
		bytes32 hash=sha256('mergex', msg.sender, tokenA, tokenB, valueA, valueB, expiration, nonce);
		require(block.number<=expiration);
		require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32",hash),v,r,s)==msg.sender);
		Cancel(hash);
		fills[msg.sender][hash]=valueA;
	}

	function tradeTokens(bytes32 hash, address userA,address userB,address tokenA,address tokenB,uint amountA,uint valueA,uint valueB) internal returns(bool success){
		uint amountB=valueB.mul(amountA).div(valueA);
		require(ERC20_Interface(tokenA).balanceOf(userA)>=amountA);
		require(ERC20_Interface(tokenB).balanceOf(userB)>=amountB);
		if(!checkAllowance(tokenA, userA, amountA))return false;
		if(!checkAllowance(tokenB, userB, amountB))return false;
		uint feeA=amountA.mul(feePercent).div(10000);
		uint feeB=amountB.mul(feePercent).div(10000);
		uint tradeA=amountA.sub(feeA);
		uint tradeB=amountB.sub(feeB);
		if(!ERC20_Interface(tokenA).transferFrom(userA,userB,tradeA))return false;
		if(!ERC20_Interface(tokenB).transferFrom(userB,userA,tradeB))return false;
		if(!ERC20_Interface(tokenA).transferFrom(userA,feeAddress,feeA))return false;
		if(!ERC20_Interface(tokenB).transferFrom(userB,feeAddress,feeB))return false;
		Trade(hash, tokenA, tokenB, amountA, amountB);
		return true;
	}
}