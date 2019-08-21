pragma solidity ^0.4.25;

contract Token {
    string  public name;
    string  public symbol;
    //string  public standard = "Token v1.0";
    uint256 public totalSupply;
    //
    address public minter;

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

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply, string memory _name, string memory _symbol, address _minter) public {
        balanceOf[_minter] = _initialSupply;
        totalSupply = _initialSupply;
        name = _name;
        symbol =_symbol;
        //
        minter =_minter;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function getTokenDetails() public view returns(address _minter, string memory _name, string memory _symbol, uint256 _totalsupply) {
        return(minter, name, symbol, totalSupply);
    }
}