pragma solidity ^0.4.21;

library SafeMath {
    function add(uint256 _a, uint256 _b) pure internal returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a && c >= _b);
        
        return c;
    }

    function sub(uint256 _a, uint256 _b) pure internal returns (uint256) {
        assert(_b <= _a);

        return _a - _b;
    }

    function mul(uint256 _a, uint256 _b) pure internal returns (uint256) {
        uint256 c = _a * _b;
        assert(_a == 0 || c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) pure internal returns (uint256) {
        assert(_b == 0);

        return _a / _b;
    }
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    function transfer(address _to, uint256 _value) public returns (bool _success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success);
    function approve(address _spender, uint256 _value) public returns (bool _success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TrexCoin is Token {
    using SafeMath for uint256;

    address public owner;
    uint256 public maxSupply;
    bool public stopped = false;

    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Stop();
    event Start();
    event Rename(string name, string symbol);

    modifier isOwner {
        assert(msg.sender == owner);
        _;
    }

    modifier isRunning {
        assert(!stopped);
        _;
    }

    modifier isValidAddress {
        assert(msg.sender != 0x0);
        _;
    }

    modifier hasPayloadSize(uint256 size) {
        assert(msg.data.length >= size + 4);
        _;
    }    

    function TrexCoin(uint256 _totalSupply, uint256 _maxSupply, string _name, string _symbol, uint8 _decimals) public {
        owner = msg.sender;
        decimals = _decimals;
        maxSupply = _maxSupply;
        name = _name;
        symbol = _symbol;
        _mint(owner, _totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) private returns (bool _success) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function transfer(address _to, uint256 _value) public isRunning isValidAddress hasPayloadSize(2 * 32) returns (bool _success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public isRunning isValidAddress hasPayloadSize(3 * 32) returns (bool _success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        
        return _transfer(_from, _to, _value);
    }

    function _approve(address _owner, address _spender, uint256 _value) private returns (bool _success) {
        allowance[_owner][_spender] = _value;

        emit Approval(_owner, _spender, _value);
        
        return true;
    }

    function approve(address _spender, uint256 _value) public isRunning isValidAddress hasPayloadSize(2 * 32) returns (bool _success) {
        return _approve(msg.sender, _spender, _value);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public isRunning isValidAddress hasPayloadSize(4 * 32) returns (bool _success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (_approve(msg.sender, _spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;
        }

        return false;
    }

    function _burn(address _from, uint256 _value) private returns (bool _success) {
        require(balanceOf[_from] >= _value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Burn(_from, _value);

        return true;
    }

    function burn(uint256 _value) public isRunning isValidAddress hasPayloadSize(32) returns (bool _success) {
        return _burn(msg.sender, _value);
    }

    function burnFrom(address _from, uint256 _value) public isRunning isValidAddress hasPayloadSize(2 * 32) returns (bool _success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        return _burn(_from, _value);
    }

    function _mint(address _to, uint256 _value) private {
        require(_to != 0x0);
        require(totalSupply + _value <= maxSupply);
        if (_value > 0) {
            totalSupply = totalSupply.add(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);

            emit Mint(_to, _value);
        }
    }

    function mint(uint256 _value) public isOwner {
        _mint(owner, _value);
    }

    function mintTo(address _to, uint256 _value) public isOwner {
        _mint(_to, _value);
    }

    function start() public isOwner {
        stopped = false;

        emit Start();
    }
    
    function stop() public isOwner {
        stopped = true;

        emit Stop();
    }

    function rename(string _name, string _symbol) public isOwner {
        name = _name;
        symbol = _symbol;

        emit Rename(_name, _symbol);
    }
}