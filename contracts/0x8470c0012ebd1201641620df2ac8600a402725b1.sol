pragma solidity ^0.4.18;

/* @nitzaalfinas */

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract MerialCoin {

    using SafeMath for uint256;

    string  public symbol;
    string  public name;
    uint8   public decimals;
    uint256 public totalSupply;

    address public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAddress;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenAddress(address indexed target, bool frozen);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    constructor () public {
        name        = 'Merial Coin';
        symbol      = 'MRA';
        decimals    = 18;
        totalSupply = 1000000000 * 10 ** uint256(decimals);

        owner                 = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transferOwnership(address _newOwner) public returns (bool success) {
        require(msg.sender == owner);
        owner = _newOwner;
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balanceOf[tokenOwner];
    }


    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != address(0x0));

        require(!frozenAddress[_from]);

        require(!frozenAddress[_to]);

        require(_from != _to);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function freezeAddress(address target, bool freeze) public returns (bool success) {

        require(msg.sender == owner);
        require(target != owner);
        require(msg.sender != target);

        frozenAddress[target] = freeze;

        emit FrozenAddress(target, freeze);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!frozenAddress[msg.sender]);
        require(!frozenAddress[_spender]);
        require(msg.sender != _spender);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(!frozenAddress[msg.sender]);
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(!frozenAddress[msg.sender]);
        require(!frozenAddress[_from]);
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender] );
        balanceOf[_from] = balanceOf[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

}