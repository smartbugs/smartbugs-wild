pragma solidity ^ 0.4.16;

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

contract GexCrypto is owned {
    using SafeMath for uint256;

    // Token Variables Initialization
    string public constant name = "GexCrypto";
    string public constant symbol = "GEX";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    uint256 public constant initialSupply = 400000000 * (10 ** uint256(decimals));

    address public reserveAccount;
    address public generalBounty;
    address public russianBounty;

    uint256 reserveToken;
    uint256 bountyToken;

    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public balanceOf;

    event Burn(address indexed _from,uint256 _value);
    event FrozenFunds(address _account, bool _frozen);
    event Transfer(address indexed _from,address indexed _to,uint256 _value);

    function GexCrypto() {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

        bountyTransfers();
    }

    function bountyTransfers() internal {
        reserveAccount = 0x0058106dF1650Bf1AdcB327734e0FbCe1996133f;
        generalBounty = 0x00667a9339FDb56A84Eea687db6B717115e16bE8;
        russianBounty = 0x00E76A4c7c646787631681A41ABa3514A001f4ad;
        reserveToken = ( totalSupply * 13 ) / 100;
        bountyToken = ( totalSupply * 2 ) / 100;

        balanceOf[msg.sender] = totalSupply - reserveToken - bountyToken;
        balanceOf[russianBounty] = bountyToken / 2;
        balanceOf[generalBounty] = bountyToken / 2;
        balanceOf[reserveAccount] = reserveToken;

        Transfer(msg.sender,reserveAccount,reserveToken);
        Transfer(msg.sender,generalBounty,bountyToken);
        Transfer(msg.sender,russianBounty,bountyToken);
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

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender,_value);

        return true;
    }

    function newTokens(address _owner, uint256 _value) onlyOwner {
        balanceOf[_owner] = balanceOf[_owner].add(_value);
        totalSupply = totalSupply.add(_value);
        Transfer(0, this, _value);
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