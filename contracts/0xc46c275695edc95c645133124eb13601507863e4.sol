pragma solidity ^0.4.17;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

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

contract TokenTimeLock {
    IToken public token;

    address public beneficiary;

    uint public releaseTimeFirst;
    uint public amountFirst;

    uint public releaseTimeSecond;
    uint public amountSecond;


    function TokenTimeLock(IToken _token, address _beneficiary, uint _releaseTimeFirst, uint _amountFirst, uint _releaseTimeSecond, uint _amountSecond)
    public
    {
        require(_releaseTimeFirst > now && _releaseTimeSecond > now);
        token = _token;
        beneficiary = _beneficiary;

        releaseTimeFirst = _releaseTimeFirst;
        releaseTimeSecond  = _releaseTimeSecond;
        amountFirst = _amountFirst;
        amountSecond = _amountSecond;
    }

    function releaseFirst() public {
        require(now >= releaseTimeFirst);

        uint amount = token.balanceOf(this);
        require(amount > 0 && amount >= amountFirst);

        token.transfer(beneficiary, amountFirst);
    }

    function releaseSecond() public {
        require(now >= releaseTimeSecond);

        uint amount = token.balanceOf(this);
        require(amount > 0 && amount >= amountSecond);

        token.transfer(beneficiary, amountSecond);
    }
}

contract Base {
    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }

    // *************************************************
    // *          reentrancy handling                  *
    // *************************************************

    uint constant internal L00 = 2 ** 0;
    uint constant internal L01 = 2 ** 1;
    uint constant internal L02 = 2 ** 2;
    uint constant internal L03 = 2 ** 3;
    uint constant internal L04 = 2 ** 4;
    uint constant internal L05 = 2 ** 5;

    uint private bitlocks = 0;

    modifier noAnyReentrancy {
        var _locks = bitlocks;
        require(_locks == 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }

}

contract Owned is Base {

    address public owner;
    address newOwner;

    function Owned() {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) only(owner) {
        newOwner = _newOwner;
    }

    function acceptOwnership() only(newOwner) {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);

}

contract IToken {
    function mint(address _to, uint _amount);
    function start();
    function getTotalSupply() returns(uint);
    function balanceOf(address _owner) returns(uint);
    function transfer(address _to, uint _amount) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
}

