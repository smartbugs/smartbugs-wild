pragma solidity ^0.3.5;

contract DepositHolder {
    uint constant GUARANTEE_PERIOD = 365 days;
    
    event Claim(address addr, uint amount);
    
    struct Entry {
        bytes16 next;
        uint64 deposit;
        uint64 expires;
    }

    address owner;
    address auditor;
    
    mapping(bytes16=>Entry) entries;
    bytes16 oldestHash;
    bytes16 newestHash;
    
    uint public paidOut;
    uint public totalPaidOut;
    uint public depositCount;
    
    function DepositHolder() {
        owner = msg.sender;
        auditor = owner;
    }
    
    modifier owner_only {
        if(msg.sender != owner) throw;
        _;
    }
    
    modifier auditor_only {
        if(msg.sender != auditor) throw;
        _;
    }
    
    function setOwner(address newOwner) owner_only {
        owner = newOwner;
    }
    
    function setAuditor(address newAuditor) auditor_only {
        auditor = newAuditor;
    }

    /**
     * @dev Lodge deposits for a set of address hashes. Automatically uses
     *      expired deposits to pay for new ones.
     * @param values A list of hashes of addresses to place deposits for.
     *        Each value is the first 16 bytes of the keccak-256 hash of the
     *        address the deposit is for.
     * @param deposit The amount of the deposit on each address.
     */
    function deposit(bytes16[] values, uint64 deposit) owner_only {
        uint required = values.length * deposit;
        if(msg.value < required) {
            throw;
        } else if(msg.value > required) {
            if(!msg.sender.send(msg.value - required))
                throw;
        }

        extend(values, uint64(deposit));
    }

    function extend(bytes16[] values, uint64 deposit) private {
        uint64 expires = uint64(now + GUARANTEE_PERIOD);

        if(oldestHash == 0) {
            oldestHash = values[0];
            newestHash = values[0];
        } else {
            entries[newestHash].next = values[0];
        }
        
        for(uint i = 0; i < values.length - 1; i++) {
            if(entries[values[i]].expires != 0)
                throw;
            entries[values[i]] = Entry(values[i + 1], deposit, expires);
        }
        
        newestHash = values[values.length - 1];
        if(entries[newestHash].expires != 0)
            throw;
        entries[newestHash] = Entry(0, deposit, expires);
        
        depositCount += values.length;
    }

    /**
     * @dev Withdraw funds held for expired deposits.
     * @param max Maximum number of deposits to claim.
     */
    function withdraw(uint max) owner_only {
        uint recovered = recover(max);
        if(!msg.sender.send(recovered))
            throw;
    }

    function recover(uint max) private returns(uint recovered) {
        // Iterate through entries deleting them, until we find one
        // that's new enough, or hit the limit.
        bytes16 ptr = oldestHash;
        uint count;
        for(uint i = 0; i < max && ptr != 0 && entries[ptr].expires < now; i++) {
            recovered += entries[ptr].deposit;
            ptr = entries[ptr].next;
            count += 1;
        }

        oldestHash = ptr;
        if(oldestHash == 0)
            newestHash = 0;
        
        // Deduct any outstanding payouts from the recovered funds
        if(paidOut > 0) {
            if(recovered > paidOut) {
                recovered -= paidOut;
                paidOut = 0;
            } else {
                paidOut -= recovered;
                recovered = 0;
            }
        }
        
        depositCount -= count;
    }

    /**
     * @dev Fetches information on a future withdrawal event
     * @param hash The point at which to start scanning; 0 for the first event.
     * @return when Unix timestamp at which a withdrawal can next happen.
     * @return count Number of addresses expiring at this time
     * @return value Total amount withdrawable at this time
     * @return next Hash of the start of the next withdrawal event, if any.
     */
    function nextWithdrawal(bytes16 hash) constant returns(uint when, uint count, uint value, bytes16 next) {
        if(hash == 0) {
            hash = oldestHash;
        }
        next = hash;
        when = entries[hash].expires;
        while(next != 0 && entries[next].expires == when) {
            count += 1;
            value += entries[next].deposit;
            next = entries[next].next;
        }
    }

    /**
     * @dev Checks if a deposit is held for the provided address.
     * @param addr The address to check.
     * @return expires The unix timestamp at which the deposit on this address
     *         expires, or 0 if there is no deposit.
     * @return deposit The amount deposited against this address.
     */
    function check(address addr) constant returns (uint expires, uint deposit) {
        Entry storage entry = entries[bytes16(sha3(addr))];
        expires = entry.expires;
        deposit = entry.deposit;
    }
    
    /**
     * @dev Pays out a claim.
     * @param addr The address to pay.
     * @param amount The amount to send.
     */
    function disburse(address addr, uint amount) auditor_only {
        paidOut += amount;
        totalPaidOut += amount;
        Claim(addr, amount);
        if(!addr.send(amount))
            throw;
    }
    
    /**
     * @dev Deletes the contract, if no deposits are held.
     */
    function destroy() owner_only {
        if(depositCount > 0)
            throw;
        selfdestruct(msg.sender);
    }
}