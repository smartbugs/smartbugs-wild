pragma solidity ^0.4.25;

contract Token{
    using SafeMath for *;
    uint256 public totalSupply;
    string public name;                 //name of token
    string public symbol;               //symbol of token
    uint256 public decimals;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns
    (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256  _value);
}

contract owned {
    address public owner;
    bool public paused;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier normal {
        require(!paused);
        _;
    }

    function upgradeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function setPaused(bool _paused) onlyOwner public {
        paused = _paused;
    }
}

contract BonusState{
    constructor(address _tokenAddress) public{
        tokenAddress = _tokenAddress;
        settlementTime = 10 days + now;
    }

    //balance for bonus compute withdraw, when withdraw and balance is zero means
    //1. no balance for owner
    //2. nerver update state
    //so when withdraw, check balance state, when state is zero, check token balance
    mapping(address=>uint256) balanceState;
    //state is true while withdrawed
    mapping(address=>bool) withdrawState;
    //computedTotalBalance means this amount has been locked for withdraw, so when computing lockBonus,base amount will exclude this amount
    uint256 computedTotalBalance = 0;
    //price for token holder use this to compute withdrawable bonus for unit amount(unit amount means one exclude decimals)
    uint256 computedUnitPrice = 0;
    //while times up, next transaction for contract will auto settle bonus
    uint256 settlementTime = 0;


    //token contract address, only contract can operate this state contract
    address public tokenAddress;
    modifier onlyToken {
        require(msg.sender == tokenAddress);
        _;
    }

    function getSettlementTime() public view returns(uint256 _time){
        return settlementTime;
    }

    function setBalanceState(address _target,uint256 _amount) public onlyToken{
        balanceState[_target] = _amount;
    }

    function getBalanceState(address _target) public view returns (uint256 _balance) {
        return balanceState[_target];
    }


    function setWithdrawState(address _target,bool _state) public onlyToken{
        withdrawState[_target] = _state;
    }

    function getWithdrawState(address _target) public view returns (bool _state) {
        return withdrawState[_target];
    }


    function setComputedTotalBalance(uint256 _amount) public onlyToken{
        computedTotalBalance = _amount;
    }

    function setComputedUnitPrice(uint256 _amount) public onlyToken{
        computedUnitPrice = _amount;
    }

    function getComputedTotalBalance() public view returns(uint256){
        return computedTotalBalance;
    }

    function getComputedUnitPrice() public view returns(uint256){
        return computedUnitPrice;
    }

}

