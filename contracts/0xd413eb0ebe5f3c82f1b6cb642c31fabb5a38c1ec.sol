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

contract TokenTimeLock {

    IToken public token;
    address public beneficiary;
    uint public releaseTimeFirst;
    uint public amountFirst;

    function TokenTimeLock(IToken _token, address _beneficiary, uint _releaseTimeFirst, uint _amountFirst)
    public
    {
        require(_releaseTimeFirst > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTimeFirst = _releaseTimeFirst;
        amountFirst = _amountFirst;
    }

    function releaseFirst() public {
        require(now >= releaseTimeFirst);
        uint amount = token.balanceOf(this);
        require(amount > 0 && amount >= amountFirst);
        token.transfer(beneficiary, amountFirst);
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

contract ATFSCrowdsale is Owned
{

    using SafeMath for uint;

    //
    //
    enum State { INIT, ICO, TOKEN_DIST, CLOSED, EMERGENCY_STOP }

    uint public constant MAX_SALE_SUPPLY 		= 35 * (10**15);
    uint public constant MAX_NON_SALE_SUPPLY 	= 18 * (10**15);

    State public currentState = State.INIT;

    IToken public token;

    uint public totalSaleSupply 	= 0;
    uint public totalNonSaleSupply 	= 0;

    mapping( address => TokenTimeLock ) lockBalances;

    modifier inState( State _state ) {
        require(currentState == _state);
        _;
    }

    modifier inICOExtended( ) {
        require( currentState == State.ICO || currentState == State.TOKEN_DIST );
        _;
    }

    //
	// constructor
	//
  //
  // constructor
  //
  function ATFSCrowdsale( ) public {
  }

  function setToken( IToken _token ) public only( owner ) {
    require( _token != address( 0 ) );
      token = _token;
    }

    //
    // change state
    //
    // no chance to recover from EMERGENY_STOP ( just never do that ?? )
    //
    function setState( State _newState ) public only(owner)
    {
        require(
           ( currentState == State.INIT && _newState == State.ICO )
        || ( currentState == State.ICO && _newState == State.TOKEN_DIST )
        || ( currentState == State.TOKEN_DIST && _newState == State.CLOSED )
        || _newState == State.EMERGENCY_STOP
        );
        currentState = _newState;
        if( _newState == State.CLOSED ) {
            _finish( );
        }
    }

    //
    // mint to investor ( sale )
    //
    function mintInvestor( address _to, uint _amount ) public only(owner) inState( State.TOKEN_DIST )
    {
     	require( totalSaleSupply.add( _amount ) <= MAX_SALE_SUPPLY );
        totalSaleSupply = totalSaleSupply.add( _amount );
        _mint( _to, _amount );
    }

    //
    // mint to partner ( non-sale )
    //
    function mintPartner( address _to, uint _amount ) public only( owner ) inState( State.TOKEN_DIST )
    {
    	require( totalNonSaleSupply.add( _amount ) <= MAX_NON_SALE_SUPPLY );
    	totalNonSaleSupply = totalNonSaleSupply.add( _amount );
    	_mint( _to, _amount );
    }

    //
    // mint to partner with lock ( non-sale )
    //
    // [caution] do not mint again before token-receiver retrieves the previous tokens
    //
    function mintPartnerWithLock( address _to, uint _amount, uint _unlockDate ) public only( owner ) inICOExtended( )
    {
    	require( totalNonSaleSupply.add( _amount ) <= MAX_NON_SALE_SUPPLY );
        totalNonSaleSupply = totalNonSaleSupply.add( _amount );

        TokenTimeLock tokenTimeLock = new TokenTimeLock( token, _to, _unlockDate, _amount );
        lockBalances[_to] = tokenTimeLock;
        _mint( address(tokenTimeLock), _amount );
    }

    function unlockAccount( ) public inState( State.CLOSED )
    {
        require( address( lockBalances[msg.sender] ) != 0 );
        lockBalances[msg.sender].releaseFirst();
    }

    //
    // mint to private investor ( sale, ICO )
    //
    function mintPrivate( address _to, uint _amount ) public only( owner ) inState( State.ICO )
    {
    	require( totalSaleSupply.add( _amount ) <= MAX_SALE_SUPPLY );
    	totalSaleSupply = totalSaleSupply.add( _amount );
    	_mint( _to, _amount );
    }

    //
    // internal function
    //
    function _mint( address _to, uint _amount ) noAnyReentrancy internal
    {
        token.mint( _to, _amount );
    }

    function _finish( ) noAnyReentrancy internal
    {
        token.start( );
    }
}