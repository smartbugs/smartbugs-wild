pragma solidity ^0.4.18;

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

contract Ownable {
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function Ownable() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

contract ERC20Basic {
	uint256 public totalSupply;
	uint256 freezeTransferTime;
	function balanceOf(address who) public constant returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {

	using SafeMath for uint256;
	mapping(address => uint256) balances;

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
        require(now >= freezeTransferTime);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balances[_owner];
	}
}

contract StandardToken is ERC20, BasicToken {

	mapping (address => mapping (address => uint256)) allowed;

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(now >= freezeTransferTime);

		var _allowance = allowed[_from][msg.sender];
		balances[_to] = balances[_to].add(_value);
		balances[_from] = balances[_from].sub(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
}

contract MintableToken is StandardToken, Ownable {

	event Mint(address indexed to, uint256 amount);
	event MintFinished();

	bool public mintingFinished = false;

	modifier canMint() {
		require(!mintingFinished);
		_;
	}

	function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
		totalSupply = totalSupply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		return true;
	}

	function finishMinting() public onlyOwner returns (bool) {
		mintingFinished = true;
		MintFinished();
		return true;
	}
}

contract SIGToken is MintableToken {

	string public constant name = "Saxinvest Group Coin";
	string public constant symbol = "SIG";
	uint32 public constant decimals = 18;

	function SIGToken(uint256 _freezeTransferTime) public {
		freezeTransferTime = _freezeTransferTime;
	}
}

contract SIGICO is Ownable {
	using SafeMath for uint256;

	SIGToken public token;

	uint256 public startTime;
	uint256 public endTime;
	uint256 public freezeTransferTime;

	bool public isFinalized = false;

	uint256 Round1 = 1517000399; // first round end time
	uint256 Round2 = 1519851599; // second round end time

	address SafeAddr = 0x99C5FAb804600C8504EEeE0908251b0504B6354A;

	address FundOwnerAddr_1 = 0x8C6Ef7697b14bD32Be490036566396B0bc821569;
	address FundOwnerAddr_2 = 0xEeE2A9aE8db4bd43E72aa912dD908557D5D23891;
	address FundOwnerAddr_3 = 0x8f89f10C379cD244c451Df6aD4a569aFe567c22f;

	address ReserveFundAddr = 0xC9a5E3c3ed6c340dD10F87fe35929d93fee642Ed;

	address DeveloperTokensStoreAddr = 0x0e22b0Baa6714A8Dd18dC966002E02b5116522EF;
	address OtherTokensStoreAddr = 0x53E936299f2b7A7173A81B28C93591C880aDfD45;

	uint256 rate;
	uint256 TotalBuyers;
	uint256 PercentageForFounders = 10;
	uint256 PercentageForReserveFund = 5;
	uint256 PercentageForDevelopers = 3;
	uint256 PercentageForOther = 2;
	uint256 tokenCost;

	mapping (address => bool) Buyers;
	mapping (uint8 => uint256) BonusTokens;
	mapping (uint8 => uint256) Restricted;

	event TokenPurchase(address indexed sender, address indexed buyer, uint8 round, uint256 rate, uint256 weiAmount, uint256 tokens, uint256 bonus);
	event ChangeRate(uint256 changeTime, uint256 prevRate, uint256 newRate, uint256 prevSupply);
	event Finalized();

	function SIGICO(uint256 _startTime, uint256 _endTime, uint256 _rate) public {
		require(_startTime >= now);
		require(_endTime >= _startTime);
		require(_rate > 0);

		freezeTransferTime = _endTime.add(90 * 1 days);
        token = new SIGToken(freezeTransferTime);

		startTime = _startTime;
		endTime = _endTime;
		rate = _rate;

		tokenCost = uint256(1 ether).div(rate);
	}

	function () external payable {
		buyTokens(msg.sender);
	}

	function buyTokens(address buyer) public payable {
		require(buyer != address(0));
		require(validPurchase());

		uint256 tokens = rate.mul(msg.value).div(1 ether);
		uint256 tokens2mint = 0;
        uint256 bonus = 0;
        uint8 round = 3;

		if(now < Round1){
            round = 1;
			bonus = tokens.mul(20).div(100);
            BonusTokens[round] += bonus;
		}else if(now > Round1 && now < Round2){
            round = 2;
			bonus = tokens.mul(10).div(100);
            BonusTokens[round] += bonus;
		}

		tokens += bonus;
        tokens2mint = tokens.mul(1 ether);
		token.mint(buyer, tokens2mint);
		TokenPurchase(msg.sender, buyer, round, rate, msg.value, tokens, bonus);

        if(Buyers[buyer] != true){
			TotalBuyers += 1;
			Buyers[buyer] = true;
		}

		forwardFunds();
	}

	function forwardFunds() internal {
		SafeAddr.transfer(msg.value);
	}

	function validPurchase() internal view returns (bool) {
		bool withinPeriod = now >= startTime && now <= endTime;
		bool nonZeroPurchase = msg.value != 0;
		bool haveEnoughEther = msg.value >= tokenCost;
		return withinPeriod && nonZeroPurchase && haveEnoughEther;
	}

	function hasEnded() public view returns (bool) {
		return now > endTime;
	}

	function finalize() onlyOwner public {
		require(!isFinalized);
		require(hasEnded());
		finalization();
		Finalized();
		isFinalized = true;
	}

	function finalization() internal {
		uint256 totalSupply = token.totalSupply().div(1 ether);

		uint256 tokens = totalSupply.mul(PercentageForFounders).div(100 - PercentageForFounders);
		uint256 tokens2mint = tokens.mul(1 ether);
		token.mint(FundOwnerAddr_1, tokens2mint);
		token.mint(FundOwnerAddr_2, tokens2mint);
		token.mint(FundOwnerAddr_3, tokens2mint);
		Restricted[1] = tokens.mul(3);

		tokens = totalSupply.mul(PercentageForDevelopers).div(100 - PercentageForDevelopers);
        tokens2mint = tokens.mul(1 ether);
		token.mint(DeveloperTokensStoreAddr, tokens2mint);
		Restricted[2] = tokens;

		tokens = totalSupply.mul(PercentageForOther).div(100 - PercentageForOther);
        tokens2mint = tokens.mul(1 ether);
		token.mint(OtherTokensStoreAddr, tokens2mint);
		Restricted[3] = tokens;

		tokens = totalSupply.mul(PercentageForReserveFund).div(100 - PercentageForReserveFund);
		tokens2mint = tokens.mul(1 ether);
		token.mint(ReserveFundAddr, tokens2mint);
		Restricted[4] = tokens;

		token.finishMinting();
	}

	function changeRate(uint256 _rate) onlyOwner public returns (uint256){
		require(!isFinalized);
		require(_rate > 0);
		uint256 totalSupply = token.totalSupply().div(1 ether);
		tokenCost = uint256(1 ether).div(_rate);
		ChangeRate(now, rate, _rate, totalSupply);
		rate = _rate;
		return rate;
	}

	function getRestrictedTokens(uint8 _who) onlyOwner public constant returns (uint256){
		require(isFinalized);
		require(_who <= 4);
		return Restricted[_who];
	}

	function getBonusTokens(uint8 _round) onlyOwner public constant returns (uint256){
		require(_round < 3);
		return BonusTokens[_round];
	}

	function getTotalBuyers() onlyOwner public constant returns (uint256){
		return TotalBuyers;
	}
}