contract Crowdsale is Owned {
    using SafeMath for uint;

    enum State { INIT, PRESALE, PREICO, PREICO_FINISHED, ICO, CLOSED, EMERGENCY_STOP}
    uint public constant MAX_SALE_SUPPLY = 26 * (10**24);

    State public currentState = State.INIT;
    IToken public token;
    uint public totalSaleSupply = 0;
    uint public totalFunds = 0;
    uint public tokenPrice = 1000000000000000000; //wei
    uint public bonus = 5000; //50%
    uint public currentPrice;
    address public beneficiary;
    mapping(address => uint) balances;
    mapping(address => TokenTimeLock) lockBalances;
    mapping(address => uint) prices;

    uint private bonusBase = 10000; //100%;

    address confirmOwner = 0x40e72D1052A1bd4c40E5850DAC46C8B44e366a59;
    
    event Transfer(address indexed _to, uint _value);

    modifier onlyConfirmOwner(){
        require(msg.sender == confirmOwner);
        _;
    }
    
    modifier inState(State _state){
        require(currentState == _state);
        _;
    }

    modifier salesRunning(){
        require(currentState == State.PREICO || currentState == State.ICO);
        _;
    }

    function Crowdsale(address _beneficiary){
        beneficiary = _beneficiary;
    }

    function initialize(IToken _token)
    public
    only(owner)
    inState(State.INIT)
    {
        require(_token != address(0));

        token = _token;
        currentPrice = tokenPrice.mul(bonus).div(bonusBase);
    }

    function setBonus(uint _bonus) public
    only(owner)
    {
        bonus = _bonus;
        currentPrice = tokenPrice.mul(bonus).div(bonusBase);
    }

    function setPrice(uint _tokenPrice)
    public
    only(owner)
    {
        tokenPrice = _tokenPrice;
        currentPrice = tokenPrice.mul(bonus).div(bonusBase);
    }

    function setState(State _newState)
    public
    only(owner)
    {
        require(
        currentState == State.INIT && _newState == State.PRESALE
        || currentState == State.PRESALE && _newState == State.PREICO
        || currentState == State.PREICO && _newState == State.PREICO_FINISHED
        || currentState == State.PREICO_FINISHED && _newState == State.ICO
        || currentState == State.ICO && _newState == State.CLOSED
        || _newState == State.EMERGENCY_STOP
        );

        currentState = _newState;

        if(_newState == State.CLOSED){
            _finish();
        }
    }

    function mintPresaleWithBlock(address _to, uint _firstStake, uint _firstUnblockDate, uint _secondStake, uint _secondUnblockDate)
    public
    only(owner)
    inState(State.PRESALE)
    {
        uint totalAmount = _firstStake.add(_secondStake);
        require(totalSaleSupply.add(totalAmount) <= MAX_SALE_SUPPLY);

        totalSaleSupply = totalSaleSupply.add(totalAmount);

        TokenTimeLock tokenTimeLock = new TokenTimeLock(token, _to, _firstUnblockDate, _firstStake, _secondUnblockDate, _secondStake);
        lockBalances[_to] = tokenTimeLock;
        _mint(address(tokenTimeLock), totalAmount);
    }

    function unblockFirstStake()
    public
    inState(State.CLOSED)
    {
        require(address(lockBalances[msg.sender]) != 0);

        lockBalances[msg.sender].releaseFirst();
    }

    function unblockSecondStake()
    public
    inState(State.CLOSED)
    {
        require(address(lockBalances[msg.sender]) != 0);

        lockBalances[msg.sender].releaseSecond();
    }

    function mintPresale(address _to, uint _amount)
    public
    only(owner)
    inState(State.PRESALE)
    {
        require(totalSaleSupply.add(_amount) <= MAX_SALE_SUPPLY);

        totalSaleSupply = totalSaleSupply.add(_amount);

        _mint(_to, _amount);
    }

    function ()
    public
    payable
    salesRunning
    {
        _receiveFunds();
    }

    function setTokenPrice(address _token, uint _price)
    only(owner)
    {
        prices[_token] = _price;
    }

    function mint(uint _amount, address _erc20OrEth)
    public
    payable
    salesRunning
    {
        uint transferTokens;

        if(_erc20OrEth == address(0)){
            require(msg.value != 0);
            uint weiAmount = msg.value;
            transferTokens = weiAmount.div(currentPrice);
            require(totalSaleSupply.add(transferTokens) <= MAX_SALE_SUPPLY);

            totalSaleSupply = totalSaleSupply.add(transferTokens);
            balances[msg.sender] = balances[msg.sender].add(weiAmount);
            totalFunds = totalFunds.add(weiAmount);

            _mint(msg.sender, transferTokens);
            beneficiary.transfer(weiAmount);
            Transfer(msg.sender, transferTokens);
        } else {
            uint price = prices[_erc20OrEth];

            require(price > 0 && _amount > 0);

            transferTokens = _amount.div(price);
            require(totalSaleSupply.add(transferTokens) <= MAX_SALE_SUPPLY);

            totalSaleSupply = totalSaleSupply.add(transferTokens);
            balances[msg.sender] = balances[msg.sender].add(weiAmount);
            totalFunds = totalFunds.add(weiAmount);

            IToken(_erc20OrEth).transferFrom(msg.sender, beneficiary, transferTokens);
            Transfer(msg.sender, transferTokens);
        }
    }

    function refundBalance(address _owner)
    public
    constant
    returns(uint)
    {
        return balances[_owner];
    }
    
    function investDirect(address _to, uint _amount)
    public
    salesRunning
    onlyConfirmOwner
    {

        require(totalSaleSupply.add(_amount) <= MAX_SALE_SUPPLY);

        totalSaleSupply = totalSaleSupply.add(_amount);

        _mint(_to, _amount);
        Transfer(_to, _amount);
        
    }
    //==================== Internal Methods =================
    function _receiveFunds()
    internal
    {
        require(msg.value != 0);
        uint transferTokens = msg.value.div(currentPrice);
        require(totalSaleSupply.add(transferTokens) <= MAX_SALE_SUPPLY);

        totalSaleSupply = totalSaleSupply.add(transferTokens);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalFunds = totalFunds.add(msg.value);

        _mint(msg.sender, transferTokens);
        beneficiary.transfer(msg.value);
        Transfer(msg.sender, transferTokens);
    }
    function _mint(address _to, uint _amount)
    noAnyReentrancy
    internal
    {
        token.mint(_to, _amount);
    }

    function _finish()
    noAnyReentrancy
    internal
    {
        token.start();
    }
}