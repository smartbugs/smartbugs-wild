pragma solidity ^0.4.16;

contract LineOfTransfers {

    address[] public accounts;
    uint[] public values;
    
    uint public transferPointer = 0;

    address public owner;

    event Transfer(address to, uint amount);

    modifier hasBalance(uint index) {
        require(this.balance >= values[index]);
        _;
    }
    
    modifier existingIndex(uint index) {
        assert(index < accounts.length);
        assert(index < values.length);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function () payable public {}

    function LineOfTransfers() public {
        owner = msg.sender;
    }

    function transferTo(uint index) existingIndex(index) hasBalance(index) internal returns (bool) {
        uint amount = values[index];
        accounts[index].transfer(amount);

        Transfer(accounts[index], amount);
        return true;
    }

    function makeTransfer(uint times) public {
        while(times > 0) {
            transferTo(transferPointer);
            transferPointer++;
            times--;
        }
    }
    
    function getBalance() constant returns (uint balance) {
        return this.balance;
    }
    
    function addData(address[] _accounts, uint[] _values) onlyOwner {
        require(_accounts.length == _values.length);
        
        for (uint i = 0; i < _accounts.length; i++) {
            accounts.push(_accounts[i]);
            values.push(_values[i]);
        }
    }
    
    
    function terminate() onlyOwner {
        selfdestruct(owner);
    }
}