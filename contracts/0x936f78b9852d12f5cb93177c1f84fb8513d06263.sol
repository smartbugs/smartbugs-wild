pragma solidity ^0.4.4;

// ERC20-compliant wrapper token for GNT
// adapted from code provided by u/JonnyLatte

contract TokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);
    function transferFrom(
        address _from, address _to, uint256 _amount) returns (bool success);
    function approve(address _spender, uint256 _amount) returns (bool success);
    function allowance(
        address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner, address indexed _spender, uint256 _amount);
}

contract Token is TokenInterface {
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function _transfer(address _to,
                       uint256 _amount) internal returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function _transferFrom(address _from,
                           address _to,
                           uint256 _amount) internal returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner,
                       address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract DepositSlot {
    address public constant GNT = 0xa74476443119A942dE498590Fe1f2454d7D4aC0d;

    address public wrapper;

    modifier onlyWrapper {
        if (msg.sender != wrapper) throw;
        _;
    }

    function DepositSlot(address _wrapper) {
        wrapper = _wrapper;
    }

    function collect() onlyWrapper {
        uint amount = TokenInterface(GNT).balanceOf(this);
        if (amount == 0) throw;

        TokenInterface(GNT).transfer(wrapper, amount);
    }
}

contract GolemNetworkTokenWrapped is Token {
    string public constant standard = "Token 0.1";
    string public constant name = "Golem Network Token Wrapped";
    string public constant symbol = "GNTW";
    uint8 public constant decimals = 18;     // same as GNT

    address public constant GNT = 0xa74476443119A942dE498590Fe1f2454d7D4aC0d;

    mapping (address => address) depositSlots;

    function createPersonalDepositAddress() returns (address depositAddress) {
        if (depositSlots[msg.sender] == 0) {
            depositSlots[msg.sender] = new DepositSlot(this);
        }

        return depositSlots[msg.sender];
    }

    function getPersonalDepositAddress(
                address depositer) constant returns (address depositAddress) {
        return depositSlots[depositer];
    }

    function processDeposit() {
        address depositSlot = depositSlots[msg.sender];
        if (depositSlot == 0) throw;

        DepositSlot(depositSlot).collect();

        uint balance = TokenInterface(GNT).balanceOf(this);
        if (balance <= totalSupply) throw;

        uint freshGNTW = balance - totalSupply;
        totalSupply += freshGNTW;
        balances[msg.sender] += freshGNTW;
        Transfer(address(this), msg.sender, freshGNTW);
    }

    function transfer(address _to,
                      uint256 _amount) returns (bool success) {
        if (_to == address(this)) {
            withdrawGNT(_amount);   // convert back to GNT
            return true;
        } else {
            return _transfer(_to, _amount);     // standard transfer
        }
    }

    function transferFrom(address _from,
                          address _to,
                          uint256 _amount) returns (bool success) {
        if (_to == address(this)) throw;        // not supported
        return _transferFrom(_from, _to, _amount);
    }


    function withdrawGNT(uint amount) internal {
        if (balances[msg.sender] < amount) throw;

        balances[msg.sender] -= amount;
        totalSupply -= amount;
        Transfer(msg.sender, address(this), amount);

        TokenInterface(GNT).transfer(msg.sender, amount);
    }
}