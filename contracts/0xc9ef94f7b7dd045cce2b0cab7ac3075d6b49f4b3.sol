pragma solidity ^0.4.24;

contract SmartGrowup {
    address public owner;
    address public support;
    uint public depAmount;
    uint public stage;
    uint public lastPayDate;
    
    uint constant public MASS_LIMIT = 150;
    uint constant public MIN_INVEST = 10000000000000000 wei;

    address[] public addresses;
    mapping(address => Depositor) public depositors;
    bool public pause;

    struct Depositor
    {
        uint id;
        uint deposit;
        uint deposits;
        uint date;
        address referrer;
    }

    event Deposit(address addr, uint amount, address referrer);
    event Payout(address addr, uint amount, string eventType, address from);
    event NextStageStarted(uint round, uint date, uint deposit);

    modifier onlyOwner {if (msg.sender == owner) _;}

    constructor() public {
        owner = msg.sender;
        support = msg.sender;
        addresses.length = 1;
        stage = 1;
    }

    function transferOwnership(address addr) onlyOwner public {
        owner = addr;
    }

    function addDepositors(address[] _addr, uint[] _deposit, uint[] _date, address[] _referrer) onlyOwner public {
        // add initiated investors
        for (uint i = 0; i < _addr.length; i++) {
            uint id = addresses.length;
            if (depositors[_addr[i]].deposit == 0) {
                addresses.push(_addr[i]);
                depAmount += _deposit[i];
            }

            depositors[_addr[i]] = Depositor(id, _deposit[i], 1, _date[i], _referrer[i]);
            emit Deposit(_addr[i], _deposit  [i], _referrer[i]);
        }
        lastPayDate = now;
    }

    function() payable public {
        if (owner == msg.sender) {
            return;
        }

        if (0 == msg.value) {
            payoutSelf();
            return;
        }

        require(false == pause, "Restarting. Please wait.");
        require(msg.value >= MIN_INVEST, "Small amount, minimum 0.01 ether");
        Depositor storage user = depositors[msg.sender];

        if (user.id == 0) {
            // ensure that payment not from hacker contract
            msg.sender.transfer(0 wei);
            addresses.push(msg.sender);
            user.id = addresses.length;
            user.date = now;

            // referrer
            address referrer = transferBytestoAddress(msg.data);
            if (depositors[referrer].deposit > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }
        } else {
            payoutSelf();
        }

        // counter deposits and value deposits
        user.deposit += msg.value;
        user.deposits += 1;

        emit Deposit(msg.sender, msg.value, user.referrer);

        depAmount += msg.value;
        lastPayDate = now;

        support.transfer(msg.value / 5); // project fee for supporting
        uint bonusAmount = (msg.value / 100) * 3; // referrer commission for all deposits

        if (user.referrer > 0x0) {
            if (user.referrer.send(bonusAmount)) {
                emit Payout(user.referrer, bonusAmount, "referral", msg.sender);
            }

            if (user.deposits == 1) { // cashback only for the first deposit 3%
                if (msg.sender.send(bonusAmount)) {
                    emit Payout(msg.sender, bonusAmount, "CashBack", 0);
                }
            }
        } 


    }

    function payout(uint removal) public
    {
        if (pause == true) {
            goRestart();
            return;
        }

        uint txs;
        uint amount;

        for (uint idx = addresses.length - removal - 1; idx >= 1 && txs < MASS_LIMIT; idx--) {
            address addr = addresses[idx];
            if (depositors[addr].date + 20 hours > now) {
                continue;
            }

            amount = getDividendsAmount(addr);
            depositors[addr].date = now;

            if (address(this).balance < amount) {
                pause = true;
                return;
            }

            if (addr.send(amount)) {
                emit Payout(addr, amount, "Payout", 0);
            }

            txs++;
        }
    }

    function payoutSelf() private {
        require(depositors[msg.sender].id > 0, "Investor not found.");
        uint amount = getDividendsAmount(msg.sender);

        depositors[msg.sender].date = now;
        if (address(this).balance < amount) {
            pause = true;
            return;
        }

        msg.sender.transfer(amount);
        emit Payout(msg.sender, amount, "Autopayout", 0);
    }


    function getCount() public view returns (uint) {
        return addresses.length - 1;
    }

    function getDividendsAmount(address addr) public view returns (uint) {
        return depositors[addr].deposit / 100 * 4 * (now - depositors[addr].date) / 1 days;
    }

    function transferBytestoAddress(bytes byt) private pure returns (address addr) {
        assembly {
            addr := mload(add(byt, 20))
        }
    }
    
    function goRestart() private {
        uint txs;
        address addr;

        for (uint i = addresses.length - 1; i > 0; i--) {
            addr = addresses[i];
            addresses.length -= 1;
            delete depositors[addr];
            if (txs++ == MASS_LIMIT) {
                return;
            }
        }

        emit NextStageStarted(stage, now, depAmount);
        pause = false;
        stage += 1;
        depAmount = 0;
        lastPayDate = now;

    }

}