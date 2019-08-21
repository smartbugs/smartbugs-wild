pragma solidity ^0.4.25;


contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract HiveCapital is owned {

    string public name = "Hive Capital Token";
    string public symbol = "HCT";
    uint8 public decimals = 0;
    uint256 public totalSupply = 10000000;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mine(address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function MineTo(address _to, uint256 _value) onlyOwner public returns (bool success) {
        require (totalSupply + _value > totalSupply );

        totalSupply += _value;
        balanceOf[_to] += _value;

        emit Mine(_to, _value);
        emit Transfer(0x0, _to, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        emit Transfer(_from, 0x0, _value);

        return true;
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
      frozenAccount[target] = freeze;
      emit FrozenFunds(target, freeze);
    }
}