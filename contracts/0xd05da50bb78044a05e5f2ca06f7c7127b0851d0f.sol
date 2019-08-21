pragma solidity ^0.4.9;

contract ERC20 {
	string public name;
	string public symbol;
	uint8 public decimals = 8;

	uint public totalSupply;
	function balanceOf(address _owner) public constant returns (uint balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

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

	/* function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	} */

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

contract owned {
	address public owner;

	function owned() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		owner = newOwner;
	}
}

contract BazistaToken is ERC20, owned {
	using SafeMath for uint256;

	string public name = 'Bazista Token';
	string public symbol = 'BZS';

	uint256 public totalSupply = 44000000000000000;

	address public icoWallet;
	uint256 public icoSupply = 33440000000000000;

	address public advisorsWallet;
	uint256 public advisorsSupply = 1320000000000000;

	address public teamWallet;
	uint256 public teamSupply = 6600000000000000;

	address public marketingWallet;
	uint256 public marketingSupply = 1760000000000000;

	address public bountyWallet;
	uint256 public bountySupply = 880000000000000;

	mapping(address => uint) balances;
	mapping (address => mapping (address => uint256)) allowed;

	modifier onlyPayloadSize(uint size) {
		require(msg.data.length >= (size + 4));
		_;
	}

	function BazistaToken () public {
		balances[this] = totalSupply;
	}


	function setWallets(address _advisorsWallet, address _teamWallet, address _marketingWallet, address _bountyWallet) public onlyOwner {
		advisorsWallet = _advisorsWallet;
		_transferFrom(this, advisorsWallet, advisorsSupply);

		teamWallet = _teamWallet;
		_transferFrom(this, teamWallet, teamSupply);

		marketingWallet = _marketingWallet;
		_transferFrom(this, marketingWallet, marketingSupply);

		bountyWallet = _bountyWallet;
		_transferFrom(this, bountyWallet, bountySupply);
	}


	function setICO(address _icoWallet) public onlyOwner {
		icoWallet = _icoWallet;
		_transferFrom(this, icoWallet, icoSupply);
	}

	function () public{
		revert();
	}

	function balanceOf(address _owner) public constant returns (uint balance) {
		return balances[_owner];
	}
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool success) {
		_transferFrom(msg.sender, _to, _value);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		_transferFrom(_from, _to, _value);
		return true;
	}
	function _transferFrom(address _from, address _to, uint256 _value) internal {
		require(_value > 0);
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}
}

