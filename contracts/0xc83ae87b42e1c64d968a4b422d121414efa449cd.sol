pragma solidity ^0.4.16;

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a / b;
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


contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}

contract BasicToken is owned {
    using SafeMath for uint256;

    // Token Variables Initialization
    string public constant name = "Valorem";
    string public constant symbol = "VLR";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    uint256 constant initialSupply = 200000000 * (10 ** uint256(decimals));

    address public reserveAccount;
    address public bountyAccount;

    uint256 reserveToken;
    uint256 bountyToken;

    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public balanceOf;

    event Burn(address indexed _from,uint256 _value);
    event FrozenFunds(address _account, bool _frozen);
    event Transfer(address indexed _from,address indexed _to,uint256 _value);

    function BasicToken () {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

        bountyTransfers();
    }

    function bountyTransfers() internal {
        reserveAccount = 0x000f1505CdAEb27197FB652FB2b1fef51cdc524e;
        bountyAccount = 0x00892214999FdE327D81250407e96Afc76D89CB9;

        reserveToken = ( totalSupply * 25 ) / 100;
        bountyToken = ( reserveToken * 7 ) / 100;

        balanceOf[msg.sender] = totalSupply - reserveToken;
        balanceOf[bountyAccount] = bountyToken;
        reserveToken = reserveToken - bountyToken;
        balanceOf[reserveAccount] = reserveToken;

        Transfer(msg.sender,reserveAccount,reserveToken);
        Transfer(msg.sender,bountyAccount,bountyToken);
    }

    function _transfer(address _from,address _to,uint256 _value) internal {
        require(balanceOf[_from] > _value);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
    }

    function transfer(address _to,uint256 _value) {
        _transfer(msg.sender, _to, _value);
    }

    function freezeAccount(address _account, bool _frozen) onlyOwner {
        frozenAccount[_account] = _frozen;
        FrozenFunds(_account, _frozen);
    }

    function burnTokens(uint256 _value) onlyOwner returns (bool success) {
        require(balanceOf[msg.sender] > _value);

        balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender,_value);

        return true;
    }

    function newTokens(address _owner, uint256 _value) onlyOwner {
        balanceOf[_owner] = balanceOf[_owner].add(_value);
        totalSupply = totalSupply.add(_value);
        Transfer(this, _owner, _value);
    }

    function escrowAmount(address _account, uint256 _value) onlyOwner {
        _transfer(msg.sender, _account, _value);
        freezeAccount(_account, true);
    }

    function () {
        revert();
    }

}