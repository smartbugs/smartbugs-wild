pragma solidity ^0.4.13;

contract Base {
    
    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }

    // *************************************************
    // *          reentrancy handling                  *
    // *************************************************

    uint private bitlocks = 0;
    modifier noReentrancy(uint m) {
        var _locks = bitlocks;
        require(_locks & m <= 0);
        bitlocks |= m;
        _;
        bitlocks = _locks;
    }

    modifier noAnyReentrancy {
        var _locks = bitlocks;
        require(_locks <= 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }

    modifier reentrant { _; }
}

contract Owned {
    address public owner;
    address public newOwner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) onlyOwner public {
        newOwner = _newOwner;
    }

    function acceptOwnership() onlyOwner public {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);
}

contract Crowdsale is Base, Owned {
    using SafeMath for uint256;

    enum State { INIT, ICO, CLOSED, PAUSE }

    uint public constant DECIMALS = 10**18;
    uint public constant WEI_DECIMALS = 10**18;
    uint public constant MAX_SUPPLY = 3400000000 * DECIMALS;

    mapping (address => bool) investors;
    State public currentState = State.INIT;
    IToken public token;

    uint public totalSupply = 0;

    uint public totalFunds = 0;
    uint public currentPrice = WEI_DECIMALS / 166;
    address public beneficiary;
    uint public countMembers = 0;

    event Transfer(address indexed _to, uint256 _value);

    modifier inState(State _state){
        require(currentState == _state);
        _;
    }

    modifier salesRunning(){
        require(currentState == State.ICO);
        _;
    }

    modifier notClosed(){
        require(currentState != State.CLOSED);
        _;
    }

    function Crowdsale(address _beneficiary) public {
        beneficiary = _beneficiary;
    }

    function ()
        public
        payable
        salesRunning
    {
        _receiveFunds();
    }

    function initialize(address _token)
        public
        onlyOwner
        inState(State.INIT)
    {
        require(_token != address(0));
        token = IToken(_token);
    }

    function setTokenPrice(uint _tokenPrice) public
        onlyOwner
        notClosed
    {
        currentPrice = _tokenPrice;
    }

    function setTokenPriceAsRatio(uint _tokenCount) public
        onlyOwner
        notClosed
    {
        currentPrice = WEI_DECIMALS / _tokenCount;
    }

    function setState(State _newState)
        public
        onlyOwner
    {
        require(currentState != State.CLOSED);
        require(
            (currentState == State.INIT && _newState == State.ICO ||
             currentState == State.ICO && _newState == State.CLOSED ||
            currentState == State.ICO && _newState == State.PAUSE ||
            currentState == State.PAUSE && _newState == State.ICO)
        );

        if(_newState == State.CLOSED){
            _finish();
        }
        currentState = _newState;
    }


    function withdraw(uint _amount)
        public
        noAnyReentrancy
        onlyOwner
    {
        require(_amount > 0 && _amount <= this.balance);
        beneficiary.transfer(_amount);
    }

    function sendToken(address _to, uint _amount)
        public
        onlyOwner
        salesRunning
    {
        uint amount = _amount.mul(DECIMALS);
        _checkMaxSaleSupply(amount);
        _mint(_to, amount);
    }


    function getCountMembers()
        public
        constant
        returns(uint)
    {
        return countMembers;
    }


    //==================== Internal Methods =================
    function _mint(address _to, uint _amount)
        noAnyReentrancy
        internal
    {
        _increaseSupply(_amount);
        IToken(token).mint(_to, _amount);
        Transfer(_to, _amount);
    }

    function _finish()
        noAnyReentrancy
        internal
    {
        IToken(token).start();
    }

    function _receiveFunds()
        internal
    {
        require(msg.value != 0);
        uint weiAmount = msg.value;
        uint transferTokens = weiAmount.mul(DECIMALS).div(currentPrice);

        _checkMaxSaleSupply(transferTokens);

        if(!investors[msg.sender]){
            countMembers = countMembers.add(1);
            investors[msg.sender] = true;
        }
        totalFunds = totalFunds.add(weiAmount);
        _mint(msg.sender, transferTokens);
    }

    function _checkMaxSaleSupply(uint transferTokens)
        internal
    {
        require(totalSupply.add(transferTokens) <= MAX_SUPPLY);
    }

    function _increaseSupply(uint _amount)
        internal
    {
        totalSupply = totalSupply.add(_amount);
    }

}

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

contract IToken {
  uint256 public totalSupply;
  function mint(address _to, uint _amount) public returns(bool);
  function start() public;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract TokenTimelock {
  IToken public token;
  address public beneficiary;
  uint64 public releaseTime;

  function TokenTimelock(address _token, address _beneficiary, uint64 _releaseTime) public {
    require(_releaseTime > now);
    token = IToken(_token);
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  function release() public {
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.transfer(beneficiary, amount);
  }
}