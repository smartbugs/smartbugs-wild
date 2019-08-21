pragma solidity ^0.4.18;

contract TokenBlueGoldERC20 {
    string private constant _name = "BlueGold";
    string private constant _symbol = "BEG";
    uint8 private constant _decimals = 8;
    uint256 private constant _initialSupply = 15000000;
    uint256 private constant _totalSupply = _initialSupply * (10 ** uint256(_decimals));

    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function TokenBlueGoldERC20() public {
        address sender = msg.sender;

        _balanceOf[sender] = _totalSupply;
    }

    function name() public pure returns (string) {
        return _name;
    }

    function symbol() public pure returns (string) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _ownerAddress) public view returns (uint256) {
        return _balanceOf[_ownerAddress];
    }

    function transfer(address _to, uint256 _value) public returns (bool)  {
        address sender = msg.sender;

        _transfer(sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        address sender = msg.sender;

        require(_value <= _allowance[_from][sender]);
        _reduceAllowanceLimit(_from, _value);
        _transfer(_from, _to, _value);

        return true;
    }

    function _reduceAllowanceLimit(address _from, uint256 _value) internal {
        address sender = msg.sender;

        _allowance[_from][sender] -= _value;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        _preValidTransfer(_from, _to, _value);

        uint256 previousBalances = _balanceOf[_from] + _balanceOf[_to];

        _sendToken(_from, _to, _value);

        assert(_balanceOf[_from] + _balanceOf[_to] == previousBalances);
    }

    function _preValidTransfer(address _from, address _to, uint256 _value) view internal {
        require(_to != 0x0);
        require(_value > 0);
        require(_balanceOf[_from] >= _value);
    }

    function _sendToken(address _from, address _to, uint256 _value) internal {
        _balanceOf[_from] -= _value;
        _balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        address sender = msg.sender;

        _allowance[sender][_spender] = _value;
        Approval(sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowance[_owner][_spender];
    }
}