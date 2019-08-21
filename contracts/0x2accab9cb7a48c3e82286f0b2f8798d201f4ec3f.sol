pragma solidity ^0.4.15;

contract Owned {

    address owner;
    
    function Owned() { owner = msg.sender; }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract TokenEIP20 {

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract TokenNotifier {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

library SafeMathLib {

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }

    function sub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }

    function mul(uint x, uint y) internal returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function per(uint x, uint y) internal constant returns (uint z) {
        return mul((x / 100), y);
    }

    function min(uint x, uint y) internal returns (uint z) {
        return x <= y ? x : y;
    }

    function max(uint x, uint y) internal returns (uint z) {
        return x >= y ? x : y;
    }

    function imin(int x, int y) internal returns (int z) {
        return x <= y ? x : y;
    }

    function imax(int x, int y) internal returns (int z) {
        return x >= y ? x : y;
    }

    function wmul(uint x, uint y) internal returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint x, uint y) internal returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint x, uint y) internal returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wper(uint x, uint y) internal constant returns (uint z) {
        return wmul(wdiv(x, 100), y);
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

}

contract BattleToken is Owned, TokenEIP20 {
    using SafeMathLib for uint256;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    string  public constant name        = "Battle";
    string  public constant symbol      = "BTL";
    uint256 public constant decimals    = 18;
    uint256 public constant totalSupply = 1000000 * (10 ** decimals);

    function BattleToken(address _battleAddress) {
        balances[owner] = totalSupply;
        require(approve(_battleAddress, totalSupply));
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        assert(balances[msg.sender] >= 0);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }
        balances[_from] = balances[_from].sub(_value);
        assert(balances[_from] >= 0);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        if (!approve(_spender, _value)) {
            return false;
        }
        TokenNotifier(_spender).receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}