pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface token { function transferFrom(address _from, address _to, uint256 _value) public returns (bool success); }

contract CZRLocker is owned {
    
    event AddLock(address addr, uint index, uint startLockTime, uint lockMonth, uint lockedAmount);
    event RemoveLock(address addr, uint index);
    event Unlock(address addr, uint index, uint unlockAmount);

    address public tokenAddr;
    address public unlocker;
    
    struct LockedCZR {
        uint startLockTime;
        uint lockMonth;
        uint lockedAmount;
        uint unlockedAmount;
    }
    
    mapping(address => LockedCZR[]) public lockedCZRMap;
    
    function CZRLocker(address _tokenAddr, address _unlocker) public {
        tokenAddr = _tokenAddr;
        unlocker = _unlocker;
    }

    /// @notice remove CZR lock (only set all field to 0)
    /// @param addr address to remove lock
    /// @param index index to remove
    function removeCZRLock(address addr, uint index) onlyOwner public {
        LockedCZR[] storage lockArr = lockedCZRMap[addr];
        require(lockArr.length > 0 && index < lockArr.length);
    
        delete lockArr[index];      //delete just set all feilds to zero value, not remove item out of array;
        RemoveLock(addr, index);
    }
    
    /// @notice add CZR lock
    /// @param addr address to add lock
    /// @param startLockTime start lock time, 0 for now
    /// @param amount CZR amount
    /// @param lockMonth months to lock
    function addCZRLock(address addr, uint startLockTime, uint amount, uint lockMonth) onlyOwner public {
        require(amount > 0);
        if (startLockTime == 0)
            startLockTime = now;
        lockedCZRMap[addr].push(LockedCZR(startLockTime, lockMonth, amount, 0));
        uint index = lockedCZRMap[addr].length - 1;
        AddLock(addr, index, startLockTime, lockMonth, amount);
    }
    
    /// @notice unlock CZR
    /// @param addr address to unlock
    /// @param limit max unlock number
    function unlockCZR(address addr, uint limit) public {
        require(msg.sender == owner || msg.sender == unlocker);
        
        LockedCZR[] storage lockArr = lockedCZRMap[addr];
        require(lockArr.length > 0);
        token t = token(tokenAddr);
        
        uint num = 0;
        for (uint i = 0; i < lockArr.length; i++) {
            var lock = lockArr[i];
            if (lock.lockedAmount > 0) {
                uint time = now - lock.startLockTime;
                uint month = time / 30 days;
                
                if (month == 0) 
                    continue;

                uint unlockAmount;
                if (month >= lock.lockMonth)
                    unlockAmount = lock.lockedAmount;
                else
                    unlockAmount = (lock.lockedAmount + lock.unlockedAmount) * month / lock.lockMonth - lock.unlockedAmount;
                        
                if (unlockAmount == 0) 
                    continue;
                    
                lock.unlockedAmount += unlockAmount;
                lock.lockedAmount -= unlockAmount;
                        
                t.transferFrom(owner, addr, unlockAmount);
                Unlock(addr, i, unlockAmount);
                
                num++;
                if (limit > 0 && num == limit)
                    break;
            }
        }
        
        require(num > 0);
    }
    
    /// @notice withdraw eth
    /// @param to Address to receive the eth
    /// @param value the amount of eth it will receive
    function withdrawEth(address to, uint256 value) onlyOwner public {
        to.transfer(value);
    }
    
    /// record total received eth and check whether goal completed
    function() payable public {
    }
}