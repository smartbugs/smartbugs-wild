pragma solidity 0.4.19;


contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}


// ERC20 Short Address Attack fix
contract InputValidator {
    modifier safeArguments(uint _numArgs) {
        assert(msg.data.length == _numArgs * 32 + 4);
        _;
    }
}


contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract EngravedCoin is ERC20, InputValidator, Owned {
    string public name = "Engraved Coin";
    string public symbol = "XEG";
    uint8 public decimals = 18;

    // Token state
    uint internal currentTotalSupply;

    // Token balances
    mapping (address => uint) internal balances;

    // Token allowances
    mapping (address => mapping (address => uint)) internal allowed;

    function EngravedCoin() public {
        owner = msg.sender;
        balances[msg.sender] = 0;
        currentTotalSupply = 0;
    }

    function () public payable {
        revert();
    }

    function totalSupply() public constant returns (uint) {
        return currentTotalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public safeArguments(2) returns (bool) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public safeArguments(3) returns (bool) {
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_to] += _value;
        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public safeArguments(2) returns (bool) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return allowed[_owner][_spender];
    }

    function issue(address _to, uint _value) public onlyOwner safeArguments(2) returns (bool) {
        require(balances[_to] + _value > balances[_to]);

        balances[_to] += _value;
        currentTotalSupply += _value;

        Transfer(0, this, _value);
        Transfer(this, _to, _value);

        return true;
    }

}