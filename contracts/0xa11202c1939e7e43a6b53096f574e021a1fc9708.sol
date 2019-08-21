pragma solidity ^0.4.17;

contract Owned {
    address public owner;
    function Owned() { owner = msg.sender; }
    modifier onlyOwner { if (msg.sender != owner) revert(); _; }
}

contract PasswordRecoverableWallet is Owned {
    event Deposit(address from, uint amount);
    event Withdrawal(address from, uint amount);
    address public owner = msg.sender;
    bytes32 recoveryHash;
    uint256 recoveryValue;

    function() public payable {
        Deposit(msg.sender, msg.value);
    }

    function setRecoveryInfo(bytes32 hash, uint256 value) public onlyOwner {
        recoveryHash = hash;
        recoveryValue = value;
    }

    function recover(bytes32 password) public payable {
        if ((sha256(password) == recoveryHash) && (msg.value == recoveryValue)) owner = msg.sender;
    }

    function withdraw(uint amount) public onlyOwner {
        msg.sender.transfer(amount);
        Withdrawal(msg.sender, amount);
    }
}