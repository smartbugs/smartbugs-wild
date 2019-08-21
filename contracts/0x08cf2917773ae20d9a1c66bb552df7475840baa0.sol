pragma solidity ^0.4.15;

contract Base {

    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }

    // *************************************************
    // *          reentrancy handling                  *
    // *************************************************
    uint private bitlocks = 0;

    modifier noAnyReentrancy {
        var _locks = bitlocks;
        require(_locks == 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }
}

contract IToken {
    function mint(address _to, uint _amount) public;
    function start() public;
    function getTotalSupply()  public returns(uint);
    function balanceOf(address _owner)  public returns(uint);
    function transfer(address _to, uint _amount)  public returns (bool success);
    function transferFrom(address _from, address _to, uint _value)  public returns (bool success);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract Owned is Base {
    address public owner;
    address newOwner;

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public only(owner) {
        newOwner = _newOwner;
    }

    function acceptOwnership() public only(newOwner) {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);
}

contract Crowdsale is Base, Owned {
    using SafeMath for uint256;

    enum State { INIT, BOUNTY, PREICO, PREICO_FINISHED, ICO, CLOSED, STOPPED }
    enum SupplyType { BOUNTY, SALE }

    uint public constant DECIMALS = 10**18;
    uint public constant MAX_PREICO_SUPPLY = 20000000 * DECIMALS;
    uint public constant MAX_ICO_SUPPLY = 70000000 * DECIMALS;
    uint public constant MAX_BOUNTY_SUPPLY = 10000000 * DECIMALS;

    State public currentState = State.INIT;
    IToken public token;

    uint public totalPreICOSupply = 0;
    uint public totalICOSupply = 0;
    uint public totalBountySupply = 0;

    uint public totalFunds = 0;
    uint public tokenPrice = 6000000000000; //wei
    uint public bonus = 2000; //20%
    uint public currentPrice;
    address public beneficiary;
    mapping(address => uint) balances;
    uint public countMembers = 0;

    uint private bonusBase = 10000; //100%;

    event Transfer(address indexed _to, uint256 _value);

    modifier inState(State _state){
        require(currentState == _state);
        _;
    }

    modifier salesRunning(){
        require(currentState == State.PREICO || currentState == State.ICO);
        _;
    }

    modifier notStopped(){
        require(currentState != State.STOPPED);
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
        only(owner)
        inState(State.INIT)
    {
        require(_token != address(0));

        token = IToken(_token);
        currentPrice = tokenPrice;
    }

    function setBonus(uint _bonus) public
        only(owner)
        notStopped
    {
        bonus = _bonus;
    }

    function getBonus()
        public
        constant
        returns(uint)
    {
        return bonus.mul(100).div(bonusBase);
    }

    function setTokenPrice(uint _tokenPrice) public
        only(owner)
        notStopped
    {
        currentPrice = _tokenPrice;
    }

    function setState(State _newState)
        public
        only(owner)
    {
        require(
            currentState != State.STOPPED && (_newState == State.STOPPED ||
            (currentState == State.INIT && _newState == State.BOUNTY
            || currentState == State.BOUNTY && _newState == State.PREICO
            || currentState == State.PREICO && _newState == State.PREICO_FINISHED
            || currentState == State.PREICO_FINISHED && _newState == State.ICO
            || currentState == State.ICO && _newState == State.CLOSED))
        );

        if(_newState == State.CLOSED){
            _finish();
        }

        currentState = _newState;
    }

    function investDirect(address _to, uint _amount)
        public
        only(owner)
        salesRunning
    {
        uint bonusTokens = _amount.mul(bonus).div(bonusBase);
        _amount = _amount.add(bonusTokens);

        _checkMaxSaleSupply(_amount);

        _mint(_to, _amount);
    }
    
    function investBounty(address _to, uint _amount)
        public
        only(owner)
        inState(State.BOUNTY)
    {
        _mint(_to, _amount);
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

        uint bonusTokens = transferTokens.mul(bonus).div(bonusBase);
        transferTokens = transferTokens.add(bonusTokens);

        _checkMaxSaleSupply(transferTokens);

        if(balances[msg.sender] == 0){
            countMembers = countMembers.add(1);
        }

        balances[msg.sender] = balances[msg.sender].add(weiAmount);
        totalFunds = totalFunds.add(weiAmount);

        _mint(msg.sender, transferTokens);
        beneficiary.transfer(weiAmount);
    }

    function _checkMaxSaleSupply(uint transferTokens)
        internal
    {
        if(currentState == State.PREICO) {
            require(totalPreICOSupply.add(transferTokens) <= MAX_PREICO_SUPPLY);
        } else if(currentState == State.ICO) {
            require(totalICOSupply.add(transferTokens) <= MAX_ICO_SUPPLY);
        }
    }
    
     function _increaseSupply(uint _amount)
        internal
    {
        if(currentState == State.PREICO) {
            totalPreICOSupply = totalPreICOSupply.add(_amount);
        } else if(currentState == State.ICO) {
            totalICOSupply = totalICOSupply.add(_amount);
        }
    }
}