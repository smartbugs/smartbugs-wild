pragma solidity ^0.4.11;

contract SPGForEver {

    string public constant name = "SPG For Ever";      //  token name
    string public constant symbol = "SPG";         //  token symbol
    uint256 public constant decimals = 18;          //  token digit

    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public lockOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 10000000000 *  10 ** decimals;
    address owner = 0x0;

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function SPGForEver(address _addressFounder) public{
        owner = msg.sender;
        totalSupply = valueFounder;
        balanceOf[_addressFounder] = valueFounder;
        Transfer(0x0, _addressFounder, valueFounder);
    }

    function transfer(address _to, uint256 _value) public isRunning validAddress returns (bool success) {
        require(balanceOf[msg.sender] - lockOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public isRunning validAddress returns (bool success) {
        require(balanceOf[_from] - lockOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)public isRunning validAddress returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function setLock(address _owner, uint256 _value) public isOwner validAddress returns (bool success) {
        require(_value >= 0);
        if (_value > balanceOf[_owner]) {
            _value = balanceOf[_owner];
        }
        lockOf[_owner] = _value;
        SetLock(msg.sender, _owner, _value);
        return true;
    }

    function stop() public isOwner {
        stopped = true;
    }

    function start()public isOwner {
        stopped = false;
    }

    function burn(uint256 _value)public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[0x0] += _value;
        Transfer(msg.sender, 0x0, _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event SetLock(address indexed _sender, address indexed _owner, uint256 _value);
}