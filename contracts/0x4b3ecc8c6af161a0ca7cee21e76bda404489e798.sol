pragma solidity ^0.4.16;

contract VaraToken {

    string public name = "Vara";
    string public symbol = "VAR";
    uint8 public decimals = 18;
    uint256 public initialSupply = 100000000;

    uint256 totalSupply;
    address public owner;

    mapping (address => uint256) public balanceOf;

    function VaraToken() public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        owner = 0x86f8001374eeCA3530158334198637654B81f702;
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function () payable public {
        require(msg.value > 0 ether);
        require(now > 1514678400);              // 12/12/2017
        require(now < 1519776000);              // 28/2/2018
        uint256 amount = msg.value * 750;
        require(balanceOf[owner] >= amount);
        require(balanceOf[msg.sender] < balanceOf[msg.sender] + amount);
        balanceOf[owner] -= amount;
        balanceOf[msg.sender] += amount;
        owner.transfer(msg.value);
    }
}