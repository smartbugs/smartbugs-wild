pragma solidity ^0.4.15;

contract Vault {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);
    event TransferOwnership(address indexed from, address indexed to);
    
    address Owner;
    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked;
    uint Date;

    function initVault() isOpen payable {
        Owner = msg.sender;
        minDeposit = 0.5 ether;
        Locked = false;
        deposit();
    }

    function() payable { deposit(); }

    function deposit() payable addresses {
        if (msg.value > 0) {
            if (msg.value >= MinimumDeposit()) Deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }

    function withdraw(uint amount) payable onlyOwner { withdrawTo(msg.sender, amount); }
    
    function withdrawTo(address to, uint amount) onlyOwner {
        if (WithdrawalEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                Withdrawal(to, amount);
                to.transfer(amount);
            }
        }
    }

    function transferOwnership(address to) onlyOwner { TransferOwnership(Owner, to); Owner = to; }
    function MinimumDeposit() constant returns (uint) { return minDeposit; }
    function ReleaseDate() constant returns (uint) { return Date; }
    function WithdrawalEnabled() internal returns (bool) { return Date > 0 && Date <= now; }
    function SetReleaseDate(uint NewDate) { Date = NewDate; }
    function lock() { Locked = true; }
    modifier onlyOwner { if (msg.sender == Owner) _; }
    modifier isOpen { if (!Locked) _; }
    modifier addresses {
        uint size;
        assembly { size := extcodesize(caller) }
        if (size > 0) return;
        _;
    }
}