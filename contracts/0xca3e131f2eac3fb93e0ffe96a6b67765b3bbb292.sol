pragma solidity ^0.4.25;
contract OCX {
    string public name = "OCX";
    string public symbol = "OCX";
    uint8 public decimals = 2;
    uint256 public totalSupply =1500000000;
    mapping (address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() public{balanceOf[msg.sender] = totalSupply;}
    function _transfer(address _from, address _to, uint _value) internal
    {   require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);}
    function transfer(address _to, uint256 _value) public  returns (bool success) 
    {   require(_value >= 100000000);
        _transfer(msg.sender, _to, _value);
        return true;
    }
}