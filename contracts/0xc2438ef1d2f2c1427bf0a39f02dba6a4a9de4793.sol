pragma solidity ^0.4.13;

contract BankDeposit {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);

    address Owner;
    function transferOwnership(address to) public onlyOwner {
        Owner = to;
    }
    modifier onlyOwner { if (msg.sender == Owner) _; }
    
    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked;
    uint Date;

    function init() payable open {
        Owner = msg.sender;
        minDeposit = 0.25 ether;
        Locked = false;
        deposit();
    }
    
    function MinimumDeposit() public constant returns (uint) { return minDeposit; }

    function setRelease(uint newDate) public {
        Date = newDate;
    }
    function ReleaseDate() public constant returns (uint) { return Date; }
    function WithdrawEnabled() public constant returns (bool) { return Date > 0 && Date <= now; }

    function() public payable { deposit(); }

    function deposit() public payable {
        if (msg.value > 0) {
            if (msg.value >= MinimumDeposit())
                Deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }

    function withdraw(uint amount) public { return withdrawTo(msg.sender, amount); }
    
    function withdrawTo(address to, uint amount) public onlyOwner {
        if (WithdrawEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }

    function lock() public { Locked = true; }
    modifier open { if (!Locked) _; }
    function kill() { require(this.balance == 0); selfdestruct(Owner); }
}