// `interface` would make a nice keyword ;)
contract TheDaoHardForkOracle {
    // `ran()` manually verified true on both ETH and ETC chains
    function forked() constant returns (bool);
}

// demostrates calling own function in a "reversible" manner
/* important lines are marked by multi-line comments */
contract ReversibleDemo {
    // counters (all public to simplify inspection)
    uint public numcalls;
    uint public numcallsinternal;

    address owner;

    // needed for "naive" and "oraclized" checks
    address constant withdrawdaoaddr = 0xbf4ed7b27f1d666546e30d74d50d173d20bca754;
    TheDaoHardForkOracle oracle = TheDaoHardForkOracle(0xe8e506306ddb78ee38c9b0d86c257bd97c2536b3);

    event logCall(uint indexed _numcalls, uint indexed _numcallsinternal);

    modifier onlyOwner { if (msg.sender != owner) throw; _ }
    modifier onlyThis { if (msg.sender != address(this)) throw; _ }

    // constructor (setting `owner` allows later termination)
    function ReversibleDemo() { owner = msg.sender; }

    /* external: increments stack height */
    /* onlyThis: prevent actual external calling */
    function sendIfNotForked() external onlyThis returns (bool) {
        numcallsinternal++;

        /* naive check for "is this the classic chain" */
        // guaranteed `true`: enough has been withdrawn already
        //     three million ------> 3'000'000
        if (withdrawdaoaddr.balance < 3000000 ether) {
            /* intentionally not checking return value */
            owner.send(42);
        }

        /* "reverse" if it's actually the HF chain */
        if (oracle.forked()) throw;

        // not exactly a "success": send() could have failed on classic
        return true;
    }

    // accepts value transfers
    function doCall(uint _gas) onlyOwner {
        numcalls++;

        // if it throws, there won't be any return value on the stack :/
        this.sendIfNotForked.gas(_gas)();

        logCall(numcalls, numcallsinternal);
    }

    function selfDestruct() onlyOwner {
        selfdestruct(owner);
    }

    // reject value trasfers
    function() { throw; }
}