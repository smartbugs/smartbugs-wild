contract ElcoinDb {
    address owner;
    address caller;

    event Transaction(bytes32 indexed hash, address indexed from, address indexed to, uint time, uint amount);

    modifier checkOwner() { if(msg.sender == owner) { _ } else { return; } }
    modifier checkCaller() { if(msg.sender == caller) { _ } else { return; } }
    mapping (address => uint) public balances;

    function ElcoinDb(address pCaller) {
        owner = msg.sender;
        caller = pCaller;
    }

    function getOwner() constant returns (address rv) {
        return owner;
    }

    function getCaller() constant returns (address rv) {
        return caller;
    }

    function setCaller(address pCaller) checkOwner() returns (bool _success) {
        caller = pCaller;

        return true;
    }

    function setOwner(address pOwner) checkOwner() returns (bool _success) {
        owner = pOwner;

        return true;
    }

    function getBalance(address addr) constant returns(uint balance) {
        return balances[addr];
    }

    function deposit(address addr, uint amount, bytes32 hash, uint time) checkCaller() returns (bool res) {
        balances[addr] += amount;
        Transaction(hash,0 , addr, time, amount);

        return true;
    }

    function withdraw(address addr, uint amount, bytes32 hash, uint time) checkCaller() returns (bool res) {
        uint oldBalance = balances[addr];
        if(oldBalance >= amount) {
            msg.sender.send(amount);
            balances[addr] = oldBalance - amount;
            Transaction(hash, addr, 0, time, amount);
            return true;
        }

        return false;
    }
}