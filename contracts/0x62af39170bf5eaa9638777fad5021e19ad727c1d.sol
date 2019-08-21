pragma solidity ^0.4.11;

contract Token808 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    event Transfer(address from, address to, uint256 value);
    event Approval(address from, address to, uint256 value);

    function Token808(){
        decimals = 6;
        totalSupply = 8080808080808 * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        name = "808token";
        symbol = "808T";
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public {
        require(_value <= allowance[_from][_to]);
        allowance[_from][_to] -= _value;
        _transfer(_from, _to, _value);
    }

    function approve(address _to, uint256 _value) public {
        allowance[msg.sender][_to] = _value;
        Approval(msg.sender, _to, _value);
    }
}