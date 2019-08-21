pragma solidity ^0.4.25;


contract T {

    uint256 public totalSupply;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => bool) public centralUsers;

    string public name;
    uint8 public decimals;
    string public symbol;
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // 8888800000000,"center for digital finacial assets",8,"T", ["0x72F720B4fa62F0d12EF58F2E460272548C897c5a","0x27e04E00B3A092CF7B943C31d3DC1b292f1B41e9"]


    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address [] _centralUsers
    ) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        owner = msg.sender;
        for (uint8 i = 0; i< _centralUsers.length; i++){
            centralUsers[_centralUsers[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCentralUser() {
        require(centralUsers[msg.sender] == true);
        _;
    }

    function setCentralUser(address user) public onlyOwner {
        centralUsers[user] = true;
    }

    function removeCentralUser(address user) public onlyOwner {
        centralUsers[user] = false;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function feeCentralTransfer(address _from, address _to, uint256 _value, uint256 _charge) public onlyCentralUser returns (bool success) {
        // charge

        // not charge company account
        if (_from != owner && _charge != 0) {
            _transfer(_from, owner, _charge);
        }
        _value = _value - _charge;
        _transfer(_from, _to, _value);
        return true;
    }

    function centralTransfer(address _from, address _to, uint256 _value) public onlyCentralUser returns (bool success) {
        _transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}