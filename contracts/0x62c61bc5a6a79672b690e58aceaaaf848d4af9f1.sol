pragma solidity ^0.4.22;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

contract IWCEToken {

    using SafeMath for uint256;
    address owner = msg.sender;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) public airDroppedList;

    string public constant name = "IWC ecosystem";
    string public constant symbol = "IWCE";
    uint public constant decimals = 18;

    uint256 public totalSupply = 500000000 ether;

    uint256 public totalAirDropNum = 5000004 ether;

    uint256 public airDropNum = 18 ether;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed from, address indexed to, uint256 value);

    event AirDrop(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function IWCEToken() public {
        owner = msg.sender;
        balances[owner] = totalSupply.sub(totalAirDropNum);
    }

    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    function airDrop(address _to, uint256 _amount) private returns (bool) {
        totalAirDropNum = totalAirDropNum.sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit AirDrop(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function() external payable {
        getTokens();
    }

    function getTokens() internal {
        if (totalAirDropNum > 0 && airDroppedList[msg.sender] != true) {
            airDrop(msg.sender, airDropNum);
            airDroppedList[msg.sender] = true;
        }
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) {return false;}
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
}