pragma solidity ^0.4.18;

contract ERC20Interface {

  // Events ---------------------------

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  // Functions ------------------------

  function totalSupply() constant returns (uint);
  function balanceOf(address _owner) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address _from, address _to, uint _value) returns (bool success);
  function approve(address _spender, uint _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint remaining);

}

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

contract TriipBooking is ERC20Interface {

		using SafeMath for uint256;
    
    uint public constant _totalSupply = 50 * 10 ** 24;
    
    string public constant name = "TripBooking";
    string public constant symbol = "TRP";
    uint8 public constant decimals = 18;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address=>uint256)) allowed;

		uint256 public constant developmentTokens = 15 * 10 ** 24;
    uint256 public constant bountyTokens = 2.5 * 10 ** 24;
		address public constant developmentTokensWallet = 0x27Aa956546Cd747D730CBd82b29a2Fa5b6BeE02a;
		address public constant bountyTokensWallet = 0xc377f0B79aD77996a15ED7eFb450DDC760a02b45;

		uint public constant startTime = 1516406400;

    uint public constant endTime = 1520899140;
		uint256 public constant icoTokens = 32.5 * 10 ** 24;
		uint256 public totalCrowdsale;

		 address public owner;
    
	function TriipBooking() {

		balances[developmentTokensWallet] = balanceOf(developmentTokensWallet).add(developmentTokens);
		Transfer(address(0), developmentTokensWallet, developmentTokens);
		balances[bountyTokensWallet] = balanceOf(bountyTokensWallet).add(bountyTokens);
		Transfer(address(0), bountyTokensWallet, bountyTokens);

		// ToDo
		owner = msg.sender;
	}

	function () payable {
        createTokens();
    }
	function createTokens() public payable {
			uint ts = atNow();
	    require(msg.value > 0 );
			require(ts < endTime );
      require(ts >= startTime );
			uint256 tokens = msg.value.mul(getConversionRate());
			require(validPurchase(msg.value,tokens));

	    balances[msg.sender] = balances[msg.sender].add(tokens);
			totalCrowdsale = totalCrowdsale.add(tokens);
			owner.transfer(msg.value);
	}	
	
	function totalSupply() constant returns (uint256 totalSupply) {
		return _totalSupply;
		
	}
	function balanceOf(address _owner) constant returns (uint256 balance)
	{
		// ToDo
		return balances[_owner];
	}
	function transfer(address _to, uint256 _value) returns (bool success){
		// ToDo
		require(
		    balances[msg.sender] >= _value
		    && _value > 0
		);
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender,_to,_value);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
		require(
		    allowed[_from][msg.sender] >= _value
		    && balances[_from] >= _value
		    && _value > 0
		);
		balances[_from] -= _value;
		balances[_to] += _value;
		allowed[_from][msg.sender] -= _value ;
		Transfer(_from, _to, _value);
		return true;
	}
	function approve(address _spender, uint256 _value) returns (bool success){
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender,_spender, _value);
		return true;
	}
	
	function allowance(address _owner, address _spender) constant returns (uint256 remaining){
        return allowed[_owner][_spender];
	}
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	function getConversionRate() public constant returns (uint256) {
			uint ts = atNow();
			if (ts >= 1520294340) {
					return 3200;
			} else if (ts >= 1519689540) {
					return 3520;
			} else if (ts >= 1518998340) {
					return 3840;
			} else if (ts >= 1518307140 ) {
					return 4160;
			} else if (ts >= startTime) {
					return 4480;
			}
			return 0;
	}
	function validPurchase(uint256 _value, uint256 _tokens) internal constant returns (bool) {
			bool nonZeroPurchase = _value != 0;
			bool withinPeriod = now >= startTime && now <= endTime;
			bool withinICOTokens = totalCrowdsale.add(_tokens) <= icoTokens;

			return nonZeroPurchase && withinPeriod && withinICOTokens;

	}
	function atNow() constant public returns (uint) {
    return now;
  }

}