pragma solidity ^0.4.18;

contract EIP20Interface {

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
    event FrozenFunds(address target, bool frozen);
}

contract TokenContract is EIP20Interface {
    
    uint256 constant MAX_UINT256 = 2**256 - 1;
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function () payable public {
    }

    uint256 public totalSupply;
    string public name;
    uint8 public decimals = 18;
    string public symbol;

    function TokenContract(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        owner = msg.sender;   
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!frozen[msg.sender]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(!frozen[msg.sender]);
        require(!frozen[_from]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!frozen[msg.sender]);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function burn(uint256 _value) public returns (bool success) {
        require(!frozen[msg.sender]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function transferOwnership(address _newOwner) public onlyOwner { 
        owner = _newOwner; 
    }

    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }

    function mintToken(address _target, uint256 _amount) public onlyOwner {
        balances[_target] += _amount;
        totalSupply += _amount;
        Transfer(0, owner, _amount);
        if (_target != owner) {
            Transfer(owner, _target, _amount);
        }
    }

    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        frozen[_target] = _freeze;
        FrozenFunds(_target, _freeze);
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) frozen;
}