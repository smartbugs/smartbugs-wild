pragma solidity >=0.5.0 <0.6.0;

contract MMRRCToken {
    string public name = "Make Me Really Rich Coin";
    string public symbol = "MMRRC";
    string public standard = "FromMeToYou v1.0";

    uint256 public tSupply;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply) public {
        balances[msg.sender] = _initialSupply;
        tSupply = _initialSupply;
        
    }

    function totalSupply() public view returns (uint256) {
        return tSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        require(balances[msg.sender] >= _value, "Insufficient Balance."); 
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from], "Not enough tokens for transfer");
        require(_value <= allowance[_from][msg.sender], "Exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}