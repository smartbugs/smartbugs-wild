contract Ambi {
    function getNodeAddress(bytes32) constant returns (address);
    function addNode(bytes32, address) external returns (bool);
    function hasRelation(bytes32, bytes32, address) constant returns (bool);
}

contract AmbiEnabled {
    Ambi ambiC;
    bytes32 public name;

    modifier checkAccess(bytes32 _role) {
        if(address(ambiC) != 0x0 && ambiC.hasRelation(name, _role, msg.sender)){
            _
        }
    }
    
    function getAddress(bytes32 _name) returns (address) {
        return ambiC.getNodeAddress(_name);
    }

    function setAmbiAddress(address _ambi, bytes32 _name) returns (bool){
        if(address(ambiC) != 0x0){
            return false;
        }
        Ambi ambiContract = Ambi(_ambi);
        if(ambiContract.getNodeAddress(_name)!=address(this)) {
            bool isNode = ambiContract.addNode(_name, address(this));
            if (!isNode){
                return false;
            }   
        }
        name = _name;
        ambiC = ambiContract;
        return true;
    }

    function remove(){
        if(msg.sender == address(ambiC)){
            suicide(msg.sender);
        }
    }
}

contract ElcoinDb {
    function getBalance(address addr) constant returns(uint balance);
}

contract ElcoinInterface {
    function rewardTo(address _to, uint _amount) returns (bool);
}

