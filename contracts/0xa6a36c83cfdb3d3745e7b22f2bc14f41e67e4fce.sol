pragma solidity ^0.4.25;

contract BaseToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract BurnToken is BaseToken {
    event Burn(address indexed from, uint256 value);

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}

contract ICOToken is BaseToken {
    // 1 ether = icoRatio token
    uint256 public icoRatio;
    uint256 public icoBalance = 500000000000000;
    address public owner;

    event ICO(address indexed from, uint256 indexed value, uint256 tokenValue);

    function() public payable {
        uint256 tokenValue = (msg.value * icoRatio * 10 ** uint256(decimals)) / (1 ether / 1 wei);
        if (tokenValue == 0 || icoBalance < tokenValue) {
            revert();
        }
        icoBalance -= tokenValue;
        _transfer(owner, msg.sender, tokenValue);
        uint256 balance = address(this).balance;
        owner.transfer(balance);
        emit ICO(msg.sender, msg.value, tokenValue);
    }
}

contract CustomToken is BaseToken, BurnToken, ICOToken {
    constructor() public {
        totalSupply = 1000000000000000000;
        owner = 0xD96a64a46d7912718a13eA5cccE3222500D8A58f;
        balanceOf[owner] = totalSupply;
        name = 'ONEDS';
        symbol = 'ONEDS';
        decimals = 8;
        icoRatio = 25000;
    }
}