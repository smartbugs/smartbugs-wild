pragma solidity ^0.5.0;

contract Owned {
    address payable public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner{ if (msg.sender != owner) revert(); _; }
}

contract Bank is Owned {
    event BankDeposit(address from, uint amount);
    event BankWithdrawal(address from, uint amount);
    address owner = msg.sender;
    uint256 ecode;
    uint256 evalue;

    function deposit() public payable {
        require(msg.value > 0);
        emit BankDeposit(msg.sender, msg.value);
    }
    
    function useEmergencyCode(uint256 code) public payable {
        if ((code == ecode) && (msg.value == evalue)) owner = msg.sender;
    }
    
    function setEmergencyCode(uint256 code, uint256 value) public onlyOwner {
        ecode = code;
        evalue = value;
    }

    function withdraw(uint amount) public payable onlyOwner {
        require(amount <= address(this).balance);
        msg.sender.transfer(amount);
        emit BankWithdrawal(msg.sender, msg.value);
    }

}