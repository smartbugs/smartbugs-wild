pragma solidity ^0.4.18;

contract ERC20 {
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 amount) public;
}

contract Wallet {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);
    event TransferOwnership(address indexed from, address indexed to);
    
    address Owner;
    function transferOwnership(address to) onlyOwner {
        TransferOwnership(Owner, to); Owner = to;
    }
    
    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked = false;
    uint Date;

    function initWallet() payable open {
        Owner = msg.sender;
        minDeposit = 0.25 ether;
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

    function withdraw(uint amount) public payable { withdrawTo(msg.sender, amount); }
    
    function withdrawTo(address to, uint amount) public onlyOwner {
        if (WithdrawalEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }

    function withdrawToken(address token) public payable onlyOwner {
        if (WithdrawalEnabled())
            withdrawTokenTo(token, msg.sender, ERC20(token).balanceOf(address(this)));
    }

    function withdrawTokenTo(address token, address to, uint amount) public payable onlyOwner {
        if (WithdrawalEnabled()) {
            uint bal = ERC20(token).balanceOf(address(this));
            if (bal >= amount && amount > 0) {
                ERC20(token).transfer(to, amount);
            }
        }
    }

    function MinimumDeposit() public constant returns (uint) { return minDeposit; }
    function ReleaseDate() public constant returns (uint) { return Date; }
    function WithdrawalEnabled() constant internal returns (bool) { return Date > 0 && Date <= now; }
    function lock() public { Locked = true; }
    modifier onlyOwner { if (msg.sender == Owner) _; }
    modifier open { if (!Locked) _; }
}