contract EssToken is Token,owned {

    //bonus state never change for withdraw;
    address public bonusState_fixed;

    //bonus state change while balance modified by transfer
    address public bonusState;

    //transfer eth to contract means incharge the bonus
    function() public payable normal{
        computeBonus(msg.value);
    }
    function incharge() public payable normal{
        computeBonus(msg.value);
    }

    uint256 public icoTotal;

    uint256 public airdropTotal;

    //empty token while deploy the contract, token will minted by ico or minted by owner after ico
    constructor() public {
        decimals = 18;
        name = "Ether Sesame";
        symbol = "ESS";
        totalSupply = 100000000 * 10 ** decimals;
        icoTotal = totalSupply * 30 / 100; //30% for ico
        airdropTotal = totalSupply * 20 / 100;  //20% for airdrop
        uint256 _initAmount = totalSupply - icoTotal - airdropTotal;
        bonusState = new BonusState(address(this));
        _mintToken(msg.sender,_initAmount);
    }

    function transfer(address _to, uint256 _value) public normal returns (bool success) {
        computeBonus(0);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public normal returns
    (bool success) {
        computeBonus(0);
        require(_value <= allowed[_from][msg.sender]);     // Check allowed
        allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public normal returns (bool success)
    {
        computeBonus(0);
        allowed[tx.origin][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数
    }
    //end for ERC20 Token standard

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);

        //update bonus state when balance changed
        BonusState(bonusState).setBalanceState(_from,balances[_from]);
        BonusState(bonusState).setBalanceState(_to,balances[_to]);
    }

    //mint token for ico purchase or airdrop
    function _mintToken(address _target, uint256 _mintAmount) internal {
        require(_mintAmount>0);
        balances[this] = (balances[this]).add(_mintAmount);
        //update bonus state when balance changed
        BonusState(bonusState).setBalanceState(address(this),balances[this]);
        _transfer(this,_target,_mintAmount);
    }

    //check lockbonus for target
    function lockedBonus(address _target) public view returns(uint256 bonus){
        if(BonusState(bonusState).getSettlementTime()<=now)
	    {
	        return 0;
	    }
	    else{
	        uint256 _balance = balances[_target];
            uint256 _fixedBonusTotal = lockBonusTotal();

            uint256 _unitPrice = ((address(this).balance).sub(_fixedBonusTotal)).div(totalSupply.div(10**decimals));
            return _balance.mul(_unitPrice).div(10**decimals);
	    }
    }

	function lockBonusTotal() public view returns(uint256 bonus){
	    if(BonusState(bonusState).getSettlementTime()<=now)
	    {
	        return address(this).balance;
	    }
	    else{
	        uint256 _fixedBonusTotal = 0;
            if(bonusState_fixed!=address(0x0))
            {
                _fixedBonusTotal = BonusState(bonusState_fixed).getComputedTotalBalance();
            }
    		return _fixedBonusTotal;
	    }
	}

    function _withdrawableBonus(address _target) internal view returns(uint256 bonus){
        uint256 _unitPrice;
        uint256 _bonusBalance;
        if(BonusState(bonusState).getSettlementTime()<=now){
            _unitPrice = (address(this).balance).div(totalSupply.div(10**decimals));
            _bonusBalance = balances[_target];
            return _bonusBalance.mul(_unitPrice).div(10**decimals);
        }
        else{
            if(bonusState_fixed==address(0x0))
            {
                return 0;
            }
            else{
                bool _withdrawState = BonusState(bonusState_fixed).getWithdrawState(_target);
        		//withdraw only once for each bonus compute
        		if(_withdrawState)
        			return 0;
        		else
        		{
        			_unitPrice = BonusState(bonusState_fixed).getComputedUnitPrice();
        			_bonusBalance = BonusState(bonusState_fixed).getBalanceState(_target);
        			//when bonus balance is zero and withdraw state is false means possibly state never changed after last compute bonus
        			//so try to check token balance,if balance has token means never change state
        			if(_bonusBalance==0){
        				_bonusBalance = balances[_target];
        			}
        			return _bonusBalance.mul(_unitPrice).div(10**decimals);
        		}
            }
        }
    }

    function withdrawableBonus(address _target)  public view returns(uint256 bonus){
        return _withdrawableBonus(_target);
    }

    //compute bonus for withdraw and reset bonus state
    function computeBonus(uint256 _incharge) internal {
        if(BonusState(bonusState).getSettlementTime()<=now){
            BonusState(bonusState).setComputedTotalBalance((address(this).balance).sub(_incharge));
            BonusState(bonusState).setComputedUnitPrice((address(this).balance).sub(_incharge).div(totalSupply.div(10**decimals)));
            bonusState_fixed = bonusState; //set current bonus as fixed bonus state
            bonusState = new BonusState(address(this)); //deploy a new bonus state contract
        }
    }

    function getSettlementTime() public view returns(uint256 _time){
        return BonusState(bonusState).getSettlementTime();
    }

    //withdraw the bonus
    function withdraw() public normal{
        computeBonus(0);
        //calc the withdrawable amount
        uint256 _bonusAmount = _withdrawableBonus(msg.sender);
        msg.sender.transfer(_bonusAmount);

        //set withdraw state to true,means bonus has withdrawed
        BonusState(bonusState_fixed).setWithdrawState(msg.sender,true);
        uint256 _fixedBonusTotal = 0;
        if(bonusState_fixed!=address(0x0))
        {
            _fixedBonusTotal = BonusState(bonusState_fixed).getComputedTotalBalance();
        }
        BonusState(bonusState_fixed).setComputedTotalBalance(_fixedBonusTotal.sub(_bonusAmount));
    }

}

contract EtherSesame is EssToken{

    //about ico
    uint256 public icoCount;


    uint256 public beginTime;
    uint256 public endTime;

    uint256 public offeredAmount;

    //the eth price(wei) of one ess(one ess means number exclude the decimals)
    uint256 public icoPrice;

    function isOffering() public view returns(bool){
        return beginTime>0&&now>beginTime&&now<endTime&&icoTotal>0;
    }

    function startIco(uint256 _beginTime,uint256 _endTime,uint256 _icoPrice) public onlyOwner{
        require(_beginTime>0&&_endTime>_beginTime&&_icoPrice>0);
        beginTime  = _beginTime;
        endTime  = _endTime;
        icoPrice = _icoPrice;
        icoCount++;
    }

    function buy() public payable normal{
        computeBonus(msg.value);
        //ico activity is started and must buy one ess at least
        require(isOffering()&&msg.value>=icoPrice);
        uint256 _amount = (msg.value).div(icoPrice).mul(10**decimals);
        offeredAmount = offeredAmount.add(_amount);  //increase the offeredAmount for this round
        icoTotal = icoTotal.sub(_amount);
        owner.transfer(msg.value);
        _mintToken(msg.sender,_amount);
    }
    //end ico

    //about airdrop
    //authed address for airdrop
    address public airdropAuthAddress;
    //update airdrop auth
    function upgradeAirdropAuthAddress(address newAirdropAuthAddress) onlyOwner public {
        airdropAuthAddress = newAirdropAuthAddress;
    }
    modifier airdropAuthed {
        require(msg.sender == airdropAuthAddress);
        _;
    }

    //airdrop to player amount: (_ethPayment/_airdropPrice)
    function airdrop(uint256 _airdropPrice,uint256 _ethPayment) public airdropAuthed normal returns(uint256){
        computeBonus(0);
        if(_airdropPrice>0&&_ethPayment/_airdropPrice>0&&airdropTotal>0){
            uint256 _airdropAmount = _ethPayment.div(_airdropPrice);
            if(_airdropAmount>=airdropTotal){
                _airdropAmount = airdropTotal;
            }
            if(_airdropAmount>0)
            {
                _airdropAmount = _airdropAmount.mul(10 ** decimals);
                airdropTotal-=_airdropAmount;
                _mintToken(tx.origin,_airdropAmount);
            }
            return _airdropAmount;
        }
        else{
            return 0;
        }
    }
}

/**
 * @title SafeMath
 */
library SafeMath {

    /**
    * @dev divide two numbers, throws on overflow.
    */
    function div(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        require(b > 0);
        c = a / b;
        return c;
    }

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }

}