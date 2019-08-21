contract BTCRelay {
    function getLastBlockHeight() returns (int);
    function getBlockchainHead() returns (int);
    function getFeeAmount(int blockHash) returns (int);
    function getBlockHeader(int blockHash) returns (bytes32[3]);
}

contract Lottery {
    int constant LOTTERY_BLOCKS = 7 * 24 * 6;
    uint constant LOTTERY_INTERVAL = 7 days;
    int constant CUTOFF_BLOCKS = 6 * 6;
    uint constant CUTOFF_INTERVAL = 6 hours;
    uint constant TICKET_PRICE = 10 finney;
    uint constant FEE_FACTOR = 200; // 0.5 %

    BTCRelay btcRelay = BTCRelay(0x41f274c0023f83391de4e0733c609df5a124c3d4);

    struct Bucket {
        uint numHolders;
        address[] ticketHolders;
    }

    struct Payout {
        address winner;
        uint amount;
        uint blockNumber;
        uint timestamp;
        address processor;
    }

    int public decidingBlock;
    int public cutoffBlock;
    uint public cutoffTimestamp;
    int public nearestKnownBlock;
    int public nearestKnownBlockHash;

    uint public numTickets;
    uint public numBuckets;
    mapping (uint => Bucket) buckets;
    uint public lastSaleTimestamp;

    Payout[] public payouts;
    uint public payoutIdx;

    address public owner;

    modifier onlyOwner { if (msg.sender == owner) _ }

    event Activity();

    function Lottery() {
        owner = msg.sender;
        payouts.length = 3;
        prepareLottery();
    }

    function prepareLottery() internal {
        decidingBlock = btcRelay.getLastBlockHeight() + LOTTERY_BLOCKS;
        cutoffBlock = decidingBlock - CUTOFF_BLOCKS;
        cutoffTimestamp = now + LOTTERY_INTERVAL - CUTOFF_INTERVAL;
        nearestKnownBlock = 0;
        nearestKnownBlockHash = 0;

        numTickets = 0;
        for (uint i = 0; i < numBuckets; i++) {
            buckets[i].numHolders = 0;
        }
        numBuckets = 0;
        lastSaleTimestamp = 0;
    }

    function resetLottery() {
        if (numTickets > 0) throw;
        if (!payoutReady()) throw;

        prepareLottery();
        Activity();
    }

    function () {
        buyTickets(msg.sender);
    }

    function buyTickets(address ticketHolder) {
        if (msg.value < TICKET_PRICE) throw;
        if (!ticketsAvailable()) throw;

        uint n = msg.value / TICKET_PRICE;
        numTickets += n;

        // We maintain the list of ticket holders in a number of buckets.
        // Entries in the first bucket represent one ticket each, in the
        // second bucket they represent two tickets each, then four tickets
        // each and so on. This allows us to process the sale of n tickets
        // with a gas cost of O(log(n)).
        uint bucket = 0;
        while (n > 0) {
            uint inThisBucket = n & (2 ** bucket);
            if (inThisBucket > 0) {
                uint pos = buckets[bucket].numHolders++;
                if (buckets[bucket].ticketHolders.length <
                    buckets[bucket].numHolders) {
                    buckets[bucket].ticketHolders.length =
                        buckets[bucket].numHolders;
                }
                buckets[bucket].ticketHolders[pos] = ticketHolder;
                n -= inThisBucket;
            }
            bucket += 1;
        }

        if (bucket > numBuckets) numBuckets = bucket;

        int missingBlocks = decidingBlock - btcRelay.getLastBlockHeight();
        uint betterCutoffTimestamp =
            now + uint(missingBlocks) * 10 minutes - CUTOFF_INTERVAL;
        if (betterCutoffTimestamp < cutoffTimestamp) {
            cutoffTimestamp = betterCutoffTimestamp;
        }

        lastSaleTimestamp = now;
        Activity();
    }

    function ticketsAvailable() constant returns (bool) {
        return now < cutoffTimestamp &&
            btcRelay.getLastBlockHeight() < cutoffBlock;
    }

    function lookupTicketHolder(uint idx) constant returns (address) {
        uint bucket = 0;
        while (idx >= buckets[bucket].numHolders * (2 ** bucket)) {
            idx -= buckets[bucket].numHolders * (2 ** bucket);
            bucket += 1;
        }

        return buckets[bucket].ticketHolders[idx / (2 ** bucket)];
    }

    function getNumHolders(uint bucket) constant returns (uint) {
        return buckets[bucket].numHolders;
    }

    function getTicketHolders(uint bucket) constant returns (address[]) {
        return buckets[bucket].ticketHolders;
    }

    function getLastBlockHeight() constant returns (int) {
        return btcRelay.getLastBlockHeight();
    }

    function getOperatingBudget() constant returns (uint) {
        return this.balance - numTickets * TICKET_PRICE;
    }

    function checkDepth(uint n) constant returns (bool) {
        if (n == 0) return true;
        return checkDepth(n - 1);
    }

    function payoutReady() constant returns (bool) {
        return decidingBlock <= btcRelay.getLastBlockHeight();
    }

    function processPayout() returns (bool done) {
        if (!payoutReady()) throw;
        if (getOperatingBudget() < 1 ether) throw;
        if (numTickets == 0) throw;
        if (!checkDepth(8)) throw;

        var (walkingDone, blockHash) = walkTowardsBlock();
        if (!walkingDone) return false;

        int winnerIdx = blockHash % int(numTickets);
        address winner = lookupTicketHolder(uint(winnerIdx));
        uint fee = (numTickets * TICKET_PRICE) / FEE_FACTOR;
        uint amount = (numTickets * TICKET_PRICE) - fee;

        // keep some records
        payouts[payoutIdx].winner = winner;
        payouts[payoutIdx].amount = amount;
        payouts[payoutIdx].blockNumber = block.number;
        payouts[payoutIdx].timestamp = now;
        payouts[payoutIdx].processor = msg.sender;
        payoutIdx = (payoutIdx + 1) % 3;

        prepareLottery();   // prepare next round
        var _ = winner.send(amount);
        Activity();

        return true;
    }

    function walkTowardsBlock() internal returns (bool, int) {
        int blockHeight;
        int blockHash;
        if (nearestKnownBlock == 0) {
            blockHeight = btcRelay.getLastBlockHeight();
            blockHash = btcRelay.getBlockchainHead();
        } else {
            blockHeight = nearestKnownBlock;
            blockHash = nearestKnownBlockHash;
        }

        // Walk at most 5 steps to keep an upper limit on gas costs.
        for (uint steps = 0; steps < 5; steps++) {
            if (blockHeight == decidingBlock) {
                return (true, blockHash);
            }

            uint fee = uint(btcRelay.getFeeAmount(blockHash));
            bytes32 blockHeader =
                btcRelay.getBlockHeader.value(fee)(blockHash)[2];
            bytes32 temp;

            assembly {
                let x := mload(0x40)
                mstore(x, blockHeader)
                temp := mload(add(x, 0x04))
            }

            blockHeight -= 1;
            blockHash = 0;
            for (int i = 0; i < 32; i++) {
                blockHash = blockHash | int(temp[uint(i)]) * (256 ** i);
            }
        }

        // Store the progress to pick up from there next time.
        nearestKnownBlock = blockHeight;
        nearestKnownBlockHash = blockHash;

        return (false, 0);
    }

    function accessOperatingBudget(uint amount) onlyOwner {
        if (getOperatingBudget() < 1 ether) throw;

        uint safeToAccess = getOperatingBudget() - 1 ether;
        if (amount > safeToAccess) throw;

        var _ = owner.send(amount);
    }

    function setOwner(address _owner) onlyOwner {
        owner = _owner;
    }
}