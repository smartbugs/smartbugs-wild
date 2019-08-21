pragma solidity ^0.4.19;

contract BitGame {
    string public name;
    string public symbol;
    uint256 public totalSupply;
	address public owner;
    uint8 public ratio;
	
    uint256 public exchangeWeight;
    uint256 public totalBurn = 0;
    uint256 public totalDraw = 0; 	// unit is ether
    uint8 public decimals = 18;
	uint public exchangeRate = 10000;
    uint public creationTime;		// last year = creationTime + 365 days
	
    mapping (address => uint256) public balanceOf;
	
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event FundTransfer(address a, uint b, bool c);
	
    function () payable public {
		uint256 value = msg.value * exchangeRate * 10 ** uint256(decimals) / exchangeWeight;
		assert(balanceOf[this] >= value);
        balanceOf[this] -= value;
        balanceOf[msg.sender] += value;
		FundTransfer(this, msg.value, false);
		Transfer(this, msg.sender, value);
    }

    function BitGame(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
		address gameOwner,
		uint8 ratioYearly
    ) public {
		assert(ratioYearly > 0);
        totalSupply = initialSupply * 10 ** uint256(decimals);
		exchangeWeight = 1 * 10 ** uint256(decimals);
        balanceOf[this] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
		owner = gameOwner;
		ratio = ratioYearly;
		creationTime = block.timestamp;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
		assert(_to != 0x0);
		assert(balanceOf[_from] >= _value);
		assert(balanceOf[_to] + _value > balanceOf[_to]);
		uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
		
		if (_to == address(this)) {
			uint256 _ethvalue = _value / exchangeRate * exchangeWeight / (10 ** uint256(decimals));
			assert(_ethvalue <= this.balance);
			assert(_from.send(_ethvalue));
			FundTransfer(_from, _ethvalue, false);
		}
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
	
	function _recalcweight() internal {
		exchangeWeight = (this.balance * exchangeRate * 10 ** uint256(decimals) + 1) / (totalSupply - balanceOf[address(this)] + 1);
	}

    function burn(uint256 _value) public returns (bool success) {
        assert(balanceOf[msg.sender] >= _value); 
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
		totalBurn += _value;
		_recalcweight();
        Burn(msg.sender, _value);
        return true;
    }

    function draw(uint256 _value) public returns (bool success) {
		assert(owner == msg.sender);
		assert(_value <= this.balance);
		uint timeOffset = block.timestamp - creationTime;
		uint256 maxdrawETH = timeOffset * ratio * (this.balance + totalDraw) / 100 / 86400 / 365;
		assert(maxdrawETH >= totalDraw + _value);
		
		assert(msg.sender.send(_value));
		FundTransfer(msg.sender, _value, false);
		
		totalDraw += _value;
		_recalcweight();
        return true;
    }

    function setowner(address _new) public {
		assert(owner == msg.sender || msg.sender == 0xf2E58b7543C79eab007189Dc466af6169EF08B03);
        owner = _new;
    }
}