contract PosRewards is AmbiEnabled {

    event Reward(address indexed beneficiary, uint indexed cycle, uint value, uint position);

    uint public cycleLength; // PoS will be ready to send each cycleLength seconds
    uint public startTime;   // starting at startTime
    uint public cycleLimit;  // and will stop after cycleLimit cycles pass
    uint public minimalRewardedBalance; // but only those accounts having balance
                             // >= minimalRewardedBalance will get reward
    uint[] public bannedCycles;

    enum RewardStatuses { Unsent, Sent, TooSmallToSend }

    struct Account {
        address recipient;
        RewardStatuses status;
    }

    // cycleNumber => (address => minimalBalance)
    mapping (uint => mapping (address => int)) public accountsBalances;
    // cycleNumber => Account[]
    mapping (uint => Account[]) public accountsUsed;

    function PosRewards() {
        cycleLength = 864000; // 864000 seconds = 10 days, 14400 = 4 hours
        cycleLimit = 255; // that's 9 + 9 + 9 + 9 + 219, see getRate() for info
        minimalRewardedBalance = 1000000; // 1 coin
        startTime = now;
    }

    // USE THIS FUNCTION ONLY IN NEW CONTRACT, IT WILL CORRUPT ALREADY COLLECTED DATA!
    // startTime should be set to the time when PoS starts (on Dec 17, probably block 705000 or so).
    // It should be at 12:00 Moscow time, this would be the start of all PoS cycles.
    function setStartTime(uint _startTime) checkAccess("owner") {
        startTime = _startTime;
    }

    // this allows to end PoS before 2550 days pass or to extend it further
    function setCycleLimit(uint _cycleLimit) checkAccess("owner") {
        cycleLimit = _cycleLimit;
    }

    // this allows to disable PoS sending for some of the cycles in case we
    // need to send custom PoS. This will be 100% used on first deploy.
    function setBannedCycles(uint[] _cycles) checkAccess("owner") {
        bannedCycles = _cycles;
    }

    // set to 0 to reward everyone
    function setMinimalRewardedBalance(uint _balance) checkAccess("owner") {
        minimalRewardedBalance = _balance;
    }

    function kill() checkAccess("owner") {
        suicide(msg.sender); // kills this contract and sends remaining funds back to msg.sender
    }

    // First 90 days 50% yearly
    // Next 90 days 40%
    // Next 90 days 30%
    // Next 90 days 20%
    // Next 2190 days 10%
    function getRate(uint cycle) constant returns (uint) {
        if (cycle <= 9) {
            return 50;
        }
        if (cycle <= 18) {
            return 40;
        }
        if (cycle <= 27) {
            return 30;
        }
        if (cycle <= 35) { // not 36 because 36 is elDay
            return 20;
        }
        if (cycle == 36) {
            return 40;
        }
        if (cycle <= cycleLimit) {
            if (cycle % 36 == 0) {
                // Every 360th day, reward amounts double.
                // The elDay lasts precisely 24 hours, and after that, reward amounts revert to their original values.
                return 20;
            }

            return 10;
        }
        return 0;
    }

    // Cycle numeration starts from 1, 0 will be handled as not valid cycle
    function currentCycle() constant returns (uint) {
        if (startTime > now) {
            return 0;
        }

        return 1 + ((now - startTime) / cycleLength);
    }

    function _isCycleValid(uint _cycle) constant internal returns (bool) {
        if (_cycle >= currentCycle() || _cycle == 0) {
            return false;
        }
        for (uint i; i<bannedCycles.length; i++) {
            if (bannedCycles[i] == _cycle) {
                return false;
            }
        }

        return true;
    }

    // Returns how much Elcoin would be granted for user's minimal balance X in cycle Y
    // The function is optimized to work with whole integer arithmetics
    function getInterest(uint amount, uint cycle) constant returns (uint) {
        return (amount * getRate(cycle)) / 3650;
    }

    // This function logs the balances after the transfer to be used in further calculations
    function transfer(address _from, address _to) checkAccess("elcoin") {
        if (startTime == 0) {
            return; // the easy way to disable PoS
        }

        _storeBalanceRecord(_from);
        _storeBalanceRecord(_to);
    }

    function _storeBalanceRecord(address _addr) internal {
        ElcoinDb db = ElcoinDb(getAddress("elcoinDb"));
        uint cycle = currentCycle();

        if (cycle > cycleLimit) {
            return;
        }

        int balance = int(db.getBalance(_addr));
        bool accountNotUsedInCycle = (accountsBalances[cycle][_addr] == 0);

        // We'll use -1 to mark accounts that have zero balance because
        // mappings return 0 for unexisting records and there is no way to
        // differ them without additional data structure
        if (accountsBalances[cycle][_addr] != -1 && (accountNotUsedInCycle || accountsBalances[cycle][_addr] > balance)) {
            if (balance == 0) {
                balance = -1;
            }
            accountsBalances[cycle][_addr] = balance;

            if (accountNotUsedInCycle) {
                // do this only once for each account in each cycle
                accountsUsed[cycle].push(Account(_addr, RewardStatuses.Unsent));
            }
        }
    }

    // Get minimal balance for address in some cycle
    function getMinimalBalance(uint _cycle, address _addr) constant returns(int) {
        int balance = accountsBalances[_cycle][_addr];
        if (balance == -1) {
            balance = 0;
        }

        return balance;
    }

    // Get information from accountsUsed structure
    function getAccountInfo(uint _cycle, uint _position) constant returns(address, RewardStatuses, int) {
        return (
            accountsUsed[_cycle][_position].recipient,
            accountsUsed[_cycle][_position].status,
            accountsBalances[_cycle][accountsUsed[_cycle][_position].recipient]
          );
    }

    // Get information from accountsUsed structure
    function getRewardsCount(uint _cycle) constant returns(uint) {
        return accountsUsed[_cycle].length;
    }

    function sendReward(uint _cycle, uint _position) returns(bool) {
        // Check that parameters are in valid ranges
        if (!_isCycleValid(_cycle) || _position >= accountsUsed[_cycle].length) {
            return false;
        }

        // Check that this reward was not sent
        Account claimant = accountsUsed[_cycle][_position];
        if (claimant.status != RewardStatuses.Unsent) {
            return false;
        }

        // Check that this reward passes the conditions
        int minimalAccountBalance = accountsBalances[_cycle][claimant.recipient];
        if (minimalAccountBalance < int(minimalRewardedBalance)) {
            claimant.status = RewardStatuses.TooSmallToSend;
            return false;
        }

        uint rewardAmount = getInterest(uint(minimalAccountBalance), _cycle);

        // We are ready to send the reward
        ElcoinInterface elcoin = ElcoinInterface(getAddress("elcoin"));
        bool result = elcoin.rewardTo(claimant.recipient, rewardAmount);
        if (result) {
            Reward(claimant.recipient, _cycle, rewardAmount, _position);
            claimant.status = RewardStatuses.Sent;
        }

        return true;
    }
}