contract BazistaICO is owned {
	enum Status {WAIT_PRESALE, PRESALE, WAIT_SALE, SALE, STOP, FINISH, REFUND}
	using SafeMath for uint256;

	BazistaToken public token;

	Status public status = Status.WAIT_PRESALE;

	uint256 public crowdsaleTokens = 32120000000000000;
	uint256 public presaleTokens = 1320000000000000;

	uint256 public wireLimit = 6688000000000000;
	uint256 public soldTokens = 0;

	uint256 public presaleStart = 1510822800;	//2017-11-16 12:00:00
	uint256 public presaleEnd = 1511254800;		//2017-11-21 12:00:00
	uint256 public saleStart = 1512378000;		//2017-12-04 12:00:00
	uint256 public saleEnd = 1514970000;		//2018-01-03 12:00:00

	uint256 public salePrice = 1100000000000;
	uint256 public minTokens = 4180000000000000; //3800*salePrice
	uint256 public maxWeis = 30300000000000000000000; //30300 eth

	mapping(address => uint) deposits;

	function BazistaICO (
		address tokenAddress,
		address _owner
	) public {
		owner = _owner;
		token = BazistaToken(tokenAddress);
	}

	function () public payable {
		buy();
	}

	function getDeposits(address _owner) public constant returns (uint256 weis) {
		return deposits[_owner];
	}
	function getBonus(uint256 amount) public constant returns (uint256 bonus) {
		Status _status = getStatus();
		if(_status == Status.PRESALE) {
			return percentFrom(amount, 45);
		}

		require(_status == Status.SALE);

		if(now < (saleStart + 3 days)) {
			return percentFrom(amount, 30);
		}
		if(now < (saleStart + 11 days)) {
			return (amount / 5); //20%
		}
		if(now < (saleStart + 17 days)) {
			return percentFrom(amount, 15);
		}
		if(now < (saleStart + 23 days)) {
			return (amount / 10); //10%
		}
		if(now < (saleStart + 28 days)) {
			return (amount / 20); //5%
		}

		return 0;
	}

	function icoFinished() public constant returns (bool yes) {
		return (status == Status.FINISH || ((status == Status.REFUND) && (now > (saleEnd + 14 days))));
	}

	function status() public constant returns (Status _status){
		return getStatus();
	}
	function getStatus() internal constant returns (Status _status){
		if((status == Status.STOP) || (status == Status.FINISH) || (status == Status.REFUND)){
			return status;
		}

		if(now < presaleStart) {
			return Status.WAIT_PRESALE;
		}
		else if((now > presaleStart) && (now < presaleEnd)){
			return Status.PRESALE;
		}
		else if((now > presaleEnd) && ((now < saleStart))){
			return Status.WAIT_SALE;
		}
		else if((now > saleStart) && (now < saleEnd) && (this.balance < maxWeis)){
			return Status.SALE;
		}
		else {
			return Status.STOP;
		}
	}

	function percentFrom(uint256 from, uint8 percent) internal constant returns (uint256 val){
		val = from.mul(percent) / 100;
	}
	function calcTokens(uint256 _wei) internal constant returns (uint256 val){
		val = _wei.mul(salePrice) / (1 ether);
	}

	function canBuy() internal returns (bool apply){
		status = getStatus();

		if((status == Status.PRESALE)){
			return true;
		}
		else if((status == Status.SALE)) {
			if(presaleTokens>0){
				crowdsaleTokens = crowdsaleTokens.add(presaleTokens);
				presaleTokens = 0;
			}
			return true;
		}
		else{
			return false;
		}
	}

	function stopForce() public onlyOwner {
		require(getStatus() != Status.STOP);
		status = Status.STOP;
		saleEnd = now;
	}

	function saleStopped() public onlyOwner {
		require(getStatus() == Status.STOP);
		if(soldTokens < minTokens){
			status = Status.REFUND;
		}
		else{
			status = Status.FINISH;
		}
	}

	function _refund(address _to) internal {
		require(status == Status.REFUND);
		require(deposits[_to]>0);
		uint256 val = deposits[_to];
		deposits[_to] = 0;
		require(_to.send(val));
	}
	function refund() public {
		_refund(msg.sender);
	}
	function refund(address _to) public onlyOwner {
		_refund(_to);
	}

	function buy() public payable returns (uint256 tokens) {
		require((msg.value > 0) && canBuy());

		tokens = calcTokens(msg.value);
		soldTokens = soldTokens.add(tokens);
		tokens = tokens.add(getBonus(tokens));

		require(token.transfer(msg.sender, tokens));

		if(status == Status.PRESALE) {
			presaleTokens = presaleTokens.sub(tokens);
		}
		if(status == Status.SALE){
			crowdsaleTokens = crowdsaleTokens.sub(tokens);
		}

		deposits[msg.sender]=deposits[msg.sender].add(msg.value);
	}
	function addWire(address _to, uint tokens, uint bonus) public onlyOwner {
		require((tokens > 0) && (bonus >= 0) && canBuy());

		soldTokens = soldTokens.add(tokens);

		tokens = tokens.add(bonus);
		wireLimit = wireLimit.sub(tokens);

		require(wireLimit>=0);
		require(token.transfer(_to, tokens));

		if(status == Status.PRESALE) {
			presaleTokens = presaleTokens.sub(tokens);
		}
		if(status == Status.SALE){
			crowdsaleTokens = crowdsaleTokens.sub(tokens);
		}
	}

	function addUnsoldTokens() public onlyOwner {
		require((now > (saleEnd + 60 days)) && (token.balanceOf(this) > 0));

		require(token.transfer(token.marketingWallet(), token.balanceOf(this)));
	}

	function sendAllFunds(address receiver) public onlyOwner {
		sendFunds(this.balance, receiver);
	}

	function sendFunds(uint amount, address receiver) public onlyOwner {
		require(icoFinished());
		if(status == Status.REFUND){
			status == Status.FINISH;
		}
		require((this.balance >= amount) && receiver.send(amount));
	}
}