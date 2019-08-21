pragma solidity ^0.4.11;

contract Vault {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);

    mapping (address => uint) public deposits;
    uint minDeposit;
    bool Locked;
    address Owner;
    uint Date;

    function initVault() isOpen payable {
        Owner = msg.sender;
        minDeposit = 0.1 ether;
        Locked = false;
    }

    function() payable { deposit(); }

    function MinimumDeposit() constant returns (uint) { return minDeposit; }
    function ReleaseDate() constant returns (uint) { return Date; }
    function WithdrawalEnabled() internal returns (bool) { return Date > 0 && Date <= now; }

    function deposit() payable {
        if (msg.value >= MinimumDeposit()) {
            deposits[msg.sender] += msg.value;
        }
        Deposit(msg.sender, msg.value);
    }

    function withdraw(address to, uint amount) onlyOwner {
        if (WithdrawalEnabled()) {
            if (deposits[msg.sender] > 0 && amount <= deposits[msg.sender]) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }
    
    function SetReleaseDate(uint NewDate) { Date = NewDate; }
    modifier onlyOwner { if (msg.sender == Owner) _; }
    function lock() { Locked = true; }
    modifier isOpen { if (!Locked) _; }
    
}