pragma solidity 0.5.1;

contract MyBank {
    
    mapping (address => uint) bank;
    
    function getValue() public view returns (uint) {
        return bank[msg.sender];
    }
    
    function diposit() payable public {
        require(msg.value > 0);
         bank[msg.sender] += msg.value;
    }
    
    function withdraw(uint _amount, address payable _account) public{
        require (msg.sender != _account);
        require(bank[msg.sender] >= _amount);
        bank[msg.sender] = bank[msg.sender] - _amount;
        _account.transfer(_amount);
    }
}